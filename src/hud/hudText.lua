--
-- HudText
--
-- @author  TyKonKet
-- @date 06/04/2017
HudText = {};
local HudText_mt = Class(HudText, Hud);

function HudText:new(name, text, size, x, y, bold, parent, mt)
    local self = Hud:new(name, x, y, 0, 0, parent, mt or HudText_mt);
    self.text = text;
    self:setSize(size);
    self.bold = bold;
    self.shadow = {};
    self.shadow.visible = false;
    self.shadow.pX = 0;
    self.shadow.x = 0;
    self.shadow.pY = 0;
    self.shadow.y = 0;
    self.shadow.r = 0;
    self.shadow.g = 0;
    self.shadow.b = 0;
    self.shadow.a = 1;
    return self;
end

function HudText:render()
    if self.visible then
        local x, y = self:getRenderPosition();
        setTextBold(self.bold);
        if self.shadow.visible then
            setTextColor(self.shadow.r, self.shadow.g, self.shadow.b, self.shadow.a);
            renderText(x + self.shadow.x, y - self.shadow.y, self.size, self.text);
        end
        setTextColor(self.r, self.g, self.b, self.a);
        renderText(x, y, self.size, self.text);
        setTextBold(false);
        setTextColor(1, 1, 1, 1);
    end
end

function HudText:setText(text)
    self.text = text;
    self.width = getTextWidth(self.size, self.text);
    self.height = getTextHeight(self.size, self.text);
    self:realign();
end

function HudText:setSize(size)
    _, self.size = getNormalizedScreenValues(0, size * self.uiScale);
    self:setText(self.text);
end

function HudText:realign()
    if self.alignmentVertical == Hud.ALIGNS_VERTICAL_TOP then
        self.offsetY = -self.height;
    elseif self.alignmentVertical == Hud.ALIGNS_VERTICAL_MIDDLE then
        self.offsetY = -self.height * 0.5;
    else
        self.offsetY = 0;
    end
    
    if self.alignmentHorizontal == Hud.ALIGNS_HORIZONTAL_RIGHT then
        self.offsetX = -self.width;
    elseif self.alignmentHorizontal == Hud.ALIGNS_HORIZONTAL_CENTER then
        self.offsetX = -self.width * 0.5;
    else
        self.offsetX = 0;
    end
end

function Hud:setShadow(visible, x, y, r, g, b, a)
    self.shadow.visible = visible;
    self.shadow.pX = Utils.getNoNil(x, self.shadow.pX);
    self.shadow.pY = Utils.getNoNil(y, self.shadow.pY);
    self.shadow.x, self.shadow.y = getNormalizedScreenValues(self.shadow.pX * self.uiScale, self.shadow.pY * self.uiScale);
    if type(r) == "table" then
        self.shadow.r = Utils.getNoNil(r[1], self.shadow.r);
        self.shadow.g = Utils.getNoNil(r[2], self.shadow.g);
        self.shadow.b = Utils.getNoNil(r[3], self.shadow.b);
        self.shadow.a = Utils.getNoNil(r[4], self.shadow.a);
    else
        self.shadow.r = Utils.getNoNil(r, self.shadow.r);
        self.shadow.g = Utils.getNoNil(g, self.shadow.g);
        self.shadow.b = Utils.getNoNil(b, self.shadow.b);
        self.shadow.a = Utils.getNoNil(a, self.shadow.a);
    end
end
