
ChatMgr.ChatAward = ChatMgr.ChatAward or {};

local ChatAward = ChatMgr.ChatAward;

ChatAward.TYPE_GOLD = 1;
ChatAward.TYPE_ITEM = 2;

ChatAward.nShowCount = 20;
ChatAward.tbAllAward =
{
	[1] = {
		nType = ChatAward.TYPE_ITEM;
		nItemId = 4791;
		nCount = 100;
		bWorldNotify = false;
	};
	
	[2] = {
		nType = ChatAward.TYPE_ITEM;
		nItemId = 4792;
		nCount = 100;
		bWorldNotify = false;
	};
	
}

ChatAward.tbDefaultAward =
{
	[1] = 8;
	[2] = 18;
	[3] = 28;
}

ChatAward.tbChatAwardInfo = ChatAward.tbChatAwardInfo or {};

function ChatAward:GetAwardRandomFunc(nAwardId)
	if not self.tbAllAward[nAwardId] then
		return;
	end

	local nType = self.tbAllAward[nAwardId].nType or 0;

	if nType == ChatAward.TYPE_GOLD then
		return self:GetAwardRandomFunc_Gold(nAwardId);
	elseif nType == ChatAward.TYPE_ITEM then
		return self:GetAwardRandomFunc_Item(nAwardId);
	end
end

function ChatAward:GetAwardRandomFunc_Item(nAwardId)
	local tbAward = self.tbAllAward[nAwardId];

	local nTotalRandomCount = 0;
	local function fnRandomAward(nPlayerId, bLimitPlayer)
		if nTotalRandomCount >= tbAward.nCount then
			return nil, false, tbAward.nCount, nTotalRandomCount;
		end

		nTotalRandomCount = nTotalRandomCount + 1;
		return tbAward.nItemId, tbAward.bWorldNotify, tbAward.nCount, nTotalRandomCount;
	end

	local function fnCheckFinish()
		return nTotalRandomCount >= tbAward.nCount, nTotalRandomCount;
	end
	return fnRandomAward, fnCheckFinish;
end

function ChatAward:GetAwardRandomFunc_Gold(nAwardId)
	local nTotalNorAwardCount = 0;
	local nTotalLimitAwardCount = 0;
	local nDefaultAward = 0;
	local nTotalAward = 0;

	for _, tbAward in ipairs(self.tbAllAward[nAwardId]) do
		nDefaultAward = tbAward[2];
		if tbAward[4] then
			nTotalNorAwardCount = nTotalNorAwardCount + tbAward[1];
		else
			nTotalLimitAwardCount = nTotalLimitAwardCount + tbAward[1];
		end
		nTotalAward = nTotalAward + tbAward[1] * tbAward[2];
	end

	local nTotalRandomCount = 0;
	local tbRandomInfo = {};
	local fnGetNorAward = Lib:GetRandomSelect(nTotalNorAwardCount);
	local fnGetLimitAward = Lib:GetRandomSelect(nTotalLimitAwardCount);
	local function fnRandomAward (nPlayerId, bLimitPlayer)
		if nTotalRandomCount >= nTotalNorAwardCount + nTotalLimitAwardCount then
			return nil, false, nTotalNorAwardCount + nTotalLimitAwardCount, nTotalRandomCount, nTotalAward;
		end

		local bWorldNotify = false;
		local nAward = nDefaultAward;
		if bLimitPlayer then
			local nRandom = fnGetLimitAward();
			if tbRandomInfo[nRandom + nTotalNorAwardCount] then
				nRandom = fnGetNorAward();
				tbRandomInfo[nRandom] = nPlayerId;
			else
				tbRandomInfo[nRandom + nTotalNorAwardCount] = nPlayerId;
				for _, tbAward in ipairs(self.tbAllAward[nAwardId]) do
					if not tbAward[4] then
						if nRandom <= tbAward[1] then
							nAward = tbAward[2];
							break;
						else
							nRandom = nRandom - tbAward[1];
						end
					end
				end
			end
		else
			local bNorAward = true;
			local nRandom = fnGetNorAward();
			if tbRandomInfo[nRandom] then
				nRandom = fnGetLimitAward();
				tbRandomInfo[nRandom + nTotalNorAwardCount] = nPlayerId;
				bNorAward = false;
			else
				tbRandomInfo[nRandom] = nPlayerId;
			end

			for _, tbAward in ipairs(self.tbAllAward[nAwardId]) do
				if tbAward[4] == bNorAward then
					if nRandom <= tbAward[1] then
						nAward = tbAward[2];
						bWorldNotify = tbAward[3];
						break;
					else
						nRandom = nRandom - tbAward[1];
					end
				end
			end
		end
		nTotalRandomCount = nTotalRandomCount + 1;
		return nAward, bWorldNotify, nTotalNorAwardCount + nTotalLimitAwardCount, nTotalRandomCount, nTotalAward;
	end

	local function fnCheckFinish()
		return nTotalRandomCount >= nTotalNorAwardCount + nTotalLimitAwardCount, nTotalRandomCount;
	end

	return fnRandomAward, fnCheckFinish;
