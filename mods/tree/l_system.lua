--[[
	This is the Lua file defining standardized L-System tree templates to be used by the `tree` mod
]]

local trees = {
	["oak"] = {
		indices = {
			[1] = "large",
			[2] = "medium"
		},
		["large"] = {
			axiom = "FFFACB",
			rules_a = "F[+FFFf][-FFFf]",
			rules_b = "F[&FFFf][^^FFFf]",
			rules_c = "F[++FFFFf][--FFFFf]",
			trunk="tree:oak_log",
			leaves="tree:oak_leaves",
			angle=30,
			iterations=2,
			random_level=0,
			trunk_type="single",
			thin_branches=true
		},
		["medium"] = {
			axiom = "FFFACB",
			rules_a = "F[+FFFf][-FFFf]",
			rules_b = "F[&FFFf][^^FFFf]",
			rules_c = "F[++FFFFf][--FFFFf]",
			trunk="tree:oak_log",
			leaves="tree:oak_leaves",
			angle=30,
			iterations=2,
			random_level=0,
			trunk_type="single",
			thin_branches=true
		}
	},
}
function trees.place_ltree(center_pos, ltree, tree_type)
	-- Dimension check comes later
    core.set_node(center_pos, {name = "tree:"..tree_type.."_log"})
	core.spawn_tree(center_pos, ltree)
end
core.register_decoration({
	deco_type = "lsystem",
	fill_ratio = 0.0004,
	biomes = {"biomes:temperate"},
	place_on = {"geology:grass_block", "geology:dirt"},
	treedef = trees.oak.large,
	y_min = 2
})
core.register_decoration({
	deco_type = "lsystem",
	fill_ratio = 0.0004,
	biomes = {"biomes:temperate"},
	place_on = {"geology:grass_block", "geology:dirt"},
	treedef = trees.oak.medium,
	y_min = 2
})
core.register_decoration({
	deco_type = "lsystem",
	fill_ratio = 0.005,
	biomes = {"biomes:temperate_forest"},
	place_on = {"geology:grass_block", "geology:dirt"},
	treedef = trees.oak.large,
	y_min = 2
})
core.register_decoration({
	deco_type = "lsystem",
	fill_ratio = 0.005,
	biomes = {"biomes:temperate_forest"},
	place_on = {"geology:grass_block", "geology:dirt"},
	treedef = trees.oak.medium,
	y_min = 2
})
return trees