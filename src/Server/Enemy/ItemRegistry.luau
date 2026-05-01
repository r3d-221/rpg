local ServerScriptService = game:GetService("ServerScriptService")

local Server = ServerScriptService.Server
local weaponConfigs = Server.Weapons
local armorConfigs = Server.Armors

local public = {}
local registry = {}

for _, module in weaponConfigs:GetChildren() do
	local ok, entry = pcall(require, module)
	if ok and entry and entry.id then
		registry[entry.id] = entry
	else
		warn("ItemRegistry: failed to load weapon module: " .. module.Name)
	end
end

for _, module in armorConfigs:GetChildren() do
	local ok, set = pcall(require, module)
	if ok and set and set.pieces then
		for _, piece in set.pieces do
			if piece.id then
				registry[piece.id] = {
					setName = set.setName,
					setBonus = set.setBonus,
					baseArmor = piece.baseArmor,
					baseHealth = piece.baseHealth,
					baseSpeed = piece.baseSpeed,
					baseLuck = piece.baseLuck,
				}
			end
		end
	else
		warn("ItemRegistry: failed to load armor module: " .. module.Name)
	end
end

function public.getItemInfo(id: string)
	return registry[id]
end

return public
