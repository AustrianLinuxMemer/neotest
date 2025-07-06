loot = {
    default_prob = tonumber(core.settings:get("neotest_default_prob")) or 0.2,
    default_max_w = tonumber(core.settings:get("neotest_default_max_w")) or 65535,
    loot_pool = {
        default = {}
    }
}

--[[
    loot.add_to_loot_pool(loot_def, keys...)

    loot_def = {
        item = an item,
        max_q = how many items of this type can be generated (optional and ignored if it's higher than the stack limit),
        max_w = maximum wear for tools to be added (ignored for non-tool items, default: 65535),
        prob = a number between 0 and 1 (default: 0.2),
        keys = a table of loot pool keys, the loot_def gets inserted into each loot pool listed in this table
    }

    keys... = the access keys for the loot tables the items get placed in
]]
function loot.add_to_loot_pool(loot_def)
    loot_def.item = ItemStack(loot_def.item)
    loot_def.is_tool = core.registered_tools[loot_def.item:get_name()] ~= nil
    if type(loot_def.max_q) ~= "number" then
        loot_def.max_q = loot_def.item:get_stack_max()
    else
        loot_def.max_q = math.min(loot_def.max_q, loot_def.item:get_stack_max())
    end
    if type(loot_def.prob) ~= "number" then
        loot_def.prob = loot.default_prob
    elseif loot_def.prob < 0 or loot_def.prob >= 1 then
        loot_def.prob = loot.default_prob
    end
    -- 
    if type(loot_def.max_w) ~= "number" then
        loot_def.max_w = loot.default_max_w
    elseif loot_def.max_w < 0 or loot_def.max_w > 65535 then
        loot_def.max_w = loot.default_max_w
    end
    -- If there is no key specification, the loot will be inserted into the "default" category
    if loot_def.keys == nil then
        loot_def.keys = {"default"}
    elseif #loot_def.keys == 0 then
        loot_def.keys = {"default"}
    end
    for _, key in ipairs(loot_def.keys) do
        -- add the loot definition to it's appropriate loot pool
        if loot.loot_pool[key] == nil then
            loot.loot_pool[key] = {}
        end
        table.insert(loot.loot_pool[key], loot_def)
    end
end
function loot.get_chest_loot(invlist, key)
    local key = key or "default"
    -- Every chest loot starts with the default table
    local loot_list = {}
    for _, loot in ipairs(loot.loot_pool["default"]) do
        table.insert(loot_list, loot)
    end
    
    -- If the key does not equal to default, the key's loot table gets appended to the loot list, but only if the loot list exists
    if key ~= "default" then
        local additional = loot.loot_pool[key]
        if additional ~= nil and #additional > 0 then
            for _, v in ipairs(additional) do
                table.insert(loot_list, v)
            end
        end
    end
    -- Loop over it, add random items according to their probability
    for i = 1, #invlist do
        local loot_table_entry = loot_list[math.random(1, #loot_list)]
        local containing = ItemStack(invlist[i])
        if math.random() <= loot_table_entry.prob and containing:is_empty() then
            local item_table = {
                name = loot_table_entry.item:get_name(), 
                count = math.random(1, loot_table_entry.max_q),
                metadata = loot_table_entry.item:get_metadata()
            }
            if loot_table_entry.is_tool then
                item_table["wear"] = math.random(1, loot_table_entry.max_w)
            end
            invlist[i] = ItemStack(item_table)
        end
    end
    return invlist
end
