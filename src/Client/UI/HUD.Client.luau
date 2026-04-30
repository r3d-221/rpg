local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local PlayerScripts = player:FindFirstChild("PlayerScripts")
local PlayerGui = player:WaitForChild("PlayerGui")

local HUD = PlayerGui:WaitForChild("HUD")
local screens = HUD:FindFirstChild("screens")

local playerBars = HUD:FindFirstChild("playerBars")
local healthBar = playerBars:FindFirstChild("healthBar")
local currentHealthBar = healthBar:FindFirstChild("currentHealthBar")
local healthText = healthBar:FindFirstChild("health")

local ClientFolder = PlayerScripts:WaitForChild("Client")
local UIFolder = ClientFolder.UI

local UIManager = require(UIFolder["UIManager.Client"])

local inventoryButton = screens:FindFirstChild("inventory"):FindFirstChild("inventoryIcon")
local profileButton = screens:FindFirstChild("profile"):FindFirstChild("profileIcon")
local questButton = screens:FindFirstChild("quest"):FindFirstChild("questIcon")
local settingsButton = screens:FindFirstChild("store"):FindFirstChild("settingsIcon")
local storeButton = screens:FindFirstChild("settings"):FindFirstChild("storeIcon")

local private = {}
local public = {}

function public.onStart()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)

	private.updateHealth(humanoid.Health)
	humanoid.HealthChanged:Connect(private.updateHealth)

	player.CharacterAdded:Connect(function(newCharacter)
		character = newCharacter
		humanoid = newCharacter:WaitForChild("Humanoid")
		private.updateHealth(humanoid.Health)
		humanoid.HealthChanged:Connect(private.updateHealth)
	end)

	inventoryButton.MouseButton1Click:Connect(function()
		local isOpen = UIManager.toggle("inventory")
		if not isOpen then
			UIManager.fire("inventoryClosed")
		end
	end)

	-- profileButton.MouseButton1Click:Connect(function()
	-- 	UIManager.toggle("profile")
	-- end)

	-- questButton.MouseButton1Click:Connect(function()
	-- 	UIManager.toggle("quest")
	-- end)

	-- storeButton.MouseButton1Click:Connect(function()
	-- 	UIManager.toggle("store")
	-- end)

	-- settingsButton.MouseButton1Click:Connect(function()
	-- 	UIManager.toggle("settings")
	-- end)
end

function private.updateHealth(newHealth: number)
	local ratio = newHealth / humanoid.MaxHealth
	currentHealthBar.Size = UDim2.fromScale(ratio, 1)
	healthText.Text = math.floor(newHealth) .. " / " .. humanoid.MaxHealth
end

return public
