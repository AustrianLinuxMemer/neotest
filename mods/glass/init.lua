local glass_def = {
    description = "Glass",
    drawtype = "glasslike_framed_optional",
    tiles = {"glass_glass.png"},
    is_ground_content = false,
    sunlight_propagates = true,
    paramtype = "light",
    use_texture_alpha = "blend",
    groups = {choppy = 2, glass = 1, pane_connect = 1}
}
local glass_pane_def = {
    tiles = {"glass_pane_side.png","glass_pane_side.png","glass_glass.png","glass_glass.png","glass_glass.png","glass_glass.png"},
    use_texture_alpha = "blend",
    sunlight_propagates = true,
    paramtype = "light",
    groups = {choppy = 2, glass = 1}
}
base.register_node("glass:glass", glass_def)
panes.register_pane("glass:glass", "Glass Pane", "glass_glass.png",glass_pane_def)
core.register_craft({
    type = "cooking",
    output = "glass:glass",
    recipe = "group:sand",
    cooktime = 15
})

loot.add_to_loot_pool({item = "glass:glass", max_q = 16, prob = 0.1, keys = {"desert"}})
loot.add_to_loot_pool({item = "glass:glass_pane", max_q = 16, prob = 0.1, keys = {"desert"}})