-- 抽奖系统

local KEY_DATA = "Lottery";
local KEY_RECORD = "LotteryRecord";

-- 每张数据库表可存储的最大玩家个数
Lottery.TABLE_PLAYER_COUNT = 2500;

function Lottery:Load()
	self:ClearCache();

	local nTotalCount = 0;
	local nIndex = 1;
	while (true) do
		local nPlayerCount = 0;
		local tbTicketData = self:GetTicketData(nIndex);
		for dwPlayerId in pairs(tbTicketData) do
			if self.tbCache.tbPlayerIndex[dwPlayerId] then
				Log("[ERROR][Lottery] failed to load lottery data, repeated player: ", dwPlayerId);
				Lottery.IsForbid = true;
			else
				self.tbCache.tbPlayerIndex[dwPlayerId] = nIndex;
				nPlayerCount = nPlayerCount + 1;
			end
		end
		
		if nPlayerCount == 0 then
			break;
		end
		
		self.tbCache.tbTableSize[nIndex] = nPlayerCount;

		nTotalCount = nTotalCount + nPlayerCount;
		nIndex = nIndex + 1;
	end

	local tbInvalidTicket = self:GetInvalidTicket();
	for _ in pairs(tbInvalidTicket) do
		self.tbCache.nInvaildPlayerCount = self.tbCache.nInvaildPlayerCount + 1;
	end

	Log("[Lottery] load finished! player count:", nTotalCount, "invalid count:", self.tbCache.nInvaildPlayerCount);

	self:CheckNotify();
end

function Lottery:ClearCache()
	self.tbCache = 
	{ 
		tbPlayerIndex = {}, 
		tbTableSize = {},
		nInvaildPlayerCount = 0,
	};
end

function Lottery:GetTicketData(nIndex)
	local szKey = KEY_DATA .. nIndex;
	ScriptData:AddDef(szKey);
	local tbData = ScriptData:GetValue(szKey);
	if not tbData.tbTicket then
		tbData.tbTicket = {};
	end
	return tbData.tbTicket;
end

function Lottery:GetPlayerTicketData(dwPlayerId)
	local nIndex = self.tbCache.tbPlayerIndex[dwPlayerId];
	if not nIndex then
		return;
	end

	local tbTicketData = self:GetTicketData(nIndex);
	return tbTicketData[dwPlayerId], nIndex;
end

function Lottery:SaveTicketData(nIndex)
	local szKey = KEY_DATA .. nIndex;
	ScriptData:AddDef(szKey);
	ScriptData:AddModifyFlag(szKey);
end

function Lottery:GetFreeTableIndex()
	local tbTableSize = self.tbCache.tbTableSize;
	local nTableCount = #tbTableSize;
	for nIndex, nCount in ipairs(tbTableSize) do
		if nCount < self.TABLE_PLAYER_COUNT then
			return nIndex;
		end
	end

	nTableCount = nTableCount + 1;
	tbTableSize[nTableCount] = 0;

	local szKey = KEY_DATA .. nTableCount;
	ScriptData:AddDef(szKey);
	ScriptData:SaveAtOnce(szKey, {});

	return nTableCount;
end

function Lottery:Draw()
	local bRet = self:IsAvailable();
	if not bRet then
		Log("[Lottery] skip draw, lottery is not available!");
		return;
	end

	self:DoDraw(self.tbCache.tbPlayerIndex);
end

