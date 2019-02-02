-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local funcs = require "functions"
--local storage = require "storage"
local statMgr = require "stats"
local tiles = require "tiles"
local scene = composer.newScene()
local hills = require("levels.lvl1")
local physics = require "physics"
local json = require( "json" )

local CBE = require("CBE.CBE")

composer.removeScene("tryagain");

-- const

local ppm = 30
local _firewall = json.decodeFile(system.pathForFile( "particles/fire.json", system.ResourceDirectory )) 

-- game groups
local car = display.newGroup()
local wheels = display.newGroup()
local world = display.newGroup()
local gui = display.newGroup()
local gameover = display.newGroup()
local firewall = display.newGroup()

-- game elements
local wheel = {}
local background, carShape, forward, back, tryagain;
local throttle = 0

--game vars
local startOffset = 0
local score = 0
local score_text
local highscore_text
local car_hp = 1000
local max_hp = 1000

local stats = statMgr.load()

-- level creating
local stopped = false
local hill_sheet = {normal = {}, special = {}}
local hill_outlines = { normal = {}, special = {}}
local fire_sprite

-- timer to stop when leaving scene
local timerTable = {}

-- sound
local menuSound
local soundTable = {
 
    engine_zero = audio.loadSound( "sounds/engine.wav" ),
    engine = audio.loadSound( "sounds/engine_loop.mp3" ),
}

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

	smokeVent._cbe_reserved.destroy()

	composer.gotoScene("tryagain", {
		effect = "fade",
		time = 100,
		params = { actualGoTo = name }
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
	DRIVING FUNCTIONS
]]

function rotateCar(rotateForward) 
	local rotateAcc = 7
	local f = -1
	if(rotateForward) then f = 1 end

	carShape.angularVelocity = carShape.angularVelocity+ f*rotateAcc
end

function accel(ac, max)
	local f = 5 * ( 1 + stage/10 )
	--gas geben
	local maxSpeed = max or 720 * f
	local acceleration = val or 35 * f
	

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
	--fire_sprite.y = carShape.y -- move fire wall with car height
	fireBlock.y = carShape.y
	fireEmitter.x = fireBlock.x
	fireEmitter.y = carShape.y -30

	

	world:translate( -deltaX, -deltaY )
	car:translate( -deltaX, -deltaY )
	-- camera END

	--particle creating (hp)
	
	smokeVent.emitX = carShape.x
	smokeVent.emitY = carShape.y

	--particle end

	-- every 1 seconds check hills
	if(frames % 4 == 0) then
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
		
		--print(al.Source(source, al.PITCH, 2.5))

    elseif ("ended" == phase or "cancelled" == phase ) then
		--timer.pause(touchLooper)
		throttle = 0
		--al.Source(source, al.PITCH, 1)
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

	local hillw = 200
	local hillh = 200

