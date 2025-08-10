-- Melting
core.register_abm({
    nodenames = {"group:melts"},
    chance = 25,
    interval = 1,
    action = function(pos)
        local biome_data = core.get_biome_data(pos)
        local heat_humidity = biomes.biome_query(biome_data.biome, {"heat_point", "humidity_point"})
        if heat_humidity.heat_point >= 25 then
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
        local biome_data = core.get_biome_data(pos)
        local heat_humidity = biomes.biome_query(biome_data.biome, {"heat_point", "humidity_point"})
        if heat_humidity.heat_point < 25 and node_above.name == "air" then
            ice.freeze(pos)
        end
    end
})