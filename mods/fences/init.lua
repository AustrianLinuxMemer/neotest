fences = {}

function fences.register_fence(t_name, name, node_def)
    local fence_def = table.copy(node_def)
    fence_def.description = name
    fence_def.paramtype = "light"
    fence_def.sunlight_propagates = true
    if fence_def.groups == nil then
        fence_def.groups = {fence = 1, connect_fence = 1}
    else
        fence_def.groups["fence"] = 1
        fence_def.groups["connect_fence"] = 1
    end
    fence_def.drawtype = "nodebox"
    fence_def.node_box = {
        type = "connected",
        fixed = {-0.125, -0.5, -0.125, 0.125, 0.5, 0.125}, --center
        connect_left = {
            {-0.5, 0.1875, -0.0625, -0.125, 0.3125, 0.0625}, -- minus_x_top
			{-0.5, -0.3125, -0.0625, -0.125, -0.1875, 0.0625}, -- minux_x_bottom
        },
        connect_back = {
            {-0.0625, 0.1875, 0.125, 0.0625, 0.3125, 0.5}, -- plus_z_top
			{-0.0625, -0.3125, 0.125, 0.0625, -0.1875, 0.5}, -- plus_z_bottom
        },
        connect_right = {
            {0.125, 0.1875, -0.0625, 0.5, 0.3125, 0.0625}, -- plus_x_top
			{0.125, -0.3125, -0.0625, 0.5, -0.1875, 0.0625}, -- plus_x_bottom
        },
        connect_front = {
            {-0.0625, 0.1875, -0.5, 0.0625, 0.3125, -0.125}, -- minus_z_top
			{-0.0625, -0.3125, -0.5, 0.0625, -0.1875, -0.125}, -- minus_z_bottom
        }
    }
    fence_def.connects_to = {"group:fence", "group:connect_fence"}
    core.register_node(t_name, fence_def)
end