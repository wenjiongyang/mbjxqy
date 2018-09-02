function ImperialTomb:Init()
	self.tbMapList = {}
	self.tbNormalMapList = {}
	self.tbSecretMapList = {}
	self.tbEmperorMapList = {}
	self.tbBossMapList = {}
	self.tbEmperorMirrorMapList = {}
	self.tbSecretInviteList = {}
	self:ClearBossData()
	self:ClearEmperorData()


	local fnOnCreate = function (tbMap, nMapId)
		local tbInfo = self.tbMapList[nMapId];
		if tbInfo then
			tbInfo.bCreated = true;
			self:OnMapCreate(tbMap.nMapTemplateId, nMapId, tbInfo.nType);
		else
			Log("[Error]", "ImperialTomb", "create map but not found info", tbMap.nMapTemplateId, nMapId)
		end
	end

	local fnOnDestroy = function (tbMap, nMapId)
		local tbInfo = self.tbMapList[nMapId];
		if tbInfo then
			self:OnMapClose(tbMap.nMapTemplateId, nMapId, tbInfo.nType);
		else
			Log("[Error]", "ImperialTomb", "destroy map but not found info", tbMap.nMapTemplateId, nMapId)
		end
	end

	local fnOnEnter = function (tbMap, nMapId)
		local tbInfo = self.tbMapList[nMapId];
		if tbInfo then
			self:OnEnterMap(tbMap.nMapTemplateId, nMapId, tbInfo.nType, tbInfo.nParam);
		else
			Log("[Error]", "ImperialTomb", "enter map but not found info", tbMap.nMapTemplateId, nMapId)
		end

	end

	local fnOnLogin = function (tbMap, nMapId)
		local tbInfo = self.tbMapList[nMapId];
		if tbInfo then
			self:OnLoginMap(tbMap.nMapTemplateId, nMapId, tbInfo.nType, tbInfo.nParam);
		else
			Log("[Error]", "ImperialTomb", "login map but not found info", tbMap.nMapTemplateId, nMapId)
		end
	end

	local fnOnLeave = function (tbMap,nMapId)
		local tbInfo = self.tbMapList[nMapId];
		if tbInfo then
			self:OnLeaveMap(tbMap.nMapTemplateId, nMapId, tbInfo.nType);
		else
			Log("[Error]", "ImperialTomb", "leave map but not found info", tbMap.nMapTemplateId, nMapId)
		end
	end

	local fnOnTrap = function (tbMap, nMapId, szClassName)
		local tbInfo = self.tbMapList[nMapId];
		if tbInfo then
			self:OnMapTrap(tbMap.nMapTemplateId, nMapId, tbInfo.nType, szClassName);
		else
			Log("[Error]", "ImperialTomb", "trap map but not found info", tbMap.nMapTemplateId, nMapId)
		end
	end

	for _,nType in pairs(self.MAP_TYPE) do
		local tbMapClass = Map:GetClass(self.MAP_TEMPLATE_ID[nType]);
		tbMapClass.OnCreate = fnOnCreate;
		tbMapClass.OnDestroy = fnOnDestroy;
		tbMapClass.OnEnter = fnOnEnter;
		tbMapClass.OnLogin = fnOnLogin;
		tbMapClass.OnLeave = fnOnLeave;
		tbMapClass.OnPlayerTrap = fnOnTrap;
	end

	self:CreateRequest(self.MAP_TYPE.FIRST_FLOOR);
	self:CreateRequest(self.MAP_TYPE.SECOND_FLOOR);
	self:CreateRequest(self.MAP_TYPE.THIRD_FLOOR);

	self:CreateRequest(self.MAP_TYPE.SECRET_ROOM_FIRST_FLOOR);
	self:CreateRequest(self.MAP_TYPE.SECRET_ROOM_SECOND_FLOOR);
	self:CreateRequest(self.MAP_TYPE.SECRET_ROOM_THIRD_FLOOR);

	self:CreateRequest(self.MAP_TYPE.FEMALE_EMPEROR_FLOOR);

	self.nCheckStayTimer = Timer:Register(Env.GAME_FPS * self.CHECK_STAY_INTERVAL, self.OnCheckStayTime, self);
	self.nSecretSpawnTimer = Timer:Register(Env.GAME_FPS * self.SECRET_ROOM_SPAWN_INTERVAL, self.OnSpawnSecret, self);


	PlayerEvent:RegisterGlobal("OnLevelUp", ImperialTomb.OnPlayerLevelup,ImperialTomb);

	if GetTimeFrameState(self.OPEN_TIME_FRAME) == 1 and self:CheckEnterTime() then
		self:Open()
	end
end

function ImperialTomb:Open()
	Calendar:OnActivityBegin("ImperialTomb")

	local nOpenServerTime = CalcTimeFrameOpenTime(self.OPEN_TIME_FRAME)
	local nOpenServerDay = Lib:GetLocalDay(nOpenServerTime)
	local nToday = Lib:GetLocalDay()
	if nOpenServerDay == nToday then
		local tbMail =
		{
			Title = '寶珠贈俠士',
			Text = [[    秦始皇陵重現于世，古秦士卒四起傷人，各位於皇陵出現時等級已達60級，特贈[FFFE0D]「夜明珠」[-]一顆，此物有避毒功效，始皇降世時，唯有攜此物方可前往皇陵。還望諸位能夠除此禍害，還江湖平靜。若仍有不解之處，可通過下方連結前往查看説明。
                                     查看活動：[47f005][url=openwnd:秦始皇陵, CalendarPanel, 1, 37][-]
                                     查看活動：[47f005][url=openwnd:始皇降世, CalendarPanel, 1, 38][-] ]],
			From = '獨孤劍',
			LevelLimit = ImperialTomb.MIN_LEVEL,
			tbAttach = {{'item', ImperialTomb.EMPEROR_NEED_ITEM, 1}},
			nLogReazon = Env.LogWay_ImperialTomb_Send_Ticket,
		};

		Mail:SendGlobalSystemMail(tbMail);
	end
end

function ImperialTomb:Close()
	self:TransferAllPlayerOut();
	Calendar:OnActivityEnd("ImperialTomb")
