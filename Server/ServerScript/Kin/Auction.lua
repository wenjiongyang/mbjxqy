--[[
拍卖:
	1.家族拍卖:
	AuctionData = {
		[nId] = {
			nItemId = ,
			nOrgPrice =
			nCurPrice =
			nLastBidPrice = (竞拍时会记录当前竞拍价格，无则空)
		};

	}
	2.全服拍卖:入口为家族拍卖, 只进行家族流拍的物品的拍卖
]]

Kin.Auction = Kin.Auction or {};
local Auction = Kin.Auction;
Auction.tbAuctionDealRecord = Auction.tbAuctionDealRecord or {}; -- 拍卖成交记录
Auction.tbPersonalAuctionDataVersions = Auction.tbPersonalAuctionDataVersions or {};

-- 起服时若有未完成的拍卖则延时一定时间
function Kin:OnAuctionStart()
	local nNow = GetTime();
	Kin:TraverseKin(function (kinData)
		local tbTypes = Auction:GetAllOpenAuctionsType(kinData.nKinId);
		for _, szType in pairs(tbTypes) do
			local tbAuctionData = Auction:GetAuctionData(kinData.nKinId, szType);
			if tbAuctionData and tbAuctionData.bOpen and next(tbAuctionData.tbItems) and not Auction:IsPermanent(szType) then
				for nId, tbItem in pairs(tbAuctionData.tbItems) do
					tbItem.nTimeOut  = nNow + Kin.AuctionDef.nServerRestartLastingTime;
				end

				tbAuctionData.nStartTime = nNow;
				tbAuctionData.nEndTime = nNow + Kin.AuctionDef.nServerRestartLastingTime;
				tbAuctionData.nFinishTimer = Timer:Register(Env.GAME_FPS * Kin.AuctionDef.nServerRestartLastingTime,
														Auction.FinishAuction, Auction, kinData.nKinId, szType);
				Auction:SaveAuctionData(kinData.nKinId, szType);
			end
		end
	end);

	-- 删除个人拍卖，即，如果已有个人拍卖，则立即使结束 。。
	local tbAuctionData = Auction:GetGlobalAuctionData();
	for nId, tbItem in pairs(tbAuctionData.tbItems or {}) do
		if tbItem.nOwnerId then
			tbItem.nTimeOut = 0;
		end
	end

	-- 行脚商人处理
	local tbDealerAuctionData = Auction:GetDealerAcutionData();
	if tbDealerAuctionData.bOpen then
		for nId, tbItem in pairs(tbDealerAuctionData.tbItems) do
			tbItem.nTimeOut  = nNow + Kin.AuctionDef.nServerRestartLastingTime;
		end

		tbDealerAuctionData.nStartTime = nNow;
		tbDealerAuctionData.nEndTime = nNow + Kin.AuctionDef.nServerRestartLastingTime;
		tbDealerAuctionData.nFinishTimer = Timer:Register(Env.GAME_FPS * Kin.AuctionDef.nServerRestartLastingTime,
														Auction.FinishAuction, Auction, nil, tbDealerAuctionData.szType);
		Auction:SaveAuctionData(nil, tbDealerAuctionData.szType);
	end
end

local nNextCheckGlobalAuctionTime = 0;
local nNextCheckPersonalAuctionTime = 0;
function Kin:AuctionActive(bForceUpdateGlobal)
	local nNow = GetTime();

	-- 全服拍卖过期处理
	if nNow >= nNextCheckGlobalAuctionTime or bForceUpdateGlobal then
		nNextCheckGlobalAuctionTime = math.huge;
		local tbAuctionData = Auction:GetGlobalAuctionData();
		for nId, tbItem in pairs(tbAuctionData.tbItems or {}) do
			if nNow >= tbItem.nTimeOut then
				if tbItem.nBidderId and not tbItem.bSold then
					Auction:OnDeal(nil, "Global", nId);
				end

				Auction:PersonalAuctionFinish(tbAuctionData.tbItems[nId]);

				tbAuctionData.tbItems[nId] = nil;

				local bRet = Lib:CallBack({Kin.Auction.OnGlobalRemove,Kin.Auction,nId});
				if not bRet then
					Log("[Auction] OnGlobalRemove fail",nId)
				end

				tbAuctionData.nVersion = tbAuctionData.nVersion + 1;
			elseif nNextCheckGlobalAuctionTime > tbItem.nTimeOut then
				nNextCheckGlobalAuctionTime = tbItem.nTimeOut;
			end
		end
		Auction:SaveGlobalAuctionData();
	end

	-- 更新全服拍卖
	if nNow >= nNextCheckPersonalAuctionTime then
		nNextCheckPersonalAuctionTime = math.huge;
		local tbPersonAuctionData = ScriptData:GetValue("PersonAuctionPool");
		for nPlayerId, tbWaitAuctionData in pairs(tbPersonAuctionData) do
			for nIntoAuctionTime, tbItems in pairs(tbWaitAuctionData) do
				if nNow > nIntoAuctionTime then
					Auction:AddPlayerAuction2Global(nPlayerId, tbItems);
					tbWaitAuctionData[nIntoAuctionTime] = nil;
					Auction:ModifyPersonalAuctionDataVersion(nPlayerId);
				elseif nNextCheckPersonalAuctionTime > nIntoAuctionTime then
					nNextCheckPersonalAuctionTime = nIntoAuctionTime;
				end
			end
			if not next(tbWaitAuctionData) then
				tbPersonAuctionData[nPlayerId] = nil;
				Auction:ModifyPersonalAuctionDataVersion(nPlayerId, true);
			end
		end
		Auction:OpenGlobalAuction("Personal");
		Auction:SavePersonAuctionData();
	end
end

-- Kin:AddPersonAuction(me.dwID, {{1378, 2}});
function Kin:AddPersonAuction(nPlayerId, tbItems)
	-- 关闭该功能，这里提示，从源头关闭
	Log("Kin:AddPersonAuction", nPlayerId);
	Lib:LogTB(tbItems);
	Log(debug.traceback())

	local tbPersonAuctionData = Auction:GetPersonAuctionData(nPlayerId);
	local nAdd2GlobalAuctionTime = GetTime() + Kin.AuctionDef.nPersonalAuctionWaitingTime;
	if not tbPersonAuctionData[nAdd2GlobalAuctionTime] then
		tbPersonAuctionData[nAdd2GlobalAuctionTime] = {};
	end

	tbItems = Auction:SplitItems(tbItems);
	for _, tbItem in ipairs(tbItems) do
		table.insert(tbPersonAuctionData[nAdd2GlobalAuctionTime], tbItem);
	end

	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		pPlayer.CallClientScript("Kin:PersonalAuctionAddedNotify", tbItems);
	end

	Auction:ModifyPersonalAuctionDataVersion(nPlayerId);
	nNextCheckPersonalAuctionTime = math.min(nNextCheckPersonalAuctionTime, nAdd2GlobalAuctionTime);
	Auction:SavePersonAuctionData();
end

