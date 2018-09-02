
MarketStall.nMaxLimitTimeFrameCount = 20;	-- 当前支持的冷门物品时间轴限制个数
MarketStall.nMinVipLevel = 6;				-- 小号判定用 VIP 等级
MarketStall.nMinPricePercent = 11;			-- 当购买物品价格低于此(1/10倍数)的基准价格时，不作为冷门物品

MarketStall.nShowPriceLimit = 0.8;			-- 只能看到价格小于或等于 nNormalPrice * MarketStall.nShowPriceLimit 的物品
MarketStall.tbShowLimitTime = {19, 22};		-- 只有此时间段才能上架摆摊物品
MarketStall.tbShowLimitTime[1] = MarketStall.tbShowLimitTime[1] * 3600;
MarketStall.tbShowLimitTime[2] = MarketStall.tbShowLimitTime[2] * 3600;


MarketStall.nLimitType_Buy = 1;
MarketStall.nLimitType_Sell = 2;
MarketStall.nLimitType_BuyMin = 3;

MarketStall.tbLimitDataInfo = MarketStall.tbLimitDataInfo or {nStartTime = GetTime()};

function MarketStall:LoadLimit()
	local szType = "sd";
	local tbParam = {"szMainType", "nSubType"};

	for i = 1, self.nMaxLimitTimeFrameCount do
		szType = szType .. "s";
		table.insert(tbParam, "szLimit" .. i);
	end

	self.tbLimitInfo = {};
	local tbAllStallInfo = LoadTabFile("Setting/MarketStall/MarketStallItem.tab", szType, nil, tbParam);
	for _, tbInfo in pairs(tbAllStallInfo) do
		self.tbLimitInfo[tbInfo.szMainType] = self.tbLimitInfo[tbInfo.szMainType] or {};
		self.tbLimitInfo[tbInfo.szMainType][tbInfo.nSubType or 0] = self.tbLimitInfo[tbInfo.szMainType][tbInfo.nSubType or 0] or {};
		local tbLimit = self.tbLimitInfo[tbInfo.szMainType][tbInfo.nSubType or 0];
		for i = 1, self.nMaxLimitTimeFrameCount do
			local szLimit = tbInfo["szLimit" .. i];
			if szLimit and szLimit ~= "" then
				local szTimeFrame, bLimit = string.match(szLimit, "([^ ]+).*|(%d)");
				bLimit = (bLimit == "1");
				table.insert(tbLimit, {szTimeFrame, bLimit});
			end
			tbInfo["szLimit" .. i] = nil;
		end
	end

	self.tbLimitPlayerInfo = {};
	local tbFile = LoadTabFile("ServerSetting/MarketStall/LimitPlayer.tab", "ssd", nil, {"szTimeFrame", "nDay", "nMinLevel"});
	for _, tbRow in ipairs(tbFile) do
		tbRow.nDay = tonumber(tbRow.nDay);

		assert(tbRow.nDay);

		local nOpenDay = TimeFrame:CalcRealOpenDay(tbRow.szTimeFrame, tbRow.nDay);
		self.tbLimitPlayerInfo[nOpenDay] = {nOpenServerDay = nOpenDay, nMinLevel = tbRow.nMinLevel};
	end
end

function MarketStall:SetPlayerLimit(nPlayerId, nType, nValue, nEndTime)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		KPlayer.AddDelayCmd(nPlayerId, string.format("MarketStall:SetPlayerLimit(%s, %s, %s, %s)", nPlayerId, nType, nValue, nEndTime), "SetPlayerLimit");
		return;
	end

	-- 浮点数的比较有问题，所以做下处理
	nValue = math.floor((nValue + 0.00001) * 10) / 10;

	local bCheck = false;
	for i = 0.1, 2.1, 0.1 do
		i = math.floor((i + 0.000001) * 10) / 10;
		if nValue == i then
			bCheck = true;
			break;
		end
	end

	if not bCheck then
		Log("[MarketStall] SetPlayerLimit ERR ?? ", nPlayerId, nType, nValue, nEndTime)
		return;
	end

	local tbPlayerInfo = pPlayer.GetScriptTable("MarketStall");
	tbPlayerInfo.tbNewLimitInfo = tbPlayerInfo.tbNewLimitInfo or {};
	tbPlayerInfo.tbNewLimitInfo[nType] = {nValue = nValue, nEndTime = nEndTime};

	if nType == self.nLimitType_Sell then
		pPlayer.nMarketStallLimit = nValue * 10;

		self.tbSellLimitCache = self.tbSellLimitCache or {};
		self.tbSellLimitCache[nPlayerId] = {nValue = nValue, nEndTime = nEndTime};
	end

	Log("[MarketStall] SetPlayerLimit", nPlayerId, nType, nValue, nEndTime, Lib:GetTimeStr4(nEndTime));
