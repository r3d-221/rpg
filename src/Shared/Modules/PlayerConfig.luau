return {
	expToLevel = function(level: number): number
		-- level 1 = 100, level 2 = 283, level 3 = 520, etc.
		return math.floor(100 * (level ^ 1.5))
	end,
}
