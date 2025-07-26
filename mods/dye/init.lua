local S = core.get_translator("mods:dyes")
dye = {
    types = {
        ["white"] = {
            description = S("White Dye"),
            inventory_image = "dye_white.png"
        },
        ["grey"] = {
            description = S("Grey Dye"),
            inventory_image = "dye_grey.png"
        },
        ["dark_grey"] = {
            description = S("Dark Grey Dye"),
            inventory_image = "dye_dark_grey.png"
        },
        ["black"] = {
            description = S("Black Dye"),
            inventory_image = "dye_black.png"
        },
        ["blue"] = {
            description = S("Blue Dye"),
            inventory_image = "dye_blue.png"
        },
        ["cyan"] = {
            description = S("Cyan Dye"),
            inventory_image = "dye_cyan.png"
        },
        ["green"] = {
            description = S("Green Dye"),
            inventory_image = "dye_green.png"
        },
        ["dark_green"] = {
            description = S("Dark Green Dye"),
            inventory_image = "dye_dark_green.png"
        },
        ["yellow"] = {
            description = S("Yellow Dye"),
            inventory_image = "dye_yellow.png"
        },
        ["orange"] = {
            description = S("Orange Dye"),
            inventory_image = "dye_orange.png"
        },
        ["brown"] = {
            description = S("Brown Dye"),
            inventory_image = "dye_brown.png"
        },
        ["red"] = {
            description = S("Red Dye"),
            inventory_image = "dye_red.png"
        },
        ["pink"] = {
            description = S("Pink Dye"),
            inventory_image = "dye_pink.png"
        },
        ["magenta"] = {
            description = S("Magenta Dye"),
            inventory_image = "dye_magenta.png"
        },
        ["violet"] = {
            description = S("Violet Dye"),
            inventory_image = "dye_violet.png"
        }
    },
    combinations = {
        {a = "black",       b = "grey",         result = "dark_grey"},
        {a = "black",       b = "white",        result = "grey"},
        {a = "black",       b = "green",        result = "dark_green"},
        {a = "black",       b = "orange",       result = "brown"},
        {a = "dark_grey",   b = "white",        result = "grey"},
        {a = "white",       b = "dark_green",   result = "green"},
        {a = "white",       b = "red",          result = "pink"},
        {a = "green",       b = "blue",         result = "cyan"},
        {a = "green",       b = "red",          result = "brown"},
        {a = "cyan",        b = "magenta",      result = "blue"},
        {a = "cyan",        b = "yellow",       result = "green"},
        {a = "blue",        b = "magenta",      result = "purple"},
        {a = "blue",        b = "red",          result = "purple"},
        {a = "blue",        b = "orange",       result = "grey"},
        {a = "blue",        b = "yellow",       result = "green"},
        {a = "violet",      b = "pink",         result = "magenta"},
        {a = "violet",      b = "yellow",       result = "dark_grey"},
        {a = "magenta",     b = "yellow",       result = "red"},
        {a = "red",         b = "yellow",       result = "orange"},
    }
}
for dye_name, dye_definition in pairs(dye.types) do
    base.register_craftitem("dye:"..dye_name, dye_definition)
end
for _, dye_combination in ipairs(dye.combinations) do
    core.register_craft({
        type = "shapeless",
        output = "dye:"..dye_combination.result.." 2",
        recipe = {"dye:"..dye_combination.a, "dye:"..dye_combination.b}
    })
end
function dye.register_craft(recipe)
    if recipe.type == "fuel" then
        error("Dyes are not supposed to be fuel")
    end
    local is_dye = dye.types[recipe.output] ~= nil
    if is_dye then 
        recipe.output = "dye:"..recipe.output
        core.register_craft(recipe)
    else
        error("Supplied output is not a registered dye color")
    end
end