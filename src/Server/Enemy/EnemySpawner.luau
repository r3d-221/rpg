local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")

local EnemyFolder = ServerScriptService.Server.Enemy
local Enemy = require(EnemyFolder.Enemy)
local EnemyData = require(EnemyFolder.EnemyData)

local enemyTemplates = ReplicatedStorage.enemyTemplates

local SPAWNER_TAG = "spawnPart"

local processedSpawners = {}
local private = {}
local public = {}

function public.onStart()
	for _, spawner in CollectionService:GetTagged(SPAWNER_TAG) do
		private.spawnEnemy(spawner)
	end

	CollectionService:GetInstanceAddedSignal(SPAWNER_TAG):Connect(private.spawnEnemy)
end

function private.pickType(level: string): string
	local pool = EnemyData.spawnTable[level]
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

function private.pickSubtype(): string?
	for subtype, chance in EnemyData.subtypeChance do
		if math.random() <= chance then
			return subtype
		end
	end
	return nil
end

function private.getModel(level: string)
	for _, model in enemyTemplates:GetChildren() do
		if model:GetAttribute("level") == level then
			return model:Clone()
		end
	end
	warn("No template found for level: " .. level)
	return nil
end

function private.spawnEnemy(spawner: BasePart)
	if processedSpawners[spawner] then
		return
	end
	processedSpawners[spawner] = true

	local level = spawner:GetAttribute("level") or "starter"
	local spawnCount = spawner:GetAttribute("spawnCount") or 3
	local respawnTime = spawner:GetAttribute("respawnTime") or 10
	local spawnCFrame = spawner.CFrame
	local activeCount = 0

	local function trySpawn()
		if activeCount >= spawnCount then
			return
		end

		local clone = private.getModel(level)
		if not clone then
			return
		end

		local enemyType = private.pickType(level)
		local enemySubtype = private.pickSubtype()
		local enemyStats = EnemyData.getStats(level, enemyType, enemySubtype)

		-- comment it out later and never use the attributes
		clone:SetAttribute("enemyType", enemyType)
		clone:SetAttribute("enemySubtype", enemySubtype)
		clone:SetAttribute("Health", enemyStats.health)
		clone:SetAttribute("Damage", enemyStats.damage)
		clone:SetAttribute("Armor", enemyStats.armor)
		clone:SetAttribute("CritRate", enemyStats.critRate)
		clone:SetAttribute("CritDamage", enemyStats.critDamage)
		clone:SetAttribute("AttackRange", enemyStats.attackRange)
		clone:SetAttribute("AggroRange", enemyStats.aggroRange)
		clone:SetAttribute("AggroLoseRange", enemyStats.aggroLoseRange)
		clone:SetAttribute("AttackCooldown", enemyStats.attackCooldown)
		clone:SetAttribute("Walkspeed", enemyStats.walkspeed)
		clone:SetAttribute("ReactionTime", enemyStats.reactionTime)
		clone:SetAttribute("ArmorPenetration", enemyStats.armorPenetration)
		clone:SetAttribute("DropRate", enemyStats.dropRate)

		clone.Humanoid.MaxHealth = enemyStats.health
		clone.Humanoid.Health = enemyStats.health
		clone.Humanoid.WalkSpeed = enemyStats.walkspeed

		clone:PivotTo(spawnCFrame)
		clone.Parent = workspace.enemies
		activeCount += 1

		Enemy.new(clone, enemyStats, function()
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
