minetest.register_item(":", {
    type = "none",  -- Makes it the player's hand
    wield_image = "wieldhand.png",
    wield_scale = {x = 1, y = 1, z = 2.5},
    tool_capabilities = {
        full_punch_interval = 1.0,  -- How fast the player can hit
        max_drop_level = 0,
        groupcaps = {
            crumbly = {times = {[1] = 1.5, [2] = 0.7, [3] = 0.3}, uses = 0}, -- Faster digging for crumbly nodes
            snappy = {times = {[1] = 1.0, [2] = 0.5, [3] = 0.2}, uses = 0}, -- Adjust snappy nodes
            choppy = {times = {[1] = 2.0, [2] = 1.0, [3] = 0.5}, uses = 0},
            oddly_breakable_by_hand = {times = {[1] = 2.0, [2] = 1.0, [3] = 0.5}, uses = 0}, -- Still slow for stone-like blocks
        },
        damage_groups = {fleshy = 1},
    }
})
