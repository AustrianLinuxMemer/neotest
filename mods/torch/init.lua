local function on_place_torch(itemstack, placer, pointed_thing)
    itemstack:take_item(1)
    local dir = vector.subtract(pointed_thing.under, pointed_thing.above)
    local wallmounted_value = core.dir_to_wallmounted(dir)
    if wallmounted_value > 1 and wallmounted_value < 6 then
        core.set_node(pointed_thing.above, {name = "torch:torch_attached", param2 = wallmounted_value})
    else
        core.set_node(pointed_thing.above, {name = "torch:torch", param2 = wallmounted_value})
    end
    return itemstack
end

core.register_node("torch:torch", {
    description = "Torch",
    drawtype = "mesh",
    paramtype = "light",
    inventory_image = "torch_item.png",
    wield_image = "torch_item.png",
    sunlight_propagates = true,
    walkable = false,
    light_source = core.LIGHT_MAX,
    paramtype2 = "wallmounted",
    mesh = "torch_freestanding.obj",
    tiles = {"torch.png"},
    groups = {oddly_breakable_by_hand = 1},
    on_place = on_place_torch
})

core.register_node("torch:torch_attached", {
    description = "Torch",
    drawtype = "mesh",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    light_source = core.LIGHT_MAX,
    paramtype2 = "wallmounted",
    mesh = "torch_attached.obj",
    tiles = {"torch.png"},
    groups = {oddly_breakable_by_hand = 1},
    drop = "torch:torch"
})