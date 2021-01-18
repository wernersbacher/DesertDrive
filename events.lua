function restart()

	stopped = true
	--physics.pause()
	if(score > stats.highscore) then
		stats.highscore = score
	end
	statMgr.save(stats)
	--storage.saveScores("stats", stats)
	goToSc("game")

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

-- timer to stop when leaving scene
timerTable = {}
stillRunning = false

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
			stillRunning = false
		end
	end )
	table.insert(timerTable, gTimer)

end

function addEventListeners()

	forward:addEventListener("touch", go)
	back:addEventListener("touch", brake)
	tryagain:addEventListener("touch", restart)
	govertryagain:addEventListener("touch", restart)

	tuningBtn:addEventListener("touch", goTuning)
	govertuningBtn:addEventListener("touch", goTuning)

	Runtime:addEventListener( "enterFrame", onFrame )

end

function removeEventListeners()
	forward:removeEventListener("touch", go)
	back:removeEventListener("touch", brake)
	tryagain:removeEventListener("touch", restart)
	govertryagain:removeEventListener("touch", restart)

	tuningBtn:removeEventListener("touch", goTuning)
	govertuningBtn:removeEventListener("touch", goTuning)

	Runtime:removeEventListener( "enterFrame", onFrame )
end