
function RankBattle:Init()
	self.tbPlayerRank = self.tbPlayerRank or {};
	self.tbPlayerOutRank = self.tbPlayerOutRank or {};
	self.tbEnemy = self.tbEnemy or {};
	self.tbAttrib = {}
	self.tbLockNo = self.tbLockNo or {};

	self.tbRoomSetting = LoadTabFile("Setting/RankBattle/RankRoom.tab", "ddddd", "RankRoom", {"RankRoom", "BeginNo", "EndNo", "NpcTeam", "Award"});
	self.nMaxRoom = #self.tbRoomSetting;

	self.tbNpcSetting = LoadTabFile("Setting/RankBattle/RankBattleNpcTeam.tab", "dssddddddddddddddddddd", "TeamID", {
		"TeamID", "Name", "HeroName", "Faction", "Level", "ExtAttribId", "HonorLevel",
		"PartnerId1", "PartnerId2", "PartnerId3", "PartnerId4", "PartnerLevel",
		"Strength", "Vitality", "Dexterity", "Energy", "SkillLevel", "SkillID1","SkillID2","SkillID3","SkillID4","SkillID5",});

	local tbAttribFile = LoadTabFile("Setting/RankBattle/RankNpcAttrib.tab", "dsddd", nil, {"AttribId", "AttribType", "Value1", "Value2", "Value3"});

	if not self.tbRank then
		self.tbRank = {}
		for nRoomId, tbInfo in ipairs(self.tbRoomSetting) do
			for nRankNo = tbInfo.BeginNo, tbInfo.EndNo do
				self.tbRank[nRankNo] =
				{
					nPlayerId = nil,
					nRankNo = nRankNo,
					nLevel = nil,
					nFaction = nil,
					nRankRoom = nRoomId,
					nAward = tbInfo.Award,
				}
			end
		end
	end


	for _, tbInfo in ipairs(tbAttribFile) do
		self.tbAttrib[tbInfo.AttribId] = self.tbAttrib[tbInfo.AttribId] or {}

		table.insert(self.tbAttrib[tbInfo.AttribId],
		{
			szAttribType = tbInfo.AttribType,
			tbValue =
			{
				tbInfo.Value1,
				tbInfo.Value2,
				tbInfo.Value3,
			},
		})
	end
end

RankBattle:Init()


function RankBattle:OnLoad(nPlayerId, nRankNo, nLevel, nFaction)
	if nRankNo == RankBattle.DEF_NO then
		self.tbPlayerOutRank[nPlayerId] = 1;
		return;
	end
	if not self.tbRank[nRankNo] then
		Log("Error!! Rank No is not under contorl!!", nRankNo)
		return;
	end
	if self.tbRank[nRankNo].nPlayerId then
		Log("Error!! Rank No Conflict!!", nRankNo, self.tbRank[nRankNo].nPlayerId, nPlayerId)
		return;
	end

	if self.tbPlayerRank[nPlayerId] then
		Log("Error!! Player Id Conflict!!", self.tbPlayerRank[nPlayerId].nRankNo, nRankNo);
		return;
	end

	self.tbRank[nRankNo].nPlayerId = nPlayerId;
	self.tbRank[nRankNo].nLevel = nLevel;
	self.tbRank[nRankNo].nFaction = nFaction;

	self.tbPlayerRank[nPlayerId] = self.tbRank[nRankNo];

	-- if nRankNo == 1 then
	-- 	Map:UpdateStatue(self.STATUE_ID, nPlayerId, "竞技场第一");
	-- end
end

