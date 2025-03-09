core.register_alias("mapgen_stone", "geology:stone")
core.register_alias("mapgen_water_source", "liquids:water_source")
core.register_alias("mapgen_river_water_source", "liquids:river_water_source")
core.register_alias("mapgen_lava_source", "liquids:lava_source")


-- Temperate Biome
core.register_biome({
    name = "temperate",
    node_top = "geology:grass_block",
    depth_top = 1,
    node_filler = "geology:dirt",
    depth_filler = 3,
    heat_point = 50,
    humidity_point = 50
})

-- Temperate Forest Biome
core.register_biome({
    name = "temperate_forest",
    node_top = "geology:grass_block",
    depth_top = 1,
    node_filler = "geology:dirt",
    depth_filler = 3,
    heat_point = 50,
    humidity_point = 50
})

-- Desert biome
core.register_biome({
    name = "desert",
    node_top = "geology:sand",
    depth_top = 3,
    node_filler = "geology:sandstone",
    depth_filler = 25,
    heat_point = 75,
    humidity_point = 25
})

-- Coal
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "geology:coal_ore",
	wherein        = "geology:stone",
	clust_scarcity = 8 * 8 * 18,
	clust_num_ores = 30,
	clust_size     = 5,
	y_max          = 64,
	y_min          = -31000,
})

-- Iron
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "geology:iron_ore",
	wherein        = "default:stone",
	clust_scarcity = 12 * 12 * 12,
	clust_num_ores = 30,
	clust_size     = 5,
	y_max          = 32,
	y_min          = -31000,
})

-- Gold
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "geology:gold_ore",
	wherein        = "default:stone",
	clust_scarcity = 13 * 13 * 13,
	clust_num_ores = 30,
	clust_size     = 5,
	y_max          = -128,
	y_min          = -31000,
})
-- Diamond
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "geology:diamond_ore",
	wherein        = "default:stone",
	clust_scarcity = 14 * 14 * 14,
	clust_num_ores = 30,
	clust_size     = 5,
	y_max          = -256,
	y_min          = -31000,
})
-- Forest trees
core.register_decoration({
    deco_type = "schematic",
    place_on = {"geology:grass_block"},
    sidelen = 16,
    fill_ratio = 0.01,
    biomes = {"temperate_forest"},
    y_max = 200,
    y_min = 1,
    schematic = core.get_modpath("tree") .. "/schematics/tree_short.mts",
    flags = "place_center_x, place_center_z",
    rotation = "random",
})
core.register_decoration({
    deco_type = "schematic",
    place_on = {"geology:grass_block"},
    sidelen = 16,
    fill_ratio = 0.01,
    biomes = {"temperate_forest"},
    y_max = 200,
    y_min = 1,
    schematic = core.get_modpath("tree") .. "/schematics/tree_medium.mts",
    flags = "place_center_x, place_center_z",
    rotation = "random",
})
core.register_decoration({
    deco_type = "schematic",
    place_on = {"geology:grass_block"},
    sidelen = 16,
    fill_ratio = 0.01,
    biomes = {"temperate_forest"},
    y_max = 200,
    y_min = 1,
    schematic = core.get_modpath("tree") .. "/schematics/tree_large.mts",
    flags = "place_center_x, place_center_z",
    rotation = "random",
})
-- Trees in non-forests
core.register_decoration({
    deco_type = "schematic",
    place_on = {"geology:grass_block"},
    sidelen = 16,
    fill_ratio = 0.0001,
    biomes = {"temperate"},
    y_max = 200,
    y_min = 1,
    schematic = core.get_modpath("tree") .. "/schematics/tree_short.mts",
    flags = "place_center_x, place_center_z",
    rotation = "random",
})
core.register_decoration({
    deco_type = "schematic",
    place_on = {"geology:grass_block"},
    sidelen = 16,
    fill_ratio = 0.0001,
    biomes = {"temperate"},
    y_max = 200,
    y_min = 1,
    schematic = core.get_modpath("tree") .. "/schematics/tree_medium.mts",
    flags = "place_center_x, place_center_z",
    rotation = "random",
})
core.register_decoration({
    deco_type = "schematic",
    place_on = {"geology:grass_block"},
    sidelen = 16,
    fill_ratio = 0.0001,
    biomes = {"temperate"},
    y_max = 200,
    y_min = 1,
    schematic = core.get_modpath("tree") .. "/schematics/tree_large.mts",
    flags = "place_center_x, place_center_z",
    rotation = "random",
})