function Lottery:DoDraw(tbPlayer)
	Lottery.IsForbid = true;

	local nStartTime = os.clock();

	local tbLucky = {};
	local tbInvalidTicket = self:GetInvalidTicket();
	local tbGroup, nPlayerCount = self:GetRankGroup(tbPlayer);
	for nRank, tbSetting in ipairs(Lottery.tbRankSetting) do
		local tbRankGroup = tbGroup[nRank];
		local nMax = math.min(tbRankGroup.nPlayerCount, tbSetting.nNum);
		for i = 1, nMax do
			local dwLuckyId, nTicketCount = self:RandomLuckyOne(tbRankGroup);
			assert(dwLuckyId, string.format("[ERROR][Lottery] failed to random lucky one: %d, %d", nRank, tbRankGroup.nTotalTicketCount));

			assert(not tbLucky[dwLuckyId], "repeated lucky guy: " .. dwLuckyId);
			tbLucky[dwLuckyId] = nRank;

			for nRemoveRank in ipairs(Lottery.tbRankSetting) do
				self:RemovePlayerFromRankGroup(tbGroup[nRemoveRank], dwLuckyId);
			end

			Log("[Lottery] lucky guy! ", nRank, dwLuckyId);
		end
	end

	self:RecordData(tbLucky);
	self:ClearData();

	Lottery.IsForbid = nil;

	Timer:Register(1, function ()
		self:Announce(tbLucky);
		self:SendJoinAward(tbGroup, tbInvalidTicket, tbLucky);
	end)

	Log("[Lottery] draw finished! player count: ", nPlayerCount, "cost time: ", os.clock() - nStartTime);
end

function Lottery:GetRankGroup(tbPlayer)
	local tbGroup = {};
	for nRank in ipairs(Lottery.tbRankSetting) do
		tbGroup[nRank] = { nPlayerCount = 0, nTotalTicketCount = 0, tbPlayer = {} };
	end	

	local nPlayerCount = 0;
	for dwPlayerId in pairs(tbPlayer) do
		local tbPlayerData = self:GetPlayerTicketData(dwPlayerId);
		assert(tbPlayerData, "player ticket data not exist: " .. dwPlayerId);

		local tbExcept = tbPlayerData.tbExcept;
		for nRank in ipairs(Lottery.tbRankSetting) do
			if not tbExcept or not tbExcept[nRank] then
				local nCount = tbPlayerData.nCount;
				local tbRankGroup = tbGroup[nRank];
				tbRankGroup.nPlayerCount = tbRankGroup.nPlayerCount + 1;
				tbRankGroup.nTotalTicketCount = tbRankGroup.nTotalTicketCount + nCount;
				tbRankGroup.tbPlayer[dwPlayerId] = nCount;
			end
		end
		nPlayerCount = nPlayerCount + 1;
	end

	return tbGroup, nPlayerCount;
end

function Lottery:RandomLuckyOne(tbRankGroup)
	if tbRankGroup.nTotalTicketCount <= 0 then
		Log("[ERROR][Lottery] failed to random lucky one, total ticket count is non!");
		return;
	end

	local nCurValue = 0;
	local nRandom = MathRandom(tbRankGroup.nTotalTicketCount);
	for dwPlayerId, nCount in pairs(tbRankGroup.tbPlayer) do
		nCurValue = nCurValue + nCount;
		if nRandom <= nCurValue then
			return dwPlayerId, nCount;
		end
	end
end

function Lottery:RemovePlayerFromRankGroup(tbRankGroup, dwPlayerId)
	local nTicketCount = tbRankGroup.tbPlayer[dwPlayerId];
	if not nTicketCount then
		return;
	end

	tbRankGroup.tbPlayer[dwPlayerId] = nil;
	tbRankGroup.nPlayerCount = tbRankGroup.nPlayerCount - 1;
	tbRankGroup.nTotalTicketCount = tbRankGroup.nTotalTicketCount - nTicketCount;
end

function Lottery:AddTicket(dwPlayerId, tbExcept, nCount)
	nCount = nCount or 1;

	local tbPlayerData, nIndex = self:GetPlayerTicketData(dwPlayerId);
	if not tbPlayerData then
		tbPlayerData = { nCount = 0, tbExcept = nil };
		nIndex = self:NewPlayer(dwPlayerId);

		Log("[Lottery] add ticket ", dwPlayerId, "table index: ", nIndex);
	end

	tbPlayerData.tbExcept = tbExcept;
	tbPlayerData.nCount = nCount;

	local tbTicketData = self:GetTicketData(nIndex);
	tbTicketData[dwPlayerId] = tbPlayerData;
	
	self:SaveTicketData(nIndex);
end

