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
    inv:set_size("output", 4)
    inv:set_size("intermediary", 1)
    inv:set_stack("input", 1, ItemStack())
    inv:set_stack("fuel", 1, ItemStack())
    inv:set_stack("output", 1, ItemStack())
    inv:set_stack("output", 2, ItemStack())
    inv:set_stack("output", 3, ItemStack())
    inv:set_stack("output", 4, ItemStack())
    inv:set_stack("intermediary", 1, ItemStack())
    core.get_node_timer(pos):start(0.1)
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
    end
end
local function destroy_furnace(pos, node, digger)
    if digger:is_player() then
        local node_meta = core.get_meta(pos)
        local node_inv = node_meta:get_inventory()
        local digger_inv = digger:get_inventory()
        local list_names = {"fuel","input","output"}
        for _, name in ipairs(list_names) do
            local list_size = node_inv:get_size(name)
            for i = 1, list_size do
                local stack = node_inv:get_stack(name, i)
                if not stack:is_empty() then
                    local leftover = digger_inv:add_item("main", stack)
                    if not leftover:is_empty() then
                        local item_pos = vector.new(pos.x, pos.y+1, pos.z)
                        core.add_item(item_pos, leftover)
                    end
                end
            end
        end
        core.node_dig(pos, node, digger)
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
local function calc_arrow_fire(remaining, full)
    if full == 0 then
        return 0
    else
        return math.abs(math.round((remaining / full) * 12))
    end
end
local function get_recipes(stacks)
    -- Furnaces always use the first listed recipe
    local fuel_output, d = core.get_craft_result({
        items = {stacks.fuel},
        width = 1,
        method = "fuel"
    })
    local input_output, d = core.get_craft_result({
        items = {stacks.input},
        width = 1,
        method = "cooking"
    })
    local registration_fuel = core.registered_items[stacks.fuel:get_name()]
    local registration_input = core.registered_items[stacks.input:get_name()]
    local recipes = {
        fuel = {
            input = stacks.input,
            output = ItemStack(),
            time = fuel_output.time
        },
        input = {
            input = stacks.input,
            output = input_output.item,
            time = input_output.time
        }
    }
    recipes.fuel.byproduct = registration_fuel._byproducts or {}
    recipes.input.byproduct = registration_input._byproducts or {}
    return recipes
end

local function furnace_loop(pos, elapsed)
    local meta = core.get_meta(pos)
    local furnace_id = meta:get_string("furnace_id")
    local inventory = meta:get_inventory()
    local list = furnace_subscriptions[furnace_id]

    local stacks = {
        fuel = inventory:get_stack("fuel", 1),
        input = inventory:get_stack("input", 1)
    }
    local intermediary = inventory:get_stack("intermediary", 1)
    local remaining = {
        fuel = meta:get_float("remaining_fuel"),
        input = meta:get_float("remaining_input")
    }
    local total = {
        fuel = meta:get_float("total_fuel"),
        input = meta:get_float("total_input")
    }
    local recipes = get_recipes(stacks)
    -- Consume fuel and add byproduct to output if:
    -- * remaining.fuel is under or equals zero
    -- * there is fuel
    -- * the byproduct would fit into the output list
    -- * the burntime is greater than zero
    if remaining.fuel <= 0 and not stacks.fuel:is_empty() and not stacks.input:is_empty() and inventory:room_for_item("output", recipes.fuel.byproduct) and recipes.fuel.time > 0 then
        stacks.fuel:take_item(1)
        inventory:add_item("output", recipes.fuel.byproduct)
        remaining.fuel = recipes.fuel.time
        total.fuel = recipes.fuel.time
        
    end

    -- Consume item into intermediary if:
    -- * remaining.fuel is over zero
    -- * there are items
    -- * If the cooktime is not zero
    -- * If the intermediary is empty
    if remaining.fuel > 0 and remaining.input <= 0 and not stacks.input:is_empty() and intermediary:is_empty() and recipes.input.time > 0 then
        stacks.input:take_item(1)
        intermediary:add_item(ItemStack(recipes.input.output))
        remaining.input = recipes.input.time
        total.input = recipes.input.time
    end

    -- If the fuel ran out, power off the furnace and destory the intermediary, otherwise keep the furnace on
    if remaining.fuel <= 0 then
        remaining.input = 0
        total.input = 0
        intermediary:clear()
        local this_node = core.get_node(pos)
        this_node.name = "furnace:furnace"
        core.swap_node(pos, this_node)
    else
        local this_node = core.get_node(pos)
        this_node.name = "furnace:active_furnace"
        core.swap_node(pos, this_node)
    end


    --Empty the intermediary if:
    -- * the intermediary is not empty
    -- * there is space in the output
    -- * remaining.input below or at zero
    if remaining.input <= 0 and not intermediary:is_empty() and inventory:room_for_item("output", intermediary) then
        inventory:add_item("output", intermediary)
        intermediary:clear()
    end

    

    if remaining.fuel > 0 then
        remaining.fuel = remaining.fuel - elapsed
    end
    if remaining.input > 0 then
        remaining.input = remaining.input - elapsed
    end
    inventory:set_stack("input", 1, stacks.input)
    inventory:set_stack("fuel", 1, stacks.fuel)
    inventory:set_stack("intermediary", 1, intermediary)
    meta:set_float("remaining_fuel", remaining.fuel)
    meta:set_float("remaining_input", remaining.input)
    meta:set_float("total_fuel", total.fuel)
    meta:set_float("total_input", total.input)
    formspec_helper.multicast(list, furnace_id, generate_formspec(pos, calc_arrow_fire(remaining.input, total.input), calc_arrow_fire(remaining.fuel, total.fuel)))
    return true
end
base.register_node("furnace:furnace", {
    description = "Furnace",
    paramtype2 = "facedir",
    tiles = {"furnace_up_down.png", "furnace_up_down.png", "furnace_side.png", "furnace_side.png", "furnace_side.png", "furnace_front.png"},
    groups = {cracky = 3},
    on_construct = init_furnace,
    on_rightclick = open_furnace,
    on_timer = furnace_loop,
    on_dig = destroy_furnace,
    after_place_node = base.correct_orientation_after_place_node
})

base.register_node("furnace:active_furnace", {
    description = "Furnace (active)",
    paramtype2 = "facedir",
    tiles = {"furnace_up_down.png", "furnace_up_down.png", "furnace_side.png", "furnace_side.png", "furnace_side.png", "furnace_front_lit.png"},
    groups = {cracky = 3, no_creative = 1},
    light_source = core.LIGHT_MAX,
    on_construct = init_furnace,
    on_rightclick = open_furnace,
    on_timer = furnace_loop,
    on_dig = destroy_furnace,
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
