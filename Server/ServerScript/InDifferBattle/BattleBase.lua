if not MODULE_ZONESERVER then
	return
end

InDifferBattle.tbBattleBase = InDifferBattle.tbBattleBase or {};
local tbBattleBase = InDifferBattle.tbBattleBase
local tbDefine = InDifferBattle.tbDefine

local tbSkillBook = Item:GetClass("SkillBook");

function tbBattleBase:Init(nMapId, tbTeamIds, szBattleType)
	self.nMapId = nMapId
	self.szBattleType = szBattleType
	--先打乱房间的顺序，然后按队伍顺序放进房间就好了
	local tbTeamFactionInfo = {} --队伍为key的门派信息
	self.tbTeamRoomInfo = {}; --队伍为key的队友房间信息
	self.tbTeamServerInfo = {}; --队伍为key的服务端信息，不同步到客户端
	local nCount = 0
	local tbChooseFactionSet = {};
	local tbTeamPkMode = {}
	self.tbTeamDataVersion = {}; --队伍为key的 客户端主动请求更新的数据版本号
	local tbRandomFactionGroup = InDifferBattle.tbRandomFactionGroup
	local tbRandomRoomIndex = InDifferBattle.tbRandomRoomIndex

	self.tbTeamReportInfo = {}; --队伍的战报信息
	for dwTeamID,v in pairs(tbTeamIds) do
		nCount = nCount + 1
		-- 小组随机门派 直接取20组随机数组合门派。然后先随机取一组，再随机取1-5开始往后的6个数字 -- 这个可以服务器启动时做
		local nRand = MathRandom(5)
		tbChooseFactionSet[dwTeamID] =  { unpack(tbRandomFactionGroup[MathRandom(20)], nRand, nRand + 5) } 
		tbTeamFactionInfo[dwTeamID] = {  };
		tbTeamPkMode[dwTeamID] = nCount
		self.tbTeamRoomInfo[dwTeamID] = { [0] = tbRandomRoomIndex[ (nCount - 1) % tbDefine.nMaxRoomNum + 1 ] } ;
		self.tbTeamServerInfo[dwTeamID] = { nLivePlayerNum = 0, tbTurnsGetAwardMembers = {} };
		self.tbTeamDataVersion[dwTeamID] = 0;
		self.tbTeamReportInfo[dwTeamID] = {};
	end
	self.nLeftTeamNum = nCount --剩余的队伍数，如果有队伍人员全部死亡就减一
	self.tbTeamPkMode = tbTeamPkMode
	self.tbTeamFactionInfo = tbTeamFactionInfo
	self.tbChooseFactionSet = tbChooseFactionSet 
	self.tbPlayerInfos = {};
	self.tbCurSingleNpcRoomIndex = {};  --[nRoomIndex] =nNpcTemplateId 
	self.tbCurSingleNpcRoomId = {};--[nRoomIndex] = nNpcId; 只是单房间出现的npc

	self.tbCanUseRoomIndex = Lib:CopyTB(InDifferBattle.tbRoomIndex)
	self.nSynClientDataVersion = 0; --客户端主动请求更新的数据版本号
	self.tbMapNpcGroup = {};
	self.tbTimerGroup = {};
	self.tbAutoDeleteNpcs = {};--切阶段时自动删除的npc

	self.tbForceSynNpcSet = {}; --强制同步的npc，[nRoomId] = nNpcId
	self.tbRoomPlayerIds = {}; --进入每个房间的玩家列表 ,[nRoomId][dwRoldId] = 1; 目前只是活的玩家
	self.tbGateCloseNpcId = {};--房间关闭时需要操作提示的npc列表
	self.tbNpcDmgInfo = {}; -- [nRoomIndex] = {nUpdateTime, tbDmgInfo }  --用room做key是因为客户端传上来时没有npcId,也好删除

	for nRoomIndex=1,25 do
		self.tbGateCloseNpcId[nRoomIndex] = {} --因为用时是 nTarRoomIndex和下面的不一样
	end

	for nRoomIndex=1,25 do
		self.tbMapNpcGroup[nRoomIndex] = {};
		self.tbTimerGroup[nRoomIndex] = {};
		self.tbRoomPlayerIds[nRoomIndex] = {};
		
		local nRow, nCol = unpack(InDifferBattle.tbRoomIndex[nRoomIndex])
		for szPosName, tbRowCol in pairs(tbDefine.tbGateDirectionModify) do
			local nRowModi, nColModi = unpack(tbRowCol)
			local nTarRoomIndex = InDifferBattle:GetRoomIndexByRowCol(nRow + nRowModi, nCol + nColModi)
			if nTarRoomIndex then
				local pNpc = self:AddMapNpcByPosName(tbDefine.nGateNpcId, 1, 0, nRoomIndex, szPosName)
				if pNpc then
					pNpc.SetName(string.format("前往%d號區域", nTarRoomIndex))
					table.insert(self.tbGateCloseNpcId[nTarRoomIndex], pNpc.nId)	
				end
			end
		end
	end
end

function tbBattleBase:Start()
	self.nGameStartTime = GetTime();

	self.STATE_TRANS = tbDefine.STATE_TRANS
	self.nSchedulePos = 0;
	self:StartSchedule();

	self.nActiveTimer = Timer:Register(Env.GAME_FPS, function ()
		self.nActiveCount = self.nActiveCount + 1
		self:Active()
		return true
	end)
end

function tbBattleBase:SetTeamData( dwTeamID ,tbTar, Key, Val)
	tbTar[Key] = Val
	self.tbTeamDataVersion[dwTeamID] = self.tbTeamDataVersion[dwTeamID] + 1;
	return self.tbTeamDataVersion[dwTeamID]
end

function tbBattleBase:SetServerData(tbTar, Key, Val)
	tbTar[Key] = Val
	self.nSynClientDataVersion = self.nSynClientDataVersion + 1
end

function tbBattleBase:ForEachAlivePlayerInRoom(nRoomIndex, fnFunction)
	local tbPlayers = self.tbRoomPlayerIds[nRoomIndex];
	for dwID, _ in pairs(tbPlayers) do
		local pPlayer = KPlayer.GetPlayerObjById(dwID)
		if pPlayer and pPlayer.nFightMode ~= 2 then
			fnFunction(pPlayer, nRoomIndex);
		else
			tbPlayers[dwID] = nil;
		end
	end
end

function tbBattleBase:ForEachAlivePlayerInTeam(dwTeamID, fnFunction)
	local tbTeamServerInfo = self.tbTeamServerInfo[dwTeamID]
	if not tbTeamServerInfo then
		return
	end
	local tbTurnsGetAwardMembers = tbTeamServerInfo.tbTurnsGetAwardMembers
	for _, dwRoleID in ipairs(tbTurnsGetAwardMembers) do
		local pPlayer = KPlayer.GetPlayerObjById(dwRoleID)
		if pPlayer and pPlayer.nFightMode ~= 2 then
			fnFunction(pPlayer)
		end
	end
	
end

function tbBattleBase:OnAddSingleRoomNpc(nNpcTemplate, nLiveTime)
	local tbNpcInfo = InDifferBattle.tbRoomSetting.tbSingleRoomNpc[nNpcTemplate]
	if not tbNpcInfo then
		return
	end
	self:AddSingleRoomNpc(nNpcTemplate, tbNpcInfo.nLevel, tbNpcInfo.nRoomGroup, nLiveTime, tbNpcInfo.nDir)
end

function tbBattleBase:OnWorldNotify(szNotify)
	KPlayer.MapBoardcastScript(self.nMapId, "Ui:OnWorldNotify", szNotify, 1, 1)	
end

function tbBattleBase:AddSingleRoomNpc(nNpcTemplate , nLevel, nRoomGroup, nLiveTime, nDir)
	if not self.nMapId then
		return
	end
	local tbRooms = self.tbSignleRooms[nRoomGroup]
	for i=#tbRooms,1, -1 do
		if not self.tbCanUseRoomIndex[tbRooms[i]] then
			table.remove(tbRooms, i)
		end
	end

	if #tbRooms == 0 then
		return
	end

	local nIndex = #tbRooms == 1 and 1 or MathRandom(#tbRooms)
	local nRoomIndex = table.remove(tbRooms, nIndex) --保证一个随机的房间里只会出现一个

	local pNpc = self:AddNpc(nNpcTemplate, nLevel, nRoomIndex, nDir)
	if not pNpc then
		return
	end
	
	-- npc死亡时应该把占用的房间放回 tbSignleRooms 区别 重生的添加回去所以重生npc的房间占用就不放回去了
	pNpc.nRoomGroup = nRoomGroup	
	--刷新这个房间的玩家 npc信息
	local fnFunction = function (pPlayer, nRoomIndex)
		self:UpdateClinetSingleNpcInfo(pPlayer, pPlayer.nClientDataVersion);
	end
	self:ForEachAlivePlayerInRoom(nRoomIndex, fnFunction)
		
	if nLiveTime > 0 then
		Timer:Register(Env.GAME_FPS * nLiveTime, self.DeleteNpc, self, pNpc.nId) 
	end
end

--现在只是单房间npc ，要确定小怪的出现是随机还是固定摆放的 TODO 
function tbBattleBase:AddNpc(nTemplateId, nLevel, nRoomIndex, nDir)
	if not self.nMapId then
		return
	end

	if not self.tbCanUseRoomIndex[nRoomIndex] then
		return
	end

	local x, y = unpack(InDifferBattle.tbRooomPosSet[nRoomIndex]["center"]) 
	local pNpc = KNpc.Add(nTemplateId, nLevel, -1, self.nMapId, x, y, 0, nDir)
	if pNpc then
		pNpc.nRoomIndex = nRoomIndex
		table.insert(self.tbMapNpcGroup[nRoomIndex], pNpc.nId)
		self.tbCurSingleNpcRoomId[nRoomIndex] = pNpc.nId;

		self:SetServerData(self.tbCurSingleNpcRoomIndex, nRoomIndex, nTemplateId)
		Npc:RegNpcOnDeath(pNpc, self.OnRegNpcDeath, self)	
	end
	return pNpc;
end

--自定义地点安放的npc，房间关闭时都删除
function tbBattleBase:AddMapNpc(nTemplateId, nLevel, nRoomIndex, x, y, nDir, nReviveTime)
	if not self.tbCanUseRoomIndex[nRoomIndex] then
		return
	end
	local pNpc = KNpc.Add(nTemplateId, nLevel, -1, self.nMapId, x, y, 0, nDir) 
	if pNpc then
		local tbGroup = self.tbMapNpcGroup[nRoomIndex]
		pNpc.nRoomIndex = nRoomIndex
		table.insert(tbGroup, pNpc.nId)
		pNpc.nReviveTime = nReviveTime
		if tbDefine.tbAutoDeleteWhenStateChangeNpc[nTemplateId] then
			table.insert(self.tbAutoDeleteNpcs, pNpc.nId)
		end
		return pNpc
	end
end

function tbBattleBase:AddRandPosNpcSet(nTemplateId, nLevel, nRoomIndex, tbPosSet, tbRandNum, nReviveTime)
	local nRandNum = MathRandom(unpack(tbRandNum))
	for i=1,nRandNum do
		self:AddMapNpcByPosName(nTemplateId, nLevel, 0, nRoomIndex, tbPosSet[i], nReviveTime)
	end
end

