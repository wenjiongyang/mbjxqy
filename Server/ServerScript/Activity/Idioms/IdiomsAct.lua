local tbAct = Activity:GetClass("IdiomsAct")
tbAct.tbTimerTrigger = 
{ 
   
}
tbAct.tbTrigger  = {Init = {}, Start = {}, End = {}}

function tbAct:OnTrigger(szTrigger)
    if szTrigger == "Start" then
    	IdiomFuben:LoadSetting()
        Activity:RegisterNpcDialog(self, 99,  {Text = "成語接龍", Callback = self.OnNpcDialog, Param = {self}})
        Activity:RegisterPlayerEvent(self, "Act_OnPlayerLogin", "OnPlayerLogin")
        self:SynSwitch() 
    elseif szTrigger == "End" then
        self:SynSwitch(true) 
    end
    Log("IdiomsAct OnTrigger:", szTrigger)
end

function tbAct:OnNpcDialog()
    local fnJoin = function(nPlayerId)
        local pPlayer = KPlayer.GetPlayerObjById(nPlayerId or 0)
        if not pPlayer then
            return
        end
        IdiomFuben:TryCreateFuben(pPlayer)
    end
    me.MsgBox("你們確定要參加 成語接龍 活動嗎?",
                {
                    {"確認參加", fnJoin, me.dwID},
                    {"取消"},
                })
end

-- 同步活动开关
function tbAct:SynSwitch(bClose) 
    local tbPlayer = KPlayer.GetAllPlayer()
    for _, pPlayer in pairs(tbPlayer) do
    	local nEndTime
    	if not bClose then
    		nEndTime = Activity:GetActEndTime(self.szKeyName)
    	end
        pPlayer.CallClientScript("IdiomFuben:SynSwitch",nEndTime)
    end
end

function tbAct:OnPlayerLogin()
    me.CallClientScript("IdiomFuben:SynSwitch",Activity:GetActEndTime(self.szKeyName))
end


