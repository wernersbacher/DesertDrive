
function noProp(e)
	return true
end

goverBack = nil
goverLogo = nil
govertuningBtn = nil
govertryagain = nil


govertryagain = display.newImageRect(gameover, "img/gui/repeatw.png", 150, 150 )
govertryagain.x = display.contentCenterX -40 - 75
govertryagain.y = display.contentCenterY

	
govertuningBtn = display.newImageRect(gameover, "img/gui/tuningw.png", 150, 150 )
govertuningBtn.x = display.contentCenterX +40 +75
govertuningBtn.y = display.contentCenterY

function initGameoverButtons()
	goverBack = display.newRect(gameover, 0, 0, display.actualContentWidth, display.actualContentWidth )
	goverBack.anchorX = 0
	goverBack.anchorY = 0
	goverBack.x = 0 + display.screenOriginX 
	goverBack.y = 0 + display.screenOriginY
	goverBack.alpha = 0.5
	goverBack:setFillColor( black )
	goverBack:addEventListener("touch", noProp)

	goverLogo = display.newImageRect(gameover, "img/gameover.png", 545*2, 50*2)
	goverLogo.x = display.contentCenterX
	goverLogo.y = 200

	govertryagain = display.newImageRect(gameover, "img/gui/repeatw.png", 150, 150 )
	govertryagain.x = display.contentCenterX -40 - 75
	govertryagain.y = display.contentCenterY
		
	govertuningBtn = display.newImageRect(gameover, "img/gui/tuningw.png", 150, 150 )
	govertuningBtn.x = display.contentCenterX +40 +75
	govertuningBtn.y = display.contentCenterY
end