function RankBattle:SetRankNo(nPlayerId, nRankNo, bNotify)
	local tbStayInfo = KPlayer.GetRoleStayInfo(nPlayerId)
	assert(tbStayInfo);
	assert(self.tbRank[nRankNo]);

	local tbOldRankNo;
	if self.tbPlayerRank[nPlayerId] then
		tbOldRankNo = self.tbPlayerRank[nPlayerId];
		tbOldRankNo.nPlayerId = nil;
	end

	local nLostPlayer = self.tbRank[nRankNo].nPlayerId
	if nLostPlayer then
		self.tbPlayerRank[nLostPlayer] = tbOldRankNo
		local nLostNewNo;
		if tbOldRankNo then
			tbOldRankNo.nPlayerId 	= self.tbRank[nRankNo].nPlayerId;
			tbOldRankNo.nLevel 		= self.tbRank[nRankNo].nLevel;
			tbOldRankNo.nFaction 	= self.tbRank[nRankNo].nFaction;
			UpdateBattleRankInfo(nLostPlayer, tbOldRankNo.nRankNo, 0);
			self.tbEnemy[nLostPlayer] = nil;		-- 清空对方的敌人列表
			nLostNewNo = tbOldRankNo.nRankNo;
		else
			UpdateBattleRankInfo(nLostPlayer, RankBattle.DEF_NO, 0);
			self.tbPlayerOutRank[nLostPlayer] = 1;
			self.tbEnemy[nLostPlayer] = nil;		-- 清空对方的敌人列表
			nLostNewNo = RankBattle.DEF_NO;
		end

		if bNotify then
			Player:SendNotifyMsg(nLostPlayer, {
				szType = "RankBattle",
				nTimeOut = GetTime() + 86400 * 15,
				szName = tbStayInfo.szName,
				nOrgNo = nRankNo,
				nNewNo = nLostNewNo;
			})
		end
	end

	self.tbRank[nRankNo].nPlayerId 	= nPlayerId;
	self.tbRank[nRankNo].nLevel 	= tbStayInfo.nLevel;
	self.tbRank[nRankNo].nFaction 	= tbStayInfo.nFaction;
	self.tbPlayerRank[nPlayerId] = self.tbRank[nRankNo];

	UpdateBattleRankInfo(nPlayerId, nRankNo, 1);
	self.tbEnemy[nPlayerId] = nil;
	self.tbPlayerOutRank[nPlayerId] = nil;

	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	if pPlayer then
		RankBattle:SyncRankEnemy(pPlayer, nil, 1)
	end

	if nRankNo <= 1 then
		Achievement:AddCount(pPlayer, "RankBattle_5", 1);
	elseif nRankNo <= 10 then
		Achievement:AddCount(pPlayer, "RankBattle_4", 1);
	elseif nRankNo <= 100 then
		Achievement:AddCount(pPlayer, "RankBattle_3", 1);
	elseif nRankNo <= 1000 then
		Achievement:AddCount(pPlayer, "RankBattle_2", 1);
	end

	if nRankNo == 1 and pPlayer then
		pPlayer.CallClientScript("GameSetting.Comment:OnEvent", GameSetting.Comment.Type_RankBattle_First);
	end

	Kin:RedBagOnEvent(pPlayer, Kin.tbRedBagEvents.wsd_rank, nRankNo)
	if nRankNo<=1500 then
		TeacherStudent:TargetAddCount(pPlayer, "WuShenDian1500", 1)
	end
	if nRankNo<=500 then
		TeacherStudent:TargetAddCount(pPlayer, "WuShenDian500", 1)
	end
end

function RankBattle:SyncRankTen(pPlayer)
	local tbTen = {}
	local nPlayerId = pPlayer.dwID;
	for i = 1, 10 do
		local tbInfo = self:GetRankInfo(i);
		--if tbInfo.nFightType == self.FIGHT_TYPE_PLAYER then
			table.insert(tbTen, tbInfo);
		--end
	end
	local nAward = 0;
	if self.tbPlayerRank[nPlayerId] then
		nAward = self.tbPlayerRank[nPlayerId].nAward
	elseif self.tbPlayerOutRank[nPlayerId] then
		nAward = self.DEF_TIMER_AWARD;
	end
	pPlayer.CallClientScript("RankBattle:UpdateTenPlayer", tbTen, self:GetSelfInfo(nPlayerId), nAward)
end

