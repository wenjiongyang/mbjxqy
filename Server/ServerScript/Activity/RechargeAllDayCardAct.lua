
local tbAct = Activity:GetClass("RechargeAllDayCardAct");

tbAct.tbTimerTrigger = 
{ 
}
tbAct.tbTrigger = { 
	Init 	= { }, 
	Start 	= { }, 
	End 	= { }, 
}

tbAct.SAVE_GROUP = 121;
tbAct.KEY_TAKE_DAY = 1;


function tbAct:OnTrigger(szTrigger)
	if szTrigger == "Start" then
		self.tbAward = Lib:GetAwardFromString(self.tbParam[1])
		self:SendNews()
		Activity:RegisterPlayerEvent(self, "Act_DailyGift", "OnAct_DailyGift");
	end
end

function tbAct:SendNews()
	local nStartTime, nEndTime = self:GetOpenTimeInfo()
	local tbTime1 = os.date("*t", nStartTime)
	local tbTime2 = os.date("*t", nEndTime)

	local szAwadDesc =  table.concat( Lib:GetAwardDesCount2(self.tbAward), "、")

	NewInformation:AddInfomation("RechargeResetDou", nEndTime, {
		string.format([[
            活動時間：[c8ff00]%d年%d月%d日4點-%d月%d日4點[-]
            活動說明：活動時間內購買[c8ff00]白銀/黃金/鑽石三個[-]超值禮包後，還將獲得[c8ff00]%s[-]的額外獎勵，還等什麼，快去購買吧！
            獎勵將會通過郵件發放，請注意查收。

        ]], tbTime1.year, tbTime1.month, tbTime1.day, tbTime2.month, tbTime2.day, szAwadDesc)},
         {szTitle = "每日禮包加碼送", nReqLevel = 1})
end



function tbAct:OnAct_DailyGift(pPlayer)
	local nToday = Lib:GetLocalDay(GetTime() - 3600 * 4)
	local nTakedyDay = pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_TAKE_DAY)
	if nTakedyDay == nToday then
		return
	end
	for nGroupIndex, tbBuyInfo in ipairs(Recharge.tbSettingGroup.DayGift) do
		local nBuyDay = pPlayer.GetUserValue(Recharge.SAVE_GROUP, tbBuyInfo.nBuyDayKey)
		if nBuyDay ~= nToday then
			return
		end
	end
	pPlayer.SetUserValue(self.SAVE_GROUP, self.KEY_TAKE_DAY, nToday)


	Mail:SendSystemMail({
		To = pPlayer.dwID,
		Title = "活動獎勵",
		Text = "      尊敬的俠士！恭喜您在每日禮包加碼送活動中達成要求，獲得活動獎勵",
		tbAttach = self.tbAward,
		nLogReazon = Env.LogWay_RechargeAllDayCardAct,
	});

end

