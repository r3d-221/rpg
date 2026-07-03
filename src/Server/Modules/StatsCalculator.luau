local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ItemRegistry = require(ReplicatedStorage.Shared.Items.ItemRegistry)
local PlayerClassData = require(ServerScriptService.Server.Player.PlayerClassData)

local private = {}
local public = {}

local STAT_KEYS = {
	"health",
	"armor",
	"luck",
	"damage",
	"critRate",
	"critDamage",
	"armorPierce",
	"attackSpeed",
	"walkspeed",
	"cooldownReduction",
}

public.STAT_POINT_VALUES = {
	health = 10,
	armor = 2,
	damage = 3,
	critRate = 0.01,
	critDamage = 0.05,
}

function public.calculateBase(data)
	local classData = data.classes[data.class]
	if not classData then
		warn("StatCalculator.calculateBase: no class data for class: " .. tostring(data.class))
		return
	end

	local flatTotal = private.mergeFlat({
		private.calculateStatPoints(data),
		private.calculateItems(data),
	})

	local baseStats = private.applyPercentLayers(flatTotal, {
		private.calculateTitle(data),
		private.calculatePassives(data),
	})

	classData.baseStats = baseStats

	public.calculateTemp(data)
end

function public.calculateTemp(data)
	local classData = data.classes[data.class]
	if not classData then
		warn("StatCalculator.calculateTemp: no class data for class: " .. tostring(data.class))
		return
	end

	local baseStats = classData.baseStats or {}
	local activeBuffs = classData.tempBuffs or {}

	local combinedPercent = {}
	for _, buff in activeBuffs do
		combinedPercent[buff.stat] = (combinedPercent[buff.stat] or 0) + buff.percent
	end

	local finalStats = {}
	for _, stat in STAT_KEYS do
		local base = baseStats[stat] or 0
		local percent = combinedPercent[stat] or 0
		finalStats[stat] = base * (1 + percent)
	end

	classData.stats = finalStats
end

function private.calculateStatPoints(data): {}
	local classData = data.classes[data.class]
	local baseStats = PlayerClassData.baseStats[data.class] or {}
	local points = classData.statPoints or {}

	local contribution = {}
	for stat, value in baseStats do
		contribution[stat] = (contribution[stat] or 0) + value
	end

	for stat, amount in points do
		local pointValue = public.STAT_POINT_VALUES[stat]
		if pointValue then
			contribution[stat] = (contribution[stat] or 0) + amount * pointValue
		end
	end

	return contribution
end

function private.calculateItems(data): {}
	local contribution = {}

	for slotName, uid in data.equipped do
		if slotName == "artifacts" or not uid then
			continue
		end

		local item = ItemRegistry.findItemByUid(data.inventory, uid)
		if not item or not item.stats then
			continue
		end

		for stat, value in item.stats do
			contribution[stat] = (contribution[stat] or 0) + value
		end
	end

	for _, uid in data.equipped.artifacts or {} do
		local item = ItemRegistry.findItemByUid(data.inventory, uid)
		if not item or not item.stats then
			continue
		end

		for stat, value in item.stats do
			contribution[stat] = (contribution[stat] or 0) + value
		end
	end

	return contribution
end

function private.calculateTitle(data): {}
	return {}
end

function private.calculatePassives(data): {}
	return {}
end

function private.mergeFlat(contributions: { {} }): {}
	local total = {}
	for _, stat in STAT_KEYS do
		total[stat] = 0
	end

	for _, contribution in contributions do
		for stat, value in contribution do
			total[stat] = (total[stat] or 0) + value
		end
	end

	return total
end

function private.applyPercentLayers(flatTotal: {}, percentLayers: { {} }): {}
	local running = table.clone(flatTotal)

	for _, layer in percentLayers do
		for stat, percent in layer do
			running[stat] = (running[stat] or 0) * (1 + percent)
		end
	end

	return running
end

return public
