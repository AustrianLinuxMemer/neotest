local S = core.get_translator("mods:geology")
local geology_def_table = {
    craftitems = {
        ["geology:iron_ingot"] = {
            description = S("Iron ingot"),
            inventory_image = "geology_iron_ingot.png",
            groups = {iron = 1}
        },
        ["geology:gold_ingot"] = {
            description = S("Gold ingot"),
            inventory_image = "geology_gold_ingot.png",
            groups = {gold = 1}
        },
        ["geology:coal"] = {
            description = S("Coal"),
            inventory_image = "geology_coal.png",
            groups = {coal=1}
        },
        ["geology:diamond"] = {
            description = S("Diamond"),
            inventory_image = "geology_diamond.png",
            groups = {diamond = 1, gemstone = 1}
        },
        ["geology:clay_lump"] = {
            description = S("Clay lump"),
            inventory_image = "geology_clay_lump.png",
            stack_max = 16
        }
    },
    nodes = {
        ["geology:cobble"] = {
            description = S("Cobblestone"),
            tiles = {"geology_cobble.png"},
            groups = {cracky=3, stone=1, pane_connect = 1}
        },
        ["geology:sandstone"] = {
            description = S("Sandstone"),
            tiles = {"geology_sandstone_top.png", "geology_sandstone_bottom.png", "geology_sandstone.png"},
            groups = {cracky=3, stone=1, pane_connect = 1}
        },
        ["geology:stone"] = {
            description = S("Stone"),
            tiles = {"geology_stone.png"},
            is_ground_content = true,
            groups = {cracky=3, stone=1, pane_connect = 1},
            drop = "geology:cobble"
        },
        ["geology:dirt"] = {
            description = S("Dirt"),
            tiles = {"geology_dirt.png"},
            is_ground_content = true,
            groups = {crumbly=3, soil=1, pane_connect = 1}
        },
        ["geology:sand"] = {
            description = S("Sand"),
            tiles = {"geology_sand.png"},
            is_ground_content = true,
            groups = {crumbly=3, falling_node=1, sand=1, pane_connect = 1}
        },
        ["geology:gravel"] = {
            description = S("Gravel"),
            tiles = {"geology_gravel.png"},
            is_ground_content = true,
            groups = {crumbly=3, falling_node=1, gravel=1, pane_connect = 1}
        },
        ["geology:grass_block"] = {
            description = S("Grass block"),
            tiles = {
                "geology_grass.png", "geology_dirt.png", "geology_dirt_grass.png", "geology_dirt_grass.png", "geology_dirt_grass.png", "geology_dirt_grass.png"
            },
            is_ground_content = true,
            groups = {crumbly=3, soil=1, pane_connect = 1},
            drop = "geology:dirt"
        },
        ["geology:coal_ore"] = {
            description = S("Coal ore"),
            tiles = {"geology_coal_ore.png"},
            is_ground_content = true,
            groups = {cracky=3, ore=1, pane_connect = 1},
            drop = "geology:coal"
        },
        ["geology:iron_ore"] = {
            description = S("Iron ore"),
            tiles = {"geology_iron_ore.png"},
            is_ground_content = true,
            groups = {cracky=3, ore=1, pane_connect = 1}
        },
        ["geology:gold_ore"] = {
            description = S("Gold ore"),
            tiles = {"geology_gold_ore.png"},
            is_ground_content = true,
            groups = {cracky=3, ore=1, pane_connect = 1}
        },
        ["geology:diamond_ore"] = {
            description = S("Diamond ore"),
            tiles = {"geology_diamond_ore.png"},
            is_ground_content = true,
            groups = {cracky=3, ore=1, pane_connect = 1},
            drop = "geology:diamond"
        },
        ["geology:clay"] = {
            description = S("Clay"),
            tiles = {"geology_clay.png"},
            is_ground_content = true,
            groups = {crumbly=3, pane_connect = 1},
            drop = {
                max_items = 1,
                items = {
                    {rarity = 3, items = {"geology:clay_lump 3"}},
                    {rarity = 2, items = {"geology:clay_lump 4"}},
                    {rarity = 1, items = {"geology:clay_lump 5"}}
                }
            }
        }
    },
    yes_slab_stair = {
        "geology:cobble",
        "geology:stone",
        "geology:sandstone",
        "geology:dirt",
        "geology:sand",
        "geology:gravel"
    },
    crafts = {
        {
            type = "cooking",
            output = "geology:iron_ingot",
            recipe = "geology:iron_ore",
            cooktime = 10
        },
        {
            type = "cooking",
            output = "geology:gold_ingot",
            recipe = "geology:gold_ore",
            cooktime = 10
        },
        {
            type = "cooking",
            output = "geology:stone",
            recipe = "geology:cobble",
            cooktime = 10
        },
        {
            type = "fuel",
            recipe = "geology:coal",
            burntime = 30
        },
        {
            type = "shaped",
            output = "geology:clay",
            recipe = {
                {"geology:clay_lump", "geology:clay_lump"},
                {"geology:clay_lump", "geology:clay_lump"}
            }
        }
    }
}

for k, v in pairs(geology_def_table.craftitems) do
    base.register_craftitem(k,v)    
end
for k, v in pairs(geology_def_table.nodes) do
    base.register_node(k,v)
end
for k, v in pairs(geology_def_table.crafts) do
    core.register_craft(v)
end
for _,v in pairs(geology_def_table.yes_slab_stair) do
    local node_def = geology_def_table.nodes[v]
    stairs.register_stair(v, node_def.description.." Stairs", node_def, true)
    stairs.register_slab(v, node_def.description.." Slab", node_def, true)
end

-- Turning covered grass blocks into dirt blocks
core.register_abm({
    nodenames = {"geology:grass_block"},
    interval = 5,
    chance = 50,
    action = function(pos, node)
        local pos_neighbor = {x = pos.x, y = pos.y + 1, z = pos.z}
        local is_transparent = base.is_transparent(pos_neighbor)
        
        if not is_transparent then
            core.set_node(pos, {name = "geology:dirt"})
        end
    end
})
-- Turning free dirt blocks into grass blocks
core.register_abm({
    nodenames = {"geology:dirt"},
    interval = 5,
    chance = 50,
    action = function(pos, node)
        local pos_neighbor = {x = pos.x, y = pos.y + 1, z = pos.z}
        local is_transparent = base.is_transparent(pos_neighbor)
        local node_light = core.get_node_light(pos_neighbor)
        local natural_light = core.get_natural_light(pos_neighbor, 0.5)
        if is_transparent and (node_light ~= 0 or natural_light ~= 0)then
            core.set_node(pos, {name = "geology:grass_block"})        
        end
    end
})
loot.add_to_loot_pool({item = "geology:coal", max_q = 16, prob = 0.1})
loot.add_to_loot_pool({item = "geology:iron_ingot", max_q = 16, prob = 0.1})
loot.add_to_loot_pool({item = "geology:gold_ingot", max_q = 16, prob = 0.01})
loot.add_to_loot_pool({item = "geology:clay_lump", max_q = 16, prob = 0.1})
loot.add_to_loot_pool({item = "geology:diamond", max_q = 16, prob = 0.001})
loot.add_to_loot_pool({item = "geology:sand", max_q = 16, prob = 0.1, keys = {"desert"}})
loot.add_to_loot_pool({item = "geology:sandstone", max_q = 16, prob = 0.1, keys = {"desert"}})
loot.add_to_loot_pool({item = "geology:cobble", max_q = 16, prob = 0.1})
loot.add_to_loot_pool({item = "geology:gravel", max_q = 16, prob = 0.1})