function RankBattle:SyncRankEnemy(pPlayer, nVersion, bRefresh)
	local nPlayerId = pPlayer.dwID;
	local nRoom = self.nMaxRoom + 1
	local tbRankInfo = self.tbPlayerRank[nPlayerId];
	local nCurTime = GetTime();
	if tbRankInfo then
		nRoom = tbRankInfo.nRankRoom;
	end

	RankBattle:SyncRankTen(pPlayer);

	if not bRefresh and self.tbEnemy[nPlayerId] then
		if nVersion == self.tbEnemy[nPlayerId].nFrashEnemyCD then
			return;
		end
		pPlayer.CallClientScript("RankBattle:UpdateEnemy", self.tbEnemy[nPlayerId].tbInfo, self.tbEnemy[nPlayerId].nFrashEnemyCD)
		return;
	end

	if bRefresh and self.tbEnemy[nPlayerId] and self.tbEnemy[nPlayerId].nFrashEnemyCD >= nCurTime then
		pPlayer.CenterMsg("您刷新對手過快，請稍後再試")
		return
	end

	self.tbEnemy[nPlayerId] =
	{
		tbInfo = {},
		nFrashEnemyCD = nCurTime + self.FRESH_CD_TIME,
	}

	print("RankBattle:SyncRankEnemy", nVersion)

	for i = nRoom - 1, math.max(1, nRoom - 5), -1 do
		local tbRoom = self.tbRoomSetting[i]
		if tbRoom then
			local nRandom = MathRandom(tbRoom.BeginNo, tbRoom.EndNo);

			local tbEnemy = self:GetRankInfo(nRandom);

			table.insert(self.tbEnemy[nPlayerId].tbInfo, tbEnemy);
		end
	end

	pPlayer.CallClientScript("RankBattle:UpdateEnemy", self.tbEnemy[nPlayerId].tbInfo, self.tbEnemy[nPlayerId].nFrashEnemyCD)
end

function RankBattle:RefreshEnemy(pPlayer)
--	local nCoin = pPlayer.GetMoney("Gold");
--    if nCoin < self.REFRESH_GOLD then
--		return;
--    end
--    pPlayer.CostMoney("Gold", self.REFRESH_GOLD);
	self:SyncRankEnemy(pPlayer, 0, true)

	--pPlayer.CallClientScript("RankBattle:Update")
end


function RankBattle:GetRankInfo(nRankNo)
	local tbEnemy;

	if self.tbRank[nRankNo].nPlayerId then
		local tbStayInfo = KPlayer.GetRoleStayInfo(self.tbRank[nRankNo].nPlayerId)
		local pAsyncData = KPlayer.GetRankAsyncData(self.tbRank[nRankNo].nPlayerId)
		if tbStayInfo and pAsyncData then
			local tbPartner = {}
			for i = 1, 4 do
				local nPartnerId, nLevel, nFightPower = pAsyncData.GetPartnerInfo(i);		--- partner ERR ??
				if nPartnerId and nPartnerId > 0 then
					table.insert(tbPartner, { nPartnerId, nGrowthLevel })
				end
			end
			tbEnemy =
			{
				nId = tbStayInfo.dwID,
				szName 	= tbStayInfo.szName,
				nLevel 	= self.tbRank[nRankNo].nLevel,
				nFaction = self.tbRank[nRankNo].nFaction,
				nPortrait = tbStayInfo.nPortrait,
				nFightType = self.FIGHT_TYPE_PLAYER,
				nRankNo = nRankNo,
				tbPartner = tbPartner,
				nHonorLevel = tbStayInfo.nHonorLevel
			}
		end
	end
	local tbRoom = self.tbRoomSetting[self.tbRank[nRankNo].nRankRoom]
	if not tbEnemy and tbRoom.NpcTeam and self.tbNpcSetting[tbRoom.NpcTeam] then
		local tbNpcTeam = self.tbNpcSetting[tbRoom.NpcTeam];
		local tbPartner = {}
		for i = 1, 4 do
			if tbNpcTeam["PartnerId"..i] and tbNpcTeam["PartnerId"..i] > 0 then
				table.insert(tbPartner, { tbNpcTeam["PartnerId"..i], tbNpcTeam.GrowthLevel })
			end
		end

		tbEnemy =
			{
				nId 	= tbNpcTeam.TeamID,
				szName 	= tbNpcTeam.Name,
				nLevel 	= tbNpcTeam.Level,
				nFaction = tbNpcTeam.Faction,
				nFightType = self.FIGHT_TYPE_NPC,
				nRankNo = nRankNo,
				nHonorLevel = tbNpcTeam.HonorLevel,
				tbPartner = tbPartner,
			}
	end

	return tbEnemy;
end

