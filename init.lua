local AddonName, AddonVars = ...
local util = AddonVars.util
local dump = util.dump

AddonVars = AddonVars or {} -- should already be a table but
AddonVars.modules = {}

local unregisterInit

local function InitModules()
    for k, v in pairs(AddonVars.modules) do
        if v.Init then
            dump('initializing module '.. k)
            v:Init()
            v.Init = nil -- may as well drop the ptr
        end
    end
end

local function autoRun()
    C_Timer.After(2, function()
        AddonVars.modules.ui:Show()
    end)
end

local function OnLoad(event, addonName)
    if addonName == AddonName then
        dump('we loaded')
        InitModules()
        autoRun()
        unregisterInit()
    end
end
--
AddonVars.registry = util.CreateEventRegistry()
unregisterInit = AddonVars.registry:RegisterEvent('ADDON_LOADED', OnLoad)
