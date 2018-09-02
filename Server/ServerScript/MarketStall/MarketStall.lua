
MarketStall.tbMgr = MarketStall.tbMgr or GetMarketStallMgr();
local MarketMgr = MarketStall.tbMgr;

MarketStall.nSaveCount = 10;
MarketStall.tbToSave = MarketStall.tbToSave or {};
MarketStall.tbAllStall = MarketStall.tbAllStall or {};
MarketStall.tbWaittingStall = MarketStall.tbWaittingStall or {};
MarketStall.tbTimeoutInfo = MarketStall.tbTimeoutInfo or {};
MarketStall.tbWaittingTimeout = MarketStall.tbWaittingTimeout or {};
MarketStall.tbActive = MarketStall.tbActive or {};
MarketStall.tbStallInfoByPlayer = MarketStall.tbStallInfoByPlayer or {};
MarketStall.tbPlayerShowStallInfo = MarketStall.tbPlayerShowStallInfo or {};
MarketStall.tbAveragePrice = MarketStall.tbAveragePrice or {};							-- 近期平均成交价
MarketStall.tbAverageStallPrice = MarketStall.tbAverageStallPrice or {};				-- 当前上架物品平均价格

-- 系统插入物品交易ID，防止和正常ID冲突，所以选取个很大的数字（不要再大了，lua用的double类型，在大double的精度就不够用了），
-- 讲道理的话，这个数字已经足够支持每天产生61亿个上架物品持续1000年了
-- MarketStall.MIN_EXT_STALL_ID / (365 * 1000) = 61亿
MarketStall.MIN_EXT_STALL_ID = 2048 * 2048 * 2048 * 2048 * 128;
MarketStall.MAX_RANDOM_RATE = 10000;
MarketStall.tbExtStallInfo = MarketStall.tbExtStallInfo or {nMaxStallId = MarketStall.MIN_EXT_STALL_ID, tbExtStall = {}};
MarketStall.nCurMaxStallId = 0;

MarketStall.bOpenPreStall = true;
MarketStall.nPreStallPoolCount = 5; --预上架池子数量
MarketStall.nPreStallTime = 60 * 60;  --预上架时间

MarketStall.nItemPreStallId = 1;
MarketStall.nPlayerPreStallId = 1;


function MarketStall:Setup()
	MarketStall:LoadLimit();
	self:CheckAllLimit();

	table.sort(self.tbWaittingTimeout);

	self:RandomNextStallTime();
	self:InitMSSoldPrice();
end

function MarketStall:InitMSSoldPrice()
	local tbSoldPriceInfo = ScriptData:GetValue("MSSoldPrice");
	for szMainType, tbSInfo in pairs(tbSoldPriceInfo) do
		for nSubType, tbInfo in pairs(tbSInfo) do
			local tbAverageInfo = Lib:InitTable(self.tbAveragePrice, szMainType, nSubType);
			tbAverageInfo.tbData = {};
			for i =  1, tbInfo[1] do
				tbAverageInfo.tbData[i] = tbInfo[2];
			end
			tbAverageInfo.nOldIdx = 1;
			tbAverageInfo.nAvaragePrice = tbInfo[2];
		end
	end
end

function MarketStall:SaveSoldPrice(szMainType, nSubType, nCount, nAvaragePrice)
	local tbSoldPriceInfo = ScriptData:GetValue("MSSoldPrice");
	local tbSoldInfo = Lib:InitTable(tbSoldPriceInfo, szMainType, nSubType or 0);
	tbSoldInfo[1] = nCount;
	tbSoldInfo[2] = nAvaragePrice;
	ScriptData:AddModifyFlag("MSSoldPrice");
end

function MarketStall:OnQuit()
	self.bClose = true;
	for _, nStallId in pairs(MarketStall.tbToSave) do
		local tbStallInfo = self.tbAllStall[nStallId];
		if tbStallInfo and tbStallInfo.bNeedSave then
			MarketMgr.UpdateStallItem(nStallId, tbStallInfo.nPrice, tbStallInfo.nCount, tbStallInfo.nCacheMoney);
		end
	end
	MarketStall.tbToSave = {};

	MarketStall:OutputLimitDataInfo(true)
end

function MarketStall:RandomNextStallTime()
	local nTimeNow = GetTime();
	local nTodaySec = Lib:GetTodayZeroHour(nTimeNow);
	if nTimeNow >= nTodaySec + self.tbForbiddenTime[1] and nTimeNow <= nTodaySec + self.tbForbiddenTime[2] then
		nTimeNow = nTodaySec + self.tbForbiddenTime[2];
	end

	local nLastTime = self.nNextStallTime or 0;
	self.nNextStallTime = nTimeNow + self.nJoinGlobalStallSpace + MathRandom(self.nMaxRandomRefreshTime);
	Log("[MarketStall] RandomNextStallTime ", self.nNextStallTime, nLastTime);
end

function MarketStall:LoadData(nStallId, nPlayerId, szMainType, nSubType, nPrice, nCount, nCacheMoney, nMoneyType, nTime)
	local tbStallInfo = {nPlayerId = nPlayerId, szMainType = szMainType, nSubType = nSubType, nPrice = nPrice, nCount = nCount, nCacheMoney = nCacheMoney, nMoneyType = nMoneyType, nTime = nTime};
	self.tbAllStall[nStallId] = tbStallInfo;
	tbStallInfo.nType = self:GetItemType(szMainType, nSubType);

	local nTimeNow = GetTime();
	local nTimeout = nTime + self.nTimeout;
	if not tbStallInfo.nType or nTimeout <= nTimeNow then
		tbStallInfo.bTimeout = true;
	else
		if nTimeNow - nTime >= self.nStartServerJoinGlobalStallTime then
			self:StallItem(nStallId, tbStallInfo);
		else
			table.insert(self.tbWaittingStall, nStallId);
		end

		if not self.tbTimeoutInfo[nTimeout] then
			self.tbTimeoutInfo[nTimeout] = {};
			table.insert(self.tbWaittingTimeout, nTimeout);
		end

		self.tbTimeoutInfo[nTimeout][nStallId] = true;
		self:SaveAveragePriceInfo(tbStallInfo.szMainType, tbStallInfo.nSubType, tbStallInfo.nCount, tbStallInfo.nPrice, true);
	end

	self.tbStallInfoByPlayer[nPlayerId] = self.tbStallInfoByPlayer[nPlayerId] or {};
	self.tbStallInfoByPlayer[nPlayerId][nStallId] = true;
	self.nCurMaxStallId = math.max(self.nCurMaxStallId, nStallId);
end

function MarketStall:DoSaveDataActive(nTimeNow)
	-- 保存数据
	local nCurCount = 0;
	for nIndex, nStallId in ipairs(MarketStall.tbToSave) do
		local tbStallInfo = self.tbAllStall[nStallId];
		if tbStallInfo and tbStallInfo.bNeedSave then
			nCurCount = nCurCount + 1;
			tbStallInfo.bNeedSave = false
			MarketMgr.UpdateStallItem(nStallId, tbStallInfo.nPrice, tbStallInfo.nCount, tbStallInfo.nCacheMoney);
		end

		if nCurCount > self.nSaveCount then
			break;
		end
	end

	for i = #MarketStall.tbToSave, 1, -1 do
		local tbStallInfo = self.tbAllStall[MarketStall.tbToSave[i]];
		if not tbStallInfo or not tbStallInfo.bNeedSave then
			table.remove(MarketStall.tbToSave, i);
		end
	end
end

function MarketStall:DoCheckTimeoutActive(nTimeNow)
	local nCurIndex = 0;
	for nIndex, nTimeout in ipairs(self.tbWaittingTimeout) do
		if nTimeout > nTimeNow then
			break;
		end
		local nTime = nTimeout - self.nTimeout;
		local tbTimeout = self.tbTimeoutInfo[nTimeout] or {};
		for nStallId in pairs(tbTimeout) do
			local tbStallInfo = self.tbAllStall[nStallId];
			if tbStallInfo and tbStallInfo.nTime <= nTime and tbStallInfo.nCount > 0 then
				local pTimeouter = KPlayer.GetPlayerObjById(tbStallInfo.nPlayerId);
				if pTimeouter then
					pTimeouter.CallClientScript("MarketStall:OnEvent", self.emEvent_OnItemTimeout);
				end

				if tbStallInfo.tbActiveTable then
					tbStallInfo.tbActiveTable[nStallId] = nil;
					tbStallInfo.tbActiveTable = nil;
				end

				tbStallInfo.bTimeout = true;

				self:SaveAveragePriceInfo(tbStallInfo.szMainType, tbStallInfo.nSubType, tbStallInfo.nCount, tbStallInfo.nPrice, false);
			end
		end
		self.tbTimeoutInfo[nTimeout] = nil;
		nCurIndex = nIndex;
	end

	for i = 1, nCurIndex do
		table.remove(self.tbWaittingTimeout, 1);
	end
