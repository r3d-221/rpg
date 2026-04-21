local public = {}

local attackCooldown = 5

function public.onEnter(enemy, handler)
	-- print(enemy.Name .. " entered state: Attack")
	enemy.Humanoid.WalkSpeed = 0
	handler.data._lastAttack = 0
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

	local now = tick()
	if now - handler.data._lastAttack >= attackCooldown then
		handler.data._lastAttack = now
		local playerArmor = 20 -- will change later
		local damage = public._calculateDamage(enemyStats, playerArmor)
		player.Character.Humanoid:TakeDamage(damage)
	end
end

function public._calculateCrit(stats)
	if math.random() <= stats.critRate then
		return stats.damage * stats.critDamage
	end
	return stats.damage
end

function public._calculateDamage(stats, playerArmor)
	local rawDamage = public._calculateCrit(stats)

	local effectiveArmor = math.max(0, playerArmor - stats.armorPenetration)
	local damageReduction = effectiveArmor / (effectiveArmor + 100)
	damageReduction = math.min(damageReduction, 0.75) -- cap at 75% damage recuction

	return math.floor(rawDamage * (1 - damageReduction))
end

function public.onExit() end

return public
