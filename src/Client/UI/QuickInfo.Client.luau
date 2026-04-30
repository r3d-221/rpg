local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Modules = ReplicatedStorage.Shared.Modules

local ItemData = require(Modules.ItemData)

local public = {}

local moveConnection
local frame
local itemName
local itemText
local stats
local level
local type
local description

function public.onStart(screenGui: ScreenGui)
	frame = screenGui:FindFirstChild("quickInfo")
	itemName = frame:FindFirstChild("itemName")
	itemText = itemName:FindFirstChild("name")
	stats = frame:FindFirstChild("stats")
	level = frame:FindFirstChild("level")
	type = frame:FindFirstChild("type")
	description = frame:FindFirstChild("description")
end

function public.show(item, slot)
	local info = ItemData[item.id] or {}

	itemText.Text = info.name or item.id
	type.Text = "Type: " .. (info.subCategory or "?")
	itemName.BackgroundColor3 = ItemData.rarity[item.rarity] or ItemData.rarity.common

	if info.subCategory == "Material" then
		level.Text = "Qty: " .. (item.quantity or 1)
		stats.Visible = false
		description.Visible = true
		description.Text = info.description or "This is a description of the selected item..."
	else
		stats.Visible = true
		description.Visible = false
		level.Text = "Lvl: " .. (item.level or 1)

		-- set stats
		for _, stat in stats:GetChildren() do
			if stat:IsA("Frame") then
				local rank = stat:FindFirstChild("rank") -- show the quality from D to S rank
				local statInfo = stat:FindFirstChild("statInfo")
				-- get serialized info of the stats in player inventory
			end
		end
	end

	frame.Visible = true

	moveConnection = UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			frame.Position = UDim2.fromOffset(input.Position.X + 12, input.Position.Y + 64)
		end
	end)
end

function public.hide()
	frame.Visible = false
	if moveConnection then
		moveConnection:Disconnect()
		moveConnection = nil
	end
end

return public
