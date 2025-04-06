core.register_alias("mapgen_stone", "geology:stone")
core.register_alias("mapgen_water_source", "liquids:water_source")
core.register_alias("mapgen_river_water_source", "liquids:river_water_source")
core.register_alias("mapgen_lava_source", "liquids:lava_source")
core.register_alias("mapgen_cobble", "geology:cobble")
core.register_alias("mapgen_sand", "geology:sand")
core.register_alias("mapgen_gravel", "geology:gravel")
minetest.register_alias("mapgen_dirt_with_grass", "geology:grass_block")

minetest.register_alias("mapgen_tree", "tree:oak_log")
minetest.register_alias("mapgen_leaves", "tree:oak_leaves")
-- Temperate Biome
core.register_biome({
    name = "temperate",
    node_top = "geology:grass_block",
    depth_top = 1,
    node_filler = "geology:dirt",
    node_riverbed = "geology:gravel",
    depth_riverbed = 2,
    depth_filler = 3,
    y_min = 7,
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
    node_riverbed = "geology:gravel",
    depth_riverbed = 2,
    y_min = 7,    
    heat_point = 50,
    humidity_point = 50
})
-- Desert biome
core.register_biome({
    name = "desert",
    node_top = "geology:sand",
    depth_top = 3,
    node_filler = "geology:sandstone",
    depth_filler = 128,
    node_riverbed = "geology:sand",
    depth_riverbed = 2,
    y_min = 7,
    heat_point = 75,
    humidity_point = 25
})
-- Temperate Beach
core.register_biome({
    name = "temperate_beach",
    node_top = "geology:sand",
    depth_top = 3,
    node_filler = "geology:sandstone",
    depth_filler = 1,
    node_riverbed = "geology:gravel",
    depth_riverbed = 2,
    y_max = 6,    
    heat_point = 50,
    humidity_point = 50
})
-- Desert Beach
core.register_biome({
    name = "temperate_beach",
    node_top = "geology:sand",
    depth_top = 3,
    node_filler = "geology:sandstone",
    depth_filler = 1,
    node_riverbed = "geology:gravel",
    depth_riverbed = 2,
    y_max = 6,    
    heat_point = 75,
    humidity_point = 75
})
-- Temperate Gravel Beach
core.register_biome({
    name = "temperate_gravel_beach",
    node_top = "geology:gravel",
    depth_top = 3,
    node_riverbed = "geology:gravel",
    depth_riverbed = 2,    
    y_max = 6,
    heat_point = 50,
    humidity_point = 50
})
-- Replace all grass blocks under non-air with dirt
core.register_on_generated(function(minp, maxp, seed)
    local is_liquid = {
        [core.get_content_id("liquids:water_source")] = true,
        [core.get_content_id("liquids:water_flowing")] = true,
    }
    local voxelmanip = core.get_mapgen_object("voxelmanip")
    local emin, emax = voxelmanip:read_from_map(minp, maxp)
    local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
    local data = voxelmanip:get_data()
    for z = emin.z, emax.z do
        for y = emin.y, emax.y do
            for x = emin.x, emax.x do
                local index = area:index(x, y, z)
                local index_beneath = area:index(x, y-1, z)
                if data[index_beneath] == core.get_content_id("geology:grass_block") and data[index] ~= core.get_content_id("air") then
                    data[index_beneath] = core.get_content_id("geology:dirt")
                end
            end
        end
    end
    voxelmanip:set_data(data)
    voxelmanip:write_to_map(true)
end)
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
