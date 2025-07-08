dofile(core.get_modpath("tree").."/l_system.lua")

local types = {
    {name = "Oak", tname = "oak"}
}
local valid_grow_nodes = {
    ["geology:dirt"] = true,
    ["geology:grass_block"] = true
}
local function place_ltree(center_pos, ltree, tree_type)
    local corner_1 = vector.new(center_pos.x-25, center_pos.y, center_pos.z-25)
    local corner_2 = vector.new(center_pos.x+25, center_pos.y+75, center_pos.z+25)
    
    local lvm, emin, emax = core.get_voxel_manip(corner_1, corner_2)
    local voxelarea = VoxelArea(emin, emax)
    local old_data = lvm:get_data()
    core.spawn_tree_on_vmanip(lvm, center_pos, ltree)

    local new_data = lvm:get_data()
    -- Check if non-air nodes are overridden
    local is_tree_node = {
        [core.get_content_id("tree:"..tree_type.."_log")] = true,
        [core.get_content_id("tree:"..tree_type.."_leaves")] = true
    }
    for i = 1, #old_data do
        local old_id = old_data[i]
        local new_id = new_data[i]
        if is_tree_node[new_id] and old_id ~= core.CONTENT_AIR then
            base.chat_send_all_debug("Tree growth failed")
            return false
        end
    end
    lvm:write_to_map()
    core.set_node(center_pos, {name = "tree:"..tree_type.."_log"})
    return true
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
local function sapling_grows(pos, tree_type)
    local available_trees = trees[tree_type]
    local tree_name = available_trees.indices[math.random(#available_trees.indices)]
    local ltree = available_trees[tree_name]
    place_ltree(pos, ltree, tree_type)
end

for _, t in ipairs(types) do
    -- technical names
    local base_name = "tree:"..t.tname
    local texture_base_name = "tree_"..t.tname
	local log_name = "tree:"..t.tname.."_log"
	local planks_name = "tree:"..t.tname.."_planks"
	local fence_name = "tree:"..t.tname.."_fence"
	local sapling_name = "tree:"..t.tname.."_sapling"
    local door_name = "tree:"..t.tname.."_door"

    -- human name

    local planks_def = {
        description = t.name.." Planks",
        tiles = {texture_base_name.."_planks.png"},
        is_ground_content = false,
        groups = {choppy=3, planks=1, pane_connect = 1}
    }
    base.register_node(planks_name, planks_def)
    fences.register_fence(fence_name, t.name.." Fence", planks_def)
    core.register_craft({
        type = "shaped",
        output = fence_name,
        recipe = {
            {planks_name, "group:stick", planks_name},
            {planks_name, "group:stick", planks_name}
        }
    })
    stairs.register_stair(planks_name, planks_def.description.." Stairs", planks_def, true)
    stairs.register_slab(planks_name, planks_def.description.." Slab", planks_def, true)
    
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
    		{planks_name, planks_name},
    		{planks_name, planks_name},
    		{planks_name, planks_name}
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
                {rarity = 1, tools = {"group:shears"}, items = {base_name.."_leaves"}},
                {rarity = 2, items = {base_name.."_sapling"}},
                {rarity = 2, items = {"tree:stick"}}
            }
        }
    })

    base.register_node(base_name.."_sapling", {
        description = t.name.." sapling",
        drawtype = "plantlike",
        walkable = false,
        sunlight_propagates = true,
        inventory_image = texture_base_name.."_sapling.png",
        tiles = {texture_base_name.."_sapling.png"},
        groups = {oddly_breakable_by_hand=1, sapling=1},
        on_timer = function(pos) sapling_grows(pos, t.tname) end,
        on_construct = function(pos)
            local timer = core.get_node_timer(pos)
            timer:start(math.random(15, 30))
        end,
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

	core.register_decoration({
		deco_type = "lsystem",
		place_on = {"geology:grass_block"},
        biomes = {"temperate_forest"},
		sidelen = 16,
		fill_ratio = 0.01,
		treedef = trees[t.tname]["large"]
	})
    core.register_decoration({
		deco_type = "lsystem",
		place_on = {"geology:grass_block"},
        biomes = {"temperate"},
		sidelen = 16,
		fill_ratio = 0.0005,
		treedef = trees[t.tname]["large"]
	})
    core.register_decoration({
		deco_type = "lsystem",
		place_on = {"geology:grass_block"},
        biomes = {"temperate_forest"},
		sidelen = 16,
		fill_ratio = 0.01,
		treedef = trees[t.tname]["medium"]
	})
    core.register_decoration({
		deco_type = "lsystem",
		place_on = {"geology:grass_block"},
        biomes = {"temperate"},
		sidelen = 16,
		fill_ratio = 0.0005,
		treedef = trees[t.tname]["medium"]
	})
    loot.add_to_loot_pool({item = base_name.."_log", max_q = 16, prob = 0.2, keys = {"temperate"}})
    loot.add_to_loot_pool({item = base_name.."_planks", max_q = 16, prob = 0.2, keys = {"temperate"}})
    loot.add_to_loot_pool({item = base_name.."_door", max_q = 16, prob = 0.2, keys = {"temperate"}})
    loot.add_to_loot_pool({item = base_name.."_sapling", max_q = 16, prob = 0.2, keys = {"temperate"}})
end
base.register_craftitem("tree:stick", {
    description = "Stick",
    inventory_image = "tree_stick.png",
    groups = {stick=1}
})
core.register_craft({
    type = "shaped",
    output = "tree:stick 4",
    recipe = {{"group:planks"}, {"group:planks"}}
})
core.register_abm(leaf_abm)
loot.add_to_loot_pool({item = "tree:stick", max_q = 16, prob = 0.2})