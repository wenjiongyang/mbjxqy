
local tbAct = Activity:GetClass("ConsumeSumAct");

tbAct.tbTimerTrigger = 
{ 
}
tbAct.tbTrigger = { 
	Init 	= { }, 
	Start 	= { }, 
	End 	= { }, 
}


--nMoney  元宝
tbAct.tbAllAward = {
	{nMoney = 1000, tbAward = {{"Contrib", 1000}, {"Item", 222, 10}, {"Item", 786, 5}},},
}



assert(#tbAct.tbAllAward < 32)

function tbAct:OnTrigger(szTrigger)
	if szTrigger == "Start" then
		Activity:RegisterPlayerEvent(self, "OnConsumeGold", "OnConsumeGold");
		Activity:RegisterPlayerEvent(self, "Act_OnPlayerLogin", "OnLogin");
		local nStartTime = self:GetOpenTimeInfo()
		Recharge:OnConsumeSumActStart(nStartTime)
		KPlayer.BoardcastScript(1, "Recharge:OnConsumeSumActStart", nStartTime)
	elseif szTrigger == "End" then
		Recharge:OnConsumeSumActEnd()
		KPlayer.BoardcastScript(1, "Recharge:OnConsumeSumActEnd")
	end
end

function tbAct:OnLogin(pPlayer)
	local nStartTime = self:GetOpenTimeInfo()
	pPlayer.CallClientScript("Recharge:OnConsumeSumActStart", nStartTime)
end

function tbAct:OnConsumeGold(pPlayer, nCostGold)
	local nStartTime = self:GetOpenTimeInfo()
	local nLastRestTime = Recharge:GetActConsumeSumTime(pPlayer)
	if nLastRestTime < nStartTime then
		if nLastRestTime ~= 0 then
			Log("ConsumeSumAct Reset", pPlayer.dwID, nLastRestTime, Recharge:GetActConsumeSumVal(pPlayer))
		end

		Recharge:SetActConsumeSumVal(pPlayer, 0)
		Recharge:SetActConsumeSumTime(pPlayer, nStartTime)
		Recharge:SetActConsumeSumTake(pPlayer, 0)
	end

	local nSumRecharge = Recharge:GetActConsumeSumVal(pPlayer) + nCostGold
	Recharge:SetActConsumeSumVal(pPlayer, nSumRecharge)

	local nTakeVal = Recharge:GetActConsumeSumTake(pPlayer)
	local tbBit = KLib.GetBitTB(nTakeVal)
	for i,v in ipairs(self.tbAllAward) do
		if nSumRecharge >= v.nMoney then
			if tbBit[i] == 0 then
				tbBit[i] = 1;
				nTakeVal = KLib.SetBit(nTakeVal, i, 1)
				Recharge:SetActConsumeSumTake(pPlayer, nTakeVal)
				Mail:SendSystemMail({
					To = pPlayer.dwID,
					Title = "活動獎勵",
					Text = string.format("      尊敬的俠士！恭喜您在累計消費活動中達成要求，獲得活動獎勵", i),
					tbAttach = v.tbAward,
					nLogReazon = Env.LogWay_RechargeSumAct,
					});
			end
		else
			break;
		end
	end
end

