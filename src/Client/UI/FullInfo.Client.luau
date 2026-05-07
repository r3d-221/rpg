local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local PlayerScripts = player:FindFirstChild("PlayerScripts")

local ClientFolder = PlayerScripts:WaitForChild("Client")
local UIFolder = ClientFolder.UI

local Shared = ReplicatedStorage.Shared
local Remotes = Shared.Remotes
local equipItem = Remotes.equipItem
local unequipItem = Remotes.unequipItem

local ItemRegistry = require(Shared.Items.ItemRegistry)
local UIManager = require(UIFolder["UIManager.Client"])
local PlayerData = require(UIFolder["PlayerData.Client"])

local public = {}

local currentItem = nil
local frame
local itemName
local itemText
local stats
local level
local passives
local type
local equipButton
local sellButton
local unequipButton
local closeButton
local description
local equip
local sell
local unequip
local sellOriginalSize
local stat1
local stat2
local stat3
local stat4
local stat5

function public.onStart(screenGui: ScreenGui)
	frame = screenGui:FindFirstChild("fullInfo")
	itemName = frame:FindFirstChild("itemName")
	itemText = itemName:FindFirstChild("name")
	stats = frame:FindFirstChild("stats")
	level = frame:FindFirstChild("level")
	passives = frame:FindFirstChild("passives")
	type = frame:FindFirstChild("type")
	equip = frame:FindFirstChild("equip")
	unequip = frame:FindFirstChild("unequip")
	sell = frame:FindFirstChild("sell")
	equipButton = equip:FindFirstChild("equipButton")
	unequipButton = unequip:FindFirstChild("unequipButton")
	sellButton = sell:FindFirstChild("sellButton")
	closeButton = frame:FindFirstChild("close"):FindFirstChild("closeButton")
	description = frame:FindFirstChild("description")
	sellOriginalSize = sell.Size
	stat1 = stats:FindFirstChild("stat1")
	stat2 = stats:FindFirstChild("stat2")
	stat3 = stats:FindFirstChild("stat3")
	stat4 = stats:FindFirstChild("stat4")
	stat5 = stats:FindFirstChild("stat5")

	UIManager.onEvent("showFullInfo", function(id)
		public.show(id)
	end)

	closeButton.MouseButton1Click:Connect(function()
		public.hide()
		UIManager.fire("inventorySlideBack")
	end)

	equipButton.MouseButton1Click:Connect(function()
		if not currentItem then
			return
		end
		equipItem:FireServer(currentItem.id, currentItem.category)
	end)

	unequipButton.MouseButton1Click:Connect(function()
		if not currentItem then
			return
		end
		unequipItem:FireServer()
	end)

	sellButton.MouseButton1Click:Connect(function() end)

	PlayerData.onChange(function(data)
		if not currentItem then
			return
		end

		if not frame.Visible then
			return
		end

		local isEquipped = false
		if data and data.equipped then
			for _, equippedId in data.equipped do
				if equippedId == currentItem.id then
					isEquipped = true
					break
				end
			end
		end

		equip.Visible = not isEquipped
		unequip.Visible = isEquipped
	end)
end

function public.hide()
	UIManager.close("fullInfo")
end

function public.show(item)
	if not frame or not item then
		return
	end

	local defaultItemData = ItemRegistry.get(item.id)

	currentItem = item

	itemText.Text = defaultItemData.name or item.id
	type.Text = "Type: " .. (defaultItemData.class or defaultItemData.subCategory or "?")
	itemName.BackgroundColor3 = ItemRegistry.rarity[defaultItemData.rarity] or ItemRegistry.rarity.common

	local data = PlayerData.getPlayerData()
	local isEquipped = false
	if data and data.equipped then
		for _, equippedId in data.equipped do
			if equippedId == item.id then
				isEquipped = true
				break
			end
		end
	end

	equip.Visible = not isEquipped
	unequip.Visible = isEquipped

	if defaultItemData.category == "materials" then
		level.Text = "Qty: " .. (item.quantity or 1)
		passives.Visible = false
		stats.Visible = false
		description.Visible = true
		description.Text = defaultItemData.description or "This is a description of the selected item..."

		sell.Size = UDim2.new(
			sellOriginalSize.X.Scale + 0.45,
			sellOriginalSize.X.Offset,
			sellOriginalSize.Y.Scale,
			sellOriginalSize.Y.Offset
		)
	else
		stats.Visible = true
		stat4.Visible = false
		stat5.Visible = false

		sell.Size = sellOriginalSize
		description.Visible = false
		level.Text = "Lvl: " .. (item.level or 1)

		-- passives
		if not defaultItemData.passives or #defaultItemData.passives == 0 then
			passives.Visible = false
		else
			passives.Visible = true
			passives.Text = "Passives: " .. table.concat(defaultItemData.passives, ", ")
		end

		if defaultItemData.category == "weapons" then
			local itemStats = item.stats or {}
			local itemRolls = item.rolls or {}

			stat4.Visible = true
			stat5.Visible = true

			stat1:FindFirstChild("rank").Text = "[" .. (itemRolls[1] or "D") .. "]"
			stat2:FindFirstChild("rank").Text = "[" .. (itemRolls[2] or "D") .. "]"
			stat3:FindFirstChild("rank").Text = "[" .. (itemRolls[3] or "D") .. "]"
			stat4:FindFirstChild("rank").Text = "[" .. (itemRolls[4] or "D") .. "]"
			stat5:FindFirstChild("rank").Text = "[" .. (itemRolls[5] or "D") .. "]"

			stat1:FindFirstChild("statInfo").Text = "Damage: " .. math.floor(itemStats.damage or 0)
			stat2:FindFirstChild("statInfo").Text = "Crit Rate: "
				.. string.format("%.1f", (itemStats.critRate or 0) * 100)
				.. "%"
			stat3:FindFirstChild("statInfo").Text = "Crit Damage: "
				.. string.format("%.1f", (itemStats.critDamage or 1) * 100)
				.. "%"
			stat4:FindFirstChild("statInfo").Text = "Attack Speed: "
				.. string.format("%.1f", (itemStats.attackSpeed or 1) * 100)
				.. "%"
			stat5:FindFirstChild("statInfo").Text = "Armor Pierce: " .. math.floor(itemStats.armorPenetration or 0)
		end

		if defaultItemData.category == "armors" then
			local itemStats = item.stats or {}
			local itemRolls = item.rolls or {}

			stat5.Visible = false

			stat1:FindFirstChild("rank").Text = "[" .. (itemRolls[1] or "D") .. "]"
			stat2:FindFirstChild("rank").Text = "[" .. (itemRolls[2] or "D") .. "]"
			stat3:FindFirstChild("rank").Text = "[" .. (itemRolls[3] or "D") .. "]"

			stat1:FindFirstChild("statInfo").Text = "Health: " .. math.floor(itemStats.health or 0)
			stat2:FindFirstChild("statInfo").Text = "Armor: " .. math.floor(itemStats.armor or 0)
			stat3:FindFirstChild("statInfo").Text = "luck: " .. math.floor(itemStats.luck or 0)

			if itemStats.walkspeed and itemStats.walkspeed > 1 then
				stat4.Visible = true
				stat4:FindFirstChild("rank").Text = "[" .. (itemRolls[4] or "D") .. "]"
				stat4:FindFirstChild("statInfo").Text = "Walkspeed: +" .. string.format("%.1f", itemStats.walkspeed - 1)
			else
				stat4.Visible = false
			end
		end
	end

	UIManager.open("fullInfo")
end

return public
