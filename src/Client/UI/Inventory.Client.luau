local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local PlayerScripts = player:FindFirstChild("PlayerScripts")
local UITemplates = ReplicatedStorage.UITemplates

local ClientFolder = PlayerScripts:WaitForChild("Client")
local UIFolder = ClientFolder.UI

local UIManager = require(UIFolder["UIManager.Client"])
local QuickInfo = require(UIFolder["QuickInfo.Client"])
local PlayerData = require(UIFolder["PlayerData.Client"])

local private = {}
local public = {}

local SLIDE_AMOUNT = 0.07
local TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local inventoryFrame
local slots
local tabs
local closeButton
local isMoved = false
local currentTab = "weapons"

function public.onStart(screenGui: ScreenGui)
	inventoryFrame = screenGui:FindFirstChild("inventory")
	slots = inventoryFrame:FindFirstChild("slots")
	tabs = inventoryFrame:FindFirstChild("tabs")
	closeButton = inventoryFrame:FindFirstChild("close"):FindFirstChild("closeButton")

	closeButton.MouseButton1Click:Connect(function()
		UIManager.closeAll()
		if isMoved then
			public.slideBack()
		end
	end)

	PlayerData.onChange(function(data)
		private.addSlots(data.inventory)
	end)

	UIManager.onEvent("inventoryClosed", function()
		UIManager.close("fullInfo")
		if isMoved then
			public.slideBack()
		end
	end)

	UIManager.onEvent("inventorySlideBack", function()
		public.slideBack()
	end)

	for _, tab in tabs:GetChildren() do
		if tab:IsA("Frame") then
			local tabButton
			for _, v in tab:GetChildren() do
				if v:IsA("TextButton") then
					tabButton = v
					break
				end
			end
			tabButton.MouseButton1Click:Connect(function()
				private.switchTab(tab.Name)
			end)
		end
	end
end

function public.slide()
	if isMoved then
		return
	end
	isMoved = true

	local targetPos = UDim2.new(
		inventoryFrame.Position.X.Scale + SLIDE_AMOUNT,
		inventoryFrame.Position.X.Offset,
		inventoryFrame.Position.Y.Scale,
		inventoryFrame.Position.Y.Offset
	)

	TweenService:Create(inventoryFrame, TWEEN_INFO, { Position = targetPos }):Play()
end

function public.slideBack()
	if not isMoved then
		return
	end
	isMoved = false

	local targetPos = UDim2.new(
		inventoryFrame.Position.X.Scale - SLIDE_AMOUNT,
		inventoryFrame.Position.X.Offset,
		inventoryFrame.Position.Y.Scale,
		inventoryFrame.Position.Y.Offset
	)

	TweenService:Create(inventoryFrame, TWEEN_INFO, { Position = targetPos }):Play()
end

function private.switchTab(name: string)
	currentTab = name
	local data = PlayerData.getPlayerData()
	if data then
		private.addSlots(data.inventory)
	end
end

function private.addSlots(inventory)
	local itemList = inventory[currentTab]

	if not itemList then
		warn("No items were found in cache.")
		return
	end

	for _, slot in slots:GetChildren() do
		if slot:IsA("Frame") then
			slot:Destroy()
		end
	end

	for _, item in itemList do
		private.createSlot(item)
	end
end

function private.createSlot(item)
	local slot = UITemplates.slot:Clone()
	slot.Parent = slots

	local itemButton = slot:FindFirstChild("item")

	itemButton.MouseEnter:Connect(function()
		QuickInfo.show(item, slot)
	end)

	itemButton.MouseLeave:Connect(function()
		QuickInfo.hide()
	end)

	itemButton.MouseButton1Click:Connect(function()
		QuickInfo.hide()
		public.slide()
		UIManager.fire("showFullInfo", item)
	end)
end

return public
