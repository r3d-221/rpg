local public = {}

function public.onEnter(enemy)
	enemy.Humanoid.Health = 0
	task.delay(3, function()
		enemy.Parent:Destroy()
	end)
end

function public.onUpdate() end

function public.onExit() end

return public
