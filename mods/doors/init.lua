doors = {}
door_nodebox = {
    type = "fixed",
    fixed = {8/16, -8/16, -6/16, -8/16, 24/16, -8/16}
}
local debug_mode = core.settings:get_bool("neotest_debug", false) or false
core.register_node("doors:top_node", {
	drawtype = "airlike",
	pointable = debug_mode,
	walkable = false,
	paramtype = "light",
	sunlight_propagates = true,
    groups={no_creative=1}
})
local S = core.get_translator("mods:doors")

function doors.register_door(door_tname, door_name, door_item_texture, door_uv, groups)
    local flipped_door_uv
    if type(door_uv) == "string" then
        flipped_door_uv = door_uv.."^[transformFX"
    elseif type(door_uv) == "table" and type(door_uv.name) == "string" then
        flipped_door_uv = table.copy(door_uv)
        flipped_door_uv.name = flipped_door_uv.name.."^[transformFX"
    else
        error("door_uv was of invalid type and/or format: "..type(door_uv))
    end
    local door_item_def = {
        description = door_name,
        inventory_image = door_item_texture,
        groups = {},
        on_place = function(itemstack, placer, pointed_thing)
            if pointed_thing.type == "node" then
                local left = true
                if placer:is_player() and placer:get_player_control().aux1 then
                    left = false
                end
                if left then
                    core.place_node(pointed_thing.above, {name = door_tname.."_left"}, placer)
                else
                    core.place_node(pointed_thing.above, {name = door_tname.."_right"}, placer)
                end
            end
        end
    }
    for k, v in pairs(groups.item) do
        door_item_def.groups[k] = v
    end
    local door_node_def = {
        drawtype = "mesh",
        paramtype2 = "4dir",
        use_texture_alpha = "blend",
        mesh = "door.obj",
        selection_box = door_nodebox,
        collision_box = door_nodebox,
        groups = {door = 1, no_creative = 1, attached_node = 3},
        drop = door_tname,
        after_place_node = function(pos)
            local node = core.get_node(pos)
            local meta = core.get_meta(pos)
            local above = vector.add(pos, vector.new(0,1,0))
            meta:set_int("closed", node.param2)
            core.set_node(above, {name = "doors:top_node"})
        end,
        after_destruct = function(pos)
            local above = vector.add(pos, vector.new(0,1,0))
            core.set_node(above, {name = "air"})
        end,
        on_rightclick = function(pos, node)
            local l_door = core.get_item_group(node.name, "l_door") ~= 0
            local r_door = core.get_item_group(node.name, "r_door") ~= 0
            local meta = core.get_meta(pos)
            local closed = meta:get_int("closed")
            local state = node.param2
            local function new_state()
                if l_door then
                    if state == closed then
                        return state - 1
                    else
                        return state + 1
                    end
                elseif r_door then
                    if state == closed then
                        return state + 1
                    else
                        return state - 1
                    end
                else
                    return 0
                end
            end
            core.swap_node(pos, {name = node.name, param2 = new_state()})
        end
    }
    for k, v in pairs(groups.node) do
        door_node_def.groups[k] = v
    end
    local l_door_node_def = table.copy(door_node_def)
    l_door_node_def.groups["l_door"] = 1
    l_door_node_def.tiles = {door_uv}
    local r_door_node_def = table.copy(door_node_def)
    r_door_node_def.groups["r_door"] = 1
    r_door_node_def.tiles = {flipped_door_uv}

    base.register_node(door_tname.."_left", l_door_node_def)
    base.register_node(door_tname.."_right", r_door_node_def)
    base.register_craftitem(door_tname, door_item_def)
end

core.register_lbm({
    label = "Fix door top nodes",
    name = "doors:fix_door_top_node",
    run_at_every_load = true,
    nodenames = {"doors:top_node"},
    bulk_action = function(pos_list)
        for i, pos in ipairs(pos_list) do
            local below_node = core.get_node(vector.add(pos, vector.new(0,-1,0)))
            local is_not_door = core.get_item_group(below_node.name, "door") == 0
            if is_not_door then
                core.set_node(pos, {name = "air"})
            end
        end
    end
})

core.register_chatcommand("fixdoorair", {
    params = "pos1 pos2 [pos1 pos2]...",
    description = "Removes \"door air\"",
    privs = {server = true},
    func = function(name, param)
        local params = string.split(param, " ", false)
        if #params % 6 ~= 0 then
            return false
        end
        local cords = {}
        for i = 1, #params, 3 do
            local x = tonumber(params[i])
            local y = tonumber(params[i+1])
            local z = tonumber(params[i+2])
            if x == nil or y == nil or z == nil then
                return false
            end
            table.insert(cords, vector.new(x,y,z))
        end
        for i = 1, #cords, 2 do
            local pos1 = cords[i]
            local pos2 = cords[i+1]
            local instances = core.find_nodes_in_area(pos1, pos2, {"doors:top_node"}, true)
            if instances["doors:top_node"] ~= nil then
                for k,v in ipairs(instances["doors:top_node"]) do
                    local below = vector.new(v.x, v.y-1, v.z)
                    if core.get_item_group(core.get_node(below).name, "door") <= 0 then
                        core.set_node(v, {name = "air"})
                    end
                end
            end
        end
        return true
    end
})