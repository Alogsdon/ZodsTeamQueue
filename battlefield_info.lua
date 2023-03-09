local AddonName, AddonVars = ...
local util = AddonVars.util
local dump = util.dump

local GetMaxBattlefieldID = GetMaxBattlefieldID
local GetBattlefieldStatus = GetBattlefieldStatus

AddonVars.modules.Battlefield = {}
local Battlefield = AddonVars.modules.Battlefield

-- statuses as GetBattlefieldStatus returns
local STATUSES = {
    NONE = 'none', -- stays here until queued
    QUEUED = 'queued',
    CONFIRM = 'confirm', -- I think this is when it actually pops
    ACTIVE = 'active', -- when you're inside, others go back to queued
}
Battlefield.statuses = STATUSES

local UPDATE_TYPES = {
    QUEUED = 'queued',
    DROPPED = 'dropped',
    POPPED = 'popped',
    ENTERED = 'entered',
    LEFT = 'left',
}
Battlefield.updateTypes = UPDATE_TYPES

-- as returned by GetBattlefieldStatus, param 6. I think with teamsize, we can unique map to pvp mode
local QUEUE_TYPES = {
    RATEDSHUFFLE = 'RATEDSHUFFLE',
    BATTLEGROUND = 'BATTLEGROUND',
    ARENA = 'ARENA',
    ARENASKIRMISH = 'ARENASKIRMISH',
    WARGAME = 'WARGAME'
}
Battlefield.queueTypes = QUEUE_TYPES

local IDS = AddonVars.modules.PvpModes.IDS
local SOLO_SHUFFLE = IDS.SOLO_SHUFFLE
local ARENA_2V2 = IDS.ARENA_2V2
local ARENA_3V3 = IDS.ARENA_3V3
local RBG = IDS.RBG
local UNKNOWN = IDS.UNKNOWN
local PVP_MODE_MAP = { -- [queueType][size]
    [QUEUE_TYPES.RATEDSHUFFLE] = { [0] = SOLO_SHUFFLE },
    [QUEUE_TYPES.ARENA] = { [2] = ARENA_2V2, [3] = ARENA_3V3 },
    -- TODO not sure about RBGS what is teamSize and queueType for RBGS GetBattlefieldStatus
}

-- API

function Battlefield:GetActive()
    return self:FirstByStatus(STATUSES.ACTIVE)
end

function Battlefield:GetReady()
    return self:FirstByStatus(STATUSES.CONFIRM)
end

-- should be unique, at least for ranked
function Battlefield:ByPvpMode()
    return self.byPvpMode
end

Battlefield.updateHook = 'BATTLEFIELD_UPDATED_HOOK' -- updateType, info

-- rest is mostly private-ish

function Battlefield.CreateBattleFieldInfoForIndex(i)
    local status, mapName, teamSize, rated, _, queueType = GetBattlefieldStatus(i)
    if (not status) or (status == STATUSES.NONE) then return end
    local byTeamSize = PVP_MODE_MAP[queueType] or {}
    local pvpMode = byTeamSize[teamSize] or UNKNOWN
    local info = {
        status = status,
        mapName = mapName,
        teamSize = teamSize,
        rated = rated,
        queueType = queueType,
        index = i,
        pvpMode = pvpMode,
    }
    return info
end

function Battlefield:FirstByStatus(status)
    if not self.byStatus then return end

    local infos = self.byStatus[status]
    if infos then
        for info in pairs(infos) do
            return info
        end
    end
end

function Battlefield:ResetInfoCaches()
    self.lastByIndex = self.byIndex or {}
    self.byIndex = {}

    self.byStatus = {}
    for _, v in pairs(STATUSES) do
        self.byStatus[v] = {}
    end

    self.byPvpMode = {}
end

function Battlefield:CacheInfo(info)
    Battlefield.byIndex[info.index] = info

    local t = Battlefield.byStatus[info.status]
    if t then
        t[info] = true
    else
        dump('we found an unrecognized status: ' .. info.status)
    end
    if info.pvpMode then
        Battlefield.byPvpMode[info.pvpMode] = info
    end
end

function Battlefield.checkDiffAndFire(lastInfo, newInfo)
    if (lastInfo) and (not newInfo) then
        AddonVars.registry:FireEvent(Battlefield.updateHook, UPDATE_TYPES.DROPPED, lastInfo)
    end

    -- need nil safety for the rest
    lastInfo = lastInfo or {}
    newInfo = newInfo or {}
    if (not lastInfo.status) and (newInfo.status == STATUSES.QUEUED) then
        AddonVars.registry:FireEvent(Battlefield.updateHook, UPDATE_TYPES.QUEUED, newInfo)
    end

    if (lastInfo.status ~= STATUSES.CONFIRM) and (newInfo.status == STATUSES.CONFIRM) then
        AddonVars.registry:FireEvent(Battlefield.updateHook, UPDATE_TYPES.POPPED, newInfo)
    end

    if (lastInfo.status ~= STATUSES.ACTIVE) and (newInfo.status == STATUSES.ACTIVE) then
        AddonVars.registry:FireEvent(Battlefield.updateHook, UPDATE_TYPES.ENTERED, newInfo)
    end

    if (lastInfo.status == STATUSES.ACTIVE) and (newInfo.status ~= STATUSES.ACTIVE) then
        AddonVars.registry:FireEvent(Battlefield.updateHook, UPDATE_TYPES.LEFT, lastInfo)
    end
end

function Battlefield.Update(event, ...)
    Battlefield:ResetInfoCaches()
    for i=1, GetMaxBattlefieldID() do
        local info = Battlefield.CreateBattleFieldInfoForIndex(i)
        if info then
            Battlefield:CacheInfo(info)
        end
	end
    if event == 'UPDATE_BATTLEFIELD_STATUS' then
        local updatedIndex = ...
        local lastInfo = Battlefield.lastByIndex[updatedIndex]
        local newInfo = Battlefield.byIndex[updatedIndex]
        Battlefield.checkDiffAndFire(lastInfo, newInfo)
    else
        for i=1, GetMaxBattlefieldID() do
            local lastInfo = Battlefield.lastByIndex[i]
            local newInfo = Battlefield.byIndex[i]
            Battlefield.checkDiffAndFire(lastInfo, newInfo)
        end
    end
end

local updateEvents = {
    'UPDATE_BATTLEFIELD_STATUS',
    'ZONE_CHANGED_NEW_AREA',
    'ZONE_CHANGED',
    'PLAYER_ENTERING_WORLD',
}
AddonVars.registry:RegisterEvent(updateEvents, Battlefield.Update)

