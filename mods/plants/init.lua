local cactus_def = {
    description = "Cactus",
    tiles = {"cactus_top.png", "cactus_bottom.png", "cactus_side.png", "cactus_side.png", "cactus_side.png", "cactus_side.png"},
    groups = {choppy = 2, pane_connect = 1},
    on_punch = function(pos, node, puncher)
        if puncher:is_player() then
            local hp = puncher:get_hp()
            puncher:set_hp(hp-1, "Punched a Cactus")
        end
    end
}

base.register_node("plants:cactus", cactus_def)
stairs.register_stair("plants:cactus", cactus_def.description.." Stairs", cactus_def, true)
stairs.register_stair("plants:cactus", cactus_def.description.." Slab", cactus_def, true)
core.register_decoration({
    deco_type = "schematic",
    place_on = {"geology:sand"},
    sidelen = 16,
    fill_ratio = 0.005,
    biomes = {"desert", "desert_beach"},
    schematic = core.get_modpath("plants").."/schematics/cactus_small.mts",
})
core.register_decoration({
    deco_type = "schematic",
    place_on = {"geology:sand"},
    sidelen = 16,
    fill_ratio = 0.005,
    biomes = {"desert", "desert_beach"},
    schematic = core.get_modpath("plants").."/schematics/cactus_medium.mts",
})
core.register_decoration({
    deco_type = "schematic",
    place_on = {"geology:sand"},
    sidelen = 16,
    fill_ratio = 0.005,
    biomes = {"desert", "desert_beach"},
    schematic = core.get_modpath("plants").."/schematics/cactus_large.mts",
})
