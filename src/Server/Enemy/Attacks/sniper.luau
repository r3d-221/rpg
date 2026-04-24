return {
	basicAttack = {
		name = "basicAttack",
		damageMultiplier = 1,
		windUp = 0.4,
		active = 0.15,
		recovery = 0.6,
		animationId = "rbxassetid://111111",
		hitbox = { type = "raycast", range = 10 },
	},
	abilities = {
		{
			name = "snipeShot",
			damageMultiplier = 1.4,
			cooldown = 5,
			weight = 70,
			windUp = 0.5,
			active = 0.2,
			recovery = 0.8,
			animationId = "rbxassetid://123456",
			hitbox = { type = "raycast", range = 15 },
			modifiers = {
				guaranteedCrit = true,
			},
		},
		{
			name = "neverMissShot",
			damageMultiplier = 1.8,
			cooldown = 7,
			weight = 30,
			windUp = 1.2,
			active = 0.3,
			recovery = 1.4,
			animationId = "rbxassetid://654321",
			hitbox = { type = "raycast", range = 20 },
			modifiers = {
				ignoreAttackRange = true,
			},
		},
	},
}
