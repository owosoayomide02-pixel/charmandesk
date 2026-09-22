--!strict

local RS = game:GetService("ReplicatedStorage")
local COSG = require(RS:WaitForChild("COSG"))

local Catalog = COSG.Catalog
local Config = COSG.Config
local Operators = COSG.Operators
local ProfileTemplate = COSG.ProfileTemplate

local Grants = {}

function Grants.owns(profile: any, id: string): boolean
	return profile.cosmetics[id] ~= nil
end

function Grants.cosmetic(profile: any, id: string, src: string, now: number): boolean
	if Grants.owns(profile, id) then
		profile.shards = (profile.shards or 0) + 5
		return false
	end
	if not Catalog.get(id) then
		return false
	end
	profile.cosmetics[id] = { at = now, src = src }
	return true
end

function Grants.glint(profile: any, amount: number)
	if amount <= 0 then
		return
	end
	profile.glint += amount
	profile.runEarned += amount
	profile.lifetimeEarned += amount
end

function Grants.starter(profile: any, now: number)
	if profile.flags.starter then
		return
	end
	profile.flags.starter = true
	for _, id in Config.Starter.Grants do
		Grants.cosmetic(profile, id, "starter", now)
	end
end

function Grants.seasonBundle(profile: any, now: number)
	for _, id in Config.SeasonBundle.Grants do
		Grants.cosmetic(profile, id, "bundle", now)
	end
end

function Grants.battlePass(profile: any, now: number)
	if profile.battlePass.season ~= Config.BattlePass.Season then
		profile.battlePass.season = Config.BattlePass.Season
		profile.battlePass.xp = 0
		profile.battlePass.tier = 0
		profile.battlePass.claimed = {}
	end
	profile.battlePass.premium = true
	profile.battlePass.premiumAt = now
end

function Grants.idle(profile: any, now: number)
	local last = profile.lastIdleAt or now
	local dt = math.clamp(now - last, 0, 8 * 60 * 60)
	profile.lastIdleAt = now
	if dt <= 0 then
		return 0
	end
	local cps = 0
	for opId, count in profile.operators do
		local def = Operators.get(opId)
		if def and count > 0 then
			cps += def.baseCps * count
		end
	end
	local prestige = ProfileTemplate.prestigeMultiplier(profile.prestigeLevel)
	local shard = 1 + 0.02 * (profile.shardSpent.glint_boost_2pct or 0)
	local boost = if now < (profile.boosterUntil or 0) then 1.25 else 1
	local amount = math.floor(cps * dt * prestige * shard * boost)
	Grants.glint(profile, amount)
	Grants.chapters(profile, now)
	return amount
end

function Grants.chapters(profile: any, now: number)
	for _, ch in Config.Chapters do
		local key = tostring(ch.id)
		if profile.runEarned >= ch.runEarned and not profile.chapters[key] then
			profile.chapters[key] = true
			Grants.cosmetic(profile, ch.grantId, "chapter", now)
		end
	end
end

return Grants
