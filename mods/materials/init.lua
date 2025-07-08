local farming_loaded = core.get_modpath("farming") ~= nil

base.register_craftitem("materials:brick", {
    description = "Brick",
    inventory_image = "materials_brick.png"
})
core.register_craft({
    type = "cooking",
    output = "materials:brick",
    recipe = "geology:clay_lump",
    cooktime = 10
})
if farming_loaded then
    base.register_craftitem("materials:sawdust", {
        description = "Sawdust",
        inventory_image = "materials_sawdust.png",
        on_use = farming.fertilize
    })
else
    base.register_craftitem("materials:sawdust", {
        description = "Sawdust",
        inventory_image = "materials_sawdust.png"
    })
end

core.register_craft({
    type = "fuel",
    recipe = "materials:sawdust",
    burntime = 2
})
core.register_craft({
    type = "shapeless",
    output = "materials:sawdust 4",
    recipe = {"group:stick"}
})

base.register_craftitem("materials:pulp", {
    description = "Pulp",
    inventory_image = "materials_pulp.png"
})

core.register_craft({
    type = "shapeless",
    output = "materials:pulp",
    recipe = {"materials:sawdust", "bucket:water_bucket"},
    replacements = {{"bucket:water_bucket", "bucket:empty_bucket"}}
})

core.register_craft({
    type = "shapeless",
    output = "materials:pulp",
    recipe = {"materials:sawdust", "bucket:river_water_bucket"},
    replacements = {{"bucket:river_water_bucket", "bucket:empty_bucket"}}
})

base.register_craftitem("materials:paper", {
    description = "Paper",
    inventory_image = "materials_paper.png"
})

core.register_craft({
    type = "cooking",
    output = "materials:paper",
    recipe = "materials:pulp",
    cooktime = 10
})

loot.add_to_loot_pool({item = "materials:brick", max_q = 16, prob = 0.2})
loot.add_to_loot_pool({item = "materials:sawdust", max_q = 16, prob = 0.2})
loot.add_to_loot_pool({item = "materials:pulp", max_q = 16, prob = 0.2})
loot.add_to_loot_pool({item = "materials:paper", max_q = 16, prob = 0.2})