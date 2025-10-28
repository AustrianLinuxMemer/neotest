fire = {
    spaces = function(pos)
        local space = {
            [1] = vector.new(pos.x + 1, pos.y, pos.z),
            [2] = vector.new(pos.x - 1, pos.y, pos.z),
            [3] = vector.new(pos.x, pos.y + 1, pos.z),
            [4] = vector.new(pos.x, pos.y - 1, pos.z),
            [5] = vector.new(pos.x, pos.y, pos.z + 1),
            [6] = vector.new(pos.x, pos.y, pos.z - 1),
        }
        return space
    end,
    reverse_spaces = function(pos)
        local space = {
            [2] = vector.new(pos.x + 1, pos.y, pos.z),
            [1] = vector.new(pos.x - 1, pos.y, pos.z),
            [4] = vector.new(pos.x, pos.y + 1, pos.z),
            [3] = vector.new(pos.x, pos.y - 1, pos.z),
            [6] = vector.new(pos.x, pos.y, pos.z + 1),
            [5] = vector.new(pos.x, pos.y, pos.z - 1),
        }
        return space
    end
}



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
        
        local node_fire = core.get_node(pos)
        local node_pos = fire.reverse_spaces(pos)[node_fire.param2]
        local node = core.get_node(node_pos)
        local node_name = node.name
        local def = core.registered_nodes[node_name] or {_burn = nil}
        local is_flammable = core.get_item_group(node_name, "flammable") ~= 0
        if is_flammable then
            if def._burn then
                def._burn(node_pos)
            else
                core.set_node(node_pos, {name = "air"})
            end
        end
        core.chat_send_all("expired")
        core.set_node(pos, {name = "air"})
    end
})

function fire.spawn(pos)
    local node = core.get_node(pos)
    local node_name = node.name
    local flammable_level = core.get_item_group(node_name, "flammable")
    local flammable_forever = core.get_item_group(node_name, "flammable_forever") ~= 0
    for i, space in pairs(fire.spaces(pos)) do
        local node_space = core.get_node(space)
        local node_space_name = node_space.name
        local node_space_def = core.registered_nodes[node_space_name] or {buildable_to = false}
        if node_space_def.buildable_to then
            core.chat_send_all("fire set to "..node_name..";"..flammable_level..";"..tostring(flammable_forever))
            core.set_node(space, {name = "fire:fire", param2 = i})
            local timer = core.get_node_timer(space)
            if flammable_level > 0 then
                timer:start((flammable_level)*5.42)
            elseif not flammable_forever then
                timer:start(1.5)
            end
        end
    end
end

core.register_tool("fire:flint_and_steel", {
    description = "Flint and Steel",
    inventory_image = "fire_flint_and_steel.png",
    on_use = function(itemstack, user, pointed_thing)
        if pointed_thing.type ~= "node" then return end
        local above_node = core.get_node(pointed_thing.above)
        local under_node = core.get_node(pointed_thing.under)
        local above_def = core.registered_nodes[above_node.name] or {buildable_to = false}
        pos = pointed_thing.under
        fire.spawn(pos)
        creative_mode = core.settings:get_bool("creative_mode", false)
        if not creative_mode then
            itemstack:add_wear(65535 / 128)
            return itemstack
        end
    end
})

core.register_abm({
    label = "Fire spread",
    nodenames = {"group:fire"},
    interval = 3,
    chance = 2,
    action = function(pos)
        min = pos:apply(function(n) return n - 1 end)
        max = pos:apply(function(n) return n + 1 end)
        local nodes_by_name = core.find_nodes_in_area(min, max, {"group:flammable"}, true)
        for nodename, positions in pairs(nodes_by_name) do
            local flammability = math.min(core.get_item_group(nodename, "flammability") + 15, 100)
            for _, pos in ipairs(positions) do
                if math.random() < flammability/100 then
                    fire.spawn(pos)
                end
            end
        end
    end
})