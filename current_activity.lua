local AddonName, AddonVars = ...
local util = AddonVars.util
local modules = AddonVars.modules
local dump = util.dump

AddonVars.modules.CurrentActivity = {}
local CurrentActivity = AddonVars.modules.CurrentActivity
CurrentActivity.CF = {} -- ConquestFrame ptr, temp, gets initialized
CurrentActivity.CFOptionToPvpModeMap = {} -- same

local IDS = AddonVars.modules.PvpModes.IDS
local SOLO_SHUFFLE = IDS.SOLO_SHUFFLE
local ARENA_2V2 = IDS.ARENA_2V2
local ARENA_3V3 = IDS.ARENA_3V3
local RBG = IDS.RBG


--pvpMode, enabled
CurrentActivity.updateHook = 'CURRENT_ACTIVITY_UPDATED'

function CurrentActivity.GetPvpMode()
    local CF = CurrentActivity.CF
    local map = CurrentActivity.CFOptionToPvpModeMap
    if CF.selectedButton and map[CF.selectedButton] then
        return map[CF.selectedButton]
    end
end

function CurrentActivity.Update()
    local CF = CurrentActivity.CF
    local map = CurrentActivity.CFOptionToPvpModeMap
    CurrentActivity.previousPvpMode = CurrentActivity.pvpMode
    CurrentActivity.previousEnabled = CurrentActivity.enabled
    if CF.selectedButton then
        local pvpMode = map[CF.selectedButton]
        CurrentActivity.pvpMode = pvpMode
        CurrentActivity.enabled = CF.JoinButton:IsEnabled()
    else
        CurrentActivity.pvpMode = 'unknown'
        CurrentActivity.enabled = false
    end

    if (CurrentActivity.previousPvpMode ~=  CurrentActivity.pvpMode) or (CurrentActivity.previousEnabled ~=  CurrentActivity.enabled) then
        AddonVars.registry:FireEvent(CurrentActivity.updateHook, CurrentActivity.pvpMode, CurrentActivity.enabled)
    end
end

function CurrentActivity:Init()
    if not IsAddOnLoaded('Blizzard_PVPUI') then
        UIParentLoadAddOn('Blizzard_PVPUI')
    end

    local CF = _G.ConquestFrame
    local map = CurrentActivity.CFOptionToPvpModeMap
    CurrentActivity.CF = CF
    map[CF.RatedSoloShuffle] = SOLO_SHUFFLE
    map[CF.Arena2v2] = ARENA_2V2
    map[CF.Arena3v3] = ARENA_3V3
    map[CF.RatedBG] = RBG

    hooksecurefunc('ConquestFrame_SelectButton', CurrentActivity.Update)
    AddonVars.registry:RegisterEvent('PLAYER_ENTERING_WORLD', CurrentActivity.Update)
end

