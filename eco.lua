--[[
	economy/money
]]

local statMgr = require "stats"

stats = statMgr.load()

function addMoney(mon) 
	stats.money = stats.money + mon
	moneyTxt.text = "$".. stats.money
end