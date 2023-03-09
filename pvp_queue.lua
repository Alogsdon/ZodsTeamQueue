local AddonName, AddonVars = ...
local util = AddonVars.util
local dump = util.dump
local modules = AddonVars.modules
local PvpQueue = {}
modules.PvpQueue = PvpQueue
PvpQueue.roleCheckItem = nil
PvpQueue.battlefieldItems = {}

local QUEUE_STATUSES = {
    UNKNOWN = 'UNKNOWN',
    IN_QUEUE = 'IN_QUEUE',
    NOT_QUEUED = 'NOT_QUEUED',
    ROLE_CHECK = 'ROLE_CHECK',
    DONT_OVERRIDE = 'DONT_OVERRIDE',
}
PvpQueue.queueStatuses = QUEUE_STATUSES

-- PvpQueue tells us when any of our pvp queues change
-- this is essentially just battlefield plus role check
-- we want this for the hook

PvpQueue.updateHook = 'PVP_QUEUE_UPDATED_HOOK' -- queueItems - {[pvpMode] = status}

local UT1 = modules.Battlefield.updateTypes
local QUEUED = UT1.QUEUED
local DROPPED = UT1.DROPPED
local POPPED = UT1.POPPED
local ENTERED = UT1.ENTERED
local LEFT = UT1.LEFT
local UT2 = modules.RoleCheck.updateTypes
local INITIATED = UT2.INITIATED
local CANCELLED = UT2.CANCELLED
local UT3 = modules.Battlefield.statuses
local NONE = UT3.NONE
local CONFIRM = UT3.CONFIRM
local ACTIVE = UT3.ACTIVE

local updateToStatusMap = {
    [QUEUED] = QUEUE_STATUSES.IN_QUEUE,
    [DROPPED] = QUEUE_STATUSES.NOT_QUEUED,
    [POPPED] = QUEUE_STATUSES.IN_QUEUE,
    [ENTERED] = QUEUE_STATUSES.NOT_QUEUED,
    [LEFT] = QUEUE_STATUSES.NOT_QUEUED,
    [INITIATED] = QUEUE_STATUSES.ROLE_CHECK,
    [CANCELLED] = QUEUE_STATUSES.NOT_QUEUED,
    [NONE] = QUEUE_STATUSES.DONT_OVERRIDE, -- not determinite. could be in role check
    [CONFIRM] = QUEUE_STATUSES.IN_QUEUE, -- this is when it actually pops
    [ACTIVE] = QUEUE_STATUSES.NOT_QUEUED,
}

function PvpQueue.ToQueueStatus(updateType)
    -- updateType can be in Battlefield.updateTypes, Battlefield.statuses, or RoleCheck.updateTypes
    -- or already be a PvpQueue.queueStatuses. idk if thats too much flexibility. mapping should work I think..

    if not updateType then return QUEUE_STATUSES.DONT_OVERRIDE end

    -- maybe its already a status. seems reasonable
    if QUEUE_STATUSES[updateType] then return QUEUE_STATUSES[updateType] end

    return updateToStatusMap[updateType] or QUEUE_STATUSES.DONT_OVERRIDE
end

local function mapsMatch(x, y) -- shallow compare
    if type(x) ~= type(y) then return false end

    for key in pairs(y) do
        if x[key] ~= y[key] then
            return false
        end
    end
    -- x has everything that y does
    -- then, does x have anything that y does NOT?
    for key in pairs(x) do
        if y[key] == nil then
            return false
        end
    end
    return true
end

function PvpQueue.CheckDiffAndFire()
    PvpQueue.currentStatuses = PvpQueue.currentStatuses or {}
    local matched = mapsMatch(PvpQueue.lastStatuses, PvpQueue.currentStatuses)
    if not matched then
        PvpQueue.lastStatuses = {} -- shallow copy it, so we can compare again later
        for k, v in pairs(PvpQueue.currentStatuses) do
            PvpQueue.lastStatuses[k] = v
        end

        AddonVars.registry:FireEvent(PvpQueue.updateHook, PvpQueue.currentStatuses)
    end
end

function PvpQueue.Update()
    PvpQueue.CheckDiffAndFire()
end

function PvpQueue.SetPvpModeStatus(pvpMode, status)
    if not (pvpMode and status) then return end
    PvpQueue.currentStatuses = PvpQueue.currentStatuses or {}

    local currentStatus = PvpQueue.currentStatuses[pvpMode] or QUEUE_STATUSES.UNKNOWN
    if status == QUEUE_STATUSES.DONT_OVERRIDE then
        status = currentStatus
    end
    PvpQueue.currentStatuses[pvpMode] = status
end

function PvpQueue.RoleCheckUpdate(event, updateType, pvpMode)
    local status = PvpQueue.ToQueueStatus(updateType)
    PvpQueue.SetPvpModeStatus(pvpMode, status)
    PvpQueue.Update()
end

function PvpQueue.BattlefieldUpdate(event, updateType, info)
    PvpQueue.SetPvpModeStatus(info.pvpMode, updateType)
    local byPvpMode = modules.Battlefield:ByPvpMode() or {}
    for pvpMode, info in pairs(byPvpMode) do
        local status = PvpQueue.ToQueueStatus(info.status)
        PvpQueue.SetPvpModeStatus(pvpMode, status)
    end
    PvpQueue.Update()
end

function PvpQueue:Init()
    AddonVars.registry:RegisterEvent(modules.RoleCheck.transitionHook, PvpQueue.RoleCheckUpdate)
    AddonVars.registry:RegisterEvent(modules.Battlefield.updateHook, PvpQueue.BattlefieldUpdate)
end
