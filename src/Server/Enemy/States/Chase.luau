local public = {}

local attackRange = 30
local aggroLoseRange = 50

function public.onEnter(enemy)
	print(enemy.Name .. " entered state: Chase")
	enemy.Humanoid.WalkSpeed = 16
end

function public.onUpdate(enemy, handler, player)
	if not player or not player.Character then
		handler:changeState("Idle")
		return
	end

	local targetRoot = player.Character.HumanoidRootPart
	local distance = (enemy.HumanoidRootPart.Position - targetRoot.Position).Magnitude
	print(distance)

	if distance <= attackRange then
		handler:changeState("Attack")
		print(enemy.Name .. " changed state to: Attack")
	elseif distance >= aggroLoseRange then
		handler:changeState("Idle")
		print(enemy.Name .. " changed state to: Idle")
	else
		enemy.Humanoid:MoveTo(targetRoot.Position)
	end
end

function public.onExit() end

return public
