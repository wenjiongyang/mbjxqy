Require("CommonScript/Fuben/RandomFubenCommon.lua");

local tbFuben = Fuben:CreateFubenClass("RandomFubenBase");
local RandomFuben = Fuben.RandomFuben;
function tbFuben:OnCreate(nRandomCount, tbScoreInfo, tbDropAward, nCostTime, nWinCount, nFubenLevel)
	self.nFubenLevel = nFubenLevel;
	self.nRoomLevel = self.nRoomLevel or 1;
	self.nRandomCount = nRandomCount or 1;
	self.nCostTime = nCostTime or 0;
	self.nWinCount = nWinCount or 0;
	self.tbScoreInfo = tbScoreInfo or {};
	self.tbDropAward = tbDropAward or {};
	self.nMapTemplateId = self.nMapTemplateId or -1;
	self.nChangeTime = 0;

	self.tbDeathInfo = {};
	self:Start();
end

function tbFuben:OnStart()
	self.nRealStartTime = GetTime();

	local function fnUpdateScore(pPlayer)
		self:UpdatePlayerScore(pPlayer)
	end
	self:AllPlayerExcute(fnUpdateScore);
end

function tbFuben:OnLogin(bReConnect)
	me.CallClientScript("Fuben:ClearClientData");
	me.CallClientScript("Ui:OpenWindow", "HomeScreenFuben", "RandomFuben");
	if self.nShowEndTime and self.nShowEndTime > 0 then
		me.CallClientScript("Fuben:SetEndTime", self.bClose == 1 and 0 or self.nShowEndTime);
	end

	if self.bClose == 1 then
		me.CallClientScript("Fuben:ShowLeave");
	end
end

function tbFuben:GetNumber(value)
	if type(value) == "number" then
		return value;
	end

	return Fuben.RandomFuben:GetNumber(value, self.nFubenLevel);
end

function tbFuben:OnFirstJoin(pPlayer)
	Timer:Register(Env.GAME_FPS * 5, function (nPlayerId)
		local pP = KPlayer.GetPlayerObjById(nPlayerId);
		if pP then
			pP.SendBlackBoardMsg("秘境即將開啟，原地等待隊友集合後進行探險！");
		end
	end, pPlayer.dwID);

	if self.nRandomCount == 1 then
		DegreeCtrl:ReduceDegree(pPlayer, "RandomFuben", 1);
		EverydayTarget:AddCount(pPlayer, "RandomFuben");
	end
end

function tbFuben:OnChangeTime(nTime)
	self.nChangeTime = self.nChangeTime or 0;
	self.nChangeTime = self.nChangeTime + nTime;
end

function tbFuben:OnJoinKin(dwKinId)
	if not self.bIsMissionAward then
		return;
	end

	local tbAllPlayer = KPlayer.GetMapPlayer(self.nMapId);
	for _, pPlayer in pairs(tbAllPlayer) do
		if pPlayer.dwKinId == dwKinId then
			self:UpdatePlayerScore(pPlayer);
		end
	end
end

function tbFuben:OnNpcDrop(tbAward)
	self.tbDropAward[me.dwID] = self.tbDropAward[me.dwID] or {};
	local tbDrop = self.tbDropAward[me.dwID];
	for _, tbInfo in pairs(tbAward) do
		local nAwardType = Player.AwardType[tbInfo[1]];
		if nAwardType == Player.award_type_money and (tbInfo[1] == "Coin" or tbInfo[1] == "coin") then
			tbDrop.nCoin = (tbDrop.nCoin or 0) + tbInfo[2];
		elseif nAwardType == Player.award_type_exp then
			tbDrop.nExp = (tbDrop.nExp or 0) + tbInfo[2];
		elseif nAwardType == Player.award_type_item or
			nAwardType == Player.award_type_money or
			nAwardType == Player.award_type_partner then

			tbDrop.tbOther = tbDrop.tbOther or {};
			table.insert(tbDrop.tbOther, tbInfo);
		end
	end

	local nItemCount = tbDrop.tbOther and #tbDrop.tbOther or 0;
	me.CallClientScript("Fuben:SetShowInfo", nItemCount, tbDrop.nCoin or 0);
end

