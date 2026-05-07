local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
		local info = weaponType and private.pickItem("weapons", weaponType, rarity)

		if info and info.item then
			local level = math.random(weaponConfig.levelRange.min, weaponConfig.levelRange.max)
			table.insert(droppedItems, {
				id = info.item.id,
				rolls = info.rolls,
				stats = info.stats,
				level = level,
				category = "weapons",
				rarity = rarity,
			})
		end
	end

	-- armor roll
	local armorConfig = itemDropPool.armors
	if armorConfig and math.random() <= armorConfig.chance then
		local adjustedRange = private.applyLuck(armorConfig.rarityRange, luck)
		local rarity = private.pickRarity(adjustedRange)

		local armorType = private.pickItemType(armorConfig.armorType)
		local info = armorType and private.pickItem("armors", armorType, rarity)

		if info and info.item then
			local level = math.random(armorConfig.levelRange.min, armorConfig.levelRange.max)
			table.insert(droppedItems, {
				id = info.item.id,
				rolls = info.rolls,
				stats = info.stats,
				level = level,
				category = "armors",
				rarity = rarity,
			})
		end
	end

	-- materials roll
	local ingredientConfig = itemDropPool.materials
	if ingredientConfig and math.random() <= ingredientConfig.chance then
		local adjustedRange = private.applyLuck(ingredientConfig.rarityRange, luck)
		local rarity = private.pickRarity(adjustedRange)

		local materialType = private.pickItemType(ingredientConfig.materialType)
		local info = private.pickItem("materials", materialType, rarity)

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

-- gets a random item from the sub category
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

	local item = candidates[math.random(1, #candidates)]
	local info = private.rollStats(item, category)
	if not info then
		return nil
	end

	return { item = item, rolls = info.rolls, stats = info.stats }
end

function private.rollStats(item, category)
	local stats = {}
	local rolls = {}

	if category == "materials" then
		return { rolls = rolls, stats = stats }
	end

	if category == "weapons" then
		rolls = {
			private.pickRank(),
			private.pickRank(),
			private.pickRank(),
			private.pickRank(),
			private.pickRank(),
		}
		stats = {
			damage = (item.baseDamage or 0) * EnemyDropsData.statRank[rolls[1]],
			critRate = (item.baseCritRate or 0) * EnemyDropsData.statRank[rolls[2]],
			critDamage = (item.baseCritDamage or 0) * EnemyDropsData.statRank[rolls[3]],
			attackSpeed = (item.baseAttackSpeed or 0) * EnemyDropsData.statRank[rolls[4]],
			armorPenetration = (item.baseArmorPenetration or 0) * EnemyDropsData.statRank[rolls[5]],
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
			health = (item.baseHealth or 0) * EnemyDropsData.statRank[rolls[1]],
			armor = (item.baseArmor or 0) * EnemyDropsData.statRank[rolls[2]],
			luck = (item.baseLuck or 0) * EnemyDropsData.statRank[rolls[3]],
			walkspeed = (item.baseSpeed and item.baseSpeed > 0) and item.baseSpeed * EnemyDropsData.statRank[rolls[4]]
				or 0,
		}
		return { rolls = rolls, stats = stats }
	end

	return { rolls = rolls, stats = stats }
end

return public
