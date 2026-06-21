local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local StarterPlayer = game:GetService("StarterPlayer")

local player = Players.LocalPlayer
local PlayerScripts = player:FindFirstChild("PlayerScripts")

local Shared = ReplicatedStorage:FindFirstChild("Shared")
local Modules = Shared:FindFirstChild("Modules")
local ItemRegistry = require(ReplicatedStorage.Shared.Items.ItemRegistry)
local UserInput = require(Modules:FindFirstChild("UserInput"))

local screens = player:FindFirstChild("PlayerGui"):WaitForChild("Screens")
local ClientFolder = PlayerScripts:WaitForChild("Client")
local UIFolder = ClientFolder.UI

local EnemyUI = require(UIFolder["EnemyUI.Client"])
local PlayerData = require(UIFolder.PlayerData)

local Menu = require(UIFolder.Menu)
local Inventory = require(UIFolder.Inventory)

local animate = ReplicatedStorage:FindFirstChild("IgnoredFolder"):FindFirstChild("Animate")

local enemyTag = "Enemy"

local function applyAnimate(object)
	if not object:IsDescendantOf(workspace) then
		return
	end
	if object:FindFirstChild("Animate") then
		return
	end

	local humanoid = object:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	local newAnimate = animate:Clone()
	newAnimate.Parent = object
	newAnimate.Enabled = true
end

for _, object in CollectionService:GetTagged(enemyTag) do
	applyAnimate(object)
end

PlayerData.onStart()

CollectionService:GetInstanceAddedSignal(enemyTag):Connect(applyAnimate)
UserInput.onStart()

Menu.onStart(screens)
ItemRegistry.onStart()
Inventory.onStart(screens)
