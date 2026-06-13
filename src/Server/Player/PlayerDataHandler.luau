local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local PlayerClassData = require(script.Parent.PlayerClassData)
local WeaponHandler = require(ServerScriptService.Server.Modules.WeaponHandler)
local PlayerConfig = require(ReplicatedStorage.Shared.Modules.PlayerConfig)
local ProfileStore = require(ServerScriptService.ServerPackages.ProfileStore)

local Remotes = ReplicatedStorage.Shared.Remotes
local syncPlayerData = Remotes.syncPlayerData
local useSprint = Remotes.useSprint
local spendStatPoint = Remotes.spendStatPoint
local resetStatPoints = Remotes.resetStatPoints
local equipItem = Remotes.equipItem
local unequipItem = Remotes.unequipItem
local syncStamina = Remotes.syncStamina

local PROFILE_STORE_KEY = "test_v6"

local STACK_CAP = 100
local STAMINA_REGEN_RATE = 10
local STAMINA_REGEN_DELAY = 2

local STAT_POINT_VALUES = {
	health = 10,
	armor = 2,
	damage = 3,
	critRate = 0.01,
	critDamage = 0.05,
}

local DEFAULT_PLAYER_DATA = {
	rankLevel = 1, -- rank = F =  1-5, E = 6-10, D = 11-15, ...
	class = "swordsman",

	-- Shared
	stamina = 100,
	staminaCost = 15,
	staminaSpeedMultiplier = 1.25,

	currency = {
		coins = 0,
		gems = 0,
		rankExp = 0,
	},

	inventory = {
		materials = {},
		artifacts = {},
		weapons = {},
		armors = {},
		misc = {},
	},

	storageSlots = {
		weapons = 20,
		armors = 20,
		artifects = 20,
		misc = 20,
		materials = 20,
	},

	equipped = {
		weapon = nil,
		helmet = nil,
		chestplate = nil,
		leggings = nil,
		boots = nil,
		artifects = {},
	},

	classes = {
		swordsman = {
			assignableStatPoints = 3,
			classLevel = 1,
			classExp = 0,

			stats = {},

			statPoints = {
				health = 0,
				damage = 0,
				armor = 0,
				critRate = 0,
				critDamage = 0,
			},
		},

		archer = {
			assignableStatPoints = 3,
			classLevel = 1,
			classExp = 0,

			stats = {},

			statPoints = {
				health = 0,
				damage = 0,
				armor = 0,
				critRate = 0,
				critDamage = 0,
			},
		},

		mage = {
			assignableStatPoints = 3,
			classLevel = 1,
			classExp = 0,

			stats = {},

			statPoints = {
				health = 0,
				damage = 0,
				armor = 0,
				critRate = 0,
				critDamage = 0,
			},
		},

		paladin = {
			assignableStatPoints = 3,
			classLevel = 1,
			classExp = 0,

			stats = {},

			statPoints = {
				health = 0,
				damage = 0,
				armor = 0,
				critRate = 0,
				critDamage = 0,
			},
		},
	},
}

local store = ProfileStore.New(PROFILE_STORE_KEY, DEFAULT_PLAYER_DATA)
local profiles = {} -- key: player; value: profile

local leaderstats = {}
local sprintingPlayers = {}
local staminaLastUsed = {}
local stamina = {}
local private = {}
local public = {}

