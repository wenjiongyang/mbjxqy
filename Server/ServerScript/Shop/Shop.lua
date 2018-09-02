--[[
tbWares = {
	TemplateId,
	Price,
	MoneyType,
	Sort,
	LimitKey,
	Discount,--C
	HotTip,--C
}
{"TemplateId", "Price", "MoneyType", "ShopType", "Sort", "Discount", "StartDate", "EndDate", "LimitKey", "HotTip"});
tbTradingWares = {  --这个是内存中的，当前的价格，是根据买入卖出变更的
		[123] = {
			nTemplateId = 123,
			nClass1 = 1,
			nClass2 = 3,
			nPrice = 100,
			nRate = -0.03,
		}
}
]]


function Shop:Init()
	self:InitEquipMakerXYItemValues()
	self.nSpecailStartTime = Lib:ParseDateTime("2017/5/27 0:01") --一开始是指令加上的，下次如有类似活动可做进活动
	self.nSpecailEndTime = Lib:ParseDateTime("2017/6/9 23:59")
end

function Shop:InitEquipMakerXYItemValues()
    local tbMap = {}

    for _, tb in pairs(self.tbEquipMakerSettings) do
        local nUnidentifyId = tb.nItem3Id
        local tbInfo = KItem.GetItemBaseProp(nUnidentifyId)
        if tbInfo then
            local nItemValue = tbInfo.nValue

            local nType, nQuality = self:_EquipMakerGetTypeQuality(nUnidentifyId)
            tbMap[nType] = tbMap[nType] or {}
            tbMap[nType][nQuality] = nItemValue
        end
    end

    self.tbEquipMakerItemValues = tbMap
end


function Shop:BuyAfterCost(pPlayer, tbWare, nCount, nPrice, bRand, szMoneyType, nRequestIndex)
	nRequestIndex = nRequestIndex or 0;
	local nTemplateId = tbWare.nTemplateId
	if bRand then
		self:ReduceFamilyWareRemain(pPlayer, tbWare.szShopType, nTemplateId, nCount);
		self:SyncShopWares(pPlayer, tbWare.szShopType, nTemplateId, tbWare);
	end

	if tbWare.nLimitType then
		self:ChedkBuyLimitUpdate(pPlayer, tbWare, nCount);
	end

	Task:OnTaskExtInfo(pPlayer, Task.ExtInfo_ShangCheng);
	pPlayer.nShopRequestIndex = nRequestIndex
	pPlayer.CallClientScript("Shop:OnBuyResponse", true, "購買成功", nRequestIndex + 1);
	Log(string.format("Shop:Buy pPlayer:%d, szShopType:%s, nTemplateId:%d, nCount:%d, bFromLimit:%s", pPlayer.dwID, tbWare.szShopType, nTemplateId, nCount, tostring(tbWare.nLimitType)))
	pPlayer.AddItem(nTemplateId, nCount, nil, Env.LogWay_ShopBuy, (tbWare.nGoodsId or 0), nCount * nPrice, Shop.tbMoney[szMoneyType]["SaveKey"]);

	TeacherStudent:OnShopBuy(pPlayer, nTemplateId, nCount, tbWare.nLimitType and tbWare.nLimitType>0)

	return true
end

--现在只是家族商店是走这里
function Shop:Buy(pPlayer, szShopType, nTemplateId, nCount, nClientPrice, nRequestIndex)
	if pPlayer.nShopRequestIndex and nRequestIndex and pPlayer.nShopRequestIndex == nRequestIndex then
		pPlayer.CallClientScript("Shop:OnBuyResponse", false, "該筆交易已成功", pPlayer.nShopRequestIndex + 1);
		return
	end
	local bSuccess, szInfo = Shop:CanBuyWare(pPlayer, szShopType, nTemplateId, nCount);
	if not bSuccess then
		pPlayer.CallClientScript("Shop:OnBuyResponse", bSuccess, szInfo);
		return;
	end

	if szShopType == "WarShop" then
        return self:BuyWarWare(pPlayer, nTemplateId, nCount, nRequestIndex);
    end

	local bFamiShop, bRand = self:IsFamilyShop(szShopType)
	if bRand then
		local tbFamilyShopData = pPlayer.GetScriptTable("FamilyShop");
	    local nLastDay = tbFamilyShopData.nLastDay;

	    if self:IsNeedRefresh(nLastDay) then
	    	self:RefreshFamilyShopWare(pPlayer);
	    	tbFamilyShopData.nLastDay = Lib:GetLocalDay(GetTime() - self.FAMILY_SHOP_REFRESH);
	    	pPlayer.CenterMsg("商品已經刷新，請重進介面");
	    	return;
	    end
	end
	local tbWare = self:GetAWare(szShopType, nTemplateId);
	self:DoBuyWare(pPlayer, tbWare, nCount, nClientPrice, nRequestIndex)

end

--现在的 BuyGoods 只是珍宝阁，不包括家族商店
function Shop:BuyGoods(pPlayer, szShopType, nGoodsId, nCount, nClientPrice, nRequestIndex)
	if pPlayer.nShopRequestIndex and nRequestIndex and pPlayer.nShopRequestIndex == nRequestIndex then
		pPlayer.CallClientScript("Shop:OnBuyResponse", false, "該筆交易已成功", pPlayer.nShopRequestIndex + 1);
		return
	end
	local bSuccess, szInfo = Shop:CanBuyGoodsWare(pPlayer, szShopType, nGoodsId, nCount);
	if not bSuccess then
		pPlayer.CallClientScript("Shop:OnBuyResponse", bSuccess, szInfo);
		return;
	end

	local tbWare = self:GetGoodsWare(szShopType, nGoodsId);
	self:DoBuyWare(pPlayer, tbWare, nCount, nClientPrice, nRequestIndex)
