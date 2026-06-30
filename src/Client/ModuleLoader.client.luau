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

local PlayerGui = player:FindFirstChild("PlayerGui")
local screens = PlayerGui:WaitForChild("Screens")
local ClientFolder = PlayerScripts:WaitForChild("Client")
local UIFolder = ClientFolder.UI

local EnemyUI = require(UIFolder.EnemyUI)
local PlayerData = require(UIFolder.PlayerData)

local Menu = require(UIFolder.Menu)
local Class = require(UIFolder.Class)
local Profile = require(UIFolder.Profile)
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
Profile.onStart(screens)
ItemRegistry.onStart()
Inventory.onStart(screens)
Class.onStart(screens)
Menu.onStart(screens)
EnemyUI.onStart()

CollectionService:GetInstanceAddedSignal(enemyTag):Connect(applyAnimate)
UserInput.onStart()
