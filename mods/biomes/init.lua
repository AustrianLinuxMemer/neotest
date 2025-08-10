core.register_alias("mapgen_stone", "geology:stone")
core.register_alias("mapgen_water_source", "liquids:water_source")
core.register_alias("mapgen_river_water_source", "liquids:river_water_source")
core.register_alias("mapgen_lava_source", "liquids:lava_source")
core.register_alias("mapgen_cobble", "geology:cobble")
core.register_alias("mapgen_sand", "geology:sand")
core.register_alias("mapgen_gravel", "geology:gravel")
core.register_alias("mapgen_dirt", "geology:dirt")
core.register_alias("mapgen_dirt_with_grass", "geology:grass_block")

core.register_alias("mapgen_tree", "tree:oak_log")
core.register_alias("mapgen_leaves", "tree:oak_leaves")
-- No apples in the game yet (like wtf Luanti why do i need apples for v6 mapgen, can't that be optional)
core.register_alias("mapgen_apple", "air")

biomes = {
    biome_def = {
        [1] = {
            name = "biomes:temperate",
            node_top = "geology:grass_block",
            depth_top = 1,
            node_filler = "geology:dirt",
            depth_filler = 3,
            node_riverbed = "geology:gravel",
            depth_riverbed = 2,
            node_dungeon = "nodes:stone_bricks",
            node_dungeon_stair = "nodes:stone_bricks_stairs",
            y_min = 7,
            heat_point = 50,
            humidity_point = 50
        },
        [2] = {
            name = "biomes:temperate_forest",
            node_top = "geology:grass_block",
            depth_top = 1,
            node_filler = "geology:dirt",
            depth_filler = 3,
            node_riverbed = "geology:gravel",
            depth_riverbed = 2,
            node_dungeon = "nodes:stone_bricks",
            node_dungeon_stair = "nodes:stone_bricks_stairs",
            y_min = 7,    
            heat_point = 50,
            humidity_point = 50
        },
        [3] = {
            name = "biomes:desert",
            node_top = "geology:sand",
            depth_top = 3,
            node_riverbed = "geology:sand",
            depth_riverbed = 2,
            node_dungeon = "nodes:sandstone_bricks",
            node_dungeon_stair = "nodes:sandstone_bricks_stairs",
            node_stone = "geology:sandstone",
            y_min = 1,
            heat_point = 75,
            humidity_point = 25
        },
        [4] = {
            name = "biomes:temperate_beach",
            node_top = "geology:sand",
            depth_top = 3,
            node_filler = "geology:sandstone",
            depth_filler = 1,
            node_riverbed = "geology:gravel",
            depth_riverbed = 2,
            node_dungeon = "nodes:stone_bricks",
            node_dungeon_stair = "nodes:stone_bricks_stairs",
            y_max = 6,
            y_min = -5,   
            heat_point = 50,
            humidity_point = 50
        },
        [5] = {
            name = "biomes:temperate_gravel_ocean",
            node_top = "geology:gravel",
            depth_top = 3,
            node_riverbed = "geology:gravel",
            depth_riverbed = 2,
            node_dungeon = "nodes:stone_bricks",
            node_dungeon_stair = "nodes:stone_bricks_stairs",
            vertical_blend = 4,   
            y_max = -4,
            heat_point = 50,
            humidity_point = 50,
        },
        [6] = {
            name = "biome:temperate_sand_ocean",
            node_top = "geology:sand",
            depth_top = 3,
            node_filler = "geology:sandstone",
            depth_filler = 1,
            node_riverbed = "geology:sand",
            depth_riverbed = 2,
            node_dungeon = "nodes:stone_bricks",
            node_dungeon_stair = "nodes:stone_bricks_stairs",
            vertical_blend = 4,    
            y_max = -4,
            heat_point = 50,
            humidity_point = 50,
        },
        [7] = {
            name = "biomes:tundra",
            node_dust = "ice:snow",
            node_top = "ice:snowy_grass_block",
            depth_top = 1,
            node_filler = "geology:dirt",
            depth_filler = 3,
            node_riverbed = "geology:gravel",
            depth_riverbed = 2,
            node_dungeon = "nodes:stone_bricks",
            node_dungeon_stair = "nodes:stone_bricks_stairs",
            vertical_blend = 4,
            node_water_top = "ice:water_ice",
            depth_water_top = 5,
            heat_point = 0,
            humidity_point = 50
        }
    },
    biome_map = {}
}
for i, biome in ipairs(biomes.biome_def) do
    local id = core.register_biome(biome)
    biome_map[id] = i
    core.log("error", biome.name.." ["..tostring(i).."] got "..tostring(id))
    ice.register_biome_temperature_humidity(i, biome.heat_point, biome.humidity_point)
end

chest.register_loot_chest("biomes:loot_temperate", {{
    deco_type = "simple",
    place_on = {"geology:cobble", "nodes:stone_bricks"},
    decoration = "biomes:loot_temperate",
    fill_ratio = 0.03
}}, "temperate")
chest.register_loot_chest("biomes:loot_desert", {{
    deco_type = "simple",
    place_on = {"nodes:sandstone_bricks"},
    decoration = "biomes:loot_desert",
    fill_ratio = 0.03
}}, "desert")
-- Sand
core.register_ore({
    ore_type = "blob",
    ore = "geology:sand",
    wherein = {"geology:gravel", "geology:stone", "geology:sandstone", "geology:dirt"},
    clust_scarcity = 10*10*10,
    clust_size = 4,
    y_max = 31000,
    y_min = -31000,
    noise_params = {
        offset = 0,
        scale = 1,
        spread = {x = 100, y = 100, z = 100},
        seed = 23,
        octaves = 3,
        persistence = 0.7
    },
})

-- Clay
core.register_ore({
    ore_type = "blob",
    ore = "geology:clay",
    wherein = {"geology:gravel", "geology:sand", "geology:dirt"},
    clust_scarcity = 10*10*10,
    clust_size = 4,
    y_max = -1,
    y_min = -31000,
    noise_params = {
        offset = 0,
        scale = 1,
        spread = {x = 100, y = 100, z = 100},
        seed = 23,
        octaves = 3,
        persistence = 0.7
    },
})

-- Gravel
core.register_ore({
    ore_type = "blob",
    ore = "geology:gravel",
    wherein = {"geology:sand", "geology:dirt", "geology:stone", "geology:sandstone"},
    clust_scarcity = 10*10*10,
    clust_size = 4,
    y_max = 31000,
    y_min = -31000,
    noise_params = {
        offset = 0,
        scale = 1,
        spread = {x = 100, y = 100, z = 100},
        seed = 23,
        octaves = 3,
        persistence = 0.7
    },
})
-- Dirt
core.register_ore({
    ore_type = "blob",
    ore = "geology:sand",
    wherein = {"geology:gravel", "geology:stone", "geology:sandstone"},
    clust_scarcity = 10*10*10,
    clust_size = 4,
    y_max = 31000,
    y_min = -31000,
    noise_params = {
        offset = 0,
        scale = 1,
        spread = {x = 100, y = 100, z = 100},
        seed = 23,
        octaves = 3,
        persistence = 0.7
    },
})
-- Coal
core.register_ore({
	ore_type       = "scatter",
	ore            = "geology:coal_ore",
	wherein        = "geology:stone",
	clust_scarcity = 10 * 10 * 10,
	clust_num_ores = 30,
	clust_size     = 5,
	y_max          = 64,
	y_min          = -31000,
})

-- Iron
core.register_ore({
	ore_type       = "scatter",
	ore            = "geology:iron_ore",
	wherein        = "geology:stone",
	clust_scarcity = 12 * 12 * 12,
	clust_num_ores = 30,
	clust_size     = 5,
	y_max          = 64,
	y_min          = -31000,
})

-- Gold
core.register_ore({
	ore_type       = "scatter",
	ore            = "geology:gold_ore",
	wherein        = "geology:stone",
	clust_scarcity = 13 * 13 * 13,
	clust_num_ores = 30,
	clust_size     = 5,
	y_max          = -128,
	y_min          = -31000,
})
-- Diamond
core.register_ore({
	ore_type       = "scatter",
	ore            = "geology:diamond_ore",
	wherein        = "geology:stone",
	clust_scarcity = 14 * 14 * 14,
	clust_num_ores = 30,
	clust_size     = 5,
	y_max          = -256,
	y_min          = -31000,
})
