local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local ItemRegistry = require(ReplicatedStorage.Shared.Items.ItemRegistry)

local public = {}
local private = {}

public.statRank = {
	S = 1.2, -- 20%
	A = 1.15,
	B = 1.1,
	C = 1.05,
	D = 1,
}

public.statRankWeights = {
	S = 0.05,
	A = 0.10,
	B = 0.20,
	C = 0.30,
	D = 0.35,
}

function public.createItem(id: string, level: number?): {}?
	local registryItem = ItemRegistry.get(id)
	if not registryItem then
		warn("ItemHandler.createItem: no registry entry for id: " .. tostring(id))
		return nil
	end

	local info = private.rollStats(registryItem)

	return {
		uid = HttpService:GenerateGUID(false),
		id = id,
		level = level or 1,
		stats = info.stats,
		rolls = info.rolls,
		locked = false,
	}
end

function public.createMaterial(id: string, amount: number): {}?
	if not ItemRegistry.get(id) then
		warn("ItemHandler.createMaterial: no registry entry for id: " .. tostring(id))
		return nil
	end

	return { id = id, amount = amount }
end

function private.rollStats(registryItem): {}
	local category = registryItem.category
	local stats = {}
	local rolls = {}

	if category == "weapons" then
		rolls = {
			private.pickRank(),
			private.pickRank(),
			private.pickRank(),
			private.pickRank(),
			private.pickRank(),
		}
		stats = {
			damage = (registryItem.baseDamage or 0) * public.statRank[rolls[1]],
			critRate = (registryItem.baseCritRate or 0) * public.statRank[rolls[2]],
			critDamage = (registryItem.baseCritDamage or 0) * public.statRank[rolls[3]],
			attackSpeed = (registryItem.baseAttackSpeed or 0) * public.statRank[rolls[4]],
			armorPierce = (registryItem.baseArmorPierce or 0) * public.statRank[rolls[5]],
		}
		return { rolls = rolls, stats = stats }
	end

	if category == "armors" then
		rolls = {
			private.pickRank(),
			private.pickRank(),
			private.pickRank(),
			private.pickRank(),
		}
		stats = {
			health = (registryItem.baseHealth or 0) * public.statRank[rolls[1]],
			armor = (registryItem.baseArmor or 0) * public.statRank[rolls[2]],
			luck = (registryItem.baseLuck or 0) * public.statRank[rolls[3]],
			walkspeed = (registryItem.baseSpeed and registryItem.baseSpeed > 0)
					and registryItem.baseSpeed * public.statRank[rolls[4]]
				or 0,
		}
		return { rolls = rolls, stats = stats }
	end

	return { rolls = rolls, stats = stats }
end

function private.pickRank(): string
	local totalWeight = 0
	for _, weight in public.statRankWeights do
		totalWeight += weight
	end

	local roll = math.random() * totalWeight
	local cumulative = 0
	for rank in public.statRank do
		cumulative += public.statRankWeights[rank]
		if roll <= cumulative then
			return rank
		end
	end

	return "D"
end

return public
