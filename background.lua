-- BACKGROUND
background = nil

function initBackground()
    background = display.newImageRect( "img/background2.png", display.actualContentWidth, display.actualContentHeight )
    background.anchorX = 0
    background.anchorY = 0
    background.x = 0 + display.screenOriginX 
    background.y = 0 + display.screenOriginY
end