-- Levelelemente laden

-- todo: remove start bottom too
loaded_hills = {}
wall_bot = nil

START_BOTTOM_WIDTH = 1000
NUMBER_OF_HEIGHT_POINTS = 10
MIN_HEIGHT_VALUE = -150
MAX_HEIGHT_VALUE = 150
HEIGHTPOINT_WIDTH = 200
HILL_DEPTH = 1000

PRELOAD_HILL_NUM = 5

local hill_margin_left = 0 -- to calculate the coordinate
local hill_margin_top = 0

function createHill()
	print("create hills now")

	hill_margin_top = hill_margin_top + getLastHillHeight()

	-- vertices
	local vertices = generateHillVertices()

	-- spawn location
	local x = spawnXStartBottom + START_BOTTOM_WIDTH + getHillWidth()/2 + hill_margin_left
	local y = spawnY + HILL_DEPTH/2 + hill_margin_top

	-- hill creation
	local new_hill = display.newPolygon(world, x, y, vertices)
--[[ 	new_hill.anchorX = 0
	new_hill.anchorY = 0 ]]

	-- body
	physics.addBody( new_hill, "static", { outline=vertices, bounce=0.1, friction=1 } )
    wall_bot:setFillColor(80/255,80/255,80/255)

	hill_margin_left = hill_margin_left + getHillWidth()
	
	table.insert(loaded_hills, new_hill);
end


function removeHill(i)
	if(i>0) then
		loaded_hills[i]:removeSelf()
		loaded_hills[i] = nil
		if(loaded_hills[i] ~= nil) then
			loaded_hills[i]:removeSelf()
			loaded_hills[i] = nil
		end
	end
end

function refreshHills()

	while(#loaded_hills - PRELOAD_HILL_NUM < 1 
		or ( loaded_hills[#loaded_hills-PRELOAD_HILL_NUM] ~= nil and car.x > loaded_hills[#loaded_hills-PRELOAD_HILL_NUM].x)) do
			print("Create hill ".. #loaded_hills-PRELOAD_HILL_NUM)
		createHill()
	end

	for i=#loaded_hills, 1, -1 do
		if (loaded_hills[i] ~= nil and car.x - loaded_hills[i].x > 3000) then
			removeHill(i)
   		end
	end
end


function getHillWidth()
	return (NUMBER_OF_HEIGHT_POINTS-1)*HEIGHTPOINT_WIDTH
end

function initWorld()

	-- init vars
	loaded_hills = {}
	lastHillHeight = 0
	hill_margin_left = 0
	hill_margin_top = 0

	wall_bot = display.newRect(world, spawnXStartBottom, spawnY, START_BOTTOM_WIDTH, 1000)

	wall_bot.anchorX = 0
	wall_bot.anchorY = 0
	physics.addBody(wall_bot, "static", { bounce = 0.1, friction=1 })
    wall_bot:setFillColor(80/255,80/255,80/255)
	table.insert(loaded_hills, wall_bot);
    
	-- check to remove

--[[     local function listener( event )
        local count = event.count
		print( "Table listener called " .. count .. " time(s)" )
		if car.x ~= nil and car.x > 5000 then
			timer.cancel( event.source ) -- after 3rd invocation, cancel timer
			
			wall_bot:removeSelf()
			wall_bot = nil
		end
    end ]]
	  
	
--[[     local remove_bottom_timer = timer.performWithDelay( 1000, listener, 0)
	table.insert(timerTable, remove_bottom_timer) ]]

	-- for testing only
	--createHill()

end