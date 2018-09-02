

local fnInit = function ()
	assert(#Recharge.tbSettingGroup.BuyGold <= 32) --首次购买用的bit标识符
	for i,v in ipairs(Recharge.tbGrowInvestGroup) do
		assert(#v <= 32) --首次购买用的bit标识符
	end
	assert(#Recharge.tbVipAward >= #Recharge.tbVipSetting + 1)
	assert(#Recharge.tbVipDesc >= #Recharge.tbVipSetting + 1)

	--现在的特权礼包最多6个，超了需要改界面为滚动
	for i,v in ipairs(Recharge.tbVipAward) do
		assert(v.nGiveItemId > 0, i)
	end
end
fnInit();

function Recharge:OnTakeCard(pPlayer, nSaveKey1, nSaveKey2, tbAward, nLogWay, nIndex)
	local nToday = Lib:GetLocalDay(GetTime() - 3600 * 4)

	local bTaked = false
	if pPlayer.GetUserValue(self.SAVE_GROUP, nSaveKey1) ~= nToday then
		pPlayer.SetUserValue(self.SAVE_GROUP, nSaveKey1, nToday)
		pPlayer.SendAward(tbAward, true, false, nLogWay)		
		EverydayTarget:AddCount(pPlayer, "RechargeGift");
		bTaked = true
	end

	local tbCardExtPrams = Recharge:IsOnActvityDay()
	if tbCardExtPrams then
		local nExtParam = tbCardExtPrams[nIndex]
		if nExtParam and pPlayer.GetUserValue(Recharge.SaveGroupActiviy, nSaveKey2) ~= nToday then
			pPlayer.SetUserValue(Recharge.SaveGroupActiviy, nSaveKey2, nToday)
			local nGiveGold = math.floor(tbAward[1][2] * nExtParam / 100)
			pPlayer.AddMoney("Gold", nGiveGold , Env.LogWay_ActivyRechargeCard)
			local MonyszName, szMoneyEmotion = Shop:GetMoneyName("Gold");
			pPlayer.CenterMsg(string.format("元寶大禮活動額外領取%s%s%s", MonyszName, szMoneyEmotion, nGiveGold) , true)
			bTaked = true		
		end
	end

	if bTaked then
		pPlayer.CallClientScript("Recharge:OnTakeCardAwardScuess")
		Lottery:SendTicket(pPlayer, (nIndex == 1 and "Weekly" or "Monthly"));
	end
end

function Recharge:TakeMonthCardAward(pPlayer)
	local nIndex = 2
	local nLeftAwardDay = Recharge:GetDaysCardLeftDay(pPlayer, nIndex)
	if nLeftAwardDay <= 0 then
		return
	end
	local tbAward = Recharge:GetMonthCardAward()
	self:OnTakeCard(pPlayer, self.KEY_TAKE_MON, Recharge.SaveKeyActiviyMon, tbAward, Env.LogWay_TakeMonthCardAward, nIndex)
end

function Recharge:TakeWeekMonthCardAward(pPlayer)
	local nIndex = 1
	local nLeftAwardDay = Recharge:GetDaysCardLeftDay(pPlayer, 1)
	if nLeftAwardDay <= 0 then
		return
	end

	local tbAward = Recharge:GetWeekCardAward()
	self:OnTakeCard(pPlayer, self.KEY_TAKE_WEEK, Recharge.SaveKeyActiviyWeek, tbAward, Env.LogWay_TakeWeekCardAward, nIndex)
end


--购买vip特权礼包
function Recharge:BuyVipAward(pPlayer, nBuyLevel)
	local tbInfo = self.tbVipAward[nBuyLevel + 1]
	if not tbInfo then
		return
	end
	if pPlayer.GetMoney("Gold") < tbInfo.nRealPrice then
		pPlayer.CenterMsg("元寶不足")
		return
	end

	local nCurLevel = pPlayer.GetVipLevel()
	if nCurLevel < nBuyLevel then
		pPlayer.CenterMsg("【劍俠V】特權等級不夠")
		return
	end

	--已买过的也不能
	local nBuyedVal = pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_VIP_AWARD)
	local nBuydeBit = KLib.GetBit(nBuyedVal, nBuyLevel + 1)
	if nBuydeBit == 1 then
		pPlayer.CenterMsg("您已經買過該禮包了")
		return
	end

	pPlayer.CostGold(tbInfo.nRealPrice, Env.LogWay_BuyVipAward, nil, function (nPlayerId, bSucceed)
		if not bSucceed then
			return false
		end
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
		if not pPlayer then
			return false
		end 
		local nBuyedVal = pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_VIP_AWARD)
		local nBuydeBit = KLib.GetBit(nBuyedVal, nBuyLevel + 1)
		if nBuydeBit == 1 then
			return false, "數據超時"
		end

		local nNewVal = KLib.SetBit(nBuyedVal, nBuyLevel + 1, 1)
		pPlayer.SetUserValue(self.SAVE_GROUP, self.KEY_VIP_AWARD, nNewVal)

		local nBuyedValEx = pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_VIP_AWARD_EX)
		local nNewValEx = KLib.SetBit(nBuyedValEx, nBuyLevel + 1, 1)
		pPlayer.SetUserValue(self.SAVE_GROUP, self.KEY_VIP_AWARD_EX, nNewValEx)

		local nTakeKey = Recharge.tbVipAwardTakeTimeKey[nBuyLevel]
		if nTakeKey then
			pPlayer.SetUserValue(self.SAVE_GROUP, nTakeKey, GetTime())	
		end

		pPlayer.AddItem(tbInfo.nGiveItemId, 1, nil, Env.LogWay_BuyVipAward, 0, tbInfo.nRealPrice, Shop.tbMoney["Gold"]["SaveKey"])

		pPlayer.CallClientScript("Recharge:OnBuyVipAwardScucess")	
		return true
	end)
end


--这个leftday 是包括今天的，就是即使是月卡的最后一天，那么返回的也是1
function Recharge:TakeGrowInvestAward(pPlayer, nIndex, nGroupIndex)
	if not self.IS_OPEN_INVEST then
		pPlayer.CenterMsg("很抱歉一本萬利功能暫時關閉了")
		return
	end
	local tbGrowInvestSetting = self.tbGrowInvestGroup[nGroupIndex]
	if not tbGrowInvestSetting then
		return
	end

	if pPlayer.GetUserValue(self.SAVE_GROUP, self.tbKeyGrowBuyed[nGroupIndex]) == 0 then
		return
	end

	local tbInfo = tbGrowInvestSetting[nIndex]
	if not tbInfo then
		return
	end

	if pPlayer.nLevel < tbInfo.nLevel then
		return
	end

	local nKeyTaked = self.tbKeyGrowTaked[nGroupIndex]
	local nTaked = pPlayer.GetUserValue(self.SAVE_GROUP, nKeyTaked)
	local nTakeeBit = KLib.GetBit(nTaked, nIndex)
	if nTakeeBit ~= 0 then
		pPlayer.CenterMsg("您已經領取過了")
		return
	end

	if tbInfo.nDay then
		local nShowTakeDay = Recharge:GetActGrowInvestTakeDay(pPlayer, nGroupIndex)
		if nShowTakeDay ~= nIndex then
			pPlayer.CenterMsg("錯誤的領取天數")
			return
		end
		local nSaveKey = self:GetDayInvestTaskedDayKey(nGroupIndex)
		if not nSaveKey then
			Log("Recharge TakeGrowInvestAward Err", pPlayer.dwID, nGroupIndex, nIndex)
			return
		end
		local nDay = Recharge:GetRefreshDay()
		if pPlayer.GetUserValue(self.SAVE_GROUP, nSaveKey) == nDay then
			pPlayer.CenterMsg("您今天已經領取過了")
			return
		end
		pPlayer.SetUserValue(self.SAVE_GROUP, nSaveKey, nDay)
	end

	nTaked = KLib.SetBit(nTaked, nIndex, 1)
	pPlayer.SetUserValue(self.SAVE_GROUP, nKeyTaked, nTaked)

	pPlayer.SendAward({{"Gold", tbInfo.nAwardGold}}, true, false, Env.LogWay_GrowInvestAward, nGroupIndex*1000+nIndex)
	Log("Recharge:TakeGrowInvestAward", pPlayer.dwID, tbInfo.nAwardGold, nIndex)

	
	pPlayer.CallClientScript("Recharge:OnTakedGrowInvestAward")
end

function Recharge:GetRechargeParts(nRechareRMB) --累计过来的值，返回应该是几个和起来的
	local tbBuyGoldGroup = Recharge.tbSettingGroup.BuyGold
	local tbRes = {}
	for j=1,1000 do
		local bFound = false
		for i=#tbBuyGoldGroup, 1, -1 do
			local v = tbBuyGoldGroup[i]
			if nRechareRMB >= v.nMoney then
				nRechareRMB = nRechareRMB - v.nMoney
				table.insert(tbRes, {v.nMoney, i})
				bFound = true
				break;
			end
		end	
		if nRechareRMB == 0 or not bFound then
			break;
		end
	end
	
	if nRechareRMB > 0 then
		table.insert(tbRes, {nRechareRMB, 0})
	end
	return tbRes
end


function Recharge:OnTotalRechargeChange(pPlayer, nGoldRMB, nCardRMB)
	local dwRoleId = pPlayer.dwID
	if not nGoldRMB and not nCardRMB then
		Log(dwRoleId, debug.traceback())
		return 
	end
	if nGoldRMB and nGoldRMB < 0 then
		Log(dwRoleId, nGoldRMB, debug.traceback())
		return
	end
	if nCardRMB and nCardRMB < 0 then
		Log(dwRoleId, nCardRMB, debug.traceback())
		return
	end

	local nOldGoldRMB = self:GetTotoalRechargeGold(pPlayer)
	local nOldCardRMB = pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_TOTAL_CARD)
	local nRechareGold, nRechareCard = 0, 0;

	local bCheckFirstRecharge = true;
	if nCardRMB then
		nRechareCard = nCardRMB - nOldCardRMB
		if nRechareCard == 100 or nRechareCard == 300 or nRechareCard == 600 then
			bCheckFirstRecharge = false;
		end
	end
	if bCheckFirstRecharge then --1元礼包不计入首冲
		if pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_GET_FIRST_RECHARGE) ~= 1 then
			local tbFirstAward = self:GetFirstChargeAward(pPlayer)

			pPlayer.SetUserValue(self.SAVE_GROUP, self.KEY_GET_FIRST_RECHARGE, 1) 
			pPlayer.SendAward(tbFirstAward, nil, nil, Env.LogWay_FirstRechargeAward)

			Log("FirstCharge Award", dwRoleId, nGoldRMB, nCardRMB)

			Kin:RedBagOnEvent(pPlayer, Kin.tbRedBagEvents.charge_count, 1)	
		end		
	end

	if nGoldRMB then
		nRechareGold = nGoldRMB - nOldGoldRMB
		if nRechareGold > 0 and nOldGoldRMB >= 0 then
			self:SetTotoalRechargeGold(pPlayer, nGoldRMB)
			local nNow = GetTime()
			local tbRechargeRMBs = self:GetRechargeParts(nRechareGold)
			local nBuyedFlag = Recharge:GetBuyedFlag(pPlayer);
			local tbBit = KLib.GetBitTB(nBuyedFlag)
			local tbAward = {};
			local tbBuyGoldGroup = Recharge.tbSettingGroup.BuyGold
			for _, tbRMB in ipairs(tbRechargeRMBs) do
				local nRMB, nIndex = unpack(tbRMB)
				local v = tbBuyGoldGroup[nIndex]
				if v then
					if tbBit[v.nGroupIndex] == 0 then
						Lib:MergeTable(tbAward, v.tbFirstAward)
						nBuyedFlag = KLib.SetBit(nBuyedFlag, v.nGroupIndex, 1)
						tbBit[v.nGroupIndex] = 1;
						pPlayer.SetUserValue(self.SAVE_GROUP, self.KEY_BUYED_FLAG, nBuyedFlag)	
						
					else
						Lib:MergeTable(tbAward, v.tbAward)
					end
					Activity:OnPlayerEvent(pPlayer, "Act_OnRechargeGold", nRMB)
				else
					Log("ERROR Recharge:UnkwonOnTotalRechargeChange",pPlayer.dwID, nRMB, nRechareGold, nGoldRMB)
				end
			end

			if next(tbAward)  then
				pPlayer.SendAward(tbAward, true, false, Env.LogWay_Recharge)
				pPlayer.CallClientScript("Recharge:OnRechargeGoldScucess", nRechareGold, tbAward)
			end
		else
			Log(pPlayer.dwID, nGoldRMB, nCardRMB, debug.traceback())
		end
	end
	if nCardRMB then
		pPlayer.SetUserValue(self.SAVE_GROUP, self.KEY_TOTAL_CARD, nCardRMB)
	end

	local nNewVipLevel = self:CheckVipLevelChange(pPlayer, nRechareGold, nRechareCard)
	
	pPlayer.SavePlayer();
	
	local nRechareRMB = nRechareGold + nRechareCard
	local nTotalCharge = nOldGoldRMB + nOldCardRMB + nRechareRMB
		
	local nChargeGold = Recharge:GetRechareRMBToGold(nRechareRMB)
	
	Kin:OnMemberCharge(pPlayer, nChargeGold)
	pPlayer.TLog("RechargeFlow", pPlayer.szIP, nRechareRMB, nTotalCharge, nNewVipLevel)
	Log("Recharge OnTotalRechargeChange", pPlayer.dwID, nGoldRMB, nCardRMB, nChargeGold)

	Activity:OnPlayerEvent(pPlayer, "OnRecharge", nRechareGold, nRechareCard, Recharge:GetActRechareRMBToGold(nRechareRMB))

	AssistClient:ReportQQScore(pPlayer, Env.QQReport_RechargeTotalCount, nTotalCharge / 100, 0, 1)
	AssistClient:ReportQQScore(pPlayer, Env.QQReport_RechargeSingleCount, nRechareRMB / 100, 0, 1) 
	AssistClient:ReportQQScore(pPlayer, Env.QQReport_RechargeTime, GetTime(), 0, 1) 
