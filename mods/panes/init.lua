panes = {}

function panes.register_pane(t_name, name, texture_item, node_def)
    pane_def = table.copy(node_def)
    if pane_def.groups == nil then
        pane_def.groups = {}
    end
    pane_def.groups.pane = 1
    pane_def.groups.pane_connect = 1
    pane_def.connects_to = {"group:pane", "group:pane_connect"}
    pane_def.drawtype = "nodebox"
    pane_def.inventory_image = texture_item
    pane_def.wield_image = texture_item
    pane_def.node_box = {
        type = "connected",
        fixed = {{-1/32, -1/2, -1/32, 1/32, 1/2, 1/32}},
        connect_front = {{-1/32, -1/2, -1/2, 1/32, 1/2, -1/32}},
        connect_left = {{-1/2, -1/2, -1/32, -1/32, 1/2, 1/32}},
        connect_back = {{-1/32, -1/2, 1/32, 1/32, 1/2, 1/2}},
        connect_right = {{1/32, -1/2, -1/32, 1/2, 1/2, 1/32}},
    }
    core.register_node(t_name.."_pane", pane_def)
end