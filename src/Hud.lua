require "Cocos2d"
require "Cocos2dConstants"
require "VR"

local scoreLabel = nil;
local retrybtn = nil


Hud = class("Hud",function()
    return cc.Layer:create()
end)
Hud.__index = Hud
--getters
function Hud:getScoreLabel() return scoreLabel end

function Hud:create()
    local hud = Hud.new()
    --score label
    scoreLabel = cc.Label:create()
    scoreLabel:setString("0")
    scoreLabel:setPosition(VisibleRect:left().x+5,VisibleRect:top().y-5)
    scoreLabel:setAnchorPoint(cc.p(0,1))
    scoreLabel:setSystemFontSize(45)
    hud:addChild(scoreLabel,0)
    --retry button
    retrybtn = ccui.Button:create("btn.png")
    retrybtn:setTitleText("retry")
    retrybtn:setPosition(VisibleRect:right().x-5,VisibleRect:top().y-5)
    retrybtn:setAnchorPoint(cc.p(1,1))
    hud:addChild(retrybtn)
    return hud
end
function Hud:setRetryBtnListener(listener)
    retrybtn:addTouchEventListener(listener)
end
