--!strict
--[[
	Session mutations. Studio DataStore failures stay in memory so Play Solo works.
]]

local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local COSG = require(RS:WaitForChild("COSG"))

local Catalog = COSG.Catalog
local Config = COSG.Config
local Economy = COSG.Economy
local Operators = COSG.Operators
local Products = COSG.Products
local ShopRotation = COSG.ShopRotation

local Grants = require(script.Parent.Grants)
local Profile = require(script.Parent.Profile)

local Game = {}

local function now(): number
	return os.time()
end

function Game.snapshot(profile: any): { [string]: any }
	local snap = Economy.snapshot(profile)
	snap.studioShop = RunService:IsStudio() and not Products.isConfigured()
	return snap
end

function Game.sync(player: Player)
	local data = Profile.getCached(player.UserId)
	if not data then
		return
	end
	local folder = RS:FindFirstChild(COSG.Remotes.FolderName)
	if not folder then
		return
	end
	local ev = folder:FindFirstChild(COSG.Remotes.ProfileSync)
	if ev and ev:IsA("RemoteEvent") then
		ev:FireClient(player, Game.snapshot(data))
	end
end

function Game.buyUpgrade(userId: number, kind: string): (boolean, string?)
	local data = Profile.getCached(userId)
	if not data then
		return false, "no_session"
	end
	Grants.idle(data, now())
	if kind == "click" then
		local cost = Economy.clickCost(data.clickLevel)
		if data.glint < cost then
			return false, "poor"
		end
		data.glint -= cost
		data.clickLevel += 1
		return true, nil
	end
	local def = Operators.get(kind)
	if not def or not def.launch then
		return false, "unknown_op"
	end
	if data.runEarned < def.unlockRunEarned then
		return false, "locked"
	end
	local owned = data.operators[kind] or 0
	local cost = Economy.operatorCost(kind, owned)
	if not cost or data.glint < cost then
		return false, "poor"
	end
	data.glint -= cost
	data.operators[kind] = owned + 1
	return true, nil
end

function Game.prestige(userId: number): (boolean, string?)
	local data = Profile.getCached(userId)
	if not data then
		return false, "no_session"
	end
	local need = Economy.prestigeNeed(data.prestigeLevel + 1)
	if not need then
		return false, "max"
	end
	if data.runEarned < need then
		return false, "need"
	end
	local nextP = data.prestigeLevel + 1
	data.glint = 0
	data.runEarned = 0
	data.clickLevel = 0
	for id in data.operators do
		data.operators[id] = 0
	end
	data.prestigeLevel = nextP
	data.shards += Economy.shardGrant(nextP)
	data.stats.prestiges += 1
	data.lastIdleAt = now()
	return true, nil
end

function Game.equip(userId: number, cosmeticId: string): (boolean, string?)
	local data = Profile.getCached(userId)
	if not data then
		return false, "no_session"
	end
	if cosmeticId == "" then
		return false, "bad_id"
	end
	if not Grants.owns(data, cosmeticId) then
		return false, "unowned"
	end
	local row = Catalog.get(cosmeticId)
	if not row then
		return false, "unknown_id"
	end
	local slot = row.type
	if slot == "operator" then
		slot = "operator"
	end
	data.equipped[slot] = cosmeticId
	return true, nil
end

function Game.studioBuy(userId: number, cosmeticId: string): (boolean, string?)
	if not RunService:IsStudio() then
		return false, "studio_only"
	end
	if Products.isConfigured() then
		return false, "live_products"
	end
	local week = ShopRotation.weekIndex(now())
	local ok, why = Catalog.assertPurchasable(cosmeticId, week)
	if not ok then
		return false, why
	end
	if not ShopRotation.isListed(cosmeticId, now()) then
		return false, "not_listed"
	end
	local data = Profile.getCached(userId)
	if not data then
		return false, "no_session"
	end
	Grants.cosmetic(data, cosmeticId, "studio", now())
	return true, nil
end

return Game
