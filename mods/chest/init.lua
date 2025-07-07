chest = {}

local function on_chest_construct(pos)
    local meta = core.get_meta(pos)
    local inv = meta:get_inventory()
    inv:set_size("chest", 24)
end
local function dig_chest(pos, node, digger)
    local meta = core.get_meta(pos)
    local inv = meta:get_inventory()
    local item_list = inv:get_list("chest")
    if digger:is_player() then
        if base.is_protected(pos, digger:get_player_name(), " tried to dig a chest at "..vector.to_string(pos)) then
            return false
        end
        local player_inv = digger:get_inventory()
        for _, v in ipairs(item_list) do
            core.add_item(pos, player_inv:add_item("main", v))
        end
    else
        for _, v in ipairs(item_list) do
            core.add_item(pos, v)
        end
    end
    core.node_dig(pos, node, digger)
    return true
end
local function on_chest_open(pos, node, clicker)
    if clicker:is_player() then
        local name = clicker:get_player_name()
        if base.is_protected(pos, name, " tried to open a chest at "..vector.to_string(pos)) then
            return
        else
            local preamble = "formspec_version[8]size[10.25,10]real_coordinates[true]"
            local nodemeta_expr = "nodemeta:"..tostring(pos.x)..","..tostring(pos.y)..","..tostring(pos.z)
            local player_list = "list[current_player;main;0.25,5;8,4;]"
            local chest_list = "list["..nodemeta_expr..";chest;0.25,0.25;8,3;]"
            core.show_formspec(name, "chest:chest", preamble..player_list..chest_list)
        end
    end
end
local function on_chest_blast(pos, intensity)
    local meta = core.get_meta(pos)
    local inv = meta:get_inventory()
    for _, v in ipairs(inv:get_list("chest")) do
        core.add_item(pos, v)
    end
end
base.register_node("chest:chest", {
    description = "Chest",
    tiles = {"chest_top.png", "chest_top.png", "chest_side.png", "chest_side.png", "chest_side.png", "chest_front.png"},
    paramtype2 = "4dir",
    groups = {choppy=3, pane_connect = 1},
    after_place_node = base.mod_fourdir_node,
    on_construct = on_chest_construct,
    on_dig = dig_chest,
    on_rightclick = on_chest_open,
    on_blast = on_chest_blast
})

local function init_loot_chest(pos, key)
    local oldnode = core.get_node(pos)
    core.set_node(pos, {name = "chest:chest", param2 = oldnode.param2})
    local meta = core.get_meta(pos)
    local inv = meta:get_inventory()
    local list_with_loot = loot.get_loot(inv:get_list("chest"), key)
    inv:set_list("chest", list_with_loot)
end
function chest.register_loot_chest(name, decorations, key)
    base.register_node(name, {
        description = "Generated Chest ("..key..")",
        tiles = {"chest_top.png", "chest_top.png", "chest_side.png", "chest_side.png", "chest_side.png", "chest_front.png"},
        paramtype2 = "4dir",
        groups = {choppy=3, pane_connect = 1},
        after_place_node = base.mod_fourdir_node,
        on_dig = function(pos, node, digger)
            init_loot_chest(pos, key)
            dig_chest(pos, node, digger)
        end,
        on_rightclick = function(pos, node, clicker)
            init_loot_chest(pos, key)
            on_chest_open(pos, node, clicker)
        end,
        on_blast = function(pos, intensity)
            init_loot_chest(pos, key)
            on_chest_blast(pos, intensity)
        end
    })
    for _, decoration in ipairs(decorations) do
        core.register_decoration(decoration)
    end
end


core.register_craft({
    type = "shaped",
    output = "chest:chest",
    recipe = {
        {"group:planks", "group:planks", "group:planks"},
        {"group:planks", "", "group:planks"},
        {"group:planks", "group:planks", "group:planks"}
    }
})