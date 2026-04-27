local EnemyDropsData = require(script.Parent.EnemyDropsData)
local private = {}
local public = {}

--==== NOTE ====--
-- category: weapons, armors, etc.
-- sub category: sword, chestplate, etc.

-- converts the position of the rarity in the list to a number
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

-- gets the rarity
function private.pickRarity(rarityRange): string
	local minIndex = private.rarityToIndex(rarityRange.min)
	local maxIndex = private.rarityToIndex(rarityRange.max)

	local pool = {}
	local totalWeight = 0

	-- gets the rarities in the range
	for i = minIndex, maxIndex do
		local tier = EnemyDropsData.rarityTiers[i]
		local weight = EnemyDropsData.rarityWeights[tier]
		table.insert(pool, { tier = tier, weight = weight })
		totalWeight += weight
	end

	-- gets a tier depending on the weight
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

-- gets the sub category
function private.pickSubCategory(typeTable: {}): string?
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

-- gets a random item from the sub category
function private.pickItemFromSubCategory(category: string, subCategory: string?, rarity: string): {}?
	local categoryList = EnemyDropsData.itemList[category]
	if not categoryList then
		return nil
	end

	local subCategoryList = if subCategory then categoryList[subCategory] else categoryList
	if not subCategoryList then
		return nil
	end

	local candidates = {}
	for _, item in subCategoryList do
		if item.rarity == rarity then
			table.insert(candidates, item)
		end
	end

	if #candidates == 0 then
		return nil
	end

	return candidates[math.random(1, #candidates)] -- will randomly pick any item from the given rarity
end

-- player luck will influence the rarity, min level
-- drop rate will influence the min and max quantity
-- rolls rarity, sub category, items, quantity, levels for EVERY category
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
		local weaponType = private.pickSubCategory(weaponConfig.weaponType)
		local item = weaponType and private.pickItemFromSubCategory("weapons", weaponType, rarity)
		if item then
			local level = math.random(weaponConfig.levelRange.min, weaponConfig.levelRange.max)
			table.insert(droppedItems, { id = item.id, category = "weapons", rarity = rarity, level = level })
		end
	end

	-- armor roll
	local armorConfig = itemDropPool.armors
	if armorConfig and math.random() <= armorConfig.chance then
		local adjustedRange = private.applyLuck(armorConfig.rarityRange, luck)
		local rarity = private.pickRarity(adjustedRange)
		local armorType = private.pickSubCategory(armorConfig.armorType)
		local item = armorType and private.pickItemFromSubCategory("armors", armorType, rarity)
		if item then
			local level = math.random(armorConfig.levelRange.min, armorConfig.levelRange.max)
			table.insert(droppedItems, { id = item.id, category = "armors", rarity = rarity, level = level })
		end
	end

	-- crafting ingredients roll
	local ingredientConfig = itemDropPool.craftingIngredients
	if ingredientConfig and math.random() <= ingredientConfig.chance then
		local adjustedRange = private.applyLuck(ingredientConfig.rarityRange, luck)
		local rarity = private.pickRarity(adjustedRange)
		local item = private.pickItemFromSubCategory("craftingIngredients", nil, rarity)
		if item then
			local scaledMax =
				math.max(ingredientConfig.quantity.min, math.floor(ingredientConfig.quantity.max * dropRate))
			local quantity = math.random(ingredientConfig.quantity.min, scaledMax)
			table.insert(
				droppedItems,
				{ id = item.id, category = "craftingIngredients", rarity = rarity, quantity = quantity }
			)
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

function public.rerollWeaponStat() end

function public.rerollArmorStat() end

function public.rerollArtifectStat() end

return public
