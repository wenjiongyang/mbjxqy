
local function IsPartnerSSPlus(tbItem)
	return Lib:IsInArray({
		Partner.tbDes2QualityLevel.SS,
		Partner.tbDes2QualityLevel.SSS},
		tbItem.nQualityLevel);
end

local function IsPartnerSPlus(tbItem)
	return Lib:IsInArray({
		Partner.tbDes2QualityLevel.S,
		Partner.tbDes2QualityLevel.SS,
		Partner.tbDes2QualityLevel.SSS},
		tbItem.nQualityLevel);
end

local function IsPartnerS(tbItem)
	return tbItem.nQualityLevel == Partner.tbDes2QualityLevel.S;
end

local function IsPartnerB(tbItem)
	return tbItem.nQualityLevel == Partner.tbDes2QualityLevel.B;
end

local function IsPartnerA(tbItem)
	return tbItem.nQualityLevel == Partner.tbDes2QualityLevel.A;
end

local function IsPartnerSpecial(tbItem)
	return tbItem.szItemType == CardPicker.Def.tbSpecialTenGoldSPartner.szItemType
			and tbItem.nItemId == CardPicker.Def.tbSpecialTenGoldSPartner.nItemId;
end

function CardPicker:SelectRandomItems(tbItems, szPickerType)
	local nAllProbVip = 0;
	for _, tbItem in ipairs(tbItems) do
		nAllProbVip = nAllProbVip + tbItem.nProb;
	end

	local nMyProb = MathRandom(1, nAllProbVip);
	for nIdx, tbItem in ipairs(tbItems) do
		local nItemPro = tbItem.nProb;
		if nItemPro >= nMyProb then
			return tbItem, nIdx;
		else
			nMyProb = nMyProb - nItemPro;
		end
	end

	assert(false, szPickerType .. "數量:" .. #tbItems .. "機率:" .. nMyProb .. "/" .. nAllProbVip);
end

function CardPicker:GetRandomItem(szPickerType, pPlayer, fnCheck)
	local tbItems = CardPicker:GetCardPickItems(pPlayer, szPickerType, fnCheck);
	local tbItem = CardPicker:SelectRandomItems(tbItems, szPickerType);
	return tbItem;
end

function CardPicker:GetPartnerSPlusItem(szPickerType, pPlayer)
	local fnCheck = function (tbItem)
		return tbItem.szItemType == "Partner" and IsPartnerSPlus(tbItem);
	end

	return self:GetRandomItem(szPickerType, pPlayer, fnCheck);
end

function CardPicker:GetPartnerSItem(szPickerType, pPlayer)
	local fnCheck = function (tbItem)
		return tbItem.szItemType == "Partner" and IsPartnerS(tbItem);
	end

	return self:GetRandomItem(szPickerType, pPlayer, fnCheck);
end

function CardPicker:GetPartnerBItem(szPickerType, pPlayer)
	local fnCheck = function (tbItem)
		return tbItem.szItemType == "Partner" and IsPartnerB(tbItem);
	end

	return self:GetRandomItem(szPickerType, pPlayer, fnCheck);
end

function CardPicker:GetPartnerAItem(szPickerType, pPlayer)
	local fnCheck = function (tbItem)
		return tbItem.szItemType == "Partner" and IsPartnerA(tbItem);
	end

	return self:GetRandomItem(szPickerType, pPlayer, fnCheck);
end

function CardPicker:GetPartnerNomalItem(szPickerType, pPlayer)
	local fnCheck = function (tbItem)
		return tbItem.szItemType == "Partner" and not IsPartnerSPlus(tbItem);
	end

	return self:GetRandomItem(szPickerType, pPlayer, fnCheck);
end

function CardPicker:GetGoldTenItem(pPlayer)
	local tbResult = {};
	for i = 1, 9 do
		local tbItem = CardPicker:GetRandomItem("Gold", pPlayer);
		table.insert(tbResult, tbItem);
	end

	local nSCount = 0;
	for nIth, tbItem in ipairs(tbResult) do
		if tbItem.szItemType == "Partner" and IsPartnerSPlus(tbItem) then
			nSCount = nSCount + 1;
		end

		if nSCount > 1 then
			nSCount = nSCount - 1;
			tbResult[nIth] = CardPicker:GetPartnerNomalItem("Gold", pPlayer);
		end
	end

	tbResult[10] = CardPicker:GetPartnerSPlusItem("Gold", pPlayer);
	return tbResult;
end

function CardPicker:GetSpecialGoldTenItem(pPlayer)
	local fnCheckA = function (tbItem)
		return tbItem.szItemType == "Partner"
			and IsPartnerA(tbItem)
			and pPlayer.GetUserValue(Partner.PARTNER_HAS_GROUP, tbItem.nItemId) ~= 1;
	end

	local fnCheckS = function (tbItem)
		return tbItem.szItemType == "Partner"
			and IsPartnerS(tbItem)
			and pPlayer.GetUserValue(Partner.PARTNER_HAS_GROUP, tbItem.nItemId) ~= 1;
	end

	local tbValidAItem = CardPicker:GetCardPickItems(pPlayer, "Gold", fnCheckA);
	local tbValidSItem = CardPicker:GetCardPickItems(pPlayer, "Gold", fnCheckS);
	local tbGoldTenItem = CardPicker:GetGoldTenItem(pPlayer);

	-- 对于高V玩家，抽中SS级特殊同伴的规则单独处理
	local nVipLevel = pPlayer.GetVipLevel();
	if nVipLevel >= CardPicker.Def.nVipProbDivide then
		local nGoldTenCount = pPlayer.GetUserValue(CardPicker.Def.CARD_SAVE_GROUP, CardPicker.Def.SAVE_TEN_GOLD_COUNT_KEY) % 10000;
		local bSpecialHit = CardPicker:IsSpecialPartnerHit(nGoldTenCount + 1);
		local bHasSpecial = false;
		for nIdx, tbItem in ipairs(tbGoldTenItem) do
			if IsPartnerSpecial(tbItem) then
				if not bSpecialHit then
					tbGoldTenItem[nIdx] = CardPicker:GetPartnerSItem("Gold", pPlayer);
				end
				bHasSpecial = true;
			end
		end

		if bSpecialHit and not bHasSpecial then
			for nIdx, tbItem in ipairs(tbGoldTenItem) do
				if IsPartnerS(tbItem) then
					tbGoldTenItem[nIdx] = CardPicker.Def.tbSpecialTenGoldSPartner;
					break;
				end
			end
		end
	end

	-- 抽到过的卡不再抽到，直到无卡可抽时，可抽到重复的
	for nIdx, tbItem in ipairs(tbGoldTenItem) do
		if tbItem.szItemType == "Partner" then
			if IsPartnerA(tbItem) and next(tbValidAItem) then
				local tbNewItem, nItemIdx = CardPicker:SelectRandomItems(tbValidAItem, "Gold");
				if tbNewItem then
					tbGoldTenItem[nIdx] = tbNewItem;
					table.remove(tbValidAItem, nItemIdx);
				end
			elseif IsPartnerS(tbItem) and next(tbValidSItem) then
				local tbNewItem, nItemIdx = CardPicker:SelectRandomItems(tbValidSItem, "Gold");
				if tbNewItem then
					tbGoldTenItem[nIdx] = tbNewItem;
					table.remove(tbValidSItem, nItemIdx);
				end
			end
		end
	end
	return tbGoldTenItem;
end

function CardPicker:GetNextGoldItem(pPlayer, bNotSave)
	local tbCardPickData = CardPicker:GetCardPickerData(pPlayer);
	if not next(tbCardPickData.tbGoldPickCache or {}) then
		tbCardPickData.tbGoldPickCache = CardPicker:GetGoldTenItem(pPlayer);
	end

	local tbItem = tbCardPickData.tbGoldPickCache[1];
	table.remove(tbCardPickData.tbGoldPickCache, 1);

	tbCardPickData.nLeftSTime = #(tbCardPickData.tbGoldPickCache);
	if not bNotSave then
		CardPicker:SaveCardPickerData(pPlayer, tbCardPickData);
	end
	return tbItem;
end

function CardPicker:CoinPick()
	if not self:CheckIsOpen() then
		return false, "招募還沒開放！";
	end

	if me.GetFreeBagCount() < 1 then
		return false, "背包將達到上限, 請先清理背包";
	end

	if me.GetMoney("Coin") < CardPicker.Def.nCoinCost then
		return false, "銀兩不足以進行招募";
	end

	local tbItem = nil;
	local tbCardPickData = CardPicker:GetCardPickerData(me);
	if tbCardPickData.nCoinPickCount == 0 then
		tbItem = CardPicker:GetPartnerBItem("Coin", me);
	else
		tbItem = CardPicker:GetRandomItem("Coin", me);
	end

	if not me.CostMoney("Coin", CardPicker.Def.nCoinCost, Env.LogWay_CoinPick, tbItem.nItemId) then
		return false, "扣除銀兩出錯";
	end

	me.SendAward({{tbItem.szItemType, tbItem.nItemId, tbItem.nCount}}, false, false, Env.LogWay_CoinPick);

	local tbGift = CardPicker.Def.tbCoinPickGift;
	me.SendAward({{tbGift.szItemType, tbGift.nItemId, 1}}, nil, nil, Env.LogWay_CoinPick);
	me.CallClientScript("CardPicker:OnCoinPickResult", {tbItem}, tbGift);

	tbCardPickData.nCoinPickCount = tbCardPickData.nCoinPickCount + 1;
	CardPicker:SaveCardPickerData(me, tbCardPickData);
	CardPicker:RecordCardPickInfo(me, "CoinPick", {tbItem});
	Log("CardPicker", me.szAccount, me.dwID, "Coin", tbItem.szItemType, tbItem.nItemId, tbItem.nCount);
	return true;
end

function CardPicker:CoinTenPick()
	if not self:CheckIsOpen() then
		return false, "招募還沒開放！";
	end

	if me.GetFreeBagCount() < 10 then
		return false, "背包將達到上限, 請先清理背包";
	end

	if me.GetMoney("Coin") < CardPicker.Def.nCoinTenCost then
		return false, "銀兩不足以進行招募";
	end

	local tbItems = {};
	local strGetItemIds = ""
	local tbCardPickData = CardPicker:GetCardPickerData(me);
	if tbCardPickData.nCoinPickCount == 0 then
		table.insert(tbItems, CardPicker:GetPartnerBItem("Coin", me));
	else
		table.insert(tbItems, CardPicker:GetRandomItem("Coin", me));
	end
	strGetItemIds = tbItems[1].nItemId;

	for i = 1, 9 do
		local tbItem = CardPicker:GetRandomItem("Coin", me);
		table.insert(tbItems, tbItem);
		strGetItemIds = strGetItemIds .. "," .. tbItem.nItemId
	end

	if not me.CostMoney("Coin", CardPicker.Def.nCoinTenCost, Env.LogWay_CoinTenPick, strGetItemIds) then
		return false, "扣除銀兩出錯";
	end

	for _, tbItem in ipairs(tbItems) do
		me.SendAward({{tbItem.szItemType, tbItem.nItemId, tbItem.nCount}}, false, false, Env.LogWay_CoinTenPick);
		Log("CardPicker", me.szAccount, me.dwID, "Coin", tbItem.szItemType, tbItem.nItemId, tbItem.nCount);
	end

	local tbGift = CardPicker.Def.tbCoinPickGift;
	me.SendAward({{tbGift.szItemType, tbGift.nItemId, 10}}, nil, nil, Env.LogWay_CoinTenPick);

	tbCardPickData.nCoinPickCount = tbCardPickData.nCoinPickCount + 10;
	CardPicker:SaveCardPickerData(me, tbCardPickData);
	CardPicker:RecordCardPickInfo(me, "CoinTenPick", tbItems);
	me.CallClientScript("CardPicker:OnTenPickResult", tbItems, tbGift);
	return true;
end


function CardPicker:CoinFreePick()
	if not self:CheckIsOpen() then
		return false, "招募還沒開放！";
	end

	if me.GetFreeBagCount() < 1 then
		return false, "背包將達到上限, 請先清理背包";
	end

	local tbCardPickData = CardPicker:GetCardPickerData(me);
	local nNow = GetTime();
	if nNow < tbCardPickData.nNextCoinFreePickTime then
		return false, "免費招募冷卻時間未到";
	end

	local tbItem = nil;
	if tbCardPickData.nCoinPickCount == 0 then
		tbItem = CardPicker:GetPartnerBItem("Coin", me);
	else
		tbItem = CardPicker:GetRandomItem("Coin", me);
	end

	tbCardPickData.nCoinPickCount = tbCardPickData.nCoinPickCount + 1;
	tbCardPickData.nNextCoinFreePickTime = nNow + CardPicker:GetFreeCoinCDTime();
	CardPicker:SaveCardPickerData(me, tbCardPickData);

	me.SendAward({{tbItem.szItemType, tbItem.nItemId, tbItem.nCount}}, false, false, Env.LogWay_CoinPick);

	local tbGift = CardPicker.Def.tbCoinPickGift;
	me.SendAward({{tbGift.szItemType, tbGift.nItemId, 1}}, nil, nil, Env.LogWay_CoinPick);
	me.CallClientScript("CardPicker:OnCoinPickResult", {tbItem}, tbGift);
	CardPicker:RecordCardPickInfo(me, "CoinFreePick", {tbItem});
	Log("CardPicker", me.szAccount, me.dwID, "CoinFree", tbItem.szItemType, tbItem.nItemId, tbItem.nCount);
	return true;
end

function CardPicker:GoldPick()
	if not self:CheckIsOpen() then
		return false, "招募還沒開放！";
	end

	if me.GetFreeBagCount() < 1 then
		return false, "背包將達到上限, 請先清理背包";
	end

	if me.GetMoney("Gold") < CardPicker.Def.nGoldCost then
		return false, "元寶不足以進行元寶招募";
	end

	local tbItem = CardPicker:GetNextGoldItem(me, true);
	me.CostGold(CardPicker.Def.nGoldCost, Env.LogWay_GoldPick, tbItem.nItemId, function (nPlayerId, bSuccess)
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if not pPlayer then
			return false, "元寶招募過程中, 您離線了.";
		end

		if not bSuccess then
			return false, "元寶招募失敗";
		end

		local tbItem = CardPicker:GetNextGoldItem(pPlayer);

		local tbCardPickData = CardPicker:GetCardPickerData(pPlayer);
		local bIsFirst = (tbCardPickData.nGoldPickCount == 0);
		if bIsFirst then
			tbItem = CardPicker:GetPartnerAItem("Gold", pPlayer);
		end
		tbCardPickData.nGoldPickCount = tbCardPickData.nGoldPickCount + 1;
		CardPicker:SaveCardPickerData(pPlayer, tbCardPickData);

		local tbItems, bHasSSPlus = CardPicker:HiddenRuleHandler({tbItem}, pPlayer);
		tbItem = unpack(tbItems);

		Task:OnTaskExtInfo(pPlayer, Task.ExtInfo_YuanBaoZhaoMu);
		pPlayer.SendAward({{tbItem.szItemType, tbItem.nItemId, tbItem.nCount}}, false, false, Env.LogWay_GoldPick);

		local tbGift = CardPicker.Def.tbGoldPickGift;
		pPlayer.SendAward({{tbGift.szItemType, tbGift.nItemId, 1}}, nil, nil, Env.LogWay_GoldPick);

		pPlayer.CallClientScript("CardPicker:OnGoldPickResult", {tbItem}, tbGift);
		if bHasSSPlus then
			pPlayer.CallClientScript("GameSetting.Comment:OnEvent", GameSetting.Comment.Type_CardPick_SS);
		end
		Log("CardPicker", pPlayer.szAccount, pPlayer.dwID, "Gold", tbItem.szItemType, tbItem.nItemId, tbItem.nCount);
		CardPicker:RecordCardPickInfo(pPlayer, "GoldPick", {tbItem});
		return true;
	end);
	return true;
end

function CardPicker:GoldTenPick(nPrice)
	if not self:CheckIsOpen() then
		return false, "招募還沒開放！";
	end

	if me.GetFreeBagCount() < 10 then
		return false, "背包將達到上限, 請先清理背包";
	end

	if not nPrice then
		return false, "用戶端版本過舊, 請俠士重啟用戶端後再次嘗試";
	end

	local nRealCost = CardPicker:GetGoldTenCostInfo(me);
	if nPrice ~= nRealCost then
		CardPicker:UpdateCardPickInfo();
		return false, "抽卡價格有變, 還請俠士稍後再次嘗試";
	end

	if me.GetMoney("Gold") < nRealCost then
		return false, "元寶不足以進行招募十次";
	end

	me.CostGold(nRealCost, Env.LogWay_GoldTenPick, nil, function (nPlayerId, bSuccess, szBillNo)
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if not pPlayer then
			return false, "元寶招募過程中, 您離線了.";
		end

		if not bSuccess then
			return false, "元寶招募失敗";
		end

		local nRealCost, nOnSaleFlag = CardPicker:GetGoldTenCostInfo(pPlayer);
		if nPrice ~= nRealCost then
			return false, "抽卡價格有變, 還請俠士刷新介面後再次嘗試";
		end

		if nOnSaleFlag then
			pPlayer.SetUserValue(CardPicker.Def.CARD_GOLD_TEN_SALE_GROUP, CardPicker.Def.CARD_GOLD_TEN_SALE_KEY, nOnSaleFlag);
		end

		local bHasSSPlus = false;
		local tbItems = CardPicker:GetSpecialGoldTenItem(pPlayer);
		tbItems, bHasSSPlus = CardPicker:HiddenRuleHandler(tbItems, pPlayer, true);
		local tbSendAward = {}
		local strGetItemIds = ""
		for _, tbItem in ipairs(tbItems) do
			table.insert(tbSendAward, {tbItem.szItemType, tbItem.nItemId, tbItem.nCount})
			strGetItemIds = strGetItemIds .. tbItem.nItemId .. ","
		end

		Task:OnTaskExtInfo(pPlayer, Task.ExtInfo_YuanBaoZhaoMu);
		pPlayer.SendAward(tbSendAward , false, false, Env.LogWay_GoldTenPick);
		Log("CardPicker", pPlayer.szAccount, pPlayer.dwID, "GoldTen", strGetItemIds);

		local tbGift = CardPicker.Def.tbGoldPickGift;
		pPlayer.SendAward({{tbGift.szItemType, tbGift.nItemId, 10}}, nil, nil, Env.LogWay_GoldTenPick);

		pPlayer.CallClientScript("CardPicker:OnTenPickResult", tbItems, tbGift);
		if bHasSSPlus then
			pPlayer.CallClientScript("GameSetting.Comment:OnEvent", GameSetting.Comment.Type_CardPick_SS);
		end
		pPlayer.TLog("MoneyFlow", pPlayer.nLevel, 0, 0, 0, Env.LogWay_GoldTenPick, strGetItemIds, 1, Shop.tbMoney["Gold"]["SaveKey"]);
		CardPicker:RecordCardPickInfo(pPlayer, "GoldTenPick", tbItems);
		return true;
	end);
	return true;
end

function CardPicker:GoldFreePick()
	if not self:CheckIsOpen() then
		return false, "招募還沒開放！";
	end

	if me.GetFreeBagCount() < 1 then
		return false, "背包將達到上限, 請先清理背包";
	end

	local tbCardPickData = CardPicker:GetCardPickerData(me);
	local nNow = GetTime();
	if nNow < tbCardPickData.nNextGoldFreePickTime then
		return false, "免費招募冷卻時間未到";
	end

	local tbItem = CardPicker:GetNextGoldItem(me);
	tbCardPickData = CardPicker:GetCardPickerData(me);
	local bIsFirst = (tbCardPickData.nGoldPickCount == 0);
	if bIsFirst then
		tbItem = CardPicker:GetPartnerAItem("Gold", me);
	end

	local tbItems, bHasSSPlus = CardPicker:HiddenRuleHandler({tbItem}, me);
	tbItem = unpack(tbItems);

	Task:OnTaskExtInfo(me, Task.ExtInfo_YuanBaoZhaoMu);
	me.SendAward({{tbItem.szItemType, tbItem.nItemId, tbItem.nCount}}, false, false, Env.LogWay_GoldFreePick);

	local tbGift = CardPicker.Def.tbGoldPickGift;
	me.SendAward({{tbGift.szItemType, tbGift.nItemId, 1}}, nil, nil, Env.LogWay_GoldFreePick);

	tbCardPickData.nNextGoldFreePickTime = nNow + CardPicker:GetFreeGoldCDTime();
	tbCardPickData.nGoldPickCount = tbCardPickData.nGoldPickCount + 1;
	CardPicker:SaveCardPickerData(me, tbCardPickData);

	me.CallClientScript("CardPicker:OnGoldPickResult", {tbItem}, tbGift);
	if bHasSSPlus then
		me.CallClientScript("GameSetting.Comment:OnEvent", GameSetting.Comment.Type_CardPick_SS);
	end
	CardPicker:RecordCardPickInfo(me, "GoldFreePick", {tbItem});
	Log("CardPicker", me.szAccount, me.dwID, "GoldFree", tbItem.szItemType, tbItem.nItemId, tbItem.nCount);
	return true;
end

function CardPicker:GetCardPickerData(pPlayer)
	local nGoldPickCount = pPlayer.GetUserValue(CardPicker.Def.CARD_SAVE_GROUP, CardPicker.Def.SAVE_GOLD_PICK_COUNT_KEY);
	local nSpecailCount = pPlayer.GetUserValue(CardPicker.Def.CARD_SAVE_GROUP, CardPicker.Def.SAVE_TEN_GOLD_COUNT_KEY);
	local nCoinPickCount = pPlayer.GetUserValue(CardPicker.Def.CARD_SAVE_GROUP, CardPicker.Def.SAVE_COIN_PICK_COUNT_KEY);
	local nLeftSTime = pPlayer.GetUserValue(CardPicker.Def.CARD_SAVE_SYNC_GROUP, CardPicker.Def.SAVE_LEFT_S_TIME);
	local nNextGoldFreePickTime = pPlayer.GetUserValue(CardPicker.Def.CARD_SAVE_SYNC_GROUP, CardPicker.Def.SAVE_NEXT_GOLD_FREE_TIME);
	local nNextCoinFreePickTime = pPlayer.GetUserValue(CardPicker.Def.CARD_SAVE_SYNC_GROUP, CardPicker.Def.SAVE_NEXT_COIN_FREE_TIME);

	if nNextGoldFreePickTime == 0 then
		nNextGoldFreePickTime = pPlayer.dwCreateTime + CardPicker.Def.nFreeGoldCdTimeFromCreate;
		pPlayer.SetUserValue(CardPicker.Def.CARD_SAVE_SYNC_GROUP, CardPicker.Def.SAVE_NEXT_GOLD_FREE_TIME, nNextGoldFreePickTime);
	end

	if nNextCoinFreePickTime == 0 then
		nNextCoinFreePickTime = pPlayer.dwCreateTime + CardPicker.Def.nFreeCoinPickCdTime;
		pPlayer.SetUserValue(CardPicker.Def.CARD_SAVE_SYNC_GROUP, CardPicker.Def.SAVE_NEXT_COIN_FREE_TIME, nNextCoinFreePickTime);
	end

	if nLeftSTime == 0 then
		nLeftSTime = 10;
		pPlayer.SetUserValue(CardPicker.Def.CARD_SAVE_SYNC_GROUP, CardPicker.Def.SAVE_LEFT_S_TIME, nLeftSTime);
	end

	local tbGoldPickCache = {};
	for nIdx = CardPicker.Def.SAVE_GOLD_PICK_CACHE_BEGIN, CardPicker.Def.SAVE_GOLD_PICK_CACHE_END, 2 do
		local nTyp = pPlayer.GetUserValue(CardPicker.Def.CARD_SAVE_GROUP, nIdx);
		local nItemId = pPlayer.GetUserValue(CardPicker.Def.CARD_SAVE_GROUP, nIdx + 1);
		if nTyp ~= 0 and nItemId ~= 0 then
			table.insert(tbGoldPickCache, {
				szItemType = Player.AwardType2Name[nTyp];
				nItemId    = nItemId;
				nCount     = 1;
			});
		end
	end

	-- local tbSPartnerCache = {};
	-- for nIdx = CardPicker.Def.SAVE_FRIST_THREE_S_BEGIN, CardPicker.Def.SAVE_FRIST_THREE_S_END do
	-- 	local nItemId = pPlayer.GetUserValue(CardPicker.Def.CARD_SAVE_GROUP, nIdx);
	-- 	if nItemId ~= 0 then
	-- 		tbSPartnerCache[nItemId] = true;
	-- 	end
	-- end

	local tbCardPickData = {
		nNextGoldFreePickTime = nNextGoldFreePickTime;
		nNextCoinFreePickTime = nNextCoinFreePickTime;
		nGoldPickCount = nGoldPickCount;
		nSpecailCount = nSpecailCount;
		nCoinPickCount = nCoinPickCount;
		nLeftSTime = nLeftSTime;
		tbGoldPickCache = tbGoldPickCache;
		-- tbSPartnerCache = tbSPartnerCache;
	};

	return tbCardPickData;
end

function CardPicker:SaveCardPickerData(pPlayer, tbData)
	pPlayer.SetUserValue(CardPicker.Def.CARD_SAVE_GROUP, CardPicker.Def.SAVE_GOLD_PICK_COUNT_KEY, tbData.nGoldPickCount);
	pPlayer.SetUserValue(CardPicker.Def.CARD_SAVE_GROUP, CardPicker.Def.SAVE_COIN_PICK_COUNT_KEY, tbData.nCoinPickCount);
	pPlayer.SetUserValue(CardPicker.Def.CARD_SAVE_GROUP, CardPicker.Def.SAVE_TEN_GOLD_COUNT_KEY, tbData.nSpecailCount);
	pPlayer.SetUserValue(CardPicker.Def.CARD_SAVE_SYNC_GROUP, CardPicker.Def.SAVE_LEFT_S_TIME, tbData.nLeftSTime);
	pPlayer.SetUserValue(CardPicker.Def.CARD_SAVE_SYNC_GROUP, CardPicker.Def.SAVE_NEXT_GOLD_FREE_TIME, tbData.nNextGoldFreePickTime);
	pPlayer.SetUserValue(CardPicker.Def.CARD_SAVE_SYNC_GROUP, CardPicker.Def.SAVE_NEXT_COIN_FREE_TIME, tbData.nNextCoinFreePickTime);

	local tbGoldPickCache = tbData.tbGoldPickCache or {};
	local nGoldPickIdx = 0;
	for nIdx = CardPicker.Def.SAVE_GOLD_PICK_CACHE_BEGIN, CardPicker.Def.SAVE_GOLD_PICK_CACHE_END, 2 do
		nGoldPickIdx = nGoldPickIdx + 1;
		local tbItem = tbGoldPickCache[nGoldPickIdx];
		if tbItem then
			pPlayer.SetUserValue(CardPicker.Def.CARD_SAVE_GROUP, nIdx, Player.AwardType[tbItem.szItemType]);
			pPlayer.SetUserValue(CardPicker.Def.CARD_SAVE_GROUP, nIdx + 1, tbItem.nItemId);
		else
			pPlayer.SetUserValue(CardPicker.Def.CARD_SAVE_GROUP, nIdx, 0);
			pPlayer.SetUserValue(CardPicker.Def.CARD_SAVE_GROUP, nIdx + 1, 0);
		end
	end

	-- local nSParterIdx = CardPicker.Def.SAVE_FRIST_THREE_S_BEGIN;
	-- for nItemId, _ in pairs(tbData.tbSPartnerCache or {}) do
	-- 	pPlayer.SetUserValue(CardPicker.Def.CARD_SAVE_GROUP, nSParterIdx, nItemId);
	-- 	nSParterIdx = nSParterIdx + 1;
	-- end
end

function CardPicker:HiddenRuleHandler(tbItems, pPlayer, bGoldTen)
	pPlayer = pPlayer or me;
	local bSave = false;
	local tbCardPickData = CardPicker:GetCardPickerData(pPlayer);

	-- 历史原因特殊处理之， 将之前抽到卡之后的次数重置为20000, 即(20,20000)的数
	if tbCardPickData.nSpecailCount > CardPicker.Def.nGoldTenSpecialCount
		and tbCardPickData.nSpecailCount < CardPicker.Def.nCurSpecialCountBegin
		then
		bSave = true;
		tbCardPickData.nSpecailCount = CardPicker.Def.nCurSpecialCountBegin;
	end

	-- 元宝10连则累加次数
	if bGoldTen then
		bSave = true;
		tbCardPickData.nSpecailCount = tbCardPickData.nSpecailCount + 1;
	end

	-- 抽中 特殊同伴后， 将次数清为20000
	for nIdx, tbItem in ipairs(tbItems) do
		if IsPartnerSpecial(tbItem) then
			bSave = true;
			tbCardPickData.nSpecailCount = CardPicker.Def.nCurSpecialCountBegin;
		end
	end

	-- 潜规则之 每20次10连必出 特殊同伴。由于历史原因，第20次，第21次，20020次必出
	if bGoldTen then
		if tbCardPickData.nSpecailCount == CardPicker.Def.nGoldTenSpecialCount
			or tbCardPickData.nSpecailCount >= (CardPicker.Def.nGoldTenSpecialCount + CardPicker.Def.nCurSpecialCountBegin)
			or tbCardPickData.nSpecailCount == (CardPicker.Def.nGoldTenSpecialCount + 1)
			then
			tbCardPickData.nSpecailCount = CardPicker.Def.nCurSpecialCountBegin;
			for nIdx, tbItem in ipairs(tbItems) do
				if tbItem.szItemType == "Partner" and IsPartnerSPlus(tbItem) then
					tbItems[nIdx] = CardPicker.Def.tbSpecialTenGoldSPartner;
					break;
				end
			end
		end
	end

--[[-- 潜规则之 前三次S级不重复 -- 去掉此规则，新规则包含之
	local tbSPartnerCache = tbCardPickData.tbSPartnerCache;
	if Lib:CountTB(tbSPartnerCache) < 3 then
		for nIdx, tbItem in ipairs(tbItems) do
			if Lib:CountTB(tbSPartnerCache) >= 3 then
				break;
			end

			if tbItem.szItemType == "Partner" and IsPartnerSPlus(tbItem.nItemId) then
				if tbSPartnerCache[tbItem.nItemId] then
					tbItems[nIdx] = CardPicker:GetFilteredPartnerSItem("Gold", tbSPartnerCache, pPlayer);
					bSave = true;
				end

				tbSPartnerCache[tbItems[nIdx].nItemId] = true;
			end
		end
	end
--]]
	if bSave then
		CardPicker:SaveCardPickerData(pPlayer, tbCardPickData);
	end

	local bHasSSPlus = false;
	for nIdx, tbItem in pairs(tbItems) do
		if tbItem.szItemType == "Partner" and IsPartnerSSPlus(tbItem) then
			bHasSSPlus = true;
			break;
		end
	end

	tbItems = CardPicker:DealWithSpecialCardReplaceAct(tbItems);

	return tbItems, bHasSSPlus;
end

function CardPicker:GetSpecialCardScheduleData()
	return ScriptData:GetValue("CardPickSchedule");
end

function CardPicker:UpdateSpecialCardSchedule()
	local tbSchedule = self:GetSpecialCardScheduleData();
	local nToday = Lib:GetLocalDay();
	if tbSchedule[nToday] then
		return;
	end

	local tbNewSchedule = {};
	local tbSpecialCards = CardPicker:GetCurTimeFramsSpecialCards() or {};
	for nIdx, nPartnerId in ipairs(tbSpecialCards) do
		tbNewSchedule[nToday + nIdx - 1] = nPartnerId;
	end

	ScriptData:SaveAtOnce("CardPickSchedule", tbNewSchedule);
	self:SendSpecialPartnerNewInformation();
end

function CardPicker:SendSpecialPartnerNewInformation()
	local szTitle = "絕世名俠現江湖";
	local tbContent = {"    如今江湖風起雲湧，諸多握有一技之長的俠士、武者、名姬現身江湖，據惜花老闆娘的情報，他們會在以下時日出現于隱香樓，還望諸位俠士把握時機，前去進行[00FF00][url=openwnd:元寶招募, Partner, \"CardPickingPanel\"][-]，將之納入麾下。\n    [FFFE0D]注：以下特定日期進行[url=openwnd:元寶招募, Partner, \"CardPickingPanel\"]將有概率獲得特定SS級同伴[-]"};
	local szPartnerFormate = "\n    [FFFE0D]%s[-]    SS級同伴[FFFE0D][url=openwnd:%s, PartnerDetail, nil, nil, nil, %d][-] "

	if version_tx then
		tbContent = {"    如今江湖風起雲湧，諸多握有一技之長的俠士、武者、名姬現身江湖，據惜花老闆娘的情報，他們會在以下時日出現于隱香樓，還望諸位俠士把握時機，前去進行[00FF00][url=openwnd:元寶招募, Partner, \"CardPickingPanel\"][-]，將之納入麾下。\n    [FFFE0D]注：以下特定日期進行[url=openwnd:元寶招募, Partner, \"CardPickingPanel\"]將有機率獲得特定SS級同伴[-]"};
		szPartnerFormate = "\n    [FFFE0D]%s[-]    SS級同伴[FFFE0D][url=openwnd:%s, PartnerDetail, nil, nil, nil, %d][-] "	
	end

	local tbSchedule = self:GetSpecialCardScheduleData();
	local nToday = Lib:GetLocalDay();
	local nNewInfoTimeout = 0;

	for nIdx = nToday, (nToday + 99999) do
		local nPartnerId = tbSchedule[nIdx];
		if not nPartnerId then
			break;
		end

		local nDayTime = Lib:GetTimeByLocalDay(nIdx);
		nNewInfoTimeout = nDayTime;

		local szDate = Lib:TimeDesc11(nDayTime);
		local szPartnerName = GetOnePartnerBaseInfo(nPartnerId);
		table.insert(tbContent, string.format(szPartnerFormate, szDate, szPartnerName, nPartnerId));
	end

	if nNewInfoTimeout == 0 then
		return;
	end

	local szContent = table.concat(tbContent, "\n");
	nNewInfoTimeout = nNewInfoTimeout + 24 * 3600;
	NewInformation:AddInfomation("CardPickSchedule", nNewInfoTimeout, {szContent}, { szTitle = szTitle});
end

function CardPicker:GetCurSpecialCard()
	local tbReplaceCard = CardPicker:GetSpecialReplaceCard();
	if tbReplaceCard then
		return tbReplaceCard;
	end

	local tbSchedule = self:GetSpecialCardScheduleData();
	local nToday = Lib:GetLocalDay();
	local nPartnerId = tbSchedule[nToday];
	if nPartnerId then
		return {
			szItemType = "Partner",
			nItemId = nPartnerId,
			nCount = 1,
		};
	end
end

function CardPicker:DealWithSpecialCardReplaceAct(tbItems)
	local tbReplaceCard = CardPicker:GetCurSpecialCard();
	if not tbReplaceCard then
		return tbItems;
	end

	for nIdx, tbItem in ipairs(tbItems) do
		if IsPartnerSpecial(tbItem) then
			tbItems[nIdx] = tbReplaceCard;
			-- break;
		end
	end
	return tbItems;
end

function CardPicker:UpdateFreeTimeData()
	CardPicker:GetCardPickerData(me);
	return true;
end

function CardPicker:UpdateFreeInfo(pPlayer)
	pPlayer = pPlayer or me;
	local tbCardPickData = CardPicker:GetCardPickerData(pPlayer);
	local nNow = GetTime();
	local bSave = false;
	local nLeftFreeCoinTime = tbCardPickData.nNextCoinFreePickTime - nNow;
	local nFreeCoinCd = CardPicker:GetFreeCoinCDTime();
	-- 免费抽卡时间可能动态变化，登入时检查如果当前cd时间大于最大cd时间则设为当前cd时间
	if nLeftFreeCoinTime > nFreeCoinCd then
		bSave = true;
		tbCardPickData.nNextCoinFreePickTime = nNow + nFreeCoinCd;
	end

	local nLeftFreeGoldTime = tbCardPickData.nNextGoldFreePickTime - nNow;
	local nFreeGoldCd = CardPicker:GetFreeGoldCDTime();
	if nLeftFreeGoldTime > nFreeGoldCd then
		bSave = true;
		tbCardPickData.nNextGoldFreePickTime = nNow + nFreeGoldCd;
	end

	if bSave then
		CardPicker:SaveCardPickerData(pPlayer, tbCardPickData);
	end
	return true;
end

function CardPicker:UpdateCardPickInfo()
	self:UpdateFreeInfo(me);
	local nRealCost, nOnSaleFlag = CardPicker:GetGoldTenCostInfo(me);
	local tbSpecialPartner = CardPicker:GetCurSpecialCard();
	me.CallClientScript("CardPicker:OnSyncGoldTenInfo", nRealCost, nOnSaleFlag, tbSpecialPartner);
	return true;
end

CardPicker.tbLastestCardPickHistory = CardPicker.tbLastestCardPickHistory or {};
CardPicker.nMaxLastestCardPickHistory = 50;

CardPicker.tbTXCardPickDayLimitMap = CardPicker.tbTXCardPickDayLimitMap or {};
CardPicker.nTXCardPickDayLimitCount = 40;

function CardPicker:RecordCardPickInfo(pPlayer, szPickType, tbItems)
	for _, tbItem in ipairs(tbItems) do
		if tbItem.szItemType == "Partner" then
			if #CardPicker.tbLastestCardPickHistory >= CardPicker.nMaxLastestCardPickHistory then
				table.remove(CardPicker.tbLastestCardPickHistory);
			end
			table.insert(CardPicker.tbLastestCardPickHistory, 1, {pPlayer.szName, szPickType, tbItem.nItemId});
		end
	end

	if version_tx then
		local nPlayerId = pPlayer.dwID;
		local nToday = Lib:GetLocalDay();
		if self.tbTXCardPickDayLimitMap.nRecardDay ~= nToday then
			self.tbTXCardPickDayLimitMap = {};
			self.tbTXCardPickDayLimitMap.nRecardDay = nToday;
		end

		self.tbTXCardPickDayLimitMap[nPlayerId] = self.tbTXCardPickDayLimitMap[nPlayerId] or {};
		self.tbTXCardPickDayLimitMap[nPlayerId][szPickType] = self.tbTXCardPickDayLimitMap[nPlayerId][szPickType] or 0;
		self.tbTXCardPickDayLimitMap[nPlayerId][szPickType] = self.tbTXCardPickDayLimitMap[nPlayerId][szPickType] + 1;
	end
end

function CardPicker:CheckCardPickCount(nPlayerId, szRequestType)
	if not version_tx then
		return true;
	end

	local nToday = Lib:GetLocalDay();
	if self.tbTXCardPickDayLimitMap.nRecardDay ~= nToday then
		self.tbTXCardPickDayLimitMap = {};
		self.tbTXCardPickDayLimitMap.nRecardDay = nToday;
	end

	if self.tbTXCardPickDayLimitMap[nPlayerId] 
		and self.tbTXCardPickDayLimitMap[nPlayerId][szRequestType]
		and self.tbTXCardPickDayLimitMap[nPlayerId][szRequestType] >= CardPicker.nTXCardPickDayLimitCount
		then
		return false;
	end
	return true;
end

function CardPicker:Ask4CardPickHistory()
	me.CallClientScript("CardPicker:OnSyncPickHistory", self.tbLastestCardPickHistory);
end

local PickerInterface = {
	CoinPick = true;
	CoinTenPick = true;
	CoinFreePick = true;
	GoldPick = true;
	GoldTenPick = true;
	GoldFreePick = true;
	UpdateFreeTimeData = true;
	UpdateCardPickInfo = true;
	Ask4CardPickHistory = true;
};

function CardPicker:ClientRequest(szRequestType, ...)
	if not CardPicker:CheckCardPickCount(me.dwID, szRequestType) then
		me.CallClientScript("CardPicker:OnCardPickFail", "今日已達招募次數上限，請少俠明日再來！");
		return;
	end

	if PickerInterface[szRequestType] then
		local bSuccess, szInfo = CardPicker[szRequestType](CardPicker, ...);
		if not bSuccess then
			me.CenterMsg(szInfo);
		end
	else
		Log("WRONG CardPicker Request:", szRequestType, ...);
	end
end

function CardPicker:CheckIsOpen()
	return me.nLevel >=CardPicker.Def.OpenLevel;
end

function CardPicker:OnFinishPersonalFuben(nFubenIndex, nFubenLevel, nStarLevel)
	local nSectionIdx, nSubSectionIdx = PersonalFuben:GetSectionIdx(nFubenIndex, nFubenLevel);
	if nFubenLevel == CardPicker.Def.nGoldPickResetFubenLevel
		and nSectionIdx == CardPicker.Def.nGoldPickResetSectionIdx
		and nSubSectionIdx == CardPicker.Def.nGoldPickResetSubSectionIdx
		then
		local tbCardPickData = CardPicker:GetCardPickerData(me);
		if tbCardPickData.nGoldPickCount == 0 then
			tbCardPickData.nNextGoldFreePickTime = GetTime();
			CardPicker:SaveCardPickerData(me, tbCardPickData);
		end
	end

	if nFubenLevel == CardPicker.Def.nCoinPickResetFubenLevel
		and nSectionIdx == CardPicker.Def.nCoinPickResetSectionIdx
		and nSubSectionIdx == CardPicker.Def.nCoinPickResetSubSectionIdx
		then
		local tbCardPickData = CardPicker:GetCardPickerData(me);
		if tbCardPickData.nCoinPickCount == 0 then
			tbCardPickData.nNextCoinFreePickTime = GetTime();
			CardPicker:SaveCardPickerData(me, tbCardPickData);
		end
	end
end

PlayerEvent:RegisterGlobal("OnFinishPersonalFuben",CardPicker.OnFinishPersonalFuben, CardPicker);

function CardPicker:OnLogin(pPlayer)
	self:UpdateFreeInfo(pPlayer);
end
