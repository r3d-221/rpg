local public = {}

local roamRange = 15

local MAX_IDLE = 1.3
local MIN_IDLE = 0.5

function public.onEnter(enemy, handler)
	print("changed " .. enemy.Name .. " state to: Idle")
	handler.data.isRoaming = true

	task.spawn(function()
		while handler.data.isRoaming do
			if not enemy or not enemy.Parent then
				break
			end

			local origin = handler.data.origin
			local root = handler.data.RootPart
			if not root then
				break
			end

			local y = root.Position.Y
			local x = math.random(origin.X - roamRange, origin.X + roamRange)
			local z = math.random(origin.Z - roamRange, origin.Z + roamRange)

			handler.data.Humanoid:MoveTo(Vector3.new(x, y, z))

			-- timeout so it doesn't hang forever if MoveTo fails
			local moved = false
			local conn
			conn = handler.data.Humanoid.MoveToFinished:Connect(function()
				moved = true
				conn:Disconnect()
			end)

			local elapsed = 0
			while not moved and elapsed < 5 do
				task.wait(0.1)
				elapsed += 0.1
			end
			conn:Disconnect() -- disconnect if timeout hit

			local idleTime = math.random() * (MAX_IDLE - MIN_IDLE) + MIN_IDLE
			task.wait(idleTime)
		end
	end)
end

function public.onUpdate(enemy, handler, player)
	if not player or not player.Character then
		return
	end

	local enemyStats = handler.data.stats
	local distance = (enemy.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude

	if distance <= enemyStats.aggroRange then
		handler:changeState("Chase")
	end
end

function public.onExit(enemy, handler)
	handler.data.isRoaming = false
end

return public