function tbFuben:OnJoin(pPlayer)
	local teamData = TeamMgr:GetTeamById(pPlayer.dwTeamID);
	if teamData then
		self.nTeamLeader = teamData.nCaptainID;
	end
	self.tbPlayer[pPlayer.dwID].nJoinKinCallbackId = PlayerEvent:Register(pPlayer, "OnJoinKin", self.OnJoinKin, self);
	self.tbPlayer[pPlayer.dwID].nNpcDropCallbackId = PlayerEvent:Register(pPlayer, "OnNpcDrop", self.OnNpcDrop, self);
	pPlayer.CallClientScript("Fuben:ClearClientData");
	pPlayer.CallClientScript("Ui:OpenWindow", "HomeScreenFuben", "RandomFuben");
	pPlayer.CallClientScript("Fuben:CloseLeave");
	pPlayer.RestoreAll();
	self:UpdatePlayerScore(pPlayer);
end

function tbFuben:OnLeaveMap(pPlayer)
	if self.tbPlayer[pPlayer.dwID].nJoinKinCallbackId then
		PlayerEvent:UnRegister(pPlayer, "OnJoinKin", self.tbPlayer[pPlayer.dwID].nJoinKinCallbackId);
		self.tbPlayer[pPlayer.dwID].nJoinKinCallbackId = nil;
	end

	if self.tbPlayer[pPlayer.dwID].nNpcDropCallbackId then
		PlayerEvent:UnRegister(pPlayer, "OnNpcDrop", self.tbPlayer[pPlayer.dwID].nNpcDropCallbackId);
		self.tbPlayer[pPlayer.dwID].nNpcDropCallbackId = nil;
	end

	if self.nRandomCount >= RandomFuben.RANDOM_COUNT then
		self:ConfirmFubenMission(pPlayer, true);
	end

	pPlayer.CallClientScript("Ui:CloseWindow", "HomeScreenFuben");
	pPlayer.Revive(1);
	pPlayer.RestoreAll();
	self:ClearDeathState(pPlayer);
end

function tbFuben:OnOut(pPlayer)
	self:ClearDeathState(pPlayer);
end

function tbFuben:OnPlayerDeath()
	me.nFightMode = 2;
	self.tbDeathInfo[me.dwID] = (self.tbDeathInfo[me.dwID] or 0) + 1;
	local nReviveTime = self.tbDeathInfo[me.dwID] * RandomFuben.nReviveAddTime;
	local nDeathSkillId = RandomFuben.DEATH_SKILLID;

	Timer:Register(nReviveTime * Env.GAME_FPS, self.DoRevive, self, me.dwID);
	me.SendBlackBoardMsg(string.format("您已身受重傷，將於%s秒後復活", nReviveTime));

	me.Revive(1);
	me.RestoreAll();
	me.AddSkillState(nDeathSkillId, 1, 0, 10000);
end

function tbFuben:DoRevive(nPlayerId)
	if self.bClose == 1 then
		return;
	end

	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end

	if pPlayer.nFightMode ~= 2 then
		return;
	end

	if self.tbDynamicRevivePoint then
		pPlayer.SetPosition(unpack(self.tbDynamicRevivePoint));
	elseif self.tbSetting.tbTempRevivePoint then
		pPlayer.SetPosition(unpack(self.tbSetting.tbTempRevivePoint));
	end

	self:ClearDeathState(pPlayer);
end

function tbFuben:ClearDeathState(pPlayer)
	pPlayer.RemoveSkillState(RandomFuben.DEATH_SKILLID);
	pPlayer.RemoveSkillState(RandomFuben.DEATH_SKILLID2);
	pPlayer.bRandomFubenRealDeath = nil;
	pPlayer.nFightMode = 1;
end

function tbFuben:FinishGame()
	if self.nCostTime then
		for _, tbInfo in ipairs(RandomFuben.tbTimeScroe) do
			if self.nCostTime <= tbInfo[1] then
				self:OnAddMissionScore(tbInfo[2]);
				break;
			end
		end
	end

	local fnExcute = function (pPlayer)
		self:ClearDeathState(pPlayer);
		local function fnShowMA(nPlayerId)
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer and pPlayer.nMapId == self.nMapId then
				self:ShowMissionAward(pPlayer);
			end
		end
		Timer:Register(Env.GAME_FPS, fnShowMA, pPlayer.dwID);
		pPlayer.CallClientScript("Fuben:ShowLeave");

		local szMsg = self.nWinCount >= RandomFuben.RANDOM_COUNT and "完美闖關" or "闖關成功 離開凌絕峰";
		pPlayer.CallClientScript("Fuben:SetFubenProgress", -1, szMsg);

		szMsg = self.nWinCount >= RandomFuben.RANDOM_COUNT and "恭喜您闖關成功！篝火已刷出可持續獲得經驗！" or "恭喜您闖關成功，現在可以離開了！";
		pPlayer.SendBlackBoardMsg(szMsg, 1);
	end

	self:AllPlayerExcute(fnExcute);

	if self.nWinCount < RandomFuben.RANDOM_COUNT then
		self:OnKickOutAllPlayer(10);
	end

	Timer:Register(Env.GAME_FPS, self.GotoEndPos, self);