function RankBattle:GetSelfInfo(nPlayerId)
	if self.tbPlayerRank[nPlayerId] then
		return self:GetRankInfo(self.tbPlayerRank[nPlayerId].nRankNo);
	end

	local tbStayInfo = KPlayer.GetRoleStayInfo(nPlayerId)
	local tbKin = Kin:GetKinById(nKinId);
	return {
		nId = tbStayInfo.dwID,
		szName = tbStayInfo.szName,
		nLevel = tbStayInfo.nLevel,
		nFaction = tbStayInfo.nFaction,
		nPortrait = tbStayInfo.nPortrait,
		nFightType = self.FIGHT_TYPE_PLAYER,
		nRankNo = RankBattle.DEF_NO,
		nHonorLevel = tbStayInfo.nHonorLevel,
	}
end


function RankBattle:StartBattle(pPlayer, nFightType, nRankNo, nId)
	local nCurTime = GetTime();
	local nPlayerId = pPlayer.dwID;
	local tbMyRankInfo = self.tbPlayerRank[nPlayerId]
	if not self.tbEnemy[nPlayerId] then
		pPlayer.CenterMsg("您的名次已經發生了變化，重新為您更新挑戰列表");
		self:SyncRankEnemy(pPlayer, 0)
		return;
	end

	if pPlayer.nLevel < 12 then
		pPlayer.CenterMsg("武神殿12級開放");
		return;
	end

	if not AsyncBattle:CanStartAsyncBattle(pPlayer) then
		pPlayer.CenterMsg("目前地圖無法挑戰，請先返回[FFFE0D]「襄陽城」[-]再嘗試")
		return;
	end

	if pPlayer.dwTeamID > 0 then
		pPlayer.MsgBox("組隊狀態無法進行挑戰，是否退出目前隊伍？",
			{
				{"退出隊伍", TeamMgr.QuiteTeam, TeamMgr, pPlayer.dwTeamID, pPlayer.dwID},
				{"取消"},
			})
		return;
	end

	-- 次数处理
	if DegreeCtrl:GetDegree(pPlayer, "RankBattle") <= 0 then
		pPlayer.CenterMsg("您的挑戰次數不足")
		return;
	end

	local pPlayerNpc = pPlayer.GetNpc();
    local nResult = pPlayerNpc.CanChangeDoing(Npc.Doing.skill);
    if nResult == 0 then
    	pPlayer.CenterMsg("目前狀態不能參加");
        return;
    end

	local tbEnemy

	for nIdx, tbData in ipairs(self.tbEnemy[nPlayerId].tbInfo) do
		if tbData.nRankNo == nRankNo then
			tbEnemy = tbData;
			break;
		end
	end

	if not tbEnemy and tbMyRankInfo and tbMyRankInfo.nRankNo <= self.NO_LIMIT_RANK and
		nRankNo <= self.NO_LIMIT_RANK and tbMyRankInfo.nRankNo ~= nRankNo then
		tbEnemy = self:GetRankInfo(nRankNo)
	end

	if tbEnemy then
		if tbEnemy.nFightType ~= nFightType or (nFightType == self.FIGHT_TYPE_NPC and self.tbRank[nRankNo].nPlayerId) or
			(nFightType == self.FIGHT_TYPE_PLAYER and (self.tbRank[nRankNo].nPlayerId ~= nId or tbEnemy.nId ~= nId)) then
			-- 该名次已经易主
			pPlayer.CenterMsg("您要挑戰的玩家名次發生了變化")
			self:SyncRankEnemy(pPlayer, nil, 1);
			return;
		end

		if self.tbLockNo[nRankNo] then
			if self.tbLockNo[nRankNo].nTimeOut > nCurTime then	-- 木有超时
				pPlayer.CenterMsg("對方正在進行挑戰，請稍後再試")
				return;
			else
				self:UnLockRankNo(nRankNo)
			end
		end

		if tbMyRankInfo and self.tbLockNo[tbMyRankInfo.nRankNo] then
			if self.tbLockNo[tbMyRankInfo.nRankNo].nTimeOut > nCurTime then	-- 木有超时
				pPlayer.CenterMsg("您正在被其他玩家挑戰，請稍後再試")
				return;
			else
				self:UnLockRankNo(tbMyRankInfo.nRankNo)
			end
		end

		if not DegreeCtrl:ReduceDegree(pPlayer, "RankBattle", 1) then
			return;
		end

		--pPlayer.AddMoney(self.BATTLE_AWARD_TYPE, self.LOST_AWARD, Env.LogWay_RankBattle_BASE_AWARD);
		local nExp = self.LOST_AWARD * pPlayer.GetBaseAwardExp();
		pPlayer.AddExperience(nExp, Env.LogWay_RankBattle_BASE_AWARD);

		LogD(Env.LOGD_ActivityPlay, pPlayer.szAccount, pPlayer.dwID, pPlayer.nLevel, nil, Env.LOGD_VAL_TAKE_TASK, Env.LOGD_MIS_RANKBATTLE, pPlayer.GetFightPower());

		if nFightType == self.FIGHT_TYPE_NPC then
			if self:CreateNpcBattle(pPlayer, tbEnemy.nId, nRankNo) then
				self:LockRankNo(nRankNo, tbMyRankInfo and tbMyRankInfo.nRankNo)
			end
		else
			if self:CreatePlayerBattle(pPlayer, tbEnemy.nId, nRankNo) then
				self:LockRankNo(nRankNo, tbMyRankInfo and tbMyRankInfo.nRankNo)
			end
		end

		EverydayTarget:AddCount(pPlayer, "Rank")

		AssistClient:ReportQQScore(pPlayer, Env.QQReport_IsJoinRankBattle, 1, 0, 1)
		return;
	else
		pPlayer.CenterMsg("您的名次發生了變化");
		self:SyncRankEnemy(pPlayer, nil, 1);
	end


	--self:SyncRankEnemy(pPlayer, 0)