end

function Shop:DoBuyWare(pPlayer, tbWare, nCount, nClientPrice, nRequestIndex)
	local szMoneyType = tbWare.szMoneyType;
	local nPrice = self:GetPrice(pPlayer, tbWare); --家族商店有根据等级的折扣	;
	if nClientPrice ~= nPrice then
		pPlayer.CenterMsg("該商品的價格配置無效")
		return
	end
	local bFamiShop, bRand = self:IsFamilyShop(tbWare.szShopType)
	local nTemplateId = tbWare.nTemplateId
	if szMoneyType == "Gold" then
		pPlayer.CostGold(nCount * nPrice, Env.LogWay_ShopBuy, nTemplateId, function (nPlayerId, bSucceed)
			if not bSucceed then
				return false
			end
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
			if not pPlayer then
				return false
			end

			if tbWare.nLimitType then
		        local nRemainCount = self:GetWareRemainCount(pPlayer, tbWare);
		        if nCount > nRemainCount then
		            return false, "剩餘庫存不足";
		        end
		    end

		    if bFamiShop and bRand then
		    	local nDegree = self:GetFamilyWareDegree(pPlayer, tbWare.szShopType, nTemplateId);
	            if nCount > nDegree then
	                return false, "剩餘庫存不足";
	            end
		    end

			return self:BuyAfterCost(pPlayer, tbWare, nCount, nPrice, bRand, szMoneyType, nRequestIndex)

		end)
		return
	end
	if not pPlayer.CostMoney(szMoneyType, nCount * nPrice, Env.LogWay_ShopBuy, nTemplateId) then
		return;
	end

	self:BuyAfterCost(pPlayer, tbWare, nCount, nPrice, bRand, szMoneyType, nRequestIndex)
end


function Shop:BuyWarWare(pPlayer, nTemplateId, nCount, nRequestIndex)
	--在CanBuyWarWare 里都检查过了
	local tbWare = self:GetAWare("WarShop", nTemplateId);
	local nPrice = self:GetPrice(pPlayer, tbWare);
	local tbKin = Kin:GetKinById(pPlayer.dwKinId)
	local bRet,szMsg = tbKin:CheckAddBattleApplysLimit(nTemplateId, nCount)
	if not bRet then
		if szMsg then
			pPlayer.CenterMsg(szMsg)
		end
		return
	end
	if not tbKin:CostFound(nPrice * nCount) then
		pPlayer.CenterMsg("消耗幫派建設資金出錯")
		return
	end

	tbKin:AddBattleApplys(nTemplateId, nCount)
    	local tbMember = Kin:GetMemberData(pPlayer.dwID)
	local nCareer = tbMember and  tbMember:GetCareer() or Kin.Def.Career_Normal

	local tbItemBase = KItem.GetItemBaseProp(nTemplateId)
	local szItemName = tbItemBase.szName
	ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, string.format("%s「%s」購買了%d個<%s>", Kin.Def.Career_Name[nCareer], pPlayer.szName, nCount, szItemName), pPlayer.dwKinId, {nLinkType = ChatMgr.LinkType.Item, nTemplateId = nTemplateId, nFaction = pPlayer.nFaction});
	local tbBattleSupply = tbKin:GetBattleApplys();
	Kin:SyncKinBaseInfo(nil, pPlayer);
	pPlayer.CallClientScript("DomainBattle:OnSyncBaseInfo", nil, tbBattleSupply)

	pPlayer.CallClientScript("Shop:OnBuyResponse", true, string.format("你購買了%d個「%s」，已被自動存入幫派領地中。", nCount, szItemName) , (nRequestIndex or 0) + 1);
end

function Shop:GetLimitInfo(pPlayer, nLimitType)
	nLimitType = nLimitType or Shop.WEEK_LIMIT_TYPE;
	if nLimitType == Shop.ACT_LIMIT_TYPE then
		local nShopActStartTime = self.nShopActStartTime
		if not nShopActStartTime then
			return
		end
		local tbAllLimit = pPlayer.GetScriptTable("ShopLimit");
		if tbAllLimit.nActStartTime == nShopActStartTime then
			return tbAllLimit[nLimitType]
		else
			tbAllLimit.nActStartTime = nShopActStartTime
			tbAllLimit[nLimitType] = {}	
			return tbAllLimit[nLimitType]
		end
	elseif nLimitType == Shop.WEEK_LIMIT_TYPE then
		local tbAllLimit = pPlayer.GetScriptTable("ShopLimit");
		tbAllLimit[nLimitType] = tbAllLimit[nLimitType] or {}
		local nCheckDay = Lib:GetLocalWeek(GetTime() - self.TREASURE_REFRESH)
		if tbAllLimit.nCheckWeekDay ~= nCheckDay then
			tbAllLimit[nLimitType] = {};
		end
		tbAllLimit.nCheckWeekDay = nCheckDay;
		return tbAllLimit[nLimitType]
	elseif nLimitType == self.Special_LIMIT_TYPE then
		local nSpecialStartTime = Shop.nSpecailStartTime
		if not nSpecialStartTime then
			return
		end
		local tbAllLimit = pPlayer.GetScriptTable("ShopLimit");
		if tbAllLimit.nSpecialStartTime == nSpecialStartTime then
			return tbAllLimit[nLimitType]
		else
			tbAllLimit.nSpecialStartTime = nSpecialStartTime
			tbAllLimit[nLimitType] = {}	
			return tbAllLimit[nLimitType]
		end
	end
