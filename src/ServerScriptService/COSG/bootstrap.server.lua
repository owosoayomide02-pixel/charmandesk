--!strict
--[[
	Wires remotes, ProcessReceipt, Play Solo memory profiles.
	Product IDs stay 0 until Creator Hub; StudioBuy grants shop items in Studio only.
]]

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local COSG = require(RS:WaitForChild("COSG"))

local Profile = require(script.Parent.Data.Profile)
local Receipts = require(script.Parent.Data.Receipts)
local ClickEconomy = require(script.Parent.Data.ClickEconomy)
local Game = require(script.Parent.Data.Game)

local Remotes = COSG.Remotes

local folder = RS:FindFirstChild(Remotes.FolderName)
if not folder then
	folder = Instance.new("Folder")
	folder.Name = Remotes.FolderName
	folder.Parent = RS
end

local function ensure(className: string, name: string): Instance
	local existing = folder:FindFirstChild(name)
	if existing then
		return existing
	end
	local inst = Instance.new(className)
	inst.Name = name
	inst.Parent = folder
	return inst
end

local PreparePurchase = ensure("RemoteFunction", Remotes.PreparePurchase) :: RemoteFunction
local ClaimVoucher = ensure("RemoteFunction", Remotes.ClaimVoucher) :: RemoteFunction
local BuyUpgrade = ensure("RemoteFunction", Remotes.BuyUpgrade) :: RemoteFunction
local Prestige = ensure("RemoteFunction", Remotes.Prestige) :: RemoteFunction
local Equip = ensure("RemoteFunction", Remotes.Equip) :: RemoteFunction
local StudioBuy = ensure("RemoteFunction", Remotes.StudioBuy) :: RemoteFunction
local ClickBatch = ensure("RemoteEvent", Remotes.ClickBatch) :: RemoteEvent
ensure("RemoteEvent", Remotes.ProfileSync)
ensure("RemoteEvent", Remotes.Toast)

local function reply(player: Player, ok: boolean, err: string?): { ok: boolean, err: string?, snap: any? }
	if ok then
		Game.sync(player)
		local data = Profile.getCached(player.UserId)
		return { ok = true, snap = if data then Game.snapshot(data) else nil }
	end
	return { ok = false, err = err }
end

Profile.bind()
Receipts.bind()

local function onPlayer(player: Player)
	task.defer(function()
		if not Profile.getCached(player.UserId) then
			Profile.load(player.UserId)
		end
		Game.sync(player)
	end)
end

Players.PlayerAdded:Connect(onPlayer)
for _, player in Players:GetPlayers() do
	onPlayer(player)
end

PreparePurchase.OnServerInvoke = function(player, cosmeticId)
	if type(cosmeticId) ~= "string" then
		return { ok = false, err = "bad_id" }
	end
	return Receipts.prepare(player.UserId, cosmeticId)
end

ClaimVoucher.OnServerInvoke = function(player, cosmeticId)
	if type(cosmeticId) ~= "string" then
		return { ok = false, err = "bad_id" }
	end
	return Receipts.claimVoucher(player.UserId, cosmeticId)
end

BuyUpgrade.OnServerInvoke = function(player, kind)
	if type(kind) ~= "string" then
		return { ok = false, err = "bad_kind" }
	end
	return reply(player, Game.buyUpgrade(player.UserId, kind))
end

Prestige.OnServerInvoke = function(player)
	return reply(player, Game.prestige(player.UserId))
end

Equip.OnServerInvoke = function(player, cosmeticId)
	if type(cosmeticId) ~= "string" then
		return { ok = false, err = "bad_id" }
	end
	return reply(player, Game.equip(player.UserId, cosmeticId))
end

StudioBuy.OnServerInvoke = function(player, cosmeticId)
	if type(cosmeticId) ~= "string" then
		return { ok = false, err = "bad_id" }
	end
	return reply(player, Game.studioBuy(player.UserId, cosmeticId))
end

ClickBatch.OnServerEvent:Connect(function(player, batch)
	local ok = ClickEconomy.apply(player.UserId, batch)
	if ok then
		Game.sync(player)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	ClickEconomy.release(player.UserId)
end)

task.spawn(function()
	while true do
		task.wait(COSG.Config.AutosaveSeconds)
		for _, player in Players:GetPlayers() do
			Profile.save(player.UserId)
		end
	end
end)

if not COSG.Products.isConfigured() then
	warn("[COSG] Product IDs are 0. Studio shop grants are on. Create Creator Hub products before a public Robux test.")
end
