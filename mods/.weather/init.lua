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

local store = core.get_mod_storage()
weather = {
    spawners = {},
    radius = tonumber(core.settings:get("neotest_weather_radius")) or 15,
    active = store:get_int("weather_active") ~= 0
}



function weather.set_weather(active)
    if active then
        weather.active = true
        store:set_int("weather_active", 1)
    else
        weather.active = false
        store:set_int("weather_active", 0)
    end
end

core.register_chatcommand("weather", {
    params = "[<active>]",
    description = "toggle the weather on/off",
    privs = {server = true},
    func = function(name, param)
        if param == "active" then
            weather.set_weather(true)
            return true, "Weather has been set to active"
        else
            weather.set_weather(false)
            return true, "Weather has been set to inactive"
        end
    end
})

local function x_z_to_string(x_z)
    return tostring(x_z.x)..":"..tostring(x_z.z)
end

local function particlespawner_factory(pos, particle_texture, player_name, vertical_velocity, particle_count)
    return {
        time = 0,
        amount = particle_count or 30,
        texture = particle_texture,
        collisiondetection = true,
        collision_removal = true,
        object_collision = true,
        vertical = true,
        playername = player_name,
        pos = {
            min = vector.new(pos.x - 0.5, pos.y, pos.z - 0.5),
            max = vector.new(pos.x + 0.5, pos.y + weather.radius, pos.z + 0.5)
        },
        vel = vector.new(0, -vertical_velocity, 0)
    }
end

function weather.spawn(player_pos, player_name)
    weather.spawners[player_name] = weather.spawners[player_name] or {}
    local min_x_z = {x = player_pos.x - weather.radius, z = player_pos.z - weather.radius}
    local max_x_z = {x = player_pos.x + weather.radius, z = player_pos.z + weather.radius}
    local to_add = {}
    local to_remove = {}
    if weather.active then
    for xi = min_x_z.x, max_x_z.x do
        for zi = min_x_z.z, max_x_z.z do
            local raycast = Raycast(vector.new(xi, player_pos.y + weather.radius, zi), vector.new(xi, 120, zi), false, true)
            local blocked = false
            for pointed_thing in raycast do
                if pointed_thing.type == "node" then
                    blocked = true
                    break
                end
            end

            local spawner_pos = {x = xi, y = player_pos.y, z = zi}
            local spawner_key = x_z_to_string(spawner_pos)
            local spawner_info = weather.spawners[player_name][spawner_key]
            if not blocked then
                if spawner_info == nil then 
                    table.insert(to_add, spawner_pos) 
                elseif spawner_info.pos.y ~= player_pos.y then
                    table.insert(to_remove, spawner_pos)
                    table.insert(to_add, spawner_pos)
                end
            end
        end
    end
    end    
    for index, spawner_info in pairs(weather.spawners[player_name]) do
        local spawner_pos = spawner_info.pos
        if spawner_pos.x < min_x_z.x or spawner_pos.x > max_x_z.x or spawner_pos.z < min_x_z.z or spawner_pos.z > max_x_z.z then
            table.insert(to_remove, spawner_pos)
        end
    end
    for i, remove_pos in ipairs(to_remove) do
        local key = x_z_to_string(remove_pos)
        local spawner_info = weather.spawners[player_name][key]
        if spawner_info ~= nil then
            local id = spawner_info.id
            core.delete_particlespawner(id, player_name)
            weather.spawners[player_name][key] = nil
        end
    end
    for i, add_pos in ipairs(to_add) do
        local key = x_z_to_string(add_pos)
        local spawner_info = {
            pos = add_pos,
            id = core.add_particlespawner(particlespawner_factory(add_pos, "weather_raindrop.png", player_name, 8, 10))
        }
        weather.spawners[player_name][key] = spawner_info
    end
end

tracking:add_callback(weather.spawn)