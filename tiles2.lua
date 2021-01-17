local M = {}

local stages = {}

table.insert(stages, {
    name = "geo",
    width = 200,
    height = 200,
    scaler = 1,
    count = 30,
    ende = 30 * 100,
    color = {0/255, 0/255, 0/255},
    num = 5,
    special = 0
})


M.stages = stages
--M.getOptions = getOptions
--M.getNum = getNum

return M