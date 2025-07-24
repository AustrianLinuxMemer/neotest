player_tracker = {
    trails = {},
    callbacks = {}
}
function player_tracker.trigger(name, pos)
    for _, callback in ipairs(player_tracker.callbacks) do
        callback(name, pos)
    end
end
function player_tracker.push(name, pos)
    if type(name) ~= "string" or not vector.check(pos) then
        return
    end
    -- If the record for my player does not exist yet, create it, add the position and trigger callbacks
    if type(player_tracker.trails[name]) ~= "table" then
        player_tracker.trails[name] = {pos}
        player_tracker.trigger(name, pos)
    end
    -- If the list is empty, add the position and triggr callbacks
    if #player_tracker.trails[name] == 0 then
        table.insert(player_tracker.trails[name], pos)
        player_tracker.trigger(name, pos)
    else
        --If the list is not empty, only add the position if it differs from the last position
        local last_index = #player_tracker.trails[name]
        local last_pos = player_tracker.trails[name][last_index]
        if not vector.equals(last_pos, pos) then
            table.insert(player_tracker.trails[name], pos)
            player_tracker.trigger(name, pos)
        end
    end
end
function player_tracker.register_callback(callback_fn)
    if type(callback_fn) == "function" then
        table.insert(player_tracker.callbacks, callback_fn)
    end
end

core.register_on_joinplayer(function(player, last_login)
    local name = player:get_player_name()
    local pos = player:get_pos()
    player_tracker.trigger(name, pos)
end)

core.register_globalstep(function(dtime)
    local players = core.get_connected_players()
    for _, player in ipairs(players) do
        local name = player:get_player_name()
        local pos = player:get_pos()
        player_tracker.push(name, pos)
    end
end)