end

function ImperialTomb:CreateRequest(nMapType, nParam)
	if not self:CheckMapCountLimit(nMapType) then
		Log("[Error]", "ImperialTomb", "CreateRequest Map Reach Count Limit", nMapType)
		return false
	end

	local nMapTemplateId =  self.MAP_TEMPLATE_ID[nMapType]

	local nMapId = CreateMap(nMapTemplateId);

	local tbInfo =
	{
		nMapId = nMapId,
		nMapTemplateId = nMapTemplateId,
		nType = nMapType,
		bCreated = false,
		nParam = nParam,
	}

	self.tbMapList[nMapId] = tbInfo;

	if self:IsNormalMapByType(nMapType) then
		self.tbNormalMapList[nMapType] = tbInfo
	elseif self:IsSecretMapByType(nMapType) then
		self.tbSecretMapList[nMapType] = tbInfo
	elseif nMapType == self.MAP_TYPE.EMPEROR_ROOM or  nMapType == self.MAP_TYPE.FEMALE_EMPEROR_ROOM then
		self.tbEmperorMapList[nMapId] = tbInfo
	elseif nMapType == self.MAP_TYPE.BOSS_ROOM or  nMapType == self.MAP_TYPE.FEMALE_EMPEROR_BOSS_ROOM then
		self.tbBossMapList[nMapId] = tbInfo
	elseif nMapType == self.MAP_TYPE.EMPEROR_MIRROR_ROOM or nMapType == self.MAP_TYPE.FEMALE_EMPEROR_MIRROR_ROOM then
		self.tbEmperorMirrorMapList[nMapId] = tbInfo
	end

	Log("[Info]", "ImperialTomb", "CreateRequest Map Success", nMapId, nMapTemplateId, nMapType)

	return true, tbInfo;
end

function ImperialTomb:CheckMapCountLimit(nMapType)
	if self:IsNormalMapByType(nMapType) then
		return not self.tbNormalMapList[nMapType]
	elseif self:IsSecretMapByType(nMapType) then
		return true
	elseif nMapType == self.MAP_TYPE.EMPEROR_ROOM or  nMapType == self.MAP_TYPE.FEMALE_EMPEROR_ROOM then
		return Lib:CountTB(self.tbEmperorMapList) < self.EMPEROR_COUNT
	elseif nMapType == self.MAP_TYPE.BOSS_ROOM then
		return Lib:CountTB(self.tbBossMapList) < self.BOSS_COUNT
	elseif nMapType == self.MAP_TYPE.FEMALE_EMPEROR_BOSS_ROOM then
		return Lib:CountTB(self.tbBossMapList) < self.FEMALE_EMPEROR_BOSS_COUNT
	elseif nMapType == self.MAP_TYPE.EMPEROR_MIRROR_ROOM or nMapType == self.MAP_TYPE.FEMALE_EMPEROR_MIRROR_ROOM then
		return true
	end

	return false;
end

function ImperialTomb:OnMapCreate(nMapTemplateId, nMapId, nType)
	Log("[Info]", "ImperialTomb", "OnMapCreate", nMapTemplateId, nMapId, nType)
	if nType == self.MAP_TYPE.EMPEROR_ROOM or  nType == self.MAP_TYPE.FEMALE_EMPEROR_ROOM then
		SetMapSurvivalTime(nMapId, GetTime()+self.EMPEROR_EXSIT_TIME*2)
	elseif nType == self.MAP_TYPE.BOSS_ROOM or  nType == self.MAP_TYPE.FEMALE_EMPEROR_BOSS_ROOM then
		SetMapSurvivalTime(nMapId, GetTime()+self.BOSS_EXSIT_TIME*2)
	elseif nType == self.MAP_TYPE.EMPEROR_MIRROR_ROOM  or nType == self.MAP_TYPE.FEMALE_EMPEROR_MIRROR_ROOM then
		self:OnEmperorMirrorMapCreate(nMapTemplateId, nMapId, nType)
	end
end

function ImperialTomb:OnMapClose(nMapTemplateId, nMapId, nType)
	self:TransMapPlayer(nMapId)

	if self:IsNormalMapByType(nType) then
		self.tbNormalMapList[nType] = nil
	elseif self:IsSecretMapByType(nType) then
		self.tbSecretMapList[nType] = nil
	elseif nType == self.MAP_TYPE.EMPEROR_ROOM or  nType == self.MAP_TYPE.FEMALE_EMPEROR_ROOM then
		self.tbEmperorMapList[nMapId] = nil
	elseif nType == self.MAP_TYPE.BOSS_ROOM or nType == self.MAP_TYPE.FEMALE_EMPEROR_BOSS_ROOM then
		self.tbBossMapList[nMapId] = nil
	elseif nType == self.MAP_TYPE.EMPEROR_MIRROR_ROOM or nType == self.MAP_TYPE.FEMALE_EMPEROR_MIRROR_ROOM then
		self.tbEmperorMirrorMapList[nMapId] = nil
	end

	self.tbMapList[nMapId] = nil;

	Log("[Info]", "ImperialTomb", "OnMapClose", nMapTemplateId, nMapId, nType)
end

function ImperialTomb:OnEnterAllMap(nMapTemplateId, nMapId)
	if MODULE_ZONESERVER then
		return
	end

	--Log("[Info]", "ImperialTomb", "OnEnterAllMap", nMapTemplateId, nMapId, nType)

	--如果从皇陵的地图离开
	if me.nLastLeaveMap and self:IsTombMap(me.nLastLeaveMap) and not self.tbMapList[nMapId] then
		me.ClearTempRevivePos();
		if me.nEnterImperialTombTime then
			local nTime = GetTime() - me.nEnterImperialTombTime
			local nLogWay = Env.LogWay_ImperialTomb_Normal_Attend
			if self.bOpenEmperor then
				nLogWay = Env.LogWay_ImperialTomb_Emperor_Attend
			end

			me.TLogRoundFlow(nLogWay,
				 me.nMapTemplateId,
				 0,
				 nTime,
				 0 ,
				 0,
				 0);
		end
		Log("[Info]", "ImperialTomb", "OnEnterAllMap", nMapTemplateId, nMapId, nType)
	elseif not me.nLastLeaveMap and not self.tbMapList[nMapId] then

	end
