
local function place_torch(itemstack, placer, pointed_thing)
    --base.chat_send_all_debug("triggereds")
    local freestanding = {
        [0] = true,
        [1] = true,
        [6] = true,
        [7] = true
    }
    if pointed_thing.type ~= "node" then
        return itemstack
    end
    local direction = vector.subtract(pointed_thing.under, pointed_thing.above)
    local param2 = core.dir_to_wallmounted(direction)
    local above = core.get_node(pointed_thing.above)
    local under = core.get_node(pointed_thing.under)
    local no_torch = core.get_item_group(under.name, "torch") == 0
    local is_air = above.name == "air"
    if no_torch and is_air then
        if freestanding[param2] then
            core.set_node(pointed_thing.above, {name = "torch:torch_freestanding", param2 = param2})
        else
            core.set_node(pointed_thing.above, {name = "torch:torch_attached", param2 = param2})
        end
        itemstack:take_item(1)
    end
    return itemstack
end
base.register_craftitem("torch:torch", {
    description = "Torch",
    inventory_image = "torch_item.png",
    on_place = place_torch
})
base.register_node("torch:torch_attached", {
    drawtype = "mesh",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    light_source = core.LIGHT_MAX,
    paramtype2 = "wallmounted",
    mesh = "torch_attached.obj",
    tiles = {"torch.png"},
    groups = {oddly_breakable_by_hand = 1},
    drop = "torch:torch",
    selection_box = {
		type = "wallmounted",
		wall_side = {-8/16, 4/16, -2/16, -2/16, -6/16, 2/16},
	}
    
})
base.register_node("torch:torch_freestanding", {
    drawtype = "mesh",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    light_source = core.LIGHT_MAX,
    paramtype2 = "wallmounted",
    mesh = "torch_freestanding.obj",
    tiles = {"torch.png"},
    groups = {oddly_breakable_by_hand = 1, no_creative = 1},
    drop = "torch:torch",
    selection_box = {
		type = "wallmounted",
		wall_bottom = {-2/16, 2/16, -2/16, 2/16, -8/16, 2/16},
        wall_top = {-2/16, 8/16, -2/16, 2/16, -2/16, 2/16}
	}
})
core.register_craft({
	type = "shaped",
	output = "torch:torch 4",
	recipe = {
		{"group:coal"},
		{"group:stick"}
	}
})

loot.add_to_loot_pool({item = "torch:torch", max_q = 8, prob = 0.2})