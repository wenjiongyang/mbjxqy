
local tbAct = Activity:GetClass("RechargeResetDou");

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

function tbAct:SendNews()
end

function tbAct:OnPlayerLogin()
    self:CheckVal(me)
end

function tbAct:CheckVal(pPlayer)
	local nStartTime = self:GetOpenTimeInfo()
	if pPlayer.GetUserValue(Recharge.SAVE_GROUP, Recharge.KEY_BUYED_FLAG_TIME) >= nStartTime then
    	return
    end
    pPlayer.SetUserValue(Recharge.SAVE_GROUP, Recharge.KEY_BUYED_FLAG_TIME, GetTime())
    pPlayer.SetUserValue(Recharge.SAVE_GROUP, Recharge.KEY_BUYED_FLAG, 0)
    Log("RechargeResetDou Reseted", pPlayer.dwID)
end