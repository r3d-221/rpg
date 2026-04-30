local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage.Shared.Remotes
local syncPlayerData = Remotes.syncPlayerData

local listeners = {}
local public = {}
local cache = nil

function public.onStart()
	syncPlayerData.OnClientEvent:Connect(function(data)
		cache = data
		for _, fn in listeners do
			fn(data)
		end
	end)
end

function public.getPlayerData()
	return cache
end

function public.onChange(fn)
	table.insert(listeners, fn)
end

return public
