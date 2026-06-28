return {
	id = "iron_knife",
	name = "Iron Knife",
	category = "weapons",
	subCategory = "dagger",
	rarity = "common",
	level = 1,
	uid = nil,

	baseDamage = 10,
	baseAttackSpeed = 1.1,
	baseArmorPierce = 3,
	baseCritRate = 0.02,
	baseCritDamage = 0.1,

	description = "A basic iron knife.",
	passives = {},
	stats = {},
	rolls = {},

	abilities = {
		{ name = "slice", cooldown = 4, damageMultiplier = 1.3 },
		{ name = "backStab", cooldown = 8, damageMultiplier = 1.4, critRateMultiplier = 1.05 },
	},
}
