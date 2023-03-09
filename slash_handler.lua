local AddonName, AddonVars = ...
local util = AddonVars.util
local dump = util.dump
local modules = AddonVars.modules

_G['SLASH_' .. AddonName .. '1'] = '/zq'


SlashCmdList[AddonName] = function(msg)
    dump('zods queue')
    --if msg == 'clear' then
    --end
    modules.ui:Show()
end

_G['SLASH_RELOADS1'] = '/rl'

SlashCmdList['RELOADS'] = function(msg)
    ReloadUI();
end



