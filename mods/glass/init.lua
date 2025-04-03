core.register_node("glass:glass", {
    description = "Glass",
    drawtype = "glasslike_framed_optional",
    tiles = {"glass_glass.png"},
    is_ground_content = false,
    sunlight_propagates = true,
    paramtype = "light",
    groups = {choppy = 2, glass = 1}
})

core.register_craft({
    type = "cooking",
    output = "glass:glass",
    recipe = "group:sand",
    cooktime = 15
})
