screwdriver = {}

local function to_facedir(dir, rot)
    if dir >= 0 and dir <= 5 and rot >= 0 and rot <= 3 then
        return dir * 4 + rot
    end
end
local function from_facedir(facedir)
    return {dir = math.floor(facedir / 4), rot = facedir % 4}
end

core.register_tool("screwdriver:screwdriver", {
    description = "Screwdriver",
    inventory_image = "screwdriver.png",
    on_place = function(itemstack, user, pointed_thing)
        local pos = pointed_thing.under
        local node = core.get_node(pos)
        if base.is_protected(pos, user:get_player_name(), "tried to modify a node with a screwdriver") then
            return
        end
        if core.registered_nodes[node.name].paramtype2 == "facedir" then
            local dir_rot = from_facedir(node.param2)
            if (dir_rot.dir < 6) then
                dir_rot.dir = dir_rot.dir + 1
            else
                dir_rot.dir = 0
            end
            node.param2 = to_facedir(dir_rot.dir, dir_rot.rot)
            core.set_node(pos, node)
        end
        return nil
    end,
    on_use = function(itemstack, user, pointed_thing)
        local pos = pointed_thing.under
        local node = core.get_node(pos)
        if base.is_protected(pos, user:get_player_name(), "tried to modify a node with a screwdriver") then
            return
        end
        if core.registered_nodes[node.name].paramtype2 == "facedir" then
            local dir_rot = from_facedir(node.param2)
            if (dir_rot.rot < 5) then
                dir_rot.rot = dir_rot.rot + 1
            else
                dir_rot.rot = 0
            end
            node.param2 = to_facedir(dir_rot.dir, dir_rot.rot)
            core.set_node(pos, node)
        end
        if core.registered_nodes[node.name].paramtype2 == "4dir" then
            local dir = node.param2
            if (dir < 5) then
                dir = dir + 1
            else
                dir = 0
            end
            node.param2 = dir
            core.set_node(pos, node)
        end
        return nil
    end
})

core.register_craft({
    type = shaped,
    output = "screwdriver:screwdriver",
    recipe = {
        {"group:iron"},
        {"group:stick"}
    }
})