end

function Recharge:CheckVipLevelChange(pPlayer, nRechareGold, nRechareCard)
	local pAsync = KPlayer.GetAsyncData(pPlayer.dwID)
	if not pAsync then
		Log(pPlayer.dwID, debug.traceback())
		return
	end

	local nOldVipLevel = pAsync.GetVipLevel();
	local nNewVipLevel = pPlayer.GetVipLevel(true)
	pPlayer.TLog("VipLevelFlow", pPlayer.nLevel, nOldVipLevel, nNewVipLevel, nRechareGold, nRechareCard,
		 self:GetTotoalRechargeGold(pPlayer), pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_TOTAL_CARD));

	if nNewVipLevel > nOldVipLevel then
		pAsync.SetVipLevel(nNewVipLevel)

		pPlayer.CallClientScript("Recharge:OnNewVipLevel", nNewVipLevel)

		if  self.VIP_SHOW_LEVEL[nOldVipLevel] ~= self.VIP_SHOW_LEVEL[nNewVipLevel] then
			--更新显示其好友和家族数据 vip特效标识显示
			if pPlayer.dwKinId ~= 0 then
				Kin:UpdateKinMemberInfo(pPlayer.dwKinId)
			end
		end
		Kin:RedBagOnEvent(pPlayer, Kin.tbRedBagEvents.vip_level, nNewVipLevel)

		if nNewVipLevel>=6 then
			TeacherStudent:TargetAddCount(pPlayer, "Vip6", 1)
		end
		pPlayer.OnEvent("OnVipChanged", nNewVipLevel, nOldVipLevel);
		Activity:OnPlayerEvent(pPlayer, "Act_VipChanged", nOldVipLevel, nNewVipLevel)
		AssistClient:ReportQQScore(pPlayer, Env.QQReport_VipLevel, nNewVipLevel, 0, 1)
		Lottery:OnVipChanged(pPlayer);
	end
	return nNewVipLevel
