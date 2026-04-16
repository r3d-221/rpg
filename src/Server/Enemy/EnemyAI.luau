local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local public = {}
public.__index = public

---- Settings ----
local aggroRange = 30
local roamRange = 10

local detectionCooldown = 1
local thinkingTime = 0.2

local MIN_IDLE = 0.5
local MAX_IDLE = 3

local attackRange = 4
local RECOMPUTE_INTERVAL = 0.5
local RECOMPUTE_MOVE_THRESHOLD = 3 -- player's movement in studs that triggers recompute of the path

---- TO DO ----
-- when enemy loses aggro, it should try to go back to its origin position
-- when enemy gets close enough to the player to attack, it should call canAttack (maybe)

---- BUGS ----
-- the offsetFromPlayer makes it so if the player comes too close, the enemy starts to back away and so it cant get close enought to attack the player
-- what the hell is the logic for the offsetFromPlayer

---- Constructer ----
function public.new(controller)
	local self = setmetatable({}, public)

	self.Character = controller.Character
	self.Humanoid = controller.Humanoid
	self.HumanoidRootPart = controller.HumanoidRootPart
	self.OriginPosition = self.HumanoidRootPart.Position

	-- states
	self.alive = true
	self.isChasing = false

	-- properties
	self.RootPart:SetNetworkOwner(nil)
	self:_setCollisionGroup()

	-- inform when target found
	self.onDestinationReached = Instance.new("BindableEvent")

	task.wait(math.random() * 0.2)
	self:_behavior()

	return self
end

-- sets the collision groups so the enemies don't collide with other enemies
function public:_setCollisionGroup()
	for _, obj in self.Character:GetDescendants() do
		if obj:IsA("BasePart") then
			obj.CollisionGroup = "Character"
		end
	end
end

-- enemy ai
function public:_behavior()
	task.spawn(function()
		public:_decision()
	end)

	task.spawn(function()
		public:_react()
	end)
end

-- sets the target
function public:_decision()
	while self.alive and self.Humanoid.Health > 0 do
		if self.target then
			local targetCharacter = self.target.Character
			local targetRoot = targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart")
			if not targetRoot then
				self.target = nil
				self.isChasing = false
				continue
			end

			self.isChasing = true

			-- loses aggro if target is too far away
			local distance = (targetRoot.Position - self.Origin).Magnitude
			if distance > aggroRange then
				self.target = nil
				self.isChasing = false
			end
		else
			self.target = self:_getNearestPlayer()
		end
		task.wait(detectionCooldown)
	end
end

-- sets states to chase or roam
function public:_react()
	while self.alive and self.Humanoid.Health > 0 do
		if self.target then
			self.isChasing = true
			self:_followPlayer(self.target)
			task.wait(thinkingTime)
		else
			self.isChasing = false
			self:_roam()
			task.wait(thinkingTime)
		end
	end
end

-- still not sure about this
-- decides if the enemy can attack or not
function public:canAttack()
	-- call it in follow player
	-- check if target is close enough
	-- notify combat system to attack
	-- roam if target not found
end

-- for roaming around
function public:_roam()
	if self.isChasing then
		return
	end

	local origin = self.Origin
	local y = self.RootPart.Position.Y
	local x = math.random(origin.X - roamRange, origin.X + roamRange)
	local z = math.random(origin.Z - roamRange, origin.Z + roamRange)

	local destination = Vector3.new(x, y, z)
	self.Humanoid:MoveTo(destination)
	self.Humanoid.MoveToFinished:Wait()

	local idleTime = math.random() * (MAX_IDLE - MIN_IDLE) + MIN_IDLE
	task.wait(idleTime)
end

