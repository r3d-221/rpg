local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Items = ReplicatedStorage.Shared.Items

local private = {}
local public = {}
local registry = {}
local byCategory = { weapons = {}, armors = {}, materials = {} }

public.rarity = {
	common = Color3.fromHex("#c4cfc8"),
	uncommon = Color3.fromHex("#86a7ac"),
	rare = Color3.fromHex("#4b7cb7"),
	epic = Color3.fromHex("#7255a1"),
	legendary = Color3.fromHex("#ffb155"),
	mythic = Color3.fromHex("#b86440"),
	secret = Color3.fromHex("#302033"),
	secretText = Color3.fromHex("#b83a2d"),
}

function private.loadFolder(folder)
	for _, module in folder:GetChildren() do
		if module:IsA("ModuleScript") then
			local ok, data = pcall(require, module)
			if ok and data and data.id then
				registry[data.id] = data
				if byCategory[data.category] then
					table.insert(byCategory[data.category], data)
				end
			elseif module.Name == "ItemRegistry" or module.Name == "SetBonus" then
				continue
			else
				warn("ItemRegistry: failed to load", module.Name)
			end
		elseif module:IsA("Folder") then
			private.loadFolder(module)
		end
	end
end

private.loadFolder(Items)

function public.get(id: string)
	return registry[id]
end

function public.getCategory(category: string)
	return byCategory[category] or {}
end

return public
