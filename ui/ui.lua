local AddonName, AddonVars = ...
local util = AddonVars.util
local dump = util.dump
local modules = AddonVars.modules
modules.ui = {}
local ui = modules.ui

local frameName = 'ZODS_TEAM_QUEUE_FRAME'
local widgets = ZODS_WIDGETS_LIB

local function CreateWindowFrame()
    local window = widgets.CreateWindow(500, 400, {title = 'Zods Team Queue'})
    ui.windowFrame = window
    local button = widgets.CreateSecureButton(100, 35, {
        parent = window,
        text = 'Queue',
        macrotext = "/click ConquestJoinButton ",  --  -- /dump 'yo'
    })
    button:SetPoint('TOPLEFT', 130, -65)
    ui.queueButton = button
    ui.activityText = window:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    ui.activityText:SetPoint('TOPLEFT', window, 'TOPLEFT', 35, -80)

    ui.queueText = window:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    ui.queueText:SetPoint('TOPLEFT', window, 'TOPLEFT', 250, -80)
end

function ui.updateCurrentActivity(event, pvpMode, enabled)
    dump({event, pvpMode, enabled})
    if not pvpMode then return end

    local enabled = modules.CurrentActivity.enabled
    ui.activityText:SetText(pvpMode)
    ui.queueButton:SetEnabled(enabled)
end

function ui.updateCurrentQueue(event, queueStatus, ...)
    dump({event, queueStatus, ...})
    if not (ui.pvpMode and queueStatus) then return end

    local currentQueueStatus = queueStatus[ui.pvpMode] or 'idk'
    ui.queueText:SetText(currentQueueStatus)
end

function ui:Show()
    local frame = self.windowFrame
    if frame then
        frame:Show()
    end
end

function ui.UpdatePvPMode(event, pvpMode)
    ui.pvpMode = pvpMode
end


-- RoleCheck.memberUpdateHook = 'ROLE_CHECK_MEMBER_UPDATE_HOOK' -- RoleCheck.currentCheck


function ui:Init()
    _G[frameName] = CreateWindowFrame()

    AddonVars.registry:RegisterEvent(modules.CurrentActivity.updateHook, ui.updateCurrentActivity)

    AddonVars.registry:RegisterEvent(modules.PvpQueue.updateHook, ui.updateCurrentQueue)

    AddonVars.registry:RegisterEvent(modules.CurrentActivity.updateHook, ui.UpdatePvPMode)
end
