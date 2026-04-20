local public = {}

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
	if now - handler.data._lastAttack >= enemyStats.attackCooldown then
		handler.data._lastAttack = now
		player.Character.Humanoid:TakeDamage(enemyStats.damage)
	end
end

function public.onExit() end

return public
