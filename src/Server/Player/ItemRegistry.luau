local ServerScriptService = game:GetService("ServerScriptService")

local Server = ServerScriptService.Server
local weaponConfigs = Server.Weapons
local armorConfigs = Server.Armors

local public = {}

for _, module in weaponConfigs do
	local entry = require(module)
	public[entry.id] = entry
end

for _, module in armorConfigs do
	local set = require(module)

	for _, piece in set.pieces do
		public[piece.id] = {
			setName = set.setName,
			setBonus = set.setBonus,
			piece = piece,
		}
	end
end

function public.getRegistry(id: string)
	return public[id]
end

return public
