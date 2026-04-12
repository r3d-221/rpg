local public = {}

local attackRange = 5
local aggroLoseRange = 40

function public.onEnter(enemy)
	enemy.Humanoid.Walkspeed = 16
end

function public.onUpdate(enemy, handler)
	local player = game.Players:GetPlayers()[1] -- needs to be the same target that the idle state focused on
	if not player or not player.Character then
		handler:changeState("Idle")
		return
	end

	local targetRoot = player.Character.HumanoidRootPart
	local distance = (enemy.HumanoidRootPart.Position - targetRoot.Position).Magnitude

	if distance <= attackRange then
		handler:changeState("Attack")
	elseif distance >= aggroLoseRange then
		handler:changeState("Idle")
	else
		enemy.Humanoid:MoveTo(targetRoot.Position)
	end
end

function public.onExit() end

return public
