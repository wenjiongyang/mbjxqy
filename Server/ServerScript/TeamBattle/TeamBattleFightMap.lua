Require("CommonScript/TeamBattle/TeamBattleDef.lua");

TeamBattle.tbFightMapClass = TeamBattle.tbFightMapClass or {};
local tbFightMap = TeamBattle.tbFightMapClass;

function tbFightMap:Init(nMapId, nFloor, tbMapInfo, tbTeamInfo, tbAllTeamInfo, nNextFightTimerId, fnSetResult, nType, nFightTimes, nMaxFightTimes)
	self.nType = nType or TeamBattle.TYPE_NORMAL;
	self.nMapId = nMapId;
	self.nFloor = nFloor;
	self.tbTeamInfo = tbTeamInfo;
	self.nNextFightTimerId = nNextFightTimerId;
	self.nFightTimes = nFightTimes;
	self.nMaxFightTimes = nMaxFightTimes
	self.tbMapInfo = {
		[1] = { nStartId = 1, tbRestPos = tbMapInfo[2][1], tbBeginFightPos = tbMapInfo[2][2], },
		[2] = { nStartId = 2, tbRestPos = tbMapInfo[3][1], tbBeginFightPos = tbMapInfo[3][2], },
	};

	self.tbTeamMemeberInfo = {};
	for i = 1, #tbTeamInfo do
		self.tbTeamMemeberInfo[i] = {nBattleTeamId = tbTeamInfo[i]};
		for _, nPlayerId in ipairs(tbAllTeamInfo[tbTeamInfo[i]]) do
			table.insert(self.tbTeamMemeberInfo[i], nPlayerId);
		end
	end

	self.tbQQReportKillCountInfo = {};
	self.tbQQReportKillCount2Info = {};
	self.tbQQReportDeathCountInfo = {};
	self.tbDmgInfo = {{nTotalDmg = 0, nKillCount = 0}, {nTotalDmg = 0, nKillCount = 0}};
	self.fnSetResult = fnSetResult;

	self.tbCurTeamId = {};
	for nTeamId, tbTeam in pairs(self.tbTeamMemeberInfo) do
		for _, nPlayerId in ipairs(tbTeam) do
			self.tbCurTeamId[nPlayerId] = nTeamId;
		end
	end

	if #tbTeamInfo == 1 then
		self.bBeyFight = true;
	end
end

function tbFightMap:Start()
	if MODULE_ZONESERVER and self.nType == TeamBattle.TYPE_NORMAL then
		self.STATE_TRANS = TeamBattle.STATE_TRANS_CROSS;
	else
		self.STATE_TRANS = TeamBattle.STATE_TRANS;
	end
	self.nSchedulePos = 0;
	self.nTeamBattleStartTime = GetTime();
	self:StartSchedule();
end

function tbFightMap:StartSchedule()
	self.nMainTimer = nil;
	self.nSchedulePos = self.nSchedulePos + 1;

	local tbCurSchedule = self.STATE_TRANS[self.nSchedulePos]
	if tbCurSchedule then
		self.szStateInfo = tbCurSchedule.szDesc;
		self[tbCurSchedule.szFunc](self)
	end

	--Log("[TeamBattle] StartSchedule", self.nMapId, self.nSchedulePos, (tbCurSchedule or {}).nSeconds or 0, (tbCurSchedule or {}).szDesc or "nil");
	if not self.STATE_TRANS[self.nSchedulePos + 1] then --后面没有timer 就断了
		Timer:Register(Env.GAME_FPS * 300, self.ClearPlayer, self);
		return;
	end

	local function fnSyncFightState(self, pPlayer)
		self:SyncPlayerLeftInfo(pPlayer);
		pPlayer.CallClientScript("TeamBattle:SyncFightState", tbCurSchedule.nSeconds);
	end
	self:ForeachPlayer(-1, fnSyncFightState);
	self.nMainTimer = Timer:Register(Env.GAME_FPS * tbCurSchedule.nSeconds, self.StartSchedule, self )
end

