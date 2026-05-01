local public = {}

public.rarityTiers = {
	"common",
	"uncommon",
	"rare",
	"epic",
	"legendary",
	"mythic",
	"secret",
}

-- the higher the index, the higher the rarity
public.statRank = {
	S = 1.2, -- 20%
	A = 1.15,
	B = 1.1,
	C = 1.05,
	D = 1,
}

public.statRankWeights = {
	S = 0.05,
	A = 0.10,
	B = 0.20,
	C = 0.30,
	D = 0.35,
}

public.rarityWeights = {
	common = 0.50,
	uncommon = 0.25,
	rare = 0.13,
	epic = 0.07,
	legendary = 0.03,
	mythic = 0.015,
	secret = 0.005,
}

public.itemList = {
	---- Weapons Category ----
	weapons = {
		sword = { -- sub category
			{ id = "wooden_sword", rarity = "common" },
			{ id = "iron_sword", rarity = "common" },
			{ id = "steel_sword", rarity = "uncommon" },
		},
		knife = {
			{ id = "rusty_knife", rarity = "common" },
			{ id = "iron_knife", rarity = "common" },
		},
		longBow = {
			{ id = "long_bow", rarity = "common" },
		},
		shortBow = {
			{ id = "short_bow", rarity = "common" },
		},
	},

	---- Armors Category ----
	armors = {
		heavySet = {
			{ id = "iron_chestplate", rarity = "common" },
			{ id = "iron_leggings", rarity = "common" },
			{ id = "iron_boots", rarity = "common" },
			{ id = "iron_helmet", rarity = "common" },
		},
		lightSet = {
			{ id = "leather_vest", rarity = "common" },
			{ id = "leather_leggings", rarity = "common" },
			{ id = "leather_boots", rarity = "common" },
			{ id = "leather_cap", rarity = "common" },
		},
	},

	---- crafting Ingredients Category ----
	materials = {
		{ id = "bone_fragment", rarity = "common", quantity = { min = 1, max = 3 } },
		{ id = "torn_cloth", rarity = "common", quantity = { min = 1, max = 2 } },
		{ id = "iron_shard", rarity = "uncommon", quantity = { min = 1, max = 2 } },
	},
	artifacts = {},
}

public.items = {
	starter = {
		canDropMultiple = false, -- makes it so that enemies will have a chance to drop 2 or more pieces of armor, weapon or artifect; influenced by luck
		melee = {
			weapons = {
				chance = 0.02,
				levelRange = { min = 1, max = 5 },
				rarityRange = { min = "common", max = "uncommon" },
				weaponType = { sword = 0.3, knife = 0.7 },
			},
			armors = {
				chance = 0.025,
				levelRange = { min = 1, max = 5 },
				rarityRange = { min = "common", max = "common" },
				armorType = { heavySet = 0.3, lightSet = 0.7 },
			},
			artifacts = nil,
			materials = {
				chance = 0.50,
				rarityRange = { min = "common", max = "common" },
				quantity = { min = 1, max = 3 },
			},
		},
		ranged = {
			weapons = {
				chance = 0.02,
				levelRange = { min = 1, max = 5 },
				rarityRange = { min = "common", max = "uncommon" },
				weaponType = { longBow = 0.3, shortBow = 0.7 },
			},
			armors = {
				chance = 0.025,
				levelRange = { min = 1, max = 5 },
				rarityRange = { min = "common", max = "common" },
				armorType = { heavySet = 0.2, lightSet = 0.8 },
			},
			artifacts = nil,
			materials = {
				chance = 0.50,
				rarityRange = { min = "common", max = "common" },
				quantity = { min = 1, max = 3 },
			},
		},
	},
}

public.currency = {
	starter = {
		{ id = "coins", chance = 1.0, min = 5, max = 15 },
		{ id = "gems", chance = 0.1, min = 1, max = 3 },
		{ id = "exp", chance = 1.0, min = 10, max = 20 },
	},
}

return public
