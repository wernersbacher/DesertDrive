local M = {}

local stages = {}

table.insert(stages, {
    name = "start",
    width = 200,
    height = 200,
    scaler = 1,
    count = 30,
    ende = 30 * 100,
    color = {80/255, 80/255, 80/255},
    num = 5,
    special = 0
})

table.insert(stages, {
    name = "blue",
    width = 1000,
    height = 600,
    scaler = 1,
    count = 15,
    ende = 30 * 5000,
    color = {32/255, 83/255, 201/255},
    num = 6,
    special = 0
})

table.insert(stages, {
    name = "quick",
    width = 1000,
    height = 600,
    scaler = 1,
    count = 25,
    ende = 30 * 5000,
    color = {127/255, 61/255, 61/255},
    num = 3,
    special = 3
})

--[[
table.insert(stages, {
    name = "desert1",
    width = 100,
    height = 200,
    scaler = 1,
    count = 30,
    ende = 30 * 2000,
    num = 6,
    color = {234/255, 156/255, 32/255},
    special = 0
})
]]
table.insert(stages, {
    name = "fast",
    width = 1000,
    height = 300,
    scaler = 1,
    count = 15,
    ende = 30 * 30000,
    scaler = 1,
    num = 5,
    color = {10/255, 2/255, 2/255},
    special = 2
})

table.insert(stages, {
    name = "hard",
    width = 500,
    height = 300,
    scaler = 1,
    count = 15,
    ende = 30 * 40000,
    num = 5,
    color = {107/255, 0/255, 0/255},
    special = 0
})



M.stages = stages

-- not working
local function getOptions() 
    local options = { }

    for i=1, M.num, 1 do

        table.insert(options, {
            x = 1,
            --x = 2 --sheet2.png
            --y = 2*i + (i-1)*500, --sheet2.png
            y = 1 + 500 * (i-1),
            width = 2000,
            height = 500,
        })

    end

    return { frames = options }
end

M.getOptions = getOptions
--M.getNum = getNum

return M