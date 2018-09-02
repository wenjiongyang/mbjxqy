
local tbFuben = Fuben:CreateFubenClass("TeamFubenBase");

function tbFuben:OnCreate(nSectionIdx, nSubSectionIdx, tbHelpState)
	self.nSectionIdx = nSectionIdx;
	self.nSubSectionIdx = nSubSectionIdx;
	self.tbReviveTimer = {};
	self.tbRecord = {};
	self.nScore = 0;
	self.tbPlayerScore = {};
	self.tbPlayerState = {};
	self.tbHelpState = tbHelpState;

	local tbFubenSetting = TeamFuben:GetFubenSetting(nSectionIdx, nSubSectionIdx);
	self.szMissionSumup = tbFubenSetting.szMissionSumup;
	self.tbAward = tbFubenSetting.tbAward;
	self.szTitle = tbFubenSetting.szName;
	self.tbDropAward = {};
	self.nStartTime = GetTime();
	self:Start();
end

function tbFuben:OnLogin(bReConnect)
	me.CallClientScript("Ui:SetAllUiVisable", true);
	me.CallClientScript("Fuben:ClearClientData");
	me.CallClientScript("Ui:OpenWindow", "HomeScreenFuben", "TeamFuben");
	if self.nShowEndTime and self.nShowEndTime > 0 then
		me.CallClientScript("Fuben:SetEndTime", self.bClose == 1 and 0 or self.nShowEndTime);
	end

	if not self.tbPlayerState[me.dwID] then
		Npc:SetPlayerNoDropMap(me, self.nMapId);
	end

	if self.bClose == 1 then
		me.CallClientScript("Fuben:ShowLeave");
	end
end

function tbFuben:OnJoin(pPlayer)
	local bCost = false;

	local teamData = TeamMgr:GetTeamById(pPlayer.dwTeamID);
	if teamData then
		self.nTeamLeader = teamData.nCaptainID;
	end
	if not self.tbHelpState[pPlayer.dwID] then
		bCost = DegreeCtrl:ReduceDegree(pPlayer, "TeamFuben", 1);
	end

	self.tbPlayer[pPlayer.dwID].nJoinKinCallbackId = PlayerEvent:Register(pPlayer, "OnJoinKin", self.OnJoinKin, self);
	self.tbPlayer[pPlayer.dwID].nNpcDropCallbackId = PlayerEvent:Register(pPlayer, "OnNpcDrop", self.OnNpcDrop, self);

	pPlayer.CallClientScript("Fuben:ClearClientData");
	pPlayer.CallClientScript("Ui:OpenWindow", "HomeScreenFuben", "TeamFuben");
	pPlayer.CallClientScript("Fuben:CloseLeave");

	self.tbPlayerState[pPlayer.dwID] = bCost;
	if bCost then
		self.tbPlayerScore[pPlayer.dwID] = 0;
		AssistClient:ReportQQScore(pPlayer, Env.QQReport_IsJoinTeamFuben, 1, 0, 1)
	end

	if not bCost then
		Npc:SetPlayerNoDropMap(pPlayer, self.nMapId);
		pPlayer.CenterMsg("您處於助戰狀態，不能獲得闖關獎勵！", true);
		Log("[TeamFuben] Join TeamFuben Whith Help State !!", pPlayer.szName, pPlayer.szAccount, pPlayer.dwID);
	end

	GameSetting:SetGlobalObj(pPlayer, him, it);
	self:OnNpcDrop(bCost and self.tbAward or TeamFuben.tbCommonAward);
	GameSetting:RestoreGlobalObj();

	self:UpdatePlayerScore(pPlayer);
	if bCost then
		EverydayTarget:AddCount(pPlayer, "TeamFuben");
	end
	LogD(Env.LOGD_ActivityPlay, pPlayer.szAccount, pPlayer.dwID, pPlayer.nLevel, string.format("%s_%s", self.nSectionIdx, self.nSubSectionIdx), Env.LOGD_VAL_TAKE_TASK, Env.LOGD_MIS_TEAM_FUBEN, pPlayer.GetFightPower());
end

function tbFuben:OnJoinKin(dwKinId)
	local tbAllPlayer = KPlayer.GetMapPlayer(self.nMapId);
	for _, pPlayer in pairs(tbAllPlayer) do
		if pPlayer.dwKinId == dwKinId then
			self:UpdatePlayerScore(pPlayer);
		end
	end
end

