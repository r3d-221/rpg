local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Items = ReplicatedStorage.Shared.Items

local private = {}
local public = {}
local registry = {}
local byCategory = { weapons = {}, armors = {}, materials = {} }

function private.loadFolder(folder)
	for _, module in folder:GetChildren() do
		if module:IsA("ModuleScript") then
			local ok, data = pcall(require, module)
			if ok and data and data.id then
				registry[data.id] = data
				if byCategory[data.category] then
					table.insert(byCategory[data.category], data)
				end
			else
				warn("ItemRegistry: failed to load", module.Name)
			end
		elseif module:IsA("Folder") then
			private.loadFolder(module)
		end
	end
end

private.loadFolder(Items) -- will it check one folder?

function public.get(id: string)
	return registry[id]
end

function public.getCategory(category: string)
	return byCategory[category] or {}
end

return public
