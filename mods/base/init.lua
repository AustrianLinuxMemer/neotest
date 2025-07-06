base = {}
local transparent_drawtypes = {
    normal = false,
    airlike = true,
    liquid = false,
    flowingliquid = false,
    glasslike = true,
    glasslike_framed = true,
    glasslike_framed_optional = true,
    allfaces = true,
    allfaces_optional = true,
    torchlike = true,
    signlike = true,
    plantlike = true,
    firelike = true,
    fencelike = true,
    raillike = true,
    nodebox = true,
    mesh = true,
    plantlike_rooted = true
}
function base.is_transparent(pos)
    local node_name = core.get_node(pos).name
    local node_def = core.registered_nodes[node_name]
    if node_def ~= nil then
        local transparent_by_drawtype = transparent_drawtypes[node_def.drawtype]
        local transparent_by_sunlight_propagates = node_def.sunlight_propagates
        return transparent_by_drawtype or transparent_by_sunlight_propagates
    else
        return false
    end
end
function base.dir_to_facedir_column(direction)
    if direction.y ~= 0 then return 0 end
    if direction.z ~= 0 then return 4 end
    if direction.x ~= 0 then return 12 end
    return 0
end

function base.dir_to_facedir_stair(pitch, yaw)
    local upright = pitch > 0
    local facedir = minetest.dir_to_facedir({x = math.cos(yaw+math.pi/2), y = 0, z = math.sin(yaw+math.pi/2)})
    core.chat_send_all(facedir)
    local param2_map = {
        [true] = {0, 1, 2, 3},
        [false] = {20, 23, 22, 21},
    }
    return param2_map[upright][facedir + 1]
end

function base.dir_to_fourdir(direction, yaw)
    if direction.y ~= 0 then
        -- Placed on top of a node, needing yaw
        return core.dir_to_facedir({x = math.cos(yaw+math.pi/2), y = 0, z = math.sin(yaw+math.pi/2)})
    else
        -- Placed against a node, not needing yaw, negating vector to make the block face towards the player
        local opposite = vector.multiply(direction, -1)
        return core.dir_to_fourdir(opposite)
    end

end

function base.mod_column(pos, placer, itemstack, pointed_thing)
    local direction = vector.subtract(pointed_thing.above, pointed_thing.under)
    local pos = vector.add(direction, pointed_thing.under)
    local node = core.get_node(pos)
    node.param2 = base.dir_to_facedir_column(direction)
    core.swap_node(pos, node)
    return core.settings:get_bool("creative_mode", false)
end

function base.mod_stair(pos, placer, itemstack, pointed_thing)
    local direction = vector.subtract(pointed_thing.above, pointed_thing.under)
    local pos = vector.add(direction, pointed_thing.under)
    local pitch = placer:get_look_vertical()
    local yaw = placer:get_look_horizontal()
    local node = core.get_node(pos)
    node.param2 = base.dir_to_facedir_stair(pitch, yaw)
    core.swap_node(pos, node)
    return core.settings:get_bool("creative_mode", false)
end

function base.mod_fordir_node(pos, placer, itemstack, pointed_thing)
    local direction = vector.subtract(pointed_thing.above, pointed_thing.under)
    local pos = vector.add(direction, pointed_thing.under)
    local yaw = placer:get_look_horizontal()
    local node = core.get_node(pos)
    node.param2 = base.dir_to_fourdir(direction)
    core.swap_node(pos, node)
    return core.settings:get_bool("creative_mode", false)
end

function base.round(number, n)
    local function value_of_digit(number, digits)
        local digits_int = math.floor(digits)
        local shifted = number * (10^digits)
        local shifted_int = math.floor(shifted)
        return shifted_int % 10
    end
    
    if type(n) ~= "number" then
        n = 1
    end
    local n_int = math.floor(n)
    local digit_after = value_of_digit(number, n_int + 1)
    local factor = 10 ^ n_int
    if digit_after >= 5 then
        return math.ceil(number*factor) / factor
    else
        return math.floor(number*factor) / factor
    end
end

function base.register_craftitem(name, def)
    def.stack_max = def.stack_max or 64
    core.register_craftitem(name, def)
end

function base.register_node(name, def)
    def.stack_max = def.stack_max or 64
    core.register_node(name, def)
end

function base.log_protection_violation(pos, player_name, action)
    core.log("action", "[Protection] "..player_name.." tried to "..action.." at "..vector.to_string(pos))
end

function base.communicate_protection_violation(pos, player_name, action)
    core.chat_send_player(player_name, "You are not allowed to do "..action.." at "..vector.to_string(pos))
end

function base.is_protected(pos, player_name, action)
    if core.is_protected(pos, player_name) then
        base.log_protection_violation(pos, player_name, action)
        base.communicate_protection_violation(pos, player_name, action)
        return true
    else
        return false
    end
end
local neotest_debug = core.settings:get_bool("neotest_debug", false)

function base.chat_send_all_debug(msg)
    if neotest_debug then
        core.chat_send_all(msg)
    end
end
function base.chat_send_player_debug(player_name, msg)
    if neotest_debug then
        core.chat_send_player(player_name, msg)
    end
end

function base.utf_8_iter(s)
	local pos = 1
    local len = #s
    return function()
        if pos > len then return nil end
        local c = string.byte(s, pos)
        local char_len = 1
        if c >= 0xF0 then
            char_len = 4
        elseif c >= 0xE0 then
            char_len = 3
        elseif c >= 0xC0 then
            char_len = 2
        end
        local char = string.sub(s, pos, pos + char_len - 1)
        pos = pos + char_len
        return char
    end
end