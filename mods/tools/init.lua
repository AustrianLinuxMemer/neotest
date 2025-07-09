local crafting_prototypes = dofile(core.get_modpath("tools").."/crafting_prototypes.lua")
local tools = dofile(core.get_modpath("tools").."/data.lua")
dofile(core.get_modpath("tools").."/loot.lua")
-- Main addition loop
for mk, material in pairs(tools) do
    for tk, tool in pairs(material) do
        local toolname = "tools:"..mk.."_"..tk
        core.register_tool(toolname, tool)
        if crafting_prototypes:is_lr(tk) then
            local left = crafting_prototypes:get_recipe(tk, "group:"..mk, "group:stick", "L")
            local right = crafting_prototypes:get_recipe(tk, "group:"..mk, "group:stick", "R")
            core.register_craft({
                type = "shaped",
                output = toolname,
                recipe = left
            })
            core.register_craft({
                type = "shaped",
                output = toolname,
                recipe = right
            })
        else
            local recipe = crafting_prototypes:get_recipe(tk, "group:"..mk, "group:stick")
            core.register_craft({
                type = "shaped",
                output = toolname,
                recipe = recipe
            })
        end
    end
end