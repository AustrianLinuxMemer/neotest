local S = core.get_translator("mods:plants")

if core.get_modpath("farming") ~= nil then
    dofile(core.get_modpath("plants").."/farmable.lua")
end
local cactus_def = {
    description = S("Cactus"),
    tiles = {"plants_cactus_top.png", "plants_cactus_bottom.png", "plants_cactus_side.png"},
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
stairs.register_slab("plants:cactus", cactus_def.description.." Slab", cactus_def, true)
core.register_decoration({
    deco_type = "simple",
    place_on = {"geology:sand"},
    sidelen = 16,
    fill_ratio = 0.005,
    y_min = 1,
    biomes = {"desert", "desert_beach"},
    decoration = "plants:cactus",
    height = 1,
    height_max = 3
})

loot.add_to_loot_pool({item = "plants:cactus", max_q = 3, prob = 0.2, keys = {"desert"}})