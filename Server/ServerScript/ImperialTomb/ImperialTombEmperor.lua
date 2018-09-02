--开始始皇降世，先刷新首领
function ImperialTomb:OpenEmperor(bOpenFemaleEmperor)
	local nNeedCount = self.EMPEROR_COUNT
	local nIndex = 0;

	if bOpenFemaleEmperor then
		self.bOpenFemaleEmperor = true
		Calendar:OnActivityBegin("ImperialTombFemaleEmperor")
	else
		self.bOpenFemaleEmperor = false
		Calendar:OnActivityBegin("ImperialTombEmperor")
	end

	local nMapType = self.MAP_TYPE.EMPEROR_ROOM

	if self.bOpenFemaleEmperor then
		nMapType = self.MAP_TYPE.FEMALE_EMPEROR_ROOM
	end

	for nMapId,tbMapInfo in pairs(self.tbEmperorMapList) do
		nNeedCount = nNeedCount  - 1;
		nIndex = nIndex + 1;
		tbMapInfo.nEndTimer = Timer:Register(Env.GAME_FPS * self.EMPEROR_EXSIT_TIME, self.OnEmperorTimeOut, self, nMapId);
		--tbMapInfo.bOpen = true
		SetMapSurvivalTime(tbMapInfo.nMapId, GetTime()+self.EMPEROR_EXSIT_TIME*2)
	end

	if nNeedCount > 0 then
		for i=1,nNeedCount do
			local _, tbMapInfo = self:CreateRequest(nMapType, nIndex + i);
			tbMapInfo.nEndTimer = Timer:Register(Env.GAME_FPS * self.EMPEROR_EXSIT_TIME, self.OnEmperorTimeOut, self, tbMapInfo.nMapId);
			--[[if tbMapInfo then
				tbMapInfo.bOpen = true
			end]]
		end
	end

	if not self.bOpenFemaleEmperor then
		--武则天可以同时挂机
		self:ClearAllPlayerTmpRevive();
		self:ClearAllPlayerSecretInvite();

		self:TransferNormalFloorPlayerOut()
		self:DeleteNormalFloorNpc()
	end

	self:ClearEmperorData()

	self:OpenBossRoom()

	self:SendEmperorPrepare()

	self.bOpenEmperor = true
end

function ImperialTomb:CloseEmperor()

	self:EmperorAward()

	for nNpcId,tbNpcInfo in pairs(self.tbEmperorList) do
		local pNpc = KNpc.GetById(nNpcId);

		if pNpc then
			pNpc.Delete();
		end

		for _,nSweepNpcId in ipairs(tbNpcInfo.tbSweepNpcId) do
			local pSweepNpc = KNpc.GetById(nSweepNpcId)
			if pSweepNpc then
				pSweepNpc.Delete();
			end
		end

		tbNpcInfo.tbSweepNpcId = {}
		tbNpcInfo.bDead = true

		if tbNpcInfo.nMirrorTransTimer and Timer:GetRestTime(tbNpcInfo.nMirrorTransTimer) >= 0 then
			Timer:Close(tbNpcInfo.nMirrorTransTimer)
		end
		
		tbNpcInfo.nMirrorTransTimer = nil

		if tbNpcInfo.nMirrorEndTimer and Timer:GetRestTime(tbNpcInfo.nMirrorEndTimer) >= 0 then
			Timer:Close(tbNpcInfo.nMirrorEndTimer)
		end
		
		tbNpcInfo.nMirrorEndTimer = nil

		if tbNpcInfo.nMirrorSkillTimer and Timer:GetRestTime(tbNpcInfo.nMirrorSkillTimer) >= 0 then
			Timer:Close(tbNpcInfo.nMirrorSkillTimer)
		end
		
		tbNpcInfo.nMirrorSkillTimer = nil
	end

	for nNpcId,tbNpcInfo in pairs(self.tbEmperorMirrorList) do
		local pNpc = KNpc.GetById(nNpcId);

		if pNpc then
			pNpc.Delete();
		end

		tbNpcInfo.bDead = true


		if tbNpcInfo.nDmgTimer and Timer:GetRestTime(tbNpcInfo.nDmgTimer) >= 0 then
			Timer:Close(tbNpcInfo.nDmgTimer)
		end

		tbNpcInfo.nDmgTimer = nil
	end

	for nMapId,tbMapInfo in pairs(self.tbEmperorMapList) do
		tbMapInfo.bOpen = false
		self:TransMapPlayer(nMapId)

		if tbMapInfo.nEndTimer and Timer:GetRestTime(tbMapInfo.nEndTimer) >= 0 then
			Timer:Close(tbMapInfo.nEndTimer)
		end
		tbMapInfo.nEndTimer = nil
	end

	for nMapId,tbMapInfo in pairs(self.tbEmperorMirrorMapList) do
		self:TransMapPlayer(nMapId)
	end


	self:DeleteTrapNpc()
	--self:ClearEmperorData()
	self:CloseBossRoom()

	if self.bOpenFemaleEmperor then
		self:TransferFemaleEmperorPlayerOut()
		Calendar:OnActivityEnd("ImperialTombFemaleEmperor")
	else
		self:TransferAllPlayerOut();
		Calendar:OnActivityEnd("ImperialTombEmperor")
		self:DeleteNormalFloorNpc()
		self:ReloadNormalFloorNpc()
	end

	self.bOpenEmperor = false
	self.bOpenFemaleEmperor = false
	self.bCallEmperor = false
end

function ImperialTomb:ClearEmperorData()
	self.tbEmperorList = {}
	self.tbEmperorMirrorList = {}
	self.tbMap2Emperor = {}
	self.tbMap2EmperorMirror = {}
	self.tbSyncEmperorDmg = {}
	self.tbFinalEmperorDmg = {}
	self.tbEmperorMirrorDmg = {}
	self.tbTrapList = {}
	self.tbEmperorJoinList = {}
	self.tbMirrorMapAssign = {}
	self.tbPlayerEmperorRoomList = {}
	self.nLastUpdateSyncDmgInfo = 0
	self.bEmperorAward = false
	self.bCallEmperor = false

	if self.tbEmperorTikectList then
		for nPlayerId,_ in pairs(self.tbEmperorTikectList) do
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer then
				pPlayer.CallClientScript("ImperialTomb:SyncEmperorTicketState", false)
			end
		end
	end
	
	self.tbEmperorTikectList = {}
end

function ImperialTomb:CallEmperor()
	if self.bCallEmperor then
		return
	end

	self.bCallEmperor = true

	for nMapId,tbMapInfo in pairs(self.tbEmperorMapList) do
		self:_CallEmperor(nMapId)
		tbMapInfo.bOpen = true
	end

	if self.bOpenFemaleEmperor then
		self:CallFemaleEmperorTrapNpc()
	else
		self:CallTrapNpc()
	end

	self:SendEmperorInvite()
end

function ImperialTomb:_CallEmperor(nMapId)
	local szLvlFrame = Lib:GetMaxTimeFrame(self.NPC_TIME_FRAME_LEVEL);
	local nLevel = nil
	if szLvlFrame then
		nLevel = self.NPC_TIME_FRAME_LEVEL[szLvlFrame]
	end

	if not nLevel then
		Log("[Error]", "ImperialTomb", "CallEmperor Failed Not Found Level Config", nMapId)
		return false
	end

	local tbSweepNpcId = {}
	local tbSweepNpcInfo = self.EMPEROR_SWEEP_INFO

	if self.bOpenFemaleEmperor then
		tbSweepNpcInfo = self.FEMALE_EMPEROR_SWEEP_INFO
	end

	for nRank=1,self.EMPEROR_AWARD_RANK_COUNT do
		local pSweepNpc = KNpc.Add(tbSweepNpcInfo.nTemplate, 1, 0, nMapId, tbSweepNpcInfo.nX, tbSweepNpcInfo.nY, 0);
		if pSweepNpc then
			tbSweepNpcId[nRank] = pSweepNpc.nId
		else
			Log("[Error]", "ImperialTomb", "CallEmperor Failed Add Sweep Npc", nMapId, nRank)
		end
	end
	
	local tbEmperorInfo = self.EMPEROR_INFO
	if self.bOpenFemaleEmperor then
		tbEmperorInfo = self.FEMALE_EMPEROR_INFO
	end

	local pNpc = KNpc.Add(tbEmperorInfo.nTemplate, nLevel, 0, nMapId, tbEmperorInfo.nX, tbEmperorInfo.nY, 0);

	if not pNpc then
		Log("[Error]", "ImperialTomb", "CallEmperor Failed Add Npc", nMapId, nLevel)
		return false
	end

	pNpc.SetActiveForever(1);
	pNpc.SetByAttackCallScript(1);
	pNpc.SetTitleID(tbEmperorInfo.nTitleId);

	for _,nPercent in ipairs(self.EMPEROR_SWEEP_HP) do
		Npc:RegisterNpcHpPercent(pNpc, nPercent, function (nTriggerPercent, nCurPercent)
			self:OnWarnningSweepPlayer(nTriggerPercent, nCurPercent)
		end)
	end

	for _,tbPercent in ipairs(self.EMPEROR_MIRROR_HP) do

		local nEventId = Npc:RegisterNpcHpPercent(pNpc, tbPercent[2], function (nTriggerPercent, nCurPercent)
			self:OnEndEmperorMirror(nTriggerPercent, nCurPercent)
		end)

		Npc:RegisterNpcHpPercent(pNpc, tbPercent[1], function (nTriggerPercent, nCurPercent)
			self:OnStartEmperorMirror(nTriggerPercent, nCurPercent, tbPercent[2], nEventId)
		end)

	end

	local nNpcId = pNpc.nId;
	local nMaxLife = pNpc.nMaxLife

	self.tbEmperorList[nNpcId] = {nNpcId = nNpcId, nTotalDamage = nMaxLife,  nEndTime = (GetTime() + self.EMPEROR_EXSIT_TIME), bDead = false, nFirstKin = nil, nLastKin = nil, tbSweepNpcId = tbSweepNpcId};
	self.tbMap2Emperor[nMapId] = nNpcId;

	local tbPlayer,count = KPlayer.GetMapPlayer(nMapId)
	for _, pPlayer in ipairs(tbPlayer) do
		pPlayer.CallClientScript("ImperialTomb:SyncRoomCloseTime", self.EMPEROR_EXSIT_TIME)
	end

	Log("[Info]", "ImperialTomb", "CallEmperor Success", nMapId, nLevel, nNpcId);

	return true
end