end

function ImperialTomb:OnEnterMap(nMapTemplateId, nMapId, nType, nParam)
	Log("[Info]", "ImperialTomb", "OnEnterMap", nMapTemplateId, nMapId, nType, nParam)

	me.SetPkMode(Player.MODE_PK);
	me.bOpenComboSkill = true;
	if self.bOpenEmperor then
		if self.bOpenFemaleEmperor then
			me.szComboSkillFun = "FemaleImperialTomb";
		else
			me.szComboSkillFun = "ImperialTomb";
		end
	end

	local tbEnterPos = nil
	local nEmperorRecordRoom = nil

	if self:IsNormalMapByType(nType) then
		local nRevMapId, nX , nY = self:GetDefaultPos(nType)
		if nType == self.MAP_TYPE.FEMALE_EMPEROR_FLOOR and me.nFightMode == 0 then
			nRevMapId, nX , nY = me.GetWorldPos()
		end
		me.SetTempRevivePos(nRevMapId, nX , nY, 0);
		if nType == self.MAP_TYPE.THIRD_FLOOR then
			local tbLastRoomInfo = self.tbPlayerEmperorRoomList[me.dwID]
			nEmperorRecordRoom = tbLastRoomInfo and tbLastRoomInfo[2]
		end
	elseif self:IsSecretMapByType(nType) then
		self:OnEnterSecretRoom(me)
		self:SyncSecretRoomTime(me)
		self:SyncSecretRoomProtectTime(me)
		self:SyncSecretRoomSpawnTime(me)
	elseif nType == self.MAP_TYPE.EMPEROR_ROOM or nType == self.MAP_TYPE.FEMALE_EMPEROR_ROOM then
		self:SyncEmperorTime(me)
		self:SynEmperorDmgInfo(me)
		local nRevMapId, nX , nY = self:GetDefaultPos(self.MAP_TYPE.THIRD_FLOOR)
		if nType == self.MAP_TYPE.FEMALE_EMPEROR_ROOM then
			nRevMapId, nX , nY = me.GetWorldPos()
			self:ForceSyncSweepNpc(me, nMapId)
		end
		me.SetTempRevivePos(nRevMapId, nX , nY, 0);

		self:RecordPlayerEmperorRoom(me, nMapId, nParam)

		local szMsg = self.EMPEROR_MIRROR_OUT_MSG[self.bOpenFemaleEmperor]
		if me.nLastLeaveMap and (self:IsEmperorMirrorMapByTemplate(me.nLastLeaveMap) or self:IsFemaleEmperorMirrorMapByTemplate(me.nLastLeaveMap)) then
			me.SendBlackBoardMsg(szMsg)
			me.Msg(szMsg)
		end

		local nTrapId = self:GetTrapIdFromIndex(nParam)

		tbEnterPos = {self:GetTrapInfoFromId(nTrapId)}

	elseif nType == self.MAP_TYPE.BOSS_ROOM or nType == self.MAP_TYPE.FEMALE_EMPEROR_BOSS_ROOM then
		self:SyncBossTime(me)
		self:SynBossDmgInfo(me, nMapId)

		local nTrapId = self:GetBossTrapIdFromIndex(nParam)

		tbEnterPos = {self:GetBossTrapInfoFromId(nTrapId)}

		if nType == self.MAP_TYPE.FEMALE_EMPEROR_BOSS_ROOM then
			local nRevMapId, nX , nY = self:GetDefaultPos(self.MAP_TYPE.FEMALE_EMPEROR_FLOOR)
			local nEnterIndex = self.FEMALE_EMPEROR_BOSS_TRAP_2_ENTER_INDEX[nTrapId] or 1
			nX = self.FEMALE_EMPEROR_FLOOR_ENTER_POS[nEnterIndex][1]
			nY = self.FEMALE_EMPEROR_FLOOR_ENTER_POS[nEnterIndex][2]

			me.SetTempRevivePos(nRevMapId, nX , nY, 0);
		end

	elseif nType == self.MAP_TYPE.EMPEROR_MIRROR_ROOM  or nType == self.MAP_TYPE.FEMALE_EMPEROR_MIRROR_ROOM then
		self:SyncEmperorMirrorTime(me)
		self:SynEmperorDmgInfo(me)

		Env:SetSystemSwitchOff(me, Env.SW_All)

		local nX , nY = Map:GetDefaultPos(nMapTemplateId)
		me.SetTempRevivePos(nMapId, nX , nY, 0);
		me.nImperialTombReviveCount = 0;

		local szMsg = self.EMPEROR_MIRROR_IN_MSG[self.bOpenFemaleEmperor]
		me.SendBlackBoardMsg(szMsg)
		me.Msg(szMsg)
	end

	me.nLastRefreshStayTime = GetTime();

	if me.nOnDeathImperialTomb then
		PlayerEvent:UnRegister(me, "OnDeath", me.nOnDeathImperialTomb);
		me.nOnDeathImperialTomb = nil
	end

	me.nOnDeathImperialTomb = PlayerEvent:Register(me, "OnDeath", self.OnPlayerDeath, self);
	me.CallClientScript("ImperialTomb:OnEnter", nMapTemplateId, nMapId, nType, self.bOpenEmperor, self.bOpenFemaleEmperor, self.bCallEmperor, nParam, tbEnterPos, nEmperorRecordRoom)
end

