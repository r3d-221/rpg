local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:FindFirstChild("Shared"):FindFirstChild("Remotes")
local attack = Remotes.attack

local Dmg = 50
local Range = 20
local Angle = 150

local private = {}
local public = {}

function public.onStart()
	attack.OnServerEvent:Connect(function(player, enemy)
		private.checkAttack(player, enemy)
	end)
end

function private.checkAttack(player: Player, enemy)
	-- print("validating attack..")
	local char = player.Character or player.CharacterAdded:Wait()
	local plrRoot = char:FindFirstChild("HumanoidRootPart")
	local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
	local enemyHum = enemy:FindFirstChild("Humanoid")

	if not (plrRoot and enemyRoot and enemyHum) then
		return
	end

	local distanceVector = enemyRoot.Position - plrRoot.Position
	local distance = distanceVector.Magnitude

	if distance > Range then
		-- print("INVALID RANGE!")
		return
	end

	local plrDirection = plrRoot.CFrame.LookVector
	local enemyDirection = distanceVector.Unit

	local dotProduct = plrDirection:Dot(enemyDirection)
	local angleInRadians = math.acos(math.clamp(dotProduct, -1, 1))
	local angleInDegrees = math.deg(angleInRadians)

	if angleInDegrees > Angle / 2 then
		-- print("INVALID AOE!")
		return
	end

	enemyHum:TakeDamage(Dmg)
	-- print("Mob hit! Remaining Health:", enemyHum.Health)
end

return public
