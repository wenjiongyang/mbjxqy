
local tbAct = Activity:GetClass("RechargeNewYearBuyGift");

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
		local szAwardKey = self.tbParam[1]
		assert(Recharge.tbSettingGroup.YearGift[1][szAwardKey])
		self.szAwardKey = szAwardKey
		Recharge:SetYearGiftAwardKey(szAwardKey)
		--防止购买那边回调回来时活动已结束的情况就结束时不清了
		-- local nStartTime, nEndTime = self:GetOpenTimeInfo()
		-- NewInformation:AddInfomation("AnniversaryBag", nEndTime, {nStartTime, nEndTime} )
	end
end

function tbAct:OnPlayerLogin()
    self:CheckVal(me)
end

function tbAct:CheckVal(pPlayer)
    local nStartTime = self:GetOpenTimeInfo()
	if pPlayer.GetUserValue(Recharge.SAVE_GROUP, Recharge.KEY_ACT_NEWYEARGIFT_RESET) >= nStartTime then
    	return
    end
    pPlayer.SetUserValue(Recharge.SAVE_GROUP, Recharge.KEY_ACT_NEWYEARGIFT_RESET, GetTime())
    	
    local  tbNewYearBuySetting = Recharge.tbNewYearBuySetting
    for i,v in ipairs(Recharge.tbSettingGroup.YearGift) do
    	pPlayer.SetUserValue(Recharge.SAVE_GROUP, v.nBuyDayKey, 0)
    	local tbLimit = tbNewYearBuySetting[v.nGroupIndex]
    	if tbLimit and tbLimit.nSaveCountKey then
    		pPlayer.SetUserValue(Recharge.SAVE_GROUP, tbLimit.nSaveCountKey, 0)
    	end
    end

    Log("RechargeNewYearBuyGift Reseted", pPlayer.dwID)
end

function tbAct:GetUiData()
	return {szAwardKey = self.szAwardKey}
end

