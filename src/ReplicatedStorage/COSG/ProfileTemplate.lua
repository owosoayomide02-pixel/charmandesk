--!strict
--[[
	Player document. Key = u_{userId} in COSG_Player_v1.

	Persists: cosmetics, equipped, receipts, flags, progression.
	Never persist: click timestamps, combo, particles, username.
]]

local Config = require(script.Parent.Config)
local Operators = require(script.Parent.Operators)

export type OwnedCosmetic = {
	at: number,
	src: string, -- default | robux | starter | bundle | bp | quest | prestige | chapter | voucher
}

export type PendingBuy = {
	cosmeticId: string,
	productId: number,
	at: number,
}

export type Profile = {
	v: number,
	userId: number,
	createdAt: number,
	lastLogin: number,

	glint: number,
	runEarned: number,
	lifetimeEarned: number,
	clickLevel: number,
	prestigeLevel: number,
	shards: number,
	shardSpent: { [string]: number },
	chapters: { [string]: boolean },

	operators: { [string]: number }, -- id -> copy count

	cosmetics: { [string]: OwnedCosmetic },
	equipped: { [string]: string },

	pendingBuy: PendingBuy?,
	vouchers: { [string]: number }, -- price string -> unused grants
	receipts: { [string]: boolean },
	purchases: { [string]: { productId: number, cosmeticId: string?, at: number, kind: string } },
	flags: { starter: boolean, vip: boolean },

	battlePass: {
		season: number,
		xp: number,
		tier: number,
		premium: boolean,
		claimed: { [string]: boolean },
	},

	quests: {
		dayKey: string,
		ids: { string },
		progress: { [string]: number },
		done: { [string]: boolean },
		allBonus: boolean,
	},

	lastIdleAt: number,
	boosterUntil: number,

	social: {
		visits: number,
		stickersToday: number,
		stickerDayKey: string,
	},

	stats: {
		clicks: number,
		crits: number,
		prestiges: number,
		playSeconds: number,
	},
}

local ProfileTemplate = {}

function ProfileTemplate.new(userId: number, now: number): Profile
	local operators: { [string]: number } = {}
	for _, id in Operators.launchIds() do
		operators[id] = 0
	end

	local cosmetics: { [string]: OwnedCosmetic } = {}
	for _, id in Config.DefaultOwned do
		cosmetics[id] = { at = now, src = "default" }
	end

	local equipped = {}
	for slot, id in Config.DefaultEquipped do
		equipped[slot] = id
	end

	return {
		v = Config.SCHEMA_VERSION,
		userId = userId,
		createdAt = now,
		lastLogin = now,
		glint = 0,
		runEarned = 0,
		lifetimeEarned = 0,
		clickLevel = 0,
		prestigeLevel = 0,
		shards = 0,
		shardSpent = {
			glint_boost_2pct = 0,
			daily_common_roll = 0,
			operator_slot_extra = 0,
		},
		chapters = {},
		operators = operators,
		cosmetics = cosmetics,
		equipped = equipped,
		pendingBuy = nil,
		vouchers = {},
		receipts = {},
		purchases = {},
		flags = { starter = false, vip = false },
		battlePass = {
			season = Config.BattlePass.Season,
			xp = 0,
			tier = 0,
			premium = false,
			claimed = {},
		},
		quests = {
			dayKey = "",
			ids = {},
			progress = {},
			done = {},
			allBonus = false,
		},
		lastIdleAt = now,
		boosterUntil = 0,
		social = {
			visits = 0,
			stickersToday = 0,
			stickerDayKey = "",
		},
		stats = {
			clicks = 0,
			crits = 0,
			prestiges = 0,
			playSeconds = 0,
		},
	}
end

-- Fill missing fields after a schema bump or a partial document.
function ProfileTemplate.hydrate(raw: any, userId: number): Profile
	local now = os.time()
	local base = ProfileTemplate.new(userId, now)
	if type(raw) ~= "table" then
		return base
	end
	for key, value in raw :: { [string]: any } do
		if base[key] ~= nil or key == "pendingBuy" then
			(base :: any)[key] = value
		end
	end
	base.userId = userId
	base.v = Config.SCHEMA_VERSION
	if type(base.cosmetics) ~= "table" then
		base.cosmetics = {}
	end
	-- Migrate old array inventory: { "trail_click_sparkdust", ... }
	if base.cosmetics[1] ~= nil then
		local migrated: { [string]: OwnedCosmetic } = {}
		for _, id in base.cosmetics :: any do
			if type(id) == "string" then
				migrated[id] = { at = now, src = "migrated" }
			end
		end
		base.cosmetics = migrated
	end
	return base
end

function ProfileTemplate.prestigeMultiplier(prestigeLevel: number): number
	return Config.Economy.PrestigeCompound ^ prestigeLevel
end

function ProfileTemplate.clickPower(clickLevel: number, prestigeLevel: number, shardNodes: number): number
	local base = Config.Economy.ClickLevelPower ^ clickLevel
	local prestige = ProfileTemplate.prestigeMultiplier(prestigeLevel)
	local shards = 1 + 0.02 * shardNodes
	return math.max(1, math.floor(base * prestige * shards))
end

return ProfileTemplate
