local public = {}

local aggroRange = 20

function public.onEnter(enemy)
	print(enemy.Name .. " entered state: Idle")
	-- roam
	-- play animation
	enemy.Humanoid.WalkSpeed = 0
end

function public.onUpdate(enemy, handler, player)
	if not player or not player.Character then
		return
	end

	local distance = (enemy.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude

	if distance <= aggroRange then
		handler:changeState("Chase")
	end
end

function public.onExit() end

return public
