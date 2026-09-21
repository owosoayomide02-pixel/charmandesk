--!strict
--[[
	ID grammar (locked): {type}_{category}_{name}

	trail_{click|fx}_{name}
	op_{operator}_{skin}
	comp_{name}
	theme_{name}
	finish_{name}
	frame_{name}
	sound_{name}

	Source of truth for price, rarity, shop window. Not a DataStore.
	Live rotation is ShopRotation.lua over these IDs.
]]

local Rarity = require(script.Parent.Rarity)

export type Cosmetic = {
	id: string,
	name: string,
	type: string,
	rarity: string,
	priceRobux: number,
	shopWindow: string, -- evergreen | limited | bp | default | prestige
	seasonWeek: number?, -- 1-52 if limited
	copyLimit: number?, -- celestial
	bpSeason: number?,
	bpTier: number?,
	bpTrack: string?, -- free | premium
	launch: boolean,
	operator: string?,
}

local function item(
	id: string,
	name: string,
	type_: string,
	rarity: string,
	window: string,
	extra: { [string]: any }?
): Cosmetic
	local price = if window == "default" or window == "prestige" or window == "bp" then 0 else Rarity.price(rarity)
	local row: Cosmetic = {
		id = id,
		name = name,
		type = type_,
		rarity = rarity,
		priceRobux = price,
		shopWindow = window,
		launch = extra and extra.launch == true or window == "evergreen" or window == "default",
		seasonWeek = extra and extra.seasonWeek or nil,
		copyLimit = extra and extra.copyLimit or nil,
		bpSeason = extra and extra.bpSeason or nil,
		bpTier = extra and extra.bpTier or nil,
		bpTrack = extra and extra.bpTrack or nil,
		operator = extra and extra.operator or nil,
	}
	return row
end

