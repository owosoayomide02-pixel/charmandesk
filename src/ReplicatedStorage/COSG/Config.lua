--!strict
--[[
	Numeric and store-name truth. Product IDs live in Products.lua.
	Never rename a live DataStore; bump the suffix instead.
]]

local Config = {}

Config.SCHEMA_VERSION = 1
Config.GAME_CODE = "COSG"

Config.Stores = {
	Player = "COSG_Player_v1",
	PrestigeBoard = "COSG_Prestige",
	CollectionBoard = "COSG_Collection",
	WeeklyGlintPrefix = "COSG_WeeklyGlint_",
}

Config.Keys = {
	player = function(userId: number): string
		return ("u_%d"):format(userId)
	end,
}

-- Wednesday 2026-09-23 00:00 UTC = shop week 1. Change before launch if needed.
Config.SHOP_EPOCH_UNIX = 1790121600
Config.SHOP_WEEK_SECONDS = 7 * 24 * 60 * 60
Config.PENDING_BUY_TTL = 15 * 60
Config.AutosaveSeconds = 60

Config.Click = {
	BatchSeconds = 2,
	MaxPerSecond = 12,
	BatchSlack = 6,
	MinBatchGap = 1.5,
	ComboWindowMs = 500,
	CritBase = 0.05,
	CritPerComboTier = 0.005,
	CritChanceCap = 0.20,
	CritClickMultiplier = 10,
}

Config.Click.MaxPerBatch = Config.Click.MaxPerSecond * Config.Click.BatchSeconds + Config.Click.BatchSlack

Config.Economy = {
	ClickLevelBaseCost = 12,
	ClickLevelGrowth = 1.18,
	ClickLevelPower = 1.08,
	PrestigeCompound = 1.10,
	OperatorCostGrowth = 1.15,
	ShardBase = 10,
	ShardGrowth = 1.15,
}

-- runEarned required to enter prestige N.
Config.PrestigeNeed = {
	[1] = 400000,
	[2] = 2500000,
	[3] = 12000000,
	[4] = 40000000,
	[5] = 120000000,
	[6] = 280000000,
	[7] = 500000000,
	[8] = 900000000,
}

Config.Chapters = {
	{ id = 1, runEarned = 25000, grantId = "frame_doodle" },
	{ id = 2, runEarned = 120000, grantId = "trail_click_tapflash" },
}

Config.BattlePass = {
	Season = 1,
	Tiers = 50,
	PremiumPrice = 799,
	PremiumXpMult = 1.25,
	DailyQuestCount = 3,
	AllCompleteXp = 50,
}

Config.Starter = {
	PriceRobux = 199,
	Grants = {
		"trail_click_stickerstars",
		"trail_click_candysprinkle",
		"comp_paper_crane",
		"trail_click_neonpulse",
	},
}

Config.SeasonBundle = {
	PriceRobux = 2499,
	Grants = {
		"theme_lofi_room",
		"trail_click_rainbowribbon",
		"comp_tiny_slime",
	},
}

-- Free on new profile. Quiet Bow is granted on first prestige, not here.
Config.DefaultOwned = {
	"trail_click_firstspark",
	"theme_bedroom_desk",
	"sound_soft_taps",
	"op_sparkpup_default",
	"op_neonkitten_default",
	"op_pixelbee_default",
	"op_crystalfox_default",
	"op_prismdeer_default",
	"finish_quiet_bow",
}

Config.DefaultEquipped = {
	trail = "trail_click_firstspark",
	operator = "op_sparkpup_default",
	companion = "",
	theme = "theme_bedroom_desk",
	finisher = "finish_quiet_bow",
	frame = "",
	sound = "sound_soft_taps",
}

return Config
