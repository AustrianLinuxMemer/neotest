crafting_book = {}




core.register_chatcommand("recipe", {
    params = "<name>",
    description = "Gives you the crafting recipe for this item",
    privs = {},
    func = function(name, param)
        if core.registered_items[param] ~= nil then
            local recipe = core.get_craft_recipe(param)
            core.chat_send_player(name, dump2(recipe, "Recipe: "))
        end
    end
})