--
-- HudControl
--
-- @author  TyKonKet
-- @date 05/12/2017
HudControl = {};
local HudControl_mt = Class(HudControl, Hud);

function HudControl:new(name, x, y, width, height, parent, mt)
    local self = Hud:new(name, x, y, width, height, parent, mt or HudControl_mt);
    self.huds = {};
    return self;
end

function HudControl:addHud(hud)
    HudManager:removeHudWithKey(hud.key);
    hud.parent = self;
    table.insert(self.huds, hud);
end

function HudControl:delete(applyToChilds)
    for _, h in pairs(self.huds) do
        h:delete();
    end
    HudControl:superClass().delete(self, applyToChilds);
end

function HudControl:keyEvent(unicode, sym, modifier, isDown)
    HudControl:superClass().keyEvent(self, unicode, sym, modifier, isDown);
    for _, h in pairs(self.huds) do
        h:keyEvent(unicode, sym, modifier, isDown);
    end
end

function HudControl:mouseEvent(posX, posY, isDown, isUp, button)
    HudControl:superClass().mouseEvent(self, posX, posY, isDown, isUp, button);
    for _, h in pairs(self.huds) do
        h:mouseEvent(posX, posY, isDown, isUp, button);
    end
end

function HudControl:update(dt)
    HudControl:superClass().update(self, dt);
    for _, h in pairs(self.huds) do
        h:update(dt);
    end
end

function HudControl:render()
    HudControl:superClass().render(self);
    for _, h in pairs(self.huds) do
        h:render();
    end
end

function HudControl:setIsVisible(visible, applyToChilds)
    for _, h in pairs(self.huds) do
        h:setIsVisible(visible);
    end
    HudControl:superClass().setIsVisible(self, visible, applyToChilds);
end

function HudControl:resetDimensions(applyToChilds)
    for _, h in pairs(self.huds) do
        h:resetDimensions();
    end
    HudControl:superClass().resetDimensions(self);
end
