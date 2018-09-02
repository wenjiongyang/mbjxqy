
local tbAct = Activity:GetClass("RechargeSumAct");

tbAct.tbTimerTrigger = 
{ 
}
tbAct.tbTrigger = { 
	Init 	= { }, 
	Start 	= { }, 
	End 	= { }, 
}


function tbAct:OnTrigger(szTrigger)
	if szTrigger == "Start" then
		local tbFile = LoadTabFile(self.tbParam[1], "dss", nil, {"nMoney", "AwardList", "NameList"});
		local tbAllAward = {};
		for i,v in ipairs(tbFile) do
			table.insert(tbAllAward, { nMoney = v.nMoney, tbAward = Lib:GetAwardFromString(v.AwardList), tbItemName = Lib:SplitStr(v.NameList, "|") })
		end
		self.tbAllAward = tbAllAward;

		Activity:RegisterPlayerEvent(self, "OnRecharge", "OnRecharge");
		Activity:RegisterPlayerEvent(self, "Act_OnPlayerLogin", "OnLogin");
		local nStartTime = self:GetOpenTimeInfo()
		Recharge:OnSumActStart(nStartTime)
		KPlayer.BoardcastScript(1, "Recharge:OnSumActStart", nStartTime)
	elseif szTrigger == "End" then
		Recharge:OnSumActEnd()
		KPlayer.BoardcastScript(1, "Recharge:OnSumActEnd")
	end
end

function tbAct:OnLogin(pPlayer)
	local nStartTime = self:GetOpenTimeInfo()
	pPlayer.CallClientScript("Recharge:OnSumActStart", nStartTime)
end

function tbAct:OnRecharge(pPlayer, nGoldRMB, nCardRMB , nRechargeGold)
	local nStartTime = self:GetOpenTimeInfo()
	local nLastRestTime = Recharge:GetActRechageSumTime(pPlayer) --pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_ACT_SUM_SET_TIME)
	if nLastRestTime < nStartTime then
		if nLastRestTime ~= 0 then
			Log("RechargeSumAct Reset", pPlayer.dwID, nLastRestTime, Recharge:GetActRechageSumVal(pPlayer)) --.GetUserValue(self.SAVE_GROUP, self.KEY_ACT_SUM)
		end
		Recharge:SetActRechageSumVal(pPlayer, 0)
		Recharge:SetActRechageSumTake(pPlayer, 0)
		Recharge:SetActRechageSumTime(pPlayer, nStartTime)
	end

	local nSumRecharge = Recharge:GetActRechageSumVal(pPlayer) + nRechargeGold
	Recharge:SetActRechageSumVal(pPlayer, nSumRecharge)

	local nTakeVal = Recharge:GetActRechageSumTake(pPlayer)
	local tbBit = KLib.GetBitTB(nTakeVal)
	for i,v in ipairs(self.tbAllAward) do
		if nSumRecharge >= v.nMoney then
			if tbBit[i] == 0 then
				tbBit[i] = 1;
				nTakeVal = KLib.SetBit(nTakeVal, i, 1)
				Recharge:SetActRechageSumTake(pPlayer, nTakeVal)

				Mail:SendSystemMail({
					To = pPlayer.dwID,
					Title = "活動獎勵",
					Text = string.format("      尊敬的俠士！恭喜您在累計儲值活動中達成要求，獲得活動獎勵", i),
					tbAttach = v.tbAward,
					nLogReazon = Env.LogWay_RechargeSumAct,
					});
			end
		else
			break;
		end
	end
end

function tbAct:GetUiData()
	if not self.tbUiData then
		local tbUiData = {}
		self.tbUiData = tbUiData
		tbUiData.nShowLevel = 1;
		tbUiData.szTitle = "累計儲值活動";
		local nStartTime, nEndTime = self:GetOpenTimeInfo()
		local tbTime1 = os.date("*t", nStartTime)
		local tbTime2 = os.date("*t", nEndTime)
		--文字如果前面要空格不要用tab
		tbUiData.szContent = string.format([[活動時間：[c8ff00]%d年%d月%d日0點-%d月%d日24點[-]
活動內容：
尊敬的俠士，活動期間累計儲值達到[FFFF00]指定元寶數（有且僅有儲值金額直接兌換的元寶計算入內，系統贈送的元寶不計入累計儲值金額）[-]，即可獲得額外獎勵，活動在[FFFF00]凌晨24點[-]結束，千萬不要錯過哦！
]], tbTime1.year, tbTime1.month, tbTime1.day, tbTime2.month, tbTime2.day);
		tbUiData.szBtnText = "前去儲值"
		tbUiData.szBtnTrap = "[url=openwnd:test, CommonShop, 'Recharge', 'Recharge']";

		local tbSubInfo = {}
		for i,v in ipairs(self.tbAllAward) do
			table.insert(tbSubInfo, 
				{ szType = "Item3", szSub = "Recharge", nParam = v.nMoney, tbItemList = v.tbAward, tbItemName = v.tbItemName}
			)
		end
		tbUiData.tbSubInfo = tbSubInfo
	end
	return self.tbUiData;	
end