end

function Shop:RefreshLimitInfo(pPlayer)
    local nLimitType = Shop.WEEK_LIMIT_TYPE
    Shop:GetLimitInfo(pPlayer, nLimitType)
    local tbAllLimit = pPlayer.GetScriptTable("ShopLimit");
    tbAllLimit[nLimitType] = {}

    Shop:SyncBuyLimitInfo(pPlayer, tbAllLimit[nLimitType])
    Log("Shop RefreshLimitInfo", pPlayer.dwID)
end

function Shop:ChedkBuyLimitUpdate(pPlayer, tbWare, nCount)
	local nLimitType = tbWare.nLimitType
	local tbLimitInfo = self:GetLimitInfo(pPlayer, nLimitType)
	local nKey = self:GetLimitSaveKey(tbWare)
	tbLimitInfo[nKey] = (tbLimitInfo[nKey] or 0) + nCount
	if nLimitType == Shop.ACT_LIMIT_TYPE then
		Shop:SyncActBuyLimitInfo(pPlayer, tbLimitInfo)
	elseif nLimitType == Shop.Special_LIMIT_TYPE then
		pPlayer.CallClientScript("Shop:OnSyncSpecailBuyLimitInfo", tbLimitInfo)
	else
		Shop:SyncBuyLimitInfo(pPlayer, tbLimitInfo)
	end
end

-- tbGoods = {
-- 	[1] = {nId = 123, nCount =10},
-- 	[2] = ...
-- 	...
-- }
function Shop:Sell(pPlayer, tbGoods, nRequestIndex)
	if pPlayer.nShopRequestIndex and nRequestIndex and pPlayer.nShopRequestIndex == nRequestIndex then
		pPlayer.CallClientScript("Shop:OnSellResponse", false, "該筆交易已成功", pPlayer.nShopRequestIndex + 1);
		return
	end
	local tbAfterCheck = {};

	for i,v in ipairs(tbGoods) do
		local nItemId, nCount = v.nId, v.nCount;
		local bSuccess, szInfo = Shop:CanSellWare(pPlayer, nItemId, nCount);
		if not bSuccess then
			pPlayer.CallClientScript("Shop:OnSellResponse", bSuccess, szInfo);
			return;
		end

		local pItem = pPlayer.GetItemInBag(nItemId);
		local nTemplateId = pItem.dwTemplateId;
		local nSumPrice, szMoneyType = self:GetSellSumPrice(pPlayer, nTemplateId, nCount);
		if not nSumPrice or not szMoneyType then
			pPlayer.CallClientScript("Shop:OnSellResponse", false, "無出售價格配置");
			return
		end
		table.insert(tbAfterCheck,
		{
			nTemplateId = nTemplateId,
			nItemId 	= nItemId,
			szMoneyType = szMoneyType,
			nSumPrice 	= nSumPrice,
			nCount 		= nCount,
		});
	end

	local szSellInfo = "";
	for i,v in ipairs(tbAfterCheck) do
		local pItem = pPlayer.GetItemInBag(v.nItemId);
		local nConsumeCount = pPlayer.ConsumeItem(pItem, v.nCount, Env.LogWay_ShopSell)

		if nConsumeCount ~= v.nCount then
			Log("ERROR Shop:Sell comsumeItem failed ", pPlayer.dwID, v.nItemId);
			return;
		end

		pPlayer.AddMoney(v.szMoneyType, v.nSumPrice, Env.LogWay_ShopSell);
		local _, szMoneyEmotion = self:GetMoneyName(v.szMoneyType);
		pPlayer.CenterMsg(string.format("獲得了%s:%s", szMoneyEmotion, v.nSumPrice))

		szSellInfo = string.format("%s; nTemplateId:%d, nCount:%d, szMoneyType:%s, nSumPrice:%d", szSellInfo, v.nTemplateId, v.nCount, v.szMoneyType, v.nSumPrice)
	end

	pPlayer.nShopRequestIndex = nRequestIndex
	pPlayer.CallClientScript("Shop:OnSellResponse", true, nil, nRequestIndex + 1);
	Log(string.format("Shop:Sell, pPlayer:%d %s", pPlayer.dwID, szSellInfo))
end

--------------------家族随机商店-------------------------------------

function Shop:ReduceFamilyWareRemain(pPlayer, szShopType, nTemplateId, nCount)
	if not self.FamilyPool[szShopType] then
		return
	end
    local nRemain = self:GetFamilyWareRemainServer(pPlayer, szShopType, nTemplateId);

    if nRemain < nCount then
        Log("[ERROR] in Shop:ReduceFamilyWareRemain", tbWare.nCount, nCount);
        return;
    end

	local tbFamilyShopData = pPlayer.GetScriptTable("FamilyShop");
    local tbShopWares =  tbFamilyShopData[szShopType];
    for k,v in pairs(tbShopWares.tbWares or {}) do
    	if v.nTemplateId == nTemplateId then
    		v.nCount = nRemain - nCount;
    	end
    end
