--
-- FieldInfos
--
-- @author TyKonKet
-- @date 23/05/2018
FieldPanel = {}
local FieldPanel_mt = Class(FieldPanel, ScreenElement)

function FieldPanel:new(target, custom_mt)
	if custom_mt == nil then
		custom_mt = FieldPanel_mt
	end
	local self = ScreenElement:new(target, custom_mt)
	self.returnScreenName = ""
	return self
end

function FieldPanel:onOpen()
	FieldPanel:superClass().onOpen(self)
end
