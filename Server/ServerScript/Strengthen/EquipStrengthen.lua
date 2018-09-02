
function Strengthen:OnStrengthen(pPlayer, nEquipId, nEquipPos)
	local pEquip = pPlayer.GetItemInBag(nEquipId);
	if not pEquip then
		pPlayer.CenterMsg("裝備不存在");
		return;
	end

	local bRet, szInfo, tbTotalStone, nCombineCost = self:CanStrengthen(pPlayer, nEquipPos, pEquip.nLevel);
	if not bRet then
		pPlayer.CallClientScript("Strengthen:OnResponse", false, szInfo);
		return;
	end

	local nStrenLevel 	= self:GetStrengthenLevel(pPlayer, nEquipPos);
	local tbSetting 	= self:GetStrenSetting(nStrenLevel);
	local szPrefix 		= self.tbPosPrefixName[nEquipPos]

	local bNeedBreakThrough = self:IsNeedBreakThrough(pPlayer, nEquipPos)
	local nConsumeId, nLogWay,nNeedNum;
	if bNeedBreakThrough then
		nConsumeId 	= KItem.GetTemplateByKind(tbSetting.BreakItem);
		nNeedNum = tbSetting["BreakCount" .. szPrefix]
		nLogWay = Env.LogWay_StrengthenBreak
	else
		nConsumeId  = KItem.GetTemplateByKind(tbSetting.ConsumeItem);
		nNeedNum = tbSetting["ConsumeCount" .. szPrefix]
		nLogWay = Env.LogWay_DoStrengthen
		local nCoin = self:GetStrengthenCost(nStrenLevel, nEquipPos);
		if not pPlayer.CostMoney("Coin", nCoin, Env.LogWay_Strengthen) then
			pPlayer.CenterMsg("銀兩不足")
			return
		end
	end

	local nConsumeIdTotolValue = 0;
	if tbTotalStone then --应该是消耗背包里所有的
		local nHasCount = pPlayer.GetItemCountInAllPos(nConsumeId)
		if nHasCount >= nNeedNum then
			Log(debug.traceback())
			return
		end
		if  not pPlayer.CostMoney("Coin", nCombineCost, Env.LogWay_StoneCombine) then
			pPlayer.CenterMsg("銀兩不足")
			return
		end
		pPlayer.ConsumeItemInAllPos(nConsumeId, nHasCount, nLogWay);
		local tbBaseInfo = KItem.GetItemBaseProp(nConsumeId);

		if not version_tx then
			nConsumeIdTotolValue = 	nConsumeIdTotolValue + tbBaseInfo.nValue * nHasCount
		end

		for i,v in ipairs(tbTotalStone) do
			if not version_tx then
				local tbBaseInfoSub = KItem.GetItemBaseProp(v[1]);
				nConsumeIdTotolValue = 	nConsumeIdTotolValue + tbBaseInfoSub.nValue * v[2]
			end			
			if not pPlayer.ConsumeItemInAllPos(v[1], v[2], nLogWay) then
				Log("StoneMgr:OnStrengthen break del Stone Miss ", v[1], v[2], pPlayer.dwID)
				return
			end
		end
		
		pPlayer.CenterMsg(string.format("自動合成了%d個%s", nNeedNum - nHasCount, tbBaseInfo.szName), true)

	else
		if not version_tx then
			local tbBaseInfo = KItem.GetItemBaseProp(nConsumeId);
			nConsumeIdTotolValue = 	nConsumeIdTotolValue + tbBaseInfo.nValue * nNeedNum
		end
		pPlayer.ConsumeItemInAllPos(nConsumeId, nNeedNum, nLogWay);
	end

	--突破
	if bNeedBreakThrough then
		local nBreakCount = self:GetPlayerBreakCount(pPlayer, nEquipPos);
		self:SetPlayerBreakCount(pPlayer, nEquipPos, nBreakCount + 1)
		pPlayer.CallClientScript("Strengthen:OnResponse", true, "突破成功");

	else
		--强化
		local nToday = Lib:GetLocalDay()
		if nToday ~= pPlayer.GetUserValue(self.USER_VALUE_GROUP, self.SAVE_KEY_LAST_ENHANCE_DAY) then
			for i = Item.EQUIPPOS_HEAD,Item.EQUIPPOS_PENDANT do
				pPlayer.SetUserValue(self.USER_VALUE_GROUP, self.SAVE_KEY_ENHANCE_COUNT_FROM + i, 0)
			end
		end
		pPlayer.SetUserValue(self.USER_VALUE_GROUP, self.SAVE_KEY_LAST_ENHANCE_DAY, nToday)
		pPlayer.SetUserValue(self.USER_VALUE_GROUP, self.SAVE_KEY_ENHANCE_COUNT_FROM + nEquipPos, pPlayer.GetUserValue(self.USER_VALUE_GROUP, self.SAVE_KEY_ENHANCE_COUNT_FROM + nEquipPos) + 1)
		
		local nFailTime = self:GetStrengthenFailTimes(pPlayer, nEquipPos)

		local nProbility = self:GetStrengthenProb(tbSetting.Probility, nFailTime, nStrenLevel)
		local bFail = nProbility < MathRandom(0, 999)
		if not bFail then
			if not version_tx then
				local nRewardValueDebt = Player:GetRewardValueDebt(pPlayer.dwID);
				if nRewardValueDebt > 0 and  nProbility < 800 then
					assert(nConsumeIdTotolValue > 0)
					bFail = true
					local fnParams = nStrenLevel < 100 and 0.9 or 0.8
					local nPoint = math.floor( nConsumeIdTotolValue * fnParams / 1000)
					Player:CostRewardValueDebt(pPlayer.dwID, nPoint, Env.LogWay_Strengthen, nProbility)
					Log("Strengthen:OnStrengthen CostValueDebt", pPlayer.dwID, nRewardValueDebt, nPoint, Player:GetRewardValueDebt(pPlayer.dwID))
				end
			end
		end

		if bFail then
			self:SetStrengthenFailTimes(pPlayer, nEquipPos, nFailTime + 1)
			pPlayer.CallClientScript("Strengthen:OnResponse", false, "強化失敗");
			pPlayer.nEnhanceFailTime = (pPlayer.nEnhanceFailTime or 0) + 1
			if pPlayer.nEnhanceFailTime == 3 then
				Achievement:AddCount(pPlayer, "EnhanceFailure_1", 1);
			end
			return false;
		end

		if nFailTime ~= 0 then
			self:SetStrengthenFailTimes(pPlayer, nEquipPos, 0)
		end

		pPlayer.nEnhanceFailTime = nil;

		self:DoStrengthen(pPlayer, nEquipId, nEquipPos, nStrenLevel + 1, true);
	end
