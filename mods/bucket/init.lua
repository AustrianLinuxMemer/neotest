local bucket_index = {}
local liquid_index = {}


local S = core.get_translator("mods:bucket")

local function on_bucket_place(itemstack, placer, pointed_thing)
    local direction = vector.subtract(pointed_thing.above, pointed_thing.under)
    local pos = vector.add(pointed_thing.under, direction)
    local liquid_name = bucket_index[itemstack:get_name()] or ""
    local msg = S("placing a bucket of @1", liquid_name)
    if base.is_protected(pos, placer:get_player_name(), msg) then
        return itemstack
    end
    if core.get_node(pos).name == "air" then
        local creative = core.settings:get_bool("creative_mode", false)
        local empty_bucket = core.settings:get_bool("neotest_creative_empty_bucket", false)
        if liquid_name == nil or liquid_name == "" then
            return itemstack
        end
        core.set_node(pos, {name = liquid_name})
        if empty_bucket then
            return ItemStack("bucket:empty_bucket")
        else
            if creative then
                return itemstack
            else
                return ItemStack("bucket:empty_bucket")
            end
        end
    else
        return itemstack
    end
end
local function on_bucket_use(itemstack, user, pointed_thing)
    if pointed_thing.type ~= "node" then
        return itemstack
    end
    local pos = pointed_thing.under
    base.chat_send_all_debug(core.get_node(pos).name)
    local bucket_name = liquid_index[core.get_node(pos).name]
    local inv = user:get_inventory()
    local msg = S("pick up a @1 with a bucket", core.get_node(pos).name)
    if base.is_protected(pos, user:get_player_name(), msg) then
        return itemstack
    end
    if bucket_name ~= nil then
        local item = ItemStack(bucket_name)
        itemstack:take_item(1)
        core.set_node(pos, {name = "air"})
        if inv:room_for_item("main", item) then
            inv:add_item("main", item)
            return itemstack
        else
            if itemstack:get_count() == 0 then
                return item
            else
                core.add_item(user:get_pos(), item)
                return itemstack
            end
        end
    else
        return itemstack
    end
end
function register_bucket(bucket_name, bucket_description, bucket_image, liquid_name, fuel, btime)
    bucket_index["bucket:"..bucket_name] = liquid_name
    liquid_index[liquid_name] = "bucket:"..bucket_name
    base.register_craftitem("bucket:"..bucket_name, {
        description = bucket_description,
        inventory_image = bucket_image,
        on_place = on_bucket_place,
        --on_use = on_bucket_use,
        liquids_pointable = true,
        stack_max = 1,
    })
    if fuel and btime ~= 0 then
        core.register_craft({
            type = "fuel",
            recipe = "bucket:"..bucket_name,
            burntime = btime,
            replacements = {{"bucket:"..bucket_name, "bucket:empty_bucket"}},
        })
    end
end
base.register_craftitem("bucket:empty_bucket", {
    description = "Bucket",
    inventory_image = "bucket_bucket.png",
    --on_place = on_bucket_place,
    on_use = on_bucket_use,
    stack_max = 16,
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

register_bucket("water_bucket", S("Water Bucket"), "bucket_bucket_water.png", "liquids:water_source")
register_bucket("river_water_bucket", S("River Water Bucket"), "bucket_bucket_river_water.png", "liquids:river_water_source")
register_bucket("lava_bucket", S("Lava Bucket"), "bucket_bucket_lava.png", "liquids:lava_source", true, 2000)

loot.add_to_loot_pool({item = "bucket:empty_bucket", max_q = 4, prob = 0.2})
loot.add_to_loot_pool({item = "bucket:water_bucket", max_q = 1, prob = 0.2})
loot.add_to_loot_pool({item = "bucket:river_water_bucket", max_q = 1, prob = 0.2})
loot.add_to_loot_pool({item = "bucket:lava_bucket", max_q = 1, prob = 0.01})