function ImperialTomb:OnLeaveMap(nMapTemplateId, nMapId, nType)
	Log("[Info]", "ImperialTomb", "OnLeaveMap", nMapTemplateId, nMapId, nType)

	me.SetPkMode(Player.MODE_PEACE);
	me.bOpenComboSkill = false;
	me.szComboSkillFun = nil;

	self:RefreshStayTime(me)

	Env:SetSystemSwitchOn(me, Env.SW_All);

	if nType == self.MAP_TYPE.EMPEROR_ROOM or nType == self.MAP_TYPE.FEMALE_EMPEROR_ROOM  then
	elseif nType == self.MAP_TYPE.EMPEROR_MIRROR_ROOM or nType == self.MAP_TYPE.FEMALE_EMPEROR_MIRROR_ROOM then
		self:OnLeaveMirrorRoom(me, nMapId)
	end

	if me.nOnDeathImperialTomb then
		PlayerEvent:UnRegister(me, "OnDeath", me.nOnDeathImperialTomb);
		me.nOnDeathImperialTomb = nil
	end
	
	self:ClearDeathState(me);

	--me.CallClientScript("ImperialTomb:OnLeave")
end

--只有在皇陵地图里登录才会调到这里
function ImperialTomb:OnLoginMap(nMapTemplateId, nMapId, nType, nParam)
	Log("[Info]", "ImperialTomb", "OnLoginMap", nMapTemplateId, nMapId, nType, nParam)

	local tbEnterPos = nil
	local nEmperorRecordRoom = nil

	if self:IsSecretMapByType(nType) then
		self:SyncSecretRoomTime(me)
		self:SyncSecretRoomProtectTime(me)
		self:SyncSecretRoomSpawnTime(me)

	elseif nType == self.MAP_TYPE.EMPEROR_ROOM or nType == self.MAP_TYPE.FEMALE_EMPEROR_ROOM then
		self:SyncEmperorTime(me)
		self:SynEmperorDmgInfo(me)

		local nTrapId = self:GetTrapIdFromIndex(nParam)

		tbEnterPos = {self:GetTrapInfoFromId(nTrapId)}

	elseif nType == self.MAP_TYPE.BOSS_ROOM or nType == self.MAP_TYPE.FEMALE_EMPEROR_BOSS_ROOM then
		self:SyncBossTime(me)
		self:SynBossDmgInfo(me, me.nMapId)

	elseif nType == self.MAP_TYPE.EMPEROR_MIRROR_ROOM or nType == self.MAP_TYPE.FEMALE_EMPEROR_MIRROR_ROOM  then
		self:SyncEmperorMirrorTime(me)
		self:SynEmperorDmgInfo(me)

		local nTrapId = self:GetBossTrapIdFromIndex(nParam)

		tbEnterPos = {self:GetBossTrapInfoFromId(nTrapId)}
	elseif nType == self.MAP_TYPE.THIRD_FLOOR then
		if nType == self.MAP_TYPE.THIRD_FLOOR then
			local tbLastRoomInfo = self.tbPlayerEmperorRoomList[me.dwID]
			nEmperorRecordRoom = tbLastRoomInfo and tbLastRoomInfo[2]
		end
	end

	me.CallClientScript("ImperialTomb:OnEnter", nMapTemplateId, nMapId, nType, self.bOpenEmperor, self.bOpenFemaleEmperor, self.bCallEmperor, nParam, tbEnterPos, nEmperorRecordRoom)
end

function ImperialTomb:OnPlayerLogin(pPlayer)
	self:GetStayTime(pPlayer)
	pPlayer.CallClientScript("ImperialTomb:SyncEmperorTicketState", self.tbEmperorTikectList[pPlayer.dwID])
end

function ImperialTomb:OnMapTrap(nMapTemplateId, nMapId, nType, szClassName)
	if szClassName == "TrapPeace" then
		if me.nFightMode ~= 2 then
			self:RefreshStayTime(me)
			me.nFightMode = 0;
			if self:IsSecretMapByType(nType) or self:IsEmperorMapByType(nType) or
			self:IsBossMapByType(nType) or self:IsEmperorMirrorMapByType(nType) or 
			self:IsFemaleEmperorMapByType(nType) or self:IsFemaleEmperorBossMapByType(nType) or 
			self:IsFemaleEmperorMirrorMapByType(nType) then

				--临时处理topbutton 显示问题
				me.CallClientScript("Ui:OpenWindow", "BattleTopButton");
			end
		end
	elseif szClassName == "TrapFight" then
		if me.nFightMode ~= 2 then
			me.nFightMode = 1;
		end
	else
		local szType, nId = string.match(szClassName, "(%w-)(%d+)")
		if szType == "QSHLToBossRoom" then
			local nIndex = self:GetTrapIndexFromId(tonumber(nId))
			if self:IsEmperorRoomOpen(nIndex) then
				self:EnterEmperorRoom(nIndex)
			end
		elseif szType == "QSHLToLeaderRoom" then
			local nIndex = self:GetBossTrapIndexFromId(tonumber(nId))
			if self:IsBossRoomOpen(nIndex) then
				self:EnterBossRoom(nIndex)
			end
		end
	end
end

function ImperialTomb:TransMapPlayer(nMapId)
	local tbMapInfo = self.tbMapList[nMapId];
	if not tbMapInfo then
		Log("[Error]", "ImperialTomb", "TransPlayer Not Found Map Info", nMapId)
		return
	end

	local nTransMapId = nil
	local nTransX = nil
	local nTransY = nil

	if self:IsSecretMapByType(tbMapInfo.nType) then
		nTransMapId, nTransX, nTransY = self:GetDefaultPos(self:GetNormalMapType(tbMapInfo.nType))
	elseif self:IsEmperorMapByType(tbMapInfo.nType) then
		tbMapInfo.bOpen = false
		nTransMapId, nTransX, nTransY = self:GetDefaultPos(self.MAP_TYPE.THIRD_FLOOR)
	elseif self:IsBossMapByType(tbMapInfo.nType) then
		tbMapInfo.bOpen = false
		local nEnterMapType = self:GetBossEnterMapByIndex(tbMapInfo.nParam)
		nTransMapId, nTransX, nTransY = self:GetDefaultPos(nEnterMapType)
	elseif self:IsEmperorMirrorMapByType(tbMapInfo.nType) or self:IsFemaleEmperorMirrorMapByType(tbMapInfo.nType) then
		local tbEmperorMapInfo = self.tbMapList[tbMapInfo.nParam]
		if tbEmperorMapInfo then
			nTransMapId = tbEmperorMapInfo.nMapId
			nTransX, nTransY = Map:GetDefaultPos(tbEmperorMapInfo.nMapTemplateId)
		end
	elseif self:IsFemaleEmperorMapByType(tbMapInfo.nType) or self:IsFemaleEmperorBossMapByType(tbMapInfo.nType) then
		tbMapInfo.bOpen = false
		nTransMapId, nTransX, nTransY = self:GetDefaultPos(self.MAP_TYPE.FEMALE_EMPEROR_FLOOR)
	end

	local tbPlayer,count = KPlayer.GetMapPlayer(tbMapInfo.nMapId)
	for _, pPlayer in ipairs(tbPlayer) do
		pPlayer.Revive(1)

		if nTransMapId then
			pPlayer.SwitchMap(nTransMapId, nTransX, nTransY);
		else
			pPlayer.GotoEntryPoint();
		end
	end
