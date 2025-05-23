local testing_definition = {
    description = "testing",
    paramtype2 = "facedir",
    tiles = {"test_top.png", "test_bottom.png", "test_plus_x.png", "test_minus_x.png", "test_plus_z.png", "test_minus_z.png"},
    groups = {oddly_breakable_by_hand = 1, pane_connect = 1},
    after_place_node = base.correct_orientation_after_place_node
}

core.register_node("testing:testing", testing_definition)
stairs.register_stair("testing:testing", "testing Stair", testing_definition, true)
stairs.register_slab("testing:testing", "testing Slab", testing_definition, true)
