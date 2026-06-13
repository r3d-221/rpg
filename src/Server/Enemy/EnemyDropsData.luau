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

public.items = {
	starter = {
		canDropMultiple = false, -- makes it so that enemies will have a chance to drop 2 or more pieces of armor, weapon or artifect; influenced by luck
		melee = {
			weapons = {
				chance = 0.02,
				levelRange = { min = 1, max = 5 },
				rarityRange = { min = "common", max = "uncommon" },
				weaponType = { sword = 0.3, dagger = 0.7 },
			},
			armors = {
				chance = 0.025,
				levelRange = { min = 1, max = 5 },
				rarityRange = { min = "common", max = "common" },
				armorType = { heavy = 0.3, light = 0.7 },
			},
			artifacts = nil,
			materials = {
				chance = 0.50,
				rarityRange = { min = "common", max = "common" },
				quantity = { min = 1, max = 3 },
				materialType = { mob = 0.6, ore = 0.2, fabric = 0.2 },
			},
		},
		ranged = {
			weapons = {
				chance = 0.02,
				levelRange = { min = 1, max = 5 },
				rarityRange = { min = "common", max = "uncommon" },
				weaponType = { bow = 1 },
			},
			armors = {
				chance = 0.025,
				levelRange = { min = 1, max = 5 },
				rarityRange = { min = "common", max = "common" },
				armorType = { heavy = 0.2, light = 0.8 },
			},
			artifacts = nil,
			materials = {
				chance = 0.50,
				rarityRange = { min = "common", max = "common" },
				quantity = { min = 1, max = 3 },
				materialType = { mob = 0.6, ore = 0.2, fabric = 0.2 },
			},
		},
	},
}

public.currency = {
	starter = {
		{ id = "coins", chance = 1.0, min = 5, max = 15 },
		{ id = "gems", chance = 0.1, min = 1, max = 3 },
		{ id = "classExp", chance = 1.0, min = 10, max = 20 },
	},
}

return public
