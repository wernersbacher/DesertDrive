local M = {}


M["dodge"] = {
    name = "dodge",

    width = 691,
    height = 194,
    scale = 0.43,
    dens = 100,
    wheelrad = 28 * 2,
    wheelXOffRight = 110 * 2,
	wheelYOffRight = 55 * 2,
    wheelXOffLeft = 110 * 2 * 1.02,
    wheelYOffLeft = 55 * 2 * 1.17,
    wheeldamp = 0.5,
    wheelaxis = 40,
    wheelfreq = 3,

    maxForwardSpeed = 720,
    maxAcc = 35,
    max_hp = 5000,

    pitch = 1


}

M["mini"] = {
    name = "mini",

    width = 558,
    height = 327,
    scale = 0.38,
    dens = 70,
    wheelrad = 28 * 2,
    wheelXOffRight = 92 * 2,
	wheelYOffRight = 66 * 2,
    wheelXOffLeft = 96 * 2,
    wheelYOffLeft = 66 * 2,
    wheeldamp = 0.5,
    wheelaxis = 40,
    wheelfreq = 3,

    maxForwardSpeed = 760,
    maxAcc = 40,
    max_hp = 6000,

    pitch = 1

}

M["mustang"] = {
    name = "mustang",

    width = 691,
    height = 183,
    scale = 0.43,
    dens = 150,
    wheelrad = 45 * 2,
    wheelXOffRight = 110 * 2,
	wheelYOffRight = 75 * 2,
    wheelXOffLeft = 97 * 2 ,
	wheelYOffLeft = 75 * 2 ,
    wheeldamp = 0.5,
    wheelaxis = 40,
    wheelfreq = 3,

    maxForwardSpeed = 280,
    maxAcc = 12,
    max_hp = 2500,

    pitch = 1.4

}

return M