end

function ImperialTomb:EnterTomb()
	local bEmperor = self.bOpenEmperor

	if self.bOpenFemaleEmperor then
		bEmperor = false
	end

	local ret, msg = self:CheckEnterTomb(me, bEmperor, false)

	if not ret then
		return ret, msg
	end

	if not Env:CheckSystemSwitch(me, Env.SW_SwitchMap) then
		me.CenterMsg("目前狀態不允許切換地圖")
		return false, "目前狀態不允許切換地圖"
	end

	local nEnterMapType = self.MAP_TYPE.FIRST_FLOOR

	if bEmperor and not self.tbEmperorTikectList[me.dwID] then
		local nNeedCount = self.EMPEROR_TICKET_COUNT[false]
		--扣除夜明珠
		local nCount = me.ConsumeItemInAllPos(self.EMPEROR_NEED_ITEM, nNeedCount, Env.LogWay_ImperialTomb_Enter_Boss)
		if nCount <= 0 then
			return
		end

		self:SetEmperorTicketState(me, true);
		TeacherStudent:CustomTargetAddCount(me, "QinShiHuang", 1)
	end

	me.SetEntryPoint();

	me.nEnterImperialTombTime = GetTime()

	self:EnterNormalFloor(nEnterMapType)
end

function ImperialTomb:EnterFemaleEmperorTomb(nIndex)
	if not self.bOpenFemaleEmperor then
		return
	end

	nIndex = nIndex or 1

	local ret, msg = self:CheckEnterTomb(me, self.bOpenEmperor, true)
	if not ret then
		return ret, msg
	end

	if not Env:CheckSystemSwitch(me, Env.SW_SwitchMap) then
		me.CenterMsg("目前狀態不允許切換地圖")
		return false, "目前狀態不允許切換地圖"
	end

	local tbPos = self.FEMALE_EMPEROR_FLOOR_ENTER_POS[nIndex]
	if not tbPos then
		return
	end

	local nEnterMapType = self.MAP_TYPE.FEMALE_EMPEROR_FLOOR
	local tbMapInfo = self.tbNormalMapList[nEnterMapType];
	if not tbMapInfo or not tbMapInfo.bCreated then
		return
	end

	if not self.tbEmperorTikectList[me.dwID] then
		--扣除夜明珠
		local nNeedCount = self.EMPEROR_TICKET_COUNT[true]
		local nCount = me.ConsumeItemInAllPos(self.EMPEROR_NEED_ITEM, nNeedCount, Env.LogWay_ImperialTomb_Enter_Boss)
		if nCount <= 0 then
			return
		end

		self:SetEmperorTicketState(me, true);
		--TeacherStudent:CustomTargetAddCount(me, "QinShiHuang", 1)
	end

	me.SetEntryPoint();

	me.nEnterImperialTombTime = GetTime()

	me.SwitchMap(tbMapInfo.nMapId, tbPos[1], tbPos[2]);
end

function ImperialTomb:EnterNormalFloor(nType)
	local tbMapInfo = self.tbNormalMapList[nType];
	if not tbMapInfo or not tbMapInfo.bCreated then
		return
	end

	Map:SwitchMapDirectly(tbMapInfo.nMapId, tbMapInfo.nMapTemplateId);
end

function ImperialTomb:EnterEmperorRoom(nIndex)
	local ret, msg, nMapId, nMapTemplateId = self:CheckEnterEmperorRoom(me, nIndex)
	if not ret then
		me.CenterMsg(msg);
		return
	end

	Map:SwitchMapDirectly(nMapId, nMapTemplateId);
end

function ImperialTomb:EnterBossRoom(nIndex)
	local ret, msg, nMapId, nMapTemplateId = self:CheckEnterBossRoom(me, nIndex)
	if not ret then
		me.CenterMsg(msg);
		return
	end

	Map:SwitchMapDirectly(nMapId, nMapTemplateId);
end

function ImperialTomb:GetDefaultPos(nType)
	local tbMapInfo = self.tbNormalMapList[nType]
	local tbPos = self.NOMAL_FLOOR_DEFAULT_POS[nType]
	if tbMapInfo and tbPos then
		return tbMapInfo.nMapId, tbPos.nX, tbPos.nY
	end

	return Map:GetDefaultPos(self.MAP_TEMPLATE_ID[nType]);
end

function ImperialTomb:GetEmperorMapByIndex(nIndex)
	for nMapId, tbInfo in pairs(self.tbEmperorMapList) do
		if tbInfo.nParam == nIndex then
			return tbInfo
		end
	end

	return nil
end

function ImperialTomb:IsEmperorRoomOpen(nIndex)
	local tbMapInfo = self:GetEmperorMapByIndex(nIndex)
	if not tbMapInfo or not tbMapInfo.bCreated or not tbMapInfo.bOpen then
		return false
	end

	return true, tbMapInfo
end

