return {
	expToLevel = function(level: number): number
		-- level 1 = 100, level 2 = 283, level 3 = 520, etc.
		return math.floor(100 * (level ^ 1.5))
	end,

	formatNumber = function(n: number): string
		n = math.floor(n)
		if n >= 1_000_000_000 then
			return string.format("%.1fB", n / 1_000_000_000)
		elseif n >= 1_000_000 then
			return string.format("%.1fM", n / 1_000_000)
		elseif n >= 1_000 then
			return string.format("%.1fK", n / 1_000)
		end
		return tostring(n)
	end,
}
