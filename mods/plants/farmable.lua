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
farming.register_plant({
    seed = {
        name = "plants:wheat_seed",
        def = {
            description = S("Wheat seeds"),
            inventory_image = "plants_wheat_seed.png"
        }
    },
    harvest = {
        {
            name = "plants:wheat",
            def = {
                description = S("Wheat"),
                inventory_image = "plants_wheat.png"
            }
        }
    },
    plants = {
        {tname = "plants:wheat_1", name = S("Wheat (stage 1)"), texture = "plants_wheat_plant1.png", texture_variation = 3, drop = "plants:wheat_seed", selection_box = {type = "fixed", fixed = {-6/16, -8/16, -6/16, 6/16, -6/16, 6/16}}},
        {tname = "plants:wheat_2", name = S("Wheat (stage 2)"), texture = "plants_wheat_plant2.png", texture_variation = 3, drop = "plants:wheat_seed", selection_box = {type = "fixed", fixed = {-6/16, -8/16, -6/16, 6/16, -4/16, 6/16}}},
        {tname = "plants:wheat_3", name = S("Wheat (stage 3)"), texture = "plants_wheat_plant3.png", texture_variation = 3, drop = "plants:wheat_seed", selection_box = {type = "fixed", fixed = {-6/16, -8/16, -6/16, 6/16, -2/16, 6/16}}},
        {tname = "plants:wheat_4", name = S("Wheat (stage 4)"), texture = "plants_wheat_plant4.png", texture_variation = 3, drop = "plants:wheat_seed", selection_box = {type = "fixed", fixed = {-6/16, -8/16, -6/16, 6/16, 2/16, 6/16}}},
        {tname = "plants:wheat_5", name = S("Wheat (stage 5)"), texture = "plants_wheat_plant5.png", texture_variation = 3, drop = "plants:wheat_seed", selection_box = {type = "fixed", fixed = {-6/16, -8/16, -6/16, 6/16, 2/16, 6/16}}},
        {tname = "plants:wheat_6", name = S("Wheat (stage 6)"), texture = "plants_wheat_plant6.png", texture_variation = 3, drop = "plants:wheat_seed", selection_box = {type = "fixed", fixed = {-6/16, -8/16, -6/16, 6/16, 5/16, 6/16}}},
        {tname = "plants:wheat_7", name = S("Wheat (stage 7)"), texture = "plants_wheat_plant7.png", texture_variation = 3, drop = wheat_drop, selection_box = {type = "fixed", fixed = {-6/16, -8/16, -6/16, 6/16, 7/16, 6/16}}},
    }
})