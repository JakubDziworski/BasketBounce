require "Cocos2d"
require "Cocos2dConstants"
require "VR"
require "Paths"

Effects = class("Effects")
Effects.__index = Effects

function Effects:plusPoints(layer,position,points)
    local text = ""
    if points > 0 then text = ccui.Text:create(string.format("+ %d",points),R.default_font,15) 
    else          text = ccui.Text:create(string.format("- %d",math.abs(points)),R.default_font,15) end
    local function rmvHandler() text:removeFromParent() end
    text:setPosition(position)
    text:runAction(cc.MoveBy:create(1.5,cc.p(0,100)))
    text:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.FadeOut:create(0.4)))
    text:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.CallFunc:create(rmvHandler)))
    layer:addChild(text)
end
function Effects:blink(node,speed)
    speed = speed or 0.2
    local defaultScale = node:getScale()
    node:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.6),cc.ScaleTo:create(speed,defaultScale+0.3),cc.ScaleTo:create(speed,defaultScale-0.1))))
end