require "Cocos2d"
require "Cocos2dConstants"
require "VR"
require "Paths"
require "Effects"
require "GameLogic"
require "Utils"
require "Shortcuts"
MainMenu = class("MainMenu",function() 
    MainMenu.mainLayer = nil
    MainMenu.globalLAyer = nil
    MainMenu.optionsLayer = nil
    MainMenu.levelsLayer = nil
    MainMenu.backBtn = nil
    return cc.Scene:create()
end)

function MainMenu.create()
    local scene = MainMenu.new()
    scene:addChild(scene:createGlobalLayer(),1)
    scene:addChild(scene:createMain(),0)
    scene:addChild(scene:createLevels(),0)
    return scene
end

function MainMenu:createGlobalLayer()
    MainMenu.globalLAyer = cc.Layer:create()
    local function listenerr() 
        hideLevels()
        MainMenu.backBtn:runAction(cc.EaseBackIn:create(cc.ScaleTo:create(0.3,0)))
        MainMenu.backBtn:setTouchEnabled(false)
        self:show(self.mainLayer)
    end
    MainMenu.backBtn = SC:createButton("BACK",R.backMenuButton,listenerr,MainMenu.globalLAyer)
    MainMenu.backBtn:setAnchorPoint(cc.p(0,1))
    MainMenu.backBtn:setPosition(VisibleRect:left().x+5,VisibleRect:top().y-5)
    return MainMenu.globalLAyer
end
function MainMenu:createMain()
    self.mainLayer = cc.Layer:create()
    local function handler() 
        MainMenu.backBtn:runAction(cc.Sequence:create(cc.DelayTime:create(0.6),cc.EaseBackOut:create(cc.ScaleTo:create(0.3,1))))
        MainMenu.backBtn:setTouchEnabled(true)
        showLevels()
        self:hide(self.mainLayer) 
    end 
    MainMenu.backBtn:setScale(0)
    local playBtn = SC:createButton("PLAY",R.normalnyButton,handler,self.mainLayer)
    playBtn:setPosition(VisibleRect:center())
    Effects:blink(playBtn)
    self.mainLayer:setTouchEnabled(false)
    return self.mainLayer
end
function MainMenu:createLevels()
    self.levelsLayer = cc.Layer:create()
    local scrlView = ccui.ScrollView:create()
    scrlView:setTouchEnabled(false)
    scrlView:setContentSize(cc.size(VisibleRect:width(),VisibleRect:height()))
    scrlView:setBounceEnabled(true)
    scrlView:setInnerContainerSize(cc.size(2*scrlView:getContentSize().width,scrlView:getContentSize().height)) 
    scrlView:setDirection(ccui.ScrollViewDir.horizontal)
    local btns = {}
    for i=0,15,1 do
       for j=0,2,1 do
            local btn = ccui.Button:create(R.levelButton,"","")
            local function goToLevelHandler()
                cc.Director:getInstance():replaceScene(GameLogic.create(2*i+1+j))
            end
            local btn = SC:createButton(3*i+1+j,R.levelButton,goToLevelHandler,scrlView)
            btn:setTouchEnabled(false)
            btn:setScale(0)
            table.insert(btns,btn)
            btn:setPosition(cc.p(40+i*79.5,3*VisibleRect:height()/4-VisibleRect:height()/4*j))
       end
    end 
    self.levelsLayer:addChild(scrlView)
    self.levelsLayer:setTouchEnabled(false)
    function showLevels()
        scrlView:setTouchEnabled(true)
        for k,v in pairs(btns) do
            btns[k]:setScale(0)
            btns[k]:setTouchEnabled(true)
            btns[k]:runAction(cc.Sequence:create(cc.DelayTime:create(0.4+0.06*k),cc.EaseBackOut:create(cc.ScaleTo:create(0.3,1))))
        end
    end
    function hideLevels()
        scrlView:setTouchEnabled(false)
        for k,v in pairs(btns) do
            btns[k]:setTouchEnabled(false)
            btns[k]:runAction(cc.Sequence:create(cc.DelayTime:create(0.02*k),cc.EaseBackIn:create(cc.ScaleTo:create(0.3,0))))
        end
    end
    return self.levelsLayer
end
function MainMenu:show(layer)
    layer:setPositionX(VisibleRect:right().x)
    layer:runAction(cc.Sequence:create(cc.DelayTime:create(0.6),cc.EaseBackOut:create(cc.MoveTo:create(0.7,cc.p(0,0)))))
end
function  MainMenu:hide(layer)
    layer:runAction(cc.EaseBackIn:create(cc.MoveTo:create(0.4,cc.p(-VisibleRect:right().x,0))))
end


