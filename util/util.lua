local AddonName, AddonVars = ...
AddonVars.util = {}
local util = AddonVars.util

util.dump = function(obj, options)
    options = options or {}
    local offset = options.offset
    local timestamp = options.timestamp
    if type(offset) == 'nil' then offset = 2 end
    if type(timestamp) == 'nil' then timestamp = true end
    local codeinfo = ''
    if offset then
        local location = strmatch(debugstack(offset), "@(.-:%d+):")
        codeinfo = codeinfo .. '@' ..location .. '  '
    end
    if timestamp then

        codeinfo = codeinfo .. 't:' .. GetTime()
    end

    print(codeinfo)
    if type(obj) == 'nil' then
       print('dump obj was nil')
    else
        DevTools_Dump(obj)
    end
end

