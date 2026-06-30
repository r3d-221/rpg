local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Inventory = require(script.Parent.Inventory)
local ItemRegistry = require(ReplicatedStorage.Shared.Items.ItemRegistry)
local PlayerConfig = require(ReplicatedStorage.Shared.Modules.PlayerConfig)
local PlayerData = require(script.Parent.PlayerData)
local Utils = require(script.Parent.Utils)

local Remotes = ReplicatedStorage.Shared.Remotes
local spendStatPoint = Remotes.spendStatPoint
local resetStatPoints = Remotes.resetStatPoints

local public = {}
local private = {}
local equipments = {
	weapon = "weapon_slot",
	helmet = "helmet_slot",
	chestplate = "chestplate_slot",
	leggings = "leggings_slot",
	boots = "boots_slot",
}

local initialized = false
local originalPosition = UDim2.fromScale(0.834, 0.5)

local profile

local info
local assignablePoints
local assignablePointsAmount
local resetStatPointsFrame
local resetStatPointsButton

local playerInfo
local classText
local rankText
local titleText

local Stats

local currentTab = "stats"

local statPoints

local tabs
local statsTab
local statsTabText
local statsTabButton
local infoTab
local infoTabText
local infoTabButton
local statPointTab
local statPointTabText
local statPointTabButton
local passivesTab
local passivesTabText
local passivesTabButton
local activesTab
local activesTabText
local activesTabButton
local statusTab
local statusTabText
local statusTabButton

local classLevel
local level
local classExpBar
local classExpProgressBar

local equipmentsList
local weaponSlotButton
local helmetSlotButton
local chestplateSlotButton
local leggingsSlotButton
local bootsSlotButton
local closeButton

function public.onStart(screenGui: ScreenGui)
	profile = screenGui:FindFirstChild("Profile")
	closeButton = profile:FindFirstChild("close"):FindFirstChild("button")
	equipmentsList = profile:FindFirstChild("equipments"):FindFirstChild("list")
	weaponSlotButton = equipmentsList:FindFirstChild("weapon_slot"):FindFirstChild("button")
	helmetSlotButton = equipmentsList:FindFirstChild("helmet_slot"):FindFirstChild("button")
	chestplateSlotButton = equipmentsList:FindFirstChild("chestplate_slot"):FindFirstChild("button")
	leggingsSlotButton = equipmentsList:FindFirstChild("leggings_slot"):FindFirstChild("button")
	bootsSlotButton = equipmentsList:FindFirstChild("boots_slot"):FindFirstChild("button")
	info = profile:FindFirstChild("info")
	assignablePoints = info:FindFirstChild("assignable_points")
	assignablePointsAmount = assignablePoints:FindFirstChild("amount")
	playerInfo = info:FindFirstChild("player_info")
	classText = playerInfo:FindFirstChild("class"):FindFirstChild("text")
	rankText = playerInfo:FindFirstChild("rank"):FindFirstChild("text")
	titleText = playerInfo:FindFirstChild("title"):FindFirstChild("text")
	Stats = info:FindFirstChild("stats")
	statPoints = info:FindFirstChild("stat_points")
	tabs = info:FindFirstChild("tabs")
	infoTab = tabs:FindFirstChild("info")
	infoTabText = infoTab:FindFirstChild("text")
	infoTabButton = infoTab:FindFirstChild("button")
	statsTab = tabs:FindFirstChild("stats")
	statsTabText = statsTab:FindFirstChild("text")
	statsTabButton = statsTab:FindFirstChild("button")
	statPointTab = tabs:FindFirstChild("stat_points")
	statPointTabText = statPointTab:FindFirstChild("text")
	statPointTabButton = statPointTab:FindFirstChild("button")
	passivesTab = tabs:FindFirstChild("passives")
	passivesTabText = passivesTab:FindFirstChild("text")
	passivesTabButton = passivesTab:FindFirstChild("button")
	activesTab = tabs:FindFirstChild("actives")
	activesTabText = activesTab:FindFirstChild("text")
	activesTabButton = activesTab:FindFirstChild("button")
	statusTab = tabs:FindFirstChild("status")
	statusTabText = statusTab:FindFirstChild("text")
	statusTabButton = statusTab:FindFirstChild("button")
	resetStatPointsFrame = info:FindFirstChild("reset_stat_points")
	resetStatPointsButton = resetStatPointsFrame:FindFirstChild("button")
	classLevel = profile:FindFirstChild("class_level")
	level = classLevel:FindFirstChild("level")
	classExpBar = classLevel:FindFirstChild("class_exp_bar")
	classExpProgressBar = classExpBar:FindFirstChild("class_exp_progress_bar")

	private.setupButtons()

	initialized = true

	PlayerData.onChange(function(data)
		if not profile.Visible then
			return
		end
		public.updateAll(data)
	end)
end

function public.updateAll(data)
	if not initialized then
		return
	end
	private.updateStats(data, data.class)
	private.updateStatPoints(data, data.class)
	private.updateClassLevel(data, data.class)
	private.updateEquipments(data)
	private.updatePlayerInfo(data)
end

function private.updatePlayerInfo(data)
	titleText.Text = data.title
	classText.Text = data.class
	rankText.Text = data.rank
end