function tbFuben:OnNpcDrop(tbAward)
	self.tbDropAward[me.dwID] = self.tbDropAward[me.dwID] or {};

	-- QQ会员加成
	local nVipAddRate = 0; --me.GetQQVipInfo();
	local tbDrop = self.tbDropAward[me.dwID];
	for _, tbInfo in pairs(tbAward) do
		local nAwardType = Player.AwardType[tbInfo[1]];
		if nAwardType == Player.award_type_money and (tbInfo[1] == "Coin" or tbInfo[1] == "coin") then
			tbDrop.nCoin = (tbDrop.nCoin or 0) + tbInfo[2] * (1 + nVipAddRate);
		elseif nAwardType == Player.award_type_exp then
			tbDrop.nExp = (tbDrop.nExp or 0) + tbInfo[2];
		elseif nAwardType == Player.award_type_item or
			nAwardType == Player.award_type_money or
			nAwardType == Player.award_type_partner then

			tbDrop.tbOther = tbDrop.tbOther or {};
			table.insert(tbDrop.tbOther, tbInfo);
		end
	end
end

function tbFuben:OnOut(pPlayer)
	self:DoRevive(pPlayer.dwID, true);
	self:ShowMissionAward(pPlayer);

	-- 发固定奖励，如果没奖励次数则不发任何奖励

	if self.tbPlayerState[pPlayer.dwID] then
		pPlayer.SendAward(self.tbAward, false, false, Env.LogWay_TeamFubenOutAward);
	end

	self.tbPlayerState[pPlayer.dwID] = nil;
end

-- 这个时候才真正离开副本地图
function tbFuben:OnLeaveMap(pPlayer)
	if self.tbPlayer[pPlayer.dwID] and self.tbPlayer[pPlayer.dwID].nJoinKinCallbackId then
		PlayerEvent:UnRegister(pPlayer, "OnJoinKin", self.tbPlayer[pPlayer.dwID].nJoinKinCallbackId);
		self.tbPlayer[pPlayer.dwID].nJoinKinCallbackId = nil;
	end

	if self.tbPlayer[pPlayer.dwID] and self.tbPlayer[pPlayer.dwID].nNpcDropCallbackId then
		PlayerEvent:UnRegister(pPlayer, "OnNpcDrop", self.tbPlayer[pPlayer.dwID].nNpcDropCallbackId);
		self.tbPlayer[pPlayer.dwID].nNpcDropCallbackId = nil;
	end

	pPlayer.CallClientScript("Ui:CloseWindow", "HomeScreenFuben");
	self:ConfirmFubenMission(pPlayer, true);
	self:DoRevive(pPlayer.dwID, true);
end

function tbFuben:ShowMissionAward(pPlayer)
	if not self.tbPlayerState[pPlayer.dwID] then
		pPlayer.CenterMsg("您處於助戰狀態，不能獲得闖關獎勵！");
		return;
	end

	Achievement:AddCount(pPlayer, "TeamFuben_1", 1);

	local nScroe, bHasNewPlayer = self:UpdatePlayerScore(pPlayer);
	local tbMember = self:GetMember(pPlayer);
	pPlayer.CallClientScript("Ui:OpenWindow", "TeamFubenMission", self.szTitle, nScroe, tbMember, self.nCostTime, self.tbDropAward[pPlayer.dwID], bHasNewPlayer);
	self.tbShowMissAward = self.tbShowMissAward or {};
	self.tbShowMissAward[pPlayer.dwID] = true;
end

