function ImperialTomb:OpenBossRoom()

	local nNeedCount = self.BOSS_COUNT
	if self.bOpenFemaleEmperor then
		nNeedCount = self.FEMALE_EMPEROR_BOSS_COUNT
	end

	local nIndex = 0;
	local nMapType = self.MAP_TYPE.BOSS_ROOM
	if self.bOpenFemaleEmperor then
		nMapType = self.MAP_TYPE.FEMALE_EMPEROR_BOSS_ROOM
	end

	for nMapId,tbMapInfo in pairs(self.tbBossMapList) do
		nNeedCount = nNeedCount  - 1;
		nIndex = nIndex + 1;
		tbMapInfo.bOpen = true
		SetMapSurvivalTime(tbMapInfo.nMapId, GetTime()+self.BOSS_EXSIT_TIME*2)
	end

	if nNeedCount > 0 then
		for i=1,nNeedCount do
			local _, tbMapInfo = self:CreateRequest(nMapType, nIndex + i);
			if tbMapInfo then
				tbMapInfo.bOpen = true
			end
		end
	end

	self:ClearBossData()
	
	if not self.bOpenFemaleEmperor then
		self:CallBossTrapNpc()
	end
end

function ImperialTomb:CloseBossRoom()
	for nNpcId,tbNpcInfo in pairs(self.tbBossList) do
		local pNpc = KNpc.GetById(nNpcId);

		if pNpc then
			pNpc.Delete();
		end

		tbNpcInfo.bDead = true

		if tbNpcInfo.nTimer and Timer:GetRestTime(tbNpcInfo.nTimer) >= 0 then
			Timer:Close(tbNpcInfo.nTimer)
			tbNpcInfo.nTimer = nil
		end

		if tbNpcInfo.nTransTimer and Timer:GetRestTime(tbNpcInfo.nTransTimer) >= 0 then
			Timer:Close(tbNpcInfo.nTransTimer)
			tbNpcInfo.nTransTimer = nil
		end
	end

	for nMapId,tbMapInfo in pairs(self.tbBossMapList) do
		tbMapInfo.bOpen = false
		self:TransMapPlayer(nMapId)
	end

	self:DeleteBossTrapNpc()
	--self:ClearBossData()
end

function ImperialTomb:ClearBossData()
	self.tbBossList = {}
	self.tbMap2Boss = {}
	self.tbSyncBossDmg = {}
	self.tbFinalBossDmg = {}
	self.tbBossTrapList = {}
	self.nLastUpdatBossDmgInfo = 0;
end

function ImperialTomb:CallBoss()
	local tbBossInfoList = self.BOSS_INFO;
	local szMsg = self.EMPEROR_BOSS_CALL_MSG[self.bOpenFemaleEmperor]
	local nLevelLimit = self.MIN_LEVEL
	if self.bOpenFemaleEmperor then
		tbBossInfoList = self.FEMALE_EMPEROR_BOSS_INFO
		self:CallFemaleEmperorBossTrapNpc()
		nLevelLimit = self.FEMALE_EMPEROR_MIN_LEVEL
	end

	for nMapId,tbMapInfo in pairs(self.tbBossMapList) do
		local tbBossInfo = tbBossInfoList[tbMapInfo.nParam]
		if tbBossInfo then
			self:_CallBoss(nMapId, tbBossInfo)
		else
			Log("[Error]", "ImperialTomb", "CallBoss Failed Not Found Boss Config", nMapId, tbMapInfo.nParam)
		end
	end

	KPlayer.SendWorldNotify(nLevelLimit, 1000,
			szMsg,
			ChatMgr.ChannelType.Public, 1);
end

