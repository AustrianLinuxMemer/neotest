core.register_node("plants:cactus", {
    description = "Cactus",
    tiles = {"cactus_top.png", "cactus_bottom.png", "cactus_side.png", "cactus_side.png", "cactus_side.png", "cactus_side.png"},
    groups = {choppy = 2}
})
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
