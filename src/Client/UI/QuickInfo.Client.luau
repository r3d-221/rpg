local Players = game:GetService("Players")

local player = Players.LocalPlayer
local PlayerScripts = player:FindFirstChild("PlayerScripts")

local ClientFolder = PlayerScripts:WaitForChild("Client")
local UIFolder = ClientFolder.UI

local UIManager = require(UIFolder["UIManager.Client"])

local public = {}

local frame
local itemText
local stats
local level
local type

function public.onStart(screenGui: ScreenGui)
	frame = screenGui:FindFirstChild("quickInfo")
	itemText = frame:FindFirstChild("itemName"):FindFirstChild("name")
	stats = frame:FindFirstChild("stats")
	level = frame:FindFirstChild("level")
	type = frame:FindFirstChild("type")
end

function public.show(item, slot)
	itemText.Text = item.name or "Unknown"
	type.Text = item.subCategory or "?"
	level.Text = tostring(item.level or 1)

	-- set stats
	for _, stat in stats:GetChildren() do
		if stat:IsA("Frame") then
			local rank = stat:FindFirstChild("rank") -- show the quality from D to S rank
			local statInfo = stat:FindFirstChild("statInfo")
			-- get serialized info of the stats in player inventory
		end
	end

	frame.Visible = true
end

function public.hide()
	frame.Visible = false
end

return public