function tbFightMap:UpdatePlayerDmg(pPlayer)
	local nTeamId = self.tbCurTeamId[pPlayer.dwID];
	if not nTeamId then
		return;
	end

	self.tbDmgInfo[nTeamId].tbPlayerDmg = self.tbDmgInfo[nTeamId].tbPlayerDmg or {};
	self.tbDmgInfo[nTeamId].tbPlayerDmg[pPlayer.dwID] = self.tbDmgInfo[nTeamId].tbPlayerDmg[pPlayer.dwID] or {nDamage = 0};

	local tbLastCounter = self.tbDmgInfo[nTeamId].tbPlayerDmg[pPlayer.dwID];
	local tbCounter = pPlayer.GetNpc().GetDamageCounter();
	self.tbDmgInfo[nTeamId].tbPlayerDmg[pPlayer.dwID] = tbCounter;
	self.tbDmgInfo[nTeamId].nTotalDmg = self.tbDmgInfo[nTeamId].nTotalDmg - tbLastCounter.nDamage + tbCounter.nDamage;
end

function tbFightMap:SyncPlayerLeftInfo(pPlayer)
	local tbDmgInfo = {
		szStateInfo = self.szStateInfo or "等待開始",
		[1] = {nTotalDmg = self.tbDmgInfo[1].nTotalDmg, nKillCount = self.tbDmgInfo[1].nKillCount},
		[2] = {nTotalDmg = self.tbDmgInfo[2].nTotalDmg, nKillCount = self.tbDmgInfo[2].nKillCount},
	};
	pPlayer.CallClientScript("TeamBattle:SyncPlayerLeftInfo", self.tbCurTeamId[pPlayer.dwID], tbDmgInfo);
end

function tbFightMap:UpdateAllPlayerDmg()
	self:ForeachPlayer(-1, self.UpdatePlayerDmg);
	self:ForeachPlayer(-1, self.SyncPlayerLeftInfo);

	return not self.bClcResult;
end

function tbFightMap:ForeachPlayer(nTeamId, fnFunc, ...)
	for nTId, tbTeam in pairs(self.tbTeamMemeberInfo) do
		if nTeamId < 0 or nTeamId == nTId then
			for _, nPlayerId in ipairs(tbTeam) do
				local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
				if pPlayer and pPlayer.nMapId == self.nMapId then
					Lib:CallBack({fnFunc, self, pPlayer, ...});
				end
			end
		end
	end
end

function tbFightMap:SetPlayerDmgCounter(pPlayer, bStart)
	local pPlayerNpc = pPlayer.GetNpc();
	if bStart then
		pPlayerNpc.StartDamageCounter();
	else
		pPlayerNpc.StopDamageCounter();
	end
end

function tbFightMap:ShowTeamInfo()
	if self.bBeyFight then
		self:ShowBeyInfo();
		return;
	end

	self.tbCurTeamInfo = {};
	local function fnGetPlayerInfo(pPlayer)
		local nTeamId = self.tbCurTeamId[pPlayer.dwID];
		self.tbCurTeamInfo[nTeamId] = self.tbCurTeamInfo[nTeamId] or {};
		table.insert(self.tbCurTeamInfo[nTeamId], {
			szName		= pPlayer.szName,
			nPortrait	= pPlayer.nPortrait,
			nLevel		= pPlayer.nLevel,
			nHonorLevel	= pPlayer.nHonorLevel,
			nFaction	= pPlayer.nFaction,
			nFightPower	= pPlayer.GetFightPower();
		});
	end

	for nTId, tbTeam in pairs(self.tbTeamMemeberInfo) do
		for _, nPlayerId in ipairs(tbTeam) do
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer then
				fnGetPlayerInfo(pPlayer);
			end
		end
	end

	self:ForeachPlayer(-1, self.ShowInfo)
	self.bShowTeamInfo = true;
end

function tbFightMap:ShowInfo(pPlayer)
	local szMsg = TeamBattle.szStartMsg;
	if pPlayer.nLastResult then
		szMsg = TeamBattle.szJoinMsg;
	end

	pPlayer.SendBlackBoardMsg(string.format(szMsg, self.nFloor), true);

	local nTeamId = self.tbCurTeamId[pPlayer.dwID];
	pPlayer.CallClientScript("TeamBattle:ShowTeamInfo", nTeamId, self.tbCurTeamInfo);
end

