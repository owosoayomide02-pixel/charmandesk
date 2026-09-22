--!strict

local Config = require(script.Parent.Config)
local Operators = require(script.Parent.Operators)
local ProfileTemplate = require(script.Parent.ProfileTemplate)

local Economy = {}

function Economy.clickCost(clickLevel: number): number
	return math.max(1, math.floor(Config.Economy.ClickLevelBaseCost * (Config.Economy.ClickLevelGrowth ^ clickLevel)))
end

function Economy.operatorCost(operatorId: string, owned: number): number?
	local def = Operators.get(operatorId)
	if not def then
		return nil
	end
	return math.max(1, math.floor(def.baseCost * (Config.Economy.OperatorCostGrowth ^ owned)))
end

function Economy.prestigeNeed(nextLevel: number): number?
	return Config.PrestigeNeed[nextLevel]
end

function Economy.shardGrant(newPrestigeLevel: number): number
	return math.floor(Config.Economy.ShardBase * (Config.Economy.ShardGrowth ^ math.max(0, newPrestigeLevel - 1)))
end

function Economy.snapshot(profile: any): { [string]: any }
	local owned = {}
	for id in profile.cosmetics do
		table.insert(owned, id)
	end
	table.sort(owned)
	local ops = {}
	for id, count in profile.operators do
		ops[id] = count
	end
	return {
		glint = profile.glint,
		runEarned = profile.runEarned,
		lifetimeEarned = profile.lifetimeEarned,
		clickLevel = profile.clickLevel,
		prestigeLevel = profile.prestigeLevel,
		prestigeMult = ProfileTemplate.prestigeMultiplier(profile.prestigeLevel),
		clickPower = ProfileTemplate.clickPower(
			profile.clickLevel,
			profile.prestigeLevel,
			profile.shardSpent.glint_boost_2pct or 0
		),
		clickCost = Economy.clickCost(profile.clickLevel),
		prestigeNeed = Economy.prestigeNeed(profile.prestigeLevel + 1),
		shards = profile.shards,
		operators = ops,
		owned = owned,
		equipped = profile.equipped,
		vouchers = profile.vouchers,
		studioShop = false,
	}
end

return Economy
