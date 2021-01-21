
--[[
	DRIVING FUNCTIONS
]]

function rotateCar(rotateForward)
	local rotateAcc = getMaxes().maxRotationSpeed
	local f = -1
	if(rotateForward) then f = 1 end

	car.angularVelocity = car.angularVelocity+ f*rotateAcc
end

function getMaxes()
	local f = 5
    local M = {}
    M["maxRotationSpeed"] = carTable.maxRotationSpeed
	M["maxForwardSpeed"] = carTable.maxForwardSpeed * f
	M["maxForwardAccel"] = carTable.maxAcc * f
	M["maxBackwardSpeed"] = -360 * 3
	M["maxBackwardAcc"] = -20 * 3

	return M
end

function getCurrentAccel(maxSpeed, currentSpeed)

	-- static

	-- Skala von 1 bis auf x achse, 10 entspricht 100 des topspeeds
	-- Die ausgabe ist der prozentuale wert in dezimal der maximalen accel, die genutzt werden darf

	local x = 10 * currentSpeed/maxSpeed

	-- Formel für Plotter:	1/(e^(0.3*(x-1)))*0.5*(abs(sin(0.8*pi*x))+0.5)

	local e_func = 1 / math.exp(0.3*(x-1))
	local sinus_func = 0.5*(math.abs(math.sin(1.5*math.pi*x))+0.5)
	local accel_factor = e_func*sinus_func
	return accel_factor

end

function accel()
	--gas geben
	local max = getMaxes()
	local maxSpeed = max.maxForwardSpeed
    local maxAcceleration = max.maxForwardAccel
    
	for i = 1,2,1 do
        local speed = wheel[i].angularVelocity
        local transmission = getCurrentAccel(maxSpeed, speed)
        local accel = transmission * maxAcceleration
        
		if(speed+accel > maxSpeed) then
			wheel[i].angularVelocity = maxSpeed
		else
			wheel[i].angularVelocity = speed+accel
		end
	
	end

end

function decel() 
	local max = getMaxes()
	local maxSpeed = max.maxBackwardSpeed
	local acceleration = max.maxBackwardAcc

	for i = 1,2,1 do
		local speed = wheel[i].angularVelocity
		if( speed+acceleration < maxSpeed) then
			wheel[i].angularVelocity = maxSpeed
		else
			wheel[i].angularVelocity = speed+acceleration
		end
	
	end

end

function motorbreak()
	decel(-1, 0)
end

--[[ 
    CAR SETUP
 ]]

car = nil
wheel = nil
car_hp, max_hp = 0, 0

log_file = nil

function initCar(carChosen)

    --log_file = io.open("C:\\Logs\\desert.txt", "a")

    carTable = globals.garage[carChosen]
    car_scale = carTable.scale --#
    max_hp, car_hp = carTable.max_hp, carTable.max_hp
    dens = carTable.dens

    local car_image = "img/car/".. carChosen .."/car-body.png" --#
    local car_outline = graphics.newOutline( 5, car_image)

    car = display.newImageRect(carGroup, car_image, carTable.width*car_scale, carTable.height*car_scale) --#
    car.x = spawnXCar -- basically 0 and content height/2
    car.y = spawnYCar
    physics.addBody( car, "dynamic", { outline = car_outline, friction=0.3, density = 0.005*dens } )
    car.linearDamping = 0.5

    car.name = "carShape"

    local carX = car.x
    local carY = car.y
    local wheelrad = carTable.wheelrad * carTable.scale --13 --#
    local wheelXOffRight = carTable.wheelXOffRight * carTable.scale -- 52 --#
    local wheelYOffRight = carTable.wheelYOffRight * carTable.scale  --27 --#

    local wheelXOffLeft = carTable.wheelXOffLeft * carTable.scale
    local wheelYOffLeft = carTable.wheelYOffLeft * carTable.scale

    -- Set the fill (paint) to use the bitmap image
    local tyre = {
        type = "image",
        filename = "img/car/".. carChosen .."/car-wheel.png" --#
    }

    wheel = {}
    --wheel[1] = display.newCircle(car, carX+110, carY+55, 30)
    wheel[1] = display.newCircle(carGroup, carX+wheelXOffRight, carY+wheelYOffRight, wheelrad)
    physics.addBody( wheel[1], "dynamic", {density = 0.05*dens,  bounce = 0.1, friction=10, radius=wheelrad,  } )
    wheel[1].angularDamping = 1
    wheel[1].fill = tyre
    wheel[1].name = "tyre"
    --wheel[1]:toBack()

    --wheel[2] = display.newCircle(car, carX-114, carY+60, 30)
    wheel[2] = display.newCircle(carGroup, carX-wheelXOffLeft, carY+wheelYOffLeft, wheelrad)
    physics.addBody( wheel[2], "dynamic", {density = 0.05*dens,  bounce = 0.1, friction=10, radius=wheelrad } )
    wheel[2].angularDamping = 1
    wheel[2].fill = tyre
    wheel[1].name = "tyre"
    --wheel[2]:toBack()

    -- JOINTS

    --local wheel1Joint = physics.newJoint( "pivot", carShape, wheel1, wheel1.x, wheel1.y, 0, 1 )
    --local wheel2Joint = physics.newJoint("pivot", carShape, wheel[2], wheel[2].x, wheel[2].y, 0, 1 )
    local wheelfreq = carTable.wheelfreq
    local wheeldamp = carTable.wheeldamp
    local wheelaxis = carTable.wheelaxis

    --front
    local wheel1Joint = physics.newJoint("wheel", car, wheel[1], wheel[1].x, wheel[1].y, 1, wheelaxis);
    wheel1Joint.isLimitEnabled = true
    wheel1Joint.springFrequency = wheelfreq
    wheel1Joint.springDampingRatio = wheeldamp

    --back
    local wheel2Joint = physics.newJoint("wheel", car, wheel[2], wheel[2].x, wheel[2].y, 1, wheelaxis);
    wheel2Joint.isLimitEnabled = true
    wheel2Joint.springFrequency = wheelfreq
    wheel2Joint.springDampingRatio = wheeldamp


end

function getSpeedRaw()
    local x, y = car:getLinearVelocity()
    return math.sqrt(x ^ 2 +  y ^ 2)
end

function getSpeedms()
    return getSpeedRaw()/(5*ppm)
end