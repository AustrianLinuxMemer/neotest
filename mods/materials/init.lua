base.register_craftitem("materials:brick", {
    description = "Brick",
    inventory_image = "materials_brick.png"
})
core.register_craft({
    type = "cooking",
    output = "materials:brick",
    recipe = "geology:clay_lump",
    cooktime = 10
})