function Kin:StartAuctionDealer()
	Log("Kin:StartAuctionDealer");
	local tbAuctionData = Auction:GetDealerAcutionData();
	tbAuctionData.bOpenPeriod = false;
	if tbAuctionData.bOpen then
		Auction:FinishAuction(nil, tbAuctionData.szType);
	end
	
	local tbItems, szCurTimeFrame = Auction:GetCurrentDealerItems();
	if not next(tbItems) then
		Log("No Items for Dealer Auction");
		return;
	end

	local nNow = GetTime();
	local nOpenTime = CalcTimeFrameOpenTime(szCurTimeFrame);
	local nOverDay = (nNow - nOpenTime)/(24*3600);
	if nOverDay > Kin.AuctionDef.nDealerAutionOpenCount then
		Log("Kin:StartAuctionDealer Over Time", szCurTimeFrame, nOverDay);
		return;
	end

	tbAuctionData.bOpenPeriod = true;
	tbItems = Auction:SplitItems(tbItems);
	tbAuctionData.tbItems = {};

	local nStartTime = nNow + Kin.AuctionDef.nAuctionPrepareTime;
	local nEndTime = nNow + Kin.AuctionDef.nKinAuctionLastingTime + Kin.AuctionDef.nAuctionPrepareTime;
	local nBasePriceSum = 0;
	for nIdx, tbItem in ipairs(tbItems) do
		tbItem.nId       = nIdx;
		tbItem.nOrgPrice = Kin:GetAuctionItemPrice(tbItem.nItemId) * tbItem.nCount;
		tbItem.bSold     = false;
		tbItem.nBidderId = nil;
		tbItem.nMaxPrice = math.ceil(tbItem.nOrgPrice * Kin:GetAuctionMaxPriceRate(tbItem.nItemId));
		tbItem.nCurPrice = Kin:GetAuctionItemRealPrice(tbItem.nItemId, tbItem.nOrgPrice, tbItem.nMaxPrice);
		tbItem.nStartTime  = nStartTime;
		tbItem.nTimeOut  = nEndTime;
		nBasePriceSum = nBasePriceSum + tbItem.nOrgPrice;

		tbAuctionData.tbItems[nIdx] = tbItem;
	end

	tbAuctionData.nVersion = tbAuctionData.nVersion + 1;
	tbAuctionData.szSaleOrderId = string.format("%s_%d_%d_%d", tbAuctionData.szType, 0, nNow, MathRandom(1000));
	tbAuctionData.bOpen = true;
	tbAuctionData.nStartTime = nStartTime;
	tbAuctionData.nEndTime = nEndTime;
	tbAuctionData.nFinishTimer = Timer:Register(
				Env.GAME_FPS * (Kin.AuctionDef.nKinAuctionLastingTime + Kin.AuctionDef.nAuctionPrepareTime),
				Auction.FinishAuction, Auction, nil, tbAuctionData.szType);
	Auction:SaveAuctionData(nil, tbAuctionData.szType);
	
	Auction:Send10MinutsNotify(tbAuctionData.tbItems, tbAuctionData.szType);
	local szGameAppid, nPlat, nServerIdentity, nAreaId = GetWorldConfifParam();
	for i,v in ipairs(tbItems) do
		TLog("AuctionAddFlow", szGameAppid, nPlat, nServerIdentity, tbAuctionData.szType, 0, v.nItemId, v.nCount,"",0)
	end

	TLog("AuctionKinFlow", szGameAppid, nPlat, nServerIdentity, tbAuctionData.szType, 0, nBasePriceSum, 0, 0, 0, tbAuctionData.szSaleOrderId);
end

function Auction:FinishDealerAuction()
	local tbAuctionData = Auction:GetDealerAcutionData();
	if not tbAuctionData or not tbAuctionData.bOpen then
		return;
	end

	local tbBidders = {};
	for nId, tbItem in pairs(tbAuctionData.tbItems) do
		if not tbItem.bSold and tbItem.nBidderId then
			Auction:OnDeal(nil, tbAuctionData.szType, nId);
		end

		if tbItem.bSold and tbItem.nBidderId then
			tbBidders[tbItem.nBidderId] = tbBidders[tbItem.nBidderId] or 0;
			tbBidders[tbItem.nBidderId] = tbBidders[tbItem.nBidderId] + tbItem.nCurPrice;
		end
	end

	for nPlayerId, nGold in pairs(tbBidders) do
		local nRedBagId = Kin.Auction:GetDealerLuckybagIdByCost(nGold);
		if nRedBagId then
			Kin:RedBagOnEvent(nPlayerId, nRedBagId);
		end
	end

	Auction:ClearAuctionData(nil, tbAuctionData.szType);
	Log("FinishDealerAuction");
end

function Auction:ModifyPersonalAuctionDataVersion(nPlayerId, bClear)
	if bClear then
		self.tbPersonalAuctionDataVersions[nPlayerId] = nil;
	else
		self.tbPersonalAuctionDataVersions[nPlayerId] = self.tbPersonalAuctionDataVersions[nPlayerId] or 1;
		self.tbPersonalAuctionDataVersions[nPlayerId] = self.tbPersonalAuctionDataVersions[nPlayerId] + 1;
	end
end

function Auction:PersonalAuctionFinish(tbItem)
	if not tbItem or not tbItem.nOwnerId then
		return;
	end

	local bSold = tbItem.bSold;
	local tbItemInfo = KItem.GetItemBaseProp(tbItem.nItemId);
	if bSold then
		local tbMail = {
			To = tbItem.nOwnerId;
			Title = "個人拍賣所得";
			Text = string.format("恭喜您的[FFFE0D]%s[-]以[FFFE0D]%d元寶[-]的價格賣出，請查收附件！", tbItemInfo.szName, tbItem.nCurPrice);
			From = "拍賣行";
			tbAttach = {{"Gold", tbItem.nCurPrice}};
			nLogReazon = Env.LogWay_PersonalAuction;
		};

		Mail:SendSystemMail(tbMail);
	else
		local tbMail = {
			To = tbItem.nOwnerId;
			Title = "個人拍賣流拍";
			Text = string.format("您的[FFFE0D]%s[-]無人競價，已退回請查收附件！",tbItemInfo.szName);
			From = "拍賣行";
			tbAttach = {{"item", tbItem.nItemId, tbItem.nCount}};
			nLogReazon = Env.LogWay_PersonalAuction;
		};

		Mail:SendSystemMail(tbMail);
	end
	return bSold
end

function Auction:AddPlayerAuction2Global(nPlayerId, tbItems)
	for _, tbItem in pairs(tbItems) do
		Auction:Add2GlobalAuction("Personal", tbItem.nItemId, tbItem.nCount, nPlayerId);
	end
end

function Auction:GetPersonAuctionData(nPlayerId, bOnlySeeSee)
	local tbPersonAuctionData = ScriptData:GetValue("PersonAuctionPool");
	if not tbPersonAuctionData[nPlayerId] and not bOnlySeeSee then
		tbPersonAuctionData[nPlayerId] = {};
	end

	return tbPersonAuctionData[nPlayerId], self.tbPersonalAuctionDataVersions[nPlayerId];
end

function Auction:SavePersonAuctionData()
	ScriptData:AddModifyFlag("PersonAuctionPool");
end

function Auction:IsGlobal(szType)
	return szType == "Global";
end

function Auction:IsPermanent(szType)
	return szType == "Global" or szType == "Dealer";
end

function Auction:OpenGlobalAuction(szAuctionType)
	local tbAuctionData, tbItemsPool = Auction:GetGlobalAuctionData(szAuctionType);
	if not next(tbItemsPool) then
		return;
	end

	local nNow = GetTime();
	local nEndTime = nNow - Lib:GetLocalDayTime() + 3600 * 24; -- 当日0点，合服拍卖功能调整为次日00:00结束
	local nStartTime = nNow + Kin.AuctionDef.nAuctionPrepareTime;
	local nLeftTime = nEndTime - nNow;
	nEndTime = math.max(nEndTime, nStartTime + 10 * 60); -- 最小拍卖时间为10分钟

	for _, tbItem in pairs(tbItemsPool) do
		tbAuctionData.tbItems[tbItem.nId] = tbItem;
		tbItem.nTimeOut   = nEndTime;
		tbItem.nStartTime = nStartTime;
		tbItem.bSold      = false;
		tbItem.nBidderId  = nil;
	end

	tbAuctionData.nVersion = tbAuctionData.nVersion + 1;

	if szAuctionType ~= "Personal" then
		Auction:Send10MinutsNotify(tbItemsPool, tbAuctionData.szType);
	end

	Auction:ClearGlobalAuctionPool(szAuctionType);
	Kin:AuctionActive(true);
	Auction:SaveGlobalAuctionData();
