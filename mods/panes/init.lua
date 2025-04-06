panes = {}
local PANE_PARAM2 = {
    NORMAL = {north = {0, 2}, south = {0, 2}, east = {1, 3}, west = {1, 3}},
    T = {north = {0, 1, 3}, south = {1, 2, 3}, east = {0, 1, 2}, west = {0, 2, 3}},
    X = {north = {0,1,2,3}, south = {0,1,2,3}, east = {0,1,2,3}, west = {0,1,2,3}},
    L = {north = {0, 3}, south = {1, 2}, west = {2, 3}, east = {0, 1}}
}

local function search(t_name, directions)
    local count = 0
    for _, v in pairs(directions) do
        if v then count = count + 1 end
    end
    if count == 4 then
        return {name = t_name.."_pane_x", param2 = 0}
    end
    if count == 0 then
        return {name = t_name.."_pane_p", param2 = 0}
    end
end
local function register_pane_item(t_name, name, inventory_image)
    local item_def = {
        description = name,
        inventory_image = inventory_image,
        wield_image = inventory_image,
        on_place = function(itemstack, placer, pointed_thing)
            local pos = pointed_thing.above
            local around = {
                north = core.get_node({pos.x, pos.y, pos.z+1}),
                south = core.get_node({pos.x, pos.y, pos.z-1}),
                east = core.get_node({pos.x+1, pos.y, pos.z}),
                west = core.get_node({pos.x-1, pos.y, pos.z}),
            }
            local is_pane = {
                north = core.get_item_group(around.north, "pane") >= 1,
                south = core.get_item_group(around.south, "pane") >= 1,
                east = core.get_item_group(around.east, "pane") >= 1,
                west = core.get_item_group(around.west, "pane") >= 1
            }
            local is_pane_attachable = {
                north = core.get_item_group(around.north, "pane_attachable") >= 1,
                south = core.get_item_group(around.south, "pane_attachable") >= 1,
                east = core.get_item_group(around.east, "pane_attachable") >= 1,
                west = core.get_item_group(around.west, "pane_attachable") >= 1
            }
            local this_pane = search(t_name, {north = true, south = true, east = true, west = true})
            if this_pane ~= nil then
                core.set_node(pos, this_pane)
            end
            --[[
            local this_pane = search(is_pane_attachable)
            if this_pane.type == "X" then
                core.set_node(pos, {name = t_name.."_pane_x", param2 = this_pane.param2})
            elseif this_pane.type == "T" then
                core.set_node(pos, {name = t_name.."_pane_t", param2 = this_pane.param2})
            elseif this_pane.type == "C" then
                core.set_node(pos, {name = t_name.."_pane_c", param2 = this_pane.param2})
            elseif this_pane.type == "N" then
                core.set_node(pos, {name = t_name.."_pane_n", param2 = this_pane.param2})
            elseif this_pane.type == "S" then
                core.set_node(pos, {name = t_name.."_pane_s", param2 = this_pane.param2})
            elseif this_pane.type == "P" then
                core.set_node(pos, {name = t_name.."_pane_p", param2 = this_pane.param2})
            end
            ]]
        end
    }
    core.register_craftitem(t_name.."_pane", item_def)
end
local function register_stump(t_name, name, node_def)
    local pane_name = t_name.."_pane_p"
    local copy = table.copy(node_def)
    copy.drawtype = "nodebox"
    copy.description = name.." (Stump)"
    copy.paramtype2 = "facedir"
    copy.node_box = {
        type = "fixed",
        fixed = {
            {0, -0.5, -0.0625, 0.125, 0.5, 0.0625}, -- pane
        }
    }
    copy.groups["pane"] = 1
    copy.groups["pane_stump"] = 1
    copy.groups["pane_attachable"] = 1
    copy.drop = t_name.."_pane"
    core.register_node(pane_name, copy)
