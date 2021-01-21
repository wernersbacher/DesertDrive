local M = {}

M["dodge"] = {
    name = "dodge",

    width = 691,
    height = 194,
    scale = 1.4,
    bodyDens = 0.025,
    wheelDens = 0.04,
    wheelrad = 28 * 2,
    wheelXOffRight = 110 * 2,
	wheelYOffRight = 55 * 2,
    wheelXOffLeft = 110 * 2 * 1.02,
    wheelYOffLeft = 55 * 2 * 1.17,
    wheeldamp = 0.5,
    wheelaxis = 40,
    wheelfreq = 3,
    linearDamping = 0.1,
    wheelFriction = 5,

    maxRotationSpeed = 5,
    maxForwardSpeed = 10000,
    maxAcc = 50,
    max_hp = 5000,

    pitch = 1


}

M["mini"] = {
    name = "mini",

    width = 558,
    height = 327,
    scale = 0.38,
    bodyDens = 70,
    wheelDens = 100,
    wheelrad = 28 * 2,
    wheelXOffRight = 92 * 2,
	wheelYOffRight = 66 * 2,
    wheelXOffLeft = 96 * 2,
    wheelYOffLeft = 66 * 2,
    wheeldamp = 0.5,
    wheelaxis = 40,
    wheelfreq = 3,
    wheelFriction = 5,

    maxRotationSpeed = 3,
    maxForwardSpeed = 2760,
    maxAcc = 40,
    max_hp = 6000,

    pitch = 1

}

M["mustang"] = {
    name = "mustang",

    width = 691,
    height = 183,
    scale = 0.43,
    bodyDens = 150,
    wheelDens = 100,
    wheelrad = 45 * 2,
    wheelXOffRight = 110 * 2,
	wheelYOffRight = 75 * 2,
    wheelXOffLeft = 97 * 2 ,
	wheelYOffLeft = 75 * 2 ,
    wheeldamp = 0.5,
    wheelaxis = 40,
    wheelfreq = 3,
    wheelFriction = 5,

    maxRotationSpeed = 15,
    maxForwardSpeed = 1280,
    maxAcc = 20,
    max_hp = 2500,

    pitch = 1.4

}

return M