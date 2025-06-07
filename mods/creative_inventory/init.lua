local creative = core.settings:get_bool("creative_mode", false) or false
local function get_all_items() 
    local list = {}
    local forbidden = {
        air = true,
        ignore = true,
        unknown = true,
        [""] = true
    }
    for k, v in pairs(core.registered_items) do
        if not v.groups["no_creative"] and not forbidden[k] then
            table.insert(list, ItemStack({name = k, count = v.stack_max}))
        end
    end
    -- Sorting the items after technical name
    table.sort(list, function(a,b)
        local name_a = a:get_name()
        local name_b = b:get_name()
        return name_a < name_b
    end)
    return list
end

local function create_creative_inventory()
    local all_items = get_all_items()
    local inv = core.get_inventory({type = "detached", name = "creative"})
    if not inv then
        inv = core.create_detached_inventory("creative", {
            allow_put = function() return -1 end,
            allow_take = function(_, _, _, stack) return -1 end,
            allow_move = function(_, _, _, count) return count end
        })
    end
    inv:set_size("items", #all_items)
    inv:set_list("items", all_items)
end

local function make_creative_tab()
    create_creative_inventory()
    local inv = core.get_inventory({type = "detached", name = "creative"})
    local item_count = inv:get_size("items")
    sfinv.register_page("player:inventory", {
        title = "Alles",
        get = function(self, player, context)
            local cols = 8
            local total_rows = math.ceil(item_count/cols)
            local visible_rows = 6
            local formspec = "scroll_container[0,0;10.5,"..tostring(visible_rows)..";creative_scrollbar;vertical]"..
            "list[detached:creative;items;0,0;"..tostring(cols)..","..tostring(total_rows).."]"..
            "scroll_container_end[]"..
            "scrollbaroptions[max="..tostring(item_count)..";smallstep="..tostring(12).."]"..
            "scrollbar[11,0;0.5,"..tostring(visible_rows)..";vertical;creative_scrollbar;0]"
            return sfinv.make_formspec(player, context, formspec, true)
        end
    })
end

if creative then
    core.register_on_mods_loaded(function()
        make_creative_tab()
    end)
end