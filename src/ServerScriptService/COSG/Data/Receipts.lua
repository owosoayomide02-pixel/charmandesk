--!strict
--[[
	Roblox ProcessReceipt does NOT include a cosmeticId.
	Client must call PreparePurchase first. Server stores pendingBuy.
	If pending is missing/expired, grant a price-tier voucher instead of eating Robux.
]]

local MarketplaceService = game:GetService("MarketplaceService")
local RS = game:GetService("ReplicatedStorage")
local COSG = require(RS:WaitForChild("COSG"))

local Catalog = COSG.Catalog
local Config = COSG.Config
local Products = COSG.Products
local ShopRotation = COSG.ShopRotation

local Grants = require(script.Parent.Grants)
local Profile = require(script.Parent.Profile)

local Receipts = {}

export type PrepareResult = { ok: boolean, productId: number?, err: string? }

function Receipts.prepare(userId: number, cosmeticId: string): PrepareResult
	local row = Catalog.get(cosmeticId)
	if not row then
		return { ok = false, err = "unknown_id" }
	end
	local week = ShopRotation.weekIndex(os.time())
	local ok, why = Catalog.assertPurchasable(cosmeticId, week)
	if not ok then
		return { ok = false, err = why }
	end
	if not ShopRotation.isListed(cosmeticId, os.time()) then
		return { ok = false, err = "not_listed" }
	end
	local productId = Products.tierId(row.priceRobux)
	if productId == 0 then
		return { ok = false, err = "product_unconfigured" }
	end

	local saved, err = Profile.update(userId, function(data)
		if Grants.owns(data, cosmeticId) then
			error("already_owned")
		end
		data.pendingBuy = {
			cosmeticId = cosmeticId,
			productId = productId,
			at = os.time(),
		}
	end)
	if not saved then
		if err and string.find(err, "already_owned", 1, true) then
			return { ok = false, err = "already_owned" }
		end
		return { ok = false, err = "datastore" }
	end
	return { ok = true, productId = productId }
end

function Receipts.claimVoucher(userId: number, cosmeticId: string): PrepareResult
	local row = Catalog.get(cosmeticId)
	if not row or row.priceRobux <= 0 then
		return { ok = false, err = "unknown_id" }
	end
	local key = tostring(row.priceRobux)
	local saved, err = Profile.update(userId, function(data)
		local n = data.vouchers[key] or 0
		if n < 1 then
			error("no_voucher")
		end
		if Grants.owns(data, cosmeticId) then
			error("already_owned")
		end
		local week = ShopRotation.weekIndex(os.time())
		local purchasable, why = Catalog.assertPurchasable(cosmeticId, week)
		if not purchasable and why ~= "not_in_window" then
			-- vouchers can claim evergreen of that tier anytime
			if row.shopWindow ~= "evergreen" then
				error(why or "not_for_sale")
			end
		end
		if row.shopWindow ~= "evergreen" and row.shopWindow ~= "limited" then
			error("not_for_sale")
		end
		data.vouchers[key] = n - 1
		Grants.cosmetic(data, cosmeticId, "voucher", os.time())
	end)
	if not saved then
		return { ok = false, err = err or "datastore" }
	end
	return { ok = true }
end

local function applyReceipt(data: any, receipt, route): boolean
	local purchaseId = receipt.PurchaseId
	if data.receipts[purchaseId] then
		return true
	end

	local now = os.time()
	local cosmeticId: string? = nil

	if route.kind == "cosmetic" then
		local pending = data.pendingBuy
		local fresh = pending
			and pending.productId == receipt.ProductId
			and (now - pending.at) <= Config.PENDING_BUY_TTL
			and type(pending.cosmeticId) == "string"
		if fresh then
			local row = Catalog.get(pending.cosmeticId)
			if row and row.priceRobux == route.price then
				cosmeticId = pending.cosmeticId
				Grants.cosmetic(data, cosmeticId, "robux", now)
			else
				local key = tostring(route.price)
				data.vouchers[key] = (data.vouchers[key] or 0) + 1
			end
		else
			local key = tostring(route.price)
			data.vouchers[key] = (data.vouchers[key] or 0) + 1
		end
		data.pendingBuy = nil
	elseif route.kind == "starter" then
		Grants.starter(data, now)
	elseif route.kind == "battlepass" then
		Grants.battlePass(data, now)
	elseif route.kind == "bundle" then
		Grants.seasonBundle(data, now)
	end

	data.receipts[purchaseId] = true
	data.purchases[purchaseId] = {
		productId = receipt.ProductId,
		cosmeticId = cosmeticId,
		at = now,
		kind = route.kind,
	}
	return true
end

function Receipts.process(receipt): Enum.ProductPurchaseDecision
	local route = Products.route(receipt.ProductId)
	if not route then
		warn("[COSG] unknown product", receipt.ProductId)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- CurrencySpent is Robux paid. Do not read receipt.Price or receipt.CosmeticId — they do not exist.
	if receipt.CurrencySpent ~= nil and receipt.CurrencySpent > 0 and receipt.CurrencySpent ~= route.price then
		warn("[COSG] currency mismatch", receipt.ProductId, receipt.CurrencySpent, route.price)
	end

	local saved, err = Profile.update(receipt.PlayerId, function(data)
		applyReceipt(data, receipt, route)
	end)
	if saved then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
	warn("[COSG] receipt save failed", err)
	return Enum.ProductPurchaseDecision.NotProcessedYet
end

function Receipts.bind()
	MarketplaceService.ProcessReceipt = Receipts.process
end

return Receipts
