local S = core.get_translator("mods:ice")
ice = {
    melt_into = {},
    freeze_into = {},
    snows = {},
    ices = {},
}


function ice.register_ice(ice_name, liquid_name, node_def)
    local ice_def = table.copy(node_def)
    ice.melt_into[ice_name] = liquid_name
    ice.freeze_into[liquid_name] = ice_name
    ice.ices[ice_name] = true
    if ice_def.groups == nil then ice_def.groups = {} end
    ice_def.groups.melts = 1
    core.register_node(ice_name, ice_def)
end
function ice.freeze(pos)
    local liquid_name = core.get_node(pos).name
    local ice_name = ice.freeze_into[liquid_name]
    if ice_name ~= nil then
        core.set_node(pos, {name = ice_name})
    end
end
function ice.melt_ice(pos)
    local node_name = core.get_node(pos).name
    local liquid_name = ice.melt_into[node_name]
    if liquid_name ~= nil then
        core.set_node(pos, {name = liquid_name})
    end
end
ice.register_ice("ice:water_ice", "liquids:water_source", {
    description = S("Ice"),
    tiles = {"ice_ice.png"},
    groups = {cracky = 3, water_ice = 1}
})
ice.register_ice("ice:river_water_ice", "liquids:river_water_source", {
    description = S("River Ice"),
    tiles = {"ice_river_ice.png"},
    groups = {cracky = 3, water_ice = 1}
})

function ice.pile_snow(pos)
    local node = core.get_node(pos)
    local is_snow = ice.snows[node.name]
    if is_snow and node.param2 < 64 then
        local new_param2 = math.min(node.param2 + 8, 64)
        core.swap_node(pos, {name = node.name, param2 = new_param2})
        return true
    end
    return false
end
function ice.melt_snow(pos)
    local node = core.get_node(pos)
    local is_snow = ice.snows[node.name]
    if is_snow then
        if node.param2 <= 8 then
            core.set_node(pos, {name = "air"})
        else
            local new_param2 = node.param2 - 8
            core.swap_node(pos, {name = node.name, param2 = new_param2})
        end
    end
end
function ice.place_snow(itemstack, placer, pointed_thing, snow_name)
    if pointed_thing.type ~= "node" then
        return
    end
    if base.is_protected(pos, placer:get_player_name(), S("place a layer of @1", snow_name)) then
        return
    end
    local above = core.get_node(pointed_thing.above)
    local under = core.get_node(pointed_thing.under)
    local successful = false
    if ice.snows[under.name] and under.param2 < 64 then
        successful = ice.pile_snow(pointed_thing.under)
    elseif ice.snows[above.name] and above.param2 < 64 then
        successful = ice.pile_snow(pointed_thing.above)
    else
        core.place_node(pointed_thing.above, {name = snow_name, param2 = 8})
        successful = true
    end
    if successful then
        itemstack:take_item(1)
        return itemstack
    end
end
function ice.dig_snow(pos, node, digger, snowball)
    local node = core.get_node(pos)
    local how_many_snowballs = math.floor(node.param2 / 8)
    if base.is_protected(pos, digger:get_player_name(), S("dug @1", node.name)) then
        return false
    end
    core.node_dig(pos, node, digger)
    local inventory = digger:get_inventory()
    local snowballs = ItemStack({name = snowball, count = how_many_snowballs})
    local leftovers = inventory:add_item("main", snowballs)
    if leftovers:get_count() > 0 then
        core.add_item(pos, leftovers)
    end
    return true
end
function ice.register_snow(snow_name, node_def, snowball_name, item_def)
    local snow_def = table.copy(node_def)
    local snowball_def = table.copy(item_def)
    ice.snows[snow_name] = true
    snow_def.drawtype = "nodebox"
    snow_def.paramtype = "light"
    snow_def.paramtype2 = "leveled"
    snow_def.node_box = {
        type = "leveled",
        fixed = {-8/16, -8/16, -8/16, 8/16, -7/16, 8/16}
    }
    if snow_def.groups == nil then snow_def.groups = {} end
    snow_def.groups.snow = 1
    snow_def.groups.melts = 1
    snow_def.groups.falling_node = 1
    snow_def.groups.no_creative = 1
    snow_def.place_param2 = 8
    snow_def.leveled_max = 64
    snow_def.drop = ""
    function snow_def.on_dig(pos, node, digger)
        return ice.dig_snow(pos, node, digger, snowball_name)
    end
    function snowball_def.on_place(itemstack, placer, pointed_thing)
        return ice.place_snow(itemstack, placer, pointed_thing, snow_name)
    end
    snowball_def.stack_max = snowball_def.stack_max or 16
    base.register_node(snow_name, snow_def)
    base.register_craftitem(snowball_name, snowball_def)
end

ice.register_snow("ice:snow", {
    description = S("Snow layer"),
    tiles = {"ice_snow.png"},
    groups = {crumbly=3}
}, "ice:snowball", {
    description = S("Snow ball"),
    inventory_image = "ice_snowball.png"
})


function ice.melt(pos)
    local node_name = core.get_node(pos).name
    if ice.ices[node_name] then
        ice.melt_ice(pos)
    elseif ice.snows[node_name] then
        ice.melt_snow(pos)
    end
end

-- Melting
core.register_abm({
    nodenames = {"group:melts"},
    chance = 25,
    interval = 10,
    action = function(pos)
        local biome_data = core.get_biome_data(pos)
        if biome_data.heat >= 25 then
            ice.melt(pos)
        end
    end
})
-- Freeze
core.register_abm({
    nodenames = {"group:water"},
    chance = 25,
    interval = 10,
    action = function(pos)
        local node_above = core.get_node(vector.new(pos.x, pos.y + 1, pos.z))
        local biome_data = core.get_biome_data(pos)
        if biome_data.heat < 25 and node_above.name == "air" then
            ice.freeze(pos)
        end
    end
})