--
-- HudImage
--
-- @author  TyKonKet
-- @date 06/04/2017
HudImage = {};
local HudImage_mt = Class(HudImage, Hud);

function HudImage:new(name, overlayFilename, x, y, width, height, parent, mt)
    local self = Hud:new(name, x, y, width, height, parent, mt or HudImage_mt);
    self.filename = overlayFilename;
    self.overlayId = 0;
    if self.filename ~= nil then
        self.overlayId = createImageOverlay(self.filename);
    end
    return self;
end

function HudImage:delete(applyToChilds)
    if self.overlayId ~= 0 then
        delete(self.overlayId);
        self.overlayId = 0;
    end
    HudImage:superClass().delete(self, applyToChilds);
end

function HudImage:setColor(r, g, b, a, applyToChilds)
    HudImage:superClass().setColor(self, r, g, b, a, applyToChilds);
    if self.overlayId ~= 0 then
        setOverlayColor(self.overlayId, self.r, self.g, self.b, self.a);
    end
end

function HudImage:setUVs(uvs)
    if uvs ~= self.uvs then
        if type(uvs) == "number" then
            printCallstack();
        end
        if self.overlayId ~= 0 then
            self.uvs = uvs;
            setOverlayUVs(self.overlayId, unpack(self.uvs));
        end
    end
end

function HudImage:setInvertX(invertX, applyToChilds)
    if self.invertX ~= invertX then
        self.invertX = invertX;
        if self.overlayId ~= 0 then
            if invertX then
                setOverlayUVs(self.overlayId, unpack(self.uvs));
            else
                setOverlayUVs(self.overlayId, self.uvs[5], self.uvs[6], self.uvs[7], self.uvs[8], self.uvs[1], self.uvs[2], self.uvs[3], self.uvs[4]);
            end
        end
    end
    if applyToChilds then
        for _, c in pairs(self.childs) do
            c:setInvertX(invertX, applyToChilds);
        end
    end
end

function HudImage:setRotation(rotation, centerX, centerY, applyToChilds)
    if self.rotation ~= rotation or self.rotationCenterX ~= centerX or self.rotationCenterY ~= centerY then
        self.rotation = rotation;
        self.rotationCenterX = centerX;
        self.rotationCenterY = centerY;
        if self.overlayId ~= 0 then
            setOverlayRotation(self.overlayId, rotation, centerX, centerY);
        end
    end
    if applyToChilds then
        for _, c in pairs(self.childs) do
            c:setRotation(rotation, centerX, centerY, applyToChilds);
        end
    end
end

function HudImage:render()
    if self.visible and self.overlayId ~= 0 then
        local x, y = self:getRenderPosition();
        local w, h = self:getRenderDimension();
        renderOverlay(self.overlayId, x, y, w, h);
    end
end

function HudImage:setImage(overlayFilename)
    if self.filename ~= overlayFilename then
        if self.overlayId ~= 0 then
            delete(self.overlayId);
        end
        self.filename = overlayFilename;
        self.overlayId = createImageOverlay(overlayFilename);
    end
end
