local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UITemplates = ReplicatedStorage.UITemplates
local PlayerData = require(script.Parent.PlayerData)
local UIManager = require(script.Parent.UIManager)
local Utils = require(script.Parent.Utils)
local ItemRegistry = require(ReplicatedStorage.Shared.Items.ItemRegistry)

local Remotes = ReplicatedStorage.Shared.Remotes
local equipItem = Remotes.equipItem
local unequipItem = Remotes.unequipItem

local statTemplate = UITemplates.stat_template
local slotTemplate = UITemplates.slot_template

local private = {}
local public = {}

local infoPanels
local infoTabFrames

local currentInfoTab = "stats"
local category = "weapons"
local currentSlot = nil
local currentItem = nil

local inventory

local slots
local tabs
local weaponsTab
local weaponsTabText
local weaponsTabButton
local armorsTab
local armorsTabText
local armorsTabButton
local materialsTab
local materialsTabText
local materialsTabButton
local artifactsTab
local artifactsTabText
local artifactsTabButton
local miscTab
local miscTabText
local miscTabButton

local contents
local statsInfo
local tagsInfo
local passivesInfo
local descriptionInfo
local descriptionInfoText
local infoTabs
local statsTab
local statsTabText
local statsTabButton
local tagsTab
local tagsTabText
local tagsTabButton
local passivesTab
local passivesTabText
local passivesTabButton
local descriptionTab
local descriptionTabText
local descriptionTabButton
local title
local titleText
local glow
local amount

local slotAmount
local slotAmountText
local equipFrame
local sellFrame
local unequipFrame

local addButton
local closeButton
local filterButton
local equipButton
local sellButton
local unequipButton

function public.onStart(screenGui: ScreenGui)
	inventory = screenGui:FindFirstChild("Inventory")
	slots = inventory:FindFirstChild("slots")
	tabs = inventory:FindFirstChild("tabs")
	slotAmount = inventory:FindFirstChild("slot_amount")
	filterButton = inventory:FindFirstChild("filter"):FindFirstChild("button")
	closeButton = inventory:FindFirstChild("close"):FindFirstChild("button")
	contents = inventory:FindFirstChild("info"):FindFirstChild("contents")
	equipFrame = contents:FindFirstChild("equip")
	equipButton = equipFrame:FindFirstChild("button")
	sellFrame = contents:FindFirstChild("sell")
	sellButton = sellFrame:FindFirstChild("button")
	unequipFrame = contents:FindFirstChild("unequip")
	unequipButton = unequipFrame:FindFirstChild("button")
	statsInfo = contents:FindFirstChild("stats_info")
	tagsInfo = contents:FindFirstChild("tags_info")
	passivesInfo = contents:FindFirstChild("passives_info")
	descriptionInfo = contents:FindFirstChild("description_info")
	descriptionInfoText = descriptionInfo:FindFirstChild("text")
	glow = contents:FindFirstChild("glow")
	amount = contents:FindFirstChild("amount"):FindFirstChild("text")
	infoTabs = contents:FindFirstChild("tabs")
	title = contents:FindFirstChild("title")
	titleText = title:FindFirstChild("text")
	statsTab = infoTabs:FindFirstChild("stats")
	statsTabText = statsTab:FindFirstChild("text")
	statsTabButton = statsTab:FindFirstChild("button")
	tagsTab = infoTabs:FindFirstChild("tags")
	tagsTabText = tagsTab:FindFirstChild("text")
	tagsTabButton = tagsTab:FindFirstChild("button")
	passivesTab = infoTabs:FindFirstChild("passives")
	passivesTabText = passivesTab:FindFirstChild("text")
	passivesTabButton = passivesTab:FindFirstChild("button")
	descriptionTab = infoTabs:FindFirstChild("description")
	descriptionTabText = descriptionTab:FindFirstChild("text")
	descriptionTabButton = descriptionTab:FindFirstChild("button")
	weaponsTab = tabs:FindFirstChild("weapons")
	weaponsTabText = weaponsTab:FindFirstChild("text")
	weaponsTabButton = weaponsTab:FindFirstChild("button")
	materialsTab = tabs:FindFirstChild("materials")
	materialsTabText = materialsTab:FindFirstChild("text")
	materialsTabButton = materialsTab:FindFirstChild("button")
	artifactsTab = tabs:FindFirstChild("artifacts")
	artifactsTabText = artifactsTab:FindFirstChild("text")
	artifactsTabButton = artifactsTab:FindFirstChild("button")
	armorsTab = tabs:FindFirstChild("armors")
	armorsTabText = armorsTab:FindFirstChild("text")
	armorsTabButton = armorsTab:FindFirstChild("button")
	miscTab = tabs:FindFirstChild("misc")
	miscTabText = miscTab:FindFirstChild("text")
	miscTabButton = miscTab:FindFirstChild("button")
	slotAmountText = slotAmount:FindFirstChild("amount")
	addButton = slotAmount:FindFirstChild("add_button"):FindFirstChild("button")

	infoPanels = {
		stats = statsInfo,
		tags = tagsInfo,
		passives = passivesInfo,
		description = descriptionInfo,
	}

	infoTabFrames = {
		stats = { frame = statsTab, text = statsTabText },
		tags = { frame = tagsTab, text = tagsTabText },
		passives = { frame = passivesTab, text = passivesTabText },
		description = { frame = descriptionTab, text = descriptionTabText },
	}

	private.setupButtons()
	private.changeTabs()

	PlayerData.onChange(function(data)
		if not inventory.Visible then
			return
		end
		public.updateSlots(data)
	end)
