local ServerScriptService = game:GetService("ServerScriptService")

local HelperModules = ServerScriptService.Server.HelperModules

local EnemyNavigation = require(HelperModules.EnemyNavigation)
local EnemyCombat = require(HelperModules.EnemyCombat)
local EnemyList = require(HelperModules.EnemyList)

local enemies: Folder = game.Workspace.enemies

export type Enemy = EnemyList.Enemy

---- enemy list ----
local starterEnemies = EnemyList.starterEnemies

local public = {}
public.__index = public

---- NOTE ----
-- PURPOSE of the module is to make the enemy based on the model and apply every stats to it

---- Constructer ----
function public.new(model: Model)
	local self = setmetatable({}, public)

	local newEnemy = model:Clone()
	newEnemy.Parent = enemies

	self.Model = newEnemy
	self.Humanoid = newEnemy:WaitForChild("Humanoid")

	self.Navigation = EnemyNavigation.new(self)

	self.Combat = EnemyCombat.new(self)

	return self
end

-- when the enemy dies, spawn another enemy

return public
