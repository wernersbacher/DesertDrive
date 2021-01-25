
--[[
	DRIVING FUNCTIONS
]]

function rotateCar(rotateForward)

    -- todo only rotate mid air
	local rotateAcc = getMaxes().maxRotationSpeed
	local f = -1
	if(rotateForward) then f = 1 end

	car.angularVelocity = car.angularVelocity + f*rotateAcc
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

function accel()
	--gas geben
    local drive_torque = getDriveTorqueFromRpm()
    wheel[2]:applyTorque(drive_torque)

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

function getWheelRpm()
    return wheel[2].angularVelocity/360
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

    local car_image = "img/car/".. carChosen .."/car-body.png" --#
    local car_outline = graphics.newOutline( 5, car_image)

    car = display.newImageRect(carGroup, car_image, carTable.width*car_scale, carTable.height*car_scale) --#
    car.x = spawnXCar -- basically 0 and content height/2
    car.y = spawnYCar
    physics.addBody( car, "dynamic", { outline = car_outline, friction=0.3, density = carTable.bodyDens } )
    car.linearDamping = carTable.linearDamping

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
    physics.addBody( wheel[1], "dynamic", {density = carTable.wheelDens, bounce = 0.1, friction=carTable.wheelFriction, radius=wheelrad,  } )
    wheel[1].angularDamping = 1
    wheel[1].fill = tyre
    wheel[1].name = "tyre"
    --wheel[1]:toBack()

    --wheel[2] = display.newCircle(car, carX-114, carY+60, 30)
    wheel[2] = display.newCircle(carGroup, carX-wheelXOffLeft, carY+wheelYOffLeft, wheelrad)
    physics.addBody( wheel[2], "dynamic", {density = carTable.wheelDens, bounce = 0.1, friction=carTable.wheelFriction, radius=wheelrad } )
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

    initEngine()

end

function getSpeedRaw()
    local x, y = car:getLinearVelocity()
    return math.sqrt(x ^ 2 +  y ^ 2)
end

function getSpeedms()
    return getSpeedRaw()/(2*ppm)
end