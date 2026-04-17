local public = {}

export type attributes = {
	type: {},
	drops: {},
	health: number,
	walkspeed: number,
	aggroRange: number,
	aggroLoseRange: number,
	damage: number,
	attackRange: number,
	armor: number,
	reactionTime: number,
	critRate: number,
	critDamage: number,
	attackCooldown: number,
}

export type Multipliers = {
	cooldownReductionMulti: number,
	reactionTimeMulti: number,
	walkspeedMulti: number,
	critRateMulti: number,
	critDamageMulti: number,
	healthMulti: number,
	armorMulti: number,
	aggroLoseRangeMulti: number,
	aggroRangeMulti: number,
	attackRangeMulti: number,
	dropMulti: number,
}

export type BaseStats = {
	health: number,
	aggroRange: number,
	aggroLoseRange: number,
	damage: number,
	critRate: number,
	critDamage: number,
	attackCooldown: number,
	walkspeed: number,
	armor: number,
	reactionTime: number,
	attackRange: number,
	drops: {},
}

-- every enemy will have a type
public.type = {
	melee = {
		cooldownReductionMulti = 1,
		reactionTimeMulti = 1,
		walkspeedMulti = 1.2,
		critRateMulti = 1,
		critDamageMulti = 1,
		healthMulti = 1.2,
		armorMulti = 1.1,
		attackRangeMulti = 1,
		aggroLoseRangeMulti = 1,
		aggroRangeMulti = 1,
		dropMulti = 1,
	},
	ranged = {
		cooldownReductionMulti = 1,
		reactionTimeMulti = 1.1,
		walkspeedMulti = 0.9,
		critRateMulti = 1.1,
		critDamageMulti = 1.2,
		healthMulti = 1,
		armorMulti = 1,
		attackRangeMulti = 1.5,
		aggroLoseRangeMulti = 2,
		aggroRangeMulti = 2,
		dropMulti = 1,
	},
	elemental = {
		cooldownReductionMulti = 1.2,
		reactionTimeMulti = 1,
		walkspeedMulti = 0.9,
		critRateMulti = 1,
		critDamageMulti = 1,
		healthMulti = 1.1,
		armorMulti = 1,
		attackRangeMulti = 1.3,
		aggroLoseRangeMulti = 1.2,
		aggroRangeMulti = 1.2,
		dropMulti = 1,
	},
	explosive = {
		cooldownReductionMulti = 1,
		reactionTimeMulti = 1.3,
		walkspeedMulti = 1.3,
		critRateMulti = 1.2,
		critDamageMulti = 1.2,
		healthMulti = 1,
		armorMulti = 1,
		attackRangeMulti = 1.2, -- blast radius
		aggroLoseRangeMulti = 1.1,
		aggroRangeMulti = 1.5,
		dropMulti = 1,
	},
}

-- there is a chance for enemies to get a supType
public.subtype = {
	armored = {
		cooldownReductionMulti = 1,
		reactionTimeMulti = 1,
		walkspeedMulti = 0.95,
		critRateMulti = 1,
		critDamageMulti = 1,
		healthMulti = 1.1,
		armorMulti = 1.5,
		attackRangeMulti = 1,
		aggroLoseRangeMulti = 1,
		aggroRangeMulti = 1,
		dropMulti = 1.1,
	},
	elite = {
		cooldownReductionMulti = 1.1,
		reactionTimeMulti = 1.1,
		walkspeedMulti = 1,
		critRateMulti = 1.2,
		critDamageMulti = 1.2,
		healthMulti = 1.3,
		armorMulti = 1.4,
		attackRangeMulti = 1.05,
		aggroLoseRangeMulti = 1.05,
		aggroRangeMulti = 1.05,
		dropMulti = 1.2,
	},
	miniBoss = {
		cooldownReductionMulti = 1.2,
		reactionTimeMulti = 1.2,
		walkspeedMulti = 1.1,
		critRateMulti = 1.25,
		critDamageMulti = 1.3,
		healthMulti = 1.5,
		armorMulti = 1.6,
		attackRangeMulti = 1.1,
		aggroLoseRangeMulti = 1.1,
		aggroRangeMulti = 1.1,
		dropMulti = 1.5,
	},
}

-- base enemy stats
public.enemyLevel = {
	starter = {
		health = 100,
		aggroRange = 20,
		damage = 10,
		critRate = 0.05, -- 5%
		critDamage = 1.2, -- 120%
		attackCooldown = 5,
		walkspeed = 12,
		armor = 10,
		drops = { -- drops may vary depending on the type
			"coins",
			"gems",
			"common loot",
		},
		reactionTime = 0.1,
		attackRange = 8,
		aggroloseRange = 40,
	},
}

public.spawnTable = {
	starter = {
		{ type = "melee", weight = 70 },
		{ type = "ranged", weight = 30 },
	},
}

public.subtypeChance = {
	armored = 0.15, -- 15% chance
	elite = 0.08,
	miniBoss = 0.02,
}

return public