end

function MarketStall:DoStallItemActive(nTimeNow)
	if self.nNextStallTime >= nTimeNow then
		return;
	end

	for nIndex, nStallId in ipairs(self.tbWaittingStall) do
		local tbStallInfo = self.tbAllStall[nStallId];
		if tbStallInfo then
			self:StallItem(nStallId, tbStallInfo);
		end
	end
	self.tbWaittingStall = {};
	self:RandomNextStallTime();
end

function MarketStall:Activate(nTimeNow)
	self:DoSaveDataActive(nTimeNow);
	self:DoCheckTimeoutActive(nTimeNow);
	self:DoStallItemActive(nTimeNow);
end

function MarketStall:StallItem(nStallId, tbStallInfo)
	if tbStallInfo.nCount <= 0 then
		return;
	end

	local nType = tbStallInfo.nType;
	if not nType then
		Log("[MarketStall] Unknow StallItem Type ", nStallId, tbStallInfo.szMainType, tbStallInfo.nSubType, tbStallInfo.nTime);
		return;
	end

	self.tbActive[nType] = self.tbActive[nType] or {};
	self.tbActive[nType][nStallId] = tbStallInfo;
	tbStallInfo.tbActiveTable = self.tbActive[nType];
	tbStallInfo.nPreStallId = self.nItemPreStallId;
	self.nItemPreStallId = self.nItemPreStallId + 1;

	local nTimeNow = GetTime();
	if tbStallInfo.nTime + MarketStall.nMaxRandomRefreshTime + MarketStall.nJoinGlobalStallSpace <= nTimeNow then
		tbStallInfo.nPreStallTime = tbStallInfo.nTime + MarketStall.nMaxRandomRefreshTime + MarketStall.nJoinGlobalStallSpace;
	else
		tbStallInfo.nPreStallTime = nTimeNow;
	end

	local nTodayZeroTime = Lib:GetTodayZeroHour(nTimeNow);
	local nPreStallEndTime = tbStallInfo.nPreStallTime + self.nPreStallTime;
	if nPreStallEndTime > nTodayZeroTime + self.tbForbiddenTime[1] and nPreStallEndTime < nTodayZeroTime + self.tbForbiddenTime[2] then
		tbStallInfo.nPreStallTime = nTodayZeroTime + self.tbForbiddenTime[2] + self.nJoinGlobalStallSpace + MathRandom(self.nMaxRandomRefreshTime);
	end
end

function MarketStall:AddExtStallInfo(szMainType, nSubType, nCount, nPrice, nRate)
	if nCount <= 0 or nCount > 100 then
		Log("[MarketStall] AddExtStallInfo ERR ?? nCount is nil !!", szMainType, nSubType, nCount, nPrice, nRate);
		return false;
	end

	local nNorPrice, tbAllow = MarketStall:GetPriceInfo(szMainType, nSubType);
	if not nNorPrice then
		Log("[MarketStall] AddExtStallInfo ERR ?? nPrice is nil !!", szMainType, nSubType, nCount, nPrice, nRate);
		return false;
	end

	if not tbAllow[nPrice] then
		nPrice = 0;
		for nP in pairs(tbAllow) do
			nPrice = math.max(nP, nPrice);
		end
	end

	local nType = self:GetItemType(szMainType, nSubType);
	local nStallId = self.tbExtStallInfo.nMaxStallId;
	self.tbExtStallInfo.nMaxStallId = self.tbExtStallInfo.nMaxStallId + 1;
	self.tbExtStallInfo.tbExtStall[nStallId] = {nRate = nRate, nType = nType, nPlayerId = 0, szMainType = szMainType, nSubType = nSubType, nPrice = nPrice, nCount = nCount, nCacheMoney = 0, nMoneyType = 0, nTime = 0};

	Log("[MarketStall] AddExtStallInfo", szMainType, nSubType, nCount, nPrice, nRate, nStallId);
	return nStallId;
end

function MarketStall:RemoveExtStallInfo(nStallId)
	if not nStallId or not self.tbExtStallInfo or not self.tbExtStallInfo.tbExtStall then
		return;
	end

	local tbStall = self.tbExtStallInfo.tbExtStall[nStallId];
	self.tbExtStallInfo.tbExtStall[nStallId] = nil

	if tbStall then
		Log("[MarketStall] RemoveExtStallInfo ", nStallId, tbStall.szMainType, tbStall.nSubType, tbStall.nCount, tbStall.nPrice);
	end

	return true
end

function MarketStall:SaveAveragePriceInfo(szMainType, nSubType, nCount, nPrice, bAdd)
	local tbAverage = self:GetAveragePriceInfo(szMainType, nSubType);
	if bAdd then
		tbAverage.nTotalPrice = tbAverage.nTotalPrice + nCount * nPrice;
		tbAverage.nTotalCount = tbAverage.nTotalCount + nCount;
	else
		tbAverage.nTotalPrice = math.max(tbAverage.nTotalPrice - nCount * nPrice, 0);
		tbAverage.nTotalCount = math.max(tbAverage.nTotalCount - nCount, 0);
	end

	if tbAverage.nTotalCount <= 0 or tbAverage.nTotalPrice <= 0 then
		tbAverage.nTotalPrice = 0;
		tbAverage.nTotalCount = 0;
		tbAverage.nAveragePrice = 0;
	else
		tbAverage.nAveragePrice = tbAverage.nTotalPrice / tbAverage.nTotalCount;
	end
end

function MarketStall:GetAveragePriceInfo(szMainType, nSubType)
	nSubType = nSubType or 0;
	self.tbAverageStallPrice[szMainType] = self.tbAverageStallPrice[szMainType] or {};
	self.tbAverageStallPrice[szMainType][nSubType] = self.tbAverageStallPrice[szMainType][nSubType] or {nTotalPrice = 0; nTotalCount = 0; nAveragePrice = 0};
	return self.tbAverageStallPrice[szMainType][nSubType];
end

function MarketStall:GetStallInfoByStallId(nStallId)
	local tbStallInfo;
	if nStallId >= self.MIN_EXT_STALL_ID then
		tbStallInfo = self.tbExtStallInfo.tbExtStall[nStallId];
	else
		tbStallInfo = self.tbAllStall[nStallId];
	end
	return tbStallInfo;
end

function MarketStall:GetStallItemInfo(nStallId, bNeedCahceMoney)
	local tbStallInfo = self:GetStallInfoByStallId(nStallId);

	local tbResult = {};
	if tbStallInfo then
		local tbSetting = self.tbAllStallInfo[tbStallInfo.szMainType]
		if tbStallInfo.nSubType then
			tbSetting = tbSetting[tbStallInfo.nSubType]
		end

		tbResult.nType = (tbSetting or {nType = 0}).nType;
		tbResult.nStallId = nStallId;
		tbResult.szMainType = tbStallInfo.szMainType;
		tbResult.nSubType = tbStallInfo.nSubType;
		tbResult.nCount = tbStallInfo.nCount;
		tbResult.nPrice = tbStallInfo.nPrice;
		if bNeedCahceMoney then
			tbResult.nCacheMoney = tbStallInfo.nCacheMoney;
			tbResult.nTime = tbStallInfo.bTimeout and 0 or tbStallInfo.nTime;
		end
	end
	return tbResult;
end

