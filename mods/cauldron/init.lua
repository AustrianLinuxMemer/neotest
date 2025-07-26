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
function cauldron.register_callback(cauldron_name, item_name, func)
    if type(func) ~= "function" then error("Callback function must be a function") end
    if cauldron.interactions[cauldron_name] == nil then cauldron.interactions[cauldron_name] = {} end
    cauldron.interactions[cauldron_name][item_name] = func
end
function cauldron.on_cauldron_rightclick(pos, node, clicker, itemstack, pointed_thing, cauldron_info)
    if cauldron.interactions[cauldron_info.name] == nil then return end
    if type(cauldron.interactions[cauldron_info.name][itemstack:get_name()]) == "function" then
        return cauldron.interactions[cauldron_info.name][itemstack:get_name()](pos, node, clicker, itemstack, pointed_thing, cauldron_info)
    end
end
function cauldron.on_empty_cauldron_rightclick(pos, node, clicker, itemstack, pointed_thing)
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
    groups = {cracky = 1}
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
                cauldron.on_cauldron_rightclick(pos, node, clicker, itemstack, pointed_thing, cauldron_info)
            end,
            groups = {cracky = 1, no_creative = 1, cauldron_level = i}
        })
    end
end

cauldron.register_cauldron("water", S("Water Cauldron"), "cauldron_water_top.png")
