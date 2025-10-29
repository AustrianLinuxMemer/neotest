local S = core.get_translator("mods:plants")
local cactus_def = {
    description = S("Cactus"),
    tiles = {"plants_cactus_top.png", "plants_cactus_bottom.png", "plants_cactus_side.png"},
    groups = {choppy = 2, pane_connect = 1, flammable = 6},
    on_punch = function(pos, node, puncher)
        if puncher:is_player() then
            local hp = puncher:get_hp()
            puncher:set_hp(hp-1, "Punched a Cactus")
        end
    end
}

base.register_node("plants:cactus", cactus_def)
stairs.register_stair("plants:cactus", cactus_def.description.." Stairs", cactus_def, true)
stairs.register_slab("plants:cactus", cactus_def.description.." Slab", cactus_def, true)
core.register_decoration({
    deco_type = "simple",
    place_on = {"geology:sand"},
    decoration = "plants:cactus",
    biomes = {"biomes:desert"},
    fill_ratio = 0.005,
    y_min = 1,
    height = 1,
    height_max = 3
})
if core.get_modpath("dye") ~= nil then
    dye.register_craft({
        type = "cooking",
        output = "dark_green",
        recipe = "plants:cactus",
        cooktime = 5
    })
end