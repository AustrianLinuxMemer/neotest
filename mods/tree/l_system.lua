--[[
	This is the Lua file defining standardized L-System tree templates to be used by the `tree` mod
]]

trees = {
	indices = {
		[1] = "oak_large",
		[2] = "oak_medium"
	},
	["oak_large"] = {
		axiom = "FFFACB",
		rules_a = "F[+FFFf][-FFFf]",
		rules_b = "F[&FFFf][^^FFFf]",
		rules_c = "F[//FFFFf][**FFFFf]",
		trunk="tree:oak_log",
		leaves="tree:oak_leaves",
		angle=30,
		iterations=2,
		random_level=0,
		trunk_type="single",
		thin_branches=true
	},
	["oak_medium"] = {
		axiom = "FFFACB",
		rules_a = "F[+FFFf][-FFFf]",
		rules_b = "F[&FFFf][^^FFFf]",
		rules_c = "F[//FFFFf][**FFFFf]",
		trunk="tree:oak_log",
		leaves="tree:oak_leaves",
		angle=30,
		iterations=2,
		random_level=0,
		trunk_type="single",
		thin_branches=true
	}
}