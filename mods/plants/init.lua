local S = core.get_translator("mods:plants")
if core.get_modpath("farming") ~= nil then
    dofile(core.get_modpath("plants").."/farmable.lua")
end
plants = {}
function plants.plant_flood(pos, oldnode, newnode)
    local items = core.get_node_drops(oldnode.name)
    for _, item in ipairs(items) do core.add_item(pos, item) end
end
function plants.plant_place(itemstack, placer, pointed_thing)
    if pointed_thing.type ~= "node" then return end
    local node_below = core.get_node(pointed_thing.under)
    local not_soil = core.get_item_group(node_below.name, "soil") == 0
    if not_soil then return end
    core.item_place(itemstack, placer, pointed_thing)
end
function plants.register_plant(plant_tname, plant_name, plant_texture, additional_drops)
    local definition = {}
    definition.description = plant_name
    definition.tiles = {plant_texture}
    definition.inventory_image = plant_texture
    definition.drawtype = "plantlike"
    definition.paramtype = "light"
    definition.paramtype2 = "meshoptions"
    definition.walkable = false
    definition.groups = {oddly_breakable_by_hand = 1}
    local drop_table = {
        max_items = 1,
        items = {
            {
                tool_groups = {"shears"},
                items = {plant_tname}
            }
        }
    }
    if type(additional_drops) == "table" then
        for _, additional_drop in ipairs(additional_drops) do
            table.insert(drop_table.items, additional_drop)
        end
    end
    definition.drop = drop_table
    definition.on_place = plants.plant_place
    definition.on_flood = plants.plant_flood
    base.register_node(plant_tname, definition)
end



function plants.register_mesh_fungus(fungus_tname, fungus_name, fungus_texture, fungus_inventory_texture, fungus_model, crafting_groups)
    local definition = {}
    definition.description = fungus_name
    definition.inventory_image = fungus_inventory_texture
    definition.drawtype = "mesh"
    definition.paramtype = "light"
    definition.mesh = fungus_model
    definition.tiles = {fungus_texture}
    definition.walkable = false
    definition.groups = crafting_groups or {}
    definition.groups.oddly_breakable_by_hand = 1
    definition.on_place = plants.plant_place
    definition.on_flood = plants.plant_flood
    definition.selection_box = {
        type = "fixed",
        fixed = {{-3/16, -5/16, -3/16, 3/16, -3/16, 3/16}, {-1/16, -8/16, -1/16, 1/16, -5/16, 1/16}}
    }
    base.register_node(fungus_tname, definition)
end
function plants.register_normal_fungus(fungus_tname, fungus_name, fungus_texture, crafting_groups)
    local definition = {}
    definition.description = fungus_name
    definition.inventory_image = fungus_texture
    definition.drawtype = "plantlike"
    definition.paramtype = "light"
    definition.tiles = {fungus_texture}
    definition.walkable = false
    definition.groups = crafting_groups or {}
    definition.groups.oddly_breakable_by_hand = 1
    definition.on_place = plants.plant_place
    definition.on_flood = plants.plant_flood
    definition.selection_box = {
        type = "fixed",
        fixed = {-2/16, -8/16, -2/16, 2/16, -2/16, 2/16}
    }
    base.register_node(fungus_tname, definition)
end

local mesh_fungus = core.settings:get_bool("neotest_use_mesh_mushrooms", false) or false
function plants.register_fungus(fungus_tname, fungus_name, fungus_texture, crafting_groups)
    if mesh_fungus then
        plants.register_mesh_fungus(fungus_tname, fungus_name, fungus_texture.."_mesh.png", fungus_texture.."_item.png", "fungus.obj", crafting_groups)
    else
        plants.register_normal_fungus(fungus_tname, fungus_name, fungus_texture.."_item.png", crafting_groups)
    end
end

plants.register_fungus("plants:brown_fungus", S("Brown Fungus"), "plants_brown_fungus", {brown_fungus = 1})
plants.register_fungus("plants:red_fungus", S("Red Fungus"), "plants_red_fungus", {red_fungus = 1})

plants.register_plant("plants:grass", S("Grass"), "plants_grass.png", 
{
    {
        rarity = 3, 
        items = {"plants:wheat_seed"}
    }
})
plants.register_plant("plants:snowy_grass", S("Snowy Grass"), "plants_snowy_grass.png", 
{
    {
        rarity = 3, 
        items = {"plants:wheat_seed"}
    }
})
plants.register_plant("plants:desert_shrub", S("Desert Shrub"), "plants_desert_shrub.png", 
{
    {
        items = {"tree:stick"}
    }
})



local cactus_def = {
    description = S("Cactus"),
    tiles = {"plants_cactus_top.png", "plants_cactus_bottom.png", "plants_cactus_side.png"},
    groups = {choppy = 2, pane_connect = 1},
    on_punch = function(pos, node, puncher)
        if puncher:is_player() then
            local hp = puncher:get_hp()
            puncher:set_hp(hp-1, "Punched a Cactus")
        end
    end
}

base.register_node("plants:cactus", cactus_def)
stairs.register_stair("plants:cactus", cactus_def.description.." Stairs", cactus_def, true)
stairs.register_slab("plants:cactus", cactus_def.description.." Slab", cactus_def, true)
core.register_decoration({
    deco_type = "simple",
    place_on = {"geology:sand"},
    decoration = "plants:desert_shrub",
    biomes = {"biomes:desert"},
    fill_ratio = 0.005,
    y_min = 1,
    height = 1
})
core.register_decoration({
    deco_type = "simple",
    place_on = {"geology:sand"},
    decoration = "plants:cactus",
    biomes = {"biomes:desert"},
    fill_ratio = 0.005,
    y_min = 1,
    height = 1,
    height_max = 3
})
core.register_decoration({
    deco_type = "simple",
    place_on = {"geology:grass_block"},
    decoration = "plants:grass",
    fill_ratio = 0.2,
    y_min = 1,
    height = 1
})
core.register_decoration({
    deco_type = "simple",
    place_on = {"ice:snowy_grass_block"},
    decoration = "plants:snowy_grass",
    fill_ratio = 0.2,
    y_min = 1,
    height = 1
})

loot.add_to_loot_pool({item = "plants:cactus", max_q = 3, prob = 0.2, keys = {"desert"}})