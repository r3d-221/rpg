local Players = game:GetService("Players")

local public = {}
local callbacks = {}

local player = Players.LocalPlayer
local screenGui = player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")

local screens = {
	inventory = screenGui:WaitForChild("inventory"),
	fullInfo = screenGui:WaitForChild("fullInfo"),
	quickInfo = screenGui:WaitForChild("quickInfo"),
}

function public.onEvent(name: string, fn: (...any) -> ())
	callbacks[name] = fn
end

function public.fire(name: string, ...: any)
	if callbacks[name] then
		callbacks[name](...)
	end
end

function public.toggle(name: string)
	local screen = screens[name]
	if not screen then
		return
	end
	screen.Visible = not screen.Visible

	if name == "inventory" and not screen.Visible then
		public.close("fullInfo")
		public.close("quickInfo")
	end
end

function public.closeAll()
	for _, screen in screens do
		screen.Visible = false
	end
end

function public.open(name: string)
	local screen = screens[name]
	if screen then
		screen.Visible = true
	end
end

function public.close(name: string)
	local screen = screens[name]
	if screen then
		screen.Visible = false
	end
end

return public
