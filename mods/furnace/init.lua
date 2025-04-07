local function init_furnace(pos)
end
local function open_furnace(pos, player)
end
local function furnace_loop(pos)
end
core.register_node("furnace:furnace", {
    description = "Furnace",
    paramtype2 = "facedir",
    tiles = {"furnace_up_down.png", "furnace_up_down.png", "furnace_side.png", "furnace_side.png", "furnace_side.png", "furnace_front.png"},
    groups = {cracky = 3},
    on_construct = init_furnace,
    on_rightclick = open_furnace,
    after_place_node = base.correct_orientation_after_place_node
})

core.register_node("furnace:active_furnace", {
    description = "Furnace (active)",
    paramtype2 = "facedir",
    tiles = {"furnace_up_down.png", "furnace_up_down.png", "furnace_side.png", "furnace_side.png", "furnace_side.png", "furnace_front_lit.png"},
    groups = {cracky = 3},
    light_source = core.LIGHT_MAX,
    on_construct = init_furnace,
    on_rightclick = open_furnace,
    drop = "furnace:furnace",
    after_place_node = base.correct_orientation_after_place_node
})

core.register_craft({
    type = "shaped",
    output = "furnace:furnace",
    recipe = {
        {"group:stone", "group:stone", "group:stone"},
        {"group:stone", "", "group:stone"},
        {"group:stone", "group:stone", "group:stone"}
    }
})

core.register_abm({
    label = "furnace",
    nodenames = {"furnace:furnace", "furnace:active_furnace"},
    interval = 1,
    chance = 1,
    action = furnace_loop
})
