
Activity.tbBase = Activity.tbBase or {}

local tbBase = Activity.tbBase;

function tbBase:Init(szType, szKeyName, ...)
	self.szType = szType;
	self.szKeyName = szKeyName;
	self.tbParam = {...}
end

function tbBase:OnPlayerEvent(pPlayer, szEventType, szFunc, ...)
	if not self[szFunc] then
		Log("[Activity] OnPlayerEvent ERR ?? Unknow PlayerEvent Func", szEventType, szFunc, pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, ...);
		return;
	end

	self[szFunc](self, pPlayer, ...);
end

function tbBase:OnGlobalEvent(szEventType, szFunc, ...)
    if not self[szFunc] then
        Log("[Activity] OnGlobalEvent ERR ?? Unknow GlobalEvent Func", szEventType, szFunc, ...)
        return
    end

    self[szFunc](self, ...)
end

function tbBase:GetOpenTimeInfo()
    local nStartTime, nEndTime = Activity:__GetActTimeInfo(self.szKeyName)
    return nStartTime, nEndTime
end

function tbBase:RegisterDataInPlayer(nTimeout)
	Activity:__RegisterPlayerActivityData(self.szKeyName, nTimeout);
end

function tbBase:SaveDataToPlayer(pPlayer, tbValue)
	Activity:__SetPlayerActivityData(self.szKeyName, pPlayer, tbValue);
end

function tbBase:GetDataFromPlayer(nPlayerId)
	return Activity:__GetPlayerActivityData(self.szKeyName, nPlayerId);
end

