local S = core.get_translator("mods:plants")
if core.get_modpath("farming") ~= nil then
    dofile(core.get_modpath("plants").."/farmable.lua")
end
dofile(core.get_modpath("plants").."/cactus.lua")
dofile(core.get_modpath("plants").."/plants_api.lua")

plants.register_fungus("plants:brown_fungus", S("Brown Fungus"), "plants_brown_fungus", {brown_fungus = 1}, true)
plants.register_fungus("plants:red_fungus", S("Red Fungus"), "plants_red_fungus", {red_fungus = 1}, true)

plants.register_plant("plants:grass", S("Grass"), "plants_grass.png", 
{
    {
        rarity = 3, 
        items = {"plants:wheat_seed"}
    }
})
plants.register_plant("plants:snowy_grass", S("Snowy Grass"), "plants_snowy_grass.png", 
{
    {
        rarity = 3, 
        items = {"plants:wheat_seed"}
    }
})
plants.register_plant("plants:desert_shrub", S("Desert Shrub"), "plants_desert_shrub.png", 
{
    {
        items = {"tree:stick"}
    }
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