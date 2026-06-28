return {
	id = "steel_sword",
	name = "Steel Sword",
	category = "weapons",
	subCategory = "sword",
	rarity = "rare",
	level = 1,
	uid = nil,

	baseDamage = 12,
	baseAttackSpeed = 1.0,
	baseArmorPierce = 5,
	baseCritRate = 0.02,
	baseCritDamage = 0.1,

	description = "A basic steel sword.",
	passives = {},
	stats = {},
	rolls = {},

	abilities = {
		{ name = "slash", cooldown = 4, damageMultiplier = 1.3 },
		{ name = "barrage", cooldown = 8, damageMultiplier = 1.4 },
	},
}
