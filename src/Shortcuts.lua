require "Cocos2d"
require "Cocos2dConstants"
require "VR"

SC = class("SC")
SC.__index = SC

function SC:createButton(text,img,listener,parent)
    local btn = ccui.Button:create(img,"","")
    btn:setTitleText(text)
    btn:setTitleColor(cc.c3b(0,0,0))
    btn:setTitleFontName(R.default_font)
    SC:addButtnListener(listener,btn)
    parent:addChild(btn)
    return btn
end

function SC:addButtnListener(listener,btn)
    local function handler(ref,type)
        if type ~= ccui.TouchEventType.ended then return end
        listener()
    end
    btn:addTouchEventListener(handler)
end
function SC:calculateStars(score,maxScore)
    if score == maxScore then return 3
    elseif score >= maxScore/2 then return 2
    else return 1 end
end
function SC:calculateStarsbyPercent(percent)
    if percent == 100 then return 3
    elseif percent >= 50 then return 2
    else return 1 end
end