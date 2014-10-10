require "Cocos2d"
require "Cocos2dConstants"
require "VR"

local basketTag = 1
local scoreLabelTag = 1
local score = 0
local shorStarted = false
local shotReleased = false
local ballMaterial = cc.PhysicsMaterial(25,1.2,1),cc.p(0,0);
local basketMaterial = cc.PhysicsMaterial(25,0.3,1),cc.p(0,0);
local floorMaterial = cc.PhysicsMaterial(255,1,1),cc.p(0,0);
local scoreLabel = cc.Label:create();
local currBall = nil;
local gameLayer = cc.Layer:create();
local hud = cc.Layer:create();
local timeHeld = 0
local barsContainer = {nil,nil}
local arrow = cc.ProgressTimer:create(cc.Sprite:create("arrow.png"));

local GameScene = class("GameScene",function()
    return cc.Scene:createWithPhysics()
end)

function GameScene.checkIfResetBall(dt)
    if currBall == nil then
       return   
    end 
    if shorStarted then 
        timeHeld  = timeHeld+2*dt
        arrow:setPercentage(100*timeHeld/3.0)
    else 
        timeHeld = 0
    end
    if table.getn(barsContainer) < timeHeld then
        local bar = cc.Sprite:create("btn.png")
        bar:setPosition(cc.p(VisibleRect:left().x+timeHeld*bar:getContentSize().width+100,VisibleRect:top().y))
        bar:setAnchorPoint(1,1)
        gameLayer:addChild(bar)
        table.insert(barsContainer,bar)
    elseif table.getn(barsContainer) > 0 and shotReleased == true then 
        for val,value in pairs(barsContainer) do
            barsContainer[val]:removeFromParent()
        end 
        barsContainer = {nil,nil}
    end
    if (currBall:getPositionX() > VisibleRect:right().x  or currBall:getPositionX() < VisibleRect:left().x ) then
        GameScene:createNewBall()
        shotReleased = false
    end
    local basketRect = gameLayer:getChildByTag(basketTag):getBoundingBox()
    local ballRect = currBall:getBoundingBox();
    if(cc.rectContainsPoint(basketRect,cc.p(cc.rectGetMaxX(ballRect),cc.rectGetMaxY(ballRect)))
        and cc.rectContainsPoint(basketRect,cc.p(cc.rectGetMinX(ballRect),cc.rectGetMinY(ballRect)))
        and shotReleased == true) then
        score=score+1
        shotReleased = false
        hud:getChildByTag(scoreLabelTag):setString(score)
    end
end
function GameScene.create()
    local scene = GameScene.new()
    scene:getPhysicsWorld():setDebugDrawMask(cc.PhysicsWorld.DEBUGDRAW_ALL)
    scene:getPhysicsWorld():setGravity(cc.p(0,-300))
    GameScene:createGameView()
    scene:init()
    scene:addChild(scene:createBg())
    scene:addChild(scene:createHud())
    scene:addChild(gameLayer)
    return scene
end
function GameScene:init()
    local function onTouchMoved(touch, event)
        local location = touch:getLocation()
        local vector = cc.p(arrow:getPositionX()-location.x,location.y-arrow:getPositionY())
        local angle = math.atan2(vector.x,vector.y)*(180.0/math.pi)+90
        if(angle < 0) then angle = angle + 360 end
        arrow:setRotation(-angle)
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
        local impuls = (1/-(0.1*timeHeld+0.25)+4)*7780000
        print(impuls,"   ",timeHeld)
        local odlX = location.x - currBall:getPositionX()
        local odlY = location.y - currBall:getPositionY()
        local lacznaOdleglosc =  math.abs(odlX) + math.abs(odlY)
        local ratioX = (odlX/lacznaOdleglosc)
        local ratioY = (odlY/lacznaOdleglosc)
        currBall:getPhysicsBody():applyImpulse(cc.p(ratioX*impuls,ratioY*impuls))
        arrow:runAction(cc.ProgressTo:create(0.15,0))
    end 
    local listener = cc.EventListenerTouchOneByOne:create()    
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    local eventDispatcher = gameLayer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, gameLayer)
end

function GameScene:createBg()
    return cc.Layer:create()
end

