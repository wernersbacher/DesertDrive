oldx = 0
oldy = display.actualContentHeight/2

frames = 0
seconds = 0


function initRenderOptions()
	oldx = spawnXCar
	oldy = spawnYCar

	world.xScale = ZOOM
	world.yScale = ZOOM

	carGroup.xScale = ZOOM
	carGroup.yScale = ZOOM

	frames = 0
	seconds = 0
end

function onFrame()

	if(stopped == true) then
		return
	end

	if(throttle+braking == 1) then
		accel()
		rotateCar()
	elseif(throttle+braking == -1) then
		decel()
		rotateCar(true)
	end

	-- moving the "camera"
	local deltaX = car.x - oldx
	oldx = car.x

	local deltaY = car.y - oldy
	oldy = car.y
	world:translate( -deltaX*ZOOM, -deltaY *ZOOM)
	carGroup:translate( -deltaX*ZOOM, -deltaY *ZOOM)
	-- camera END

	motorSmoke.emitX = car.x
	motorSmoke.emitY = car.y

	--particle end

	-- update engine
	refreshEngine()

	-- every 17 frames check hills
	if(frames % 17 == 0) then
		refreshHills()
	end
	
	if(frames % 10 == 0) then
		pitchEngine()

		-- score updating
		score = funcs.round(car.x/ppm)
		score_text.text =  score.. "m"

		speedtxt.text = funcs.round(getSpeedms()*3.6).. " km/h"

		-- rpm updating
		rpmtxt.text = funcs.round(funcs.round(rpm)).. " rpm"

		-- gear updating
		geartxt.text = "Gang "..currentGear
	end

	if frames % 60 == 0 then
		seconds = seconds +1
		local x = seconds*1

    end

	frames = (frames + 1) % 10000
end


function go(event)
    
    -- gets called when the gas pedal gets pressed
	local phase = event.phase
	local target = event.target
	local bounds = target.contentBounds
    local phase = event.phase

    if ( "began" == phase ) then
		display.getCurrentStage():setFocus(target)
		target.isFocus = true
		throttle = 1;
		
	elseif ("ended" == phase or "cancelled" == phase) then
		--timer.pause(touchLooper)
		display.getCurrentStage():setFocus(nil)
      	target.isFocus = false
		  throttle = 0
		  
	elseif ( target.isFocus ) then
		if ( (event.x < bounds.xMin) or (event.x > bounds.xMax) or (event.y < bounds.yMin) or (event.y > bounds.yMax) ) then
			display.getCurrentStage():setFocus(nil)        
			target.isFocus = false 

			throttle = 0
		else
			throttle = 1
		end

    
    end

    return true; -- no touch propagation
end

function brake(event)
    -- gets called when the brake pedal gets pressed
	local phase = event.phase
	local target = event.target
	local bounds = target.contentBounds
    local phase = event.phase

    if ( "began" == phase ) then
		display.getCurrentStage():setFocus(target)
		target.isFocus = true
		braking = -1;
		
	elseif ("ended" == phase or "cancelled" == phase) then
		--timer.pause(touchLooper)
		display.getCurrentStage():setFocus(nil)
      	target.isFocus = false
		  braking = 0
		  
	elseif ( target.isFocus ) then
		if ( (event.x < bounds.xMin) or (event.x > bounds.xMax) or (event.y < bounds.yMin) or (event.y > bounds.yMax) ) then
			display.getCurrentStage():setFocus(nil)
			target.isFocus = false

			braking = 0
		else
			braking = -1
		end

    
    end

    return true; -- no touch propagation

end