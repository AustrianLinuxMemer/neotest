-- GENERATED CODE
-- Node Box Editor, version 0.9.0
-- Namespace: test

minetest.register_node("test:node_1", {
	tiles = {
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.125, -0.5, -0.125, 0.125, 0.5, 0.125}, -- center
			{-0.5, 0.1875, -0.0625, -0.125, 0.3125, 0.0625}, -- minus_x_top
			{-0.5, -0.3125, -0.0625, -0.125, -0.1875, 0.0625}, -- minux_x_bottom
			{-0.0625, 0.1875, 0.125, 0.0625, 0.3125, 0.5}, -- plus_z_top
			{-0.0625, -0.3125, 0.125, 0.0625, -0.1875, 0.5}, -- plus_z_bottom
			{0.125, 0.1875, -0.0625, 0.5, 0.3125, 0.0625}, -- plus_x_top
			{0.125, -0.3125, -0.0625, 0.5, -0.1875, 0.0625}, -- plus_x_bottom
			{-0.0625, 0.1875, -0.5, 0.0625, 0.3125, -0.125}, -- minus_z_top
			{-0.0625, -0.3125, -0.5, 0.0625, -0.1875, -0.125}, -- minus_z_bottom
		}
	}
})

