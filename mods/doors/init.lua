doors = {}
door_nodebox = {
    type = "fixed",
    fixed = {8/16, -8/16, -6/16, -8/16, 24/16, -8/16}
}
core.register_node("doors:top_node", {
	drawtype = "airlike",
	pointable = false,
	walkable = false,
	paramtype = "light",
	sunlight_propagates = true,
    groups={no_creative=1}
})
function door_after_place(pos, placer)
    local meta = core.get_meta(pos)
    local node = core.get_node(pos)
    local player_control = placer:get_player_control()
    if player_control.aux1 ~= nil then
        if player_control.aux1 then
            meta:set_int("lr", 1)
        else
            meta:set_int("lr", 0)
        end
    else
        meta:set_int("lr", 1)
    end
    meta:set_int("closed", node.param2)
    local above = vector.add(pos, vector.new(0,1,0))
    core.set_node(above, {name="doors:top_node"})
    return core.settings:get_bool("creative_mode", false)
end
function door_on_destroy(pos)
	local above = vector.add(pos, vector.new(0,1,0))
	core.set_node(above, {name="air"})
end
function door_on_rightclick(pos, node)
    local meta = core.get_meta(pos)
    local closed = meta:get_int("closed")
    local lr = meta:get_int("lr")
    local state = node.param2
    if closed == state then
        if lr == 1 then
            state = state + 1
        else
            state = state - 1
        end
    else
        if lr == 1 then
            state = state - 1
        else
            state = state + 1
        end
    end
    core.swap_node(pos, {name = node.name, param2 = state})

end
function doors.register_door(door_name, def)
    door_def = table.copy(def)
    door_def.drawtype = "mesh"
    door_def.mesh = "door.obj"
    door_def.paramtype = "light"
    door_def.paramtype2 = "4dir"
    door_def.backface_culling = false
    door_def.selection_box = {type = "fixed", fixed = {8/16, -8/16, -6/16, -8/16, 24/16, -8/16}}
    door_def.collision_box = {type = "fixed", fixed = {8/16, -8/16, -6/16, -8/16, 24/16, -8/16}}
    door_def.on_rightclick = door_on_rightclick
    door_def.after_place_node = door_after_place
    door_def.on_destruct = door_on_destroy
    base.register_node(door_name, door_def)
end
