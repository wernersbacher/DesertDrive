
function pitchEngine()

	local pitch = 0.9 + 0.8*(rpm/6000)

	al.Source(enginePitch, al.PITCH, pitch)
end