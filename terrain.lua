math.randomseed(os.clock()*100000000000)

-- https://www.codementor.io/@nickwiggill/eye-openers-series-generating-and-smoothing-2d-terrain-in-unity-p2fpsd0zm

local lastHillHeight = 0

function generateHeightMap()
    math.randomseed(os.clock()*100000000000)

    -- generates a random heightmap with 0 as first and last values
    -- workaround because otherwise the shapes are misaligned
    local temp_map = {0}
	for i=1,NUMBER_OF_HEIGHT_POINTS-1 do
		randomHeight = math.random(0, MAX_HEIGHT_VALUE)
        table.insert(temp_map, randomHeight)
    end
    --table.insert(temp_map, 0)

    local smoothed_map = smoothHeightmap(temp_map)
    smoothed_map[1] = 0
    --smoothed_map[#smoothed_map-1] = 0

	return smoothed_map
end

function smoothHeightmap(heightmap)

    local SCAN_RADIUS = 3

    for i=0, NUMBER_OF_HEIGHT_POINTS do
        
        height = heightmap[i+1]
        
        heightSum = 0
        heightCount = 0
        
        for n=i-SCAN_RADIUS, i+SCAN_RADIUS+1 do
            if n >= 0 and n < NUMBER_OF_HEIGHT_POINTS then
                --print("n "..n)
                heightOfNeighbour = heightmap[n+1]
                heightSum = heightSum + heightOfNeighbour
                heightCount = heightCount + 1
            end
        end
        
        heightAverage = heightSum/heightCount
        heightmap[i+1] = heightAverage;
        
    end

    return heightmap

end

function generateHillVertices()
    -- creates random height maps, and puts that into a correct polygon
    local hill_x_points = {}
	for i=1, NUMBER_OF_HEIGHT_POINTS do
		local coordinate = (i-1)*HEIGHTPOINT_WIDTH
		table.insert(hill_x_points, coordinate);
	end

	--local hill_x_points = {0, 100, 200, 300, 400, 500, 600, 700, 800, 900}
    local heightmap = generateHeightMap()
    
    --heightmap[1] = 0 --set to zero again
    lastHillHeight = heightmap[#heightmap-1] -- save the last hill height for next hills
    local vertices = mergeTables(hill_x_points, heightmap)
    
	-- bottom right corner
	table.insert(vertices, hill_x_points[#hill_x_points]);
	table.insert(vertices, HILL_DEPTH);
	-- bottom left corner
	table.insert(vertices, 0);
    table.insert(vertices, HILL_DEPTH);
    
    return vertices
end

function getLastHillHeight()
    return lastHillHeight
end

function iter(a, b)
    local i = 0
    return function()
        i = i + 1
        return a[i], b[i]
    end
end

function mergeTables(a, b)
    -- both tables must have same lentgh!
    local mergedtable = {}
    for u, v in iter(a, b) do
        table.insert(mergedtable, u)
        table.insert(mergedtable, v)
    end
    return mergedtable
end