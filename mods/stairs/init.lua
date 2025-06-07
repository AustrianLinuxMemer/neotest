stairs = {}
function stairs.register_slab(t_name, n_name, block_def, add_recipe)
    local slab_name = t_name.."_slab"
    local slab_def = table.copy(block_def)
    slab_def["description"] = n_name
    slab_def["drawtype"] = "nodebox"
    slab_def["paramtype"] = "light"
    slab_def["paramtype2"] = "facedir"
    slab_def["node_box"] = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.5, 0.5, 0, 0.5}
        }
    }
    slab_def["groups"]["slab"] = 1
    slab_def["after_place_node"] = base.correct_orientation_after_place_node
    base.register_node(slab_name, slab_def)
    if add_recipe then    
        core.register_craft({
            type = "shaped",
            output = slab_name,
            recipe = {
                {t_name, t_name, t_name},        
            }
        })
    end
end
function stairs.register_stair(t_name, n_name, block_def, add_recipe)
    local stair_name = t_name.."_stair"
    local stair_def = table.copy(block_def)
    stair_def["description"] = n_name
    stair_def["drawtype"] = "nodebox"
    stair_def["paramtype"] = "light"
    stair_def["paramtype2"] = "facedir"
    stair_def["node_box"] = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
            {-0.5, 0, 0, 0.5, 0.5, 0.5}
        }
    }
    stair_def["groups"]["stair"] = 1
    stair_def["after_place_node"] = base.correct_orientation_after_place_node
    base.register_node(stair_name, stair_def)
    if add_recipe then
        core.register_craft({
            type = "shaped",
            output = stair_name,
            recipe = {
                {"", "", t_name},
                {"", t_name, t_name},
                {t_name, t_name, t_name}
            }
        })
        core.register_craft({
            type = "shaped",
            output = stair_name,
            recipe = {
                {t_name, "", ""},
                {t_name, t_name, ""},
                {t_name, t_name, t_name}        
            }
        })
    end
end


