local AddonName, AddonVars = ...
local util = AddonVars.util

local type = type
local pairs = pairs
local ipairs = ipairs
local print = print
local error = error
local GetTime = GetTime
local CreateFrame = CreateFrame
local IsEventValid = C_EventUtils.IsEventValid
local UnitName = UnitName

local debugging = false
do
    local playerName = UnitName('player')
    if playerName == 'Zodicus' then
        debugging = true
        print('debugging event hooks')
    end
end

local API = {}
local PRIVATE = {}

--- the only key for options, right now, is debounceDelay
util.CreateEventRegistry = function(options)
    -- I'll declare this without setmetatable for exposition
    local api = {
        RegisterEvent = API.RegisterEvent,
        FireEvent = API.FireEvent,
        Callbacks = API.Callbacks,
        Disable = API.Disable,
        Enable = API.Enable,
        p = PRIVATE.CreatePrivateVars(options), -- semi-private vars (just separated, really)
    }

    return api
end

--- API
---@param eventOrEvents any (eventName string or array of them) the event doesn't have to be a blizzard event, if you want to fire it manually
---@param callback function callback will be passed (eventName, ...)
---@return any function save this if you want to unregister that event (nil return for array signature)
function API:RegisterEvent(eventOrEvents, callback)
    if type(eventOrEvents) == 'table' then
        local events = eventOrEvents

        for _, eventName in ipairs(events) do
            self.p:_RegisterEvent(eventName, callback)
        end
    else
        local eventName = eventOrEvents
        return self.p:_RegisterEvent(eventName, callback)
    end
end

-- fire all of an events callbacks that were registered, with args
-- THIS WILL NOT TRIGGER EVENTS REGISTERED GLOBALLY (this might be obvious, but no, I didn't invent a secret hack to do that)
-- e.g. you can send 'COMBAT_LOG_EVENT_UNFILTERED' to test your addon, which uses this API
-- but that wont propagate to ALL frames in your UI which register that
function API:FireEvent(eventName, ...)
    self.p:TryFireEventCallbacks(eventName, ...)
end

-- we probably shouldn't need this. only providing it for really hacky needs
-- MAP OF SETS, [eventName][callback] = true
function API:Callbacks()
    return self.p.eventCallbackRegistry
end

function API:Disable()
    self.p.enabled = false
end

-- it comes enabled, you don't need to touch this unless you've called Disable
function API:Enable()
    self.p.enabled = true
end

--- PRIVATE (ish, still very accessible. I don't see any point in true "private", just for organization)

-- the name had a conflict, but I like the name, since this is kind of an extension
function PRIVATE:_RegisterEvent(eventName, func)
    if not self.eventCallbackRegistry[eventName] then
        self.eventCallbackRegistry[eventName] = {}

        if IsEventValid(eventName) then
            self:RegisterEvent(eventName)
        end
    end

    self.eventCallbackRegistry[eventName][func] = true

    return function()
        self.eventCallbackRegistry[eventName][func] = nil
    end
end

function PRIVATE:OnEvent(eventName, ...)
    if not self.enabled then
        if debugging then
            print('event not fired due to registry disabled : ' .. eventName)
        end
        return
    end

    self:TryFireEventCallbacks(eventName, ...)
end

-- plural
function PRIVATE:TryFireEventCallbacks(eventName, ...)
    local eventCallbacks = self.eventCallbackRegistry[eventName]
    if eventCallbacks then
        self:SetEventTime()
        for callback in pairs(eventCallbacks) do
            self:TryFireEventCallback(eventName, callback, ...)
        end
    end
end

function PRIVATE:TryFireEventCallback(eventName, callback, ...)
    local lastTime = self.eventFireTimeCache[callback]
    local t = self:GetEventTime()
    if (not lastTime) or (t - lastTime > self.debounceDelay) then
        callback(eventName, ...)
        self.eventFireTimeCache[callback] = t
    end
end


function PRIVATE:GetEventTime()
    return self.eventTime
end

function PRIVATE:SetEventTime()
    self.eventTime = GetTime()
end

-- static
function PRIVATE.CreatePrivateVars(options)
    options = options or {}
    -- yes, I know about metatables... this is clean and readable
    -- we'll stick the private vars on our registry frame, cuz why not
    local p = CreateFrame('Frame')
    p.eventCallbackRegistry = {}
    p.debounceDelay = options.debounceDelay or 0.03
    p.eventFireTimeCache = {} -- MAP, [callback] = timestamp
    p.eventTime = nil
    p.enabled = true

    -- private methods
    p._RegisterEvent = PRIVATE._RegisterEvent
    p.TryFireEventCallbacks = PRIVATE.TryFireEventCallbacks
    p.TryFireEventCallback = PRIVATE.TryFireEventCallback
    p.GetEventTime = PRIVATE.GetEventTime
    p.SetEventTime = PRIVATE.SetEventTime

    -- other setup
    p:SetScript('OnEvent', PRIVATE.OnEvent)

    return p
end
