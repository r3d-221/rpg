local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ItemHandler = require(ServerScriptService.Server.Modules.ItemHandler)
local EnemyDropsData = require(script.Parent.EnemyDropsData)
local ItemRegistry = require(ReplicatedStorage.Shared.Items.ItemRegistry)

local private = {}
local public = {}

function public.rollDrops(difficultyLevel: string, enemyType: string, dropRate: number, luck: number): {}
	local itemDropPool = EnemyDropsData.items[difficultyLevel] and EnemyDropsData.items[difficultyLevel][enemyType]
	local currencyDropPool = EnemyDropsData.currency[difficultyLevel]

	if not itemDropPool or not currencyDropPool then
		warn(
			"No drop pool found for difficulty level: "
				.. tostring(difficultyLevel)
				.. " -- enemy type: "
				.. tostring(enemyType)
		)
		return { currency = {}, items = {} }
	end

	local droppedItems = {}

	-- weapon roll
	local weaponConfig = itemDropPool.weapons
	if weaponConfig and math.random() <= weaponConfig.chance then
		local adjustedRange = private.applyLuck(weaponConfig.rarityRange, luck)
		local rarity = private.pickRarity(adjustedRange)

		local weaponType = private.pickItemType(weaponConfig.weaponType)
		local registryItem = weaponType and private.pickItem("weapons", weaponType, rarity)

		if registryItem then
			local level = math.random(weaponConfig.levelRange.min, weaponConfig.levelRange.max)
			local instance = ItemHandler.createItem(registryItem.id, level)
			if instance then
				table.insert(droppedItems, instance)
			end
		end
	end

	-- armor roll
	local armorConfig = itemDropPool.armors
	if armorConfig and math.random() <= armorConfig.chance then
		local adjustedRange = private.applyLuck(armorConfig.rarityRange, luck)
		local rarity = private.pickRarity(adjustedRange)

		local armorType = private.pickItemType(armorConfig.armorType)
		local registryItem = armorType and private.pickItem("armors", armorType, rarity)

		if registryItem then
			local level = math.random(armorConfig.levelRange.min, armorConfig.levelRange.max)
			local instance = ItemHandler.createItem(registryItem.id, level)
			if instance then
				table.insert(droppedItems, instance)
			end
		end
	end

	-- materials roll
	local ingredientConfig = itemDropPool.materials
	if ingredientConfig and math.random() <= ingredientConfig.chance then
		local adjustedRange = private.applyLuck(ingredientConfig.rarityRange, luck)
		local rarity = private.pickRarity(adjustedRange)

		local materialType = private.pickItemType(ingredientConfig.materialType)
		local registryItem = private.pickItem("materials", materialType, rarity)

		if registryItem then
			local scaledMax =
				math.max(ingredientConfig.quantity.min, math.floor(ingredientConfig.quantity.max * dropRate))
			local quantity = math.random(ingredientConfig.quantity.min, scaledMax)

			local instance = ItemHandler.createMaterial(registryItem.id, quantity)
			if instance then
				table.insert(droppedItems, instance)
			end
		end
	end

	-- currency roll
	local currencyDrops = {}
	for _, entry in currencyDropPool do
		if math.random() <= entry.chance then
			local amount = math.floor(math.random(entry.min, entry.max) * dropRate)
			table.insert(currencyDrops, { id = entry.id, amount = math.max(1, amount) })
		end
	end

	return { currency = currencyDrops, items = droppedItems }
end

function private.rarityToIndex(rarity: string): number
	for i, tier in EnemyDropsData.rarityTiers do
		if tier == rarity then
			return i
		end
	end
	return 1
end

-- every 10 luck changes the min rarity
function private.applyLuck(rarityRange, luck: number): {}
	local minIndex = private.rarityToIndex(rarityRange.min)
	local maxIndex = private.rarityToIndex(rarityRange.max)

	local luckBonus = math.floor(luck / 10)
	local newMin = math.min(minIndex + luckBonus, maxIndex)

	return {
		min = EnemyDropsData.rarityTiers[newMin],
		max = rarityRange.max,
	}
end

function private.pickRarity(rarityRange): string
	local minIndex = private.rarityToIndex(rarityRange.min)
	local maxIndex = private.rarityToIndex(rarityRange.max)

	local pool = {}
	local totalWeight = 0

	for i = minIndex, maxIndex do
		local tier = EnemyDropsData.rarityTiers[i]
		local weight = EnemyDropsData.rarityWeights[tier]
		table.insert(pool, { tier = tier, weight = weight })
		totalWeight += weight
	end

	local roll = math.random() * totalWeight
	local cumulative = 0
	for _, entry in pool do
		cumulative += entry.weight
		if roll <= cumulative then
			return entry.tier
		end
	end

	return pool[#pool].tier
end

function private.pickItemType(typeTable: {}): string?
	local totalWeight = 0
	for _, weight in typeTable do
		totalWeight += weight
	end

	local roll = math.random() * totalWeight
	local cumulative = 0
	for typeName, weight in typeTable do
		cumulative += weight
		if roll <= cumulative then
			return typeName
		end
	end
	return nil
end

function private.pickItem(category: string, type: string?, rarity: string): {}?
	local allItems = ItemRegistry.getCategory(category)
	local candidates = {}

	for _, item in allItems do
		if item.rarity ~= rarity then
			continue
		end
		if type then
			local itemType = (category == "armors") and item.class or item.subCategory
			if not itemType or itemType:lower() ~= type:lower() then
				continue
			end
		end
		table.insert(candidates, item)
	end

	if #candidates == 0 and type then
		for _, item in allItems do
			if item.rarity == rarity then
				table.insert(candidates, item)
			end
		end
	end

	if #candidates == 0 then
		warn("No candidates for:", category, type, rarity)
		return nil
	end

	return candidates[math.random(1, #candidates)]
end

return public
