base.register_node("sign:sign", {
    description = "Sign",
    drawtype = "nodebox",
    paramtype2 = "wallmounted",
    inventory_image = "sign_sign_item.png",
    wield_image = "sign_sign_item.png",
    tiles = {"sign_sign_front.png", "sign_sign_back.png"},
    groups = {oddly_breakable_by_hand = 1},
    node_box = {
        type = "wallmounted",
        wall_top = {-8/16, 6/16, -8/16, 8/16, 8/16, 8/16},
        wall_bottom = {-8/16, -8/16, -8/16, 8/16, -6/16, 8/16},
        wall_side = {-8/16, -8/16, -8/16, -6/16, 8/16, 8/16},
    },
    after_place_node = function(pos, _, _, pointed_thing)
        local direction = vector.subtract(pointed_thing.under, pointed_thing.above)
        local new_param2 = core.dir_to_wallmounted(direction)
        local old_node = core.get_node(pos)
        core.swap_node(pos, {name = old_node.name, param2 = new_param2})
    end
})