function GameScene:createHud()
    hud = cc.Layer:create()
    --score
    scoreLabel:setString(0)
    scoreLabel:setPosition(VisibleRect:left().x+5,VisibleRect:top().y-5)
    scoreLabel:setAnchorPoint(cc.p(0,1))
    scoreLabel:setSystemFontSize(45)
    hud:addChild(scoreLabel,0,scoreLabelTag)
    --retry
    function backbuttonHandler(sender,type)
        if(type ~= ccui.TouchEventType.ended) then return end
        shotReleased = false
        GameScene:createNewBall()
    end
    local retrybtn = ccui.Button:create("btn.png")
    retrybtn:setTitleText("retry")
    retrybtn:addTouchEventListener(backbuttonHandler)
    retrybtn:setPosition(VisibleRect:right().x-5,VisibleRect:top().y-5)
    retrybtn:setAnchorPoint(cc.p(1,1))
    hud:addChild(retrybtn)
    return hud
end
function GameScene:createNewBall()
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
    currBall:setPosition(cc.p(VisibleRect:left().x+100,VisibleRect:bottom().y+7.5+currBall:getContentSize().height/2))
    arrow:setPosition(cc.p(currBall:getPositionX(),currBall:getPositionY()+34))
    gameLayer:addChild(currBall)  
end
function GameScene:createObstacle(size,position,rotation)
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
    gameLayer:addChild(obstacle)
    return obstacle
end
function GameScene:makeObstacleMoveBy(obstacle,point1,speed)
    local moveToPoint1 = cc.MoveBy:create(speed/2.0,point1)
    local sequnce = cc.Sequence:create(moveToPoint1,moveToPoint1:reverse())
    obstacle:runAction(cc.RepeatForever:create(cc.Sequence:create(moveToPoint1, moveToPoint1:reverse())));
end
function GameScene:makeObstacleRotateBy(obstacle,speed)
    local rotate = cc.RotateBy:create(speed,360)
    obstacle:runAction(cc.RepeatForever:create(rotate)); 
end
function GameScene:createGameView()
    gameLayer = cc.Layer:create()
    --basket
    local shape1 = cc.PhysicsShapeEdgeBox:create(cc.size(10,45),basketMaterial,1,cc.p(-35,0))
    local shape2 = cc.PhysicsShapeEdgeBox:create(cc.size(10,45),basketMaterial,1,cc.p(35,0))
    local shape3= cc.PhysicsShapeEdgeBox:create(cc.size(10,90),basketMaterial,1,cc.p(45,45))
    local shape4= cc.PhysicsShapeEdgeBox:create(cc.size(80,10),basketMaterial,1,cc.p(0,-18))
    local basketPhysBody = cc.PhysicsBody:create();
    basketPhysBody:addShape(shape2)
    basketPhysBody:addShape(shape1)
    basketPhysBody:addShape(shape3)
    basketPhysBody:addShape(shape4)
    basketPhysBody:setDynamic(false)
    local basket = cc.Sprite:create("basket.png")
    basket:setPhysicsBody(basketPhysBody)
    basket:setPosition(VisibleRect:right().x-basket:getContentSize().width,VisibleRect:center().y)
    --bounding box
    local floor = cc.PhysicsBody:createEdgeBox(cc.size(VisibleRect:right().x,15));
    local floorSpr = cc.Sprite:create("floor.png")
    floorSpr:setPhysicsBody(floor) 
    floorSpr:setPosition(cc.p(VisibleRect:right().x/2,0))
    gameLayer:addChild(floorSpr)
    gameLayer:addChild(basket,0,basketTag)
    GameScene:createNewBall()
    gameLayer:scheduleUpdateWithPriorityLua(GameScene.checkIfResetBall,0);
    --progress timer
    arrow:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    arrow:setMidpoint(cc.p(0,0))
    arrow:setBarChangeRate(cc.p(1,0))
    arrow:setPercentage(60)
    arrow:setAnchorPoint(0,0.5)
    gameLayer:addChild(arrow)
    --additional
    GameScene:createObstacle(cc.size(100,15),cc.p(VisibleRect:center().x+70,VisibleRect:top().y-20),-15)
    local movingObstacle = GameScene:createObstacle(cc.size(100,15),cc.p(VisibleRect:center().x-50,VisibleRect:top().y-25),0)
    GameScene:makeObstacleMoveBy(movingObstacle,cc.p(50,0),1)
    GameScene:createObstacle(cc.size(100,15),cc.p(VisibleRect:center().x-20,VisibleRect:top().y-250),15)
end

return GameScene
