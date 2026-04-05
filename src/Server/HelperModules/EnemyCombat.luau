local private = {}
local public = {}
public.__index = public

---- "Telegraph logic" ----
-- anticipation -- wind up
-- active -- time of hitting
-- recovery -- enemy stops after attack

---- Special Queries ----
-- for range, use raycast

--TO DO
--1. get notified when the enemy stops at the destination -- if range then set it from the configs
--2. check in range if any players are around
--3. if players found, play animation
--4. after animation, check again if the targeted player(s) is in range and then do damage
--5. notify the player of how much damage is done

---- Settings ----
local attackRange = 4
local damage = 20
local windUpTime = 0.6
local recoveryTime = 0.8

---- Constructer ----
function public.new(controller)
	local self = setmetatable({}, public)
	
	self.Controller = controller
	self.Enemy = controller.Model
	self.Humanoid = self.Enemy:WaitForChild("Humanoid")
	self.RootPart = self.Enemy:WaitForChild("HumanoidRootPart")
	self.canAttack = true
	
	self.Controller.Navigation.onDestinationReached.Event:Connect(function(attackPosition)
		self:_attamptToAttack()
	end)
	
	return self
end

-- tries to attack the player
function public:_attamptToAttack()
	if not self.canAttack or self.Humanoid.Health <= 0 then return end
	
	self.canAttack = false -- debounce

	self.Humanoid:Move(Vector3.new(0,0,0)) -- wind up
	
	task.wait(windUpTime) -- animation replacement
	
	self:_createHitbox() -- damage
	
	task.wait(recoveryTime)
	self.canAttack = true
end

-- creates a hitbox to damage the player
function public:_createHitbox()
	-- avoid hitting the enemy itself
	local overlapParams = OverlapParams.new()
	overlapParams.FilterDescendantsInstances = {self.Enemy}
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	
	-- creates a sphere at the rootPart
	local sphereHitbox = workspace:GetPartBoundsInRadius(self.RootPart.Position, attackRange, overlapParams)
	
	-- how many players hit in one attack
	local damagedHumanoids = {}
	
	-- finds the humanoids in the hitbox
	for _, part in ipairs(sphereHitbox) do
		local model = part.Parent
		local humanoid = model:FindFirstChild("Humanoid")
		
		if humanoid and not damagedHumanoids[humanoid] then
			if humanoid.Health > 0 then
				damagedHumanoids[humanoid] = true
				humanoid:TakeDamage(damage)
				
				print(self.Enemy.Name.." has dealt "..damage.." damage to "..model.Name)
			end
		end
	end
	
	if game:GetService("RunService"):IsStudio() then
		self:_showHitboxVisual()
	end
end

-- for studio testing
function public:_showHitboxVisual()
	local sphere = Instance.new("Part")
	sphere.Shape = Enum.PartType.Ball
	sphere.Color = Color3.fromRGB(236, 119, 131)
	sphere.Material = Enum.Material.Neon
	sphere.Transparency = 0.5
	sphere.Anchored = true
	sphere.Anchored = true
	sphere.CanCollide = false
	sphere.Size = Vector3.new(attackRange * 2, attackRange * 2, attackRange * 2)
	sphere.Position = self.RootPart.Position
	sphere.Parent = workspace
	
	game.Debris:AddItem(sphere, 0.2)
end

return public