function Lottery:RemoveTicket(dwPlayerId)
	local nIndex = self:RemovePlayer(dwPlayerId);
	if not nIndex then
		return;
	end

	local tbTicketData = self:GetTicketData(nIndex);
	tbTicketData[dwPlayerId] = nil;

	self:SaveTicketData(nIndex);

	Log("[Lottery] remove ticket ", dwPlayerId, "table index: ", nIndex);
end

function Lottery:NewPlayer(dwPlayerId)
	local nIndex = self:GetFreeTableIndex();
	self.tbCache.tbPlayerIndex[dwPlayerId] = nIndex;
	self.tbCache.tbTableSize[nIndex] = self.tbCache.tbTableSize[nIndex] + 1;
	return nIndex;
end

function Lottery:RemovePlayer(dwPlayerId)
	local nIndex = self.tbCache.tbPlayerIndex[dwPlayerId];
	if not nIndex then
		return;
	end
	self.tbCache.tbPlayerIndex[dwPlayerId] = nil;
	self.tbCache.tbTableSize[nIndex] = self.tbCache.tbTableSize[nIndex] - 1;
	return nIndex;
end

function Lottery:AddInvalidTicket(dwPlayerId)
	local tbTicket = self:GetInvalidTicket();
	if tbTicket[dwPlayerId] then
		return;
	end

	if self.tbCache.nInvaildPlayerCount >= self.MAX_JOIN_AWARD_COUNT then
		return;
	end

	self.tbCache.nInvaildPlayerCount = self.tbCache.nInvaildPlayerCount + 1;
	tbTicket[dwPlayerId] = true;

	ScriptData:AddModifyFlag(KEY_RECORD);

	Log("[Lottery] add invalid ticket: ", dwPlayerId);
end

function Lottery:RemoveInvalidTicket(dwPlayerId)
	local tbTicket = self:GetInvalidTicket();
	if not tbTicket[dwPlayerId] then
		return;
	end

	self.tbCache.nInvaildPlayerCount = self.tbCache.nInvaildPlayerCount - 1;
	tbTicket[dwPlayerId] = nil;

	ScriptData:AddModifyFlag(KEY_RECORD);

	Log("[Lottery] remove invalid ticket: ", dwPlayerId);
end

function Lottery:GetRecordData()
	local tbData = ScriptData:GetValue(KEY_RECORD);
	if not tbData.tbLucky then
		tbData.nDrawWeek = nil;
		tbData.bIsNotify = nil;
		tbData.tbLucky = {};
		tbData.tbInvalidTicket = {};
	end
	return tbData;
end

function Lottery:GetInvalidTicket()
	local tbData = self:GetRecordData();
	return tbData.tbInvalidTicket;
end

function Lottery:RecordData(tbLucky)
	local tbData = self:GetRecordData();
	tbData.bIsNotify = nil;
	tbData.nDrawWeek = tbData.nDrawWeek + 1;
	tbData.tbLucky = tbLucky;
	ScriptData:SaveAtOnce(KEY_RECORD, tbData);

	local nCurWeek = self:GetDrawWeek();
	Log("[Lottery] record data! week:", nCurWeek, tbData.nDrawWeek);
	
	if tbData.nDrawWeek ~= nCurWeek + 1 then
		Log("[WARNING][Lottery] draw week not match!!");
		Log(debug.traceback());
	end
end

function Lottery:ClearData()
	local tbData = self:GetRecordData();
	tbData.tbInvalidTicket = {};
	ScriptData:SaveAtOnce(KEY_RECORD, tbData);

	for nIndex in ipairs(self.tbCache.tbTableSize) do
		ScriptData:SaveAtOnce(KEY_DATA .. nIndex, {});
	end

	self:ClearCache();

	Log("[Lottery] clear data! ");
end

function Lottery:GetLuckyRecord()
	local tbData = self:GetRecordData();
	return tbData.tbLucky;
end