end

function Shop:GetFamilyWareRemainServer(pPlayer, szShopType, nTemplateId)
	local tbFamilyShopData = pPlayer.GetScriptTable("FamilyShop");
    local tbShopWares =  tbFamilyShopData[szShopType];
    for k,v in pairs(tbShopWares.tbWares or {}) do
    	if v.nTemplateId == nTemplateId then
    		return v.nCount;
    	end
    end

    Log("ERROR IN Shop:GetFamilyWareRemainServer", szShopType, nTemplateId);

    return 0;
end

function Shop:CheckFamilyShop(pPlayer)
    local tbFamilyShopData = pPlayer.GetScriptTable("FamilyShop");
    local nLastDay = tbFamilyShopData.nLastDay;

    if self:IsNeedRefresh(nLastDay) then
    	self:RefreshFamilyShopWare(pPlayer);
    	tbFamilyShopData.nLastDay = Lib:GetLocalDay( GetTime() - self.FAMILY_SHOP_REFRESH );
    	return;
    end

    --今天
    --检查建筑是否升级了，升级了则多给它刷新物品.
    for szShopType, _ in pairs(Shop.FamilyPool) do
    	local nBuildingId = self.tbFamilyShopCharToId[szShopType]
    	if nBuildingId then
    		local nLevel = self:GetBuildingLevel(pPlayer, nBuildingId);
    		nLevel = self:GetCanGetFamilyShopLevel(pPlayer.nLevel, nLevel, szShopType)
    		local tbShopData = tbFamilyShopData[szShopType];
	        local nSaveLevel = tbShopData.nLevel;

	        if nLevel > nSaveLevel then
	            local tbNewShopData = self:MakeShopWares(pPlayer, szShopType, nLevel, nSaveLevel + 1);
	            Lib:MergeTable(tbShopData.tbWares, tbNewShopData);
	            tbShopData.nLevel = nLevel;
	        end

        	self:SyncShopWares(pPlayer, szShopType);
    	end
    end
end

function Shop:IsNeedRefresh(nLastDay)
    return nLastDay ~= Lib:GetLocalDay(GetTime() - self.FAMILY_SHOP_REFRESH);
end

function Shop:GetCanGetFamilyShopLevel(nPlayerLevel, nBuildLevel, szShopType)
	for i = nBuildLevel, 1, -1 do
		local nNeedPlayerLevel = self.FamilyPoolPlayerLevelLimit[szShopType][i]
		if nNeedPlayerLevel and nPlayerLevel >= nNeedPlayerLevel then
			return i;
		end
	end
	return 0;
end

function Shop:RefreshFamilyShopWare(pPlayer)
    local tbFamilyShopData = pPlayer.GetScriptTable("FamilyShop");
    for szShopType, _ in pairs(Shop.FamilyPool) do
    	local nBuildingId = self.tbFamilyShopCharToId[szShopType]
    	if nBuildingId then
    		local nLevel = self:GetBuildingLevel(pPlayer, nBuildingId);
    		nLevel = self:GetCanGetFamilyShopLevel(pPlayer.nLevel, nLevel, szShopType)
			--不同等级的家族商店道具池子集合合成，随机道具，随机数量，固定三种池子
	        local tbShopWares = self:MakeShopWares(pPlayer, szShopType, nLevel, 1);
	        tbFamilyShopData[szShopType] = tbFamilyShopData[szShopType] or {};
	        tbFamilyShopData[szShopType].tbWares = tbShopWares;
	        tbFamilyShopData[szShopType].nLevel = nLevel;
	        self:SyncShopWares(pPlayer, szShopType);
    	end
    end
end

function Shop:MakeShopWares(pPlayer, szShopType, nLevel, nEndLevel)
    local tbShopWares = {};
    local nTotalCount = 0;
    for nLevel = nLevel, nEndLevel, -1 do
        local tbLevelWares = self:MakeLevelWares(szShopType, nLevel);
        if nTotalCount + #tbLevelWares > Shop.FAMILY_SHOP_MAX_ITEM then
            local nRemain = Shop.FAMILY_SHOP_MAX_ITEM - nTotalCount;
            for i = 1, nRemain do
                table.insert(tbShopWares, tbLevelWares[i]);
            end
            break;
        else
            nTotalCount = nTotalCount + #tbLevelWares;
            Lib:MergeTable(tbShopWares, tbLevelWares);
        end
    end

    return tbShopWares;
end

