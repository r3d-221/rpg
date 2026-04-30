return {
	id = "iron_knife",
	subCategory = "knife",
	baseDamage = 10,
	baseAttackSpeed = 1.1,
	baseArmorPenetration = 3,
	baseCritRate = 0.02,
	baseCritDamage = 1.1,
	passives = { "none" },
	abilities = {
		{ name = "slice", cooldown = 4, damageMultiplier = 1.3 },
		{ name = "backStab", cooldown = 8, damageMultiplier = 1.4, critRateMultiplier = 1.05 },
	},
}
