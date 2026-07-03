local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local StatsCalculator = require(ServerScriptService.Server.Modules.StatsCalculator)
local ItemRegistry = require(ReplicatedStorage.Shared.Items.ItemRegistry)
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

local PROFILE_STORE_KEY = "test_v11"

local STACK_CAP = 100
local STAMINA_REGEN_RATE = 10
local STAMINA_REGEN_DELAY = 2

local ARMOR_SLOTS = {
	helmet = true,
	chestplate = true,
	leggings = true,
	boots = true,
}

local DEFAULT_PLAYER_DATA = {
	rankLevel = 1,
	class = "warrior",
	title = "None",
	rank = "D",

	stamina = 100,
	staminaCost = 15,
	staminaSpeedMultiplier = 1.25,

	quests = {
		classes = {
			warrior = true,
			archer = true,
			mage = true,
			paladin = false,
		},
	},

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
		artifacts = 20,
		misc = 20,
		materials = 20,
	},

	equipped = {
		weapon = nil,
		helmet = nil,
		chestplate = nil,
		leggings = nil,
		boots = nil,
		artifacts = {},
	},

	classes = {
		warrior = {
			assignableStatPoints = 3,
			classLevel = 1,
			classExp = 0,
			baseStats = {},
			stats = {},
			statPoints = {
				health = 0,
				damage = 0,
				armor = 0,
				critRate = 0,
				critDamage = 0,
			},
			tempBuffs = {},
		},

		archer = {
			assignableStatPoints = 3,
			classLevel = 1,
			classExp = 0,
			baseStats = {},
			stats = {},
			statPoints = {
				health = 0,
				damage = 0,
				armor = 0,
				critRate = 0,
				critDamage = 0,
			},
			tempBuffs = {},
		},

		mage = {
			assignableStatPoints = 3,
			classLevel = 1,
			classExp = 0,
			baseStats = {},
			stats = {},
			statPoints = {
				health = 0,
				damage = 0,
				armor = 0,
				critRate = 0,
				critDamage = 0,
			},
			tempBuffs = {},
		},

		paladin = {
			assignableStatPoints = 3,
			classLevel = 1,
			classExp = 0,
			baseStats = {},
			stats = {},
			statPoints = {
				health = 0,
				damage = 0,
				armor = 0,
				critRate = 0,
				critDamage = 0,
			},
			tempBuffs = {},
		},
	},
}