end

function tbFuben:GotoEndPos()
	if not self.tbEndPos then
		return;
	end

	local fnExcute = function (pPlayer)
		pPlayer.SetPosition(unpack(self.tbEndPos));
	end

	self:AllPlayerExcute(fnExcute);
end

tbFuben.tbAchievement = {"RandomFuben_1", "RandomFuben_2", "RandomFuben_3", "RandomFuben_4", "RandomFuben_5"};
function tbFuben:GameWin()
	if self.bClose == 1 then
		return;
	end

	self.nWinCount = self.nWinCount + 1;
	local szAchievement = self.tbAchievement[self.nRoomLevel];
	local fnExcute = function (pPlayer)
		Achievement:AddCount(pPlayer, szAchievement, 1);
	end

	if szAchievement then
		self:AllPlayerExcute(fnExcute);
	end

	local nTimeNow = GetTime();
	self.nCostTime = self.nCostTime + math.max(nTimeNow - self.nRealStartTime + self.nChangeTime, 0);
	if self.nRandomCount >= RandomFuben.RANDOM_COUNT then
		self:FinishGame();
	else
		local fnExcute = function (pPlayer)
			pPlayer.CallClientScript("Fuben:SetEndTime", GetTime() + RandomFuben.AFTER_END_TIME);
			pPlayer.CallClientScript("Fuben:SetFubenProgress", -1, "繼續探索凌絕峰");
		end
		self:AllPlayerExcute(fnExcute);
		Timer:Register(Env.GAME_FPS * RandomFuben.AFTER_END_TIME, self.JoinToNextRoom, self, self.nRoomLevel + 1);
	end
	self:Close();
end

function tbFuben:GameLost()
	if self.bClose == 1 then
		return;
	end

	local nTimeNow = GetTime();
	self.nCostTime = self.nCostTime + math.max(nTimeNow - self.nRealStartTime + self.nChangeTime, 0);
	if self.nRandomCount >= RandomFuben.RANDOM_COUNT then
		self:FinishGame();
	else
		local fnExcute = function (pPlayer)
			pPlayer.CallClientScript("Fuben:SetEndTime", GetTime() + RandomFuben.AFTER_END_TIME);
			pPlayer.CallClientScript("Fuben:SetFubenProgress", -1, "另尋道路上山");
		end
		self:AllPlayerExcute(fnExcute);
		Timer:Register(Env.GAME_FPS * RandomFuben.AFTER_END_TIME, self.JoinToNextRoom, self, self.nRoomLevel);
	end
	self:Close();
end

function tbFuben:JoinToNextRoom(nLevel)
	local nMapTemplateId;
	if nLevel == self.nRoomLevel then
		nMapTemplateId = self.nMapTemplateId;
	end
	local nMapTemplateId = RandomFuben:GetRoom(nLevel, nMapTemplateId);

	local function fnSucess(nMapId)
		local tbAllPlayer = KPlayer.GetMapPlayer(self.nMapId);
		for _, pPlayer in pairs(tbAllPlayer) do
			pPlayer.SwitchMap(nMapId, 0, 0);
		end
	end

	local function fnFailed()
		--
	end

	Fuben:ApplyFubenUseLevel(-1, nMapTemplateId, self.nFubenLevel, fnSucess, fnFailed, self.nRandomCount + 1, self.tbScoreInfo, self.tbDropAward, self.nCostTime, self.nWinCount, self.nFubenLevel);
end

function tbFuben:GetScore()
	local nResult = 0;
	for _, nScore in pairs(self.tbScoreInfo or {}) do
		nResult = nResult + nScore;
	end
	return nResult;
end

function tbFuben:DoFubenClickMakeFriend(pPlayer, nOtherPlayerId)
	self.tbMakeFriendList = self.tbMakeFriendList or {};
	self.tbMakeFriendList[pPlayer.dwID] = self.tbMakeFriendList[pPlayer.dwID] or {};
	self.tbMakeFriendList[pPlayer.dwID][nOtherPlayerId] = true;
	self:UpdatePlayerScore(pPlayer);
end

