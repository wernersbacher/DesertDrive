local json = require( "json" )
local storage = require "storage"

N = {}

local function load() 

    local stats = {}
    stats.highscore = 0
    stats.money = 0

    local stat_load = storage.loadScores("stats")
    if(stat_load) then
        for key,value in pairs(stats) do --actualcode
            if stat_load[key] ~= nil then
                stats[key] = stat_load[key]
            end
        end
    end

    return stats
end

local function save(stats)

    storage.saveScores("stats", stats)

end

N.load = load
N.save = save
 
return N