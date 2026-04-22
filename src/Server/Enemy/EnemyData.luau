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
	cooldownReduction: number,
	armorPenetration: number,
}

export type Multipliers = {
	cooldownReductionMultiplier: number,
	reactionTimeMultiplier: number,
	walkspeedMultiplier: number,
	critRateMultiplier: number,
	critDamageMultiplier: number,
	healthMultiplier: number,
	armorMultiplier: number,
	aggroLoseRangeMultiplier: number,
	aggroRangeMultiplier: number,
	attackRangeMultiplier: number,
	dropMultiplier: number,
	armorPenetrationMultiplier: number,
	damageMultiplier: number,
}

export type BaseStats = {
	health: number,
	damage: number,
	walkspeed: number,
	armor: number,
	aggroRange: number,
	aggroLoseRange: number,
	attackRange: number,
	basicAttackCooldown: number,
	cooldownReduction: number,
	critRate: number,
	critDamage: number,
	reactionTime: number,
	armorPenetration: number,
	dropRate: number,
	drops: {},
}

-- every enemy will have a type
public.type = {
	melee = {
		cooldownReductionMultiplier = 1,
		reactionTimeMultiplier = 1,
		walkspeedMultiplier = 1.2,
		critRateMultiplier = 1,
		critDamageMultiplier = 1,
		healthMultiplier = 1.2,
		armorMultiplier = 1.1,
		attackRangeMultiplier = 1,
		aggroLoseRangeMultiplier = 1,
		aggroRangeMultiplier = 1,
		dropMultiplier = 1,
		armorPenetrationMultiplier = 1,
		damageMultiplier = 1,
	},
	ranged = {
		cooldownReductionMultiplier = 1,
		reactionTimeMultiplier = 1.1,
		walkspeedMultiplier = 0.9,
		critRateMultiplier = 1.1,
		critDamageMultiplier = 1.2,
		healthMultiplier = 1,
		armorMultiplier = 1,
		attackRangeMultiplier = 1.5,
		aggroLoseRangeMultiplier = 2,
		aggroRangeMultiplier = 2,
		dropMultiplier = 1,
		armorPenetrationMultiplier = 1.2,
		damageMultiplier = 0.9,
	},
	elemental = {
		cooldownReductionMultiplier = 1.2,
		reactionTimeMultiplier = 1,
		walkspeedMultiplier = 0.9,
		critRateMultiplier = 1,
		critDamageMultiplier = 1,
		healthMultiplier = 1.1,
		armorMultiplier = 1,
		attackRangeMultiplier = 1.3,
		aggroLoseRangeMultiplier = 1.2,
		aggroRangeMultiplier = 1.2,
		dropMultiplier = 1,
		armorPenetrationMultiplier = 1.1,
		damageMultiplier = 0.95,
	},
	explosive = {
		cooldownReductionMultiplier = 1,
		reactionTimeMultiplier = 1.3,
		walkspeedMultiplier = 1.3,
		critRateMultiplier = 1.2,
		critDamageMultiplier = 1.2,
		healthMultiplier = 1,
		armorMultiplier = 1,
		attackRangeMultiplier = 1.2, -- blast radius
		aggroLoseRangeMultiplier = 1.1,
		aggroRangeMultiplier = 1.5,
		dropMultiplier = 1,
		armorPenetrationMultiplier = 1.5,
		damageMultiplier = 1.2,
	},
}

-- there is a chance for enemies to get a supType
public.subtype = {
	armored = {
		cooldownReductionMultiplier = 1,
		reactionTimeMultiplier = 1,
		walkspeedMultiplier = 0.95,
		critRateMultiplier = 1,
		critDamageMultiplier = 1,
		healthMultiplier = 1.1,
		armorMultiplier = 1.5,
		attackRangeMultiplier = 1,
		aggroLoseRangeMultiplier = 1,
		aggroRangeMultiplier = 1,
		dropMultiplier = 1.1,
		armorPenetrationMultiplier = 1,
		damageMultiplier = 1.1,
	},
	elite = {
		cooldownReductionMultiplier = 1.1,
		reactionTimeMultiplier = 1.1,
		walkspeedMultiplier = 1.05,
		critRateMultiplier = 1.2,
		critDamageMultiplier = 1.2,
		healthMultiplier = 1.3,
		armorMultiplier = 1.4,
		attackRangeMultiplier = 1.05,
		aggroLoseRangeMultiplier = 1.05,
		aggroRangeMultiplier = 1.05,
		dropMultiplier = 1.2,
		armorPenetrationMultiplier = 1.2,
		damageMultiplier = 1.2,
	},
	miniBoss = {
		cooldownReductionMultiplier = 1.2,
		reactionTimeMultiplier = 1.2,
		walkspeedMultiplier = 1.1,
		critRateMultiplier = 1.25,
		critDamageMultiplier = 1.3,
		healthMultiplier = 1.5,
		armorMultiplier = 1.6,
		attackRangeMultiplier = 1.1,
		aggroLoseRangeMultiplier = 1.1,
		aggroRangeMultiplier = 1.1,
		dropMultiplier = 1.5,
		armorPenetrationMultiplier = 1.3,
		damageMultiplier = 1.4,
	},
}

