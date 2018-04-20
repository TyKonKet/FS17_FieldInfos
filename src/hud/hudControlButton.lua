--
-- HudControlButton
--
-- @author  TyKonKet
-- @date 05/12/2017
HudControlButton = {};
local HudControlButton_mt = Class(HudControlButton, HudControl);

HudControlButton.STATE_NORMAL = 1;
HudControlButton.STATE_HOVER = 2;
HudControlButton.STATE_CLICK = 3;

function HudControlButton:new(name, x, y, width, height, text, size, parent, mt)
    local self = HudControl:new(name, x, y, width, height, parent, mt or HudControlButton_mt);
    self.bg = HudImage:new(name .. "Bg", g_baseUIFilename, 0, 0, width, height);
    self.text = HudText:new(name .. "Text", text, size, 0.5, 0.55, true);
    self:addHud(self.bg);
    self:addHud(self.text);
    self.bg:setUVs(getNormalizedUVs({10, 1010, 4, 4}));
    self.text:setAlignment(Hud.ALIGNS_VERTICAL_MIDDLE, Hud.ALIGNS_HORIZONTAL_CENTER);
    self.bg:addCallback(self, self.onEnter, Hud.CALLBACKS_MOUSE_ENTER);
    self.bg:addCallback(self, self.onLeave, Hud.CALLBACKS_MOUSE_LEAVE);
    self.bg:addCallback(self, self.onDown, Hud.CALLBACKS_MOUSE_DOWN);
    self.bg:addCallback(self, self.onUp, Hud.CALLBACKS_MOUSE_UP);
    self.bg:addCallback(self, self.onClick, Hud.CALLBACKS_MOUSE_CLICK);
    self.stateSettings = {};
    for i = 1, 3 do
        self.stateSettings[i] = {};
        self.stateSettings[i].text = {};
        self.stateSettings[i].image = {};
        self.stateSettings[i].text.size = size;
        self.stateSettings[i].text.color = {1, 1, 1, 1};
        self.stateSettings[i].image.color = {0.2122, 0.5271, 0.0307, 1};
    end
    self.stateSettings[1].image.color = {0.0075, 0.0075, 0.0075, 1};
    self.bg:setColor(self.stateSettings[1].image.color);
    self.text:setSize(self.stateSettings[1].text.size);
    self.text:setColor(self.stateSettings[1].text.color);
    return self;
end

function HudControlButton:onEnter()
    self.bg:setColor(self.stateSettings[2].image.color);
    self.text:setSize(self.stateSettings[2].text.size);
    self.text:setColor(self.stateSettings[2].text.color);
    self.bg.isHover = true;
end

function HudControlButton:onLeave()
    self.bg:setColor(self.stateSettings[1].image.color);
    self.text:setSize(self.stateSettings[1].text.size);
    self.text:setColor(self.stateSettings[1].text.color);
    self.bg.isHover = false;
end

function HudControlButton:onDown()
    self.bg:setColor(self.stateSettings[3].image.color);
    self.text:setSize(self.stateSettings[3].text.size);
    self.text:setColor(self.stateSettings[3].text.color);
end

function HudControlButton:onUp()
    if self.bg.isHover then
        self.bg:setColor(self.stateSettings[2].image.color);
        self.text:setSize(self.stateSettings[2].text.size);
        self.text:setColor(self.stateSettings[2].text.color);
    else
        self.bg:setColor(self.stateSettings[1].image.color);
        self.text:setSize(self.stateSettings[1].text.size);
        self.text:setColor(self.stateSettings[1].text.color);
    end
end

function HudControlButton:onClick(_, posX, posY, button)
    self:virtualCallCallback(Hud.CALLBACKS_MOUSE_CLICK, posX, posY, button);
end

function HudControlButton:setColor(r, g, b, a, state)
    if type(r) == "table" then
        state = g or 1;
        r, g, b, a = HudControlButton:superClass().setColor(self, r);
    else
        state = state or 1;
        r, g, b, a = HudControlButton:superClass().setColor(self, r, g, b, a);
    end
    self.stateSettings[state].image.color = {r, g, b, a};
    if state == 1 then
        self.bg:setColor(self.stateSettings[state].image.color);
    end
    return r, g, b, a;
end

function HudControlButton:callCallback(type, ...)
end

function HudControlButton:virtualCallCallback(type, ...)
    if self.callbacks[type] ~= nil then
        for _, c in pairs(self.callbacks[type]) do
            if c ~= nil then
                c.callback(c.object, self, ...);
            end
        end
    end
end
