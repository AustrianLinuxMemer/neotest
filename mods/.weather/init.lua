local mod_storage = core.get_mod_storage()
local S = core.get_translator("mods:weather")
weather = {
    -- One sky per weather code
    skies = {
        [0] = nil,
        [1] = {
            type = "regular",
            clouds = true,
            sky_color = {
                day_sky = "#999999",
                day_horizon = "#888888"
            },
            fog = {
                fog_distance = 170,
                fog_start = 0.5
            }
        },
        [2] = {
            type = "regular",
            clouds = true,
            sky_color = {
                day_sky = "#888888",
                day_horizon = "#777777"
            },
            fog = {
                fog_distance = 80,
                fog_start = 0.5
            }
        },
    },
    clouds = {
        [0] = nil,
        [1] = {
            density = 0.5,
            color = "#666666e5",

        },
        [2] = {
            density = 0.6,
            color = "#444444e5",
        },
    },
    lighting = {
        [0] = nil,
        [1] = {
            saturation = 0.9
        },
        [2] = {
            saturation = 0.8
        }
    },
    weather_names = {
        [0] = "clear",
        [1] = "rain",
        [2] = "storm"
    },
    spawner_template = {
        [true] = {
            time = 0,
            amount = 20,
            texture = "weather_snowflake.png",
            vertical = true,
            collisiondetection = true,
            collision_removal = true,
            object_collision = true,
            vel = {
                min = vector.new(0, -9, 0),
                max = vector.new(0, -9, 0),
            },
            acc = {
                min = vector.zero(),
                max = vector.zero()
            },
            exptime = {
                min = 4,
                max = 8
            },
            size = {
                min = 0.7,
                max = 0.9
            }
        },
        [false] = {
            time = 0,
            amount = 20,
            texture = "weather_raindrop.png",
            vertical = true,
            collisiondetection = true,
            collision_removal = true,
            object_collision = true,
            vel = {
                min = vector.new(0, -10, 0),
                max = vector.new(0, -10, 0),
            },
            acc = {
                min = vector.zero(),
                max = vector.zero()
            },
            exptime = {
                min = 4,
                max = 8
            },
            size = {
                min = 0.6,
                max = 0.8
            }
        }
    },
    total_particle_amount = 40,
    weather_code = 0,
    is_snow = false,
    last_spawners = {}
}
function weather.clear_particlespawners(player)
    if weather.last_spawners[player] == nil then 
        weather.last_spawners[player] = {}
        return
    end
    for _, id in ipairs(weather.last_spawners[player]) do
        core.delete_particlespawner(id)
    end
    weather.last_spawners[player] = {}
end
function weather.spawn_precipitation(player, pos, height, is_snow, amount)
    local pmin = vector.new(pos.x-0.5, pos.y + 2, pos.z-0.5)
    local pmax = vector.new(pos.x+0.5, pos.y + height, pos.z+0.5)
    local box = {
        min = pmin,
        max = pmax
    }
    local spawner = table.copy(weather.spawner_template[is_snow])
    spawner.pos = box
    spawner.amount = amount
    if weather.last_spawners[player] == nil then weather.last_spawners[player] = {} end
    table.insert(weather.last_spawners[player], core.add_particlespawner(spawner))
end
function weather.spawn_weatherbox(name, pos, radius, height, cloud_height, is_snow)
    radius = radius or 15
    height = height or 15
    cloud_height = cloud_height or 120
    is_snow = is_snow or false
    weather.clear_particlespawners(name)
    if pos.y >= cloud_height then return end
    if weather.weather_code == 0 then return end
    local amount = weather.total_particle_amount/radius
    for x = pos.x - radius, pos.x + radius do
        for z = pos.z - radius, pos.z + radius do
            local max = vector.new(x, cloud_height, z)
            local min = vector.new(x, pos.y + 3, z)

            local raycast = Raycast(max, min, false, true)
            local reverse_raycast = Raycast(min, max, false, true)
            
            local rain = true
            for pointed_thing in raycast do
                if pointed_thing.type == "node" then
                    rain = false
                    break
                end
            end
            local current_pos = vector.new(x, pos.y, z)
            if rain then
                weather.spawn_precipitation(name, current_pos, height, is_snow, amount)
            end
        end
    end
end
function weather.on_node_change(player, radius, height, cloud_height, is_snow)
    if player:is_player() then
        local player_pos = player:get_pos()
        local name = player:get_player_name()
        weather.spawn_weatherbox(name, player_pos, radius, height, cloud_height, is_snow)
    end
end
function weather.on_player_move(name, pos)
    weather.spawn_weatherbox(name, pos)
end
core.register_on_placenode(function(pos, _, placer)
    weather.on_node_change(placer)
end)
core.register_on_dignode(function(pos, _, digger)
    weather.on_node_change(digger)
end)
player_tracker.register_callback(weather.on_player_move)
function weather.set_weather(weather_code, is_snow)
    weather.weather_code = weather_code
    if is_snow then
        mod_storage:set_int("is_snow", 0)
        mod_storage:set_int("weather_code", weather_code)
    else
        mod_storage:set_int("is_snow", 1)
        mod_storage:set_int("weather_code", weather_code)
    end
end

function weather.load_weather()
    weather.is_snow = mod_storage:get_int("is_snow") == 0
    weather.weather_code = mod_storage:get_int("weather_code")
end
function weather.set_player_sky(player, dtime)
    local sky = weather.skies[weather.weather_code]
    local cloud = weather.clouds[weather.weather_code]
    local lighting = weather.lighting[weather.weather_code]
    player:set_sky(sky)
    player:set_clouds(cloud)
    player:set_lighting(lighting)
end
function weather:code_to_string(code)
    return self.weather_names[code] or "unknown"
end
core.register_on_joinplayer(function(player, last_login)
    weather.load_weather()
    weather.set_player_sky(player)
end)
core.register_globalstep(function(dtime)
    local players = core.get_connected_players()
    for _, player in ipairs(players) do
        weather.set_player_sky(player)
    end
end)
core.register_chatcommand("set_weather", {
    params = "<weather_code>",
    description = "Changes the weather",
    func = function(name, arg)
        local code = tonumber(arg)
        if code == nil then 
            return false, S("Please use a number") 
        end
        if weather.weather_names[code] == nil then 
            return false, S("Invalid weather code") 
        end
        local player = core.get_player_by_name(name)
        weather.set_weather(code, false)
        weather.set_player_sky(player)
        weather.spawn_weatherbox(name, player:get_pos())
        core.chat_send_player(name, S("Weather set to: @1", S(weather:code_to_string(code))))
    end
})
core.register_chatcommand("what_weather", {
    description = "current weather",
    func = function(name, arg)
        core.chat_send_player(name, S("Weather: @1", S(weather:code_to_string(weather.weather_code))))
    end
})