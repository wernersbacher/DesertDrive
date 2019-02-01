local M = {}

M.stages = {}

M.stages[1] = {
    name = "start",
    width = 200,
    height = 200,
    ende = 30 * 300,
    color = {80/255, 80/255, 80/255},
    num = 5,
    special = 2
}

M.stages[2] = {
    name = "desert1",
    width = 100,
    height = 200,
    ende = 30 * 500,
    num = 6,
    color = {234/255, 156/255, 32/255},
    special = 0
}

M.stages[3] = {
    name = "fast",
    width = 200,
    height = 200,
    ende = 30 * 800,
    num = 4,
    color = {10/255, 2/255, 2/255},
    special = 2
}

M.stages[4] = {
    name = "hard",
    width = 500,
    height = 300,
    ende = 30 * 4000,
    num = 5,
    color = {107/255, 0/255, 0/255},
    special = 0
}



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