function tbFightMap:ShowBeyInfo()
	self.nSchedulePos = 999;
	if self.nMainTimer then
		Timer:Close(self.nMainTimer);
		self.nMainTimer = nil;
	end

	local nNextFightTime = 0;
	if self.nNextFightTimerId then
		nNextFightTime = Timer:GetRestTime(self.nNextFightTimerId);
	end

	local function fnShowBeyInfo(self, pPlayer)
		pPlayer.SendBlackBoardMsg("本輪輪空，直接晉級！", true);
		pPlayer.CallClientScript("TeamBattle:ShowBeyInfo", math.floor(nNextFightTime / Env.GAME_FPS), true, self.nNextFightTimerId and true or false);

		if MODULE_ZONESERVER and self.nType == TeamBattle.TYPE_NORMAL then
			CallZoneClientScript(pPlayer.nZoneIndex, "TeamBattle:OnSyncWin", pPlayer.dwID);
		elseif not MODULE_ZONESERVER then
			RecordStone:AddRecordCount(pPlayer, "Tower", 1);
		end
	end

	self:ForeachPlayer(-1, fnShowBeyInfo);
	self.fnSetResult(self.tbTeamMemeberInfo[1].nBattleTeamId);
end

function tbFightMap:PreStart()
	local function fnPreStart(self, pPlayer)
		local nTeamId = self.tbCurTeamId[pPlayer.dwID];
		local tbBeginFightPos = self.tbMapInfo[nTeamId].tbBeginFightPos;
		if tbBeginFightPos then
			pPlayer.nFightMode = 1;
			pPlayer.SetPkMode(0);
			pPlayer.SetPosition(unpack(tbBeginFightPos));
			pPlayer.CallClientScript("Ui:OpenWindow", "ReadyGo");
		else
			pPlayer.CenterMsg("資料異常，請聯繫客服！");
			TeamBattle:GoBack(pPlayer);
		end
	end
	self:ForeachPlayer(-1, fnPreStart);
end

function tbFightMap:StartFight()
	if not self.bIsSecondFight then
		self:ForeachPlayer(-1, self.SetPlayerDmgCounter, true);
		self.nUpdateDmgTime = Timer:Register(Env.GAME_FPS * 2, self.UpdateAllPlayerDmg, self);
		self.bIsSecondFight = true;
	end

	local function fnSetPlayerFight(self, pPlayer)
		local nTeamId = self.tbCurTeamId[pPlayer.dwID];
		pPlayer.SetPkMode(3, nTeamId);
	end

	self:ForeachPlayer(-1, fnSetPlayerFight);
end

function tbFightMap:MidRest()
	self.tbMapInfo[1], self.tbMapInfo[2] = self.tbMapInfo[2], self.tbMapInfo[1];
	self:UpdateAllPlayerDmg();
	self:GotoRest(true);
end

function tbFightMap:GotoRest(bIsMid)
	local function fnGotoRest(self, pPlayer)
		local nTeamId = self.tbCurTeamId[pPlayer.dwID];
		local tbRestPos = self.tbMapInfo[nTeamId].tbRestPos;
		if tbRestPos then
			if bIsMid then
				pPlayer.SendBlackBoardMsg("上半場結束，中場休息", true);
			end

			pPlayer.GetNpc().ClearAllSkillCD();
			pPlayer.SetPosition(unpack(tbRestPos));
			self:ClearState(pPlayer);
		else
			pPlayer.CenterMsg("資料異常，請聯繫客服！");
			TeamBattle:GoBack(pPlayer);
		end
	end
	self:ForeachPlayer(-1, fnGotoRest);
end

function tbFightMap:CheckResult()
	local bIsFinish = true;
	local function fnCheckDeath(self, pPlayer)
		local pNpc = pPlayer.GetNpc();
		if not bIsFinish or pNpc.GetSkillState(TeamBattle.nDeathSkillState) then
			return;
		end
		bIsFinish = false;
	end
	self:ForeachPlayer(1, fnCheckDeath);

	if not bIsFinish then
		bIsFinish = true;
		self:ForeachPlayer(2, fnCheckDeath);
	end

	if not bIsFinish then
		return;
	end

	if self.nMainTimer then
		Timer:Close(self.nMainTimer);
		self.nMainTimer = nil;
	end

	Timer:Register(Env.GAME_FPS, self.StartSchedule, self);
end

