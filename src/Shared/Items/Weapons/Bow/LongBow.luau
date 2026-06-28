return {
	id = "long_bow",
	name = "Long Bow",
	category = "weapons",
	subCategory = "bow",
	rarity = "common",
	level = 1,
	uid = nil,

	baseDamage = 12,
	baseAttackSpeed = 1.0,
	baseArmorPierce = 5,
	baseCritRate = 0.02,
	baseCritDamage = 0.1,

	description = "A basic iron sword.",
	passives = {},
	stats = {},
	rolls = {},

	abilities = {
		{ name = "slash", cooldown = 4, damageMultiplier = 1.3 },
		{ name = "barrage", cooldown = 8, damageMultiplier = 1.4 },
	},
}
