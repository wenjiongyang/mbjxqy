TeamBattle.tbMgrClass = TeamBattle.tbMgrClass or {};

local tbTeamBattleMgr = TeamBattle.tbMgrClass;

function tbTeamBattleMgr:Init(nPreMapId, nPreTime, bCross, nType)
	self.bCross = bCross;
	self.nPreTime = nPreTime;
	self.nPreMapId = nPreMapId;
	self.bIsLoadOK = false;
	self.tbAllTeamInfo = {};
	self.tbPlayerTeamId = {};
	self.bIsPreTime = true;
	self.tbFightInstByMapId = {};
	self.tbAllFloorInfo = {};
	self.nFightTimes = nil;
	self.tbWinInfo = {};
	self.nType = nType or TeamBattle.TYPE_NORMAL;

	local nMaxFloor = bCross and TeamBattle.nMaxFloor_Cross or TeamBattle.nMaxFloor;
	if MODULE_ZONESERVER and self.nType ~= TeamBattle.TYPE_NORMAL then
		nMaxFloor = TeamBattle.nMaxFloor_Cross;
	end

	for i = 1, nMaxFloor do
		self.tbAllFloorInfo[i] = {};
	end

	if nPreTime > 0 then
		self.nStartTimer = Timer:Register(Env.GAME_FPS * nPreTime + 1, self.TryStartFight, self);
		self.nNotifyPlayerCountTimer = Timer:Register(Env.GAME_FPS * 3, self.SyncPlayerCountInfo, self);
	end

	if MODULE_ZONESERVER then
		CallZoneClientScript(-1, "TeamBattle:OnSyncPreTime", true);
	end
end

function tbTeamBattleMgr:GetTeamId()
	self.nMaxTeamId = (self.nMaxTeamId or 0) + 1;
	while self.tbAllTeamInfo[self.nMaxTeamId] do
		self.nMaxTeamId = self.nMaxTeamId + 1;
	end
	return self.nMaxTeamId;
end

function tbTeamBattleMgr:NotifyTeamEnter(nPlayerId)
	self.tbPreUsedTeamId = self.tbPreUsedTeamId or {};
	self.tbPreUsedTeamId[nPlayerId] = self:GetTeamId();
end

function tbTeamBattleMgr:UpdateLeaguePlayerTeamInfo(nPlayerId, nLeaderId)
	local nTeamId = (self.tbPreUsedTeamId or {})[nLeaderId] or -1;
	self:UpdatePlayerTeamInfo(nPlayerId, nTeamId);
	assert(nTeamId > 0);
end

function tbTeamBattleMgr:UpdatePlayerTeamInfo(nPlayerId, nTeamId)
	local nOldTeamId = self.tbPlayerTeamId[nPlayerId] or -1;
	local tbMember = self.tbAllTeamInfo[nOldTeamId];
	for nIdx, nMemberId in ipairs(tbMember or {}) do
		if nMemberId == nPlayerId then
			table.remove(tbMember, nIdx);
			break;
		end
	end
	if tbMember and #tbMember == 0 then
		self.tbAllTeamInfo[nOldTeamId] = nil;
	end
	self.tbPlayerTeamId[nPlayerId] = nil;

	if nTeamId then
		self.tbPlayerTeamId[nPlayerId] = nTeamId;
		local tbMember = self.tbAllTeamInfo[nTeamId] or {};
		local bInTeam = false;
		for _, nMemberId in pairs(tbMember) do
			if nMemberId == nPlayerId then
				bInTeam = true;
				break;
			end
		end
		if not bInTeam then
			table.insert(tbMember, nPlayerId);
		end
		if not self.tbAllTeamInfo[nTeamId] then
			self.tbAllTeamInfo[nTeamId] = tbMember;
		end
	end
end

function tbTeamBattleMgr:ForeachPlayer(nTeamId, fnFunc, ...)
	local tbMember = self.tbAllTeamInfo[nTeamId];
	for nTTId, tbMember in pairs(self.tbAllTeamInfo) do
		if nTTId == nTeamId then
			for _, nPlayerId in ipairs(tbMember) do
				local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
				if pPlayer then
					fnFunc(self, pPlayer, tbMember, ...);
				end
			end
		end
	end
end

