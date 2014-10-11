require "Cocos2d"
require "Cocos2dConstants"
require "VR"

Hud = class("Hud",function()
    return cc.Layer:create()
end)
Hud.__index = Hud
Hud.scoreLabel = nil
Hud.retrybtn = nil
Hud.nextLevelBtn = nil
--getters
function Hud:getScoreLabel() return self.scoreLabel end
--setters
function Hud:setHudText(txt) self.scoreLabel:setString(txt) end
function Hud:levelCompleted()
    self.retrybtn:setTouchEnabled(false)
    local youWin = cc.Label:create()
    youWin:setString("You win")
    self.nextLevelBtn = ccui.Button:create("btn.png")
    self.nextLevelBtn:setTitleText("next")
    self.nextLevelBtn:setTitleColor(cc.c3b(0,0,0))
    youWin:setSystemFontSize(45)
    youWin:setPosition(VisibleRect:right().x+youWin:getContentSize().width/2,VisibleRect:center().y+50)
    self.nextLevelBtn:setPosition(youWin:getPositionX(),youWin:getPositionY()-50)
    local action = cc.EaseBackOut:create(cc.MoveBy:create(0.3,cc.p(-(VisibleRect:right().x-VisibleRect:center().x)-youWin:getContentSize().width/2,0)))
    local action2 = cc.EaseBackOut:create(cc.MoveBy:create(0.3,cc.p(-(VisibleRect:right().x-VisibleRect:center().x)-youWin:getContentSize().width/2,0)))
    self:addChild(youWin)
    self:addChild(self.nextLevelBtn)
    youWin:runAction(action2)
    self.nextLevelBtn:runAction(action)
end
function Hud.create()
    local hud = Hud.new()
    --score label
    hud.scoreLabel = cc.Label:create()
    hud.scoreLabel:setString("0")
    hud.scoreLabel:setPosition(VisibleRect:left().x+5,VisibleRect:top().y-5)
    hud.scoreLabel:setAnchorPoint(cc.p(0,1))
    hud.scoreLabel:setSystemFontSize(45)
    hud:addChild(hud.scoreLabel,0)
    --retry button
    hud.retrybtn = ccui.Button:create("btn.png")
    hud.retrybtn:setTitleText("retry")
    hud.retrybtn:setPosition(VisibleRect:right().x-5,VisibleRect:top().y-5)
    hud.retrybtn:setAnchorPoint(cc.p(1,1))
    hud:addChild(hud.retrybtn)
    return hud
end
function Hud:setRetryBtnListener(listener)
    self.retrybtn:addTouchEventListener(listener)
end
function Hud:setNextLevelBtnListener(listener)
    self.nextLevelBtn:addTouchEventListener(listener)
end
