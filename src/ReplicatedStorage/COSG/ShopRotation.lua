--!strict
--[[
	One limited listing per week, Wednesday 00:00 UTC.
	Week index is computed from Config.SHOP_EPOCH_UNIX, not calendar folklore.
]]

local Config = require(script.Parent.Config)
local Catalog = require(script.Parent.Catalog)

local WEEKLY: { [number]: string } = {
	[1] = "comp_snowglobe",
	[2] = "trail_click_firstlight",
	[3] = "op_sparkpup_bee_costume",
	[4] = "trail_click_firecracker",
	[5] = "theme_jade_moon",
	[6] = "frame_red_envelope",
	[7] = "comp_koi",
	[8] = "trail_click_rosepetal",
	[12] = "trail_click_galaxydust",
	[27] = "theme_neon_campus",
	[40] = "comp_ghost",
	[41] = "theme_veil_midnight",
	[42] = "finish_midnight_bell",
	[52] = "trail_click_celestialaurora",
}

-- Weeks without a named drop still need a listing. Cycle the designed set.
local FALLBACK = {
	"comp_snowglobe",
	"trail_click_firstlight",
	"op_sparkpup_bee_costume",
	"trail_click_firecracker",
	"theme_jade_moon",
	"frame_red_envelope",
	"comp_koi",
	"trail_click_rosepetal",
}

local ShopRotation = {}

function ShopRotation.weekIndex(unix: number): number
	if unix < Config.SHOP_EPOCH_UNIX then
		return 1
	end
	local elapsed = unix - Config.SHOP_EPOCH_UNIX
	return (math.floor(elapsed / Config.SHOP_WEEK_SECONDS) % 52) + 1
end

function ShopRotation.weekEndsAt(unix: number): number
	local week = ShopRotation.weekIndex(unix)
	local start = Config.SHOP_EPOCH_UNIX + (week - 1) * Config.SHOP_WEEK_SECONDS
	-- If we wrapped a year, still return the current window end from epoch cycle.
	local cycles = math.max(0, math.floor((unix - Config.SHOP_EPOCH_UNIX) / Config.SHOP_WEEK_SECONDS))
	return Config.SHOP_EPOCH_UNIX + (cycles + 1) * Config.SHOP_WEEK_SECONDS
end

function ShopRotation.currentId(unix: number): string
	local week = ShopRotation.weekIndex(unix)
	return WEEKLY[week] or FALLBACK[((week - 1) % #FALLBACK) + 1]
end

function ShopRotation.current(unix: number)
	return Catalog.get(ShopRotation.currentId(unix))
end

function ShopRotation.isListed(cosmeticId: string, unix: number): boolean
	local row = Catalog.get(cosmeticId)
	if not row then
		return false
	end
	if row.shopWindow == "evergreen" then
		return true
	end
	if row.shopWindow == "limited" then
		return ShopRotation.currentId(unix) == cosmeticId
	end
	return false
end

return ShopRotation
