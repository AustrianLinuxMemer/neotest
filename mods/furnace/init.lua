

core.register_node("furnace:furnace", {
    description = "Furnace",
    tiles = {"furnace_up_down.png", "furnace_up_down.png", "furnace_side.png", "furnace_side.png", "furnace_side.png", "furnace_front.png"},
    groups = {cracky = 3},
    on_construct = function(pos)
        local meta = core.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("fuel", 1)
        inv:set_size("input", 1)
        inv:set_size("output", 1)
        meta:set_string("formspec", "formspec_version[8]".."size[11,10]".."real_coordinates[true]".."list[context;fuel;2,3;1,1;]".."list[context;input;2,1;1,1;]".."list[context;output;5,1;2,2;]".."list[current_player;main;0.5,5;8,4;]")
    end,
    on_rightclick = function(pos, node, player, itemstack, pointed_thing)
        local meta = minetest.get_meta(pos)
        core.show_formspec(player:get_player_name(), "furnace:furnace", meta:get_string("formspec"))    
    end
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
