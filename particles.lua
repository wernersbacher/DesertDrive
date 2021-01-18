motorSmoke = nil

function initMotorSmoke()
    -- call after car got created!

    motorSmoke = CBE.newVent({
        --preset = "burn",
    
        positionType = "inRadius", -- Add a bit of randomness to the position
        build = function() local size = math.random(50, 150) return display.newImageRect("img/particle.png", size, size) end,
        rotateTowardVel = true,
        --towardVelOffset = 90,
        lifeTime = 100,
        color = {{0.54}, {0.47}, {0.39}, {0.31}},
        startAlpha = 0.0,
        endAlpha = 0.0,
        lifeAlpha = 0.0,
        physics = {
            angles = {{80, 100}},
            scaleRateX = 0.98,
            scaleRateY = 0.98,
            gravityY = -0.05
        }
    })

    motorSmoke.emitX = car.x
    motorSmoke.emitY = car.y

    carGroup:insert(motorSmoke)
	motorSmoke:start()

end