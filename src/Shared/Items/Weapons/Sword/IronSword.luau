return {
	id = "iron_sword", -- type ID
	name = "Iron Sword", -- for UI only
	category = "weapons",
	subCategory = "sword",
	rarity = "common",
	level = 1,
	energy = 5,
	uid = nil, -- instance ID

	baseDamage = 12,
	baseAttackSpeed = 1.0,
	baseArmorPierce = 5,
	baseCritRate = 0.02,
	baseCritDamage = 0.1,

	description = "A basic iron sword.",
	attackType = "light",
	passives = {},
	stats = {},
	rolls = {},
	combo = {},

	abilities = {
		{ name = "slash", cooldown = 4, damageMultiplier = 1.3, energy = 15 },
		{ name = "barrage", cooldown = 8, damageMultiplier = 1.4, energy = 20 },
	},
}
