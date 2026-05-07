local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local player = Players.LocalPlayer
local PlayerScripts = player:FindFirstChild("PlayerScripts")

local Shared = ReplicatedStorage:FindFirstChild("Shared")
local Modules = Shared:FindFirstChild("Modules")
local ItemRegistry = require(ReplicatedStorage.Shared.Items.ItemRegistry)
local PlayerIconCache = require(Modules:FindFirstChild("PlayerIconCache"))
local UserInput = require(Modules:FindFirstChild("UserInput"))

local screenGui = player:FindFirstChild("PlayerGui"):WaitForChild("ScreenGui")
local ClientFolder = PlayerScripts:WaitForChild("Client")
local UIFolder = ClientFolder.UI

local EnemyUI = require(UIFolder["EnemyUI.Client"])
local PlayerData = require(UIFolder["PlayerData.Client"])
local Inventory = require(UIFolder["Inventory.Client"])
local Profile = require(UIFolder["Profile.Client"])
local FullInfo = require(UIFolder["FullInfo.Client"])
local QuickInfo = require(UIFolder["QuickInfo.Client"])
local HUD = require(UIFolder["HUD.Client"])

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

CollectionService:GetInstanceAddedSignal(enemyTag):Connect(applyAnimate)
UserInput.onStart()

PlayerIconCache.onStart()
ItemRegistry.onStart()
PlayerData.onStart()
EnemyUI.onStart()
HUD.onStart()
Inventory.onStart(screenGui)
Profile.onStart(screenGui)
FullInfo.onStart(screenGui)
QuickInfo.onStart(screenGui)