function tbFightMap:ClcResult()
	local nCostTime = GetTime() - self.nTeamBattleStartTime;
	if self.nUpdateDmgTime then
		Timer:Close(self.nUpdateDmgTime);
		self.nUpdateDmgTime = nil;
	end

	if not self.nNextFightTimerId then
		self.szStateInfo = "比賽結束";
	end

	self.bClcResult = true;
	self:UpdateAllPlayerDmg();

	local nWinTeamId = 1;
	if self.tbDmgInfo[2].nKillCount > self.tbDmgInfo[1].nKillCount or
		(self.tbDmgInfo[2].nKillCount == self.tbDmgInfo[1].nKillCount and self.tbDmgInfo[2].nTotalDmg >= self.tbDmgInfo[1].nTotalDmg) then

		nWinTeamId = 2;
	end

	local tbShowInfo = {};
	local function fnSetShowInfo(self, pPlayer)
		local nTeamId = self.tbCurTeamId[pPlayer.dwID];
		local nDamage = 0;
		local nKillCount = 0;
		if self.tbDmgInfo[nTeamId] then
			if self.tbDmgInfo[nTeamId].tbPlayerDmg[pPlayer.dwID] then
				nDamage = self.tbDmgInfo[nTeamId].tbPlayerDmg[pPlayer.dwID].nDamage;
			end

			if self.tbDmgInfo[nTeamId].tbPlayerKillCount then
				nKillCount = self.tbDmgInfo[nTeamId].tbPlayerKillCount[pPlayer.dwID] or 0;
			end
		end
		tbShowInfo[nTeamId] = tbShowInfo[nTeamId] or {};
		tbShowInfo[nTeamId][pPlayer.dwID] = {
			szName		= pPlayer.szName,
			nPortrait	= pPlayer.nPortrait,
			nLevel		= pPlayer.nLevel,
			nHonorLevel	= pPlayer.nHonorLevel,
			nFaction	= pPlayer.nFaction,
			nDamage		= nDamage,
			nKillCount	= nKillCount,
		};
		pPlayer.nLastResult = nTeamId == nWinTeamId and 1 or 0;
	end
	self:ForeachPlayer(-1, fnSetShowInfo);

	local function fnNotifyResult(self, pPlayer)
		local nTeamId = self.tbCurTeamId[pPlayer.dwID];

		local nNextFightTime = nil;
		if self.nNextFightTimerId then
			nNextFightTime = Timer:GetRestTime(self.nNextFightTimerId);
		end
		if nNextFightTime and nNextFightTime > 0 then
			pPlayer.CallClientScript("TeamBattle:SyncFightState", math.floor(nNextFightTime / Env.GAME_FPS));
		end

		if nTeamId == nWinTeamId then
			if not MODULE_ZONESERVER then
				Achievement:AddCount(pPlayer, "TeamBattle_2", 1);
			end
		end

		local szMsg = nTeamId == nWinTeamId and TeamBattle.szWinMsg or TeamBattle.szFailMsg;
		local nFloor = nTeamId == nWinTeamId and self.nFloor + 1 or self.nFloor;
		pPlayer.SendBlackBoardMsg(string.format(szMsg, nFloor), true);
		pPlayer.CallClientScript("TeamBattle:ShowFightResult", nTeamId, tbShowInfo, nWinTeamId, self.nNextFightTimerId and true or false);

		local nResult = nTeamId == nWinTeamId and Env.LogRound_SUCCESS or Env.LogRound_FAIL;
		pPlayer.TLogRoundFlow( Env.LogWay_TeamBattle, pPlayer.nMapTemplateId, 0, nCostTime, nResult, 0, 0);

		if nTeamId == nWinTeamId then
			if MODULE_ZONESERVER and self.nType == TeamBattle.TYPE_NORMAL then
				CallZoneClientScript(pPlayer.nZoneIndex, "TeamBattle:OnSyncWin", pPlayer.dwID);
			elseif not MODULE_ZONESERVER then
				RecordStone:AddRecordCount(pPlayer, "Tower", 1);
			end
		end

		TeamBattle:ReportQQScore(pPlayer, Env.QQReport_TeamBattle_Result, nResult);

		local nKillCount = self.tbQQReportKillCountInfo[pPlayer.dwID] or 0;
		TeamBattle:ReportQQScore(pPlayer, Env.QQReport_TeamBattle_KillCount, nKillCount);

		local nKillCount2 = self.tbQQReportKillCount2Info[pPlayer.dwID] or 0;
		TeamBattle:ReportQQScore(pPlayer, Env.QQReport_TeamBattle_KillCount2, math.max(nKillCount2, nKillCount - nKillCount2));
		TeamBattle:ReportQQScore(pPlayer, Env.QQReport_TeamBattle_DeathCount, self.tbQQReportDeathCountInfo[pPlayer.dwID] or 0);
	end

	self.tbDmgInfo = {{nTotalDmg = 0, nKillCount = 0}, {nTotalDmg = 0, nKillCount = 0}};
	self:ForeachPlayer(-1, self.SyncPlayerLeftInfo);

	self:GotoRest();
	self:ForeachPlayer(-1, fnNotifyResult);
	self.fnSetResult(self.tbTeamMemeberInfo[nWinTeamId].nBattleTeamId, self.tbTeamMemeberInfo[3 - nWinTeamId].nBattleTeamId);
