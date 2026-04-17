local public = {}

local aggroRange = 20
local roamRange = 15

local MAX_IDLE = 1.3
local MIN_IDLE = 0.5

function public.onEnter(enemy, handler)
	print(enemy.Name .. " entered state: Idle")
	handler.data.isRoaming = true

	task.spawn(function()
		while handler.data.isRoaming do
			public:_roam(handler)
		end
	end)
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

function public.onExit(handler)
	handler.data.isRoaming = false
end

function public:_roam(handler)
	local origin = handler.data.origin
	local y = handler.data.RootPart.Position.Y
	local x = math.random(origin.X - roamRange, origin.X + roamRange)
	local z = math.random(origin.Z - roamRange, origin.Z + roamRange)

	local destination = Vector3.new(x, y, z)
	handler.data.Humanoid:MoveTo(destination)
	handler.data.Humanoid.MoveToFinished:Wait()

	local idleTime = math.random() * (MAX_IDLE - MIN_IDLE) + MIN_IDLE
	task.wait(idleTime)
end

return public