end

function ChatAward:AddChatAward(szKey, nId, nAwardId, nTimeout)
	if self.tbChatAwardInfo[szKey] then
		Log("[ChatAward] ERROR !! szKey has exist !!", szKey, nTimeout, nAwardId);
		return false,"RedPacket has exist";
	end

	if not nAwardId or not self.tbAllAward[nAwardId] then
		Log("[ChatAward] ERROR !! nAwardId is not exist !!", szKey, nTimeout, nAwardId);
		return false,"RedPacketType is not exist";
	end

	self.tbUseId = self.tbUseId or {};
	if self.tbUseId[nId] then
		Log("[ChatAward] ERROR !! nId has exist !!", szKey, nTimeout, nAwardId, nId);
		return false,"RedPacketId has exist";
	end

	self.tbUseId[nId] = true;

	nTimeout = nTimeout or 900;
	nTimeout = math.min(math.max(nTimeout, 2), 900);

	self.nIdx = self.nIdx or 0;
	self.nIdx = self.nIdx + 1;

	local fnRandom, fnCheckFinish = self:GetAwardRandomFunc(nAwardId);
	if not fnRandom then
		return false, "RedPacketType is not exist";
	end

	self.tbChatAwardInfo[szKey] = {
			nTimeout = GetTime() + nTimeout,
			nAwardId = nAwardId,
			nId = nId,
			nIdx = self.nIdx,
			nType = self.tbAllAward[nAwardId].nType,
			fnRandom = fnRandom,
			fnCheckFinish = fnCheckFinish
	};

	Timer:Register(Env.GAME_FPS * nTimeout, self.CheckFinish, self, nIdx);
	KChat.CacheChatInfo(ChatMgr.ChannelType.Public, 1);
	Log("[ChatAward] AddChatAward", szKey, nTimeout, nAwardId, self.nIdx, nId);
	return true;
end

function ChatAward:CancelChatAward(nId)
	for szKey, tbInfo in pairs(self.tbChatAwardInfo) do
		if tbInfo.nId == nId then
			self.tbChatAwardInfo[szKey] = nil;
			self.tbUseId[nId] = nil;
			Log("[ChatAward] CancelChatAward", szKey, nId);
			return true
		end
	end
end

function ChatAward:CheckFinish(nIdx)
	if nIdx then
		for szKey, tbInfo in pairs(self.tbChatAwardInfo) do
			if nIdx == tbInfo.nIdx then
				local bFinish, nCount = tbInfo.fnCheckFinish();
				local szMsg = string.format("本次口令獎勵已結束！正確口令：“%s”", szKey);
				if nCount > 0 then
					szMsg = szMsg .. string.format("，恭喜%s名俠士獲得獎勵", nCount);
				end
				KPlayer.SendWorldNotify(0, 999, szMsg, 1, 1);
				self.tbChatAwardInfo[szKey] = nil;
				self.tbUseId[tbInfo.nId] = true;
				Log("[ChatAward] ChatAward timeout !!", tbInfo.nIdx, szKey, nCount);
				break;
			end
		end
	end

	local nTimeNow = GetTime();
	local tbToRemove = {};
	for szKey, tbInfo in pairs(self.tbChatAwardInfo) do
		if nTimeNow >= tbInfo.nTimeout then
			tbToRemove[szKey] = true;
			Log("[ChatAward] ChatAward finish !!", tbInfo.nIdx, szKey, nCount)
		end
	end

	for szKey in pairs(tbToRemove) do
		local _, nCount = self.tbChatAwardInfo[szKey].fnCheckFinish();
		local szMsg = string.format("本次口令獎勵已結束！正確口令：“%s”", szKey);
		if nCount > 0 then
			szMsg = szMsg .. string.format("，恭喜%s名俠士獲得獎勵", nCount);
		end
		KPlayer.SendWorldNotify(0, 999, szMsg, 1, 1);
		self.tbUseId[self.tbChatAwardInfo[szKey].nId] = true;
		self.tbChatAwardInfo[szKey] = nil;
	end

	if not next(self.tbChatAwardInfo) then
		KChat.CacheChatInfo(ChatMgr.ChannelType.Public, 0);
	end