function Lottery:Announce(tbLucky)
	local tbPlayer = {};
	for dwPlayerId, nRank in pairs(tbLucky) do
		local tbPlayerData = {};
		tbPlayerData.dwPlayerId = dwPlayerId;
		tbPlayerData.nRank = nRank;
		table.insert(tbPlayer, tbPlayerData);
	end
	table.sort(tbPlayer, function (t1, t2) return t1.nRank < t2.nRank end );

	for _, tbPlayerData in ipairs(tbPlayer) do
		local dwPlayerId = tbPlayerData.dwPlayerId;
		tbPlayerData.dwPlayerId = nil;

		local tbAward = self:SendAward(dwPlayerId, tbPlayerData.nRank);
		tbPlayerData.tbAward = tbAward;

		local tbRoleInfo = KPlayer.GetRoleStayInfo(dwPlayerId);
		tbPlayerData.szName = tbRoleInfo.szName;

		local pKinData = Kin:GetKinById(tbRoleInfo.dwKinId or 0);
		if pKinData then
			tbPlayerData.szKinName = pKinData.szName;	
		end
	end

	local nEndTime = GetTime() + Lottery.NEWINFO_TIME_RESULT;
	NewInformation:AddInfomation(Lottery.NEWINFO_KEY_RESULT, nEndTime, tbPlayer);
end

function Lottery:SendJoinAward(tbGroup, tbInvalidTicket, tbLucky)
	local tbJoin = {}; 
	local nJoinCount = self.MAX_JOIN_AWARD_COUNT;
	local bIsTree = false;
	local fnAward = function (dwPlayerId)
		if tbJoin[dwPlayerId] then
			return;
		end

		if tbLucky[dwPlayerId] then
			Log("[ERROR][Lottery] failed to send join award, repeated with lucky guy:", dwPlayerId);
			if not bIsTree then
				bIsTree = true;
				Lib:Tree(tbLucky);
			end
			return;
		end

		tbJoin[dwPlayerId] = true;
		nJoinCount = nJoinCount - 1;

		self:SendAward(dwPlayerId, -1);

		return nJoinCount <= 0;
	end

	for _, tbRankGroup in ipairs(tbGroup) do
		for dwPlayerId in pairs(tbRankGroup.tbPlayer) do
			if fnAward(dwPlayerId) then
				return;
			end
		end
	end

	for dwPlayerId in pairs(tbInvalidTicket) do
		if fnAward(dwPlayerId) then
			return;
		end
	end
end

function Lottery:SendAward(dwPlayerId, nRank)
	local tbAward = self:GetAwardSetting(nRank);
	local tbMail = 
	{
        To = dwPlayerId;
        Title = "盟主的贈禮";
        From = "武林盟主";
        Text = "少俠為維護武林秩序做出的傑出貢獻，吾與其他俠士盡皆看在眼裡，今奉薄禮一份，以助少俠一臂之力。還望少俠在江湖中繼續努力，闖蕩出自己的一番天地。";
        tbAttach = tbAward;
        nLogReazon = Env.LogWay_Lottery_Award;
    }; 
    Mail:SendSystemMail(tbMail);

	local tbRoleInfo = KPlayer.GetRoleStayInfo(dwPlayerId);
	local tbRankSetting = self.tbRankSetting[nRank];
	if tbRankSetting and tbRankSetting.szWorldNotify then
		local szMsg = string.format(tbRankSetting.szWorldNotify, tbRoleInfo.szName);
		KPlayer.SendWorldNotify(0, 999, szMsg, 1, nRank == 1 and 1 or 0);
	end

	if tbRankSetting and tbRankSetting.szKinNotify and tbRoleInfo.dwKinId ~= 0 then
		local szMsg = string.format(tbRankSetting.szKinNotify, tbRoleInfo.szName);
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, tbRoleInfo.dwKinId);
	end

	if nRank > 0 then
		Log("[Lottery] send award to lucky guy! ", nRank, dwPlayerId);
	end

	return tbAward;
end

-- 测试代码
function Lottery:Test(nPlayerCount)
	nPlayerCount = nPlayerCount or 10;
	Lottery.SendAward = function ( ... )
		Log("[Lottery] send award ... ", ...);
	end

	local tbRank = {};
	for nRank in ipairs(Lottery.tbRankSetting) do
		table.insert(tbRank, nRank);
	end

	for i = 1, nPlayerCount do
		Lib:RandomArray(tbRank);
		local tbExcept = nil;
		local nMax = #tbRank;
		local nNum = MathRandom(nMax + 1);
		local nCount = MathRandom(10);
		if nNum <= nMax then
			tbExcept = {};
			for j = 1, nNum do
				tbExcept[tbRank[j]] = true;
			end
		end
		Lottery:AddTicket(i, tbExcept, nCount);
	end

	Lottery:Print();
	Lottery:Draw();
	Lottery:Print();
