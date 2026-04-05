local ReplicatedStorage = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")

local Remotes = ReplicatedStorage:FindFirstChild("Shared"):FindFirstChild("Remotes")
local attack = Remotes.attack

local Dmg = 50
local Range = 20
local Angle = 150

local private = {}
local public = {}

function public.onStart()
	attack.OnServerEvent:Connect(function(player, enemy, dmg)
		private.checkAttack(player, enemy, dmg)
	end)
end

function private.checkAttack(player: Player, enemy, dmg)
	print("validating attack..")
	local char = player.Character or player.CharacterAdded:Wait()
	local plrRoot = char:FindFirstChild("HumanoidRootPart")
	local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
	local enemyHum = enemy:FindFirstChild("Humanoid")

	if not (plrRoot and enemyRoot and enemyHum) then
		print("all info not loaded")
		if plrRoot then
			print("plrRoot loaded")
		end
		if enemyRoot then
			print("enemyRoot loaded")
		end
		if enemyHum then
			print("enemyHum loaded")
		end
	end

	local distanceVector = enemyRoot.Position - plrRoot.Position
	local distance = distanceVector.Magnitude

	if distance > Range then
		print("INVALID RANGE!")
		return
	end

	local plrDirection = plrRoot.CFrame.LookVector
	local enemyDirection = distanceVector.Unit

	local dotProduct = plrDirection:Dot(enemyDirection)
	local angleInRadians = math.acos(math.clamp(dotProduct, -1, 1))
	local angleInDegrees = math.deg(angleInRadians)

	if angleInDegrees > Angle / 2 then
		print("INVALID AOE!")
		return
	end

	enemyHum:TakeDamage(dmg)
	print("Mob hit! Remaining Health:", enemyHum.Health)
end

return public
