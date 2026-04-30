local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local PlayerScripts = player:FindFirstChild("PlayerScripts")

local ClientFolder = PlayerScripts:WaitForChild("Client")
local UIFolder = ClientFolder.UI
local Modules = ReplicatedStorage.Shared.Modules

local ItemData = require(Modules.ItemData)
local UIManager = require(UIFolder["UIManager.Client"])

local public = {}

local frame
local itemName
local itemText
local stats
local level
local passives
local type
local equipButton
local sellButton
local closeButton
local description
local equip
local sell
local sellOriginalSize

function public.onStart(screenGui: ScreenGui)
	frame = screenGui:FindFirstChild("fullInfo")
	itemName = frame:FindFirstChild("itemName")
	itemText = itemName:FindFirstChild("name")
	stats = frame:FindFirstChild("stats")
	level = frame:FindFirstChild("level")
	passives = frame:FindFirstChild("passives")
	type = frame:FindFirstChild("type")
	equip = frame:FindFirstChild("equip")
	sell = frame:FindFirstChild("sell")
	equipButton = equip:FindFirstChild("equipButton")
	sellButton = sell:FindFirstChild("sellButton")
	closeButton = frame:FindFirstChild("close"):FindFirstChild("closeButton")
	description = frame:FindFirstChild("description")
	sellOriginalSize = sell.Size

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
	local info = ItemData[item.id] or {}

	itemText.Text = info.name or item.id
	type.Text = "Type: " .. (info.subCategory or "?")
	itemName.BackgroundColor3 = ItemData.rarity[item.rarity] or ItemData.rarity.common

	if info.subCategory == "Material" then
		level.Text = "Qty: " .. (item.quantity or 1)
		passives.Visible = false
		stats.Visible = false
		description.Visible = true
		description.Text = info.description or "This is a description of the selected item..."
		equip.Visible = false
		sell.Size = UDim2.new(
			sellOriginalSize.X.Scale + 0.45,
			sellOriginalSize.X.Offset,
			sellOriginalSize.Y.Scale,
			sellOriginalSize.Y.Offset
		)
	else
		stats.Visible = true
		equip.Visible = true
		sell.Size = sellOriginalSize
		description.Visible = false
		level.Text = "Lvl: " .. (item.level or 1)

		-- passives
		if not item.passives or #item.passives == 0 then
			passives.Visible = false
		else
			passives.Visible = true
			passives.Text = "Passives: " .. table.concat(item.passives, ", ")
		end
	end

	UIManager.open("fullInfo")
end

return public