function Shop:MakeLevelWares(szShopType, nLevel)
    local tbAllPoolSetting = self.FamilyPool[szShopType] or {};
    local tbPoolSetting = tbAllPoolSetting[nLevel] or {};

    local tbLevelWares = {};

    --物品随机
    for nPool, v in ipairs(tbPoolSetting) do
    	local nCount1, nProb1, nCount2, nProb2 = unpack(v);
    	--数量随机
    	if  nProb1 ~= 0 and nProb2 ~= 0 then
	        local nRan = MathRandom(nProb1 + nProb2);
	        local nCount;
	        if nRan < nProb1 then
	            nCount = nCount1;
	        else
	            nCount = nCount2;
	        end

	        if nCount ~= 0 then
	        	local tbPoolWares = self:GetAPoolWares(szShopType, nLevel, nPool);
	        	local tbWares = self:MakePoolWares(tbPoolWares, nCount);
	        	Lib:MergeTable(tbLevelWares, tbWares);
	        end
    	--数量固定
    	else
    		if nProb1 ~= 0 or nProb2 ~= 0 then
    			Log(debug.traceback(), szShopType .. "," .. nLevel)	--填了无效的概率
    		end
    		local tbPoolWares = self:GetAPoolWares(szShopType, nLevel, nPool);
	        local tbWares = self:MakePoolWares(tbPoolWares, nCount1);
	        Lib:MergeTable(tbLevelWares, tbWares);
    	end
    end

    --数量固定 物品固定 -- 目前没有 pool 0 了，因为那个表里还有兵甲坊这种不走池子的,如果此类型多再改pool 0
    -- local tbPoolWares = self:GetAPoolWares(szShopType, nLevel, 0);
    -- local tbWares = {};
    -- for k,v in pairs(tbPoolWares) do
    -- 	table.insert(tbWares, {
    --         nTemplateId = v.nTemplateId,
    --         nCount = v.nCount,
    --         -- nTotalCount = v.nCount,
    -- 	});
    -- end
    -- Lib:MergeTable(tbLevelWares, tbWares);
    return tbLevelWares;
end

