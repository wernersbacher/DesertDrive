-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------


require "math"

local composer = require( "composer" )
local funcs = require "functions"
--local storage = require "storage"
local statMgr = require "stats"
local tiles = require "datasets.tiles"
local scene = composer.newScene()
local hills = require("levels.lvl1")
local physics = require "physics"
local globals = require("globals")

local CBE = require("CBE.CBE")

composer.removeScene("tryagain");

-- game classes
local carClass = require("classes.car")

-- const

local ppm = 30
local preLoadNum = 6


local smokeAlpha = 0.11
local maxFireSpeed = 780

-- game groups
local carGroup = display.newGroup()
local wheels = display.newGroup()
local world = display.newGroup()
local gui = display.newGroup()
local gameover = display.newGroup()

-- game elements
local carObject = carClass:Create()

local wheel = {}
local background, forward, back, tryagain;
local car;
local throttle = 0
local braking = 0

--game vars
local gameoverStatus = false
local startOffset = 0
local score = 0
local score_text
local highscore_text
local car_hp, max_hp = 5000, 5000
local carChosen = "dodge"

local stats = statMgr.load()

-- level creating
local stopped = false
local hill_sheet = {normal = {}, special = {}}
local hill_outlines = { normal = {}, special = {}}
local stageTrigger = {}

-- timer to stop when leaving scene
local timerTable = {}

-- forward declarations and other locals
local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX
local spawnX = halfW
local spawnY = screenH / 5 *4

-- functions loc

local rand = math.random

local function noProp(e)
	return true
end

--[[
	RESTART GAME/SCENE
]]

function goToSc(name) 

	for k, v in pairs(timerTable) do
		timer.cancel( v )
	end

	motorSmoke._cbe_reserved.destroy()
	
	audio.stop({ channel=1 })

	composer.gotoScene("tryagain", {
		effect = "fade",
		time = 100,
		params = { actualGoTo = name, carChosen = carChosen }
	})

end

function restart()

	stopped = true
	--physics.pause()
	if(score > stats.highscore) then
		stats.highscore = score
	end
	statMgr.save(stats)
	--storage.saveScores("stats", stats)
	goToSc("level1")

end

function goTuning() 

	stopped = true
	--physics.pause()
	if(score > stats.highscore) then
		stats.highscore = score
	end
	statMgr.save(stats)
	--storage.saveScores("stats", stats)
	goToSc("menu")

end

--[[
	SOUND FUNCTIONS
]]

function pitchEngine() 
	
	local max = getMaxes()
	local max = max.maxForwardSpeed
	--local acceleration = max.maxForwardAccel
	local cur = math.min( math.abs(wheel[1].angularVelocity), max) -- entweder absolut wert von current, aber höchstens max
	
	local pitch = 0.9 + 0.8*(cur/max)

	al.Source(enginePitch, al.PITCH, pitch)
end

--[[
	DRIVING FUNCTIONS
]]

function rotateCar(rotateForward) 
	local rotateAcc = 12
	local f = -1
	if(rotateForward) then f = 1 end

	car.angularVelocity = car.angularVelocity+ f*rotateAcc
end

function getMaxes() 
	local f = 5 * ( 1 + stage/10 )
	local M = {}
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
	local sinus_func = 0.5*(math.abs(math.sin(0.8*math.pi*x))+0.5)
	local accel_factor = e_func*sinus_func
	print(accel_factor)
	return accel_factor

end

function accel()
	--gas geben
	local max = getMaxes()
	local maxSpeed = max.maxForwardSpeed
	local maxAcceleration = max.maxForwardAccel
	

	for i = 1,2,1 do
		local speed = wheel[i].angularVelocity
		local accel = getCurrentAccel(maxSpeed, speed) * maxAcceleration
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


local oldx = 0
local oldy = display.actualContentHeight/2

local frames = 0
local triggerCounter = 1
local seconds = 0

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
	 -- move fire wall with car height
