local public = {}

local attackRange = 5
local aggroLoseRange = 40

function public.onEnter(enemy)
	print(enemy.Name .. " entered state: Chase")
	enemy.Humanoid.WalkSpeed = 10
end

function public.onUpdate(enemy, handler, player)
	if not player or not player.Character then
		handler:changeState("Idle")
		return
	end

	local targetRoot = player.Character.HumanoidRootPart
	local distanceToPlayer = (enemy.HumanoidRootPart.Position - targetRoot.Position).Magnitude
	local distanceFromOrigin = (targetRoot.Position - handler.data.origin).Magnitude

	if distanceToPlayer <= attackRange then
		handler:changeState("Attack")
	elseif distanceFromOrigin >= aggroLoseRange then
		handler:changeState("Idle")
	else
		enemy.Humanoid:MoveTo(targetRoot.Position)
	end
end
function public.onExit() end

return public