function ImperialTomb:CheckEnterEmperorRoom(pPlayer, nIndex)
	if GetTimeFrameState(self.OPEN_TIME_FRAME) ~= 1 then
		return false, XT("尚未開啟");
	end

	if pPlayer.nMapTemplateId ~= self.MAP_TEMPLATE_ID[self.MAP_TYPE.THIRD_FLOOR] and pPlayer.nMapTemplateId ~= self.MAP_TEMPLATE_ID[self.MAP_TYPE.FEMALE_EMPEROR_FLOOR] then
		return false, "所在地圖不允許進入";
	end

	local bRet, tbMapInfo = self:IsEmperorRoomOpen(nIndex)
	if not bRet  then
		return false, "尚未開啟";
	end

	local tbLastRoomInfo = self.tbPlayerEmperorRoomList[pPlayer.dwID]

	if tbLastRoomInfo and tbLastRoomInfo[1] ~= tbMapInfo.nMapId then
		return false, self.EMPEROR_WRONG_ENTRY_MSG[self.bOpenFemaleEmperor];
	end

	return true, "", tbMapInfo.nMapId, tbMapInfo.nMapTemplateId
end

function ImperialTomb:CheckEnterBossRoom(pPlayer, nIndex)
	if GetTimeFrameState(self.OPEN_TIME_FRAME) ~= 1 then
		return false, XT("尚未開啟");
	end

	local bRet, tbMapInfo = self:IsBossRoomOpen(nIndex)
	if not bRet  then
		return false, "尚未開啟";
	end

	return true, "", tbMapInfo.nMapId, tbMapInfo.nMapTemplateId
end

function ImperialTomb:AddStayTime(pPlayer, nTime)
	local nStayTime = self:GetStayTime(pPlayer);

	if nTime <= 0 then
		return nStayTime
	end

	nStayTime = nStayTime + nTime;
	nStayTime = math.min(nStayTime, self.MAX_STAY_TIME);
	pPlayer.SetUserValue(self.SAVE_GROUP, self.TOTAL_STAY_TIME_KEY, nStayTime);

	pPlayer.CallClientScript("ImperialTomb:OnStayTimeChange", nTime, nStayTime)

	Log("[Info]", "ImperialTomb", "AddStayTime", pPlayer.dwID, pPlayer.szName, nTime, nStayTime);

	return nStayTime
end

function ImperialTomb:ReduceStayTime(pPlayer, nTime)
	local nOldStayTime = self:GetStayTime(pPlayer);

	if nTime <= 0 then
		return nOldStayTime
	end

	if nOldStayTime <= 0  then
		return nOldStayTime
	end

	--非战斗状态,不在普通挂机1，2，3层 , 秦始皇房间开启时不扣时间
	if --[[pPlayer.nFightMode == 0 or]] not (self:IsNormalMapReduceStayTimeByTemplate(pPlayer.nMapTemplateId) and (not self.bOpenEmperor or self.bOpenFemaleEmperor)) then
		return nOldStayTime
	end

	local nStayTime = nOldStayTime - nTime;
	nStayTime = math.max(nStayTime, 0);

	pPlayer.SetUserValue(self.SAVE_GROUP, self.TOTAL_STAY_TIME_KEY, nStayTime);

	pPlayer.CallClientScript("ImperialTomb:OnStayTimeChange", nStayTime - nOldStayTime, nStayTime)

	Log("[Info]", "ImperialTomb", "ReduceStayTime", pPlayer.dwID, pPlayer.szName, nStayTime - nOldStayTime, nStayTime);

	return nStayTime
end

function ImperialTomb:RefreshStayTime(pPlayer)
	local nNow = GetTime();
	if not pPlayer.nLastRefreshStayTime then
		pPlayer.nLastRefreshStayTime = nNow;
		return
	end

	local nTime = math.abs(nNow - pPlayer.nLastRefreshStayTime)

	if nTime <= 0 then
		return
	end

	pPlayer.nLastRefreshStayTime = nNow;

	return self:ReduceStayTime(pPlayer, nTime)
end

function ImperialTomb:CheckStayTime(pPlayer)
	local nLeftTime = self:RefreshStayTime(pPlayer)
	if nLeftTime and nLeftTime <= 0 then
		pPlayer.Msg(XT("皇陵毒霧彌漫，俠士已無法承受其中劇毒，唯有將俠士送出皇陵"))
		pPlayer.Revive(1);
		pPlayer.GotoEntryPoint();
	end
end

function ImperialTomb:OnCheckStayTime()
	if self.bOpenEmperor and not self.bOpenFemaleEmperor then
		return true
	end

	for nMapType, tbMapInfo in pairs(self.tbNormalMapList) do
		if nMapType ~= self.MAP_TYPE.FEMALE_EMPEROR_FLOOR then
			local tbPlayer,count = KPlayer.GetMapPlayer(tbMapInfo.nMapId)
			for _, pPlayer in ipairs(tbPlayer) do
				self:CheckStayTime(pPlayer)
			end
		end
	end

	for nMapType, tbMapInfo in pairs(self.tbSecretMapList) do
		local tbPlayer,count = KPlayer.GetMapPlayer(tbMapInfo.nMapId)
		for _, pPlayer in ipairs(tbPlayer) do
			self:CheckSecretTime(pPlayer)
		end
	end

	return true
end

function ImperialTomb:TransferAllPlayerOut()
	for nMapId,_ in pairs(self.tbMapList) do
		local tbPlayer,_ = KPlayer.GetMapPlayer(nMapId)
		for _, pPlayer in ipairs(tbPlayer) do
			pPlayer.Revive(1)
			pPlayer.GotoEntryPoint();
		end
	end
end

function ImperialTomb:TransferFemaleEmperorPlayerOut()
	for nMapId,tbMapInfo in pairs(self.tbMapList) do
		if self:IsFemaleEmperorMapByType(tbMapInfo.nType) or 
		self:IsFemaleEmperorBossMapByType(tbMapInfo.nType) or 
		self:IsFemaleEmperorMirrorMapByType(tbMapInfo.nType) or 
		tbMapInfo.nType == self.MAP_TYPE.FEMALE_EMPEROR_FLOOR then

			local tbPlayer,_ = KPlayer.GetMapPlayer(nMapId)
			for _, pPlayer in ipairs(tbPlayer) do
				pPlayer.Revive(1)
				pPlayer.GotoEntryPoint();
			end
		end
	end
end

