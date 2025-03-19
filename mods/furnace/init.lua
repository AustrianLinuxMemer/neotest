core.register_node("furnace:furnace", {
    description = "Furnace",
    tiles = {"furnace_up_down.png", "furnace_up_down.png", "furnace_side.png", "furnace_side.png", "furnace_side.png", "furnace_front.png"},
    groups = {cracky = 3},
    on_construct = function(pos)
        local meta = core.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("fuel", 1)
        inv:set_size("input", 1)
        inv:set_size("result", 1)
        meta:set_string("formspec", "formspec_version[8]".."size[11,10]".."real_coordinates[true]".."list[context;fuel;3.5,3;1,1;]".."list[context;input;3.5,1;1,1;]".."list[context;result;6,2;2,2;]".."list[current_player;main;0.5,5;8,4;]")
    end,
    on_rightclick = function(pos, node, player, itemstack, pointed_thing)
        local meta = minetest.get_meta(pos)
        core.show_formspec(player:get_player_name(), "furnace:furnace", meta:get_string("formspec"))    
    end
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

local function nice_percent(ratio, deplaces)
    return tostring(math.round(ratio*100, dplaces)).."%"
end

core.register_abm({
    label = "furnace",
    nodenames = {"furnace:furnace"},
    interval = 1,
    chance = 1,
    action = function(pos, node, active_object_count, active_object_count_wider)
        local meta = core.get_meta(pos)
        local inv = meta:get_inventory()
        local fuel_stack = inv:get_stack("fuel", 1)
        local input_stack = inv:get_stack("input", 1)
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
        if input_stack:is_empty() == false then
            local remaining_fuel = meta:get_int("remaining_fuel")
            core.chat_send_all("Fuel: "..nice_percent(remaining_fuel/fuel.time, 3))
            if fuel_stack:is_empty() == false then
                if remaining_fuel == 0 then
                    fuel_stack:take_item(1)
                    inv:set_stack("fuel", 1, fuel_stack)
                    meta:set_int("remaining_fuel", fuel.time)
                end
                if remaining_fuel > 0 then
                    local remaining = meta:get_int("remaining")
                    core.chat_send_all("Item: "..nice_percent(remaining/output.time, 3))
                    local result_old_stack = inv:get_stack("result", 1)               
                    if remaining == 0 then
                        meta:set_int("remaining", output.time)
                    end
                    if remaining > 0 then
                        meta:set_int("remaining", remaining - 1)
                    else
                        local output_stack = output.item
                        if (result_old_stack:get_name() == output_stack:get_name() or result_old_stack:is_empty()) and result_old_stack:item_fits(output_stack) then
                            
                            input_stack:take_item(1)
                            result_old_stack:add_item(output_stack)
                            
                            inv:set_stack("input", 1, input_stack)
                            inv:set_stack("result", 1, result_old_stack)
                        end
                    end
                    meta:set_int("remaining_fuel", remaining_fuel - 1)
                end
            else
                meta:set_int("remaining_fuel", 0)
            end
        else
            meta:set_int("remaining", 0)
        end
    end
})
