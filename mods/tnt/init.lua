tnt = {}
top_anim = {
    name = "tnt_top_ignited_animated.png",
    animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 4
    }
}
function tnt.boom(pos, explosion_radius)
    for object in core.objects_inside_radius(pos, explosion_radius) do
        local object_pos = object:get_pos()
        local direction = vector.direction(pos, object_pos)
        local distance = vector.distance(pos, object_pos)
        local velocity = direction:multiply((explosion_radius / (distance + 0.1))*3.5)
        object:add_velocity(velocity)

        local current_hp = object:get_hp()
        local damage = 12 * math.max(0, 1 - (distance / explosion_radius))
        object:set_hp(current_hp - damage, "Explosion")
    end

    local minp = vector.subtract(pos, explosion_radius)
    local maxp = vector.add(pos, explosion_radius)
    local removal_list = {}
    -- Filtering explosion radius
    for dx = minp.x, maxp.x do
        for dy = minp.y, maxp.y do
            for dz = minp.z, maxp.z do
                local current = vector.new(dx, dy, dz)
                local distance = vector.distance(pos, current)
                if distance <= explosion_radius then
                    if distance >= (explosion_radius - 1) then
                        if math.random() < 0.5 then
                            table.insert(removal_list, current)
                        end
                    else
                        table.insert(removal_list, current)
                    end
                end
            end
        end
    end
    -- Filtering blocks that have an on_blast callback
    local filtered = {}
    for _, current_pos in ipairs(removal_list) do
        local node = core.get_node(current_pos)
        local def = core.registered_nodes[node.name]
        local on_blast = def.on_blast
        if on_blast == nil then
            table.insert(filtered, current_pos)
        else
            on_blast(current_pos, explosion_radius/10)
        end
    end
    
    -- Filtering what has an on_destory callback and making a list of what has an after_destroy callback
    local deferred_callbacks = {}
    local final_candidates = {}
    for _, current_pos in ipairs(filtered) do
        local node = core.get_node(current_pos)
        local def = core.registered_nodes[node.name]
        local on_destruct = def.on_destruct
        local after_destruct = def.after_destruct
        if on_destruct ~= nil then
            on_destruct(current_pos)
            core.set_node(current_pos, {name = "air"})
        elseif after_destruct ~= nil then
            table.insert(deferred_callbacks, {callback = after_destruct, pos = current_pos, oldnode = node})
            table.insert(final_candidates, current_pos)
        else
            table.insert(final_candidates, current_pos)
        end
    end
    local drops = {}
    -- Preparing the LVM
    local lvm = VoxelManip()
    local lminp, lmaxp = lvm:read_from_map(minp, maxp)
    local data = lvm:get_data()
    local voxelarea = VoxelArea(lminp, lmaxp)
    for _, current_pos in ipairs(final_candidates) do
        local idx = voxelarea:indexp(current_pos)
        local old_content = data[idx]
        local name = core.get_name_from_content_id(old_content)
        local node_drops = core.get_node_drops(name, "tnt:tnt_digger")
        for _, drop in ipairs(node_drops) do table.insert(drops, drop) end
        data[idx] = core.get_content_id("air")
    end
    lvm:set_data(data)
    lvm:write_to_map()
    for _, cbk_info in ipairs(deferred_callbacks) do
        cbk_info.callback(cbk_info.pos, cbk_info.oldnode)
    end
    for _, drop in ipairs(drops) do core.add_item(pos, drop) end
end

function tnt.spawn_tnt(pos)
    core.set_node(pos, {name = "tnt:lit_tnt"})
end
base.register_node("tnt:tnt", {
    description = "TNT",
    tiles = {"tnt_top.png", "tnt_bottom.png", "tnt_side.png"},
    groups = {flammable = 1, ignitable = 1, oddly_breakable_by_hand = 1},
    _ignite = tnt.spawn_tnt,
    _burn = tnt.spawn_tnt,
    
})
base.register_node("tnt:lit_tnt", {
    description = "Lit TNT",
    tiles = {top_anim, "tnt_bottom.png", "tnt_side.png"},
    groups = {falling_node = 1, virtual = 1},
    diggable = false,
    on_construct = function(pos)
        local timer = core.get_node_timer(pos)
        timer:start(3)
    end,
    on_timer = function(pos)
        core.set_node(pos, {name = "air"})
        tnt.boom(pos, 5)
    end
})
base.register_node("tnt:gunpowder", {
    description = "Gunpowder",
    paramtype = "light",
    drawtype = "raillike",
    walkable = false,
    inventory_image = "tnt_gunpowder_item.png",
    wield_image = "tnt_gunpowder_item.png",
    tiles = {"tnt_gunpowder_straight.png", "tnt_gunpowder_curve.png", "tnt_gunpowder_t_junction.png", "tnt_gunpowder_cross.png"},
    groups = {oddly_breakable_by_hand = 1}
})

core.register_craft({
    type = "shapeless",
    output = "tnt:gunpowder",
    recipe = {"group:gravel", "group:coal"}
})

core.register_craft({
    type = "shaped",
    output = "tnt:tnt",
    recipe = {
        {"tnt:gunpowder", "group:sand", "tnt:gunpowder"},
        {"group:sand", "tnt:gunpowder", "group:sand"},
        {"tnt:gunpowder", "group:sand", "tnt:gunpowder"}
    }
})

-- Hypothetical tool to be used to get node drops
core.register_tool("tnt:tnt_digger", {
    description = "TNT digger",
    tool_capabilities = {
        full_punch_interval = 0.9,
        max_drop_level=3,
        groupcaps={
            cracky = {cracky = {times={[1]=2.0, [2]=1.0, [3]=0.50}, uses=30, maxlevel=3}},
            snappy = {snappy = {times={[1]=2.0, [2]=1.0, [3]=0.50}, uses=30, maxlevel=3}},
            choppy = {choppy = {times={[1]=2.0, [2]=1.0, [3]=0.50}, uses=30, maxlevel=3}},
            crumbly = {crumbly = {times={[1]=2.0, [2]=1.0, [3]=0.50}, uses=30, maxlevel=3}},
        },
        damage_groups = {fleshy = 5},
    },
    groups = {virtual = 1, test_tool = 1, no_creative = 1}
})