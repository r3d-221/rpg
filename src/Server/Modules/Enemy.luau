local ServerScriptService = game:GetService("ServerScriptService")

local Modules = ServerScriptService.Server.Modules
local EnemyStates = ServerScriptService.Server.EnemyStates

local StateHandler = require(Modules.EnemyStateHandler)
local Idle = require(EnemyStates.Idle)
local Chase = require(EnemyStates.Chase)
local Attack = require(EnemyStates.Attack)
local Dead = require(EnemyStates.Dead)

local enemies: Folder = game.Workspace.enemies

-- export type Enemy = EnemyList.Enemy

---- enemy list ----
-- local starterEnemies = EnemyList.starterEnemies

local public = {}
public.__index = public

---- Constructer ----
function public.new(model: Model)
	local self = setmetatable({}, public)

	local enemy = model:Clone()
	enemy.Parent = enemies

	StateHandler.new(self)
	StateHandler:changeState("Idle")

	task.spawn(function()
		while true do
			StateHandler:update()
			task.wait(0.1)
		end
	end)

	return self
end

return public
