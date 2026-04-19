local Players = game:GetService("Players")

local range = 30

local public = {}
public.__index = public

function public.new(enemy)
	local self = setmetatable({}, public)

	self.Character = enemy
	self.currentState = nil
	self.data = {}
	self.states = {}

	self.data.origin = enemy.HumanoidRootPart.Position
	self.data.RootPart = enemy.HumanoidRootPart
	self.data.Humanoid = enemy.Humanoid
	return self
end

function public:addState(name: string, module: {})
	self.states[name] = module
end

function public:changeState(name: string)
	if self.currentState and self.currentState.onExit then
		self.currentState.onExit(self)
	end

	self.currentState = self.states[name]

	if self.currentState and self.currentState.onEnter then
		self.currentState.onEnter(self.Character, self)
	end
end

function public:update()
	if not self.Character or not self.Character.Parent then
		return
	end
	if not self.Character:FindFirstChild("HumanoidRootPart") then
		return
	end

	self.targetPlayer = self:nearestPlayer(self.Character)
	if self.currentState and self.currentState.onUpdate then
		self.currentState.onUpdate(self.Character, self, self.targetPlayer)
	end
end

function public:nearestPlayer(enemy)
	local nearest = nil
	local minDistance = math.huge

	local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
	if not enemyRoot then
		return nil
	end -- guard here too

	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		if not character then
			continue
		end

		local playerRoot = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChild("Humanoid")

		if not playerRoot or not humanoid then
			continue
		end
		if humanoid.Health <= 0 then
			continue
		end

		local distance = (playerRoot.Position - enemyRoot.Position).Magnitude
		if distance <= range and distance < minDistance then
			minDistance = distance
			nearest = player
		end
	end

	return nearest
end

return public
