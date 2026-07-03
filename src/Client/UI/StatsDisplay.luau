local public = {}

public.uiNames = {
	health = "health",
	armor = "armor",
	luck = "luck",
	damage = "damage",
	critRate = "crit_rate",
	critDamage = "crit_damage",
	armorPierce = "armor_pierce",
	attackSpeed = "attack_speed",
	cooldownReduction = "cooldown_reduction",
}

public.statPoints = {
	health = "health",
	armor = "armor",
	damage = "damage",
	critRate = "crit_rate",
	critDamage = "crit_damage",
}

public.displayNames = {
	health = "Health",
	armor = "Armor",
	luck = "Luck",
	damage = "Damage",
	critRate = "Crit Rate",
	critDamage = "Crit Damage",
	armorPierce = "Armor Pierce",
	attackSpeed = "Attack Speed",
	cooldownReduction = "Cooldown Reduction",
}

public.statOrder = {
	weapons = { "damage", "critRate", "critDamage", "attackSpeed", "armorPierce" },
	armors = { "health", "armor", "luck", "walkspeed" },
}

public.rankRarity = {
	D = "common",
	C = "rare",
	B = "epic",
	A = "legendary",
	S = "mythic",
}

function public.format(stat: string, value: number): string
	if stat == "critRate" then
		return string.format("%.1f%%", value * 100)
	elseif stat == "critDamage" then
		return string.format("%.0f%%", value * 100)
	else
		return string.format("%.1f", value)
	end
end

return public
