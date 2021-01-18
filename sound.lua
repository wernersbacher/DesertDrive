
function pitchEngine() 
	
	local max = getMaxes()
	local max = max.maxForwardSpeed
	--local acceleration = max.maxForwardAccel
	local cur = math.min( math.abs(wheel[1].angularVelocity), max) -- entweder absolut wert von current, aber höchstens max
	
	local pitch = 0.9 + 0.8*(cur/max)

	al.Source(enginePitch, al.PITCH, pitch)
end