function public.onStart()
	Players.PlayerAdded:Connect(private.onPlayerAdded)
	Players.PlayerRemoving:Connect(private.onPlayerRemoved)

	for _, player in Players:GetPlayers() do
		task.spawn(private.onPlayerAdded, player)
	end

	equipItem.OnServerEvent:Connect(function(player, itemId, category)
		local data = public.getData(player)
		if not data then
			return
		end

		local found = false
		for _, item in data.inventory[category] do
			if item.id == itemId then
				found = true
				break
			end
		end

		if not found then
			warn("Player does not own item: " .. itemId)
			return
		end

		local equippedItem = nil
		for _, item in data.inventory[category] do
			if item.id == itemId then
				equippedItem = item
				break
			end
		end
		if not equippedItem then
			warn("Could not find item entry for: " .. itemId)
			return
		end
		data.equipped.weapon = equippedItem
		WeaponHandler.equip(player, equippedItem.id)
		private.sync(player)
	end)

	unequipItem.OnServerEvent:Connect(function(player)
		local data = public.getData(player)
		if not data then
			return
		end

		data.equipped.weapon = nil
		WeaponHandler.unequip(player)
		private.sync(player)
	end)

	useSprint.OnServerEvent:Connect(function(player, isSprinting)
		if isSprinting then
			if sprintingPlayers[player] then
				return
			end
			sprintingPlayers[player] = true

			task.spawn(function()
				while sprintingPlayers[player] do
					local data = public.getData(player)
					if not data then
						break
					end

					local success = private.useStamina(player, data.staminaCost)
					if not success then
						sprintingPlayers[player] = nil
						useSprint:FireClient(player, false)
						break
					end
					task.wait(1)
				end
			end)
		else
			sprintingPlayers[player] = nil
		end
	end)

	spendStatPoint.OnServerEvent:Connect(function(player, stat)
		local data = public.getData(player)
		if not data then
			return
		end

		if (data.classes[data.class].assignableStatPoints or 0) <= 0 then
			print("no points to spend")
			return
		end
		if data.statPoints[stat] == nil then
			print("invalid stat:", stat)
			return
		end

		data.assignableStatPoints -= 1
		data.statPoints[stat] += 1
		private.applyStatPoints(data)
		private.sync(player)
	end)

	resetStatPoints.OnServerEvent:Connect(function(player)
		local data = public.getData(player)
		if not data then
			return
		end

		local cost = 2
		if (data.currency.gems or 0) < cost then
			-- send alert massege
			return
		end

		data.currency.gems -= cost

		local total = 0
		for stat, points in data.statPoints do
			total += points
			data.statPoints[stat] = 0
		end
		data.assignableStatPoints = (data.assignableStatPoints or 0) + total
		private.applyStatPoints(data)
		private.sync(player)
	end)
end

function public.getProfile(player: Player)
	return profiles[player]
end

function public.getData(player: Player): {}
	local profile = profiles[player]
	return profile and profile.Data
end

function public.addCurrency(player: Player, id: string, amount: number)
	local data = public.getData(player)
	if not data then
		warn("Couldn't add currency to player data.")
		return
	end

	data.currency[id] = (data.currency[id] or 0) + amount

	if id == "rankExp" then
		private.checkLevelUp(data, "rank")
	end

	if id == "classExp" then
		private.checkLevelUp(data, "class")
	end

	private.sync(player)
	-- print(data)
end

function public.addItem(player: Player, item)
	local data = public.getData(player)
	if not data then
		warn("Couldn't add item to player data.")
		return
	end

	local category = item.category
	if not data.inventory[category] then
		warn("Item category not found in player data")
		return
	end

	local slots = data.inventory[category]
	local slotCap = data.storageSlots[category]

	if category == "materials" then
		local remaining = item.quantity or 1

		-- fills in slots that have the item but aren't full
		for _, existing in slots do
			if existing.id == item.id and existing.quantity < STACK_CAP then
				local space = STACK_CAP - existing.quantity
				local toAdd = math.min(space, remaining)
				existing.quantity += toAdd
				remaining -= toAdd
			end
			if remaining <= 0 then
				private.sync(player)
				return
			end
		end

		-- creates new slot
		while remaining > 0 do
			if #slots >= slotCap then
				warn("Storage full for " .. category)
				-- drop the item for pickup
				break
			end
			local toAdd = math.min(remaining, STACK_CAP)
			table.insert(slots, { id = item.id, category = category, rarity = item.rarity, quantity = toAdd })
			remaining -= toAdd
		end

		private.sync(player)
		return
	end

	-- non-stackables
	if #slots >= slotCap then
		warn("Backpack full for category: " .. category .. " — item dropped: " .. item.id)
		-- drop the item for pickup
		private.sync(player)
		return
	end

	table.insert(slots, item)
	private.sync(player)
end

function public.changeClass(player: Player, class: string)
	local data = public.getData(player)
	if not data then
		warn("Couldn't add item to player data.")
		return
	end

	for _, v in data.classes do
		if v == class then
			data.class = class
			private.sync(player)
			break
		end
	end
end

function public.addStorageSlots(player: Player, category: string, amount: number)
	local data = public.getData(player)
	if not data then
		warn("Couldn't add storage to player data.")
		return
	end

	if not data.storageSlots[category] then
		warn("Item category not found in player data")
		return
	end

	data.storageSlots[category] += amount
	private.sync(player)
	-- print(data.storageSlots)
end

-- different from all the other values since it changes frequently
function public.getStamina(player: Player)
	return stamina[player] or 100
end

