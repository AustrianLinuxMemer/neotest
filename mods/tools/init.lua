local crafting_prototypes = dofile(core.get_modpath("tools").."/crafting_prototypes.lua")
local tools = dofile(core.get_modpath("tools").."/data.lua")
dofile(core.get_modpath("tools").."/loot.lua")
-- Main addition loop
for mk, material in pairs(tools) do
    for tk, tool in pairs(material) do
        local toolname = "tools:"..mk.."_"..tk
        core.register_tool(toolname, tool)
        crafting_prototypes:register_recipe(tk, "group:"..mk, "group:stick", toolname)
    end
end
core.register_craft({
    type = "toolrepair",
    additional_wear = 0
})