end

function ChatAward:OnChat(nSenderId, szKey)
	local pPlayer = KPlayer.GetPlayerObjById(nSenderId);
	if not pPlayer then
		return;
	end

	if not self.tbChatAwardInfo[szKey] then
		return;
	end

	local tbChatAward = self.tbChatAwardInfo[szKey];
	tbChatAward.tbPlayerInfo = tbChatAward.tbPlayerInfo or {};
	if tbChatAward and not tbChatAward.tbPlayerInfo[nSenderId] then
		self:SendChatAward(szKey, pPlayer, tbChatAward);
	end

	self:CheckFinish();
end

function ChatAward:SendChatAward(szKey, pPlayer, tbChatAward)
	if tbChatAward.nType == self.TYPE_GOLD then
		self:SendChatAward_Gold(szKey, pPlayer, tbChatAward);
	elseif tbChatAward.nType == self.TYPE_ITEM then
		self:SendChatAward_Item(szKey, pPlayer, tbChatAward);
	end
end

function ChatAward:SendChatAward_Gold(szKey, pPlayer, tbChatAward)
	local nSenderId = pPlayer.dwID;
	local bIsLimitPlayer = MarketStall:CheckIsLimitPlayer(pPlayer);
	local nAward, bNotify, nTotalCount, nCurrentCount, nTotalAward = tbChatAward.fnRandom(nSenderId, bIsLimitPlayer);
	if not nAward then
		nAward = self.tbDefaultAward[tbChatAward.nAwardId] or 1;
	end

	tbChatAward.tbPlayerInfo[nSenderId] = true;
	tbChatAward.tbShowInfo = tbChatAward.tbShowInfo or {};
	table.insert(tbChatAward.tbShowInfo, 1, {nId = nSenderId, szName = pPlayer.szName, nLevel = pPlayer.nLevel, nFaction = pPlayer.nFaction, nPortrait = pPlayer.nPortrait, nGold = nAward});
	if #tbChatAward.tbShowInfo > self.nShowCount then
		for i = #tbChatAward.tbShowInfo, self.nShowCount + 1, -1 do
			table.remove(tbChatAward.tbShowInfo, i);
		end
	end

	local tbRedBag = {
		szId = "chat_award";
		szTips = "發佈會口令紅包";
		szContent = string.format("口令：“%s”", szKey);
		nMaxReceiver = nTotalCount;
		nGold = nTotalAward;
		nCurrentReceiver = nCurrentCount;
		tbOwner = {
			szName = "";
			nPortrait = 105;
		};
		tbReceivers = tbChatAward.tbShowInfo;
	};
	pPlayer.CallClientScript("Ui:OpenWindow", "RedBagDetailPanel", "viewgrab", "chat_award", false, tbRedBag);
	pPlayer.SendAward({{"Gold", nAward}}, false, false, Env.LogWay_ChatAward);
	pPlayer.CenterMsg(string.format("恭喜俠士！本次紅包口令正確，獲得%s元寶", nAward), true);
	if bNotify then
		KPlayer.SendWorldNotify(0, 999, string.format("恭喜「%s」在口令紅包中，獲得%s元寶！", pPlayer.szName, nAward), 1, 1);
	end
	Log("[ChatAward] Gold ", pPlayer.szName, pPlayer.dwID, pPlayer.szAccount, nAward);
end

function ChatAward:SendChatAward_Item(szKey, pPlayer, tbChatAward)
	local nSenderId = pPlayer.dwID;
	local nAward, bNotify = tbChatAward.fnRandom(nSenderId);
	if not nAward then
		return;
	end

	tbChatAward.tbPlayerInfo[nSenderId] = true;

	pPlayer.SendAward({{"item", nAward, 1}}, false, false, Env.LogWay_ChatAward);
	pPlayer.CallClientScript("Ui:OpenWindow", "ShowGainItem", nAward);
	if bNotify then
		local szName = KItem.GetItemShowInfo(nAward);
		KPlayer.SendWorldNotify(0, 999, string.format("恭喜「%s」在口令獎勵中，獲得%s！", pPlayer.szName, szName), 1, 1);
	end
	Log("[ChatAward] Item ", pPlayer.szName, pPlayer.dwID, pPlayer.szAccount, nAward);
end