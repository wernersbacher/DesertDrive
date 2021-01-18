-- Levelelemente laden

function createHill()
	print("create hills now")
end


function removeHill(i)
    print("Remove old hills")
end



wall_bot = nil

function initStartBottom()
	
	wall_bot = display.newRect(world, display.screenOriginX, spawnY, 3000, 1000)

	wall_bot.anchorX = 0
	wall_bot.anchorY = 0
	physics.addBody(wall_bot, "static", { bounce = 0.1, friction=1 })
    wall_bot:setFillColor(80/255,80/255,80/255)
    
	-- check to remove

    local function listener( event )
        local count = event.count
		print( "Table listener called " .. count .. " time(s)" )
		if car.x ~= nil and car.x > 5000 then
			timer.cancel( event.source ) -- after 3rd invocation, cancel timer
			
			wall_bot:removeSelf()
			wall_bot = nil
		end
    end
	  
	
    local remove_bottom_timer = timer.performWithDelay( 1000, listener, 0)
	table.insert(timerTable, remove_bottom_timer)

end