end

function tbFightMap:ClearPlayer()
	local tbPlayer = KPlayer.GetMapPlayer(self.nMapId);
	for _, pPlayer in pairs(tbPlayer) do
		TeamBattle:GoBack(pPlayer);
	end
end

function tbFightMap:Clear()
	assert(self.bClcResult);
	if self.nMainTimer then
		Timer:Close(self.nMainTimer);
		self.nMainTimer = nil;
	end
end

function tbFightMap:ClearState(pPlayer)
	pPlayer.Revive(1);
	pPlayer.SetPkMode(0);
	pPlayer.RestoreAll();
	pPlayer.nFightMode = 1;
	pPlayer.RemoveSkillState(TeamBattle.nDeathSkillState);
end

function tbFightMap:OnPlayerDeath(pKiller)
	local nMyTeamId = self.tbCurTeamId[me.dwID];
	local nKillerTeamId = nMyTeamId == 1 and 2 or 1;

	if pKiller then
		local pKillPlayer = pKiller.GetPlayer();
		if pKillPlayer then
			self.tbDmgInfo[nKillerTeamId].tbPlayerKillCount = self.tbDmgInfo[nKillerTeamId].tbPlayerKillCount or {};
			self.tbDmgInfo[nKillerTeamId].tbPlayerKillCount[pKillPlayer.dwID] = self.tbDmgInfo[nKillerTeamId].tbPlayerKillCount[pKillPlayer.dwID] or 0;
			self.tbDmgInfo[nKillerTeamId].tbPlayerKillCount[pKillPlayer.dwID] = self.tbDmgInfo[nKillerTeamId].tbPlayerKillCount[pKillPlayer.dwID] + 1;
			pKillPlayer.nTeamBattleComboKill = (pKillPlayer.nTeamBattleComboKill or 0) + 1;
			pKillPlayer.nTeamBattleTotalKill = (pKillPlayer.nTeamBattleTotalKill or 0) + 1;

			self.tbQQReportKillCountInfo[pKillPlayer.dwID] = self.tbQQReportKillCountInfo[pKillPlayer.dwID] or 0;
			self.tbQQReportKillCountInfo[pKillPlayer.dwID] = self.tbQQReportKillCountInfo[pKillPlayer.dwID] + 1;

			if not self.tbQQReportDeathCountInfo[pKillPlayer.dwID] or self.tbQQReportDeathCountInfo[pKillPlayer.dwID] <= 0 then
				self.tbQQReportKillCount2Info[pKillPlayer.dwID] = self.tbQQReportKillCount2Info[pKillPlayer.dwID] or 0;
				self.tbQQReportKillCount2Info[pKillPlayer.dwID] = self.tbQQReportKillCount2Info[pKillPlayer.dwID] + 1;
			end

			pKillPlayer.CallClientScript("Ui:ShowComboKillCount", pKillPlayer.nTeamBattleComboKill);
		end
	end

	self.tbQQReportDeathCountInfo[me.dwID] = self.tbQQReportDeathCountInfo[me.dwID] or 0;
	self.tbQQReportDeathCountInfo[me.dwID] = self.tbQQReportDeathCountInfo[me.dwID] + 1;

	self.tbDmgInfo[nKillerTeamId].nKillCount = self.tbDmgInfo[nKillerTeamId].nKillCount + 1;

	me.nTeamBattleTotalDeath = (me.nTeamBattleTotalDeath or 0) + 1;
	me.nTeamBattleComboKill = 0;
	me.Revive(1);
	me.SetPkMode(0);
	me.RestoreAll();
	me.nFightMode = 2;
	me.AddSkillState(TeamBattle.nDeathSkillState, 1, 0, 10000);
	self:CheckResult();