function ImperialTomb:_CallBoss(nMapId, tbBossInfo)
	local szLvlFrame = Lib:GetMaxTimeFrame(self.NPC_TIME_FRAME_LEVEL);
	local nLevel = nil
	if szLvlFrame then
		nLevel = self.NPC_TIME_FRAME_LEVEL[szLvlFrame]
	end

	if not nLevel then
		Log("[Error]", "ImperialTomb", "CallBoss Failed Not Found Level Config", nMapId, nType)
		return false
	end

	local pNpc = KNpc.Add(tbBossInfo.nTemplate, nLevel, 0, nMapId, tbBossInfo.nX, tbBossInfo.nY, 0);

	if not pNpc then
		Log("[Error]", "ImperialTomb", "CallBoss Failed Add Npc", nMapId, tbBossInfo.nTemplate, nLevel, tbBossInfo.nX, tbBossInfo.nY)
		return false
	end

	pNpc.SetByAttackCallScript(1);
	pNpc.SetTitleID(tbBossInfo.nTitleId);

	local nNpcId = pNpc.nId;

	local nTimer = Timer:Register(Env.GAME_FPS * self.BOSS_EXSIT_TIME, self.OnBossTimeOut, self, nNpcId, nMapId);

	self.tbBossList[nNpcId] = {nNpcId = nNpcId, nTotalDamage = pNpc.nMaxLife, nEndTime = (GetTime() + self.BOSS_EXSIT_TIME), bDead = false, nFirstKin = nil, nLastKin = nil, nTimer = nTimer};
	self.tbMap2Boss[nMapId] = nNpcId;

	local tbPlayer,count = KPlayer.GetMapPlayer(nMapId)
	for _, pPlayer in ipairs(tbPlayer) do
		pPlayer.CallClientScript("ImperialTomb:SyncRoomCloseTime", self.BOSS_EXSIT_TIME)
	end

	Log("[Info]", "ImperialTomb", "CallBoss Success", nMapId, tbBossInfo.nTemplate, nLevel, pNpc.nId);

	return true
end

function ImperialTomb:OnBossAttack()
	local nNpcId = him.nId;
	local tbNpcInfo = self.tbBossList[nNpcId];

	if not tbNpcInfo then
		local nNpcMapId, _, _ = him.GetWorldPos();
		Log("[Error]", "ImperialTomb", "OnBossAttack Not Found Npc Info", nNpcMapId, nNpcId)
		return
	end

	if not tbNpcInfo.nFirstKin and me.dwKinId > 0 then
		tbNpcInfo.nFirstKin = me.dwKinId
		local nNpcMapId, _, _ = him.GetWorldPos();
		Log("[Info]", "ImperialTomb", "OnBossAttack First Touch", nNpcMapId, nNpcId, tbNpcInfo.nFirstKin)
	end
end

function ImperialTomb:OnBossTimeOut(nNpcId, nMapId)
	local pNpc = KNpc.GetById(nNpcId);
	local tbNpcInfo = self.tbBossList[nNpcId];
	local tbDamage = nil
	local szNpcName = ""
	local nNpcTemplate = 0

	if pNpc then
		szNpcName = pNpc.szName;
		nNpcTemplate = pNpc.nTemplateId
		tbDamage = pNpc.GetDamageInfo();
		pNpc.Delete();
	end

	if not tbNpcInfo then
		Log("[Error]", "ImperialTomb", "OnBossTimeOut Not Found Npc Info", nMapId, nNpcId)
		return
	end

	Log("[Info]", "ImperialTomb", "OnBossTimeOut", nMapId,  nNpcId);

	tbNpcInfo.bDead = true

	if tbDamage then
		Log("------Start Boss Dmg Info------", nMapId,  nNpcId);
		Lib:LogTB(tbDamage);
		Log("------End Boss Dmg Info------", nMapId,  nNpcId);

		local tbSortedList = self:GetSortedDmgInfo(tbDamage, 
			{tbNpcInfo},
			self.BOSS_FIRST_LAST_DMG_BONUS, 
			self.BOSS_DMG_PERCENT_FACTOR
			);

		self.tbSyncBossDmg[nMapId] =
				{
					tbDmg = self:GetSyncDmg(tbSortedList, self.BOSS_SYNC_DMG_COUNT),
					szTargetName = szNpcName,
				}


		self.tbFinalBossDmg[nMapId] = 
				{
					tbSortedList = tbSortedList,
					nMapId = nMapId,
					nNpcId = nNpcId,
					nNpcTemplate = nNpcTemplate,
					szNpcName = szNpcName,
				}
	end

	--[[tbNpcInfo.nTransTimer = Timer:Register(Env.GAME_FPS * self.EMPEROR_END_DELAY_TIME, self.TransMapPlayer, self, nMapId);

	local tbPlayer,count = KPlayer.GetMapPlayer(nMapId)
	for _, pPlayer in ipairs(tbPlayer) do
		pPlayer.CallClientScript("ImperialTomb:SyncTransTime", self.EMPEROR_END_DELAY_TIME)
	end]]

	if self.bCallEmperor then
		if self:IsAllEmperorDead() and self:IsAllBossDead() then
			self:EmperorAward()
		end
	else
		if self:IsAllBossDead() then
			--所有首领击杀后开启秦始皇房间
			self:CallEmperor()
		end
	end
	
