--
-- Hud
--
-- @author  TyKonKet
-- @date 04/04/2017
Hud = {};
local Hud_mt = Class(Hud);

Hud.CALLBACKS_MOUSE_ENTER = 1;
Hud.CALLBACKS_MOUSE_LEAVE = 2;
Hud.CALLBACKS_MOUSE_DOWN = 3;
Hud.CALLBACKS_MOUSE_UP = 4;
Hud.CALLBACKS_MOUSE_CLICK = 5;
Hud.CALLBACKS_SHOW_GUI = 6;

Hud.MOUSEBUTTONS_LEFT = 1;
Hud.MOUSEBUTTONS_WHEEL = 2;
Hud.MOUSEBUTTONS_RIGHT = 3;
Hud.MOUSEBUTTONS_WHEEL_UP = 4;
Hud.MOUSEBUTTONS_WHEEL_DOWN = 5;

Hud.ALIGNS_VERTICAL_BOTTOM = 1;
Hud.ALIGNS_VERTICAL_MIDDLE = 2;
Hud.ALIGNS_VERTICAL_TOP = 3;

Hud.ALIGNS_HORIZONTAL_LEFT = 4;
Hud.ALIGNS_HORIZONTAL_CENTER = 5;
Hud.ALIGNS_HORIZONTAL_RIGHT = 6;

Hud.DEFAULT_UVS = {0, 0, 0, 1, 1, 0, 1, 1};

function Hud:print(text, ...)
    local start = string.format("[%s(%s)] -> ", self.name, getDate("%H:%M:%S"));
    local ptext = string.format(text, ...);
    print(string.format("%s%s", start, ptext));
end

function Hud:new(name, x, y, width, height, parent, mt)
    local self = setmetatable({}, mt or Hud_mt);
    self.name = name;
    self.uiScale = g_gameSettings:getValue("uiScale");
    self.width, self.height = getNormalizedScreenValues(width * self.uiScale, height * self.uiScale);
    self.pWidth = width;
    self.pHeight = height;
    self.defaultWidth = self.width;
    self.defaultHeight = self.height;
    self.x = x;
    self.y = y;
    self.alignmentVertical = Hud.ALIGNS_VERTICAL_BOTTOM;
    self.alignmentHorizontal = Hud.ALIGNS_HORIZONTAL_LEFT;
    self.offsetX = 0;
    self.offsetY = 0;
    self.invertX = false;
    self.rotation = 0;
    self.rotationCenterX = 0;
    self.rotationCenterY = 0;
    self.r = 1.0;
    self.g = 1.0;
    self.b = 1.0;
    self.a = 1.0;
    self.visible = true;
    self.uvs = Hud.DEFAULT_UVS;
    self.callbacks = {};
    self.leaveRaised = true;
    self.upRaised = true;
    self.downRaised = false;
    self.childs = {};
    self.parent = parent;
    if self.parent ~= nil then
        table.insert(self.parent.childs, self);
    end
    if self.x > 1 or self.x < 0 then
        self.x = self:getNormalizedValues(x, 0)[1];
    end
    if self.y > 1 or self.y < 0 then
        self.y = self:getNormalizedValues(0, y)[2];
    end
    self.index, self.key = HudManager:addHud(self);
    return self;
end

function Hud:delete(applyToChilds)
    for _, c in pairs(self.childs) do
        if applyToChilds then
            c:delete(applyToChilds);
        else
            c.parent = nil;
        end
    end
    HudManager:removeHudWithKey(self.key);
end

function Hud:update(dt)
end

function Hud:setColor(r, g, b, a)
    if type(r) == "table" then
        self.r = Utils.getNoNil(r[1], self.r);
        self.g = Utils.getNoNil(r[2], self.g);
        self.b = Utils.getNoNil(r[3], self.b);
        self.a = Utils.getNoNil(r[4], self.a);
    else
        self.r = Utils.getNoNil(r, self.r);
        self.g = Utils.getNoNil(g, self.g);
        self.b = Utils.getNoNil(b, self.b);
        self.a = Utils.getNoNil(a, self.a);
    end
    return self.r, self.g, self.b, self.a;
end

function Hud:setPosition(x, y)
    self.x = Utils.getNoNil(x, self.x);
    self.y = Utils.getNoNil(y, self.y);
end

