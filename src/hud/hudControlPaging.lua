--
-- HudControlPaging
--
-- @author  TyKonKet
-- @date 11/12/2017
HudControlPaging = {};
local HudControlPaging_mt = Class(HudControlPaging, HudControl);

function HudControlPaging:new(name, x, y, width, height, parent, mt)
    local self = HudControl:new(name, x, y, width, height, parent, mt or HudControlPaging_mt);
    
    self.leftButton = HudControlButton:new(name .. "LeftButton", 0, 1, 37, 36, "<", 23);
    self.leftButton:setAlignment(Hud.ALIGNS_VERTICAL_TOP, Hud.ALIGNS_HORIZONTAL_LEFT);
    self.leftButton:addCallback(self, self.leftButtonClick, Hud.CALLBACKS_MOUSE_CLICK);
    
    self.rightButton = HudControlButton:new(name .. "RightButton", 1, 1, 37, 36, ">", 23);
    self.rightButton:setAlignment(Hud.ALIGNS_VERTICAL_TOP, Hud.ALIGNS_HORIZONTAL_RIGHT);
    self.rightButton:addCallback(self, self.rightButtonClick, Hud.CALLBACKS_MOUSE_CLICK);
    
    self.textBg = HudImage:new(name .. "TextBg", g_baseUIFilename, 0.5, 1, width - 76, 36);
    self.textBg:setUVs(getNormalizedUVs({10, 1010, 4, 4}));
    self.textBg:setColor({0.0075, 0.0075, 0.0075, 1});
    self.textBg:setAlignment(Hud.ALIGNS_VERTICAL_TOP, Hud.ALIGNS_HORIZONTAL_CENTER);
    
    self.text = HudText:new(name .. "Text", "Page title", 17, 0.5, 0.975, true);
    self.text:setAlignment(Hud.ALIGNS_VERTICAL_TOP, Hud.ALIGNS_HORIZONTAL_CENTER);
    
    self:addHud(self.leftButton);
    self:addHud(self.rightButton);
    self:addHud(self.textBg);
    self:addHud(self.text);
    
    self.pages = {};
    self.selectedPage = 1;
    self.pagesColor = {0, 0, 0, 0};
    
    return self;
end

function HudControlPaging:addPage(title)
    local newPage = {};
    newPage.title = title;
    newPage.page = HudImage:new(self.name .. "Page" .. tostring(#self.pages), g_baseUIFilename, 0, 0, self.pWidth, self.pHeight - 37);
    newPage.page:setUVs(getNormalizedUVs({10, 1010, 4, 4}));
    newPage.page:setColor(self.pagesColor);
    self:addHud(newPage.page);
    table.insert(self.pages, newPage);
    self:selectPage(self.selectedPage);
end

function HudControlPaging:selectPage(index)
    for _, p in pairs(self.pages) do
        p.page:setIsVisible(false, true, true);
    end
    if self.visible then
        self.pages[index].page:setIsVisible(true, true, true);
    end
    self.text:setText(self.pages[index].title);
    self.selectedPage = index;
end

function HudControlPaging:selectNextPage()
    local p = self.selectedPage + 1;
    if p > #self.pages then
        p = 1;
    end
    self:selectPage(p);
end

function HudControlPaging:selectPreviousPage()
    local p = self.selectedPage - 1;
    if p < 1 then
        p = #self.pages;
    end
    self:selectPage(p);
end

function HudControlPaging:leftButtonClick()
    self:selectPreviousPage();
end

function HudControlPaging:rightButtonClick()
    self:selectNextPage();
end

function HudControlPaging:setIsVisible(visible, applyToChilds, skipSelection)
    HudControlPaging:superClass().setIsVisible(self, visible, applyToChilds);
    if not skipSelection then
        self:selectPage(self.selectedPage);
    end
end
