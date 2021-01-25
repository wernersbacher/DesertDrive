function onCarCollision(self, event)
	if gameoverStatus then
		return 
	end

	if ( event.phase == "began" and event.other.name ~= nil and event.other.name == "hill") then
        print( "Touchiiing" )
	end
end

local crashFrameNum = 0
local SMOKE_ALPHA = 0.3
local COLLISION_THRESHOLD = 10

function onPostCollision( self, event )
	if gameoverStatus then
		print("already gameover")
		return
	end
	--car_hp
	if ( event.force > COLLISION_THRESHOLD and event.other.name ~= nil and event.other.name == "hill") then

		print( "force: " .. event.force )
		print( "friction: " .. event.friction )

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
		local alpha = SMOKE_ALPHA * alphaFactor --(max_hp-car_hp)/max_hp 
		
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