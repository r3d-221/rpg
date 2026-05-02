local public = {}

function public.onEnter(enemy)
	-- print("changed " .. enemy.Name .. " state to: Dead")
	task.delay(3, function()
		if enemy and enemy.Parent then
			enemy:Destroy()
		end
	end)
end

function public.onUpdate() end

function public.onExit() end

return public
