local AddonName, AddonVars = ...
local util = AddonVars.util
local dump = util.dump

AddonVars = AddonVars or {} -- should already be a table but
AddonVars.modules = {}

AddonVars.RegisterEvent = function(event)
    AddonVars.registryFrame:RegisterEvent(event)
end

local init = {}
init.loaded = false

function init.OnLoad(...)
    if init.loaded then error('tried to load twice my dude') end

    dump('we loaded')
    init.InitModules()
    init.autoRun()
    init.loaded = true
end

function init.autoRun()
    C_Timer.After(2, function()
        AddonVars.modules.ui:Show()
    end)
end


function init.OnEvent(_, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == AddonName then
            init.OnLoad(...)
        end
    end
end

function init.InitModules()
    for k, v in pairs(AddonVars.modules) do
        if v.Init then
            dump('initializing module '.. k)
            v:Init()
            v.Init = nil -- may as well drop the ptr
        end
    end
end

AddonVars.registryFrame = CreateFrame("Frame")
AddonVars.registryFrame:SetScript('OnEvent', init.OnEvent)
AddonVars.RegisterEvent("ADDON_LOADED")