end

function Lottery:Print()
	for nIndex in ipairs(self.tbCache.tbTableSize) do
		Lib:Tree(ScriptData:GetValue(KEY_DATA .. nIndex));
	end
	Lib:Tree(ScriptData:GetValue(KEY_RECORD));
	Lib:Tree(self.tbCache);	
end

function Lottery:IsAvailable()
	if not Lottery:IsOpen() then
		return false, "活動尚未開啟，稍安勿躁！";
	end

	if Lottery.IsForbid then
		return false, "系統繁忙，請稍候再試！";
	end

	return true;
end

function Lottery:ExchangeTicket(pPlayer)
	local bRet, szMsg = self:IsAvailable();
	if not bRet then
		pPlayer.CenterMsg(szMsg);
		return false;
	end

	local nCount = self:GetPlayerTicketCount(pPlayer);
	nCount = nCount + 1;

	pPlayer.SetUserValue(self.USER_GROUP, self.USER_KEY_TICKET, nCount);

	self:DoRefreshTicketData(pPlayer, nCount);

	pPlayer.CenterMsg(string.format("使用成功，本週已使用盟主的贈禮%d張", nCount, 1));

	Log("[Lottery] exchange ticket:", pPlayer.dwID, "current ticket count:", nCount);

	return true;
end

function Lottery:IsInvalidTicket(pPlayer)
	return MarketStall:CheckIsLimitPlayer(pPlayer);
end

function Lottery:Rule(pPlayer, tbExcept)
	local nVipLevel = pPlayer.GetVipLevel();
	local nWeekCardEndTime = Recharge:GetDaysCardEndTime(pPlayer, 1);
	local nDrawTime = self:GetDrawTime();
	local bIsWeekCardState = nWeekCardEndTime >= nDrawTime;
	if nVipLevel < self.VIP_MIN or not bIsWeekCardState then
		local nMinRank = 3;
		for i = 1, nMinRank do
			tbExcept[i] = true;
		end
	elseif nVipLevel > self.VIP_MAX then
		tbExcept[1] = true;
	end

	self:FilterLucky(pPlayer, tbExcept);
end

function Lottery:FilterLucky(pPlayer, tbExcept)
	local nLimitRank = 2;
	local dwPlayerId = pPlayer.dwID;
	local tbLucky = self:GetLuckyRecord();
	if not tbLucky[dwPlayerId] or tbLucky[dwPlayerId] > nLimitRank then
		return;
	end

	for nRank = 1, nLimitRank do
		tbExcept[nRank] = true;
	end
end

function Lottery:SendTicket(pPlayer, szType)
	if not Lottery:IsOpen() then
		return;
	end

	local nItemId = self:GetTicketItem();
	local nCount = self:GetAwardTicketCount(szType);
	local nCurTime = GetTime();
	local nDrawTime = self:GetDrawTime(nCurTime);
	local nTimeout = math.max(nCurTime + 1, nDrawTime - 30);

	local tbAward = {{"item", nItemId, nCount, nTimeout}};
	pPlayer.SendAward(tbAward, true, false, Env.LogWay_Lottery_Award);
end

function Lottery:Notify()
	if not self:IsOpen() then
		self:Open();
	end
	
	local szKey = self.NEWINFO_KEY_NOTIFY; 
	local nEndTime = self:GetDrawTime();
	local tbSetting = { szTitle = "盟主的贈禮", szUiName = "LotteryNotify" }; 
	NewInformation:AddInfomation(szKey, nEndTime, {}, tbSetting);

	local tbData = self:GetRecordData();
	tbData.bIsNotify = true;
	ScriptData:SaveAtOnce(KEY_RECORD, tbData);
end

