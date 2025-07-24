local S = core.get_translator("mods:testing")
local testing_definition = {
    description = S("testing"),
    paramtype2 = "facedir",
    tiles = {"test_top.png", "test_bottom.png", "test_plus_x.png", "test_minus_x.png", "test_plus_z.png", "test_minus_z.png"},
    groups = {oddly_breakable_by_hand = 1, pane_connect = 1, no_creative = 1},
    after_place_node = base.correct_orientation_after_place_node
}

base.register_node("testing:testing", testing_definition)
stairs.register_stair("testing:testing", S("@1 Stair", testing_definition.description), testing_definition, true)
stairs.register_slab("testing:testing", S("@1 Slab", testing_definition.description), testing_definition, true)

base.register_craftitem("testing:testing_fuel_byproduct", {
    description = "Testing Fuel Byproduct",
    inventory_image = "test_fuel_byproduct.png",
    wield_image = "test_fuel_byproduct.png",
    groups = {no_creative = 1}
})

base.register_craftitem("testing:testing_fuel", {
    description = "Testing Fuel",
    inventory_image = "test_fuel.png",
    wield_image = "test_fuel.png",
    groups = {no_creative = 1},
})

core.register_tool("testing:orientation_tester", {
    description = "Orientation tester",
    inventory_image = "testing_orientation_tester.png",
    on_use = function(_, _, pointed_thing)
        local dir = vector.subtract(pointed_thing.above, pointed_thing.under)
        core.chat_send_all(core.serialize(dir))
    end,
    groups = {no_creative = 1, test_tool = 1}
})

core.register_tool("testing:biome_data_tester", {
    description = "Biome tester",
    inventory_image = "testing_biome_tester.png",
    pointabilities = {
        nodes = {
            ["group:liquid"] = true
        }
    },
    on_use = function(_, user, pointed_thing)
        if pointed_thing.type == "node" then
            local data = core.get_biome_data(pointed_thing.under)
            local player_name = user:get_player_name()
            core.chat_send_player(player_name, dump2(data, "biome_data"))
        end
    end,
    groups = {no_creative = 1, test_tool = 1}
})

core.register_craft({
    type = "fuel",
    recipe = "testing:testing_fuel",
    burntime = 1,
    replacements = {{"testing:testing_fuel", "testing:testing_fuel_byproduct"}}
})