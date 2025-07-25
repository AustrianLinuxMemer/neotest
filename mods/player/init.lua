local creative = core.settings:get_bool("creative_mode", false)
local creative_singleplayer_autogrant_privs = core.settings:get_bool("neotest_creative_singleplayer_autogrant_privs", false)
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
            oddly_breakable_by_hand = {times = {[1] = 0, [2] = 0, [3] = 0}, uses = 0}
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
            crumbly = {times = {[1] = 0.1, [2] = 0.1, [3] = 0.1}, uses = 0}, -- Faster digging for crumbly nodes
            snappy = {times = {[1] = 0.1, [2] = 0.1, [3] = 0.1}, uses = 0}, -- Adjust snappy nodes
            choppy = {times = {[1] = 0.1, [2] = 0.1, [3] = 0.1}, uses = 0},
            cracky = {times = {[1] = 0.1, [2] = 0.1, [3] = 0.1}, uses = 0},
            oddly_breakable_by_hand = {times = {[1] = 0.1, [2] = 0.1, [3] = 0.1}, uses = 0}, -- Still slow for stone-like blocks
        },
        damage_groups = {fleshy = 1000},
    }
}
-- Setting up the Player's appearence to remove the alien look default in the Minetest engine
core.register_on_joinplayer(function(player, last_login)
    player:set_properties({
        visual = "mesh",
        textures = {"player.png"},
        visual_size = {x=10, y=10, z=10},
        rotation = {x = 0, y = 0, z = 90},
        mesh = "player.gltf",
        physical = true
    })
    sfinv.set_player_inventory_formspec(player)
end)

local player_animation_state = {}
local player_animation_range = {
    walking = {x = 0, y = 80},
    walking_punching = {x = 0, y = 0},
    walking_holding = {x = 0, y = 0},
    sneaking = {x = 0, y = 0},
    sneaking_punching = {x = 0, y = 0},
    sneaking_holding = {x = 0, y = 0},
    standing = {x = 0, y = 0},
    standing_punching = {x = 0, y = 0},
    standing_holding = {x = 0, y = 0}
    
}

core.register_globalstep(function(dtime)
    for _, player in pairs(core.get_connected_players()) do
        local velocity = player:get_velocity()
        local speed = math.sqrt(velocity.x^2 + velocity.z^2)
        local name = player:get_player_name()
        local animation = player_animation_state[name]
        if speed > 0 then
            if animation ~= "walking" then
                player:set_animation({x = 0, y = 80}, 2, 0.5, true)
                player_animation_state[name] = "walking"
            end
        else
            if animation ~= "standing" then
                player:set_animation({x = 81, y = 82}, 20, 0, false)
                player_animation_state[name] = "standing"
            end
        end
    end
end)



if creative then
    core.register_tool(":", hand_creative)
    -- Grant all privileges to "singleplayer" if configured to do so
    if core.is_singleplayer() and creative_singleplayer_autogrant_privs then
        core.register_on_joinplayer(function(player, last_login)
            local name = player:get_player_name()
            local grant = {}
            for k, _ in pairs(core.registered_privileges) do
                grant[k] = true
            end
            core.set_player_privs(name, grant)
        end)
    end
else
    core.register_tool(":", hand_survival)
end

local keep_inventory = core.settings:get_bool("neotest_keep_inventory", false)

if not keep_inventory then
    core.register_on_dieplayer(function(player, reason)
        local inv = player:get_inventory()
        local pos = player:get_pos()
        local main = inv:get_list("main")
        local craft = inv:get_list("craft")
        for i, item in ipairs(main) do
            core.add_item(pos, item)
            inv:set_stack("main", i, ItemStack())
        end
        for i, item in ipairs(craft) do
            core.add_item(pos, item)
            inv:set_stack("craft", i, ItemStack())
        end
    end)
end

