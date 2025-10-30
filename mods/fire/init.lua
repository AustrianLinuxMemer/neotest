fire = {}

function fire.get_flammable_info(pos)
    local node = core.get_node(pos)
    local flammable_level = core.get_item_group(node.name, "flammable")
    local flammable_forever = core.get_item_group(node.name, "flammable_forever") ~= 0
    return {
        is_flammable = flammable_level ~= 0,
        flammable_forever = flammable_forever,
        burntime = flammable_level * 5.42,
    }
end

function fire.encode_param2(pos)
    local directions = {
        x_plus = vector.new(pos.x+1, pos.y, pos.z),
        x_minus = vector.new(pos.x-1, pos.y, pos.z),
        y_plus = vector.new(pos.x, pos.y+1, pos.z),
        y_minus = vector.new(pos.x, pos.y-1, pos.z),
        z_plus = vector.new(pos.x, pos.y, pos.z+1),
        z_minus = vector.new(pos.x, pos.y, pos.z-1)
    }
    local bitmap = {x_plus=false, x_minus=false, y_plus=false, y_minus=false, z_plus=false, z_minus=false}
    for key, direction in pairs(directions) do
        local info = fire.get_flammable_info(direction)
        if info.is_flammable then
            bitmap[key] = true
        end
    end
    
    return (bitmap.x_plus and 1 or 0)+
        (bitmap.x_minus and 2 or 0)+
        (bitmap.y_plus and 4 or 0)+
        (bitmap.y_minus and 8 or 0)+
        (bitmap.z_plus and 16 or 0)+
        (bitmap.z_minus and 32 or 0)
end
function fire.decode_param2(param2, pos)
    local bitmap = {x_plus=false, x_minus=false, y_plus=false, y_minus=false, z_plus=false, z_minus=false}
    bitmap.x_plus = (param2 % 2) >= 1
    bitmap.x_minus = (math.floor(param2 / 2) % 2) >= 1
    bitmap.y_plus = (math.floor(param2 / 4) % 2) >= 1
    bitmap.y_minus = (math.floor(param2 / 8) % 2) >= 1
    bitmap.z_plus = (math.floor(param2 / 16) % 2) >= 1
    bitmap.z_minus = (math.floor(param2 / 32) % 2) >= 1

    local directions = {
        x_plus = vector.new(pos.x+1, pos.y, pos.z),
        x_minus = vector.new(pos.x-1, pos.y, pos.z),
        y_plus = vector.new(pos.x, pos.y+1, pos.z),
        y_minus = vector.new(pos.x, pos.y-1, pos.z),
        z_plus = vector.new(pos.x, pos.y, pos.z+1),
        z_minus = vector.new(pos.x, pos.y, pos.z-1)
    }
    local neighbors = {}
    for key, yes in pairs(bitmap) do
        if yes then
            table.insert(neighbors, directions[key])
        end
    end
    return neighbors
end


core.register_node("fire:fire", {
    description = "Fire",
    drawtype = "firelike",
    floodable = true,
    tiles = {"fire_fire.png"},
    groups = {dig_immediate = 3, fire=1},
    paramtype2 = "none",
    paramtype = "light",
    walkable = false,
    drop = "",
    light_source = core.LIGHT_MAX,
    on_timer = function(pos)
        local node = core.get_node(pos)
        local param2 = node.param2
        local neighbors = fire.decode_param2(param2, pos)
        for _, neighbor in ipairs(neighbors) do
            local neighbor_node = core.get_node(neighbor)
            local _burn = core.registered_nodes[neighbor_node.name]._burn
            if type(_burn) == "function" then
                _burn(neighbor)
            end
            core.set_node(neighbor, {name = "air"})
        end
        core.set_node(pos, {name = "air"})
    end
})

function fire.spawn(pos, info)
    local param2 = fire.encode_param2(pos)
    core.set_node(pos, {name = "fire:fire", param2 = param2})
    if not info.flammable_forever then
        local timer = core.get_node_timer(pos)
        timer:start(info.burntime)
    end
end

function fire.ignite(pointed_thing)
    local info = fire.get_flammable_info(pointed_thing.under)
    local node = core.get_node(pointed_thing.under)
    local _ignite = core.registered_nodes[node.name]._ignite
    if type(_ignite) == "function" then
        _ignite(pointed_thing.under)
    else
        fire.spawn(pointed_thing.above, info)
    end
end

core.register_tool("fire:flint_and_steel", {
    description = "Flint and Steel",
    inventory_image = "fire_flint_and_steel.png",
    on_use = function(itemstack, user, pointed_thing)
        if pointed_thing.type ~= "node" then return end
        fire.ignite(pointed_thing)
        creative_mode = core.settings:get_bool("creative_mode", false)
        if not creative_mode then
            itemstack:add_wear(65535 / 128)
            return itemstack
        end
    end
})



local function find_air_around(pos)
    local directions = {
        x_plus = vector.new(pos.x+1, pos.y, pos.z),
        x_minus = vector.new(pos.x-1, pos.y, pos.z),
        y_plus = vector.new(pos.x, pos.y+1, pos.z),
        y_minus = vector.new(pos.x, pos.y-1, pos.z),
        z_plus = vector.new(pos.x, pos.y, pos.z+1),
        z_minus = vector.new(pos.x, pos.y, pos.z-1)
    }
    local air_neighbors = {}
    for _, direction in pairs(directions) do
        local node = core.get_node(direction)
        if node.name == "air" then
            table.insert(air_neighbors, direction)
        end
    end
    return air_neighbors
end

local fire_spread = core.settings:get_bool("neotest_spread_fire", false)


core.register_abm({
    label = "Fire Spread",
    interval = 2,
    chance = 1,
    nodenames = {"group:fire", "group:igniter"},
    neighbors = {"group:flammable"},
    action = function(pos, node)
        local pos1 = pos:apply(function(n) return n-1 end)
        local pos2 = pos:apply(function(n) return n+1 end)
        local flammable_nodes = core.find_nodes_in_area(pos1, pos2, {"group:flammable"}, true)
        for category, pos_list in pairs(flammable_nodes) do
            
            for _, node_pos in ipairs(pos_list) do
                if math.random() < 0.15 then
                    local fire_info = fire.get_flammable_info(node_pos)
                    local air_around = find_air_around(node_pos)
                    if #air_around > 0 and math.random() > 0.5 then
                        local air_pos = air_around[math.random(1, #air_around)]
                        fire.spawn(air_pos, fire_info)
                    end
                end
            end
        end
    end
})