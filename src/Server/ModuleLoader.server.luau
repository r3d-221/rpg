local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")

local ServerModules = ServerScriptService.Server
local EnemyFolder = ServerModules.Enemy
local Player = ServerModules.Player

local PlayerCombat = require(Player.PlayerCombat)

local Enemy = require(EnemyFolder.Enemy)
local enemyTag = "Enemy"

for _, object in CollectionService:GetTagged(enemyTag) do
	print(object)
	Enemy.new(object)
end

CollectionService:GetInstanceAddedSignal(enemyTag):Connect(Enemy.new)

PlayerCombat.onStart()

game.Players.PlayerAdded:Connect(function(player)
	player.CharacterAppearanceLoaded:Connect(function(character)
		for _, obj in character:GetDescendants() do
			if obj:IsA("BasePart") then
				obj.CollisionGroup = "Player"
			end
		end
	end)
end)
