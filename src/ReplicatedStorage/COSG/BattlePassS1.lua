--!strict
--[[
	Season 1: 50 tiers. Free cosmetics: 8. Premium cosmetics: 18 unique IDs.
	Do not launch this on day 1. Wire it in live week 3.
]]

export type Reward = {
	kind: "cosmetic" | "glint" | "shards" | "booster",
	id: string?,
	amount: number?,
}

export type Tier = {
	tier: number,
	free: Reward?,
	premium: Reward?,
}

local function cos(id: string): Reward
	return { kind = "cosmetic", id = id }
end

local function glint(n: number): Reward
	return { kind = "glint", amount = n }
end

local function shards(n: number): Reward
	return { kind = "shards", amount = n }
end

local function boost(): Reward
	return { kind = "booster", amount = 7200 }
end

local freeAt: { [number]: Reward } = {
	[1] = cos("trail_s1_freeglint"),
	[8] = glint(2500),
	[16] = cos("comp_mini_spark"),
	[24] = glint(8000),
	[32] = cos("frame_s1_ticket"),
	[40] = glint(20000),
	[46] = cos("theme_pastel_grid"),
	[50] = shards(15),
}

local premiumAt: { [number]: Reward } = {
	[1] = glint(3000),
	[3] = cos("trail_click_stickerstars"),
	[5] = cos("op_sparkpup_lantern"),
	[7] = boost(),
	[10] = shards(8),
	[12] = cos("trail_s1_neonstitch"),
	[14] = glint(12000),
	[16] = cos("comp_s1_pocketbell"),
	[18] = boost(),
	[20] = cos("sound_keyboard_clack"),
	[22] = glint(18000),
	[25] = cos("finish_love_letter"),
	[28] = shards(12),
	[30] = cos("sound_s1_choirhit"),
	[33] = glint(25000),
	[36] = cos("op_pixelbee_dj"),
	[40] = cos("theme_s1_paperlantern"),
	[44] = boost(),
	[45] = cos("finish_s1_stamp"),
	[47] = cos("comp_moon_rabbit"),
	[50] = cos("frame_rank_ribbon"),
}

local tiers: { Tier } = {}
for t = 1, 50 do
	tiers[t] = {
		tier = t,
		free = freeAt[t],
		premium = premiumAt[t],
	}
end

local BattlePassS1 = {
	season = 1,
	tiers = tiers,
	xpPerTier = 1000,
}

function BattlePassS1.tierForXp(xp: number): number
	return math.clamp(math.floor(xp / BattlePassS1.xpPerTier), 0, 50)
end

return BattlePassS1
