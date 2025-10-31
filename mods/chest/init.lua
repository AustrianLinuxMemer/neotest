chest = {}
local S = core.get_translator("mods:chest")
local function on_chest_open(pos, node, clicker)
    if clicker:is_player() then
        local name = clicker:get_player_name()
        local msg = S("open a chest")
        if base.is_protected(pos, name, msg) then
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

container.register_container("chest:chest", {
    description = S("Chest"),
    tiles = {"chest_top.png", "chest_top.png", "chest_side.png", "chest_side.png", "chest_side.png", "chest_front.png"},
    _inventory_lists = {
        {name = "chest", size = 24}
    },
    paramtype2 = "4dir",
    groups = {choppy = 3},
    after_place_node = base.mod_fourdir_node,
    on_rightclick = on_chest_open
}, base.register_node)


core.register_craft({
    type = "shaped",
    output = "chest:chest",
    recipe = {
        {"group:planks", "group:planks", "group:planks"},
        {"group:planks", "", "group:planks"},
        {"group:planks", "group:planks", "group:planks"}
    }
})