local private = {}
local public = {}

export type Enemy = {
	originalPosition: Vector3,
	luckMultiplier: number,
	snappingOffset: number, -- the offset RADIUS from the humanoidRootPart to which the player will snap to
	moveSpeed: number,
	health: number,
	rarity: number,
	xpDrop: number,
	armor: number,
	area: BasePart, -- maybe need to change later
	drops: {
		currency: number,
		common: {},
		rare: {},
		epic: {},
		legendary: {},
		mythic: {},
		secret: {}
	}
}

local starterEnemies: {Enemy} = {
	normalEnemy = {
		originalPosition = Vector3.new(0, 0, 0),
		luckMultiplier = 1,
		areaTag = "starter",
		moveSpeed = 10,
		health = 100,
		rarity = 1,
		xpDrop = 10,
		armor = 0,
		drops = {
			currency = 10,
			common = {"common weapon drop"},
			rare = {"rare weapon drop"},
			epic=  {"epic weapon drop"},
			legendary = {"legendary weapon drop"},
		}
	},
	rareEnemy = {
		originalPosition = Vector3.new(0, 0, 0),
		luckMultiplier = 1.2,
		areaTag = "starter",
		moveSpeed = 20,
		health = 150,
		rarity = 2,
		xpDrop = 22,
		armor = 10,
		drops = {
			currency = 20,
			common = {"common weapon drop"},
			rare = {"rare weapon drop"},
			epic=  {"epic weapon drop"},
			legendary = {"legendary weapon drop"},
		}
	}
}

local bossEnemies = {
	firstBoss = {}
}

public.starterEnemies = starterEnemies
public.bossEnemies = bossEnemies

return public
