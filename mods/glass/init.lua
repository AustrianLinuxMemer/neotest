local glass_def = {
    description = "Glass",
    drawtype = "glasslike_framed_optional",
    tiles = {"glass_glass.png"},
    is_ground_content = false,
    sunlight_propagates = true,
    paramtype = "light",
    groups = {choppy = 2, glass = 1}
}
local glass_pane_def = {
    tiles = {"glass_pane_side.png","glass_pane_side.png","glass_glass.png","glass_glass.png","glass_glass.png","glass_glass.png"},
    use_texture_alpha = "blend",
    sunlight_propagates = true,
    paramtype = "light",
    groups = {choppy = 2, glass = 1}
}
core.register_node("glass:glass", glass_def)
panes.register_pane("glass:glass", "Glass Pane", "glass_pane_front.png", "glass_glass.png",glass_pane_def)

stairs.register_stair("glass:glass", glass_def.description.." Stairs", glass_def, true)
stairs.register_slab("glass:glass", glass_def.description.." Slab", glass_def, true)
core.register_craft({
    type = "cooking",
    output = "glass:glass",
    recipe = "group:sand",
    cooktime = 15
})