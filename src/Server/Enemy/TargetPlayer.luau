local Players = game:GetService("Players")

local range = 20

local public = {}
local private = {}

function public.find(enemy)
	return private.nearestPlayer(enemy)
end

function private.nearestPlayer(enemy)
	local nearest = nil
	local minDistance = math.huge

	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		if not character then
			continue
		end

		local playerRoot = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChild("Humanoid")

		if not playerRoot or not humanoid then
			continue
		end
		if humanoid.Health <= 0 then
			continue
		end

		local distance = (playerRoot.Position - enemy.HumanoidRootPart.Position).Magnitude

		if distance <= range and distance < minDistance then
			minDistance = distance
			nearest = player
		end
	end

	return nearest
end

return public
