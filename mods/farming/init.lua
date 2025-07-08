farming = {}

core.register_node("farming:dry_farmland", {
    description = "Dry Farmland",
    tiles = {"farming_dry_farmland_top.png", "farming_dry_farmland_bottom.png"},
    drop = "geology:dirt",
    groups = {crumbly=3, farmland=1}
})
core.register_node("farming:wet_farmland", {
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
core.register_abm({
    label = "Plant growth",
    nodenames = {"group:farming_plant"},
    interval = 1,
    chance = 100,
    action = function(pos)
        local plant = core.get_node(pos)
        local below = core.get_node(vector.new(pos.x, pos.y-1, pos.z))
        
        local is_farmland = core.get_item_group(below.name, "farmland") ~= 0
        local is_wet = core.get_item_group(below.name, "wet") ~= 0
        if is_farmland and is_wet then
            local plant_def = core.registered_nodes[plant.name]
            local next_level = plant_def._next_level
            base.chat_send_all_debug(next_level)
            core.set_node(pos, {name = next_level, param2 = plant_def.place_param2})
        end
    end
})

--[[
    plant_def = {
        seed = {} (item definition of the seed)
        plants = {
            {tname = "", name = "", texture = "", texture_variation = 0, harvest = {}}
        }
    }
]]

local function place_seed(itemstack, placer, pointed_thing, node)
    
    if pointed_thing.type ~= "node" then
        base.chat_send_all_debug("wrong pointed_thing")
        return itemstack
    end
    if base.is_protected(pointed_thing.above, placer:get_player_name(), " tried to plant a seed") then
        base.chat_send_all_debug("protected")
        return itemstack
    end
    local soil = core.get_node(pointed_thing.under)
    local above = core.get_node(pointed_thing.above)
    if core.get_item_group(soil.name, "farmland") ~= 0 then
        base.chat_send_all_debug("placement logic")
        core.set_node(pointed_thing.above, node)
        itemstack:take_item(1)
        return itemstack
    end
end


function farming.register_plant(plant_def)
    for i = 2, #plant_def.plants do
        local current = plant_def.plants[i]
        local previous = plant_def.plants[i-1]
        base.register_node(previous.tname, {
            description = previous.name,
            paramtype2 = "meshoptions",
            drawtype = "plantlike",
            walkable = false,
            sunlight_propagates = true,
            place_param2 = previous.texture_variation,
            tiles = {previous.texture},
            drop = previous.drop,
            groups={farming_plant=1, oddly_breakable_by_hand=1, no_creative=1},
            _next_level = current.tname
        })
    end
    local last_plant = plant_def.plants[#plant_def.plants]
    core.register_node(last_plant.tname, {
        description = last_plant.name,
        paramtype2 = "meshoptions",
        drawtype = "plantlike",
        walkable = false,
        sunlight_propagates = true,
        place_param2 = last_plant.texture_variation,
        tiles = {last_plant.texture},
        groups={last_farming_plant=1, oddly_breakable_by_hand=1, no_creative=1},
        drop = last_plant.drop
        
    })
    for _, v in ipairs(plant_def.harvest) do
        base.register_craftitem(v.name, v.def)
    end
    plant_def.seed.def.on_place = function(itemstack, placer, pointed_thing)
        place_seed(itemstack, placer, pointed_thing, {name = plant_def["plants"][1]["tname"], param2 = plant_def["plants"][1]["texture_variation"]})
    end
    base.register_craftitem(plant_def.seed.name, plant_def.seed.def)
    
end

function farming.tilt_land(itemstack, user, pointed_thing)
    if pointed_thing.type ~= "node" then
        return itemstack
    end
    local above = core.get_node(pointed_thing.above)
    local under = core.get_node(pointed_thing.under)
    if base.is_protected(pointed_thing.under, user:get_player_name(), " tried to tilt farmland") then
        return itemstack
    end
    if core.get_item_group(under.name, "soil") ~= 0 and core.get_item_group(under.name, "farmland") == 0 then
        local tool = itemstack:get_tool_capabilities()
        local use = math.floor(0xFFFF / tool.groupcaps.crumbly.uses)
        itemstack:add_wear(use)
        core.set_node(pointed_thing.under, {name = "farming:dry_farmland"})
        return itemstack
    end
end
function farming.fertilize(itemstack, user, pointed_thing)
    if pointed_thing.type ~= "node" then
        return itemstack
    end
    if base.is_protected(pointed_thing.under, user:get_player_name(), " tried to fertilize") then
        return itemstack
    end
    local plant = core.get_node(pointed_thing.under)
    if core.get_item_group(plant.name, "farming_plant") ~= 0 and math.random() >= 0.7 then
        local plant_def = core.registered_nodes[plant.name]
        local next_level = plant_def._next_level
        core.set_node(pointed_thing.under, {name = next_level, param2 = plant_def.place_param2})
        itemstack:take_item(1)
        return itemstack
    end
end

local wheat_drop = {
    max_items = 5,
    items = {
        {
            rarity = 5,
            items = {"farming:wheat", "farming:wheat_seed 4"}
        },
        {
            rarity = 5,
            items = {"farming:wheat", "farming:wheat_seed 3"}
        },
        {
            rarity = 5,
            items = {"farming:wheat", "farming:wheat_seed 2"}
        },
        {
            rarity = 5,
            items = {"farming:wheat 2", "farming:wheat_seed"}
        },
        {
            rarity = 5,
            items = {"farming:wheat 3", "farming:wheat_seed"}
        }
    }
}
farming.register_plant({
    seed = {
        name = "farming:wheat_seed",
        def = {
            description = "Wheat seeds",
            inventory_image = "farming_wheat_seed.png"
        }
    },
    harvest = {
        {
            name = "farming:wheat",
            def = {
                description = "Wheat",
                inventory_image = "farming_wheat.png"
            }
        }
    },
    plants = {
        {tname = "farming:wheat_1", name = "Wheat (stage 1)", texture = "farming_wheat_plant1.png", texture_variation = 3, drop = "farming:wheat_seeds"},
        {tname = "farming:wheat_2", name = "Wheat (stage 2)", texture = "farming_wheat_plant2.png", texture_variation = 3, drop = "farming:wheat_seeds"},
        {tname = "farming:wheat_3", name = "Wheat (stage 3)", texture = "farming_wheat_plant3.png", texture_variation = 3, drop = "farming:wheat_seeds"},
        {tname = "farming:wheat_4", name = "Wheat (stage 4)", texture = "farming_wheat_plant4.png", texture_variation = 3, drop = "farming:wheat_seeds"},
        {tname = "farming:wheat_5", name = "Wheat (stage 5)", texture = "farming_wheat_plant5.png", texture_variation = 3, drop = "farming:wheat_seeds"},
        {tname = "farming:wheat_6", name = "Wheat (stage 6)", texture = "farming_wheat_plant6.png", texture_variation = 3, drop = "farming:wheat_seeds"},
        {tname = "farming:wheat_7", name = "Wheat (stage 7)", texture = "farming_wheat_plant7.png", texture_variation = 3, drop = wheat_drop},
    }
})