end
local function register_short(t_name, name, node_def)
    local pane_name = t_name.."_pane_s"
    local copy = table.copy(node_def)
    copy.drawtype = "nodebox"
    copy.description = name.." (Short)"
    copy.paramtype2 = "facedir"
    copy.node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.0625, 0.125, 0.5, 0.0625}, -- pane
		}
	}
    copy.groups["pane"] = 1
    copy.groups["pane_short"] = 1
    copy.groups["pane_attachable"] = 1
    copy.drop = t_name.."_pane"
    core.register_node(pane_name, copy)

end
local function register_normal(t_name, name, node_def)
    local pane_name = t_name.."_pane_n"
    local copy = table.copy(node_def)
    copy.drawtype = "nodebox"
    copy.description = name
    copy.paramtype2 = "facedir"
    copy.node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.0625, 0.5, 0.5, 0.0625}, -- pane
		}
	}
    copy.groups["pane"] = 1
    copy.groups["pane_normal"] = 1
    copy.groups["pane_attachable"] = 1
    copy.drop = t_name.."_pane"
    core.register_node(pane_name, copy)
end

local function register_t(t_name, name, intersect_texture, node_def)
    local pane_name = t_name.."_pane_t"
    local copy = table.copy(node_def)
    copy.drawtype = "nodebox"
    copy.description = name.." (T-shaped)"
    copy.paramtype2 = "facedir"
    copy.tiles[5] = intersect_texture
    copy.node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.0625, 0.5, 0.5, 0.0625}, -- pane
			{-0.0625, -0.5, 0.0625, 0.0625, 0.5, 0.5}, -- intersection
		}
	}
    copy.groups["pane"] = 1
    copy.groups["pane_t"] = 1
    copy.groups["pane_attachable"] = 1
    copy.drop = t_name.."_pane"
    core.register_node(pane_name, copy)
end

local function register_x(t_name, name, intersect_texture, node_def)
    local pane_name = t_name.."_pane_x"
    local copy = table.copy(node_def)
    copy.drawtype = "nodebox"
    copy.description = name.." (X-shaped)"
    copy.paramtype2 = "facedir"
    copy.tiles[5] = intersect_texture
    copy.tiles[6] = intersect_texture
    copy.node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.0625, 0.5, 0.5, 0.0625}, -- pane
			{-0.0625, -0.5, 0.0625, 0.0625, 0.5, 0.5}, -- intersect_1
			{-0.0625, -0.5, -0.5, 0.0625, 0.5, -0.0625}, -- intersect_2
		}
	}
    copy.groups["pane"] = 1
    copy.groups["pane_x"] = 1
    copy.groups["pane_attachable"] = 1
    copy.drop = t_name.."_pane"
    core.register_node(pane_name, copy)
end

local function register_corner(t_name, name, intersect_texture, node_def)
    local pane_name = t_name.."_pane_c"
    local copy = table.copy(node_def)
    copy.drawtype = "nodebox"
    copy.description = name.." (L-shaped)"
    copy.paramtype2 = "facedir"
    copy.node_box = {
		type = "fixed",
		fixed = {
			{-0.0625, -0.5, -0.0625, 0.5, 0.5, 0.0625}, -- intersect_2
			{-0.0625, -0.5, -0.0625, 0.0625, 0.5, 0.5}, -- intersect_1
		}
	}
    copy.groups["pane"] = 1
    copy.groups["pane_c"] = 1
    copy.groups["pane_attachable"] = 1
    copy.drop = t_name.."_pane"
    core.register_node(pane_name, copy)
end

function panes.register_pane(t_name, name, intersect_texture, inventory_image, node_def)
    register_pane_item(t_name, name, inventory_image)
    register_stump(t_name, name, node_def)
    register_short(t_name, name, node_def)
    register_normal(t_name, name, node_def)
    register_t(t_name, name, intersect_texture, node_def)
    register_x(t_name, name, intersect_texture, node_def)
    register_corner(t_name, name, intersect_texture, node_def)
end