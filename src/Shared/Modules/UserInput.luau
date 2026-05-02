local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Modules = ReplicatedStorage.Shared.Modules
local Remotes = ReplicatedStorage.Shared.Remotes

local HitboxManager = require(Modules.HitboxManager)
local PlayerData = require(Players.LocalPlayer.PlayerScripts.Client.UI["PlayerData.Client"])

local useSprint = Remotes.useSprint

local player = Players.LocalPlayer

local walkspeed
local isSprinting = false

local private = {}
local public = {}

function public.onStart()
	ContextActionService:BindAction("primary", private.primary, true, Enum.UserInputType.MouseButton1)
	ContextActionService:BindAction("sprint", private.sprint, true, Enum.KeyCode.LeftShift)

	useSprint.OnClientEvent:Connect(function(sprintAllowed)
		if not sprintAllowed then
			private.stopSprint()
		end
	end)
end

function private.stopSprint()
	isSprinting = false
	local character = player.Character
	if not character then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = walkspeed
	end
end

function private.primary(actionName, inputState)
	if actionName == "primary" and inputState == Enum.UserInputState.Begin then
		HitboxManager.New()
	end
end

function private.sprint(actionName, inputState)
	if actionName ~= "sprint" then
		return
	end

	local character = player.Character
	if not character then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	local data = PlayerData.getPlayerData()
	if inputState == Enum.UserInputState.Begin then
		if not data or (data.currentStamina or data.stamina) < data.staminaCost then
			return
		end

		walkspeed = data.stats.walkspeed
		isSprinting = true
		humanoid.WalkSpeed = walkspeed * data.staminaSpeedMultiplier
		useSprint:FireServer(true)
	elseif inputState == Enum.UserInputState.End then
		isSprinting = false
		humanoid.WalkSpeed = walkspeed
		useSprint:FireServer(false)
	end
end

return public
