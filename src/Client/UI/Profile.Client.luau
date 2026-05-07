local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local PlayerScripts = player:FindFirstChild("PlayerScripts")
local ClientFolder = PlayerScripts:WaitForChild("Client")
local UIFolder = ClientFolder.UI

local Modules = ReplicatedStorage.Shared.Modules
local ItemRegistry = require(ReplicatedStorage.Shared.Items.ItemRegistry)
local PlayerConfig = require(Modules.PlayerConfig)
local PlayerIconCache = require(Modules.PlayerIconCache)
local PlayerData = require(UIFolder["PlayerData.Client"])
local UIManager = require(UIFolder["UIManager.Client"])
local QuickInfo = require(UIFolder["QuickInfo.Client"])

local Remotes = ReplicatedStorage.Shared.Remotes
local spendStatPoint: RemoteEvent = Remotes.spendStatPoint
local resetStatPoints: RemoteEvent = Remotes.resetStatPoints

local STAT_POINTS_SLIDER = 0.1

-- Add attackRange here once it exists in player stats
-- stats
local STATS_MAP: { { uiKey: string, dataKey: string } } = {
	{ uiKey = "health", dataKey = "health" },
	{ uiKey = "armor", dataKey = "armor" },
	{ uiKey = "luck", dataKey = "luck" },
	{ uiKey = "damage", dataKey = "damage" },
	{ uiKey = "critRate", dataKey = "critRate" },
	{ uiKey = "critDamage", dataKey = "critDamage" },
	{ uiKey = "walkspeed", dataKey = "walkspeed" },
	{ uiKey = "attackSpeed", dataKey = "attackSpeed" },
	{ uiKey = "armorPierce", dataKey = "armorPenetration" },
}

-- Stat points
local ASSIGNABLE_STATS = { "health", "armor", "damage", "critRate", "critDamage" }

local private = {}
local public = {}

local frame
local closeButton

-- equipment panel
local equipmentSlots
local equipmentSlotsCloseButton
local equipmentButton
local equipmentSlotsList
local equipmentSlotFrames = {}
local equipmentSlotFrameImages = {}

-- stat points panel
local statPointsAmountFrame
local statPointsAmountOriginalPosition
local statPointsButtons
local resetButton
local pointsText
local buttonsVisible = false

-- stats panel
local statsAmountFrame

-- profile header
local profileImage
local levelText
local currentExpBar
local expText
local playerNameText

local equipmentSlotsColor = Color3.fromHex("#2c2624")

function public.onStart(screenGui: ScreenGui)
	frame = screenGui:FindFirstChild("profile")
	closeButton = frame:FindFirstChild("close"):FindFirstChild("closeButton")

	equipmentSlots = frame:FindFirstChild("equipmentSlots")
	equipmentSlotsCloseButton = equipmentSlots:FindFirstChild("close"):FindFirstChild("closeButton")
	equipmentButton = frame:FindFirstChild("equipment"):FindFirstChild("equipmentButton")
	equipmentSlotsList = equipmentSlots:FindFirstChild("equipmentSlotsList")
	equipmentSlots.Visible = false

	local slotNames = { "weapon", "helmet", "chestplate", "leggings", "boots" }
	for _, slotName in slotNames do
		local slotFrame = equipmentSlotsList:FindFirstChild(slotName)
		equipmentSlotFrames[slotName] = slotFrame
		if not slotFrame then
			continue
		end

		local slotImage = slotFrame:FindFirstChildOfClass("ImageButton")
		equipmentSlotFrameImages[slotName] = slotImage
		if not slotImage then
			continue
		end

		slotImage.MouseEnter:Connect(function()
			local data = PlayerData.getPlayerData()
			if not data then
				return
			end
			local item = data.equipped and data.equipped[slotName]
			if not item then
				return
			end

			QuickInfo.show(item)
		end)

		slotImage.MouseLeave:Connect(function()
			QuickInfo.hide()
		end)

		slotImage.MouseButton1Click:Connect(function()
			QuickInfo.hide()
			local data = PlayerData.getPlayerData()
			if not data then
				return
			end
			local item = data.equipped and data.equipped[slotName]
			if not item then
				return
			end

			UIManager.closeAll()
			UIManager.open("inventory")
			UIManager.fire("inventorySlide")
			UIManager.fire("showFullInfo", item)
		end)
	end

	local statPointsFrame = frame:FindFirstChild("statPoints")
	statPointsAmountFrame = statPointsFrame:FindFirstChild("amount")
	statPointsAmountOriginalPosition = statPointsAmountFrame.Position
	statPointsButtons = statPointsFrame:FindFirstChild("buttons")
	statPointsButtons.Visible = false
	resetButton = statPointsFrame:FindFirstChild("reset"):FindFirstChild("resetButton")
	pointsText = statPointsFrame:FindFirstChild("points")

	statsAmountFrame = frame:FindFirstChild("stats"):FindFirstChild("amount")

	profileImage = frame:FindFirstChild("profileIcon"):FindFirstChild("profileImage")
	levelText = frame:FindFirstChild("level")
	playerNameText = frame:FindFirstChild("playerName")

	local expBar = frame:FindFirstChild("expBar")
	currentExpBar = expBar:FindFirstChild("currentExpBar")
	expText = expBar:FindFirstChild("exp")

	PlayerIconCache.get(player.UserId, function(imageId)
		if profileImage then
			profileImage.Image = imageId
		end
	end)

	private.setupButtons()

	PlayerData.onChange(private.updateAll)

	local data = PlayerData.getPlayerData()
	if data then
		private.updateAll(data)
	end
