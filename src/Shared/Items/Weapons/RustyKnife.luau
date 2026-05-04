return {
	id = "rusty_knife",
	name = "Rusty Knife",
	category = "weapons",
	subCategory = "knife",
	rarity = "common",

	baseDamage = 12,
	baseAttackSpeed = 1.0,
	baseArmorPenetration = 5,
	baseCritRate = 0.02,
	baseCritDamage = 1.1,

	description = "A rusty knife.",
	passives = {},

	abilities = {
		{ name = "slice", cooldown = 4, damageMultiplier = 1.3 },
		{ name = "backStab", cooldown = 8, damageMultiplier = 1.4, critRateMultiplier = 1.05 },
	},
}
