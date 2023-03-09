local AddonName, AddonVars = ...
local util = AddonVars.util
local dump = util.dump
local modules = AddonVars.modules
local PvpModes = {}
modules.PvpModes = PvpModes

local SOLO_SHUFFLE = 'Rated Solo Shuffle'
local ARENA_2V2 = 'Rated 2v2 Arena'
local ARENA_3V3 = 'Rated 3v3 Arena'
local RBG = 'Rated Battleground'
local UNKNOWN = 'Unknown'
PvpModes.SOLO_SHUFFLE = SOLO_SHUFFLE
PvpModes.ARENA_2V2 = ARENA_2V2
PvpModes.ARENA_3V3 = ARENA_3V3
PvpModes.RBG = RBG
PvpModes.UNKNOWN = UNKNOWN
PvpModes.IDS = {
    SOLO_SHUFFLE = SOLO_SHUFFLE,
    ARENA_2V2 = ARENA_2V2,
    ARENA_3V3 = ARENA_3V3,
    RBG = RBG,
    UNKNOWN = UNKNOWN,
}
for _, identifier in pairs(PvpModes.IDS) do
    PvpModes[identifier] = {}
end