end

-- formats the percentages
local function formatStat(key: string, value: number): string
	if key == "critRate" then
		return string.format("%.1f%%", value * 100)
	elseif key == "critDamage" then
		return string.format("%.0f%%", value * 100)
	else
		return tostring(math.floor(value))
	end
end

function private.updateHeader(data)
	levelText.Text = "lvl: " .. tostring(data.level)
	playerNameText.Text = player.DisplayName

	local required = PlayerConfig.expToLevel(data.level)
	local ratio = math.clamp((data.currency.exp or 0) / required, 0, 1)
	currentExpBar.Size = UDim2.fromScale(ratio, 1)
	expText.Text = math.floor(data.currency.exp or 0) .. " / " .. required
end

function private.updateStats(data)
	local stats = data.stats or {}
	for _, entry in STATS_MAP do
		local label = statsAmountFrame:FindFirstChild(entry.uiKey)
		if label and stats[entry.dataKey] ~= nil then
			label.Text = formatStat(entry.dataKey, stats[entry.dataKey])
		end
	end
end

function private.updateStatPoints(data)
	local assignable = data.assignableStatPoints or 0
	pointsText.Text = "Points: " .. tostring(assignable)

	local shouldShow = assignable > 0

	if shouldShow and not buttonsVisible then
		statPointsAmountFrame.Position = UDim2.new(
			statPointsAmountOriginalPosition.X.Scale - STAT_POINTS_SLIDER,
			statPointsAmountOriginalPosition.X.Offset,
			statPointsAmountOriginalPosition.Y.Scale,
			statPointsAmountOriginalPosition.Y.Offset
		)
	elseif not shouldShow and buttonsVisible then
		statPointsAmountFrame.Position = statPointsAmountOriginalPosition
	end

	statPointsButtons.Visible = shouldShow
	buttonsVisible = shouldShow

	-- updates stat points
	local statPointsData = data.statPoints or {}
	for _, stat in ASSIGNABLE_STATS do
		local label = statPointsAmountFrame:FindFirstChild(stat)
		if label then
			label.Text = tostring(statPointsData[stat] or 0)
		end
	end
end

function private.updateEquipmentSlots(data)
	local equipped = data.equipped or {}

	for slotName, slotFrame in equipmentSlotFrames do
		if not slotFrame then
			continue
		end

		local itemId = equipped[slotName]
		if itemId then
			local rarity = "common"
			for _, category in data.inventory do
				for _, entry in category do
					if entry.id == itemId then
						rarity = entry.rarity or "common"
						break
					end
				end
			end
			slotFrame.BackgroundColor3 = ItemRegistry.rarity[rarity]
		else
			slotFrame.BackgroundColor3 = equipmentSlotsColor
		end
	end
end

function private.updateAll(data)
	private.updateHeader(data)
	private.updateStats(data)
	private.updateStatPoints(data)
	private.updateEquipmentSlots(data)
end

function private.setupButtons()
	closeButton.MouseButton1Click:Connect(function()
		UIManager.close("profile")
	end)

	equipmentButton.MouseButton1Click:Connect(function()
		equipmentSlots.Visible = not equipmentSlots.Visible
	end)

	equipmentSlotsCloseButton.MouseButton1Click:Connect(function()
		equipmentSlots.Visible = false
	end)

	-- buttons for stat points
	for _, stat in ASSIGNABLE_STATS do
		local button = statPointsButtons:FindFirstChild(stat)
		if not button then
			continue
		end

		button.MouseButton1Click:Connect(function()
			local data = PlayerData.getPlayerData()
			if not data or (data.assignableStatPoints or 0) <= 0 then
				return
			end
			spendStatPoint:FireServer(stat)
		end)
	end

	resetButton.MouseButton1Click:Connect(function()
		resetStatPoints:FireServer()
	end)
end

return public
