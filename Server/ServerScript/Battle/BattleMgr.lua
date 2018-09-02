Battle.tbMapInst = Battle.tbMapInst or {} --放的是实际实例
local tbMapInst = Battle.tbMapInst

Battle.tbSignUpPlayerList = Battle.tbSignUpPlayerList or {} --报名等待队列
Battle.tbInGamePlayers = Battle.tbInGamePlayers or {}
local tbInGamePlayers = Battle.tbInGamePlayers --分配好进战场的玩家
-- [nMapId] = {
--  [PlayerInfo] = { [nId] = tbInfo,  }, --战场自己在管理 PlayerInfos
-- 	[tbTeamA] ={ids, 12,,32,3,2}
-- 	[tbTeamB] ={ids, 12,,32,3,2}
	-- tbTeamFightPowers
-- }

--schedule 接口
function Battle:OpenBattleSignUp(nIndex) --nIndex 是第几个战场图
	local tbReadyMaps = {Battle.READY_MAP_ID};
	self:_OpenBattleSignUp(nIndex, tbReadyMaps)
end

function Battle:_OpenBattleSignUp(nIndex, tbReadyMaps) --nIndex 是第几个战场图
	if self.tbCurBattleSetting then
		Log("Error !! already OpenBattleSignUp", self.tbCurBattleSetting.nIndex)
		return
	end
	self:StopBattleSignUp();

	local tbSetting = self.tbMapSetting[nIndex]
	self.tbCurBattleSetting =  tbSetting

	self.tbReadyMapWaitIds = {}
	self.tbReadyMapIds = {};
	self.tbReadyMapIdIndexs = {};
	self.tbSignUpPlayerList = {}
	self.tbFightBattleMapIdToReadyMapIndex =  {};
	for i, nReadyMap in ipairs(tbReadyMaps) do
		local nMapId = CreateMap(nReadyMap);
		self.tbReadyMapWaitIds[i] = nMapId
		self.tbSignUpPlayerList[nMapId] = {};
	end
end

--在跨区里重载
function Battle:GetCurBattleSetting(nReadyMapIndex)
	return self.tbCurBattleSetting
end

--sche 接口
function Battle:StopBattleSignUp()
	if self.nActiveTimer then
		Timer:Close(self.nActiveTimer)
		self.nActiveTimer = nil;
	end
	if self.nActiveTimerReady then
		Timer:Close(self.nActiveTimerReady)
		self.nActiveTimerReady = nil;
	end


	if self.tbReadyMapIds then
		for i,nMapId in ipairs(self.tbReadyMapIds) do
			KPlayer.MapBoardcastScript(nMapId, "Ui:OpenWindow", "QYHLeftInfo", "BattleClose")
		end
	end

	if not MODULE_ZONESERVER then
		--跨区服上就不通知客户端这个了，不然客户端等于可能提前关闭了状态 TODO 直接改 Calendar:OnActivityEnd里？
		Calendar:OnActivityEnd("Battle")
		Calendar:OnActivityEnd("BattleZone")
		if self.tbCurBattleSetting then
			Calendar:OnActivityEnd(self.tbCurBattleSetting.szLogicClass)
		end
	end

	self.tbCurBattleSetting = nil
	self.tbSignUpPlayerList = nil;
	self.tbReadyMapIds = nil;
	self.tbReadyMapIdIndexs = nil;
	self.tbReadyMapWaitIds = nil;
	self.tbFightBattleMapIdToReadyMapIndex = nil;
	self.nCahcheMatchTimeMonth = nil;
	self.nCahcheMatchTimeSeason = nil;
	self.nCahcheMatchTimeYear = nil;
	self.nCahcheMatchTimeMonthNext = nil;
	self.nCahcheMatchTimeYearNext = nil;

	self:OnStopBattleSignUpEvent();
end

--跨区重载
function Battle:OnStopBattleSignUpEvent()
	-- body
end