end

---- SLOTS ----

function public.clearSlots()
	for _, slot in slots:GetChildren() do
		if slot:IsA("Frame") then
			slot:Destroy()
		end
	end

	currentSlot = nil
	currentItem = nil
	contents.Visible = false
end

function public.updateSlots(data)
	public.clearSlots()

	local list = data.inventory[category]
	if list then
		for _, item in list do
			private.createItemSlot(item)
		end
	end
	private.updateSlotAmount(data)
	private.toggleButtons(data)
	-- clear filters
	print(data)
end

function private.createItemSlot(item)
	local defaultInfo = ItemRegistry.get(item.id)
	local newSlot = slotTemplate:Clone()
	newSlot:SetAttribute("uid", item.uid)

	newSlot.Parent = slots
	newSlot.Name = item.id
	local newGlow = newSlot:FindFirstChild("glow")
	local button = newSlot:FindFirstChild("button")
	newGlow.ImageColor3 = ItemRegistry.rarity[defaultInfo.rarity]

	button.MouseButton1Click:Connect(function()
		if currentSlot == newSlot then
			currentSlot = nil
			currentItem = nil
			contents.Visible = false
		else
			currentSlot = newSlot
			currentItem = item
			private.updateInfo(item)
			contents.Visible = true
		end
	end)
end

function public.openSlot(targetUid, data)
	for _, slot in slots:GetChildren() do
		if slot:GetAttribute("uid") == targetUid then
			UIManager.closeAll()
			UIManager.openExclusive("Inventory")
			currentSlot = slot
			public.updateSlots(data)
		end
	end
end

---- MISC. ----

function private.search() end

function private.filterSlots() end

function private.changeTabs()
	weaponsTabButton.MouseButton1Click:Connect(function()
		category = "weapons"
		private.resetTabColor(tabs)
		weaponsTab.BackgroundColor3 = Color3.fromHex("dcc9a9")
		weaponsTabText.TextColor3 = Color3.fromHex("2c2624")
		local data = PlayerData.getPlayerData()
		if data then
			public.updateSlots(data)
		end
	end)

	materialsTabButton.MouseButton1Click:Connect(function()
		category = "materials"
		private.resetTabColor(tabs)
		materialsTab.BackgroundColor3 = Color3.fromHex("dcc9a9")
		materialsTabText.TextColor3 = Color3.fromHex("2c2624")
		local data = PlayerData.getPlayerData()
		if data then
			public.updateSlots(data)
		end
	end)

	artifactsTabButton.MouseButton1Click:Connect(function()
		category = "artifacts"
		private.resetTabColor(tabs)
		artifactsTab.BackgroundColor3 = Color3.fromHex("dcc9a9")
		artifactsTabText.TextColor3 = Color3.fromHex("2c2624")
		local data = PlayerData.getPlayerData()
		if data then
			public.updateSlots(data)
		end
	end)

	armorsTabButton.MouseButton1Click:Connect(function()
		category = "armors"
		private.resetTabColor(tabs)
		armorsTab.BackgroundColor3 = Color3.fromHex("dcc9a9")
		armorsTabText.TextColor3 = Color3.fromHex("2c2624")
		local data = PlayerData.getPlayerData()
		if data then
			public.updateSlots(data)
		end
	end)

	miscTabButton.MouseButton1Click:Connect(function()
		category = "misc"
		private.resetTabColor(tabs)
		miscTab.BackgroundColor3 = Color3.fromHex("dcc9a9")
		miscTabText.TextColor3 = Color3.fromHex("2c2624")
		local data = PlayerData.getPlayerData()
		if data then
			public.updateSlots(data)
		end
	end)
