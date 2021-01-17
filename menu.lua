-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

local funcs = require "functions"
local statMgr = require "stats"
local CBE = require("CBE.CBE")
local json = require( "json" )

-- include Corona's "widget" library
local widget = require "widget"

local gameMusic = audio.loadStream("sounds/dude.mp3")
local globals = require("globals")

--------------------------------------------
-- FIRST LOADING
if globals["init"] == nil then
	globals["init"] = true

	
	globals["garage"]  = require "cars"

	globals["garage_names"] = {}
	local i = 1
	for k, v in pairs(globals["garage"]) do
		globals["garage_names"][i] = k
		i = i+1
    end

	globals["soundTable"] = {
 
		engine_zero = audio.loadSound( "sounds/engine.wav" ),
		engine = audio.loadSound( "sounds/engine_loop2.mp3" ),
		jeep = audio.loadSound( "sounds/jeep2.mp3" ),
		check_fire = audio.loadStream("sounds/check_fire.mp3"),
		gameMusic = audio.loadStream("sounds/dude.mp3"),
		crash = audio.loadSound("sounds/crash.mp3")
	}

	globals["_firewall"] = json.decodeFile(system.pathForFile( "particles/fire.json", system.ResourceDirectory )) 


end

--------------------------------------------


local stats = statMgr.load()
local carChosen = "dodge"


-- forward declarations and other locals
local playBtn
local moneyTxt
local scrollView

-- 'onRelease' event listener for playBtn
local function onPlayBtnRelease()
	
	-- go to level1.lua scene
	--composer.gotoScene( "level1", "fade", 500 )
	
	
	funcs.goToSc("level1", carChosen)
	
	return true	-- indicates successful touch
end