--Lib:CopyTB()视情况而定
function Shop:MakePoolWares(tbPoolWares, nCount)
    local tbRandom = {};
    for k,v in pairs(tbPoolWares) do
		table.insert(tbRandom, v);
    end

    if #tbRandom == 0 then
    	Log("ERROR Shop:MakePoolWares. PoolWares is zero");
    	return {};
    end

    local tbRet = {};
    for i = 1, nCount do
    	local nRandIndex = MathRandom(#tbRandom)
        local nPickTemplateId = tbRandom[nRandIndex].nTemplateId;
        tbRet[nPickTemplateId] = (tbRet[nPickTemplateId] or 0) + 1
    end

    local tbWares = {};
    for nTemplateId, nCount in pairs(tbRet) do
        table.insert(tbWares, {
            nTemplateId = nTemplateId,
            nCount = nCount,
            -- nTotalCount = nCount,
        });
    end

    return tbWares;
end

function Shop:GetAPoolWares(szShopType, nLevel, nPool)
	if self.ShopWares[szShopType][nLevel] then
		return self.ShopWares[szShopType][nLevel][nPool] or {};
	end

    return {};
end

function Shop:GetBuildingLevelServer(pPlayer, nBuildingId)
    local KinData = Kin:GetKinById(pPlayer.dwKinId);
    if not KinData then
    	return 0;
    end
    local nLevel = KinData:GetBuildingLevel(nBuildingId);
    return nLevel;
end

function Shop:SyncShopWares(pPlayer, szShopType, nTemplateId, tbSyncWare)
	--放在外面会有加载ScriptData顺序问题
	local tbWares = self.ShopWares[szShopType];

	if tbSyncWare then
		tbWares = tbSyncWare
	elseif nTemplateId then
    	tbWares = tbWares[nTemplateId]
	end
	if not tbWares then return end

	local bFamiShop, bRand = self:IsFamilyShop(szShopType)
	if bFamiShop then
		if bRand then
			local tbFamilyShopData = pPlayer.GetScriptTable("FamilyShop");
	    	pPlayer.CallClientScript("Shop:OnSyncFamilyShopData", szShopType, tbFamilyShopData[szShopType].tbWares);
		end
	end

	pPlayer.CallClientScript("Shop:OnSyncShopWares", szShopType, tbWares, nTemplateId);
end


function Shop:SyncBuyLimitInfo(pPlayer, tbLimitInfo)
	if not tbLimitInfo then
		tbLimitInfo = self:GetLimitInfo(pPlayer, self.WEEK_LIMIT_TYPE)
		local nNow = GetTime()
		if nNow >= self.nSpecailStartTime and  nNow <= self.nSpecailEndTime then
			local tbSpecial = Shop:GetLimitInfo(pPlayer, self.Special_LIMIT_TYPE)
			if tbSpecial then
				pPlayer.CallClientScript("Shop:OnSyncSpecailBuyLimitInfo", tbSpecial)
			end
		end
	end

	pPlayer.CallClientScript("Shop:OnSyncBuyLimitInfo", tbLimitInfo)
end

----------------活动商店

function Shop:SyncActBuyLimitInfo(pPlayer, tbActLimitInfo)
	if not tbActLimitInfo then
		tbActLimitInfo = self:GetLimitInfo(pPlayer, self.ACT_LIMIT_TYPE)
	end

	pPlayer.CallClientScript("Shop:OnSyncActBuyLimitInfo", tbActLimitInfo)
end

function Shop:SyncActWaresInfo(pPlayer)
	local tbWares = self.tbActShopWares
	if not tbWares then
		return
	end
	local tbActLimitInfo = self:GetLimitInfo(pPlayer, self.ACT_LIMIT_TYPE)
	pPlayer.CallClientScript("Shop:OnSyncActWaresInfo", tbWares, tbActLimitInfo, self.nShopActStartTime)
end

function Shop:LoadActShopWare(tbWares, nActStartTime)
	--检查下 goodid重复，加到 Treasure 里面
	--先去除所有旧的
	for szShopType,tbTreatureWares in pairs(Shop.ShopWares) do
		for nGoodsId,v in pairs(tbTreatureWares) do
			if v.nLimitType == self.ACT_LIMIT_TYPE then
				tbTreatureWares[nGoodsId] = nil;
			end
		end
	end
	tbWares = tbWares or {};
	for k,v in pairs(tbWares) do
		local szShopType = v.szShopType
		local tbTreatureWares = Shop.ShopWares[szShopType]
		v.nLimitType = self.ACT_LIMIT_TYPE
		tbTreatureWares[v.nGoodsId] = v;
	end
	self.tbActShopWares = tbWares --这部分主要是为了同步给客户端用
	self.nShopActStartTime = nActStartTime
end

function Shop:RemoveActShopWare()
	for szShopType,tbTreatureWares in pairs(Shop.ShopWares) do
		for nGoodsId,v in pairs(tbTreatureWares) do
			if v.nLimitType == self.ACT_LIMIT_TYPE then
				tbTreatureWares[nGoodsId] = nil;
			end
		end
	end

	self.tbActShopWares = nil;
	self.nShopActStartTime = nil;
end
-----------------------活动商店结束

local ShopInterface = {
	Buy = true,
	BuyGoods = true,
	Sell = true,
	SyncShopWares = true,
	CheckFamilyShop = true,
	SyncBuyLimitInfo = true,
	SyncActBuyLimitInfo = true,
	SyncActWaresInfo = true,
	MakeEquip = true,
	RenownShopRefresh = true,
	RenownShopBuy = true,
}
function Shop:ClientRequest(pPlayer, szRequestType, ... )
	if ShopInterface[szRequestType] then
		Shop[szRequestType](Shop, pPlayer, ...);
	else
		Log("WRONG Shop Request:", szRequestType, ...);
	end
end

Shop.EQUIP_MAKER_XY_SAVE_GRP = 93   -- 稀有
Shop.EQUIP_MAKER_CC_SAVE_GRP = 94   -- 传承
local EM_WEAPON_BEGIN_KEY = 1   --武器
local EM_CLOTHES_BEGIN_KEY = 21 --衣服
local EM_JEWELRY_BEGIN_KEY = 41 --首饰（项链、戒指、玉佩、护身符
local EM_ARMOR_BEGIN_KEY = 61   --防具（帽子、护腕、腰带、鞋子）

local tbEquipMakerType2BeginKeys = {
    [Item.EQUIP_WEAPON] = EM_WEAPON_BEGIN_KEY,      -- 武器
    [Item.EQUIP_ARMOR] = EM_CLOTHES_BEGIN_KEY,      -- 衣服

    [Item.EQUIP_RING] = EM_JEWELRY_BEGIN_KEY,       -- 戒指
    [Item.EQUIP_NECKLACE] = EM_JEWELRY_BEGIN_KEY,   -- 项链
    [Item.EQUIP_AMULET] = EM_JEWELRY_BEGIN_KEY,     -- 护身符
    [Item.EQUIP_PENDANT] = EM_JEWELRY_BEGIN_KEY,    -- 腰坠

    [Item.EQUIP_BOOTS] = EM_ARMOR_BEGIN_KEY,        -- 鞋子
    [Item.EQUIP_BELT] = EM_ARMOR_BEGIN_KEY,         -- 腰带
    [Item.EQUIP_HELM] = EM_ARMOR_BEGIN_KEY,         -- 头盔
    [Item.EQUIP_CUFF] = EM_ARMOR_BEGIN_KEY,         -- 护腕
}

function Shop:_EquipMakerGetTypeQuality(nUnidentifyId)
	local nItemId = Item:GetIdAfterIdentify(nUnidentifyId)
    local nType = Item:GetType(nItemId)
    local nQuality = Item:GetLevel(nItemId)
    return nType, nQuality
end

function Shop:_EquipMakerGetKeyByTypeQuality(nType, nQuality)
	local nBeginKey = tbEquipMakerType2BeginKeys[nType]
    if not nBeginKey then return end

    return nBeginKey+nQuality-1
end

function Shop:_EquipMakerGetKey(nUnidentifyId)
	local nType, nQuality = self:_EquipMakerGetTypeQuality(nUnidentifyId)
	return self:_EquipMakerGetKeyByTypeQuality(nType, nQuality)
end

function Shop:EquipMakerGetCurFails(pPlayer, bXY, nItemId)
    local nKey = self:_EquipMakerGetKey(nItemId)
    if not nKey then return 0 end

    local nSaveGrp = bXY and self.EQUIP_MAKER_XY_SAVE_GRP or self.EQUIP_MAKER_CC_SAVE_GRP
    return pPlayer.GetUserValue(nSaveGrp, nKey) or 0
end

function Shop:_EquipMakerGatherFails(pPlayer, nItemId)
	local nType, nDestQuality = self:_EquipMakerGetTypeQuality(nItemId)
	local tbTypeValues = self.tbEquipMakerItemValues[nType]
	if not tbTypeValues then
		return
	end

	local nTotalValue = 0
	for nQuality, nValue in pairs(tbTypeValues) do
		if nQuality<nDestQuality then
			local nKey = self:_EquipMakerGetKeyByTypeQuality(nType, nQuality)
			if nKey then
				local nFails = pPlayer.GetUserValue(self.EQUIP_MAKER_XY_SAVE_GRP, nKey) or 0
				if nFails>0 then
					nTotalValue = nTotalValue+(nFails*nValue)
					pPlayer.SetUserValue(self.EQUIP_MAKER_XY_SAVE_GRP, nKey, 0)
					Log("Shop:_EquipMakerGatherFails reset", nItemId, nKey, nFails, nValue, nTotalValue)
				end
			end
		end
	end

	if nTotalValue>0 then
		local nDestValue = tbTypeValues[nDestQuality] or math.huge
		local nAddFails = math.floor(nTotalValue/nDestValue)
		if nAddFails>0 then
			local nKey = self:_EquipMakerGetKeyByTypeQuality(nType, nDestQuality)
			if nKey then
				local nFails = pPlayer.GetUserValue(self.EQUIP_MAKER_XY_SAVE_GRP, nKey) or 0
				pPlayer.SetUserValue(self.EQUIP_MAKER_XY_SAVE_GRP, nKey, nFails+nAddFails)
				Log("Shop:_EquipMakerGatherFails add", nKey, nTotalValue, nDestValue, nFails, nAddFails)
			end
		end
	end
end

function Shop:_EquipMakerGetItemValue(nItemId)
    local tbInfo = KItem.GetItemBaseProp(nItemId)
    if tbInfo then
    	return tbInfo.nValue
    end
    return 0
end

function Shop:MakeEquip(pPlayer, nId)
	local nPlayerId = pPlayer.dwID
	local tbSetting = self.tbEquipMakerSettings[nId]
	if not tbSetting then
		Log("[x] Shop:MakeEquip failed: unknown id", nId)
		return
	end

	local bCan, szErr = self:CanMakeEquip(pPlayer, nId)
	if not bCan then
		pPlayer.CenterMsg(szErr)
		return
	end

	self:_EquipMakerGatherFails(pPlayer, tbSetting.nItem3Id)
	local nIdx = self:_EquipMakerGetRandomIdx(pPlayer, tbSetting.nItem1Id)
	local nItemId = tbSetting[string.format("nItem%dId", nIdx)]
	if nItemId<=0 then
		Log("[x] Shop:MakeEquip failed: can't get random item")
		return
	end

	local nPrice = Shop:GetEquipMakerPrice(pPlayer, nId)
	if not pPlayer.CostMoney(tbSetting.szMoneyType, nPrice, Env.LogWay_EquipMaker, nItemId) then
		Log("[x] Shop:MakeEquip, CostMoney failed", nPlayerId, pPlayer.szName, nId, tbSetting.szMoneyType, nPrice)
		return
	end

	self:_EquipMakerUpdateSaveKey(pPlayer, nItemId, nIdx)

	-- 越南倒元宝惩罚机制
	if version_vn and nIdx==3 and Player:GetRewardValueDebt(nPlayerId)>0 and MathRandom(100)<50 then
		nIdx = 2
		local nOldItemId = nItemId
		nItemId = tbSetting[string.format("nItem%dId", nIdx)]

		local nOldValue = self:_EquipMakerGetItemValue(nOldItemId)
		local nNewValue = self:_EquipMakerGetItemValue(nItemId)
		local nReduce = math.ceil((nOldValue-nNewValue)/1000)
		Player:CostRewardValueDebt(nPlayerId, nReduce, Env.LogWay_EquipMaker)
		Log("Shop:MakeEquip vn_debt ", nPlayerId, nId, nOldItemId, nItemId, nOldValue, nNewValue, nReduce, Player:GetRewardValueDebt(nPlayerId))
	end

	pPlayer.AddItem(nItemId, 1, nil, Env.LogWay_EquipMaker)
	pPlayer.CallClientScript("Shop:OnEquipMakerRet", nItemId)

	Achievement:AddCount(pPlayer, "Family_4", 1)

	local nKinId = pPlayer.dwKinId
	if nIdx==3 and nKinId>0 then
		local tbKinData = Kin:GetKinById(nKinId)
		if tbKinData then
			local szBuildingName = Kin.Def.BuildingName[tbSetting.nHouse]
			local szEquipName = KItem.GetItemShowInfo(nItemId, pPlayer.nFaction)
			local szSysMsg = string.format("「%s」在%s成功打造出了<%s>，真是鴻運當頭！", pPlayer.szName, szBuildingName, szEquipName)
			ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szSysMsg, nKinId, {nLinkType = ChatMgr.LinkType.Item, nTemplateId = nItemId, nFaction = pPlayer.nFaction})
		end
	end

	Log("Shop:MakeEquip", nPlayerId, nId, nItemId, nIdx, nKinId)
