TeamBattle.nConnectIdxSpace = 100000;

function TeamBattle:StartTeamBattle_Cross()
	Log("[TeamBattle] StartTeamBattle_Cross");
	self.nStartTimerId = nil;
	self.nLastStartTime = GetTime();

	local nLimitFloor = self:ClcLimitFloor(self.tbFloorInfo);
	CallZoneClientScript(-1, "TeamBattle:OnSyncLimitFloor", nLimitFloor);

	local tbBattleTeamInfo = self:ClcBattleTeamInfo(self.tbFloorInfo, nLimitFloor);
	for _, tbBattle in pairs(tbBattleTeamInfo) do
		if #tbBattle == 1 then
			CallZoneClientScript(tbBattle[1][1], "TeamBattle:OnSyncResult", tbBattle[1][2], tbBattle[1][3] + 1, nil, true);
		elseif #tbBattle == 2 then
			self:StartFight(tbBattle);
		else
			Log("[TeamBattle_Cross] StartTeamBattle_Cross Err ?? #tbBattle Error !!", #tbBattle);
			Lib:LogTB(tbBattle);
		end
	end
end

function TeamBattle:ClcLimitFloor(tbFloorInfo)
	local nMaxEnterPlayerCount = KPlayer.GetOnlineLimit() - GetOnlinePlayerCount();
	local nLimitFloor = self.nMaxFloor_Cross;
	local nCurCount = 0;
	-- 按照当前服务器承载上限，从高层到底层，判断人数，超过上限时，低层的不在跨区服进行比赛，打回原服
	for i = self.nMaxFloor_Cross, 1, -1 do
		local tbFloor = tbFloorInfo[i];
		for _, tbInfo in pairs(tbFloor or {}) do
			nCurCount = nCurCount + (#tbInfo * self.nTeamMemeber);
		end

		if nCurCount > nMaxEnterPlayerCount then
			break;
		end

		nLimitFloor = i - 1;
	end
	return nLimitFloor;
end

function TeamBattle:ClcBattleTeamInfo(tbFloorInfo, nLimitFloor)
	local tbBattleTeamInfo = {};
	for nFloor, tbFloor in pairs(tbFloorInfo) do
		if nFloor > nLimitFloor then 		-- 低层次的就不要在跨区服比赛了，直接在原服
			local tbLastTeamInfo = nil;
			while true do 					-- 分派场次
				local bFinish = true;
				for nCurConnectIdx, tbInfo in pairs(tbFloor) do
					tbInfo.nUseIdx = tbInfo.nUseIdx or 1;
					if tbInfo.nUseIdx <= #tbInfo then
						local nTeamId = tbInfo[tbInfo.nUseIdx];
						if not tbLastTeamInfo then
							tbLastTeamInfo = {nCurConnectIdx, nTeamId, nFloor};
						else
							table.insert(tbBattleTeamInfo, {tbLastTeamInfo, {nCurConnectIdx, nTeamId, nFloor}})
							tbLastTeamInfo = nil;
						end
						tbInfo.nUseIdx = tbInfo.nUseIdx + 1;
					end

					if tbInfo.nUseIdx <= #tbInfo then
						bFinish = false;
					end
				end
				if bFinish then
					break;
				end
			end

			if tbLastTeamInfo then
				table.insert(tbBattleTeamInfo, {tbLastTeamInfo});
			end
		end
	end
	return tbBattleTeamInfo;
end

function TeamBattle:StartFight(tbBattleInfo)
	local nFloor = tbBattleInfo[1][3];
	local tbFloorMapInfo = TeamBattle.tbFightMapBeginPoint[nFloor];
	local tbFightMapInfo = tbFloorMapInfo[MathRandom(#tbFloorMapInfo)];
	local tbInst = Lib:NewClass(TeamBattle.tbFightMapClass);
	local nMapId = CreateMap(tbFightMapInfo[1]);

	self.tbTeamBattleFMInstByMapId = self.tbTeamBattleFMInstByMapId or {};
	self.tbTeamBattleFMInstByMapId[nMapId] = tbInst;

	local nFirstTId = TeamBattle:GetNewTeamId(tbBattleInfo[1][1], tbBattleInfo[1][2]);
	local nSecondTId = TeamBattle:GetNewTeamId(tbBattleInfo[2][1], tbBattleInfo[2][2]);
	local tbTeamInfo = {nFirstTId, nSecondTId};

	tbInst:Init(nMapId, nFloor, tbFightMapInfo, tbTeamInfo, self.tbAllTeamInfo, nil, function (nWinTeamId, nOtherTeamId)
		self:OnSendResult(nWinTeamId, nOtherTeamId, nFloor);
	end, TeamBattle.TYPE_NORMAL, 5, 5);

	Log(string.format("[TeamBattleMgr] start fight nFloor = %s, nTeam1 = %s, nTeam2 = %s, nMapId = %s", nFloor, tbTeamInfo[1], tbTeamInfo[2], nMapId));
end

function TeamBattle:OnSyncLimitFloor(nLimitFloor)
	Log("[TeamBattle] OnSyncLimitFloor ", nLimitFloor);
	if not self.tbCurZoneTeamBattleMgr or self.tbCurZoneTeamBattleMgr.nLimitFloor then
		return;
	end

	if self.tbCurZoneTeamBattleMgr.nOnSyncLimitFloorTimerId then
		Timer:Close(self.tbCurZoneTeamBattleMgr.nOnSyncLimitFloorTimerId);
		self.tbCurZoneTeamBattleMgr.nOnSyncLimitFloorTimerId = nil;
	end

	self.tbCurZoneTeamBattleMgr.nLimitFloor = nLimitFloor;
	self.tbCurZoneTeamBattleMgr:StartLimitFloorFight();
end

function TeamBattle:OnSendResult(nWinTeamId, nOtherTeamId, nFloor)
	local szWinTeamName = "";
	local nWinServerId = 0;
	local nLostPlayerId = 0;
	local szLostTeamName = "";
	local nLostServerId = 0;

	local function fnSendResult(nNewTeamId, tbResult, bWin)
		local nConnectIdx, nTeamId = TeamBattle:GetConnectInfoByTeamId(nNewTeamId);
		local tbShowInfo = {
								bWin = bWin,
								szWinTeamName = szWinTeamName,
								szLostTeamName = szLostTeamName,
								nWinServerId = nWinServerId,
								nLostServerId = nLostServerId,
								nLostPlayerId = nLostPlayerId
							};

		CallZoneClientScript(nConnectIdx, "TeamBattle:OnSyncResult", nTeamId, bWin and nFloor + 1 or nFloor, tbShowInfo);

		for _, nPlayerId in ipairs(self.tbAllTeamInfo[nNewTeamId]) do
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer then
				if bWin and nFloor >= (self.nMaxFloor_Cross - 1) then
					TeamBattle:SwitchToTopMap(pPlayer);
				else
					pPlayer.nCanLeaveMapId = pPlayer.nMapId;
					pPlayer.CallClientScript("TeamBattle:DealyShowTeamInfo");
					pPlayer.CallClientScript("Ui:OpenWindow", "QYHLeavePanel");
					pPlayer.CallClientScript("Map:SetCloseUiOnLeave", pPlayer.nMapId, "QYHLeavePanel");

					local nWinCount = self.tbAllCacheData[pPlayer.dwID][4] or 0;
					nWinCount = nWinCount + (bWin and 1 or 0)
					local tbAward, nAwardItemCount, nLastValue, nAddHonor, nTotalHonor = TeamBattle.tbMgrClass:GetPlayerAward(pPlayer, bWin and nFloor + 1 or nFloor);
					pPlayer.CallClientScript("Ui:OpenWindow", "TeamBattleResultPanel", bWin and nFloor + 1 or nFloor, tbResult, tbAward, TeamBattle.tbAddImityInfo[nWinCount], nAwardItemCount, nAddHonor);
				end
			end
		end
	end

	local function fnCheckInfo(nTeamId)
		local tbResult = {};
		for _, nPlayerId in ipairs(self.tbAllTeamInfo[nTeamId]) do
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer then
				pPlayer.nTeamBattleTotalKill = pPlayer.nTeamBattleTotalKill or 0;
				pPlayer.nTeamBattleTotalDeath = pPlayer.nTeamBattleTotalDeath or 0;
				if pPlayer.bTeamBattleLeader then
					szWinTeamName = nTeamId == nWinTeamId and pPlayer.szName or szWinTeamName;
					nWinServerId = nTeamId == nWinTeamId and pPlayer.nServerIdx or nWinServerId;
					szLostTeamName = nTeamId == nOtherTeamId and pPlayer.szName or szLostTeamName;
					nLostServerId = nTeamId == nOtherTeamId and pPlayer.nServerIdx or nLostServerId;
					nLostPlayerId = nTeamId == nOtherTeamId and pPlayer.dwID or nLostPlayerId;
				end

				tbResult[pPlayer.dwID] = {
					pPlayer.szName,
					pPlayer.nPortrait,
					pPlayer.nFaction,
					pPlayer.nLevel,
					pPlayer.nTeamBattleTotalKill,
					pPlayer.nTeamBattleTotalDeath,
				};
				pPlayer.nTeamBattleTotalDeath = nil;
				pPlayer.nTeamBattleTotalKill = nil;
			end
		end
		return tbResult;
	end

	local tbWinResult = fnCheckInfo(nWinTeamId);
	local tbOtherResult = fnCheckInfo(nOtherTeamId);

	fnSendResult(nWinTeamId, tbWinResult, true);
	fnSendResult(nOtherTeamId, tbOtherResult, false);
end

function TeamBattle:DoSyncTeamInfoToZoneServer(tbTeamBattleMgr)
	self.tbSendAwardInfo = {};
	self.tbCurZoneTeamBattleMgr = tbTeamBattleMgr;
	local tbCacheData = {};
	for nTeamId, tbMemeber in pairs(tbTeamBattleMgr.tbAllTeamInfo) do
		for _, nPlayerId in ipairs(tbMemeber) do
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer then
				local nCacheHonor = pPlayer.GetUserValue(TeamBattle.SAVE_GROUP, TeamBattle.SAVE_HONOR);
				tbCacheData[nPlayerId] = {nCacheHonor, pPlayer.nTeamBattleTotalKill or 0, pPlayer.nTeamBattleTotalDeath or 0, self.tbCurZoneTeamBattleMgr.tbWinInfo[nTeamId]};
			end
		end
	end

	local tbAllTeamInfo = {};
	for nTId, tbMember in pairs(tbTeamBattleMgr.tbAllTeamInfo) do
		tbAllTeamInfo[nTId] = {};
		for _, nPlayerId in ipairs(tbMember) do
			table.insert(tbAllTeamInfo[nTId], nPlayerId);
		end
	end

	self.tbAllTeamInfo = tbAllTeamInfo;
	local tbTeamInfo = {};
	local tbCacheInfo = {};
	local nCount = 0;
	for nTId, tbMember in pairs(tbAllTeamInfo) do
		tbTeamInfo[nTId] = tbMember;
		for _, nPlayerId in pairs(tbMember) do
			tbCacheInfo[nPlayerId] = tbCacheData[nPlayerId];
		end
		nCount = nCount + 1;

		if nCount >= 50 then
			CallZoneServerScript("TeamBattle:OnSyncTeamInfo", {}, tbTeamInfo, tbCacheInfo);
			tbTeamInfo = {};
			tbCacheInfo = {};
			nCount = 0;
		end
	end

	CallZoneServerScript("TeamBattle:OnSyncTeamInfo", tbTeamBattleMgr.tbAllFloorInfo, tbTeamInfo, tbCacheInfo);
end

function TeamBattle:OnSyncTeamInfo(tbFloorInfo, tbTeamInfo, tbCacheData)
	Log("[TeamBattle] OnSyncTeamInfo", Server.nCurConnectIdx);
	Lib:LogData(tbFloorInfo, tbTeamInfo, tbCacheData);

	local nTimeNow = GetTime();
	self.nLastStartTime = self.nLastStartTime or 0;
	if not self.nStartTimerId then
		-- 开启过跨服通天塔5分钟内不允许重开
		if nTimeNow - self.nLastStartTime <= 300 then
			Log("[TeamBattle] OnSyncTeamInfo ERROR ?? nTimeNow - self.nLastStartTime <= 300");
			return;
		else
			self.nStartTimerId = Timer:Register(Env.GAME_FPS * 10, function ()
				self:StartTeamBattle_Cross();
			end)
			Log("[TeamBattle] Start Timer To StartTeamBattle_Cross");
		end
	end

	self.tbFloorInfo = self.tbFloorInfo or {};
	for nFloor, tbInfo in pairs(tbFloorInfo) do
		self.tbFloorInfo[nFloor] = self.tbFloorInfo[nFloor] or {};
		self.tbFloorInfo[nFloor][Server.nCurConnectIdx] = tbInfo;
	end

	self.tbAllTeamInfo = self.tbAllTeamInfo or {};
	for nTeamId, tbMember in pairs(tbTeamInfo) do
		local nNewTeamId = TeamBattle:GetNewTeamId(Server.nCurConnectIdx, nTeamId);
		self.tbAllTeamInfo[nNewTeamId] = tbMember;
	end

	self.tbAllCacheData = self.tbAllCacheData or {};
	for nPlayerId, tbInfo in pairs(tbCacheData) do
		self.tbAllCacheData[nPlayerId] = tbInfo;
	end
end

function TeamBattle:GetConnectInfoByTeamId(nNewTeamId)
	local nConnectIdx = math.floor(nNewTeamId / self.nConnectIdxSpace);
	local nTeamId = nNewTeamId % self.nConnectIdxSpace;
	return nConnectIdx, nTeamId;
end

function TeamBattle:GetNewTeamId(nConnectIdx, nTeamId)
	assert(nTeamId < self.nConnectIdxSpace);
	return nConnectIdx * self.nConnectIdxSpace + nTeamId;
end

function TeamBattle:OnSyncMapId(nTeamId, nMapId, tbPos)
	Log("[TeamBattle] Cross OnSyncMapId", nTeamId, nMapId, unpack(tbPos));
	for _, nPlayerId in pairs(self.tbAllTeamInfo[nTeamId] or {}) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			Log("[TeamBattle] Cross fnSwitchToZone ", pPlayer.szName, pPlayer.szAccount, pPlayer.dwID, nMapId, unpack(tbPos));
			pPlayer.GotoEntryPoint();

			local function fnSwitchToZone(nPlayerId, nDstMapId, tbDstPos)
				local pPlayerObj = KPlayer.GetPlayerObjById(nPlayerId)
				if not pPlayerObj then
					return
				end
				if not pPlayerObj.SwitchZoneMap(nDstMapId, unpack(tbDstPos)) then
					pPlayerObj.CenterMsg("地圖進入失敗");
				end
			end
			Timer:Register(2, fnSwitchToZone, pPlayer.dwID, nMapId, tbPos);
		end
	end
end

function TeamBattle:OnSyncResult(nTeamId, nFloor, tbShowInfo, bShowLeave)
	if not self.tbCurZoneTeamBattleMgr then
		Log(string.format("[TeamBattleMgr] Cross SendTeamAward ERR ?? self.tbCurZoneTeamBattleMgr is nil !! nTeamId = %s, nFloor = %s", nTeamId, nFloor));
		return;
	end

	local tbCheckInfo = {};
	local nWinCount = self.tbCurZoneTeamBattleMgr.tbWinInfo[nTeamId] or 0;
	nWinCount = nWinCount + ((tbShowInfo or {}).bWin and 1 or 0);
	local nAddImityCount = TeamBattle.tbAddImityInfo[nWinCount];
	local function fnSendAward(self, pPlayer, tbMember)
		self:SendPlayerAward(pPlayer, nFloor);

		for _, nPlayerId in ipairs(tbMember) do
			if nPlayerId ~= pPlayer.dwID then
				local nFirst = math.min(nPlayerId, pPlayer.dwID);
				local nSecond = math.max(pPlayer.dwID, nPlayerId);
				if not tbCheckInfo[nFirst] or not tbCheckInfo[nFirst][nSecond] then
					tbCheckInfo[nFirst] = tbCheckInfo[nFirst] or {};
					tbCheckInfo[nFirst][nSecond] = true;
					if FriendShip:IsFriend(nFirst, nSecond) then
						FriendShip:AddImitity(nFirst, nSecond, nAddImityCount, Env.LogWay_TeamBattle);
					end
				end
			end
		end

		if nFloor >= TeamBattle.nMaxFloor_Cross then
			if pPlayer.dwKinId > 0 then
				ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, string.format(TeamBattle.szTopKinNotify_Cross, pPlayer.szName), pPlayer.dwKinId);
			end

			KPlayer.SendWorldNotify(1, 999, string.format(TeamBattle.szTopWorldNotify_Cross, pPlayer.szName), 1, 1);
		end

		if nFloor == TeamBattle.nMaxFloor_Cross - 1 and tbShowInfo and pPlayer.dwID == tbShowInfo.nLostPlayerId then
			if pPlayer.dwKinId > 0 then
				ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, string.format(TeamBattle.szTopNotifyCrossLost, tbShowInfo.szLostTeamName or "", tbShowInfo.nWinServerId or 1, tbShowInfo.szWinTeamName or ""), pPlayer.dwKinId);
			end
		end

		if bShowLeave then
			pPlayer.nCanLeaveMapId = pPlayer.nMapId;
			pPlayer.CallClientScript("TeamBattle:DealyShowTeamInfo");
			pPlayer.CallClientScript("Ui:OpenWindow", "QYHLeavePanel");
			pPlayer.CallClientScript("Map:SetCloseUiOnLeave", pPlayer.nMapId, "QYHLeavePanel");
		end
	end

	self.tbSendAwardInfo = self.tbSendAwardInfo or {};
	if not self.tbSendAwardInfo[nTeamId] then
		self.tbSendAwardInfo[nTeamId] = true;
		self.tbCurZoneTeamBattleMgr:ForeachPlayer(nTeamId, fnSendAward);

		FriendRecall:OnTeamBattleAward(self.tbCurZoneTeamBattleMgr.tbAllTeamInfo[nTeamId]);
		Log(string.format("[TeamBattleMgr] Cross SendTeamAward nTeamId = %s, nFloor = %s", nTeamId, nFloor));
	else
		Log(string.format("[TeamBattleMgr] Cross SendTeamAward ERR ?? nTeamId = %s, nFloor = %s", nTeamId, nFloor));
	end

	if nFloor == self.nMaxFloor_Cross and tbShowInfo and tbShowInfo.nLostServerId > 0 and tbShowInfo.szWinTeamName ~= "" and tbShowInfo.szLostTeamName ~= "" then
		KPlayer.SendWorldNotify(1, 999, string.format(TeamBattle.szTopNotifyCrossWin, tbShowInfo.szWinTeamName or "", tbShowInfo.nLostServerId or 1, tbShowInfo.szLostTeamName or ""), 1, 1);
	end
end

function TeamBattle:OnSyncWin(dwPlayerID)
	local pPlayer = KPlayer.GetPlayerObjById(dwPlayerID);
	if pPlayer then
		RecordStone:AddRecordCount(pPlayer, "Tower", 1);
	end
end

function TeamBattle:ReportQQScore(playerOrId, nReportType, szReportData)
	local pPlayer = playerOrId;
	if type(playerOrId) == "number" then
		pPlayer = KPlayer.GetPlayerObjById(playerOrId);
	end
	if MODULE_ZONESERVER then
		CallZoneClientScript(pPlayer.nZoneIndex, "TeamBattle:ReportQQScore", pPlayer.dwID, nReportType, szReportData);
		return;
	end

	if not pPlayer then
		Log("[TeamBattle] ReportQQScore ERROR ?? pPlayer is nil !!", playerOrId, nReportType, szReportData);
		return;
	end

	Lib:CallBack({AssistClient.ReportQQScore, AssistClient, pPlayer, nReportType, szReportData, 0, 0});
	Log("[TeamBattle] ReportQQScore", pPlayer.dwID, pPlayer.szName, pPlayer.szAccount, nReportType, szReportData);
end

function TeamBattle:OnCrossPlayedTeamBattle( tbAllTeamInfo )
	for _, tbMember in pairs(tbAllTeamInfo) do
		for _, nPlayerId in ipairs(tbMember) do
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer then
				TeamBattle:OnPlayedTeamBattle(pPlayer)
			end
		end
	end
end