end

function ImperialTomb:OnBossDeath(pNpc, pKiller)
	local nNpcId = pNpc.nId;
	local nNpcMapId, _, _ = pNpc.GetWorldPos();
	local tbNpcInfo = self.tbBossList[nNpcId];

	if not tbNpcInfo then
		Log("[Error]", "ImperialTomb", "OnBossDeath Not Found Npc Info", nNpcMapId, nNpcId)
		return
	end

	tbNpcInfo.bDead = true

	local nPlayerId = pNpc.GetLastDmgMePlayerID();
	local szKinName = nil
	local szPlayerName = nil

	Log("[Info]", "ImperialTomb", "OnBossDeath", nNpcMapId,  nNpcId, tostring(nPlayerId));

	if nPlayerId and nPlayerId > 0 then
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			szPlayerName = pPlayer.szName
		end


		local nKinId = self:GetPlayerKinID(nPlayerId)
		if nKinId > 0 then
			tbNpcInfo.nLastKin = nKinId;

			local kinData = Kin:GetKinById(nKinId)
			if kinData then
				szKinName = kinData.szName
			end
		end
	end

	local szNpcName = pNpc.szName
	local tbDamage = pNpc.GetDamageInfo();
	if tbDamage then
		Log("------Start Emperor Dmg Info------", nNpcMapId,  nNpcId);
		Lib:LogTB(tbDamage);
		Log("------End Emperor Dmg Info------", nNpcMapId,  nNpcId);

		local tbSortedList = self:GetSortedDmgInfo(tbDamage,
						{tbNpcInfo},
						 self.BOSS_FIRST_LAST_DMG_BONUS,
						 self.BOSS_DMG_PERCENT_FACTOR
						 );

		self.tbSyncBossDmg[nNpcMapId] =
				{
					tbDmg = self:GetSyncDmg(tbSortedList, self.BOSS_SYNC_DMG_COUNT),
					szTargetName = szNpcName,
				}

		self.tbFinalBossDmg[nNpcMapId] = 
				{
					tbSortedList = tbSortedList,
					nMapId = nNpcMapId,
					nNpcId = nNpcId,
					nNpcTemplate = pNpc.nTemplateId,
					szNpcName = szNpcName,
				}
	end

	--[[tbNpcInfo.nTransTimer = Timer:Register(Env.GAME_FPS * self.EMPEROR_END_DELAY_TIME, self.TransMapPlayer, self, nNpcMapId);

	local tbPlayer,count = KPlayer.GetMapPlayer(nNpcMapId)
	for _, pPlayer in ipairs(tbPlayer) do
		pPlayer.CallClientScript("ImperialTomb:SyncTransTime", self.EMPEROR_END_DELAY_TIME)
	end]]

	tbNpcInfo.szLastKinName = szKinName
	tbNpcInfo.szLastPlayerName = szPlayerName

	local szMsg = ""

	if szKinName and szPlayerName then
		szMsg = string.format(XT("恭喜「%s」幫派的「%s」給予%s最後一擊，使其得以安息", szKinName, szPlayerName, szNpcName))
	elseif szPlayerName then
		szMsg = string.format(XT("恭喜「%s」給予%s最後一擊，使其得以安息", szPlayerName, szNpcName))
	end

	local nLevelLimit = self.MIN_LEVEL
	if self.bOpenFemaleEmperor then
		nLevelLimit = self.FEMALE_EMPEROR_MIN_LEVEL
	end

	KPlayer.SendWorldNotify(nLevelLimit, 1000,
				szMsg,
				ChatMgr.ChannelType.Public, 1);


	if self.bCallEmperor then
		if self:IsAllEmperorDead() and self:IsAllBossDead() then
			self:EmperorAward()
		end
	else
		if self:IsAllBossDead() then
			--所有首领击杀后开启秦始皇房间
			self:CallEmperor()
		end
	end