function tbFuben:ConfirmFubenMission(pPlayer, bNotShowMissionAward)
	pPlayer.CallClientScript("Ui:CloseWindow", "TeamFubenMission");
	if self.tbShowMissAward then
		self.tbShowMissAward[pPlayer.dwID] = nil;
	end

	if not self.tbPlayerScore[pPlayer.dwID] then
		return;
	end

	local nScroe = self:UpdatePlayerScore(pPlayer);
	if not nScroe then
		return;
	end

	local nGrade, szType, nNextLevelScroe, nMaxScroe = MissionAward:GetGrade(MissionAward.emType_TeamFuben, nScroe);
	self.tbPlayerScore[pPlayer.dwID] = nil;

	if nGrade == 1 then
		if self.nSectionIdx == 1 and self.nSubSectionIdx == 1 then
			Achievement:AddCount(pPlayer, "TeamFuben_2", 1);
		elseif self.nSectionIdx == 1 and self.nSubSectionIdx == 2 then
			Achievement:AddCount(pPlayer, "TeamFuben_3", 1);
		elseif self.nSectionIdx == 1 and self.nSubSectionIdx == 3 then
			Achievement:AddCount(pPlayer, "TeamFuben_4", 1);
		elseif self.nSectionIdx == 1 and self.nSubSectionIdx == 4 then
			Achievement:AddCount(pPlayer, "TeamFuben_5", 1);
		end
		TeacherStudent:TargetAddCount(pPlayer, "FuBenSSS", 1)
		pPlayer.CallClientScript("GameSetting.Comment:OnEvent", GameSetting.Comment.Type_TeamFuben_SSS);
	end
	if nGrade<=3 then
		TeacherStudent:TargetAddCount(pPlayer, "FuBenS", 1)
	end

	if self.nTeamLeader and self.nTeamLeader == pPlayer.dwID then
		local nLeaderExtAward = TeamFuben.tbTeamLeaderExtAward[nGrade] or 40;
		pPlayer.SendAward({{"Contrib", nLeaderExtAward}}, true, false, Env.LogWay_TeamFuben);

		if pPlayer.dwTeamID > 0 then
			local szMsg = string.format("本次評價為「%s」，隊長額外獲得%s點貢獻", MissionAward.tbGradeDesc[szType], nLeaderExtAward);
			ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Team, szMsg, pPlayer.dwTeamID);
		end
	end

	local nAddImitity = MissionAward:GetAddImity(MissionAward.emType_TeamFuben, nGrade);
	self.tbAddImityPlayer = self.tbAddImityPlayer or {};
	self.tbAddImityPlayer[pPlayer.dwID] = true;
	for nPlayerId in pairs(self.tbAllFinishPlayer or {}) do
		if nPlayerId ~= pPlayer.dwID and not self.tbAddImityPlayer[nPlayerId] and FriendShip:IsFriend(pPlayer.dwID, nPlayerId) then
			FriendShip:AddImitity(pPlayer.dwID, nPlayerId, nAddImitity, Env.LogWay_TeamFuben);
		end
	end

	local tbExtAward = TeamFuben.tbExtMissAward[nGrade];
	if tbExtAward then
		pPlayer.SendAward(tbExtAward, true, false, Env.LogWay_TeamFuben);
	end

	pPlayer.TLogRoundFlow(Env.LogWay_TeamFuben, pPlayer.nMapTemplateId, nScroe, self.nCostTime or 0, self.nCostTime and Env.LogRound_SUCCESS or Env.LogRound_FAIL, 0, 0);
end

function tbFuben:UpdateAllPlayerScore()
	local fnExcute = function (pPlayer)
		self:UpdatePlayerScore(pPlayer);
	end

	self:AllPlayerExcute(fnExcute);
end

function tbFuben:GetMember(pPlayer)
	local tbResult = {};
	local tbAllPlayer = KPlayer.GetMapPlayer(self.nMapId);
	for _, pMember in pairs(tbAllPlayer or {}) do
		if pMember.dwID ~= pPlayer.dwID then
			local tbInfo = {
				nPlayerId = pMember.dwID,
				szName = pMember.szName,
				nLevel = pMember.nLevel,
				nFaction = pMember.nFaction,
				nPortrait = pMember.nPortrait,
				dwKinId = pMember.dwKinId or 0,
			};
			table.insert(tbResult, tbInfo);
		end
	end
	return tbResult;
end

function tbFuben:DoFubenClickMakeFriend(pPlayer, nOtherPlayerId)
	self.tbMakeFriendList = self.tbMakeFriendList or {};
	self.tbMakeFriendList[pPlayer.dwID] = self.tbMakeFriendList[pPlayer.dwID] or {};
	self.tbMakeFriendList[pPlayer.dwID][nOtherPlayerId] = true;
	self:UpdatePlayerScore(pPlayer);
end

