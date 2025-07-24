local snow_levels = {
    8,
    16
}
core.register_on_generated(function(vmanip, _, _, seed)
    local random = PcgRandom(seed)
    local node_data = vmanip:get_data()
    local param2_data = vmanip:get_param2_data()
    local snow_id = core.get_content_id("ice:snow")
    for i = 1, #node_data do
        if node_data[i] == snow_id then
            param2_data[i] = snow_levels[random:next(1, #snow_levels)]
        end
    end
    vmanip:set_data(node_data)
    vmanip:set_param2_data(param2_data)
end)