local Players = game:GetService("Players")

local player = Players.LocalPlayer
local Inventory = require(script.Parent.Inventory)
local PlayerData = require(script.Parent.PlayerData)
local UIManager = require(script.Parent.UIManager)

local menu
local slider
local buttons
local inventoryButton
local profileButton
local questButton
local storeButton

local playerInfo
local rankExpBar
local rankExpProgressBar
local profileBackGround
local level
local playerName

local settingsButton

local menuButton

local private = {}
local public = {}

function public.onStart(screenGui: ScreenGui)
	menu = screenGui:FindFirstChild("menu")
	slider = menu:FindFirstChild("slider")
	buttons = slider:FindFirstChild("buttons")
	inventoryButton = buttons:FindFirstChild("inventory"):FindFirstChild("button")
	profileButton = buttons:FindFirstChild("profile"):FindFirstChild("button")
	questButton = buttons:FindFirstChild("quest"):FindFirstChild("button")
	storeButton = buttons:FindFirstChild("inventory"):FindFirstChild("button")
	playerInfo = slider:FindFirstChild("player_info")
	rankExpBar = playerInfo:FindFirstChild("rank_exp_bar")
	rankExpProgressBar = playerInfo:FindFirstChild("rank_exp_progress_bar")
	profileBackGround = playerInfo:FindFirstChild("profile_background")
	playerName = playerInfo:FindFirstChild("player_name")
	level = playerInfo:FindFirstChild("level")
	settingsButton = slider:FindFirstChild("settings"):FindFirstChild("button")
	menuButton = menu:FindFirstChild("menu_button")

	private.buttonConnections()
	PlayerData.onChange(private.updatePlayerInfo)

	local data = PlayerData.getPlayerData()
	if data then
		private.updatePlayerInfo(data)
	end

	playerName.Text = player.DisplayName
end

function private.buttonConnections()
	menuButton.MouseButton1Click:Connect(function()
		private.sliderToggle()
	end)

	inventoryButton.MouseButton1Click:Connect(function()
		local isOpen = UIManager.toggle("inventory")
		if isOpen then
			UIManager.closeAll()
			UIManager.openExclusive("inventory")
			PlayerData.onChange(Inventory.updateSlots)
			local data = PlayerData.getPlayerData()
			if data then
				Inventory.updateSlots(data)
			end
		else
			UIManager.fire("inventoryClosed")
			Inventory.clearSlots()
		end
	end)

	profileButton.MouseButton1Click:Connect(function() end)
	questButton.MouseButton1Click:Connect(function() end)
	storeButton.MouseButton1Click:Connect(function() end)
end

function private.updatePlayerInfo(data)
	-- update rank level
	-- update profile image
end

function private.sliderToggle()
	if slider.Visible then
		slider.Visible = false
		menuButton.ImageColor3 = Color3.fromHex("2c2624")
	else
		slider.Visible = true
		menuButton.ImageColor3 = Color3.fromHex("dcc9a9")
	end
end

return public
