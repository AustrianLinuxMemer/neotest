core.register_craftitem("torch:torch", {
    description = "Torch",
    
})
core.register_node("torch:attached_torch", {
    description = "Torch (attached)",
    drop = "torch:torch"
})
core.register_node("torch:freestanding_torch", {
    description = "Torch (freestanding)",
    drop = "torch:torch"
})
core.register_craft({
    type = "shaped",
    output = "torch:torch",
    recipe = {
        {"group:coal"},
        {"group:stick"}
    }
})
