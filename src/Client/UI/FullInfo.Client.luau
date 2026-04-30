local Players = game:GetService("Players")

local player = Players.LocalPlayer
local PlayerScripts = player:FindFirstChild("PlayerScripts")

local ClientFolder = PlayerScripts:WaitForChild("Client")
local UIFolder = ClientFolder.UI

local UIManager = require(UIFolder["UIManager.Client"])

local public = {}

local frame
local itemText
local stats
local level
local passives
local type
local equipButton
local sellButton
local closeButton

function public.onStart(screenGui: ScreenGui)
	frame = screenGui:FindFirstChild("fullInfo")
	itemText = frame:FindFirstChild("itemName"):FindFirstChild("name")
	stats = frame:FindFirstChild("stats")
	level = frame:FindFirstChild("level")
	passives = frame:FindFirstChild("passives")
	type = frame:FindFirstChild("type")
	equipButton = frame:FindFirstChild("equip"):FindFirstChild("equipButton")
	sellButton = frame:FindFirstChild("sell"):FindFirstChild("sellButton")
	closeButton = frame:FindFirstChild("close"):FindFirstChild("closeButton")

	UIManager.onEvent("showFullInfo", function(item)
		public.show(item)
	end)

	closeButton.MouseButton1Click:Connect(function()
		public.hide()
		UIManager.fire("inventorySlideBack")
	end)

	equipButton.MouseButton1Click:Connect(function() end)

	sellButton.MouseButton1Click:Connect(function() end)
end

function public.hide()
	UIManager.close("fullInfo")
end

function public.show(item)
	itemText.Text = item.name or "Unknown"
	type.Text = "Type: " .. (item.subCategory or "?")
	level.Text = "Lvl: " .. (item.level or 1)

	-- passives
	if not item.passives or #item.passives == 0 then
		passives.Visible = false
	else
		passives.Visible = true
		passives.Text = "Passives: " .. table.concat(item.passives, ", ")
	end

	UIManager.open("fullInfo")
end

return public