local list: { Cosmetic } = {
	-- Defaults (free, not in the 48)
	item("trail_click_firstspark", "First Spark", "trail", "common", "default"),
	item("theme_bedroom_desk", "Bedroom Desk", "theme", "common", "default"),
	item("sound_soft_taps", "Soft Taps", "sound", "common", "default"),
	item("finish_quiet_bow", "Quiet Bow", "finisher", "common", "prestige"),
	item("op_sparkpup_default", "Spark Pup", "operator", "common", "default", { operator = "sparkpup" }),
	item("op_neonkitten_default", "Neon Kitten", "operator", "common", "default", { operator = "neonkitten" }),
	item("op_pixelbee_default", "Pixel Bee", "operator", "common", "default", { operator = "pixelbee" }),
	item("op_crystalfox_default", "Crystal Fox", "operator", "common", "default", { operator = "crystalfox" }),
	item("op_prismdeer_default", "Prism Deer", "operator", "common", "default", { operator = "prismdeer" }),

	-- Launch shop: 20 Common
	item("trail_click_sparkdust", "Spark Dust", "trail", "common", "evergreen"),
	item("trail_click_bubblepop", "Bubble Pop", "trail", "common", "evergreen"),
	item("trail_click_pixelconfetti", "Pixel Confetti", "trail", "common", "evergreen"),
	item("trail_click_softglow", "Soft Glow", "trail", "common", "evergreen"),
	item("trail_click_pencilscribble", "Pencil Scribble", "trail", "common", "evergreen"),
	item("trail_click_pollencloud", "Pollen Cloud", "trail", "common", "evergreen"),
	item("trail_click_staticsnow", "Static Snow", "trail", "common", "evergreen"),
	item("trail_click_dewdrop", "Dewdrop", "trail", "common", "evergreen"),
	item("trail_click_tapflash", "Tap Flash", "trail", "common", "evergreen"),
	item("trail_click_pencilring", "Pencil Ring", "trail", "common", "evergreen"),
	item("comp_mini_spark", "Mini Spark", "companion", "common", "evergreen"),
	item("comp_floating_star", "Floating Star", "companion", "common", "evergreen"),
	item("comp_cursor_bug", "Cursor Bug", "companion", "common", "evergreen"),
	item("comp_marble_pet", "Marble Pet", "companion", "common", "evergreen"),
	item("theme_pastel_grid", "Pastel Grid", "theme", "common", "evergreen"),
	item("theme_graph_grid", "Graph Grid", "theme", "common", "evergreen"),
	item("finish_confetti_pop", "Confetti Pop", "finisher", "common", "evergreen"),
	item("finish_polaroid_snap", "Polaroid Snap", "finisher", "common", "evergreen"),
	item("frame_doodle", "Doodle Frame", "frame", "common", "evergreen"),
	item("sound_woodblock", "Woodblock", "sound", "common", "evergreen"),

	-- Launch shop: 12 Uncommon
	item("trail_click_stickerstars", "Sticker Stars", "trail", "uncommon", "evergreen"),
	item("trail_click_candysprinkle", "Candy Sprinkle", "trail", "uncommon", "evergreen"),
	item("trail_click_rainbowribbon", "Rainbow Ribbon", "trail", "uncommon", "evergreen"),
	item("trail_click_sodafizz", "Soda Fizz", "trail", "uncommon", "evergreen"),
	item("comp_paper_crane", "Paper Crane", "companion", "uncommon", "evergreen"),
	item("comp_tiny_slime", "Tiny Slime", "companion", "uncommon", "evergreen"),
	item("theme_lofi_room", "Lo-fi Room", "theme", "uncommon", "evergreen"),
	item("theme_candy_shop", "Candy Shop", "theme", "uncommon", "evergreen"),
	item("op_sparkpup_hoodie", "Spark Pup Hoodie", "operator", "uncommon", "evergreen", { operator = "sparkpup" }),
	item("op_pixelbee_dj", "DJ Bee", "operator", "uncommon", "evergreen", { operator = "pixelbee" }),
	item("frame_soft_gold", "Soft Gold Frame", "frame", "uncommon", "evergreen"),
	item("sound_keyboard_clack", "Keyboard Clack", "sound", "uncommon", "evergreen"),

	-- Launch shop: 10 Rare
	item("trail_click_neonpulse", "Neon Pulse", "trail", "rare", "evergreen"),
	item("trail_click_electricarc", "Electric Arc", "trail", "rare", "evergreen"),
	item("trail_click_holoscan", "Hologram Scanlines", "trail", "rare", "evergreen"),
	item("trail_click_blossomdrift", "Cherry Blossom Drift", "trail", "rare", "evergreen"),
	item("comp_firefly", "Firefly", "companion", "rare", "evergreen"),
	item("theme_deep_forest", "Deep Forest", "theme", "rare", "evergreen"),
	item("theme_retro_arcade", "Retro Arcade", "theme", "rare", "evergreen"),
	item("op_neonkitten_streetwear", "Street Cat", "operator", "rare", "evergreen", { operator = "neonkitten" }),
	item("op_crystalfox_armor", "Fox Armor", "operator", "rare", "evergreen", { operator = "crystalfox" }),
	item("sound_arcade_bleeps", "Arcade Bleeps", "sound", "rare", "evergreen"),

	-- Launch shop: 6 Epic
	item("trail_click_fireflyorbit", "Firefly Orbit", "trail", "epic", "evergreen"),
	item("trail_click_crystalshatter", "Crystal Shatter", "trail", "epic", "evergreen"),
	item("comp_moon_rabbit", "Moon Rabbit", "companion", "epic", "evergreen"),
	item("theme_origami_room", "Origami Room", "theme", "epic", "evergreen"),
	item("finish_origami_storm", "Origami Storm", "finisher", "epic", "evergreen"),
	item("op_prismdeer_flowercrown", "Flower Crown Deer", "operator", "epic", "evergreen", { operator = "prismdeer" }),

	-- Designed limiteds (not in the 48; shopWindow limited)
	item("comp_snowglobe", "Snowglobe", "companion", "rare", "limited", { seasonWeek = 1, launch = false }),
	item("trail_click_firstlight", "First Light", "trail", "uncommon", "limited", { seasonWeek = 2, launch = false }),
	item("op_sparkpup_bee_costume", "Bee Costume", "operator", "uncommon", "limited", { seasonWeek = 3, operator = "sparkpup", launch = false }),
	item("trail_click_firecracker", "Firecracker", "trail", "rare", "limited", { seasonWeek = 4, launch = false }),
	item("theme_jade_moon", "Jade Moon", "theme", "epic", "limited", { seasonWeek = 5, launch = false }),
	item("frame_red_envelope", "Red Envelope", "frame", "uncommon", "limited", { seasonWeek = 6, launch = false }),
	item("comp_koi", "Koi", "companion", "rare", "limited", { seasonWeek = 7, launch = false }),
	item("trail_click_rosepetal", "Rose Petal", "trail", "uncommon", "limited", { seasonWeek = 8, launch = false }),
	item("theme_neon_campus", "Neon Campus", "theme", "epic", "limited", { seasonWeek = 27, launch = false }),
	item("comp_ghost", "Ghost", "companion", "rare", "limited", { seasonWeek = 40, launch = false }),
	item("finish_midnight_bell", "Midnight Bell", "finisher", "legendary", "limited", { seasonWeek = 42, launch = false }),
	item("theme_veil_midnight", "Veil of Midnight", "theme", "mythic", "limited", { seasonWeek = 41, launch = false }),
	item("trail_click_galaxydust", "Galaxy Dust", "trail", "legendary", "limited", { seasonWeek = 12, launch = false }),
	item("trail_click_celestialaurora", "Celestial Aurora", "trail", "celestial", "limited", { seasonWeek = 52, copyLimit = 1000, launch = false }),

	-- Battle Pass S1 exclusives (price 0, never shop)
	item("frame_rank_ribbon", "Rank Ribbon", "frame", "legendary", "bp", { bpSeason = 1, bpTier = 50, bpTrack = "premium" }),
	item("finish_love_letter", "Love Letter", "finisher", "rare", "bp", { bpSeason = 1, bpTier = 25, bpTrack = "premium" }),
	item("op_sparkpup_lantern", "Lantern Pup", "operator", "uncommon", "bp", { bpSeason = 1, bpTier = 5, bpTrack = "premium", operator = "sparkpup" }),
	item("trail_s1_neonstitch", "Neon Stitch", "trail", "rare", "bp", { bpSeason = 1, bpTier = 12, bpTrack = "premium" }),
	item("comp_s1_pocketbell", "Pocket Bell", "companion", "uncommon", "bp", { bpSeason = 1, bpTier = 18, bpTrack = "premium" }),
	item("theme_s1_paperlantern", "Paper Lantern Room", "theme", "epic", "bp", { bpSeason = 1, bpTier = 40, bpTrack = "premium" }),
	item("sound_s1_choirhit", "Choir Hit", "sound", "rare", "bp", { bpSeason = 1, bpTier = 30, bpTrack = "premium" }),
	item("finish_s1_stamp", "Gold Stamp", "finisher", "epic", "bp", { bpSeason = 1, bpTier = 45, bpTrack = "premium" }),
	item("frame_s1_ticket", "Season Ticket", "frame", "rare", "bp", { bpSeason = 1, bpTier = 20, bpTrack = "free" }),
	item("trail_s1_freeglint", "Season Spark", "trail", "common", "bp", { bpSeason = 1, bpTier = 1, bpTrack = "free" }),
}

local byId: { [string]: Cosmetic } = {}
for _, row in list do
	assert(byId[row.id] == nil, "duplicate cosmetic " .. row.id)
	byId[row.id] = row
end

local Catalog = {}

function Catalog.get(id: string): Cosmetic?
	return byId[id]
end

function Catalog.all(): { Cosmetic }
	return list
end

function Catalog.launchShop(): { Cosmetic }
	local out = {}
	for _, row in list do
		if row.shopWindow == "evergreen" then
			table.insert(out, row)
		end
	end
	return out
end

function Catalog.isOwned(cosmetics: { [string]: any }, id: string): boolean
	return cosmetics[id] ~= nil
end

function Catalog.assertPurchasable(id: string, nowWeek: number): (boolean, string?)
	local row = byId[id]
	if not row then
		return false, "unknown_id"
	end
	if row.shopWindow == "default" or row.shopWindow == "prestige" or row.shopWindow == "bp" then
		return false, "not_for_sale"
	end
	if row.priceRobux <= 0 then
		return false, "not_for_sale"
	end
	if row.shopWindow == "limited" then
		if row.seasonWeek ~= nowWeek then
			return false, "not_in_window"
		end
	end
	return true, nil
end

return Catalog
