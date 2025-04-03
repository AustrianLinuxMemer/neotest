-- Pickaxes

core.register_tool("tools:wooden_pickaxe", {
    description = "Wooden pickaxe",
    inventory_image = "pickaxe_wood.png",
    tool_capabilities = {
		full_punch_interval = 1.2,
		max_drop_level=0,
		groupcaps={
			cracky = {times={[3]=1.60}, uses=10, maxlevel=1},
		},
		damage_groups = {fleshy=2},
	},
})
core.register_craft({
    type = "shaped",
    output = "tools:wooden_pickaxe",
    recipe = {
        {"group:wood", "group:wood", "group:wood"},
        {"", "group:stick", ""},
        {"", "group:stick", ""}
    }
})
core.register_craft({
    type = "fuel",
    recipe = "tools:wooden_pickaxe",
    burntime = 10
})

core.register_tool("tools:stone_pickaxe", {
    description = "Stone pickaxe",
    inventory_image = "pickaxe_stone.png",
    tool_capabilities = {
        full_punch_interval = 1.3,
        groupcaps = {
            cracky = {times={[2]=2.0, [3]=1.00}, uses=20, maxlevel=1}        
        },
        damage_groups = {fleshy=3}
    }
})

core.register_craft({
    type = "shaped",
    output = "tools:stone_pickaxe",
    recipe = {
        {"group:stone", "group:stone", "group:stone"},
        {"", "group:stick", ""},
        {"", "group:stick", ""},    
    }
})

core.register_tool("tools:iron_pickaxe", {
    description = "Iron pickaxe",
    inventory_image = "pickaxe_iron.png",
    tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=1,
		groupcaps={
			cracky = {times={[1]=4.00, [2]=1.60, [3]=0.80}, uses=20, maxlevel=2},
		},
		damage_groups = {fleshy=4},
	}
})

core.register_craft({
    type = "shaped",
    output = "tools:iron_pickaxe",
    recipe = {
        {"geology:iron_ingot", "geology:iron_ingot", "geology:iron_ingot"},
        {"", "group:stick", ""},
        {"", "group:stick", ""},
    }
})

core.register_tool("tools:gold_pickaxe", {
    description = "Golden pickaxe",
    inventory_image = "pickaxe_gold.png",
    tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=1,
		groupcaps={
			cracky = {times={[1]=2.0, [2]=0.8, [3]=0.4}, uses=15, maxlevel=2},
		},
		damage_groups = {fleshy=4},
	}
})

core.register_craft({
    type = "shaped",
    output = "tools:gold_pickaxe",
    recipe = {
        {"geology:gold_ingot", "geology:gold_ingot", "geology:gold_ingot"},
        {"", "group:stick", ""},
        {"", "group:stick", ""},
    }
})

core.register_tool("tools:diamond_pickaxe", {
    description = "Diamond pickaxe",
    inventory_image = "pickaxe_diamond.png",
    tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level=3,
		groupcaps={
			cracky = {times={[1]=2.0, [2]=1.0, [3]=0.50}, uses=30, maxlevel=3},
		},
		damage_groups = {fleshy=5},
	},
})

core.register_craft({
    type = "shaped",
    output = "tools:diamond_pickaxe",
    recipe = {
        {"geology:diamond", "geology:diamond", "geology:diamond"},
        {"", "group:stick", ""},
        {"", "group:stick", ""},
    }
})

core.register_tool("tools:stone_shovel", {
	description = "Stone Shovel",
	inventory_image = "shovel_stone.png",
	wield_image = "shovel_stone.png^[transformR90",
	tool_capabilities = {
		full_punch_interval = 1.4,
		max_drop_level=0,
		groupcaps={
			crumbly = {times={[1]=1.80, [2]=1.20, [3]=0.50}, uses=20, maxlevel=1},
		},
		damage_groups = {fleshy=2},
	}
})

core.register_craft({
    type = "shaped",
    output = "tools:stone_shovel",
    recipe = {
        {"group:stone"},
        {"group:stick"},
        {"group:stick"}
    }
})

core.register_tool("tools:iron_shovel", {
	description = "Iron Shovel",
	inventory_image = "shovel_iron.png",
	wield_image = "shovel_iron.png^[transformR90",
	tool_capabilities = {
		full_punch_interval = 1.1,
		max_drop_level=1,
		groupcaps={
			crumbly = {times={[1]=1.50, [2]=0.90, [3]=0.40}, uses=30, maxlevel=2},
		},
		damage_groups = {fleshy=3},
	}
})

core.register_craft({
    type = "shaped",
    output = "tools:iron_shovel",
    recipe = {
        {"geology:iron_ingot"},
        {"group:stick"},
        {"group:stick"}
    }
})

core.register_tool("tools:gold_shovel", {
	description = "Gold Shovel",
	inventory_image = "shovel_gold.png",
	wield_image = "shovel_gold.png^[transformR90",
	tool_capabilities = {
		full_punch_interval = 1.1,
		max_drop_level=1,
		groupcaps={
			crumbly = {times={[1]=1.10, [2]=0.5, [3]=0.3}, uses=10, maxlevel=2},
		},
		damage_groups = {fleshy=3},
	}
})

core.register_craft({
    type = "shaped",
    output = "tools:gold_shovel",
    recipe = {
        {"geology:gold_ingot"},
        {"group:stick"},
        {"group:stick"}
    }
})

core.register_tool("tools:diamond_shovel", {
	description = "Diamond Shovel",
	inventory_image = "shovel_diamond.png",
	wield_image = "shovel_diamond.png^[transformR90",
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=1,
		groupcaps={
			crumbly = {times={[1]=1.10, [2]=0.50, [3]=0.30}, uses=30, maxlevel=3},
		},
		damage_groups = {fleshy=4},
	}
})

core.register_craft({
    type = "shaped",
    output = "tools:diamond_shovel",
    recipe = {
        {"geology:diamond"},
        {"group:stick"},
        {"group:stick"}
    }
})