function private.updateStatPoints(data, class)
	assignablePointsAmount.Text = data.classes[class].assignableStatPoints

	for stat, frame in Utils.statPoints do
		local statFrame = statPoints:FindFirstChild(frame)
		if not statFrame then
			warn("Frame not found for: " .. stat)
			continue
		end

		local text = statFrame:FindFirstChild("amount")
		if not text then
			warn("TextLabel not found for: " .. stat)
			continue
		end

		local addButton = statFrame:FindFirstChild("add_button")
		if not addButton then
			warn("Add button not found for: " .. stat)
			continue
		end

		text.Text = data.classes[class].statPoints[stat] or 0

		if data.classes[class].assignableStatPoints == 0 then
			text.Position = addButton.Position
			addButton.Visible = false
		else
			text.Position = originalPosition
			addButton.Visible = true
		end
	end
end

function private.updateEquipments(data)
	for name, frame in equipments do
		local slotFrame = equipmentsList:FindFirstChild(frame)
		if not slotFrame then
			warn("Frame not found for: " .. name)
			continue
		end

		local glow = slotFrame:FindFirstChild("glow")
		if not glow then
			warn("Frame not found for: " .. name)
			continue
		end

		glow.Visible = false
		local uid = data.equipped[name]
		if not uid then
			continue
		end

		glow.Visible = true
		local item = uid and Utils.findItemByUid(data.inventory, uid)
		local defaultInfo = ItemRegistry.get(item.id)
		glow.ImageColor3 = ItemRegistry.rarity[defaultInfo.rarity]
	end
end

function private.updateStats(data, class)
	for stat, frame in Utils.uiNames do
		local statFrame = Stats:FindFirstChild(frame)
		if not statFrame then
			warn("Frame not found for: " .. stat)
			continue
		end

		local text = statFrame:FindFirstChild("amount")
		if not text then
			warn("TextLabel not found for: " .. stat)
			continue
		end

		text.Text = Utils.format(stat, data.classes[class].stats[stat] or 0)
	end
end

function private.updateClassLevel(data, class)
	local max = PlayerConfig.expToClassLevel(data.classes[class].classExp)
	local ratio = math.clamp((data.currency.rankExp or 0) / max, 0, 1)
	classExpProgressBar.Size = UDim2.fromScale(ratio, 1)
	level.Text = "Class Lvl: " .. data.classes[class].classLevel
end

function private.setupButtons()
	closeButton.MouseButton1Click:Connect(function()
		profile.Visible = false
	end)

	for stat, frame in Utils.statPoints do
		local statFrame = statPoints:FindFirstChild(frame)
		if not statFrame then
			warn("Frame not found for: " .. stat)
			continue
		end

		local button = statFrame:FindFirstChild("add_button"):FindFirstChild("button")
		if not button then
			warn("Add button not found for: " .. stat)
			continue
		end

		button.MouseButton1Click:Connect(function()
			spendStatPoint:FireServer(stat)
		end)
	end

	resetStatPointsButton.MouseButton1Click:Connect(function()
		resetStatPoints:FireServer()
	end)

	weaponSlotButton.MouseButton1Click:Connect(function()
		local data = PlayerData.getPlayerData()
		Inventory.openSlot(data.equipped.weapon, data)
	end)

	infoTabButton.MouseButton1Click:Connect(function()
		private.clearInfo()
		private.resetTabColor()

		infoTab.BackgroundColor3 = Color3.fromHex("dcc9a9")
		infoTabText.TextColor3 = Color3.fromHex("2c2624")

		playerInfo.Visible = true

		currentTab = "info"
	end)

	statsTabButton.MouseButton1Click:Connect(function()
		private.clearInfo()
		private.resetTabColor()

		statsTab.BackgroundColor3 = Color3.fromHex("dcc9a9")
		statsTabText.TextColor3 = Color3.fromHex("2c2624")

		Stats.Visible = true

		currentTab = "stats"
	end)

	statPointTabButton.MouseButton1Click:Connect(function()
		private.clearInfo()
		private.resetTabColor()

		statPointTab.BackgroundColor3 = Color3.fromHex("dcc9a9")
		statPointTabText.TextColor3 = Color3.fromHex("2c2624")

		statPoints.Visible = true
		assignablePoints.Visible = true
		resetStatPointsFrame.Visible = true

		currentTab = "statPoints"
	end)

	passivesTabButton.MouseButton1Click:Connect(function()
		private.clearInfo()
		private.resetTabColor()

		passivesTab.BackgroundColor3 = Color3.fromHex("dcc9a9")
		passivesTabText.TextColor3 = Color3.fromHex("2c2624")

		currentTab = "passives"
	end)

	activesTabButton.MouseButton1Click:Connect(function()
		private.clearInfo()
		private.resetTabColor()

		activesTab.BackgroundColor3 = Color3.fromHex("dcc9a9")
		activesTabText.TextColor3 = Color3.fromHex("2c2624")

		currentTab = "actives"
	end)

	statusTabButton.MouseButton1Click:Connect(function()
		private.clearInfo()
		private.resetTabColor()

		statusTab.BackgroundColor3 = Color3.fromHex("dcc9a9")
		statusTabText.TextColor3 = Color3.fromHex("2c2624")

		currentTab = "status"
	end)
end

function private.clearInfo()
	for _, child in info:GetChildren() do
		if child:IsA("Frame") then
			child.Visible = false
		end
	end
end

function private.resetTabColor()
	for _, child in tabs:GetChildren() do
		if child:IsA("Frame") then
			child.BackgroundColor3 = Color3.fromHex("24201e")

			local label = child:FindFirstChildOfClass("TextLabel")
			if label then
				label.TextColor3 = Color3.fromHex("dcc9a9")
			end
		end
	end
end

return public