end


function Recharge:OnBuyDaysCardCallBack(pPlayer, nEndTime, nGroupIndex)
	local tbBuyInfo = Recharge.tbSettingGroup.DaysCard[nGroupIndex]
	local nLocalEndTime = pPlayer.GetUserValue(self.SAVE_GROUP, tbBuyInfo.nEndTimeKey)
	if nEndTime ~= nLocalEndTime then
		if nLocalEndTime ~= 0 and math.ceil((nEndTime - nLocalEndTime) / 3600 / 24) < tbBuyInfo.nLastingDay then
			Log("Recharge:OnBuyDaysCardCallBack ERROR",  pPlayer.dwID, nEndTime, nLocalEndTime, nGroupIndex)
		end
		if Recharge:GetDaysCardLeftDay(pPlayer, nGroupIndex) > Recharge.tbDaysCardBuyLimitDay[nGroupIndex] then
			Log(pPlayer.dwID, debug.traceback())
		end
		pPlayer.SetUserValue(self.SAVE_GROUP, tbBuyInfo.nEndTimeKey, nEndTime)
		local nCostMoney = tbBuyInfo.nMoney
		if tbBuyInfo.tbAward then
			pPlayer.SendAward(tbBuyInfo.tbAward, true, nil, (nGroupIndex == 1 and Env.LogWay_BuyWeekCard or Env.LogWay_BuyMonthCard))	
		end
		
		self:AddTotalCardRecharge(pPlayer, nCostMoney)

		pPlayer.CallClientScript("Recharge:BuyCardScucess")
		Log("Recharge:Sucess DaysCard ", nGroupIndex, pPlayer.dwID)

		Kin:RedBagOnEvent(pPlayer, (nGroupIndex == 1 and Kin.tbRedBagEvents.buy_weekly_gift or Kin.tbRedBagEvents.buy_monthly_gift) )
		TeacherStudent:TargetAddCount(pPlayer, (nGroupIndex==1 and "Buy7DaysGift" or "Buy30DaysGift"), 1)

		Activity:OnPlayerEvent(pPlayer, "Act_BuyDaysCard", nGroupIndex)

		Lottery:OnBuyDaysCard(pPlayer, nGroupIndex);
	end
