local nodes = {
    ["nodes:bricks"] = {
        description = "Brick",
        tiles = {"nodes_bricks.png"},
        groups = {cracky=3}
    },
    ["nodes:stone_bricks"] = {
        description = "Stone Brick",
        tiles = {"nodes_stone_bricks.png"},
        groups = {cracky=3}
    },
    ["nodes:smooth_sandstone"] = {
        description = "Smooth Sandstone",
        tiles = {"nodes_smooth_sandstone_top.png", "nodes_smooth_sandstone_top.png", "nodes_smooth_sandstone.png"},
        groups = {cracky=3}
    },
    ["nodes:sandstone_bricks"] = {
        description = "Sandstone Bricks",
        tiles = {"nodes_sandstone_bricks.png"},
         groups = {cracky=3}
    }
}
local recipes = {
    {
        type = "shaped",
        output = "nodes:bricks 4",
        recipe = {
            {"materials:brick","materials:brick"},
            {"materials:brick","materials:brick"}
        }
    },
    {
        type = "shaped",
        output = "nodes:stone_bricks 4",
        recipe = {
            {"geology:stone", "geology:stone"},
            {"geology:stone", "geology:stone"}
        }
    },
    {
        type = "cooking",
        output = "nodes:smooth_sandstone",
        recipe = "geology:sandstone",
        cooktime = 20
    },
    {
        type = "shaped",
        output = "nodes:sandstone_bricks 4",
        recipe = {
            {"nodes:smooth_sandstone", "nodes:smooth_sandstone"},
            {"nodes:smooth_sandstone", "nodes:smooth_sandstone"}
        }
    }
}
local stairs_slabs = {
    "nodes:bricks",
    "nodes:stone_bricks",
    "nodes:smooth_sandstone",
    "nodes:sandstone_bricks"
}

for k, v in pairs(nodes) do
    base.register_node(k,v)
end
for _, v in ipairs(stairs_slabs) do
    local definition = nodes[v]
    stairs.register_stair(v.."_stairs", definition.description.." Stairs", definition, true)
    stairs.register_slab(v.."_slab", definition.description.." Slab", definition, true)
end
for _, v in ipairs(recipes) do
    core.register_craft(v)
end