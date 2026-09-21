--!strict
--[[
	Wires remotes and ProcessReceipt. Play/Shop UI comes next.
	Paste Creator Hub IDs into ReplicatedStorage.COSG.Products before any live purchase.
]]

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local COSG = require(RS:WaitForChild("COSG"))

local Profile = require(script.Parent.Data.Profile)
local Receipts = require(script.Parent.Data.Receipts)
local ClickEconomy = require(script.Parent.Data.ClickEconomy)

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
local ClickBatch = ensure("RemoteEvent", Remotes.ClickBatch) :: RemoteEvent

Profile.bind()
Receipts.bind()

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

ClickBatch.OnServerEvent:Connect(function(player, batch)
	ClickEconomy.apply(player.UserId, batch)
end)

Players.PlayerRemoving:Connect(function(player)
	ClickEconomy.release(player.UserId)
end)

if not COSG.Products.isConfigured() then
	warn("[COSG] Products.lua still has 0 IDs. Purchases will return product_unconfigured.")
end