end

function Recharge:OnBuyOneDayCardCallBack(pPlayer, nEndTime, nGroupIndex)
	local tbBuyInfo = self.tbSettingGroup.DayGift[nGroupIndex]

	local nLocalEndTime = pPlayer.GetUserValue(self.SAVE_GROUP, tbBuyInfo.nEndTimeKey)
	if nEndTime ~= nLocalEndTime then
		if nLocalEndTime ~= 0 and (nEndTime - nLocalEndTime) < 3600 * 24 then
			Log("Recharge:OnBuyOneDayCardCallBack ERROR",  pPlayer.dwID, nEndTime, nLocalEndTime, nGroupIndex)
		end
		
		pPlayer.SetUserValue(self.SAVE_GROUP, tbBuyInfo.nEndTimeKey, nEndTime)
		local nBuyedDay = self:GetRefreshDay()
		local nBuyCount = 1;
		if nEndTime - GetTime() >= 3600 * 36 and nEndTime - nLocalEndTime >=  3600 * 36 then
			nBuyCount = 2;
			nBuyedDay = nBuyedDay + 1
		end
		pPlayer.SetUserValue(self.SAVE_GROUP, tbBuyInfo.nBuyDayKey, nBuyedDay)

		for i = 1, nBuyCount do
			pPlayer.SendAward(tbBuyInfo.tbAward , true, nil, Env.LogWay_OneDayCard, tbBuyInfo.nEndTimeKey)
			self:AddTotalCardRecharge(pPlayer, tbBuyInfo.nMoney)
			Log("Recharge:Sucess BuyDayCard ", pPlayer.dwID, tbBuyInfo.ProductId, nBuyCount)
		end
		self:OnAfterBuyOneDayCard(pPlayer, nGroupIndex, nBuyCount)
	end
