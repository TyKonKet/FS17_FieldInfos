--
-- HudLevelBar
--
-- @author  TyKonKet
-- @date 12/05/2017
HudLevelBar = {};
local HudLevelBar_mt = Class(HudLevelBar, HudProgressBar);

function HudLevelBar:new(name, overlayFilename, uvsBg, uvsMarker, bgColor, valueColor, markerSize, x, y, width, height, parent, mt)
    local self = HudProgressBar:new(name, overlayFilename, uvsBg, uvsMarker, bgColor, valueColor, markerSize, x, y, width, height, parent, mt or HudLevelBar_mt);
    self.textColor = {1, 1, 1, 1};
    self.unitTextColor = {1, 1, 1, 1};
    self.text = "???";
    self.unitText = "???";
    self.fillType = nil;
    self.icon = nil;
    return self;
end

function HudLevelBar:setTextColor(r, g, b, a)
    r = Utils.getNoNil(r, self.textColor[1]);
    g = Utils.getNoNil(g, self.textColor[2]);
    b = Utils.getNoNil(b, self.textColor[3]);
    a = Utils.getNoNil(a, self.textColor[4]);
    self.textColor = {r, g, b, a};
end

function HudLevelBar:setUnitTextColor(r, g, b, a)
    r = Utils.getNoNil(r, self.unitTextColor[1]);
    g = Utils.getNoNil(g, self.unitTextColor[2]);
    b = Utils.getNoNil(b, self.unitTextColor[3]);
    a = Utils.getNoNil(a, self.unitTextColor[4]);
    self.unitTextColor = {r, g, b, a};
end

function HudLevelBar:setText(text)
    if text ~= nil then
        self.text = text;
    end
end

function HudLevelBar:setUnitText(text)
    if text ~= nil then
        self.unitText = text;
    end
end

function HudLevelBar:setFillType(fillType)
    if fillType ~= nil and fillType ~= self.fillType then
        self.fillType = fillType;
        self.icon = g_currentMission.fillTypeOverlays[self.fillType];
    end
end

function HudLevelBar:setAll(text, unitText, fillType)
    self:setText(text);
    self:setUnitText(unitText);
    self:setFillType(fillType);
end

function HudLevelBar:render()
    if self.visible then
        setTextAlignment(RenderText.ALIGN_RIGHT);
        setTextColor(unpack(self.unitTextColor));
        setTextBold(false);
        HudLevelBar:superClass().render(self);
        local x, y = self:getRenderPosition();
        local width, height = self:getRenderDimension();
        local posX = x + width + g_currentMission.levelTextSmallOffsetX;
        width = getTextWidth(g_currentMission.levelTextSmallTextSize, self.unitText);
        renderText(posX, y + g_currentMission.levelTextSmallOffsetY, g_currentMission.levelTextSmallTextSize, self.unitText);
        posX = posX - width - g_currentMission.levelTextTextOffsetX;
        setTextColor(unpack(self.textColor));
        renderText(posX, y + g_currentMission.levelTextOffsetY, g_currentMission.levelTextTextSize, self.text);
        setTextColor(1, 1, 1, 1);
        if self.icon ~= nil and self.progressBar ~= nil then
            self.icon:setPosition(x + g_currentMission.levelIconOffsetX, y + g_currentMission.levelIconOffsetY);
            self.icon:setColor(self.progressBar.overlayValue.r, self.progressBar.overlayValue.g, self.progressBar.overlayValue.b, self.progressBar.overlayValue.a);
            self.icon:render();
        end
    end
end