function MarketStall:GetStallItemList(pPlayer, nType, nCount, nPlayerPreStallId)
	self.tbCurStallList = self.tbCurStallList or {};
	self.tbCurStallList[nType] = self.tbCurStallList[nType] or {}
	self.tbUseIndex = self.tbUseIndex or {};
	self.tbUseIndex[nType] = self.tbUseIndex[nType] or 1;

	local nCurGetCount = 0;
	local bHasRange = false;
	local tbResult = {};
	local tbTmpInfo = {};
	while true do
		if bHasRange then
			break;
		end

		if self.tbUseIndex[nType] > #self.tbCurStallList[nType] then
			bHasRange = true;
			local nCurCount = 1;
			self.tbUseIndex[nType] = 1;
			self.tbCurStallList[nType] = {};
			for nStallId, tbStallInfo in pairs(self.tbActive[nType] or {}) do
				table.insert(self.tbCurStallList[nType], MathRandom(nCurCount), nStallId);
				nCurCount = nCurCount + 1;
			end
		end

		while nCurGetCount < nCount do
			local nStallId = self.tbCurStallList[nType][self.tbUseIndex[nType]];
			if not nStallId then
				break;
			end

			self.tbUseIndex[nType] = self.tbUseIndex[nType] + 1;
			local tbStallInfo = self.tbAllStall[nStallId];
			local bCanShow = self:CheckStallCanShow(pPlayer, tbStallInfo, nStallId, tbTmpInfo, nPlayerPreStallId);
			if bCanShow then
				tbTmpInfo[nStallId] = true;
				table.insert(tbResult, nStallId);
				nCurGetCount = nCurGetCount + 1;
			end
		end

		if nCurGetCount >= nCount then
			break;
		end
	end
	tbResult.nCount = nCurGetCount;
	return tbResult;
end

function MarketStall:CheckStallCanShow(pPlayer, tbStallInfo, nStallId, tbTmpInfo, nPlayerPreStallId)
	local nPlayerId = pPlayer and pPlayer.dwID or 0;
	if not tbStallInfo or tbStallInfo.nCount <= 0 or (tbStallInfo.nPlayerId or -1) == nPlayerId or tbTmpInfo[nStallId] then
		return false;
	end

	if self.bOpenPreStall and tbStallInfo.nPreStallTime and tbStallInfo.nPreStallTime + self.nPreStallTime > GetTime() then
		if nPlayerPreStallId and tbStallInfo.nPreStallId % self.nPreStallPoolCount ~= nPlayerPreStallId then
			return false;
		end
	end

	local nSubType = tbStallInfo.nSubType or 0;
	if pPlayer and not MarketStall:CheckShowByLimit(pPlayer, tbStallInfo) then
		return false;
	end

	local _, nShowLimitPrecent = self:GetItemType(tbStallInfo.szMainType, nSubType);
	local tbAverage = self:GetAveragePriceInfo(tbStallInfo.szMainType, nSubType);
	if tbAverage and tbAverage.nAveragePrice and tbAverage.nAveragePrice > 0 and tbStallInfo.nPrice > tbAverage.nAveragePrice * nShowLimitPrecent then
		return false;
	end

	return true;
end

function MarketStall:DoUpdatePlayerShowInfo(pPlayer)
	local nPlayerId = pPlayer.dwID;
	local tbShowInfo = {nLastUpdateTime = GetTime(), tbBuyFromSystemInfo = {}};
	self.tbPlayerShowStallInfo[nPlayerId] = tbShowInfo;

	if not pPlayer.nPlayerPreStallId then
		if MarketStall:CheckIsLimitPlayer(pPlayer) then
			pPlayer.nPlayerPreStallId = -1;
		else
			pPlayer.nPlayerPreStallId = self.nPlayerPreStallId;
			self.nPlayerPreStallId = self.nPlayerPreStallId + 1;
		end
	end

	local nPlayerPreStallId = pPlayer.nPlayerPreStallId > 0 and pPlayer.nPlayerPreStallId % self.nPreStallPoolCount or -1;
	for nType in pairs(self.tbAllType) do
		local nShowCount = MarketStall:GetShowCount(nType);
		nShowCount = MarketStall:GetVipShowCount(nShowCount, pPlayer.GetVipLevel());
		tbShowInfo[nType] = self:GetStallItemList(pPlayer, nType, nShowCount, nPlayerPreStallId);
	end

	for nStallId, tbInfo in pairs(self.tbExtStallInfo.tbExtStall) do
		if MathRandom(self.MAX_RANDOM_RATE) <= tbInfo.nRate then
			tbShowInfo[tbInfo.nType] = tbShowInfo[tbInfo.nType] or {};
			table.insert(tbShowInfo[tbInfo.nType], nStallId);
		end
	end
	return tbShowInfo;
end

function MarketStall:OnLogin(pPlayer)
	MarketStall:CheckPlayerLimitTimeout(pPlayer);

	local tbInfo = self.tbStallInfoByPlayer[pPlayer.dwID];
	local bHasTimeout = false;
	local bHasCacheMoney = false;
	for nStallId in pairs(tbInfo or {}) do
		local tbStallInfo = self.tbAllStall[nStallId];
		if tbStallInfo and tbStallInfo.nPlayerId == pPlayer.dwID then
			if tbStallInfo.bTimeout then
				bHasTimeout = true;
			end

			if tbStallInfo.nCacheMoney > 0 then
				bHasCacheMoney = true;
			end
		end

		if bHasTimeout and bHasCacheMoney then
			break;
		end
	end

	if bHasTimeout then
		pPlayer.CallClientScript("MarketStall:OnEvent", self.emEvent_OnItemTimeout);
	end

	if bHasCacheMoney then
		pPlayer.CallClientScript("MarketStall:OnEvent", self.emEvent_OnItemSelled);
	end

	local tbSelllLimiteData = self:GetSellLimitInfo(pPlayer);
	pPlayer.CallClientScript("MarketStall:OnSyncSelllLimitData", tbSelllLimiteData);
end

