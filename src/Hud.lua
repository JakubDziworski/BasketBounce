require "Cocos2d"
require "Cocos2dConstants"
require "VR"

Hud = class("Hud",function()
    Hud.__index = Hud
    Hud.scoreLabel = nil
    Hud.retrybtn = nil
    Hud.nextLevelBtn = nil
    Hud.restartListener= nil
    Hud.scoreLine = nil
    return cc.Layer:create()
end)
--getters
function Hud:getScoreLabel() return self.scoreLabel end
--setters
function Hud:setScoreText(txt,maxScore)
    self.scoreLabel:setString(txt) 
    if txt == maxScore then self.scoreLine:runAction(cc.TintTo:create(0.7,239,172,31))
    elseif txt >= maxScore/2 then self.scoreLine:runAction(cc.TintTo:create(0.7,200,200,200))
    else self.scoreLine:runAction(cc.TintTo:create(0.7,190,160,69)) end
    self.scoreLine:runAction(cc.ProgressTo:create(0.7,100*txt/maxScore))
end
function Hud:levelCompleted(score,maxScore)
    local gameOverNode = cc.Node:create()
    local delayTime = 0.5
    local posY = VisibleRect:center().y+50
    self.retrybtn:setTouchEnabled(false)
    local youWin = cc.Label:create()
    youWin:setString("Level Completed!")
    youWin:setSystemFontSize(35)
    youWin:setPosition(VisibleRect:right().x+youWin:getContentSize().width/2,posY)
    local action2 = cc.Sequence:create(cc.DelayTime:create(delayTime),cc.EaseBackOut:create(cc.MoveBy:create(0.3,cc.p(-(VisibleRect:right().x-VisibleRect:center().x)-youWin:getContentSize().width/2,0))))
    youWin:runAction(action2)
    gameOverNode:addChild(youWin)
    --gwiazdki
    posY = posY - 50
    delayTime = delayTime +1.2
    local gwiazdki = SC:calculateStars(score,maxScore)
    local starContainer = cc.Node:create()
    local starWidth = cc.Sprite:create(R.star):getContentSize().width
    starContainer:setContentSize(cc.size(gwiazdki*starWidth,1))
    starContainer:setPosition(VisibleRect:center().x,posY)
    gameOverNode:addChild(starContainer)
    for k=-1,gwiazdki-2,1 do
        local gwiazdka = cc.Sprite:create(R.star)
        gwiazdka:setScale(18)
        gwiazdka:setVisible(false)
        local pokaz = cc.CallFunc:create(function () gwiazdka:setVisible(true) end)
        gwiazdka:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime+k*0.5),pokaz,cc.ScaleTo:create(0.3,1)))
        gwiazdka:setPosition(cc.p(k*starWidth,0))
        starContainer:addChild(gwiazdka)
    end
    --nextLevel Bttn
    posY = posY - 50
    delayTime = delayTime + 0.3+gwiazdki*0.3
    self.nextLevelBtn = SC:createButton("next",R.normalnyButton,nil,gameOverNode)
    self.nextLevelBtn:setPosition(youWin:getPositionX(),posY)
    local action = cc.Sequence:create(cc.DelayTime:create(delayTime),cc.EaseBackOut:create(cc.MoveBy:create(0.3,cc.p(-(VisibleRect:right().x-VisibleRect:center().x)-youWin:getContentSize().width/2,0))))
    self.nextLevelBtn:runAction(action)
    --powtorz--
    posY = posY - 50
    delayTime = delayTime + 0.25
    local retryBtnEnd = SC:createButton("RETRY",R.rertyButton,self.restartListener,gameOverNode)
    retryBtnEnd:setPosition(cc.p(self.nextLevelBtn:getPositionX(),posY))
    local action3 = cc.Sequence:create(cc.DelayTime:create(delayTime),cc.EaseBackOut:create(cc.MoveBy:create(0.3,cc.p(-(VisibleRect:right().x-VisibleRect:center().x)-youWin:getContentSize().width/2,0))))
    retryBtnEnd:runAction(action3)
    --multi Res correction
    if cc.rectGetMinY(retryBtnEnd:getBoundingBox()) < VisibleRect:bottom().y then
        gameOverNode:setPositionY(gameOverNode:getPositionY() + VisibleRect:bottom().y -cc.rectGetMinY(retryBtnEnd:getBoundingBox()))
    end
    self:addChild(gameOverNode)
end
function Hud.create()
    local hud = Hud.new()
    --score label
    hud.scoreLabel = cc.Label:create()
    hud.scoreLabel:setString("0")
    hud.scoreLabel:setPosition(VisibleRect:left().x+5,VisibleRect:top().y-5)
    hud.scoreLabel:setAnchorPoint(cc.p(0,1))
    hud.scoreLabel:setSystemFontSize(25)
    hud:addChild(hud.scoreLabel,0)
    --retry button
    hud.retrybtn = SC:createButton("RETRY",R.rertyButton,hud.restartListener,hud)
    hud.retrybtn:setPosition(VisibleRect:rightTop())
    hud.retrybtn:setAnchorPoint(cc.p(1,1))
    --go home button
    local goHomeBtn = SC:createButton("MENU",R.homeButton,function () cc.Director:getInstance():replaceScene(MainMenu.create()) end,hud)
    goHomeBtn:setPosition(VisibleRect:leftTop())
    goHomeBtn:setAnchorPoint(cc.p(0,1))
    --scoreLine
    local frame = cc.Sprite:create(R.scoreLineFrame)
    local scaleX = VisibleRect:width()/frame:getContentSize().width/2
    local scaleY = 4
    frame:setScale(scaleX,scaleY)
    frame:setAnchorPoint(0.5,1)
    frame:setPosition(VisibleRect:top())
    hud:addChild(frame)
    hud.scoreLine = cc.ProgressTimer:create(cc.Sprite:create(R.scoreLine))
    hud.scoreLine:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    hud.scoreLine:setMidpoint(cc.p(0,0))
    hud.scoreLine:setBarChangeRate(cc.p(1,0))
    hud.scoreLine:setPercentage(0)
    hud.scoreLine:setAnchorPoint(0,0)
    hud.scoreLine:setColor(cc.c3b(255,0,0))
    frame:addChild(hud.scoreLine,-1)
    local linebx = frame:getBoundingBox()
    local startwidth = cc.Sprite:create(R.star):getContentSize().width
    for i=0,2,1 do
        local starsContainer = cc.Node:create()
        starsContainer:setContentSize(cc.size(startwidth*i,1))
        starsContainer:setAnchorPoint(cc.p(0.5,0.5))
        starsContainer:setPosition(cc.p(cc.rectGetMinX(linebx)+i*(cc.rectGetMaxX(linebx)-cc.rectGetMinX(linebx))/2,VisibleRect:top().y-8))
        for j=i,0,-1 do
             local star = cc.Sprite:create(R.star)
             star:setPosition(cc.p(j*startwidth,0))
             starsContainer:addChild(star)
        end
        starsContainer:setScale(0.2)
        hud:addChild(starsContainer)
    end
    return hud
end
function Hud:setRetryBtnListener(listener)
    self.retrybtn:addTouchEventListener(listener)
end
function Hud:setRestartEndBtnListneer(listener)
    self.restartListener = listener
end
function Hud:setNextLevelBtnListener(listener)
    self.nextLevelBtn:addTouchEventListener(listener)
end