end

function RankBattle:LockRankNo(nRankNo1, nRankNo2)
	if self.tbLockNo[nRankNo1] or self.tbLockNo[nRankNo2] then
		return false
	end

	local tbLock = { nTimeOut = GetTime() + self.BATTLE_TIME_OUT, tbRankNo = {} }
	if nRankNo1 then
		table.insert(tbLock.tbRankNo, nRankNo1)
		self.tbLockNo[nRankNo1] = tbLock;
	end
	if nRankNo2 then
		table.insert(tbLock.tbRankNo, nRankNo2)
		self.tbLockNo[nRankNo2] = tbLock
	end

	return true;
end

function RankBattle:UnLockRankNo(nRankNo)
	if not self.tbLockNo[nRankNo] then
		return;
	end

	local tbCurLock = self.tbLockNo[nRankNo];

	-- 解锁相关的名次
	for _, nRankNoInLock in ipairs(self.tbLockNo[nRankNo].tbRankNo) do
		if self.tbLockNo[nRankNoInLock] and self.tbLockNo[nRankNoInLock] == tbCurLock then
			self.tbLockNo[nRankNoInLock] = nil;
		end
	end
end


function RankBattle:CheckLastBattle(pPlayer)

end

function RankBattle:CreateNpcBattle(pPlayer, nNpcTeam, nRankNo)
	if not self.tbNpcSetting[nNpcTeam] then
		Log("CreateNpcBattle Failed!! Npc Team is unexist!! "..tostring(nNpcTeam))
		return;
	end

	local nBattleKey = GetTime();

	if not AsyncBattle:CreateAsyncBattle(pPlayer, self.FIGHT_MAP, self.ENTER_POINT, "RankBattlePve", nNpcTeam, nBattleKey, {nNpcTeam, nRankNo, nBattleKey}) then
		Log("Error!! Enter RankBattlePve Map Failed!")
		return;
	end

	return true;
end

function RankBattle:CreatePlayerBattle(pPlayer, nEnemyId, nRankNo)
	Log("CreatePlayerBattle", pPlayer, nEnemyId, nRankNo)

	local nBattleKey = GetTime();

	if not AsyncBattle:CreateAsyncBattle(pPlayer, self.FIGHT_MAP, self.ENTER_POINT, "RankBattlePvp", nEnemyId, nBattleKey, {nEnemyId, nRankNo, nBattleKey}) then
		Log("Error!! Enter RankBattlePvp Map Failed!")
		return;
	end

	return true
end

