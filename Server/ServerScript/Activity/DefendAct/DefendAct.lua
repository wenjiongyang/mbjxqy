local tbAct = Activity:GetClass("DefendAct")
tbAct.tbTimerTrigger = 
{ 
   
}
tbAct.tbTrigger  = {Init = {}, Start = {}, End = {}}

function tbAct:OnTrigger(szTrigger)
    if szTrigger == "Start" then
        Activity:RegisterNpcDialog(self, 99,  {Text = "五一江湖展身手", Callback = self.OnNpcDialog, Param = {self}})
        Activity:RegisterPlayerEvent(self, "Act_OnPlayerLogin", "OnPlayerLogin")
        self:SynSwitch()
    elseif szTrigger == "End" then
        self:SynSwitch(true) 
    end
    Log("DefendAct OnTrigger:", szTrigger)
end

function tbAct:OnNpcDialog()
    local fnJoin = function(nPlayerId)
        local pPlayer = KPlayer.GetPlayerObjById(nPlayerId or 0)
        if not pPlayer then
            return
        end
        DefendFuben:TryCreateFuben(pPlayer)
    end
    me.MsgBox("你們確定要參加 五一江湖展身手 活動嗎?\n（每日有且僅有一次參與機會，一旦進入就將消耗次數）",
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
        pPlayer.CallClientScript("DefendFuben:SynSwitch",nEndTime)
    end
end

function tbAct:OnPlayerLogin()
    me.CallClientScript("DefendFuben:SynSwitch",Activity:GetActEndTime(self.szKeyName))
end
