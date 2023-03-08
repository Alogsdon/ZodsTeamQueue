local AddonName, AddonVars = ...

AddonVars.modules.ui = {}
local ui = AddonVars.modules.ui

local frameName = 'ZODS_TEAM_QUEUE_FRAME'
local widgets = ZODS_WIDGETS_LIB

local function CreateWindowFrame()
    local window = widgets.CreateWindow(500, 400)
    ui.windowFrame = window
end

function ui:Show()
    local frame = self.windowFrame
    if frame then
        frame:Show()
    end
end

function ui:Init()
    _G[frameName] = CreateWindowFrame()
end

