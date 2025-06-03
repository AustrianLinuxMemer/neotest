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
function base.rad_to_deg(rad)
    return ((rad)/(2*math.pi))*360
end
function base.rad_to_facedir(rad_player)
    local dir = {
        math.pi/4,
        (3*math.pi)/4,
        (5*math.pi)/4,
        (7*math.pi)/4
    }
    local rad = rad_player % (2*math.pi)
    if rad >= dir[4] or rad < dir[1] then
        return 2
    elseif rad >= dir[1] and rad < dir[2] then
        return 1
    elseif rad >= dir[2] and rad < dir[3] then
        return 0
    elseif rad >= dir[3] and rad < dir[4] then
        return 3
    end
end

function base.correct_orientation_after_place_node(pos, placer, itemstack, pointed_thing)
    if placer ~= nil and placer:is_player() then
        local rot = placer:get_look_horizontal()
        local node = core.get_node(pos)
        node.param2 = base.rad_to_facedir(rot+math.pi)
        core.swap_node(pos, node)
    end
    return false
end

function base.to_facedir(dir, rot)
    if dir >= 0 and dir <= 5 and rot >= 0 and rot <= 3 then
        return dir * 4 + rot
    end
end
function base.from_facedir(facedir)
    return {dir = math.floor(facedir / 4), rot = facedir % 4}
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