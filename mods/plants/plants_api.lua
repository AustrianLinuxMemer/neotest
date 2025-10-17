plants = {
}
function plants.plant_flood(pos, oldnode, newnode)
    local items = core.get_node_drops(oldnode.name)
    for _, item in ipairs(items) do core.add_item(pos, item) end
end
function plants.valid_light(pos, light_requirement)
    local light = core.get_node_light(pos) or 0
    return light_requirement(light)
end

function plants.get_base_definition(name, texture_name)
    return {
        description = name,
        inventory_image = texture_name,
        tiles = {texture_name}
    }
end
function plants.add_groups(definition, additional_groups)
    for k, v in pairs(additional_groups or {}) do
        definition.groups[k] = v
    end
end
function plants.add_items_to_drops(definition, item_list)
    definition.drop = {
        max_items = 1,
        items = {}
    }
    for _, v in ipairs(item_list) do
        table.insert(definition.drop.items, v)
    end
end
function plants.get_plantlike_definition(name, texture_name)
    definition = plants.get_base_definition(name, texture_name)
    definition.drawtype = "plantlike"
    definition.paramtype = "light"
    definition.paramtype2 = "meshoptions"
    definition.place_param2 = place_param2 or 8
    definition.walkable = false
    return definition
end
function plants.get_signlike_definition(name, texture_name)
    definition = plants.get_base_definition(name, texture_name)
    definition.drawtype = "signlike"
    return definition
end
function plants.register_plantlike_plant(technical_name, name, texture_name, additional_drops, additional_groups, place_param2)
    definition = plants.get_plantlike_definition(name, texture_name, place_param2)
    if type(additional_groups) == "table" then
        definition.groups = additional_groups
        definition.groups.plant = 1
    else
        definition.groups = {plant = 1, oddly_breakable_by_hand = 1}
    end
    definition.drop = {
        max_items = 1,
        items = {
            {
                tools = {"group:shears"},
                items = {technical_name}
            }
        }
    }
    if type(additional_drops) == "table" then
        for _, v in ipairs(additional_drops) do
            table.insert(definition.drop.items, v)
        end
    end
    base.register_node(technical_name, definition)
end

function plants.register_signlike_plant(technical_name, name, texture_name, additional_drops, additional_groups)
    definition = plants.get_signlike_definition(name, texture_name)

end