end

function Auction:GetNextGlobalAuctionItemId()
	if not self.nNextGlobalAcutionItemId then
		self.nNextGlobalAcutionItemId = 0;
		local tbAuctionData, tbItemsPools = Auction:GetGlobalAuctionData();
		for nId, _ in pairs(tbAuctionData.tbItems or {}) do
			if self.nNextGlobalAcutionItemId < nId then
				self.nNextGlobalAcutionItemId = nId;
			end
		end

		for _, tbPool in pairs(tbItemsPools) do
			for _, tbItem in pairs(tbPool) do
				if self.nNextGlobalAcutionItemId < tbItem.nId then
					self.nNextGlobalAcutionItemId = tbItem.nId;
				end
			end
		end
	end

	self.nNextGlobalAcutionItemId = self.nNextGlobalAcutionItemId + 1;
	return self.nNextGlobalAcutionItemId;
end

function Auction:Add2GlobalAuction(szAuctionType, nItemId, nCount, nPlayerId)
	local _, tbItemsPool = Auction:GetGlobalAuctionData(szAuctionType);
	local nOrgPrice = Kin:GetAuctionItemPrice(nItemId) * nCount;
	if nOrgPrice <= 0 then
		Log("Auction:Add2GlobalAuction:ERROR", szAuctionType, nItemId, nCount, nPlayerId);
		return;
	end

	local nMaxPrice = math.ceil(nOrgPrice * Kin:GetAuctionMaxPriceRate(nItemId));
	local nNextItemId = Auction:GetNextGlobalAuctionItemId();
	table.insert(tbItemsPool, {
			nId = nNextItemId;
			nOwnerId = nPlayerId;
			nItemId   = nItemId;
			nCount    = nCount;
			nOrgPrice = nOrgPrice;
			nMaxPrice = nMaxPrice;
			nCurPrice = Kin:GetAuctionItemRealPrice(nItemId, nOrgPrice, nMaxPrice);
		});

	local szGameAppid, nPlat, nServerIdentity, nAreaId = GetWorldConfifParam()
	if nPlayerId then --单人拍卖
		local pRole = KPlayer.GetRoleStayInfo(nPlayerId)
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
		local pASync = KPlayer.GetAsyncData(nPlayerId)
		if pRole and pASync then
			local szAccount = KPlayer.GetPlayerAccount(nPlayerId)
			local nItemLevel, nQuality = 0, 0;
			local tbItemBase = KItem.GetItemBaseProp(nItemId)
			if tbItemBase then
				nItemLevel = tbItemBase.nLevel
				nQuality = tbItemBase.nQuality
			end

			local nMaxLevel = GetMaxLevel()
			TLog("SecAuctionFlow", szGameAppid, nPlat, nServerIdentity, szAccount, nPlayerId, nAreaId, pRole.nFaction, pRole.nLevel, (pPlayer and pPlayer.szIP or 0), pASync.GetVipLevel(), nNextItemId, 1, nOrgPrice, nItemId, nCount,
				nItemLevel, nQuality, Kin.AuctionDef.nGlobalAuctionLastingTime, nMaxLevel, Env.LogSellType_AuctionAll, (pPlayer and pPlayer.GetShouldHaveMoney("Gold") or 0))
		end
	end

	TLog("AuctionAddFlow", szGameAppid, nPlat, nServerIdentity, "Global", 0, nItemId, nCount, szAuctionType, nPlayerId or 0)

	Auction:SaveGlobalAuctionData();
	return nNextItemId;
end

---根据拍卖id查询状态， 返回1为在等待池中， 返回2为在全服拍卖中，nil为找不到
function Auction:QueryGlobalAuctionItemById(nId)
	local tbAuctionData, tbItemsPools = Auction:GetGlobalAuctionData();
	for _, tbPool in pairs(tbItemsPools) do
		for _, tbItem in pairs(tbPool) do
			if nId == tbItem.nId then
				return 1;
			end
		end
	end

	if tbAuctionData.tbItems and tbAuctionData.tbItems[nId] then
		return 2;
	end
end



function Auction:RecordNormalAuction(szAuctionType, nKinId)
	self.tbAuctionRecord = self.tbAuctionRecord or {};
	self.tbAuctionRecord[szAuctionType] = self.tbAuctionRecord[szAuctionType] or {};
	self.tbAuctionRecord[szAuctionType][nKinId] = true;
end

function Auction:EraseNormalAution(szAuctionType, nKinId)
	self.tbAuctionRecord = self.tbAuctionRecord or {};
	self.tbAuctionRecord[szAuctionType] = self.tbAuctionRecord[szAuctionType] or {};
	self.tbAuctionRecord[szAuctionType][nKinId] = nil;

	if not next(self.tbAuctionRecord[szAuctionType]) then
		Auction:OpenGlobalAuction(szAuctionType);
	end
end

function Auction:GetGlobalAuctionData(szAuctionType)
	local tbGlobalAuctionData = ScriptData:GetValue("GlobalAuction");
	if not tbGlobalAuctionData.tbAuctionData then
		tbGlobalAuctionData.tbAuctionData = {
			szType = "Global";
			bOpen = true;
			nEndTime = 0;
			nVersion = 0;
			nStartTime = 0;
			tbItems = {};
		};

		tbGlobalAuctionData.tbItemsPool = {};
	end

	local tbItemsPool = tbGlobalAuctionData.tbItemsPool;
	if szAuctionType and not tbGlobalAuctionData.tbItemsPool[szAuctionType] then
		tbGlobalAuctionData.tbItemsPool[szAuctionType] = {};
	end

	if szAuctionType then
		tbItemsPool = tbItemsPool[szAuctionType];
	end

	return tbGlobalAuctionData.tbAuctionData, tbItemsPool;
end

function Auction:GetDealerAcutionData()
	local tbGlobalAuctionData = ScriptData:GetValue("GlobalAuction");
	if not tbGlobalAuctionData.tbDealerAuctionData then
		tbGlobalAuctionData.tbDealerAuctionData = {
			szType = "Dealer";
			bOpen = false;
			nEndTime = 0;
			nVersion = 0;
			nStartTime = 0;
			bOpenPeriod = false;
			tbItems = {};
		};
	end

	return tbGlobalAuctionData.tbDealerAuctionData;
end

function Auction:ClearGlobalAuctionPool(szAuctionType)
	local tbGlobalAuctionData = ScriptData:GetValue("GlobalAuction");
	tbGlobalAuctionData.tbItemsPool[szAuctionType] = {};
end

function Auction:MarkAuctionDeal(nKinId, szType, szName, nItemId, nCount, nPrice, bBidOver)
	local tbDealList = Auction:GetAuctionDealList(nKinId, szType);
	table.insert(tbDealList, 1, {
			szType = szType,
			szName = szName,
			nItemId = nItemId,
			nCount = nCount,
			nPrice = nPrice,
			bBidOver = bBidOver,
			nTime = GetTime(),
		});

	if #tbDealList > Kin.AuctionDef.nMaxDealListNum then
		table.remove(tbDealList);
	end

	Log("Auction:MarkAuctionDeal", nKinId, szType, szName, nItemId, nCount, nPrice, bBidOver)
end

