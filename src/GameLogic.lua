require "Cocos2d"
require "Cocos2dConstants"
require "VR"
require "Level"
require "Hud"

GameLogic = class("GameLogic",function()
    return cc.Scene:createWithPhysics()
end)
GameLogic.__index = GameLogic
GameLogic.shorStarted = false
GameLogic.shotReleased = false
GameLogic.timeHeld = 0
GameLogic.maxTimeHeld = 3.0
GameLogic.level = nil
GameLogic.hud = nil
GameLogic.removedObstacles = {}
GameLogic.currLevel = nil


function GameLogic:checkIfResetBall(dt) 
    if self.level:getCurrBall() == nil then
       return   
    end 
    if self.shorStarted then 
        self.timeHeld  = self.timeHeld+4*dt
        self.level:getArrow():setPercentage(100*self.timeHeld/3.0)
        self.level:getArrow():setPosition(cc.p(self.level:getCurrBall():getPositionX(),self.level:getCurrBall():getPositionY()))
    else 
        self.timeHeld = 0
    end
    if (self.level:getCurrBall():getPositionX() > VisibleRect:right().x  or self.level:getCurrBall():getPositionX() < VisibleRect:left().x ) then
        self.level:createNewBall()
        self.shotReleased = false
    end 
end
function GameLogic.create(levelNumber)
    local scene = GameLogic.new()
    scene.currLevel = levelNumber
    scene.level = Level.create(levelNumber)
    scene.hud = Hud.create()
    scene:createHudHandlers()
    scene:getPhysicsWorld():setDebugDrawMask(cc.PhysicsWorld.DEBUGDRAW_ALL)
    scene:getPhysicsWorld():setGravity(cc.p(0,-300))
    scene:addChild(scene.level)
    scene:addChild(scene.hud)
    scene:init()
    return scene
end
function GameLogic:onWonLevel()
    local function goToNextLevel()
        cc.Director:getInstance():replaceScene(GameLogic.create(self.currLevel+1))
    end
    self.hud:levelCompleted()
    self.hud:setNextLevelBtnListener(goToNextLevel)
end
function GameLogic:resetScene()
    for k,v in pairs(self.removedObstacles) do
        print(k,v)
        table.insert(self.level:getObstacles(),v)
        v:getNode():setColor(cc.c3b(255,255,255))
    end
    self.level:createNewBall()
    self.removedObstacles = {}
end
function GameLogic:createHudHandlers()
    local function HUDBackbuttonHandler(sender,type)
        if(type ~= ccui.TouchEventType.ended) then return end
        self.shotReleased = false
        self:resetScene()
    end
    self.hud:setRetryBtnListener(HUDBackbuttonHandler)
end
function GameLogic:init()
    local function onCollided(contact)
         --print("contact started")
         local bodyB = contact:getShapeB():getBody();
         if(bodyB:isDynamic()) then return end
         bodyB:getNode():setColor(cc.c3b(0,255,0))
         for k,v in pairs(self.level:getObstacles()) do
            if v == bodyB then 
                table.remove(self.level:getObstacles(),k)
                table.insert(self.removedObstacles,v)
                self.hud:setHudText(self.level:addPointsToScoreAndGetScore(100))
                if table.getn(self.level:getObstacles()) == 0 then self:onWonLevel() end
            end
            --else print("did not found body to rmv") end
         end
    end
    local collisionListener = cc.EventListenerPhysicsContact:create()
    collisionListener:registerScriptHandler(onCollided, cc.Handler.EVENT_PHYSICS_CONTACT_POSTSOLVE)
    local function onTouchMoved(touch, event)
        local location = touch:getLocation()
        local vector = cc.p(self.level:getArrow():getPositionX()-location.x,location.y-self.level:getArrow():getPositionY())
        local angle = math.atan2(vector.x,vector.y)*(180.0/math.pi)+90
        if(angle < 0) then angle = angle + 360 end
        self.level:getArrow():setRotation(-angle)
    end
    local function onTouchBegan(touch, event)
        if self.shotReleased == true then return end
        self.shorStarted = true
        onTouchMoved(touch,event)
        return true;
    end  
    local function onTouchEnded(touch, event)
        if self.shotReleased == true then return end
        local location = touch:getLocation()
        self.shotReleased = true
        self.shorStarted = false
        local location = touch:getLocation()
        if(self.timeHeld > self.maxTimeHeld)then self.timeHeld = self.maxTimeHeld end
        local impuls = (1/-(0.1*self.timeHeld+0.25)+4)*7780000
        print(impuls,"   ",self.timeHeld)
        local odlX = location.x - self.level:getCurrBall():getPositionX()
        local odlY = location.y - self.level:getCurrBall():getPositionY()
        local lacznaOdleglosc =  math.abs(odlX) + math.abs(odlY)
        local ratioX = (odlX/lacznaOdleglosc)
        local ratioY = (odlY/lacznaOdleglosc)
        self.level:getCurrBall():getPhysicsBody():applyImpulse(cc.p(ratioX*impuls,ratioY*impuls))
        self.level:getArrow():runAction(cc.ProgressTo:create(0.15,0))
    end 
    local listener = cc.EventListenerTouchOneByOne:create()    
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.level)
    eventDispatcher:addEventListenerWithSceneGraphPriority(collisionListener, self.level)
    local function update(dt)
        self:checkIfResetBall(dt) 
    end
    self.level:scheduleUpdateWithPriorityLua(update,0);
end