function scene:create( event )
	local sceneGroup = self.view

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	-- display a background image
	
	
	--local background = display.newImageRect( "background.jpg", display.actualContentWidth, display.actualContentHeight )
	local background = display.newRect(0,0, display.actualContentWidth, display.actualContentHeight)
	background.fill = { 0, 0, 0 }
	background.anchorX = 0
	background.anchorY = 0
	background.x = 0 + display.screenOriginX 
	background.y = 0 + display.screenOriginY
	
	bg_aura = CBE.newVent({
		preset = "evil",
		positionType = "inRect",
		emitX = 0, emitY = 0,
		rectWidth = display.actualContentWidth,
		rectHeight = display.actualContentHeight,
		rectLeft = display.screenOriginX , -- Left and top coordinates
		rectTop = display.screenOriginY,
		perEmit = 2,
		inTime = 2000,
		physics = {
			velocity = 0
		}
	})
	bg_aura:start()

	-- create/position logo/title image on upper-half of the screen
	local titleLogo = display.newImageRect("img/gui/logo.png", 639, 110)
	titleLogo.x = display.contentCenterX
	titleLogo.y = 100
	
	-- auto anzeige
	local f = 0.6
	--local car = display.newImageRect("img/car/car-full.png", 691*f, 275*f)
	--car.x = -100
	--car.y = display.contentCenterY

	-- Function to handle button events
	function handleButtonEvent( event )
	
		local phase = event.phase
 
		if ( phase == "moved" ) then
			local dy = math.abs( ( event.y - event.yStart ) )
			-- If the touch on the button has moved more than 10 pixels,
			-- pass focus back to the scroll view so it can continue scrolling
			if ( dy > 5 ) then
				scrollView:takeFocus( event )
			end
		
		elseif ( "ended" == phase ) then
			print(event.target.id)
			carChosen = event.target.id
			carText.text = carChosen
		end

		return true
	end

	-- BUTTONS
	
	--[[local dodgeBtn = widget.newButton(
		{
			id = "dodge",
			width = 691*f,
			height = 275*f,
			defaultFile = "img/car/dodge/car-full.png",
			onEvent = handleButtonEvent
		}
	)
	--dodgeBtn.x = scrollView.x
	--dodgeBtn.y = scrollView.y]]
	 
	local num = #globals.garage_names
	local num_cur = 1
	local car_set = false
	local scrollTime = 150

	function setCar() 
		carChosen = globals.garage_names[num-num_cur+1]
		carText.text = carChosen
	end

	function scrollLeft()
		print("pre!")

		local w = dodgeBtn.width + 100
		transition.to( dodgeBtn, { time=scrollTime, x= dodgeBtn.x - w} )
		transition.to( mustangBtn, { time=scrollTime, x= mustangBtn.x - w} )
		transition.to( miniBtn, { time=scrollTime, x= miniBtn.x - w} )
		
	end

	function scrollRight() 
		print("next!")
		
		local w = dodgeBtn.width + 100
		transition.to( dodgeBtn, { time=scrollTime, x= dodgeBtn.x + w} )
		transition.to( mustangBtn, { time=scrollTime, x= mustangBtn.x + w} )
		transition.to( miniBtn, { time=scrollTime, x= miniBtn.x + w} )
	end

	function carScrollListener(event) 
		local phase = event.phase
		if ( phase == "moved" ) then
			local dy =( event.x - event.xStart )
			-- If the touch on the button has moved more than 10 pixels,
			-- pass focus back to the scroll view so it can continue scrolling
			if ( dy < -5 and num_cur < num and car_set == false) then
				num_cur = num_cur+1
				car_set = true
				scrollLeft()
				setCar()
			elseif dy > 5 and num_cur >1 and car_set == false then
				num_cur = num_cur-1
				car_set = true
				scrollRight()
				setCar()
			end
		elseif phase == "ended" then
			car_set = false
		
		end
	 
		return true
	end

	scrollView = widget.newScrollView
	{ 	
		x = display.contentCenterX,
		y =  display.contentCenterY,
		isLocked = true,
		width = 700,
		height = 400,
		scrollWidth = 600,
		scrollHeight = 800,
		verticalScrollDisabled = true,
		hideBackground = false,
		backgroundColor = { 0.8, 0.8, 0.8, 0.3 },
		listener = carScrollListener
	}
	scrollView.x = display.contentCenterX
	scrollView.y = display.contentCenterY


	dodgeBtn = display.newImageRect("img/car/dodge/car-full.png", 691*f, 275*f)
	dodgeBtn.id = "dodge"
	dodgeBtn.x = display.contentCenterX
	dodgeBtn.y = 200
	scrollView:insert( dodgeBtn )
	--sceneGroup:insert( scrollView )
	
	
	mustangBtn = display.newImageRect("img/car/mustang/car-full.png", 691*f, 213*f)
	mustangBtn.id = "mustang"
	mustangBtn.x = dodgeBtn.x+dodgeBtn.width + 100
	mustangBtn.y = 200
	
	scrollView:insert( mustangBtn )

	miniBtn = display.newImageRect("img/car/mini/car-full.png", 558*f, 351*f)
	miniBtn.id = "mini"
	miniBtn.x = mustangBtn.x+mustangBtn.width + 100
	miniBtn.y = 200
	
	scrollView:insert( miniBtn )

	-- BUTTONS ENDE
	---

	carText = display.newText("dodge", display.contentCenterX, display.contentHeight - 250, native.systemFont, 54 )
	--
	moneyTxt = display.newText("$".. stats.money, display.contentCenterX, 200, native.systemFont, 54 )

	-- create a widget button (which will loads level1.lua on release)
	playBtn = widget.newButton{
		label="Start Game",
		emboss = false,
        -- Properties for a rounded rectangle button
		shape = "roundedRect",
		fontSize = 30,
        width = 500,
        height = 100,
		cornerRadius = 2,
		labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
        fillColor = { default={1,0,0,1}, over={1,0.1,0.7,0.4} },
        strokeColor = { default={1,0.4,0,1}, over={0.8,0.8,1,1} },
        strokeWidth = 4,
		onPress = onPlayBtnRelease	-- event listener function
	}
	playBtn.x = display.contentCenterX
	playBtn.y = display.contentHeight - 125


	
	
	-- all display objects must be inserted into group
	sceneGroup:insert( background )
	sceneGroup:insert( bg_aura )
	
	

	--sceneGroup:insert( mustangBtn )
	--sceneGroup:insert( miniBtn )

	sceneGroup:insert(carText)

	sceneGroup:insert( moneyTxt )
	sceneGroup:insert( titleLogo )
	sceneGroup:insert( playBtn )


end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen

		
		--dodgeBtn:addEventListener("touch", handleButtonEvent)
		--dodgeBtn:addEventListener("touch", handleButtonEvent)
		--miniBtn:addEventListener("touch", handleButtonEvent)

		--audio.setVolume( 0.4, { channel=2 } )
		--audio.play(globals.soundTable.gameMusic,{channel = 2, loops = -1})

	scrollView.isVisible = true

	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
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
	elseif phase == "did" then
		-- Called when the scene is now off screen
		
	end	
	
	scrollView.isVisible = false

end

function scene:destroy( event )
	local sceneGroup = self.view
	
	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	
	bg_aura._cbe_reserved.destroy()


	if playBtn then
		playBtn:removeSelf()	-- widgets must be manually removed
		playBtn = nil
	end

end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene