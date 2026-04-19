local ServerScriptService = game:GetService("ServerScriptService")

local EnemyFolder = ServerScriptService.Server.Enemy
local States = EnemyFolder.States

local StateHandler = require(EnemyFolder.EnemyStateHandler)
local idleState = require(States.Idle)
local chaseState = require(States.Chase)
local attackState = require(States.Attack)
local deadState = require(States.Dead)

local public = {}
public.__index = public

---- Constructer ----
function public.new(model, onDied)
	local self = setmetatable({}, public)
	self.handler = StateHandler.new(model)

	self.handler:addState("Idle", idleState)
	self.handler:addState("Chase", chaseState)
	self.handler:addState("Attack", attackState)
	self.handler:addState("Dead", deadState)

	self.handler:changeState("Idle")

	local diedConnection
	diedConnection = model.Humanoid.Died:Connect(function()
		diedConnection:Disconnect()
		self.handler:changeState("Dead")
		if onDied then
			onDied()
		end
	end)

	task.spawn(function()
		while model and model.Parent do
			local humanoid = model:FindFirstChild("Humanoid")
			if not humanoid or humanoid.Health <= 0 then
				break
			end
			self.handler:update()
			task.wait(0.1)
		end
	end)

	return self
end

return public
