require "Cocos2d"
require "Cocos2dConstants"
require "VR"
require "Level"
require "Hud"

local GameLogic = class("GameLogic",function()
    return cc.Scene:createWithPhysics()
end)

local score = 0
local shorStarted = false
local shotReleased = false
local timeHeld = 0
local maxTimeHeld = 3.0
local level = nil
local hud = nil
local barsContainer = {nil,nil}


function GameLogic.checkIfResetBall(dt) 
    if level:getCurrBall() == nil then
       return   
    end 
    if shorStarted then 
        timeHeld  = timeHeld+4*dt
        level:getArrow():setPercentage(100*timeHeld/3.0)
        level:getArrow():setPosition(cc.p(level:getCurrBall():getPositionX(),level:getCurrBall():getPositionY()))
    else 
        timeHeld = 0
    end
    if (level:getCurrBall():getPositionX() > VisibleRect:right().x  or level:getCurrBall():getPositionX() < VisibleRect:left().x ) then
        level:createNewBall()
        shotReleased = false
    end 
end
function GameLogic.create()
    level = Level:create(1)
    hud = Hud:create()
    local scene = GameLogic.new()
    scene:createHudHandlers()
    scene:getPhysicsWorld():setDebugDrawMask(cc.PhysicsWorld.DEBUGDRAW_ALL)
    scene:getPhysicsWorld():setGravity(cc.p(0,-300))
    scene:addChild(level)
    scene:addChild(hud)
    scene:init()
    return scene
end
function GameLogic:createHudHandlers()
    local function HUDBackbuttonHandler(sender,type)
        if(type ~= ccui.TouchEventType.ended) then return end
        shotReleased = false
        level:createNewBall()
    end
    hud:setRetryBtnListener(HUDBackbuttonHandler)
end
function GameLogic:init()
    local function onTouchMoved(touch, event)
        local location = touch:getLocation()
        local vector = cc.p(level:getArrow():getPositionX()-location.x,location.y-level:getArrow():getPositionY())
        local angle = math.atan2(vector.x,vector.y)*(180.0/math.pi)+90
        if(angle < 0) then angle = angle + 360 end
        level:getArrow():setRotation(-angle)
    end
    local function onTouchBegan(touch, event)
        if shotReleased == true then return end
        shorStarted = true
        return true;
    end  
    local function onTouchEnded(touch, event)
        if shotReleased == true then return end
        local location = touch:getLocation()
        shotReleased = true
        shorStarted = false
        local location = touch:getLocation()
        if(timeHeld > maxTimeHeld)then timeHeld = maxTimeHeld end
        local impuls = (1/-(0.1*timeHeld+0.25)+4)*7780000
        print(impuls,"   ",timeHeld)
        local odlX = location.x - level:getCurrBall():getPositionX()
        local odlY = location.y - level:getCurrBall():getPositionY()
        local lacznaOdleglosc =  math.abs(odlX) + math.abs(odlY)
        local ratioX = (odlX/lacznaOdleglosc)
        local ratioY = (odlY/lacznaOdleglosc)
        level:getCurrBall():getPhysicsBody():applyImpulse(cc.p(ratioX*impuls,ratioY*impuls))
        level:getArrow():runAction(cc.ProgressTo:create(0.15,0))
    end 
    local listener = cc.EventListenerTouchOneByOne:create()    
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, level)
    level:scheduleUpdateWithPriorityLua(GameLogic.checkIfResetBall,0);
end

return GameLogic
