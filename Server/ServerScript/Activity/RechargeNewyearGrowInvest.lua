
local tbAct = Activity:GetClass("RechargeNewyearGrowInvest");

tbAct.tbTimerTrigger = 
{ 
}
tbAct.tbTrigger = { 
	Init 	= { }, 
	Start 	= { }, 
	End 	= { }, 
}


function tbAct:OnTrigger(szTrigger)
	if szTrigger == "Init" then
		local tbPlayers = KPlayer.GetAllPlayer()
		for i,player in ipairs(tbPlayers) do
			self:CheckVal(player)
		end
	elseif szTrigger == "Start" then
		Activity:RegisterPlayerEvent(self, "Act_OnPlayerLogin", "OnPlayerLogin");
	end
end

function tbAct:OnPlayerLogin()
    self:CheckVal(me)
end

function tbAct:CheckVal(pPlayer)
    local nStartTime = self:GetOpenTimeInfo()
	if pPlayer.GetUserValue(Recharge.SAVE_GROUP, Recharge.KEY_ACT_INVEST_RESET) >= nStartTime then
    	return
    end
    --看下玩家如果上一档的活动一本万利还没领完，直接邮件补发
    local nGroupIndex = 4
    local nBuyedKey = Recharge.tbKeyGrowBuyed[nGroupIndex]
    local nKeyTaked = Recharge.tbKeyGrowTaked[nGroupIndex]
    local nBuyed = pPlayer.GetUserValue(Recharge.SAVE_GROUP, nBuyedKey)
    if nBuyed ~= 0 then
    	local nTaked = pPlayer.GetUserValue(Recharge.SAVE_GROUP, nKeyTaked)
    	local tbGrowInvestSetting = Recharge.tbGrowInvestGroup[nGroupIndex]
    	local tbBit = KLib.GetBitTB(nTaked)
    	local nLeftGold = 0
    	for i,v in ipairs(tbGrowInvestSetting) do
    		if tbBit[i] == 0 then
    			nLeftGold = nLeftGold + v.nAwardGold;
    		end
    	end
    	if nLeftGold > 0 then
			Mail:SendSystemMail({
				To = pPlayer.dwID;
				Text = "  大俠，這是您上次活動尚未領完的一本萬利獎勵";
				tbAttach = { { "Gold",  nLeftGold} };
				nLogReazon = Env.LogWay_GrowInvestAward;
				tbParams = { LogReason2 = nGroupIndex*1000 };
				})    		
    	end
    end


    pPlayer.SetUserValue(Recharge.SAVE_GROUP, Recharge.KEY_ACT_INVEST_RESET, GetTime())
    pPlayer.SetUserValue(Recharge.SAVE_GROUP, nBuyedKey, 0)
    pPlayer.SetUserValue(Recharge.SAVE_GROUP, nKeyTaked, 0)
    pPlayer.SetUserValue(Recharge.SAVE_GROUP, Recharge.KEY_INVEST_ACT_TAKEDAY, 0)

    Log("RechargeNewyearGrowInvest Reseted", pPlayer.dwID)
end



