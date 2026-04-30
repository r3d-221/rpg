local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local player = Players.LocalPlayer
local PlayerScripts = player:FindFirstChild("PlayerScripts")

local Modules = ReplicatedStorage:FindFirstChild("Shared"):FindFirstChild("Modules")
local UserInput = require(Modules:FindFirstChild("UserInput"))

local screenGui = player:FindFirstChild("PlayerGui"):WaitForChild("ScreenGui")
local ClientFolder = PlayerScripts:WaitForChild("Client")
local UIFolder = ClientFolder.UI

local PlayerData = require(UIFolder["PlayerData.Client"])
local Inventory = require(UIFolder["Inventory.Client"])
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

PlayerData.onStart()
HUD.onStart()
Inventory.onStart(screenGui)
FullInfo.onStart(screenGui)
QuickInfo.onStart(screenGui)
