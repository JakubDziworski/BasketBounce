require "Cocos2d"
require "Cocos2dConstants"
require "VR"




Level = class("Level",function()
    return cc.Layer:create()
end)
Level.__index = Level
ballMaterial = cc.PhysicsMaterial(25,1,1),cc.p(0,0);
basketMaterial = cc.PhysicsMaterial(25,0.3,1),cc.p(0,0);
floorMaterial = cc.PhysicsMaterial(255,1,1),cc.p(0,0);
Level.currBall = nil
Level.arrow = nil
Level.obstacles = {nil,nil}
Level.defaultBallSize = nil
Level.score = 0
--getters
function Level:getCurrBall() return self.currBall end
function Level:getArrow() return self.arrow end
function Level:getObstacles() return self.obstacles end
--setters
function Level:addPointsToScoreAndGetScore(pointz) 
    self.score = self.score+pointz
    return self.score
end 
function Level.create(levelNumber)
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
    --*****************LEVEL 1********************--
    if (levelNumber == 1) then
        self:createNewBall(cc.p(VisibleRect:left().x+100,VisibleRect:bottom().y+7.5+45))
        local movingObstacle = self:createObstacle(cc.size(100,15),cc.p(VisibleRect:center().x+110,VisibleRect:top().y-55),35)
        local movingObstacle2 = self:createObstacle(cc.size(100,15),cc.p(VisibleRect:center().x-110,VisibleRect:top().y-55),-35)
        self:makeObstacleMoveBy(movingObstacle,cc.p(-50,0),1,0)
        self:createObstacle(cc.size(100,15),cc.p(VisibleRect:center().x,VisibleRect:top().y-280),0)
        self:makeObstacleMoveBy(movingObstacle2,cc.p(50,0),1)
    elseif (levelNumber == 2) then
        self:createNewBall(cc.p(VisibleRect:left().x+100,VisibleRect:bottom().y+7.5+45))
        local movingObstacle = self:createObstacle(cc.size(100,15),cc.p(VisibleRect:center().x+110,VisibleRect:top().y-55),0)
        local movingObstacle2 = self:createObstacle(cc.size(100,15),cc.p(VisibleRect:center().x-110,VisibleRect:top().y-55),0)
        self:makeObstacleMoveBy(movingObstacle,cc.p(-50,0),1,0)
        self:createObstacle(cc.size(100,15),cc.p(VisibleRect:center().x,VisibleRect:top().y-280),0)
        self:makeObstacleMoveBy(movingObstacle2,cc.p(50,0),1)
    end
end
function Level:createNewBall(position)
    position = position or self.obstacles
    if(position ~= nil) then self.obstacles = position end
    if self.currBall ~= nil then
        local oldBall = self.currBall
        --oldBall:runAction(cc.FadeOut:create(1))
        local function rmvHandler(oldBall)
            oldBall:removeFromParentAndCleanup()
        end
        oldBall:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(rmvHandler)))
    end
    self.currBall = cc.Sprite:create("ball.png")
    local physbody = cc.PhysicsBody:createCircle(self.currBall:getContentSize().width/2,ballMaterial)
    physbody:setContactTestBitmask(1)
    self.currBall:setPhysicsBody(physbody)
    self.currBall:setPosition(position)
    self:addChild(self.currBall)
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
    body:setContactTestBitmask(1)
    obstacle:setRotation(rotation)
    body:setRotationEnable(true) 
    obstacle:getPhysicsBody():setDynamic(false)
    self:addChild(obstacle)
    table.insert(self.obstacles,body)
    return obstacle
end

function Level:setUpArrow()
    self.arrow = cc.ProgressTimer:create(cc.Sprite:create("arrow.png"))
    self.arrow:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self.arrow:setMidpoint(cc.p(0,0))
    self.arrow:setBarChangeRate(cc.p(1,0))
    self.arrow:setPercentage(0)
    self.arrow:setAnchorPoint(-1,0.5)
    self:addChild(self.arrow)
end
function Level:makeObstacleMoveBy(obstacle,point1,speed,delay)
    delay = delay or 0
    local del = cc.DelayTime:create(delay)
    --local sequnce = cc.Sequence:create(moveToPoint1,moveToPoint1:reverse()) 
    local function dosth()  
        local moveToPoint1 = cc.MoveBy:create(speed/2.0,point1)
        obstacle:runAction(cc.RepeatForever:create(cc.Sequence:create(moveToPoint1,moveToPoint1:reverse())))
    end
    obstacle:runAction(cc.Sequence:create(del,cc.CallFunc:create(dosth)));
end
function Level:makeObstacleRotateBy(obstacle,speed)
    local rotate = cc.RotateBy:create(speed,360)
    obstacle:runAction(cc.RepeatForever:create(rotate)); 
end


