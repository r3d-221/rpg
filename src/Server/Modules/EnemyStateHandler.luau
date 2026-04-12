local ServerScriptService = game:GetService("ServerScriptService")

local EnemyStates = ServerScriptService.Server.EnemyStates
local idleState = require(EnemyStates.Idle)
local chaseState = require(EnemyStates.Chase)
local attackState = require(EnemyStates.Attack)
local deadState = require(EnemyStates.Dead)

local public = {}
public.__index = public

function public.new(enemy)
	local self = setmetatable({}, public)

	self.character = enemy
	self.currentState = nil
	self.states = {}

	return self
end

function public:addState(name: string, module)
	self.states[name] = module
end

function public:changeState(name: string)
	if self.currentState and self.currentState.onExit then
		self.currentState.onExit(self.character)
	end

	self.currentState = self.states[name]

	if self.currentState and self.currentState.onEnter then
		self.currentState.onEnter(self.character)
	end
end

function public:update()
	if self.currentState and self.currentState.onUpdate then
		self.currentState.onUpdate(self.character, self)
	end
end

return public