end

-- 1-普通；2-传承；3-稀有
function Shop:_EquipMakerGetRandomIdx(pPlayer, nItemId)
	local nMaxFails = #self.tbEquipMakerRateSettings
	local nCCFails = math.min(self:EquipMakerGetCurFails(pPlayer, false, nItemId), nMaxFails)
	local nXYFails = math.min(self:EquipMakerGetCurFails(pPlayer, true, nItemId), nMaxFails)

	local nCCRate = self.tbEquipMakerRateSettings[nCCFails].nCCRate
	local nXYRate = self.tbEquipMakerRateSettings[nXYFails].nXYRate

	local nRand = MathRandom(1, 1000)
	if nRand<=nXYRate then
		return 3
	elseif nRand<=(nCCRate+nXYRate) then
		return 2
	end
	return 1
end

function Shop:_EquipMakerUpdateSaveKey(pPlayer, nItemId, nIdx)
	local nKey = self:_EquipMakerGetKey(nItemId)
	if not nKey then
		Log("[x] Shop:_EquipMakerUpdateSaveKey", pPlayer.dwID, nItemId, nIdx)
		return
	end

	local bXY = nIdx==3
	local bCC = nIdx==2

	local nXYCount = 0
	local nCCCount = 0
	local nMaxFails = #self.tbEquipMakerRateSettings
	local nForceReset = 3
	if not bXY then
		nXYCount = pPlayer.GetUserValue(self.EQUIP_MAKER_XY_SAVE_GRP, nKey)+1
		if nXYCount>nMaxFails+nForceReset then
			nXYCount = 1
		end
	end
	if not bCC then
		nCCCount = pPlayer.GetUserValue(self.EQUIP_MAKER_CC_SAVE_GRP, nKey)+1
		if nCCCount>nMaxFails+nForceReset then
			nCCCount = 1
		end
	end
	pPlayer.SetUserValue(self.EQUIP_MAKER_XY_SAVE_GRP, nKey, nXYCount)
	pPlayer.SetUserValue(self.EQUIP_MAKER_CC_SAVE_GRP, nKey, nCCCount)

	Log("Shop:_EquipMakerUpdateSaveKey", pPlayer.dwID, nItemId, nIdx, nKey, nXYCount, nCCCount)
