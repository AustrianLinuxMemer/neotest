base = {}
transparent_drawtypes = {
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
        return transparent_by_drawtype or transparent_by_paramtype or transparent_by_sunlight_propagates
    else
        return false
    end
end
function base.dir_to_facedir_column(direction)
    if direction.x ~= 0 then
        if direction.x > 0 then
            return 3*4
        else
            return 4*4
        end
    elseif direction.y ~= 0 then
        if direction.y > 0 then
            return 0*4
        else
            return 5*4
        end
    elseif direction.z ~= 0 then
        if direction.z > 0 then
            return 1*4
        else
            return 2*4
        end
    else
        return 0
    end
end

function base.dir_to_facedir_stair(pitch, yaw)
    local upside_down = yaw > 0
    local dir = {
        math.pi/4,
        (3*math.pi)/4,
        (5*math.pi)/4,
        (7*math.pi)/4
    }
    local param2 = {
        [true] = {
            [0] = 0,
            [1] = 3,
            [2] = 2,
            [3] = 1,
        },
        [false] = {
            [0] = 20,
            [1] = 21,
            [2] = 22,
            [3] = 23,
        }
    }
    local rad = pitch
    if rad >= dir[4] or rad < dir[1] then
        return param2[upside_down][0]
    elseif rad >= dir[1] and rad < dir[2] then
        return param2[upside_down][1]
    elseif rad >= dir[2] and rad < dir[3] then
        return param2[upside_down][2]
    elseif rad >= dir[3] and rad < dir[4] then
        return param2[upside_down][3]
    end
end

function base.sixdir_place_node_column(itemstack, placer, pointed_thing)
    local direction = vector.subtract(pointed_thing.above, pointed_thing.under)
    local pos = vector.add(direction, pointed_thing.under)
    local node = {name = itemstack:get_name(), param2 = base.dir_to_facedir_column(direction)}
    itemstack:take_item(1)
    core.set_node(pos, node)
    return itemstack
end

function base.place_node_stair(itemstack, placer, pointed_thing)
    local direction = vector.subtract(pointed_thing.above, pointed_thing.under)
    local pos = vector.add(direction, pointed_thing.under)
    local pitch = placer:get_look_horizontal()
    local yaw = placer:get_look_vertical()
    local node = {name = itemstack:get_name(), param2 = base.dir_to_facedir_stair(pitch, yaw)}
    itemstack:take_item(1)
    core.set_node(pos, node)
    return itemstack
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