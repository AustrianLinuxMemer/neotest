-- Melting
core.register_abm({
    nodenames = {"group:melts"},
    chance = 25,
    interval = 1,
    action = function(pos)
        local biome_data = core.get_biome_data(pos)
        local heat = biomes.biome_query(biome_data.biome, "heat_point")
        local node = core.get_node(pos)
        local artificial_light = core.get_artificial_light(node.param1)
        if heat >= 25 or artificial_light > 4 then
            ice.melt(pos)
        end
    end
})
-- Freeze
core.register_abm({
    nodenames = {"group:water"},
    chance = 25,
    interval = 1,
    action = function(pos)
        local node_above = core.get_node(vector.new(pos.x, pos.y + 1, pos.z))
        local node = core.get_node(pos)
        local artificial_light = core.get_artificial_light(node.param1)
        local biome_data = core.get_biome_data(pos)
        local heat = biomes.biome_query(biome_data.biome, "heat_point")
        if heat < 25 and node_above.name == "air" and artificial_light <= 4 then
            ice.freeze(pos)
        end
    end
})