function Battle:OnEnterReadyMap()
	local tbSignUpPlayerList = self.tbSignUpPlayerList[me.nMapId]
	table.insert(tbSignUpPlayerList, me.dwID)
	local nTime = math.floor(Timer:GetRestTime(self.nActiveTimer) / Env.GAME_FPS);
	local tbBattleSetting = Battle:GetCurBattleSetting(self.tbReadyMapIdIndexs[me.nMapId])
	local szType = tbBattleSetting.szLogicClass == "BattleMoba" and "BattleMoba" or "Battle"
	me.CallClientScript("Battle:EnterReadyMap", szType, {nTime, string.format("%d / %d", #tbSignUpPlayerList, tbBattleSetting.nPlayerMaxNum)})
end

function Battle:OnLeaveReadyMap()
	if not self.tbSignUpPlayerList then
		return
	end
	local tbSignUpPlayerList = self.tbSignUpPlayerList[me.nMapId]
	if not tbSignUpPlayerList then
		return
	end
	for i,v in ipairs( tbSignUpPlayerList) do
		if v == me.dwID then
			table.remove(tbSignUpPlayerList, i)
			return
		end
	end
end

function Battle:OnLoginReadyMap(nMapId)
	if not self.tbSignUpPlayerList then
		me.CallClientScript("Ui:OpenWindow", "QYHLeftInfo", "BattleClose")
	else
		local tbSignUpPlayerList = self.tbSignUpPlayerList[me.nMapId]
		local nTime = math.floor(Timer:GetRestTime(self.nActiveTimer) / Env.GAME_FPS);
		local tbBattleSetting = Battle:GetCurBattleSetting(self.tbReadyMapIdIndexs[me.nMapId])
		local szType = tbBattleSetting.szLogicClass == "BattleMoba" and "BattleMoba" or "Battle"
		me.CallClientScript("Battle:EnterReadyMap", szType, {nTime, string.format("%d / %d", #tbSignUpPlayerList, tbBattleSetting.nPlayerMaxNum)})
	end
end

function Battle:UpdateReadyMapInfo()
	local nTime = math.floor(Timer:GetRestTime(self.nActiveTimer) / Env.GAME_FPS);
	for nMapId, tbSignUpPlayerList in pairs(self.tbSignUpPlayerList) do
		local nTotalNum = #tbSignUpPlayerList
		local tbBattleSetting = Battle:GetCurBattleSetting(self.tbReadyMapIdIndexs[nMapId])
		local szNumInfo = string.format(nTotalNum < 1000 and "%d / %d" or "%d/%d", nTotalNum, tbBattleSetting.nPlayerMaxNum)
		KPlayer.MapBoardcastScript(nMapId, "Ui:DoLeftInfoUpdate", {nTime, szNumInfo})
	end
	return true
end

function Battle:Active()
	for i, nMapId in ipairs(self.tbReadyMapIds) do
		self:ActiveSingleMap(nMapId, i)
	end
end

function Battle:ActiveSingleMap(nMapId, nReadyMapIndex)
	local tbSignUpPlayerList = self.tbSignUpPlayerList[nMapId]
	if not tbSignUpPlayerList then
		Log(debug.traceback(), nMapId, nReadyMapIndex)
		return
	end
	local tbCurBattleSetting = Battle:GetCurBattleSetting(nReadyMapIndex)
	local nMatchPlayerNumMax = tbCurBattleSetting.nPlayerMaxNum
	local nMatchPlayerNumMin = tbCurBattleSetting.nPlayerMinNum
	if #tbSignUpPlayerList < nMatchPlayerNumMin then
		return
	end

	local tbPlayers = {};
	local tbNewSignUpList = {}
	--非法的移除队列，并通知
	for i, dwRoleId in ipairs(tbSignUpPlayerList) do
		local pPlayer = self:CheckPlayerCanInvite(dwRoleId)
		if pPlayer then
			table.insert(tbPlayers, pPlayer)
		end
	end

	--看下合法的能开几场
	local bAssigMatchAvrage = false; --如果是规定人数的战场，则战场分配按照战力接近的放一个场次
	local nTotalNum = #tbPlayers
	local nMatchNum = math.ceil(nTotalNum / nMatchPlayerNumMax)
	if nMatchPlayerNumMin == nMatchPlayerNumMax then
		nMatchNum = math.floor(nTotalNum / nMatchPlayerNumMax)
		bAssigMatchAvrage = true;
	end
	if #tbPlayers < nMatchPlayerNumMin then
		nMatchNum = 0;
	end

	if nMatchNum == 0 then
        for i, pPlayer in ipairs(tbPlayers) do
            table.insert(tbNewSignUpList, pPlayer.dwID)
        end
    else
        if nTotalNum > nMatchNum * nMatchPlayerNumMax then
            for i = nTotalNum, nMatchNum * nMatchPlayerNumMax + 1, -1 do
                if tbPlayers[i] then
                    table.insert(tbNewSignUpList, tbPlayers[i].dwID)      
                    table.remove(tbPlayers, i)
                end
            end
        end
    end
	self.tbSignUpPlayerList[nMapId] = tbNewSignUpList

	if nMatchNum < 1 then
		return
	end

	--直接扣除次数了，上面检查过了
	self:OpenBattleMap(tbPlayers, nMatchNum, nReadyMapIndex, bAssigMatchAvrage)
end

--根据玩家和开启场数，对玩家做均匀的场次分配
function Battle:OpenBattleMap(tbPlayers, nMatchNum, nReadyMapIndex, bAssigMatchAvrage)
	--先创建地图
	local tbMapIds = {}
	local tbMapPlayers = {}
	local tbCurBattleSetting = Battle:GetCurBattleSetting(nReadyMapIndex)
	for i = 1, nMatchNum do
		local nMapId = CreateMap(tbCurBattleSetting.nMapTemplateId);
		self.tbFightBattleMapIdToReadyMapIndex[nMapId] = nReadyMapIndex;
		table.insert(tbMapIds, nMapId);
		tbMapPlayers[nMapId] = {};
	end

	--todo 目前是没有考虑门派的
    local fnSort = function (pPlayerA, pPlayerB)
        return pPlayerA.GetFightPower() > pPlayerB.GetFightPower();
    end
    local fnAssignMatch = function (nPos)
    	return math.floor(nPos - 1) % nMatchNum + 1;
    end
    if bAssigMatchAvrage then
    	local nAverageNum = math.floor(#tbPlayers / nMatchNum) 
    	fnAssignMatch = function (nPos)
	    	return math.floor( (nPos - 0.1) / nAverageNum) + 1;
	    end
    end

    table.sort(tbPlayers, fnSort)

	for nPos, pPlayer in ipairs(tbPlayers) do
        local nGameIndex = fnAssignMatch(nPos)
        local nMapId = tbMapIds[nGameIndex]

        table.insert(tbMapPlayers[nMapId], pPlayer);
        Log(string.format("Battle:OpenBattleMap szName:%s nFaction:%d FightPower:%s nMapId:%d", pPlayer.szName,
        	pPlayer.nFaction, pPlayer.GetFightPower(), nMapId));
    end

    --分组
    for _, nMapId in ipairs(tbMapIds) do
    	self:AssignTeam(tbMapPlayers[nMapId], nMapId, nReadyMapIndex)
    end
end

--根据功力分配单场的阵营
function Battle:AssignTeam(tbPlayers, nMapId, nReadyMapIndex)
	local tbPlayerInfos = {};
    local tbTeams = {{}, {}}
    local tbCurBattleSetting = Battle:GetCurBattleSetting(nReadyMapIndex)
    local tbTeamNames = tbCurBattleSetting.tbTeamNames
    local tbTeamFightPowers = {0, 0}

    local fnSort = function (pPlayerA, pPlayerB)
        return pPlayerA.GetFightPower() > pPlayerB.GetFightPower();
    end
    table.sort(tbPlayers, fnSort)

    local nMaxTeamPlayerNum = math.ceil(#tbPlayers / 2)
    local nRandTeamIndex1 = MathRandom(2)
    local nRandTeamIndex2 = nRandTeamIndex1 == 1 and 2 or 1;

    local fnAssignTeam = function ()
		local nTeamNum1 = #tbTeams[nRandTeamIndex1]
		if nTeamNum1 >= nMaxTeamPlayerNum then
			return nRandTeamIndex2
		end

		local nTeamNum2 = #tbTeams[nRandTeamIndex2]
		if nTeamNum2 >= nMaxTeamPlayerNum then
			return nRandTeamIndex1
		end

		if tbTeamFightPowers[nRandTeamIndex1] > tbTeamFightPowers[nRandTeamIndex2] then
			return nRandTeamIndex2
		else
			return nRandTeamIndex1
		end
    end

    for _, pPlayer in ipairs(tbPlayers) do
    	local nTeamIndex = fnAssignTeam()

    	table.insert(tbTeams[nTeamIndex], pPlayer.dwID)
    	tbTeamFightPowers[nTeamIndex] = tbTeamFightPowers[nTeamIndex] + pPlayer.GetFightPower();

    	--todo 其他玩家情况需要的再加吧 战场相关的积分在进入后初始化 因为中间是不允许离开战场的
    	local tbPlayerInfo = {
	    	nTeamIndex = nTeamIndex,
	    	szName = pPlayer.szName,
	    	nFaction = pPlayer.nFaction,
	    	nLevel = pPlayer.nLevel,
	    };

    	tbPlayerInfos[pPlayer.dwID] = tbPlayerInfo

    	pPlayer.CenterMsg(string.format("你加入了%s", tbTeamNames[nTeamIndex]))
    end

    Log(string.format("Battle:AssignTeam nMapId:%d, tbTeamA_num:%d, A_fight_powe:%d, tbTeamB_num:%d, B_fight_powe:%d",
    		nMapId, #tbTeams[1], tbTeamFightPowers[1], #tbTeams[2], tbTeamFightPowers[2]));

    tbInGamePlayers[nMapId] = {
		tbPlayerInfo = tbPlayerInfos, --[id] = tbInfo
		tbTeamA = tbTeams[1],--ids,1,2,32,3,
		tbTeamB = tbTeams[2],
		tbTeamFightPowers = tbTeamFightPowers,
	};
end

-- 检查玩家是否符合进入改战场的条件，比如在线状态，地图等等
function Battle:CheckPlayerCanInvite(dwRoleId)
	local pPlayer = KPlayer.GetPlayerObjById(dwRoleId)
	if not pPlayer then
		return
	end

	if DegreeCtrl:GetDegree(pPlayer, "Battle") < 1 then
		return
	end

	if not self.LegalMap[pPlayer.nMapTemplateId] then
		pPlayer.CenterMsg("您目前無法被傳入戰場地圖，已經退出等待佇列")
		return
	end

	if pPlayer.nState ~= 2 and pPlayer.nState ~= 5 then -- emPLAYER_STATE_NORMAL
		return
	end

    return pPlayer;
end

--c2s 报名，
function Battle:SignUp(pPlayer, bSkipZone)
    if not Env:CheckSystemSwitch(pPlayer, Env.SW_SwitchMap) then
    	pPlayer.CenterMsg("目前狀態不允許切換地圖")
	    return
	end
	local tbBattleSetting, nSignGroupIndex = Battle:GetCanSignBattleSetting(pPlayer)
	if not tbBattleSetting then
		pPlayer.CenterMsg("現在沒有戰場")
		return
	end

	local bRet, szMsg = self:CheckCanSignUp(pPlayer, tbBattleSetting)
	if not bRet then
		pPlayer.CenterMsg(szMsg)
		return
	end
	if self.tbNowOpenZoneSetting and nSignGroupIndex then --本服开的只有一种战场，如果跨服的能报就先报了
		local tbReadyMapIds = self.tbNowOpenZoneSetting[tbBattleSetting.nIndex]  
		if tbReadyMapIds then
			local nReadyMapId = tbReadyMapIds[nSignGroupIndex]
			if nReadyMapId then
				pPlayer.SetEntryPoint()
				pPlayer.SwitchZoneMap(nReadyMapId, unpack(self.READY_MAP_POS[MathRandom(#self.READY_MAP_POS)]) )
				return			
			end
		end
	end

	if not self.tbReadyMapIds or not next(self.tbReadyMapIds) then
		pPlayer.CenterMsg("現在沒有戰場")
		return
	end
	local _, nReadyMapId = next(self.tbReadyMapIds)

	local tbCurBattleSetting = Battle:GetCurBattleSetting()
	if pPlayer.nLevel < tbCurBattleSetting.nMinLevel then
		pPlayer.CenterMsg(string.format("需要%d級才能參加", tbCurBattleSetting.nMinLevel))
		return
	end


	pPlayer.SetEntryPoint()
	pPlayer.SwitchMap(nReadyMapId, unpack(self.READY_MAP_POS[MathRandom(#self.READY_MAP_POS)]) )

	Log("Battle:SignUp add to the wait list", pPlayer.dwID)
end

--BattleNpc 类被杀时
function Battle:OnNpcDeath(him, pKiller)
	local tbInst = tbMapInst[him.nMapId]
	if tbInst then
		tbInst:OnNpcDeath(him, pKiller)
		return
	end

	local tbKinBattleInst = KinBattle.tbFightInstanceByMapId[him.nMapId];
	if tbKinBattleInst then
		tbKinBattleInst:OnNpcDeath(him, pKiller);
		return
	end

	local tbDomainBattleInst = DomainBattle.tbMapInst[him.nMapId]
	if tbDomainBattleInst then
		tbDomainBattleInst:OnNpcDeath(him, pKiller)
	end
end

function Battle:OnEarlyDeath( him, pKiller )
	local tbInst = tbMapInst[him.nMapId]
	if tbInst and tbInst.OnEarlyDeath then
		tbInst:OnEarlyDeath(him, pKiller)
		return
	end
end

function Battle:OnReadyMapCreate(nMapId)
	for i, nReadyMapId in ipairs(self.tbReadyMapWaitIds) do
		if nMapId == nReadyMapId then
			self.tbReadyMapIds[i] = nMapId
			self.tbReadyMapIdIndexs[nMapId] = i;
			break;
		end
	end
	if #self.tbReadyMapIds == #self.tbReadyMapWaitIds then
		self:OnAllReadyMapCreate()
		self.tbReadyMapWaitIds = nil;
	end
end

function Battle:OnAllReadyMapCreate()
	local tbSetting = self.tbCurBattleSetting
	assert(tbSetting)

	self.nActiveTimer =	Timer:Register(Env.GAME_FPS * Battle.ONLY_SIGNUP_TIME, function ()
		self:Active()

		self.nActiveTimer = Timer:Register(Env.GAME_FPS * Battle.NEXT_SIGNUP_TIME, function ()
			self:Active();
			return true
		end)
	end)

	self.nActiveTimerReady =  Timer:Register(Env.GAME_FPS * 3, self.UpdateReadyMapInfo, self)

	self:OnAllReadyMapCreateEvent();
end

--跨区重载
function Battle:OnAllReadyMapCreateEvent()
	local tbSetting = self.tbCurBattleSetting
    assert(tbSetting)
   	local szBattleName = "宋金大戰";
   	if tbSetting.bShowName then
   		szBattleName = tbSetting.szName
   	end
    local szMsg = string.format("%s一觸即發，眾俠士請火速報名加入！", szBattleName) 
    local bHasZoneBattle = false;
    Log("self.tbChangedCalendar",tostring(self.tbChangedCalendar))
    if self.tbNowOpenZoneSetting and self.tbChangedCalendar then
        local nLastLevel = 1;
        for nSettingIndex, _ in pairs(self.tbNowOpenZoneSetting) do
            bHasZoneBattle = true
            local tbBattleSetting = self.tbMapSetting[nSettingIndex]    
            if tbBattleSetting.bZone then
                if tbBattleSetting.nShowLevel > nLastLevel and ( not tbBattleSetting.nRealNeedLevel or  GetMaxLevel() >= tbBattleSetting.nRealNeedLevel)  then
                    szMsg = string.format("%s即將開啟，眾俠士請火速報名參戰！", tbBattleSetting.szName) 
                end
            end
            Log("tbBattleSetting.szLogicClass", tbBattleSetting.szLogicClass, self.tbChangedCalendar[tbBattleSetting.szLogicClass])
            if not self.tbChangedCalendar[tbBattleSetting.szLogicClass] then
                Calendar:OnActivityBegin(tbBattleSetting.szLogicClass) 
            end
        end
        if bHasZoneBattle then 
            Calendar:OnActivityBegin("BattleZone")
        end
    end
    
    KPlayer.SendWorldNotify(tbSetting.nMinLevel, 150, szMsg, 1, 1)

    local tbMsgData = {
        szType = "StartBattle";
        nTimeOut = GetTime() + 1800;
    };

    KPlayer.BoardcastScript(tbSetting.nMinLevel, "Ui:SynNotifyMsg", tbMsgData);
    if self.tbCurBattleSetting.szLogicClass ~= "BattleMoba" then
    	Calendar:OnActivityBegin("Battle")
    end
    
    Calendar:OnActivityBegin(self.tbCurBattleSetting.szLogicClass)
    SupplementAward:OnActivityOpen("Battle")
end

--战场地图创建完时
function Battle:OnBattleMapCreate(nMapId)
	local nReadyMapIndex = self.tbFightBattleMapIdToReadyMapIndex[nMapId]
	if not nReadyMapIndex then
		Log(debug.traceback(), nMapId)
		return
	end
	self.tbFightBattleMapIdToReadyMapIndex[nMapId] = nil;
	local tbCurBattleSetting = self:GetCurBattleSetting(nReadyMapIndex)
	if not tbCurBattleSetting then
		Log(debug.traceback(), nReadyMapIndex)
		return
	end
	local tbInst = Lib:NewClass(Battle:GetClass(tbCurBattleSetting.szLogicClass))
	tbMapInst[nMapId] = tbInst

	local tbMapPlayerInfo = tbInGamePlayers[nMapId]
	tbInst:Init(nMapId, tbCurBattleSetting, tbMapPlayerInfo.tbPlayerInfo, tbMapPlayerInfo.tbTeamA, tbMapPlayerInfo.tbTeamB, nReadyMapIndex, tbMapPlayerInfo.tbTeamFightPowers)
	tbInst:Start();

	--开始传送玩家
	local nToday = Lib:GetLocalDay()
	local bCostTicket = tbCurBattleSetting.nQualifyTitleId == nil;

	for dwRoleId, v in pairs(tbMapPlayerInfo.tbPlayerInfo) do
		local pPlayer = KPlayer.GetPlayerObjById(dwRoleId)
		if pPlayer and (pPlayer.nState == 2 or pPlayer.nState == 5)  then
			if pPlayer.dwTeamID ~= 0 then
				TeamMgr:QuiteTeam(pPlayer.dwTeamID, pPlayer.dwID);
			end
			self:OnPlayedBattleEvnet(pPlayer, bCostTicket)

			pPlayer.SwitchMap(nMapId, 0,0);

		else
			v.bNotJoin = true;
		end
	end
end

function Battle:OnPlayedBattleEvnet(pPlayer, bCostTicket)
	if bCostTicket then
		DegreeCtrl:ReduceDegree(pPlayer, "Battle", 1)
	end
	
	EverydayTarget:AddCount(pPlayer, "Battle");
	LogD(Env.LOGD_ActivityPlay, pPlayer.szAccount, pPlayer.dwID, pPlayer.nLevel, nil, Env.LOGD_VAL_TAKE_TASK, Env.LOGD_MIS_BATTLE, pPlayer.GetFightPower());
	AssistClient:ReportQQScore(pPlayer, Env.QQReport_IsJoinSongJin, 1, 0, 1)
	Achievement:AddCount(pPlayer, "Battle_1", 1)
	TeacherStudent:TargetAddCount(pPlayer, "BattleField", 1)
	TeacherStudent:CustomTargetAddCount(pPlayer, "BattleField", 1)
	SupplementAward:OnJoinActivity(pPlayer, "Battle")
end

function Battle:OnGetAwardEvent(dwRoleId, tbAchievenments, tbAwardNeedCopy, tbBattleInfo, szMsg)
	local tbAward = Lib:CopyTB(tbAwardNeedCopy)
	for i,v in ipairs(Battle.tbAllAwardSet.tbExtRandomAward) do
		if GetTimeFrameState(v[1]) == 1 then
			if MathRandom() <= v[3] then
				table.insert(tbAward, {"item", v[2], 1})
			end
			break;
		end
	end
	local pPlayer = KPlayer.GetPlayerObjById(dwRoleId)
	if pPlayer then
		for i, v in ipairs(tbAchievenments) do
			Achievement:AddCount(pPlayer, v, 1)
		end

		if tbBattleInfo then
			pPlayer.TLogRoundFlow(Env.LogWay_Battle, tbBattleInfo.nMapTemplateId, tbBattleInfo.nScore, tbBattleInfo.nMatchTime
				 			, tbBattleInfo.nResult,  tbBattleInfo.nRank, 0);

			AssistClient:ReportQQScore(pPlayer, Env.QQReport_SongJinKillCount, tbBattleInfo.nKillCount, 0, 1)
			AssistClient:ReportQQScore(pPlayer, Env.QQReport_SJBattleResult, tbBattleInfo.nResult, 0, 1)
			AssistClient:ReportQQScore(pPlayer, Env.QQReport_SJBattleMaxCombo, tbBattleInfo.nMaxCombo, 0, 1)
			AssistClient:ReportQQScore(pPlayer, Env.QQReport_SJBattleDeathCount, tbBattleInfo.nDeathCount, 0, 1)

			
			RecordStone:AddRecordCount(pPlayer, "Battle", tbBattleInfo.nKillCount)

			if tbBattleInfo.nRank == 1 then
				pPlayer.CallClientScript("GameSetting.Comment:OnEvent", GameSetting.Comment.Type_Battle_First);
			end

			local tbBattleSetting = Battle.tbAllBattleSetting[tbBattleInfo.szLogicClass] 
			if tbBattleSetting and tbBattleSetting.nQualifyMinRank and  not (not tbBattleSetting.bZone and  tbBattleInfo.bZone) then --低阶战场是不会获取资格的
				if tbBattleInfo.nRank <= tbBattleSetting.nQualifyMinRank then
					--如果是刚获得下次资格赛资格时有各种提示，后面如果是有更高级比赛时才会出对应提示	

					local szQualifyBattleLogic = tbBattleSetting.szQualifyBattleLogic
					local tbQUalifySetting = self.tbAllBattleSetting[szQualifyBattleLogic]
					if tbQUalifySetting and GetTimeFrameState(tbQUalifySetting.OpenTimeFrame) == 1 and tbQUalifySetting.ChechConditionFunc then
						local bNowCanInNext = self[tbQUalifySetting.ChechConditionFunc](self,pPlayer, true)

						local nNextMothBattleOpenTime = self[tbQUalifySetting.fnGetQualifyMatchTime](self, true)
						pPlayer.SetUserValue(self.SAVE_GROUP, tbQUalifySetting.nKeyQualifyTime, nNextMothBattleOpenTime)
						if not bNowCanInNext then
							--原来没有，现在有，则出各种提示, 月度资格称号是一直到下次月度赛开始前的
							pPlayer.Msg(tbQUalifySetting.szQUalifyNotifyMsg)

							Mail:SendSystemMail({
								To 			= dwRoleId, 
								Text        = tbQUalifySetting.szQUalifyNotifyMsg,
								tbAttach 	= { {"AddTimeTitle", tbQUalifySetting.nQualifyTitleId, nNextMothBattleOpenTime} };
								nLogReazon 	= Env.LogWay_GetBattleQualify;
								tbParams 	= {LogReason2 = tbQUalifySetting.szQualifyType};
								})

							local szNotifyMsg = string.format("恭喜俠士「%s」參加%s進入前%d名，成功獲得武林角逐賽%s資格。", pPlayer.szName, tbBattleSetting.szName, tbBattleSetting.nQualifyMinRank, tbQUalifySetting.szName)
							ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Friend, szNotifyMsg, dwRoleId);
							if pPlayer.dwKinId ~= 0 then
								ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szNotifyMsg, pPlayer.dwKinId)
							end
						end	
					end
				end
			end
			if tbBattleSetting.nKeyQualifyTime then
				pPlayer.SetUserValue(self.SAVE_GROUP, tbBattleSetting.nKeyQualifyTime, 0) --现在去打今晚的就是获得下个月的了，如果已有资格的玩家必然是先进资格赛的
				Log("BattleMonth Played", tbBattleInfo.szLogicClass, dwRoleId)
			end
		end
	end

	Mail:SendSystemMail(
	{
		To 	  		= dwRoleId,
		Title 		= "戰場獎勵",
		Text        = szMsg,
		tbAttach 	= tbAward,
		nLogReazon = Env.LogWay_Battle,
	})

	if tbBattleInfo then
		local tbBattleSetting = Battle.tbAllBattleSetting[tbBattleInfo.szLogicClass] 
		if tbBattleSetting and tbBattleSetting.nCalendarType then
			Calendar:OnCompleteAct(dwRoleId, "Battle", tbBattleInfo.nRank, tbBattleSetting.nCalendarType)
		end
	end
end

function Battle:OnGetBattleFirstEnven(dwRoleId, szLogicClass, nReadyMapIndex)
	local tbBattleSetting = Battle.tbAllBattleSetting[szLogicClass]
	local pRole = KPlayer.GetRoleStayInfo(dwRoleId)
	if pRole and tbBattleSetting then
		local dwKinId = pRole.dwKinId
		if dwKinId ~= 0 then
			local tbKin = Kin:GetKinById(dwKinId)
			if tbKin then
				ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, string.format("恭喜本幫派的「%s」獲得了%s第一名！", pRole.szName, tbBattleSetting.szName), dwKinId);
				tbKin:InsertBattleKingName(pRole.szName);
			end
		end
		if tbBattleSetting.bZone then
			local tbZoneLevelSetting = Battle.tbHighZoneLevelSetting[nReadyMapIndex]
			if tbZoneLevelSetting then
				if tbZoneLevelSetting.nLevelEnd >= GetMaxLevel() then
					KPlayer.SendWorldNotify(1, 150,  string.format("恭喜「%s」勇奪%s第一名！", pRole.szName, tbBattleSetting.szName), 1, 1)
				end
			end
		end

		local nRedBagType = Kin.tbRedBagBattleTypes[tbBattleSetting.szLogicClass]
		if nRedBagType then
			local pPlayer = KPlayer.GetPlayerObjById(dwRoleId)
			if pPlayer then
				Kin:RedBagOnEvent(pPlayer, nRedBagType, 1)
			else
				Log("[x] Battle:OnGetBattleFirstEnven, redbag offline", dwRoleId, nRedBagType)
			end
		end
	end
end


--战场地图销毁时
function Battle:OnBattleMapDestory(nMapId)
	tbInGamePlayers[nMapId] = nil
	if tbMapInst[nMapId] then
		tbMapInst[nMapId]:OnMapDestroy();
		tbMapInst[nMapId] = nil
	end
end


function Battle:RequireAloneBattle(pPlayer)
	local tbSetting = self.tbAllBattleSetting.BattleAlone;
	pPlayer.EnterClientMap(tbSetting.nMapTemplateId,  unpack(Battle:GetRandInitPos(1, tbSetting)) )
	pPlayer.CallClientScript("Battle:BeginClinetBattle")
	-- LogD(Env.LOGD_ActivityPlay, pPlayer.szAccount, pPlayer.dwID, pPlayer.nLevel, nil, Env.LOGD_VAL_TAKE_TASK, Env.LOGD_MIS_BATTLE, pPlayer.GetFightPower());
end

function Battle:OnFinishTask(nTaskId)
	if nTaskId ~= self.JOIN_TASK then
		return;
	end

	self:RequireAloneBattle(me);
end

function Battle:LeaveAloneBattle(pPlayer)
	if pPlayer.nState ~= Player.emPLAYER_STATE_ALONE then
		return
	end
	pPlayer.LeaveClientMap();
end

function Battle:StopBattleCalender()
	Calendar:OnActivityEnd("Battle")
	if self.tbCurBattleSetting then
		Calendar:OnActivityEnd(self.tbCurBattleSetting.szLogicClass)
	end
	if self.tbNowOpenZoneSetting then
        for nSettingIndex, _ in pairs(self.tbNowOpenZoneSetting) do
            local tbBattleSetting = self.tbMapSetting[nSettingIndex]    
            Calendar:OnActivityEnd(tbBattleSetting.szLogicClass) 
        end        
    end
end

function Battle:OnCreateChatRoom(dwTeamID, uRoomHighId, uRoomLowId) 
	--只有6v6用了语音房间
	local tbMembers = TeamMgr:GetMembers(dwTeamID)
	local nMemberId = tbMembers[1]
	if not nMemberId then
		return
	end
	local pMember = KPlayer.GetPlayerObjById(nMemberId)
	if not pMember then
		return
	end
	local tbInst = self.tbMapInst[pMember.nMapId]
	if not tbInst then
		return
	end
	local tbTeamIdToSide = tbInst.tbTeamIdToSide
	if not tbTeamIdToSide then
		return
	end
	local nSide = tbTeamIdToSide[dwTeamID]
	if not nSide then
		return
	end

	if not tbInst.tbPlayerInfos then
		return
	end

	for k,v in pairs(tbInst.tbPlayerInfos) do
		if v.nTeamIndex == nSide then
			local pMember = KPlayer.GetPlayerObjById(k)
			if pMember then
				ChatMgr:JoinChatRoom(pMember, 1) 
			end	
		end
	end
	return true
	
end


Battle.tbC2SRequest = {
	["RequestCampMapInfo"] = function ( pPlayer )
		local tbInst = tbMapInst[pPlayer.nMapId]
		if tbInst and tbInst.RequestCampMapInfo then
			tbInst:RequestCampMapInfo(pPlayer)
		end
	end;
	["RequestTeamInfo"] =  function (pPlayer)
		local tbInst = tbMapInst[pPlayer.nMapId]
		if tbInst and tbInst.RequestTeamInfo then
			tbInst:RequestTeamInfo(pPlayer)
		end
	end;
}


---初始化
function Battle:Init()
	self:SetupMapCallback()
end

function Battle:SetupMapCallback()
	local fnOnCreate = function (tbMap, nMapId)
		self:OnBattleMapCreate(nMapId)
	end

	local fnOnDestory = function (tbMap, nMapId)
		self:OnBattleMapDestory(nMapId)
	end

	local fnOnEnter = function (tbMap, nMapId)
		local tbInst = tbMapInst[nMapId]
		if tbInst then
			tbInst:OnEnter()
		end
	end

	local fnOnLeave = function (tbMap, nMapId)
		local tbInst = tbMapInst[nMapId]
		if tbInst then
			tbInst:OnLeave()
		end
	end

	local fnOnPlayerTrap = function (tbMap, nMapId, szTrapName)
		local tbInst = tbMapInst[nMapId]
		if tbInst then
			tbInst:OnPlayerTrap(szTrapName)
		end
	end

	local fnOnMapLogin = function (tbMap, nMapId)
		local tbInst = tbMapInst[nMapId]
		if tbInst then
			tbInst:OnLogin()
		end
	end

	for _, v in ipairs(self.tbMapSetting) do
		local tbMapClass = Map:GetClass(v.nMapTemplateId)
		tbMapClass.OnCreate = fnOnCreate;
		tbMapClass.OnDestroy = fnOnDestory;
		tbMapClass.OnEnter = fnOnEnter;
		tbMapClass.OnLeave = fnOnLeave;
		tbMapClass.OnPlayerTrap = fnOnPlayerTrap;
		tbMapClass.OnLogin = fnOnMapLogin;
	end

	local tbReadyMaps = {Battle.READY_MAP_ID,  Battle.ZONE_READY_MAP_ID}
	local fnOnReadyMapCreate = function (tbMap, nMapId)
		Battle:OnReadyMapCreate(nMapId)
	end

	local fnOnEnterReadyMap = function (tbMap, nMapId)
		Battle:OnEnterReadyMap(nMapId)
	end

	local fnOnLeaveReadyMap = function (tbMap, nMapId)
		Battle:OnLeaveReadyMap(nMapId)
	end

	local fnOnLogiReadyMap = function (tbMap, nMapId)
		Battle:OnLoginReadyMap(nMapId)
	end

	for i, nReadyMapID in ipairs(tbReadyMaps) do
		local tbReadyMap = Map:GetClass(nReadyMapID);
		tbReadyMap.OnCreate = fnOnReadyMapCreate;
		tbReadyMap.OnEnter = fnOnEnterReadyMap
		tbReadyMap.OnLeave = fnOnLeaveReadyMap
		tbReadyMap.OnLogin = fnOnLogiReadyMap;
	end

end

Battle:Init();

