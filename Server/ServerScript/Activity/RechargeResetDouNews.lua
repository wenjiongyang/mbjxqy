
local tbAct = Activity:GetClass("RechargeResetDouNews");

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
		self:SendNews()
	end
end

function tbAct:SendNews()
	local _, nEndTime = self:GetOpenTimeInfo()
	NewInformation:AddInfomation("RechargeResetDou", nEndTime, {[[。
        [FFFE0D]迎全新資料片，全民狂歡福利[-]
            諸位俠士，全新資料片即將到來，以下為活動預告~

            活動時間：[FFFE0D]2016年9月10日-2016年9月20日[-]
            迎全新資料片，全民狂歡福利！活動期間只要登錄遊戲的俠士，所有已儲值檔的[FFFE0D]首次儲值雙倍元寶獎勵[-]將會重新開啟。
        ]]}, {szTitle = "全民狂歡", nReqLevel = 1})
end