function tbFuben:UpdatePlayerScore(pPlayer)
	if self.nScore <= 0 then
		return;
	end

	local nCurScore = self.nScore + (self.tbPlayerScore[pPlayer.dwID] or 0);

	local nKinNewScore = 0;
	local tbPlayerInfo = self.tbAllFinishPlayer;
	if not tbPlayerInfo then
		local tbAllPlayer = KPlayer.GetMapPlayer(self.nMapId);
		tbPlayerInfo = {};
		for _, pMember in pairs(tbAllPlayer or {}) do
			tbPlayerInfo[pMember.dwID] = true;
		end
	end

	for pMemberID in pairs(tbPlayerInfo or {}) do
		if pMemberID ~= pPlayer.dwID then
			if Kin:PlayerAtSameKin(pPlayer.dwID, pMemberID) then
				local tbMember = Kin:GetMemberData(pMemberID)
				if tbMember and tbMember.nCareer==Kin.Def.Career_New then
					nKinNewScore = TeamFuben.KIN_NEWER_SCROE;
				end

				nCurScore = nCurScore + TeamFuben.SAME_KIN_SCROE;
			end

			self.tbMakeFriendList = self.tbMakeFriendList or {};
			self.tbMakeFriendList[pPlayer.dwID] = self.tbMakeFriendList[pPlayer.dwID] or {};
			local nAddScroe = 0;
			if self.tbMakeFriendList[pPlayer.dwID][pMemberID] then
				nAddScroe = TeamFuben:GetFriendLevelScroe(1);
			else
				local nImity = FriendShip:GetImity(pPlayer.dwID, pMemberID);
				local nImityLevel = FriendShip:GetImityLevel(nImity);
				nAddScroe = TeamFuben:GetFriendLevelScroe(nImityLevel);
			end

			if nAddScroe and nAddScroe > 0 then
				nCurScore = nCurScore + nAddScroe;
			end
		end
	end

	nCurScore = nCurScore + nKinNewScore;

	if self.nCostTime then
		for _, tbInfo in ipairs(TeamFuben.FubenTimeScroe) do
			if self.nCostTime <= tbInfo[1] then
				nCurScore = nCurScore + tbInfo[2];
				break;
			end
		end
	end

	pPlayer.CallClientScript("Fuben:SetScoro", nCurScore);

	if self.tbShowMissAward and self.tbShowMissAward[pPlayer.dwID] then
		pPlayer.CallClientScript("Fuben:OnUpdateMissionScroe", nCurScore);
	end
	return nCurScore, nKinNewScore > 0;
end

function tbFuben:OnPlayerDeath()
	me.CallClientScript("Ui:OpenWindow", "CommonDeathPopup", "AutoRevive", "您將在 %d 秒後復活", TeamFuben.REVIVE_TIME);
	self.tbReviveTimer[me.dwID] = Timer:Register(TeamFuben.REVIVE_TIME * Env.GAME_FPS, self.DoRevive, self, me.dwID);
end

function tbFuben:DoRevive(nPlayerId, bIsOut)
	if bIsOut and self.tbReviveTimer[nPlayerId] then
		Timer:Close(self.tbReviveTimer[nPlayerId]);
	end
	self.tbReviveTimer[nPlayerId] = nil;

	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end

	pPlayer.Revive(bIsOut and 1 or 0);
end

function tbFuben:OnKickOutAllPlayer(nTime)
	Timer:Register(Env.GAME_FPS * nTime, function ()
		self:KickOutAllPlayer();
	end);
end

function tbFuben:KickOutAllPlayer()
	local tbAllPlayer = KPlayer.GetMapPlayer(self.nMapId);
	for _, pPlayer in pairs(tbAllPlayer) do
		pPlayer.GotoEntryPoint();
	end
end

function tbFuben:OnAddMissionScore(nScore)
	self.nScore = self.nScore + nScore;

	local function fnUpdateScore(pPlayer)
		self:UpdatePlayerScore(pPlayer)
	end
	self:AllPlayerExcute(fnUpdateScore);
end

function tbFuben:GameWin()
	self.nCostTime = self.nCostTime or GetTime() - self.nStartTime;
	self:Close();
end

function tbFuben:GameLost()
	self:Close();
end

function tbFuben:OnClose()
	self.tbAllFinishPlayer = {};
	local tbAllPlayer = KPlayer.GetMapPlayer(self.nMapId);
	for _, pPlayer in pairs(tbAllPlayer) do
		self.tbAllFinishPlayer[pPlayer.dwID] = true;
		pPlayer.CallClientScript("Fuben:ShowLeave");
		LogD(Env.LOGD_ActivityPlay, pPlayer.szAccount, pPlayer.dwID, pPlayer.nLevel, string.format("%s_%s", self.nSectionIdx, self.nSubSectionIdx), Env.LOGD_VAL_FINISH_TASK, Env.LOGD_MIS_TEAM_FUBEN, pPlayer.GetFightPower());
	end

	self:OnKickOutAllPlayer(180);

	FriendRecall:OnTeamFubenAward(self.tbAllFinishPlayer);
end

function tbFuben:OnLog(...)
	Log(...);
end

function tbFuben:OnDropAward(szDropFile, nPosX, nPosY, nMsgId)
	local function fnDropAward(pPlayer)
		if self.tbPlayerScore[pPlayer.dwID] then
			local tbAward = Npc:RandomAward(1, szDropFile);
			local tbMsg = {};
			pPlayer.DropAward(nPosX, nPosY, tbMsg, tbAward, Env.LogWay_TeamFuben);
		end
	end
	self:AllPlayerExcute(fnDropAward);
end
