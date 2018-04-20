--
-- HudManager
--
-- @author  TyKonKet
-- @date 04/04/2017
HudManager = {};
HudManager.modDir = g_currentModDirectory;
HudManager.modName = g_currentModName;
HudManager.hudsKey = {};
HudManager.huds = {};
HudManager.hudIndex = 0;
HudManager.codeFolder = "hud";
source(HudManager.modDir .. HudManager.codeFolder .. "/hud.lua", HudManager.modName);
source(HudManager.modDir .. HudManager.codeFolder .. "/hudControl.lua", HudManager.modName);
source(HudManager.modDir .. HudManager.codeFolder .. "/hudImage.lua", HudManager.modName);
source(HudManager.modDir .. HudManager.codeFolder .. "/hudText.lua", HudManager.modName);
source(HudManager.modDir .. HudManager.codeFolder .. "/hudProgressBar.lua", HudManager.modName);
source(HudManager.modDir .. HudManager.codeFolder .. "/hudLevelBar.lua", HudManager.modName);
source(HudManager.modDir .. HudManager.codeFolder .. "/hudProgressIcon.lua", HudManager.modName);
source(HudManager.modDir .. HudManager.codeFolder .. "/hudControlButton.lua", HudManager.modName);
source(HudManager.modDir .. HudManager.codeFolder .. "/hudControlPaging.lua", HudManager.modName);

function HudManager:loadMap(name)
    g_gui.showGui = Utils.overwrittenFunction(g_gui.showGui, self.showGui);
end

function HudManager:deleteMap()
end

function HudManager:keyEvent(unicode, sym, modifier, isDown)
    if self.missionIsStarted then
        for _, h in pairs(self.huds) do
            h:keyEvent(unicode, sym, modifier, isDown);
        end
    end
end

function HudManager:mouseEvent(posX, posY, isDown, isUp, button)
    if self.missionIsStarted then
        for _, h in pairs(self.huds) do
            h:mouseEvent(posX, posY, isDown, isUp, button);
        end
    end
end

function HudManager:update(dt)
    if not self.missionIsStarted then
        self.missionIsStarted = true;
    end
    for _, h in pairs(self.huds) do
        h:update(dt);
    end
end

function HudManager:draw()
    if self.missionIsStarted and g_currentMission.showVehicleInfo then
        for _, h in pairs(self.huds) do
            h:render();
        end
    end
end

function HudManager:showGui(super, guiName)
    if super ~= nil then
        local gui = super(self, guiName);
        for _, h in pairs(HudManager.huds) do
            h:showGui(gui ~= nil, guiName, gui);
        end
        return gui;
    end
end

function HudManager:addHud(hud)
    self.hudIndex = self.hudIndex + 1;
    local key = string.format("[%s]%s", self.hudIndex, hud.name);
    self.huds[self.hudIndex] = hud;
    self.hudsKey[key] = self.hudIndex;
    return self.hudIndex, key;
end

function HudManager:removeHud(index)
    self.huds[index] = nil;
end

function HudManager:removeHudWithKey(key)
    self.huds[self.hudsKey[key]] = nil;
    self.hudsKey[key] = nil;
end

function HudManager.lockVehicleCameras(vehicle)
    if not vehicle.camerasAreLocked then
        for _, c in pairs(vehicle.cameras) do
            c.lastAllowTranslation = c.allowTranslation;
            c.allowTranslation = false;
            c.lastIsRotatable = c.isRotatable;
            c.isRotatable = false;
        end
        vehicle.camerasAreLocked = true;
    end
end

function HudManager.unlockVehicleCameras(vehicle)
    if vehicle.camerasAreLocked then
        for _, c in pairs(vehicle.cameras) do
            c.allowTranslation = c.lastAllowTranslation;
            c.isRotatable = c.lastIsRotatable;
        end
        vehicle.camerasAreLocked = false;
    end
end

function HudManager.setShowMouseCursor(state, vehicle)
    InputBinding.setShowMouseCursor(state);
    if vehicle ~= nil then
        if vehicle.lockInput ~= nil then
            vehicle:lockInput(state);
        else
            if state then
                HudManager.lockVehicleCameras(vehicle);
            else
                HudManager.unlockVehicleCameras(vehicle);
            end
        end
    end
end

addModEventListener(HudManager);