end

function Shop:DataCheck()
	--在交易中心出现的商品就不能出现到荣誉商店了
	-- local tbHonorWare = self.ShopWares["Honor"]
	-- local tbCenterWare = self.tbTradingSetting --TradingCenter
	-- for k,v in pairs(tbHonorWare) do
	-- 	assert(not tbCenterWare[k],  k)
	-- end
	local tbTreasureWare = self.ShopWares["Treasure"]
	for nTemplateId, v in pairs(tbTreasureWare) do
		if v.nFullPrice then
			assert(v.nLimitType and v.nDiscount, nTemplateId)
		end
		if v.nLimitType  then
		    assert(v.nLimitType == 7, nTemplateId) --现在只有每周限购
		    assert(v.nLimitNum > 0 , nTemplateId)
		end
		if not Lib:IsEmptyStr(v.szOpenTime) or not Lib:IsEmptyStr(v.szCloseTime) then
			assert(Lib:ParseDateTime(v.szOpenTime) < Lib:ParseDateTime(v.szCloseTime), nTemplateId)
		end
	end

	local tbFile = LoadTabFile("Setting/Shop/Wares.tab", "d", nil, {"GoodsId"});
	local tbHasUseGoodId = {};
	for i,v in ipairs(tbFile) do
		assert(not tbHasUseGoodId[v.GoodsId], v.GoodsId)
		tbHasUseGoodId[v.GoodsId] = 1;
	end
end


function Shop:RenownShopRefresh(pPlayer)
	if not self:ShouldRenownShopRefresh(pPlayer) then
		return
	end

	for nId, tbSetting in pairs(self.tbRenownShop) do
		if nId<1 or nId>=255 then
			Log("[x] Shop:RenownShopRefresh, invalid id", nId)
		else
			local nAvaliableCount = 0
			local szTimeFrame = tbSetting.szTimeFrame or ""
			if szTimeFrame=="" or GetTimeFrameState(szTimeFrame)==1 then
				local nRand = MathRandom(1, 100)
				if nRand<=tbSetting.nRate then
					nAvaliableCount = tbSetting.nMaxCount
				end
			end
			pPlayer.SetUserValue(self.nRenownShopSaveGrp, nId, nAvaliableCount)
		end
	end
	pPlayer.SetUserValue(self.nRenownShopSaveGrp, self.nRenownShopUpdateKey, GetTime())
	pPlayer.CallClientScript("Shop:RenownShopRefreshed")
end

function Shop:RenownShopBuy(pPlayer, nId, nCount, nClientPrice)
	self:RenownShopRefresh(pPlayer)

	nCount = math.floor(nCount or 0)
	local bOk, szErr = self:RenownShopCheckBeforeBuy(pPlayer, nId, nCount)
	if not bOk then
		pPlayer.CenterMsg(szErr)
		return
	end

	local tbSetting = self.tbRenownShop[nId]
	if nClientPrice ~= tbSetting.nPrice then
		pPlayer.CenterMsg("該商品的價格配置無效")
		return
	end
	local nCost = tbSetting.nPrice*nCount

	if not pPlayer.CostMoney("Renown", nCost, Env.LogWay_RenownShop) then
		pPlayer.CenterMsg("消耗名望失敗")
		return
	end

	local nAvaliableCount = pPlayer.GetUserValue(self.nRenownShopSaveGrp, nId)
	local nLeft = nAvaliableCount-nCount
	if nLeft<=0 then
		nLeft = -1
	end
	pPlayer.SetUserValue(self.nRenownShopSaveGrp, nId, nLeft)

	pPlayer.AddItem(tbSetting.nItemId, nCount, nil, Env.LogWay_RenownShop)
	pPlayer.CallClientScript("Shop:RenownShopBought", {
		nId = nId,
		nLeft = nLeft,
		nCost = nCost,
	})

	Log("Shop:RenownShopBuy", pPlayer.dwID, pPlayer.szName, nId, nCount)
end

Shop:DataCheck();