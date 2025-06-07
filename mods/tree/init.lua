local types = {
    {name = "Oak", tname = "oak"}
}
local leaf_abm = {
    nodenames = {"group:leaf"},
    interval = 0.1,
    chance = 100,
    action = function(pos, node)
        local to_remove = true
        local radius = 5 -- later configurable
        for dz = -radius, radius do
            for dy = -radius, radius do
                for dx = -radius, radius do
                    local check_pos = {x = pos.x + dx, y = pos.y + dy, z = pos.z + dz}
                    local check_node = core.get_node(check_pos)
                    local group_name = core.get_item_group(check_node.name, "log")
                    if group_name > 0 then
                        to_remove = false
                        break
                    end
                end
                if not to_remove then
                    break                
                end
            end
            if not to_remove then
                break            
            end
        end
        if to_remove then
            core.set_node(pos, {name = "air"})
        end
    end
}

local sapling_abm = {
    nodenames = {"group:sapling"},
    interval = 1,
    chance = 25,
    action = function(pos, node)
        local sapling = core.get_node(pos)
        local min_blocks_above = 15 -- later configurable
        local block_beneath = core.get_node({x = pos.x, y = pos.y-1, z = pos.z})
        local viable = true
        for dy = pos.y, pos.y+min_blocks_above do
            local block_name = core.get_node({x = pos.x, y = pos.y + dy, z = pos.z}).name
            if not block_name == "air" then
                viable = false
                break
            end
        end
        local block_above = core.get_node({x = pos.x, y = pos.y+1, z = pos.z})
        if core.get_item_group(block_beneath, "soil") > 0 and viable then
            
        end
    end
}
for _, t in ipairs(types) do
    local base_name = "tree:"..t.tname
    
    local planks_def = {
        description = t.name.." Planks",
        tiles = {t.tname.."_planks.png"},
        is_ground_content = false,
        groups = {choppy=3, wood=1, pane_connect = 1}
    }
    base.register_node(base_name.."_planks", planks_def)
    fences.register_fence(base_name.."_fence", t.name.." Fence", planks_def)
    core.register_craft({
        type = "shaped",
        output = base_name.."_fence",
        recipe = {
            {base_name.."_planks", "group:stick", base_name.."_planks"},
            {base_name.."_planks", "group:stick", base_name.."_planks"}
        }
    })
    stairs.register_stair(base_name.."_planks", planks_def.description.." Stairs", planks_def, true)
    stairs.register_slab(base_name.."_planks", planks_def.description.." Slab", planks_def, true)
    
    local log_def = {
        description = t.name.." Log",
        paramtype2 = "facedir",
        tiles = {t.tname.."_log.png", t.tname.."_log.png", t.tname.."_bark.png", t.tname.."_bark.png", t.tname.."_bark.png", t.tname.."_bark.png"},
        is_ground_content = false,
        groups = {choppy=3, log=1, pane_connect = 1},
    }
    base.register_node(base_name.."_log", log_def)
    stairs.register_stair(base_name.."_log", log_def.description.." Stairs", log_def, true)
    stairs.register_slab(base_name.."_log", log_def.description.." Slab", log_def, true)
    base.register_node(base_name.."_leaves", {
        description = t.name.." leaves",
        drawtype = "allfaces_optional",
        sunlight_propagates = true,
        tiles = {t.tname.."_leaves.png"},
        is_ground_content = false,
        groups = {snappy=3, leaf=1}
    })

    base.register_node(base_name.."_sapling", {
        description = t.name.." sapling",
        drawtype = "plantlike",
        inventory_image = t.tname.."_sapling.png",
        tiles = {t.tname.."_sapling.png"},
        groups = {oddly_breakable_by_hand=1}
    })
    core.register_craft({
        type = "fuel",
        recipe = base_name.."_planks",
        burntime = 30
    })
    core.register_craft({
        type = "fuel",
        recipe = base_name.."_log",
        burntime = 30
    })
    core.register_craft({
        type = "fuel",
        recipe = base_name.."_leaves",
        burntime = 5
    })
    core.register_craft({
        type = "fuel",
        recipe = base_name.."_sapling",
        burntime = 5
    })
    core.register_craft({
    type = "shapeless",
    output = base_name.."_planks 4",
    recipe = {base_name.."_log"}
    })

    core.register_craft({
        type = "shapeless",
        output = base_name.."_sapling",
        recipe = {base_name.."_leaves"}
    })
    local tree_path = core.get_modpath("tree").."/schematics/"
    local short = tree_path..t.tname.."_tree_small.mts"
    local medium = tree_path..t.tname.."_tree_medium.mts"
    local large = tree_path..t.tname.."_tree_large.mts"
    -- Forest trees
    core.register_decoration({
        deco_type = "schematic",
        place_on = {"geology:grass_block"},
        sidelen = 16,
        fill_ratio = 0.1,
        biomes = {"temperate_forest"},
        y_max = 4000,
        schematic = short,
        flags = "place_center_x, place_center_z",
        rotation = "random",
    })
    core.register_decoration({
        deco_type = "schematic",
        place_on = {"geology:grass_block"},
        sidelen = 16,
        fill_ratio = 0.1,
        biomes = {"temperate_forest"},
        y_max = 3500,
        schematic = medium,
        flags = "place_center_x, place_center_z",
        rotation = "random",
    })
    core.register_decoration({
        deco_type = "schematic",
        place_on = {"geology:grass_block"},
        sidelen = 16,
        fill_ratio = 0.1,
        biomes = {"temperate_forest"},
        y_max = 3000,
        schematic = large,
        flags = "place_center_x, place_center_z",
        rotation = "random",
    })
    -- Trees in non-forests
    core.register_decoration({
        deco_type = "schematic",
        place_on = {"geology:grass_block"},
        sidelen = 16,
        fill_ratio = 0.001,
        biomes = {"temperate"},
        y_max = 4000,
        schematic = short,
        flags = "place_center_x, place_center_z",
        rotation = "random",
    })
    core.register_decoration({
        deco_type = "schematic",
        place_on = {"geology:grass_block"},
        sidelen = 16,
        fill_ratio = 0.001,
        biomes = {"temperate"},
        y_max = 3500,
        schematic = medium,
        flags = "place_center_x, place_center_z",
        rotation = "random",
    })
    core.register_decoration({
        deco_type = "schematic",
        place_on = {"geology:grass_block"},
        sidelen = 16,
        fill_ratio = 0.001,
        biomes = {"temperate"},
        y_max = 3000,
        schematic = large,
        flags = "place_center_x, place_center_z",
        rotation = "random",
    })
end
base.register_craftitem("tree:stick", {
    description = "Stick",
    inventory_image = "tree_stick.png",
    groups = {stick=1}
})
core.register_craft({
    type = "shaped",
    output = "tree:stick 4",
    recipe = {{"group:wood"}, {"group:wood"}}
})
core.register_abm(leaf_abm)
core.register_abm(sapling_abm)
