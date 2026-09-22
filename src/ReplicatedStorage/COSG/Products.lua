--!strict
--[[
	Create these in Creator Hub → Monetization → Passes & Products, then paste IDs.

	Name                         Price    Field
	Charmdesk Common             49       Tiers[49]
	Charmdesk Uncommon           199      Tiers[199]
	Charmdesk Rare               499      Tiers[499]
	Charmdesk Epic               1299     Tiers[1299]
	Charmdesk Legendary          2499     Tiers[2499]
	Charmdesk Ultra              4499     Tiers[4499]
	Charmdesk Mythic             9999     Tiers[9999]
	Charmdesk Celestial          14999    Tiers[14999]
	Charmdesk Starter Bundle     199      Starter          (different id from Uncommon)
	Charmdesk Battle Pass        799      BattlePass
	Charmdesk Season Bundle      2499     SeasonBundle     (different id from Legendary)
	Charmdesk VIP                399      VipGamePass      (Game Pass, not a product)

	Until IDs are pasted, Studio Play Solo uses StudioBuy (free test grants).
	Live servers will not grant cosmetics for Robux until IDs are set.
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