end

function MarketStall:CheckPlayerLimitTimeout(pPlayer)
	local tbPlayerInfo = pPlayer.GetScriptTable("MarketStall");
	if not tbPlayerInfo or not tbPlayerInfo.tbNewLimitInfo then
		return;
	end

	local nTimeNow = GetTime();
	local tbToRemove = {};

	for nType, tbInfo in pairs(tbPlayerInfo.tbNewLimitInfo) do
		if tbInfo.nEndTime <= nTimeNow then
			tbToRemove[nType] = true;

			if nType == self.nLimitType_Sell then
				pPlayer.nMarketStallLimit = 0;

				if self.tbSellLimitCache and self.tbSellLimitCache[nPlayerId] then
					self.tbSellLimitCache[nPlayerId] = nil;
				end
			end
		end
	end

	for nType in pairs(tbToRemove) do
		tbPlayerInfo.tbNewLimitInfo[nType] = nil;
	end
end

function MarketStall:CheckShowByLimit(pPlayer, tbStallInfo)
	local nNormalPrice = self:GetPriceInfo(tbStallInfo.szMainType, tbStallInfo.nSubType);
	if not nNormalPrice then
		return false;
	end

	local nTimeNow = GetTime();
	local tbPlayerInfo = pPlayer.GetScriptTable("MarketStall");
	if tbPlayerInfo and tbPlayerInfo.tbNewLimitInfo then
		local tbBuyLimit = tbPlayerInfo.tbNewLimitInfo[self.nLimitType_Buy];
		if tbBuyLimit and tbBuyLimit.nEndTime and tbBuyLimit.nEndTime > nTimeNow then
			if tbStallInfo.nPrice >= math.floor(nNormalPrice * tbBuyLimit.nValue) then
				return false;
			end
		end

		local tbBuyLimitMin = tbPlayerInfo.tbNewLimitInfo[self.nLimitType_BuyMin];
		if tbBuyLimitMin and tbBuyLimitMin.nEndTime and tbBuyLimitMin.nEndTime > nTimeNow then
			if tbStallInfo.nPrice <= math.floor(nNormalPrice * tbBuyLimitMin.nValue) then
				return false;
			end
		end
	end

	local nLimit, nEndTime = self:GetPlayerSellLimitInfo(tbStallInfo.nPlayerId);
	if nLimit and (not nEndTime or nEndTime > nTimeNow) then
		if tbStallInfo.nPrice >= math.floor(nNormalPrice * nLimit) then
			return false;
		end
	end

	return true;
end

function MarketStall:GetPlayerSellLimitInfo(nPlayerId)
	self.tbSellLimitCache = self.tbSellLimitCache or {};
	if not self.tbSellLimitCache[nPlayerId] then
		self.tbSellLimitCache[nPlayerId] = {};

		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			local tbPlayerInfo = pPlayer.GetScriptTable("MarketStall");
			if tbPlayerInfo and tbPlayerInfo.tbNewLimitInfo and tbPlayerInfo.tbNewLimitInfo[self.nLimitType_Sell] then
				self.tbSellLimitCache[nPlayerId].nValue = tbPlayerInfo.tbNewLimitInfo[self.nLimitType_Sell].nValue;
				self.tbSellLimitCache[nPlayerId].nEndTime = tbPlayerInfo.tbNewLimitInfo[self.nLimitType_Sell].nEndTime;
			end
		else
			local tbRole = KPlayer.GetRoleStayInfo(nPlayerId);
			if tbRole and tbRole.nMarketStallLimit > 0 then
				self.tbSellLimitCache[nPlayerId].nValue = tbRole.nMarketStallLimit / 10;
			end
		end
	end

	return self.tbSellLimitCache[nPlayerId].nValue, self.tbSellLimitCache[nPlayerId].nEndTime;
end

function MarketStall:CheckAllLimit()
	Log("[MarketStall] CheckAllLimit Start ..............");
	for szMainType, tbInfo in pairs(self.tbLimitInfo) do
		for nSubType, tbLimit in pairs(tbInfo) do
			tbLimit.bLimit = false;
			for _, tbTimeFrame in ipairs(tbLimit) do
				if GetTimeFrameState(tbTimeFrame[1]) == 1 then
					tbLimit.bLimit = tbTimeFrame[2];
				else
					break;
				end
			end
			--if tbLimit.bLimit then
			--	Log("[MarketStall]", szMainType, nSubType or 0, tbLimit.bLimit and "Limit" or "Not Limit");
			--end
		end
	end

	local nCurOpenServerDay = Lib:GetLocalDay(GetServerCreateTime());
	local nCurOpenDay = Lib:GetLocalDay() - nCurOpenServerDay + 1;

	MarketStall.nLimitPlayerLevel = 0;
	for nOpenDay, tbInfo in pairs(self.tbLimitPlayerInfo) do
		if nCurOpenDay >= nOpenDay then
			MarketStall.nLimitPlayerLevel = math.max(MarketStall.nLimitPlayerLevel, tbInfo.nMinLevel);
		end
	end

	Log("[MarketStall] LevelLimit", nCurOpenServerDay, nCurOpenDay, MarketStall.nLimitPlayerLevel);
	Log("[MarketStall] CheckAllLimit End ...............");
