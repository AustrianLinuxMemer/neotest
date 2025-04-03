local function on_bucket_place(itemstack, placer, pointed_thing)
    local pos = pointed_thing.above
    local empty_bucket = ItemStack("bucket:empty_bucket")
    if itemstack:get_name() == "bucket:water_bucket" then
        core.set_node(pos, {name = "liquids:water_source"})
        return empty_bucket
    elseif itemstack:get_name() == "bucket:river_water_bucket" then
        core.set_node(pos, {name = "liquids:river_water_source"})
        return empty_bucket
    elseif itemstack:get_name() == "bucket:lava_bucket" then
        core.set_node(pos, {name = "liquids:lava_source"})
        return empty_bucket    
    else
        return nil
    end
end
local function on_bucket_use(itemstack, user, pointed_thing)
    if pointed_thing.type ~= "node" and pointed_thing ~= "object" then
        return nil
    end
    local pos = pointed_thing.above
    local node = core.get_node(pos)
    if itemstack:get_name() == "bucket:empty_bucket" then
        if node.name == "liquids:water_source" then
            core.set_node(pos, {name = "air"})
            return ItemStack("bucket:water_bucket")
        elseif node.name == "liquids:river_water_source" then
            core.set_node(pos, {name = "air"})
            return ItemStack("bucket:river_water_bucket")
        elseif node.name == "liquids:lava_source" then
            core.set_node(pos, {name = "air"})
            return ItemStack("bucket:lava_bucket")
        else
            return nil
        end
    else
        return nil
    end
end
core.register_craftitem("bucket:empty_bucket", {
    description = "Bucket",
    inventory_image = "bucket.png",
    on_place = on_bucket_place,
    on_use = on_bucket_use
})
core.register_craftitem("bucket:water_bucket", {
    description = "Water Bucket",
    inventory_image = "water_bucket.png",
    on_place = on_bucket_place,
    on_use = on_bucket_use
})
core.register_craftitem("bucket:river_water_bucket", {
    description = "River Water Bucket",
    inventory_image = "river_water_bucket.png",
    on_place = on_bucket_place,
    on_use = on_bucket_use
})
core.register_craftitem("bucket:lava_bucket", {
    description = "Lava Bucket",
    inventory_image = "lava_bucket.png",
    on_place = on_bucket_place,
    on_use = on_bucket_use
})

core.register_craft({
    type = "shaped",
    output = "bucket:empty_bucket",
    recipe = {
        {"geology:iron_ingot", "", "geology:iron_ingot"},
        {"","geology:iron_ingot",""}
    }
})
