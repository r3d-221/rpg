local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")

local EnemyFolder = ServerScriptService.Server.Enemy

local Remotes = ReplicatedStorage.Shared.Remotes
local getEnemyData = Remotes.getEnemyData
local enemySpawned = Remotes.enemySpawned

local PlayerDataHandler = require(ServerScriptService.Server.Player.PlayerDataHandler)
local EnemyDropsHandler = require(script.Parent.EnemyDropsHandler)
local Enemy = require(EnemyFolder.Enemy)
local EnemyData = require(ReplicatedStorage.Shared.Modules.EnemyData)

local enemyTemplates = ReplicatedStorage.enemyTemplates

local SPAWNER_TAG = "spawnPart"

local activeEnemies = {}
local processedSpawners = {}
local private = {}
local public = {}

function public.onStart()
	getEnemyData.OnServerInvoke = function()
		local result = {}
		for enemy, data in activeEnemies do
			table.insert(result, { enemy = enemy, data = data })
		end
		return result
	end

	for _, spawner in CollectionService:GetTagged(SPAWNER_TAG) do
		private.spawnEnemy(spawner)
	end

	CollectionService:GetInstanceAddedSignal(SPAWNER_TAG):Connect(private.spawnEnemy)
end

function private.pickType(difficultyLevel: string): string
	local pool = EnemyData.spawnTable[difficultyLevel]
	if not pool then
		return "melee"
	end

	local totalWeight = 0
	for _, entry in pool do
		totalWeight += entry.weight
	end

	local roll = math.random(1, totalWeight)
	local cumulative = 0
	for _, entry in pool do
		cumulative += entry.weight
		if roll <= cumulative then
			return entry.type
		end
	end

	return "melee"
end

function private.pickSubtype(difficultyLevel: string, spawner: BasePart): { string }
	local subtypes = {}
	for subtype, chance in EnemyData.subtypeChance do
		if math.random() <= chance then
			table.insert(subtypes, subtype)
			break
		end
	end

	if #subtypes == 0 then
		return subtypes
	end

	local allowDoubles = spawner:GetAttribute("doubleSubtype")
	if not allowDoubles then
		return subtypes
	end

	local difficultyLevelData = EnemyData.enemyDifficultyLevel[difficultyLevel]
	local doubleChance = difficultyLevelData and difficultyLevelData.doubleSubtypeChance or 0

	if doubleChance > 0 and math.random() <= doubleChance then
		for subtype, chance in EnemyData.subtypeChance do
			if math.random() <= chance then
				table.insert(subtypes, subtype)
				break
			end
		end
	end

	return subtypes
end

function private.getModel(difficultyLevel: string, enemyType: string)
	for _, model in enemyTemplates:GetChildren() do
		if model:GetAttribute("difficultyLevel") == difficultyLevel and model:GetAttribute("variant") == enemyType then
			return model:Clone()
		end
	end
	warn("No template found for difficultyLevel: " .. difficultyLevel .. ", type: " .. enemyType)
	return nil
end

function private.setAttributes(clone, enemyLevel, enemyStats, enemyType, enemySubtype)
	clone:SetAttribute("enemyType", enemyType)
	clone:SetAttribute("enemySubtype", table.concat(enemySubtype, ", "))
	clone:SetAttribute("level", enemyLevel)

	clone:SetAttribute("Health", enemyStats.health)
	clone:SetAttribute("Damage", enemyStats.damage)
	clone:SetAttribute("Armor", enemyStats.armor)
	clone:SetAttribute("CritRate", enemyStats.critRate)
	clone:SetAttribute("CritDamage", enemyStats.critDamage)
	clone:SetAttribute("AttackRange", enemyStats.attackRange)
	clone:SetAttribute("AggroRange", enemyStats.aggroRange)
	clone:SetAttribute("AggroLoseRange", enemyStats.aggroLoseRange)
	clone:SetAttribute("BasicAttackCooldown", enemyStats.basicAttackCooldown)
	clone:SetAttribute("Walkspeed", enemyStats.walkspeed)
	clone:SetAttribute("ReactionTime", enemyStats.reactionTime)
	clone:SetAttribute("ArmorPenetration", enemyStats.armorPenetration)
	clone:SetAttribute("DropRate", enemyStats.dropRate)
end

function private.spawnEnemy(spawner: BasePart)
	if processedSpawners[spawner] then
		return
	end
	processedSpawners[spawner] = true

	local difficultyLevel = spawner:GetAttribute("difficultyLevel") or "starter"
	local spawnCount = spawner:GetAttribute("spawnCount") or 3
	local respawnTime = spawner:GetAttribute("respawnTime") or 10
	local spawnCFrame = spawner.CFrame
	local activeCount = 0

	local function trySpawn()
		if activeCount >= spawnCount then
			return
		end

		local enemyType = private.pickType(difficultyLevel)

		local clone = private.getModel(difficultyLevel, enemyType)
		if not clone then
			return
		end

		local enemySubtype = private.pickSubtype(difficultyLevel, spawner)
		local enemyLevel = EnemyData.getLevel(difficultyLevel, enemySubtype)
		local enemyStats = EnemyData.getStats(difficultyLevel, enemyType, enemySubtype, enemyLevel)

		clone.Humanoid.MaxHealth = enemyStats.health
		clone.Humanoid.Health = enemyStats.health
		clone.Humanoid.WalkSpeed = enemyStats.walkspeed

		local configName = clone:GetAttribute("attackConfig") or "zombie"
		local config = require(EnemyFolder.Attacks[configName])

		private.setAttributes(clone, enemyLevel, enemyStats, enemyType, enemySubtype)

		clone:PivotTo(spawnCFrame)
		clone.Parent = workspace.enemies
		activeCount += 1

		CollectionService:AddTag(clone, "Enemy")

		local enemyData = {
			level = enemyLevel,
			name = configName,
			enemyType = enemyType,
			enemySubtype = enemySubtype,
		}
		activeEnemies[clone] = enemyData
		enemySpawned:FireAllClients(clone, enemyData)

		Enemy.new(clone, enemyStats, config, function()
			activeEnemies[clone] = nil
			local attackerName = clone:GetAttribute("lastAttacker")
			local lastAttacker = attackerName and game.Players:FindFirstChild(attackerName)
			local luck = 0

			if lastAttacker then
				local data = PlayerDataHandler.getData(lastAttacker)
				luck = data and data.stats.luck or 0
			end

			local drops = EnemyDropsHandler.rollDrops(difficultyLevel, enemyType, enemyStats.dropRate, luck)
			-- print(drops)

			-- adds drops to player inventory
			if lastAttacker then
				for _, currency in drops.currency do
					PlayerDataHandler.addCurrency(lastAttacker, currency.id, currency.amount)
				end
				for _, item in drops.items do
					PlayerDataHandler.addItem(lastAttacker, item)
				end
			end

			task.delay(respawnTime, function()
				activeCount -= 1
				trySpawn()
			end)
		end)
	end

	for _ = 1, spawnCount do
		trySpawn()
	end
end

return public
