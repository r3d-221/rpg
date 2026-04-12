local public = {}

local attackRange = 5
local damage = 20
local attackCooldown = 1.5
local lastAttack = 0

function public.onEnter(enemy)
	enemy.Humanoid.Walkspeed = 0
end

function public.onUpdate(enemy, handler)
	local player = game.Players:GetPlayers()[1]
	if not player or not player.Character then
		handler:changeState("Idle")
		return
	end

	local distance = (enemy.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude

	if distance > attackRange then
		handler:changeState("Chase")
		return
	end

	local now = tick()
	if now - lastAttack >= attackCooldown then
		lastAttack = now
		player.Character.Humanoid:TakeDamage(damage)
	end
end

function public.onExit() end

return public
