--!strict
--[[
	Procedural Charmdesk look. Real vinyl art replaces these Color3 tokens later.
]]

local Appearance = {}

local RARITY: { [string]: Color3 } = {
	common = Color3.fromRGB(244, 233, 216),
	uncommon = Color3.fromRGB(126, 200, 163),
	rare = Color3.fromRGB(91, 163, 214),
	epic = Color3.fromRGB(107, 91, 149),
	legendary = Color3.fromRGB(230, 184, 77),
	ultra = Color3.fromRGB(224, 122, 95),
	mythic = Color3.fromRGB(186, 148, 255),
	celestial = Color3.fromRGB(255, 236, 179),
}

local THEME: { [string]: Color3 } = {
	theme_bedroom_desk = Color3.fromRGB(26, 21, 35),
	theme_pastel_grid = Color3.fromRGB(58, 48, 72),
	theme_graph_grid = Color3.fromRGB(36, 42, 48),
	theme_lofi_room = Color3.fromRGB(42, 28, 38),
	theme_candy_shop = Color3.fromRGB(72, 36, 52),
	theme_deep_forest = Color3.fromRGB(18, 36, 28),
	theme_retro_arcade = Color3.fromRGB(22, 18, 48),
	theme_origami_room = Color3.fromRGB(48, 40, 36),
	theme_jade_moon = Color3.fromRGB(20, 40, 42),
	theme_neon_campus = Color3.fromRGB(18, 24, 48),
	theme_veil_midnight = Color3.fromRGB(12, 10, 22),
	theme_s1_paperlantern = Color3.fromRGB(48, 24, 28),
}

local TRAIL: { [string]: Color3 } = {
	trail_click_firstspark = Color3.fromRGB(230, 184, 77),
	trail_click_sparkdust = Color3.fromRGB(255, 220, 140),
	trail_click_bubblepop = Color3.fromRGB(140, 210, 255),
	trail_click_neonpulse = Color3.fromRGB(80, 255, 210),
	trail_click_rainbowribbon = Color3.fromRGB(255, 120, 180),
}

Appearance.Ink = Color3.fromRGB(26, 21, 35)
Appearance.InkRaised = Color3.fromRGB(36, 28, 48)
Appearance.Cream = Color3.fromRGB(244, 233, 216)
Appearance.Gold = Color3.fromRGB(230, 184, 77)
Appearance.Mint = Color3.fromRGB(126, 200, 163)
Appearance.Coral = Color3.fromRGB(224, 122, 95)
Appearance.Muted = Color3.fromRGB(203, 187, 166)

function Appearance.rarity(rarity: string): Color3
	return RARITY[rarity] or Appearance.Cream
end

function Appearance.theme(id: string): Color3
	return THEME[id] or Appearance.Ink
end

function Appearance.trail(id: string): Color3
	if TRAIL[id] then
		return TRAIL[id]
	end
	local n = 0
	for i = 1, #id do
		n += string.byte(id, i)
	end
	return Color3.fromHSV((n % 360) / 360, 0.45, 0.92)
end

return Appearance
