-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local funcs = require "functions"
local storage = require "storage"
local tiles = require "tiles"
local scene = composer.newScene()
local hills = require("levels.lvl1")
local physics = require "physics"


composer.removeScene("tryagain");

-- const

local ppm = 30

-- game groups
local car = display.newGroup()
local wheels = display.newGroup()
local world = display.newGroup()
local gui = display.newGroup()

-- game elements
local wheel = {}
local background, carShape, forward, back, tryagain;
local throttle = 0

--game vars
local startOffset = 0
local score = 0
local score_text
local highscore_text

local stats = {}
stats.highscore = 0

-- level creating
local stopped = false
local hill_sheet = {normal = {}, special = {}}
local hill_outlines = { normal = {}, special = {}}

-- forward declarations and other locals
local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX
local spawnX = halfW
local spawnY = screenH / 5 *4

-- functions loc

local rand = math.random

--[[
	RESTART GAME/SCENE
]]

function restart()

	stopped = true
	--physics.pause()
	if(score > stats.highscore) then
		stats.highscore = score
	end
	storage.saveScores("stats", stats)
	composer.gotoScene("tryagain", "fade", 100)

end

--[[
	DRIVING FUNCTIONS
]]

function rotateCar(rotateForward) 
	local rotateAcc = 7
	local f = -1
	if(rotateForward) then f = -1 end

	carShape.angularVelocity = carShape.angularVelocity+ f*rotateAcc
end

function accel(ac, max)
	local f = 6
	--gas geben
	local maxSpeed = max or 720 * f
	local acceleration = val or 25 * f
	

	for i = 1,2,1 do
		local speed = wheel[i].angularVelocity
		if(speed+acceleration > maxSpeed) then
			wheel[i].angularVelocity = maxSpeed
		else
			wheel[i].angularVelocity = speed+acceleration
		end
	
	end

end

function decel(ac, max) 
	local maxSpeed = max or -360 * 3
	local acceleration = val or -20 * 3

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
local oldy = display.actualContentHeight/3 * 2

local frames = 0

function onFrame() 
	if(stopped == true) then
		return
	end

	if(throttle == 1) then
		accel()
		rotateCar()
	elseif(throttle == -1) then
		decel()
		rotateCar(true)
	end

	-- moving the "camera"
	local deltaX = carShape.x - oldx
	oldx = carShape.x

	local deltaY = carShape.y - oldy
	oldy = carShape.y

	world:translate( -deltaX, -deltaY )
	car:translate( -deltaX, -deltaY )
	-- camera END

	-- every 1 seconds check hills
	if(frames % 60 == 0) then
		checkHills()
	end


	-- score updating
	score = math.round(carShape.x/ppm)
	score_text.text =  score.. "m"
	--score_text.text = display.fps .. " FPS"

	frames = frames + 1
end

function go(event)
	--debug.text = "DEBUG"

	--local wheel = event.target
    local phase = event.phase

    if ( "began" == phase ) then
		--timer.resume(touchLooper)
		throttle = 1;
    elseif ("ended" == phase or "cancelled" == phase ) then
		--timer.pause(touchLooper)
		throttle = 0
    end

    return true; -- no touch propagation

	--wheel1.angularVelocity
	 
	--wheel1:applyTorque( 50 )
end

function brake(event)
	--debug.text = "DEBUG"

	--local wheel = event.target
    local phase = event.phase

    if ( "began" == phase ) then
		--timer.resume(touchLooper)
		throttle = -1;
    elseif ("ended" == phase or "cancelled" == phase) then
		--timer.pause(touchLooper)
		throttle = 0
    end

    return true; -- no touch propagation

	--wheel1.angularVelocity
	 
	--wheel1:applyTorque( 50 )
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

	local stage = 1

	local hillw = 200
	local hillh = 200

