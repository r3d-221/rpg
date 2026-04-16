local ServerScriptService = game:GetService("ServerScriptService")

local Enemy = ServerScriptService.Server.Enemy

local TargetPlayer = require(Enemy.TargetPlayer)

local public = {}
public.__index = public

function public.new(enemy)
	local self = setmetatable({}, public)

	self.Character = enemy
	self.currentState = nil
	self.targetPlayer = nil
	self.states = {}

	return self
end

function public:addState(name: string, module: {})
	self.states[name] = module
end

function public:changeState(name: string)
	if self.currentState and self.currentState.onExit then
		self.currentState.onExit(self.Character)
	end

	self.currentState = self.states[name]

	if self.currentState and self.currentState.onEnter then
		self.currentState.onEnter(self.Character)
	end
end

function public:update()
	self.targetPlayer = TargetPlayer.find(self.Character)
	if self.currentState and self.currentState.onUpdate then
		self.currentState.onUpdate(self.Character, self, self.targetPlayer)

		-- debug
		local name = self.targetPlayer and self.targetPlayer.Name or "NIL"
		print("Target player set to: " .. name)
	end
end

function public:getPlayer()
	return self.targetPlayer
end

return public
