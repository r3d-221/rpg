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
	armorPenetration: number,
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
	armorPenetrationMulti: number,
	damageMulti: number,
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
	armorPenetration: number,
	dropRate: number,
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
		armorPenetrationMulti = 1,
		damageMulti = 1,
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
		armorPenetrationMulti = 1.2,
		damageMulti = 0.9,
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
		armorPenetrationMulti = 1.1,
		damageMulti = 0.95,
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
		armorPenetrationMulti = 1.5,
		damageMulti = 1.2,
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
		armorPenetrationMulti = 1,
		damageMulti = 1.1,
	},
	elite = {
		cooldownReductionMulti = 1.1,
		reactionTimeMulti = 1.1,
		walkspeedMulti = 1.05,
		critRateMulti = 1.2,
		critDamageMulti = 1.2,
		healthMulti = 1.3,
		armorMulti = 1.4,
		attackRangeMulti = 1.05,
		aggroLoseRangeMulti = 1.05,
		aggroRangeMulti = 1.05,
		dropMulti = 1.2,
		armorPenetrationMulti = 1.2,
		damageMulti = 1.2,
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
		armorPenetrationMulti = 1.3,
		damageMulti = 1.4,
	},
}

-- base enemy stats
public.enemyLevel = {
	starter = {
		health = 100,
		aggroRange = 20,
		aggroLoseRange = 40,
		damage = 10,
		critRate = 0.05, -- 5%
		critDamage = 1.2, -- 120%
		attackCooldown = 5,
		walkspeed = 12,
		armor = 10,
		reactionTime = 0.1,
		attackRange = 8,
		armorPenetration = 10,
		dropRate = 1,
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
	armored = 0.15, -- 15% chance
	elite = 0.08,
	miniBoss = 0.02,
}

function public.getStats(level: string, type: string, subtype: string): BaseStats
	local base = public.enemyLevel[level]
	local typeMulti = public.type[type]
	local subTypeMulti = public.subtype[subtype]

	if not base or not typeMulti then
		warn("Invalid level or type: " .. tostring(level) .. ", " .. tostring(type))
		return base
	end

	local enemyStats = {
		health = base.health * typeMulti.healthMulti,
		damage = base.damage * typeMulti.damageMulti,
		walkspeed = base.walkspeed * typeMulti.walkspeedMulti,
		armor = base.armor * typeMulti.armorMulti,
		aggroRange = base.aggroRange * typeMulti.aggroRangeMulti,
		aggroLoseRange = base.aggroLoseRange * typeMulti.aggroLoseRangeMulti,
		attackRange = base.attackRange * typeMulti.attackRangeMulti,
		attackCooldown = base.attackCooldown * typeMulti.cooldownReductionMulti, -- might need to be recalculated
		critRate = base.critRate * typeMulti.critRateMulti,
		critDamage = base.critDamage * typeMulti.critDamageMulti,
		reactionTime = base.reactionTime * typeMulti.reactionTimeMulti,
		armorPenetration = base.armorPenetration * typeMulti.armorPenetrationMulti,
		dropRate = base.dropRate * typeMulti.dropMulti,
	}

	if subTypeMulti then
		for key, mult in pairs({
			health = subTypeMulti.healthMulti,
			damage = subTypeMulti.damageMulti,
			walkspeed = subTypeMulti.walkspeedMulti,
			armor = subTypeMulti.armorMulti,
			aggroRange = subTypeMulti.aggroRangeMulti,
			aggroLoseRange = subTypeMulti.aggroLoseRangeMulti,
			attackRange = subTypeMulti.attackRangeMulti,
			attackCooldown = subTypeMulti.cooldownReductionMulti,
			critRate = subTypeMulti.critRateMulti,
			critDamage = subTypeMulti.critDamageMulti,
			reactionTime = subTypeMulti.reactionTimeMulti,
			armorPenetration = subTypeMulti.armorPenetrationMulti,
			dropRate = subTypeMulti.dropMulti,
		}) do
			if enemyStats[key] then
				enemyStats[key] = enemyStats[key] * mult
			end
		end
	end

	return enemyStats
end

return public
