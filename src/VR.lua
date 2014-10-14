require "extern"
require "Cocos2d"

VisibleRect = class("VisibleRect")
VisibleRect.__index = VisibleRect


VisibleRect.s_visibleRect = cc.rect(0,0,0,0)

function VisibleRect:lazyInit()
    local origin = cc.Director:getInstance():getVisibleOrigin()
    local size = cc.Director:getInstance():getVisibleSize()
    self.s_visibleRect = cc.rect(origin.x,origin.y,size.width,size.height)
end

function VisibleRect:getVisibleRect()
    self:lazyInit()
    return cc.rect(self.s_visibleRect.x, self.s_visibleRect.y, self.s_visibleRect.width, self.s_visibleRect.height)
end

function VisibleRect:left()
    self:lazyInit()
    return cc.p(self.s_visibleRect.x, self.s_visibleRect.y+self.s_visibleRect.height/2)
end

function VisibleRect:right()
    self:lazyInit()
    return cc.p(self.s_visibleRect.x+self.s_visibleRect.width, self.s_visibleRect.y+self.s_visibleRect.height/2)
end

function VisibleRect:top()
    self:lazyInit()
    return cc.p(self.s_visibleRect.x+self.s_visibleRect.width/2, self.s_visibleRect.y+self.s_visibleRect.height)
end

function VisibleRect:bottom()
    self:lazyInit()
    return cc.p(self.s_visibleRect.x+self.s_visibleRect.width/2, self.s_visibleRect.y)
end

function VisibleRect:center()
    self:lazyInit()
    return cc.p(self.s_visibleRect.x+self.s_visibleRect.width/2, self.s_visibleRect.y+self.s_visibleRect.height/2)
end

function VisibleRect:leftTop()
    self:lazyInit()
    return cc.p(self.s_visibleRect.x, self.s_visibleRect.y+self.s_visibleRect.height)
end

function VisibleRect:rightTop()
    self:lazyInit()
    return cc.p(self.s_visibleRect.x+self.s_visibleRect.width, self.s_visibleRect.y+self.s_visibleRect.height)
end

function VisibleRect:leftBottom()
    self:lazyInit()
    return cc.p(self.s_visibleRect.x,self.s_visibleRect.y)
end

function VisibleRect:rightBottom()
    self:lazyInit()
    return cc.p(self.s_visibleRect.x+self.s_visibleRect.width, self.s_visibleRect.y)
end
function VisibleRect:height()
    self:lazyInit()
    return VisibleRect:top().y - VisibleRect:bottom().y
end
function VisibleRect:width()
    self:lazyInit()
    return VisibleRect:right().x - VisibleRect:left().x
end