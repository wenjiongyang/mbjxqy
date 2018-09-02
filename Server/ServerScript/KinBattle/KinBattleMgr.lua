Require("CommonScript/KinBattle/KinBattleCommon.lua");

KinBattle.tbPreMapInstance = KinBattle.tbPreMapInstance or {};
KinBattle.tbPreMapInstByMapId = KinBattle.tbPreMapInstByMapId or {};
KinBattle.tbFightInstanceByMapId = KinBattle.tbFightInstanceByMapId or {};
KinBattle.tbFightInstanceByKinId = KinBattle.tbFightInstanceByKinId or {};

KinBattle.nState = KinBattle.nState or KinBattle.STATE_NONE;

function KinBattle:PreStartKinBattle(nWaitTime)
	Log("[KinBattle] PreStartKinBattle", nWaitTime);
	if self.nState ~= self.STATE_NONE then
		Log("[KinBattle] PreStartKinBattle Fail !! State Err !!", self.nState);
		return;
	end

	Calendar:OnActivityBegin("KinBattle");

	self.nState = self.STATE_PRE;
	self.nWaitTime = nWaitTime or self.nPreTime;
	self.nStartPreTime = GetTime();
	KPlayer.SendWorldNotify(1, 999, KinBattle.szStartWorldMsg, 1, 1);
	Timer:Register(Env.GAME_FPS * self.nWaitTime, function ()
		self:StartKinBattleFight();
	end);
end

function KinBattle:StartKinBattleFight()
	Log("[KinBattle] StartKinBattleFight");
	if self.nState ~= self.STATE_PRE then
		Log("[KinBattle] StartKinBattleFight Fail !! State Err !!", self.nState);
		return;
	end

	Calendar:OnActivityEnd("KinBattle");

	self.nState = self.STATE_FIGHT;
	self.tbFightInstanceByMapId = {};
	self.tbFightInstanceByKinId = {};

	if not self.nResultDate or self.nResultDate ~= Lib:GetLocalDay() or not self.tbAllKinBattleResult then
		self.nResultDate = Lib:GetLocalDay();
		self.tbAllKinBattleResult = {};
	end

	table.insert(self.tbAllKinBattleResult, {});
	self.tbKinBattleResult = self.tbAllKinBattleResult[#self.tbAllKinBattleResult];

	local tbAllKin = self:GetAllJoinKin();
	local tbKinMatchInfo, nByeKinId = self:MatchKinBattle(tbAllKin);
	if nByeKinId > 0 then
		self.tbKinBattleResult[nByeKinId] = {szOtherKinName = "輪空", tbInfo = {1, 1}, nWinCount = 2, nFailCount = 0, bIsFinish = true};
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, KinBattle.tbFightByeMsg, nByeKinId);
		self:KinBattleWin(nByeKinId);
		Log("[KinBattle] ByeKinId ", nByeKinId);
	end

	for _, tbKinInfo in pairs(tbKinMatchInfo) do
		Log("[KinBattle] match kinbattle", tbKinInfo[1], tbKinInfo[2]);
		self:CreateFightMap(tbKinInfo);
	end

	Timer:Register(Env.GAME_FPS * 5, self.ClearPreMap, self);
end

function KinBattle:EndKinBattle()
	self.nState = KinBattle.STATE_NONE;
end

function KinBattle:GetAllJoinKin()
	local tbKinList = {};
	Log("[KinBattle] start get all join kin --------------------");
	for nKinId, tbInst in pairs(self.tbPreMapInstance) do
		if tbInst.nPlayerCount > 0 then
			local tbKin = Kin:GetKinById(nKinId);
			if tbKin then
				Log("[KinBattle] GetAllJoinKin", nKinId, tbKin.szName, tbInst.nPlayerCount);
				table.insert(tbKinList, {nKinId, tbKin:GetPrestige() or 0});
			end
		end
	end

	local function fnSort(a, b)
		return a[2] > b[2];
	end

	table.sort(tbKinList, fnSort);

	local tbResult = {};
	for _, tbInfo in ipairs(tbKinList) do
		table.insert(tbResult, tbInfo[1]);
	end

	return tbResult;
end

