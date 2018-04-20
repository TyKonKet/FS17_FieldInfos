--
-- HudProgressBar
--
-- @author  TyKonKet
-- @date 11/05/2017
HudProgressBar = {};
local HudProgressBar_mt = Class(HudProgressBar, Hud);

function HudProgressBar:new(name, overlayFilename, uvsBg, uvsMarker, bgColor, valueColor, markerSize, x, y, width, height, parent, mt)
    local self = Hud:new(name, x, y, width, height, parent, mt or HudProgressBar_mt);
    self.filename = overlayFilename;
    if self.filename ~= nil then
        self.progressBar = StatusBar:new(self.filename, uvsBg, uvsMarker, bgColor, valueColor, markerSize, self.x, self.y, self.width, self.height);
    end
    return self;
end

function HudProgressBar:delete(applyToChilds)
    if self.progressBar ~= nil then
        self.progressBar:delete();
        self.progressBar = nil;
    end
    HudProgressBar:superClass().delete(self, applyToChilds);
end

function HudProgressBar:setColor(r, g, b, a, applyToChilds)
    HudProgressBar:superClass().setColor(self, r, g, b, a, applyToChilds);
    if self.progressBar ~= nil then
        self.progressBar:setColor(self.r, self.g, self.b, self.a);
    end
end

function HudProgressBar:setValue(newValue)
    if self.progressBar ~= nil then
        self.progressBar:setValue(newValue);
    end
end

function HudProgressBar:render()
    if self.visible and self.progressBar ~= nil then
        local x, y = self:getRenderPosition();
        self.progressBar:setPosition(x, y);
        self.progressBar:render();
    end
end
