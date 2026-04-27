local public = {}

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
	minimumLevelRange: number,
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
	level: number,
	levelRange: {},
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
		minimumLevelRange = 1,
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
		minimumLevelRange = 1,
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
		minimumLevelRange = 1,
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
		minimumLevelRange = 1,
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
		minimumLevelRange = 5,
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
		minimumLevelRange = 8,
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
		minimumLevelRange = 12,
	},
}

-- base enemy enemyStats
public.enemyDifficultyLevel = {
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
		level = 1,
		levelRange = { 1, 15 },
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

function public.getLevel(difficultyLevel: string, subtypes: { string }): number
	local area = public.enemyDifficultyLevel[difficultyLevel]
	if not area then
		return 1
	end

	local min = area.levelRange[1]
	local max = area.levelRange[2]

	local subtypeMin = min
	for _, subtypeName in subtypes do
		local subtype = public.subtype[subtypeName]
		if subtype and subtype.minimumLevelRange > subtypeMin then
			subtypeMin = subtype.minimumLevelRange
		end
	end

	if #subtypes > 1 then
		subtypeMin = math.min(subtypeMin + 3, max)
	end

	if subtypeMin > max then
		return max
	end

	local effectiveMin = math.max(min, subtypeMin)

	local roll1 = math.random(effectiveMin, max)
	local roll2 = math.random(effectiveMin, max)
	local roll3 = math.random(effectiveMin, max)

	-- takes the lowest two rolls
	local sorted = { roll1, roll2, roll3 }
	table.sort(sorted)
	return math.floor((sorted[1] + sorted[2]) / 2)
end

function public.getStats(difficultyLevel: string, type: string, subtypes: { string }, level: number): {}
	local base = public.enemyDifficultyLevel[difficultyLevel]
	local typeMultiplier = public.type[type]

	if not base or not typeMultiplier then
		warn("Invalid difficultyLevel or type: " .. tostring(difficultyLevel) .. ", " .. tostring(type))
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

	local levelScale = 1 + (level - 1) * 0.08 -- 8% increase per level
	enemyStats.health = enemyStats.health * levelScale
	enemyStats.damage = enemyStats.damage * levelScale
	enemyStats.armor = enemyStats.armor * levelScale
	enemyStats.armorPenetration = enemyStats.armorPenetration * levelScale
	enemyStats.dropRate = enemyStats.dropRate * (1 + (level - 1) * 0.02) -- 2% per level

	enemyStats.level = level

	local effectiveCooldown = base.basicAttackCooldown * (1 - enemyStats.cooldownReduction / 100)
	enemyStats.basicAttackCooldown = math.max(effectiveCooldown, 0.5)

	return enemyStats
end

return public
