--降低疲劳活动
local tbAct = Activity:GetClass("ReduceFatigueAct")
tbAct.tbTrigger  =
{
    Init  = {},
    Start = {},
    End   = {},
}
-- tbAct.nDayTargetItemTID = 3690 --加活跃道具模版ID
-- tbAct.nRefreshTime = 4*3600
-- tbAct.GROUP = 66
-- tbAct.DATA_KEY = 61

function tbAct:OnTrigger(szTrigger)
    -- if szTrigger == "Start" then
    --     Activity:RegisterPlayerEvent(self, "Act_OnPlayerLogin", "OnLogin")
    -- end
end

-- function tbAct:OnLogin(pPlayer)
--     if Lib:IsDiffDay(self.nRefreshTime, pPlayer.GetUserValue(self.GROUP, self.DATA_KEY)) then
--         pPlayer.SetUserValue(self.GROUP, self.DATA_KEY, GetTime())
--         self:SendAwardEmail(pPlayer)
--     end
-- end

-- function tbAct:SendAwardEmail(pPlayer)
--     local nEndTime = GetTime() - Lib:GetLocalDayTime() + self.nRefreshTime 
--     if Lib:GetLocalDayTime() >= self.nRefreshTime then
--         nEndTime = nEndTime + 24*3600
--     end

--     local tbAward = {{"Item", self.nDayTargetItemTID, 1, nEndTime}}
--     local szContent = "    啦啦啦，心灵手巧的真儿又来了哦，这一次带来的是甜甜甜的新年糕点，嘻嘻，怎么？你有什么不满意的吗？竟敢翻我白眼！一副「你又来了」的样子，哼，下次若再让我看见，就休想再吃我做的东西，无论如何，新年佳节，总是应当活跃些才是，新年快乐！"
--     local tbMail = {Title = "新年糕点送甜蜜", From = "纳兰真", nLogReazon = Env.LogWay_ReduceFatigueAct, Text = szContent, To = pPlayer.dwID, tbAttach = tbAward, nRecyleTime = nEndTime - GetTime()}
--     Mail:SendSystemMail(tbMail)
--     Log("ReduceFatigueAct SendAwardEmail", pPlayer.dwID, nEndTime)
-- end