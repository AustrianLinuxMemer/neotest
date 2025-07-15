local crafting_prototypes = {
    shovel = {
            {"I"},
            {"S"},
            {"S"}
    },
    hoe = {
        L = {
            {"I","I"},
            {"","S"},
            {"", "S"}
        },
        R = {
            {"I","I"},
            {"S", ""},
            {"S", ""}
        }
    },
    axe = {
        L = {
            {"I","I"},
            {"I","S"},
            {"", "S"}
        },
        R = {
            {"I","I"},
            {"S", "I"},
            {"S", ""}
        }
    },
    pickaxe = {
            {"I","I","I"},
            {"","S",""},
            {"","S",""}
    },
    shears = {
            {"", "I"},
            {"I", ""}
    },
    lr = {["axe"] = true, ["hoe"] = true}
}
local function replace(template, item, stick)
    local recipe = {}
    for row, _ in ipairs(template) do
        recipe[row] = {}
        for col, _ in ipairs(template[row]) do
            local symbol = template[row][col]
            if symbol == "I" then
                recipe[row][col] = item
            elseif symbol == "S" then
                recipe[row][col] = stick
            else
                recipe[row][col] = ""
            end
        end
    end
    return recipe
end
function crafting_prototypes:register_recipe(t, item, stick, result)
    local template = self[t]
    if template == nil then 
        error("No template found")
    end
    local is_lr = self.lr[t]
    if is_lr then
        local right_template = template["R"]
        local left_template = template["L"]
        core.register_craft({
            type = "shaped",
            output = result,
            recipe = replace(right_template, item, stick)
        })
        core.register_craft({
            type = "shaped",
            output = result,
            recipe = replace(left_template, item, stick)
        })
    else
        core.register_craft({
            type = "shaped",
            output = result,
            recipe = replace(template, item, stick)
        })
    end
end
return crafting_prototypes