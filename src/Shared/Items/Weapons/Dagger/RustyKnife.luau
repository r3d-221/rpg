return {
	id = "rusty_knife",
	name = "Rusty Knife",
	category = "weapons",
	subCategory = "dagger",
	rarity = "common",
	level = 1,

	baseDamage = 12,
	baseAttackSpeed = 1.0,
	baseArmorPierce = 5,
	baseCritRate = 0.02,
	baseCritDamage = 1.1,

	description = "A rusty knife.",
	passives = {},
	stats = {},
	rolls = {},

	abilities = {
		{ name = "slice", cooldown = 4, damageMultiplier = 1.3 },
		{ name = "backStab", cooldown = 8, damageMultiplier = 1.4, critRateMultiplier = 1.05 },
	},
}