function MarketStall:SaveSellingPrice(szMainType, nSubType, nPrice)
	if not nSubType or nSubType <= 0 then
		nSubType = 0;
	end

	local tbAveragePrice = Lib:InitTable(self.tbAveragePrice, szMainType, nSubType);
	tbAveragePrice.tbData = tbAveragePrice.tbData or {};
	if #tbAveragePrice.tbData >= self.nAvaragePriceCount then
		if not tbAveragePrice.nOldIdx or not tbAveragePrice.tbData[tbAveragePrice.nOldIdx] then
			tbAveragePrice.nOldIdx = 1;
		end
		tbAveragePrice.tbData[tbAveragePrice.nOldIdx] = nPrice;
		tbAveragePrice.nOldIdx = tbAveragePrice.nOldIdx + 1;
	else
		table.insert(tbAveragePrice.tbData, nPrice);
	end

	local nTotalPrice = 0;
	for _, nP in ipairs(tbAveragePrice.tbData) do
		nTotalPrice = nTotalPrice + nP;
	end

	tbAveragePrice.nAvaragePrice = math.max(math.floor(nTotalPrice / #tbAveragePrice.tbData), 1);
	self:SaveSoldPrice(szMainType, nSubType, #tbAveragePrice.tbData, tbAveragePrice.nAvaragePrice);
end

function MarketStall:GetAvaragePrice(pPlayer, szMainType, nSubType)
	if not nSubType or nSubType <= 0 then
		nSubType = 0;
	end

	local nAvaragePrice = MarketStall:GetPriceInfo(szMainType, nSubType) or 0;
	if self.tbAveragePrice[szMainType] and self.tbAveragePrice[szMainType][nSubType] then
		nAvaragePrice = self.tbAveragePrice[szMainType][nSubType].nAvaragePrice or nAvaragePrice;
	end

	pPlayer.CallClientScript("MarketStall:OnEvent", self.emEvent_OnGetAvaragePrice, nAvaragePrice);
end

-- 上架物品 bResult, {...}
function MarketStall:NewSellItem(pPlayer, szMainType, nSubType, nCount, nPrice)
	nSubType = nSubType or 0;
	local bCanNewSellItem, szMsg, nCost = self:CheckCanNewSellItem(pPlayer, szMainType, nSubType, nCount, nPrice);
	if not bCanNewSellItem then
		pPlayer.CenterMsg(szMsg, 1);
		pPlayer.CallClientScript("MarketStall:OnEvent", self.emEvent_OnNewSellItem, false);
		return;
	end

	local fnCostCallback = function (nPlayerId, bSuccess, szBillNo, szMainType, nSubType, nCount, nPrice)
		return self:CostGold_NewSellItem(nPlayerId, bSuccess, szMainType, nSubType, nCount, nPrice);
	end

	-- CostGold谨慎调用, 调用前请搜索 _LuaPlayer.CostGold 查看使用说明, 它处调用时请保留本注释
	local bRet = pPlayer.CostGold(nCost, Env.LogWay_MarketStallCostMoneyNewSell, nil, fnCostCallback, szMainType, nSubType, nCount, nPrice);
	if not bRet then
		pPlayer.CallClientScript("MarketStall:OnEvent", self.emEvent_OnNewSellItem, false);
		Log("[MarketStall] Cost Money Fail !!", szMainType, nSubType, nCount, nPrice);
		return;
	end
end

function MarketStall:CostGold_NewSellItem(nPlayerId, bSuccess, szMainType, nSubType, nCount, nPrice)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return false, "扣除手續費中途, 您離線了";
	end

	if not bSuccess then
		pPlayer.CallClientScript("MarketStall:OnEvent", self.emEvent_OnNewSellItem, false);
		return false, "支付失敗請稍後再試";
	end

	nSubType = nSubType or 0;
	local bCanNewSellItem, szMsg, nCost, pItem = self:CheckCanNewSellItem(pPlayer, szMainType, nSubType, nCount, nPrice, true);
	if not bCanNewSellItem then
		return false, "支付超時";
	end

	local nAwardType = Player.AwardType[szMainType];
	if nAwardType == Player.award_type_item then
		nSubType = pItem.dwTemplateId;
		local nConsumeCount = pPlayer.ConsumeItem(pItem, nCount, Env.LogWay_MarketStallCostItem);
		if nConsumeCount ~= nCount then
			Log("[MarketStall] ERR ?? ConsumeItem Fail !!", pItem.dwTemplateId, nConsumeCount, nCount);
			return false, "扣取物品失敗";
		end
	elseif nAwardType == Player.award_type_money then
		local bResult = pPlayer.CostMoney(szMainType, nCount, Env.LogWay_MarketStallCostMoney);
		if not bResult then
			Log("[MarketStall] ERR ?? Cost Sell Item Fail !!", szMainType, nSubType, nCount, nPrice);
			return false, "扣取物品失敗";
		end
	else
		Log("[MarketStall] ERR ?? Consume Unknow Award Type !!", szMainType, nSubType, nCount, nPrice, nConsumeCount);
		return false, "未知原因";
	end

	local nTime = GetTime();
	local nStallId = MarketMgr.NewStallItem(pPlayer.dwID, szMainType, nSubType, nPrice, nCount, nTime, self.nCurMaxStallId);
	if nStallId <= 0 then
		Log("[MarketStall] ERR ?? NewStallItem Error ", nStallId, pPlayer.dwID, szMainType, nSubType, nPrice, nCount, nTime);
		return false, "擺攤系統異常";
	end

	self:LoadData(nStallId, pPlayer.dwID, szMainType, nSubType, nPrice, nCount, 0, 0, nTime);
	pPlayer.CallClientScript("MarketStall:OnEvent", self.emEvent_OnNewSellItem, true, self:GetStallItemInfo(nStallId, true));

	Task:OnTaskExtInfo(pPlayer, Task.ExtInfo_BaiTan);
	Log("[MarketStall] NewSellItem ", pPlayer.dwID, nStallId, szMainType, nSubType, nPrice, nCount, nTime);

	local _,_,_, nAreaId = GetWorldConfifParam()
	local nItemTemplateId = nSubType
	local nItemLevel, nQuality = 0, 0;
	if not nItemTemplateId or nItemTemplateId <= 0 then
		if (Shop.tbMoney[tbStallInfo.szMainType]) then
			nItemTemplateId = - (Shop.tbMoney[tbStallInfo.szMainType]["SaveKey"])
		end
	else
		local tbBaseInfo = KItem.GetItemBaseProp(nItemTemplateId)
		if tbBaseInfo then
			nItemLevel = tbBaseInfo.nLevel
			nQuality = tbBaseInfo.nQuality
		end
	end
	local nMaxLevel = GetMaxLevel()
	pPlayer.TLog("SecAuctionFlow", nAreaId, pPlayer.nFaction, pPlayer.nLevel, pPlayer.szIP, pPlayer.GetVipLevel(), nStallId, 1,
		nPrice * nCount, nItemTemplateId, nCount, nItemLevel, nQuality, MarketStall.nTimeout,nMaxLevel, Env.LogSellType_MarketStall, pPlayer.GetShouldHaveMoney("Gold"))

	return true;
end

-- 重新上架物品 bResult, {...}
function MarketStall:UpdateMyItemPrice(pPlayer, nStallId, nCurPrice)
	local tbStallInfo = self.tbAllStall[nStallId];
	if not tbStallInfo or pPlayer.dwID ~= tbStallInfo.nPlayerId then
		Log("[MarketStall] UpdateMyItemPrice Unknow nStallId", pPlayer.dwID, nStallId, nCurPrice);
		return;
	end

	local bCanUpdate, szMsg, nCost = self:CheckCanUpdateItemPrice(pPlayer, tbStallInfo.szMainType, tbStallInfo.nSubType, tbStallInfo.nCount, nCurPrice);
	if not bCanUpdate then
		pPlayer.CenterMsg(szMsg, true);
		pPlayer.CallClientScript("MarketStall:OnEvent", self.emEvent_OnUpdateMyItemPrice, false);
		return;
	end

	local fnCostCallback = function (nPlayerId, bSuccess, szBillNo, nStallId, nCurPrice)
		return self:CostGold_UpdateMyItemPrice(nPlayerId, bSuccess, nStallId, nCurPrice);
	end

	-- CostGold谨慎调用, 调用前请搜索 _LuaPlayer.CostGold 查看使用说明, 它处调用时请保留本注释
	local bRet = pPlayer.CostGold(nCost, Env.LogWay_MarketStallCostMoneyUpdatePrice, nil, fnCostCallback, nStallId, nCurPrice);
	if not bRet then
		pPlayer.CallClientScript("MarketStall:OnEvent", self.emEvent_OnNewSellItem, false);
		Log("[MarketStall] Cost Money Fail !!", szMainType, nSubType, nCount, nPrice);
		return;
	end
end

function MarketStall:CostGold_UpdateMyItemPrice(nPlayerId, bSuccess, nStallId, nCurPrice)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return false, "扣除手續費中途, 您離線了";
	end

	if not bSuccess then
		pPlayer.CallClientScript("MarketStall:OnEvent", self.emEvent_OnUpdateMyItemPrice, false);
		return false, "支付失敗請稍後再試";
	end

	local tbStallInfo = self.tbAllStall[nStallId];
	if not tbStallInfo or pPlayer.dwID ~= tbStallInfo.nPlayerId then
		Log("[MarketStall] CostGold_UpdateMyItemPrice", nPlayerId, tbStallInfo and tbStallInfo.nPlayerId or "nil");
		return false, "支付超時";
	end

	local bCanUpdate, szMsg, nCost = self:CheckCanUpdateItemPrice(pPlayer, tbStallInfo.szMainType, tbStallInfo.nSubType, tbStallInfo.nCount, nCurPrice, true);
	if not bCanUpdate then
		Log("[MarketStall] CostGold_UpdateMyItemPrice", nPlayerId, nStallId, nCurPrice, szMsg or "nil");
		return false, "支付超時";
	end

	local tbTimeout = self.tbTimeoutInfo[tbStallInfo.nTime + self.nTimeout];
	if tbTimeout then
		tbTimeout[nStallId] = nil;
	end

	if tbStallInfo.tbActiveTable then
		tbStallInfo.tbActiveTable[nStallId] = nil;
		tbStallInfo.tbActiveTable = nil;
	end

	if not tbStallInfo.bTimeout then
		self:SaveAveragePriceInfo(tbStallInfo.szMainType, tbStallInfo.nSubType, tbStallInfo.nCount, tbStallInfo.nPrice, false);
	end

	tbStallInfo.nPrice = nCurPrice;
	tbStallInfo.nTime = GetTime();
	tbStallInfo.bNeedSave = false;
	MarketMgr.UpdateStallItem(nStallId, tbStallInfo.nPrice, tbStallInfo.nCount, tbStallInfo.nCacheMoney, tbStallInfo.nTime);
	self:LoadData(nStallId, tbStallInfo.nPlayerId, tbStallInfo.szMainType, tbStallInfo.nSubType, tbStallInfo.nPrice, tbStallInfo.nCount, tbStallInfo.nCacheMoney, tbStallInfo.nMoneyType, tbStallInfo.nTime);

	pPlayer.CallClientScript("MarketStall:OnEvent", self.emEvent_OnUpdateMyItemPrice, true, self:GetStallItemInfo(nStallId, true));
	Log("[MarketStall] UpdateMyItemPrice ", pPlayer.dwID, nStallId, nCurPrice);

	local nItemTemplateId = tbStallInfo.nSubType
	local nItemLevel, nQuality = 0, 0;
	if not nItemTemplateId or nItemTemplateId <= 0 then
		if (Shop.tbMoney[tbStallInfo.szMainType]) then
			nItemTemplateId = - (Shop.tbMoney[tbStallInfo.szMainType]["SaveKey"])
		end
	else
		local tbBaseInfo = KItem.GetItemBaseProp(nItemTemplateId)
		if tbBaseInfo then
			nItemLevel = tbBaseInfo.nLevel
			nQuality = tbBaseInfo.nQuality
		end
	end

	local szGameAppid, nPlat, nServerIdentity, nAreaId = GetWorldConfifParam()
	local nMaxLevel = GetMaxLevel()
	pPlayer.TLog("SecAuctionFlow", nAreaId, pPlayer.nFaction, pPlayer.nLevel, pPlayer.szIP, pPlayer.GetVipLevel(), nStallId, 1, nCurPrice * tbStallInfo.nCount, nItemTemplateId, nCount,
			nItemLevel, nQuality, MarketStall.nTimeout,nMaxLevel, Env.LogSellType_MarketStall, pPlayer.GetShouldHaveMoney("Gold"))

	return true;
end

-- 下架物品 bResult, {...}
function MarketStall:CancelSellItem(pPlayer, nStallId, bNotNotify)
	local nPlayerId;
	if type(pPlayer) == "number" then
		nPlayerId = pPlayer;
		pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	else
		nPlayerId = pPlayer.dwID;
	end

	local tbPlayerStallInfo = self.tbStallInfoByPlayer[nPlayerId];
	if not tbPlayerStallInfo or not tbPlayerStallInfo[nStallId] then
		return;
	end

	tbPlayerStallInfo[nStallId] = nil;

	local tbStallInfo = self.tbAllStall[nStallId]
	if not tbStallInfo or tbStallInfo.nPlayerId ~= nPlayerId then
		return;
	end

	if not tbStallInfo.bTimeout then
		self:SaveAveragePriceInfo(tbStallInfo.szMainType, tbStallInfo.nSubType, tbStallInfo.nCount, tbStallInfo.nPrice, false);
	end

	if tbStallInfo.tbActiveTable then
		tbStallInfo.tbActiveTable[nStallId] = nil;
		tbStallInfo.tbActiveTable = nil;
	end

	local tbTimeout = self.tbTimeoutInfo[tbStallInfo.nTime + self.nTimeout] or {};
	tbTimeout[nStallId] = nil;

	local tbTmpItemInfo = self:GetStallItemInfo(nStallId)
	self.tbAllStall[nStallId] = nil;
	MarketMgr.CancelStallItem(nStallId);
	Log("[MarketStall] CancelSellItem ", nPlayerId, nStallId, tbStallInfo.szMainType, tbStallInfo.nSubType, tbStallInfo.nCount, tbStallInfo.nCacheMoney);

	if tbStallInfo.nCount > 0 then
		local tbAward = self:GetStallAward(tbStallInfo.szMainType, tbStallInfo.nSubType, tbStallInfo.nCount);
		if pPlayer then
			pPlayer.SendAward({tbAward}, nil, nil, Env.LogWay_MarketStallCancelItem);
		else
			local tbMail = {
				To = tbStallInfo.nPlayerId;
				Title = "物品下架返還";
				From = "系統";
				Text = "物品下架返還物品，請在附件查收！";
				tbAttach = {tbAward};
				nLogReazon = Env.LogWay_MarketStallCancelItem;
			};
			Mail:SendSystemMail(tbMail);
		end
		Log("[MarketStall] CancelSellItem Add Sell Item ", nPlayerId, tbStallInfo.szMainType, tbStallInfo.nSubType, tbStallInfo.nCount);
	end

	if not bNotNotify and pPlayer then
		pPlayer.CallClientScript("MarketStall:OnEvent", self.emEvent_OnCancelSellItem, true, tbTmpItemInfo)
	end
end

-- 获取售卖物品的钱, bResult, nMoney, tbEmptyStallId
function MarketStall:GetCacheMoney(pPlayer, nGetStallId)
	local nAwardMoney = 0;
	local tbPlayerStallInfo = self.tbStallInfoByPlayer[pPlayer.dwID];
	local tbClearStallId = {};
	local tbEmptyStallId = {};
	for nStallId in pairs(tbPlayerStallInfo or {}) do
		local tbStallInfo = self.tbAllStall[nStallId];
		if not tbStallInfo or tbStallInfo.nPlayerId ~= pPlayer.dwID then
			table.insert(tbClearStallId, nStallId);
		elseif not nGetStallId or nGetStallId == nStallId then
			if tbStallInfo.nCount <= 0 then
				table.insert(tbEmptyStallId, nStallId);
				self:CancelSellItem(pPlayer, nStallId, true);
			end
		end
	end

	for _, nStallId in pairs(tbClearStallId) do
		tbPlayerStallInfo[nStallId] = nil;
	end

	pPlayer.CallClientScript("MarketStall:OnEvent", self.emEvent_OnGetCacheMoney, true, 0, tbEmptyStallId);
end

-- 获取我摆摊的物品, {{...}, {...}, ...}
function MarketStall:GetMySellItemInfo(pPlayer)
	local tbPlayerStallInfo = self.tbStallInfoByPlayer[pPlayer.dwID];
	local tbResult = {};
	local tbClearStallId = {};
	for nStallId in pairs(tbPlayerStallInfo or {}) do
		local tbStallInfo = self.tbAllStall[nStallId];
		if not tbStallInfo or tbStallInfo.nPlayerId ~= pPlayer.dwID then
			table.insert(tbClearStallId, nStallId);
		else
			table.insert(tbResult, self:GetStallItemInfo(nStallId, true));
		end
	end

	pPlayer.CallClientScript("MarketStall:OnEvent", self.emEvent_OnGetMySellItemInfo, tbResult);
end

-- 获取指定类型的所有商品
function MarketStall:GetAllItems(pPlayer, nType)
	local nShowCount = self:GetShowCount(nType);
	nShowCount = MarketStall:GetVipShowCount(nShowCount, pPlayer.GetVipLevel());

	-- 由于系统会安插道具，所以留了20个位置，给系统插入的道具
	nShowCount = nShowCount + 20;
	return self:GetItemList(pPlayer, nType, 1, nShowCount);
end

-- 获取一部分商品, nLastUpdateTime, nType, {{...}, {...}, ...}
function MarketStall:GetItemList(pPlayer, nType, nStartIdx, nEndIdx)
	local tbPlayerShowInfo = self.tbPlayerShowStallInfo[pPlayer.dwID];
	if not tbPlayerShowInfo then
		tbPlayerShowInfo = self:DoUpdatePlayerShowInfo(pPlayer)
	end

	local tbCurTypeInfo = tbPlayerShowInfo[nType] or {};

	assert(nStartIdx < nEndIdx);
	local tbResult = {};
	local nCount = #tbCurTypeInfo;
	for i = #tbCurTypeInfo, 1, -1 do
		local nStallId = tbCurTypeInfo[i];
		local tbStallInfo = self:GetStallInfoByStallId(nStallId);
		if not tbStallInfo or (nStallId < self.MIN_EXT_STALL_ID and not tbStallInfo.tbActiveTable) or tbStallInfo.bTimeout or tbStallInfo.nCount <= 0 then
			table.remove(tbCurTypeInfo, i);
			nCount = nCount - 1;
		end
	end

	tbCurTypeInfo.nCount = nCount;

	for i = nStartIdx, nEndIdx do
		local nStallId = tbCurTypeInfo[i];
		if not nStallId then
			break;
		end

		local tbSSInfo = self:GetStallItemInfo(nStallId);
		if tbSSInfo and self:CheckStallCanShow(nil, tbSSInfo, 0, {}) then
			local bHas = false;
			for _, tbInfo in pairs(tbResult) do
				if tbInfo.szMainType == tbSSInfo.szMainType
					and (tbInfo.nSubType or 0) == (tbSSInfo.nSubType or 0)
					and tbInfo.nPrice == tbSSInfo.nPrice then

					tbInfo.nCount = tbInfo.nCount + tbSSInfo.nCount;
					bHas = true;
					break;
				end
			end
			if not bHas then
				table.insert(tbResult, tbSSInfo);
			end
		end
	end

	local tbToRemove = {};
	for nId, tbInfo in ipairs(tbResult) do
		local szMainType, nSubType, nPrice = tbInfo.szMainType, tbInfo.nSubType, tbInfo.nPrice;
		tbPlayerShowInfo.tbBuyFromSystemInfo[szMainType] = tbPlayerShowInfo.tbBuyFromSystemInfo[szMainType] or {};
		tbPlayerShowInfo.tbBuyFromSystemInfo[szMainType][nSubType or 0] = tbPlayerShowInfo.tbBuyFromSystemInfo[szMainType][nSubType or 0] or {};
		tbPlayerShowInfo.tbBuyFromSystemInfo[szMainType][nSubType or 0][nPrice] = tbPlayerShowInfo.tbBuyFromSystemInfo[szMainType][nSubType or 0][nPrice] or 0;
		tbInfo.nCount = tbInfo.nCount - tbPlayerShowInfo.tbBuyFromSystemInfo[szMainType][nSubType or 0][nPrice];
		if tbInfo.nCount <= 0 then
			table.insert(tbToRemove, nId);
		end
	end

	for i = #tbToRemove, 1, -1 do
		table.remove(tbResult, tbToRemove[i]);
	end

	pPlayer.CallClientScript("MarketStall:OnEvent", self.emEvent_OnGetItemList, tbPlayerShowInfo.nLastUpdateTime, nType, tbResult);
end

-- 重新随机一波我看到的商品, 无
function MarketStall:UpdateAllStall(pPlayer, bCostMoney, nLastUpdateTime)
	local tbPlayerShowInfo = self.tbPlayerShowStallInfo[pPlayer.dwID];
	if not tbPlayerShowInfo then
		tbPlayerShowInfo = self:DoUpdatePlayerShowInfo(pPlayer)
	end

	if nLastUpdateTime and tbPlayerShowInfo.nLastUpdateTime ~= nLastUpdateTime then
		return;
	end

	local bInCD = tbPlayerShowInfo.nLastUpdateTime + self.nUpdateStallItemListTime > GetTime();
	if (not bCostMoney and bInCD) or (bCostMoney and not bInCD) then
		return;
	end

	if not bCostMoney then
		self:DoUpdatePlayerShowInfo(pPlayer);
		return;
	end

	local nToday = Lib:GetLocalDay();
	self.tbUpdateTimes = self.tbUpdateTimes or {nDate = nToday};
	if self.tbUpdateTimes.nDate ~= nToday then
		self.tbUpdateTimes = {nDate = nToday};
	end

	self.tbUpdateTimes[pPlayer.dwID] = self.tbUpdateTimes[pPlayer.dwID] or 0;
	if self.tbUpdateTimes[pPlayer.dwID] >= 100 then
		pPlayer.CenterMsg("今日已達擺攤刷新次數上限！");
		return;
	end

	local fnCostCallback = function (nPlayerId, bSuccess)
		local bOk, szErr = self:CostGold_UpdateAllStall(nPlayerId, bSuccess)
		if bOk then
			pPlayer.CallClientScript("MarketStall:OnEvent", self.emEvent_OnUpdateAllStall)
		end
		return bOk, szErr
	end

	-- CostGold谨慎调用, 调用前请搜索 _LuaPlayer.CostGold 查看使用说明, 它处调用时请保留本注释
	local bRet = pPlayer.CostGold(self.nManualRefreshCost, Env.LogWay_MarketUpdateItemCost, nil, fnCostCallback);
	if not bRet then
		pPlayer.CenterMsg("支付失敗請稍後再試");
		return;
	end
end

function MarketStall:CostGold_UpdateAllStall(nPlayerId, bSuccess)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return false, "扣除手續費中途, 您離線了";
	end

	if not bSuccess then
		return false, "支付失敗請稍後再試";
	end

	self.tbUpdateTimes = self.tbUpdateTimes or {nDate = Lib:GetLocalDay()};
	self.tbUpdateTimes[nPlayerId] = self.tbUpdateTimes[nPlayerId] or 0
	self.tbUpdateTimes[nPlayerId] = self.tbUpdateTimes[nPlayerId] + 1;
	self:DoUpdatePlayerShowInfo(pPlayer);
	Log("[MarketStall] CostGold_UpdateAllStall", nPlayerId);

	return true;
end

function MarketStall:GetMarketStallBillNo(nPlayerId, szMainType, nSubType, nPrice, nCount)
	if not MarketStall.nBillNoRandom or MarketStall.nBillNoRandom > 1000000000 then
		MarketStall.nBillNoRandom = MarketStall.nBillNoRandom or 0;
	end

	MarketStall.nBillNoRandom = MarketStall.nBillNoRandom + 1;
	return string.format("%s_%s_%s_%s_%s_%s_%s", nPlayerId, szMainType, nSubType or 0, nPrice, nCount, GetTime(), MarketStall.nBillNoRandom);
end

-- 购买某种商品, bResult, {...}
function MarketStall:BuyItem(pPlayer, szMainType, nSubType, nCount, nPrice)
	if pPlayer.CheckNeedArrangeBag() then
		pPlayer.CenterMsg("背包道具數量過多，請整理一下！");
		return;
	end

	local tbPlayerShowInfo = self.tbPlayerShowStallInfo[pPlayer.dwID];
	if not tbPlayerShowInfo then
		tbPlayerShowInfo = self:DoUpdatePlayerShowInfo(pPlayer)
	end

	local nType = self:GetItemType(szMainType, nSubType);
	if not nType then
		pPlayer.CenterMsg("要購買的物品不存在！");
		return;
	end

	local tbPriceInfo = {};
	for _, nSId in pairs(tbPlayerShowInfo[nType]) do
		local tbStallInfo = self:GetStallInfoByStallId(nSId);
		if tbStallInfo then
			if tbStallInfo.szMainType == szMainType and
				(tbStallInfo.nSubType or 0) == (nSubType or 0) then

				tbPriceInfo[tbStallInfo.nPrice] = tbPriceInfo[tbStallInfo.nPrice] or 0;
				tbPriceInfo[tbStallInfo.nPrice] = tbPriceInfo[tbStallInfo.nPrice] + tbStallInfo.nCount;
			end
		end
	end

	if self:CheckBuyFromSystem(pPlayer, szMainType, nSubType, nCount, nPrice) then
		tbPlayerShowInfo.tbBuyFromSystemInfo[szMainType] = tbPlayerShowInfo.tbBuyFromSystemInfo[szMainType] or {};
		tbPlayerShowInfo.tbBuyFromSystemInfo[szMainType][nSubType or 0] = tbPlayerShowInfo.tbBuyFromSystemInfo[szMainType][nSubType or 0] or {};

		for nCPrice, nSC in pairs(tbPlayerShowInfo.tbBuyFromSystemInfo[szMainType][nSubType or 0]) do
			if tbPriceInfo[nCPrice] then
				tbPriceInfo[nCPrice] = tbPriceInfo[nCPrice] - nSC;
			end
		end
	end

	local nMinPrice = nPrice;
	local nLowerCount = 0;

	for nCP, nCC in pairs(tbPriceInfo) do
		if nCP <= nMinPrice and nCC > 0 then
			nMinPrice = nCP;
			nLowerCount = nCC;
		end
	end

	if nMinPrice < nPrice then
		pPlayer.CallClientScript("MarketStall:OnEvent", self.emEvent_OnHasLowerPrice, szMainType, nSubType, nLowerCount, nMinPrice);
		return;
	end


	local szMarketStallBillNo = self:GetMarketStallBillNo(pPlayer.dwID, szMainType, nSubType, nPrice, nCount);
	local fnCostCallback = function (nPlayerId, bSuccess, szBillNo, szMainType, nSubType, nCount, nPrice)
		return self:CostGold_BuyItem(nPlayerId, bSuccess, szMarketStallBillNo, szMainType, nSubType, nCount, nPrice);
	end

	if self:CheckBuyFromSystem(pPlayer, szMainType, nSubType, nCount, nPrice) then
		fnCostCallback = function (nPlayerId, bSuccess, szBillNo, szMainType, nSubType, nCount, nPrice)
			return self:CostGold_BuyFromSystem(nPlayerId, bSuccess, szMarketStallBillNo, szMainType, nSubType, nCount, nPrice);
		end
	end

	local nItemId = self:GetLogItemIdByStallInfo(szMainType, nSubType)
	-- CostGold谨慎调用, 调用前请搜索 _LuaPlayer.CostGold 查看使用说明, 它处调用时请保留本注释
	local bRet = pPlayer.CostGold(nCount * nPrice, Env.LogWay_MarketStallCostMoneyBuy, szMarketStallBillNo, fnCostCallback, szMainType, nSubType, nCount, nPrice);
	if not bRet then
		pPlayer.CenterMsg("支付失敗請稍後再試");
		return;
	end
end

function MarketStall:GetLogItemIdByStallInfo(szMainType, nSubType)
	local nItemId = nSubType
	if not nItemId or nItemId <= 0 then
		if (Shop.tbMoney[szMainType]) then
			nItemId = - (Shop.tbMoney[szMainType]["SaveKey"])
		end
	end
	return nItemId or 0
end

function MarketStall:GetCanBuyStallInfo(pPlayer, szMainType, nSubType, nPrice)
	local nType = self:GetItemType(szMainType, nSubType);
	if not nType then
		return false, "購買物品不存在";
	end

	local tbPlayerShowInfo = self.tbPlayerShowStallInfo[pPlayer.dwID];
	if not tbPlayerShowInfo then
		tbPlayerShowInfo = self:DoUpdatePlayerShowInfo(pPlayer)
	end

	local nTotalShowCount = 0;
	local tbStallList = {};
	for _, nSId in pairs(tbPlayerShowInfo[nType]) do
		local tbStallInfo = self:GetStallInfoByStallId(nSId);
		if tbStallInfo then
			if tbStallInfo.szMainType == szMainType and
				(tbStallInfo.nSubType or 0) == (nSubType or 0) and
				tbStallInfo.nPrice == nPrice then

				table.insert(tbStallList, {tbStallInfo, nSId});
				nTotalShowCount = nTotalShowCount + tbStallInfo.nCount;
			end
		end
	end

	return true, "", tbStallList, nTotalShowCount, tbPlayerShowInfo;
end

function MarketStall:CostGold_BuyItem(nPlayerId, bSuccess, szBillNo, szMainType, nSubType, nCount, nPrice)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return false, "扣除手續費中途, 您離線了";
	end

	if not bSuccess then
		pPlayer.CallClientScript("MarketStall:OnEvent", self.emEvent_OnBuyItem, false, {szMainType = szMainType, nSubType = nSubType, nPrice = nPrice});
		return false, "支付失敗請稍後再試";
	end

	local bRet, szMsg, tbStallList, nTotalShowCount = self:GetCanBuyStallInfo(pPlayer, szMainType, nSubType, nPrice);
	if not bRet then
		return false, szMsg;
	end

	local function fnSort(a, b)
		if a[2] >= self.MIN_EXT_STALL_ID and b[2] >= self.MIN_EXT_STALL_ID then
			return a[2] >= b[2];
		end

		if a[2] >= self.MIN_EXT_STALL_ID or b[2] >= self.MIN_EXT_STALL_ID then
			return a[2] < self.MIN_EXT_STALL_ID;
		end

		return a[1].nTime < b[1].nTime;
	end

	table.sort(tbStallList, fnSort);

	local tbSellerInfo = {};
	local nCurCount = 0;
	for _, tbInfo in ipairs(tbStallList) do
		local nC, nSellerId = self:BuyItemByStallId(pPlayer, tbInfo[1], tbInfo[2], nCount - nCurCount, szBillNo);
		self:OnBuyItem(pPlayer, nSellerId, nC * nPrice);

		nCurCount = nCurCount + nC;

		if nSellerId and nSellerId > 0 and nC and nC > 0 then
			tbSellerInfo[nSellerId] = tbSellerInfo[nSellerId] or 0;
			tbSellerInfo[nSellerId] = tbSellerInfo[nSellerId] + nC;
		end

		if nCurCount >= nCount then
			break;
		end
	end

	for nSellerId, nSellCount in pairs(tbSellerInfo) do
		local pRoleSeller = KPlayer.GetRoleStayInfo(nSellerId) or {nFaction = 1};
		local szAwardName = self:GetStallAwardName(szMainType, nSubType, pRoleSeller.nFaction);
		local tbMail = {
			To = nSellerId;
			Title = "擺攤所得";
			From = "系統";
			Text = string.format("出售成功：%s\n單價：%s 元寶\n數量：%s\n收益：%s 元寶", szAwardName, nPrice, nSellCount, nPrice * nSellCount);
			tbAttach = {{"Gold", nSellCount * nPrice}};
			nLogReazon = Env.LogWay_MarketStallGetMoney;
			tbParams = {LogReason2 = szBillNo};
		};

		Mail:SendSystemMail(tbMail);
		Log("[MarketStall] Sell Item", nSellerId, szMainType, nSubType or 0, nPrice, nSellCount);
	end

	if nCurCount > 0 then
		local tbAward = self:GetStallAward(szMainType, nSubType, nCurCount);
		pPlayer.SendAward({tbAward}, nil, nil, Env.LogWay_MarketStallGetItem);
		Task:OnTaskExtInfo(pPlayer, Task.ExtInfo_BaiTan);
		Log("[MarketStall] Total CostGold_BuyItem ", pPlayer.dwID, szMainType, nSubType, nCurCount, nPrice, szBillNo);

		local tbLimitInfo = (self.tbSellLimitInfo[szMainType] or {})[nSubType or 0];
		if tbLimitInfo then
			self:OnBuyItem_SellLimit(tbLimitInfo.nType, tbLimitInfo.nSubType, tbLimitInfo.nLevel, GetTime(), pPlayer);
		end
	end

	pPlayer.CallClientScript("MarketStall:OnEvent", self.emEvent_OnBuyItem, nCurCount > 0, {szMainType = szMainType, nSubType = nSubType, nPrice = nPrice, nCount = nTotalShowCount - nCurCount});

	if nCurCount < nCount then
		if nCurCount > 0 then
			pPlayer.CenterMsg(string.format("現貨不足，成功購買 %s 個！", nCurCount), true);
		else
			pPlayer.CenterMsg("現貨不足，元寶返還！", true);
		end

		local nSendGold = math.max((nCount - nCurCount) * nPrice, 0);
		if nSendGold > 0 then
			pPlayer.SendAward({{"Gold", nSendGold}}, nil, nil, Env.LogWay_MarketStallBuyFailSendGold);
		end
		Log("[MarketStall] CostGold_BuyItem buy item fail send gold back! ", pPlayer.dwID, szMainType, nSubType, nCount, nCurCount, nSendGold, nPrice, szBillNo);
	end

	TeacherStudent:TargetAddCount(pPlayer, "BuyMarketStall", 1)

	return true;
end

function MarketStall:BuyItemByStallId(pPlayer, tbStallInfo, nStallId, nCount, szBillNo)
	if tbStallInfo.nCount < 1 then
		return 0;
	end

	local nPrice = tbStallInfo.nPrice;
	nCount = math.min(tbStallInfo.nCount, nCount);

	local nSellerId = tbStallInfo.nPlayerId;
	local pRoleSeller = KPlayer.GetRoleStayInfo(nSellerId) or {nLevel = 0};

	self:SaveAveragePriceInfo(tbStallInfo.szMainType, tbStallInfo.nSubType, nCount, nPrice, false);
	self:SaveSellingPrice(tbStallInfo.szMainType, tbStallInfo.nSubType, nPrice);
	tbStallInfo.nCount = tbStallInfo.nCount - nCount;

	if nStallId < self.MIN_EXT_STALL_ID then
		tbStallInfo.bNeedSave = true;
		table.insert(self.tbToSave, nStallId);
	end

	if tbStallInfo.nCount <= 0 then
		if tbStallInfo.tbActiveTable then
			tbStallInfo.tbActiveTable[nStallId] = nil;
			tbStallInfo.tbActiveTable = nil;
		end
		if nStallId < self.MIN_EXT_STALL_ID then
			self:CancelSellItem(nSellerId, nStallId, true);
		else
			self.tbExtStallInfo.tbExtStall[nStallId] = nil;
		end
	end

	local pSeller = KPlayer.GetPlayerObjById(nSellerId);
	if pSeller then
		pSeller.CallClientScript("MarketStall:OnEvent", self.emEvent_OnItemSelled);
	end

	Log("[MarketStall] CostGold_BuyItem ", pPlayer.dwID, tostring(nStallId), tbStallInfo.szMainType, tbStallInfo.nSubType, nCount, nPrice, szBillNo, nSellerId);

	local pAsyncSeller = KPlayer.GetAsyncData(nSellerId)
	local pSellerRole = KPlayer.GetRoleStayInfo(nSellerId) or {nFaction = 0, nLevel = 0}
	local nItemLevel, nQuality = 0, 0
	local nItemId = self:GetLogItemIdByStallInfo(tbStallInfo.szMainType, tbStallInfo.nSubType)
	if nItemId > 0 then
		local tbBaseInfo = KItem.GetItemBaseProp(nItemId)
		if tbBaseInfo then
			nItemLevel = tbBaseInfo.nLevel
			nQuality = tbBaseInfo.nQuality
		end
	end
	local szSellerAccout = nSellerId > 0 and (KPlayer.GetPlayerAccount(nSellerId) or 0) or 0;
	local nSellerVipLevel = pAsyncSeller and  pAsyncSeller.GetVipLevel() or 0
	local nSellerFightPower = pAsyncSeller and  pAsyncSeller.GetFightPower() or 0

	local szGameAppid, nPlat, nServerIdentity, nAreaId = GetWorldConfifParam()
	TLog("P2PTradeFlow", szGameAppid, nPlat, nServerIdentity, Env.LogWay_MarketStallGetItem, szSellerAccout, nSellerId, pRoleSeller.nLevel, nSellerVipLevel,
		pPlayer.szAccount, pPlayer.dwID, pPlayer.nLevel, pPlayer.GetVipLevel(), Shop.tbMoney["Gold"]["SaveKey"], nCount * nPrice,  nItemId, nCount,
		(pSeller and pSeller.GetMoney("Gold") or 0), pPlayer.GetMoney("Gold") );

	local nMaxLevel = GetMaxLevel()
	TLog("SecAuctionCompleteFlow", szGameAppid, nPlat, nServerIdentity, nAreaId,
		pPlayer.szAccount, pPlayer.dwID, pPlayer.nFaction, pPlayer.nLevel, pPlayer.GetFightPower(), pPlayer.szIP, pPlayer.GetVipLevel(),
		szSellerAccout, nSellerId, pSellerRole.nFaction, pSellerRole.nLevel, (pSeller and pSeller.szIP or 0),
		tostring(nStallId), Player.AwardType[tbStallInfo.szMainType],
		1, nCount * nPrice, nItemId, nCount, nItemLevel, nQuality, nMaxLevel, 0,0,0,0, "",Env.LogSellType_MarketStall,
		pPlayer.GetShouldHaveMoney("Gold"),  nSellerFightPower, nSellerVipLevel, pPlayer.dwKinId, "")
	return nCount, nSellerId;
end

function MarketStall:CostGold_BuyFromSystem(nPlayerId, bSuccess, szBillNo, szMainType, nSubType, nCount, nPrice)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return false, "扣除手續費中途, 您離線了";
	end

	if not bSuccess then
		pPlayer.CallClientScript("MarketStall:OnEvent", self.emEvent_OnBuyItem, false, {szMainType = szMainType, nSubType = nSubType, nPrice = nPrice});
		return false, "支付失敗請稍後再試";
	end

	local bRet, szMsg, tbStallList, nTotalShowCount, tbPlayerShowInfo = self:GetCanBuyStallInfo(pPlayer, szMainType, nSubType, nPrice);
	if not bRet then
		return false, szMsg;
	end

	tbPlayerShowInfo.tbBuyFromSystemInfo[szMainType] = tbPlayerShowInfo.tbBuyFromSystemInfo[szMainType] or {};
	tbPlayerShowInfo.tbBuyFromSystemInfo[szMainType][nSubType or 0] = tbPlayerShowInfo.tbBuyFromSystemInfo[szMainType][nSubType or 0] or {};
	tbPlayerShowInfo.tbBuyFromSystemInfo[szMainType][nSubType or 0][nPrice] = tbPlayerShowInfo.tbBuyFromSystemInfo[szMainType][nSubType or 0][nPrice] or 0;
	local nBuyFromSystemCount = tbPlayerShowInfo.tbBuyFromSystemInfo[szMainType][nSubType or 0][nPrice];

	local nCurCount = math.min(math.max(nTotalShowCount - nBuyFromSystemCount, 0), nCount);
	if nCurCount > 0 then
		local tbAward = self:GetStallAward(szMainType, nSubType, nCurCount);
		pPlayer.SendAward({tbAward}, nil, nil, Env.LogWay_MarketStallGetItem);
		Task:OnTaskExtInfo(pPlayer, Task.ExtInfo_BaiTan);

		local tbLimitInfo = (self.tbSellLimitInfo[szMainType] or {})[nSubType or 0];
		if tbLimitInfo then
			self:OnBuyItem_SellLimit(tbLimitInfo.nType, tbLimitInfo.nSubType, tbLimitInfo.nLevel, GetTime(), pPlayer);
		end
		Log("[MarketStall] Total CostGold_BuyFromSystem ", pPlayer.dwID, szMainType, nSubType, nCurCount, nPrice, szBillNo, pPlayer.szName, pPlayer.szAccount, pPlayer.nLevel, pPlayer.GetVipLevel());
	end

	nBuyFromSystemCount = nBuyFromSystemCount + nCurCount;
	tbPlayerShowInfo.tbBuyFromSystemInfo[szMainType][nSubType or 0][nPrice] = nBuyFromSystemCount;

	if nCurCount < nCount then
		if nCurCount > 0 then
			pPlayer.CenterMsg(string.format("現貨不足，成功購買 %s 個！", nCurCount), true);
		else
			pPlayer.CenterMsg("現貨不足，元寶返還！", true);
		end

		local nSendGold = math.max((nCount - nCurCount) * nPrice, 0);
		if nSendGold > 0 then
			pPlayer.SendAward({{"Gold", nSendGold}}, nil, nil, Env.LogWay_MarketStallBuyFailSendGold);
		end
		Log("[MarketStall] CostGold_BuyFromSystem buy item fail send gold back! ", pPlayer.dwID, szMainType, nSubType, nCount, nCurCount, nSendGold, nPrice, szBillNo, pPlayer.szName, pPlayer.szAccount, pPlayer.nLevel, pPlayer.GetVipLevel());
	end
	pPlayer.CallClientScript("MarketStall:OnEvent", self.emEvent_OnBuyItem, nCurCount > 0, {szMainType = szMainType, nSubType = nSubType, nPrice = nPrice, nCount = nTotalShowCount - nBuyFromSystemCount});

	local nItemLevel, nQuality = 0, 0
	local nItemId = self:GetLogItemIdByStallInfo(szMainType, nSubType)
	if nItemId > 0 then
		local tbBaseInfo = KItem.GetItemBaseProp(nItemId)
		if tbBaseInfo then
			nItemLevel = tbBaseInfo.nLevel
			nQuality = tbBaseInfo.nQuality
		end
	end
	local szGameAppid, nPlat, nServerIdentity, nAreaId = GetWorldConfifParam()
	TLog("P2PTradeFlow", szGameAppid, nPlat, nServerIdentity, Env.LogWay_MarketStallGetItem, "", 0, 0, 0,
		pPlayer.szAccount, nPlayerId, pPlayer.nLevel, pPlayer.GetVipLevel(), Shop.tbMoney["Gold"]["SaveKey"], nCurCount * nPrice,  nItemId, nCurCount,
		0, pPlayer.GetMoney("Gold") );

	local nMaxLevel = GetMaxLevel()
	TLog("SecAuctionCompleteFlow", szGameAppid, nPlat, nServerIdentity, nAreaId,
		pPlayer.szAccount, pPlayer.dwID, pPlayer.nFaction, pPlayer.nLevel, pPlayer.GetFightPower(), pPlayer.szIP, pPlayer.GetVipLevel(),
		"", 0, 0, 0, 0, "", Player.AwardType[szMainType], 1, nCurCount * nPrice, nItemId, nCurCount, nItemLevel, nQuality, nMaxLevel, 0,0,0,0, "",Env.LogSellType_MarketStall,
		pPlayer.GetShouldHaveMoney("Gold"), 0, 0, pPlayer.dwKinId, "");

	TeacherStudent:TargetAddCount(pPlayer, "BuyMarketStall", 1)

	return true;
end