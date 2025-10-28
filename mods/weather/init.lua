local weather_mod_enabled = core.settings:get_bool("neotest_weather_enabled", false)
local mod_path = core.get_modpath("weather").."/mod.lua"
if weather_mod_enabled then
    dofile(mod_path)
    core.log("info", "Weather Mod enabled by server settings")
else
    weather = {
        current_weather = 0,
        set_weather = function(n) core.log("info", "Weather Mod disabled by server settings") end
    }
    core.register_chatcommand("set_weather", {
        description = "Set the weather (disabled)",
        privs = {server=true},
        func = function(name, param)
            return false, "Weather Mod disabled by server settings"
        end
    })
    core.log("info", "Weather Mod disabled by server settings")
end