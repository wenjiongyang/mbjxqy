Require("ServerScript/Battle/BattleMgr.lua")

if not MODULE_ZONESERVER then
	return
end

Battle.tbRoleZoneIndex = Battle.tbRoleZoneIndex or {}; --因为不同服的 角色id是不会相同的

--重载
function Battle:OnStopBattleSignUpEvent()
	CallZoneClientScript(-1, "Battle:OnZoneStopBattleSignUp");
end

--重载
function Battle:OnAllReadyMapCreateEvent()
	CallZoneClientScript(-1, "Battle:OnZoneReadyMapCreate", self.tbReadyMapIds, self.tbReadyMapIndexToBattleLogic, self.tbChangedCalendar);
end

--重载
function Battle:OnPlayedBattleEvnet(pPlayer, bCostTicket)
	self.tbRoleZoneIndex[pPlayer.dwID] = pPlayer.nZoneIndex
	CallZoneClientScript(pPlayer.nZoneIndex, "Battle:OnZoneOnPlayedBattle", pPlayer.dwID, bCostTicket)
end

--重载
function Battle:OnGetAwardEvent(dwRoleId, tbAchievenments, tbAward, tbBattleInfo, szMsg)
	local nZoneIndex = self.tbRoleZoneIndex[dwRoleId]
	if not nZoneIndex then
		Log(debug.traceback(), dwRoleId)
		return
	end
	self.tbRoleZoneIndex[dwRoleId] = nil;
	CallZoneClientScript(nZoneIndex, "Battle:OnGetAwardEvent", dwRoleId, tbAchievenments, tbAward, tbBattleInfo, szMsg)
end

--schedule 接口
function Battle:OpenBattleSignUp(nIndex) --nIndex 是第几个战场图
    local tbReadyMaps = {};
    local tbMapSetting = self.tbMapSetting[nIndex]
    local nExtIndex;
    if not tbMapSetting then
        nIndex = math.floor(nIndex / 100)
        nExtIndex = nIndex % 100;
        tbMapSetting = self.tbMapSetting[nIndex]
        assert(tbMapSetting)
    end

    local tbReadyMapIndexToBattleLogic = {}; --ReadyMap场次对应的比赛类型
    local tbChangedCalendar = {}; --是非常规强制开启的战场模式，这种日历状态不下发

    if tbMapSetting.bZone then --全服跨服
        for i,v in ipairs(Battle.tbHighZoneLevelSetting) do
            table.insert(tbReadyMaps, Battle.ZONE_READY_MAP_ID)
            local tbBattleSetting
            if v.nBattleModeIndex then
                tbBattleSetting = self.tbMapSetting[v.nBattleModeIndex]
                tbChangedCalendar[tbBattleSetting.szLogicClass] = 1;
            else
                tbBattleSetting = tbMapSetting
            end
            table.insert(tbReadyMapIndexToBattleLogic, tbBattleSetting.nIndex)
        end
    else --低阶跨服
        for i,v in ipairs(Battle.tbZoneLevelSetting) do
            table.insert(tbReadyMaps, Battle.ZONE_READY_MAP_ID)
            local tbBattleSetting
            if v.nBattleModeIndex then
                tbBattleSetting = self.tbMapSetting[v.nBattleModeIndex]
                tbChangedCalendar[tbBattleSetting.szLogicClass] = 1;
            else
                tbBattleSetting = tbMapSetting
            end
            table.insert(tbReadyMapIndexToBattleLogic, tbBattleSetting.nIndex)
        end
    end
    tbChangedCalendar[tbMapSetting.szLogicClass] = nil;

    if nExtIndex then
        local nExtBattleIndex = Battle:GetQualifyBattleType()
        if nExtBattleIndex then
            table.insert(tbReadyMaps, Battle.ZONE_READY_MAP_ID)
            table.insert(tbReadyMapIndexToBattleLogic, nExtBattleIndex)
            Log("Battle:OpenBattleSignUp OpenQualifyBattleType", nIndex, nExtBattleIndex)
        end
    end
    self.tbReadyMapIndexToBattleLogic = tbReadyMapIndexToBattleLogic
    self.tbChangedCalendar = tbChangedCalendar;

    self:_OpenBattleSignUp(nIndex, tbReadyMaps)
end

function Battle:GetQualifyBattleType()
	local nNow = GetTime()
	local tbTime = os.date("*t", nNow)
	if tbTime.wday ~= 1 then
		return
	end
	if tbTime.day <= 7 then 
		return Battle.tbAllBattleSetting.BattleMonth.nIndex --每个月的第一个周日是月度
	end

	if tbTime.year == 2017 and tbTime.month == 6 then --6月不开季度赛
		return
	end
		
	local nMonthEndTime = os.time({year = tbTime.year , month = tbTime.month + 1, day = 1, hour = 0, min = 0, sec = 0});
	nMonthEndTime = nMonthEndTime - 3600
	local tbTimeMonthEnd = os.date("*t", nMonthEndTime)
	local nEndDay = tbTimeMonthEnd.day
	if nEndDay - tbTime.day <= 6 then --判断是否是月的最后一个周日
		if tbTime.month == 1 then
			return Battle.tbAllBattleSetting.BattleYear.nIndex
		elseif tbTime.month % 3 == 0 then
			return Battle.tbAllBattleSetting.BattleSeason.nIndex
		end
	end
end

--重载
function Battle:GetCurBattleSetting(nReadyMapIndex)
	if nReadyMapIndex then
		local nIndex = self.tbReadyMapIndexToBattleLogic[nReadyMapIndex]
		return self.tbMapSetting[nIndex]
	end
	return self.tbCurBattleSetting
end

function Battle:OnLeaveZoneBattleMapEvent(pPlayer, nLeftTime)
	local nZoneIndex = self.tbRoleZoneIndex[pPlayer.dwID]
	if not nZoneIndex then
		return
	end
	CallZoneClientScript(nZoneIndex, "Battle:OnLeaveZoneBattleMap", pPlayer.dwID, pPlayer.nMapId,
		nLeftTime);
end

--重载
function Battle:OnGetBattleFirstEnven(dwRoleId, szLogicClass, nReadyMapIndex)
	--第一名有可能掉线了就不单独传tbRoleZoneIndex 了，而且是在发完将后了
	CallZoneClientScript(-1, "Battle:OnGetBattleFirstEnven", dwRoleId, szLogicClass, nReadyMapIndex);
end

--重载
function Battle:StopBattleCalender()
	CallZoneClientScript(-1, "Calendar:OnActivityEnd", self.tbCurBattleSetting.szLogicClass);
end