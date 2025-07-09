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
        {"","S",""},
    },
    shears = {
        {"", "I"},
        {"I", ""}
    },
    lr = {["axe"] = true, ["hoe"] = true}
}
function crafting_prototypes:get_recipe(t, item, stick, lr)
    local template = self[t]
    if template == nil then 
        error("No template found")
    end
    
    if self.lr[t] then
        if lr ~= "L" and lr ~= "R" then
            error("for lr either L or R")
        end
        template = self[t][lr]
    end
    local result = {}
    for ri, row in ipairs(template) do
        result[ri] = {}
        for ci, symbol in ipairs(row) do
            if symbol == "I" then
                result[ri][ci] = item
            elseif symbol == "S" then 
                result[ri][ci] = stick 
            else
                result[ri][ci] = ""
            end
        end
    end
    return result
end
function crafting_prototypes:is_lr(toolname)
    return self.lr[toolname]
end
return crafting_prototypes