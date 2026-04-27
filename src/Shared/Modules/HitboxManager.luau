local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local Remotes = ReplicatedStorage:FindFirstChild("Shared"):FindFirstChild("Remotes")

local attack = Remotes:FindFirstChild("attack")

local enemyTag = "Enemy"

local Dmg = 50
local Range = 20
local Angle = 120

local private = {}
local public = {}

function public.New()
	local Character = player.Character or player.CharacterAdded:Wait()
	local humanoidRootPart = Character:FindFirstChild("HumanoidRootPart")

	local nearByEnemies: {} =
		private.findNearBy(humanoidRootPart.Position, humanoidRootPart.CFrame.LookVector, Range, Angle)

	if #nearByEnemies > 0 then
		for _, enemy in pairs(nearByEnemies) do
			attack:FireServer(enemy, Dmg)
			-- print(enemy.Name)
		end
		-- else
		-- 	print("No enemies in range!")
	end
end

function private.findNearBy(basePos: Vector3, direction: Vector3, range: number, angle: number): {}
	local nearByEnemies = {}

	for _, enemy in CollectionService:GetTagged(enemyTag) do
		local root = enemy:FindFirstChild("HumanoidRootPart")
		local humanoid: Humanoid = enemy:FindFirstChild("Humanoid")

		if root and humanoid and humanoid.Health > 0 then
			local distanceVector = root.Position - basePos
			local distance = distanceVector.Magnitude

			if distance <= range then
				local enemyDirection = distanceVector.Unit
				local dotProduct = direction:Dot(enemyDirection)
				local angleFromMob = math.deg(math.acos(dotProduct))

				if angleFromMob <= (angle / 2) then
					table.insert(nearByEnemies, enemy)
				end
			end
		end
	end
	return nearByEnemies
end

return public