-- base enemy enemyStats
public.enemyLevel = {
	starter = {
		health = 100,
		aggroRange = 20,
		aggroLoseRange = 40,
		damage = 10,
		critRate = 0.05, -- 5%
		critDamage = 1.2, -- 120%
		basicAttackCooldown = 5,
		cooldownReduction = 4,
		walkspeed = 12,
		armor = 10,
		reactionTime = 0.1,
		attackRange = 8,
		armorPenetration = 10,
		dropRate = 1,
		doubleSubtypeChance = 0,
		drops = { -- drops may vary depending on the type
			"coins",
			"gems",
			"common loot",
		},
	},
}

public.spawnTable = {
	starter = {
		{ type = "melee", weight = 70 },
		{ type = "ranged", weight = 30 },
	},
}

public.subtypeChance = {
	armored = 0.1, -- 10% chance
	elite = 0.05,
	miniBoss = 0.012,
}

function public.getStats(level: string, type: string, subtypes: { string }): {}
	local base = public.enemyLevel[level]
	local typeMultiplier = public.type[type]

	if not base or not typeMultiplier then
		warn("Invalid level or type: " .. tostring(level) .. ", " .. tostring(type))
		return base
	end

	local enemyStats = {
		health = base.health * typeMultiplier.healthMultiplier,
		damage = base.damage * typeMultiplier.damageMultiplier,
		walkspeed = base.walkspeed * typeMultiplier.walkspeedMultiplier,
		armor = base.armor * typeMultiplier.armorMultiplier,
		aggroRange = base.aggroRange * typeMultiplier.aggroRangeMultiplier,
		aggroLoseRange = base.aggroLoseRange * typeMultiplier.aggroLoseRangeMultiplier,
		attackRange = base.attackRange * typeMultiplier.attackRangeMultiplier,
		cooldownReduction = base.cooldownReduction * typeMultiplier.cooldownReductionMultiplier,
		critRate = base.critRate * typeMultiplier.critRateMultiplier,
		critDamage = base.critDamage * typeMultiplier.critDamageMultiplier,
		reactionTime = base.reactionTime * typeMultiplier.reactionTimeMultiplier,
		armorPenetration = base.armorPenetration * typeMultiplier.armorPenetrationMultiplier,
		dropRate = base.dropRate * typeMultiplier.dropMultiplier,
	}

	if not subtypes then
		return enemyStats
	end

	for _, subtype in subtypes do
		local subtypeMultiplier = public.subtype[subtype]
		if not subtypeMultiplier then
			continue
		end

		enemyStats.health = enemyStats.health * subtypeMultiplier.healthMultiplier
		enemyStats.damage = enemyStats.damage * subtypeMultiplier.damageMultiplier
		enemyStats.walkspeed = enemyStats.walkspeed * subtypeMultiplier.walkspeedMultiplier
		enemyStats.armor = enemyStats.armor * subtypeMultiplier.armorMultiplier
		enemyStats.aggroRange = enemyStats.aggroRange * subtypeMultiplier.aggroRangeMultiplier
		enemyStats.aggroLoseRange = enemyStats.aggroLoseRange * subtypeMultiplier.aggroLoseRangeMultiplier
		enemyStats.attackRange = enemyStats.attackRange * subtypeMultiplier.attackRangeMultiplier
		enemyStats.cooldownReduction = enemyStats.cooldownReduction * subtypeMultiplier.cooldownReductionMultiplier
		enemyStats.critRate = enemyStats.critRate * subtypeMultiplier.critRateMultiplier
		enemyStats.critDamage = enemyStats.critDamage * subtypeMultiplier.critDamageMultiplier
		enemyStats.reactionTime = enemyStats.reactionTime * subtypeMultiplier.reactionTimeMultiplier
		enemyStats.armorPenetration = enemyStats.armorPenetration * subtypeMultiplier.armorPenetrationMultiplier
		enemyStats.dropRate = enemyStats.dropRate * subtypeMultiplier.dropMultiplier
	end

	local effectiveCooldown = base.basicAttackCooldown * (1 - enemyStats.cooldownReduction / 100)
	enemyStats.basicAttackCooldown = math.max(effectiveCooldown, 0.5)

	return enemyStats
end

return public
