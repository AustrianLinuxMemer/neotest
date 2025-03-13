local creative = core.settings:get_bool("creative_mode", false) or false
local hand_survival = {
    type = "none",  -- Makes it the player's hand
    wield_image = "wieldhand.png",
    wield_scale = {x = 1, y = 1, z = 2.5},
    tool_capabilities = {
        full_punch_interval = 1.0,  -- How fast the player can hit
        max_drop_level = 0,
        groupcaps = {
            crumbly = {times = {[1] = 3.0, [2] = 1.4, [3] = 0.6}, uses = 0}, -- Faster digging for crumbly nodes
            snappy = {times = {[1] = 2.0, [2] = 1.0, [3] = 0.4}, uses = 0}, -- Adjust snappy nodes
            choppy = {times = {[1] = 3.0, [2] = 2.0, [3] = 1.0, }, uses = 0}, -- Still slow for stone-like blocks
        },
        damage_groups = {fleshy = 1},
    }
}
local hand_creative = {
    type = "none",  -- Makes it the player's hand
    wield_image = "wieldhand.png",
    wield_scale = {x = 1, y = 1, z = 2.5},
    tool_capabilities = {
        full_punch_interval = 1.0,  -- How fast the player can hit
        max_drop_level = 0,
        groupcaps = {
            crumbly = {times = {[1] = 0, [2] = 0, [3] = 0}, uses = 0}, -- Faster digging for crumbly nodes
            snappy = {times = {[1] = 0, [2] = 0, [3] = 0}, uses = 0}, -- Adjust snappy nodes
            choppy = {times = {[1] = 0, [2] = 0, [3] = 0}, uses = 0},
            cracky = {times = {[1] = 0, [2] = 0, [3] = 0}, uses = 0},
            oddly_breakable_by_hand = {times = {[1] = 0, [2] = 0, [3] = 0}, uses = 0}, -- Still slow for stone-like blocks
        },
        damage_groups = {fleshy = 1000},
    }
}
if creative then
    core.register_item(":", hand_creative)
else
    core.register_item(":", hand_survival)
end