function Hud:getRenderPosition()
    local x = self.x + self.offsetX;
    local y = self.y + self.offsetY;
    if self.parent ~= nil then
        local xP, yP = self.parent:getRenderPosition();
        x = self.x * self.parent.width + self.offsetX + xP;
        y = self.y * self.parent.height + self.offsetY + yP;
    end
    return x, y;
end

function Hud:setDimension(width, height)
    self.width = Utils.getNoNil(width, self.width);
    self.height = Utils.getNoNil(height, self.height);
    self:setAlignment(self.alignmentVertical, self.alignmentHorizontal)
end

function Hud:getRenderDimension()
    return self.width, self.height;
end

function Hud:resetDimensions(applyToChilds)
    self:setDimension(self.defaultWidth, self.defaultHeight);
    if applyToChilds then
        for _, c in pairs(self.childs) do
            c:resetDimensions(applyToChilds);
        end
    end
end

function Hud:render()
end

function Hud:setAlignment(vertical, horizontal)
    if vertical == Hud.ALIGNS_VERTICAL_TOP then
        self.offsetY = -self.height;
    elseif vertical == Hud.ALIGNS_VERTICAL_MIDDLE then
        self.offsetY = -self.height * 0.5;
    else
        self.offsetY = 0;
    end
    self.alignmentVertical = Utils.getNoNil(vertical, Hud.ALIGNS_VERTICAL_BOTTOM);
    
    if horizontal == Hud.ALIGNS_HORIZONTAL_RIGHT then
        self.offsetX = -self.width;
    elseif horizontal == Hud.ALIGNS_HORIZONTAL_CENTER then
        self.offsetX = -self.width * 0.5;
    else
        self.offsetX = 0;
    end
    self.alignmentHorizontal = Utils.getNoNil(horizontal, Hud.ALIGNS_HORIZONTAL_LEFT);
end

function Hud:setIsVisible(visible, applyToChilds)
    self.visible = visible;
    if applyToChilds then
        for _, c in pairs(self.childs) do
            c:setIsVisible(visible, applyToChilds);
        end
    end
end

function Hud:keyEvent(unicode, sym, modifier, isDown)
end

function Hud:mouseEvent(posX, posY, isDown, isUp, button)
    local x, y = self:getRenderPosition();
    local w, h = self:getRenderDimension();
    if posX >= x and posX <= x + w and posY >= y and posY <= y + h then
        if not self.enterRaised then
            self.leaveRaised = false;
            self.enterRaised = true;
            self:callCallback(Hud.CALLBACKS_MOUSE_ENTER, posX, posY);
        end
        if isDown then
            self.clickRaised = false;
            if self.upRaised then
                self.upRaised = false;
                self.downRaised = true;
                self:callCallback(Hud.CALLBACKS_MOUSE_DOWN, posX, posY, button);
            end
        end
        if isUp then
            if not self.clickRaised then
                self.clickRaised = true
                self:callCallback(Hud.CALLBACKS_MOUSE_CLICK, posX, posY, button);
            end
            if self.downRaised then
                self.upRaised = true;
                self.downRaised = false;
                self:callCallback(Hud.CALLBACKS_MOUSE_UP, posX, posY, button);
            end
        end
    else
        if not self.leaveRaised then
            self.leaveRaised = true;
            self.enterRaised = false;
            self:callCallback(Hud.CALLBACKS_MOUSE_LEAVE, posX, posY);
        end
    end
end

function Hud:showGui(state, guiName, gui)
    self:callCallback(Hud.CALLBACKS_SHOW_GUI, state, guiName, gui);
end

function Hud:addCallback(obj, cb, type)
    if self.callbacks[type] == nil then
        self.callbacks[type] = {};
    end
    table.insert(self.callbacks[type], {object = obj, callback = cb});
end

function Hud:callCallback(type, ...)
    if self.callbacks[type] ~= nil then
        for _, c in pairs(self.callbacks[type]) do
            if c ~= nil then
                c.callback(c.object, self, ...);
            end
        end
    end
end

function Hud:getNormalizedValues(x, y)
    if self.parent == nil then
        local values = getNormalizedValues({x, y}, {g_referenceScreenWidth, g_referenceScreenHeight});
        local newX = values[1] * g_aspectScaleX;
        local newY = values[2] * g_aspectScaleY;
        return {newX, newY};
    else
        return {(x / self.parent.pWidth), (y / self.parent.pHeight)};
    end
end