--[[ 	fireBlock.y = carShape.y
	fireEmitter.x = fireBlock.x
	fireEmitter.y = carShape.y -30 ]]

	

	world:translate( -deltaX, -deltaY )
	carGroup:translate( -deltaX, -deltaY )
	-- camera END

	--particle creating (hp)
	
	motorSmoke.emitX = car.x
	motorSmoke.emitY = car.y

	--particle end

	-- check if new stage reached
	-- upgrade
--[[ 	if stageTrigger[triggerCounter] ~= nil and stageTrigger[triggerCounter] > 0 and carShape.x > stageTrigger[triggerCounter] then
		addMoney(100)
		triggerCounter = triggerCounter +1
	end ]]

	-- every 4 frames check hills
	if(frames % 4 == 0) then
		--checkHills()
		pitchEngine()

--[[ 		if fireBlock.x + 2000 > carShape.x then
			fireWarning.isVisible = true
		else
			fireWarning.isVisible = false
		end ]]

	-- score updating
		score = math.round(car.x/ppm)
		score_text.text =  score.. "m"

		local x, y = car:getLinearVelocity()
		local abs_speed = math.sqrt(x ^ 2 +  y ^ 2)

		speedtxt.text = math.round(abs_speed/ppm).. " m/s"
	end
	
	if frames % 60 == 0 then
		seconds = seconds +1
		local x = seconds*1
		local newSpeed = maxFireSpeed * funcs.sigmoid(x)


		--local x, y = fireBlock:getLinearVelocity()
		--fireBlock:setLinearVelocity(newSpeed, 0)
	end
	
	-- score updating
	--score_text.text = display.fps .. " FPS"

	frames = frames + 1
end

function go(event)
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

--[[
	economy/money
]]

function addMoney(mon) 
	stats.money = stats.money + mon

	moneyTxt.text = "$".. stats.money
end


--[[
	LEVEL FUNCTIONS
]]

	-- Levelelemente laden
	local scale_hill_x = 1
	local scale_hill_y = 1
	local physic_hill = {}
	local loaded_elements = {}
	local bg_elements = {}
	local hill_bottoms = {}
	local left_margin = 0
	local top_margin = 0
	local scale_hill = 1
	local already_driven = 0

	stage = 1
	stageCount = 1

	local hillw = 200
	local hillh = 200
	local hillscaler = 1
	local nextStageTrigger = 0

function createHill()
	print("create hills now")
end

