--!strict

local Rarity = {}

Rarity.Order = { "common", "uncommon", "rare", "epic", "legendary", "ultra", "mythic", "celestial" }

Rarity.PriceRobux = {
	common = 49,
	uncommon = 199,
	rare = 499,
	epic = 1299,
	legendary = 2499,
	ultra = 4499,
	mythic = 9999,
	celestial = 14999,
}

Rarity.Group = {
	common = "low",
	uncommon = "low",
	rare = "low",
	epic = "mid",
	legendary = "mid",
	ultra = "high",
	mythic = "high",
	celestial = "high",
}

function Rarity.price(rarity: string): number
	local n = Rarity.PriceRobux[rarity]
	assert(n, "unknown rarity " .. tostring(rarity))
	return n
end

-- Player USD at 800 R$ = $9.99. Studio = 70% Robux * $0.0035 DevEx.
function Rarity.playerUsd(robux: number): number
	return math.floor(robux * (9.99 / 800) * 100 + 0.5) / 100
end

function Rarity.studioUsd(robux: number): number
	return math.floor(robux * 0.7 * 0.0035 * 100 + 0.5) / 100
end

return Rarity
