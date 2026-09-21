--!strict
--[[
	Daily draw: 3 of 10. Never a "spend Robux" quest.
	dayKey = YYYY-MM-DD UTC. Deterministic pick from userId + dayKey.
]]

export type QuestDef = {
	id: string,
	name: string,
	goal: number,
	xp: number,
	stat: string,
}

local pool: { QuestDef } = {
	{ id = "tap_core", name = "Tap the core", goal = 2500, xp = 40, stat = "clicks" },
	{ id = "earn_glint", name = "Earn Glint", goal = 50000, xp = 40, stat = "runEarnedDelta" },
	{ id = "land_crits", name = "Land crits", goal = 15, xp = 35, stat = "crits" },
	{ id = "hold_combo", name = "Hold a combo", goal = 8, xp = 35, stat = "comboPeak" },
	{ id = "buy_upgrade", name = "Buy an upgrade", goal = 1, xp = 30, stat = "upgrades" },
	{ id = "prestige_or_play", name = "Prestige or play 15 min", goal = 1, xp = 50, stat = "prestigeOrPlay" },
	{ id = "remix_desk", name = "Equip a different cosmetic", goal = 1, xp = 25, stat = "equip" },
	{ id = "visit_desk", name = "Visit or be visited", goal = 1, xp = 40, stat = "visit" },
	{ id = "idle_tick", name = "Collect Operator output", goal = 1, xp = 20, stat = "idleCollect" },
	{ id = "window_shop", name = "Open the weekly limited", goal = 1, xp = 15, stat = "viewLimited" },
}

local byId: { [string]: QuestDef } = {}
for _, q in pool do
	byId[q.id] = q
end

local Quests = {}

function Quests.get(id: string): QuestDef?
	return byId[id]
end

function Quests.all(): { QuestDef }
	return pool
end

function Quests.utcDayKey(unix: number): string
	return os.date("!%Y-%m-%d", unix) :: string
end

function Quests.pick(userId: number, dayKey: string, count: number): { string }
	local seed = 0
	for i = 1, #dayKey do
		seed += string.byte(dayKey, i) * i
	end
	seed += userId
	local rng = Random.new(seed)
	local bag = table.clone(pool)
	local ids = {}
	for _ = 1, math.min(count, #bag) do
		local idx = rng:NextInteger(1, #bag)
		table.insert(ids, bag[idx].id)
		table.remove(bag, idx)
	end
	return ids
end

return Quests