end

function Recharge:OnBuyOneDayCardSetCallBack(pPlayer, nEndTime, nGroupIndex)
	local tbBuyInfo = self.tbSettingGroup.DayGiftSet[nGroupIndex]
	local nLocalEndTime = pPlayer.GetUserValue(self.SAVE_GROUP, tbBuyInfo.nEndTimeKey)
	if nEndTime ~= nLocalEndTime then
		if nLocalEndTime ~= 0 and (nEndTime - nLocalEndTime) < 3600 * 24 then
			Log("Recharge:OnBuyOneDayCardSetCallBack ERROR",  pPlayer.dwID, nEndTime, nLocalEndTime, nGroupIndex)
		end
		
		pPlayer.SetUserValue(self.SAVE_GROUP, tbBuyInfo.nEndTimeKey, nEndTime)
		local nBuyedDay = self:GetRefreshDay()
		for i,v in ipairs(self.tbSettingGroup.DayGift) do
			if pPlayer.GetUserValue(self.SAVE_GROUP, v.nBuyDayKey) >= nBuyedDay then
				nBuyedDay = nBuyedDay + 1;
				Log("Recharge BuyDayCardSet hasTodayIndividual", pPlayer.dwID, i)
				break;
			end
		end

		local nBuyCount = 1;
		if nEndTime - GetTime() >= 3600 * 36 and nEndTime - nLocalEndTime >=  3600 * 36 then
			nBuyCount = 2;
			nBuyedDay = nBuyedDay + 1; --最多可能是直接买到后天了
		end
		pPlayer.SetUserValue(self.SAVE_GROUP, tbBuyInfo.nBuyDayKey, nBuyedDay)
		if not tbBuyInfo.tbAward then
			tbBuyInfo.tbAward = {};
			for i,v in ipairs(self.tbSettingGroup.DayGift) do
				for _,v2 in ipairs(v.tbAward) do
					table.insert(tbBuyInfo.tbAward, v2)
				end
			end
		end

		for i = 1, nBuyCount do
			pPlayer.SendAward(tbBuyInfo.tbAward , true, nil, Env.LogWay_OneDayCard, tbBuyInfo.nEndTimeKey)
			self:AddTotalCardRecharge(pPlayer, tbBuyInfo.nMoney)
			Log("Recharge:Sucess BuyDayCard ", pPlayer.dwID, tbBuyInfo.ProductId, nBuyCount,nBuyedDay)
		end
		for i=1,#self.tbSettingGroup.DayGift do
			self:OnAfterBuyOneDayCard(pPlayer, i, nBuyCount)
		end
	end
end

