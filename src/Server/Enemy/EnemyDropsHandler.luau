local EnemyDropsData = require(script.Parent.EnemyDropsData)
local ItemRegistry = require(script.Parent.ItemRegistry)

local private = {}
local public = {}

--==== NOTE ====--
-- category: weapons, armors, etc.
-- sub category: sword, chestplate, etc.
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
		local info = weaponType and private.pickItemFromSubCategory("weapons", weaponType, rarity)

		if info and info.item then
			local level = math.random(weaponConfig.levelRange.min, weaponConfig.levelRange.max)
			table.insert(droppedItems, {
				id = info.item.id,
				category = "weapons",
				rarity = rarity,
				rolls = info.rolls,
				stats = info.stats,
				level = level,
			})
		end
	end

	-- armor roll
	local armorConfig = itemDropPool.armors
	if armorConfig and math.random() <= armorConfig.chance then
		local adjustedRange = private.applyLuck(armorConfig.rarityRange, luck)
		local rarity = private.pickRarity(adjustedRange)

		local armorType = private.pickSubCategory(armorConfig.armorType)
		local info = armorType and private.pickItemFromSubCategory("armors", armorType, rarity)

		if info and info.item then
			local level = math.random(armorConfig.levelRange.min, armorConfig.levelRange.max)
			table.insert(droppedItems, {
				id = info.item.id,
				category = "armors",
				rarity = rarity,
				rolls = info.rolls,
				stats = info.stats,
				level = level,
			})
		end
	end

	-- materials roll
	local ingredientConfig = itemDropPool.materials
	if ingredientConfig and math.random() <= ingredientConfig.chance then
		local adjustedRange = private.applyLuck(ingredientConfig.rarityRange, luck)
		local rarity = private.pickRarity(adjustedRange)

		local info = private.pickItemFromSubCategory("materials", nil, rarity)

		if info and info.item then
			local scaledMax =
				math.max(ingredientConfig.quantity.min, math.floor(ingredientConfig.quantity.max * dropRate))
			local quantity = math.random(ingredientConfig.quantity.min, scaledMax)

			table.insert(
				droppedItems,
				{ id = info.item.id, category = "materials", rarity = rarity, quantity = quantity }
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

function private.pickRank(): string
	local totalWeight = 0
	for rank, _ in EnemyDropsData.statRank do
		totalWeight += EnemyDropsData.statRankWeights[rank]
	end

	local roll = math.random() * totalWeight
	local cumulative = 0
	for rank, _ in EnemyDropsData.statRank do
		cumulative += EnemyDropsData.statRankWeights[rank]
		if roll <= cumulative then
			return rank
		end
	end

	return "D"
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

	-- if a sub category doesn't have the rolled rarity items then it will select another sub category
	local subCategoryList = if subCategory then categoryList[subCategory] else categoryList

	local candidates = {}
	if subCategoryList then
		for _, item in subCategoryList do
			if item.rarity == rarity then
				table.insert(candidates, item)
			end
		end
	end

	-- searches ALL sub-categories for the rolled rarity
	if #candidates == 0 and subCategory then
		for _, subList in categoryList do
			for _, item in subList do
				if item.rarity == rarity then
					table.insert(candidates, item)
				end
			end
		end
	end

	if #candidates == 0 then
		warn("No candidates for:", category, subCategory, rarity)
		return nil
	end

	local item = candidates[math.random(1, #candidates)]
	local info = private.rollStats(item, category)
	-- print("rollStats returned:", info)
	-- print("rolls:", info and info.rolls)
	-- print("stats:", info and info.stats)

	if not info then
		return nil
	end

	return { item = item, rolls = info.rolls, stats = info.stats }
end

function private.rollStats(item, category): {}?
	local stats = {}
	local rolls = {}

	if category == "materials" then
		return { rolls = rolls, stats = stats }
	end

	if category == "weapons" then
		local info = ItemRegistry.getItemInfo(item.id)

		if not info then
			warn("ItemRegistry: no entry for id:", item.id)
			return { rolls = {}, stats = {} }
		end

		-- print(
		-- 	"info fields for: " .. item.id,
		-- 	info.baseDamage,
		-- 	info.baseCritRate,
		-- 	info.baseCritDamage,
		-- 	info.baseAttackSpeed,
		-- 	info.baseArmorPenetration
		-- )

		rolls = {
			private.pickRank(),
			private.pickRank(),
			private.pickRank(),
			private.pickRank(),
			private.pickRank(),
		}

		stats = {
			damage = (info.baseDamage or 0) * EnemyDropsData.statRank[rolls[1]],
			critRate = (info.baseCritRate or 0) * EnemyDropsData.statRank[rolls[2]],
			critDamage = (info.baseCritDamage or 0) * EnemyDropsData.statRank[rolls[3]],
			attackSpeed = (info.baseAttackSpeed or 0) * EnemyDropsData.statRank[rolls[4]],
			armorPenetration = (info.baseArmorPenetration or 0) * EnemyDropsData.statRank[rolls[5]],
		}

		return { rolls = rolls, stats = stats }
	end

	if category == "armors" then
		local info = ItemRegistry.getItemInfo(item.id)

		if not info then
			warn("ItemRegistry: no entry for id:", item.id)
			return { rolls = {}, stats = {} }
		end

		-- print("info fields for : " .. item.id, info.baseHealth, info.baseArmor, info.baseLuck)

		rolls = {
			private.pickRank(),
			private.pickRank(),
			private.pickRank(),
			private.pickRank(),
		}

		stats = {
			health = (info.baseHealth or 0) * EnemyDropsData.statRank[rolls[1]],
			armor = (info.baseArmor or 0) * EnemyDropsData.statRank[rolls[2]],
			luck = (info.baseLuck or 0) * EnemyDropsData.statRank[rolls[3]],
			walkspeed = 1,
		}

		if info.baseSpeed and info.baseSpeed > 0 then
			stats.walkspeed = info.baseSpeed * EnemyDropsData.statRank[rolls[4]]
		else
			stats.walkspeed = 0
		end

		return { rolls = rolls, stats = stats }
	end

	return { rolls = rolls, stats = stats }
end

return public