function createHill()
	
	local stg = tiles.stages[stage]
	--next stage after x metres
	--funcs.printt(stage)
	
	local j = rand(stg.num)
	local imageOutline = hill_outlines.normal[stage][j]
	--funcs.printt(imageOutline)
	top_margin = top_margin - funcs.topMarginLeft(imageOutline, hillw, hillh)
	
	local newHill = display.newImageRect(world, hill_sheet.normal[stage], j, hillw * scale_hill_x, hillh * scale_hill_y )
	newHill.anchorX = 0
	newHill.anchorY = 0
	newHill.x = spawnX + left_margin 
	newHill.y = spawnY + top_margin
	physics.addBody( newHill, "static", { outline=imageOutline, bounce=0, friction=1 } )
	
	--[[	
	local bg_hill = display.newPolygon(world, spawnX + left_margin - 20, spawnY + top_margin + 20, imageOutline )
	bg_hill.anchorX = 0
	bg_hill.anchorY = 0
	bg_hill:setFillColor(0.1, 0.2, 0.3)
	]]
	
	local hill_bottom = display.newRect(world, spawnX + left_margin, spawnY + top_margin + hillh-1, hillw, 1024)
	hill_bottom.anchorX = 0
	hill_bottom.anchorY = 0


	hill_bottom:setFillColor(stg.color[1], stg.color[2], stg.color[3])
	--hill_bottom:setFillColor(0.1, 0.2, 0.3)

	--table.insert(loaded_elements, newHill)
	loaded_elements[#loaded_elements+1] = newHill
	hill_bottoms[#hill_bottoms+1] = hill_bottom
	--bg_elements[#bg_elements+1] = bg_hill

	left_margin = left_margin + hillw

	local newTopM = funcs.topMarginRight(imageOutline, hillw, hillh)
	top_margin = top_margin + newTopM
		
	-- upgrade stage?
	print("stage: " .. stage .. " driven: ".. already_driven .. ", carshape.x: ".. carShape.x .. ", stg ende:"..stg.ende)
	if(carShape.x > already_driven + stg.ende and #tiles.stages > stage) then
		print ("upgrade stage!  - "..hillw.. " - "..hillh)
		already_driven = already_driven + stg.ende
		stage = stage + 1
		hillw = tiles.stages[stage].width
		hillh = tiles.stages[stage].height 
	end


end

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

	while(#loaded_elements-30 < 1 or carShape.x > loaded_elements[#loaded_elements-30].x) do
		createHill()
	end

	for i=#loaded_elements, 1, -1 do
		if (loaded_elements[i] ~= nil and carShape.x - loaded_elements[i].x > 4000) then
			removeHill(i)
        end
	end
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
		LOAD SCORES
	]]

	local stat_load = storage.loadScores("stats")
	if(stat_load) then
		stats = stat_load
	end

	--[[
		LOAD IMAGE SHEETS
	]]

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
		if(stg.special) then
			hill_sheet.special[i] = graphics.newImageSheet( "img/tiles/stage_".. stg.name .."/normal.png",  options)
		end

		--[[
			LOAD OUTLINES
		]]

		table.insert(hill_outlines.normal, i, {})
		for j=1, stg.num, 1 do
			hill_outlines.normal[i][j] = graphics.newOutline(2, hill_sheet.normal[i], j)
		end
		
	end


	-- We need physics started to add bodies, but we don't want the simulaton
	-- running until the scene is on the screen.
	physics.start()
	physics.setScale( ppm )
	physics.setGravity( 0, 28 )
	--physics.setDrawMode("hybrid")
	physics.pause()
	
	-- BACKGROUND
	local background = display.newImageRect( "img/background.png", display.actualContentWidth, display.actualContentHeight )
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
	local car_scale = 0.3

	local dens = 100

	local car_image = "img/car/car-body.png"
	local car_outline = graphics.newOutline( 5, car_image)
	carShape = display.newImageRect(car, car_image, 691*car_scale, 194*car_scale)
	carShape.x = oldx
	carShape.y = oldy
	physics.addBody( carShape, "dynamic", { outline = car_outline, friction=0.3, density = 0.005*dens } )
	carShape.linearDamping = 0.5



	local carX = carShape.x
	local carY = carShape.y
	local wheelrad = 28 * car_scale*2 --13
	local wheelXOff = 110*car_scale*2 -- 52
	local wheelYOff = 55*car_scale*2  --27

	-- Set the fill (paint) to use the bitmap image
	local tyre = {
		type = "image",
		filename = "img/car/car-wheel.png"
	}

	 --wheel[1] = display.newCircle(car, carX+110, carY+55, 30)
	 wheel[1] = display.newCircle(car, carX+wheelXOff, carY+wheelYOff, wheelrad)
	physics.addBody( wheel[1], "dynamic", {density = 0.05*dens,  bounce = 0.1, friction=100, radius=wheelrad,  } )
	wheel[1].angularDamping = 1
	wheel[1].fill = tyre
	--wheel[1]:toBack()

	 --wheel[2] = display.newCircle(car, carX-114, carY+60, 30)
	 wheel[2] = display.newCircle(car, carX-wheelXOff*1.02, carY+wheelYOff*1.17, wheelrad)
	physics.addBody( wheel[2], "dynamic", {density = 0.05*dens,  bounce = 0.1, friction=100, radius=wheelrad } )
	wheel[2].angularDamping = 1
	wheel[2].fill = tyre
	--wheel[2]:toBack()

	-- JOINTS

	--local wheel1Joint = physics.newJoint( "pivot", carShape, wheel1, wheel1.x, wheel1.y, 0, 1 )
	--local wheel2Joint = physics.newJoint("pivot", carShape, wheel[2], wheel[2].x, wheel[2].y, 0, 1 )
	local wheelfreq = 3
	local wheeldamp = 0.5
	local wheelaxis = 40

	--front
	local wheel1Joint = physics.newJoint("wheel", carShape, wheel[1], wheel[1].x, wheel[1].y, 1, wheelaxis);
	wheel1Joint.isLimitEnabled = true
	wheel1Joint.springFrequency = wheelfreq
	wheel1Joint.springDampingRatio = wheeldamp

	--back
	local wheel2Joint = physics.newJoint("wheel", carShape, wheel[2], wheel[2].x, wheel[2].y, 1, wheelaxis);
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


	-- BUTTONS
	back = display.newImageRect(gui, "img/gui/brake.png", 256, 256 )
	back.x = display.screenOriginX
	back.y = display.actualContentHeight
	back.anchorX = 0
	back.anchorY = 1

	forward = display.newImageRect(gui, "img/gui/go.png", 256, 256 )
	forward.x = display.screenOriginX+display.actualContentWidth
	forward.y = display.screenOriginY+display.actualContentHeight
	forward.anchorX = 1
	forward.anchorY = 1

	tryagain = display.newImageRect(gui, "img/gui/repeat.png", 128, 128 )
		tryagain.x = display.screenOriginX +50
		tryagain.y = 0 +50
		tryagain.anchorX = 0
		tryagain.anchorY = 0

	-- TEXT & HIGHSCORE
	score_text = display.newText( gui, "0m", display.contentCenterX, 100, native.systemFont, 54 )
	highscore_text = display.newText( gui, stats.highscore .."m", display.contentCenterX, 180, native.systemFont, 44 )

	-- camera movement
	--camera:add(carShape, 1) -- Add player to layer 1 of the camera
	--camera:prependLayer()
	--camera:add(world, 2)


	-- all display objects must be inserted into group
	sceneGroup:insert( background)

	--sceneGroup:insert( carShape)
	--sceneGroup:insert( wheel1)
	--sceneGroup:insert( wheel2)
	sceneGroup:insert(car)
	
	--sceneGroup:insert(wall_bot)
	sceneGroup:insert(world)

	sceneGroup:insert(gui)

	-- create before others
	checkHills()
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
		physics.start()

		forward:addEventListener("touch", go)
		back:addEventListener("touch", brake)
		tryagain:addEventListener("touch", restart)
		
		Runtime:addEventListener( "enterFrame", onFrame )
		
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