local S = core.get_translator("mods:plants")
local wheat_drop = {
    max_items = 5,
    items = {
        {
            rarity = 5,
            items = {"plants:wheat", "plants:wheat_seed 4"}
        },
        {
            rarity = 5,
            items = {"plants:wheat", "plants:wheat_seed 3"}
        },
        {
            rarity = 5,
            items = {"plants:wheat", "plants:wheat_seed 2"}
        },
        {
            rarity = 5,
            items = {"plants:wheat 2", "plants:wheat_seed"}
        },
        {
            rarity = 5,
            items = {"plants:wheat 3", "plants:wheat_seed"}
        }
    }
}

base.register_craftitem("plants:wheat_seed", {
    description = S("Wheat seeds"),
    inventory_image = "plants_wheat_seed.png"
})

base.register_craftitem("plants:wheat", {
    description = S("Wheat"),
    inventory_image = "plants_wheat.png"
})

local plant_list = {}
for i = 1, 7 do
    local name = "Wheat (stage"..i..")"
    local texture_name = "plants_wheat_plant"..i..".png"
    local technical_name = "plants:wheat_"..i
    local drop = {
        max_items = 1,
        items = {
            {
                items = {"plants:wheat_seed"}
            }
        }
    }
    if i == 7 then
        drop = wheat_drop
    end
    plants.register_plant_like(technical_name, {
        description = S(name),
        texture = texture_name,
        place_param2 = 3,
        selection_box = {
            type = "fixed", 
            fixed = {-6/16, -8/16, -6/16, 6/16, -6/16, 6/16}
        },
        drop = {
            drop_self_shears = false,
            drop_otherwise = drop
        },
        groups = {oddly_breakable_by_hand = 1}
    })
    table.insert(plant_list, technical_name)
end

farming.register_crop({
    seed = "plants:wheat_seed",
    plants = plant_list
})