end

function tbFightMap:OnCreate()
	if MODULE_ZONESERVER and self.nType == TeamBattle.TYPE_NORMAL then
		for i = 1, #self.tbTeamInfo do
			if self.tbMapInfo[i] then
				local nConnectIdx, nTeamId = TeamBattle:GetConnectInfoByTeamId(self.tbTeamInfo[i]);
				CallZoneClientScript(nConnectIdx, "TeamBattle:OnSyncMapId", nTeamId, self.nMapId, self.tbMapInfo[i].tbRestPos);
			end
		end
	else
		for nTeamId, tbTeamInfo in pairs(self.tbTeamMemeberInfo) do
			for _, nPlayerId in ipairs(tbTeamInfo) do
				local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
				if pPlayer then
					pPlayer.SwitchMap(self.nMapId, unpack(self.tbMapInfo[nTeamId].tbRestPos));
				end
			end
		end
	end

	self:Start();
end

function tbFightMap:WaitePlayer()
end

function tbFightMap:OnEnter()
	if MODULE_ZONESERVER and self.nType == TeamBattle.TYPE_NORMAL then
		local tbCache = TeamBattle.tbAllCacheData[me.dwID];
		if tbCache then
			me.SetUserValue(TeamBattle.SAVE_GROUP, TeamBattle.SAVE_HONOR, tbCache[1]);
			me.nTeamBattleTotalKill = tbCache[2] or 0;
			me.nTeamBattleTotalDeath = tbCache[3] or 0;
		end

		-- 跨服进来，重新组队
		local nMyTId = self.tbCurTeamId[me.dwID];
		local tbMemeber = self.tbTeamMemeberInfo[nMyTId];
		for _, nPlayerId in ipairs(tbMemeber) do
			if nPlayerId ~= me.dwID then
				local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
				if pPlayer then
					if pPlayer.dwTeamID <= 0 then
						TeamMgr:Create(me.dwID, pPlayer.dwID, true);
						me.bTeamBattleLeader = true;
					else
						local teamData = TeamMgr:GetTeamById(pPlayer.dwTeamID);
						teamData:AddMember(me.dwID, true);
					end
					break;
				end
			end
		end
	end

	if self.bShowTeamInfo then
		self:ShowInfo(me);
	end

	me.nInBattleState = 1;
	me.nFightMode = 1;
	me.SetPkMode(0);

	self.tbRegisterInfo = self.tbRegisterInfo or {};
	self.tbRegisterInfo[me.dwID] = {};
	self.tbRegisterInfo[me.dwID].nOnDeathRegID = PlayerEvent:Register(me, "OnDeath", function(pKiller) self:OnPlayerDeath(pKiller); end);
	self.tbRegisterInfo[me.dwID].nOnReviveRegID = PlayerEvent:Register(me, "OnRevive", function () end);


	self:UpdatePlayerUi(me);
end

function tbFightMap:UpdatePlayerUi(pPlayer)
	local nRestTime = 0;
	if self.nMainTimer then
		nRestTime = math.floor(Timer:GetRestTime(self.nMainTimer) / Env.GAME_FPS);
	end

	pPlayer.CallClientScript("Ui:OpenWindow", "TeamBattleInfo", self.nFloor, self.nFightTimes, self.nMaxFightTimes);
	pPlayer.CallClientScript("TeamBattle:SyncFightState", nRestTime);
	pPlayer.CallClientScript("Map:SetCloseUiOnLeave", pPlayer.nMapId, "TeamBattleInfo");
	self:SyncPlayerLeftInfo(pPlayer);

	if self.bClcResult then
		local nNextTime;
		if self.nNextFightTimerId then
			nNextTime = math.floor(Timer:GetRestTime(self.nNextFightTimerId) / Env.GAME_FPS);
			if self.bNextToZoneServer then
				-- 下一场要进行跨服的情况下，留10s时间防止各个服务器时间不统一
				nNextTime = nNextTime + 10;
			end
		end

		if not self.nNextFightTimerId then
			pPlayer.nCanLeaveMapId = pPlayer.nMapId;
			pPlayer.CallClientScript("Ui:OpenWindow", "QYHLeavePanel");
		end

		pPlayer.CallClientScript("TeamBattle:ShowBeyInfo", nNextTime, true, self.nNextFightTimerId and true or false);
	end