function Recharge:OnBuyOneDayCardPlusCallBack(pPlayer, nEndTime, nGroupIndex)
	local tbBuyInfo = self.tbSettingGroup.DayGiftPlus[nGroupIndex]
	local nLocalEndTime = pPlayer.GetUserValue(self.SAVE_GROUP, tbBuyInfo.nEndTimeKey)
	if nEndTime > nLocalEndTime then
		if nLocalEndTime ~= 0 and math.ceil((nEndTime - nLocalEndTime) / 3600 / 24) < tbBuyInfo.nLastingDay then
			Log("Recharge:OnBuyOneDayCardPlusCallBack ERROR",  pPlayer.dwID, nEndTime, nLocalEndTime, nGroupIndex)
		end
		pPlayer.SetUserValue(self.SAVE_GROUP, tbBuyInfo.nEndTimeKey, nEndTime)

		--这个米大师购买那边限制了不会出现一次性买了多个
		local nOldCount = pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_ONE_DAY_CARD_PLUS_COUNT)
		pPlayer.SetUserValue(self.SAVE_GROUP, self.KEY_ONE_DAY_CARD_PLUS_COUNT, nOldCount + tbBuyInfo.nLastingDay)


		self:AddTotalCardRecharge(pPlayer, tbBuyInfo.nMoney)
		Kin:RedBagOnEvent(pPlayer, Kin.tbRedBagEvents.buy_weekly_suit)
		Log("Recharge:Sucess OnBuyOneDayCardPlusCallBack ", pPlayer.dwID, nEndTime, nGroupIndex)
		pPlayer.CallClientScript("Recharge:BuyCardScucess")
		--对应的购买成功事件都对应领取时了
	end
end

function Recharge:TakeOneDayCardPlusAward(pPlayer)
	local bRet, szMsg, nOldCount = self:CanTakeOneDayCardPlusAward(pPlayer)
	if not bRet or nOldCount < 1 then
		pPlayer.CenterMsg(szMsg, true)
		return
	end
	pPlayer.SetUserValue(self.SAVE_GROUP, self.KEY_ONE_DAY_CARD_PLUS_COUNT, nOldCount - 1)
	pPlayer.SetUserValue(self.SAVE_GROUP, self.KEY_ONE_DAY_CARD_PLUS_DAY, self:GetRefreshDay())

	local tbBuyInfo = self.tbSettingGroup.DayGiftPlus[1]
	if not tbBuyInfo.tbAward then
		tbBuyInfo.tbAward = {};
		for i,v in ipairs(self.tbSettingGroup.DayGift) do
			for _,v2 in ipairs(v.tbAward) do
				table.insert(tbBuyInfo.tbAward, v2)
			end
		end
	end
	pPlayer.SendAward(tbBuyInfo.tbAward , true, nil, Env.LogWay_OneDayCard, tbBuyInfo.nEndTimeKey)
	--算是完成3次每日礼包了
	for i=1,#self.tbSettingGroup.DayGift do
		self:OnAfterBuyOneDayCard(pPlayer, i, 1)
	end
end

function Recharge:OnAfterBuyOneDayCard(pPlayer, nGroupIndex, nBuyCount)
	EverydayTarget:AddCount(pPlayer, "DailyRechargeGift");
	pPlayer.CallClientScript("Recharge:BuyCardScucess")
	TeacherStudent:TargetAddCount(pPlayer, "BuyDailyGift", 1)
	Activity:OnPlayerEvent(pPlayer, "Act_DailyGift", nGroupIndex, nBuyCount)
	Lottery:SendTicket(pPlayer, "Daily" .. nGroupIndex);
end

Recharge.tbYearCardRedBagTypes = {
	-- [1] = Kin.tbRedBagEvents.oneyear4 ,
	-- [2] = Kin.tbRedBagEvents.oneyear3 ,
	-- [3] = Kin.tbRedBagEvents.oneyear2 ,
	-- [4] = Kin.tbRedBagEvents.oneyear1 ,
	[1] = Kin.tbRedBagEvents.summer_gift_4,
	[2] = Kin.tbRedBagEvents.summer_gift_3,
	[3] = Kin.tbRedBagEvents.summer_gift_2,
	[4] = Kin.tbRedBagEvents.summer_gift_1,
}

function Recharge:SetYearGiftAwardKey(szAwardKey)
	self.szYearGiftAwardKey = szAwardKey
	Log("Recharge:SetYearGiftAwardKey", szAwardKey)
end

