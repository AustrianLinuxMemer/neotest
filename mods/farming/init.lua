farming = {
    plant_registry = {},
    seed_registry = {}
}
local S = core.get_translator("mods:farming")
local creative = core.settings:get_bool("creative_mode", false) or false
base.register_node("farming:dry_farmland", {
    description = "Dry Farmland",
    tiles = {"farming_dry_farmland_top.png", "farming_dry_farmland_bottom.png"},
    drop = "geology:dirt",
    groups = {crumbly=3, farmland=1}
})
base.register_node("farming:wet_farmland", {
    description = "Wet Farmland",
    tiles = {"farming_wet_farmland_top.png", "farming_wet_farmland_bottom.png"},
    drop = "geology:dirt",
    groups = {crumbly=3, farmland=1, wet=1, no_creative=1}
})

core.register_abm({
    label = "Farmland wetting",
    nodenames = {"farming:dry_farmland"},
    interval = 1,
    chance = 100,
    action = function(pos)
        local is_water = false
        local found = core.find_node_near(pos, 4, "group:water")
        if found ~= nil then
            core.set_node(pos, {name = "farming:wet_farmland"})
        end
    end
})
core.register_abm({
    label = "Farmland degredation",
    nodenames = {"farming:dry_farmland"},
    interval = 3,
    chance = 100,
    action = function(pos)
        local is_water = false
        local found = core.find_node_near(pos, 4, "group:water")
        if found == nil then
            core.set_node(pos, {name = "geology:dirt"})
        end
    end
})
core.register_abm({
    label = "Farmland drying",
    nodenames = {"farming:wet_farmland"},
    interval = 1,
    chance = 100,
    action = function(pos)
        local is_water = false
        local found = core.find_node_near(pos, 4, "group:water")
        if found == nil then
            core.set_node(pos, {name = "farming:dry_farmland"})
        end
    end
})

local function get_pos_below(pointed_thing)
    local direction = vector.subtract(pointed_thing.above, pointed_thing.under)
    if direction.y > 0 then
        return vector.add(pointed_thing.above, vector.new(0, -1, 0))
    elseif direction.y < 0 then
        return pointed_thing.under
    else
        return vector.add(pointed_thing.above, vector.new(0, -1, 0))
    end
end
function farming.register_crop(plant_def)
    farming.seed_registry[plant_def.seed] = plant_def.plants[1]

    core.override_item(plant_def.seed, {
        on_place = function(itemstack, placer, pointed_thing)
            if pointed_thing.type ~= "node" then return end
            local direction = vector.subtract(pointed_thing.above, pointed_thing.under)
            local pos_below = get_pos_below(pointed_thing)
            local node_below = core.get_node(pos_below)
            local is_farmland = core.get_item_group(node_below.name, "farmland") ~= 0
            if base.is_protected(pointed_thing.above, placer:get_player_name(), S("placed seed of "..plant_def.seed)) then
                return itemstack
            end
            if is_farmland then
                core.place_node(pointed_thing.above, {name = farming.seed_registry[plant_def.seed]})
                if not creative then
                    itemstack:take_item(1)
                    return itemstack                
                end
            end
        end
    })

    for i = 1, #plant_def.plants do
        local last = plant_def.plants[i]
        local current = plant_def.plants[i+1]
        farming.plant_registry[last] = current
    end
    local function grow(pos)
        local node = core.get_node(pos)
        local node_below = core.get_node(vector.add(pos, vector.new(0, -1, 0)))
        local next_plant = farming.plant_registry[node.name]

        local is_farmland = core.get_item_group(node_below.name, "farmland") ~= 0
        local is_wet = core.get_item_group(node_below.name, "wet") ~= 0

        if next_plant ~= nil and is_farmland and is_wet then
            local new_node = {name = next_plant, param2 = node.param2}
            core.swap_node(pos, new_node)
        end
    end
    core.register_abm({
        nodenames = table.copy(plant_def.plants),
        interval = 1,
        chance = 100,
        action = grow
    })
end

function farming.tilt_land(itemstack, user, pointed_thing)
    if pointed_thing.type ~= "node" then
        return itemstack
    end
    local above = core.get_node(pointed_thing.above)
    local under = core.get_node(pointed_thing.under)
    local msg = S("tilt farmland")
    if base.is_protected(pointed_thing.under, user:get_player_name(), msg) then
        return itemstack
    end
    if core.get_item_group(under.name, "soil") ~= 0 and core.get_item_group(under.name, "farmland") == 0 then
        if not creative then
            local tool = itemstack:get_tool_capabilities()
            local use = math.floor(0xFFFF / tool.groupcaps.crumbly.uses)
            itemstack:add_wear(use)
        end
        core.set_node(pointed_thing.under, {name = "farming:dry_farmland"})
        return itemstack
    end
end
function farming.fertilize(itemstack, user, pointed_thing)
    if pointed_thing.type ~= "node" then
        return itemstack
    end
    local msg = S("fertilize")
    if base.is_protected(pointed_thing.under, user:get_player_name(), msg) then
        return itemstack
    end
    local plant = core.get_node(pointed_thing.under)
    if farming.plant_registry[plant.name] ~= nil then
        if math.random() >= 0.7 then
            local next_level = farming.plant_registry[plant.name]
            if next_level ~= nil then
                core.set_node(pointed_thing.under, {name = next_level, param2 = plant.param2})
            end
        end
        if not creative then
            itemstack:take_item(1)
        end
        return itemstack
    end
end