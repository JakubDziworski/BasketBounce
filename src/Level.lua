require "Cocos2d"
require "Cocos2dConstants"
require "VR"

local ballMaterial = cc.PhysicsMaterial(25,1.2,1),cc.p(0,0);
local basketMaterial = cc.PhysicsMaterial(25,0.3,1),cc.p(0,0);
local floorMaterial = cc.PhysicsMaterial(255,1,1),cc.p(0,0);
local currBall = nil
local arrow = nil
local defaultBallSize = nil
Level = class("Level",function()
    return cc.Layer:create()
end)
Level.__index = Level

--getters
function Level:getCurrBall() return currBall end
function Level:getArrow() return arrow end

function Level:create(levelNumber)
    local level = Level.new()
    level:createBoundingBox()
    level:createLevel(levelNumber)
    level:setUpArrow()
    return level
end

function Level:createBoundingBox()
    local floor = cc.PhysicsBody:createEdgeBox(cc.size(VisibleRect:right().x,15));
    local floorSpr = cc.Sprite:create("floor.png")
    floorSpr:setPhysicsBody(floor) 
    floorSpr:setPosition(cc.p(VisibleRect:right().x/2,0))
    self:addChild(floorSpr)
    return floorSpr
end

function Level:createLevel(levelNumber)
    if (levelNumber == 1) then
        self:createNewBall(cc.p(VisibleRect:left().x+100,VisibleRect:bottom().y+7.5+45))
        self:createObstacle(cc.size(100,15),cc.p(VisibleRect:center().x+70,VisibleRect:top().y-20),-15)
        local movingObstacle = self:createObstacle(cc.size(100,15),cc.p(VisibleRect:center().x-50,VisibleRect:top().y-25),0)
        self:makeObstacleMoveBy(movingObstacle,cc.p(50,0),1)
        self:createObstacle(cc.size(100,15),cc.p(VisibleRect:center().x-20,VisibleRect:top().y-250),15)
    end
end
function Level:createNewBall(position)
    position = position or defaultBallSize
    if(position ~= nil) then defaultBallSize = position end
    if currBall ~= nil then
        local oldBall = currBall
        oldBall:runAction(cc.FadeOut:create(1))
        local function rmvHandler(oldBall)
            oldBall:removeFromParentAndCleanup()
        end
        oldBall:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(rmvHandler)))
    end
    currBall = cc.Sprite:create("ball.png")
    local physbody = cc.PhysicsBody:createCircle(currBall:getContentSize().width/2,ballMaterial)
    currBall:setPhysicsBody(physbody)
    currBall:setPosition(position)
    self:addChild(currBall)
end
function Level:createObstacle(size,position,rotation)
    local obstacle = cc.Sprite:create("squareObsticle.png",size);
    local squareShape = cc.PhysicsShapeBox:create(size,floorMaterial)
    --local leftCircleShape = cc.PhysicsShapeCircle:create(size.height/2,floorMaterial,cc.p(size.width/2.0,0))
    --local rightCircleShape = cc.PhysicsShapeCircle:create(size.height/2,floorMaterial,cc.p(-size.width/2.0,0))
    local body = cc.PhysicsBody:create();
    body:addShape(squareShape)
    --  body:addShape(leftCircleShape)
    -- body:addShape(rightCircleShape)
    obstacle:setPhysicsBody(body)
    obstacle:setPosition(position)
    obstacle:setRotation(rotation)
    body:setRotationEnable(true) 
    obstacle:getPhysicsBody():setDynamic(false)
    self:addChild(obstacle)
    return obstacle
end

function Level:setUpArrow()
    arrow = cc.ProgressTimer:create(cc.Sprite:create("arrow.png"))
    arrow:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    arrow:setMidpoint(cc.p(0,0))
    arrow:setBarChangeRate(cc.p(1,0))
    arrow:setPercentage(60)
    arrow:setAnchorPoint(-1,0.5)
    self:addChild(arrow)
end
function Level:makeObstacleMoveBy(obstacle,point1,speed)
    local moveToPoint1 = cc.MoveBy:create(speed/2.0,point1)
    local sequnce = cc.Sequence:create(moveToPoint1,moveToPoint1:reverse())
    obstacle:runAction(cc.RepeatForever:create(cc.Sequence:create(moveToPoint1, moveToPoint1:reverse())));
end
function Level:makeObstacleRotateBy(obstacle,speed)
    local rotate = cc.RotateBy:create(speed,360)
    obstacle:runAction(cc.RepeatForever:create(rotate)); 
end


