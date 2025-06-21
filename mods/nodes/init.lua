local nodes = {
    ["nodes:brick"] = {
        description = "Brick",
        tiles = {"nodes_brick_block.png"},
        groups ={cracky=3}
    }
}
local recipes = {
    {
        type = "shaped",
        output = "nodes:bricks",
        recipe = {
            {"nodes:bricks","nodes:bricks"},
            {"nodes:bricks","nodes:bricks"}
        }
    }
}
local stairs_slabs = {
    "nodes:brick"
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