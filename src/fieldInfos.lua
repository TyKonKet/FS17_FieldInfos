--
-- FieldInfos
--
-- @author TyKonKet
-- @date 10/07/2017
FieldInfos = {}
FieldInfos.dir = g_currentModDirectory
FieldInfos.name = "FieldInfos"
FieldInfos.debug = true

function FieldInfos:print(text, ...)
    local start = string.format("[%s(%s)] -> ", self.name, getDate("%H:%M:%S"))
    local ptext = string.format(text, ...)
    print(string.format("%s%s", start, ptext))
end

function FieldInfos:initialize(missionInfo, missionDynamicInfo, loadingScreen)
    self = FieldInfos
    self.fieldsMapTargetWidth, self.fieldsMapTargetHeight = 1024, 1024
    self.fieldsMapBits = 8
    self.fieldsMapMaxFields = 2 ^ self.fieldsMapBits - 1
    self.fieldPanelShown = false
    self.fieldPanel = FieldPanel:new()
    g_gui:loadGui(self.dir .. "guis/fieldPanel.xml", "FieldPanel", self.fieldPanel)
    FocusManager:setGui("MPLoadingScreen")
end
g_mpLoadingScreen.loadFunction = Utils.prependedFunction(g_mpLoadingScreen.loadFunction, FieldInfos.initialize)

function FieldInfos:load(missionInfo, missionDynamicInfo, loadingScreen)
    self = FieldInfos
    g_currentMission.loadMapFinished = Utils.appendedFunction(g_currentMission.loadMapFinished, self.loadMapFinished)
    g_currentMission.onStartMission = Utils.appendedFunction(g_currentMission.onStartMission, self.afterLoad)
    g_currentMission.missionInfo.saveToXML = Utils.appendedFunction(g_currentMission.missionInfo.saveToXML, self.saveSavegame)
end
g_mpLoadingScreen.loadFunction = Utils.appendedFunction(g_mpLoadingScreen.loadFunction, FieldInfos.load)

function FieldInfos:loadMap(name)
    self:print("loadMap(name:%s)", name)
    if self.debug then
        addConsoleCommand("fiGetFieldNumber", "", "fiGetFieldNumber", self)
        addConsoleCommand("fiToggleFieldNumberDebug", "", "fiToggleFieldNumberDebug", self)
    end
    self:loadSavegame()
end

function FieldInfos:loadMapFinished()
    self = FieldInfos
    self.fieldsDef = g_currentMission.fieldDefinitionBase
    self.fieldsMap = createBitVectorMap("fieldsMap")
    loadBitVectorMapNew(self.fieldsMap, self.fieldsMapTargetWidth, self.fieldsMapTargetHeight, self.fieldsMapBits, false)
    self.fieldsMapWidth, self.fieldsMapHeight = getBitVectorMapSize(self.fieldsMap)
    if self.fieldsDef.numberOfFields > self.fieldsMapMaxFields then
        print("Warning: the maximum fields amount supported by " .. self.name .. " is " .. self.fieldsMapMaxFields .. " but this map have " .. self.fieldsDef.numberOfFields .. " fields.")
    end
    local numberOfFields = math.min(self.fieldsDef.numberOfFields, self.fieldsMapMaxFields)
    for i = 1, numberOfFields do
        local fieldDef = self.fieldsDef.fieldDefsByFieldNumber[i]
        if self.fieldsDef.isInit then
            local numDimensions = getNumOfChildren(fieldDef.fieldDimensions)
            for i = 1, numDimensions do
                local dimWidth = getChildAt(fieldDef.fieldDimensions, i - 1)
                local dimStart = getChildAt(dimWidth, 0)
                local dimHeight = getChildAt(dimWidth, 1)
                local x, _, z = getWorldTranslation(dimStart)
                local x1, _, z1 = getWorldTranslation(dimWidth)
                local x2, _, z2 = getWorldTranslation(dimHeight)
                self:setFieldNumberAtWorldParallelogram(x, z, x1, z1, x2, z2, fieldDef.fieldNumber)
            end
        end
    end
end

function FieldInfos:afterLoad()
    self = FieldInfos
    self:print("afterLoad")
end

function FieldInfos:loadSavegame()
    self:print("loadSavegame()")
    --enable load of bitmap on server, this should speed up the loading
end

function FieldInfos:saveSavegame()
    self = FieldInfos
    if self.fieldsMap ~= nil then
        saveBitVectorMapToFile(self.fieldsMap, g_currentMission.missionInfo.savegameDirectory .. "/fieldsMap.grle")
    end
end

function FieldInfos:deleteMap()
end

function FieldInfos:keyEvent(unicode, sym, modifier, isDown)
end

function FieldInfos:mouseEvent(posX, posY, isDown, isUp, button)
end