end

function tbFightMap:OnLogin()
	Timer:Register(Env.GAME_FPS * 3, function (self, nPlayerId)
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if not pPlayer or pPlayer.nMapId ~= self.nMapId then
			return;
		end

		self:UpdatePlayerUi(pPlayer);
	end, self, me.dwID);
end

function tbFightMap:OnLeave()
	me.nInBattleState = nil;
	PlayerEvent:UnRegister(me, "OnDeath", self.tbRegisterInfo[me.dwID].nOnDeathRegID);
	PlayerEvent:UnRegister(me, "OnRevive", self.tbRegisterInfo[me.dwID].nOnReviveRegID);
	self.tbRegisterInfo[me.dwID] = nil;
	self:ClearState(me);
end

--------------------------------------------------------------------------------------
function TeamBattle:RegisterFightMap(nMapTemplateId)
	local tbMap = Map:GetClass(nMapTemplateId);
	function tbMap:OnCreate(nMapId)
		local tbInst = (TeamBattle.tbTeamBattleFMInstByMapId or {})[nMapId];
		if tbInst and tbInst.OnCreate then
			tbInst:OnCreate(nMapId);
		else
			for _, tbInst in pairs(TeamBattle.tbTeamBattleMgrInstByMapId or {}) do
				tbInst:OnFightMapFunc("OnCreate", nMapId);
			end
		end
	end

	function tbMap:OnEnter(nMapId)
		local tbInst = (TeamBattle.tbTeamBattleFMInstByMapId or {})[nMapId];
		if tbInst and tbInst.OnEnter then
			tbInst:OnEnter(nMapId);
		else
			for _, tbInst in pairs(TeamBattle.tbTeamBattleMgrInstByMapId or {}) do
				tbInst:OnFightMapFunc("OnEnter", nMapId);
			end
		end
	end

	function tbMap:OnLogin(nMapId)
		local tbInst = (TeamBattle.tbTeamBattleFMInstByMapId or {})[nMapId];
		if tbInst and tbInst.OnLogin then
			tbInst:OnLogin(nMapId);
		else
			for _, tbInst in pairs(TeamBattle.tbTeamBattleMgrInstByMapId or {}) do
				tbInst:OnFightMapFunc("OnLogin", nMapId);
			end
		end
	end

	function tbMap:OnLeave(nMapId)
		local tbInst = (TeamBattle.tbTeamBattleFMInstByMapId or {})[nMapId];
		if tbInst and tbInst.OnLeave then
			tbInst:OnLeave(nMapId);
		else
			for _, tbInst in pairs(TeamBattle.tbTeamBattleMgrInstByMapId or {}) do
				tbInst:OnFightMapFunc("OnLeave", nMapId);
			end
		end
	end

	function tbMap:OnDestroy(nMapId)
		if TeamBattle.tbTeamBattleFMInstByMapId and TeamBattle.tbTeamBattleFMInstByMapId[nMapId] then
			TeamBattle.tbTeamBattleFMInstByMapId[nMapId] = nil;
		else
			for _, tbInst in pairs(TeamBattle.tbTeamBattleMgrInstByMapId or {}) do
				if tbInst.tbFightInstByMapId then
					tbInst.tbFightInstByMapId[nMapId] = nil;
				end
			end
		end
	end
end

for _, tbInfo in pairs(TeamBattle.tbFightMapBeginPoint) do
	local tbRegister = {};
	for _, tbMapInfo in pairs(tbInfo) do
		if not tbRegister[tbMapInfo[1]] then
			assert(tbMapInfo[1] ~= TeamBattle.TOP_MAP_ID);
			assert(tbMapInfo[1] ~= TeamBattle.TOP_MAP_ID_CROSS);
			TeamBattle:RegisterFightMap(tbMapInfo[1]);
		end
		tbRegister[tbMapInfo[1]] = 1;
	end
end
