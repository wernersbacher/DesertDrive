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

-- include Corona's "widget" library
local widget = require "widget"

local gameMusic = audio.loadStream("sounds/dude.mp3")

--------------------------------------------


local stats = statMgr.load()
local carChosen = "dodge"


-- forward declarations and other locals
local playBtn
local moneyTxt

-- 'onRelease' event listener for playBtn
local function onPlayBtnRelease()
	
	-- go to level1.lua scene
	--composer.gotoScene( "level1", "fade", 500 )
	
	bg_aura._cbe_reserved.destroy()
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
	local function handleButtonEvent( event )
	
		if ( "ended" == event.phase ) then
			print(event.target.id)
			carChosen = event.target.id
			carText.text = carChosen
		end
	end
	
	local dodgeBtn = widget.newButton(
		{
			id = "dodge",
			width = 691*f,
			height = 275*f,
			defaultFile = "img/car/dodge/car-full.png",
			label = "button",
			onEvent = handleButtonEvent
		}
	)
	dodgeBtn.x = -100
	dodgeBtn.y = display.contentCenterY
	
	dodgeBtn:setLabel( "" )

	local mustangBtn = widget.newButton(
		{
			id = "mustang",
			width = 691*f,
			height = 213*f,
			defaultFile = "img/car/mustang/car-full.png",
			label = "button",
			onEvent = handleButtonEvent
		}
	)
	mustangBtn.x = dodgeBtn.x+dodgeBtn.width + 100
	mustangBtn.y = display.contentCenterY
	
	mustangBtn:setLabel( "" )

	local miniBtn = widget.newButton(
		{
			id = "mini",
			width = 558*f,
			height = 351*f,
			defaultFile = "img/car/mini/car-full.png",
			label = "button",
			onEvent = handleButtonEvent
		}
	)
	miniBtn.x = mustangBtn.x+mustangBtn.width + 100
	miniBtn.y = display.contentCenterY
	
	miniBtn:setLabel( "" )

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
	
	
	sceneGroup:insert( dodgeBtn )
	sceneGroup:insert( mustangBtn )
	sceneGroup:insert(miniBtn)

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

		audio.setVolume( 0.4, { channel=2 } )
		--audio.play(gameMusic,{channel = 2, loops = -1})

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
end

function scene:destroy( event )
	local sceneGroup = self.view
	
	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	
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