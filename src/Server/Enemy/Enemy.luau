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
function public.new(enemy)
	local self = setmetatable({}, public)

	self.handler = StateHandler.new(enemy)

	self.handler:addState("Idle", idleState)
	self.handler:addState("Chase", chaseState)
	self.handler:addState("Attack", attackState)
	self.handler:addState("Dead", deadState)

	self.handler:changeState("Idle")

	enemy.Humanoid.Died:Connect(function()
		self.handler:changeState("Dead")
	end)

	task.spawn(function()
		while enemy and enemy.Parent and enemy.Humanoid.Health > 0 do
			self.handler:update()
			task.wait(0.1)
		end
	end)

	return self
end

return public
