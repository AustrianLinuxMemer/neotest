furnace = {}
furnace_subscriptions = {}
function furnace:new_id()
    if self.id == nil then
        self.id = 0
    else
        self.id = self.id + 1
    end
    return self.id
end

local function create_furnace_id(id_number)
    return "furnace:furnace_"..tostring(id_number)
end
local function init_furnace(pos)
    local meta = core.get_meta(pos)
    local inv = meta:get_inventory()
    local furnace_id = create_furnace_id(furnace:new_id())
    meta:set_string("furnace_id", furnace_id)
    inv:set_size("input", 1)
    inv:set_size("fuel", 1)
    inv:set_size("output", 1)
    inv:set_stack("input", 1, ItemStack())
    inv:set_stack("fuel", 1, ItemStack())
    inv:set_stack("output", 1, ItemStack())
end
local function open_furnace(pos, node, player)
    local meta = core.get_meta(pos)
    local furnace_id = meta:get_string("furnace_id")
    if player:is_player() then
        local player_meta = player:get_meta()
        player_meta:set_string("furnace_id", furnace_id)
        if furnace_subscriptions[furnace_id] == nil then
            furnace_subscriptions[furnace_id] = {}
        end
        local list = furnace_subscriptions[furnace_id]
        formspec_helper.subscribe(list, player:get_player_name())
        --formspec_helper.multicast(list, furnace_id, "formspec_version[8]size[8,8]real_coordinates[true]label[3,3;Hello]")
    end
end

-- Unsubscribe leaving players from furnace updates
core.register_on_leaveplayer(function(player, timed_out)
    if player:is_player() then
        for furnace_id, _ in pairs(furnace_subscriptions) do 
            local old_list = furnace_subscriptions[furnace_id]
            for i, p in old_list do
                if p == player:get_player_name() then table.remove(old_list, i) end
            end
            furnace_subscriptions[furnace_id] = old_list
        end
    end
end)

core.register_on_player_receive_fields(function(player, formname, fields)
    if player:is_player() then
        local player_name = player:get_player_name()
        local player_meta = player:get_meta()
        local furnace_id = player_meta:get_string("furnace_id")
        if formname == furnace_id and fields["quit"] == "true" then
            local list = furnace_subscriptions[furnace_id]
            formspec_helper.unsubscribe(list, player_name)
        end
    end

end)
local function generate_formspec(pos)
    local preamble = "formspec_version[8]size[11,10]real_coordinates[true]"
    local nodemeta_expr = "nodemeta:"..tostring(pos.x)..","..tostring(pos.y)..","..tostring(pos.z)
    local lists = {
        "list["..nodemeta_expr..";input;1,1;1,1]",
        "list["..nodemeta_expr..";output;3,1.5;1,1]",
        "list["..nodemeta_expr..";fuel;1,3;1,1]",
        "list[current_player;main;0.5,4.75;8,4;]"
    }
    return preamble..table.concat(lists)
end
local function furnace_loop(pos)
    local meta = core.get_meta(pos)
    local furnace_id = meta:get_string("furnace_id")
    local list = furnace_subscriptions[furnace_id]
    
    formspec_helper.multicast(list, furnace_id, generate_formspec(pos))
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

core.register_abm({
    label = "furnace",
    nodenames = {"furnace:furnace", "furnace:active_furnace"},
    interval = 1,
    chance = 1,
    action = furnace_loop
})
