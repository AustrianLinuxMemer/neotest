container = {}
local function on_destruct(pos, original_on_destruct, container_name, hidden_lists)
    local meta = core.get_meta(pos)
    local inventory = meta:get_inventory()
    local lists = inventory:get_lists()
    for listname, list in pairs(lists) do
        if not hidden_lists[listname] then
            for _, item in ipairs(list) do
                core.add_item(pos, item)
            end
        end
    end
    core.add_item(pos, container_name)
    original_on_destruct(pos)
end
local function on_construct(pos, original_on_construct, lists)
    local meta = core.get_meta(pos)
    local inventory = meta:get_inventory()
    for _, listdef in ipairs(lists) do
        inventory:set_size(listdef.name, listdef.size)
    end
    original_on_construct(pos)
end

function container.register_container(technical_name, definition, registration_function)
    local original_on_construct = definition.on_construct or function(pos) end
    local original_on_destruct = definition.on_destruct or function(pos) end
    definition.drop = ""
    definition.on_construct = function(pos)
        on_construct(pos, original_on_construct, definition._inventory_lists or {})
    end
    definition.on_destruct = function(pos)
        on_destruct(pos, original_on_destruct, definition._alternative_container or technical_name, definition._hidden_lists or {})
    end
    if type(registration_function) == "function" then
        registration_function(technical_name, definition)
    else
        core.register_node(technical_name, definition)
    end
end

function container.register_generated_container(technical_name, definition, registration_function, generation_function)
    definition.on_dig = function(pos, node, digger)
        generation_function(pos)
        core.dig_node(pos, digger)
    end
    definition.on_blast = function(pos, intensity)
        generation_function(pos)
        core.set_node(pos, {node = "air"})
    end
    container.register_container(technical_name, definition, registration_function)
end