function Auction:GetAuctionDealList(nKinId, szType)
	self.tbAuctionDealRecord = self.tbAuctionDealRecord or {};
	local szKey = Auction:IsPermanent(szType) and szType or nKinId;
	self.tbAuctionDealRecord[szKey] = self.tbAuctionDealRecord[szKey] or {};
	return self.tbAuctionDealRecord[szKey];
end

function Auction:SaveGlobalAuctionData()
	ScriptData:AddModifyFlag("GlobalAuction");
end

-- 结算, 发放奖励
function Auction:FinishAuction(nKinId, szType)
	if Auction:IsGlobal(szType) then
		return;
	elseif szType == "Dealer" then
		Auction:FinishDealerAuction();
		return;
	end

	local tbAuctionData = Auction:GetAuctionData(nKinId, szType);
	if not tbAuctionData or not tbAuctionData.bOpen then
		return;
	end

	local nTotalGold = tbAuctionData.nLastLeftGold or 0;
	for nId, tbItem in pairs(tbAuctionData.tbItems) do
		if tbItem.bSold then
			nTotalGold = nTotalGold + tbItem.nCurPrice;
		elseif tbItem.nBidderId then
			Auction:OnDeal(nKinId, szType, nId);
			nTotalGold = nTotalGold + tbItem.nCurPrice;
		else
			nTotalGold = nTotalGold + tbItem.nOrgPrice * Kin.AuctionDef.nRecycleRate;
			Auction:Add2GlobalAuction(szType, tbItem.nItemId, tbItem.nCount);
			Auction:MarkAuctionDeal(nKinId, szType, nil, tbItem.nItemId, tbItem.nCount);
		end
	end

	local nJoinMember = tbAuctionData.nBonusCount or Lib:CountTB(tbAuctionData.tbPlayerIds or {});
	if nJoinMember == 0 then
		Log("ERROR:Auction:nJoinMember 0.", nKinId, szType);
		nJoinMember = 1;
	end

	local nGoldEach = math.floor(nTotalGold / nJoinMember);
	local nMinGoldEach = Kin:AuctionGetMinBonusPrice(szType);
	nGoldEach = math.max(nGoldEach, nMinGoldEach);

	local tbAttach = {};
	local szMailText = string.format("    恭喜您在【%s】拍賣會分紅中獲得了[FFFE0D]%d元寶[-]，請查收附件！", Kin.AuctionName[szType] or "", nGoldEach);

	if nGoldEach > 0 then
		table.insert(tbAttach, {"Gold", nGoldEach});
	end

	local tbMail = {
		To = nil;
		Title = "幫派拍賣分紅";
		Text = szMailText;
		From = "拍賣行";
		tbAttach = tbAttach;
		nLogReazon = Env.LogWay_AuctionGold;
		tbParams = {
			LogReason2 = tbAuctionData.szSaleOrderId,
			nGoldEach = nGoldEach
		};
	};

	local szGameAppid, nPlat, nServerIdentity = GetWorldConfifParam();
	for nPlayerId, _ in pairs(tbAuctionData.tbPlayerIds or {}) do
		tbMail.To = nPlayerId;
		Mail:SendSystemMail(tbMail);

		TLog("AuctionBonusFlow",
			szGameAppid,
			nPlat,
			nServerIdentity,
			nPlayerId, nGoldEach, nKinId, szType, tbAuctionData.szSaleOrderId);
	end

	tbAuctionData.nLastLeftGold = math.max(nTotalGold - nGoldEach * nJoinMember, 0);

	if nJoinMember > 0 then
		local szMsg = string.format("恭喜參加了【%s】活動的成員獲得了%d元寶拍賣分紅！", Kin.AuctionName[szType], nGoldEach);
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, nKinId);
	end

	Auction:ClearAuctionData(nKinId, szType);
	Auction:EraseNormalAution(szType, nKinId);
end

function Auction:ClearAuctionData(nKinId, szType)
	local tbAuctionData = Auction:GetAuctionData(nKinId, szType);

	tbAuctionData.bOpen         = nil;
	tbAuctionData.nStartTime    = nil;
	tbAuctionData.tbPlayerIds   = nil;
	tbAuctionData.tbItems       = nil;
	tbAuctionData.nEndTime      = nil;
	tbAuctionData.nFinishTimer  = nil;
	tbAuctionData.szDesc        = nil;
	tbAuctionData.szSaleOrderId = nil;
	tbAuctionData.nBonusCount   = nil;
	tbAuctionData.nVersion      = tbAuctionData.nVersion + 1;

	Auction:SaveAuctionData(nKinId, szType);
end

--[[
	tbPlayerIds = {
		[nPlayerId] = true;
	}

	tbItems = {
		{nItemId, nCount}
	}
]]

-- test data
-- Kin:AddAuction(me.dwKinId, "Boss", {[me.dwID] = true}, {{1378, 2}});

