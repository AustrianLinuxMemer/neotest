weather = {
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
}
local store = core.get_mod_storage()
weather.current_weather = store:get_int("current_weather")



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

core.register_on_joinplayer(function(player) weather.set_player(player, weather.current_weather) end)

function weather.set_weather(weathercode)
    local all_players = core.get_connected_players()
    store:set_int("current_weather", weathercode)
    for i, player in ipairs(all_players) do
        weather.set_player(player, weathercode)
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