function private.useStamina(player: Player, amount: number): boolean
	local data = public.getData(player)
	if not data then
		return false
	end

	local current = stamina[player] or data.stamina
	if current < amount then
		return false
	end

	stamina[player] = current - amount
	staminaLastUsed[player] = tick()
	syncStamina:FireClient(player, stamina[player], data.stamina)
	return true
end

function private.checkLevelUp(data, type: string)
	if type == "class" then
		local required = PlayerConfig.expToClassLevel(data.classes[data.class].classLevel) -- exp required to level up

		while data.classes[data.class].classExp >= required do
			data.classes[data.class].classExp -= required
			data.classes[data.class].classLevel += 1
			data.classes[data.class].assignableStatPoints += 1
			required = PlayerConfig.expToClassLevel(data.classes[data.class].classLevel)
		end
	end

	if type == "rank" then
		local required = PlayerConfig.expToClassLevel(data.rankLevel) -- exp required to level up

		while data.currency.rankExp >= required do
			data.currency.rankExp -= required
			data.rankLevel += 1
			required = PlayerConfig.expToClassLevel(data.rankLevel)
		end

		private.rankUp()
	end
end

function private.rankUp() end

function private.applyStatPoints(data) -- needs to be fixed
	local classData = data.classes[data.class]
	local baseStats = PlayerClassData.baseStats[data.class]
	local points = classData.statPoints

	classData.stats.health = baseStats.health + (points.health * STAT_POINT_VALUES.health)
	classData.stats.armor = baseStats.armor + (points.armor * STAT_POINT_VALUES.armor)
	classData.stats.damage = baseStats.damage + (points.damage * STAT_POINT_VALUES.damage)
	classData.stats.critRate = baseStats.critRate + (points.critRate * STAT_POINT_VALUES.critRate)
	classData.stats.critDamage = baseStats.critDamage + (points.critDamage * STAT_POINT_VALUES.critDamage)
end

function private.onPlayerAdded(player: Player)
	local profile = store:StartSessionAsync("Player_" .. player.UserId, {
		Cancel = function()
			return not player:IsDescendantOf(Players)
		end,
	})

	if not profile then
		player:Kick("Failed to load player data!")
		return
	end

	profile:AddUserId(player.UserId)
	profiles[player] = profile
	profile:Reconcile()

	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	stats.Parent = player

	local level = Instance.new("IntValue")
	level.Name = "Level"
	level.Value = profile.Data.rankLevel
	level.Parent = stats

	local class = Instance.new("StringValue")
	class.Name = "Class"
	class.Value = profile.Data.class
	class.Parent = stats

	leaderstats[player] = {
		level = level,
		class = class,
	}

	player.AncestryChanged:Connect(function()
		if not player:IsDescendantOf(Players) then
			private.onPlayerRemoved(player)
		end
	end)

	stamina[player] = profile.Data.stamina

	-- stamina regen loop
	task.spawn(function()
		while player:IsDescendantOf(Players) do
			task.wait(1)

			local data = public.getData(player)
			if not data then
				continue
			end

			local max = data.stamina
			local current = stamina[player] or max
			local lastUsed = staminaLastUsed[player] or 0

			if current < max and tick() - lastUsed >= STAMINA_REGEN_DELAY then
				stamina[player] = math.min(current + STAMINA_REGEN_RATE, max)
				syncStamina:FireClient(player, stamina[player], data.stamina)
			end
		end
	end)

	player.CharacterAdded:Connect(function()
		local data = public.getData(player)
		if data and data.equipped.weapon then
			print(data.equipped.weapon.id)
			print(data.equipped)
			WeaponHandler.equip(player, data.equipped.weapon.id)
		end
	end)

	local data = public.getData(player)
	if data and data.equipped.weapon then
		print(data.equipped.weapon.id)
		print(data.equipped)
		WeaponHandler.equip(player, data.equipped.weapon.id)
	end

	private.sync(player)
end

function private.onPlayerRemoved(player: Player)
	leaderstats[player] = nil
	staminaLastUsed[player] = nil
	stamina[player] = nil
	sprintingPlayers[player] = nil
	local profile = profiles[player]
	if profile then
		profile:EndSession()
		profiles[player] = nil
	end
end

function private.sync(player: Player)
	local data = public.getData(player)
	if not data then
		return
	end

	-- needs to be changed
	data.currentStamina = stamina[player]
	syncPlayerData:FireClient(player, data)

	local stats = leaderstats[player]
	if stats then
		stats.level.Value = data.rankLevel
		stats.class.Value = data.class
	end
end

return public
