local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerData = require(script.Parent.PlayerData)

local class_template = ReplicatedStorage.UITemplates.class_template

local Remotes = ReplicatedStorage.Shared.Remotes
local changeClass = Remotes.changeClass

local public = {}
local private = {}

local classes = {
	warrior = { layout = 1, questLine = "Complete the warrior's heart quest", completed = false },
	archer = { layout = 2, questLine = "Complete the keen intuition quest", completed = false },
	mage = { layout = 3, questLine = "Complete the mage's resolve quest", completed = false },
	paladin = { layout = 4, questLine = "Complete the heart of gold quest", completed = false },
}

local classUI
local list
local closeButton

function public.onStart(screenGui: ScreenGui)
	classUI = screenGui:FindFirstChild("Class")
	list = classUI:FindFirstChild("list")
	closeButton = classUI:FindFirstChild("close"):FindFirstChild("button")

	private.setupButtons()

	PlayerData.onChange(public.updateSlots)
	local data = PlayerData.getPlayerData()

	if data then
		public.updateSlots(data)
	end
end

function public.updateSlots(data)
	private.clearSlots()

	private.checkQuestCompleted(data)
	private.createSlots(data)
end

function private.clearSlots()
	for _, child in list:GetChildren() do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
end

function private.checkQuestCompleted(data)
	local quests = data.quests.classes

	for name, class in classes do
		if quests[name] then
			class.completed = true
		else
			class.completed = false
		end
	end
end

function private.createSlots(data)
	for name, class in data.classes do
		local newSlot = class_template:Clone()
		newSlot.Parent = list

		local className = newSlot:FindFirstChild("class_name")
		local change = newSlot:FindFirstChild("change")
		local changeButton = change:FindFirstChild("button")
		local inUse = newSlot:FindFirstChild("in_use")

		className.Text = name

		if name == data.class then
			change.Visible = false
			inUse.Visible = true
		else
			inUse.Visible = false
			change.Visible = true
		end

		if change.Visible then
			changeButton.MouseButton1Click:Connect(function()
				print("requesting to change class to: " .. name)
				changeClass:FireServer(name)
			end)
		end

		for uiName, uiClass in classes do
			if uiName == name then
				newSlot.LayoutOrder = uiClass.layout
				local requirements = newSlot:FindFirstChild("requirements")
				if uiClass.completed then
					requirements.Text = "Completed"
				else
					requirements.Text = uiClass.questLine
				end
				break
			end
		end
	end
end

function private.setupButtons()
	closeButton.MouseButton1Click:Connect(function()
		classUI.Visible = false
		private.clearSlots()
	end)
end

return public