function ImperialTomb:ClearAllPlayerTmpRevive()
	for nMapId,_ in pairs(self.tbMapList) do
		local tbPlayer,_ = KPlayer.GetMapPlayer(nMapId)
		for _, pPlayer in ipairs(tbPlayer) do
			pPlayer.ClearTempRevivePos();
		end
	end
end

function ImperialTomb:TransferNormalFloorPlayerOut()
	for nMapType, tbMapInfo in pairs(self.tbNormalMapList) do
		local tbPlayer,_ = KPlayer.GetMapPlayer(tbMapInfo.nMapId)
		for _, pPlayer in ipairs(tbPlayer) do
			pPlayer.Revive(1)
			pPlayer.GotoEntryPoint();
		end
	end
end

function ImperialTomb:DeleteNormalFloorNpc()
	for nMapType, tbMapInfo in pairs(self.tbNormalMapList) do
		local tbNpcList,_ = KNpc.GetMapNpc(tbMapInfo.nMapId)
		for _, pNpc in ipairs(tbNpcList) do
			local nKind = pNpc.nKind
			if nKind == Npc.KIND.none or nKind == Npc.KIND.normal then
				pNpc.Delete()
			end
		end
		KNpc.ClearMapReviveNpcList(tbMapInfo.nMapId)
	end
end

function ImperialTomb:ReloadNormalFloorNpc()
	for nMapType, tbMapInfo in pairs(self.tbNormalMapList) do
		KNpc.ReloadMapNpc(tbMapInfo.nMapId)
	end
end

function ImperialTomb:SetEmperorTicketState(pPlayer, bStatus)
	self.tbEmperorTikectList[pPlayer.dwID] = bStatus
	pPlayer.CallClientScript("ImperialTomb:SyncEmperorTicketState", bStatus)
end

function ImperialTomb:LeaveRequest(pPlayer)
	local nTransMapId = nil
	local nTransX = nil
	local nTransY = nil
	local  nMapTemplateId = pPlayer.nMapTemplateId

	if not self:IsTombMap(nMapTemplateId) then
		return
	end

	if self:IsEmperorMirrorMapByTemplate(nMapTemplateId) or self:IsFemaleEmperorMirrorMapByTemplate(nMapTemplateId) then
		return
	end
	
	if self:IsSecretMapByTemplate(nMapTemplateId) then
		if (not self.bOpenEmperor or self.bOpenFemaleEmperor )then
			nTransMapId, nTransX, nTransY = self:GetDefaultPos(self:GetNormalMapType(self:GetMapType(nMapTemplateId)))
		end
	elseif self:IsEmperorMapByTemplate(nMapTemplateId) then
		nTransMapId, nTransX, nTransY = self:GetDefaultPos(self.MAP_TYPE.THIRD_FLOOR)
	elseif self:IsBossMapByTemplate(nMapTemplateId) then
		local tbMapInfo = self.tbMapList[pPlayer.nMapId]
		if tbMapInfo then
			local nEnterMapType = self:GetBossEnterMapByIndex(tbMapInfo.nParam)
			nTransMapId, nTransX, nTransY = self:GetDefaultPos(nEnterMapType)
		end

	elseif self:IsFemaleEmperorMapByTemplate(nMapTemplateId) then
		nTransMapId, nTransX, nTransY = self:GetDefaultPos(self.MAP_TYPE.FEMALE_EMPEROR_FLOOR)
		local tbMapInfo = self.tbMapList[pPlayer.nMapId]
		if tbMapInfo then
			local nTrapId = self:GetTrapIdFromIndex(tbMapInfo.nParam) or 1
			nTransX = self.FEMALE_EMPEROR_FLOOR_ENTER_POS[nTrapId][1]
			nTransY = self.FEMALE_EMPEROR_FLOOR_ENTER_POS[nTrapId][2]
		end
	elseif self:IsFemaleEmperorBossMapByTemplate(nMapTemplateId) then
		nTransMapId, nTransX, nTransY = self:GetDefaultPos(self.MAP_TYPE.FEMALE_EMPEROR_FLOOR)
		local tbMapInfo = self.tbMapList[pPlayer.nMapId]
		if tbMapInfo then
			local nTrapId = self:GetBossTrapIdFromIndex(tbMapInfo.nParam) or 1
			local nEnterIndex = self.FEMALE_EMPEROR_BOSS_TRAP_2_ENTER_INDEX[nTrapId] or 1
			nTransX = self.FEMALE_EMPEROR_FLOOR_ENTER_POS[nEnterIndex][1]
			nTransY = self.FEMALE_EMPEROR_FLOOR_ENTER_POS[nEnterIndex][2]
		end
	end

	pPlayer.Revive(1)

	if nTransMapId then
		pPlayer.SwitchMap(nTransMapId, nTransX, nTransY);
	else
		pPlayer.GotoEntryPoint();
	end
end