function Lottery:GetPlayerTicketCount(pPlayer)
	local tbData = self:GetRecordData();
	if not tbData.nDrawWeek then
		Log("[ERROR][Lottery] the lottery is not opened, but someone try to get player ticket count!", pPlayer.dwID);
		Log(debug.traceback());
		return 0;
	end

	local nWeek = pPlayer.GetUserValue(self.USER_GROUP, self.USER_KEY_WEEK);
	if tbData.nDrawWeek > nWeek then
		pPlayer.SetUserValue(self.USER_GROUP, self.USER_KEY_WEEK, tbData.nDrawWeek);
		pPlayer.SetUserValue(self.USER_GROUP, self.USER_KEY_TICKET, 0);

		Log("[Lottery] clear ticket count, player:", pPlayer.dwID, "week:", nWeek, tbData.nDrawWeek);
	end
	return pPlayer.GetUserValue(self.USER_GROUP, self.USER_KEY_TICKET);
end

function Lottery:OnLogin(pPlayer)
	self:RefreshTicketData(pPlayer);
	self:SyncLotteryState(pPlayer);
end

function Lottery:HasValidTicket(dwPlayerId)
	local tbPlayerData = self:GetPlayerTicketData(dwPlayerId);
	return tbPlayerData and true or false;
end

function Lottery:OnBuyDaysCard(pPlayer, nGroupIndex)
	if nGroupIndex == 1 then
		-- 购买周卡刷新数据
		self:RefreshTicketData(pPlayer);
	end
end

function Lottery:OnVipChanged(pPlayer)
	self:RefreshTicketData(pPlayer);
end

function Lottery:RefreshTicketData(pPlayer)
	local bRet = self:IsAvailable();
	if not bRet then
		return;
	end

	local nCount = self:GetPlayerTicketCount(pPlayer);
	if nCount <= 0 then
		return;
	end

	self:DoRefreshTicketData(pPlayer, nCount);
end

function Lottery:DoRefreshTicketData(pPlayer, nCount)
	assert(nCount > 0, "failed to refresh ticket data, illegal ticket count:" .. nCount);

	local dwPlayerId = pPlayer.dwID;
	if self:IsInvalidTicket(pPlayer) then
		self:RemoveTicket(dwPlayerId);
		self:AddInvalidTicket(dwPlayerId);	
	else
		self:RemoveInvalidTicket(dwPlayerId);

		local tbExcept = {};
		self:Rule(pPlayer, tbExcept);

		if not next(tbExcept) then
			tbExcept = nil;
		end

		self:AddTicket(dwPlayerId, tbExcept, nCount);
	end
end

function Lottery:IsOpen()
	local tbData = self:GetRecordData();
	return tbData.nDrawWeek and true or false;
end

function Lottery:Open()
	local tbData = self:GetRecordData();
	tbData.nDrawWeek = self:GetDrawWeek();
	ScriptData:SaveAtOnce(KEY_RECORD, tbData);

	Log("[Lottery] lottery open!", tbData.nDrawWeek);
end

function Lottery:IsNotify()
	local tbData = self:GetRecordData();
	return tbData.bIsNotify;
end

function Lottery:CheckNotify()
	if not self:IsOpen() then
		return;
	end

	if self:IsNotify() then
		return;
	end

	local nPassTime = Lib:GetLocalWeekTime();
	if nPassTime <= self.NOTIFY_TIME or nPassTime >= self.DRAW_TIME then
		return;
	end

	self:Notify();
end

function Lottery:SendWorldMsg(nMinute)
	if not self:IsOpen() then
		return;
	end

	local szMsg = string.format("武林盟主將在%d分鐘之後從本週使用過<盟主的饋贈>的少俠中挑選幸運兒贈送驚喜大禮，敬請期待！", nMinute);
	KPlayer.SendWorldNotify(0, 999, szMsg, 0, 1);

	local nItemId = self:GetTicketItem();
	ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.System, szMsg, nil, {nLinkType = ChatMgr.LinkType.Item, nTemplateId = nItemId});
end

function Lottery:SyncLotteryState(pPlayer)
	pPlayer.CallClientScript("Lottery:OnSyncState", self:IsOpen());
end
