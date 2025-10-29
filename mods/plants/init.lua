local S = core.get_translator("mods:plants")
if core.get_modpath("farming") ~= nil then
    dofile(core.get_modpath("plants").."/farmable.lua")
end
dofile(core.get_modpath("plants").."/cactus.lua")
dofile(core.get_modpath("plants").."/plants_api.lua")

plants.register_plantlike_plant_legacy("plants:brown_fungus", S("Brown Fungus"), "plants_brown_fungus.png")
plants.register_plantlike_plant_legacy("plants:red_fungus", S("Red Fungus"), "plants_red_fungus.png")

plants.register_plantlike_plant_legacy("plants:grass", S("Grass"), "plants_grass.png", 
{
    {
        rarity = 3, 
        items = {"plants:wheat_seed"}
    }
})
plants.register_plantlike_plant_legacy("plants:snowy_grass", S("Snowy Grass"), "plants_snowy_grass.png", 
{
    {
        rarity = 3, 
        items = {"plants:wheat_seed"}
    }
})
plants.register_plantlike_plant_legacy("plants:desert_shrub", S("Desert Shrub"), "plants_desert_shrub.png", 
{
    {
        items = {"tree:stick"}
    }
})

plants.register_lilypad_like("plants:lilypad", {
    description = "Lilypad",
    inventory_image = "plants_lilypad.png",
    texture = "plants_lilypad.png",
    place_on = {
        group_names = {"water"}
    },
    groups = {oddly_breakable_by_hand = 1, flammable = 2}
})

plants.register_vine_like("plants:vines", {
    description = "Vines",
    inventory_image = "plants_vines.png",
    texture = "plants_vines.png",
    groups = {oddly_breakable_by_hand = 1, flammable = 4},
    climbable = true
})

core.register_abm({
    nodenames = {"plants:grass"},
    chance = 25,
    interval = 1,
    action = function(pos)
        local biome_info = core.get_biome_data(pos)
        local biome_heat = biomes.biome_query(biome_info.biome, "heat_point")
        local weather = weather.current_weather
        -- If temperature point is below 25 (meaning arctic) and weather is not clear, make snowy grass
        if biome_heat < 25 and weather > 0 then
            core.set_node(pos, {name = "plants:snowy_grass"})
        end
    end
})
core.register_abm({
    nodenames = {"plants:snowy_grass"},
    chance = 25,
    interval = 1,
    action = function(pos)
        local biome_info = core.get_biome_data(pos)
        local biome_heat = biomes.biome_query(biome_info.biome, "heat_point")
        local weather = weather.current_weather
        -- If temperature point is above 25 (meaning arctic), make grass
        if biome_heat > 25 then
            core.set_node(pos, {name = "plants:grass"})
        end
    end
})

core.register_decoration({
    deco_type = "simple",
    place_on = {"geology:sand"},
    decoration = "plants:desert_shrub",
    biomes = {"biomes:desert"},
    fill_ratio = 0.005,
    y_min = 1,
    height = 1
})

core.register_decoration({
    deco_type = "simple",
    place_on = {"geology:grass_block"},
    decoration = "plants:grass",
    fill_ratio = 0.15,
    y_min = 1,
    height = 1
})
core.register_decoration({
    deco_type = "simple",
    place_on = {"ice:snowy_grass_block"},
    decoration = "plants:snowy_grass",
    fill_ratio = 0.15,
    y_min = 1,
    height = 1
})

loot.add_to_loot_pool({item = "plants:cactus", max_q = 3, prob = 0.2, keys = {"desert"}})