local AddonName, AddonVars = ...
AddonVars = AddonVars or {}
AddonVars.util = {}
local util = AddonVars.util

util.dump = function(...)
    local location = strmatch(debugstack(2), "@(.-:%d+):")
    local t = GetTime()
    print(location .. ' t:' .. t)
    DevTools_Dump(...)
end

