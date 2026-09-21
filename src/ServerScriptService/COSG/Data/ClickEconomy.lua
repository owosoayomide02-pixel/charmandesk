--!strict
--[[
	Client predicts FX. Server grants Glint from a compact batch.
	Do not kick on low interval variance — mobile taps are regular and kids get banned.
	Cap and discard. Persist nothing about individual clicks.
]]

local RS = game:GetService("ReplicatedStorage")
local COSG = require(RS:WaitForChild("COSG"))

local Config = COSG.Config
local ProfileTemplate = COSG.ProfileTemplate

local Grants = require(script.Parent.Grants)
local Profile = require(script.Parent.Profile)

export type Batch = {
	clicks: number,
	crits: number,
	comboPeak: number,
}

local lastBatchAt: { [number]: number } = {}

local function comboMult(peak: number): number
	if peak >= 40 then
		return 2.5
	elseif peak >= 20 then
		return 2.0
	elseif peak >= 10 then
		return 1.5
	elseif peak >= 5 then
		return 1.25
	end
	return 1
end

local ClickEconomy = {}

function ClickEconomy.apply(userId: number, batch: Batch): (boolean, string?)
	if type(batch) ~= "table" then
		return false, "bad_batch"
	end
	local clicks = math.floor(tonumber(batch.clicks) or 0)
	local crits = math.floor(tonumber(batch.crits) or 0)
	local comboPeak = math.floor(tonumber(batch.comboPeak) or 0)
	if clicks < 1 or clicks > Config.Click.MaxPerBatch then
		return false, "click_cap"
	end
	if crits < 0 or crits > clicks then
		return false, "crit_cap"
	end
	local critMax = math.ceil(clicks * Config.Click.CritChanceCap) + 1
	if crits > critMax then
		crits = critMax
	end
	if comboPeak < 0 then
		comboPeak = 0
	end
	if comboPeak > clicks then
		comboPeak = clicks
	end

	local now = os.clock()
	local prev = lastBatchAt[userId]
	if prev and (now - prev) < Config.Click.MinBatchGap then
		return false, "too_fast"
	end
	lastBatchAt[userId] = now

	local data = Profile.getCached(userId)
	if not data then
		return false, "no_session"
	end

	local power = ProfileTemplate.clickPower(
		data.clickLevel,
		data.prestigeLevel,
		data.shardSpent.glint_boost_2pct or 0
	)
	local perClick = power * comboMult(comboPeak)
	local normal = clicks - crits
	local gain = math.floor(normal * perClick + crits * perClick * Config.Click.CritClickMultiplier)
	if os.time() < (data.boosterUntil or 0) then
		gain = math.floor(gain * 1.25)
	end

	Grants.idle(data, os.time())
	Grants.glint(data, gain)
	data.stats.clicks += clicks
	data.stats.crits += crits
	return true, nil
end

function ClickEconomy.release(userId: number)
	lastBatchAt[userId] = nil
end

return ClickEconomy
