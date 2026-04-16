local public = {}

local attackRange = 5
local damage = 20
local attackCooldown = 1.5

function public.onEnter(enemy, handler)
	print(enemy.Name .. " entered state: Attack")
	enemy.Humanoid.WalkSpeed = 0
	handler.data._lastAttack = 0
end

function public.onUpdate(enemy, handler, player)
	if not player or not player.Character then
		print(enemy.Name .. " changed state to: Idle")
		handler:changeState("Idle")
		return
	end

	local distance = (enemy.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude

	if distance > attackRange then
		print(enemy.Name .. " changed state to: Chase")
		handler:changeState("Chase")
		return
	end

	local now = tick()
	if now - handler.data._lastAttack >= attackCooldown then
		handler.data._lastAttack = now
		player.Character.Humanoid:TakeDamage(damage)
	end
end

function public.onExit() end

return public
