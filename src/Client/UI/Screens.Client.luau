local Players = game:GetService("Players")

local player = Players.LocalPlayer
local PlayerScripts = player:FindFirstChild("PlayerScripts")
local PlayerGui = player:WaitForChild("PlayerGui")

local HUD = PlayerGui:WaitForChild("HUD")
local screens = HUD:FindFirstChild("screens")

local ClientFolder = PlayerScripts:WaitForChild("Client")
local UIFolder = ClientFolder.UI

local UIManager = require(UIFolder["UIManager.Client"])

local inventoryButton = screens:FindFirstChild("inventory"):FindFirstChild("inventoryIcon")
local profileButton = screens:FindFirstChild("profile"):FindFirstChild("profileIcon")
local questButton = screens:FindFirstChild("quest"):FindFirstChild("questIcon")
local settingsButton = screens:FindFirstChild("store"):FindFirstChild("settingsIcon")
local storeButton = screens:FindFirstChild("settings"):FindFirstChild("storeIcon")

local public = {}

function public.init()
	inventoryButton.MouseButton1Click:Connect(function()
		UIManager.toggle("inventory")
	end)

	profileButton.MouseButton1Click:Connect(function()
		UIManager.toggle("profile")
	end)

	questButton.MouseButton1Click:Connect(function()
		UIManager.toggle("quest")
	end)

	storeButton.MouseButton1Click:Connect(function()
		UIManager.toggle("store")
	end)

	settingsButton.MouseButton1Click:Connect(function()
		UIManager.toggle("settings")
	end)
end

return public