function tbTeamBattleMgr:AssignTeam()
	local tbAllMapPlayer = KPlayer.GetMapPlayer(self.nPreMapId);
	local tbAllPlayer = {};
	local tbSignlePlayer = {};
	for _, pPlayer in pairs(tbAllMapPlayer) do
		tbAllPlayer[pPlayer.dwID] = pPlayer;
		if not self.tbPlayerTeamId[pPlayer.dwID] then
			table.insert(tbSignlePlayer, pPlayer);
		end
	end

	for nPlayerId in pairs(self.tbPlayerTeamId) do
		if not tbAllPlayer[nPlayerId] then
			self:UpdatePlayerTeamInfo(nPlayerId);
		end
	end

	local tbNeedTeamInfo = {};
	for nTeamId, tbMember in pairs(self.tbAllTeamInfo) do
		local nType = TeamBattle.nTeamMemeber - #tbMember;
		tbNeedTeamInfo[nType] = tbNeedTeamInfo[nType] or {};
		table.insert(tbNeedTeamInfo[nType], nTeamId);
	end

	for i = 1, TeamBattle.nTeamMemeber do
		if #tbSignlePlayer <= 0 then
			break;
		end

		for _, nTeamId in pairs(tbNeedTeamInfo[i] or {}) do
			if #tbSignlePlayer <= 0 then
				break;
			end
			while #self.tbAllTeamInfo[nTeamId] < TeamBattle.nTeamMemeber do
				if #tbSignlePlayer <= 0 then
					break;
				end

				local nRandom = MathRandom(#tbSignlePlayer);
				local pPlayer = tbSignlePlayer[nRandom];
				self:UpdatePlayerTeamInfo(pPlayer.dwID, nTeamId);
				table.remove(tbSignlePlayer, nRandom);
			end
		end
	end

	while #tbSignlePlayer >= TeamBattle.nTeamMemeber do
		local nTeamId = self:GetTeamId();
		for i = 1, TeamBattle.nTeamMemeber do
			local nRandom = MathRandom(#tbSignlePlayer);
			self:UpdatePlayerTeamInfo(tbSignlePlayer[nRandom].dwID, nTeamId);
			table.remove(tbSignlePlayer, nRandom);
		end
	end

	local nTeamCount = 0;
	for _, tbMember in pairs(self.tbAllTeamInfo) do
		if #tbMember >= TeamBattle.nTeamMemeber then
			nTeamCount = nTeamCount + 1;
		end
	end

	Log("[TeamBattleMgr] AssignTeam current tbAllTeamInfo -----------------");
	Lib:LogTB(self.tbAllTeamInfo);

	local nFightCount = TeamBattle.nMaxFightTimes;
	local bResult = nTeamCount >= TeamBattle.nMinTeamCount;
	if self.nType ~= TeamBattle.TYPE_NORMAL then
		bResult = nTeamCount > 0;

		nFightCount = 0;
		local nNeedCount = 1;
		for i = 1, 5 do
			nNeedCount = nNeedCount * 2;
			if nTeamCount < nNeedCount then
				break;
			end
			nFightCount = nFightCount + 1;
		end
	end

	return bResult, nTeamCount, nFightCount;
end

function tbTeamBattleMgr:CostAllPlayerTimes()
	if MODULE_ZONESERVER then
		CallZoneClientScript(-1, "TeamBattle:OnCrossPlayedTeamBattle", self.tbAllTeamInfo);
		return;
	end

	for _, tbMember in pairs(self.tbAllTeamInfo) do
		for _, nPlayerId in ipairs(tbMember) do
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer then
				TeamBattle:CostTimes(pPlayer);
				SupplementAward:OnJoinActivity(pPlayer, "TeamBattle");
				EverydayTarget:AddCount(pPlayer, "TeamBattle", 1);
			else
				Log("[TeamBattle] CostAllPlayerTimes ERR ?? nPlayerId = " .. nPlayerId);
			end
		end
	end
	Log("[TeamBattle] CostAllPlayerTimes Finish !!");
end

function tbTeamBattleMgr:KickoutSpacePlayer()
	for _, tbMember in pairs(self.tbAllTeamInfo) do
		if #tbMember < TeamBattle.nTeamMemeber then
			for _, nPlayerId in ipairs(tbMember) do
				self:UpdatePlayerTeamInfo(nPlayerId);
			end
		end
	end

	local tbAllMapPlayer = KPlayer.GetMapPlayer(self.nPreMapId);
	for _, pPlayer in pairs(tbAllMapPlayer) do
		if not self.tbPlayerTeamId[pPlayer.dwID] then
			pPlayer.CenterMsg("由於未能給你匹配到隊友，無法參加活動失敗！");

			if MODULE_ZONESERVER then
				local nConnectIdx = Server:GetConnectIdx(pPlayer.nServerIdx);
				if nConnectIdx then
					CallZoneClientScript(nConnectIdx, "TeamBattle:SendSpaceAward", pPlayer.dwID, self.nType);
				end
			end

			TeamBattle:GoBack(pPlayer);
			Log("[TeamBattleMgr] KickoutSpacePlayer " .. pPlayer.szName);
		end
	end
end

function tbTeamBattleMgr:AssignFloor()
	local tbAllTeam = {};
	for nTeamId, tbMember in pairs(self.tbAllTeamInfo) do
		local nTotalFightPower = 0;
		for _, nPlayerId in ipairs(tbMember) do
			local pMember = KPlayer.GetPlayerObjById(nPlayerId);
			if pMember then
				nTotalFightPower = nTotalFightPower + pMember.GetFightPower();
			end
		end

		table.insert(tbAllTeam, {nTeamId, nTotalFightPower});
	end

	table.sort(tbAllTeam, function (a, b)
		return a[2] > b[2];
	end)

	local nStartFloor = self.bCross and 2 or 1;
	local nCurFloor1Num = #tbAllTeam < (2 ^ self.nMaxFightTimes) and 0 or #tbAllTeam % (2 ^ self.nMaxFightTimes);
	local nCurFloor2Num = #tbAllTeam - nCurFloor1Num;

	if self.nType ~= TeamBattle.TYPE_NORMAL then
		nStartFloor = 2 + TeamBattle.nMaxFightTimes - self.nMaxFightTimes;
	end

	for nIdx, tbInfo in ipairs(tbAllTeam) do
		local nCurFloor = nStartFloor + (nIdx <= nCurFloor2Num and 1 or 0);
		table.insert(self.tbAllFloorInfo[nCurFloor], tbInfo[1]);
	end

	Log(string.format("[TeamBattleMgr] AssignFloor nPreMapId = %s nCurFloor1Num = %s nCurFloor2Num = %s, nStartFloor = %s", self.nPreMapId, nCurFloor1Num, nCurFloor2Num, nStartFloor));
end

function tbTeamBattleMgr:MakeTeam()
	for nTeamId, tbMember in pairs(self.tbAllTeamInfo) do
		if #tbMember >= 2 then
			local dwTeamID;
			local teamData;
			local tbOther = {};
			for _, nPlayerId in ipairs(tbMember) do
				local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
				if pPlayer and pPlayer.dwTeamID > 0 then
					if not teamData then
						teamData = TeamMgr:GetTeamById(pPlayer.dwTeamID);
						dwTeamID = pPlayer.dwTeamID;
					else
						if dwTeamID ~= pPlayer.dwTeamID then
							Log("[TeamBattle] MakeTeam ERR ?? dwTeamID ERROR !!", dwTeamID, pPlayer.dwTeamID, nTeamId);
						end
					end
				else
					table.insert(tbOther, nPlayerId);
				end
			end

			local nOtherStartIdx = 1;
			if not teamData then
				local bResult = TeamMgr:Create(tbOther[1], tbOther[2], true);
				if bResult then
					nOtherStartIdx = 3;
					local pLeader = KPlayer.GetPlayerObjById(tbOther[1]);
					dwTeamID = pLeader.dwTeamID;
					teamData = TeamMgr:GetTeamById(dwTeamID);
				else
					Log("[TeamBattle] MakeTeam ERR ?? TeamMgr:Create Fail !");
				end
			end

			if teamData then
				for i = nOtherStartIdx, #tbOther do
					teamData:AddMember(tbOther[i], true);
				end
			else
				Log("[TeamBattle] MakeTeam ERR ?? ", dwTeamID, nTeamId)
			end
		end
	end
end

function tbTeamBattleMgr:TryStartFight()
	Calendar:OnActivityEnd("TeamBattle")

	Log("[TeamBattleMgr] TryStartFight ", self.nPreMapId);
	local bRet, nCurTeamCount, nFightCount = self:AssignTeam();
	if not bRet or nFightCount <= 0 then
		self.nTryCount = (self.nTryCount or 0) + 1;
		Log(string.format("[TeamBattleMgr] TryStartFight fail !! nCurTeamCount = %s, nFailCount = %s", nCurTeamCount, self.nTryCount));
		if self.nTryCount >= TeamBattle.nTryStartCount then
			self.nStartTimer = nil;
			self:StartFail();
			return;
		end
		return true;
	end

	self.nMaxFightTimes = nFightCount;
	self.nStartTimer = nil;

	self.bIsPreTime = false;
	if MODULE_ZONESERVER then
		CallZoneClientScript(-1, "TeamBattle:OnSyncPreTime", false);
	end

	self:KickoutSpacePlayer();
	self:CostAllPlayerTimes();
	self:MakeTeam();
	self:AssignFloor();
	self:DoStartFight();
end

function tbTeamBattleMgr:StartFail()
	Log("[TeamBattleMgr] StartFight fail !!", self.nPreMapId);
	local tbAllMapPlayer = KPlayer.GetMapPlayer(self.nPreMapId);
	for _, pPlayer in pairs(tbAllMapPlayer) do
		if MODULE_ZONESERVER then
			local nConnectIdx = Server:GetConnectIdx(pPlayer.nServerIdx);
			if nConnectIdx then
				CallZoneClientScript(nConnectIdx, "TeamBattle:SendStartFailAward", pPlayer.dwID, self.nType);
			end
		end
		pPlayer.CenterMsg("由於報名人數不足，活動未開啟！");
		TeamBattle:GoBack(pPlayer);
	end

	self:Close();
end

function tbTeamBattleMgr:Close()
	self.bIsPreTime = nil;
	if self.nStartTimer then
		Timer:Close(self.nStartTimer)
		self.nStartTimer = nil;
	end

	if self.nNotifyPlayerCountTimer then
		Timer:Close(self.nNotifyPlayerCountTimer);
		self.nNotifyPlayerCountTimer = nil;
	end

	for nMapId in pairs(self.tbFightInstByMapId) do
		local tbAllPlayer = KPlayer.GetMapPlayer(nMapId)
		for _, pPlayer in pairs(tbAllPlayer) do
			TeamBattle:GoBack(pPlayer);
		end
	end

	Timer:Register(Env.GAME_FPS * 10, function ()
		self.tbFightInstByMapId = {};
		TeamBattle.tbTeamBattleMgrInstByMapId[self.nPreMapId] = nil;
	end);

	if TeamBattle.nCurPreMapId == self.nPreMapId then
		TeamBattle.nCurPreMapId = nil;
		TeamBattle.tbCurBattleMgr = nil;
	end
end

function tbTeamBattleMgr:DoStartFight()
	Log("[TeamBattleMgr] DoStartFight", self.nPreMapId, self.nFightTimes or 0);
	self.nFightTimes = (self.nFightTimes or 0) + 1;
	if self.nFightTimes < self.nMaxFightTimes then
		self.nFinalResultTimerId = nil;
		self.nFightTimerId = Timer:Register(Env.GAME_FPS * TeamBattle.nFightTime, self.DoStartFight, self);
	else
		self.nFightTimerId = nil;
		local nCloseTime = TeamBattle.nFightTime;
		if self.bCross then
			nCloseTime = nCloseTime + 120;
		end
		Timer:Register(Env.GAME_FPS * nCloseTime, function ()
			if MODULE_ZONESERVER and self.nType ~= TeamBattle.TYPE_NORMAL then
				CallZoneClientScript(-1, "TeamBattle:OnSyncFinish", self.nType);
			elseif not MODULE_ZONESERVER then
				KPlayer.SendWorldNotify(1, 999, TeamBattle.szCloseNotify, ChatMgr.SystemMsgType.System, 0);
			end

			self:Close();
		end)
	end

	assert(self.nFightTimes <= self.nMaxFightTimes);

	Log("[TeamBattleMgr] current team floor info ---------------");
	Lib:LogTB(self.tbAllFloorInfo);

	if self.bCross and self.nFightTimes == self.nMaxFightTimes then
		TeamBattle:DoSyncTeamInfoToZoneServer(self);
		self.nOnSyncLimitFloorTimerId = Timer:Register(Env.GAME_FPS * 20, self.StartLimitFloorFight, self);
	else
		local nMaxFloor = TeamBattle.nMaxFloor - 1;
		if MODULE_ZONESERVER and self.nType ~= TeamBattle.TYPE_NORMAL then
			nMaxFloor = TeamBattle.nMaxFloor_Cross - 1;
		end
		self:StartFloorFight(nMaxFloor, 1);
		if self.bCross and self.nFightTimes == self.nMaxFightTimes - 1 then
			for nMapId, tbInst in pairs(self.tbFightInstByMapId) do
				tbInst.bNextToZoneServer = true;
			end
		end
	end
end

function tbTeamBattleMgr:StartLimitFloorFight()
	self.nOnSyncLimitFloorTimerId = nil;
	self.nLimitFloor = self.nLimitFloor or TeamBattle.nMaxFloor_Cross - 1;
	if self.nLimitFloor >= 1 then
		self:StartFloorFight(self.nLimitFloor, 1);
	end
end

function tbTeamBattleMgr:UpFloor(nTeamId)
	for nFloor, tbFloorInfo in pairs(self.tbAllFloorInfo) do
		for nIdx, nCurTeamId in pairs(tbFloorInfo) do
			if nCurTeamId == nTeamId then
				table.remove(tbFloorInfo, nIdx);
				table.insert(self.tbAllFloorInfo[nFloor + 1], nTeamId);
				return;
			end
		end
	end
end

--检查轮空
function tbTeamBattleMgr:CheckBeyTeam(nFloor)
	local tbFloorInfo = self.tbAllFloorInfo[nFloor];
	if not tbFloorInfo or #tbFloorInfo <= 0 then
		return {}, {};
	end

	local nTeamCount = #tbFloorInfo;
	local nBeyCount = nTeamCount % 2;
	if self.nFightTimes == 1 and self.nType == TeamBattle.TYPE_NORMAL then
		if (self.bCross and nFloor == 3) or (not self.bCross and nFloor == 2) then
			nBeyCount = (TeamBattle.nFloor2Num - (nTeamCount % TeamBattle.nFloor2Num)) % TeamBattle.nFloor2Num;
		end
	end

	--assert(nBeyCount <= nTeamCount);
	if nBeyCount > nTeamCount then
		Log("[TeamBattle] CheckBeyTeam ERR ?? ", nBeyCount, nTeamCount, nFloor, self.bCross and "true" or "false");
		nBeyCount = 0;
	end

	local tbCanBeyTeam = {};
	for _, nTeamId in pairs(tbFloorInfo) do
		if not self.tbAllTeamInfo[nTeamId].bBeyFlat then
			table.insert(tbCanBeyTeam, nTeamId);
		end
	end

	local tbBeyInfo = {};
	local tbBeyTeam = {};
	local fnRandom = Lib:GetRandomSelect(#tbCanBeyTeam);
	local nRandomCount = math.min(#tbCanBeyTeam, nBeyCount);
	local function fnRandomTeam(nRC, fnR, tbTI)
		for i = 1, nRC do
			local nRandom = fnR();
			local nTeamId = tbTI[nRandom];
			self.tbAllTeamInfo[nTeamId].bBeyFlat = 1;
			table.insert(tbBeyTeam, nTeamId);
			tbBeyInfo[nTeamId] = 1;
		end
	end

	fnRandomTeam(nRandomCount, fnRandom, tbCanBeyTeam);

	if #tbBeyTeam < nBeyCount then
		for _, nTeamId in pairs(tbFloorInfo) do
			self.tbAllTeamInfo[nTeamId].bBeyFlat = nil;
		end

		nRandomCount = nBeyCount - #tbBeyTeam;
		fnRandom = Lib:GetRandomSelect(nTeamCount);
		fnRandomTeam(nRandomCount, fnRandom, tbFloorInfo);
	end

	local tbFightTeam = {};
	for _, nTeamId in pairs(tbFloorInfo) do
		if not tbBeyInfo[nTeamId] then
			table.insert(tbFightTeam, nTeamId);
		end
	end

	return tbBeyTeam, tbFightTeam;
end

function tbTeamBattleMgr:StartBeyFight(nTeamId, nFloor)
	local tbFloorMapInfo = TeamBattle.tbFightMapBeginPoint[nFloor];
	local tbFightMapInfo = tbFloorMapInfo[MathRandom(#tbFloorMapInfo)];
	local nMapId = CreateMap(tbFightMapInfo[1]);
	local tbInst = Lib:NewClass(TeamBattle.tbFightMapClass);
	local tbTeamInfo = {nTeamId};
	tbInst:Init(nMapId, nFloor, tbFightMapInfo, tbTeamInfo, self.tbAllTeamInfo, self.nFightTimerId, function (nWinTeamId, nOtherTeamId)
		self:OnSendResult(nMapId, nWinTeamId, nOtherTeamId);
	end, self.nType, self.nFightTimes, self.nMaxFightTimes);

	self.tbFightInstByMapId[nMapId] = tbInst;
	Log(string.format("[TeamBattleMgr] start fight nFloor = %s, nTeam1 = %s, nTeam2 = %s, nMapId = %s, nType = %s", nFloor, tbTeamInfo[1], tbTeamInfo[2] or "nil", nMapId, self.nType or 0));
end

-- 进行一个循环的分配
-- 1. 从tbTeamInfo里面随机抽一个队伍 A
-- 2. 再抽取一个队伍 B
-- 		2.1 如果队伍 B 和队伍 A 相遇过，将 B 加入 tbCache，然后从 步骤 2 继续
-- 		2.2 如果队伍 B 和队伍 A 没相遇过，将 A，B 都加入 tbResult，然后从 步骤 1 继续
-- 3. tbTeamInfo 抽取完毕时，如果存在未匹配的 队伍 A 将它加入 tbCache，然后返回 tbCache
function tbTeamBattleMgr:AssignFightInfo(tbTeamInfo, tbResult)
	if not tbTeamInfo or #tbTeamInfo <= 0 then
		return {};
	end

	local fnRandom = Lib:GetRandomSelect(#tbTeamInfo);
	local tbCache = {};
	local nLastTeamId = nil;
	for i = 1, #tbTeamInfo do
		local nTeamId = tbTeamInfo[fnRandom()];
		if nLastTeamId then
			if self.tbAllTeamInfo[nTeamId].tbOther and self.tbAllTeamInfo[nTeamId].tbOther[nLastTeamId] then
				-- 相遇过
				table.insert(tbCache, nTeamId);
			else
				-- 没相遇过
				table.insert(tbResult, nLastTeamId);
				table.insert(tbResult, nTeamId);
				nLastTeamId = nil;
			end
		else
			nLastTeamId = nTeamId;
		end
	end

	if nLastTeamId then
		table.insert(tbCache, nLastTeamId);
	end
	return tbCache;
end

function tbTeamBattleMgr:StartFloorFight(nMaxFloor, nMinFloor)
	nMinFloor = nMinFloor or 1;
	for i = nMinFloor, nMaxFloor do
		local tbBeyTeam = self:_StartFloorFight(i);
		for _, nTeamId in pairs(tbBeyTeam) do
			self:StartBeyFight(nTeamId, i);
		end
	end
end

function tbTeamBattleMgr:_StartFloorFight(nFloor)
	local tbBeyTeam, tbFightTeam = self:CheckBeyTeam(nFloor);
	if #tbFightTeam <= 0 then
		return tbBeyTeam;
	end

	local tbFightInfo = {};	--对战信息
	local tbLastTeamInfo = tbFightTeam;

	-- 循环检查几轮就好了
	for i = 1, 3 do
		tbLastTeamInfo = self:AssignFightInfo(tbLastTeamInfo, tbFightInfo);
		if #tbLastTeamInfo <= 0 then
			break;
		end
	end

	if #tbLastTeamInfo >= 0 then
		for _, nTeamId in pairs(tbLastTeamInfo) do
			table.insert(tbFightInfo, nTeamId);
		end
	end

	for i = 1, #tbFightInfo / 2 do
		local tbFloorMapInfo = TeamBattle.tbFightMapBeginPoint[nFloor];
		local tbFightMapInfo = tbFloorMapInfo[MathRandom(#tbFloorMapInfo)];
		local nMapId = CreateMap(tbFightMapInfo[1]);
		local tbInst = Lib:NewClass(TeamBattle.tbFightMapClass);

		local nFirst = tbFightInfo[(i - 1) * 2 + 1];
		local nSecond = tbFightInfo[(i - 1) * 2 + 2];

		local tbTeamInfo = {nFirst, nSecond};

		self.tbAllTeamInfo[nFirst].tbOther = self.tbAllTeamInfo[nFirst].tbOther or {};
		self.tbAllTeamInfo[nFirst].tbOther[nSecond] = true;

		self.tbAllTeamInfo[nSecond].tbOther = self.tbAllTeamInfo[nSecond].tbOther or {};
		self.tbAllTeamInfo[nSecond].tbOther[nFirst] = true;

		tbInst:Init(nMapId, nFloor, tbFightMapInfo, tbTeamInfo, self.tbAllTeamInfo, self.nFightTimerId, function (nWinTeamId, nOtherTeamId)
			self:OnSendResult(nMapId, nWinTeamId, nOtherTeamId);
		end, self.nType, self.nFightTimes, self.nMaxFightTimes);

		self.tbFightInstByMapId[nMapId] = tbInst;
		Log(string.format("[TeamBattleMgr] start fight nFloor = %s, nTeam1 = %s, nTeam2 = %s, nMapId = %s, nType = %s", nFloor, tbTeamInfo[1], tbTeamInfo[2], nMapId, self.nType or 1));
	end

	return tbBeyTeam;
end

function tbTeamBattleMgr:GetCurPlayerInfo()
	local nLastTime = 0;
	if self.nStartTimer then
		nLastTime = Timer:GetRestTime(self.nStartTimer);
		nLastTime = math.floor((nLastTime or 0) / Env.GAME_FPS);
	end

	local tbPlayer = KPlayer.GetMapPlayer(self.nPreMapId);
	return #tbPlayer, nLastTime, tbPlayer;
end

function tbTeamBattleMgr:SyncPlayerCountInfo()
	local nPlayerCount, nLastTime, tbPlayer = self:GetCurPlayerInfo();
	for _, pPlayer in pairs(tbPlayer) do
		pPlayer.CallClientScript("TeamBattle:SyncPlayerCountInfo", nPlayerCount, nLastTime);
	end

	if not self.bIsPreTime then
		self.nNotifyPlayerCountTimer = nil;
	end
	return self.bIsPreTime;
end

function tbTeamBattleMgr:OnSendResult(nMapId, nWinTeamId, nOtherTeamId)
	Log(string.format("[TeamBattleMgr] OnSendResult nMapId = %s, nWinTeamId = %s, nOtherTeamId = %s", nMapId, nWinTeamId, nOtherTeamId or 0));
	self:UpFloor(nWinTeamId);
	self.tbWinInfo[nWinTeamId] = self.tbWinInfo[nWinTeamId] or 0;
	self.tbWinInfo[nWinTeamId] = self.tbWinInfo[nWinTeamId] + 1;

	if self.nFightTimes < self.nMaxFightTimes then
		return;
	end

	self:SendTeamAward(nWinTeamId, nOtherTeamId);
end

function tbTeamBattleMgr:GetPlayerAward(pPlayer, nFloor, nOldHonor)
	local tbAllAward = TeamBattle.tbAwardInfo[nFloor];
	if not tbAllAward then
		return;
	end

	local tbResultAward = {};
	for _, tbAward in ipairs(tbAllAward) do
		table.insert(tbResultAward, Lib:CopyTB(tbAward));
	end

	nOldHonor = nOldHonor or pPlayer.GetUserValue(TeamBattle.SAVE_GROUP, TeamBattle.SAVE_HONOR);
	local nCurValue = nOldHonor + tbAllAward.nTeamBattleHonor;
	local nLastValue = nCurValue % TeamBattle.nAwardItemNeedHonor;
	local nAwardItemCount = math.floor(nCurValue / TeamBattle.nAwardItemNeedHonor);

	if nAwardItemCount > 0 then
		table.insert(tbResultAward, {"item", TeamBattle.nAwardItemId, nAwardItemCount});
	end
	return tbResultAward, nAwardItemCount, nLastValue, tbAllAward.nTeamBattleHonor, nCurValue;
end

function tbTeamBattleMgr:SendPlayerAward(pPlayer, nFloor)
	local tbAward, nAwardItemCount, nLastValue, nAddHonor, nTotalHonor = self:GetPlayerAward(pPlayer, nFloor);
	if not tbAward then
		Log("[TeamBattle] TeamBattle GetPlayerAward ERR ?? tbAward is nil !!", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, nFloor or "nil");
		return;
	end

	local szMsg = "";
	if nAwardItemCount > 0 then
		szMsg = string.format("恭喜你在本次通天塔中登上第%s層，獲得%s點榮譽。\n自動兌換%s個通天塔寶箱。剩餘%s點榮譽\n（每滿%s點榮譽，自動兌換1個通天塔寶箱）",
								nFloor, nAddHonor, nAwardItemCount, nLastValue, TeamBattle.nAwardItemNeedHonor);
	else
		szMsg = string.format("恭喜你在本次通天塔中登上第%s層，獲得%s點榮譽。\n目前剩餘%s點榮譽 \n（每滿%s點榮譽，自動兌換1個通天塔寶箱）",
								nFloor, nAddHonor, nLastValue, TeamBattle.nAwardItemNeedHonor);
	end

	pPlayer.SetUserValue(TeamBattle.SAVE_GROUP, TeamBattle.SAVE_HONOR, nLastValue);
	Log("[TeamBattle] TeamBattle Honor", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, nAwardItemCount, nLastValue, nAddHonor, nTotalHonor);

	TeamBattle:ReportQQScore(pPlayer, Env.QQReport_TeamBattle_FinalFloor, nFloor);

	if nFloor >= 7 then
		Achievement:AddCount(pPlayer, "TeamBattle_3", 1);
		pPlayer.CallClientScript("GameSetting.Comment:OnEvent", GameSetting.Comment.Type_TeamBattle_7);

		if pPlayer.dwKinId > 0 then
			local kinData = Kin:GetKinById(pPlayer.dwKinId);
			if kinData then
				kinData:CacheLatestTower7Player(pPlayer.szName);
			end
		end
	end

	if nFloor >= 8 then
		Achievement:AddCount(pPlayer, "TeamBattleFurniture_1", 1);
	end

	if GetTimeFrameState(TeamBattle.szLeagueOpenTimeFrame) == 1 and nFloor >= 7 then
		local nNextOpenTime = TeamBattle:GetNextOpenTime(TeamBattle.TYPE_MONTHLY);
		local nNextOpenMonth = Lib:GetLocalMonth(nNextOpenTime);
		local nCurInfo = pPlayer.GetUserValue(TeamBattle.SAVE_GROUP, TeamBattle.SAVE_MONTHLY_INFO);
		if nCurInfo ~= nNextOpenMonth - 1 then
			pPlayer.SetUserValue(TeamBattle.SAVE_GROUP, TeamBattle.SAVE_MONTHLY_INFO_OLD, nCurInfo);
			pPlayer.SetUserValue(TeamBattle.SAVE_GROUP, TeamBattle.SAVE_MONTHLY_INFO, nNextOpenMonth - 1);

			local szTimeInfo = Lib:GetTimeStr4(nNextOpenTime);
			local tbMonthlyMail = {
				To = pPlayer.dwID,
				Title = "月度通天塔資格通知",
				Text = string.format("      恭喜您在本場通天塔競技中成績優異，登上[FFFE0D]%s[-]層，現已獲得月度通天塔參賽資格。月度通天塔開啟時間為[FFFE0D]%s[-]，期待您的參與！更高的榮譽等著您！", nFloor, szTimeInfo),
				From = "通天塔",
				tbAttach = {{"AddTimeTitle", TeamBattle.nMonthlyAddTitle, nNextOpenTime}},
				nLogReazon = Env.LogWay_TeamBattle,
			}
			Mail:SendSystemMail(tbMonthlyMail);

			local szFriendMsg = string.format("恭喜俠士「%s」在通天塔競技中英勇無敵，一口氣登上%s層，成功獲得月度通天塔參賽資格！#49", pPlayer.szName, nFloor);
			ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Friend, szFriendMsg, pPlayer.dwID);
			if pPlayer.dwKinId > 0 then
				local szKinMsg = string.format("恭喜本幫派成員「%s」在通天塔競技中英勇無敵，一口氣登上%s層，現已獲得月度通天塔參賽資格！#49", pPlayer.szName, nFloor);
				ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szKinMsg, pPlayer.dwKinId);
			end
		end
	end
	Calendar:OnCompleteAct(pPlayer.dwID, "TeamBattle", nFloor);

	Kin:RedBagOnEvent(pPlayer, Kin.tbRedBagEvents.tower_floor, nFloor)

	local tbMail = {
		To = pPlayer.dwID,
		Title = "通天塔挑戰獎勵",
		Text = szMsg,
		From = "通天塔",
		tbAttach = tbAward,
		nLogReazon = Env.LogWay_TeamBattle,
	}
	Mail:SendSystemMail(tbMail);
	return tbAward, nAwardItemCount, nAddHonor;
end

function tbTeamBattleMgr:SendTeamAward(nTeamId, nOtherTeamId)
	if MODULE_ZONESERVER then
		Log(string.format("[TeamBattle] nWinTeamId = %s, nOtherTeamId = %s", nTeamId or -1, nOtherTeamId or -1));

		local tbAllServerInfo = {};
		for nFloor, tbFloorInfo in pairs(self.tbAllFloorInfo) do
			for nIdx, nCurTeamId in pairs(tbFloorInfo) do
				if self.tbAllTeamInfo[nCurTeamId] and not self.tbAllTeamInfo[nCurTeamId].bAward and (nCurTeamId == nTeamId or nCurTeamId == nOtherTeamId) then
					self.tbAllTeamInfo[nCurTeamId].bAward = true;

					local function fnGetServerInfo(self, pPlayer, tbMember, tbInfo)
						tbInfo[pPlayer.nServerIdx] = tbInfo[pPlayer.nServerIdx] or {};
						tbInfo[pPlayer.nServerIdx][nFloor] = tbInfo[pPlayer.nServerIdx][nFloor] or {};
						table.insert(tbInfo[pPlayer.nServerIdx][nFloor], pPlayer.dwID);

						if nFloor >= TeamBattle.nMaxFloor_Cross and nCurTeamId == nTeamId then
							TeamBattle:SwitchToTopMap(pPlayer, self.bCross);
						else
							pPlayer.nCanLeaveMapId = pPlayer.nMapId;
							pPlayer.CallClientScript("TeamBattle:ShowBeyInfo", nil, true, false);
							pPlayer.CallClientScript("TeamBattle:DealyShowTeamInfo");
							pPlayer.CallClientScript("Ui:OpenWindow", "QYHLeavePanel");
							pPlayer.CallClientScript("Map:SetCloseUiOnLeave", pPlayer.nMapId, "QYHLeavePanel");
						end
					end
					self:ForeachPlayer(nCurTeamId, fnGetServerInfo, tbAllServerInfo);
				end
			end
		end

		for nServerIdx, tbPlayerInfo in pairs(tbAllServerInfo) do
			local nConnectIdx = Server:GetConnectIdx(nServerIdx);
			if nConnectIdx then
				CallZoneClientScript(nConnectIdx, "TeamBattle:OnSyncLeagueResult", tbPlayerInfo, self.nType);
			else
				Log("[TeamBattle] GetConnectIdx Fail !!", nServerIdx);
				Lib:LogTB(tbPlayerInfo);
			end
		end
		return;
	end

	nTeamId = nTeamId or -1;
	nOtherTeamId = nOtherTeamId or -1;

	local function fnSendAward(self, pPlayer, tbMember, nFloor, tbResult, tbCheckInfo, nAddImityCount)
		if (nFloor == TeamBattle.nMaxFloor and not self.bCross) or (nFloor == TeamBattle.nMaxFloor_Cross and self.bCross) then
			KPlayer.SendWorldNotify(1, 999, string.format(self.bCross and TeamBattle.szTopWorldNotify_Cross or TeamBattle.szTopWorldNotify, pPlayer.szName), 1, 1);
			if pPlayer.dwKinId > 0 then
				ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, string.format(self.bCross and TeamBattle.szTopKinNotify_Cross or TeamBattle.szTopKinNotify, pPlayer.szName), pPlayer.dwKinId);
			end
			TeamBattle:SwitchToTopMap(pPlayer, self.bCross);
		else
			pPlayer.nCanLeaveMapId = pPlayer.nMapId;
			pPlayer.CallClientScript("TeamBattle:ShowBeyInfo", nil, true, false);
			pPlayer.CallClientScript("TeamBattle:DealyShowTeamInfo");
			pPlayer.CallClientScript("Ui:OpenWindow", "QYHLeavePanel");
			pPlayer.CallClientScript("Map:SetCloseUiOnLeave", pPlayer.nMapId, "QYHLeavePanel");
		end

		local tbAward, nAwardItemCount, nAddHonor = self:SendPlayerAward(pPlayer, nFloor);
		if not tbAward then
			return;
		end

		for nPlayerId in pairs(tbResult) do
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

		pPlayer.CallClientScript("Ui:OpenWindow", "TeamBattleResultPanel", nFloor, tbResult, tbAward, nAddImityCount, nAwardItemCount, nAddHonor);
	end

	local function fnCheckInfo(self, pPlayer, tbMember, tbResult)
		pPlayer.nTeamBattleTotalKill = pPlayer.nTeamBattleTotalKill or 0;
		pPlayer.nTeamBattleTotalDeath = pPlayer.nTeamBattleTotalDeath or 0;
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

	for nFloor, tbFloorInfo in pairs(self.tbAllFloorInfo) do
		for nIdx, nCurTeamId in pairs(tbFloorInfo) do
			if self.tbAllTeamInfo[nCurTeamId] and not self.tbAllTeamInfo[nCurTeamId].bAward and (nCurTeamId == nTeamId or nCurTeamId == nOtherTeamId) then
				self.tbAllTeamInfo[nCurTeamId].bAward = true;
				local tbResult = {};
				local tbCheckInfo = {};
				local nAddImityCount = TeamBattle.tbAddImityInfo[self.tbWinInfo[nCurTeamId] or 0] or TeamBattle.tbAddImityInfo[0];
				self:ForeachPlayer(nCurTeamId, fnCheckInfo, tbResult);
				self:ForeachPlayer(nCurTeamId, fnSendAward, nFloor, tbResult, tbCheckInfo, nAddImityCount);

				FriendRecall:OnTeamBattleAward(self.tbAllTeamInfo[nCurTeamId]);
				Log(string.format("[TeamBattleMgr] SendTeamAward nTeamId = %s, nFloor = %s", nCurTeamId, nFloor));
			end
		end
	end
end

function tbTeamBattleMgr:OnCreatePreMap()
	self.bIsLoadOK = true;

	if MODULE_ZONESERVER then
		CallZoneClientScript(-1, "TeamBattle:OnSyncLeaguePreMap", self.nType, self.nPreMapId, true);
	end
end

function tbTeamBattleMgr:OnEnterPreMap()
	me.nTeamBattleComboKill = nil;
	me.nTeamBattleTotalKill = nil;
	me.nTeamBattleTotalDeath = nil;

	if not self.tbPlayerTeamId[me.dwID] then
		TeamMgr:QuiteTeam(me.dwTeamID, me.dwID);
	end

	if MODULE_ZONESERVER then
		local bCountErr = false;
		local nCacheTeamId = self.tbPlayerTeamId[me.dwID];
		if nCacheTeamId and self.tbAllTeamInfo[nCacheTeamId] then
			local tbMembers = self.tbAllTeamInfo[nCacheTeamId];
			for _, nPlayerId in ipairs(tbMembers) do
				if nPlayerId ~= me.dwID then
					local pOther = KPlayer.GetPlayerObjById(nPlayerId);
					if pOther then
						if pOther.dwTeamID and pOther.dwTeamID > 0 then
							local teamData = TeamMgr:GetTeamById(pOther.dwTeamID);
							if teamData and teamData:GetMemberCount() <= TeamBattle.nTeamMemeber - 1 then
								teamData:AddMember(me.dwID, true);
							else
								bCountErr = true;
							end
						else
							local bResult = TeamMgr:Create(me.dwID, nPlayerId, true);
							if not bResult then
								Log("[TeamBattle] Create Team Fail !!", me.dwID, nPlayerId);
							end
						end
						break;
					end
				end
			end
		end

		if bCountErr then
			self.tbPlayerTeamId[me.dwID] = nil;
			self:UpdatePlayerTeamInfo(me.dwID);
		end
	end

	local nPlayerCount, nLastTime = self:GetCurPlayerInfo();

	me.CallClientScript("Map:SetCloseUiOnLeave", me.nMapId, "QYHLeftInfo");
	me.CallClientScript("TeamBattle:SyncPlayerCountInfo", nPlayerCount, nLastTime);
end

function tbTeamBattleMgr:OnLeavePreMap()
	if not self.bIsPreTime then
		return;
	end

	if self.tbPlayerTeamId[me.dwID] and me.dwTeamID > 0 then
		TeamMgr:QuiteTeam(me.dwTeamID, me.dwID);
	end

	self:UpdatePlayerTeamInfo(me.dwID);
end

function tbTeamBattleMgr:OnFightMapFunc(szFunc, nMapId)
	local tbInst = self.tbFightInstByMapId[nMapId];
	if not tbInst or not tbInst[szFunc] then
		return;
	end

	tbInst[szFunc](tbInst, nMapId);
end
