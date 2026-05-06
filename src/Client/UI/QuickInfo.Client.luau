local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Modules = ReplicatedStorage.Shared.Modules

local ItemRegistry = require(ReplicatedStorage.Shared.Items.ItemRegistry)
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
local stat1
local stat2
local stat3

function public.onStart(screenGui: ScreenGui)
	frame = screenGui:FindFirstChild("quickInfo")
	itemName = frame:FindFirstChild("itemName")
	itemText = itemName:FindFirstChild("name")
	stats = frame:FindFirstChild("stats")
	level = frame:FindFirstChild("level")
	type = frame:FindFirstChild("type")
	description = frame:FindFirstChild("description")
	stat1 = stats:FindFirstChild("stat1")
	stat2 = stats:FindFirstChild("stat2")
	stat3 = stats:FindFirstChild("stat3")
end

function public.show(id)
	if not frame or not id then
		return
	end

	local item = ItemRegistry.get(id)
	print(item)
	if not item or not item.category then
		return
	end

	local info = ItemData[item] or {}
	itemText.Text = info.name or item.id
	type.Text = "Type: " .. (info.subCategory or "?")
	itemName.BackgroundColor3 = ItemData.rarity[item.rarity] or ItemData.rarity.common

	if info.category == "materials" then
		level.Text = "Qty: " .. (item.quantity or 1)
		stats.Visible = false
		description.Visible = true
		description.Text = info.description or "This is a description of the selected item..."
	else
		stats.Visible = true
		description.Visible = false
		level.Text = "Lvl: " .. (item.level or 1)

		-- set stats
		if item.category == "weapons" then
			local itemStats = item.stats or {}
			local itemRolls = item.rolls or {}

			stat1:FindFirstChild("rank").Text = "[" .. (itemRolls[1] or "D") .. "]"
			stat2:FindFirstChild("rank").Text = "[" .. (itemRolls[2] or "D") .. "]"
			stat3:FindFirstChild("rank").Text = "[" .. (itemRolls[3] or "D") .. "]"

			stat1:FindFirstChild("statInfo").Text = "Damage: " .. math.floor(itemStats.damage or 0)
			stat2:FindFirstChild("statInfo").Text = "Crit Rate: "
				.. string.format("%.1f", (itemStats.critRate or 0) * 100)
				.. "%"
			stat3:FindFirstChild("statInfo").Text = "Crit Damage: "
				.. string.format("%.1f", (itemStats.critDamage or 1) * 100)
				.. "%"
		end

		if item.category == "armors" then
			local itemStats = item.stats or {}
			local itemRolls = item.rolls or {}

			stat1:FindFirstChild("rank").Text = "[" .. (itemRolls[1] or "D") .. "]"
			stat2:FindFirstChild("rank").Text = "[" .. (itemRolls[2] or "D") .. "]"
			stat3:FindFirstChild("rank").Text = "[" .. (itemRolls[3] or "D") .. "]"

			stat1:FindFirstChild("statInfo").Text = "Health: " .. math.floor(itemStats.health or 0)
			stat2:FindFirstChild("statInfo").Text = "Armor: " .. math.floor(itemStats.armor or 0)
			stat3:FindFirstChild("statInfo").Text = "luck: " .. math.floor(itemStats.luck or 0)
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
