dofile(core.get_modpath("tree").."/nodes.lua")
local valid_grow_nodes = {
    ["geology:dirt"] = true,
    ["geology:grass_block"] = true
}
local leaf_abm = {
    nodenames = {"group:leaf"},
    interval = 0.1,
    chance = 100,
    action = function(pos, node)
        local to_remove = true
        local radius = 5 -- later configurable
        for dz = -radius, radius do
            for dy = -radius, radius do
                for dx = -radius, radius do
                    local check_pos = {x = pos.x + dx, y = pos.y + dy, z = pos.z + dz}
                    local check_node = core.get_node(check_pos)
                    local group_name = core.get_item_group(check_node.name, "log")
                    if group_name > 0 then
                        to_remove = false
                        break
                    end
                end
                if not to_remove then
                    break                
                end
            end
            if not to_remove then
                break            
            end
        end
        if to_remove then
            local node = core.get_node(pos)    
            local node_drops = core.get_node_drops(node, ":")
            core.set_node(pos, {name = "air"})
            for _, v in pairs(node_drops) do
                core.add_item(pos, v)
            end
        end
    end
}
base.register_craftitem("tree:stick", {
    description = "Stick",
    inventory_image = "tree_stick.png",
    groups = {stick=1}
})
core.register_craft({
    type = "shaped",
    output = "tree:stick 4",
    recipe = {{"group:planks"}, {"group:planks"}}
})
core.register_abm(leaf_abm)
loot.add_to_loot_pool({item = "tree:stick", max_q = 16, prob = 0.2})