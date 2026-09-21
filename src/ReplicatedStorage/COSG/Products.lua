--!strict
--[[
	Create these in Creator Hub, then paste numeric IDs here.
	Eight cosmetic tiers + three specials. VIP is a GamePass, not ProcessReceipt.

	DO NOT create one product per cosmetic.
]]

export type Route = {
	kind: "cosmetic" | "starter" | "battlepass" | "bundle",
	price: number,
	productId: number,
}

local Products = {
	-- Replace every 0 with the Creator Hub product id before first purchase test.
	Tiers = {
		[49] = 0,
		[199] = 0,
		[499] = 0,
		[1299] = 0,
		[2499] = 0,
		[4499] = 0,
		[9999] = 0,
		[14999] = 0,
	},
	Starter = 0, -- 199 R$, once per account — MUST be a different id than Tiers[199]
	BattlePass = 0, -- 799 R$, once per season
	SeasonBundle = 0, -- 2499 R$, MUST be a different id than Tiers[2499]
	VipGamePass = 0, -- 399 R$ GamePass
}

local byProductId: { [number]: Route } = {}

local function add(kind: "cosmetic" | "starter" | "battlepass" | "bundle", price: number, productId: number)
	if productId == 0 then
		return
	end
	assert(byProductId[productId] == nil, "duplicate product id " .. tostring(productId))
	byProductId[productId] = { kind = kind, price = price, productId = productId }
end

function Products.rebuild()
	table.clear(byProductId)
	for price, id in Products.Tiers do
		add("cosmetic", price, id)
	end
	add("starter", 199, Products.Starter)
	add("battlepass", 799, Products.BattlePass)
	add("bundle", 2499, Products.SeasonBundle)
end

function Products.route(productId: number): Route?
	return byProductId[productId]
end

function Products.tierId(priceRobux: number): number
	local id = Products.Tiers[priceRobux]
	assert(id ~= nil, "no tier for " .. tostring(priceRobux))
	return id
end

function Products.isConfigured(): boolean
	for _, id in Products.Tiers do
		if id == 0 then
			return false
		end
	end
	return Products.Starter ~= 0
end

Products.rebuild()

return Products
