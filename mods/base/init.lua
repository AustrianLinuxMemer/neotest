base = {}
transparent_drawtypes = {
    normal = false,
    airlike = true,
    liquid = false,
    flowingliquid = false,
    glasslike = true,
    glasslike_framed = true,
    glasslike_framed_optional = true,
    allfaces = true,
    allfaces_optional = true,
    torchlike = true,
    signlike = true,
    plantlike = true,
    firelike = true,
    fencelike = true,
    raillike = true,
    nodebox = true,
    mesh = true,
    plantlike_rooted = true
}
function base.is_transparent(pos)
    local node_name = core.get_node(pos).name
    local node_def = core.registered_nodes[node_name]
    if node_def ~= nil then
        local transparent_by_drawtype = transparent_drawtypes[node_def.drawtype]
        local transparent_by_sunlight_propagates = node_def.sunlight_propagates
        return transparent_by_drawtype or transparent_by_paramtype or transparent_by_sunlight_propagates
    else
        return false
    end
end
