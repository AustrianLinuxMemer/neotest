farming = {}

function farming.tilt_land(itemstack, user, pointed_thing)
    if pointed_thing.type ~= "node" then
        return itemstack
    end
    if base.is_protected(pointed_thing.below, user:get_player_name(), " tried to tilt farmland") then
        return itemstack
    end
    if core.get_node_group(pointed_thing.below, "soil") ~= 0 then
        local tool = itemstack:get_tool_capabilities()
        local use = math.floor(0xFFFF / tool.groupcaps.crumbly.uses)
        itemstack:add_wear(use)
        return itemstack
    end
end