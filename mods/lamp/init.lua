local lamp_ui = "formspec_version[8]".."size[11,10]".."real_coordinates[true]".."list[context;fuel;5,2.5;1,1;]".."list[current_player;main;0.5,5;8,4;]"
local function on_construct_lamp(pos)
    local meta = core.get_meta(pos)
    local inv = meta:get_inventory()
    inv:set_size("fuel", 1)
    meta:set_string("formspec", lamp_ui)
end
local function open_furnace(pos, node, player, itemstack, pointed_thing)
    local meta = core.get_meta(pos)
    core.show_formspec(player:get_player_name(), "lamp:lamp", meta:get_string("formspec"))
end
local function set_lamp_active(pos, on)
    local lamp_type = core.get_node(pos).name
    if on and lamp_type == "lamp:lamp_off" then
        core.swap_node(pos, {name = "lamp:lamp_on"})    
    elseif not on and lamp_type == "lamp:lamp_on" then
        core.swap_node(pos, {name = "lamp:lamp_off"})
    end
end
local function lamp_loop(pos, node, active_object_count, active_object_count_wider)
    local meta = core.get_meta(pos)
    local inv = meta:get_inventory()
    local fuel_stack = inv:get_stack("fuel", 1)    
    local fuel = core.get_craft_result({
        method = "fuel",
        width = 1,
        items = {fuel_stack}        
    })
    local remaining_fuel = meta:get_int("remaining_fuel")
    if remaining_fuel > 0 then
        meta:set_int("remaining_fuel", remaining_fuel - 1)
        set_lamp_active(pos, true)
    else
        if not fuel_stack:is_empty() and fuel.time ~= 0 then
            fuel_stack:take_item(1)
            meta:set_int("remaining_fuel", fuel.time*64)
            set_lamp_active(pos, true)
        else
            set_lamp_active(pos, false)
        end
    end
    inv:set_stack("fuel", 1, fuel_stack)
end


core.register_node("lamp:lamp_off", {
    description = "Lamp",
    tiles = {"lamp_lamp_off.png"},
    groups = {choppy = 2, pane_connect = 1},
    on_construct = on_construct_lamp,
    on_rightclick = open_lamp
})
core.register_node("lamp:lamp_on", {
    description = "Lamp (on)",
    tiles = {"lamp_lamp_on.png"},
    light_source = core.LIGHT_MAX,
    drop = "lamp:lamp_off",
    groups = {choppy = 2, pane_connect = 1},
    on_construct = on_construct_lamp,
    on_rightclick = open_lamp
})
core.register_node("lamp:lamp_of_eternity", {
    description = "Lamp of eternity",
    tiles = {"lamp_lamp_of_eternity.png"},
    light_source = core.LIGHT_MAX,
    groups = {choppy = 2, pane_connect = 1}
})

core.register_craft({
    type = "shaped",
    output = "lamp:lamp_off",
    recipe = {
        {"group:glass", "group:glass", "group:glass"},
        {"group:glass", "", "group:glass"},
        {"group:glass", "group:glass", "group:glass"},
    }
})

core.register_craft({
    type = "shaped",
    output = "lamp:lamp_of_eternity",
    recipe = {
        {"group:glass", "group:glass", "group:glass"},
        {"group:glass", "buckets:lava_bucket", "group:glass"},
        {"group:glass", "group:glass", "group:glass"},
    }
})

core.register_abm({
    label = "lamp",
    nodenames = {"lamp:lamp_on", "lamp:lamp_off"},
    interval = 1,
    chance = 1,
    action = lamp_loop
})