function createHill()
	local magicn = rand(1,100)
	local type ="normal"
	
	
	local stg = tiles.stages[stage]
	local j = rand(stg.num)

	--if special tiles, and magic, then build a special one
		--print(magicn)
		
	if(magicn<10 and stg.special>0) then
		type = "special"
		j = rand(stg.special)
	end

	--next stage after x metres
	--funcs.printt(stage)

	local imageOutline = hill_outlines[type][stage][j]
	--funcs.printt(imageOutline)
	top_margin = top_margin - funcs.topMarginLeft(imageOutline, hillw, hillh)
	
	local newHill = display.newImageRect(world, hill_sheet[type][stage], j, hillw, hillh )
	newHill.name = "hill"
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
	--print("stage: " .. stage .. " driven: ".. already_driven .. ", carshape.x: ".. carShape.x .. ", stg ende:"..stg.ende)
	if(carShape.x > already_driven + stg.ende and #tiles.stages > stage) then
		print ("upgrade stage!  - "..hillw.. " - "..hillh)
		already_driven = already_driven + stg.ende
		stage = stage + 1
		hillw = tiles.stages[stage].width
		hillh = tiles.stages[stage].height 

		stats.money = stats.money + 100
		addMoney(100)
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

	while(#loaded_elements-20 < 1 or carShape.x > loaded_elements[#loaded_elements-20].x) do
		createHill()
	end

	for i=#loaded_elements, 1, -1 do
		if (loaded_elements[i] ~= nil and carShape.x - loaded_elements[i].x > 4000) then
			removeHill(i)
        end
	end
end


function onFireCollision( self, event )
	if stopped then
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
end


function onCarCollision(self, event) 
	if stopped then
		return 
	end

	if ( event.phase == "began" and event.other.name ~= nil and event.other.name == "hill") then
        print( "Touchiiing" )
	end
end


local function onPostCollision( self, event )
	if stopped then
		return 
	end
	--car_hp
	if ( event.force > 35.0 and event.other.name ~= nil and event.other.name == "hill") then
		--print( "force: " .. event.force )
		--print( "friction: " .. event.friction )

		car_hp = car_hp - event.force

		--smokeVent.alpha = (max_hp-car_hp)/max_hp
		local alpha = 0.07 * (max_hp-car_hp)/max_hp 
		smokeVent.startAlpha = alpha
		smokeVent.endAlpha = alpha
		smokeVent.lifeAlpha = alpha

		if car_hp <= 0 then
			setGameOver()
			car_hp = 0
		end
		hptxt.text = funcs.round(car_hp) .. " Struktur"
	end
end

local stillRunning = false

function setGameOver() 
	stillRunning = true
	transition.fadeIn( gameover, { time=2000 } )
	transition.fadeOut( gui, { time=500 } )

	
	smokeVent.stop()
	
	
	
	local gTimer = timer.performWithDelay( 3000, function()  
		if stillRunning then
			physics.pause()
			stopped = true
			fireEmitter:pause()
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
	 
	--menuSound = audio.loadSound( "audio/game-music-loop.ogg" ) 

	--[[
		LOAD SCORES
	

	local stat_load = storage.loadScores("stats")
	if(stat_load) then
		for key,value in pairs(stats) do --actualcode
			if stat_load[key] ~= nil then
				stats[key] = stat_load[key]
			end
			print(key ..  " - " .. stats[key])
		end
	end]]

	--[[
		PARTICLE SYSTEM
	]]


	--[[
		LOAD IMAGE SHEETS
	]]
	

	-- IMAGE TILES
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

		--[[
			LOAD OUTLINES
		]]

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
		
	end


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
	local car_scale = 0.43

	local dens = 100

	local car_image = "img/car/car-body.png"
	local car_outline = graphics.newOutline( 5, car_image)
	carShape = display.newImageRect(car, car_image, 691*car_scale, 194*car_scale)
	carShape.x = oldx
	carShape.y = oldy
	physics.addBody( carShape, "dynamic", { outline = car_outline, friction=0.3, density = 0.005*dens } )
	carShape.linearDamping = 0.5

	carShape.name = "carShape"



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
	wheel[1].name = "tyre"
	--wheel[1]:toBack()

	 --wheel[2] = display.newCircle(car, carX-114, carY+60, 30)
	 wheel[2] = display.newCircle(car, carX-wheelXOff*1.02, carY+wheelYOff*1.17, wheelrad)
	physics.addBody( wheel[2], "dynamic", {density = 0.05*dens,  bounce = 0.1, friction=100, radius=wheelrad } )
	wheel[2].angularDamping = 1
	wheel[2].fill = tyre
	wheel[1].name = "tyre"
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
	-- check to remove
	local start_timer = {}
	function start_timer:timer( event )
		local count = event.count
		print( "Table listener called " .. count .. " time(s)" )
		if carShape.x > 1000 then
			timer.cancel( event.source ) -- after 3rd invocation, cancel timer
			
			wall_bot:removeSelf()
			wall_bot = nil
		end
	end
	  
	-- Register to call t's timer method an infinite number of times
	--local timer.performWithDelay( 1000, t, 0 )

	-- SOUNDS

	--_, source = audio.play(soundTable["engine"], {channel = 1, loops = -1})
	audio.setVolume( 0.7, { channel=1 } )


	-- PARTICLES

	smokeVent = CBE.newVent({
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

	car:insert(smokeVent)
	
	smokeVent:start()

	smokeVent.emitX = carShape.x
	smokeVent.emitY = carShape.y
	--smokeVent.alpha = 0


	-- FIRE 

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

--[[	local fire_shape = {0,-400, 240,-300, 340,0, 240,300, 0,400, -240,300, -430,0, -240, 300, }

	fire_sprite = display.newSprite(world, fire_sheet, sequenceData)
	physics.addBody(fire_sprite, "kinematic", { shape= fire_shape })
	fire_sprite.y = carShape.y	-- spawn height
	fire_sprite.x = -2000
	fire_sprite.name = "fire"
	fire_sprite:setLinearVelocity( 300, 0 ) ]]

	local fireSpawn = -1000

	fireBlock = display.newRect(world, fireSpawn, -100, 10, 2000)
	physics.addBody(fireBlock, "kinematic" )
	fireBlock.name = "fire"
	fireBlock.alpha = 0
	fireBlock:setLinearVelocity( 300, 0 )
	
	fireEmitter = display.newEmitter( _firewall )
	fireEmitter.x = fireSpawn
	fireEmitter.y = carShape.y -30
	world:insert(fireEmitter)

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
	hptxt = display.newText(gui, car_hp .. " Struktur", 1024, 180, native.systemFont, 44 )


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



	sceneGroup:insert(car)
	
	--sceneGroup:insert(wall_bot)
	sceneGroup:insert(world)
	sceneGroup:insert(firewall)

	sceneGroup:insert(gui)
	
	sceneGroup:insert(gameover)
	gameover.alpha = 0




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
		
		
		-- collision detection
		
		--carShape.collision = onCarCollision
		--carShape:addEventListener("collision")
		carShape.postCollision = onPostCollision
		carShape:addEventListener( "postCollision" )

		fireBlock.collision = onFireCollision
		fireBlock:addEventListener( "collision" )
		
		physics.start()

		forward:addEventListener("touch", go)
		back:addEventListener("touch", brake)
		tryagain:addEventListener("touch", restart)
		govertryagain:addEventListener("touch", restart)

		tuningBtn:addEventListener("touch", goTuning)
		govertuningBtn:addEventListener("touch", goTuning)
		
		Runtime:addEventListener( "enterFrame", onFrame )
		
		--[[local pitchDesired = 2
		 
		local source = audio.play(menuSound)
		timer.performWithDelay(5000, function() 
			print("pitch")
			al.Source(source, al.PITCH, 2.0)
		end, 10)]]

		
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