end

function private.resetTabColor(tab)
	for _, child in tab:GetChildren() do
		if child:IsA("Frame") then
			child.BackgroundColor3 = Color3.fromHex("24201e")

			local label = child:FindFirstChildOfClass("TextLabel")
			if label then
				label.TextColor3 = Color3.fromHex("dcc9a9")
			end
		end
	end
end

function private.updateSlotAmount(data)
	local amount = #data.inventory[category] or 0
	local storageSlots = data.storageSlots[category]
	slotAmountText.Text = amount .. "/" .. storageSlots
end

function private.setupButtons()
	closeButton.MouseButton1Click:Connect(function()
		inventory.Visible = false
		public.clearSlots()
	end)

	equipButton.MouseButton1Click:Connect(function()
		equipItem:FireServer(currentItem.id, category)
	end)

	statsTabButton.MouseButton1Click:Connect(function()
		private.changeInfoTab("stats")
	end)
	tagsTabButton.MouseButton1Click:Connect(function()
		private.changeInfoTab("tags")
	end)
	passivesTabButton.MouseButton1Click:Connect(function()
		private.changeInfoTab("passives")
	end)
	descriptionTabButton.MouseButton1Click:Connect(function()
		private.changeInfoTab("description")
	end)
end

function private.toggleButtons(data)
	for _, item in data.equipped do
		if not currentItem then
			return
		end
		if currentItem.id == item.id then
			equipFrame.Visible = false
			sellFrame.Visible = false
			unequipFrame.Visible = true
		else
			equipFrame.Visible = true
			sellFrame.Visible = true
			unequipFrame.Visible = false
		end
	end
end

function private.increaseTotalSlots() end

---- INFO ----

function private.updateInfo(item)
	local defaultInfo = ItemRegistry.get(item.id)
	local rarity = defaultInfo.rarity
	title.BackgroundColor3 = ItemRegistry.rarity[rarity]
	titleText.Text = defaultInfo.name
	glow.ImageColor3 = ItemRegistry.rarity[rarity]
	if rarity == "secret" then
		titleText.TextColor3 = ItemRegistry.rarity[rarity]
	end

	if category == "materials" then
		currentInfoTab = "description"
		amount.Text = "x" .. item.quantity
		statsTab.Visible = false
		tagsTab.Visible = false
		passivesTab.Visible = false
		equipFrame.Visible = false
	else
		amount.Text = "Lvl: " .. item.level
		statsTab.Visible = true
		tagsTab.Visible = true
		passivesTab.Visible = true
		equipFrame.Visible = true
	end

	private.updateStats(item)
	private.updateTags(item)
	private.updatePassives(item)
	private.updateDescription(item)
	private.changeInfoTab(currentInfoTab)
end

function private.changeInfoTab(tabName: string)
	currentInfoTab = tabName

	for name, panel in infoPanels do
		panel.Visible = (name == tabName)
	end

	private.resetTabColor(infoTabs)
	local selected = infoTabFrames[tabName]
	selected.frame.BackgroundColor3 = Color3.fromHex("dcc9a9")
	selected.text.TextColor3 = Color3.fromHex("2c2624")
end

function private.updateStats(item)
	for _, child in statsInfo:GetChildren() do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	local order = Utils.statOrder[item.category]
	if not order then
		return
	end

	for index, name in order do
		local value = item.stats[name]
		if value then
			local rank = item.rolls[index] or "D"

			local newStat = statTemplate:Clone()
			local statAmount = newStat:FindFirstChild("amount")
			local statName = newStat:FindFirstChild("name")
			local statRank = newStat:FindFirstChild("rank")

			newStat.Parent = statsInfo
			newStat.Name = name
			statAmount.Text = Utils.format(name, value)
			statName.Text = Utils.uiNames[name] or name
			statRank.Text = "[" .. rank .. "]"
			statRank.TextColor3 = ItemRegistry.rarity[Utils.rankRarity[rank]] or ItemRegistry.rarity.common
		end
	end
end

function private.updateTags(item) end

function private.updatePassives(item) end

function private.updateDescription(item)
	local defaultInfo = ItemRegistry.get(item.id)

	if not defaultInfo.description then
		warn("No description found for: " .. item.id)
		return
	end
	descriptionInfoText.Text = defaultInfo.description
end

function private.showStatBoost() end

return public
