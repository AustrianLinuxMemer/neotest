local types = {
    {name = "Oak", tname = "oak"}
}
local schematics = {
    ["tree:oak_sapling"] = {
        {name = core.get_modpath("tree").."/schematics/oak_tree_large.mts", stem_dimension = vector.new(1,4,1), crown_dimension = vector.new(5,5,5)},
        {name = core.get_modpath("tree").."/schematics/oak_tree_medium.mts", stem_dimension = vector.new(1,3,1), crown_dimension = vector.new(5,5,5)},
        {name = core.get_modpath("tree").."/schematics/oak_tree_small.mts", stem_dimension = vector.new(1,2,1), crown_dimension = vector.new(5,5,5)},
    }
}
local valid_grow_nodes = {
    ["geology:dirt"] = true,
    ["geology:grass_block"] = true
}
local function count_air(pos1, pos2, nodenames)
    local table = core.find_nodes_in_area(pos1, pos2, nodenames, true)
    local count = 0
    for _, c in pairs(table) do
        count = count + #c
    end
    return count
end
local function calc_volume(pos1, pos2)
    local dx = pos2.x - pos1.x + 1
    local dy = pos2.y - pos1.y + 1
    local dz = pos2.z - pos1.z + 1
    return dx * dy * dz
end
local function place_if_space(center_pos, schematic, sapling_name)
    halves = {
        stem = {
            x = (schematic.stem_dimension.x - 1) / 2,
            y = (schematic.stem_dimension.y - 1) / 2,
            z = (schematic.stem_dimension.z - 1) / 2,
        },
        crown = {
            x = (schematic.crown_dimension.x - 1) / 2,
            y = (schematic.crown_dimension.y - 1) / 2,
            z = (schematic.crown_dimension.z - 1) / 2,
        }
    }
    pmin = {
        stem = vector.new(center_pos.x - halves.stem.x, center_pos.y, center_pos.z - halves.stem.z),
        crown = vector.new(center_pos.x - halves.crown.x, center_pos.y + schematic.stem_dimension.y, center_pos.z - halves.crown.z)
    }
    pmax = {
        stem = vector.new(center_pos.x + halves.stem.x, center_pos.y + schematic.stem_dimension.y, center_pos.z + halves.stem.z),
        crown = vector.new(center_pos.x + halves.crown.x, center_pos.y + schematic.stem_dimension.y + schematic.crown_dimension.y, center_pos.z + halves.crown.z)
    }
    nodes = {
        stem = count_air(pmin.stem, pmax.stem, {"air", sapling_name}),
        crown = count_air(pmin.crown, pmax.crown, {"air"})
    }
    volume = {
        stem = calc_volume(pmin.stem, pmax.stem),
        crown = calc_volume(pmin.crown, pmax.crown)
    }
    local place_at = vector.new(center_pos.x - halves.crown.x, center_pos.y, center_pos.z - halves.crown.z)
    if nodes.stem == volume.stem and nodes.crown == volume.crown then
        core.place_schematic(place_at, schematic.name, "random", nil, true)
    else
        local timer = core.get_node_timer(center_pos)
        timer:set(math.random(15, 25))
    end
end
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
            local node = core.get_node(pos)    
            local node_drops = core.get_node_drops(node, ":")
            core.set_node(pos, {name = "air"})
            for _, v in pairs(node_drops) do
                core.add_item(pos, v)
            end
        end
    end
}
local function sapling_grows(pos)
    local ground = core.get_node({pos.x, pos.y - 1, pos.z})
    local sapling = core.get_node(pos)
    local valid_ground = valid_grow_nodes[ground.name]
    local schematic_list = schematics[sapling.name]
    if schematic_list ~= nil then
        local schematic = schematic_list[math.random(#schematic_list)]
        place_if_space(pos, schematic, sapling.name)
    end
end

for _, t in ipairs(types) do
    local base_name = "tree:"..t.tname
    local texture_base_name = "tree_"..t.tname
    local planks_def = {
        description = t.name.." Planks",
        tiles = {texture_base_name.."_planks.png"},
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
    local door_name = base_name.."_door"
    local door_def = table.copy(planks_def)
    door_def.inventory_image = texture_base_name.."_door_item.png"
    door_def.description = t.name.." Door"
    door_def.use_texture_alpha = "blend"
    door_def.tiles = {{name = texture_base_name.."_door.png", backface_culling=true}}
    doors.register_door(door_name, door_def)
    core.register_craft({
    	type = "shaped",
    	output = door_name.." 3",
    	recipe = {
    		{base_name.."_planks", base_name.."_planks"},
    		{base_name.."_planks", base_name.."_planks"},
    		{base_name.."_planks", base_name.."_planks"}
    	}
    })
    local log_def = {
        description = t.name.." Log",
        paramtype2 = "facedir",
        tiles = {texture_base_name.."_log.png", texture_base_name.."_log.png", texture_base_name.."_bark.png", texture_base_name.."_bark.png", texture_base_name.."_bark.png", texture_base_name.."_bark.png"},
        is_ground_content = false,
        groups = {choppy=3, log=1, pane_connect = 1},
        after_place_node = base.mod_column
    }
    base.register_node(base_name.."_log", log_def)
    stairs.register_stair(base_name.."_log", log_def.description.." Stairs", log_def, true)
    stairs.register_slab(base_name.."_log", log_def.description.." Slab", log_def, true)
    base.register_node(base_name.."_leaves", {
        description = t.name.." leaves",
        drawtype = "allfaces_optional",
        sunlight_propagates = true,
        tiles = {texture_base_name.."_leaves.png"},
        is_ground_content = false,
        groups = {snappy=1, leaf=1},
        drop = {
            max_items = 1,
            items = {
                {rarity = 1, tools = {"tools:shears"}, items = {base_name.."_leaves"}},
                {rarity = 2, items = {base_name.."_sapling"}},
                {rarity = 2, items = {"tree:stick"}}
            }
        }
    })

    base.register_node(base_name.."_sapling", {
        description = t.name.." sapling",
        drawtype = "plantlike",
        inventory_image = texture_base_name.."_sapling.png",
        tiles = {texture_base_name.."_sapling.png"},
        groups = {oddly_breakable_by_hand=1, sapling=1},
        on_timer = sapling_grows,
        on_construct = function(pos)
            local timer = core.get_node_timer(pos)
            timer:start(math.random(15, 30))
        end
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
        fill_ratio = 0.02,
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
        fill_ratio = 0.02,
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
        fill_ratio = 0.02,
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
        fill_ratio = 0.002,
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
        fill_ratio = 0.002,
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
        fill_ratio = 0.002,
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