function FieldInfos:update(dt)
    if g_currentMission.player ~= nil and g_currentMission.player.isControlled then
        local x, _, z, _ = g_currentMission.player:getPositionData()
        local value = self:getFieldNumberAtWorldPos(x, z)
        if value ~= nil and value > 0 then
            if self.fieldPanelShown then
                g_currentMission:addHelpButtonText(g_i18n:getText("FI_HIDE"), InputBinding.FI_TOGGLE)
                if InputBinding.hasEvent(InputBinding.FI_TOGGLE) then
                    g_gui:showGui("")
                    self.fieldPanelShown = false
                end
            else
                g_currentMission:addHelpButtonText(string.format(g_i18n:getText("FI_SHOW"), value), InputBinding.FI_TOGGLE)
                if InputBinding.hasEvent(InputBinding.FI_TOGGLE) then
                    self:setHudByField(self.fieldsDef.fieldDefsByFieldNumber[value])
                    g_gui:showGui("FieldPanel")
                    self.fieldPanelShown = true
                end
            end
        end
    end

    if self.fieldNumberDebug then
        if g_currentMission.player ~= nil then
            if self.fieldsMap ~= nil then
                local px, _, pz, _ = g_currentMission.player:getPositionData()
                px = math.floor(px)
                pz = math.floor(pz)
                local radius = 10
                local heightOffset = 0.25
                local function colorByFieldNumber(fieldNumber)
                    i = fieldNumber
                    local r = 0
                    local g = 0
                    local b = 0
                    if fieldNumber > 0 then
                        if i <= 85 then
                            r = Utils.clamp(255, 0, 255)
                            g = Utils.clamp(i * 3, 0, 255)
                            b = Utils.clamp(0, 0, 255)
                        elseif (i <= 170) then
                            r = Utils.clamp(i * 3 - 258, 0, 255)
                            g = Utils.clamp(0, 0, 255)
                            b = Utils.clamp(255, 0, 255)
                        else
                            r = Utils.clamp(0, 0, 255)
                            g = Utils.clamp(255, 0, 255)
                            b = Utils.clamp(i * 3 - 513, 0, 255)
                        end
                    end
                    return r / 255, g / 255, b / 255
                end
                for x = px - radius, px + radius do
                    for z = pz - radius, pz + radius do
                        local fieldNumber1 = self:getFieldNumberAtWorldPos(x, z)
                        local x1, y1, z1 = x, getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, x, 0, z) + heightOffset, z
                        local r1, g1, b1 = colorByFieldNumber(fieldNumber1)
                        if x < px + radius then
                            local fieldNumber2 = self:getFieldNumberAtWorldPos(x + 1, z)
                            local x2, y2, z2 = x + 1, getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, x + 1, 0, z) + heightOffset, z
                            local r2, g2, b2 = colorByFieldNumber(fieldNumber2)
                            drawDebugLine(x1, y1, z1, r1, g1, b1, x2, y2, z2, r2, g2, b2)
                        end
                        if z < pz + radius then
                            local fieldNumber3 = self:getFieldNumberAtWorldPos(x, z + 1)
                            local x3, y3, z3 = x, getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, x, 0, z + 1) + heightOffset, z + 1
                            local r3, g3, b3 = colorByFieldNumber(fieldNumber3)
                            drawDebugLine(x1, y1, z1, r1, g1, b1, x3, y3, z3, r3, g3, b3)
                        end
                        if z < pz + radius and x < px + radius then
                            local fieldNumber4 = self:getFieldNumberAtWorldPos(x + 1, z + 1)
                            local x4, y4, z4 = x + 1, getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, x + 1, 0, z + 1) + heightOffset, z + 1
                            local r4, g4, b4 = colorByFieldNumber(fieldNumber4)
                            drawDebugLine(x1, y1, z1, r1, g1, b1, x4, y4, z4, r4, g4, b4)
                        end
                    end
                end
            end
        end
    end
end

function FieldInfos:draw()
end

function FieldInfos:fiGetFieldNumber()
    if g_currentMission.player ~= nil then
        if self.fieldsMap ~= nil then
            local x, _, z, _ = g_currentMission.player:getPositionData()
            local value = self:getFieldNumberAtWorldPos(x, z)
            return "You are over field n° " .. value
        else
            return "There is no fieldsMap"
        end
    else
        return "There is no player"
    end
end

function FieldInfos:fiToggleFieldNumberDebug()
    self.fieldNumberDebug = not self.fieldNumberDebug
    return "fieldNumberDebug = " .. tostring(self.fieldNumberDebug)
end

function FieldInfos:getFieldNumberAtWorldPos(x, z)
    if self.fieldsMap ~= nil then
        local gridX, gridZ = self:convertWorldToFieldsMapPosition(x, z)
        return getBitVectorMapPoint(self.fieldsMap, gridX, gridZ, 0, self.fieldsMapBits)
    end
    return -1
end

function FieldInfos:setFieldNumberAtWorldParallelogram(x, z, widthX, widthZ, heightX, heightZ, fieldNumber)
    if self.fieldsMap ~= nil then
        local x, z = self:convertWorldToFieldsMapPosition(x, z)
        local widthX, widthZ = self:convertWorldToFieldsMapPosition(widthX, widthZ)
        local heightX, heightZ = self:convertWorldToFieldsMapPosition(heightX, heightZ)
        setBitVectorMapParallelogram(self.fieldsMap, x, z, widthX - x, widthZ - z, heightX - x, heightZ - z, 0, self.fieldsMapBits, fieldNumber)
    end
end

function FieldInfos:convertWorldToFieldsMapPosition(x, z)
    return math.floor(self.fieldsMapWidth * (x + g_currentMission.terrainSize * 0.5) / g_currentMission.terrainSize), math.floor(self.fieldsMapHeight * (z + g_currentMission.terrainSize * 0.5) / g_currentMission.terrainSize)
end

function FieldInfos:setHudByField(fieldDef)
    --self.hud.fTitle:setText(string.format(g_i18n:getText("fieldJob_number"), " n°" .. tostring(fieldDef.fieldNumber)))
end

addModEventListener(FieldInfos)
