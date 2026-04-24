local public = {}

export type stats = {
	health: number,
	damage: number,
	walkspeed: number,
	armor: number,
	cooldownReduction: number,
	critRate: number,
	critDamage: number,
	armorPenetration: number,
}

public.baseStats = {
	health = 100,
	damage = 5,
	walkspeed = 16,
	armor = 10,
	cooldownReduction = 0, -- 0%
	critRate = 0.05, -- 5%
	critDamage = 1.2, -- 120%
	armorPenetration = 5,
}

public.statPoints = {
	health = 0, -- 1 point worth ? multiplier. Not a linear multiplier
	damage = 0,
	armor = 0,
	critRate = 0,
	critDamage = 0,
}

function public.getPlayerStats() end

return public