function ImperialTomb:SyncBossStatus(pPlayer)
	local tbSyncData =
	{
	}

	for nIndex=1, self.EMPEROR_COUNT do
		local tbMapInfo = self:GetEmperorMapByIndex(nIndex)
		if tbMapInfo then
			local nNpcId = self.tbMap2Emperor[tbMapInfo.nMapId] or 0;
			local tbNpcInfo = self.tbEmperorList[nNpcId]
			local nMapTemplateId, nMapId, nX, nY, nTrapId = self:GetTrapInfoFromIndex(nIndex)
			local tbTrapMapInfo = nMapId and self.tbMapList[nMapId]
			local tbStatus = {}
			if tbNpcInfo then
				if tbNpcInfo.bDead then
					tbStatus[1] = self.BOSS_STATUS.DEAD
					tbStatus[2] =
					{
						tbNpcInfo.szLastPlayerName,
						tbNpcInfo.szLastKinName,
					}
				else
					tbStatus[1] = self.BOSS_STATUS.EXSIT
				end
			else
				tbStatus[1] = self.BOSS_STATUS.NONE
			end

			if nMapId and tbTrapMapInfo then
				if self.bOpenFemaleEmperor then
					local tbEnterPos = self.FEMALE_EMPEROR_FLOOR_ENTER_POS[nTrapId]

					tbStatus[3] = {tbTrapMapInfo.nType, nMapTemplateId, nMapId, tbEnterPos[1], tbEnterPos[2], nTrapId}
				else
					tbStatus[3] = {tbTrapMapInfo.nType, nMapTemplateId, nMapId, nX, nY, nTrapId}
				end
			end

			tbSyncData[tbMapInfo.nType] = tbSyncData[tbMapInfo.nType] or {}
			tbSyncData[tbMapInfo.nType][nIndex] = tbStatus
		end
	end

	for nIndex=1, math.max(self.BOSS_COUNT, self.FEMALE_EMPEROR_BOSS_COUNT) do
		local tbMapInfo = self:GetBossMapByIndex(nIndex)
		if tbMapInfo then
			local nNpcId = self.tbMap2Boss[tbMapInfo.nMapId] or 0;
			local tbNpcInfo = self.tbBossList[nNpcId]
			local nMapTemplateId, nMapId, nX, nY, nTrapId = self:GetBossTrapInfoFromIndex(nIndex)
			local tbTrapMapInfo = nMapId and self.tbMapList[nMapId]
			local tbStatus = {}
			if tbNpcInfo then
				if tbNpcInfo.bDead then
					tbStatus[1] = self.BOSS_STATUS.DEAD
					tbStatus[2] =
					{
						tbNpcInfo.szLastPlayerName,
						tbNpcInfo.szLastKinName,
					}
				else
					tbStatus[1] = self.BOSS_STATUS.EXSIT
				end
			else
				tbStatus[1] = self.BOSS_STATUS.NONE
			end

			if nMapId and tbTrapMapInfo then
				if self.bOpenFemaleEmperor then
					local nEnterIndex = self.FEMALE_EMPEROR_BOSS_TRAP_2_ENTER_INDEX[nTrapId]
					local tbEnterPos = self.FEMALE_EMPEROR_FLOOR_ENTER_POS[nEnterIndex]
					tbStatus[3] = {tbTrapMapInfo.nType, nMapTemplateId, nMapId, tbEnterPos[1], tbEnterPos[2], nTrapId}
				else
					tbStatus[3] = {tbTrapMapInfo.nType, nMapTemplateId, nMapId, nX, nY, nTrapId}
				end
			end

			tbSyncData[tbMapInfo.nType] = tbSyncData[tbMapInfo.nType] or {}
			tbSyncData[tbMapInfo.nType][nIndex] = tbStatus
		end
	end

	pPlayer.CallClientScript("ImperialTomb:OnSyncBossStatus", tbSyncData)
end

function ImperialTomb:OnPlayerLevelup(nNewLevel)
	if nNewLevel == self.MIN_LEVEL then
		self:GetStayTime(me)
		local nOpenServerTime = CalcTimeFrameOpenTime(self.OPEN_TIME_FRAME)
		local nOpenServerDay = Lib:GetLocalDay(nOpenServerTime)
		local nToday = Lib:GetLocalDay()
		if nOpenServerDay == nToday and Calendar:IsActivityInOpenState("ImperialTomb") then
			local tbMail =
			{
				To = me.dwID,
				Title = '寶珠贈俠士',
				Text = [[    秦始皇陵重現于世，古秦士卒四起傷人，各位於皇陵出現時等級已達60級，特贈[FFFE0D]「夜明珠」[-]一顆，此物有避毒功效，始皇降世時，唯有攜此物方可前往皇陵。還望諸位能夠除此禍害，還江湖平靜。若仍有不解之處，可通過下方連結前往查看説明。
                                     查看活動：[47f005][url=openwnd:秦始皇陵, CalendarPanel, 1, 37][-]
                                     查看活動：[47f005][url=openwnd:始皇降世, CalendarPanel, 1, 38][-] ]],
				From = '獨孤劍',
				tbAttach = {{'item', ImperialTomb.EMPEROR_NEED_ITEM, 1}},
				nLogReazon = Env.LogWay_ImperialTomb_Send_Ticket,
			};

			Mail:SendSystemMail(tbMail);
		end
	end
end

function ImperialTomb:SwitchMapDirectly(nMapId, nMapTemplateId)
	if self:IsSecretMapByTemplate(nMapTemplateId) then
		return self:SecretEnterRequest(me, self:GetNormalMapType(self:GetMapType(nMapTemplateId)))
	elseif self:GetMapType(nMapTemplateId) == self.MAP_TYPE.FIRST_FLOOR then
		if self.bOpenFemaleEmperor then
			return self:EnterTomb(false)
		else
			return self:EnterTomb(true)
		end
	elseif self:GetMapType(nMapTemplateId) == self.MAP_TYPE.FEMALE_EMPEROR_FLOOR then
		return self:EnterFemaleEmperorTomb()
	end

	return false, "目標地圖無法傳送"
end

function ImperialTomb:ClearDeathState(pPlayer)
	pPlayer.RemoveSkillState(Fuben.RandomFuben.DEATH_SKILLID);
	pPlayer.nFightMode = 0;
end

function ImperialTomb:OnPlayerDeath(pKiller)
	if self:IsEmperorMirrorMapByTemplate(me.nMapTemplateId) or self:IsFemaleEmperorMirrorMapByTemplate(me.nMapTemplateId) then
		me.Revive(1);
		me.AddSkillState(Fuben.RandomFuben.DEATH_SKILLID, 1, 0, 10000);
		me.nFightMode = 2;
		me.nImperialTombReviveCount = me.nImperialTombReviveCount + 1
		local nTime = me.nImperialTombReviveCount * self.MIRROR_DEATH_WAIT_TIME
		Timer:Register(nTime * Env.GAME_FPS, self.OnMirrorRevive, self, me.dwID);
		me.Msg(string.format(XT("%d秒後復活", nTime)))
	end
end

function ImperialTomb:OnMirrorRevive(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end

	if pPlayer.nFightMode ~= 2 then
		return;
	end

	self:ClearDeathState(pPlayer);

	local nRevMapId, nX, nY, nRevFightMode = pPlayer.GetTempRevivePos();

	if nRevMapId then
		pPlayer.SetPosition(nX, nY);
	end
end