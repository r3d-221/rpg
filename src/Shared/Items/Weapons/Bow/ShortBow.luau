return {
	id = "short_bow",
	name = "Short Bow",
	category = "weapons",
	subCategory = "bow",
	rarity = "common",
	level = 1,

	baseDamage = 12,
	baseAttackSpeed = 1.0,
	baseArmorPenetration = 5,
	baseCritRate = 0.02,
	baseCritDamage = 1.1,

	description = "A basic iron sword.",
	passives = {},
	stats = {},
	rolls = {},

	abilities = {
		{ name = "slash", cooldown = 4, damageMultiplier = 1.3 },
		{ name = "barrage", cooldown = 8, damageMultiplier = 1.4 },
	},
}