end

function ImperialTomb:SyncBossTime(pPlayer)
	local nMapId,_,_ = pPlayer.GetWorldPos();

	local nNpcId = self.tbMap2Boss[nMapId];
	if not nNpcId then
		return
	end

	local tbNpcInfo = self.tbBossList[nNpcId]
	if not tbNpcInfo then
		return
	end

	--if tbNpcInfo.bDead then
	--	local nTime = math.max(Timer:GetRestTime(tbNpcInfo.nTransTimer), 0) / Env.GAME_FPS;
	--	pPlayer.CallClientScript("ImperialTomb:SyncTransTime", nTime)
	--else
		local nTime = math.max(Timer:GetRestTime(tbNpcInfo.nTimer), 0) / Env.GAME_FPS;
		pPlayer.CallClientScript("ImperialTomb:SyncRoomCloseTime", nTime)
	--end
end

function ImperialTomb:SynBossDmgInfo(pPlayer, nMapId)
	self:UpdateBossSynDmgInfo();
	local tbSyncInfo = self.tbSyncBossDmg[nMapId]

	pPlayer.CallClientScript("ImperialTomb:SynBossDmgInfo", nMapId, tbSyncInfo and tbSyncInfo.szTargetName, tbSyncInfo and tbSyncInfo.tbDmg)
end

function ImperialTomb:UpdateBossSynDmgInfo()
	local nNow = GetTime();
	if (self.nLastUpdatBossDmgInfo + self.UPDATE_SYNC_DMG_INTERVAL) > nNow then
		return
	end

	for nNpcId,tbNpcInfo in pairs(self.tbBossList) do
		if not tbNpcInfo.bDead then
			local pNpc = KNpc.GetById(tbNpcInfo.nNpcId);
			if pNpc then
				local tbDamage = pNpc.GetDamageInfo();
				local nMapId,_,_ = pNpc.GetWorldPos();
				if tbDamage then
					local tbSortedList = self:GetSortedDmgInfo(tbDamage,
									{tbNpcInfo},
									self.BOSS_FIRST_LAST_DMG_BONUS,
									self.BOSS_DMG_PERCENT_FACTOR
									);
					self.tbSyncBossDmg[nMapId] = 
						{
							tbDmg = self:GetSyncDmg(tbSortedList, self.BOSS_SYNC_DMG_COUNT),
							szTargetName = pNpc.szName,
						}
				end
			end
		end
	end

	self.nLastUpdatBossDmgInfo = nNow;
end

function ImperialTomb:_AddBossTrapNpc(nMapTemplateId, nMapId, nX, nY, nTrapId, nTrapIndex, szName)
	local pNpc = KNpc.Add(73, 1, 0, nMapId, nX, nY);
	if pNpc then
		pNpc.SetName(szName)
		self.tbBossTrapList[nTrapId] = {nMapTemplateId = nMapTemplateId, nNpcId = pNpc.nId, nMapId = nMapId,
						nX=nX, nY=nY, nTrapId = nTrapId, nTrapIndex = nTrapIndex};
	end

	return pNpc
end

function ImperialTomb:CallBossTrapNpc()
	local nTrapIndex = 1;
	local nTrapId = 1;
	for nMapType,tbMapInfo in pairs(self.tbNormalMapList) do
		local tbTrapList = self.BOSS_ROOM_TRAP_POS[nMapType]
		if tbTrapList then
			for _,tbPos in pairs(tbTrapList) do
				self:_AddBossTrapNpc(tbMapInfo.nMapTemplateId, tbMapInfo.nMapId, tbPos[1], tbPos[2], nTrapId, nTrapIndex, XT("通往護主殿"))
				nTrapId = nTrapId + 1;
				nTrapIndex = nTrapIndex + 1;
			end
		end
	end
