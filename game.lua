-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------


require "math"

inspect = require('lib.inspect')

composer = require( "composer" )
--storage = require "storage"
scene = composer.newScene()
physics = require "physics"
globals = require("globals")
CBE = require("CBE.CBE")
funcs = require "functions"
statMgr = require "stats"

-- convert between pixels and meters
ppm = 30

-- button states
throttle = 0
braking = 0

--game vars
gameoverStatus = false
stopped = false

-- score
score = 0

-- forward declarations and other locals
screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX
spawnX = halfW
spawnY = screenH / 5 *4
spawnXStartBottom = display.screenOriginX
spawnXCar = 0
spawnYCar = display.actualContentHeight/2


require("groups")
initGroups()
require("eco")
require("car")
require("ui")
require("gameover")
require("background")
require("events")
require("sound")
require("terrain")
require("world")
require("particles")
require("collisions")
require("render")

composer.removeScene("tryagain");

function scene:create( event )

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	local sceneGroup = self.view

    carChosen = event.params.carChosen or "dodge"
    
    initRenderOptions()
	
	-- We need physics started to add bodies, but we don't want the simulaton
	-- running until the scene is on the screen.
	physics.start()
	physics.setScale( ppm )
	physics.setGravity( 0, 28 )
	physics.pause()
	physics.setDrawMode("hybrid")

    -- BACKGROUND CREATION
    initBackground()

    -- CAR CREATION

    initCar(carChosen)

    -- START BOTTOM

    initWorld()

	-- SOUNDS

	_, enginePitch = audio.play(globals.soundTable["jeep"], {channel = 1, loops = -1})
	audio.setVolume( 0.1, { channel=1 } )

	-- PARTICLES
    initMotorSmoke()

    -- UI
    initUIButtons()
    initGameoverButtons()

	-- all display objects must be inserted into group
	sceneGroup:insert(background)
	sceneGroup:insert(carGroup)
	sceneGroup:insert(world)
	sceneGroup:insert(gui)
	sceneGroup:insert(gameover)
	gameover.alpha = 0


	-- create before others
	refreshHills()
end



function scene:show( event )
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen


	elseif phase == "did" then
		-- Called when the scene is now on screen
		--
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
		
		
		-- collision detection
		car.postCollision = onPostCollision
		car:addEventListener( "postCollision" )

		
		physics.start()

        -- SARTING EVENT listeners
        addEventListeners()
		
	end
end

function scene:hide( event )
    
    print("game got hidden")

	local phase = event.phase
	
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
        physics.stop()
        
        removeEventListeners()

	elseif phase == "did" then 
		-- Called when the scene is now off screen
	end	
	
end

function scene:destroy( event )

    
    print("game got destroyed")

	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	removeHills()
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