--[[ function createHill()
	local magicn = rand(1,100)
	local type ="normal"
	
	
	local stg = tiles.stages[stage]
	local j = rand(stg.num)

	--if special tiles, and magic, then build a special one
		--print(magicn)
		
	-- würfeln von j, welches das teil ist	
	if(magicn<10 and stg.special>0) then
		type = "special"
		j = rand(stg.special)
	end

	--hill outline poly
	local imageOutline = hill_outlines[type][stage][j]
	-- spawnverschiebung
	top_margin = top_margin - funcs.topMarginLeft(imageOutline, hillw, hillh)
	
	local newHill = display.newImageRect(world, hill_sheet[type][stage], j, hillw, hillh )
	--local newHill = display.newPolygon(world, spawnX + left_margin, spawnY + top_margin, imageOutline )
	newHill.name = "hill"
	newHill.anchorX = 0
	newHill.anchorY = 0
	newHill.x = spawnX + left_margin 
	newHill.y = spawnY + top_margin
	physics.addBody( newHill, "static", { outline=imageOutline, bounce=0, friction=1 } )
	
		
	local bg_hill = display.newPolygon(world, spawnX + left_margin - 20, spawnY + top_margin + 20, imageOutline )
	bg_hill.anchorX = 0
	bg_hill.anchorY = 0
	bg_hill:setFillColor(0.1, 0.2, 0.3)
	
	
	local hill_bottom = display.newRect(world, spawnX + left_margin, spawnY + top_margin + hillh-1, hillw, 1024)
	hill_bottom.anchorX = 0
	hill_bottom.anchorY = 0


	hill_bottom:setFillColor(stg.color[1], stg.color[2], stg.color[3])
	--hill_bottom:setFillColor(0.1, 0.2, 0.3)

	loaded_elements[#loaded_elements+1] = newHill
	hill_bottoms[#hill_bottoms+1] = hill_bottom

	left_margin = left_margin + hillw

	local newTopM = funcs.topMarginRight(imageOutline, hillw, hillh)
	top_margin = top_margin + newTopM
		
	-- upgrade stage?
	--print("stage: " .. stage .. " driven: ".. already_driven .. ", carshape.x: ".. carShape.x .. ", stg ende:"..stg.ende)
	if(stageCount >= stg.count)	then
		--print ("upgrade stage! "..carShape.x.. " > "..already_driven.. " + " .. stg.width*stg.count .. " - ".. display.actualContentWidth .. " count: ".. stg.count)
			print("stages insg: ".. #tiles.stages .. ", stage jetzt:" .. stage)

		already_driven = already_driven + stg.width*stg.count
		stageCount = 0 
		stage = stage + 1 --% #tiles.stages 
		if #tiles.stages < stage then
			stage = 1
		end
		hillw = tiles.stages[stage].width
		hillh = tiles.stages[stage].height 
		--hillscaler = tiles.stages[stage].scaler
		

		nextStageTrigger = nextStageTrigger + stg.width*stg.count
		table.insert(stageTrigger, nextStageTrigger)

	--elseif #tiles.stages <= stage then

		
		
		end

	stageCount = stageCount + 1

end ]]

function removeHill(i)
	if(i>0) then
		loaded_elements[i]:removeSelf()
		loaded_elements[i] = nil
		if(hill_bottoms[i] ~= nil) then
			hill_bottoms[i]:removeSelf()
			hill_bottoms[i] = nil
		end
	end
end


function checkHills() 

	while(#loaded_elements - preLoadNum < 1 
		or ( loaded_elements[#loaded_elements-preLoadNum] ~= nil and car.x > loaded_elements[#loaded_elements-preLoadNum].x)) do
			--print("Create hill ".. #loaded_elements-preLoadNum)
		createHill()
	end

	for i=#loaded_elements, 1, -1 do
		if (loaded_elements[i] ~= nil and car.x - loaded_elements[i].x > 3000) then
			removeHill(i)
    end
	end
end


--[[ function onFireCollision( self, event )
	if gameoverStatus then
		return 
	end
 
    if ( event.phase == "began" and event.other.name ~= nil and event.other.name == "carShape") then
		print( "Gameover!!" )
		setGameOver()
 
	elseif ( event.phase == "ended" ) then
		if event.other.name ~= nil then 
			print( self.name .. ": collision ended with " .. event.other.name )
			-- Collision.
		end
        
    end
end ]]


function onCarCollision(self, event) 
	if gameoverStatus then
		return 
	end

	if ( event.phase == "began" and event.other.name ~= nil and event.other.name == "hill") then
        print( "Touchiiing" )
	end
end
local crashFrameNum = 0
local function onPostCollision( self, event )
	if gameoverStatus then
		return 
	end
	--car_hp
	if ( event.force > 35.0 and event.other.name ~= nil and event.other.name == "hill") then
		--print( "force: " .. event.force )
		--print( "friction: " .. event.friction )

		-- generate sound
		if(crashFrameNum + 30 < frames) then
			audio.play(globals.soundTable["crash"], {channel = 3, loops = 0})
			crashFrameNum = frames
		end
		-- lower hp

		car_hp = car_hp - event.force
		local f = 10000/max_hp -- wenn weniger hp da sind, muss der wert skaliert werden
		local alphaFactor = 0.0014* 1.0007^((max_hp-car_hp)*f)
		print(alphaFactor)
		local alpha = smokeAlpha * alphaFactor --(max_hp-car_hp)/max_hp 
		
		motorSmoke.startAlpha = alpha
		motorSmoke.endAlpha = alpha
		motorSmoke.lifeAlpha = alpha

		if car_hp <= 0 then
			setGameOver()
			car_hp = 0
		end

	-- sparks
	print( "position: " .. event.x .. "," .. event.y )
	
	--sparksVent.emitX = event.x 
	--sparksVent.emitY = event.y

		hptxt.text = funcs.round(car_hp) .. " Struktur"
		
	end
end

local stillRunning = false

function setGameOver() 
	gameoverStatus = true
	throttle = 0
	braking = 0
	audio.stop({ channel=1 })
	stillRunning = true
	transition.fadeIn( gameover, { time=2000 } )
	transition.fadeOut( gui, { time=500 } )

	
	motorSmoke.stop()
	
	local gTimer = timer.performWithDelay( 3000, function()  
		if stillRunning then
			physics.pause()
			stopped = true
			--fireEmitter:pause()
		end  
	end )
	table.insert(timerTable, gTimer)

end

--[[
	SCENE FUNCTIONS
	
]]



function scene:create( event )

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	local sceneGroup = self.view


	--[[
		PARTICLE SYSTEM
	]]


	--[[
		LOAD IMAGE SHEETS
	]]
	carChosen = event.params.carChosen or "dodge"

--[[ 	-- IMAGE TILES
	for i = 1, #tiles.stages, 1 do

		local stg = tiles.stages[i]
		--funcs.printt(stg)
		options = {
			width = stg.width,
			height = stg.height,
			numFrames = stg.num
		}
		
		-- create sheet
		hill_sheet.normal[i] = graphics.newImageSheet( "img/tiles/stage_".. stg.name .."/normal.png",  options)
		if(stg.special > 0) then
			options.numFrames = stg.special
			hill_sheet.special[i] = graphics.newImageSheet( "img/tiles/stage_".. stg.name .."/special.png",  options)
		end

		
		--	LOAD OUTLINES
	

		table.insert(hill_outlines.normal, i, {})
		for j=1, stg.num, 1 do
			hill_outlines.normal[i][j] = graphics.newOutline(2, hill_sheet.normal[i], j)
		end

		
		table.insert(hill_outlines.special, i, {})
		if(stg.special > 0) then
			for j = 1, stg.special,1 do
				hill_outlines.special[i][j] = graphics.newOutline(2, hill_sheet.special[i], j)
			end
		end	
		
	end ]]

	

	-- We need physics started to add bodies, but we don't want the simulaton
	-- running until the scene is on the screen.
	physics.start()
	physics.setScale( ppm )
	physics.setGravity( 0, 28 )
	--physics.setDrawMode("hybrid")
	physics.pause()

	-- BACKGROUND
	local background = display.newImageRect( "img/background2.png", display.actualContentWidth, display.actualContentHeight )
	background.anchorX = 0
	background.anchorY = 0
	background.x = 0 + display.screenOriginX 
	background.y = 0 + display.screenOriginY
	
	-- CLOUDS ETC
	--[[
	local clouds = {}
	clouds[1] = display.newImageRect("img/bg/cloud.png", 128, 128)
	clouds[1].anchorX = 0
	clouds[1].anchorY = 0
	clouds[1].x = 0 + display.screenOriginX 
	clouds[1].y = 0 + display.screenOriginY
	]]


	-- CAR
	carObject:CreateCar()

	carTable = globals.garage[carChosen]
	local car_scale = carTable.scale --#
	max_hp, car_hp = carTable.max_hp, carTable.max_hp
	local dens = carTable.dens
	
	local car_image = "img/car/".. carChosen .."/car-body.png" --#
	local car_outline = graphics.newOutline( 5, car_image)
	car = display.newImageRect(carGroup, car_image, carTable.width*car_scale, carTable.height*car_scale) --#
	car.x = oldx -- basically 0 and content height/2
	car.y = oldy
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
	wheel1Joint.isLimitEnabled = true
	wheel1Joint.springFrequency = wheelfreq
	wheel1Joint.springDampingRatio = wheeldamp

	-- START BOTTOM

	
	-- Startboden
	local wall_bot = display.newRect(world, display.screenOriginX, spawnY, screenW/2, 1000)
	wall_bot.anchorX = 0
	wall_bot.anchorY = 0
	physics.addBody(wall_bot, "static", { bounce = 0.1, friction=1 })
	wall_bot:setFillColor(80/255,80/255,80/255)
	-- check to remove
	local start_timer = {}
	function start_timer:timer( event )
		local count = event.count
		print( "Table listener called " .. count .. " time(s)" )
		if car.x > 1000 then
			timer.cancel( event.source ) -- after 3rd invocation, cancel timer
			
			wall_bot:removeSelf()
			wall_bot = nil
		end
	end
	  
	-- Register to call t's timer method an infinite number of times
	--local timer.performWithDelay( 1000, t, 0 )

	-- SOUNDS

	_, enginePitch = audio.play(globals.soundTable["jeep"], {channel = 1, loops = -1})
	--audio.setVolume( 0.7, { channel=1 } )


	-- PARTICLES

	motorSmoke = CBE.newVent({
		--preset = "burn",

		positionType = "inRadius", -- Add a bit of randomness to the position
		build = function() local size = math.random(50, 150) return display.newImageRect("img/particle.png", size, size) end,
		rotateTowardVel = true,
		--towardVelOffset = 90,
		lifeTime = 100,
		color = {{0.54}, {0.47}, {0.39}, {0.31}},
		startAlpha = 0.0,
		endAlpha = 0.0,
		lifeAlpha = 0.0,
		physics = {
			angles = {{80, 100}},
			scaleRateX = 0.98,
			scaleRateY = 0.98,
			gravityY = -0.05
		}
	})

	carGroup:insert(motorSmoke)
	
	motorSmoke:start()

	motorSmoke.emitX = car.x
	motorSmoke.emitY = car.y
	--smokeVent.alpha = 0
--[[
	sparksVent = CBE.newVent({
		preset = "burn",

		positionType = "inRadius", -- Add a bit of randomness to the position
		build = function() local size = math.random(5, 15) return display.newImageRect("img/particle.png", size, size) end,
		physics = {
			velocity = 0,
			gravityY = -0.035,
			angles = {0, 360},
			scaleRateX = 1.05,
			scaleRateY = 1.05
		}
	})
	car:insert(sparksVent)
	sparksVent:start()
	local sTimer = timer.performWithDelay( 100, function() 
		funcs.printt(sparkGroup)
		sparkVent._cbe_reserved.destroy()
	end )
	table.insert(timerTable, sTimer)
]]


--[[ 	-- FIRE 

	local fire_sheet = graphics.newImageSheet( "img/fire.png",  {
		width = 679,
		height = 892,
		numFrames = 2
	})

	local sequenceData =
	{
		name="burn",
		start=1,
		count=2,
		time=100,
		loopCount = 0,   -- Optional ; default is 0 (loop indefinitely)
		loopDirection = "bounce"    -- Optional ; values include "forward" or "bounce"
	}

	local fireSpawn = -1500 ]]

--[[ 	fireBlock = display.newRect(world, fireSpawn, -100, 10, 2000)
	physics.addBody(fireBlock, "kinematic" )
	fireBlock.name = "fire"
	fireBlock.alpha = 0
	fireBlock:setLinearVelocity(0, 0)
	
	fireEmitter = display.newEmitter( globals._firewall )
	fireEmitter.x = fireSpawn
	fireEmitter.y = carShape.y -30
	world:insert(fireEmitter) ]]

	-- BUTTONS
	local butScale = 0.9
	back = display.newImageRect(gui, "img/gui/brake.png", 256*butScale, 256 *butScale)
	back.x = display.screenOriginX+20
	back.y = display.actualContentHeight-50
	back.anchorX = 0
	back.anchorY = 1
	

	forward = display.newImageRect(gui, "img/gui/go.png", 256*butScale, 256 *butScale)
	forward.x = display.screenOriginX+display.actualContentWidth-20
	forward.y = display.screenOriginY+display.actualContentHeight-50
	forward.anchorX = 1
	forward.anchorY = 1

	tryagain = display.newImageRect(gui, "img/gui/repeat.png", 128, 128 )
	tryagain.x = display.screenOriginX +50
	tryagain.y = 0 +50
	tryagain.anchorX = 0
	tryagain.anchorY = 0

		
	tuningBtn = display.newImageRect(gui, "img/gui/tuning.png", 128, 128 )
	tuningBtn.x = tryagain.x + 50 + 128
	tuningBtn.y = 0 +50
	tuningBtn.anchorX = 0
	tuningBtn.anchorY = 0

	-- TEXT & HIGHSCORE
	score_text = display.newText( gui, "0m", display.contentCenterX, 100, native.systemFont, 54 )
	highscore_text = display.newText( gui, stats.highscore .."m", display.contentCenterX, 180, native.systemFont, 44 )

	-- MONEY

	moneyTxt = display.newText(gui, "$".. stats.money, 1024, 100, native.systemFont, 54 )

	-- hp bzw. health
	hptxt = display.newText(gui, car_hp .. " Struktur", 1024, 180, native.systemFont, 44 )

	-- speed
	speedtxt = display.newText(gui, "0 km/h", 1024, 260, native.systemFont, 44 )

	-- WARNING FIRE

--[[ 	fireWarning = display.newImageRect(gui, "img/fire_behind2.png", 853*0.5, 184*0.5)
	fireWarning.x = display.contentCenterX
	fireWarning.y = 300
	transition.blink( fireWarning, { time=2200 } ) ]]


	-- GAMEOVER ZEUG
	local goverBack = display.newRect(gameover, 0, 0, display.actualContentWidth, display.actualContentWidth )
	goverBack.anchorX = 0
	goverBack.anchorY = 0
	goverBack.x = 0 + display.screenOriginX 
	goverBack.y = 0 + display.screenOriginY
	goverBack.alpha = 0.5
	goverBack:setFillColor( black )
	goverBack:addEventListener("touch", noProp)

	local goverLogo = display.newImageRect(gameover, "img/gameover.png", 545*2, 50*2)
	goverLogo.x = display.contentCenterX
	goverLogo.y = 200


	govertryagain = display.newImageRect(gameover, "img/gui/repeatw.png", 150, 150 )
	govertryagain.x = display.contentCenterX -40 - 75
	govertryagain.y = display.contentCenterY

		
	govertuningBtn = display.newImageRect(gameover, "img/gui/tuningw.png", 150, 150 )
	govertuningBtn.x = display.contentCenterX +40 +75
	govertuningBtn.y = display.contentCenterY

	-- all display objects must be inserted into group
	sceneGroup:insert(background)



	sceneGroup:insert(carGroup)
	
	--sceneGroup:insert(wall_bot)
	sceneGroup:insert(world)
	--sceneGroup:insert(firewall)

	sceneGroup:insert(gui)
	
	sceneGroup:insert(gameover)
	gameover.alpha = 0


	-- create before others
	--checkHills()
end



function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen


	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
		
		
		-- collision detection
		
		--carShape.collision = onCarCollision
		--carShape:addEventListener("collision")
		car.postCollision = onPostCollision
		car:addEventListener( "postCollision" )

		--fireBlock.collision = onFireCollision
		--fireBlock:addEventListener( "collision" )
		
		physics.start()

		forward:addEventListener("touch", go)
		back:addEventListener("touch", brake)
		tryagain:addEventListener("touch", restart)
		govertryagain:addEventListener("touch", restart)

		tuningBtn:addEventListener("touch", goTuning)
		govertuningBtn:addEventListener("touch", goTuning)
		
		Runtime:addEventListener( "enterFrame", onFrame )
		
		--audio.play(globals.soundTable["check_fire"], {loop=0, channel=30})

		
	end
end

function scene:hide( event )
	local sceneGroup = self.view
	
	local phase = event.phase
	
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
		physics.stop()
	elseif phase == "did" then 
		-- Called when the scene is now off screen
	end	
	
end

function scene:destroy( event )

	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	local sceneGroup = self.view
	
	package.loaded[physics] = nil
	physics = nil
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )



-----------------------------------------------------------------------------------------

return scene