local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local PlayerDataHandler = require(ServerScriptService.Server.Player.PlayerDataHandler)

local public = {}
local private = {}

function public.onEnter(enemy, handler)
	handler.data.isAttacking = false
	handler.data.lastBasicAttack = 0
	handler.data.cooldowns = handler.data.cooldowns or {}

	enemy.Humanoid.WalkSpeed = 0
	enemy.Humanoid:MoveTo(enemy.HumanoidRootPart.Position)
end

function public.onUpdate(enemy, handler, player)
	if handler.data.isAttacking then
		return
	end

	local config = handler.data.config
	if not config then
		return
	end

	if not player or not player.Character then
		handler:changeState("Idle")
		return
	end

	local enemyStats = handler.data.stats
	local distance = (enemy.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude

	if distance > enemyStats.attackRange then
		handler:changeState("Chase")
		return
	end

	-- pick an ability if not on cooldown
	local ability = private.pickAttack(config, handler.data.cooldowns)
	if ability then
		-- print(enemy.Name .. " did a " .. ability.name)
		handler.data.isAttacking = true
		task.spawn(private.performAttack, enemy, handler, player, ability)
		return
	end

	local now = tick()

	-- do basic attack if ability on cooldown
	if now - handler.data.lastBasicAttack >= enemyStats.basicAttackCooldown then
		local basicAttack = config.basicAttack
		if basicAttack then
			-- print(enemy.Name .. " did a basic attack")
			handler.data.isAttacking = true
			task.spawn(private.performAttack, enemy, handler, player, basicAttack)
		end
	end
end

function public.onExit(enemy, handler)
	enemy.Humanoid.WalkSpeed = handler.data.stats.walkspeed
end

-- calculates the damage based on the crit damage if it procs
function private.calculateCrit(stats, damageMultiplier, modifiers)
	local base = stats.damage * damageMultiplier
	if modifiers.guaranteedCrit or math.random() <= stats.critRate then
		-- print("Crit!")
		return base * stats.critDamage
	end
	return base
end

-- calculates the damage after the damage reduction
function private.calculateDamage(stats, playerArmor, damageMultiplier, modifiers)
	local rawDamage = private.calculateCrit(stats, damageMultiplier, modifiers)
	local effectiveArmor = math.max(0, playerArmor - stats.armorPenetration)
	local damageReduction = math.min(effectiveArmor / (effectiveArmor + 100), 0.75)
	return math.floor(rawDamage * (1 - damageReduction))
end

-- hitbox for spheres
function private.sphereVisual(RootPart, range, windUp, active)
	-- Wind-up visual
	local windUpSphere = Instance.new("Part")
	windUpSphere.Shape = Enum.PartType.Ball
	windUpSphere.Color = Color3.fromRGB(255, 200, 50)
	windUpSphere.Material = Enum.Material.Neon
	windUpSphere.Transparency = 0.6
	windUpSphere.Anchored = true
	windUpSphere.CanCollide = false
	windUpSphere.Size = Vector3.new(range * 2, range * 2, range * 2)
	windUpSphere.Position = RootPart.Position
	windUpSphere.Parent = workspace
	game:GetService("Debris"):AddItem(windUpSphere, windUp)

	-- Active visual
	task.delay(windUp, function()
		local activeSphere = Instance.new("Part")
		activeSphere.Shape = Enum.PartType.Ball
		activeSphere.Color = Color3.fromRGB(236, 119, 131)
		activeSphere.Material = Enum.Material.Neon
		activeSphere.Transparency = 0.5
		activeSphere.Anchored = true
		activeSphere.CanCollide = false
		activeSphere.Size = Vector3.new(range * 2, range * 2, range * 2)
		activeSphere.Position = RootPart.Position
		activeSphere.Parent = workspace
		game:GetService("Debris"):AddItem(activeSphere, active)
	end)
end

-- hitbox for arcs
function private.arcVisual(rootPart: BasePart, range: number, angle: number, windUp: number, active: number)
	local rayCount = 8
	local forward = rootPart.CFrame.LookVector

	for i = 0, rayCount do
		local t = i / rayCount
		local currentAngle = math.rad((t - 0.5) * angle * 2)
		local rotated = (CFrame.fromAxisAngle(Vector3.yAxis, currentAngle) * CFrame.new(Vector3.zero, forward)).LookVector
		local direction = rotated.Unit

		local midPoint = rootPart.Position + direction * (range / 2)

		-- Wind-up line
		local line = Instance.new("Part")
		line.Size = Vector3.new(0.1, 0.1, range)
		line.CFrame = CFrame.lookAt(midPoint, midPoint + direction)
		line.Color = Color3.fromRGB(255, 200, 50)
		line.Material = Enum.Material.Neon
		line.Transparency = 0.4
		line.Anchored = true
		line.CanCollide = false
		line.Parent = workspace
		game:GetService("Debris"):AddItem(line, windUp)

		-- Active line
		task.delay(windUp, function()
			local activeLine = Instance.new("Part")
			activeLine.Size = Vector3.new(0.2, 0.2, range)
			activeLine.CFrame = CFrame.lookAt(midPoint, midPoint + direction)
			activeLine.Color = Color3.fromRGB(236, 119, 131)
			activeLine.Material = Enum.Material.Neon
			activeLine.Transparency = 0.3
			activeLine.Anchored = true
			activeLine.CanCollide = false
			activeLine.Parent = workspace
			game:GetService("Debris"):AddItem(activeLine, active)
		end)
	end
end

-- hitbox for raycasts
function private.raycastVisual(rootPart: BasePart, targetPosition: Vector3, windUp: number, active: number)
	local direction = (targetPosition - rootPart.Position)
	local distance = direction.Magnitude
	local midPoint = rootPart.Position + direction.Unit * (distance / 2)

	-- Wind-up
	local windUpBeam = Instance.new("Part")
	windUpBeam.Size = Vector3.new(0.05, 0.05, distance)
	windUpBeam.CFrame = CFrame.lookAt(midPoint, midPoint + direction.Unit)
	windUpBeam.Color = Color3.fromRGB(255, 200, 50)
	windUpBeam.Material = Enum.Material.Neon
	windUpBeam.Transparency = 0.3
	windUpBeam.Anchored = true
	windUpBeam.CanCollide = false
	windUpBeam.Parent = workspace
	game:GetService("Debris"):AddItem(windUpBeam, windUp)

	-- Active
	task.delay(windUp, function()
		local activeBeam = Instance.new("Part")
		activeBeam.Size = Vector3.new(0.15, 0.15, distance)
		activeBeam.CFrame = CFrame.lookAt(midPoint, midPoint + direction.Unit)
		activeBeam.Color = Color3.fromRGB(236, 119, 131)
		activeBeam.Material = Enum.Material.Neon
		activeBeam.Transparency = 0.2
		activeBeam.Anchored = true
		activeBeam.CanCollide = false
		activeBeam.Parent = workspace
		game:GetService("Debris"):AddItem(activeBeam, active)
	end)
end

-- visual for the attack
function private.hitboxVisual(ability, RootPart: BasePart, targetPosition: Vector3?)
	local hitboxType = ability.hitbox.type
	local windUp = ability.windUp
	local active = ability.active

	if hitboxType == "sphere" then
		private.sphereVisual(RootPart, ability.hitbox.range, windUp, active)
	elseif hitboxType == "arc" then
		private.arcVisual(RootPart, ability.hitbox.range, ability.hitbox.angle or 60, windUp, active)
	elseif hitboxType == "raycast" then
		if targetPosition then
			private.raycastVisual(RootPart, targetPosition, windUp, active)
		end
	end
end

-- gets all the players hit by the hitbox
function private.getPartsHit(enemy: Model, RootPart: BasePart, ability): { [Humanoid]: true }
	local params = OverlapParams.new()
	params.FilterDescendantsInstances = { enemy }
	params.FilterType = Enum.RaycastFilterType.Exclude

	local hits: { [Humanoid]: true } = {}
	local parts = {}

	if ability.hitbox.type == "sphere" then
		parts = workspace:GetPartBoundsInRadius(RootPart.Position, ability.hitbox.range, params)
	elseif ability.hitbox.type == "arc" then
		local allParts = workspace:GetPartBoundsInRadius(RootPart.Position, ability.hitbox.range, params)
		local forward = RootPart.CFrame.LookVector

		for _, part in allParts do
			local toTarget = (part.Position - RootPart.Position)
			if toTarget.Magnitude > 0 then --  if the player isn't literally inside the enemy, it will run
				local dot = forward:Dot(toTarget.Unit)
				local angle = math.deg(math.acos(math.clamp(dot, -1, 1)))
				-- ability.hitbox.angle defines half of the arc
				if angle <= (ability.hitbox.angle or 60) then
					table.insert(parts, part)
				end
			end
		end
	end

	for _, part in parts do
		local model = part.Parent
		local hum: Humanoid? = model:FindFirstChildOfClass("Humanoid")
		if hum and not hits[hum] and hum.Health > 0 then
			if Players:GetPlayerFromCharacter(model) then
				hits[hum] = true
			end
		end
	end

	return hits
end

-- uses raycast for ranged enemies
function private.fireRaycast(enemy, handler, player, ability)
	local RootPart = handler.data.RootPart
	local stats = handler.data.stats

	local targetRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not targetRoot then
		return
	end

	local rayParams = RaycastParams.new()
	-- Only hits player character parts, ignores everything else
	rayParams.FilterDescendantsInstances = { player.Character }
	rayParams.FilterType = Enum.RaycastFilterType.Include

	local origin = RootPart.Position
	local direction = (targetRoot.Position - origin).Unit
	local result = workspace:Raycast(origin, direction * ability.hitbox.range, rayParams)

	if not result then
		return
	end

	local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		return
	end

	local playerData = PlayerDataHandler.getData(player)
	local playerArmor = playerData and playerData.stats.armor or 0
	local damage = private.calculateDamage(stats, playerArmor, ability.damageMultiplier, ability.modifiers or {})
	-- print(enemy.Name .. " did " .. damage .. " damage")
	humanoid:TakeDamage(damage)
end

-- chooses which attack to perform based on availability
function private.pickAttack(config, cooldowns: {})
	local pool = {}
	local totalWeight = 0

	for _, ability in config.abilities do
		local lastUsed = cooldowns[ability.name] or 0
		if tick() - lastUsed >= ability.cooldown then
			table.insert(pool, ability)
			totalWeight += ability.weight
		end
	end

	if totalWeight == 0 then
		return
	end

	local roll = math.random() * totalWeight
	local cumulative = 0
	for _, ability in pool do
		cumulative += ability.weight
		if roll <= cumulative then
			return ability
		end
	end

	return pool[#pool] --  makes sure that if the rolled ability is not available then it still does an attack
end

-- does the wind-up, active, recovery and sets timestamp on the ability cooldowns
function private.performAttack(enemy, handler, player, ability)
	enemy.Humanoid.WalkSpeed = 0

	local stats = handler.data.stats
	local RootPart = handler.data.RootPart
	local hitboxType = ability.hitbox.type
	local modifiers = ability.modifiers or {}
	local animationTime = ability.windUp + ability.active + ability.recovery

	-- creates hitbox visual
	if RunService:IsStudio() then
		local targetPosition = nil
		if ability.hitbox.type == "raycast" then
			local targetRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			targetPosition = targetRoot and targetRoot.Position
		end
		private.hitboxVisual(ability, RootPart, targetPosition)
	end

	task.wait(ability.windUp)

	if not modifiers.ignoreAttackRange then
		local humanoid = enemy:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 then
			handler.data.isAttacking = false
			return
		end
	end

	local hits = {}
	if hitboxType == "raycast" then
		private.fireRaycast(enemy, handler, player, ability) --  doesn't save the hits so no double damage
	else
		hits = private.getPartsHit(enemy, RootPart, ability)
	end

	local playerArmor = 20 -- will change later
	for humanoid in hits do
		local damage = private.calculateDamage(stats, playerArmor, ability.damageMultiplier, modifiers)
		-- print(enemy.Name .. " did " .. damage .. " damage")
		humanoid:TakeDamage(damage)
	end

	task.wait(ability.active + ability.recovery)

	enemy.Humanoid.WalkSpeed = stats.walkspeed
	handler.data.isAttacking = false

	-- puts a timestamp on the cooldown for the abilities
	if ability.name == "basicAttack" then
		handler.data.lastBasicAttack = tick()
	else
		handler.data.cooldowns[ability.name] = tick()
	end
end

return public
