
local tbAct = Activity:GetClass("DomainBattleAct2");

tbAct.tbTimerTrigger = 
{ 
	[1] = {szType = "Day", Time = "19:10" , Trigger = "AddAcution"},				
	[2] = {szType = "Day", Time = "4:02" , Trigger = "SendNews"},					--第一次攻城战是4：02
}
tbAct.tbTrigger = { 
	Init 	= { }, 
	Start 	= { {"StartTimerTrigger", 1}, {"StartTimerTrigger", 2},}, 
	End 	= { }, 
	AddAcution = {};
	SendNews = {};
}


function tbAct:OnTrigger(szTrigger)
	if szTrigger == "Start" then
		self:SendNews();
	elseif szTrigger == "AddAcution" then

		self:AddAcution()
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
	NewInformation:AddInfomation("DomainBattleAct2", nEndTime, {[[
\t\t[FFFE0D]攻城戰狂歡活動二[-]
\t\t\t[FFFE0D]活動時間：7月17日——7月23日[-]
\t\t\t各位俠士，活動期間，西域行腳商人開始出現在各大領地販賣各種珍貴物品。
\t\t\t每天[FFFE0D]19：10[-]，幫派拍賣行會出現“[FFFE0D]領地行商[-]”拍賣，參加了[FFFE0D]上一次攻城戰[-]的幫派成員可以獲得拍賣分紅。
]]} )
end

function tbAct:AddAcution()
	DomainBattle:AddOnwenrAcutionAward()
end