function RankBattle:OnRankBattleResult(pPlayer, nResult, tbBattleObj, nEnemyId, nRankNo, nBeginTime)
	if nResult == 1 then
		if Forbid:IsBanning(pPlayer,Forbid.BanType.WuShenRank) then
			local nEndTime = Forbid:BanEndTime(pPlayer,Forbid.BanType.WuShenRank)
	        local szTime = Lib:GetTimeStr3(nEndTime)
	        pPlayer.MsgBox(string.format("您由於%s被禁止上榜，解禁時間%s",Forbid:BanTips(pPlayer,Forbid.BanType.WuShenRank), szTime or ""), {{"確定"}, {"取消"}})
		end
		local nPlayerId = pPlayer.dwID;
		if (not self.tbPlayerRank[nPlayerId] or self.tbPlayerRank[nPlayerId].nRankNo > nRankNo) and not Forbid:IsBanning(pPlayer,Forbid.BanType.WuShenRank) then
			self:SetRankNo(nPlayerId, nRankNo, true)
			local nBestRank = self:GetBestRank(pPlayer)
			if nBestRank == 0 or nBestRank > nRankNo then
				self:SetBestRank(pPlayer,nRankNo)
			end
		end

		-- pPlayer.AddMoney(self.BATTLE_AWARD_TYPE, self.WIN_AWARD - self.LOST_AWARD, Env.LogWay_RankBattle_WIN_AWARD);

		local nExp = (self.WIN_AWARD - self.LOST_AWARD) * pPlayer.GetBaseAwardExp();
		pPlayer.AddExperience(nExp, Env.LogWay_RankBattle_WIN_AWARD);

		self:UnLockRankNo(nRankNo);

		pPlayer.CenterMsg(string.format("獲得[FFFE0D] %d [-]點經驗", pPlayer.TrueChangeExp(RankBattle.WIN_AWARD * pPlayer.GetBaseAwardExp())))
	else
		self:UnLockRankNo(nRankNo);

		pPlayer.CenterMsg(string.format("獲得[FFFE0D] %d [-]點經驗", pPlayer.TrueChangeExp(RankBattle.LOST_AWARD* pPlayer.GetBaseAwardExp())))
	end

	-- LogD(Env.LOGD_ActivityPlay, pPlayer.szAccount, pPlayer.dwID, pPlayer.nLevel, nil, Env.LOGD_VAL_FINISH_TASK, Env.LOGD_MIS_RANKBATTLE, pPlayer.GetFightPower());
	pPlayer.TLogRoundFlow(Env.LogWay_RankBattle, nEnemyId, 0, GetTime() - nBeginTime, nResult == 1 and Env.LogRound_SUCCESS or Env.LogRound_FAIL, 0, 0)

	Achievement:AddCount(pPlayer, "RankBattle_1", 1);
end
AsyncBattle:ResgiterBattleType("RankBattlePve", RankBattle, RankBattle.OnRankBattleResult, nil, RankBattle.FIGHT_MAP)
AsyncBattle:ResgiterBattleType("RankBattlePvp", RankBattle, RankBattle.OnRankBattleResult, nil, RankBattle.FIGHT_MAP)

function RankBattle:Award()
	for nPlayerId, tbInfo in pairs(self.tbPlayerRank) do
		self:AddTimerAward(nPlayerId, tbInfo.nAward, tbInfo.nRankNo)
	end

	for nPlayerId, _ in pairs(self.tbPlayerOutRank) do
		self:AddTimerAward(nPlayerId, self.DEF_TIMER_AWARD, self.DEF_NO)
	end
end

function RankBattle:GetPlayerAwardInfo(pAsyncData)
	local nAwardValue = pAsyncData.GetAsyncValue(self.AWARD_ASYNC_VALUE);
	local nGoldBoxNum = nAwardValue % 100
	local nSlvBoxNum = math.floor(nAwardValue / 100) % 100;
	local nResValue = math.floor(nAwardValue / 10000)
	return nResValue, nSlvBoxNum, nGoldBoxNum;
end

function RankBattle:SetPlayerAwardInfo(pAsyncData, nResValue, nSlvBoxNum, nGoldBoxNum)
	if nResValue > 100000 or nSlvBoxNum >= 100 or nGoldBoxNum >= 100 then
		return false;
	end
	local nAwardValue = nResValue * 10000 + nSlvBoxNum * 100 + nGoldBoxNum
	pAsyncData.SetAsyncValue(self.AWARD_ASYNC_VALUE, nAwardValue);
	return true;
