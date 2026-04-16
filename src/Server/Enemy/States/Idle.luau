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
		-- print("player character not found")
		-- print(player)
		return
	end

	-- print("player found for: " .. enemy.Name)

	local distance = (enemy.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
	-- print(distance)

	if distance <= aggroRange then
		handler:changeState("Chase")
		print(enemy.Name .. " changed state to: Chase")
	end
end

function public.onExit() end

return public
