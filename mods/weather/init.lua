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
    weatherboxes = {}
}

local function hash_pos_2d(pos_2d)
    if pos_2d == nil then return "" end
    if pos_2d.x == nil or pos_2d.z == nil then return end
    return pos_2d.x..":"..pos_2d.z
end

local function configure_spawner(minpos, maxpos, texture, velocity, player_name)
    if weather.current_weather == 0 then return end
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
    spawner.amount = 8
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

local function calc_box_height(pos_2d, min_y, max_y)
    lower = vector.new(pos_2d.x, min_y, pos_2d.z)
    upper = vector.new(pos_2d.x, max_y + 4, pos_2d.z)
    raycast = Raycast(upper, lower, false, true)
    block_found = false
    for pointed_thing in raycast do
        if pointed_thing.type == "node" then
            block_found = true
            pos = pointed_thing.above
            if pos.y >= max_y then
                return 0
            else
                return max_y - pos.y
            end
        end
    end
    if not block_found then
        return max_y - min_y
    end
end
local function snow_or_rain(pos)
    biome_data = core.get_biome_data(pos)
    rain_vel = vector.new(0, -9.81, 0)
    snow_vel = vector.new(0, -5, 0)
    if biome_data then
        biome_id = biome_data.biome
        heat_point = biomes.biome_query(biome_id, "heat_point")
        if heat_point > 25 then return "weather_raindrop.png", rain_vel else return "weather_snowflake.png", snow_vel end
    end
    return "weather_raindrop.png", rain_vel
end
local function configure_box(pos_2d, radius)
    box_height = calc_box_height(pos_2d, pos.y, pos.y + radius)
    max_y = pos.y + radius
    min_y = 0 -- == 0 case
    if box_height < radius then
        min_y = max_y - box_height -- < radius case
    else
        min_y = pos.y -- == radius case
    end
    if min_y ~= 0 then
        min = vector.new(pos_2d.x, min_y, pos_2d.z)
        max = vector.new(pos_2d.x, max_y, pos_2d.z)
        return min, max
    else
        return nil, nil
    end
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
    old_spawners = self.active_spawners
    min_x = math.floor(self.pos.x - self.radius)
    max_x = math.floor(self.pos.x + self.radius)
    min_z = math.floor(self.pos.z - self.radius)
    max_z = math.floor(self.pos.z + self.radius)
    new_spawners = {}
    for dx = min_x, max_x do
        for dz = min_z, max_z do
            pos_2d = {x=dx, z=dz}
            pos_2d_hash = hash_pos_2d(pos_2d)
            if not old_spawners[pos_2d_hash] then
                min, max = configure_box(pos_2d, self.radius)
                if min ~= nil and max ~= nil then
                    particle_texture, vel = snow_or_rain(min)
                    spawner = configure_spawner(min, max, particle_texture, vel, self.playername)
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