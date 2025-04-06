local geology_def_table = {
    craftitems = {
        ["geology:iron_ingot"] = {
            description = "Iron ingot",
            inventory_image = "geology_iron_ingot.png",
            groups = {iron = 1}
        },
        ["geology:gold_ingot"] = {
            description = "Gold ingot",
            inventory_image = "geology_gold_ingot.png",
            groups = {gold = 1}
        },
        ["geology:coal"] = {
            description = "Coal",
            inventory_image = "geology_coal.png",
            groups = {coal=1}
        },
        ["geology:diamond"] = {
            description = "Diamond",
            inventory_image = "geology_diamond.png",
            groups = {diamond = 1, gemstone = 1}
        }
    },
    nodes = {
        ["geology:cobble"] = {
            description = "Cobblestone",
            tiles = {"geology_cobble.png"},
            groups = {cracky=3, stone=1, pane_connect = 1}
        },
        ["geology:sandstone"] = {
            description = "Sandstone",
            tiles = {"geology_sandstone.png"},
            groups = {cracky=3, stone=1, pane_connect = 1}
        },
        ["geology:stone"] = {
            description = "Stone",
            tiles = {"geology_stone.png"},
            is_ground_content = true,
            groups = {cracky=3, stone=1, pane_connect = 1},
            drop = "geology:cobble"
        },
        ["geology:dirt"] = {
            description = "Dirt",
            tiles = {"geology_dirt.png"},
            is_ground_content = true,
            groups = {crumbly=3, soil=1, pane_connect = 1}
        },
        ["geology:sand"] = {
            description = "Sand",
            tiles = {"geology_sand.png"},
            is_ground_content = true,
            groups = {crumbly=3, falling_node=1, sand=1, pane_connect = 1}
        },
        ["geology:gravel"] = {
            description = "Gravel",
            tiles = {"geology_gravel.png"},
            is_ground_content = true,
            groups = {crumbly=3, falling_node=1, gravel=1, pane_connect = 1}
        },
        ["geology:grass_block"] = {
            description = "Grass block",
            tiles = {
                "geology_grass.png", "geology_dirt.png", "geology_dirt_grass.png", "geology_dirt_grass.png", "geology_dirt_grass.png", "geology_dirt_grass.png"
            },
            is_ground_content = true,
            groups = {crumbly=3, soil=1, pane_connect = 1}
        },
        ["geology:coal_ore"] = {
            description = "Coal ore",
            tiles = {"geology_coal_ore.png"},
            is_ground_content = true,
            groups = {cracky=3, ore=1, pane_connect = 1},
            drop = "geology:coal"
        },
        ["geology:iron_ore"] = {
            description = "Iron ore",
            tiles = {"geology_iron_ore.png"},
            is_ground_content = true,
            groups = {cracky=3, ore=1, pane_connect = 1}
        },
        ["geology:gold_ore"] = {
            description = "Gold ore",
            tiles = {"geology_gold_ore.png"},
            is_ground_content = true,
            groups = {cracky=3, ore=1, pane_connect = 1}
        },
        ["geology:diamond_ore"] = {
            description = "Diamond ore",
            tiles = {"geology_diamond_ore.png"},
            is_ground_content = true,
            groups = {cracky=3, ore=1, pane_connect = 1},
            drop = "geology:diamond",
            stack_max = 64
        },  
    },
    yes_slab_stair = {
        "geology:cobble",
        "geology:stone",
        "geology:sandstone",
        "geology:dirt",
        "geology:sand",
        "geology:gravel",
        "geology:grass_block"
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
        }
    }
}

for k, v in pairs(geology_def_table.craftitems) do
    core.register_craftitem(k,v)    
end
for k, v in pairs(geology_def_table.nodes) do
    core.register_node(k,v)
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