end

function RankBattle:AddTimerAward(nPlayerId, nAward, nRankNo)
	local pAsyncData = KPlayer.GetAsyncData(nPlayerId)
	if pAsyncData then		-- 异步数据存在就加，不在就不加了
		local nResValue, nSlvBoxNum, nGoldBoxNum = self:GetPlayerAwardInfo(pAsyncData)
		nResValue = nResValue + nAward

		local nNewSlv, nNewGold = 0, 0
		if nRankNo <= self.GOLD_BOX_REQUIRE_NO then
			nNewGold = math.floor(nResValue / self.GOLD_BOX_VALUE);
			nResValue = nResValue - nNewGold * self.GOLD_BOX_VALUE;
			nNewSlv = math.floor(nResValue / self.SLV_BOX_VALUE);
			nResValue = nResValue - nNewSlv * self.SLV_BOX_VALUE;
		else
			nNewSlv = math.floor(nResValue / self.SLV_BOX_VALUE);
			nResValue = nResValue - nNewSlv * self.SLV_BOX_VALUE;
		end

		if nGoldBoxNum * 2.1 + nSlvBoxNum < nNewGold * 2.1 + nNewSlv then
			nGoldBoxNum = nNewGold;
			nSlvBoxNum = nNewSlv;
		end

		self:SetPlayerAwardInfo(pAsyncData, nResValue, nSlvBoxNum, nGoldBoxNum);

		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
		if pPlayer then
			pPlayer.CallClientScript("RankBattle:UpdateAward", nResValue, nSlvBoxNum + nGoldBoxNum);
		end
	end
end

function RankBattle:UpdateLoginAward(pPlayer, pAsyncData)
	local nResValue, nSlvBoxNum, nGoldBoxNum = self:GetPlayerAwardInfo(pAsyncData)
	pPlayer.CallClientScript("RankBattle:UpdateAward", nResValue, nSlvBoxNum + nGoldBoxNum);
end

function RankBattle:GetAwardItem()
	local nGoldBox, nSlvBox;
	for _, tbInfo in ipairs(self.AWARD_ITEM) do
		local szTimeFrime, nItem1, nItem2 = unpack(tbInfo)
		if GetTimeFrameState(szTimeFrime) == 1 then
			nGoldBox, nSlvBox = nItem1, nItem2;
		else
			break;
		end
	end
	return nGoldBox, nSlvBox;
end

function RankBattle:FetchRankBattleAward(pPlayer)
	local pAsyncData = KPlayer.GetAsyncData(pPlayer.dwID)
	if pAsyncData then		-- 异步数据存在就加，不在就不加了
		local nResValue, nSlvBoxNum, nGoldBoxNum = self:GetPlayerAwardInfo(pAsyncData)
		if nSlvBoxNum + nGoldBoxNum > 0 then
			if not self:SetPlayerAwardInfo(pAsyncData, nResValue, 0, 0) then
				Log("Player FetchRankBattleAward Failed!", pPlayer.szName)
				return;
			end
			local tbAwardItem = {}
			local nGoldBox, nSlvBox = self:GetAwardItem()
			if nSlvBoxNum > 0 then
				table.insert(tbAwardItem, {"item", nSlvBox, nSlvBoxNum});
			end
			if nGoldBoxNum > 0 then
				table.insert(tbAwardItem, {"item", nGoldBox, nGoldBoxNum});
			end
			local _, szMsg, tbFinalAward = RegressionPrivilege:GetDoubleAward(pPlayer, "RankBattle", tbAwardItem)
			pPlayer.SendAward(tbFinalAward, false, true, Env.LogWay_RankBattleAward_Rank)
			if szMsg then
				pPlayer.CenterMsg(szMsg, true)
			end
		else
			pPlayer.CenterMsg("您沒有可以領取的獎勵");
		end
		pPlayer.CallClientScript("RankBattle:UpdateAward", nResValue, 0);
	end
end