function tbFuben:UpdatePlayerScore(pPlayer)
	local nCurScore = self:GetScore();
	if not self.nRealStartTime or nCurScore <= 0 then
		return 0;
	end

	local nAddScore = 0;
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
				if tbMember and tbMember.nCareer == Kin.Def.Career_New then
					nKinNewScore = RandomFuben.KIN_NEWER_SCROE;
				end

				nAddScore = nAddScore + RandomFuben.SAME_KIN_SCROE;
			end

			self.tbMakeFriendList = self.tbMakeFriendList or {};
			self.tbMakeFriendList[pPlayer.dwID] = self.tbMakeFriendList[pPlayer.dwID] or {};
			local nAdd = 0;
			if self.tbMakeFriendList[pPlayer.dwID][pMemberID] then
				nAdd = RandomFuben:GetFriendLevelScroe(1);
			else
				local nImity = FriendShip:GetImity(pPlayer.dwID, pMemberID);
				local nImityLevel = FriendShip:GetImityLevel(nImity);
				nAdd = RandomFuben:GetFriendLevelScroe(nImityLevel);
			end

			if nAdd and nAdd > 0 then
				nAddScore = nAddScore + nAdd;
			end
		end
	end

	nAddScore = nAddScore + nKinNewScore;

	pPlayer.CallClientScript("Fuben:SetScoro", nCurScore + nAddScore);

	if self.tbShowMissAward and self.tbShowMissAward[pPlayer.dwID] then
		pPlayer.CallClientScript("Fuben:OnUpdateMissionScroe", nCurScore + nAddScore);
	end

	return nCurScore + nAddScore, nAddScore, nKinNewScore > 0;
end

function tbFuben:OnAddMissionScore(nScore)
	nScore = self:GetNumber(nScore);
	local fnExcute = function (pPlayer)
		self:UpdatePlayerScore(pPlayer);
	end
	self:AllPlayerExcute(fnExcute);
	self.tbScoreInfo[self.nRandomCount] = (self.tbScoreInfo[self.nRandomCount] or 0) + nScore;
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
				dwKinId = pMember.dwKinId,
			};
			table.insert(tbResult, tbInfo);
		end
	end
	return tbResult;
end

function tbFuben:ShowMissionAward(pPlayer)
	if self.nRandomCount < RandomFuben.RANDOM_COUNT then
		return;
	end

	self.bIsMissionAward = true;

	local nScroe, _, bHasNewPlayer = self:UpdatePlayerScore(pPlayer);
	local tbMember = self:GetMember(pPlayer);

	pPlayer.CallClientScript("Ui:OpenWindow", "RandomFubenMission", "", nScroe, tbMember, self.nCostTime, self.tbDropAward[pPlayer.dwID], self.tbScoreInfo, bHasNewPlayer, self.nFubenLevel);
	self.tbShowMissAward = self.tbShowMissAward or {};
	self.tbShowMissAward[pPlayer.dwID] = true;
end

function tbFuben:ConfirmFubenMission(pPlayer, bIsLeaveMap, bNotShowMissionAward)
	if not bIsLeaveMap and not self.bIsMissionAward then
		return;
	end

	self.tbConfirmAward = self.tbConfirmAward or {};
	if self.tbConfirmAward[pPlayer.dwID] then
		return;
	end
	self.tbConfirmAward[pPlayer.dwID] = 1;

	local nScroe, nAddScore = self:UpdatePlayerScore(pPlayer);
	local nGrade, szType = MissionAward:GetGrade(MissionAward.emType_RandomFuben, nScroe);
	local nAddImitity = MissionAward:GetAddImity(MissionAward.emType_RandomFuben, nGrade);
	self.tbAddImityPlayer = self.tbAddImityPlayer or {};
	self.tbAddImityPlayer[pPlayer.dwID] = true;
	for nPlayerId in pairs(self.tbAllFinishPlayer or {}) do
		if nPlayerId ~= pPlayer.dwID and not self.tbAddImityPlayer[nPlayerId] and FriendShip:IsFriend(pPlayer.dwID, nPlayerId) then
			FriendShip:AddImitity(pPlayer.dwID, nPlayerId, nAddImitity, Env.LogWay_RandomFuben);
		end
	end

	if self.nTeamLeader and self.nTeamLeader == pPlayer.dwID then
		local nLeaderExtAward = RandomFuben.tbTeamLeaderExtAward[nGrade] or 80;
		pPlayer.SendAward({{"Contrib", nLeaderExtAward}}, true, false, Env.LogWay_RandomFuben);

		if pPlayer.dwTeamID > 0 then
			local szMsg = string.format("本次評價為「%s」，隊長額外獲得%s點貢獻", MissionAward.tbGradeDesc[szType], nLeaderExtAward);
			ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Team, szMsg, pPlayer.dwTeamID);
		end
	end

	local tbExtMissAward = RandomFuben.tbExtMissAwardInfo[self.nFubenLevel];
	local tbExtAward = tbExtMissAward[nGrade];
	if tbExtAward then
		pPlayer.SendAward(tbExtAward, true, false, Env.LogWay_RandomFuben);
	end

	if nGrade == 1 then
		pPlayer.CallClientScript("GameSetting.Comment:OnEvent", GameSetting.Comment.Type_RandomFuben_SSS);
	end

	pPlayer.TLogRoundFlow(Env.LogWay_RandomFuben, pPlayer.nMapTemplateId, nScroe, self.nCostTime or 0, Env.LogRound_SUCCESS, 0, 0);
