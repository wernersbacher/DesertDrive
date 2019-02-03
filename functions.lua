
local composer = require( "composer" )

local M = {}


local function printt(myTable)

    for k,v in pairs(myTable) do
        if(type(v) == "table") then
            print("--- SUB TABLE "..k.." ---")
            printt(v)
            print("--- SUB TABLE END ---")
        else 
            print( k,v )
        end
    end
end

local function topMarginRight(outlines, rightpx, maxhigh) 
    local max = 0;
    local maxtrigger = true
    for i = 1, #outlines, 2 do -- wenn wir auf de rrichtigen breite sind und der nächste wert höhere als max ist
        if( outlines[i] == rightpx and outlines[i+1] > max and outlines[i+1] ~= maxhigh) then
            max = outlines[i+1]
            maxtrigger = false
        end
    end

    if(maxtrigger) then
         return maxhigh
    else
        return max
    end
end

local function topMarginLeft(outlines, rightpx, maxhigh) 
    local max = 0;
    local maxtrigger = true
    for i = 1, #outlines, 2 do -- wenn wir auf de rrichtigen breite sind und der nächste wert höhere als max ist
        if( outlines[i] == 0 and outlines[i+1] > max and outlines[i+1] ~= maxhigh) then
            max = outlines[i+1]
            maxtrigger = false
        end
    end
    
    if(maxtrigger) then
        return maxhigh
   else
       return max
   end
end

local function scaleOutline(outline, x, y)
    local newOutline = {}
    for i= 1, #outline, 2 do
        newOutline[i] = outline[i] * x
        newOutline[i+1] = outline[i+1] *y 
    end
    return newOutline
end

local function printMemUsage()

    local memUsed = (collectgarbage("count"))/1000
    
    local texUsed = system.getInfo("textureMemoryUsed")/1000000
    
    print("\n---------MEMORY USAGE INFORMATION---------")
    print("System Memory Used:", string.format("%.03f", memUsed), "Mb")
    print("Texture Memory Used:", string.format("%.03f", texUsed), "Mb")
    print("------------------------------------------\n")
    
    return true
end

function goToSc(name, carChosen)

	composer.gotoScene("tryagain", {
		effect = "fade",
		time = 100,
		params = { actualGoTo = name, carChosen = carChosen }
	})
end

function round(number)
    if (number - (number % 0.1)) - (number - (number % 1)) < 0.5 then
      number = number - (number % 1)
    else
      number = (number - (number % 1)) + 1
    end
   return number
  end

  function eventWithinBounds(obj, event)
    
    local bounds = obj.contentBounds
    local x, y = event.x, event.y
         
    if ((x >= bounds.xMin) and (x <= bounds.xMax) and (y >= bounds.yMin) and (y <= bounds.yMax)) then
        print("got called true")
       return true
    end
    print("got called false")
    return false   
 end


function sigmoid(x)
    return 1/(1 + math.exp(-x))
end

M.printt = printt
M.topMarginRight = topMarginRight
M.topMarginLeft = topMarginLeft
M.printMemUsage = printMemUsage
M.scaleOutline = scaleOutline
M.goToSc = goToSc
M.round = round
M.sigmoid = sigmoid
M.eventWithinBounds = eventWithinBounds
 
return M