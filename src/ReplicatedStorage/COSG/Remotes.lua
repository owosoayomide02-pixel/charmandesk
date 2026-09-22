--!strict
--[[
	Remote contract. Server creates these under ReplicatedStorage.COSGRemotes.
	Client never writes DataStores.
]]

local Remotes = {
	FolderName = "COSGRemotes",
	-- Client -> server
	PreparePurchase = "PreparePurchase", -- RemoteFunction(cosmeticId) -> { ok, productId?, err? }
	ClaimVoucher = "ClaimVoucher", -- RemoteFunction(cosmeticId) -> { ok, err? }
	ClickBatch = "ClickBatch", -- RemoteEvent({ clicks, crits, comboPeak })
	BuyUpgrade = "BuyUpgrade", -- RemoteFunction("click"|operatorId) -> { ok, err? }
	Prestige = "Prestige", -- RemoteFunction() -> { ok, err? }
	Equip = "Equip", -- RemoteFunction(cosmeticId) -> { ok, err? }
	ClaimQuest = "ClaimQuest", -- RemoteFunction() all-three bonus
	StudioBuy = "StudioBuy", -- RemoteFunction(cosmeticId) Studio only while product IDs are 0
	-- Server -> client
	ProfileSync = "ProfileSync",
	Toast = "Toast",
}

return Remotes