end

function Strengthen:DoStrengthen(pPlayer, nEquipId, nEquipPos, nStrenLevel, bNotify)
	local nTotalFightPower = pPlayer.GetFightPower();
	if not pPlayer.SetStrengthen(nEquipPos, nStrenLevel) then
		Log("Strengthen:DoStrengthen Faild!!!", pPlayer.dwID, nEquipId, nEquipPos, nStrenLevel)
		return
	end
	pPlayer.SetUserValue(self.USER_VALUE_GROUP, nEquipPos + 1, nStrenLevel)

    local pAsyncData = KPlayer.GetAsyncData(pPlayer.dwID)
    if pAsyncData then
    	pAsyncData.SetEnhance(nEquipPos + 1, nStrenLevel)
    end

	self:UpdateEnhAtrrib(pPlayer);

	FightPower:ChangeFightPower("Strengthen", pPlayer, true);

	local nCurFightPower = pPlayer.GetFightPower();
	--需要延迟到强化成功的动画播出来
	pPlayer.CallClientScript("Strengthen:OnResponse", true, bNotify, nEquipPos, nStrenLevel, nCurFightPower, nTotalFightPower);

	local tbAcheiSet = {
		[1]  = "EnhanceOnce_1",
		[5]  = "EnhanceMaster_1",
		[20] = "EnhanceMaster_2",
		[40] = "EnhanceMaster_3",
		[60] = "EnhanceMaster_4",
		[80] = "EnhanceMaster_5",
		[100] = "EnhanceMaster_6",
	}
	local szAchieve = tbAcheiSet[nStrenLevel];
	if szAchieve then
		Achievement:AddCount(pPlayer, szAchieve, 1);
	end

	EverydayTarget:AddCount(pPlayer, "EquipEnhance");

	pPlayer.TLog("EnhanceFlow", nEquipPos, nStrenLevel)

	Log(string.format("Strengthen:DoStrengthen pPlayer:%d, nEquipId:%d, nEquipPos:%d, nStrenLevel:%d", pPlayer.dwID, nEquipId, nEquipPos, nStrenLevel))
end