function Kin:AddAuction(nKinId, szType, tbPlayerIds, tbItems, szDesc)
	local tbAuctionData = Auction:GetAuctionData(nKinId, szType);
	if not tbAuctionData then
		Log("Kin:AddAuction ERROR", nKinId, szType, tbPlayerIds, tbItems, szDesc);
		return;
	end
	
	if tbAuctionData.bOpen then
		Auction:FinishAuction(nKinId, szType);
	end

	if not next(tbItems) then
		local szMsg = string.format("本次 [FFFE0D]%s[-] 活動中並無所獲，各位弟兄切莫氣餒，再接再厲！", Kin.AuctionName[szType] or "");
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, nKinId);
		Log("Kin:AddAuction No Items", szType, nKinId);
		return;
	end

	tbAuctionData.tbPlayerIds = tbPlayerIds;
	tbItems = Auction:SplitItems(tbItems);
	tbAuctionData.tbItems = {};

	local nNow = GetTime();
	local nBasePriceSum = 0;
	for nIdx, tbItem in ipairs(tbItems) do
		tbItem.nId       = nIdx;
		tbItem.nOrgPrice = Kin:GetAuctionItemPrice(tbItem.nItemId) * tbItem.nCount;
		tbItem.bSold     = false;
		tbItem.nBidderId = nil;
		tbItem.nMaxPrice = math.ceil(tbItem.nOrgPrice * Kin:GetAuctionMaxPriceRate(tbItem.nItemId));
		tbItem.nCurPrice = Kin:GetAuctionItemRealPrice(tbItem.nItemId, tbItem.nOrgPrice, tbItem.nMaxPrice);
		tbItem.nTimeOut  = nNow + Kin.AuctionDef.nKinAuctionLastingTime + Kin.AuctionDef.nAuctionPrepareTime;
		nBasePriceSum = nBasePriceSum + tbItem.nOrgPrice;

		if tbItem.nOrgPrice > 0 then
			tbAuctionData.tbItems[nIdx] = tbItem;
		else
			Log("Kin:AddAuction:ERROR", nKinId, szType, tbItem.nItemId);
			Log(debug.traceback())
		end
	end

	local nJoinMembers = Lib:CountTB(tbPlayerIds);
	tbAuctionData.nBonusCount = Kin:CalculateAuctionBonusCount(szType, nBasePriceSum, nJoinMembers);
	tbAuctionData.szSaleOrderId = string.format("%s_%d_%d_%d", szType, nKinId, nNow, MathRandom(1000));
	tbAuctionData.bOpen = true;
	tbAuctionData.nStartTime = nNow + Kin.AuctionDef.nAuctionPrepareTime;
	tbAuctionData.nEndTime = nNow + Kin.AuctionDef.nKinAuctionLastingTime + Kin.AuctionDef.nAuctionPrepareTime;
	tbAuctionData.nVersion = nNow;
	tbAuctionData.szDesc = szDesc;
	tbAuctionData.nFinishTimer = Timer:Register(
				Env.GAME_FPS * (Kin.AuctionDef.nKinAuctionLastingTime + Kin.AuctionDef.nAuctionPrepareTime),
				Auction.FinishAuction, Auction, nKinId, szType);
	Auction:SaveAuctionData(nKinId, szType);

	Auction:Send10MinutsNotify(tbAuctionData.tbItems, tbAuctionData.szType, nKinId);
	Auction:RecordNormalAuction(szType, nKinId);
	local szGameAppid, nPlat, nServerIdentity, nAreaId = GetWorldConfifParam()
	for i,v in ipairs(tbItems) do
		TLog("AuctionAddFlow", szGameAppid, nPlat, nServerIdentity, szType, nKinId, v.nItemId, v.nCount,"",0)
	end
	Log("AddAuction Detail", nKinId, szType, tbAuctionData.szSaleOrderId, nJoinMembers, #tbItems, szDesc);
	TLog("AuctionKinFlow", szGameAppid, nPlat, nServerIdentity, szType, nKinId, nBasePriceSum, nJoinMembers,
		tbAuctionData.nBonusCount, (nJoinMembers == tbAuctionData.nBonusCount) and 0 or 1, tbAuctionData.szSaleOrderId);
end

function Auction:SplitItems(tbItems)
	local tbResults = {};
	for _, tbItem in pairs(tbItems) do
		local nItemId = tbItem[1];
		local nCount = tbItem[2];
		local nMaxCount = Kin:GetAuctionItemMaxCount(nItemId);
		-- 数量过多时分割成多份进行拍卖
		while nCount > 0 do
			table.insert(tbResults, {
				nItemId = nItemId;
				nCount = math.min(nCount, nMaxCount);
			});
			nCount = nCount - nMaxCount;
		end
	end
	return tbResults;
end

local function CombineItems(tbItems)
	local tbItemMap = {};
	local tbNewItems = {};
	for nIdx, tbItem in pairs(tbItems) do
		if not tbItemMap[tbItem.nItemId] then
			tbItemMap[tbItem.nItemId] = {nItemId = tbItem.nItemId, nCount = 0};
			table.insert(tbNewItems, tbItemMap[tbItem.nItemId]);
		end
		tbItemMap[tbItem.nItemId].nCount = tbItemMap[tbItem.nItemId].nCount + tbItem.nCount;
	end
	return tbNewItems;
end

function Auction:Send10MinutsNotify(tbItems, szAuctionType, nKinId)
	local szInfo = "本次拍賣品：";
	local tbItems = CombineItems(tbItems);
	for nIdx, tbItem in pairs(tbItems) do
		local tbItemInfo = KItem.GetItemBaseProp(tbItem.nItemId);
		szInfo = string.format("%s%s × %d%s", szInfo, tbItemInfo.szName, tbItem.nCount, nIdx == #tbItems and "" or "、");
	end
	local tbNotifyMsg = {
		"將在10分鐘後開始競拍",
		"將在5分鐘後開始競拍",
		"已經開始競拍",
	};
	local nCount = 1;
	local fnNotify = function ()
		if szAuctionType == "Global" then
			local szMsg = string.format("新一輪全服拍賣%s，%s", tbNotifyMsg[nCount], szInfo);
			KPlayer.SendWorldNotify(Kin.Def.nLevelLimite, 1000, szMsg, ChatMgr.SystemMsgType.System, 1);
		elseif szAuctionType == "Dealer" then
			local szMsg = string.format("【行腳商人】攜珍品現身拍賣行，%s。", tbNotifyMsg[nCount]);
			KPlayer.SendWorldNotify(Kin.Def.nLevelLimite, 1000, szMsg, ChatMgr.SystemMsgType.System, 1);
		else
			local szMsg = string.format("【%s】拍賣會%s，%s", Kin.AuctionName[szAuctionType] or "", tbNotifyMsg[nCount], szInfo);
			ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, nKinId);
		end

		nCount = nCount + 1;
		if not tbNotifyMsg[nCount] then
			if Auction:IsPermanent(szAuctionType) then
				KPlayer.BoardcastScript(Kin.AuctionDef.nAuctionLevelLimit, "Kin:AucitonOpenNew", szAuctionType);
			else
				local kinData = Kin:GetKinById(nKinId);
				if kinData then
					kinData:TraverseMembers(function (memberData)
						local member = KPlayer.GetPlayerObjById(memberData.nMemberId);
						if member then
							member.CallClientScript("Kin:AucitonOpenNew", szAuctionType);
						end
						return true;
					end);
				end
			end

			return false;
		end
		return true;
	end

	if fnNotify() then
		Timer:Register(Env.GAME_FPS * Kin.AuctionDef.nAuctionPrepareTime / 2, fnNotify);
	end
end

function Auction:GetAuctionData(nKinId, szType)
	if Auction:IsGlobal(szType) then
		return Auction:GetGlobalAuctionData();
	elseif szType == "Dealer" then
		return Auction:GetDealerAcutionData();
	end

	local kinData = Kin:GetKinById(nKinId);
	if not kinData then
		Log("Auction:GetAuctionData Error", string.format("KinID:[%d], szType:[%s]", nKinId, szType or ""));
		return nil;
	end

	local tbAuctionData = kinData:GetAuctionData();
	if not tbAuctionData[szType] then
		tbAuctionData[szType] = {
			szType = szType;
		};
	end
	return tbAuctionData[szType];
end

function Auction:GetAllOpenAuctionsType(nKinId)
	local tbTypes = {};
	table.insert(tbTypes, "Global");

	local tbDealerAuctionData = Auction:GetDealerAcutionData();
	if tbDealerAuctionData.bOpenPeriod then
		table.insert(tbTypes, "Dealer");
	end

	local kinData = Kin:GetKinById(nKinId);
	if kinData then
		local tbAuctionData = kinData:GetAuctionData();
		for szType, tbData in pairs(tbAuctionData) do
			if tbData.bOpen then
				table.insert(tbTypes, szType);
			end
		end
	end

	return tbTypes;
end

function Auction:SaveAuctionData(nKinId, szType)
	if Auction:IsPermanent(szType) then
		Auction:SaveGlobalAuctionData();
		return;
	end

	local kinData = Kin:GetKinById(nKinId);
	if not kinData then
		Log("Auction:SaveAuctionData ERROR", nKinId, szType);
		return;
	end
	kinData:SaveAuctionData();
end

function Auction:CheckFinish(nKinId, szType)
	if Auction:IsGlobal(szType) then
		return;
	end

	local tbAuctionData = Auction:GetAuctionData(nKinId, szType);
	if not tbAuctionData or not tbAuctionData.bOpen then
		return false;
	end

	local nNow = GetTime();
	local nEndTime = nNow;
	for _, tbItem in pairs(tbAuctionData.tbItems) do
		if tbItem.nTimeOut > nEndTime then
			nEndTime = tbItem.nTimeOut;
		end
	end

	if nEndTime == tbAuctionData.nEndTime then
		return;
	end

	tbAuctionData.nEndTime = nEndTime;
	Timer:Close(tbAuctionData.nFinishTimer);
	local nLeftTime = nEndTime - nNow;
	if nLeftTime <= 0 then
		Auction:FinishAuction(nKinId, szType);
	else
		tbAuctionData.nFinishTimer = Timer:Register(Env.GAME_FPS * nLeftTime, Auction.FinishAuction, Auction, nKinId, szType);
	end
end

-- 成交
function Auction:OnDeal(nKinId, szType, nId, bIsBidOver)
	local tbAuctionData = Auction:GetAuctionData(nKinId, szType);
	if not tbAuctionData or not tbAuctionData.bOpen then
		return false;
	end

	local tbItemData = tbAuctionData.tbItems[nId];
	if tbItemData.bSold then
		return;
	end

	tbItemData.bSold = true;

	local bidder = KPlayer.GetPlayerObjById(tbItemData.nBidderId);
	local bIsGlobal = Auction:IsGlobal(szType);
	local bIsPermanent = Auction:IsPermanent(szType);
	local tbItemInfo = KItem.GetItemBaseProp(tbItemData.nItemId);
	if bidder and bIsBidOver then
		local szInfoMsg = string.format("恭喜你一口價競拍獲得%d個%s", tbItemData.nCount, tbItemInfo.szName);
		bidder.CenterMsg(szInfoMsg);
		bidder.SendAward({{"item", tbItemData.nItemId, tbItemData.nCount}}, false, false, Env.LogWay_AuctionOnDeal);

		local szChatTip = string.format("【%s】×%d被「%s」以%d元寶一口價拍得。", tbItemInfo.szName, tbItemData.nCount, bidder.szName, tbItemData.nCurPrice);
		if not bIsPermanent then
			ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szChatTip, nKinId);
		end

		Achievement:AddCount(bidder, "FirstAuctionDeal_2");
	else
		local tbMail = {
			To = tbItemData.nBidderId;
			Title = "拍賣所得";
			Text = string.format("  恭喜您在【%s】拍賣會中花費[FFFE0D]%s元寶[-]拍得[FFFE0D]%s[-]",
					Kin.AuctionName[szType] or "", tbItemData.nCurPrice, tbItemInfo.szName);
			From = "拍賣行";
			tbAttach = {{"item", tbItemData.nItemId, tbItemData.nCount}};
			nLogReazon = Env.LogWay_AuctionOnDeal;
		};

		Mail:SendSystemMail(tbMail);
	end

	local pRoleBuyer = KPlayer.GetRoleStayInfo(tbItemData.nBidderId) or {};
	Auction:MarkAuctionDeal(nKinId, szType, pRoleBuyer.szName, tbItemData.nItemId, tbItemData.nCount, tbItemData.nCurPrice, bIsBidOver);

	local bP2PTrade = false;
	if bIsGlobal then
		if Auction:PersonalAuctionFinish(tbItemData) then
			bP2PTrade = true;
		end
	end

	local nBuyerId = tbItemData.nBidderId
	local nSellerId = tbItemData.nOwnerId or 0
	local pRoleSeller = KPlayer.GetRoleStayInfo(nSellerId) or {}
	local pAsyncBuyer = KPlayer.GetAsyncData(nBuyerId)
	local pAsyncSeller = KPlayer.GetAsyncData(nSellerId)
	local pSeller = KPlayer.GetPlayerObjById(nSellerId)
	local nBuyerFightPower = pAsyncBuyer and pAsyncBuyer.GetFightPower() or 0
	local szBuyllerAccount = KPlayer.GetPlayerAccount(nBuyerId) or 0
	local szSellerAccout = nSellerId ~= 0 and KPlayer.GetPlayerAccount(nSellerId) or 0
	local nBuyVipLevel = (pAsyncBuyer and pAsyncBuyer.GetVipLevel() or 0);
	local nSellerFightPower = pAsyncSeller and pAsyncSeller.GetFightPower() or 0;
	local nSellerVipLevel = pAsyncSeller and pAsyncSeller.GetVipLevel() or 0 

	local szGameAppid, nPlat, nServerIdentity, nAreaId = GetWorldConfifParam()

	if bP2PTrade then
		TLog("P2PTradeFlow", szGameAppid, nPlat, nServerIdentity, Env.LogWay_AuctionOnDeal, szSellerAccout, nSellerId, pRoleSeller.nLevel, nSellerVipLevel ,
		szBuyllerAccount, nBuyerId, pRoleBuyer.nLevel, nBuyVipLevel , Shop.tbMoney["Gold"]["SaveKey"], tbItemData.nCurPrice, tbItemData.nItemId, tbItemData.nCount,
		(pSeller and pSeller.GetMoney("Gold") or 0), (bidder and bidder.GetMoney("Gold") or 0));
	end

	local nItemLevel, nQuality = 0, 0;
	local tbItemBase = KItem.GetItemBaseProp(tbItemData.nItemId)
	if tbItemBase then
		nItemLevel = tbItemBase.nLevel
		nQuality = tbItemBase.nQuality
	end

	local nMaxLevel = GetMaxLevel()
	local nSingeChangePrice = math.ceil(tbItemData.nOrgPrice * Kin.AuctionDef.nAddRatePerTime)
	local nChangePriceTime =  tbItemData.nLastBidPrice and  math.floor((tbItemData.nLastBidPrice - tbItemData.nOrgPrice) / nSingeChangePrice) or 0
	TLog("SecAuctionCompleteFlow", szGameAppid, nPlat, nServerIdentity, nAreaId,
		szBuyllerAccount, nBuyerId, pRoleBuyer.nFaction, pRoleBuyer.nLevel, nBuyerFightPower, (bidder and bidder.szIP or 0), nBuyVipLevel,
		szSellerAccout, nSellerId, pRoleSeller.nFaction, pRoleSeller.nLevel, (pSeller and pSeller.szIP or 0), nId, Player.award_type_item,
		1, tbItemData.nCurPrice, tbItemData.nItemId, tbItemData.nCount, nItemLevel, nQuality,
		nMaxLevel, tbItemData.nOrgPrice, tbItemData.nMaxPrice, (bIsBidOver and Env.LogOnDealType_BidOver or Env.LogOnDealType_OnDeal), nChangePriceTime,
		string.format("%d*%d", nSingeChangePrice, nChangePriceTime), (bIsGlobal and Env.LogSellType_AuctionAll or Env.LogSellType_AuctionKin), 
		(bidder and bidder.GetShouldHaveMoney("Gold") or 0),  nSellerFightPower, nSellerVipLevel, pRoleBuyer.dwKinId, szType)

	if Auction:IsGlobal(szType) then
		tbAuctionData.tbItems[nId] = nil;
		local bRet = Lib:CallBack({Kin.Auction.OnGlobalRemove,Kin.Auction,nId});
		if not bRet then
			Log("[Auction] OnGlobalRemove fail",nId)
		end
	end

	tbAuctionData.nVersion = tbAuctionData.nVersion + 1;
	Auction:SaveAuctionData(nKinId, szType);
