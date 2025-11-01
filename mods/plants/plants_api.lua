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
--[[
    PlantDropTable:
    {
        drop_self_shears = boolean?,
        drop_otherwise = {
            max_items = integer
            items = {
                For examples, see Luanti Modding API, Section "Definition Tables", Subsection "Node Definition", § drop §§ items
            }
        }
    }
]]


--[[
    Definition:
    {
        description = string,
        inventory_image = string | TileDef
        texture = string | TileDef
        drop = PlantDropTable?
        place_on = {
            node_names = list[string]?,
            group_names = table[string,boolean]?
        }?,
        groups = table[string,integer]?
        grow = {
            light_requirement = function(integer) -> boolean,
            grow = function(pos) -> void,
            rate = integer[second],
            chance = integer[0-100]
        }
    }
]]

local function get_drops(plant_drop_def, technical_name)
    if type(plant_drop_def) == "string" then return plant_drop_def end
    if type(plant_drop_def) == "table" then 
        shears_case = plant_drop_def.drop_self_shears
        additional_case_table = type(plant_drop_def.drop_otherwise) == "table"
        items = {}
        max_items = 1
        if shears_case then
            table.insert(items, {tool_groups = {"shears"}, rarity = 1, items = {technical_name}})
        end
        if additional_case_table then
            max_items = plant_drop_def.drop_otherwise.max_items
            for _, item in ipairs(plant_drop_def.drop_otherwise.items) do
                table.insert(items, item)
            end
        end
        return {
            max_items = max_items,
            items = items
        }
    end
    if type(plant_drop_def) == "nil" then
        return {
            max_items = 1,
            items = {
                {
                    tool_groups = {"shears"},
                    rarity = 1,
                    items = {technical_name}
                }
            }
        }
    end
    error("drop of plant definition is neither string, table or nil")
end

local function register_growth_abm(grow_def, technical_name)
    if type(grow_def.grow) ~= "function" or type(grow_def.light_requirement) ~= "function" or type(grow_def.chance) ~= "number" or type(grow_def.rate) ~= "number" then return end
    core.register_abm({
        label = "Growth for "..technical_name,
        nodenames = {technical_name},
        interval = grow_def.rate,
        chance = grow_def.chance,
        action = function(pos)
            if plants.valid_light(pos, grow_def.light_requirement) then
                grow_def.grow(pos)
            end
        end
    })
end

function plants.register_lilypad_like(technical_name, definition)
    local function check_place(pointed_thing, player_name, msg)
        -- Protection check
        if base.is_protected(pointed_thing.above, player_name, msg) then return false end
        
        -- Directional check, only placing downwards is allowed
        local direction = vector.subtract(pointed_thing.under, pointed_thing.above)
        if direction.y >= 0 then
            core.log("error", "directional_check failed") 
            return false 
        end

        -- Neighbor check
        local name = core.get_node(pointed_thing.under).name
        if definition.place_on then
            if definition.place_on.node_names then
                if definition.place_on.node_names[name] then
                    return true
                end  
            elseif definition.place_on.group_names then
                for _, group in ipairs(definition.place_on.group_names) do
                    if core.get_item_group(name, group) ~= 0 then
                        return true
                    end
                end
                return false
            end
            return false
        else
            return true
        end
    end
    plant_def = {
        description = definition.description,
        drawtype = "signlike",
        paramtype2 = "none",
        paramtype = "light",
        liquids_pointable = definition.liquids_pointable or true,
        node_placement_prediction = "",
        tiles = {definition.texture},
        inventory_image = definition.inventory_image,
        drop = get_drops(definition.drop, technical_name),
        on_place = function(itemstack, placer, pointed_thing)
            creative_mode = core.settings:get_bool("creative_mode", false)
            if pointed_thing.type ~= "node" then return end
            if placer == nil then return end
            if not placer:is_valid() then return end
            is_place = check_place(pointed_thing, placer:get_player_name(), " tried to place "..technical_name)
            if is_place then
                core.set_node(pointed_thing.above, {name = technical_name})
                if not creative_mode then
                    itemstack:take_item(1)
                    return itemstack
                end
            end
        end,
        groups = {plant = 1, flammable = 1, attached_node = 3}
    }
    if definition.groups then
        for group, rating in pairs(definition.groups) do
            plant_def.groups[group] = rating
        end
    end
    if type(definition.grow) == "table" then
        register_growth_abm(definiton.grow, technical_name)
    end
    base.register_node(technical_name, plant_def)
