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
function plants.grow_plant(pos, plant_name, light_requirement)
    neighboring_ground = {
        {x = pos.x - 1, z = pos.z - 1},
        {x = pos.x, z = pos.z - 1},
        {x = pos.x + 1, z = pos.z - 1},
        {x = pos.x - 1, z = pos.z + 1},
        {x = pos.x, z = pos.z + 1},
        {x = pos.x + 1, z = pos.z + 1},
    }
    for _, n in ipairs(neighboring_ground) do
        local upper = vector.new(n.x, pos.y, n.z)
        local lower = vector.new(n.x, pos.y-1, n.z)

        local soil_node = core.get_node(lower)
        local neighbor_node = core.get_node(upper)
        
        local is_soil = core.get_item_group(soil_node.name, "soil") ~= 0
        local is_air = neighbor_node.name == "air"
        local light = core.get_node_light(upper) or 0
        local is_bright = light_requirement(light)
        if is_soil and is_air and is_bright then
            core.set_node(upper, {name = plant_name})
            break
        end
    end
end
function plants.register_plant(plant_tname, plant_name, plant_texture, additional_drops, do_grow)
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
    if do_grow then
        core.register_abm({
            label = "Plant Growth for "..plant_name,
            nodenames = {plant_tname},
            interval = 5,
            chance = 50,
            action = function(pos)
                plants.grow_plant(pos, plant_tname, function(l) return l >= 5 end)
            end
        })
    end
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
function plants.register_fungus(fungus_tname, fungus_name, fungus_texture, crafting_groups, do_grow)
    if mesh_fungus then
        plants.register_mesh_fungus(fungus_tname, fungus_name, fungus_texture.."_mesh.png", fungus_texture.."_item.png", "fungus.obj", crafting_groups)
    else
        plants.register_normal_fungus(fungus_tname, fungus_name, fungus_texture.."_item.png", crafting_groups)
    end
    if do_grow then
        core.register_abm({
            label = "Plant Growth for "..fungus_name,
            nodenames = {fungus_tname},
            interval = 5,
            chance = 50,
            action = function(pos)
                plants.grow_plant(pos, fungus_tname, function(l) return l <= 3 end)
            end
        })
    end
end