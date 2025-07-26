local S = core.get_translator("mods:cauldron")


local function cauldron_nodebox(water_level)
    if type(water_level) ~= "number" then water_level = 0 end
    -- -3/16, -2/16, -1/16, 0/16, 1/16, 2/16, 3/16, 4/16, 5/16, 6/16, 7/16
    local max_y = -3/16
    if water_level == 1 then
        max_y = 0/16
    elseif water_level == 2 then
        max_y = 3/16
    elseif water_level == 3 then
        max_y = 7/16
    end
    local nodebox = {
        --Leg 1
        {-8/16, -8/16, -8/16, -4/16, -5/16, -4/16},
        --Leg 2
        {-8/16, -8/16, 8/16, -4/16, -5/16, 4/16},
        --Leg 3
        {8/16, -8/16, -8/16, 4/16, -5/16, -4/16},
        --Leg 4
        {8/16, -8/16, 8/16, 4/16, -5/16, 4/16},
        --Base
        {-8/16, -5/16, -8/16, 8/16, -3/16, 8/16},
        --Wall one
        {-8/16, -3/16, -8/16, -6/16, 8/16, 8/16},
        --Wall two
        {8/16, -3/16, -8/16, 6/16, 8/16, 8/16},
        --Wall three
        {6/16, -3/16, 8/16, -6/16, 8/16, 6/16},
        --Wall four
        {-6/16, -3/16, -8/16, 6/16, 8/16, -6/16}
    }
    -- Water
    if water_level > 0 then
        table.insert(nodebox, {-6/16, -3/16, -6/16, 6/16, max_y, 6/16})
    end
    return nodebox
end
cauldron = {
    interactions = {}
}
-- Function must implement this contract:
-- function(pos, node, clicker, itemstack, pointed_thing, cauldron_info)
-- for regular cauldrons and
-- function(pos, node, clicker, itemstack, pointed_thing)
-- for empty cauldrons
-- rewire_item is used to indicate that the item has an on_place function and that the behavior needs to be rewired
-- for the item to work the callback
function cauldron.register_callback(cauldron_name, item_name, func, rewire_item)
    
    if type(func) ~= "function" then error("Callback function must be a function") end
    if cauldron.interactions[cauldron_name] == nil then cauldron.interactions[cauldron_name] = {} end
    cauldron.interactions[cauldron_name][item_name] = func

    if rewire_item then
        local registration = core.registered_items[item_name]
        if registration ~= nil and type(registration.on_place) then
            local old_on_place = registration.on_place
            local function new_on_place(itemstack, placer, pointed_thing)
                if pointed_thing.type == "node" then
                    local pos = pointed_thing.under
                    local node = core.get_node(pos)
                    local is_cauldron = core.get_item_group(node.name, "cauldron") ~= 0
                    if is_cauldron then
                        local cauldron_registration = core.registered_nodes[node.name]
                        if cauldron_registration ~= nil then
                            return func(pos, node, placer, itemstack, pointed_thing, cauldron_registration._cauldron_info)
                        else
                            return func(pos, node, placer, itemstack, pointed_thing)
                        end
                    else
                        return old_on_place(itemstack, placer, pointed_thing)
                    end
                else
                    return old_on_place(itemstack, placer, pointed_thing)
                end
            end

            core.override_item(item_name, {on_place = new_on_place}, {})
        end
    end
end
function cauldron.on_cauldron_rightclick(pos, node, clicker, itemstack, pointed_thing, cauldron_info)
    if cauldron.interactions[cauldron_info.name] == nil then return end
    if type(cauldron.interactions[cauldron_info.name][itemstack:get_name()]) == "function" then
        return cauldron.interactions[cauldron_info.name][itemstack:get_name()](pos, node, clicker, itemstack, pointed_thing, cauldron_info)
    end
end
function cauldron.on_empty_cauldron_rightclick(pos, node, clicker, itemstack, pointed_thing)
    core.chat_send_all("Cauldron logic triggered")
    if cauldron.interactions["cauldron:empty_cauldron"] == nil then return end
    if type(cauldron.interactions["cauldron:empty_cauldron"][itemstack:get_name()]) == "function" then
        return cauldron.interactions["cauldron:empty_cauldron"][itemstack:get_name()](pos, node, clicker, itemstack, pointed_thing)
    end
end
base.register_node("cauldron:empty_cauldron", {
    description = S("Empty Cauldron"),
    drawtype = "nodebox",
    tiles = {"cauldron_empty_top.png", "cauldron_bottom.png", "cauldron_side.png"},
    node_box = {
        type = "fixed",
        fixed = cauldron_nodebox(0)
    },
    on_rightclick = cauldron.on_empty_cauldron_rightclick,
    groups = {cracky = 1, cauldron = 1}
})

function cauldron.register_cauldron(liquid_type, cauldron_name, cauldron_top_texture)
    local cauldron_base_name = "cauldron:"..liquid_type.."_cauldron"
    for i = 0, 3 do
        base.register_node(cauldron_base_name.."_"..tostring(i), {
            description = cauldron_name,
            drawtype = "nodebox",
            tiles = {cauldron_top_texture, "cauldron_bottom.png", "cauldron_side.png"},
            node_box = {
                type = "fixed",
                fixed = cauldron_nodebox(i)
            },
            on_rightclick = function(pos, node, clicker, itemstack, pointed_thing) 
                local cauldron_info = {
                    name = cauldron_base_name,
                    liquid = liquid_type,
                    level = i
                }
                return cauldron.on_cauldron_rightclick(pos, node, clicker, itemstack, pointed_thing, cauldron_info)
            end,
            _cauldron_info = {
                name = cauldron_base_name,
                liquid = liquid_type,
                level = i
            },
            groups = {cracky = 1, no_creative = 1, cauldron = 1, cauldron_level = i}
        })
    end
end

local creative = core.settings:get_bool("creative_mode", false) or false
local empty_bucket = core.settings:get_bool("neotest_creative_empty_bucket", false) or false
cauldron.register_cauldron("water", S("Water Cauldron"), "cauldron_water_top.png")

cauldron.register_callback("cauldron:empty_cauldron", "bucket:water_bucket", function(pos, node, clicker, itemstack, pointed_thing)
    core.set_node(pos, {name = "cauldron:water_cauldron_3"})
    if creative then
        if empty_bucket then
            return ItemStack("bucket:empty_bucket")
        else
            return nil
        end
    else
        return ItemStack("bucket:empty_bucket")
    end
end, true)

cauldron.register_callback("cauldron:water_cauldron", "bucket:empty_bucket", function(pos, node, clicker, itemstack, pointed_thing, cauldron_info)
    if cauldron_info.level == 3 then
        core.set_node(pos, {name = "cauldron:empty_cauldron"})
        if itemstack:get_count() == 1 then
            return ItemStack("bucket:water_bucket")
        else
            if creative then
                itemstack:take_item(1)
            end
            if clicker:is_player() then
                local inventory = clicker:get_inventory()
                local remaining = inventory:add_item("main", ItemStack("bucket:water_bucket"))
                core.add_item(pos, remaining)
            end
            return itemstack
        end
    end
end, true)