function tbBattleBase:AddRandPosBuffSet(szDropBuff, nRoomIndex, tbPosSet, tbRandNum )
	local nRandNum = MathRandom(unpack(tbRandNum))
	local tbRandPosSet = { unpack(tbPosSet) }
	for i=1,nRandNum do
		local nRand = MathRandom(#tbRandPosSet)
		local szPosName = table.remove(tbRandPosSet, nRand)
		self:AddDropBuffByPosName( szDropBuff, nRoomIndex, szPosName )
	end
end

function tbBattleBase:AddRandTypeSet(nRoomIndex, szPosName, tbTypeSet)
	if not self.tbCanUseRoomIndex[nRoomIndex] then
		return
	end

	local nRand = MathRandom()
	
	for i,v in ipairs(tbTypeSet) do
		if nRand <= v[1] then
			local tbParams = { unpack(v, 3) }
			table.insert(tbParams, nRoomIndex)
			table.insert(tbParams, szPosName)
			Lib:CallBack({ self[ v[2] ], self, unpack(tbParams)  })
			break;
		end
	end
end

function tbBattleBase:AddRandTypeSetTimer(nRoomIndex, szPosName, nTime, tbTypeSet)
	self:AddRandTypeSet(nRoomIndex, szPosName, tbTypeSet)
	local nTimerId = Timer:Register(Env.GAME_FPS * nTime, function ()
		if not self.bRestTime then
			self:AddRandTypeSet(nRoomIndex, szPosName, tbTypeSet)
		end
		return true;
	end)
	table.insert(self.tbTimerGroup[nRoomIndex], nTimerId)		
end

function tbBattleBase:AddMapNpcByPosName( nTemplateId, nLevel, nLiveTime, nRoomIndex, szPosName, nReviveTime)
	local x,y,dir =  unpack(InDifferBattle.tbRooomPosSet[nRoomIndex][szPosName]) 
	local pNpc = self:AddMapNpc(nTemplateId, nLevel, nRoomIndex, x, y, dir)
	if pNpc then
		pNpc.szPosName = szPosName
		pNpc.nReviveTime = nReviveTime
		if nLiveTime > 0 then
			Timer:Register(Env.GAME_FPS * nLiveTime, self.DeleteNpc, self, pNpc.nId) 
		end
		return pNpc
	end
end

function tbBattleBase:AddDropBuffByPosName( szParam, nRoomIndex, szPosName )
	local x,y =  unpack(InDifferBattle.tbRooomPosSet[nRoomIndex][szPosName]) 
	Item.Obj:DropBufferInPosWhithType(Item.Obj.TYPE_CHECK_FIGHT_MODE, self.nMapId, x,y, szParam);
end

function tbBattleBase:OnDrapAwardListNpcDeath(pNpc, pKiller)
	local tbNpcInfo = InDifferBattle.tbRoomSetting.tbSingleRoomNpc[pNpc.nTemplateId]
	local szDropAwardList = tbNpcInfo.szDropAwardList
	if not szDropAwardList then
		return
	end
	local szDropAward = szDropAwardList[self.nSchedulePos]
	if not szDropAward then
		return
	end
	--最后一击加成的
	local tbDmgInfo = pNpc.GetDamageInfo()
	if not tbDmgInfo or #tbDmgInfo <= 0 then
		return
	end

	local nLastDmgPlayerID = pNpc.GetLastDmgMePlayerID();
	local nLastAttackTeam;
	local pLastKiller;
	if nLastDmgPlayerID > 0 then
		pLastKiller = KPlayer.GetPlayerObjById(nLastDmgPlayerID)
		if pLastKiller then
			nLastAttackTeam = pLastKiller.dwTeamID
		end
	end

	local tbDmgInfoShow = {};
	local nLastDmgBossHPPercent = tbNpcInfo.bBoss and  tbDefine.nLastDmgBigBossHPPercent or tbDefine.nLastDmgBossHPPercent
	local nMaxLife = pNpc.nMaxLife / (1 - nLastDmgBossHPPercent / 100)
	for _,v in ipairs(tbDmgInfo) do
		local tbShow = { nPercent = v.nTotalDamage / nMaxLife, nTeamId = v.nTeamId }
		if v.nTeamId == nLastAttackTeam then
			tbShow.nPercent = tbShow.nPercent + nLastDmgBossHPPercent / 100;
		end
		table.insert(tbDmgInfoShow, tbShow)
	end
	self.tbNpcDmgInfo[pNpc.nRoomIndex] = { GetTime(), tbDmgInfoShow } 

	local function fnDamageCmp(a, b)
		return a.nPercent > b.nPercent;
	end

	table.sort(tbDmgInfoShow, fnDamageCmp);

	for i, nNum in ipairs(tbNpcInfo.tbRankAwardNum) do
		local v = tbDmgInfoShow[i]
		if not v then
			break;
		end
		self:SendRandDropAwardToTeam( v.nTeamId, szDropAward, nNum, nNum)
	end

	if tbNpcInfo.bBoss then
		if pLastKiller then
			local tbItems = pLastKiller.FindItemInBag(tbDefine.nReviveItemId)
			if not next(tbItems) then
				self:SendAward(pLastKiller, { {"item", tbDefine.nReviveItemId, 1} })
			end
		end
		local dwTeamID = tbDmgInfoShow[1].nTeamId
		local tbRandGiveLiveItemMembers = {};
		for dwRoleId, nRoomIndex in pairs(self.tbTeamRoomInfo[dwTeamID]) do
			local pPlayer = KPlayer.GetPlayerObjById(dwRoleId)
			if pPlayer and pPlayer.nFightMode ~= 2 then
				self:SendAward(pPlayer, {{"RandBuff"}})

				local tbItems = pPlayer.FindItemInBag(tbDefine.nReviveItemId)
				if not next(tbItems) then
					table.insert(tbRandGiveLiveItemMembers, pPlayer)
				end
			end
		end
		local nRandGiveLiveItemMembers = #tbRandGiveLiveItemMembers
		if nRandGiveLiveItemMembers > 0 then
			local pTarPlayer
			if nRandGiveLiveItemMembers == 1 then
				pTarPlayer = tbRandGiveLiveItemMembers[1]
			else
				pTarPlayer = tbRandGiveLiveItemMembers[MathRandom(nRandGiveLiveItemMembers)]
			end
			self:SendAward(pTarPlayer, { {"item", tbDefine.nReviveItemId, 1} })
		end
	end
	self:OnWorldNotify(string.format("%s已被擊殺", him.szName))
end

function tbBattleBase:OnRegNpcDeath(pKiller)
	self:SetServerData(self.tbCurSingleNpcRoomIndex, him.nRoomIndex)
	self:RecycleNpcRoomGroup(him)
	self:OnDrapAwardListNpcDeath(him, pKiller)
end

function tbBattleBase:OnNpcDeath(pNpc, pKiller)
	local nReviveTime = pNpc.nReviveTime
	if nReviveTime and nReviveTime > 0  then
		local nRoomIndex = pNpc.nRoomIndex
		local szPosName = pNpc.szPosName
		if nRoomIndex and szPosName then
			Timer:Register(Env.GAME_FPS * nReviveTime, function (nTemplateId, nLevel) --timer 返回值不要true
				self:AddMapNpcByPosName(nTemplateId, nLevel, 0, nRoomIndex, szPosName, nReviveTime)
			end, him.nTemplateId, him.nLevel)	
		end
	end

	if not pKiller then
		return
	end
	local pKillerPlayer = pKiller.GetPlayer()
	if not pKillerPlayer then
		return
	end
	local dwTeamID = pKillerPlayer.dwTeamID
	local tbBattleNpcDropSettingMoney = tbDefine.tbBattleNpcDropSettingMoney[self.nSchedulePos]
	if tbBattleNpcDropSettingMoney then
		local tbAward = tbBattleNpcDropSettingMoney[MathRandom(#tbBattleNpcDropSettingMoney)] 
		if tbAward then
			self:SendAwardToTeamTurns(dwTeamID, {tbAward})			
		end
	end


end

function tbBattleBase:GetNpcBuffParam(nNpcTemplate)
	local tbSingleRoomNpc = InDifferBattle.tbRoomSetting.tbSingleRoomNpc
	if tbSingleRoomNpc[nNpcTemplate] then
		return tbSingleRoomNpc[nNpcTemplate].tbDropBuff
	end
end

function tbBattleBase:DeleteNpc(nNpcId)
	local pNpc = KNpc.GetById(nNpcId)
	if pNpc then
		self:RecycleNpcRoomGroup(pNpc)
		pNpc.Delete();
	end
end

function tbBattleBase:RecycleNpcRoomGroup(pNpc)
	local nRoomGroup = pNpc.nRoomGroup
	if not nRoomGroup then
		return
	end

	local nRoomIndex = pNpc.nRoomIndex
	if not nRoomIndex then
		return
	end

	self.tbCurSingleNpcRoomId[nRoomIndex] = nil;
	self:SetServerData(self.tbCurSingleNpcRoomIndex, nRoomIndex)

	if not self.tbCanUseRoomIndex[nRoomIndex] then
		return
	end
	table.insert(self.tbSignleRooms[nRoomGroup], nRoomIndex)
end

function tbBattleBase:StartSchedule()
	local tbLastSchedule = self.STATE_TRANS[self.nSchedulePos]
	if tbLastSchedule then
		Lib:CallBack({ self[tbLastSchedule.szFunc], self, tbLastSchedule.tbParam })
	end

	for i,v in ipairs(self.tbAutoDeleteNpcs) do
		local pNpc = KNpc.GetById(v) 
		if pNpc then
			pNpc.Delete()
		end
	end
	self.tbAutoDeleteNpcs = {}

	self.nMainTimer = nil; --nMainTimer 这样不为空时说明还有定时器未执行，

	self.nSchedulePos = self.nSchedulePos + 1;
	self.nActiveCount = 0
	KPlayer.MapBoardcastScript(self.nMapId, "InDifferBattle:SetClientLeftTime", self.nSchedulePos)	


	local tbNextSchedule = self.STATE_TRANS[self.nSchedulePos];
	if not tbNextSchedule then --后面没有timer 就断了
		return
	end

	self.nMainTimer = Timer:Register(Env.GAME_FPS * tbNextSchedule.nSeconds, self.StartSchedule, self )
end

function tbBattleBase:DirGotoSchedule(nPos)
	if self.nMainTimer then
		Timer:Close(self.nMainTimer)
		self.nMainTimer = nil;
	end

	self.nSchedulePos = nPos;
	self.nActiveCount = 0;
	KPlayer.MapBoardcastScript(self.nMapId, "InDifferBattle:SetClientLeftTime", self.nSchedulePos)	

	local tbNextSchedule = self.STATE_TRANS[nPos];
	if not tbNextSchedule then --后面没有timer 就断了
		return
	end
	self.nMainTimer = Timer:Register(Env.GAME_FPS * tbNextSchedule.nSeconds, self.StartSchedule, self )

end

function tbBattleBase:Active()
	local tbTrans = tbDefine.tbActiveTrans[self.nSchedulePos]
	if tbTrans then
		local tbTransFunc = tbTrans[self.nActiveCount]
		if tbTransFunc then
			for _,v in ipairs(tbTransFunc) do
				Lib:CallBack({ self[v[1]], self, unpack( v, 2 )})	
			end
		end
	end
end

function tbBattleBase:OnEnter()
	-- 同队伍的尽量在一个点，点尽量分散，那么init时候就确定各个队伍的位置了
	local dwTeamID = me.dwTeamID
	local tbTeamRoomInfo = self.tbTeamRoomInfo[dwTeamID]
	local tbTeamInfo = self.tbTeamFactionInfo[dwTeamID]
	if not tbTeamRoomInfo or not tbTeamInfo or self.tbPlayerInfos[me.dwID]  then --服务端的进入现在是只发生一次
		Log(debug.traceback(), me.dwID)
		me.ZoneLogout()
		return
	end
	local nInitRoomIndex = tbTeamRoomInfo[0]
	me.SetPosition( unpack(InDifferBattle.tbRooomPosSet[nInitRoomIndex]["center"]))
	tbTeamRoomInfo[me.dwID] = nInitRoomIndex
	self.tbRoomPlayerIds[nInitRoomIndex][me.dwID] = 1;

	me.nInBattleState = 1; --战场模式
	me.bForbidChangePk = 1;
	me.nFightMode = 0;
	me.SetPkMode(0)
	me.szNickName = "神秘人";
	Kin:SyncTitle(me.dwID, "");

	self.tbPlayerInfos[me.dwID] = { dwTeamID = dwTeamID, tbUsedItems = {}, nCostStoneNum = 0; szName = me.szName } --消耗的水晶数单独算
	self.tbTeamReportInfo[dwTeamID][me.dwID] = {nKillCount = 0, nHonorLevel = 0, nDeathState = 0, nScore = 0 }; --直接下发战报用
	local tbInfo = self.tbPlayerInfos[me.dwID]
	tbTeamInfo[me.dwID] = 0;

	local tbTeamServerInfo = self.tbTeamServerInfo[dwTeamID]
	tbTeamServerInfo.nLivePlayerNum =  tbTeamServerInfo.nLivePlayerNum + 1;
	table.insert(tbTeamServerInfo.tbTurnsGetAwardMembers, me.dwID)

	tbInfo.nOnDeathRegID = PlayerEvent:Register(me, "OnDeath", self.OnPlayerDeath, self);

    me.CallClientScript("InDifferBattle:EnterFightMap", self.nSchedulePos, math.floor(Timer:GetRestTime(self.nMainTimer) / Env.GAME_FPS), self.tbChooseFactionSet[dwTeamID], tbTeamInfo, tbTeamRoomInfo);
    ChatMgr:CreateTeamChatRoom(dwTeamID)
end

function tbBattleBase:DelayRevivePlayer(dwRoleId)
	local pPlayer = KPlayer.GetPlayerObjById(dwRoleId)
	if not pPlayer then
		return
	end
	if pPlayer.nFightMode == 2 then
		return
	end
	local _, nX, nY = pPlayer.GetWorldPos();
	pPlayer.GetNpc().CastSkill(tbDefine.nReviveEffectSkillId, 1, nX, nY)
	pPlayer.Revive(1)
	local nSafeBuffId, nFrame = unpack( InDifferBattle.tbDefine.tbReviveSafeBuff )
	pPlayer.AddSkillState(nSafeBuffId, 1,  0 , nFrame)
	Dialog:SendBlackBoardMsg(pPlayer, "消耗了一個【復活石】獲得了重生")
end

function tbBattleBase:OnPlayerDeath(pKillerLuna)
	local bCanRevive = me.ConsumeItemInBag(tbDefine.nReviveItemId, 1, 0) == 1;
	if not bCanRevive  then
		me.Revive(1)
		me.nFightMode = 2;
		me.AddSkillState(TeamBattle.nDeathSkillState, 1, 0, 100000);	 
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Team, string.format("「%s」已經陣亡", me.szName), me.dwTeamID)
		
		self.tbTeamReportInfo[me.dwTeamID][me.dwID].nDeathState = self.nSchedulePos

		--玩家托管的就只有死亡离开了
		local tbTeamServerInfo = self.tbTeamServerInfo[me.dwTeamID]
		tbTeamServerInfo.nLivePlayerNum = tbTeamServerInfo.nLivePlayerNum - 1;
		local pAlivePlayer;
		if tbTeamServerInfo.nLivePlayerNum == 0  then
			self.nLeftTeamNum = self.nLeftTeamNum - 1
			
			for dwRoleId,v in pairs(self.tbTeamFactionInfo[me.dwTeamID]) do
				local pPlayer = KPlayer.GetPlayerObjById(dwRoleId)
				if pPlayer  then
					Dialog:SendBlackBoardMsg(pPlayer, "全隊陣亡，將在5秒後離開幻境")
				end
			end		
			Timer:Register(Env.GAME_FPS * 5, self.DelayKickTeam, self, me.dwTeamID)
		else
			pAlivePlayer = self:DeathPlayerPassToAlive(me);
			if pAlivePlayer and tbTeamServerInfo.nLivePlayerNum == 1 then  --改变之前死的人的跟战目标
				for dwRoleId,v in pairs(self.tbTeamFactionInfo[me.dwTeamID]) do 
					if dwRoleId ~= me.dwID and dwRoleId ~= pAlivePlayer.dwID then
						local pOherDeader = KPlayer.GetPlayerObjById(dwRoleId)
						if pOherDeader and pOherDeader.nFightMode == 2 then
							self:DeathPlayerPassToAlive(pOherDeader, pAlivePlayer)
							pOherDeader.CallClientScript("InDifferBattle:OnGameDeath", pAlivePlayer.GetNpc().nId)
						end
					end
				end
			end
		end

		me.CallClientScript("InDifferBattle:OnGameDeath", (pAlivePlayer and pAlivePlayer.GetNpc().nId))
		for dwRoleId,v in pairs(self.tbTeamFactionInfo[me.dwTeamID]) do 
			if dwRoleId ~= me.dwID then
				local pPlayer = KPlayer.GetPlayerObjById(dwRoleId)
				if pPlayer then
					pPlayer.CallClientScript("InDifferBattle:OnMemberGameDeath", me.dwID)
				end
			end
		end
	else
		Timer:Register(tbDefine.nReviveDelayTime, self.DelayRevivePlayer, self, me.dwID)
	end
	
	if pKillerLuna then
		local pKiller = pKillerLuna.GetPlayer()	
		if pKiller then
			self:OnKillPlayer(pKiller, me, bCanRevive)
		end
	end

	if self.nLeftTeamNum <= 1 then
		self:DirectEndGameMatch();
	end
end

function tbBattleBase:OnKillPlayer(pKiller, pDeather, bCanRevive)
	local dwKillerTeamId = pKiller.dwTeamID
	local tbKillerInfo = self.tbTeamReportInfo[dwKillerTeamId][pKiller.dwID]
	tbKillerInfo.nKillCount = tbKillerInfo.nKillCount + 1;
	if not bCanRevive then 
		--坐骑，秘籍， 是取身上的 ,坐骑升阶 和强化, 秘籍升阶段 是使用时记录的
		local tbDeathPlayerInfo = self.tbPlayerInfos[pDeather.dwID]
		local tbRandItems = tbDeathPlayerInfo.tbUsedItems
		local pItems = pDeather.GetItemListInBag();
		for _, pItem in ipairs(pItems) do
			for i=1,pItem.nCount do
				table.insert(tbRandItems, pItem.dwTemplateId)
			end
		end
		local pHorse = pDeather.GetEquipByPos(Item.EQUIPPOS_HORSE);
		if pHorse then
			table.insert(tbRandItems, tbDefine.tbHorseUpgrade[1])
		end

	    for nIndex, nNeedLevel in ipairs(tbSkillBook.tbSkillBookHoleLevel) do
	    	local pEquip = pDeather.GetEquipByPos(nIndex + Item.EQUIPPOS_SKILL_BOOK - 1);
	    	if pEquip then
	    		local dwLowestItemId = tbSkillBook:GetLowestBookId(pEquip.dwTemplateId)
	    		table.insert(tbRandItems, dwLowestItemId)
	    	end
	    end

	    local tbTakeAwrdList = {};
	    --爆钱
	    local nHasMoney = pDeather.GetMoney(tbDefine.szMonoeyType)
	    local nRandMin, nRandMax, nMinNum = unpack(tbDefine.tbKillGetMoneyRand)
	    local nRandPersent = MathRandom(nRandMin, nRandMax)
	    local nGetMoney = math.max(nMinNum, math.floor( nRandPersent / 100 * nHasMoney) )
	    table.insert(tbTakeAwrdList, {tbDefine.szMonoeyType, nGetMoney})
	    --掉道具
	    if #tbRandItems == 1 then
	    	if MathRandom() <= 0.5 then
	    		table.insert(tbTakeAwrdList, {"item", tbRandItems[1], 1})
	    	end
	    elseif #tbRandItems > 1 then
	    	local nRandNum = MathRandom(unpack(tbDefine.tbKillGetItemNumRand))
	    	nRandNum = #tbRandItems * nRandNum / 100 
	    	local nFloor = nRandNum -  math.floor(nRandNum) --小数部分单独随机决定向上还是向下取整
	    	if MathRandom() <= nFloor then
	    		nRandNum = math.ceil(nRandNum)
	    	else
	    		nRandNum = math.floor(nRandNum)
	    	end
	    	for i = 1, nRandNum do
	    		if #tbRandItems == 1 then
	    			table.insert(tbTakeAwrdList, {"item", tbRandItems[1], 1})
	    			break;
	    		else
	    			local nIndex = MathRandom(#tbRandItems)	
	    			local nItemId = table.remove(tbRandItems, nIndex)
	    			table.insert(tbTakeAwrdList, {"item", nItemId, 1})
	    		end
	    	end
	    end

	    for _, v in ipairs(tbTakeAwrdList) do
	    	--如果是门派秘籍则转换下类型
	    	local nBookType = tbSkillBook:GetBookType(v[2]) 
	    	if nBookType and v[1] == "item" then
	    		self:SendAwardToTeamTurns(dwKillerTeamId, {{"SkillBook", nBookType } })
	    	else
	    		self:SendAwardToTeamTurns(dwKillerTeamId, {v})	
	    	end
	    end

	    local nRobAwardNum = #tbTakeAwrdList
	    --水晶数量比较多，就单独算平均分了
	    local nCostStoneNum = tbDeathPlayerInfo.nCostStoneNum
	    if nCostStoneNum > 0 then
	    	--算上钱和道具，SendAwardToTeamTurns至少掉了2次，直接用里面的列表平分就好
	    	local nRandNum = MathRandom(unpack(tbDefine.tbKillGetItemNumRand))
	    	local tbTurnsGetAwardMembers = self.tbTeamServerInfo[dwKillerTeamId].tbTurnsGetAwardMembers
	    	local nPerGetNum =  math.floor(nCostStoneNum * nRandNum / 100 / #tbTurnsGetAwardMembers + 0.5) 
	    	if nPerGetNum > 0 then
	    		for _,dwRoleId in ipairs(tbTurnsGetAwardMembers) do
		    		local pPlayer = KPlayer.GetPlayerObjById(dwRoleId)
		    		if pPlayer and pPlayer.nFightMode ~= 2 then
		    			self:SendAward(pPlayer, {{ "item", tbDefine.nEnhanceItemId, nPerGetNum}});
		    		end
		    	end
		    	nRobAwardNum = nRobAwardNum + nPerGetNum * #tbTurnsGetAwardMembers
	    	end
	    end

	    ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Team, string.format("「%s」擊敗了「神秘人」，搶奪了%d個寶物已均分給隊伍成員", pKiller.szName, nRobAwardNum), dwKillerTeamId)
	    	
	    --所有活着的玩家加积分
	    local nAddScore = tbDefine.tbStateGetScore[self.nSchedulePos].nKillScore
	    local fnAddScore = function (pMember)
	    	local tbMemberInfo = self.tbTeamReportInfo[dwKillerTeamId][pMember.dwID]
	    	tbMemberInfo.nScore = tbMemberInfo.nScore  + nAddScore
	    end
 		self:ForEachAlivePlayerInTeam(dwKillerTeamId, fnAddScore);

		tbDeathPlayerInfo.tbUsedItems = {};
		tbDeathPlayerInfo.nCostStoneNum = 0;
	end
end

function tbBattleBase:DeathPlayerPassToAlive(pPlayerDeath, pAlivePlayer)
	--传送到未死亡的队友旁边
	if not pAlivePlayer then
		for dwRoleId,v in pairs(self.tbTeamFactionInfo[pPlayerDeath.dwTeamID]) do
			if dwRoleId ~= pPlayerDeath.dwID then
				local pPlayer = KPlayer.GetPlayerObjById(dwRoleId)
				if pPlayer and pPlayer.nFightMode ~= 2 then
					pAlivePlayer = pPlayer;
					break;
				end
			end
		end	
	end
	if not pAlivePlayer then
		return
	end

	local _, x, y = pAlivePlayer.GetWorldPos()
	local nRoomIndex = self.tbTeamRoomInfo[pAlivePlayer.dwTeamID][pAlivePlayer.dwID]
	self:SwitchToRoom(pPlayerDeath, x, y, nRoomIndex, true)
	pPlayerDeath.dwFollowAliveId = pAlivePlayer.dwID
	return pAlivePlayer;
end

function tbBattleBase:DelayKickTeam(dwTeamID)
	self:TryAddTeamAwarad(dwTeamID)
	for dwRoleId,v in pairs(self.tbTeamReportInfo[dwTeamID]) do
		local pPlayer = KPlayer.GetPlayerObjById(dwRoleId)
		if pPlayer then
			pPlayer.ZoneLogout()
		end
	end
end

function tbBattleBase:DirectEndGameMatch() --只剩一支队伍时直接结束比赛
	local dwWinnerTeam;
	for dwTeamID,v in pairs(self.tbTeamServerInfo) do
		if v.nLivePlayerNum > 0 then
			dwWinnerTeam = dwTeamID
			break;
		end
	end
	assert(dwWinnerTeam)
	--提前结束时给存活队伍加上存活分
	local tbStateScoreInfo = tbDefine.tbStateGetScore[self.nSchedulePos]
	local nSurviveNum = 0
	if tbStateScoreInfo then
		local nAddScore = tbStateScoreInfo.nSurviveScore	
		local fnAddScore = function (pMember)
	    	local tbMemberInfo = self.tbTeamReportInfo[dwWinnerTeam][pMember.dwID]
	    	tbMemberInfo.nScore = tbMemberInfo.nScore  + nAddScore
	    	nSurviveNum = nSurviveNum + 1;
	    end
		self:ForEachAlivePlayerInTeam(dwWinnerTeam, fnAddScore);	
	end
	
	self:SetWinnerTeam(dwWinnerTeam, string.format("以最終%d人存活的優勢獲得本次心魔幻境的優勝！", nSurviveNum) )

	
	Log("InDifferBattle DirectEndGameMatch", self.nMapId, dwWinnerTeam, self.nSchedulePos)
	self:DirGotoSchedule(#self.STATE_TRANS)
end

function tbBattleBase:OnLeave()
	ChatMgr:LeaveKinChatRoom(me);
	--离开什么也不用设了
	-- me.nInBattleState = 0; --战场模式
	-- me.bForbidChangePk = 0;
	-- me.nLastTrapRoomTime = nil;

	-- me.SetPkMode(0)
	-- me.ClearTempRevivePos()

	-- local tbInfo = self.tbPlayerInfos[me.dwID]
	-- if not tbInfo then
	-- 	Log(debug.traceback(), me.dwID)
	-- 	return
	-- end

	-- if tbInfo.nOnDeathRegID then
	-- 	PlayerEvent:UnRegister(me, "OnDeath", tbInfo.nOnDeathRegID);
	-- 	tbInfo.nOnDeathRegID = nil;
 --    end
end

function tbBattleBase:OnPlayerTrap(szTrapName)
	if self.nSchedulePos == 1 then
		return
	end

	local tbTrapInfo = InDifferBattle.tbRoomTrapToPos[szTrapName]
	if tbTrapInfo then
		local nNow = GetTime()
		if nNow ~= me.nLastTrapRoomTime then
			self:SwitchToRoom(me, unpack(tbTrapInfo))
			me.nLastTrapRoomTime = nNow
		end
	end
end

function tbBattleBase:ForceSynRoomNpcToPlayer(pPlayer, nRoomIndex)
	local nLastForceSynNpcId = pPlayer.nLastForceSynNpcId
	if nLastForceSynNpcId then
		local pNpc = KNpc.GetById(nLastForceSynNpcId)
		if pNpc then
			pNpc.RemoveFromForceSyncSet(pPlayer.dwID)
		end
	end
	local nForceSyncNpcId = self.tbForceSynNpcSet[nRoomIndex]
	if nForceSyncNpcId then
		local pNpc = KNpc.GetById(nForceSyncNpcId)
		if pNpc then
			pNpc.AddToForceSyncSet(pPlayer.dwID)
			pPlayer.SyncNpc(nForceSyncNpcId)
		end
	end
	pPlayer.nLastForceSynNpcId = nForceSyncNpcId
end

function tbBattleBase:SwitchToRoom(pPlayer, x, y, nRoomIndex, bNotCheck)
	if not self.tbCanUseRoomIndex[nRoomIndex] then
		pPlayer.CenterMsg(nRoomIndex .. "號入口已坍塌")
		return
	end

	local dwTeamID = pPlayer.dwTeamID
	local dwRoleId = pPlayer.dwID
	local tbTeamRoomInfo = self.tbTeamRoomInfo[dwTeamID]

	-- 如果自己已经死亡，服务端就只限制了不能进入没有已存活队友的房间
	if  not bNotCheck and pPlayer.nFightMode == 2 then --TODO 
		local bCan = false;
		for dwID, _nRoomIndex in pairs(tbTeamRoomInfo) do
			if dwID ~= dwRoleId and  _nRoomIndex == nRoomIndex then
				bCan = true;
				break
			end
		end
		if not bCan then
			pPlayer.CenterMsg("您當前狀態無法傳入目的地區域")
			return
		end
	end
	
	local nOldRoomIndex = tbTeamRoomInfo[dwRoleId]
	self:SetTeamData(dwTeamID, tbTeamRoomInfo, dwRoleId, nRoomIndex)

	self.tbRoomPlayerIds[nOldRoomIndex][dwRoleId] = nil;
	self.tbRoomPlayerIds[nRoomIndex][dwRoleId] = 1;
	pPlayer.SetPosition(x, y)
	self:ForceSynRoomNpcToPlayer(pPlayer, nRoomIndex)

	self:UpdateClinetSingleNpcInfo(pPlayer, pPlayer.nClientDataVersion);

	  --活着的玩家自己传送时，将死亡玩家直接传到他旁边
	if not bNotCheck and  pPlayer.nFightMode ~= 2 and self.tbTeamServerInfo[dwTeamID].nLivePlayerNum < 3 then
		for dwID, nHimRoomIndex in pairs(tbTeamRoomInfo) do
			if dwID ~= pPlayer.dwID then --这里如果判断 nHimRoomIndex 不同 nRoomIndex有时会漏
				local pPlayer2 = KPlayer.GetPlayerObjById(dwID)
				if pPlayer2 and pPlayer2.nFightMode == 2  and pPlayer2.dwFollowAliveId == pPlayer.dwID  then 
					pPlayer2.SetPosition(x, y)
					self:SetTeamData(dwTeamID, tbTeamRoomInfo, dwID, nRoomIndex)
				end	
			end
		end	
	end

	--也同时同步给队友的 将房间信息同步给其他队友 所以不要version了
	for dwID, nHimRoomIndex in pairs(tbTeamRoomInfo) do
		if dwID == dwRoleId then
			pPlayer.CallClientScript("InDifferBattle:SynTeamRoomInfo", tbTeamRoomInfo, true) 
		else
			local pPlayer2 = KPlayer.GetPlayerObjById(dwID)
			if pPlayer2 then
				pPlayer2.CallClientScript("InDifferBattle:SynTeamRoomInfo", tbTeamRoomInfo) 
			end
		end
	end


end

function tbBattleBase:OnLogin()
	local dwTeamID = me.dwTeamID
	me.CallClientScript("InDifferBattle:EnterFightMap", self.nSchedulePos, math.floor(Timer:GetRestTime(self.nMainTimer) / Env.GAME_FPS), self.tbChooseFactionSet[dwTeamID], self.tbTeamFactionInfo[dwTeamID], self.tbTeamRoomInfo[dwTeamID]);
	if self.tbReadyCloseRoomIndex then
		me.CallClientScript("InDifferBattle:SynRoomReadyCloseInfo", self.tbReadyCloseRoomIndex)
	end
	me.CallClientScript("InDifferBattle:SynRoomOpenInfo", self.tbCanUseRoomIndex)
	if me.nFightMode == 2 then
		local pAlivePlayer = self:DeathPlayerPassToAlive(me)
		me.CallClientScript("InDifferBattle:OnGameDeath", (pAlivePlayer and pAlivePlayer.GetNpc().nId))
	end
	for dwRoleId,v in pairs(self.tbTeamFactionInfo[dwTeamID]) do 
		if dwRoleId ~= me.dwID then
			local pPlayer = KPlayer.GetPlayerObjById(dwRoleId)
			if pPlayer and pPlayer.nFightMode == 2 then
				me.CallClientScript("InDifferBattle:OnMemberGameDeath", dwRoleId)
			end	
		end
	end
	ChatMgr:JoinChatRoom(me, 1)
end

function tbBattleBase:CloseBattle()
	for i=1,25 do
		self:_CloseRoom(i);
	end

	if self.nActiveTimer then
		Timer:Close(self.nActiveTimer)
		self.nActiveTimer = nil
	end
	
	if self.nMainTimer then
		Timer:Close(self.nMainTimer)
		self.nMainTimer = nil
	end
	if self.nMapId then
		local tbPlayer = KPlayer.GetMapPlayer(self.nMapId);
		for _, pPlayer in ipairs(tbPlayer) do
			pPlayer.ZoneLogout()
		end	
	end
	
	self.nMapId = nil; --防止一些npc重生在结束游戏后还在添加
end

function tbBattleBase:OnMapDestroy()
	self:CloseBattle();
	if self.nMainTimer then
		Timer:Close(self.nMainTimer)
		self.nMainTimer = nil
	end
end

function tbBattleBase:ChooseFaction(pPlayer, nFaction)
	if self.nSchedulePos ~= 1 then
		return
	end

	local dwTeamID = pPlayer.dwTeamID
	local tbTeamInfo = self.tbTeamFactionInfo[dwTeamID]
	for k,v in pairs(tbTeamInfo) do
		if v == nFaction then
			return
		end
	end
	--如果不是已给的也不行
	local bFind = false;
	for i,v in ipairs(self.tbChooseFactionSet[dwTeamID]) do
		if v == nFaction then
			bFind = true
			break;
		end
	end
	if not bFind then
		pPlayer.CenterMsg("無效的門派")
		return
	end

	tbTeamInfo[pPlayer.dwID] = nFaction

	local tbMembers = TeamMgr:GetMembers(dwTeamID)
	for _,dwID in pairs(tbMembers) do
		local pPlayer = KPlayer.GetPlayerObjById(dwID)
		if pPlayer then
			pPlayer.CallClientScript("InDifferBattle:OnSynChooseFactionInfo", tbTeamInfo)
		end
	end
end

function tbBattleBase:SynGameTime()
	KPlayer.MapBoardcastScript(self.nMapId, "InDifferBattle:SetClientLeftTime", self.nSchedulePos, math.floor(Timer:GetRestTime(self.nMainTimer) / Env.GAME_FPS) )	
end

function tbBattleBase:StartFight1()
	--开始npc的创建
	self.tbSignleRooms = Lib:CopyTB( InDifferBattle.tbRoomSetting.tbSignleRooms )
	-- 去掉初始化中的无效数据
	for dwTeamID,v1 in pairs(self.tbTeamRoomInfo) do
		v1[0] = nil 
	end

	--开始第一阶段，所有玩家停止选择门派
	--结束所有的门派选择
	local nToPlayerLevel = tbDefine.nPlayerLevel
	local szAvatarEquipKey = tbDefine.szAvatarEquipKey
	local nDefaultStrengthLevel = tbDefine.nDefaultStrengthLevel
	local nInitAddBuffId, nInitAddBuffLevel, nInitAddBuffTime = unpack(InDifferBattle.tbDefine.tbInitBuffId)
	local nBuffIdProtect, nLevelProtect, nTimeProtect = unpack(tbDefine.tbFirstSkillBuff)
	for dwTeamID,v in pairs(self.tbTeamFactionInfo) do
		local tbChooseFactionSet = self.tbChooseFactionSet[dwTeamID]
		local tbHasSelFaction = {}
		for dwRoleId, nFaction in pairs(v) do
			if nFaction ~= 0 then
				tbHasSelFaction[nFaction] = dwRoleId
			end
		end
		local nTeamPkMode = self.tbTeamPkMode[dwTeamID]

		for dwRoleId, nFaction in pairs(v) do
			if nFaction == 0 then
				for i,_nFaction in ipairs(tbChooseFactionSet) do
					if not tbHasSelFaction[_nFaction] then
						v[dwRoleId] = _nFaction
						tbHasSelFaction[_nFaction] = dwRoleId
						break;
					end
				end
			end
		end
		--对所有门派做实际转门派处理
		local tbPlayers = {}
		for dwRoleId, nFaction in pairs(v) do
			local pPlayer = KPlayer.GetPlayerObjById(dwRoleId)
			if pPlayer then
				if Player:ChangePlayer2Avatar(pPlayer, nFaction, nToPlayerLevel, szAvatarEquipKey, szAvatarEquipKey, nDefaultStrengthLevel) then
					pPlayer.SetPortrait(nFaction);
					pPlayer.SetPkMode(3, nTeamPkMode)
					pPlayer.nFightMode = 1;
					pPlayer.GetNpc().RemoveFightSkill(1013) --禁止打坐操作
					local nRadnMoney = MathRandom(unpack(tbDefine.tbRandMoney) ) --因为ChangePlayer2Avatar 清了UserValue
					pPlayer.AddMoney(tbDefine.szMonoeyType, nRadnMoney, Env.LogWay_InDifferBattle); 
					--初始赠与道具
					local nRandItem = MathRandom(10000)
					for _,v2 in ipairs(tbDefine.tbInitGiveItem) do
						if nRandItem <= v2[1] then
							self:SendAward(pPlayer, {v2[2]})
							break;
						end
					end

					if nInitAddBuffId then
						pPlayer.AddSkillState(nInitAddBuffId, nInitAddBuffLevel, 0, Env.GAME_FPS * nInitAddBuffTime, 1)
					end
					pPlayer.AddSkillState(nBuffIdProtect, nLevelProtect, 0, nTimeProtect)

					self:ChangeFightPower(pPlayer) --加了头衔有血量
					local pNpc = pPlayer.GetNpc()
					pNpc.SetCurLife(pNpc.nMaxLife)
					table.insert(tbPlayers, pPlayer)

					
				else
					Log("Error!!!!!!!! In ChangePlayer2Avatar" .. pPlayer.dwID)
					pPlayer.ZoneLogout();
				end
			end
		end
		--重新同步下队伍的显示
		local tbTeamRoomInfo = self.tbTeamRoomInfo[dwTeamID]
		local teamData = TeamMgr:GetTeamById(dwTeamID);
		if teamData then
			for _, pPlayer in ipairs(tbPlayers) do
				pPlayer.CallClientScript("TeamMgr:OnSynNewTeam", teamData.nTeamID, teamData.nCaptainID, teamData:GetLuaTeamMemberData(pPlayer.dwID));	
				pPlayer.CallClientScript("InDifferBattle:SynTeamRoomInfo", tbTeamRoomInfo) 
			end
		end
	end

	--先添加上所有放技能的npc，不然开宝箱这种开出来就加npc放技能的不能立马同步
	local fnFunction = function (pPlayer, nRoomIndex)
		self:ForceSynRoomNpcToPlayer(pPlayer, nRoomIndex)
	end
	for nRoomIndex=1,25 do
		local x, y = unpack(tbDefine.tbCastSkillNpcPos[nRoomIndex]) 
		local pNpc = self:AddMapNpc(tbDefine.nTempCastSKillNpcId, 80, nRoomIndex, x, y, 0)
		if pNpc then
			self.tbForceSynNpcSet[nRoomIndex] = pNpc.nId;	
			self:ForEachAlivePlayerInRoom(nRoomIndex, fnFunction)
		end
	end
end

function tbBattleBase:ResetTime()
	self.bRestTime = true
	local tbPlayer = KPlayer.GetMapPlayer(self.nMapId)
	local nAddScore = tbDefine.tbStateGetScore[self.nSchedulePos].nSurviveScore
	for i, pPlayer in ipairs(tbPlayer) do
		if pPlayer.nFightMode ~= 2 then
			 --加存活分
			local tbScoreInfo = self.tbTeamReportInfo[pPlayer.dwTeamID][pPlayer.dwID]
			tbScoreInfo.nScore = tbScoreInfo.nScore + nAddScore
			--不然可以打小怪
			pPlayer.AddSkillState(tbDefine.nSafeStateSkillBuffId, 1, 0, 15000)
		end
	end
end

function tbBattleBase:ReStartFight()
	self.bRestTime = nil;
	self:CloseRoom(); --关闭预关闭的房间
	local tbPlayer = KPlayer.GetMapPlayer(self.nMapId)
	for i, pPlayer in ipairs(tbPlayer) do
		if pPlayer.nFightMode ~= 2 then
			pPlayer.RemoveSkillState(tbDefine.nSafeStateSkillBuffId)
			if self.nSchedulePos == 7 then
				local nBuffId, nLevel, nTime = unpack(tbDefine.tbLastSkillBuff)
		         pPlayer.AddSkillState(nBuffId, nLevel, 0, nTime)
		         pPlayer.bTempForbitMount = true;
		         pPlayer.DoChangeActionMode(Npc.NpcActionModeType.act_mode_none);
		         pPlayer.CenterMsg("本階段禁止騎馬", true)
			end
		end
	end
	if self.nSchedulePos == 7 then
		local nRoomIndex = 1;
		for _,nNpcId in ipairs(self.tbMapNpcGroup[nRoomIndex]) do
			self:DeleteNpc(nNpcId)
		end
		self.tbMapNpcGroup[nRoomIndex] = {};
		for _, nTimer in ipairs(self.tbTimerGroup[nRoomIndex]) do
			Timer:Close(nTimer)
		end
		self.tbTimerGroup[nRoomIndex] = {};
	end
end

function tbBattleBase:StopFight()
	local tbPlayer = KPlayer.GetMapPlayer(self.nMapId)
	local nAddScore = tbDefine.tbStateGetScore[self.nSchedulePos].nSurviveScore
	for i, pPlayer in ipairs(tbPlayer) do
		if pPlayer.nFightMode ~= 2 then
			local tbScoreInfo = self.tbTeamReportInfo[pPlayer.dwTeamID][pPlayer.dwID]
			tbScoreInfo.nScore = tbScoreInfo.nScore + nAddScore
		end
		pPlayer.SetPkMode(0)

	end
	local dwWinnerTeam,szWinInfo = self:GetWinnerTeam()
	Log("InDifferBattle StopFight", self.nMapId, dwWinnerTeam,szWinInfo)
	self:SetWinnerTeam(dwWinnerTeam, szWinInfo)
end

function tbBattleBase:TryAddTeamAwarad(dwTeamID)
	local tbTeamServerInfo = self.tbTeamServerInfo[dwTeamID]
	local nTimeNow = GetTime();
	if not tbTeamServerInfo.bSendAward then
		tbTeamServerInfo.bSendAward = true;
		local tbTeamReportInfo = self.tbTeamReportInfo[dwTeamID]
		InDifferBattle:SendTeamAwardZ(dwTeamID, self.dwWinnerTeam, tbTeamReportInfo, nTimeNow - self.nGameStartTime, self.szBattleType)
	end
end

function tbBattleBase:SetWinnerTeam(dwWinnerTeam, szWinInfo)
	self.dwWinnerTeam = dwWinnerTeam;
	local nSurviveScore,nDeadScore = unpack(tbDefine.tbWinTeamAddScore)
	for dwRoleId, v in pairs(self.tbTeamReportInfo[dwWinnerTeam]) do
		local pPlayer = KPlayer.GetPlayerObjById(dwRoleId)
		if pPlayer and pPlayer.nFightMode ~= 2 then
			v.nScore = v.nScore  + nSurviveScore
			v.nDeathState = 12;
		else
			v.nScore = v.nScore  + nDeadScore
		end
	end

	--增加亲密度，因为是按队伍的，3个中起码有2个是一起的才加亲密度 --在发奖前，可以获取对应的角色 ZoneIndex
	for dwTeamID,v in pairs(self.tbTeamReportInfo) do
		self:TryAddTeamAwarad(dwTeamID)
	end

	local tbWinTeamInfo = self.tbTeamRoomInfo[dwWinnerTeam]
	local tbPlayerNames = {};
	for dwRoleId, _ in pairs(tbWinTeamInfo) do
		table.insert(tbPlayerNames, string.format("「%s」", self.tbPlayerInfos[dwRoleId].szName))
	end
	self:OnWorldNotify(string.format("恭喜%s%s", table.concat( tbPlayerNames, "、"), szWinInfo))
	KPlayer.MapBoardcastScript(self.nMapId, "InDifferBattle:OnSynWinTeam", dwWinnerTeam)	
	if self.szBattleType ~= "Normal" then
		local tbRoleList = {}
		for dwRoleId,v in pairs(tbWinTeamInfo) do
			table.insert(tbRoleList, dwRoleId)
		end
		InDifferBattle:SendQualifyBattleWinRoleIds(tbRoleList)
	end
end


function tbBattleBase:GetWinnerTeam()
	local tbPlayers = KPlayer.GetMapPlayer(self.nMapId)
	local tbCurTeams = {}
	for i,pPlayer in ipairs(tbPlayers) do
		--规则改下了
		local dwTeamID = pPlayer.dwTeamID
		tbCurTeams[dwTeamID] = tbCurTeams[dwTeamID] or { nLeftPlayerNum = 0, nScoreTotal = 0, nSurvieFightPower = 0 };
		local tbTeam = tbCurTeams[dwTeamID];
		tbTeam.nScoreTotal = tbTeam.nScoreTotal + self.tbTeamReportInfo[dwTeamID][pPlayer.dwID].nScore
		if pPlayer.nFightMode ~= 2 then
			tbTeam.nLeftPlayerNum = tbTeam.nLeftPlayerNum + 1;
			tbTeam.nSurvieFightPower = tbTeam.nSurvieFightPower + pPlayer.GetFightPower()
		end
	end

	local tbSortTeams = {}
	for dwTeamID,v in pairs(tbCurTeams) do
		table.insert(tbSortTeams, { dwTeamID = dwTeamID, nSort = v.nLeftPlayerNum * 10000 + v.nScoreTotal, nSurvieFightPower = v.nSurvieFightPower } )
	end

	table.sort( tbSortTeams, function (a, b)
		if a.nSort  == b.nSort then
			return a.nSurvieFightPower > b.nSurvieFightPower
		else
			return a.nSort > b.nSort
		end
	end )

	if #tbSortTeams == 1 then
		return tbSortTeams[1].dwTeamID, string.format("以最終%d人存活的優勢獲得本次心魔幻境的優勝！", math.floor(tbSortTeams[1].nSort / 10000)) 
	end

	local nSort1 = tbSortTeams[1].nSort
	local nSort2 = tbSortTeams[2].nSort

	--第一名的总积分先计算出来吧，要算上最后的优胜积分的
	local dwSort1TeamID = tbSortTeams[1].dwTeamID
	local tbSort1TeamInfo = tbCurTeams[dwSort1TeamID]
	local nLastGetScore = tbSort1TeamInfo.nScoreTotal;
	local nSurviveScore,nDeadScore = unpack(tbDefine.tbWinTeamAddScore)
	for dwRoleId, v in pairs(self.tbTeamReportInfo[dwSort1TeamID]) do
		local pPlayer = KPlayer.GetPlayerObjById(dwRoleId)
		if pPlayer and pPlayer.nFightMode ~= 2 then
			nLastGetScore = nLastGetScore  + nSurviveScore
		else
			nLastGetScore = nLastGetScore  + nDeadScore
		end
	end

	if nSort1 > nSort2 then
		if math.floor(nSort1 / 10000) == math.floor(nSort2 / 10000) then
			return dwSort1TeamID, string.format("以最終%d人存活、%d隊伍總積分的優勢獲得本次心魔幻境的優勝！", tbSort1TeamInfo.nLeftPlayerNum, nLastGetScore)
		else
			return dwSort1TeamID, string.format("以最終%d人存活的優勢獲得本次心魔幻境的優勝！", tbSort1TeamInfo.nLeftPlayerNum)
		end
	end
	if tbSortTeams[1].nSurvieFightPower > tbSortTeams[2].nSurvieFightPower then
		return dwSort1TeamID, string.format("以最終%d人存活、%d隊伍總積分、存活隊員%d總戰力的優勢獲得本次心魔幻境的優勝！", tbSort1TeamInfo.nLeftPlayerNum, nLastGetScore, tbSort1TeamInfo.nSurvieFightPower)
	end

	local nRand = MathRandom(2)
	return tbSortTeams[nRand].dwTeamID , string.format("以最終%d人存活、%d隊伍總積分、存活隊員%d總戰力的優勢獲的本次心魔幻境的優勝！", tbSort1TeamInfo.nLeftPlayerNum, nLastGetScore, tbSort1TeamInfo.nSurvieFightPower)
end

function tbBattleBase:_CloseRoom(nRoomIndex)
	for _,nNpcId in ipairs(self.tbMapNpcGroup[nRoomIndex]) do
		self:DeleteNpc(nNpcId)
	end
	self.tbMapNpcGroup[nRoomIndex] = {};
	for _, nTimer in ipairs(self.tbTimerGroup[nRoomIndex]) do
		Timer:Close(nTimer)
	end
	self.tbTimerGroup[nRoomIndex] = {};
	self.tbForceSynNpcSet[nRoomIndex] = nil;
	self.tbCanUseRoomIndex[nRoomIndex] = nil;
	self.tbNpcDmgInfo[nRoomIndex] = nil;

	for _,nNpcId in ipairs(self.tbGateCloseNpcId[nRoomIndex]) do
		local pNpc = KNpc.GetById(nNpcId)
		if pNpc then
			pNpc.SetName("入口已坍塌")
		end
	end
end

function tbBattleBase:CloseRoom()
	local tbReadyCloseRoomIndex = self.tbReadyCloseRoomIndex
	for k,v in pairs(tbReadyCloseRoomIndex) do
		self:_CloseRoom(k)		
	end
	local tbNowCanUseRooms = {}
	for k,v in pairs(self.tbCanUseRoomIndex) do
		table.insert(tbNowCanUseRooms, k)
	end

	for dwTeamID,v in pairs(self.tbTeamRoomInfo) do
		local tbDeathPlayers = {};
		local pAlivePlayer;
		for dwRoleId,nRoomIndex in pairs(v) do
			if tbReadyCloseRoomIndex[nRoomIndex] then
				--随机传送到未关闭的房间 --如果是已经死的玩家则先不传，后面则传到活的玩家边上即可
				local pPlayer = KPlayer.GetPlayerObjById(dwRoleId)
				if pPlayer then
					--造成伤害 不能死
					if pPlayer.nFightMode ~= 2 then
						local pNpc = pPlayer.GetNpc()
						pNpc.SetCurLife(pNpc.nCurLife * tbDefine.nCloseRoomPunishPersent )
						local nRandRoom = tbNowCanUseRooms[MathRandom(#tbNowCanUseRooms)] 
						local szPosName = "center"
						if #tbNowCanUseRooms == 1 then
							szPosName = tbDefine.tbLastSwitchRandPosSet[MathRandom(#tbDefine.tbLastSwitchRandPosSet)]
						end

						local x,y = unpack(InDifferBattle.tbRooomPosSet[nRandRoom][szPosName])
						self:SwitchToRoom(pPlayer, x,y, nRandRoom, true)
						pPlayer.CenterMsg("幻境異變，被神秘力量席捲至此！", true)
						pAlivePlayer = pPlayer;
					else
						table.insert(tbDeathPlayers, pPlayer)
					end
				end
			end
		end
		if #tbDeathPlayers == 1 and tbDeathPlayers[1].dwFollowAliveId then
			pAlivePlayer = KPlayer.GetPlayerObjById(tbDeathPlayers[1].dwFollowAliveId)
		end
		if pAlivePlayer then  --三个都死在房间等传出去也是可能的
			local nHimRoomIndex = v[pAlivePlayer.dwID]
			local _,x,y = pAlivePlayer.GetWorldPos()
			for _, pPlayer in ipairs(tbDeathPlayers) do 
				self:SwitchToRoom(pPlayer, x,y, nHimRoomIndex, true)
				Dialog:SendBlackBoardMsg(pPlayer, "幻境異變，被神秘力量席捲至此！");	
			end		
		end
	end
	--同步关闭的房间信息
	KPlayer.MapBoardcastScript(self.nMapId, "InDifferBattle:SynRoomOpenInfo", self.tbCanUseRoomIndex)	

	self.tbReadyCloseRoomIndex = nil;
end

function tbBattleBase:ReadyCloseRoom( szRoomGroup, szRandomGroup )
	--准备关闭但不是真正关闭
	local tbRoomIndex1; 
	if szRandomGroup then
		local tbGroup = InDifferBattle.tbRoomSetting[szRandomGroup]
		tbRoomIndex1 = tbGroup[MathRandom(#tbGroup)]
	else
		tbRoomIndex1 = InDifferBattle.tbRoomSetting[szRoomGroup]
	end
		
	self.tbReadyCloseRoomIndex = {}

	for i, nRoomIndex in ipairs(tbRoomIndex1) do
		self.tbReadyCloseRoomIndex[nRoomIndex] = 1;
	end
	KPlayer.MapBoardcastScript(self.nMapId, "InDifferBattle:SynRoomReadyCloseInfo", self.tbReadyCloseRoomIndex)	
end

function tbBattleBase:UpdateClinetSingleNpcInfo(pPlayer, nClientDataVersion)
	if  self.nSynClientDataVersion ~= nClientDataVersion then
		pPlayer.nClientDataVersion = self.nSynClientDataVersion ;
		pPlayer.CallClientScript("InDifferBattle:SynSingleNpcRoomInfo", self.tbCurSingleNpcRoomIndex, self.nSynClientDataVersion)	
	end
end


function tbBattleBase:RequetMapInfo(pPlayer, nClientDataVersion) 
	self:UpdateClinetSingleNpcInfo(pPlayer, nClientDataVersion);

	--队员位置在主界面显示了，所以都是即时同步了
end

function tbBattleBase:RequestTeamScore(pPlayer)
	pPlayer.CallClientScript("InDifferBattle:OnSynBattleScoreInfo", self.tbTeamReportInfo[pPlayer.dwTeamID], self.dwWinnerTeam)
end


function tbBattleBase:ShopBuy(pPlayer, nNpcId, nTemplateId, nBuyCount)
	if pPlayer.nFightMode == 2 then
		pPlayer.CenterMsg("您已陣亡，無法進行操作")
		return
	end
	local pNpc = KNpc.GetById(nNpcId)
	if not pNpc then
		pPlayer.CenterMsg("神秘商人已經離開")
		return
	end

	local tbCurSellWares = pNpc.tbCurSellWares
	if not tbCurSellWares then
		pPlayer.CenterMsg("無效的npc")
		return
	end

	local nOriBookId = InDifferBattle:GetRandSkillBookOriId(nTemplateId)
	if nOriBookId then
		nTemplateId = nOriBookId;
	end

	local nLeftItemNum = tbCurSellWares[nTemplateId]
	if not nLeftItemNum or nLeftItemNum < nBuyCount then
		pPlayer.CenterMsg("該商品庫存不足")
		return
	end

	if pPlayer.GetNpc().GetDistance(nNpcId) >= tbDefine.nCanBuyDistance then
		pPlayer.CenterMsg("您距離神秘商人太遠了")
		return
	end

	local nCost, szMonoeyType = InDifferBattle:GetBuySumPrice(nTemplateId, nBuyCount)
	if not pPlayer.CostMoney(szMonoeyType, nCost, Env.LogWay_InDifferBattle) then
		return
	end

	tbCurSellWares[nTemplateId] = nLeftItemNum - nBuyCount
	self:SendAward(pPlayer, { { "item", nTemplateId, nBuyCount } }, true)
	pPlayer.CallClientScript("InDifferBattle:OnBuyShopWareSuc", tbCurSellWares, nNpcId)
end

function tbBattleBase:AddItemToPlayer(pPlayer, nTemplateId, nCount, bNotAutoSell)
	local nChangeId = InDifferBattle:GetRandSkillBookId(nTemplateId, pPlayer.nFaction)
	if nChangeId then
		nTemplateId = nChangeId
	end
	if not bNotAutoSell and not Item:IsUsableItem(pPlayer, nTemplateId) then --不放到客户端是因为现在是否有用逻辑都是根据获得该道具前的状态
		local nPrice, szMonoeyType = InDifferBattle:GetSellSumPrice(nTemplateId, nCount)
		pPlayer.AddMoney(szMonoeyType, nPrice, Env.LogWay_InDifferBattle)
		return false, { szMonoeyType, nPrice};
	end

	local pItem = pPlayer.AddItem(nTemplateId, nCount, nil, Env.LogWay_InDifferBattle)
	if pItem then
		if pItem.szClass == "SkillBook" then --如果是获得的秘籍都是取的当前最大等级的满级的
			local tbBookInfo = tbSkillBook:GetBookInfo(nTemplateId);
			if tbBookInfo then
				pItem.SetIntValue(tbSkillBook.nSaveSkillLevel, tbBookInfo.MaxSkillLevel);
				pItem.SetIntValue(tbSkillBook.nSaveBookLevel, tbBookInfo.MaxBookLevel);
				pItem.ReInit();	
			end
		end
	end
	return pItem, { "item", nTemplateId, nCount }
end

function tbBattleBase:UseItem(pPlayer, nItemId)
	if pPlayer.nFightMode == 2 then
		pPlayer.CenterMsg("您已陣亡，無法進行操作")
		return
	end
	--TODO 所有用到更新战力的地方 重新封装下新战力头衔的检测
	Item:UseItem(nItemId) --目前只是附魔石头
end

function tbBattleBase:SellItem(pPlayer, nItemId, nCount)
	if pPlayer.nFightMode == 2 then
		pPlayer.CenterMsg("您已陣亡，無法進行操作")
		return
	end
	local pItem = pPlayer.GetItemInBag(nItemId)
	if not pItem then
		print("Unexsit Item "..nItemId)
		return;
	end
	local dwTemplateId = pItem.dwTemplateId;
	local nPrice, szMonoeyType = InDifferBattle:GetSellSumPrice(dwTemplateId, nCount)
	if not nPrice then
		return
	end
	if pPlayer.ConsumeItem(pItem, nCount, Env.LogWay_InDifferBattle) ~= nCount then
		Log("ERROR Shop:Sell comsumeItem failed ", pPlayer.dwID, dwTemplateId, nCount);
		return
	end
	self:SendAward(pPlayer, { { szMonoeyType, nPrice} } )
end

function tbBattleBase:EnhanceEquip(pPlayer, nIndex)
	if pPlayer.nFightMode == 2 then
		pPlayer.CenterMsg("您已陣亡，無法進行操作")
		return
	end
	local bRet, nCostNum, tbEquipPos, nNextLevel = InDifferBattle:CanEnhance(pPlayer, nIndex)
	if not bRet then
		return
	end
	if pPlayer.ConsumeItemInBag(tbDefine.nEnhanceItemId, nCostNum, Env.LogWay_InDifferBattle) ~= nCostNum then
		Log("ConsumeItemInBag faild inf EnhanceEquip")
		return
	end
	local tbInfo = self.tbPlayerInfos[pPlayer.dwID]
	tbInfo.nCostStoneNum = tbInfo.nCostStoneNum + nCostNum
	
	for i, nEquipPos in ipairs(tbEquipPos) do
		pPlayer.SetStrengthen(nEquipPos, nNextLevel) 
		pPlayer.SetUserValue(Strengthen.USER_VALUE_GROUP, nEquipPos + 1, nNextLevel)
	end
	Strengthen:UpdateEnhAtrrib(pPlayer);
	self:ChangeFightPower(pPlayer, "Strengthen");

	pPlayer.CallClientScript("InDifferBattle:OnLevelUpItemSuc", "Strengthen", tbEquipPos, nNextLevel,nIndex)
end

function tbBattleBase:HorseUpgrade(pPlayer, nCostItemId)
	if pPlayer.nFightMode == 2 then
		pPlayer.CenterMsg("您已陣亡，無法進行操作")
		return
	end
	local pCostItem, pCurHorse, nNewItem = Item:GetClass("IndifferScrollHorse"):CanHorseUpgrade(pPlayer, nCostItemId)
	if not pCostItem then
		return
	end
	local tbUsedItems = self.tbPlayerInfos[pPlayer.dwID].tbUsedItems
	local dwCostItemId = pCostItem.dwTemplateId
	if pPlayer.ConsumeItem(pCostItem, 1, Env.LogWay_InDifferBattle) ~= 1 then
		return
	end
	table.insert(tbUsedItems, dwCostItemId)
    pCurHorse.ReInit(nNewItem);
    self:ChangeFightPower(pPlayer, FightPower:GetFightPowerTypeByEquipPos(pCurHorse.nEquipPos));
	pPlayer.CallClientScript("InDifferBattle:OnLevelUpItemSuc", "HorseUpgrade")
end

function tbBattleBase:BookUpgrade(pPlayer, nEquipId, nCostItemId, nEquipPos)
	if pPlayer.nFightMode == 2 then
		pPlayer.CenterMsg("您已陣亡，無法進行操作")
		return
	end
	local pCostItem = pPlayer.GetItemInBag(nCostItemId)
	if not pCostItem then
		return
	end
	local pEquip = pPlayer.GetItemInBag(nEquipId)

	if not pEquip then
		return
	end
	
	local nOlddwTemplateId = pEquip.dwTemplateId
	local tbBookInfo = tbSkillBook:GetBookInfo(nOlddwTemplateId);
	if not tbBookInfo then
		return
	end
	if tbBookInfo.Type >= tbDefine.nMaxSkillBookType then
		return
	end

	if tbBookInfo.UpgradeItem <= 0 then
		return
	end

	local tbUsedItems = self.tbPlayerInfos[pPlayer.dwID].tbUsedItems
	local dwCostItemId = pCostItem.dwTemplateId

	if pPlayer.ConsumeItem(pCostItem, 1, Env.LogWay_InDifferBattle) ~= 1 then
		return
	end
	table.insert(tbUsedItems, dwCostItemId)

	pEquip.Delete(Env.LogWay_InDifferBattle, 0);

	local pNewEquip = self:AddItemToPlayer(pPlayer, tbBookInfo.UpgradeItem, 1)
	if not pNewEquip then
		return
	end
	pPlayer.UseEquip(pNewEquip.dwId, nEquipPos)
	self:ChangeFightPower(pPlayer, "Skill");
	self:ChangeFightPower(pPlayer, "Equip");
	pPlayer.CallClientScript("InDifferBattle:OnLevelUpItemSuc", "BookUpgrade", nOlddwTemplateId, pNewEquip.dwTemplateId)
end

function tbBattleBase:UseEquip(pPlayer, nId, nEquipPos)
	if pPlayer.nFightMode == 2 then
		pPlayer.CenterMsg("您已陣亡，無法進行操作")
		return
	end
	Item:UseEquip(nId, nil, nEquipPos)
	local pEquip = pPlayer.GetItemInBag(nId)
	if pEquip and pEquip.nEquipPos ~= Item.EQUIPPOS_HORSE then
		local szEquipName = KItem.GetItemShowInfo(pEquip.dwTemplateId, pPlayer.nFaction);
		pPlayer.CenterMsg(string.format("成功裝備%s", szEquipName));	
	end
	self:ChangeFightPower(pPlayer, FightPower:GetFightPowerTypeByEquipPos(nEquipPos))
end

function tbBattleBase:UnuseEquip(pPlayer, nEquipPos)
	if pPlayer.nFightMode == 2 then
		pPlayer.CenterMsg("您已陣亡，無法進行操作")
		return
	end
	Item:UnuseEquip(nEquipPos)
	self:ChangeFightPower(pPlayer, FightPower:GetFightPowerTypeByEquipPos(nEquipPos))
end

--所有战力变化的地方调用这个
function tbBattleBase:ChangeFightPower(pPlayer, szType)
	if szType then
		FightPower:ChangeFightPower(szType, pPlayer);
	else
		FightPower:ResetFightPower(pPlayer); --是有buff减少战力的，更新下
	end
	
	--自动变化头衔
	local bChangeHonor = false
	local tbHonorLevel = Player.tbHonorLevel;
	for i=1,10 do
		local bRet, szMsg, tbHonorInfo = self:CheckFinishHonorLevel(pPlayer)
		if bRet and tbHonorInfo then
			pPlayer.SetHonorLevel(tbHonorInfo.Level);
			pPlayer.SetUserValue(tbHonorLevel.nSaveGroupID,  tbHonorLevel.nSaveFightPower, tbHonorInfo.Level); --不然战力计算那边不对
			bChangeHonor = true
		else
			break;
		end	
	end
	if bChangeHonor then
		FightPower:ChangeFightPower("Honor", pPlayer);
		self.tbTeamReportInfo[pPlayer.dwTeamID][pPlayer.dwID].nHonorLevel = pPlayer.nHonorLevel
	end
end

function tbBattleBase:CheckFinishHonorLevel(pPlayer)
    local nAddHonorLevel = pPlayer.nHonorLevel + 1;
    local tbHonorInfo = Player.tbHonorLevel:GetHonorLevelInfo(nAddHonorLevel);
    if not tbHonorInfo then
        return false;
    end

    local pNpc = pPlayer.GetNpc();
    local nFightPower  = pNpc.GetFightPower();
    if tbHonorInfo.NeedPower > nFightPower then
        return false;
    end

    return true, "", tbHonorInfo;
end

function tbBattleBase:RequestLeave(pPlayer)
	if pPlayer.nFightMode ~= 2 and self.nSchedulePos ~= #self.STATE_TRANS then
		pPlayer.CenterMsg("您當前還不能離開")
		return
	end

	local szMsg = "確定要離開活動？"
	pPlayer.MsgBox(szMsg, {{"確定", function (nMapId)
		if me.nMapId ~= nMapId then
			return;
		end
		if self.tbTeamServerInfo[me.dwTeamID].nLivePlayerNum == 0 then --最后一个存活的申请离开时就直接整个队伍出去了
			self:DelayKickTeam(me.dwTeamID)		
		else
			me.ZoneLogout()	
		end
		
	end, pPlayer.nMapId}, {"取消"}})
end

function tbBattleBase:SendAwardToTeamTurns(dwTeamID, tbAward, bNotify)
	local pTarPlayer;
	local tbTurnsGetAwardMembers = self.tbTeamServerInfo[dwTeamID].tbTurnsGetAwardMembers
	for i=1,3 do
		local dwTarRoleId = table.remove(tbTurnsGetAwardMembers) 
		if not dwTarRoleId then
			return
		end

		local pPlayer = KPlayer.GetPlayerObjById(dwTarRoleId)
		if pPlayer and pPlayer.nFightMode ~= 2 then
			pTarPlayer = pPlayer;
			break;
		end
	end
	if not pTarPlayer then
		return
	end
	
	self:SendAward(pTarPlayer, tbAward, bNotify)
	table.insert(tbTurnsGetAwardMembers, 1, pTarPlayer.dwID)
	return pTarPlayer
end

function tbBattleBase:SendAward(pPlayer, tbAward, bNotAutoSell)
	for i,v in ipairs(tbAward) do
		local szType, nParam1,nParam2,nParam3 = unpack(v)
		Log("tbBattleBase:SendAward=====",pPlayer.dwID, szType, nParam1, nParam2,nParam3, bNotAutoSell)

		if szType == "item" then
			local pItem, tbNewInfo = self:AddItemToPlayer(pPlayer, nParam1, nParam2, bNotAutoSell)
			if tbNewInfo then
				tbAward[i] = tbNewInfo	
			end
			
		elseif szType == "Jade" then
			pPlayer.AddMoney(tbDefine.szMonoeyType, nParam1, Env.LogWay_InDifferBattle)		
			if bNotify then
				szAwardMsg = "#987" .. nParam1
			end

		elseif szType == "SkillBook" then
			if nParam1 == 0 then
				nParam1 = MathRandom(4)
			end
			local nBookId = tbSkillBook:GetFactionTypeBook(nParam1, pPlayer.nFaction)
			local pItem, tbNewInfo = self:AddItemToPlayer(pPlayer, nBookId, 1)
			if tbNewInfo then
				tbAward[i] = tbNewInfo; --给客户端的展示	
			end

		elseif szType == "RandMoney" then
			local nRand = MathRandom(nParam1, nParam2)
			pPlayer.AddMoney(tbDefine.szMonoeyType, nRand, Env.LogWay_InDifferBattle)		
			tbAward[i] = {tbDefine.szMonoeyType, nRand}; 

		elseif szType == "RandBuff" then
			local tbRandBuffSet = tbDefine.tbRandBuffSet
			local tbBuff = tbRandBuffSet[MathRandom(#tbRandBuffSet)]
			local nBuffId, nLevel, nTime = unpack(tbBuff)
			pPlayer.AddSkillState(nBuffId, nLevel, 0, nTime)
		elseif szType == "RandItemCount" then
			local nItemCount = MathRandom(nParam2, nParam3)
			local pItem, tbNewInfo = self:AddItemToPlayer(pPlayer, nParam1, nItemCount)
			if tbNewInfo then
				tbAward[i] = tbNewInfo; --给客户端的展示
			end
		else
			Log(debug.traceback(), pPlayer.dwID .. ",".. szType)
		end

		if szAwardMsg then
			ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Team, string.format("「%s」獲得了%s", pPlayer.szName, szAwardMsg), pPlayer.dwTeamID)
		end
	end
	
	pPlayer.CallClientScript("Ui:MergeShowAwardTips", tbAward, Env.LogWay_InDifferBattle, true)
end

function tbBattleBase:OnSendAward(pPlayer, pNpc, tbAward)
	self:SendAward(pPlayer, tbAward)
end

function tbBattleBase:OnBlackBoardMsg(pPlayer, pNpc, szMsg)
	Dialog:SendBlackBoardMsg(pPlayer, szMsg)
end

function tbBattleBase:OnOpenBoxCastSkillCycle(pPlayer, pNpc, nTimeSpace, nSkillId, nSkilLevel, nParam1, nParam2)
	local _,x,y = pNpc.GetWorldPos()
	self:AddNpcAndTimerCastSkill(pNpc.nRoomIndex, x,y, nTimeSpace, nSkillId, nSkilLevel, nParam1, nParam2)
end

function tbBattleBase:AddNpcAndTimerCastSkill(nRoomIndex, x, y, nTimeSpace, nSkillId, nSkilLevel, nParam1, nParam2)
	local nForceSyncNpcId = self.tbForceSynNpcSet[nRoomIndex] 
	if not nForceSyncNpcId then
		return
	end
	if self.bRestTime then
		return
	end
	local pNpc = KNpc.GetById(nForceSyncNpcId)
	if not pNpc then
		return
	end

	pNpc.CastSkill(nSkillId, nSkilLevel, x, y);
end


function tbBattleBase:TimerActvieCastSkill(nNpcId, tbParams)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return
	end
	local nTimeCount = pNpc.nTimeCount
	if not nTimeCount then
		return
	end
	local v = tbParams[nTimeCount]
	if not v then
		nTimeCount = 1;
		pNpc.nTimeCount = nTimeCount
		v = tbParams[nTimeCount]
	end
	local nDelayTime, tbPoints = unpack(v);
	if not self.bRestTime then
		for _,v2 in ipairs(tbPoints) do
			pNpc.CastSkill(unpack(v2));	
		end
	end
	pNpc.nTimeCount = nTimeCount + 1;
	Timer:Register(nDelayTime, self.TimerActvieCastSkill, self, nNpcId, tbParams)
end

function tbBattleBase:AddActiveCastSkill(nRoomIndex, tbParams)
	local nNpcId = self.tbForceSynNpcSet[nRoomIndex]
	if not nNpcId then
		return
	end
	local pNpc = KNpc.GetById(nNpcId)
	if not pNpc then
		return
	end
	pNpc.nTimeCount = 1;
	self:TimerActvieCastSkill(nNpcId, tbParams)
end

function tbBattleBase:DelayFunc(nTime, tbFuc)
	Timer:Register(nTime, function ()
		Lib:CallBack({ self[tbFuc[1]], self, unpack( tbFuc, 2 )})	
	end )
end

function tbBattleBase:FormatNpcDmgInfo(nNpcId)
	if not nNpcId then
		return
	end
	local pNpc = KNpc.GetById(nNpcId)
	if not pNpc then
		return
	end
	local tbNpcInfo = InDifferBattle.tbRoomSetting.tbSingleRoomNpc[pNpc.nTemplateId]
	if not tbNpcInfo then
		return
	end
	
	local nLastDmgBossHPPercent = tbNpcInfo.bBoss and  tbDefine.nLastDmgBigBossHPPercent or tbDefine.nLastDmgBossHPPercent
	local nMaxLife = pNpc.nMaxLife / (1 - nLastDmgBossHPPercent / 100)
	local tbDmgInfo = pNpc.GetDamageInfo();
	local tbDmgInfoShow = {}
	for i,v in ipairs(tbDmgInfo) do
		table.insert(tbDmgInfoShow, {nPercent = v.nTotalDamage / nMaxLife, nTeamId = v.nTeamId })
	end
	return tbDmgInfoShow
end

function tbBattleBase:GetNpcDmgInfo(nRoomIndex)
	local tbInfo = self.tbNpcDmgInfo[nRoomIndex]
	local nNow = GetTime()
	if not tbInfo then
		local tbDmgInfoShow = self:FormatNpcDmgInfo(self.tbCurSingleNpcRoomId[nRoomIndex])
		if tbDmgInfoShow then
			tbInfo = { nNow, tbDmgInfoShow }	
			self.tbNpcDmgInfo[nRoomIndex] = tbInfo
		end
	else
		if tbInfo[1] + tbDefine.UPDATE_SYNC_DMG_INTERVAL < nNow  then
			local tbDmgInfoShow = self:FormatNpcDmgInfo(self.tbCurSingleNpcRoomId[nRoomIndex])
			if tbDmgInfoShow then
				tbInfo = { nNow, tbDmgInfoShow }	
				self.tbNpcDmgInfo[nRoomIndex] = tbInfo
			end	
		end
	end
	if tbInfo then
		return tbInfo[2]
	end
end

function tbBattleBase:UpdateNpcDmgInfo(pPlayer)
	local nRoomIndex = self.tbTeamRoomInfo[pPlayer.dwTeamID][pPlayer.dwID]
	local tbDmgInfoShow = self:GetNpcDmgInfo(nRoomIndex)
	if not tbDmgInfoShow then
		return
	end

	pPlayer.CallClientScript("InDifferBattle:SynNpcDmgInfo", nRoomIndex, tbDmgInfoShow)
end

function tbBattleBase:OnOpenIndifferBox(pPlayer, pNpc)
	local tbOpenBox = tbDefine.tbOpenBoxType[pNpc.nTemplateId]
	if not tbOpenBox then
		Log(debug.traceback(), pNpc.nTemplateId)
		return
	end
	local tbEvent = tbOpenBox[self.nSchedulePos]
	if not tbEvent then
		Log("OnOpenIndifferBox in not FightState")
		return
	end
	local nRand = MathRandom()
	for i,v in ipairs(tbEvent) do
		local nTarRand,tbProc = unpack(v)
		if nRand <= nTarRand then
			for _,v2 in ipairs(tbProc) do
				Lib:CallBack({self[v2[1]], self, pPlayer, pNpc, unpack(v2, 2)});
			end
			return
		end
	end
end

function tbBattleBase:SendRandDropAwardToTeam( dwTeamID, szDropList, nRandMin, nRandMax, bNotify)
	local tbDropList = tbDefine.tbDrapList[szDropList]
	if not tbDropList then
		Log(debug.traceback(), szDropList)
		return
	end
	local nTime = MathRandom(nRandMin, nRandMax)
	for nCount = 1, nTime do
		local nRand = MathRandom()	
		for _,v in ipairs(tbDropList) do
			local _rand, tbAwawrd = unpack(v)
			if nRand <= _rand then
				self:SendAwardToTeamTurns(dwTeamID, { tbAwawrd }, bNotify)
				break;
			end
		end
	end
	return nTime
end

function tbBattleBase:OnSendRandDropAwardToTeam(pPlayer, pNpc, szDropList, nRandMin, nRandMax)
	local nCount = self:SendRandDropAwardToTeam(pPlayer.dwTeamID, szDropList, nRandMin, nRandMax)
	ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Team, string.format("「%s」打開了%s，獲得了%d個寶物已均分給隊伍成員", pPlayer.szName, pNpc.szName, nCount), pPlayer.dwTeamID)
end

function tbBattleBase:OnAddRandPosNpcSet(pPlayer, pNpc, nTemplateId, nLevel, nRandMin, nRandMax)
	local nMapId, x, y = pNpc.GetWorldPos()
	local nCount = MathRandom(nRandMin, nRandMax)
	local tbPosSet = Item.Obj:GetDropPos(nCount, nMapId, x, y);
	local fnPosSelect = Lib:GetRandomSelect(#tbPosSet);
	local nDir = pNpc.GetDir()
	local nRoomIndex = pNpc.nRoomIndex
	for i=1, nCount do
		local nPosIdx = fnPosSelect();
		local x1,y1 = unpack(tbPosSet[nPosIdx]) 
		self:AddMapNpc(nTemplateId, nLevel, nRoomIndex, x1, y1, nDir)
	end
	self:OnWorldNotify(string.format("心魔幻象已被某支「神秘人」隊伍開啟，%d號區域散落了許多寶箱", nRoomIndex))
end

function tbBattleBase:OnSendAwardTeamAll(pPlayer, pNpc, tbAward)
	for dwRoleId, nRoomIndex in pairs(self.tbTeamRoomInfo[pPlayer.dwTeamID]) do
		local pPlayer = KPlayer.GetPlayerObjById(dwRoleId)
		if pPlayer and pPlayer.nFightMode ~= 2 then
			self:SendAward(pPlayer, tbAward)
		end
	end
end

function tbBattleBase:AddAutoHideWalkPathNpc(nRoomIndex, nTemplateId, nLevel, szPath, nLiveTime, nRespanTime)
	if not self.tbCanUseRoomIndex[nRoomIndex] then
		return
	end
	if not self.bRestTime then
		local tbPath = InDifferBattle.tbNpcMovePath[szPath]
		local x, y = unpack(tbPath[1])
		local pNpc = self:AddMapNpc(nTemplateId, nLevel, nRoomIndex, x, y)
		if not pNpc then
			return
		end
		pNpc.AI_ClearMovePathPoint();
		for _,Pos in ipairs(tbPath) do
			pNpc.AI_AddMovePos(unpack(Pos));
		end
		pNpc.AI_StartPath(1);
		Timer:Register(nLiveTime, self.DeleteNpc, self, pNpc.nId) 
	end
	Timer:Register(nLiveTime + nRespanTime, self.AddAutoHideWalkPathNpc, self, nRoomIndex, nTemplateId, nLevel, szPath, nLiveTime, nRespanTime)
end
