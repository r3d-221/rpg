local Players = game:GetService("Players")

local private = {}
local public = {}
local callbacks = {}

local player = Players.LocalPlayer
local screenGui = player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")

local screens = {
	inventory = screenGui:WaitForChild("inventory"),
	fullInfo = screenGui:WaitForChild("fullInfo"),
	quickInfo = screenGui:WaitForChild("quickInfo"),
}

function private.getScreen(name: string)
	return screenGui:FindFirstChild(name)
end

function public.onEvent(name: string, fn: (...any) -> ())
	callbacks[name] = fn
end

function public.fire(name: string, ...: any)
	if callbacks[name] then
		callbacks[name](...)
	end
end

function public.toggle(name: string): boolean?
	local screen = private.getScreen(name)
	if not screen then
		return
	end
	screen.Visible = not screen.Visible
	return screen.Visible
end

function public.closeAll()
	for _, screen in screens do
		screen.Visible = false
	end
end

function public.open(name: string)
	local screen = private.getScreen(name)
	if screen then
		screen.Visible = true
	end
end

function public.close(name: string)
	local screen = private.getScreen(name)
	if screen then
		screen.Visible = false
	end
end

return public
