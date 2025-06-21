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
    }
}
local recipes = {
    {
        type = "shaped",
        output = "nodes:bricks",
        recipe = {
            {"materials:brick","materials:brick"},
            {"materials:brick","materials:brick"}
        }
    },
    {
        type = "shaped",
        output = "nodes:stone_bricks",
        recipe = {
            {"geology:stone", "geology:stone"},
            {"geology:stone", "geology:stone"}
        }
    }
}
local stairs_slabs = {
    "nodes:bricks",
    "nodes:stone_bricks"
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