end

function Auction:CheckItemAvailable(pPlayer, szType, nId, nPrice, bBidOver)
	local tbAuctionData = Auction:GetAuctionData(pPlayer.dwKinId, szType);
	if not tbAuctionData then
		return false, "未找到物品資訊";
	end

	if not tbAuctionData.bOpen then
		return false, "本場拍賣已結束";
	end

	local nNow = GetTime();
	if nNow < tbAuctionData.nStartTime then
		return false, "拍賣尚未開始, 請稍等片刻";
	end

	local tbItemData = tbAuctionData.tbItems[nId];
	if not tbItemData or tbItemData.bSold then
		return false, "該物品已被其他玩家拍得";
	end

	if tbItemData.nOwnerId == pPlayer.dwID then
		return false, "不能競標自己的拍賣品";
	end

	if tbItemData.nStartTime and tbItemData.nStartTime > nNow then
		return false, "拍賣尚未開始, 請稍等片刻";
	end

	if tbItemData.nTimeOut < nNow then
		return false, "該物品競拍已結束";
	end

	local nExpectPrice = tbItemData.nCurPrice;
	if tbItemData.nBidderId then
		nExpectPrice = tbItemData.nCurPrice + math.ceil(tbItemData.nOrgPrice * Kin.AuctionDef.nAddRatePerTime);
	end

	if nPrice ~= nExpectPrice and not bBidOver then
		pPlayer.CallClientScript("Kin:AuctionPriceChanged", szType, nId, nExpectPrice);
		return false, "目標物品價格改變了";
	end

	if bBidOver and nPrice ~= tbItemData.nMaxPrice then
		return false, "一口價, 價格出問題了";
	end

	return tbItemData;
