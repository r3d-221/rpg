local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Modules = ReplicatedStorage:FindFirstChild("Shared"):FindFirstChild("Modules")
local UserInput = require(Modules:FindFirstChild("UserInput"))

local animate = ReplicatedStorage:FindFirstChild("IgnoredFolder"):FindFirstChild("Animate")

local enemyTag = "Enemy"

local function applyAnimate(object)
	if object:FindFirstChild("Animate") then
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