function ImperialTomb:SendEmperorPrepare()
	local nLevelLimit = self.MIN_LEVEL
	if self.bOpenFemaleEmperor then
		nLevelLimit = self.FEMALE_EMPEROR_MIN_LEVEL
	end
	local tbPlayer = KPlayer.GetAllPlayer();
	for _, pPlayer in pairs(tbPlayer) do
		if pPlayer.nLevel >= nLevelLimit then
			pPlayer.CallClientScript("ImperialTomb:EmperorInvite", self.bOpenFemaleEmperor);
		end
	end

	KPlayer.SendWorldNotify(nLevelLimit, 1000,
				self.EMPEROR_PREPARE_MSG[self.bOpenFemaleEmperor].szContent,
				ChatMgr.ChannelType.Public, 1);
end

function ImperialTomb:SendEmperorInvite()
	--[[local tbPlayer = KPlayer.GetAllPlayer();
	for _, pPlayer in pairs(tbPlayer) do
		if pPlayer.nLevel >= self.MIN_LEVEL then
			pPlayer.CallClientScript("ImperialTomb:EmperorInvite");
		end
	end]]
	local nLevelLimit = self.MIN_LEVEL
	if self.bOpenFemaleEmperor then
		nLevelLimit = self.FEMALE_EMPEROR_MIN_LEVEL
	end

	KPlayer.SendWorldNotify(nLevelLimit, 1000,
				self.EMPEROR_CALL_MSG[self.bOpenFemaleEmperor],
				ChatMgr.ChannelType.Public, 1);
end

function ImperialTomb:OnEmperorAttack()
	local nNpcId = him.nId;
	local tbNpcInfo = self.tbEmperorList[nNpcId];

	if not tbNpcInfo then
		local nNpcMapId, _, _ = him.GetWorldPos();
		Log("[Error]", "ImperialTomb", "OnEmperorAttack Not Found Npc Info", nNpcMapId, nNpcId)
		return
	end

	if not tbNpcInfo.nFirstKin and me.dwKinId > 0 then
		tbNpcInfo.nFirstKin = me.dwKinId
		local nNpcMapId, _, _ = him.GetWorldPos();
		Log("[Info]", "ImperialTomb", "OnEmperorAttack First Touch", nNpcMapId, nNpcId, tbNpcInfo.nFirstKin)
	end
end

function ImperialTomb:OnWarnningSweepPlayer(nTriggerPercent, nCurPercent)
	Log("OnWarnningSweepPlayer", nTriggerPercent, nCurPercent)

	local nNpcMapId, _, _ = him.GetWorldPos();

	local tbPlayer,_ = KPlayer.GetMapPlayer(nNpcMapId)
	local szMsg = self.EMPEROR_SWEEP_MSG[self.bOpenFemaleEmperor]
	for _, pPlayer in ipairs(tbPlayer) do
		pPlayer.SendBlackBoardMsg(szMsg)
		pPlayer.Msg(szMsg)
	end

	local nTimer = Timer:Register(Env.GAME_FPS * 1, self.OnEmperorSweepPlayer, self, him.nId);
end

