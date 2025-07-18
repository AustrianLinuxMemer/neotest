local S = core.get_translator("mods:nodes")
local nodes = {
    ["nodes:bricks"] = {
        description = S("Brick"),
        tiles = {"nodes_bricks.png"},
        groups = {cracky=3}
    },
    ["nodes:stone_bricks"] = {
        description = S("Stone Brick"),
        tiles = {"nodes_stone_bricks.png"},
        groups = {cracky=3}
    },
    ["nodes:smooth_sandstone"] = {
        description = S("Smooth Sandstone"),
        tiles = {"nodes_smooth_sandstone_top.png", "nodes_smooth_sandstone_top.png", "nodes_smooth_sandstone.png"},
        groups = {cracky=3}
    },
    ["nodes:sandstone_bricks"] = {
        description = S("Sandstone Bricks"),
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
    local stair_name = S("@1 Stairs", definition.description)
    local slab_name = S("@1 Slab", definition.description)
    stairs.register_stair(v.."_stairs", stair_name, definition, true)
    stairs.register_slab(v.."_slab", slab_name, definition, true)
end
for _, v in ipairs(recipes) do
    core.register_craft(v)
end

loot.add_to_loot_pool({item = "nodes:bricks", max_q = 16, prob = 0.2})
loot.add_to_loot_pool({item = "nodes:stone_bricks", max_q = 16, prob = 0.2})
loot.add_to_loot_pool({item = "nodes:sandstone_bricks", max_q = 16, prob = 0.2, keys = {"desert"}})
loot.add_to_loot_pool({item = "nodes:smooth_sandstone", max_q = 16, prob = 0.2, keys = {"desert"}})