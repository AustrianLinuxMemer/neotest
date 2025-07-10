local S = core.get_translator("mods:tree")
local trees = dofile(core.get_modpath("tree").."/l_system.lua")
local types = {
    oak = {
        wood_name = S("Oak"),
        wood_tname = "oak",
        base_groups = {choppy=3, planks=1, pane_connect=1}
    }
}
local function sapling_grows(pos, tree_type)
    local available_trees = trees[tree_type]
    local tree_name = available_trees.indices[math.random(#available_trees.indices)]
    local ltree = available_trees[tree_name]
    trees.place_ltree(pos, ltree, tree_type)
end
for t, wood_type in pairs(types) do
    local node_base_name = "tree:"..t
    local texture_prefix = "tree_"..t

    local planks_name = node_base_name.."_planks"
    local door_name = node_base_name.."_door"
    local log_name = node_base_name.."_log"
    local leaves_name = node_base_name.."_leaves"
    local sapling_name = node_base_name.."_sapling"
    local fence_name = node_base_name.."_fence"

    -- Planks, Stairs, Slab
    local planks_def = {
        description = S("@1 Planks", wood_type.wood_name),
        tiles = {texture_prefix.."_planks.png"},
        groups = {choppy=3, planks=1, pane_connect=1}
    }
    core.register_node(planks_name, table.copy(planks_def))
    stairs.register_stair(planks_name, S("@1 Stairs", wood_type.wood_name), table.copy(planks_def), true)
    stairs.register_slab(planks_name, S("@1 Slabs", wood_type.wood_name), table.copy(planks_def), true)


    -- Door
    local door_def = table.copy(planks_def)
    door_def.inventory_image = texture_prefix.."_door_item.png"
    door_def.description = S("@1 Door", wood_type.wood_name)
    door_def.use_texture_alpha = "blend"
    door_def.tiles = {{name = texture_prefix.."_door.png", backface_culling=true}}
    doors.register_door(door_name, door_def)
    core.register_craft({
        type = "shaped",
        output = door_name,
        recipe = {
            {planks_name, planks_name},
            {planks_name, planks_name},
            {planks_name, planks_name}
        }
    })

    -- Log
    local log_def = table.copy(planks_def)
    log_def.description = S("@1 Log", wood_type.wood_name)
    log_def.tiles = {texture_prefix.."_log.png", texture_prefix.."_log.png", texture_prefix.."_bark.png"}
    log_def.groups["log"] = 1
    base.register_node(log_name, log_def)

    -- Leaves and Sapling
    local leaves_def = {
        description = S("@1 Leaves", wood_type.wood_name),
        drawtype = "allfaces_optional",
        sunlight_propagates = true,
        tiles = {texture_prefix.."_leaves.png"},
        is_ground_content = false,
        groups = {snappy=1, leaf=1},
        drop = {
            max_items = 1,
            items = {
                {rarity = 1, tools = {"group:shears"}, items = {leaves_name}},
                {rarity = 2, items = {sapling_name}},
                {rarity = 2, items = {"tree:stick"}}
            }
        }
    }
    base.register_node(leaves_name, leaves_def)
    local sapling_def = {
        description = S("@1 Sapling", wood_type.wood_name),
        drawtype = "plantlike",
        walkable = false,
        sunlight_propagates = true,
        inventory_image = texture_prefix.."_sapling.png",
        tiles = {texture_prefix.."_sapling.png"},
        groups = {oddly_breakable_by_hand=1, sapling=1},
        on_timer = function(pos) sapling_grows(pos, t) end,
        on_construct = function(pos)
            local timer = core.get_node_timer(pos)
            timer:start(math.random(15, 30))
        end,
    }
    base.register_node(sapling_name, sapling_def)

    -- Fences
    fences.register_fence(fence_name, S("@1 Fence", wood_type.wood_name), table.copy(planks_def))
    core.register_craft({
        type = "shaped",
        output = fence_name,
        recipe = {
            {planks_name, "group:stick", planks_name},
            {planks_name, "group:stick", planks_name},
        }
    })
end