function Recharge:OnBuyYearCardCallBack(pPlayer, nEndTime, nGroupIndex)
	local tbBuyInfo = self.tbSettingGroup.YearGift[nGroupIndex]
	if not tbBuyInfo then
		return
	end

	local nLocalEndTime = pPlayer.GetUserValue(Recharge.SAVE_GROUP, tbBuyInfo.nEndTimeKey)
	if nEndTime > nLocalEndTime then --新年礼包和半年庆都是用的同一个
		local bRet, szMsg = Recharge:CanBuyYearGift(pPlayer, tbBuyInfo.ProductId)
		
		pPlayer.SetUserValue(Recharge.SAVE_GROUP, tbBuyInfo.nEndTimeKey, nEndTime)
		pPlayer.SetUserValue(Recharge.SAVE_GROUP, tbBuyInfo.nBuyDayKey, Lib:GetLocalDay(GetTime() - 3600 * 4))
		if not bRet then --直接按价格返回对应元宝数 能买失败的也就一个了
			local nGold = Recharge:GetRechareRMBToGold(tbBuyInfo.nMoney)
			pPlayer.SendAward({{"Gold", nGold}} , true, nil, Env.LogWay_NewYearBuyGift, tbBuyInfo.nEndTimeKey)
			pPlayer.CenterMsg(szMsg, true)
			self:AddTotalCardRecharge(pPlayer, tbBuyInfo.nMoney)
			Log("Recharge:OnBuyYearCardCallBack falileConditon", pPlayer.dwID, nGold, nEndTime, nGroupIndex)
		else
			local nBuyCount = 1;
			local tbLimitInfo = self.tbNewYearBuySetting[tbBuyInfo.nGroupIndex]
			if tbLimitInfo.nSaveCountKey and  tbLimitInfo.nBuyCount > 1 then
				if nEndTime - GetTime() >= 3600 * 36 and nEndTime - nLocalEndTime >=  3600 * 36 then
					nBuyCount = 2;
				end
				pPlayer.SetUserValue(self.SAVE_GROUP, tbLimitInfo.nSaveCountKey, (pPlayer.GetUserValue(self.SAVE_GROUP, tbLimitInfo.nSaveCountKey) + nBuyCount))
			end

			for i = 1, nBuyCount do
				pPlayer.SendAward(tbBuyInfo[self.szYearGiftAwardKey], true, nil, Env.LogWay_NewYearBuyGift, tbBuyInfo.nEndTimeKey)
				self:AddTotalCardRecharge(pPlayer, tbBuyInfo.nMoney)
				local nRedBagType = self.tbYearCardRedBagTypes[nGroupIndex]
				if nRedBagType then
					Kin:RedBagOnEvent(pPlayer, nRedBagType)
				end
				Log("Recharge:Sucess OnBuyYearCardCallBack ", pPlayer.dwID, tbBuyInfo.ProductId, nBuyCount)
			end

			if pPlayer.dwKinId ~= 0 then
				local nItemId = tbBuyInfo[self.szYearGiftAwardKey][1][2]
				local tbItemBase = KItem.GetItemBaseProp(nItemId)
				if tbItemBase then
					local _, _, _, _, TxtColor = Item:GetQualityColor(tbItemBase.nQuality)
 	               ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, string.format("幫派成員「%s」出手闊綽，購買了[%s]<%s>[-]！", pPlayer.szName, TxtColor, tbItemBase.szName), pPlayer.dwKinId, {nLinkType = ChatMgr.LinkType.Item, nTemplateId = nItemId,nFaction = pPlayer.nFaction})
				end
			end

		end
		pPlayer.CallClientScript("Recharge:BuyCardScucess")
	end
end

function Recharge:OnBuyDirectEnhanceCallBack(pPlayer, nEndTime, nGroupIndex)
	local tbBuyInfo = self.tbSettingGroup.DirectEnhance[nGroupIndex]
	local nLocalEndTime = pPlayer.GetUserValue(Recharge.SAVE_GROUP, tbBuyInfo.nEndTimeKey)
	if nEndTime ~= nLocalEndTime then
		local bRet, szMsg = Recharge:CanBuyDirectEnhance(pPlayer, tbBuyInfo.ProductId)
		pPlayer.SetUserValue(self.SAVE_GROUP, tbBuyInfo.nEndTimeKey, nEndTime)
		if not bRet then
			pPlayer.CenterMsg(szMsg, true)
			local nGold = Recharge:GetRechareRMBToGold(tbBuyInfo.nMoney)
			pPlayer.SendAward({{"Gold", nGold}} , true, nil, Env.LogWay_BuyDirectEnhance, nGroupIndex)
		else
			pPlayer.SendAward(tbBuyInfo.tbAward , nil, nil, Env.LogWay_BuyDirectEnhance, nGroupIndex)
		end
		self:AddTotalCardRecharge(pPlayer, tbBuyInfo.nMoney)
		Log("Recharge:Sucess OnBuyDirectEnhanceCallBack ", pPlayer.dwID, tbBuyInfo.ProductId, bRet)
		pPlayer.CallClientScript("Recharge:OnBuyDirectEnhanceSuc")
	end
end

local tbInvestRedBagTypes = {
	[1] = Kin.tbRedBagEvents.buy_invest_1,
	[2] = Kin.tbRedBagEvents.buy_invest_2,
	[3] = Kin.tbRedBagEvents.buy_invest_3,
	-- [4] = Kin.tbRedBagEvents.buy_invest_4,
	[5] = Kin.tbRedBagEvents.buy_invest_5,
	[6] = Kin.tbRedBagEvents.buy_invest_6,
}

function Recharge:HasBoughtInvest(pPlayer)
	for _, nBuyedKey in ipairs(Recharge.tbKeyGrowBuyed) do
		if pPlayer.GetUserValue(Recharge.SAVE_GROUP, nBuyedKey) ~= 0 then
			return true
		end
	end
	return false
