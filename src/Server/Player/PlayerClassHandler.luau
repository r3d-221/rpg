local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerClassData = require(script.Parent.PlayerClassData)
local PlayerDataHandler = require(script.Parent.PlayerDataHandler)

local Remotes = ReplicatedStorage.Shared.Remotes
local swtichClass = Remotes.swtichClass

local public = {}
local private = {}

function public.onStart()
	swtichClass.OnServerEvent.Connect(function(player, class)
		if private.verifyClassChange() then
			PlayerDataHandler.changeClass(player, class)
		end
	end)
end

function private.verifyClassChange(): boolean
	return false
end

function private.checkEquippedItems() end

return public