end

function plants.register_vine_like(technical_name, definition)
    local function break_chain_reaction(pos, node, digger)
        local function add(itemstack, force_drop)
            if digger ~= nil and digger:is_valid() and digger:is_player() then
                if not force_drop then
                    local inventory = digger:get_inventory()
                    local leftover = digger:add_item("main", itemstack)
                    core.add_item(pos, leftover)
                    return
                end
            end
            core.add_item(pos, itemstack)
        end
        local function tool()
            if digger ~= nil and digger:is_valid() and digger:is_player() then
                return digger:get_wielded_item()
            else
                return ItemStack()
            end
        end
        local drops = {}
        local tool = tool()
        local tool_name = tool:get_name()

        local here_drops = core.get_node_drops(node.name, tool_name)
        core.set_node(pos, {name = "air"})
        for _, drop in ipairs(here_drops) do
            add(drop)
        end

        for i = pos.y-1, -31000, -1 do
            local current_pos = vector.new(pos.x, i, pos.z)
            local current_node = core.get_node(current_pos)
            local current_name = current_node.name
            local current_param2 = current_node.param2
            if current_name == technical_name then
                local direction = core.wallmounted_to_dir(current_param2)
                local behind_pos = vector.add(current_pos, direction)
                local behind_node = core.get_node(behind_pos)
                local behind_name = behind_node.name
                local behind_def = core.registered_nodes[behind_name] or {walkable = false}
                if not behind_def.walkable then
                    local current_drops = core.get_node_drops(current_name, tool_name)
                    for _, drop in ipairs(current_drops) do
                        table.insert(drops, drop)
                    end
                    core.set_node(current_pos, {name = "air"})
                else
                    break
                end
            else
                break
            end
        end
        for _, item in ipairs(drops) do
            add(item, true)
        end
    end
    local function check_place(pointed_thing, player_name, msg)
        -- Protection check
        if base.is_protected(pointed_thing.above, player_name, msg) then
            return false, nil
        end

        -- Directional check, placing down only if vines above already exist, up forbidden and sides if a node is behind
        local direction = vector.subtract(pointed_thing.under, pointed_thing.above)
        if direction.y ~= 0 then
            if direction.y > 0 then
                local above = core.get_node(pointed_thing.under)
                local above_name = above.name
                local above_param2 = above.param2
                -- x+; east; 2, x-; west; 3, z+; north; 4, z-; south; 5
                local neighbors = {
                    [2] = vector.new(pointed_thing.above.x+1, pointed_thing.above.y, pointed_thing.above.z),
                    [3] = vector.new(pointed_thing.above.x-1, pointed_thing.above.y, pointed_thing.above.z),
                    [4] = vector.new(pointed_thing.above.x, pointed_thing.above.y, pointed_thing.above.z+1),
                    [5] = vector.new(pointed_thing.above.x, pointed_thing.above.y, pointed_thing.above.z-1)
                }
                local valid_neighbors = {}
                for facedir, neighbor in pairs(neighbors) do
                    name = core.get_node(neighbor).name
                    definition = core.registered_nodes[name] or {walkable = false}
                    if definition.walkable then
                        valid_neighbors[facedir] = neighbor
                    end                    
                end
                
                if above_name == technical_name then
                    return true, above_param2
                else
                    return false, nil
                end
            end
            if direction.y < 0 then
                local under = core.get_node(pointed_thing.under)
                local under_name = under.name
                local under_param2 = under.param2
                
                local neighbors = {
                    [2] = vector.new(pointed_thing.above.x+1, pointed_thing.above.y, pointed_thing.above.z),
                    [3] = vector.new(pointed_thing.above.x-1, pointed_thing.above.y, pointed_thing.above.z),
                    [4] = vector.new(pointed_thing.above.x, pointed_thing.above.y, pointed_thing.above.z+1),
                    [5] = vector.new(pointed_thing.above.x, pointed_thing.above.y, pointed_thing.above.z-1)
                }
                local valid_neighbors = {}
                for facedir, neighbor in pairs(neighbors) do
                    name = core.get_node(neighbor).name
                    definition = core.registered_nodes[name] or {walkable = false}
                    if definition.walkable then
                        valid_neighbors[facedir] = neighbor
                    end                    
                end

                if under_name == technical_name then
                    if valid_neighbors[under_param2] then
                        return true, under_param2
                    else
                        return false, nil
                    end
                else
                end
                return false, nil
            end
        else
            return true, core.dir_to_wallmounted(direction)
        end
    end
    box = {
        type = "wallmounted",
        wall_top = {-8/16, 7/16, -8/16, 8/16, 8/16, 8/16},
        wall_bottom = {-8/16, -8/16, -8/16, 8/16, -7/16, 8/16},
        wall_side = {-8/16, -8/16, -8/16, -7/16, 8/16, 8/16}
    }
    plant_def = {
        description = definition.description,
        drawtype = "signlike",
        paramtype2 = "wallmounted",
        paramtype = "light",
        selection_box = box,
        collision_box = box,
        walkable = definition.walkable or false,
        climbable = definition.climbable or false,
        floodable = definition.floodable or true,
        liquids_pointable = definition.liquids_pointable or true,
        node_placement_prediction = "",
        tiles = {definition.texture},
        inventory_image = definition.inventory_image,
        drop = get_drops(definition.drop, technical_name),
        on_place = function(itemstack, placer, pointed_thing)
            creative_mode = core.settings:get_bool("creative_mode", false)
            if pointed_thing.type ~= "node" then return end
            if placer == nil then return end
            if not placer:is_valid() then return end
            is_place, param2 = check_place(pointed_thing, placer:get_player_name(), " tried to place "..technical_name, placer:get_look_horizontal())
            if is_place then
                core.set_node(pointed_thing.above, {name = technical_name, param2 = param2})
                if not creative_mode then
                    itemstack:take_item(1)
                    return itemstack
                end
            end

        end,
        on_dig = break_chain_reaction,
        on_flood = function(pos, oldnode)
            break_chain_reaction(pos, oldnode, nil)
        end,
        on_blast = function(pos)
            node = core.get_node()
            break_chain_reaction(pos, node, nil)
        end,
        groups = {plant = 1, flammable = 1}
    }
    if definition.groups then
        for group, rating in pairs(definition.groups) do
            plant_def.groups[group] = rating
        end
    end
    if type(definition.grow) == "table" then
        register_growth_abm(definiton.grow, technical_name)
    end
    base.register_node(technical_name, plant_def)
end

function plants.register_plant_like(technical_name, definition)
    local drop = get_drops(definition.drop, technical_name)
    local groups = {plant = 1, attached_node = 3}
    for group, rating in pairs(definition.groups or {}) do
        groups[group] = rating
    end
    local def = {
        description = definition.description,
        paramtype = "light",
        drawtype = "plantlike",
        paramtype2 = "meshoptions",
        place_param2 = definition.place_param2 or 8,
        inventory_image = definition.texture,
        wield_image = definition.texture,
        tiles = {definition.texture},
        groups = groups,
        floodable = true,
        buildable_to = true,
        walkable = false,
        drop = drop,
        on_flood = plants.plant_flood,
        selection_box = definition.selection_box
    }
    base.register_node(technical_name, def)
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
function plants.register_plantlike_plant_legacy(technical_name, name, texture_name, additional_drops, additional_groups, place_param2)
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