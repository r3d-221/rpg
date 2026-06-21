local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ServerModules = ServerScriptService.Server
local EnemyFolder = ServerModules.Enemy
local PlayerFolder = ServerModules.Player

local PlayerClassHandler = require(ServerScriptService.Server.Player.PlayerClassHandler)
local ItemRegistry = require(ReplicatedStorage.Shared.Items.ItemRegistry)
local PlayerDataHandler = require(PlayerFolder.PlayerDataHandler)
local EnemySpawner = require(EnemyFolder.EnemySpawner)
local PlayerCombat = require(PlayerFolder.PlayerCombat)

PlayerDataHandler.onStart()
PlayerClassHandler.onStart()
ItemRegistry.onStart()
EnemySpawner.onStart()
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
