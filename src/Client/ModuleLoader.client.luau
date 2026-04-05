local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Modules = ReplicatedStorage:FindFirstChild("Shared"):FindFirstChild("Modules")
local UserInput = require(Modules:FindFirstChild("UserInput"))

local animate = ReplicatedStorage:FindFirstChild("IgnoredFolder"):FindFirstChild("Animate")

local enemyTag = "Enemy"

for i, object in CollectionService:GetTagged(enemyTag) do
	local newAnimate = animate:Clone()
	newAnimate.Parent = object
	newAnimate.Enabled = true
end

UserInput.onStart()
