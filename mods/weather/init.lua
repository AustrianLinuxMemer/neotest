local CLOUD_HEIGHT = 120

weather = {
    precipitation_radius = {
        [1] = 80,
        [2] = 60
    },
    valid_codes = {
        [0] = true,
        [1] = true,
        [2] = true
    },
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
                fog_distance = 80,
                fog_start = 0.7
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
                fog_distance = 60,
                fog_start = 0.8
            }
        },
    },
    clouds = {
        [0] = {
            density = 0.4,
            color = "#fff0f0e5",
            height = CLOUD_HEIGHT
        },
        [1] = {
            density = 0.5,
            color = "#666666e5",
            height = CLOUD_HEIGHT

        },
        [2] = {
            density = 0.6,
            color = "#444444e5",
            height = CLOUD_HEIGHT
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
    weatherboxes = {},
    ranges = {}
}

local function hash_pos_2d(pos_2d)
    if pos_2d == nil then return "" end
    if pos_2d.x == nil or pos_2d.z == nil then return end
    return pos_2d.x..":"..pos_2d.z
end

local function configure_spawner(minpos, maxpos, texture, velocity, player_name, intensity)
    local offset = vector.new(0.5, 0.5, 0.5)
    local minpos = minpos:subtract(offset)
    local maxpos = maxpos:add(offset)
    local spawner = {}
    spawner.pos = {
        min = minpos,
        max = maxpos
    }
    spawner.texture = texture
    spawner.time = 0
    spawner.amount = 10 * intensity
    spawner.vertical = true
    spawner.collisiondetection = true
    spawner.collision_removal = true
    spawner.object_collision = true
    spawner.vel = velocity
    spawner.playername = player_name
    spawner.size = {
        min = 0.2,
        max = 0.8
    }
    return spawner
end

local function get_weather_state(pos)
    biome_data = core.get_biome_data(pos)
    rain_vel = vector.new(0, -9.81, 0)
    snow_vel = vector.new(0, -5, 0)
    if biome_data then
        biome_id = biome_data.biome
        tbl = biomes.biome_query(biome_id, {"heat_point", "humidity_point"})
        intensity = tbl.humidity_point / 100
        snow = tbl.heat_point < 25
        if snow then
            return "weather_snowflake.png", snow_vel, intensity
        else
            return "weather_raindrop.png", rain_vel, intensity
        end
    end
    return "weather_raindrop.png", rain_vel, 0.5
end

function weather.get_height_for_box(pos_2d, base, radius)
    local max = vector.new(pos_2d.x, CLOUD_HEIGHT, pos_2d.z)
    local from = vector.new(pos_2d.x, base + 1, pos_2d.z)
    local min = vector.new(pos_2d.x, base - radius, pos_2d.z)
    first_up = nil
    first_down = nil

    for pointed_thing in Raycast(from, min, false, true) do
        if pointed_thing.type == "node" then
            local pos = pointed_thing.above
            first_down = math.max(pos.y, base - radius)
            break
        end
    end
    for pointed_thing in Raycast(from, max, false, true) do
        if pointed_thing.type == "node" then
            local pos = pointed_thing.under
            first_up = math.min(pos.y, base + radius)
            break
        end
    end
    sky_obstructed = first_up ~= nil or base >= 120
    if first_up == nil then
        first_up = base + radius
    end
    if first_down == nil then
        first_down = base - radius
    end
    
    return sky_obstructed, first_up, first_down
end

Weatherbox = {}
Weatherbox.__index = Weatherbox
function Weatherbox:new(playername, player_pos, radius)
    local obj = {playername = playername, pos = player_pos, radius = radius, active_spawners = {}, active = true}
    setmetatable(obj, self)
    return obj
end
function Weatherbox:on_playermove(new_pos)
    self.pos = new_pos
    self:update()
end
function Weatherbox:on_node_event()
    self:update()
end
function Weatherbox:set_active(active)
    self.active = active
    self:update()
end
function Weatherbox:update()
    if not self.active then
        for _, spawner_id in pairs(self.active_spawners) do
            core.delete_particlespawner(spawner_id)
        end
        self.active_spawners = {}
        return
    end
    local old_spawners = self.active_spawners
    local min_x = math.floor(self.pos.x - self.radius)
    local max_x = math.floor(self.pos.x + self.radius)
    local min_z = math.floor(self.pos.z - self.radius)
    local max_z = math.floor(self.pos.z + self.radius)
    local base_y = math.floor(self.pos.y)
    local new_spawners = {}
    for dx = min_x, max_x do
        for dz = min_z, max_z do
            pos_2d = {x=dx, z=dz}
            pos_2d_hash = hash_pos_2d(pos_2d)
            if not old_spawners[pos_2d_hash] then
                sky_obstructed, max, min = weather.get_height_for_box(pos_2d, base_y, self.radius)
                if not sky_obstructed then
                    minpos = vector.new(pos_2d.x, min, pos_2d.z)
                    maxpos = vector.new(pos_2d.x, max, pos_2d.z)
                    texture, velocity, intensity = get_weather_state(self.pos)
                    spawner = configure_spawner(minpos, maxpos, texture, velocity, self.playername, intensity)
                    new_spawners[pos_2d_hash] = core.add_particlespawner(spawner)
                end
            end
        end
    end
    for pos_hash, spawner_id in pairs(old_spawners) do
        if not new_spawners[pos_hash] then core.delete_particlespawner(spawner_id) end
    end
    self.active_spawners = new_spawners
end


local store = core.get_mod_storage()
weather.current_weather = store:get_int("current_weather")


core.register_on_placenode(function(_, _, placer)
    if placer:is_player() then
        name = placer:get_player_name()
        if weather.weatherboxes[name] then
            weatherbox = weather.weatherboxes[name]:on_node_event()
        end
    end
end)

core.register_on_dignode(function(_, _, digger)
    if digger:is_player() then
        name = digger:get_player_name()
        if weather.weatherboxes[name] then
            weatherbox = weather.weatherboxes[name]:on_node_event()
        end
    end
end)

function weather.set_player(player, weathercode)
    if player:is_valid() then
        player:set_sky(weather.skies[weathercode])
    end
    if player:is_valid() then
        player:set_clouds(weather.clouds[weathercode])
    end
    if player:is_valid() then
        player:set_lighting(weather.lighting[weathercode])
    end
end

core.register_on_joinplayer(function(player) 
    weather.set_player(player, weather.current_weather)
    player_name = player:get_player_name()
    pos = player:get_pos()
    if not weather.weatherboxes[player_name] then
        weather.weatherboxes[player_name] = Weatherbox:new(player_name, pos, 18)
    end
    weatherbox = weather.weatherboxes[player_name]
    weatherbox:set_active(weather.current_weather ~= 0)
    weatherbox:update()
end)

function weather.set_weather(weathercode)
    weather.current_weather = weathercode
    local all_players = core.get_connected_players()
    store:set_int("current_weather", weathercode)
    for i, player in ipairs(all_players) do
        weather.set_player(player, weathercode)
    end
    for _, weatherbox in pairs(weather.weatherboxes) do
        active = weathercode ~= 0
        weatherbox:set_active(active)
    end
end

core.register_chatcommand("set_weather", {
    params = "<code>",
    description = "Set the weather",
    privs = {server=true},
    func = function(name, param)
        local code = tonumber(param)
        if code == nil then
            return false, "Weather code must be a number"
        end
        if not weather.valid_codes[code] then
            return false, "Weather code must be valid (0 for clear, 1 for precipitation, 2 for heavy precipitation)"
        end
        weather.set_weather(code)
        return true, "Weather successfully set to code "..tostring(code)
    end
})

local player_tracker = {
    players = {},
    listeners = {}
}

function player_tracker.track()
    players = core.get_connected_players()
    for _, player in ipairs(players) do
        pos = player:get_pos()
        name = player:get_player_name()
        last_pos = (player_tracker.players[name] or vector.zero())
        player_tracker.players[name] = pos
        if not vector.equals(last_pos, pos) then
            for _, listener in ipairs(player_tracker.listeners) do listener(name, pos) end
        end
    end
end
function player_tracker.attach_listener(listener)
    table.insert(player_tracker.listeners, listener)
end

player_tracker.attach_listener(function(name, pos)
    if weather.weatherboxes[name] then
        weatherbox = weather.weatherboxes[name]
        weatherbox:on_playermove(pos)
    end
end)

core.register_globalstep(function()
    player_tracker.track()
end)