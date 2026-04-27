local public = {}

function public.onEnter(enemy)
	-- print(enemy.Name .. " entered state: Chase")
	enemy.Humanoid.WalkSpeed = 10
end

function public.onUpdate(enemy, handler, player)
	if not player or not player.Character then
		handler:changeState("Idle")
		return
	end

	local enemyStats = handler.data.stats
	local targetRoot = player.Character.HumanoidRootPart
	local distanceToPlayer = (enemy.HumanoidRootPart.Position - targetRoot.Position).Magnitude
	local distanceFromOrigin = (targetRoot.Position - handler.data.origin).Magnitude

	if distanceToPlayer <= enemyStats.attackRange then
		handler:changeState("Attack")
	elseif distanceFromOrigin >= enemyStats.aggroLoseRange then
		handler:changeState("Idle")
	else
		enemy.Humanoid:MoveTo(targetRoot.Position)
	end
end
function public.onExit() end

return public
