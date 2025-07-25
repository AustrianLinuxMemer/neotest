local creative = core.settings:get_bool("creative_mode", false) or false
local debug_mode = core.settings:get_bool("neotest_debug", false) or false
local S = core.get_translator("mods:creative_inventory")
local function compare_items(a,b)
    return a:get_name() < b:get_name()
end
local function is_allowed(k, v)
    local forbidden = {
        air = true,
        ignore = true,
        unknown = true,
        [""] = true
    }
    return not v.groups["no_creative"] and not v.groups["not_in_creative_inventory"] and not forbidden[k]
end
local items = {}
function items.get_all_nodes()
    local list = {}
    for k, v in pairs(core.registered_nodes) do
        if is_allowed(k,v) then
            table.insert(list, ItemStack({name = k, count = v.stack_max}))
        end
    end
    -- Sorting the items after technical name
    table.sort(list, compare_items)
    return list
end
function items.get_all_tools()
    local list = {}
    for k, v in pairs(core.registered_tools) do
        if is_allowed(k,v) then
            table.insert(list, ItemStack({name = k, count = v.stack_max}))
        end
    end
    -- Sorting the items after technical name
    table.sort(list, compare_items)
    return list
end
function items.get_all_craftitems()
    local list = {}
    for k, v in pairs(core.registered_craftitems) do
        if is_allowed(k,v) then
            table.insert(list, ItemStack({name = k, count = v.stack_max}))
        end
    end
    -- Sorting the items after technical name
    table.sort(list, compare_items)
    return list
end
function items.get_all_debug_tools()
    local list = {}
    for k, v in pairs(core.registered_tools) do
        if v.groups["test_tool"] then table.insert(list, ItemStack({name = k, count = v.stack_max})) end
    end
    return list
end

local function create_inventories()
    local all_nodes = items.get_all_nodes()
    local all_tools = items.get_all_tools()
    local all_craftitems = items.get_all_craftitems()
    local inv_nodes = core.get_inventory({type = "detached", name = "creative_nodes"})
    local inv_tools = core.get_inventory({type = "detached", name = "creative_tools"})
    local inv_craftitems = core.get_inventory({type = "detached", name = "creative_craftitems"})
    local functions_table = {
        allow_put = function() return -1 end,
        allow_take = function(_, _, _, stack) return -1 end,
        allow_move = function(_, _, _, _, _, count) return count end
    }
    if not inv_nodes then
        inv_nodes = core.create_detached_inventory("creative_nodes", functions_table)
    end
    if not inv_tools then
        inv_tools = core.create_detached_inventory("creative_tools", functions_table)
    end
    if not inv_craftitems then
        inv_craftitems = core.create_detached_inventory("creative_craftitems", functions_table)
    end
    inv_nodes:set_size("items", #all_nodes)
    inv_nodes:set_list("items", all_nodes)
    inv_tools:set_size("items", #all_tools)
    inv_tools:set_list("items", all_tools)
    inv_craftitems:set_size("items", #all_craftitems)
    inv_craftitems:set_list("items", all_craftitems)
    if debug_mode then
        local all_debug_tools = items.get_all_debug_tools()
        local inv_debug_tools = core.get_inventory({type = "detached", name = "creative_debug_tools"})
        if not inv_debug_tools then
            inv_debug_tools = core.create_detached_inventory("creative_debug_tools", functions_table)
        end
        inv_debug_tools:set_size("items", #all_debug_tools)
        inv_debug_tools:set_list("items", all_debug_tools)
    end
end

local function make_formspec(invname, item_count)
    local cols = 8
    local total_rows = math.ceil(item_count/cols)
    local visible_rows = 6
    return  "scroll_container[0,0;10.5,"..tostring(visible_rows)..";creative_scrollbar;vertical]"..
            "list[detached:"..invname..";items;0,0;"..tostring(cols)..","..tostring(total_rows).."]"..
            "scroll_container_end[]"..
            "scrollbaroptions[max="..tostring(item_count)..";smallstep="..tostring(12).."]"..
            "scrollbar[11,0;0.5,"..tostring(visible_rows)..";vertical;creative_scrollbar;0]"

end

local function make_creative_tabs()
    create_inventories()
    local inv_nodes = core.get_inventory({type = "detached", name = "creative_nodes"})
    local inv_tools = core.get_inventory({type = "detached", name = "creative_tools"})
    local inv_craftitems = core.get_inventory({type = "detached", name = "creative_craftitems"})
    local nodes_size = inv_nodes:get_size("items")
    local tools_size = inv_tools:get_size("items")
    local craftitems_size = inv_craftitems:get_size("items")
    sfinv.register_page("player:inventory_nodes", {
        title = S("Blocks"),
        get = function(self, player, context)
            return sfinv.make_formspec(player, context, make_formspec("creative_nodes", nodes_size), true)
        end
    })
    sfinv.register_page("player:inventory_tools", {
        title = S("Tools"),
        get = function(self, player, context)
            return sfinv.make_formspec(player, context, make_formspec("creative_tools", tools_size), true)
        end
    })
    sfinv.register_page("player:inventory_craftitems", {
        title = S("Items"),
        get = function(self, player, context)
            return sfinv.make_formspec(player, context, make_formspec("creative_craftitems", craftitems_size), true)
        end
    })
    if debug_mode then
        local inv_debug_tools = core.get_inventory({type = "detached", name = "creative_debug_tools"})
        local debug_tools_size = inv_debug_tools:get_size("items")
        sfinv.register_page("player:inventory_debug_tools", {
            title = S("Debug tools"),
            get = function(self, player, context)
                return sfinv.make_formspec(player, context, make_formspec("creative_debug_tools", debug_tools_size), true)
            end
        })
    end
end

if creative then
    core.register_on_mods_loaded(function()
        make_creative_tabs()
    end)
end