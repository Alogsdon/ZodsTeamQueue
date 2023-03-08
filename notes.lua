

--[[
    EVENTS
UI_INFO_MESSAGE -- arg 803
814, you are no longer queued


PLAYER_ENTERING_WORLD
PLAYER_ENTERING_BATTLEGROUND

LFG_ROLE_CHECK_ROLE_CHOSEN
local player, isTank, isHealer, isDamage = ...
LFG_ROLE_CHECK_UPDATE
both fire

PVPReadyDialog:HookScript("OnShow", function() print('YOYOYO') end)

GetGameMessageInfo(803) => 'ERR_LFG_ROLE_CHECK_INITIATED'
_G[GetGameMessageInfo(803)] => "A role check has been initiated...."
ERR_LFG_CANT_USE_BATTLEGROUND = '
'

/run for k,v in pairs(_G) do if string.match(k, '^ERR_LFG_CANT_USE_') then DevTools_Dump({k,v}) end end

/run for i=1,7 do DevTools_Dump(GetLFGMode(i)) end

mode, submode = GetLFGMode(lELfgCategory, lfgID)


local roleCheckInProgress, slots, members, roleUpdateCategory, roleUpdateID = GetLFGRoleUpdate()

GetLFGRoleUpdateBattlegroundInfo()
LFG_CATEGORY_NAMES = {
    [lELfgCategory] = 'readble'.
    [7] = 'Brawl'
}
lELfgCategories = {
    LE_LFG_CATEGORY_LFD = 1,
    LE_LFG_CATEGORY_LFR = 2,
    LE_LFG_CATEGORY_RF = 3,
    LE_LFG_CATEGORY_SCENARIO = 4,
    LE_LFG_CATEGORY_FLEXRAID = 5,
    LE_LFG_CATEGORY_WORLDPVP = 6,
    LE_LFG_CATEGORY_BATTLEFIELD = 7,
}

-- table assumbed global
hooksecurefunc("PVPReadyDialog_Display", function()
        PlaySound(5980, 'Master')
end)

btw, other use is with a table
hooksecurefunc(GameTooltip, "SetUnitAura", setAuraTooltipFunction)


	local inProgress, _, _, _, _, isBattleground = GetLFGRoleUpdate();
	if ( inProgress and isBattleground ) then
		QueueStatusDropDown_AddPVPRoleCheckButtons();
	end

	for i=1, GetMaxBattlefieldID() do
		local status, mapName, teamSize, registeredMatch = GetBattlefieldStatus(i);
        -- status {'queued', 'none', 'confirm'}
		if ( status and status ~= "none" ) then
			QueueStatusDropDown_AddBattlefieldButtons(i);
		end
	end
]]

