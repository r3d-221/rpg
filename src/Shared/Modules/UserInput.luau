local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Modules = ReplicatedStorage:FindFirstChild("Shared"):FindFirstChild("Modules")
local player = Players.LocalPlayer

local HitboxManager = require(Modules:FindFirstChild("HitboxManager"))

local private = {}
local public = {}

function public.onStart()
	ContextActionService:BindAction("primary", private.primary, true, Enum.UserInputType.MouseButton1)
end

function private.primary(actionName, inputState)
	if actionName == "primary" and inputState == Enum.UserInputState.Begin then
		print("Primary")
		HitboxManager.New()
	end
end

return public