end

function Auction:Bid(szType, nId, nPrice)
	local tbItemData, szFailInfo = Auction:CheckItemAvailable(me, szType, nId, nPrice);
	if not tbItemData then
		Auction:OnSyncAuctions(szType, -1);
		return false, szFailInfo;
	end

	if nPrice >= tbItemData.nMaxPrice then
		return Auction:BidOver(szType, nId, tbItemData.nMaxPrice);
	end

	local nRealCost = nPrice;
	if me.dwID == tbItemData.nBidderId then
		nRealCost = nPrice - tbItemData.nCurPrice;
	end

	local myGold = me.GetMoney("Gold");
	if myGold < nRealCost then
		return false, "您的元寶不足！";
	end

	-- CostGold谨慎调用, 调用前请搜索 _LuaPlayer.CostGold 查看使用说明, 它处调用时请保留本注释
	local tbAuctionData = Auction:GetAuctionData(me.dwKinId, szType) or {};
	me.CostGold(nRealCost, Env.LogWay_AuctionBid, (tbAuctionData.szSaleOrderId or "") .."_".. tbItemData.nItemId, Auction.AfterBidPaid, false, szType, nId, nPrice);
	return true;
end

function Auction.AfterBidPaid(nPlayerId, bSuccess, szBillNo, bBidOver, szType, nId, nPrice)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return false, "拍賣中途, 您離線了.";
	end

	if not bSuccess then
		return false, "支付失敗請稍後再試";
	end

	local tbItemData, szFailInfo = Auction:CheckItemAvailable(pPlayer, szType, nId, nPrice, bBidOver);
	if not tbItemData then
		return false, szFailInfo;
	end

	local tbAuctionData = Auction:GetAuctionData(pPlayer.dwKinId, szType);
	if not tbAuctionData then
		return false, "拍賣物品不存在";
	end

	local formerBidder = tbItemData.nBidderId and KPlayer.GetPlayerObjById(tbItemData.nBidderId);
	local nLogReazon2 = (tbAuctionData.szSaleOrderId or "") .."_" .. tbItemData.nItemId
	if formerBidder and tbItemData.nBidderId ~= pPlayer.dwID then
		formerBidder.AddMoney("Gold", tbItemData.nCurPrice, Env.LogWay_BidFail, nLogReazon2);
		local tbItemInfo = KItem.GetItemBaseProp(tbItemData.nItemId);
		formerBidder.CenterMsg(string.format("[FFFE0D]%s[-]競價失敗，[FFFE0D]%d元寶[-]已退還給您", tbItemInfo.szName, tbItemData.nCurPrice));
		local tbMsgData = {
			szType = "Auction";
			nTimeOut = tbItemData.nTimeOut;
			szItemName = tbItemInfo.szName;
			nCurPrice = tbItemData.nCurPrice;
		};
		formerBidder.CallClientScript("Ui:SynNotifyMsg", tbMsgData);
	elseif tbItemData.nBidderId and tbItemData.nBidderId ~= pPlayer.dwID then
		local tbItemInfo = KItem.GetItemBaseProp(tbItemData.nItemId);
		local tbMail = {
			To = tbItemData.nBidderId;
			Title = "拍賣競價失敗";
			Text = string.format("[FFFE0D]%s[-]競價失敗了，競拍所花費的[FFFE0D]%d元寶[-]已退還給您。", tbItemInfo.szName, tbItemData.nCurPrice);
			From = "拍賣系統";
			tbAttach = {{"Gold", tbItemData.nCurPrice}};
			nLogReazon = Env.LogWay_BidFail;
			tbParams = {LogReason2 = nLogReazon2 };
		};
		Mail:SendSystemMail(tbMail);
	end

	tbItemData.nBidderId = pPlayer.dwID;
	tbItemData.nCurPrice = nPrice;
	tbItemData.nTimeOut = bBidOver and 0 or math.max(tbItemData.nTimeOut, GetTime() + Kin.AuctionDef.nBidTimeOut);
	if not bBidOver then
		tbItemData.nLastBidPrice = nPrice;
	end

	tbAuctionData.nVersion = tbAuctionData.nVersion + 1;

	if bBidOver then
		Auction:OnDeal(pPlayer.dwKinId, szType, nId, true);
	end

	Auction:CheckFinish(pPlayer.dwKinId, szType);
	Auction:SaveAuctionData(pPlayer.dwKinId, szType);
	Auction:OnSyncAuctions(szType, -1, pPlayer);

	if formerBidder and formerBidder.dwID ~= pPlayer.dwID then
		Auction:OnSyncAuctions(szType, -1, formerBidder);
	end
	return true;
end

-- 一口价
function Auction:BidOver(szType, nId, nPrice)
	local tbItemData, szFailInfo = Auction:CheckItemAvailable(me, szType, nId, nPrice, true);
	if not tbItemData then
		Auction:OnSyncAuctions(szType, -1);
		return false, szFailInfo;
	end

	local nRealCost = nPrice;
	if me.dwID == tbItemData.nBidderId then
		nRealCost = nPrice - tbItemData.nCurPrice;
	end

	local myGold = me.GetMoney("Gold");
	if myGold < nRealCost then
		return false, "您的元寶不足！";
	end

	-- CostGold谨慎调用, 调用前请搜索 _LuaPlayer.CostGold 查看使用说明, 它处调用时请保留本注释
	local tbAuctionData = Auction:GetAuctionData(me.dwKinId, szType) or {};
	me.CostGold(nRealCost, Env.LogWay_AuctionBidOver, (tbAuctionData.szSaleOrderId or "") .."_" .. tbItemData.nItemId, Auction.AfterBidPaid, true, szType, nId, nPrice);
	return true;
end

function Auction:OnSyncAuctions(szType, nVersion, player)
	player = player or me;
	if player.dwKinId == 0 and not Auction:IsPermanent(szType) then
		return false, "拍賣請求資料出錯";
	end

	local tbAuctionData = Auction:GetAuctionData(player.dwKinId, szType);
	if not tbAuctionData or tbAuctionData.nVersion == nVersion then
		return true;
	end

	Auction:SyncAuctionData(player, tbAuctionData, true);
	return true;
end

--[[
	tbVersions = {
		[szType] = nVersion
	}
]]
function Auction:OnSyncAllAuctions(tbVersions)
	local tbTypes = Auction:GetAllOpenAuctionsType(me.dwKinId);
	if not next(tbTypes) then
		return true;
	end

	for _, szType in ipairs(tbTypes) do
		local tbAuctionData = Auction:GetAuctionData(me.dwKinId, szType);
		if tbAuctionData and tbAuctionData.nVersion ~= tbVersions[szType] then
			Auction:SyncAuctionData(me, tbAuctionData);
		end
	end

	me.CallClientScript("Kin:OnAuctionSyncData", nil, true, true);
	return true;
end

Auction.tbAuctionSyncHugeAuctoinCache = Auction.tbAuctionSyncHugeAuctoinCache or {};

