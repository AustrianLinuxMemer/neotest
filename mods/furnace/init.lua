furnace = {
    id = 1,
    subscribers = {}
}

function furnace.new_id()
    furnace.id = furnace.id + 1
    return "furnace:"..furnace.id
end
function furnace.subscribe(furnace_id, player_name)
    furnace.subscribers[furnace_id] = furnace.subscribers[furnace_id] or {}
    furnace.subscribers[furnace_id][player_name] = true
end

function furnace.unsubscribe(furnace_id, player_name)
    furnace.subscribers[furnace_id] = furnace.subscribers[furnace_id] or {}
    furnace.subscribers[furnace_id][player_name] = false
end

function furnace.unsubscribe_all(furnace_id)
    furnace.subscribers[furnace_id] = {}
end
function furnace.exists(furnace_id)
    return furnace.subscribers[furnace_id] ~= nil
end
function furnace.get_subscriber_list(furnace_id)
    local list = {}
    for player, subscribed in pairs(furnace.subscribers[furnace_id] or {}) do
        if subscribed then table.insert(list, player) end
    end
    return list
end

function furnace.multicast(furnace_id, furnace_formspec)
    local list = furnace.get_subscriber_list(furnace_id)
    formspec_helper.multicast(list, furnace_id, furnace_formspec)
end

local function generate_formspec(pos, arrow_state, fire_state, debug1)
    local preamble = "formspec_version[8]size[10.25,10]real_coordinates[true]"
    local nodemeta_expr = "nodemeta:"..tostring(pos.x)..","..tostring(pos.y)..","..tostring(pos.z)
    local lists = {
        "list["..nodemeta_expr..";input;2.75,1;1,1]",
        "list["..nodemeta_expr..";output;5.25,1.5;2,2]",
        "list["..nodemeta_expr..";fuel;2.75,3;1,1]",
        "list[current_player;main;0.25,5;8,4;]"
    }
    local images = {
        "image[3.875,2;1,1;furnace_progress_arrow_background.png]",
        "image[3.875,2;1,1;furnace_progress_arrow"..tostring(arrow_state)..".png]",
        "image[2.75,2;1,1;furnace_fire_background.png]",
        "image[2.75,2;1,1;furnace_fire"..tostring(fire_state)..".png]",
    }
    local formspec = preamble..table.concat(lists)..table.concat(images)
    if debug1 then
        return formspec.."label[1,1;4,4;"..debug1.."]"
    end
    return formspec
end

local function init_furnace(pos)
    local meta = core.get_meta(pos)
    meta:set_float("tick", 0)
    meta:set_string("furnace_id", furnace.new_id())
    local timer = core.get_node_timer(pos)
    timer:start(0.001)
end

local function deinit_furnace(pos)
    local timer = core.get_node_timer(pos)
    timer:stop()
    local meta = core.get_meta(pos)
    local furnace_id = meta:get_string("furnace_id")
    local subscribers = furnace.get_subscriber_list(furnace_id)
    furnace.unsubscribe_all(furnace_id)
    for _, subscriber in ipairs(subscribers) do
        core.close_formspec(subscriber, furnace_id)
    end
end

local function get_results(stacks)
    local fuel = {
        method = "fuel",
        width = 1,
        items = {stacks.fuel}
    }
    local input = {
        method = "cooking",
        width = 1,
        items = {stacks.input}
    }
    local fuel_output, d_fuel = core.get_craft_result(fuel)
    local input_output, d_input = core.get_craft_result(input)
    
    local recipes = {
        fuel = {
            input = stacks.fuel,
            remaining = d_fuel.items[1],
            byproducts = fuel_output.replacements,
            time = fuel_output.time,
            output = fuel_output.item
        },
        input = {
            input = stacks.input,
            remaining = d_input.items[1],
            byproducts = input_output.replacements,
            time = input_output.time,
            output = input_output.item
        }
    }
    return recipes
end

local function correct_inputs(stacks)
    local results = get_results(stacks)
    return results.fuel.time ~= 0, results.input.time ~= 0, results.fuel, results.input
end

