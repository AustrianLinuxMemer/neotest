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
			{-0.0625, -0.5, -0.0625, 0.0625, 0.5, 0.0625}, -- center
			{-0.0625, -0.5, -0.5, 0.0625, 0.5, 0.5}, -- z
			{-0.5, -0.5, -0.0625, 0.5, 0.5, 0.0625}, -- x
		}
	}
})

