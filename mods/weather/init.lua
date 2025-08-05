local tracking = {
    last_pos = {},
    callbacks = {}
}

function tracking:update(dtime)
    local connected_players = core.get_connected_players()
    for _, player in ipairs(connected_players) do
        local player_name = player:get_player_name()
        local player_pos = vector.apply(player:get_pos(), math.round)
        if self.last_pos[player_name] == nil or not vector.equals(self.last_pos[player_name], player_pos) then
            self.last_pos[player_name] = player_pos
            for _, callback in ipairs(self.callbacks) do
                callback(player_pos, player_name)
            end
        end
    end 
end

function tracking:add_callback(callback)
    assert(type(callback) == "function", "Callback must be a function")
    table.insert(self.callbacks, callback)
end

core.register_globalstep(function() tracking:update() end)

tracking:add_callback(function(pos, player_name)
    core.chat_send_player(player_name, "You moved to "..vector.to_string(pos))
end)