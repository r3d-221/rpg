local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local WeaponHandler = require(ServerScriptService.Server.Modules.WeaponHandler)
local ItemRegistry = require(ReplicatedStorage.Shared.Items.ItemRegistry)
local PlayerClassData = require(script.Parent.PlayerClassData)
local PlayerDataHandler = require(script.Parent.PlayerDataHandler)

local Remotes = ReplicatedStorage.Shared.Remotes
local changeClass = Remotes.changeClass

local public = {}
local private = {}

function public.onStart()
	changeClass.OnServerEvent:Connect(function(player, class)
		if private.verifyClassChange(player, class) then
			PlayerDataHandler.changeClass(player, class)
			-- private.checkEquippedItems(PlayerDataHandler.getData(player))
		end
	end)
end

function private.verifyClassChange(player: Player, class: string): boolean
	local data = PlayerDataHandler.getData(player)
	if data.quests.classes[class] then
		-- add a cooldown
		print("Class change can be done")
		return true
	end
	warn("Class change is incomplete")
	return false
end

function private.findItemByUid(itemList, uid)
	print(itemList)
	for _, list in itemList do
		for _, item in list do
			if item.uid == uid then
				return item
			end
		end
	end
	return nil
end

function private.checkEquippedItems(data)
	local filter = PlayerClassData[data.class]
	for i, v in data.equipped do
		if i == "weapon" then
			if v == nil then
				continue
			else
				print(data)
				local item = private.findItemByUid(data.inventory.weapons, v)
				local defaultInfo = ItemRegistry.get(item.id)
				if defaultInfo.subCategory == filter.weapons then
					continue
				else
					-- unequip the item
					-- give a default item from the class data
				end
			end
		else
			if v == nil then
				continue
			else
				print(data)
				local item = private.findItemByUid(data.inventory.armors, v)
				local defaultInfo = ItemRegistry.get(item.id)
				if defaultInfo.subCategory == filter.weapons then
					continue
				else
					if defaultInfo.subCategory == filter.weapons then
						continue
					else
						-- unequip the item
						-- dont give anything
					end
				end
			end
		end
	end
end

return public
