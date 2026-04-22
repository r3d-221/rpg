local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local public = {}
local private = {}

function public.onEnter(enemy, handler)
	handler.data.isAttacking = false
	handler.data.lastBasicAttack = 0
	handler.data.cooldowns = handler.data.cooldowns or {}
end

function public.onUpdate(enemy, handler, player)
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

	local config = handler.data.config
	if not config then
		return
	end

	local now = tick()

	if handler.data.isAttacking then
		return
	end

	local ability = private.pickAttack(config, handler.data.cooldowns)
	if ability then
		task.spawn(private.performAttack, enemy, handler, ability)
		return
	end

	if now - handler.data.lastBasicAttack >= enemyStats.basicAttackCooldown then
		local basicAttack = config.basicAttack
		if basicAttack then
			task.spawn(private.performAttack, enemy, handler, basicAttack)
		end
	end
end

function public.onExit() end

function private.calculateCrit(stats, damageMultiplier)
	local base = stats.damage * damageMultiplier
	if math.random() <= stats.critRate then
		return base * stats.critDamage
	end
	return base
end

function private.calculateDamage(stats, playerArmor, damageMultiplier)
	local rawDamage = private.calculateCrit(stats, damageMultiplier)
	local effectiveArmor = math.max(0, playerArmor - stats.armorPenetration)
	local damageReduction = math.min(effectiveArmor / (effectiveArmor + 100), 0.75)
	return math.floor(rawDamage * (1 - damageReduction))
end

function private.hitboxVisual(radius: number, RootPart: BasePart, active: number)
	local sphere = Instance.new("Part")
	sphere.Shape = Enum.PartType.Ball
	sphere.Color = Color3.fromRGB(236, 119, 131)
	sphere.Material = Enum.Material.Neon
	sphere.Transparency = 0.5
	sphere.Anchored = true
	sphere.CanCollide = false
	sphere.Size = Vector3.new(radius * 2, radius * 2, radius * 2)
	sphere.Position = RootPart.Position
	sphere.Parent = workspace
	game:GetService("Debris"):AddItem(sphere, active)
end

function private.getPartsHit(enemy: Model, rootPart: BasePart, radius: number): { [Humanoid]: true }
	local params = OverlapParams.new()
	params.FilterDescendantsInstances = { enemy }
	params.FilterType = Enum.RaycastFilterType.Exclude

	local hits: { [Humanoid]: true } = {}
	for _, part in workspace:GetPartBoundsInRadius(rootPart.Position, radius, params) do
		local model = part.Parent
		local hum: Humanoid? = model:FindFirstChildOfClass("Humanoid")

		if hum and not hits[hum] and hum.Health > 0 then
			local isPlayer = Players:GetPlayerFromCharacter(model) ~= nil
			if isPlayer then
				hits[hum] = true
			end
		end
	end
	return hits
end

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

	return pool[#pool]
end

function private.performAttack(enemy, handler, ability)
	handler.data.isAttacking = true
	enemy.Humanoid.WalkSpeed = 0

	local stats = handler.data.stats
	local RootPart = handler.data.RootPart
	local animationTime = ability.windUp + ability.active + ability.recovery

	task.wait(ability.windUp)

	local hits = private.getPartsHit(enemy, RootPart, ability.hitbox.range)

	for humanoid in hits do
		local playerArmor = 20 -- will change later
		local damage = private.calculateDamage(stats, playerArmor, ability.damageMultiplier)
		humanoid:TakeDamage(damage)
	end

	if RunService:IsStudio() then
		private.hitboxVisual(ability.hitbox.range, RootPart, ability.active)
	end

	task.wait(ability.active + ability.recovery)

	enemy.Humanoid.WalkSpeed = stats.walkspeed
	handler.data.isAttacking = false

	handler.data.cooldowns[ability.name] = tick()

	local isBasicAttack = ability.name == "basicAttack"
	if isBasicAttack then
		handler.data.lastBasicAttack = tick()
	else
		handler.data.cooldowns[ability.name] = tick()
	end
end

return public
