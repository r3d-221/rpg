local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local weaponTemplates = ReplicatedStorage:FindFirstChild("weapons")

local equippedWeapons = {}

local private = {}
local public = {}

function public.equip(player: Player, itemId: string)
	local character = player.Character
	if not character then
		return
	end

	public.unequip(player)

	local template = private.getTemplate(itemId)
	if not template then
		warn("WeaponHandler: no template found for id: " .. itemId)
		return
	end

	local rightHand = character:FindFirstChild("RightHand")
	if not rightHand then
		warn("WeaponHandler: RightHand not found")
		return
	end

	local weaponPart = template:Clone()
	weaponPart.Anchored = false
	weaponPart.CanCollide = false
	weaponPart.Parent = character

	local offsetVector = weaponPart:GetAttribute("offset") or Vector3.zero
	local rotationVector = weaponPart:GetAttribute("rotation") or Vector3.zero

	local rotationCFrame =
		CFrame.fromEulerAnglesXYZ(math.rad(rotationVector.X), math.rad(rotationVector.Y), math.rad(rotationVector.Z))

	local motor = Instance.new("Motor6D")
	motor.Name = "WeaponGrip"
	motor.Part0 = rightHand
	motor.Part1 = weaponPart
	motor.C0 = CFrame.new(offsetVector) * rotationCFrame
	motor.Parent = rightHand

	equippedWeapons[player] = weaponPart
end

function public.unequip(player: Player)
	local existing = equippedWeapons[player]
	if not existing then
		return
	end

	local character = player.Character
	if character then
		local rightHand = character:FindFirstChild("RightHand")
		if rightHand then
			local motor = rightHand:FindFirstChild("WeaponGrip")
			if motor then
				motor:Destroy()
			end
		end
	end

	existing:Destroy()
	equippedWeapons[player] = nil
end

function public.getEquipped(player: Player)
	return equippedWeapons[player]
end

function private.getTemplate(itemId: string)
	for _, template in weaponTemplates:GetChildren() do
		if template:GetAttribute("id") == itemId then
			return template
		end
	end
	return nil
end

Players.PlayerRemoving:Connect(function(player)
	equippedWeapons[player] = nil
end)

return public