local function active_furnace_loop(pos, elapsed)
    local meta = core.get_meta(pos)
    local inventory = meta:get_inventory()
    local remaining_burntime = meta:get_float("remaining_burntime")
    local remaining_cooktime = meta:get_float("remaining_cooktime")
    local stacks = {
        fuel = inventory:get_stack("fuel", 1),
        input = inventory:get_stack("input", 1),
    }
    local is_fuel, is_input, fuel_info, input_info = correct_inputs(stacks)

    -- If the fuel ran out, refuel
    if remaining_burntime <= 0 and is_fuel and is_input then
        remaining_burntime = fuel_info.time
        meta:set_float("total_burntime", fuel_info.time)
        inventory:set_stack("fuel", 1, fuel_info.remaining)
        for _, item in ipairs(fuel_info.byproducts) do
            local leftover = inventory:add_item("output", item)
            if not leftover:is_empty() then
                core.add_item(pos, leftover)
            end
        end
    end

    -- Dump intermediaries when cooktime is over
    if remaining_cooktime <= 0 then
        local item = ItemStack(meta:get_string("intermediary"))
        if not item:is_empty() then
            local leftover = inventory:add_item("output", item)
            if not leftover:is_empty() then
                core.add_item(pos, leftover)
            end
        end
        local replacements = core.deserialize(meta:get_string("intermediary_byproducts"), true)
        if type(replacements) == "table" then
            for _, item in ipairs(replacements) do
                local leftover = inventory:add_item("output", item)
                if not leftover:is_empty() then
                    core.add_item(pos, leftover)
                end
            end
        end
        meta:set_string("intermediary", "")
        meta:set_string("intermediary_byproducts", "")
    end

    -- If the item is done, the fire is still ithere and input is there too, reload
    if remaining_cooktime <= 0 and remaining_burntime > 0 and is_input then
        remaining_cooktime = input_info.time
        meta:set_float("total_cooktime", input_info.time)
        inventory:set_stack("input", 1, input_info.remaining)
        meta:set_string("intermediary", input_info.output:to_string())
        meta:set_string("intermediary_byproducts", core.serialize(input_info.byproducts))
    end

    
    local flame_frame = 0
    if remaining_burntime > 0 then
        local total_burntime = meta:get_float("total_burntime")
        local frac = remaining_burntime / total_burntime
        flame_frame = math.floor(frac * 12)
    end

    local arrow_frame = 0

    if remaining_cooktime > 0 then
        local total_cooktime = meta:get_float("total_cooktime")
        local frac = remaining_cooktime / total_cooktime
        arrow_frame = math.floor(frac * 12)
    end

    local furnace_id = meta:get_string("furnace_id")
    local formspec = generate_formspec(pos, arrow_frame, flame_frame, nil)
    furnace.multicast(furnace_id, formspec)

    meta:set_float("remaining_burntime", remaining_burntime - elapsed)
    meta:set_float("remaining_cooktime", remaining_cooktime - elapsed)

    local current_node = core.get_node(pos)
    if remaining_burntime > 0 then
        current_node.name = "furnace:active_furnace"
        core.swap_node(pos, current_node)
    else
        current_node.name = "furnace:furnace"
        core.swap_node(pos, current_node)
    end

    return true
end

core.register_on_player_receive_fields(function(player, formname, fields)
    if player:is_player() then
        local name = player:get_player_name()
        local is_furnace = furnace.exists(formname)
        if fields["quit"] == "true" and is_furnace then
            furnace.unsubscribe(formname, name)
            return true
        end
    end
end)

core.register_on_leaveplayer(function(player)
    for furnace_id, list in pairs(furnace.subscribers) do
        furnace.unsubscribe(furnace_id, player:get_player_name())
    end
end)

container.register_container("furnace:furnace", {
    description = "New Furnace",
    tiles = {"furnace_up_down.png", "furnace_up_down.png", "furnace_side.png", "furnace_side.png", "furnace_side.png", "furnace_front.png"},
    paramtype2 = "4dir",
    on_construct = init_furnace,
    on_destruct = deinit_furnace,
    on_timer = active_furnace_loop,
    after_place_node = base.mod_fourdir_node,
    on_rightclick = function(pos, _, clicker)
        
        local meta = core.get_meta(pos)
        local furnace_id = meta:get_string("furnace_id")
        if clicker:is_player() then
            
            local name = clicker:get_player_name()
            furnace.subscribe(furnace_id, name)
        end
    end,
    _inventory_lists = {
        {name = "fuel", size = 1},
        {name = "input", size = 1},
        {name = "output", size = 4},
    },
    groups = {oddly_breakable_by_hand = 1}
}, base.register_node)

container.register_container("furnace:active_furnace", {
    description = "New Furnace",
    tiles = {"furnace_up_down.png", "furnace_up_down.png", "furnace_side.png", "furnace_side.png", "furnace_side.png", "furnace_front_lit.png"},
    paramtype2 = "4dir",
    light_source = core.LIGHT_MAX,
    on_construct = init_furnace,
    on_destruct = deinit_furnace,
    on_timer = active_furnace_loop,
    after_place_node = base.mod_fourdir_node,
    on_rightclick = function(pos, _, clicker)
        
        local meta = core.get_meta(pos)
        local furnace_id = meta:get_string("furnace_id")
        if clicker:is_player() then
            
            local name = clicker:get_player_name()
            furnace.subscribe(furnace_id, name)
        end
    end,
    _inventory_lists = {
        {name = "fuel", size = 1},
        {name = "input", size = 1},
        {name = "output", size = 4},
    },
    groups = {oddly_breakable_by_hand = 1, virtual = 1}
}, base.register_node)

core.register_craft({
    type = "shaped",
    output = "furnace:furnace",
    recipe = {
        {"group:stone", "group:stone", "group:stone"},
        {"group:stone", "", "group:stone"},
        {"group:stone", "group:stone", "group:stone"},
    }
})