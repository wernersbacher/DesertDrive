
-- BUTTONS
back = nil
forward = nil
tryagain = nil
tuningBtn = nil

score_text = nil
highscore_text = nil
moneyTxt = nil
hptxt = nil
speedtxt = nil

function initUIButtons()
    local butScale = 0.9
    back = display.newImageRect(gui, "img/gui/brake.png", 256*butScale, 256 *butScale)
    back.x = display.screenOriginX+20
    back.y = display.actualContentHeight-50
    back.anchorX = 0
    back.anchorY = 1


    forward = display.newImageRect(gui, "img/gui/go.png", 256*butScale, 256 *butScale)
    forward.x = display.screenOriginX+display.actualContentWidth-20
    forward.y = display.screenOriginY+display.actualContentHeight-50
    forward.anchorX = 1
    forward.anchorY = 1

    tryagain = display.newImageRect(gui, "img/gui/repeat.png", 128, 128 )
    tryagain.x = display.screenOriginX +50
    tryagain.y = 0 +50
    tryagain.anchorX = 0
    tryagain.anchorY = 0

    tuningBtn = display.newImageRect(gui, "img/gui/tuning.png", 128, 128 )
    tuningBtn.x = tryagain.x + 50 + 128
    tuningBtn.y = 0 +50
    tuningBtn.anchorX = 0
    tuningBtn.anchorY = 0

    -- TEXT & HIGHSCORE
    score_text = display.newText( gui, "0m", display.contentCenterX, 100, native.systemFont, 54 )
    highscore_text = display.newText( gui, stats.highscore .."m", display.contentCenterX, 180, native.systemFont, 44 )

    -- MONEY
    moneyTxt = display.newText(gui, "$".. stats.money, 1024, 100, native.systemFont, 54 )

    -- hp bzw. health
    hptxt = display.newText(gui, car_hp .. " Struktur", 1024, 180, native.systemFont, 44 )

    -- speed
    speedtxt = display.newText(gui, "0 km/h", 1024, 260, native.systemFont, 44 )
end