require("math")

function CosineInterpolate(y1, y2, mu)
   local mu2 = (1-math.cos(mu*math.pi))/2;
   return(y1*(1-mu2)+y2*mu2);
end

-- engine vars
currentGear = 1
rpm = 0

-- CAR CONSTANTS
maxrpm = 6500
minrpm = 900
kennlinie = {[0]=10, [1000]=60,  [3000]=130, [4000]=180, [5000]=160, [6000]=120, [6500]=20, [10000] = 0}
gears = {[0]=3.42, [-1]=2.9, [1]=2.66, [2]=1.78, [3]=1.3, [4]=1.0, [5]=0.74, [6]=0.5}
gearNum = 6
transmission_efficiency = 0.7
gearup_threshold = 6000 -- ungefähr da wohl leistung merklich abfällt
geardown_threshold = 3000 -- dieser wert sollte dem entsprechen, der beim hochschalten immer mindestens erreicht wird


function getEngineTorque(currentrpm)
	-- calculates the current engine torque based on the current rpm.

	local tkeys = {}
	-- populate the table that holds the keys
	for k in pairs(kennlinie) do table.insert(tkeys, k) end
	-- sort the keys
	table.sort(tkeys)
	-- use the keys to retrieve the values in the sorted order
	for ix, rpmval in ipairs(tkeys) do 
		--print(ix, rpm, kennlinie[rpm])
		if currentrpm >= rpmval and currentrpm < tkeys[ix+1] then
			local rpm2 = tkeys[ix+1]
			local mu = (currentrpm - rpmval) / (rpm2 - rpmval)
			local nm1 = kennlinie[rpmval]
			local nm2 = kennlinie[rpm2]
			local actualnm = CosineInterpolate(nm1, nm2, mu)
			--print(nm1, nm2, mu, actualnm)
			return actualnm
		end
		
	end

end

function getDriveTorque(engine_torque, gear)
	torque = engine_torque * gears[gear] * gears[0] * transmission_efficiency
	return torque
end


function getEngineRpmFromWheelRpm(currentGear, currentWheelRpm) 
	rpm = currentWheelRpm * gears[currentGear] * gears[0] * 60 * 2 
	if rpm < minrpm then
		return minrpm
	end
	return rpm
end

function updateGear(currentGear, currentEngineRpm)

	if currentEngineRpm > gearup_threshold and currentGear < gearNum then
		--print("Hochschalten")
		return currentGear + 1
	elseif currentEngineRpm < geardown_threshold and currentGear > 1 then
		--print("Herunterschalten")
		return currentGear - 1
	end
	return currentGear

end

function getDriveTorqueFromRpm()
	local raw_torque = getEngineTorque(rpm)
	local drive_torque = getDriveTorque(raw_torque, currentGear)
    return drive_torque*5
end

function refreshEngine()
    local wheelRpm = getWheelRpm()
    rpm = getEngineRpmFromWheelRpm(currentGear, wheelRpm)
    currentGear = updateGear(currentGear, rpm)
end


function initEngine()
    currentGear = 1
    rpm = 0
end









