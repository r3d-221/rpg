local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local PlayerScripts = player:FindFirstChild("PlayerScripts")
local PlayerGui = player:WaitForChild("PlayerGui")

local HUD = PlayerGui:WaitForChild("HUD")
local screens = HUD:FindFirstChild("screens")

local playerBars = HUD:FindFirstChild("playerBars")
local currency = HUD:FindFirstChild("currency")
local coinText = currency:FindFirstChild("coin")
local gemText = currency:FindFirstChild("gem")

local levelIcon = playerBars:FindFirstChild("levelIcon")
local levelText = levelIcon:FindFirstChild("level")

local expBar = playerBars:FindFirstChild("expBar")
local currentExpBar = expBar:FindFirstChild("currentExpBar")

local staminaBar = playerBars:FindFirstChild("staminaBar")
local currentStaminaBar = staminaBar:FindFirstChild("currentStaminaBar")

local healthBar = playerBars:FindFirstChild("healthBar")
local currentHealthBar = healthBar:FindFirstChild("currentHealthBar")
local healthText = healthBar:FindFirstChild("health")

local ClientFolder = PlayerScripts:WaitForChild("Client")
local UIFolder = ClientFolder.UI

local PlayerConfig = require(ReplicatedStorage.Shared.Modules.PlayerConfig)
local UIManager = require(UIFolder["UIManager.Client"])
local PlayerData = require(UIFolder["PlayerData.Client"])

local inventoryButton = screens:FindFirstChild("inventory"):FindFirstChild("inventoryIcon")
local profileButton = screens:FindFirstChild("profile"):FindFirstChild("profileIcon")
-- local questButton = screens:FindFirstChild("quest"):FindFirstChild("questIcon")
-- local settingsButton = screens:FindFirstChild("settings"):FindFirstChild("settingsIcon")
-- local storeButton = screens:FindFirstChild("store"):FindFirstChild("storeIcon")

local private = {}
local public = {}

function public.onStart()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
	private.setButtons()

	private.updateHealth(humanoid.Health)
	humanoid.HealthChanged:Connect(private.updateHealth)

	player.CharacterAdded:Connect(function(newCharacter)
		character = newCharacter
		humanoid = newCharacter:WaitForChild("Humanoid")
		private.updateHealth(humanoid.Health)
		humanoid.HealthChanged:Connect(private.updateHealth)
	end)

	PlayerData.onChange(function(data)
		private.updateExp(data)
		private.updateStamina(data)
		levelText.Text = tostring(data.level)
		private.updateCurrency(data)
	end)
end

function private.setButtons()
	inventoryButton.MouseButton1Click:Connect(function()
		local isOpen = UIManager.toggle("inventory")
		if not isOpen then
			UIManager.fire("inventoryClosed")
		end
	end)

	profileButton.MouseButton1Click:Connect(function()
		local isOpen = UIManager.toggle("profile")
		if not isOpen then
			UIManager.fire("profileClosed")
		end
	end)

	-- questButton.MouseButton1Click:Connect(function()
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

function private.updateStamina(data)
	local max = data.stamina or 100
	local current = data.currentStamina or max
	local ratio = current / max
	currentStaminaBar.Size = UDim2.fromScale(math.clamp(ratio, 0, 1), 1)
end

function private.updateExp(data)
	local required = PlayerConfig.expToLevel(data.level)
	local ratio = data.currency.exp / required
	currentExpBar.Size = UDim2.fromScale(math.clamp(ratio, 0, 1), 1)
end

function private.updateCurrency(data)
	coinText.Text = PlayerConfig.formatNumber(data.currency.coins)
	gemText.Text = PlayerConfig.formatNumber(data.currency.gems)
end

return public
