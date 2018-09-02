
function Battle:OnZoneReadyMapCreate(tbZoneReadyMapIds, tbReadyMapIndexToBattleLogic, tbChangedCalendar)
	--分低阶跨服和全服跨区
	local tbNowOpenZoneSetting = {};
	for i,nSettingIndex in ipairs(tbReadyMapIndexToBattleLogic) do
		tbNowOpenZoneSetting[nSettingIndex] = tbNowOpenZoneSetting[nSettingIndex] or {};
		local nReadyMapId = tbZoneReadyMapIds[i]
		assert(nReadyMapId)
		table.insert(tbNowOpenZoneSetting[nSettingIndex], nReadyMapId)
	end

	for nIndex,v in pairs(tbNowOpenZoneSetting) do
		local tbSetting = self.tbMapSetting[nIndex]	
		if not tbSetting.bZone then
			if GetTimeFrameState(Battle.OpenLowZoneBattleTimeFrame) ~= 1 then
				tbNowOpenZoneSetting[nIndex] = nil;
			end
		end
		if tbSetting.OpenTimeFrame and GetTimeFrameState(tbSetting.OpenTimeFrame) ~= 1 then
			tbNowOpenZoneSetting[nIndex] = nil;
		end
	end

	self.tbNowOpenZoneSetting = tbNowOpenZoneSetting --现在开启的跨服战场种类
	self.tbChangedCalendar = tbChangedCalendar

	self.tbPlayedMapIds = {};   --重连战场地图用
	--因为本区是也有开的所以跨区就不另外推送消息了

end

function Battle:OnZoneStopBattleSignUp()
	if self.tbNowOpenZoneSetting then
		for nSettingIndex, _ in pairs(self.tbNowOpenZoneSetting) do
			local tbBattleSetting = self.tbMapSetting[nSettingIndex]	
			if tbBattleSetting.bZone then --只关闭只是跨服，避免本服的元帅保卫这种被关
				Calendar:OnActivityEnd(tbBattleSetting.szLogicClass)
			end
		end
	end
	Calendar:OnActivityEnd("BattleZone")
	self.tbNowOpenZoneSetting = nil;
	-- self.tbPlayedMapIds = nil; --结束报名后还是有最后一场战场开着的

	
end

function Battle:OnZoneOnPlayedBattle(dwRoleId, bCostTicket)
	local pPlayer = KPlayer.GetPlayerObjById(dwRoleId)
	if not pPlayer then
		Log(debug.traceback(), dwRoleId)
		return
	end
	Battle:OnPlayedBattleEvnet(pPlayer, bCostTicket)
end

function Battle:OnLeaveZoneBattleMap(dwRoleId, nMapId, nLeftTime)
	self.tbPlayedMapIds[dwRoleId] = nMapId
	local tbMsgData = {
		szType = "BackToZoneBattle";
		nTimeOut = GetTime() + nLeftTime;
	};
	Player:SendNotifyMsg(dwRoleId, tbMsgData)
end

function Battle:ReEnterZoneBattle(pPlayer)
	local nMapId = self.tbPlayedMapIds[pPlayer.dwID]
	if not nMapId then
		return
	end
	if not Env:CheckSystemSwitch(pPlayer, Env.SW_SwitchMap) then
    	pPlayer.CenterMsg("目前狀態不允許切換地圖")
	    return
	end
	self.tbPlayedMapIds[pPlayer.dwID] = nil;
	if not pPlayer.SwitchZoneMap(nMapId, 0, 0) then
		pPlayer.CenterMsg("該跨服戰場現在已無法進入", true)
	end
end