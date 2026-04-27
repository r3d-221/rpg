local ServerScriptService = game:GetService("ServerScriptService")

local EnemyFolder = ServerScriptService.Server.Enemy
local States = EnemyFolder.States

local StateHandler = require(EnemyFolder.EnemyStateHandler)
local idleState = require(States.Idle)
local chaseState = require(States.Chase)
local attackState = require(States.Attack)
local deadState = require(States.Dead)

local private = {}
local public = {}
public.__index = public

---- Constructer ----
function public.new(model, enemyStats, config, onDied)
	local self = setmetatable({}, public)
	self.handler = StateHandler.new(model, enemyStats)

	local configCopy = private.copyConfig(config)
	private.effectiveCooldown(configCopy, enemyStats.cooldownReduction)
	self.handler.data.config = configCopy

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
			task.wait(self.handler.data.stats.reactionTime)
		end
	end)

	return self
end

function private.copyConfig(config): {}
	local copy = { basicAttack = table.clone(config.basicAttack), abilities = {} }
	for i, ability in config.abilities do
		copy.abilities[i] = table.clone(ability)
	end
	return copy
end

function private.effectiveCooldown(config, cooldownReduction)
	for _, ability in config.abilities do
		local reducedCooldown = ability.cooldown * (1 - cooldownReduction / 100)
		ability.cooldown = math.max(reducedCooldown, 0.5) -- cooldown can't be lower than 0.5s
	end
end

return public
