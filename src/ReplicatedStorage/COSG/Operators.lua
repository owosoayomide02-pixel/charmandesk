--!strict
--[[
	Five Operators at launch. Later three stay launch=false until post-launch.
	count on the profile is copies owned; cost = baseCost * 1.15^count.
]]

export type OperatorDef = {
	id: string,
	name: string,
	baseCost: number,
	baseCps: number,
	unlockRunEarned: number,
	launch: boolean,
	defaultSkin: string,
}

local list: { OperatorDef } = {
	{ id = "sparkpup", name = "Spark Pup", baseCost = 40, baseCps = 0.4, unlockRunEarned = 0, launch = true, defaultSkin = "op_sparkpup_default" },
	{ id = "neonkitten", name = "Neon Kitten", baseCost = 400, baseCps = 2, unlockRunEarned = 8000, launch = true, defaultSkin = "op_neonkitten_default" },
	{ id = "pixelbee", name = "Pixel Bee", baseCost = 4000, baseCps = 10, unlockRunEarned = 40000, launch = true, defaultSkin = "op_pixelbee_default" },
	{ id = "crystalfox", name = "Crystal Fox", baseCost = 40000, baseCps = 50, unlockRunEarned = 180000, launch = true, defaultSkin = "op_crystalfox_default" },
	{ id = "prismdeer", name = "Prism Deer", baseCost = 350000, baseCps = 200, unlockRunEarned = 350000, launch = true, defaultSkin = "op_prismdeer_default" },
	{ id = "voidraven", name = "Void Raven", baseCost = 3200000, baseCps = 800, unlockRunEarned = 2500000, launch = false, defaultSkin = "op_voidraven_default" },
	{ id = "solardragon", name = "Solar Dragon", baseCost = 28000000, baseCps = 3500, unlockRunEarned = 40000000, launch = false, defaultSkin = "op_solardragon_default" },
	{ id = "chronosphinx", name = "Chrono Sphinx", baseCost = 250000000, baseCps = 15000, unlockRunEarned = 120000000, launch = false, defaultSkin = "op_chronosphinx_default" },
}

local byId: { [string]: OperatorDef } = {}
for _, op in list do
	byId[op.id] = op
end

local Operators = {}

function Operators.all(): { OperatorDef }
	return list
end

function Operators.get(id: string): OperatorDef?
	return byId[id]
end

function Operators.launchIds(): { string }
	local ids = {}
	for _, op in list do
		if op.launch then
			table.insert(ids, op.id)
		end
	end
	return ids
end

return Operators