function KinBattle:MatchKinBattle(tbAllKin)
	local tbRankInfo = {1};
	for nIdx, nValue in ipairs(self.tbKinRankSetting) do
		if #tbAllKin - nValue > 1 then
			table.insert(tbRankInfo, nValue);
		else
			table.insert(tbRankInfo, #tbAllKin + 1);
			break;
		end
	end
	if tbRankInfo[#tbRankInfo] < (#tbAllKin + 1) then
		table.insert(tbRankInfo, #tbAllKin + 1);
	end

	local tbKinFightInfo = {};
	local nCurKinId = 0;
	for i = 1, (#tbRankInfo - 1) do
		local nCount = tbRankInfo[i + 1] - tbRankInfo[i];
		local fnGetKin = Lib:GetRandomSelect(nCount);
		for j = 1, nCount do
			local nNewKinIdx = fnGetKin() + tbRankInfo[i] - 1;
			local nNewKinId = tbAllKin[nNewKinIdx];
			if nCurKinId == 0 then
				nCurKinId = nNewKinId;
			else
				table.insert(tbKinFightInfo, {nCurKinId, nNewKinId});
				nCurKinId = 0;
			end
		end
	end

	return tbKinFightInfo, nCurKinId
end

function KinBattle:SendResultMail(nKinId, szText, nReason, tbAward, nPrestige)
	local tbKinData = Kin:GetKinById(nKinId);
	if not tbKinData then
		return;
	end

	tbKinData:AddPrestige(nPrestige, nReason);

	local tbMail =
	{
		To = nil;
		Title = "系統";
		Text = szText;
		From = "幫派管理員";
		tbAttach = tbAward;
		nLogReazon = nReason;
	}
	tbKinData:TraverseMembers(function (memberData)
		tbMail.To = memberData.nMemberId;
		Mail:SendSystemMail(tbMail);
		return true;
	end);
end

function KinBattle:KinBattleWin(nKinId)
	self.tbKinBattleResult[nKinId].nFinalResult = 1;

	KinBattle:SendResultMail(nKinId, KinBattle.szWinText, Env.LogWay_KinBattle_Win, KinBattle.tbWinAward, KinBattle.nWinPrestige);
end

function KinBattle:KinBattleFail(nKinId)
	self.tbKinBattleResult[nKinId].nFinalResult = 0;
	KinBattle:SendResultMail(nKinId, KinBattle.szFailText, Env.LogWay_KinBattle_Fail, KinBattle.tbFailAward, KinBattle.nFailPrestige);
end

function KinBattle:KinBattleDraw(nKinId)
	self.tbKinBattleResult[nKinId].nFinalResult = -1;
	KinBattle:SendResultMail(nKinId, KinBattle.szDrawText, Env.LogWay_KinBattle_Draw, KinBattle.tbDrawAward, KinBattle.nDrawPrestige);
end

function KinBattle:CreateFightMap(tbKinInfo)
	local nFirstKinId, nSecondKinId = unpack(tbKinInfo);
	local tbFirstInst, tbSecondInst = self.tbPreMapInstance[nFirstKinId], self.tbPreMapInstance[nSecondKinId];
	if not tbFirstInst or not tbSecondInst then
		return;
	end

	local tbFirstKin = Kin:GetKinById(nFirstKinId);
	local tbSecondKin = Kin:GetKinById(nSecondKinId);

	self.tbKinBattleResult[nFirstKinId] = self.tbKinBattleResult[nFirstKinId] or {};
	self.tbKinBattleResult[nFirstKinId].szOtherKinName = tbSecondKin.szName;
	self.tbKinBattleResult[nSecondKinId] = self.tbKinBattleResult[nSecondKinId] or {};
	self.tbKinBattleResult[nSecondKinId].szOtherKinName = tbFirstKin.szName;

	local tbNeedOpenType = {};
	for nType = 1, self.nKinBattleTypeCount do
		if tbFirstInst.tbPlayerCount[nType] <= 0 or tbSecondInst.tbPlayerCount[nType] <= 0 then
			if tbFirstInst.tbPlayerCount[nType] == tbSecondInst.tbPlayerCount[nType] then
				KinBattle:SetKinBattleResult(nFirstKinId, nType, -1);
				KinBattle:SetKinBattleResult(nSecondKinId, nType, -1);
			else
				KinBattle:SetKinBattleResult(nFirstKinId, nType, tbFirstInst.tbPlayerCount[nType] == 0 and 0 or 1);
				KinBattle:SetKinBattleResult(nSecondKinId, nType, tbSecondInst.tbPlayerCount[nType] == 0 and 0 or 1);
			end
		else
			table.insert(tbNeedOpenType, nType);
		end
	end

	for _, nType in pairs(tbNeedOpenType) do
		local tbFightInst = Lib:NewClass(self.FightMapClass);
		local nMapId = CreateMap(self.FIGHT_MAP_ID);

		tbFightInst:Init(nMapId, tbKinInfo, nType);
		self.tbFightInstanceByMapId[nMapId] = tbFightInst;
		self.tbFightInstanceByKinId[nFirstKinId] = tbFightInst;
		self.tbFightInstanceByKinId[nSecondKinId] = tbFightInst;
	end
end

function KinBattle:OnFightMapCreate(nMapId)
	local tbFightInst = self.tbFightInstanceByMapId[nMapId];
	for _, nKinId in pairs(tbFightInst.tbKinInfo) do
		local tbPreInst = self.tbPreMapInstance[nKinId];
		local tbMapPlayer = KPlayer.GetMapPlayer(tbPreInst.nMapId);
		for _, pPlayer in pairs(tbMapPlayer) do
			local nKinBattleType = pPlayer.nKinBattleType or 0;
			if nKinBattleType == tbFightInst.nKinBattleType then
				pPlayer.SwitchMap(nMapId, 0, 0);
			end
		end
	end
	tbFightInst:Start();
end

function KinBattle:SetKinBattleResult(nKinId, nKinBattleType, nType)
	Log("[KinBattle] SetKinBattleResult", nKinId, nKinBattleType, nType);

	if KinBattle.tbResultKinMsg[nType] then
		local szMsg = string.format(KinBattle.tbResultKinMsg[nType], nKinBattleType == 1 and "一" or "二");
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, nKinId);
	end

	self.tbKinBattleResult[nKinId].nCount = self.tbKinBattleResult[nKinId].nCount or 0;
	self.tbKinBattleResult[nKinId].nCount = self.tbKinBattleResult[nKinId].nCount + 1;

	self.tbKinBattleResult[nKinId].tbInfo = self.tbKinBattleResult[nKinId].tbInfo or {};
	self.tbKinBattleResult[nKinId].tbInfo[nKinBattleType] = nType;

	self.tbKinBattleResult[nKinId].nWinCount = self.tbKinBattleResult[nKinId].nWinCount or 0;
	self.tbKinBattleResult[nKinId].nWinCount = self.tbKinBattleResult[nKinId].nWinCount + (nType == 1 and 1 or 0);

	self.tbKinBattleResult[nKinId].nFailCount = self.tbKinBattleResult[nKinId].nFailCount or 0;
	self.tbKinBattleResult[nKinId].nFailCount = self.tbKinBattleResult[nKinId].nFailCount + (nType == 0 and 1 or 0);

	if not self.tbKinBattleResult[nKinId].bIsFinish and self.tbKinBattleResult[nKinId].nCount == self.nKinBattleTypeCount then
		self.tbKinBattleResult[nKinId].bIsFinish = true;
		if self.tbKinBattleResult[nKinId].nWinCount < self.tbKinBattleResult[nKinId].nFailCount then
			self:KinBattleFail(nKinId);
		elseif self.tbKinBattleResult[nKinId].nWinCount > self.tbKinBattleResult[nKinId].nFailCount then
			self:KinBattleWin(nKinId);
		else
			self:KinBattleDraw(nKinId);
		end
	end
end

function KinBattle:ClearPreMap()
	for nMapId, tbInst in pairs(self.tbPreMapInstByMapId) do
		tbInst:DoClearPlayer();
	end

	self.tbPreMapInstance = {};
	self.tbPreMapInstByMapId = {};
	self:CheckKinBattleEnd();
end

function KinBattle:CheckKinBattleEnd()
	local nCount = 0;
	for _, tbFightInst in pairs(self.tbFightInstanceByMapId) do
		nCount = nCount + 1;
	end

	local bClose = false;
	for _, tbFightInst in pairs(self.tbFightInstanceByMapId) do
		if tbFightInst.nIsClose and tbFightInst.nIsClose == 1 then
			bClose = true;
		end
	end

	if bClose or nCount == 0 then
		self.nState = KinBattle.STATE_NONE;
	end
end

function KinBattle:CheckCanJoinPreMap(pPlayer, nType)
	if self.nState == self.STATE_FIGHT then
		return false, "準備期已過，無法入場"
	end

	if self.nState ~= self.STATE_PRE then
		return false, "目前活動未開啟";
	end

	local tbKinData = Kin:GetKinById(pPlayer.dwKinId);
	if not tbKinData then
		return false, "沒有幫派，無法入場";
	end

	if tbKinData.nKinBattleMinLevel and tbKinData.nKinBattleMinLevel > pPlayer.nLevel then
		return false, "等級過低，無法參與活動";
	end

	if pPlayer.nState == Player.emPLAYER_STATE_ALONE then
		return false, "暫時無法進入，結束目前活動再來吧";
	end

	if not Fuben.tbSafeMap[pPlayer.nMapTemplateId] and Map:GetClassDesc(pPlayer.nMapTemplateId) ~= "fight" then
		return false, "所在地圖，不允許進入！";
	end

	if Map:GetClassDesc(pPlayer.nMapTemplateId) == "fight" and pPlayer.nFightMode ~= 0 then
		return false, "不在安全區，不允許進入！";
	end

	local tbPreInst = self.tbPreMapInstance[pPlayer.dwKinId];
	if tbPreInst and tbPreInst.tbPlayerCount and tbPreInst.tbPlayerCount[nType] >= self.MAX_PLAYER_COUNT then
		return false, "本場人數已滿，無法加入";
	end

	return true;
end

function KinBattle:SetLevelLimite(pPlayer, nMinLevel)
	local tbKin = Kin:GetKinById(pPlayer.dwKinId);
	if not tbKin then
		return;
	end

	if tbKin.nMasterId ~= pPlayer.dwID then
		return false;
	end

	tbKin.nKinBattleMinLevel = math.min(math.max(nMinLevel, 1), 200);
	tbKin:Save();

	self:GetCurrentData(pPlayer);
end

function KinBattle:GetCurrentData(pPlayer)
	local nKinId = pPlayer.dwKinId;
	local tbKin = Kin:GetKinById(nKinId);
	if not tbKin then
		return;
	end

	if not self.nResultDate or self.nResultDate ~= Lib:GetLocalDay() or not self.tbAllKinBattleResult then
		self.nResultDate = Lib:GetLocalDay();
		self.tbAllKinBattleResult = {};
	end

	local tbResult = {};
	for _, tbKinResult in pairs(self.tbAllKinBattleResult or {}) do
		table.insert(tbResult, tbKinResult[nKinId] or {});
	end

	local tbPreMapPlayerCount = {};
	local tbPreInst = self.tbPreMapInstance[nKinId];
	for nType = 1, self.nKinBattleTypeCount do
		tbPreMapPlayerCount[nType] = 0;
		if tbPreInst and tbPreInst.tbPlayerCount then
			tbPreMapPlayerCount[nType] = tbPreInst.tbPlayerCount[nType] or 0;
		end
	end

	local tbData = {
		bIsKinMaster = (tbKin.nMasterId == pPlayer.dwID);
		nState = self.nState;
		tbResult = tbResult;
		tbPreMapPlayerCount = tbPreMapPlayerCount;
		nKinBattleMinLevel = tbKin.nKinBattleMinLevel or 0;
	};

	pPlayer.CallClientScript("Battle:OnSyncKinBattleData", tbData);
end

function KinBattle:TryJoinPreMap(pPlayer, nType)
	local bRet, szMsg = self:CheckCanJoinPreMap(pPlayer, nType);
	if not bRet then
		pPlayer.CenterMsg(szMsg);
		return;
	end

	assert(self.nState == self.STATE_PRE);

	local tbInst = self.tbPreMapInstance[pPlayer.dwKinId];
	if not tbInst then
		self.tbPreMapInstance[pPlayer.dwKinId] = Lib:NewClass(self.PreMapClass);
		tbInst = self.tbPreMapInstance[pPlayer.dwKinId];
		tbInst.dwKinId = pPlayer.dwKinId;
		tbInst.bLoadOK = false;
		tbInst.nMapId = CreateMap(self.PRE_MAP_ID);
		tbInst.nPlayerCount = 0;
		self.tbPreMapInstByMapId[tbInst.nMapId] = tbInst;
	end

	if not tbInst.bLoadOK then
		tbInst.tbWaitList = tbInst.tbWaitList or {};
		table.insert(tbInst.tbWaitList, {pPlayer.dwID, nType});
		return;
	end

	pPlayer.nKinBattleType = nType;
	pPlayer.SetEntryPoint();
	pPlayer.SwitchMap(tbInst.nMapId, unpack(self.tbPreMapBeginPos));
end

function KinBattle:OnPreMapCreate(nMapId)
	local tbInst = self.tbPreMapInstByMapId[nMapId];
	tbInst.bLoadOK = true;

	local tbWaitList = tbInst.tbWaitList;
	tbInst.tbWaitList = {};

	for _, tbInfo in pairs(tbWaitList) do
		local pPlayer = KPlayer.GetPlayerObjById(tbInfo[1]);
		if pPlayer then
			self:TryJoinPreMap(pPlayer, tbInfo[2]);
		end
	end

	--开启家族实时语音
	if not ChatMgr:IsKinHaveChatRoom(tbInst.dwKinId) then
		ChatMgr:CreateKinChatRoom(tbInst.dwKinId)
	end
end

function KinBattle:OnCreateChatRoom(dwKinId, uRoomHighId, uRoomLowId)
	local bInUse = false;
	if self.nState == self.STATE_NONE then
		return bInUse;
	end

	local tbPreInst = self.tbPreMapInstance[dwKinId];

	if tbPreInst then
		tbPreInst:MemberJoinKinChatRoom();
		bInUse = true;
	end

	local tbFightInst = self.tbFightInstanceByKinId[dwKinId];

	if tbFightInst then
		tbFightInst:MemberJoinKinChatRoom(dwKinId);
		bInUse = true;
	end

	return bInUse;
end