end

function tbFuben:OnClose()
	self.tbAllFinishPlayer = {};
	local tbAllPlayer = KPlayer.GetMapPlayer(self.nMapId);
	for _, pPlayer in pairs(tbAllPlayer) do
		self.tbAllFinishPlayer[pPlayer.dwID] = true;
	end

	if self.nRandomCount >= RandomFuben.RANDOM_COUNT then
		-- 真正结束了
		Timer:Register(Env.GAME_FPS * (RandomFuben.MAX_DEALY_TIME + RandomFuben.AFTER_END_TIME), self.KickOutAllPlayer, self);

		FriendRecall:OnRandomFubenAward(self.tbAllFinishPlayer);
	end
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

function tbFuben:OnCopyPlayer(nLockId, szGroup, szPointName, bRevive, nDir, nDealyTime, nEffectId, nEffectTime)
	local tbLock = self.tbLock[nLockId];
	local nPlayerCount = 0;
	local tbAllPlayer = KPlayer.GetMapPlayer(self.nMapId);
	local nMaxPos = #self.tbNpcPoint[szPointName];

	if not self.tbNpcPoint[string.format("_____copy_pos__%s_%s", szPointName, 1)] then
		for nIdx, tbPos in pairs(self.tbNpcPoint[szPointName]) do
			self.tbNpcPoint[string.format("_____copy_pos__%s_%s", szPointName, nIdx)] = {tbPos};
		end
	end

	local nCurIdx = 0;
	for _, pPlayer in pairs(tbAllPlayer) do
		nCurIdx = nCurIdx + 1;
		if nCurIdx > nMaxPos then
			nCurIdx = 1;
		end
		local tbNpcInfo = self.tbSetting.tbCopyPlayer[pPlayer.nFaction];
		if tbNpcInfo then
			self:_AddNpc(tbNpcInfo.nNpcIndex, 1, nLockId, szGroup, string.format("_____copy_pos__%s_%s", szPointName, nCurIdx), bRevive, nDir, nDealyTime, nEffectId, nEffectTime, "CopyPlayer", string.format(tbNpcInfo.szName, pPlayer.szName));
			nPlayerCount = nPlayerCount + 1;
		else
			Log("[RandomFuben] OnCopyPlayer ERR ?? self.tbSetting.tbCopyPlayer[pPlayer.nFaction] is nil !! ", pPlayer.nFaction);
		end
	end

	if tbLock then
		tbLock.nMultiNum = nPlayerCount;
	end
end

function tbFuben:OnAddNpc(pNpc, szType, szName)
	if szType ~= "CopyPlayer" then
		return;
	end

	pNpc.SetName(szName);
end

function tbFuben:OnDropAward(szDropFile, nPosX, nPosY, nMsgId)
	local function fnDropAward(pPlayer)
		local tbAward = Npc:RandomAward(1, szDropFile);
		local tbMsg = {};
		pPlayer.DropAward(nPosX, nPosY, tbMsg, tbAward, Env.LogWay_RandomFuben);
	end
	self:AllPlayerExcute(fnDropAward);
end

function tbFuben:OnKillNpc(pNpc, pKiller)
	CollectionSystem:OnRandomFubenKillNpc(pNpc, pKiller)
end

function tbFuben:OnDropCard(nCardId, nRate)
	if not CollectionSystem:IsInProcess(CollectionSystem.RANDOMFUBEN_ID) then
		return
	end

	local function fnAddCard(pPlayer)
		local nRandom = MathRandom(1000000)
		if nRate == -1 or nRate >= nRandom then
			CollectionSystem:AddCard(pPlayer, nCardId, CollectionSystem.CONDITION)
		end
	end
	self:AllPlayerExcute(fnAddCard)
end

function tbFuben:OnCheckCollectionAct(...)
	local bOpen = CollectionSystem:IsInProcess(CollectionSystem.RANDOMFUBEN_ID)
	if not bOpen then
		return
	end

	local tbEvent = {...}
	for _, tbInfo in ipairs(tbEvent) do
		self:OnEvent(unpack(tbInfo))
	end
end