end

function MarketStall:CheckIsLimit(szMainType, nSubType)
	if version_hk or version_vn or version_th then
		-- 所有装备设为冷门物品
		szMainType = szMainType or "";
		if Player.AwardType[szMainType] == Player.award_type_item then
			local tbInfo = KItem.GetItemBaseProp(nSubType);
			if tbInfo and tbInfo.szClass == "Unidentify" then
				return true;
			end
		end
	end

	local tbInfo = (self.tbLimitInfo[szMainType] or {})[nSubType or 0];
	if not tbInfo then
		return false;
	end
	return tbInfo.bLimit;
end

function MarketStall:CheckIsLimitPlayer(pPlayer)
	if pPlayer.nLevel >= self.nLimitPlayerLevel then
		return false;
	end

	if pPlayer.GetVipLevel() >= self.nMinVipLevel then
		return false;
	end

	return true;
end

function MarketStall:CheckBuyFromSystem(pPlayer, szMainType, nSubType, nCount, nPrice)
	local nNormalPrice = self:GetPriceInfo(szMainType, nSubType);
	if not nNormalPrice then
		return false;
	end

	if nPrice * 10 < nNormalPrice * self.nMinPricePercent then
		return false;
	end

	local bLimitItem = self:CheckIsLimit(szMainType, nSubType);
	if not bLimitItem then
		return false;
	end

	if not self:CheckIsLimitPlayer(pPlayer) then
		return false;
	end

	return true;
end

function MarketStall:OutputInfo(file, nMaxCountOneTimes)
	for i = 1, nMaxCountOneTimes do
		if not self.tbOutPutInfo[self.nCurIndex] then
			self.tbOutPutInfo = nil;
			self.nCurIndex = nil;
			file:close();
			return false;
		end
		local nPlayerId, nCount = unpack(self.tbOutPutInfo[self.nCurIndex]);
		local tbStayInfo = KPlayer.GetRoleStayInfo(nPlayerId);
		if tbStayInfo then
			local szAccount = KPlayer.GetPlayerAccount(nPlayerId) or "";
			file:write(string.format("%s\t%s\t%s\t%s\t%s\t%s\t%s\n", nPlayerId, szAccount, tbStayInfo.szName, tbStayInfo.nVipLevel, tbStayInfo.nHonorLevel, tbStayInfo.nLevel, nCount));
		else
			Log("[MarketStall] OutputLimitDataInfo ERROR PlayerId", nPlayerId, nCount);
		end
		self.nCurIndex = self.nCurIndex + 1;
	end

	if self.tbOutPutInfo then
		Timer:Register(5, function () self:OutputInfo(file, nMaxCountOneTimes); end)
	end
end

function MarketStall:OutputLimitDataInfo(bNotSync)
	if self.tbOutPutInfo then
		return;
	end

	self.nCurIndex = 1;
	self.tbOutPutInfo = {};
	for nPlayerId, nCount in pairs(self.tbLimitDataInfo.tbPlayerInfo or {}) do
		table.insert(self.tbOutPutInfo, {nPlayerId, nCount});
	end

	local szFileName = "stat/" .. os.date("%Y%m%d%H%M%S-", self.tbLimitDataInfo.nStartTime) .. os.date("%Y%m%d%H%M%S.tab", GetTime());
	Log("[MarketStall] OutputLimitDataInfo ", szFileName);

	local file = io.open(szFileName, "w+");
	local nMaxCountOneTimes = bNotSync and 100000 or 100;
	file:write("nPlayerId\tszOpenId\tszName\tnVipLevel\tnHonorLevel\tnLevel\tnCount\n");
	self:OutputInfo(file, nMaxCountOneTimes);
end

function MarketStall:OnBuyItem(pPlayer, nSellerId, nGoldCount)
	if not self:CheckIsLimitPlayer(pPlayer) then
		return;
	end

	self.tbLimitDataInfo.tbPlayerInfo = self.tbLimitDataInfo.tbPlayerInfo or {};
	self.tbLimitDataInfo.tbPlayerInfo[nSellerId] = self.tbLimitDataInfo.tbPlayerInfo[nSellerId] or 0;
	self.tbLimitDataInfo.tbPlayerInfo[nSellerId] = self.tbLimitDataInfo.tbPlayerInfo[nSellerId] + nGoldCount;
end