local furnace_ui = "formspec_version[8]".."size[11,10]".."real_coordinates[true]".."list[context;fuel;3.5,3;1,1;]".."list[context;input;3.5,1;1,1;]".."list[context;result;6,2;2,2;]".."list[current_player;main;0.5,5;8,4;]"
local function init_furnace(pos)
    local meta = core.get_meta(pos)
    local inv = meta:get_inventory()
    inv:set_size("fuel", 1)
    inv:set_size("input", 1)
    inv:set_size("result", 1)
    meta:set_string("formspec", furnace_ui)
end
local function open_furnace(pos, node, player, itemstack, pointed_thing)
    local meta = minetest.get_meta(pos)
    core.show_formspec(player:get_player_name(), "furnace:furnace", meta:get_string("formspec"))
end
local function furnace_loop(pos, node, active_object_count, active_object_count_wider)
    local meta = core.get_meta(pos)
    local inv = meta:get_inventory()
    local fuel_stack = inv:get_stack("fuel", 1)
    local input_stack = inv:get_stack("input", 1)
    local output_stack = inv:get_stack("result", 1)
    local furnace_type = core.get_node(pos).name
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
    local remaining_fuel = meta:get_int("remaining_fuel")
    local remaining_input = meta:get_int("remaining_input")
    -- Checking if the fuel is empty
    if remaining_fuel > 0 then
        -- Setting the furnace alight
        core.swap_node(pos, {name = "furnace:active_furnace"})
        -- Consuming the fuel
        meta:set_int("remaining_fuel", remaining_fuel - 1)
        if remaining_input > 0 then
            -- Cooking the item
            meta:set_int("remaining_input", remaining_input - 1)        
        else
            if not input_stack:is_empty() and not output.item:is_empty() then
                input_stack:take_item(1)
                meta:set_int("remaining_input", output.time)            
            end
            output_stack:add_item(output.item)

        end
    else
        
        
        -- Replenishing the Fuel
        if not fuel_stack:is_empty() then
            meta:set_int("remaining_fuel", fuel.time)
            fuel_stack:take_item(1)
        else
            -- Extinguishing the furnace
            core.swap_node(pos, {name = "furnace:furnace"})
        end
        
    end
    -- Updating item stacks
    inv:set_stack("fuel", 1, fuel_stack)
    inv:set_stack("input", 1, input_stack)
    inv:set_stack("result", 1, output_stack)
    core.chat_send_all("Fuel: "..tostring(remaining_fuel))
    core.chat_send_all("Input: "..tostring(remaining_input))
    core.chat_send_all("Recipe to cook: "..input_stack:get_name().." -> "..output.item:get_name().." ("..output.item:get_count()..")")
end

core.register_node("furnace:furnace", {
    description = "Furnace",
    tiles = {"furnace_up_down.png", "furnace_up_down.png", "furnace_side.png", "furnace_side.png", "furnace_side.png", "furnace_front.png"},
    groups = {cracky = 3},
    on_construct = init_furnace,
    on_rightclick = open_furnace
})

core.register_node("furnace:active_furnace", {
    description = "Furnace (active)",
    tiles = {"furnace_up_down.png", "furnace_up_down.png", "furnace_side.png", "furnace_side.png", "furnace_side.png", "furnace_front_lit.png"},
    groups = {cracky = 3},
    light_source = core.LIGHT_MAX,
    on_construct = init_furnace,
    on_rightclick = open_furnace,
    drop = "furnace:furnace"
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
