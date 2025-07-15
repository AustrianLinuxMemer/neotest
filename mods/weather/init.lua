local mod_storage = core.get_mod_storage()
local S = core.get_translator("mods:weather")
weather = {
    seasons = {"SPRING", "SUMMER", "FALL", "WINTER"},
    season = mod_storage:get("season") or "SUMMER",
    seasonlength = tonumber(core.settings:get("neotest_seasonlength") or "1")
}
local function season_check()
    local days = core.get_day_count()
    local season_index = math.floor(days / weather.seasonlength)
    local season = weather.seasons[season_index % #weather.seasons]
    weather.season = season
    mod_storage:set_string("season", season)
    core.after(1200, season_check)
end
core.after(1200, season_check)
core.register_chatcommand("what_season", {
    func = function(name)
        core.chat_send_player(name, S("It is @1", S(weather.season)))
    end
})
-- Melting
core.register_abm({
    nodenames = {"group:melts"},
    chance = 25,
    interval = 10,
    action = function(pos)
        local biome_data = core.get_biome_data(pos)
        if biome_data.heat >= 25 then
            ice.melt(pos)
            return
        elseif weather.season ~= "WINTER" then
            ice.melt(pos)
            return
        end
    end
})
-- Freeze
core.register_abm({
    nodenames = {"group:water"},
    chance = 25,
    interval = 10,
    action = function(pos)
        local biome_data = core.get_biome_data(pos)
        if biome_data.heat <= 25 then
            ice.freeze(pos)
            return
        elseif weather.season == "WINTER" then
            ice.freeze(pos)
            return
        end
    end
})