local store = ProfileStore.New(PROFILE_STORE_KEY, DEFAULT_PLAYER_DATA)
local profiles = {}

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

	-- no need for category
	-- search from uid
	-- for armors, check the sub category
	equipItem.OnServerEvent:Connect(function(player: Player, uid: string, category: string)
		local data = public.getData(player)
		if not data then
			return
		end

		local inventory = data.inventory[category]
		if not inventory then
			warn("equipItem: invalid category: " .. tostring(category))
			return
		end

		local item = nil
		for _, entry in inventory do
			if entry.uid == uid then
				item = entry
				break
			end
		end

		if not item then
			warn("equipItem: player does not own item: " .. uid)
			print(item)
			return
		end

		local registryItem = ItemRegistry.findItemByUid(data.inventory, uid)
		if not registryItem then
			warn("equipItem: no registry entry for: " .. uid)
			return
		end

		if category == "weapons" then
			data.equipped.weapon = item.uid
			WeaponHandler.equip(player, item.id)
		elseif category == "armors" then
			local defaultInfo = ItemRegistry.get(registryItem.id)
			local slot = defaultInfo.subCategory
			if not ARMOR_SLOTS[slot] then
				warn("equipItem: unknown armor slot: " .. tostring(slot))
				return
			end
			data.equipped[slot] = item.uid
		else
			warn("equipItem: equipping not yet supported for category: " .. tostring(category))
			return
		end

		StatsCalculator.calculateBase(data)
		private.sync(player)
	end)

	unequipItem.OnServerEvent:Connect(function(player: Player, uid: string, category: string)
		local data = public.getData(player)
		if not data then
			return
		end

		local registryItem = ItemRegistry.findItemByUid(data.inventory, uid)
		if not registryItem then
			warn("equipItem: no registry entry for: " .. uid)
			return
		end

		if category == "weapons" then
			data.equipped.weapon = nil
			WeaponHandler.unequip(player)
		elseif category == "armors" then
			local defaultInfo = ItemRegistry.get(registryItem.id)
			local slot = defaultInfo.subCategory
			if not ARMOR_SLOTS[slot] then
				warn("unequipItem: unknown armor slot: " .. tostring(slot))
				return
			end
			data.equipped[slot] = nil
		else
			warn("unequipItem: unequipping not yet supported for category: " .. tostring(category))
			return
		end

		StatsCalculator.calculateBase(data)
		private.sync(player)
	end)

	useSprint.OnServerEvent:Connect(function(player: Player, isSprinting: boolean)
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

					if not private.useStamina(player, data.staminaCost) then
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

	spendStatPoint.OnServerEvent:Connect(function(player: Player, stat: string)
		local data = public.getData(player)
		if not data then
			return
		end

		local classData = data.classes[data.class]

		if (classData.assignableStatPoints or 0) <= 0 then
			warn("spendStatPoint: no assignable points for: " .. player.Name)
			return
		end
		if classData.statPoints[stat] == nil then
			warn("spendStatPoint: invalid stat: " .. tostring(stat))
			return
		end

		classData.assignableStatPoints -= 1
		classData.statPoints[stat] += 1
		StatsCalculator.calculateBase(data)
		private.sync(player)
	end)

	resetStatPoints.OnServerEvent:Connect(function(player: Player)
		local data = public.getData(player)
		if not data then
			return
		end

		local classData = data.classes[data.class]

		local cost = 0
		if (data.currency.gems or 0) < cost then
			-- TODO: send alert to client
			return
		end

		data.currency.gems -= cost

		local total = 0
		for stat, points in classData.statPoints do
			total += points
			classData.statPoints[stat] = 0
		end
		classData.assignableStatPoints = (classData.assignableStatPoints or 0) + total
		StatsCalculator.calculateBase(data)
		private.sync(player)
	end)
end

function public.getProfile(player: Player)
	return profiles[player]
end

function public.getData(player: Player): {}?
	local profile = profiles[player]
	return profile and profile.Data
end

function public.addCurrency(player: Player, id: string, amount: number)
	local data = public.getData(player)
	if not data then
		return
	end

	if id == "classExp" then
		data.classes[data.class].classExp += amount
		private.checkLevelUp(data, "class")
	elseif id == "rankExp" then
		data.currency.rankExp += amount
		private.checkLevelUp(data, "rank")
	else
		data.currency[id] = (data.currency[id] or 0) + amount
	end

	private.sync(player)
end

function public.addItem(player: Player, item)
	local data = public.getData(player)
	if not data then
		warn("addItem: no data for player: " .. player.Name)
		return
	end

	local registryItem = ItemRegistry.get(item.id)
	if not registryItem then
		warn("addItem: no registry entry for id: " .. tostring(item.id))
		return
	end

	local category = registryItem.category
	local slots = data.inventory[category]
	local slotCap = data.storageSlots[category]

	if not slots then
		warn("addItem: category not found in inventory: " .. tostring(category))
		return
	end

	if category == "materials" then
		local remaining = item.amount or 1

		for _, existing in slots do
			if remaining <= 0 then
				break
			end
			if existing.id == item.id and existing.amount < STACK_CAP then
				local toAdd = math.min(STACK_CAP - existing.amount, remaining)
				existing.amount += toAdd
				remaining -= toAdd
			end
		end

		while remaining > 0 do
			if #slots >= slotCap then
				warn("addItem: storage full for " .. category)
				-- TODO: spawn item in world for pickup
				break
			end
			local toAdd = math.min(remaining, STACK_CAP)
			table.insert(slots, { id = item.id, amount = toAdd })
			remaining -= toAdd
		end

		private.sync(player)
		return
	end

	if #slots >= slotCap then
		warn("addItem: backpack full for " .. category .. ", item dropped: " .. item.id)
		-- TODO: spawn item in world for pickup
		private.sync(player)
		return
	end

	table.insert(slots, item)
	private.sync(player)
end

function public.changeClass(player: Player, class: string)
	local data = public.getData(player)
	if not data then
		return
	end

	if not data.classes[class] then
		warn("changeClass: invalid class: " .. tostring(class))
		return
	end

	data.class = class
	StatsCalculator.calculateBase(data)
	private.sync(player)
end

function public.addStorageSlots(player: Player, category: string, amount: number)
	local data = public.getData(player)
	if not data then
		return
	end

	if not data.storageSlots[category] then
		warn("addStorageSlots: invalid category: " .. tostring(category))
		return
	end

	data.storageSlots[category] += amount
	private.sync(player)
end

function public.getStamina(player: Player): number
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

function private.checkLevelUp(data, levelType: string)
	if levelType == "class" then
		local classData = data.classes[data.class]
		local required = PlayerConfig.expToClassLevel(classData.classLevel)

		while classData.classExp >= required do
			classData.classExp -= required
			classData.classLevel += 1
			classData.assignableStatPoints += 1
			required = PlayerConfig.expToClassLevel(classData.classLevel)
		end

		StatsCalculator.calculateBase(data)
	elseif levelType == "rank" then
		local required = PlayerConfig.expToRankLevel(data.rankLevel)

		while data.currency.rankExp >= required do
			data.currency.rankExp -= required
			data.rankLevel += 1
			required = PlayerConfig.expToRankLevel(data.rankLevel)
		end

		-- TODO: handle rank-up rewards/effects when designed
	end
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

	local data = profile.Data
	StatsCalculator.calculateBase(data)

	local statsFolder = Instance.new("Folder")
	statsFolder.Name = "leaderstats"
	statsFolder.Parent = player

	local levelValue = Instance.new("IntValue")
	levelValue.Name = "Level"
	levelValue.Value = data.rankLevel
	levelValue.Parent = statsFolder

	local classValue = Instance.new("StringValue")
	classValue.Name = "Class"
	classValue.Value = data.class
	classValue.Parent = statsFolder

	leaderstats[player] = { level = levelValue, class = classValue }

	player.AncestryChanged:Connect(function()
		if not player:IsDescendantOf(Players) then
			private.onPlayerRemoved(player)
		end
	end)

	stamina[player] = data.stamina

	task.spawn(function()
		while player:IsDescendantOf(Players) do
			task.wait(1)

			local currentData = public.getData(player)
			if not currentData then
				continue
			end

			local max = currentData.stamina
			local current = stamina[player] or max
			local lastUsed = staminaLastUsed[player] or 0

			if current < max and tick() - lastUsed >= STAMINA_REGEN_DELAY then
				stamina[player] = math.min(current + STAMINA_REGEN_RATE, max)
				syncStamina:FireClient(player, stamina[player], max)
			end
		end
	end)

	player.CharacterAdded:Connect(function()
		local currentData = public.getData(player)
		if not currentData then
			return
		end
		if currentData.equipped.weapon then
			local item = ItemRegistry.findItemByUid(currentData.inventory, currentData.equipped.weapon)
			if item then
				WeaponHandler.equip(player, item.id)
			end
		end
	end)

	if data.equipped.weapon then
		local item = ItemRegistry.findItemByUid(data.inventory, data.equipped.weapon)
		if item then
			WeaponHandler.equip(player, item.id)
		end
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

	data.currentStamina = stamina[player]
	syncPlayerData:FireClient(player, data)

	local stats = leaderstats[player]
	if stats then
		stats.level.Value = data.rankLevel
		stats.class.Value = data.class
	end
end

return public
