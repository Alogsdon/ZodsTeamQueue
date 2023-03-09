local AddonName, AddonVars = ...
local util = AddonVars.util
local dump = util.dump
local modules = AddonVars.modules
modules.RoleCheck = {}
local RoleCheck = modules.RoleCheck

local STATUSES = {
    NONE = 'NONE',
    ONGOING = 'ONGOING',
    COMPLETED = 'COMPLETED',
}
RoleCheck.statuses = STATUSES

local UPDATE_TYPES = {
    INITIATED = 'initiated',
    CANCELLED = 'cancelled',
    QUEUED = 'queued',
}
RoleCheck.updateTypes = UPDATE_TYPES

RoleCheck.currentCheck = {
    pvpMode = modules.PvpModes.IDS.ARENA_2V2,
    time = 0,
    status = STATUSES.NONE,
    members = {player = {name = 'zod', time = 0, accepted = false}}
}

RoleCheck.transitionHook = 'ROLE_CHECK_UPDATE_HOOK' --PDATE_TYPES.INITIATED, pvpMode
RoleCheck.memberUpdateHook = 'ROLE_CHECK_MEMBER_UPDATE_HOOK' -- RoleCheck.currentCheck

function RoleCheck.IsDiff()
    RoleCheck.lastCheck = RoleCheck.lastCheck or {}
    RoleCheck.currentCheck = RoleCheck.currentCheck or {}
    local last = RoleCheck.lastCheck
    local current = RoleCheck.currentCheck
    local diff = false

    if current.pvpMode ~= last.pvpMode then diff = true end
    last.pvpMode = current.pvpMode

    if current.time ~= last.time then diff = true end
    last.time = current.time

    if current.status ~= last.status then diff = true end
    last.status = current.status

    last.members = last.members or {}
    local tempMembers = {}
    for unitId, unitInfo in pairs(current.members) do
        tempMembers[unitId] = {}
        local lastMember = last.members[unitId] or {}
        for key, value in pairs(unitInfo) do
            tempMembers[unitId][key] = value
            if value ~= lastMember[key] then diff = true end
        end
    end
    for key in pairs(last.members) do
        if (current.members[key] == nil) then diff = true end
    end
    last.members = tempMembers

    return diff
end

function RoleCheck.CheckDiffAndFire()
    local diff = RoleCheck.IsDiff()
    if diff then
        AddonVars.registry:FireEvent(RoleCheck.memberUpdateHook, RoleCheck.currentCheck)
    end
end
--AddonVars.registry:RegisterEvent(RoleCheck.transitionHook, RoleCheck.CheckDiffAndFire)

function RoleCheck.RoleChosen(event, playerName)
    RoleCheck.IncludeMembers()
    -- TODO fix this.
    local found = false
    for _, info in pairs(RoleCheck.currentCheck.members) do
        if info.name == playerName then
            found = true
            info.accepted = true
            info.time = GetTime()
        end
    end
    if not found then error('why we no find man '..playerName) end

    RoleCheck.CheckDiffAndFire()
end
AddonVars.registry:RegisterEvent('LFG_ROLE_CHECK_ROLE_CHOSEN', RoleCheck.RoleChosen)

function RoleCheck.Adjust()
    RoleCheck.AdjustMembers()
end

function RoleCheck.AdjustMembers()
    RoleCheck.PurgeMissingMembers()
    RoleCheck.IncludeMembers()
end

function RoleCheck.IncludeMembers()
    RoleCheck.IncludeMember('player')
    for i = 2, GetNumGroupMembers() do
        RoleCheck.IncludeMember('party' .. tostring(i-1))
    end
end

function RoleCheck.IncludeMember(unitId)
    RoleCheck.currentCheck.members[unitId] = RoleCheck.currentCheck.members[unitId] or {}
    local member = RoleCheck.currentCheck.members[unitId]
    local name = UnitName(unitId)
    name = strsplit('-', name)
    member.name = name
    member.accepted = member.accepted or false
    member.time = member.time or 0
end

function RoleCheck.PurgeMissingMembers()
    local keepers = {player = true}
    for i = 2, GetNumGroupMembers() do
        local unitId = 'party' .. tostring(i-1)
        keepers[unitId] = true
    end
    local pidsToPurge = {}
    for pid in pairs(RoleCheck.currentCheck.members) do
        if not keepers[pid] then pidsToPurge[pid] = true end
    end
    for pid in pairs(pidsToPurge) do
        RoleCheck.currentCheck.members[pid] = nil
    end
end

local timeDiffThresh = 2
function RoleCheck.ResetOldAccepteds()
    local checkStarted = RoleCheck.currentCheck.time
    for pid, info in pairs(RoleCheck.currentCheck.members) do
        local thisTime = info.time or 0
        if checkStarted - thisTime > timeDiffThresh then info.accepted = false end
    end
end

local ROLE_INIT_MSG = 'ERR_LFG_ROLE_CHECK_INITIATED'
local GROUP_JOIN_MSG = 'ERR_GROUP_JOIN_BATTLEGROUND_S'
local SOLO_JOIN_MSG = 'ERR_SOLO_JOIN_BATTLEGROUND_S'
function RoleCheck.UiInfoMessage(event, messageNum)
    local msgKey = GetGameMessageInfo(messageNum)
    if msgKey == ROLE_INIT_MSG then
        RoleCheck.Initiated()
    end
    if msgKey == GROUP_JOIN_MSG or msgKey == SOLO_JOIN_MSG then
        RoleCheck.Queued()
    end
end
AddonVars.registry:RegisterEvent('UI_INFO_MESSAGE', RoleCheck.UiInfoMessage)

function RoleCheck.Initiated()
    RoleCheck.currentCheck.time = GetTime()
    RoleCheck.Adjust()
    RoleCheck.ResetOldAccepteds()
    local pvpMode = RoleCheck.currentCheck.pvpMode
    AddonVars.registry:FireEvent(RoleCheck.transitionHook, UPDATE_TYPES.INITIATED, pvpMode)
end

function RoleCheck.UpdatePvPMode(event, pvpMode)
    RoleCheck.currentCheck.pvpMode = pvpMode
end
AddonVars.registry:RegisterEvent(modules.CurrentActivity.updateHook, RoleCheck.UpdatePvPMode)

--updateType, pvpMode
function RoleCheck.Queued()
    RoleCheck.currentCheck.status = STATUSES.COMPLETED
    local pvpMode = RoleCheck.currentCheck.pvpMode
    AddonVars.registry:FireEvent(RoleCheck.transitionHook, UPDATE_TYPES.QUEUED, pvpMode)
end

function RoleCheck.Declined()
    RoleCheck.currentCheck.status = STATUSES.NONE
    local pvpMode = RoleCheck.currentCheck.pvpMode
    AddonVars.registry:FireEvent(RoleCheck.transitionHook, UPDATE_TYPES.CANCELLED, pvpMode)
end
AddonVars.registry:RegisterEvent('LFG_ROLE_CHECK_DECLINED', RoleCheck.Declined)


