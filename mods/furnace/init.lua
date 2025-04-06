local furnace_ui = 

local function generate_furnace_ui(remaining_fuel, remaining_item)
    "formspec_version[8]".."size[11,10]".."real_coordinates[true]".."list[context;fuel;3.5,3;1,1;]".."list[context;input;3.5,1;1,1;]".."list[context;result;6,2;2,2;]".."list[current_player;main;0.5,5;8,4;]"
end

local function init_furnace(pos)
    local meta = core.get_meta(pos)
    local inv = meta:get_inventory()
    inv:set_size("fuel", 1)
    inv:set_size("input", 1)
    inv:set_size("temp", 1)
    inv:set_size("result", 1)
end
local function open_furnace(pos, node, player, itemstack, pointed_thing)
    local meta = minetest.get_meta(pos)
    --Adding the player to the subscriber list
    local furnace_name = "furnace:furnace_"..vector.to_string(pos)
    local player_meta = player:get_meta()
    player_meta:set_string("furnace_name", furnace_name)
    formspec_helper:subscribe(player:get_player_name(), furnace_name)
    formspec_helper:multicast("furnace:furnace_"..vector.to_string(pos), meta:get_string("formspec"))
end

core.register_on_player_receive_fields(function(player, formname, fields) 
    local player_meta = player:get_meta()
    local furnace_name = meta:get_string("furnace_name")
    if formname == furnace_name then
        if fields["quit"] == "true" then
            formspec_helper:unsubscribe(player:get_player_name(), furnace_name)
        end
    end
end)

local function set_furnace_active(pos, on)
    local furnace_data = core.get_node(pos)
    local furnace_type = furnace_data.name
    local param2 = furnace_data.param2
    if on and furnace_type == "furnace:furnace" then
        core.swap_node(pos, {name = "furnace:active_furnace", param2 = furnace_data.param2})    
    elseif not on and furnace_type == "furnace:active_furnace" then
        core.swap_node(pos, {name = "furnace:furnace", param2 = furnace_data.param2})
    end
end
local function furnace_loop(pos, node, active_object_count, active_object_count_wider)
    local meta = core.get_meta(pos)
    local inv = meta:get_inventory()
    local fuel_stack = inv:get_stack("fuel", 1)
    local input_stack = inv:get_stack("input", 1)
    local output_stack = inv:get_stack("result", 1)
    local temp_stack = inv:get_stack("temp", 1)
    local output = core.get_craft_result({
        method = "cooking",
        width = 1,
        items = {input_stack}
    })
    local fuel = core.get_craft_result({
        method = "fuel",
        width = 1,
        items = {fuel_stack}        
    })

    formspec_helper:multicast("furnace:furnace_"..vector.to_string(pos), meta:get_string("formspec"))
    local remaining_fuel = meta:get_int("remaining_fuel")
    local remaining_item = meta:get_int("remaining_item")
    if remaining_fuel > 0 then
        meta:set_int("remaining_fuel", remaining_fuel - 1)
        set_furnace_active(pos, true)
        if remaining_item > 0 then
            meta:set_int("remaining_item", remaining_item - 1)
        else
            -- Empty out the temp stack
            if not temp_stack:is_empty() then
                output_stack:add_item(temp_stack)
                temp_stack:clear()            
            end
            -- Putting in the next item
            if not input_stack:is_empty() and not output.item:is_empty() then
                input_stack:take_item(1)
                temp_stack:add_item(output.item)
                meta:set_int("remaining_item", output.time)
            end
        end
    else
        if not fuel_stack:is_empty() and fuel.time ~= 0 and not input_stack:is_empty() then
            fuel_stack:take_item(1)
            meta:set_int("remaining_fuel", fuel.time)
            set_furnace_active(pos, true)
        else
            set_furnace_active(pos, false)
            meta:set_int("remaining_item", 0)
            temp_stack:clear()
        end
    end
    
    inv:set_stack("fuel", 1, fuel_stack)
    inv:set_stack("input", 1, input_stack)
    inv:set_stack("result", 1, output_stack)
    inv:set_stack("temp", 1, temp_stack)
end

core.register_node("furnace:furnace", {
    description = "Furnace",
    paramtype2 = "facedir",
    tiles = {"furnace_up_down.png", "furnace_up_down.png", "furnace_side.png", "furnace_side.png", "furnace_side.png", "furnace_front.png"},
    groups = {cracky = 3},
    on_construct = init_furnace,
    on_rightclick = open_furnace,
    after_place_node = base.correct_orientation_after_place_node
})

core.register_node("furnace:active_furnace", {
    description = "Furnace (active)",
    paramtype2 = "facedir",
    tiles = {"furnace_up_down.png", "furnace_up_down.png", "furnace_side.png", "furnace_side.png", "furnace_side.png", "furnace_front_lit.png"},
    groups = {cracky = 3},
    light_source = core.LIGHT_MAX,
    on_construct = init_furnace,
    on_rightclick = open_furnace,
    drop = "furnace:furnace",
    after_place_node = base.correct_orientation_after_place_node
})

core.register_craft({
    type = "shaped",
    output = "furnace:furnace",
    recipe = {
        {"group:stone", "group:stone", "group:stone"},
        {"group:stone", "", "group:stone"},
        {"group:stone", "group:stone", "group:stone"}
    }
})

local function nice_percent(ratio)
    return tostring(math.round(ratio*100)).."%"
end

core.register_abm({
    label = "furnace",
    nodenames = {"furnace:furnace", "furnace:active_furnace"},
    interval = 1,
    chance = 1,
    action = furnace_loop
})
