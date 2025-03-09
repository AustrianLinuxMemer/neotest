core.register_craftitem("geology:iron_ingot", {
    description = "Iron ingot",
    inventory_image = "geology_iron_ingot.png"
})

core.register_craftitem("geology:gold_ingot", {
    description = "Gold ingot",
    inventory_image = "geology_gold_ingot.png"
})

core.register_craftitem("geology:coal", {
    description = "Coal",
    inventory_image = "geology_coal.png",
    groups = {coal=1}
})

core.register_craftitem("geology:diamond", {
    description = "Diamond",
    inventory_image = "geology_diamond.png"
})
core.register_node("geology:cobble", {
    description = "Cobblestone",
    tiles = {"geology_cobble.png"},
    groups = {cracky=3, stone=1}
})
core.register_node("geology:sandstone", {
    description = "Sandstone",
    tiles = {"geology_sandstone.png"},
    groups = {cracky=3, stone=1}
})
core.register_node("geology:stone", {
    description = "Stone",
    tiles = {"geology_stone.png"},
    is_ground_content = true,
    groups = {cracky=3, stone=1},
    drop = "geology:cobble"
})

core.register_node("geology:dirt", {
    description = "Dirt",
    tiles = {"geology_dirt.png"},
    is_ground_content = true,
    groups = {crumbly=3, soil=1}
})

core.register_node("geology:sand", {
    description = "Sand",
    tiles = {"geology_sand.png"},
    is_ground_content = true,
    groups = {crumbly=3, falling_node=1, sand=1}
})

core.register_node("geology:gravel", {
    description = "Gravel",
    tiles = {"geology_gravel.png"},
    is_ground_content = true,
    groups = {crumbly=3, falling_node=1}
})

core.register_node("geology:grass_block", {
    description = "Grass block",
    tiles = {
        "geology_grass.png", "geology_dirt.png", "geology_dirt_grass.png", "geology_dirt_grass.png", "geology_dirt_grass.png", "geology_dirt_grass.png"
    },
    is_ground_content = true,
    groups = {crumbly=3}
})
core.register_node("geology:coal_ore", {
    description = "Coal ore",
    tiles = {"geology_coal_ore.png"},
    is_ground_content = true,
    groups = {cracky=3, ore=1},
    drop = "geology:coal"
})
core.register_node("geology:diamond_ore", {
    description = "Diamond ore",
    tiles = {"geology_diamond_ore.png"},
    is_ground_content = true,
    groups = {cracky=3, ore=1},
    drop = "geology:diamond",
    stack_max = 64
})
core.register_node("geology:iron_ore", {
    description = "Iron ore",
    tiles = {"geology_iron_ore.png"},
    is_ground_content = true,
    groups = {cracky=3, ore=1}
})
core.register_node("geology:gold_ore", {
    description = "Gold ore",
    tiles = {"geology_gold_ore.png"},
    is_ground_content = true,
    groups = {cracky=3, ore=1}
})

core.register_craft({
    type = "cooking",
    output = "geology:iron_ingot",
    recipe = "geology:iron_ore",
    cooktime = 10
})
core.register_craft({
    type = "cooking",
    output = "geology:gold_ingot",
    recipe = "geology:gold_ore",
    cooktime = 10
})
core.register_craft({
    type = "cooking",
    output = "geology:stone",
    recipe = "geology:cobble",
    cooktime = 10
})
core.register_craft({
    type = "fuel",
    recipe = "geology:coal",
    burntime = 300
})
