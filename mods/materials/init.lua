local farming_loaded = core.get_modpath("farming") ~= nil
local S = core.get_translator("mods:materials")
local materials = {
    craftitems =  {
        ["materials:brick"] = {
            description = S("Brick"),
            inventory_image = "materials_brick.png"
        },
        ["materials:sawdust"] = {
            description = S("Sawdust"),
            inventory_image = "materials_sawdust.png"
        },
        ["materials:pulp"] = {
            description = S("Pulp"),
            inventory_image = "materials_pulp.png"
        },
        ["materials:paper"] = {
            description = S("Paper"),
            inventory_image = "materials_paper.png"
        }
    },
    recipes = {
        {
            type = "cooking",
            output = "materials:brick",
            recipe = "geology:clay_lump",
            cooktime = 10
        },
        {
            type = "shapeless",
            output = "materials:sawdust 4",
            recipe = {"group:stick"}
        },
        {
            type = "shapeless",
            output = "materials:pulp",
            recipe = {"materials:sawdust", "group:water_bucket"},
            replacements = {{"group:water_bucket", "bucket:empty_bucket"}}
        },
        {
            type = "cooking",
            output = "materials:paper",
            recipe = "materials:pulp",
            cooktime = 10
        }
    },
    loot = {
        {item = "materials:brick", max_q = 16, prob = 0.2},
        {item = "materials:sawdust", max_q = 16, prob = 0.2},
        {item = "materials:pulp", max_q = 16, prob = 0.2},
        {item = "materials:paper", max_q = 16, prob = 0.2}
    }
}
if farming_loaded then
    materials.craftitems["materials:sawdust"].on_use = farming.fertilize
end

for k, v in pairs(materials.craftitems) do
    base.register_craftitem(k,v)
end
for _, v in ipairs(materials.recipes) do
    core.register_craft(v)
end
for _, v in ipairs(materials.loot) do
    loot.add_to_loot_pool(v)
end