-- keeps the enemy at a certain distance from the player
function public:_offsetFromPlayer(playerRootPart: BasePart, keepDistance: number)
	local position = self.RootPart.Position
	local playerPosition = playerRootPart.Position

	local directionVector = position - playerPosition
	local distance = directionVector.Magnitude

	-- default distance if ofsetting isnt possible
	if distance <= 0.001 then
		directionVector = Vector3.new(math.random() - 0.5, 0, math.random() - 0.5)
		distance = directionVector.Magnitude

		-- if distance is too low then default offset is 1 studs in x direction
		if distance <= 0.001 then
			directionVector = Vector3.new(1, 0, 0)
			distance = 1
		end
	end

	local unit = directionVector / distance
	return playerPosition + unit * keepDistance
end

-- Line of sight of the enemy
function public:_canSeeTarget(targetPart)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = { self.Character, targetPart.Parent }
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude

	local result =
		workspace:Raycast(self.RootPart.Position, (targetPart.Position - self.RootPart.Position), raycastParams)

	return result == nil -- if nil then there are no obstecles
end

-- follows the target player
function public:_followPlayer(player: Player)
	local character = player.Character
	if not character then
		return
	end

	local targetRoot = character:FindFirstChild("HumanoidRootPart")
	local targetHumanoid = character:FindFirstChild("Humanoid")

	if not targetRoot or targetHumanoid.Health <= 0 then
		return
	end

	local distanceToPlayer = (self.RootPart.Position - targetRoot.Position).Magnitude

	local stopDistance = attackRange + 2

	-- attack range check
	if distanceToPlayer <= attackRange then
		self.onDestinationReached:Fire(distanceToPlayer)
		self.Humanoid:Move(Vector3.zero) -- Stop moving to attack
		return
	end

	-- if enemy can see target then no need for pathing
	if self:_canSeeTarget(targetRoot) then
		local targetPositionOffset = self:_offsetFromPlayer(targetRoot, stopDistance)
		self.Humanoid:MoveTo(targetPositionOffset)
		return
	end

	-- pathfinding
	local targetPositionOffset = self:_offsetFromPlayer(targetRoot, stopDistance)
	local path = PathfindingService:CreatePath({
		AgentCanJump = true,
		WaypointSpacing = 4, -- Larger spacing means smoother movement
	})

	path:ComputeAsync(self.RootPart.Position, targetPositionOffset)

	if path.Status ~= Enum.PathStatus.Success then
		self.Humanoid:MoveTo(targetPositionOffset)
		return
	end

	local waypoints = path:GetWaypoints()

	-- only follows the first few waypoints before checking again for smoother movement
	for i = 2, math.min(#waypoints, 5) do
		local waypoint = waypoints[i]

		if not self.isChasing then
			break
		end

		if waypoint.Action == Enum.PathWaypointAction.Jump then
			self.Humanoid.Jump = true
		end

		self.Humanoid:MoveTo(waypoint.Position)

		-- timeout or close to waypoint
		local startWait = tick()
		repeat
			task.wait()
		until (self.RootPart.Position - waypoint.Position).Magnitude < 3 or (tick() - startWait > 0.5)

		-- checks if enemy has LOS while on path
		if i % 2 == 0 and self:_canSeeTarget(targetRoot) then
			break
		end
	end
end
-- finds the nearest players
function public:_getNearestPlayer(): Player?
	local nearest = nil
	local minDistance = math.huge

	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		if not character then
			continue
		end

		local root = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChild("Humanoid")

		if not root or not humanoid then
			continue
		end
		if humanoid.Health <= 0 then
			continue
		end

		local distance = (root.Position - self.RootPart.Position).Magnitude

		if distance <= aggroRange and distance < minDistance then
			minDistance = distance
			nearest = player
		end
	end

	return nearest
end

-- makes debug parts when in studio
function public:_debugWaypoint(position: Vector3)
	local folder = workspace:FindFirstChild("debugParts")
	if not folder then
		return
	end

	local part = Instance.new("Part")
	part.Shape = Enum.PartType.Ball
	part.Material = Enum.Material.Neon
	part.Anchored = true
	part.CanCollide = false
	part.Size = Vector3.new(0.5, 0.5, 0.5)
	part.Position = position
	part.Parent = folder

	game.Debris:AddItem(part, 3)
end

return public