end

function ImperialTomb:CallFemaleEmperorBossTrapNpc()
	local nTrapIndex = 1;
	local tbMapInfo = self.tbNormalMapList[self.MAP_TYPE.FEMALE_EMPEROR_FLOOR]
	local fnSelectZone = Lib:GetDifferentRandomSelect(self.FEMALE_EMPEROR_BOSS_ROOM_TRAP_POS);
	local tbSelectZone1 = fnSelectZone()
	local tbSelectZone2 = fnSelectZone()

	for _,tbTrapList in ipairs(self.FEMALE_EMPEROR_BOSS_ROOM_TRAP_POS) do
		local fnRandom = Lib:GetDifferentRandomSelect(tbTrapList);
		local tbPos1 = fnRandom()
		local tbPos2 = fnRandom()

		self:_AddBossTrapNpc(tbMapInfo.nMapTemplateId, tbMapInfo.nMapId, tbPos1[1], tbPos1[2], tbPos1[3], nTrapIndex, XT("通往大理寺"))
		nTrapIndex = nTrapIndex + 1;

		--有2个对应的区域是2个trap点 其他1个
		if tbSelectZone1 == tbTrapList or tbSelectZone2 == tbTrapList then
			self:_AddBossTrapNpc(tbMapInfo.nMapTemplateId, tbMapInfo.nMapId, tbPos2[1], tbPos2[2], tbPos2[3], nTrapIndex, XT("通往大理寺"))
			nTrapIndex = nTrapIndex + 1;
		end
	end
end

function ImperialTomb:DeleteBossTrapNpc()
	for _,tbTrapInfo in pairs(self.tbBossTrapList) do
		local pNpc = KNpc.GetById(tbTrapInfo.nNpcId);

		if pNpc then
			pNpc.Delete();
		end
	end
	self.tbBossTrapList = {}
end

function ImperialTomb:GetBossTrapIndexFromId(nTrapId)
	local tbTrapInfo = self.tbBossTrapList[nTrapId];

	return tbTrapInfo and tbTrapInfo.nTrapIndex
end

function ImperialTomb:GetBossTrapIdFromIndex(nTrapIndex)
	for nTrapId,tbTrapInfo in pairs(self.tbBossTrapList) do
		if tbTrapInfo.nTrapIndex == nTrapIndex then
			return nTrapId
		end
	end
end

function ImperialTomb:GetBossTrapInfoFromId(nTrapId)
	local tbTrapInfo = self.tbBossTrapList[nTrapId]
	if tbTrapInfo then
		return tbTrapInfo.nMapTemplateId, tbTrapInfo.nMapId, tbTrapInfo.nX, tbTrapInfo.nY, tbTrapInfo.nTrapIndex
	end
end

function ImperialTomb:GetBossTrapInfoFromIndex(nTrapIndex)
	if not nTrapIndex then
		return
	end
	
	for nTrapId,tbTrapInfo in pairs(self.tbBossTrapList) do
		if tbTrapInfo.nTrapIndex == nTrapIndex then
			return tbTrapInfo.nMapTemplateId, tbTrapInfo.nMapId, tbTrapInfo.nX, tbTrapInfo.nY, nTrapId
		end
	end
end

function ImperialTomb:IsAllBossDead()
	for _,tbNpcInfo in pairs(self.tbBossList) do
		if not tbNpcInfo.bDead then
			return false
		end
	end

	return true
end

function ImperialTomb:GetBossMapByIndex(nIndex)
	for nMapId, tbInfo in pairs(self.tbBossMapList) do
		if tbInfo.nParam == nIndex then
			return tbInfo
		end
	end

	return nil
end

function ImperialTomb:IsBossRoomOpen(nIndex)
	local tbMapInfo = self:GetBossMapByIndex(nIndex)
	if not tbMapInfo or not tbMapInfo.bCreated or not tbMapInfo.bOpen then
		return false
	end

	return true, tbMapInfo
end