function RankBattle:GetFakePlayerSkillList(nFaction, nPlayerLevel)
	local tbResult = {};
	local tbSkillList = FightSkill.tbFactionSkillSetting[nFaction]
	for _, tbInfo in ipairs(tbSkillList) do
		local nSkillId = tbInfo.SkillId;
        if nSkillId > 0 and FightSkill.tbSkillLevelUp[nSkillId] then
        	local nMaxLevel = 0;
        	for nLevel, tbUpdateGradeInfo in ipairs(FightSkill.tbSkillLevelUp[nSkillId]) do
        		if tbUpdateGradeInfo[1] > nPlayerLevel then
        			break;
        		end
        		nMaxLevel = nLevel;
        	end

        	if nMaxLevel > 0 then
        		table.insert(tbResult, {nSkillId,  nMaxLevel});
        	end
        end
	end

	return tbResult;
end


function RankBattle:InitFakeAsyncData(nNpcTeamId)
	local tbFakeAsyncData = {}
	local tbSetting = self.tbNpcSetting[nNpcTeamId]
	if not tbSetting then
		Log("FakeAsyncData Init Failed!!!", nNpcTeamId);
		return ;
	end
	tbFakeAsyncData.AddAsyncNpc =
	function (nMapId, nX, nY)
		local szName, nFaction, nLevel, nAttribId = tbSetting.HeroName, tbSetting.Faction, tbSetting.Level, tbSetting.ExtAttribId;
		local pNpc = KPlayer.AddFakePlayer(tbSetting.Faction, tbSetting.Level, nMapId, nX, nY)
		if pNpc then
		    local tbSkillList = self:GetFakePlayerSkillList(nFaction, nLevel)
		    for _, tbInfo in ipairs(tbSkillList) do
		        local nSkillId, nLevel = unpack(tbInfo);
		        pNpc.AddFightSkill(nSkillId, nLevel)
		        pNpc.SetName(szName);
		    end

		    local tbAttribList = RankBattle.tbAttrib[nAttribId];
		    if tbAttribList then
		        for _, tbAttrib in pairs(tbAttribList) do
		            pNpc.ChangeAttribValue(tbAttrib.szAttribType, unpack(tbAttrib.tbValue))
		        end
		    end
		    pNpc.SetCurLife(pNpc.nMaxLife);
		end
		return pNpc;
	end;
	tbFakeAsyncData.AddPartnerNpc =
	function (nAddPos, nMapId, nX, nY)
		local nPartnerId = tbSetting["PartnerId"..nAddPos]
		if not nPartnerId or nPartnerId == 0 then
			return;
		end
		local pNpc = AddPartnerNpc(nPartnerId, tbSetting.PartnerLevel, nMapId, nX, nY,
				tbSetting.Strength, tbSetting.Vitality, tbSetting.Dexterity, tbSetting.Energy, tbSetting.SkillLevel,
				tbSetting.SkillID1, tbSetting.SkillID2, tbSetting.SkillID3, tbSetting.SkillID4, tbSetting.SkillID5)

		return pNpc;
	end;
	tbFakeAsyncData.GetPlayerInfo =
	function ()
		return tbSetting.HeroName, tbSetting.Faction, tbSetting.Level, tbSetting.Faction;
	end;
	tbFakeAsyncData.GetPartnerInfo =
	function (nPartnerIdx)
		local nPartnerId = tbSetting["PartnerId"..nPartnerIdx]
		return nPartnerId, tbSetting.PartnerLevel, 0
	end;
	tbFakeAsyncData.GetBattleArray =
	function (nIdx)
		local tbPartnerPos = {5,1,3,4,6};
		return tbPartnerPos[nIdx]
	end

	return tbFakeAsyncData;
end

function RankBattle:ClearPlayerRank(nPlayerId)
	local tbRankNo = RankBattle.tbPlayerRank[nPlayerId];
	if not tbRankNo then
		return
	end
	
	tbRankNo.nPlayerId = nil;
	tbRankNo.nLevel = nil;
	tbRankNo.nFaction = nil;
	self.tbPlayerRank[nPlayerId] = nil
	UpdateBattleRankInfo(nPlayerId, RankBattle.DEF_NO, 0);
	self.tbPlayerOutRank[nPlayerId] = 1;
	self.tbEnemy[nPlayerId] = nil
end

function RankBattle:GetBestRank(pPlayer)
	return pPlayer.GetUserValue(91, 1);
end

function RankBattle:SetBestRank(pPlayer,nBest)
	pPlayer.SetUserValue(91, 1, nBest);
end