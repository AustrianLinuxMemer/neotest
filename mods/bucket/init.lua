local bucket_index = {}
local liquid_index = {}
local function on_bucket_place(itemstack, placer, pointed_thing)
    local pos = pointed_thing.under
    local empty_bucket = ItemStack("bucket:empty_bucket")
    local bucket_name = itemstack:get_name()
    local liquid_name = bucket_index[bucket_name]
    local is_liquid = liquid_index[core.get_node(pos).name] ~= nil
    if liquid_name ~= nil then
        if is_liquid then
            core.set_node(pos, {name = liquid_name})
        else
            core.set_node(vector.new(pos.x, pos.y+1, pos.z), {name = liquid_name})
        end
        return ItemStack("bucket:empty_bucket")
    else
        return nil
    end
end
local function on_bucket_use(itemstack, user, pointed_thing)
    if pointed_thing.type ~= "node" and pointed_thing ~= "object" then
        return nil
    end
    local pos = pointed_thing.under
    local node = core.get_node(pos)
    local bucket_name = liquid_index[node.name]
    local inventory = user:get_inventory()
    if bucket_name ~= nil and itemstack:get_name() == "bucket:empty_bucket" then
        core.set_node(pos, {name = "air"})
        local new_bucket = ItemStack(bucket_name)
        if inventory:room_for_item("main", new_bucket) then
            inventory:add_item("main", new_bucket)
        else
            if itemstack:get_count() == 1 then
                return new_bucket
            end
            core.add_item(pos, new_bucket)
        end
        itemstack:take_item(1)
        return itemstack
    else
        return nil
    end
end
function register_bucket(bucket_name, bucket_description, bucket_image, liquid_name)
    bucket_index["bucket:"..bucket_name] = liquid_name
    liquid_index[liquid_name] = "bucket:"..bucket_name
    core.register_craftitem("bucket:"..bucket_name, {
        description = bucket_description,
        inventory_image = bucket_image,
        on_place = on_bucket_place,
        on_use = on_bucket_use,
        liquids_pointable = true,
        stack_max = 1,
        _byproducts = {name = "bucket:empty_bucket", count = 1}
    })
end
core.register_craftitem("bucket:empty_bucket", {
    description = "Bucket",
    inventory_image = "bucket.png",
    on_place = on_bucket_place,
    on_use = on_bucket_use,
    liquids_pointable = true
})
core.register_craft({
    type = "shaped",
    output = "bucket:empty_bucket",
    recipe = {
        {"geology:iron_ingot", "", "geology:iron_ingot"},
        {"","geology:iron_ingot",""}
    }
})

register_bucket("water_bucket", "Water Bucket", "water_bucket.png", "liquids:water_source")
register_bucket("river_water_bucket", "River Water Bucket", "river_water_bucket.png", "liquids:river_water_source")
register_bucket("lava_bucket", "Lava Bucket", "lava_bucket.png", "liquids:lava_source")

core.register_craft({
    type = "fuel",
    recipe = "bucket:lava_bucket",
    burntime = 2000
})