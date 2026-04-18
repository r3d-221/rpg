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
			return model
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
	local activeCount = 0

	local function trySpawn()
		if activeCount >= spawnCount then
			return
		end

		local model = private.getModel(level)
		if not model then
			return
		end

		local clone = model:Clone()
		clone:SetAttribute("enemyType", private.pickType(level))
		clone:SetAttribute("enemySubtype", private.pickSubtype())
		clone:PivotTo(spawner.CFrame)
		clone.Parent = workspace.enemies
		activeCount += 1

		Enemy.new(clone)

		clone.Humanoid.Died:Connect(function()
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
