local public = {}

public.baseStats = {
	warrior = {
		luck = 0,
		health = 100,
		damage = 0,
		critRate = 0.05,
		critDamage = 1.2,
		walkspeed = 16,
		armor = 0,
		attackSpeed = 0,
		armorPierce = 0,
		cooldownReduction = 0,
	},
	archer = {
		luck = 0,
		health = 80,
		damage = 0,
		critRate = 0.05,
		critDamage = 1.5,
		walkspeed = 18,
		armor = 0,
		attackSpeed = 0,
		armorPierce = 0,
		cooldownReduction = 0,
	},
	mage = {
		luck = 0,
		health = 100,
		damage = 0,
		critRate = 0.05,
		critDamage = 1.3,
		walkspeed = 16,
		armor = 0,
		attackSpeed = 0,
		armorPierce = 10,
		cooldownReduction = 0,
	},
	paladin = {
		luck = 0,
		health = 140,
		damage = 0,
		critRate = 0.05,
		critDamage = 1.2,
		walkspeed = 12,
		armor = 5,
		attackSpeed = 0,
		armorPierce = 0,
		cooldownReduction = 0,
	},
	-- berserker = {},
	-- necromencer = {},
	-- assassin = {},
	-- grandPrist = {},
	-- deadEye = {},
	-- duelist = {},
	-- dragonborn = {},
	-- shadow = {},
	-- samurai = {},
}

public.filter = {
	warrior = {
		armors = { "ironSet", "steelSet" },
		weapons = { "sword" },
	},
	archer = {
		armors = { "leatherSet" },
		weapons = { "bow", "crossbow" },
	},
	mage = {
		armors = { "blueStringSet" },
		weapons = { "staff", "wand" },
	},
	paladin = {
		armors = { "ironSet", "steelSet" },
		weapons = { "greatSword" },
	},
}

public.defaultDrops = {
	armors = {
		warrior = "ironSet",
		archer = "leatherSet",
		mage = "blueStringSet",
		paladin = "ironSet",
	},
	weapons = {
		warrior = "iron_sword",
		archer = "long_bow",
		mage = "",
		paladin = "",
	},
	artifects = {},
}

return public