function Auction:SyncAuctionData(pPlayer, tbAuctionData, bFreshUi)
	local tbCache = Auction.tbAuctionSyncHugeAuctoinCache[tbAuctionData.szType];
	if not tbCache then
		Auction.tbAuctionSyncHugeAuctoinCache[tbAuctionData.szType] = {
			-- nVersion = nil;
			-- tbAuctionData = nil;
			-- tbBidders = {};
		};
		tbCache = Auction.tbAuctionSyncHugeAuctoinCache[tbAuctionData.szType];
		-- Log("Test Create Cache Type", tbAuctionData.szType);
	end

	if tbCache.nVersion == tbAuctionData.nVersion then
		Auction:SyncHugeAuction(pPlayer, tbCache, tbAuctionData.tbItems, bFreshUi);
		return;
	end

	local bSuccess = pPlayer.CallClientScript("Kin:OnAuctionSyncData", tbAuctionData, bFreshUi);
	if not bSuccess then
		-- Log("Test BuildHugeAutionSyncCache and sync");
		Auction:BuildHugeAutionSyncCache(tbCache, tbAuctionData);
		Auction:SyncHugeAuction(pPlayer, tbCache, tbAuctionData.tbItems, bFreshUi);
	end
end

function Auction:BuildHugeAutionSyncCache(tbCache, tbAuctionData)
	tbCache.tbAuctionData = Lib:CopyTB1(tbAuctionData);
	tbCache.tbBidders = {};

	local tbTypeItems = {};
	local tbOrgItems = tbAuctionData.tbItems;
	local nTotalCount = 0;
	for nId, tbItem in pairs(tbOrgItems) do
		nTotalCount = nTotalCount + 1;
		if tbItem.nBidderId then
			tbCache.tbBidders[tbItem.nBidderId] = tbCache.tbBidders[tbItem.nBidderId] or {};
			table.insert(tbCache.tbBidders[tbItem.nBidderId], nId);
		end

		local szItemType = Kin:AuctionGetItemType(tbItem.nItemId);
		tbTypeItems[szItemType] = tbTypeItems[szItemType] or {};
		table.insert(tbTypeItems[szItemType], tbItem);
	end

	local nMaxBaseCount = 250; -- 基础最大拍卖商品数
	local tbFinalBaseItems = {};
	for _, tbTypeItem in pairs(tbTypeItems) do
		table.sort(tbTypeItem, function (a, b)
			if a.nOrgPrice == b.nOrgPrice then
				return a.nId < b.nId;
			end
			return a.nOrgPrice > b.nOrgPrice;
		end);

		local nInsertCount = math.ceil((#tbTypeItem / nTotalCount) * nMaxBaseCount);
		for i = 1, nInsertCount do
			local tbItem = tbTypeItem[i];
			tbFinalBaseItems[tbItem.nId] = tbItem;
		end
		-- Log("Test BuildHugeAutionSyncCache", _, #tbTypeItem, nTotalCount, nMaxBaseCount, nInsertCount)
	end

	tbCache.tbAuctionData.tbItems = tbFinalBaseItems;
	tbCache.nVersion = tbAuctionData.nVersion;
end

function Auction:SyncHugeAuction(player, tbCache, tbOrgItems, bFreshUi)
	local tbMyItemIds = tbCache.tbBidders[player.dwID];
	local tbSynData = tbCache.tbAuctionData;
	if tbMyItemIds then
		local nMaxAddBaseCount = 20; -- 在基础同步数上，最大添加的商品数
		local tbMyItems = Lib:CopyTB1(tbSynData.tbItems);
		for _, nId in ipairs(tbMyItemIds) do
			-- Log("Test My Ids", nId);
			if not tbMyItems[nId] and nMaxAddBaseCount > 0 then
				-- Log("Test Add My Items", nId, nMaxAddBaseCount);
				tbMyItems[nId] = tbOrgItems[nId];
				nMaxAddBaseCount = nMaxAddBaseCount - 1;
			end
		end

		tbSynData = Lib:CopyTB1(tbSynData);
		tbSynData.tbItems = tbMyItems;
	end

	-- Log("Test Sync Cached data", tbSynData.szType);
	player.CallClientScript("Kin:OnAuctionSyncData", tbSynData, bFreshUi);
end

function Auction:AskDealListInfo(szType)
	if me.dwKinId == 0 and not Auction:IsPermanent(szType) then
		return false, "請求拍賣歷史記錄出錯";
	end

	local tbDealList = Auction:GetAuctionDealList(me.dwKinId, szType);
	me.CallClientScript("Kin:OnAuctionSyncDealList", szType, tbDealList);
	return true;
end

function Auction:OnSyncPersonalAuction(nClientVersion)
	local tbPersonAuctionData, nVersion = Auction:GetPersonAuctionData(me.dwID, true);
	if nVersion == nClientVersion then
		return true;
	end

	me.CallClientScript("Kin:OnSyncPersonalAuctionData", tbPersonAuctionData, nVersion);
	return true;
end

function Auction:DeletePersonalAuctionItem(nFrame, nItemId, nCount)
	local tbPersonAuctionData = Auction:GetPersonAuctionData(me.dwID, true);
	if not tbPersonAuctionData then
		me.CallClientScript("Kin:OnSyncPersonalAuctionData", {});
		return false, "找不到對應拍賣品";
	end

	local tbItems = tbPersonAuctionData[nFrame];
	if not tbItems then
		Auction:OnSyncPersonalAuction();
		return false, "找不到對應拍賣品";
	end

	local bSuccess = false;
	for nIdx, tbItem in ipairs(tbItems) do
		if tbItem.nItemId == nItemId and tbItem.nCount == nCount then
			table.remove(tbItems, nIdx);
			bSuccess = true;
			break;
		end
	end

	if bSuccess then
		me.SendAward({{"item", nItemId, nCount}}, false, true, Env.LogWay_PersonalAuction);
		--me.CenterMsg("成功取消拍卖，拍卖品已退回至背包中");

		if not next(tbItems) then
			tbPersonAuctionData[nFrame] = nil;
		end
		Auction:SavePersonAuctionData();
	else
		me.CenterMsg("找不到對應拍賣品");
	end

	Auction:OnSyncPersonalAuction();
	return true;
end

local AuctionInterface = {
	Bid                       = true;
	BidOver                   = true;
	OnSyncAuctions            = true;
	OnSyncAllAuctions         = true;
	AskDealListInfo           = true;
	OnSyncPersonalAuction     = true;
	DeletePersonalAuctionItem = true;
}

function Kin:AuctionRequest(szRequestType, ... )
	if AuctionInterface[szRequestType] then
		local bSuccess, szInfo = Auction[szRequestType](Auction, ...);
		if not bSuccess and szInfo then
			me.CenterMsg(szInfo);
		end
	else
		Log("WRONG Auction Request:", szRequestType, ...);
	end
end

function Kin:FormatAuctionItem(tbAllAward,tbAdd2AuctionIndex,tbAuctionAward)
	tbAuctionAward = tbAuctionAward or {}
	tbAllAward = tbAllAward or {}
	tbAdd2AuctionIndex = tbAdd2AuctionIndex or {}

	local nMaxIndex = #tbAdd2AuctionIndex
	if nMaxIndex == 0 then
		return tbAllAward,tbAuctionAward
	end

	for i = nMaxIndex,1,-1 do
		local nAuctionIndex = tbAdd2AuctionIndex[i]
		local tbAwardInfo = tbAllAward[nAuctionIndex]
		if tbAwardInfo and tbAwardInfo[2] and tbAwardInfo[3] then
			table.insert(tbAuctionAward,{tbAwardInfo[2],tbAwardInfo[3]})
			table.remove(tbAllAward,nAuctionIndex)
		end
	end

	return tbAllAward,tbAuctionAward
end

function Auction:OnGlobalRemove(nId)
	Transmit.tbIDIPInterface:OnGlobalAuctionRemove(nId)
end