end

function Recharge:OnBuyInvestCallBack(pPlayer, nGroupIndex)
	local nBuyedKey = Recharge.tbKeyGrowBuyed[nGroupIndex]
	if pPlayer.GetUserValue(Recharge.SAVE_GROUP, nBuyedKey) == 0 then
			pPlayer.SetUserValue(Recharge.SAVE_GROUP, nBuyedKey, 1);
		local tbBuyInfo = self.tbSettingGroup.GrowInvest[nGroupIndex]
		self:AddTotalCardRecharge(pPlayer, tbBuyInfo.nMoney)

		self:TakeGrowInvestAward(pPlayer, 1, nGroupIndex)

		pPlayer.CallClientScript("Recharge:OnBuyGrowInvestScuess")
		Log("Recharge:Sucess BuyGrowInvestCallBack ", pPlayer.dwID)

		local nRedBagType = tbInvestRedBagTypes[nGroupIndex]
		if nRedBagType then
			Kin:RedBagOnEvent(pPlayer, nRedBagType)
		end
		TeacherStudent:TargetAddCount(pPlayer, "BuyInvestGift", 1)
	end
end

function Recharge:GetFirstChargeAward(pPlayer)
	local nOffTime = 4*60*60
	local nServerCreateDay = Lib:GetLocalDay(GetServerCreateTime() - nOffTime)
	local nPlayerCreateDay = Lib:GetLocalDay(pPlayer.dwCreateTime - nOffTime)
	local nCompensationDay = math.min(nPlayerCreateDay - nServerCreateDay, self.MAX_COMPENSATION)
	local tbAward = {{"Item", self.nFirstAwardItem, 1}}
	if self.tbCompensationAward[nCompensationDay] then
		table.insert(tbAward, self.tbCompensationAward[nCompensationDay])
	end
	return tbAward
end

function Recharge:AddTotalCardRecharge(pPlayer, nCardRMB)
	local nOldCardRMB = pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_TOTAL_CARD)
	local nNewCardRMB = nOldCardRMB + nCardRMB
	self:OnTotalRechargeChange(pPlayer, nil, nNewCardRMB)
end


Recharge.tbDressMoneyPropId = 
{
	[0] = "39336"; --IOS
	[1] = "39258"; --android
}
Recharge.szDressMoneyActionId = "4837"
Recharge.szDressMoneyProductId = "com.tencent.jxqy.clothing98"  --测试是 "com.tencent.jxqy.present6"
function Recharge:RequestBuyDressMoney(pPlayer)
	if not self.IS_OPEN_BUY_DRESS then
		return
	end
	local szAppId, nPlatId, nServerId, nAreaId = GetWorldConfifParam();
	local szDressMoneyPropId = self.tbDressMoneyPropId[nPlatId]
	if not szDressMoneyPropId then
		return
	end

	Sdk:DoDaojuShopBuyingRequest(szDressMoneyPropId, self.szDressMoneyActionId, self.szDressMoneyProductId, pPlayer)
end

--购买老玩家回归礼包
function Recharge:OnBuyBackGiftCallBack(pPlayer, nEndTime, nGroupIndex)
	local tbBuyInfo = self.tbSettingGroup.BackGift[nGroupIndex]
	local nLocalEndTime = pPlayer.GetUserValue(self.SAVE_GROUP, tbBuyInfo.nEndTimeKey)
	nLocalEndTime = math.max(nLocalEndTime, GetTime())
	if nEndTime <= nLocalEndTime then
		return
	end
	pPlayer.SetUserValue(self.SAVE_GROUP, tbBuyInfo.nEndTimeKey, nEndTime)

	local nBuyCount = math.ceil((nEndTime-nLocalEndTime)/(24*3600))
	--剩余多少次需要转换为普通充值
	local nLastCount = RegressionPrivilege:OnBuyBackGiftSuccess(pPlayer, nGroupIndex, nBuyCount)
	if nLastCount == 0 then
		self:AddTotalCardRecharge(pPlayer, tbBuyInfo.nMoney * nBuyCount)
		return
	end
	local nGold = Recharge:GetRechareRMBToGold(tbBuyInfo.nMoney*nLastCount)
	pPlayer.SendAward({{"Gold", nGold}} , true, nil, Env.LogWay_RegressionPrivilege, nLastCount)
	pPlayer.CenterMsg("剩餘次數不足，已轉換為普通儲值", true)
	self:AddTotalCardRecharge(pPlayer, tbBuyInfo.nMoney*nBuyCount)
	Log("Recharge:OnBuyBackGiftCallBack LastCount NotEnough", pPlayer.dwID, nGold, nBuyCount, nLastCount, nEndTime, nGroupIndex)
end