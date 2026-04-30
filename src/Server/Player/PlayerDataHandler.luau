local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ProfileStore = require(ServerScriptService.ServerPackages.ProfileStore)

local Remotes = ReplicatedStorage.Shared.Remotes
local syncPlayerData = Remotes.syncPlayerData

local PROFILE_STORE_KEY = "test_v2"

local STACK_CAP = 100
local DEFAULT_PLAYER_DATA = {
	level = 1,

	stats = {
		luck = 0,
		health = 100,
		damage = 0,
		critRate = 0,
		critDamage = 1.2,
		walkspeed = 0,
		armor = 0,
		attackSpeed = 0,
		armorPenetration = 0,
		cooldownReduction = 0,
	},

	statPoints = {
		health = 0,
		damage = 0,
		armor = 0,
		critRate = 0,
		critDamage = 0,
	},

	currency = {
		coins = 0,
		gems = 0,
		exp = 0,
	},

	inventory = {
		craftingIngredients = {},
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
		craftingIngredients = 20,
	},
}

local store = ProfileStore.New(PROFILE_STORE_KEY, DEFAULT_PLAYER_DATA)
local profiles = {} -- key: player; value: profile

local private = {}
local public = {}

function public.onStart()
	Players.PlayerAdded:Connect(private.onPlayerAdded)
	Players.PlayerRemoving:Connect(private.onPlayerRemoved)

	for _, player in Players:GetPlayers() do
		task.spawn(private.onPlayerAdded, player)
	end
end

function public.getProfile(player: Player)
	return profiles[player]
end

function public.getData(player: Player)
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
	private.sync(player)
	print(data)
end

-- Example: item = { id = item.id, category = "weapons", rarity = rarity, level = level }
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

	if category == "craftingIngredients" then
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
	print(data.storageSlots)
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

	player.AncestryChanged:Connect(function()
		if not player:IsDescendantOf(Players) then
			private.onPlayerRemoved(player)
		end
	end)

	private.sync(player)
end

function private.onPlayerRemoved(player: Player)
	local profile = profiles[player]
	if profile then
		profile:EndSession()
		profiles[player] = nil
	end
end

function private.sync(player: Player)
	local data = public.getData(player)
	if data then
		syncPlayerData:FireClient(player, data)
	end
end

return public
