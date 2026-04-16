local ServerScriptService = game:GetService("ServerScriptService")

local Enemy = ServerScriptService.Server.Enemy
local States = Enemy.States

local StateHandler = require(Enemy.EnemyStateHandler)
local idleState = require(States.Idle)
local chaseState = require(States.Chase)
local attackState = require(States.Attack)
local deadState = require(States.Dead)

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

	self.handler = StateHandler.new(model)

	self.handler:addState("Idle", idleState)
	self.handler:addState("Chase", chaseState)
	self.handler:addState("Attack", attackState)
	self.handler:addState("Dead", deadState)

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
