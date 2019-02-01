local json = require( "json" )

local N = {}
 
local function loadScores(file)

    local filePath = system.pathForFile( file.."_auto.json", system.DocumentsDirectory )
    local scores

	local file = io.open( filePath, "r" )

	if file then
		local contents = file:read( "*a" )
		io.close( file )
        scores = json.decode( contents )
        return scores
	end

	return false
end


local function saveScores(file, scores)

    local filePath = system.pathForFile( file.."_auto.json", system.DocumentsDirectory )
	local file = io.open( filePath, "w" )
    print(scores)
	if file then
		file:write( json.encode( scores ) )
        io.close( file )
        return true
    end
    return false
end

N.loadScores = loadScores
N.saveScores = saveScores
 
return N