
local globals = require("globals")

Car = {}
Car.__index = Car
function Car:Create()


    local this =
    {
        name = "carShape", --name for body
        carShape = nil, -- actual object

        max_hp = 0,
        car_hp = 0
    }


    setmetatable(this, Car)
    return this
end

function Car:createCar(carChosen)
    
    local carTable = globals.garage[carChosen]
	local car_scale = carTable.scale
	self.max_hp, self.car_hp = carTable.max_hp, carTable.max_hp
	local dens = carTable.dens

    local car_image = "img/car/".. carChosen .."/car-body.png"


end

return Car