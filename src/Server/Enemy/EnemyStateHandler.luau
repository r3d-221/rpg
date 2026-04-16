local Players = game:GetService("Players")

local range = 30

local public = {}
public.__index = public

function public.new(enemy)
	local self = setmetatable({}, public)

	self.Character = enemy
	self.currentState = nil
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
	self.targetPlayer = public:nearestPlayer(self.Character)
	if self.currentState and self.currentState.onUpdate then
		local name = self.targetPlayer and self.targetPlayer.Name or "NIL"
		-- print("Target player set to: " .. name)

		self.currentState.onUpdate(self.Character, self, self.targetPlayer)
	end
end

function public:getPlayer()
	return
end

function public:nearestPlayer(enemy)
	local nearest = nil
	local minDistance = math.huge

	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		if not character then
			return
		end

		local playerRoot = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChild("Humanoid")

		if not playerRoot or not humanoid then
			return
		end
		if humanoid.Health <= 0 then
			return
		end

		-- print("a player was found by: " .. enemy.Name)
		local distance = (playerRoot.Position - enemy.HumanoidRootPart.Position).Magnitude
		-- print(enemy.Name .. "- " .. distance)

		if distance <= range and distance < minDistance then
			minDistance = distance
			nearest = player
			-- print("target set condition met")
		end
	end

	return nearest
end

return public
