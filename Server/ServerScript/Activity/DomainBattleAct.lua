
local tbAct = Activity:GetClass("DomainBattleAct");

tbAct.tbTimerTrigger = 
{ 
	[1] = {szType = "Day", Time = "4:02" , Trigger = "SendNews"},					--第一次攻城战是4：02
}
tbAct.tbTrigger = { 
	Init 	= { }, 
	Start 	= { {"StartTimerTrigger", 1}, }, 
	End 	= { }, 
	SendNews= { };
}


function tbAct:OnTrigger(szTrigger)
	if szTrigger == "Start" then
		self:SendNews();
	elseif szTrigger == "SendNews" then
		self:SendNews();
	end
end

function tbAct:SendNews()
	local nVersion = DomainBattle:GetBattleVersion()
	if not nVersion or nVersion == 0 then
		return
	end
	local _, nEndTime = self:GetOpenTimeInfo()
	NewInformation:AddInfomation("DomainBattleAct", nEndTime, {[[
[FFFE0D]攻城戰狂歡活動[-]

    各位大俠，本周將開啟攻城戰狂歡活動，參與攻城戰將獲得更多獎勵，請踴躍參加。
[FFFE0D]活動時間：7月12日——7月16日[-]
[FFFE0D]活動一：[-]幫派攻城器械打折
    在活動期間，戰爭坊出售的攻城器械價格將變為[FFFE0D]八折[-]。
[FFFE0D]活動二：[-]個人獎勵增加
    在活動期間，參加攻城戰後，個人獲得獎勵[FFFE0D]增加50%[-]，會獲得更多的攻城寶箱。
	]]} )	

end