function ImperialTomb:OnEmperorMirrorSkill(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		Log("[Error]", "ImperialTomb", "OnEmperorMirrorSkill Not Found Npc Obj", nNpcId)
		return
	end

	local _,nX,nY = pNpc.GetWorldPos()
	pNpc.CastSkill(self.EMPEROR_MIRROR_SKILL[self.bOpenFemaleEmperor],1,nX,nY)

	return true
end

function ImperialTomb:OnEmperorSweepPlayer(nNpcId)
	Log("OnEmperorSweepPlayer", nNpcId)

	local tbNpcInfo = self.tbEmperorList[nNpcId];

	if not tbNpcInfo then
		Log("[Error]", "ImperialTomb", "OnEmperorSweepPlayer Not Found Npc Info", nNpcId)
		return
	end

	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		Log("[Error]", "ImperialTomb", "OnEmperorSweepPlayer Not Found Npc Obj", nNpcId)
		return
	end

	local tbDamage = pNpc.GetDamageInfo();
	if not tbDamage then
		Log("[Error]", "ImperialTomb", "OnEmperorSweepPlayer No DamageInfo", nNpcId)
		return
	end

	local tbSortedList = self:GetSortedDmgInfo(tbDamage, {tbNpcInfo});

	local nNpcMapId, nNpcX, nNpcY = pNpc.GetWorldPos();
	pNpc.CastSkill(self.EMPEROR_SWEEP_EFFECT_SKILL[self.bOpenFemaleEmperor], 1, nNpcX, nNpcY)

	for nRank,tbKinInfo in ipairs(tbSortedList) do
		local nRate = self.EMPEROR_SWEEP_RATE[nRank]
		if nRate and MathRandom(100000) <= nRate then
			Log("[Info]", "ImperialTomb", "OnEmperorSweepPlayer Kill Kin Player", nNpcId, nRank, tbKinInfo.nId, tbKinInfo.szName)

			local pSweepNpc = KNpc.GetById(tbNpcInfo.tbSweepNpcId[nRank])

			if pSweepNpc then
				nNpcMapId, nNpcX, nNpcY = pSweepNpc.GetWorldPos();
				pSweepNpc.nCamp = 0
				pSweepNpc.dwKinId = tbKinInfo.nId
				pSweepNpc.SetDir(48)
				pSweepNpc.CastSkill(self.EMPEROR_SWEEP_SKILL[self.bOpenFemaleEmperor], 1, nNpcX, nNpcY)
			else
				Log("[Error]", "ImperialTomb", "OnEmperorSweepPlayer Failed Get Sweep Npc", nRank, tbNpcInfo.tbSweepNpcId[nRank])
				return false
			end
		end
	end
end

function ImperialTomb:OnStartEmperorMirror(nTriggerPercent, nCurPercent, nMirrorTargetHP, nEventId)
	Log("OnStartEmperorMirror", nNpcId, nTriggerPercent, nCurPercent, nMirrorTargetHP, nEventId)

	local nNpcId = him.nId;
	local tbNpcInfo = self.tbEmperorList[nNpcId];
	if not tbNpcInfo then
		Log("[Error]", "ImperialTomb", "OnStartEmperorMirror Failed Not Find Npc Info", nNpcId, nTriggerPercent, nCurPercent)
		return false
	end

	if tbNpcInfo.nMirrorTransTimer then
		Log("[Error]", "ImperialTomb", "OnStartEmperorMirror Failed Already Start nMirrorTransTimer", nNpcId, nTriggerPercent, nCurPercent, tbNpcInfo.nMirrorTransTimer)
		return false
	end

	if tbNpcInfo.nMirrorEndTimer then
		Log("[Error]", "ImperialTomb", "OnStartEmperorMirror Failed Already Start nMirrorEndTimer", nNpcId, nTriggerPercent, nCurPercent, tbNpcInfo.nMirrorEndTimer)
		return false
	end

	tbNpcInfo.nMirrorTargetHP = nMirrorTargetHP;
	tbNpcInfo.nMirrorTargetHPEventId = nEventId;
	tbNpcInfo.nMirrorTransTimer = Timer:Register(Env.GAME_FPS * self.MIRROR_TRANS_INTERVAL, self.OnWarnningEmperorMirrorTrans, self, nNpcId);
	tbNpcInfo.nMirrorEndTimer = Timer:Register(Env.GAME_FPS * self.MIRROR_MAP_EXIST_TIME, self.OnEmperorMirrorTimeOut, self, nNpcId);
	tbNpcInfo.nMirrorSkillTimer = Timer:Register(Env.GAME_FPS * self.MIRROR_SKILL_INTERVAL, self.OnEmperorMirrorSkill, self, nNpcId);

	self:OnWarnningEmperorMirrorTrans(nNpcId)
	return true
end

function ImperialTomb:OnWarnningEmperorMirrorTrans(nNpcId)
	local pNpc = KNpc.GetById(nNpcId)
	if not pNpc then
		Log("[Error]", "ImperialTomb", "OnWarnningEmperorMirrorTrans Failed Not Find Npc Obj", nNpcId)
		return true
	end

	local nNpcMapId, nX, nY = pNpc.GetWorldPos();

	pNpc.CastSkill(self.EMPEROR_MIRROR_WARNING_SKILL[self.bOpenFemaleEmperor], 1, nX, nY)

	local szMsg = self.EMPEROR_TRANS_MSG[self.bOpenFemaleEmperor]
	local tbPlayer,_ = KPlayer.GetMapPlayer(nNpcMapId)
	for _, pPlayer in ipairs(tbPlayer) do
		pPlayer.SendBlackBoardMsg(szMsg)
		pPlayer.Msg(szMsg)
	end

	local nTimer = Timer:Register(Env.GAME_FPS * 3, self.OnEmperorMirrorTrans, self, nNpcId);

	return true
end

function ImperialTomb:OnEmperorMirrorTrans(nNpcId)
	local tbNpcInfo = self.tbEmperorList[nNpcId];
	if not tbNpcInfo then
		Log("[Error]", "ImperialTomb", "OnEmperorMirrorTrans Failed Not Find Npc Info", nNpcId)
		return
	end

	local pNpc = KNpc.GetById(nNpcId)
	if not pNpc then
		Log("[Error]", "ImperialTomb", "OnEmperorMirrorTrans Failed Not Find Npc Obj", nNpcId)
		return
	end

	local nNpcMapId, _, _ = pNpc.GetWorldPos();

	--todo ivan 优化算法

	--先找到已经开启但是人还没满的分身地图
	local tbMirrorMapList = {}
	for nMapId, tbMapInfo in pairs(self.tbEmperorMirrorMapList) do
		if tbMapInfo.nParam == nNpcMapId then
			local tbAssignInfo = self.tbMirrorMapAssign[tbMapInfo.nMapId];
			if tbAssignInfo and #tbAssignInfo.tbPlayerList < self.MIRROR_MAP_MAX_PLAYER then
				table.insert(tbMirrorMapList, tbAssignInfo)
			end
		end
	end

	local tbPlayer,_ = KPlayer.GetMapPlayer(nNpcMapId)
	local tbNeedReassign = {}

	Lib:SmashTable(tbPlayer)
	
	--进行队长移交，如果队长不在同一个房间自动把队长移交给房间里的人
	--剔除没有家族的玩家
	for idx=#tbPlayer,1,-1 do
		local pPlayer = tbPlayer[idx]
		local nTeamId = pPlayer.dwTeamID
		local nKinId = pPlayer.dwKinId
		if nKinId <= 0 then
			table.remove(tbPlayer, idx)
		elseif nTeamId > 0 then
			local nCaptainId = nil
			local tbTeam = TeamMgr:GetTeamById(nTeamId);
	
			if tbTeam then
				nCaptainId = tbTeam:GetCaptainId();
			end

			if nCaptainId then
				local pCaptain = KPlayer.GetPlayerObjById(nCaptainId);
				if not pCaptain or pCaptain.dwKinId <= 0 or (pCaptain.nMapId ~= nNpcMapId and( not self:IsEmperorMirrorMapByTemplate(pCaptain.nMapTemplateId) and not self:IsFemaleEmperorMirrorMapByTemplate(pCaptain.nMapTemplateId))) then
					--移交队长
					tbTeam:ChangeCaptain(pPlayer.dwID);
				end
			end
		end
	end

	Lib:Tree(tbPlayer)

	Lib:Tree(tbMirrorMapList)

	--优先填满已经组好队的
	for idx=#tbPlayer,1,-1 do
		local pPlayer = tbPlayer[idx]
		local nKinId = pPlayer.dwKinId
		local nTeamId = pPlayer.dwTeamID
		if nTeamId > 0 then
			nKinId = self:GetTeamKinId(nTeamId)
		end

		for _,tbAssignInfo in pairs(tbMirrorMapList) do
			if #tbAssignInfo.tbPlayerList < self.MIRROR_MAP_MAX_PLAYER then
				if nTeamId > 0 and tbAssignInfo.tbTeamInfo[nTeamId] and tbAssignInfo.tbKinInfo[nKinId] and tbAssignInfo.tbKinInfo[nKinId] < 4 then
					table.insert(tbAssignInfo.tbPlayerList, pPlayer.dwID)
					table.remove(tbPlayer, idx)
					tbAssignInfo.tbKinInfo[nKinId] = tbAssignInfo.tbKinInfo[nKinId] + 1
					tbAssignInfo.tbTeamInfo[nTeamId] = tbAssignInfo.tbTeamInfo[nTeamId] + 1
					tbNeedReassign[tbAssignInfo] = tbAssignInfo
					break;
				end
			end
		end
	end

	--填满家族人数不足的
	for idx=#tbPlayer,1,-1 do
		local pPlayer = tbPlayer[idx]
		local nKinId = pPlayer.dwKinId
		local nTeamId = pPlayer.dwTeamID
		if nTeamId > 0 then
			nKinId = self:GetTeamKinId(nTeamId)
		end
		for _,tbAssignInfo in pairs(tbMirrorMapList) do
			if #tbAssignInfo.tbPlayerList < self.MIRROR_MAP_MAX_PLAYER then
				if tbAssignInfo.tbKinInfo[nKinId] and tbAssignInfo.tbKinInfo[nKinId] < 4 then
					table.insert(tbAssignInfo.tbPlayerList, pPlayer.dwID)
					table.remove(tbPlayer, idx)
					tbAssignInfo.tbKinInfo[nKinId] = tbAssignInfo.tbKinInfo[nKinId] + 1
					tbNeedReassign[tbAssignInfo] = tbAssignInfo
					break;
				end
			end
		end
	end

	local tbKinInfo, tbTeamInfo = self:GetMatchInfoFromPlayerList(tbPlayer);
	local tbTeamAssign = {}
	local tbKinAssign = {}

	Log("tbKinInfo")
	Lib:Tree(tbKinInfo)
	Log("tbTeamInfo")
	Lib:Tree(tbTeamInfo)

	--填满只有一个家族的
	for _,tbAssignInfo in pairs(tbMirrorMapList) do
		if #tbAssignInfo.tbPlayerList < self.MIRROR_MAP_MAX_PLAYER and
			Lib:CountTB(tbAssignInfo.tbKinInfo) == 1 then

		 	local nEnemyKinId,nCount = next(tbAssignInfo.tbKinInfo);
		 	local nTeamId, nTeamAssignCount = self:GetBestMatchTeam(tbTeamInfo, nCount, nEnemyKinId);
		 	local nKinId, nKinAssignCount = self:GetBestMatchKin(tbKinInfo, nCount, nEnemyKinId);

		 	--选择整队进入还是散人进
		 	if nTeamId and math.abs(nCount - nTeamAssignCount) <= math.abs(nCount - nKinAssignCount) then
		 		tbTeamAssign[tbAssignInfo] = {nTeamId = nTeamId, nCount = nTeamAssignCount}
		 		tbTeamInfo[nTeamId] = tbTeamInfo[nTeamId] - nTeamAssignCount
		 	elseif nKinId then
		 		tbKinAssign[tbAssignInfo] = {nKinId = nKinId, nCount = nKinAssignCount}
		 		tbKinInfo[nKinId] = tbKinInfo[nKinId] - nKinAssignCount
		 	end
		end
	end
	for idx=#tbPlayer,1,-1 do
		local pPlayer = tbPlayer[idx]

		local nKinId = pPlayer.dwKinId
		local nTeamId = pPlayer.dwTeamID
		if nTeamId > 0 then
			nKinId = self:GetTeamKinId(nTeamId)
		end

		for _,tbAssignInfo in pairs(tbMirrorMapList) do
			if #tbAssignInfo.tbPlayerList < self.MIRROR_MAP_MAX_PLAYER then
				if tbTeamAssign[tbAssignInfo] and tbTeamAssign[tbAssignInfo].nTeamId == nTeamId then
					table.insert(tbAssignInfo.tbPlayerList, pPlayer.dwID)
					table.remove(tbPlayer, idx)
					tbTeamAssign[tbAssignInfo].nCount = tbTeamAssign[tbAssignInfo].nCount - 1
					tbNeedReassign[tbAssignInfo] = tbAssignInfo
					if tbTeamAssign[tbAssignInfo].nCount <= 0 then
						tbTeamAssign[tbAssignInfo] = nil
					end
				elseif tbKinAssign[tbAssignInfo] and tbKinAssign[tbAssignInfo].nKinId == nKinId then
					table.insert(tbAssignInfo.tbPlayerList, pPlayer.dwID)
					table.remove(tbPlayer, idx)
					tbKinAssign[tbAssignInfo].nCount = tbKinAssign[tbAssignInfo].nCount - 1
					tbNeedReassign[tbAssignInfo] = tbAssignInfo
					if tbKinAssign[tbAssignInfo].nCount <= 0 then
						tbKinAssign[tbAssignInfo] = nil
					end
				end
			end
		end
	end
	
	Log("tbNeedReassign")

	for _,tbAssignInfo in pairs(tbNeedReassign) do

		Lib:LogTB(tbAssignInfo)
		self:AssignPlayerToMirrorMap(tbAssignInfo.tbPlayerList, tbAssignInfo.nFromMapId, tbAssignInfo.nMapId)
	end

	--分配剩余的玩家
	--根据家族人数分组
	for nNeedCount = 4,1,-1 do
		tbKinInfo, tbTeamInfo = self:MatchMirrorPlayer(tbPlayer, nNpcMapId, nNeedCount)
		local nCount = 0

		while (self:IsHaveEnoughMatchCount(tbKinInfo, nNeedCount) and nCount < 200) do
			nCount = nCount + 1
			tbKinInfo, tbTeamInfo = self:MatchMirrorPlayer(tbPlayer, nNpcMapId, nNeedCount)
			Log("tbKinInfo")
			Lib:LogTB(tbKinInfo)
			Log("tbTeamInfo")
			Lib:LogTB(tbTeamInfo)
		end
		if nCount >= 200 then
			assert(false)
		end
	end
	
	assert(Lib:IsEmptyTB(tbPlayer))
end

function ImperialTomb:OnEndEmperorMirror(nTriggerPercent, nCurPercent)
	Log("OnEndEmperorMirror")

	local nNpcId = him.nId;
	local nNpcMapId,_,_ = him.GetWorldPos();
	local tbNpcInfo = self.tbEmperorList[nNpcId];
	if not tbNpcInfo then
		Log("[Error]", "ImperialTomb", "OnEndEmperorMirror Failed Not Find Npc Info", nNpcId)
		return false
	end

	if tbNpcInfo.nMirrorTransTimer and Timer:GetRestTime(tbNpcInfo.nMirrorTransTimer) >= 0 then
		Timer:Close(tbNpcInfo.nMirrorTransTimer)
	end
	
	tbNpcInfo.nMirrorTransTimer = nil

	if tbNpcInfo.nMirrorEndTimer and Timer:GetRestTime(tbNpcInfo.nMirrorEndTimer) >= 0 then
		Timer:Close(tbNpcInfo.nMirrorEndTimer)
	end
	
	tbNpcInfo.nMirrorEndTimer = nil

	if tbNpcInfo.nMirrorSkillTimer and Timer:GetRestTime(tbNpcInfo.nMirrorSkillTimer) >= 0 then
		Timer:Close(tbNpcInfo.nMirrorSkillTimer)
	end
	
	tbNpcInfo.nMirrorSkillTimer = nil

	for nMapId, tbMapInfo in pairs(self.tbEmperorMirrorMapList) do
		local nMirrorNpcId = self.tbMap2EmperorMirror[nMapId]
		if tbMapInfo.nParam == nNpcMapId and nMirrorNpcId then
			self:OnMirrorMapEnd(nMapId, nMirrorNpcId)
		end
	end

	if tbNpcInfo.nMirrorTargetHP then
		local nCurLife = him.nCurLife;
		local nMaxLife = him.nMaxLife;
		local nPercent = 100*nCurLife/nMaxLife;

		Log("[Info]", "ImperialTomb", "OnEndEmperorMirror Emperor Life", tostring(tbNpcInfo.nMirrorTargetHP), tostring(nPercent))

		if tbNpcInfo.nMirrorTargetHP < nPercent then
			--结束阶段时血量没有降低到需要达到的血量
			local nNewLife = nMaxLife * tbNpcInfo.nMirrorTargetHP/100;
			if nCurLife > nNewLife then
				local nDmgBonus = nCurLife - nNewLife
				local tbDmgList = {}
				--将伤害按比例分配
				local tbDamage = him.GetDamageInfo()
				local nTotalDamage = 0;
				for _,tbDamageInfo in pairs(tbDamage) do
					nTotalDamage = nTotalDamage + tbDamageInfo.nTotalDamage
				end

				for _,tbDamageInfo in pairs(tbDamage) do
					local nDmgPercent = 100*tbDamageInfo.nTotalDamage/nTotalDamage
					table.insert(tbDmgList,
					{
						nTeamId = tbDamageInfo.nTeamId,
						nAttackRoleId = tbDamageInfo.nAttackRoleId,
						nLastDmgNpcID = tbDamageInfo.nLastDmgNpcID,
						nTotalDamage = nDmgPercent * nDmgBonus/100,
					})
				end

				if tbNpcInfo.nMirrorTargetHPEventId then
					Npc:UnRegisterNpcHpEvent(nNpcId, tbNpcInfo.nMirrorTargetHPEventId)
				end

				him.SetCurLife(nNewLife)

				Lib:LogTB(tbDmgList)

				self.tbEmperorMirrorDmg[nNpcId] = self.tbEmperorMirrorDmg[nNpcId] or {}

				table.insert(self.tbEmperorMirrorDmg[nNpcId], tbDmgList)
			end
		end
	end

	tbNpcInfo.nMirrorTargetHP = nil
	tbNpcInfo.nMirrorTargetHPEventId = nil
end

function ImperialTomb:OnEmperorMirrorTimeOut(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);

	if not pNpc then
		Log("[Error]", "ImperialTomb", "OnEmperorMirrorTimeOut Failed Not Find Npc Obj", nNpcId)
		return
	end

	GameSetting:SetGlobalObj(nil, pNpc);

	self:OnEndEmperorMirror();

	GameSetting:RestoreGlobalObj();
end

function ImperialTomb:GetBestMatchTeam(tbCountInfo, nNeedCount, nEnemyKinId)
	local nTeamId = nil
	local nAssignCount = nil

	for nTmpId,nCount in pairs(tbCountInfo) do
		if (not nTeamId or math.abs(nCount - nNeedCount) < math.abs(nAssignCount - nNeedCount) or
			(math.abs(nAssignCount - nNeedCount)  ~= 0 and nCount >= nNeedCount)) and 
			self:GetTeamKinId(nTmpId) ~= nEnemyKinId then

			nTeamId = nTmpId
			nAssignCount = math.min(nCount, nNeedCount)
		end
	end

	return nTeamId, nAssignCount
end

function ImperialTomb:MatchMirrorPlayer(tbPlayer, nNpcMapId, nNeedCount)
	Log("========Start MatchMirrorPlayer===============")
	local tbKinInfo, tbTeamInfo = self:GetMatchInfoFromPlayerList(tbPlayer);
	for nKinId,_ in pairs(tbKinInfo) do
		local tbTempKinInfo, tbTempTeamInfo = self:GetMatchInfoFromPlayerList(tbPlayer);
		Log("tbTempKinInfo")
		Lib:LogTB(tbTempKinInfo)
		Log("tbTempTeamInfo")
		Lib:LogTB(tbTempTeamInfo)
		local nCount = tbTempKinInfo[nKinId] or 0
		if nCount >= nNeedCount then
			local tbMatchInfo = nil
			local nEnemyTeamId, nTeamAssignCount = self:GetBestMatchTeam(tbTempTeamInfo, nNeedCount, nKinId);
			--人数最匹配队伍所属家族ID
			local nEnemyTeamKinId = nil
			if nEnemyTeamId then
				nEnemyTeamKinId = self:GetTeamKinId(nEnemyTeamId)
			end
			--人数最匹配队伍所属家族人数
			local nTeamKinCount = 0
			--可以补充进入的人数
			local nTeamKinLeftCount = 0
			if nEnemyTeamKinId and tbTempKinInfo[nEnemyTeamKinId] then
				nTeamKinCount = tbTempKinInfo[nEnemyTeamKinId]
				nTeamKinLeftCount = nTeamKinCount - nTeamAssignCount
			end

		 	local nEnemyKinId, nKinAssignCount = self:GetBestMatchKin(tbTempKinInfo, nNeedCount, nKinId);

		 	local nTeamId, nTeamCount = self:GetBestKinTeam(tbTempTeamInfo, nNeedCount, nKinId);

		 	Log("Match Team", tostring(nEnemyTeamId), tostring(nTeamAssignCount), tostring(nEnemyTeamKinId), tostring(nTeamKinCount), tostring(nTeamKinLeftCount))
		 	Log("Match Kin", tostring(nEnemyKinId), tostring(nKinAssignCount))
		 	Log("Match Self Team", tostring(nTeamId), tostring(nTeamCount))

		 	if nEnemyTeamId and (math.abs(nNeedCount - nTeamAssignCount) <= math.abs(nNeedCount - nKinAssignCount) or
		 		(nTeamAssignCount + nTeamKinLeftCount) >= nNeedCount) then

		 		if (nTeamAssignCount + nTeamKinLeftCount) >= nNeedCount then
		 			nTeamAssignCount = nNeedCount
		 		end

		 		tbMatchInfo = {nEnemyTeamId = nEnemyTeamId, nEnemyKinId = nEnemyTeamKinId, nCount = nTeamAssignCount, nAssignCount = nTeamAssignCount, nTeamId = nTeamId, nTeamCount = nTeamCount}

		 	elseif nEnemyKinId then
		 		tbMatchInfo = {nEnemyKinId = nEnemyKinId, nCount = nKinAssignCount, nAssignCount = nKinAssignCount, nTeamId = nTeamId, nTeamCount = nTeamCount}
		 	else
		 		--这个地图将只会有一个家族的玩家
		 		tbMatchInfo = {nCount = 0, nAssignCount = nNeedCount, nTeamId = nTeamId, nTeamCount = nTeamCount}
		 	end

		 	Log("tbMatchInfo")
		 	if tbMatchInfo then
				Lib:LogTB(tbMatchInfo)
		 	end

		 	if tbMatchInfo then
		 		local nSelfCount = 0
		 		local nEnemyCount = 0
				local tbPlayerList = {}
				for idx=#tbPlayer,1,-1 do
					local pPlayer = tbPlayer[idx]
					local nSelfTeamId = pPlayer.dwTeamID;
					local nSelfKinId = pPlayer.dwKinId;
					if nSelfTeamId > 0 then
						nSelfKinId = self:GetTeamKinId(nSelfTeamId);
					end

					if nSelfCount < tbMatchInfo.nAssignCount and nKinId == nSelfKinId then

						if not tbMatchInfo.nTeamId or tbMatchInfo.nTeamId == nSelfTeamId then
							nSelfCount = nSelfCount + 1;
							table.insert(tbPlayerList, pPlayer.dwID);
					 		table.remove(tbPlayer, idx)
						end

					elseif nEnemyCount < tbMatchInfo.nCount and nSelfKinId == tbMatchInfo.nEnemyKinId then

						if not tbMatchInfo.nEnemyTeamId or tbMatchInfo.nEnemyTeamId == nSelfTeamId then
							nEnemyCount = nEnemyCount + 1;
							table.insert(tbPlayerList, pPlayer.dwID);
					 		table.remove(tbPlayer, idx)
						end
					end
				end

				if nEnemyCount < tbMatchInfo.nCount or nSelfCount < tbMatchInfo.nAssignCount then
					for idx=#tbPlayer,1,-1 do
						local pPlayer = tbPlayer[idx]
						local nSelfTeamId = pPlayer.dwTeamID;
						local nSelfKinId = pPlayer.dwKinId;
						if nSelfTeamId > 0 then
							nSelfKinId = self:GetTeamKinId(nSelfTeamId);
						end

						if nSelfCount < tbMatchInfo.nAssignCount and nSelfKinId == nKinId then
							nSelfCount = nSelfCount + 1;
							table.insert(tbPlayerList, pPlayer.dwID);
					 		table.remove(tbPlayer, idx)
						elseif nEnemyCount < tbMatchInfo.nCount and nSelfKinId == tbMatchInfo.nEnemyKinId then
							nEnemyCount = nEnemyCount + 1;
							table.insert(tbPlayerList, pPlayer.dwID);
					 		table.remove(tbPlayer, idx)
						end
					end
				end

			 	Log("tbPlayerList")
				Lib:LogTB(tbPlayerList)

				self:AssignPlayerToMirrorMap(tbPlayerList, nNpcMapId)
		 	end
		end
	end

	return self:GetMatchInfoFromPlayerList(tbPlayer)
end

function ImperialTomb:IsHaveEnoughMatchCount(tbMatchSource, nNeedCount)
	for _,nCount in pairs(tbMatchSource) do
		if nCount >= nNeedCount then
			return true
		end
	end
end

function ImperialTomb:GetBestMatchKin(tbCountInfo, nNeedCount, nEnemyKinId)
	local nKinId = nil
	local nAssignCount = nil

	for nTmpId,nCount in pairs(tbCountInfo) do
		if (not nKinId or math.abs(nCount - nNeedCount) < math.abs(nAssignCount - nNeedCount) or
			(math.abs(nAssignCount - nNeedCount)  ~= 0 and nCount >= nNeedCount)) and 
			nTmpId ~= nEnemyKinId then

			nKinId = nTmpId
			nAssignCount = math.min(nCount, nNeedCount)
		end
	end

	return nKinId, nAssignCount
end

function ImperialTomb:GetBestKinTeam(tbTeamInfo, nNeedCount, nKinId)
	local nRetTeamId = nil
	local nRetTeamCount = nil
	for nTeamId,nCount in pairs(tbTeamInfo) do
		local nTeamKinId = self:GetTeamKinId(nTeamId)
		if nKinId == nTeamKinId and (not nRetTeamId or math.abs(nCount - nNeedCount) <= math.abs(nRetTeamCount - nNeedCount) ) then
			nRetTeamId = nTeamId
			nRetTeamCount = nCount
		end
	end

	return nRetTeamId, nRetTeamCount
end

function ImperialTomb:OnEmperorDeath(pNpc, pKiller)
	local nNpcId = pNpc.nId;
	local nNpcMapId, _, _ = pNpc.GetWorldPos();
	local tbNpcInfo = self.tbEmperorList[nNpcId];

	if not tbNpcInfo then
		Log("[Error]", "ImperialTomb", "OnEmperorDeath Not Found Npc Info", nNpcMapId, nNpcId)
		return
	end

	tbNpcInfo.bDead = true

	local nPlayerId = pNpc.GetLastDmgMePlayerID();
	local szKinName = nil
	local szPlayerName = nil

	Log("[Info]", "ImperialTomb", "OnEmperorDeath", nNpcMapId,  nNpcId, tostring(nPlayerId));

	if nPlayerId and nPlayerId > 0 then
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			szPlayerName = pPlayer.szName
			local szBagKey = "KillEmperor"
			if self.bOpenFemaleEmperor then
				szBagKey = "KillFemaleEmperor"
			end
			Sdk:SendTXLuckyBagMail(pPlayer, szBagKey);
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

	local tbDamage = pNpc.GetDamageInfo();
	if tbDamage then
		Log("------Start Emperor Dmg Info------", nNpcMapId,  nNpcId);
		Lib:LogTB(tbDamage);
		Log("------End Emperor Dmg Info------", nNpcMapId,  nNpcId);
		
		local nTotalDamage = 0
		for _,tbDamageInfo in pairs(tbDamage) do
			nTotalDamage = nTotalDamage + tbDamageInfo.nTotalDamage
		end

		local tbMirrorDmgList = self.tbEmperorMirrorDmg[nNpcId];

		if tbMirrorDmgList then
			for nNpcId,tbMirrorDmg in pairs(tbMirrorDmgList) do
				for _,tbDamageInfo in pairs(tbMirrorDmg) do
					nTotalDamage = nTotalDamage + tbDamageInfo.nTotalDamage
				end
			end
		end

		tbNpcInfo.nTotalDamage = nTotalDamage

		self.tbFinalEmperorDmg = Lib:MergeTable(self.tbFinalEmperorDmg, tbDamage);
	end

	tbNpcInfo.szLastKinName = szKinName
	tbNpcInfo.szLastPlayerName = szPlayerName
	
	local szMsg = ""
	local szTargetName = "始皇"
	local nLevelLimit = self.MIN_LEVEL
	if self.bOpenFemaleEmperor then
		szTargetName = "女帝"
		nLevelLimit = self.FEMALE_EMPEROR_MIN_LEVEL
	end

	if szKinName and szPlayerName then
		szMsg = string.format(XT("恭喜「%s」幫派的「%s」給予%s最後一擊，使其得以安息", szKinName, szPlayerName, szTargetName))
	elseif szPlayerName then
		szMsg = string.format(XT("恭喜「%s」給予%s最後一擊，使其得以安息", szPlayerName, szTargetName))
	end

	KPlayer.SendWorldNotify(nLevelLimit, 1000,
				szMsg,
				ChatMgr.ChannelType.Public, 1);

	if self:IsAllEmperorDead() and self:IsAllBossDead() then
		self:EmperorAward()
	end
end

function ImperialTomb:OnEmperorTimeOut(nMapId)
	local nNpcId = self.tbMap2Emperor[nMapId];

	if not nNpcId then
		Log("[Error]", "ImperialTomb", "OnEmperorTimeOut Not Found Npc Id", nMapId)
		return
	end

	local pNpc = KNpc.GetById(nNpcId);
	local tbNpcInfo = self.tbEmperorList[nNpcId];
	local tbDamage = nil

	if pNpc then
		tbDamage = pNpc.GetDamageInfo();
		pNpc.Delete();
	end

	if not tbNpcInfo then
		Log("[Error]", "ImperialTomb", "OnEmperorTimeOut Not Found Npc Info", nMapId, nNpcId)
		return
	end

	Log("[Info]", "ImperialTomb", "OnEmperorTimeOut", nMapId,  nNpcId);

	tbNpcInfo.bDead = true

	if tbDamage then
		Log("------Start Emperor Dmg Info------", nMapId,  nNpcId);
		Lib:LogTB(tbDamage);
		Log("------End Emperor Dmg Info------", nMapId,  nNpcId);

		self.tbFinalEmperorDmg = Lib:MergeTable(self.tbFinalEmperorDmg, tbDamage);
	end

	if self:IsAllEmperorDead() and self:IsAllBossDead() then
		self:EmperorAward()
	end
end

function ImperialTomb:EmperorAward()

	if self.bEmperorAward then
		return
	end

	self.bEmperorAward = true

	Log("------Start Emperor Info------");
	Lib:LogTB(self.tbEmperorList);
	Log("------End Emperor Info------");

	for nNpcId,tbNpcInfo in pairs(self.tbEmperorList) do

		if not tbNpcInfo.bDead then
			local pNpc = KNpc.GetById(tbNpcInfo.nNpcId);
			if pNpc then
				local tbDamage = pNpc.GetDamageInfo();
				if tbDamage then
					self.tbFinalEmperorDmg = Lib:MergeTable(self.tbFinalEmperorDmg, tbDamage);
				end
			end
		end
	end

	Log("------Start Boss Info------");
	Lib:LogTB(self.tbBossList);
	Log("------End Boss Info------");

	for nNpcId,tbNpcInfo in pairs(self.tbBossList) do

		if not tbNpcInfo.bDead then
			local pNpc = KNpc.GetById(nNpcId);
			if pNpc then
				local tbDamage = pNpc.GetDamageInfo();
				if tbDamage then

					local nNpcMapId, _, _ = pNpc.GetWorldPos();
					local tbSortedList = self:GetSortedDmgInfo(tbDamage,
									{tbNpcInfo},
									 self.BOSS_FIRST_LAST_DMG_BONUS,
									 self.BOSS_DMG_PERCENT_FACTOR
									 );

					self.tbFinalBossDmg[nNpcMapId] = 
							{
								tbSortedList = tbSortedList,
								nMapId = nNpcMapId,
								nNpcId = nNpcId,
								nNpcTemplate = pNpc.nTemplateId,
								szNpcName = pNpc.szName,
							}
				end
			end
		end
	end

	Log("------Start All Emperor Dmg Info------");
	Lib:LogTB(self.tbFinalEmperorDmg);
	Log("------End All Emperor Dmg Info------");


	Log("------Start All Emperor Mirror Dmg Info------");
	Lib:LogTB(self.tbEmperorMirrorDmg);
	Log("------End All Emperor Mirror Info------");

	local tbDamageList = {};
	Lib:MergeTable(tbDamageList, self.tbFinalEmperorDmg);

	for nEmperorNpcId,tbMirrorDmgList in pairs(self.tbEmperorMirrorDmg) do
		for nNpcId,tbMirrorDmg in pairs(tbMirrorDmgList) do
			Lib:MergeTable(tbDamageList, tbMirrorDmg);
		end
	end

	local tbSortedList = self:GetSortedDmgInfo(tbDamageList, 
							self.tbEmperorList,
							self.FIRST_LAST_DMG_BONUS,
							self.DMG_PERCENT_FACTOR
							);

	Log("------Start All Emperor Dmg tbSortedList Info------");
	Lib:LogTB(tbSortedList);
	Log("------End All Emperor Dmg tbSortedList Info------");

	Log("------Start All Boss Dmg Info------");
	Lib:LogTB(self.tbFinalBossDmg);
	Log("------End All Boss Dmg Info------");

	local nAwardGroup = self.EMPEROR_AWARD_ID;
	if self.bOpenFemaleEmperor then
		nAwardGroup = self.FEMALE_EMPEROR_AWARD_ID
	end
	
	local tbKinAwardList = RandomAward:GetKinAuctionAwardByRank(nAwardGroup, tbSortedList, self.EMPEROR_AWARD_RANK_COUNT, ImperialTomb.CalAwardValue)

	--计算家族首领所有价值量总值
	local tbKinBossValue = {}
	for _, tbBossDmgInfo in pairs(self.tbFinalBossDmg) do
		local nAwardGroupId = self.BOSS_AWARD_ID[tbBossDmgInfo.nNpcTemplate]
		if nAwardGroupId then
			local tbAwardList, tbGroup = RandomAward:GetKinAwardByGroup(nAwardGroupId)
			if tbGroup then
				for _,tbKinDmgInfo in pairs(tbBossDmgInfo.tbSortedList) do
					local nKinId = tbKinDmgInfo.nId
					tbKinBossValue[nKinId] = tbKinBossValue[nKinId] or 0
					tbKinBossValue[nKinId] = tbKinBossValue[nKinId] + tbGroup.nBaseValue * (tbKinDmgInfo.nPercent/100)
				end
			else
				Log("[Error]", "ImperialTomb", "EmperorAward Not Found Boss Award Group", tbBossDmgInfo.nNpcTemplate, nAwardGroupId)
				Lib:LogTB(tbBossDmgInfo)
			end
		else
			Log("[Error]", "ImperialTomb", "EmperorAward Not Found Boss Award Group", tbBossDmgInfo.nNpcTemplate)
			Lib:LogTB(tbBossDmgInfo)
		end
	end

	for _, tbBossDmgInfo in pairs(self.tbFinalBossDmg) do
		local nAwardGroupId = self.BOSS_AWARD_ID[tbBossDmgInfo.nNpcTemplate]
		if nAwardGroupId then
			local tbBossAwardList = RandomAward:GetKinAuctionAwardByRank(nAwardGroupId,
			 tbBossDmgInfo.tbSortedList,
			  self.BOSS_AWARD_RANK_COUNT,
			  function ( nId, nRank, nPercent, nBaseValue, nValue, nFactor )
			  	local nTotalValue = tbKinBossValue[nId] or 1
			  	local nJoinCount = ImperialTomb:GetEmperorJoinCount(nId);
				local nMaxValue = nJoinCount * ImperialTomb.BOSS_MAX_PLAYER_VALUE[ImperialTomb.bOpenFemaleEmperor]
				local nKinValue = nBaseValue * (nPercent/100)
				nMaxValue = nMaxValue * nKinValue/nTotalValue

				if nKinValue > nMaxValue then
					nKinValue = nMaxValue
				end

				Log("[Info]", "ImperialTomb", "CalBossAwardValue", nId, nRank, nPercent, nBaseValue, nValue, nFactor, nKinValue, nMaxValue, nTotalValue, nBaseValue * (nPercent/100), nJoinCount, nKinValue * (nFactor/100000));

				return  nKinValue * (nFactor/100000)
			  end)
			if tbBossAwardList then
				Lib:MergeSameKeyTable(tbKinAwardList, tbBossAwardList)
			end
		else
			Log("[Error]", "ImperialTomb", "EmperorAward Not Found Boss Award Group", tbBossDmgInfo.nNpcTemplate)
			Lib:LogTB(tbBossDmgInfo)
		end
	end

	local tbDefaultAward = self.EMPEROR_DEFAULT_AWARD_ITEM;
	if self.bOpenFemaleEmperor then
		tbDefaultAward = self.FEMALE_EMPEROR_DEFAULT_AWARD_ITEM
	end

	local szDefaultFrame = Lib:GetMaxTimeFrame(tbDefaultAward)
	local tbDefaultItemList = tbDefaultAward[szDefaultFrame]
	
	for nKinId, tbAwardList in pairs(tbKinAwardList) do
		--增加保底奖励
		local nJoinCount = self:GetEmperorJoinCount(nKinId);
		local nDefaultValue = nJoinCount * self.EMPEROR_DEFAULT_AWARD_ITEM_VALUE[self.bOpenFemaleEmperor];
		local tbAwardMap = {}
		for _,tbAward in pairs(tbAwardList) do
			tbAwardMap[tbAward[1]] = (tbAwardMap[tbAward[1]] or 0) + tbAward[2]
		end
		
		if tbDefaultItemList then
			for _,tbDefaultItem in pairs(tbDefaultItemList) do
				local nItemValue = KItem.GetBaseValue(tbDefaultItem.nItemTemplateId)
				if tbDefaultItem.szGuaranteeKey and tbDefaultItem.szGuaranteeKey ~= "" then
					local nCurCount = tbAwardMap[tbDefaultItem.nItemTemplateId] or 0;
					if nCurCount > 0 then
						local tbKinData = Kin:GetKinById(nKinId)
						if tbKinData then
							local nCurGuaranteeValue = tbKinData:GetAwardGuarantee(tbDefaultItem.szGuaranteeKey)
							tbKinData:SetAwardGuarantee(tbDefaultItem.szGuaranteeKey, nCurGuaranteeValue + nDefaultValue * tbDefaultItem.nRate)
							Log("[Info]", "ImperialTomb", "Default Guarantee Value", tbDefaultItem.szGuaranteeKey, nCurGuaranteeValue, nCurGuaranteeValue + nDefaultValue * tbDefaultItem.nRate)
						end
					else
						local nCount = RandomAward:GetKinGuaranteeAwardCount(nKinId,
									 nDefaultValue * tbDefaultItem.nRate, nItemValue, tbDefaultItem.szGuaranteeKey)	
						if nCount > 0 then
							table.insert(tbAwardList, {tbDefaultItem.nItemTemplateId, nCount})
						end
					end
				else
					local nCount = RandomAward:GetKinAwardCount(nKinId,
						nDefaultValue * tbDefaultItem.nRate,
						nItemValue)

					if nCount > 0 then
						table.insert(tbAwardList, {tbDefaultItem.nItemTemplateId, nCount})
					end
				end
			end
		end
		
		Log("[Info]", "ImperialTomb", "Kin Award", nKinId);
		Lib:LogTB(tbAwardList);

		local szAuctionType = "ImperialTombEmperor"
		if self.bOpenFemaleEmperor then
			szAuctionType = "ImperialTombFemaleEmperor"
		end

		Kin:AddAuction(nKinId, szAuctionType, self.tbEmperorJoinList[nKinId], tbAwardList)
	end

	Log("[Info]", "ImperialTomb", "EmperorAward");
end

function ImperialTomb.CalAwardValue(nId, nRank, nPercent, nBaseValue, nValue, nFactor)
	local nJoinCount = ImperialTomb:GetEmperorJoinCount(nId);
	local nMaxValue = nJoinCount * ImperialTomb.EMPEROR_MAX_PLAYER_VALUE[ImperialTomb.bOpenFemaleEmperor]
	local nKinValue = nBaseValue * (nPercent/100)

	if nKinValue > nMaxValue then
		nKinValue = nMaxValue
	end

	Log("[Info]", "ImperialTomb", "CalAwardValue", nId, nRank, nPercent, nBaseValue, nValue, nFactor, nKinValue, nMaxValue, nBaseValue * (nPercent/100), nJoinCount, nKinValue * (nFactor/100000));

	return  nKinValue * (nFactor/100000)
end

function ImperialTomb:IsAllEmperorDead()
	for _,tbNpcInfo in pairs(self.tbEmperorList) do
		if not tbNpcInfo.bDead then
			return false
		end
	end

	return true
end

function ImperialTomb:GetPlayerKinID(nPlayerID)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
	local nKinId = 0;
	if pPlayer then
		nKinId = pPlayer.dwKinId;
	else
		local tbStayInfo = KPlayer.GetRoleStayInfo(nPlayerID);
		if tbStayInfo then
			nKinId = tbStayInfo.dwKinId;
		end
	end

	return nKinId;
end

function ImperialTomb:GetSortedDmgInfo(tbDamageList, tbNpcList, nDmgBonus, nDmgFactor)
	local tbSortedList = {};
	local tbKinDmgMap = {};
	local nTotalDamage = 0;

	nDmgBonus = nDmgBonus or 0
	nDmgFactor = nDmgFactor or 1

	for _,tbNpcInfo in pairs(tbNpcList) do
		nTotalDamage = nTotalDamage + tbNpcInfo.nTotalDamage or 0
	end

	--合并家族伤害列表
	for nRank, tbDmgInfo in ipairs(tbDamageList) do
		local nCaptainId = -1;
		local tbTeam = nil;
		if tbDmgInfo.nTeamId > 0 then
			tbTeam = TeamMgr:GetTeamById(tbDmgInfo.nTeamId);
		end
		if tbTeam then
			nCaptainId = tbTeam:GetCaptainId();
		elseif tbDmgInfo.nAttackRoleId > 0 then
			nCaptainId = tbDmgInfo.nAttackRoleId;
		end

		if nCaptainId > 0 then
			local nKinId = self:GetPlayerKinID(nCaptainId)
			if nKinId > 0 then
				if not tbKinDmgMap[nKinId] then
					local kinData = Kin:GetKinById(nKinId)
					local szKinName = kinData and kinData.szName or "-";
					tbKinDmgMap[nKinId] = 
					{
						nId = nKinId,
						szName = szKinName,
						nDmg = 0,
						nPercent = 0,
					}
				end

				local tbInfo = tbKinDmgMap[nKinId]
				tbInfo.nDmg = tbInfo.nDmg + tbDmgInfo.nTotalDamage
			end
		end
	end

	--如果首摸和最后一击的家族不在伤害列表中
	for nNpcId,tbNpcInfo in pairs(tbNpcList) do
		if tbNpcInfo.nFirstKin and not tbKinDmgMap[tbNpcInfo.nFirstKin] then
			local kinData = Kin:GetKinById(tbNpcInfo.nFirstKin)
			local szKinName = kinData and kinData.szName or "-";
			tbKinDmgMap[tbNpcInfo.nFirstKin] = 
				{
					nId = tbNpcInfo.nFirstKin,
					szName = szKinName,
					nDmg = 0,
					nPercent = 0,
				}
		end

		if tbNpcInfo.nLastKin and not tbKinDmgMap[tbNpcInfo.nLastKin] then
			local kinData = Kin:GetKinById(tbNpcInfo.nLastKin)
			local szKinName = kinData and kinData.szName or "-";
			tbKinDmgMap[tbNpcInfo.nLastKin] = 
				{
					nId = tbNpcInfo.nLastKin,
					szName = szKinName,
					nDmg = 0,
					nPercent = 0,
				}
		end
	end


	for nKinId,tbDmgInfo in pairs(tbKinDmgMap) do
		local nPercent = tbDmgInfo.nDmg * 100 / nTotalDamage;

		nPercent = nPercent + nDmgBonus * self:GetFirstDmgKinBonus(nKinId, tbNpcList);
		nPercent = nPercent + nDmgBonus * self:GetLastDmgKinBonus(nKinId, tbNpcList);

		nPercent = nPercent * nDmgFactor;

		nPercent = math.max(self.MIN_DMG_PERCENT, nPercent);
		nPercent = math.min(nPercent, 100);
		tbDmgInfo.nPercent = nPercent;

		table.insert(tbSortedList, tbDmgInfo)
	end

	local function fnDamageCmp(a, b)
		return a.nPercent > b.nPercent;
	end

	table.sort(tbSortedList, fnDamageCmp);

	return tbSortedList;
end

function ImperialTomb:GetFirstDmgKinBonus(nKinId, tbNpcList)
	local nCount = 0;
	for nNpcId,tbNpcInfo in pairs(tbNpcList) do
		if tbNpcInfo.nFirstKin == nKinId then
			nCount = nCount + 1
		end
	end

	return nCount;
end

function ImperialTomb:GetLastDmgKinBonus(nKinId, tbNpcList)
	local nCount = 0;
	for nNpcId,tbNpcInfo in pairs(tbNpcList) do
		if tbNpcInfo.nLastKin == nKinId then
			nCount = nCount + 1
		end
	end

	return nCount;
end

function ImperialTomb:SyncEmperorTime(pPlayer)
	local nMapId,_,_ = pPlayer.GetWorldPos();

	local tbMapInfo = self.tbMapList[nMapId]

	if not tbMapInfo then
		return
	end

	local nTime = math.max(Timer:GetRestTime(tbMapInfo.nEndTimer), 0) / Env.GAME_FPS;
	pPlayer.CallClientScript("ImperialTomb:SyncRoomCloseTime", nTime)
end

function ImperialTomb:SyncEmperorMirrorTime(pPlayer)
	local nMapId,_,_ = pPlayer.GetWorldPos();

	local nNpcId = self.tbMap2EmperorMirror[nMapId];
	if not nNpcId then
		return
	end

	local tbNpcInfo = self.tbEmperorMirrorList[nNpcId]
	if not tbNpcInfo then
		return
	end

	local nFromMapId = tbNpcInfo.nFromMapId

	nNpcId = self.tbMap2Emperor[nFromMapId];
	if not nNpcId then
		return
	end

	tbNpcInfo = self.tbEmperorList[nNpcId]
	if not tbNpcInfo then
		return
	end

	local nTime = math.max(Timer:GetRestTime(tbNpcInfo.nMirrorEndTimer), 0) / Env.GAME_FPS;
	pPlayer.CallClientScript("ImperialTomb:SyncRoomCloseTime", nTime)
end

function ImperialTomb:SynEmperorDmgInfo(pPlayer)
	self:UpdateSynDmgInfo();
	pPlayer.CallClientScript("ImperialTomb:SynEmperorDmgInfo", self.tbSyncEmperorDmg)
end

function ImperialTomb:UpdateSynDmgInfo()
	local nNow = GetTime();
	if (self.nLastUpdateSyncDmgInfo + self.UPDATE_SYNC_DMG_INTERVAL) > nNow then
		return
	end

	local tbDamageList = {};
	Lib:MergeTable(tbDamageList, self.tbFinalEmperorDmg);

	for nEmperorNpcId,tbMirrorDmgList in pairs(self.tbEmperorMirrorDmg) do
		for nNpcId,tbMirrorDmg in pairs(tbMirrorDmgList) do
			Lib:MergeTable(tbDamageList, tbMirrorDmg);
		end
	end

	for nNpcId,tbNpcInfo in pairs(self.tbEmperorList) do
		if not tbNpcInfo.bDead then
			local pNpc = KNpc.GetById(tbNpcInfo.nNpcId);
			if pNpc then
				local tbDamage = pNpc.GetDamageInfo();
				if tbDamage then
					Lib:MergeTable(tbDamageList, tbDamage);
				end
			end
		end
	end
	
	local tbSortedList = self:GetSortedDmgInfo(tbDamageList, 
							self.tbEmperorList,
							self.FIRST_LAST_DMG_BONUS,
							self.DMG_PERCENT_FACTOR
							);
	self.tbSyncEmperorDmg = self:GetSyncDmg(tbSortedList, self.EMPEROR_SYNC_DMG_COUNT);

	self.nLastUpdateSyncDmgInfo = nNow;
end

function ImperialTomb:GetEmperorInfoByMapId(nMapId)
	local nNpcId = self.tbMap2Emperor[nMapId];
	if not nNpcId then
		return
	end

	return self.tbEmperorList[nNpcId]
end

function ImperialTomb:_AddEmperorTrapNpc(nMapTemplateId, nMapId, nX, nY, nTrapId, nTrapIndex, szName)
	local pNpc = KNpc.Add(73, 1, 0, nMapId, nX, nY);
	if pNpc then
		pNpc.SetName(szName)
		self.tbTrapList[nTrapId] = {nMapTemplateId = nMapTemplateId, nNpcId = pNpc.nId, nMapId = nMapId,
						nX=nX, nY=nY, nTrapId = nTrapId, nTrapIndex = nTrapIndex};
	end

	return pNpc
end

function ImperialTomb:CallTrapNpc()
	local tbMapInfo = self.tbNormalMapList[self.MAP_TYPE.THIRD_FLOOR]

	if not tbMapInfo then
		return
	end

	for nTrapId,tbPos in ipairs(self.EMPEROR_ROOM_TRAP_POS) do
		self:_AddEmperorTrapNpc(tbMapInfo.nMapTemplateId, tbMapInfo.nMapId, tbPos[1], tbPos[2], nTrapId, nTrapId, XT("通往永生台"))
	end
end

function ImperialTomb:CallFemaleEmperorTrapNpc()
	local tbMapInfo = self.tbNormalMapList[self.MAP_TYPE.FEMALE_EMPEROR_FLOOR]

	local fnRandom = Lib:GetDifferentEntry(self.FEMALE_EMPEROR_ROOM_TRAP_POS);

	for nTrapIndex=1,self.EMPEROR_COUNT do
		local tbPos, nTrapId = fnRandom();
		self:_AddEmperorTrapNpc(tbMapInfo.nMapTemplateId, tbMapInfo.nMapId, tbPos[1], tbPos[2], nTrapId, nTrapIndex, XT("通往天后神都"))
	end
end

function ImperialTomb:DeleteTrapNpc()
	for _,tbTrapInfo in pairs(self.tbTrapList) do
		local pNpc = KNpc.GetById(tbTrapInfo.nNpcId);

		if pNpc then
			pNpc.Delete();
		end
	end
	self.tbTrapList = {}
end

function ImperialTomb:GetTrapIndexFromId(nTrapId)
	local tbTrapInfo = self.tbTrapList[nTrapId];

	return tbTrapInfo and tbTrapInfo.nTrapIndex
end

function ImperialTomb:GetTrapIdFromIndex(nTrapIndex)
	for nTrapId,tbTrapInfo in pairs(self.tbTrapList) do
		if tbTrapInfo.nTrapIndex == nTrapIndex then
			return nTrapId
		end
	end
end

function ImperialTomb:GetTrapInfoFromId(nTrapId)
	if not nTrapId then
		return
	end
	
	local tbTrapInfo = self.tbTrapList[nTrapId]
	if tbTrapInfo then
		return tbTrapInfo.nMapTemplateId, tbTrapInfo.nMapId, tbTrapInfo.nX, tbTrapInfo.nY, tbTrapInfo.nTrapIndex 
	end
end

function ImperialTomb:GetTrapInfoFromIndex(nTrapIndex)
	if not nTrapIndex then
		return
	end
	
	for nTrapId,tbTrapInfo in pairs(self.tbTrapList) do
		if tbTrapInfo.nTrapIndex == nTrapIndex then
			return tbTrapInfo.nMapTemplateId, tbTrapInfo.nMapId, tbTrapInfo.nX, tbTrapInfo.nY, nTrapId
		end
	end
end

function ImperialTomb:AddEmperorJoinInfo(pPlayer)
	local nKinId = pPlayer.dwKinId
	if nKinId and nKinId > 0 then
		self.tbEmperorJoinList[nKinId] = self.tbEmperorJoinList[nKinId] or {}
		self.tbEmperorJoinList[nKinId][pPlayer.dwID] = true
	end
end

function ImperialTomb:GetEmperorJoinCount(nKinId)
	local tbKinJoinInfo = self.tbEmperorJoinList[nKinId]
	if not tbKinJoinInfo then
		return 0
	end

	return Lib:CountTB(tbKinJoinInfo)
end

function ImperialTomb:GetSyncDmg(tbSortedList, nCountLimit)
	local nCount = 0;
	local tbSyncDmg = {}
	for nRank,tbDmgInfo in ipairs(tbSortedList) do
		
		table.insert(tbSyncDmg, {tbDmgInfo.szName, tbDmgInfo.nPercent});

		nCount = nCount + 1;
		if nCount >= nCountLimit then
			break;
		end
	end

	return tbSyncDmg
end

function ImperialTomb:AssignPlayerToMirrorMap(tbPlayerList, nFromMapId, nMapId)
	Log("AssignPlayerToMirrorMap", tostring(nFromMapId), tostring(nMapId))
	Lib:LogTB(tbPlayerList)

	local tbAssignInfo = nil
	if nMapId then
		local tbMapInfo = self.tbMapList[nMapId];
		if not tbMapInfo then
			Lib:LogTB(tbPlayerList)
			Log("[Error]", "ImperialTomb", "AssignPlayerToMirrorMap Not Find Exsit Mirror Map Info ", nFromMapId, nMapId);
			return
		end

		tbAssignInfo = self.tbMirrorMapAssign[nMapId]
		if not tbAssignInfo then
			Lib:LogTB(tbPlayerList)
			Log("[Error]", "ImperialTomb", "AssignPlayerToMirrorMap Not Find Exsit Mirror Map Assign Info", nFromMapId, nMapId);
			return
		end

		tbAssignInfo.tbPlayerList = tbPlayerList

		Log("tbMapInfo.bCreated", tostring(tbMapInfo.bCreated))

		if tbMapInfo.bCreated then
			--地图已经创建好，直接传进去
			local nPosX, nPosY = Map:GetDefaultPos(tbMapInfo.nMapTemplateId);

			for idx=#tbAssignInfo.tbPlayerList,1,-1 do
				local nPlayerId = tbAssignInfo.tbPlayerList[idx]
				local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
				local nPlayerMapId = pPlayer and pPlayer.nMapId
				if pPlayer and nPlayerMapId == tbAssignInfo.nFromMapId then
					pPlayer.SwitchMap(nMapId, nPosX, nPosY);
				elseif not pPlayer or nPlayerMapId ~= nMapId then
					table.remove(tbAssignInfo.tbPlayerList, idx)
				end
			end
		end
	else
		local nMirrorMapType = self.MAP_TYPE.EMPEROR_MIRROR_ROOM
		if self.bOpenFemaleEmperor then
			nMirrorMapType = self.MAP_TYPE.FEMALE_EMPEROR_MIRROR_ROOM
		end

		local bRet, tbMapInfo = self:CreateRequest(nMirrorMapType, nFromMapId);

		if not bRet or not tbMapInfo then
			Lib:LogTB(tbPlayerList)
			Log("[Error]", "ImperialTomb", "AssignPlayerToMirrorMap Create Map Failed", nFromMapId);
			return
		end

		tbAssignInfo = 
		{
			nMapId = tbMapInfo.nMapId,
			tbPlayerList = tbPlayerList,
			nFromMapId = nFromMapId,
		}


		self.tbMirrorMapAssign[tbMapInfo.nMapId] = tbAssignInfo
	end

	tbAssignInfo.tbKinInfo, tbAssignInfo.tbTeamInfo = self:GetMatchInfoFromPlayerList(tbPlayerList)

	return tbAssignInfo
end

function ImperialTomb:GetMatchInfoFromPlayerList(tbPlayerList)
	local tbKinInfo = {}
	local tbTeamInfo = {}

	for _,pPlayer in pairs(tbPlayerList) do
		if type(pPlayer) == "number" then
			pPlayer = KPlayer.GetPlayerObjById(pPlayer);
		end

		if pPlayer then
			local nCaptainId = pPlayer.dwID;
			local tbTeam = nil;
			local nTeamId = pPlayer.dwTeamID
			if nTeamId > 0 then
				tbTeam = TeamMgr:GetTeamById(nTeamId);
			end    
			if tbTeam then
				nCaptainId = tbTeam:GetCaptainId();
				tbTeamInfo[nTeamId] = tbTeamInfo[nTeamId] or 0;
				tbTeamInfo[nTeamId] = tbTeamInfo[nTeamId] + 1;
			end

			local nKinId = self:GetPlayerKinID(nCaptainId)
			if nKinId > 0 then
				tbKinInfo[nKinId] = tbKinInfo[nKinId] or 0;
				tbKinInfo[nKinId] = tbKinInfo[nKinId] + 1;
			end
		end
	end

	return tbKinInfo, tbTeamInfo
end

function ImperialTomb:OnEmperorMirrorMapCreate(nMapTemplateId, nMapId, nType)
	local tbAssignInfo = self.tbMirrorMapAssign[nMapId]
	if not tbAssignInfo then
		Log("[Error]", "ImperialTomb", "OnEmperorMirrorMapCreate Failed Not Found Assign Info", nMapTemplateId, nMapId, nType);
		return
	end

	local szLvlFrame = Lib:GetMaxTimeFrame(self.NPC_TIME_FRAME_LEVEL);
	local nLevel = nil
	if szLvlFrame then
		nLevel = self.NPC_TIME_FRAME_LEVEL[szLvlFrame]
	end

	if not nLevel then
		Log("[Error]", "ImperialTomb", "CallEmperorMirror Failed Not Found Level Config", nMapId)
		return
	end

	local tbMirrorNpcInfo = self.EMPEROR_MIRROR_INFO;
	if self.bOpenFemaleEmperor then
		tbMirrorNpcInfo = self.FEMALE_EMPEROR_MIRROR_INFO;
	end

	local pNpc = KNpc.Add(tbMirrorNpcInfo.nTemplate, nLevel, 0, nMapId, tbMirrorNpcInfo.nX, tbMirrorNpcInfo.nY, 0);

	if not pNpc then
		Log("[Error]", "ImperialTomb", "CallEmperorMirror Failed Add Npc", nMapId, nLevel)
		return
	end

	pNpc.SetByAttackCallScript(1);
	pNpc.SetTitleID(tbMirrorNpcInfo.nTitleId);

	local nNpcId = pNpc.nId;
	local nMaxLife = pNpc.nMaxLife;
	
	local nDmgTimer = Timer:Register(Env.GAME_FPS * self.MIRROR_DMG_SYNC_INTERVAL, self.OnMirrorSyncDmg, self, nMapId, nNpcId)

	self.tbEmperorMirrorList[nNpcId] = {nNpcId = nNpcId, nTotalDamage = nMaxLife, nLastSyncLife = nMaxLife,  bDead = false, nDmgTimer = nDmgTimer, nFromMapId = tbAssignInfo.nFromMapId};
	self.tbMap2EmperorMirror[nMapId] = nNpcId

	local nPosX, nPosY = Map:GetDefaultPos(nMapTemplateId);

	for idx=#tbAssignInfo.tbPlayerList,1,-1 do
		local nPlayerId = tbAssignInfo.tbPlayerList[idx]
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer and pPlayer.nMapId == tbAssignInfo.nFromMapId then
			pPlayer.SwitchMap(nMapId, nPosX, nPosY);
		else
			table.remove(tbAssignInfo.tbPlayerList, idx)
		end
	end

	tbAssignInfo.tbKinInfo, tbAssignInfo.tbTeamInfo = self:GetMatchInfoFromPlayerList(tbAssignInfo.tbPlayerList)
end

function ImperialTomb:OnMirrorMapEnd(nMapId, nNpcId)
	Log("[Info]", "ImperialTomb", "OnMirrorMapEnd", nMapId, nNpcId)

	local tbMirrorInfo = self.tbEmperorMirrorList[nNpcId]
	if not tbMirrorInfo then
		Log("[Error]", "ImperialTomb", "OnMirrorMapEnd Failed Not Found Emperor Mirror Info", nMapId, nNpcId, nFromMapId)
		return
	end

	if tbMirrorInfo.nDmgTimer and Timer:GetRestTime(tbMirrorInfo.nDmgTimer) >= 0 then
		Timer:Close(tbMirrorInfo.nDmgTimer)
	end
	tbMirrorInfo.nDmgTimer = nil

	self:TransMapPlayer(nMapId)
	
	self:OnMirrorSyncDmg(nMapId, nNpcId, tbMirrorInfo.nFromMapId)

	local pNpc = KNpc.GetById(nNpcId);

	if pNpc then
		pNpc.Delete();
	end

	tbMirrorInfo.bDead = true
	self.tbEmperorMirrorList[nNpcId] = nil
	self.tbMap2EmperorMirror[nMapId] = nil
end

function ImperialTomb:OnMirrorSyncDmg(nMapId, nNpcId)
	local tbMirrorInfo = self.tbEmperorMirrorList[nNpcId]
	if not tbMirrorInfo then
		Log("[Error]", "ImperialTomb", "OnMirrorSyncDmg Failed Not Found Emperor Mirror Info", nMapId, nNpcId, nFromMapId)
		return true
	end

	local nFromMapId = tbMirrorInfo.nFromMapId

	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		Log("[Error]", "ImperialTomb", "OnMirrorSyncDmg Failed Not Found Npc", nMapId, nNpcId, nFromMapId)
		return true
	end

	local tbEmperorInfo = self:GetEmperorInfoByMapId(nFromMapId)
	if not tbEmperorInfo then
		Log("[Error]", "ImperialTomb", "OnMirrorSyncDmg Failed Not Found Real Emperor Info", nMapId, nNpcId, nFromMapId)
		return true
	end

	if tbEmperorInfo.bDead then
		Log("[Info]", "ImperialTomb", "OnMirrorSyncDmg Emperor is Dead", nMapId, nNpcId, nFromMapId, tbEmperorInfo.nNpcId)
		return true
	end

	local pEmperor = KNpc.GetById(tbEmperorInfo.nNpcId);

	if not pEmperor then
		Log("[Error]", "ImperialTomb", "OnMirrorSyncDmg Failed Not Found Real Emperor Npc", nMapId, nNpcId, nFromMapId, tbEmperorInfo.nNpcId)
		return true
	end

	local nCurEmperorLife = pEmperor.nCurLife;

	local nCurMirrorLife = pNpc.nCurLife;

	local nNewEmperorLife = math.max(1, nCurEmperorLife - (tbMirrorInfo.nLastSyncLife - nCurMirrorLife));


	Log("[Info]", "ImperialTomb", "OnMirrorSyncDmg", tbMirrorInfo.nLastSyncLife, nCurMirrorLife, (tbMirrorInfo.nLastSyncLife - nCurMirrorLife), nCurEmperorLife, nNewEmperorLife)

	tbMirrorInfo.nLastSyncLife = nCurMirrorLife

	pEmperor.SetCurLife(nNewEmperorLife);

	local tbDamage = pNpc.GetDamageInfo();
	if not tbDamage then
		Log("[Error]", "ImperialTomb", "OnMirrorSyncDmg No DamageInfo", nMapId, nNpcId, nFromMapId)
		return true
	end

	self.tbEmperorMirrorDmg[tbEmperorInfo.nNpcId] = self.tbEmperorMirrorDmg[tbEmperorInfo.nNpcId] or {}
	
	self.tbEmperorMirrorDmg[tbEmperorInfo.nNpcId][nNpcId] = tbDamage
	return true
end

function ImperialTomb:TestEmperorSweepPlayer()
	local nMapId,_,_ = me.GetWorldPos();

	local nNpcId = self.tbMap2Emperor[nMapId];
	if not nNpcId then
		return
	end

	local tbNpcInfo = self.tbEmperorList[nNpcId]
	if not tbNpcInfo then
		return
	end

	local pNpc = KNpc.GetById(nNpcId);

	if not pNpc then
		return
	end

	local nCurLife = pNpc.nCurLife;
	local nMaxLife = pNpc.nMaxLife;
	local nPercent = 100*nCurLife/nMaxLife;

	GameSetting:SetGlobalObj(me, pNpc);

	self:OnWarnningSweepPlayer(nPercent, nPercent);

	GameSetting:RestoreGlobalObj();
end

function ImperialTomb:TestStartEmperorMirror()
	local nMapId,_,_ = me.GetWorldPos();

	local nNpcId = self.tbMap2Emperor[nMapId];
	if not nNpcId then
		return
	end

	local tbNpcInfo = self.tbEmperorList[nNpcId]
	if not tbNpcInfo then
		return
	end

	local pNpc = KNpc.GetById(nNpcId);

	if not pNpc then
		return
	end

	local nCurLife = pNpc.nCurLife;
	local nMaxLife = pNpc.nMaxLife;
	local nPercent = 100*nCurLife/nMaxLife;

	GameSetting:SetGlobalObj(me, pNpc);

	self:OnStartEmperorMirror(nPercent, nPercent, nPercent - 10);

	GameSetting:RestoreGlobalObj();
end

function ImperialTomb:TestEndEmperorMirror()
	local nMapId,_,_ = me.GetWorldPos();

	local tbAssignInfo = self.tbMirrorMapAssign[nMapId];
	if not tbAssignInfo then
		return
	end

	local nFromMapId = tbAssignInfo.nFromMapId
	local nNpcId = self.tbMap2Emperor[nFromMapId];
	if not nNpcId then
		return
	end

	local tbNpcInfo = self.tbEmperorList[nNpcId]
	if not tbNpcInfo then
		return
	end

	local pNpc = KNpc.GetById(nNpcId);

	if not pNpc then
		return
	end

	local nCurLife = pNpc.nCurLife;
	local nMaxLife = pNpc.nMaxLife;
	local nPercent = 100*nCurLife/nMaxLife;

	GameSetting:SetGlobalObj(me, pNpc);

	self:OnEndEmperorMirror(nPercent, nPercent);

	GameSetting:RestoreGlobalObj();
end

function ImperialTomb:TestEmperorMirror()
	local nMapId,_,_ = me.GetWorldPos();

	local nNpcId = self.tbMap2Emperor[nMapId];
	if not nNpcId then
		return
	end

	local tbNpcInfo = self.tbEmperorList[nNpcId]
	if not tbNpcInfo then
		return
	end

	local pNpc = KNpc.GetById(nNpcId);

	if not pNpc then
		return
	end

	local nCurLife = pNpc.nCurLife;
	local nMaxLife = pNpc.nMaxLife;
	local nPercent = 100*nCurLife/nMaxLife;

	GameSetting:SetGlobalObj(me, pNpc);

	self:OnEmperorMirrorTrans(nNpcId);

	GameSetting:RestoreGlobalObj();
end

function ImperialTomb:GetTeamKinId(nTeamId)
	local nCaptainId = -1;
	local nKinId = 0;
	local tbTeam = TeamMgr:GetTeamById(nTeamId);
	
	if tbTeam then
		nCaptainId = tbTeam:GetCaptainId();
	end

	if nCaptainId > 0 then
		nKinId = self:GetPlayerKinID(nCaptainId)
	end

	return nKinId;
end

function ImperialTomb:OnLeaveMirrorRoom(pPlayer, nMapId)
	local tbAssignInfo = self.tbMirrorMapAssign[nMapId];
	if not tbAssignInfo then
		return
	end

	local nPlayerId = pPlayer.dwID
	for idx=#tbAssignInfo.tbPlayerList, 1, -1 do
		if tbAssignInfo.tbPlayerList[idx] == nPlayerId then
			table.remove(tbAssignInfo.tbPlayerList, idx)
			break;
		end
	end

	tbAssignInfo.tbKinInfo, tbAssignInfo.tbTeamInfo = self:GetMatchInfoFromPlayerList(tbAssignInfo.tbPlayerList)
end

function ImperialTomb:RecordPlayerEmperorRoom(pPlayer, nMapId, nIndex)

	local nPlayerId = pPlayer.dwID

	if not self.tbPlayerEmperorRoomList[nPlayerId] then

		local szMsg = self.EMPEROR_ROOM_RECORD_MSG[self.bOpenFemaleEmperor]

		pPlayer.SendBlackBoardMsg(szMsg)
		pPlayer.Msg(szMsg)
	end

	self.tbPlayerEmperorRoomList[nPlayerId] = {nMapId, nIndex}
end

function ImperialTomb:ForceSyncSweepNpc(pPlayer, nMapId)
	local nNpcId = self.tbMap2Emperor[nMapId];
	if not nNpcId then
		return
	end

	local tbNpcInfo = self.tbEmperorList[nNpcId]
	if not tbNpcInfo then
		return
	end

	local nRoleId = pPlayer.dwID;

	for _,nNpcId in pairs(tbNpcInfo.tbSweepNpcId) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			pNpc.AddToForceSyncSet(nRoleId);
			pPlayer.SyncNpc(nNpcId)
		end
	end

end
