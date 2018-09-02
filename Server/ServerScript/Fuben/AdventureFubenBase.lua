--奇遇秘境
local tbFuben = Fuben:CreateFubenClass("AdventureFubenBase")
tbFuben.tbBossAwardRate = {
    {40, 60, 10}, --下限等级（包括该等级），上限等级，概率
    {60, 120, 15},
}
tbFuben.tbBossAward = {"Item", 3079, 1}
tbFuben.tbFubenAward60 = {"Item", 787, 1}

function tbFuben:OnCreate(nCreater)
    self:Start()
    self.nCreateTime = GetTime()
    self.nCreater = nCreater 
end

function tbFuben:OnLogin(bReConnect)
    if self.bClose == 1 then
        me.GotoEntryPoint()
        return
    end

    me.CallClientScript("Ui:OpenWindow", "HomeScreenFuben", "TeamFuben")
    if self.nShowEndTime and self.nShowEndTime > 0 then
        me.CallClientScript("Fuben:SetEndTime", self.bClose == 1 and 0 or self.nShowEndTime)
    end

end

function tbFuben:OnJoin(pPlayer)
    if self.bClose == 1 then
        pPlayer.GotoEntryPoint()
        return
    end

    Task:OnTaskExtInfo(pPlayer, Task.ExtInfo_ShanZeiMiKu);
    DegreeCtrl:ReduceDegree(pPlayer, "AdventureFuben", 1)
    SummerGift:OnJoinAct(pPlayer, "AdventureFuben")
    pPlayer.CallClientScript("Ui:OpenWindow", "HomeScreenFuben", "TeamFuben")
    pPlayer.CallClientScript("Fuben:CloseLeave")
end

function tbFuben:OnPlayerDeath()
    me.nFightMode       = 2
    local nReviveTime   = Fuben.AdventureFuben.REVIVE_TIME
    local nDeathSkillId = Fuben.RandomFuben.DEATH_SKILLID
    Timer:Register(nReviveTime * Env.GAME_FPS, self.DoRevive, self, me.dwID)

    me.Revive(0)
    me.AddSkillState(nDeathSkillId, 1, 0, 10000)

    Dialog:SendBlackBoardMsg(me, string.format("您已身受重傷，將於%s秒後復活", nReviveTime or 1))
end

function tbFuben:DoRevive(nPlayerId)
    local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
    if not pPlayer then
        return
    end

    if pPlayer.nFightMode ~= 2 then
        return
    end

    pPlayer.RemoveSkillState(Fuben.RandomFuben.DEATH_SKILLID)
    pPlayer.nFightMode = 1
end

function tbFuben:OnLeaveMap(pPlayer)
    pPlayer.CallClientScript("Ui:CloseWindow", "HomeScreenFuben")

    local nMatchTime = GetTime() - self.nCreateTime
    pPlayer.TLogRoundFlow(Env.LogWay_AdventureFuben, self.nMapId, 0, nMatchTime, self.bClose and Env.LogRound_SUCCESS or Env.LogRound_FAIL, 0, 0)
end

function tbFuben:OnKickoutAllPlayer()
    local tbAllPlayer = KPlayer.GetMapPlayer(self.nMapId)
    for _, pPlayer in pairs(tbAllPlayer) do
        pPlayer.GotoEntryPoint()
    end
end

function tbFuben:GameWin()
    self:AddExperience()
    self:AddBossAward()

    local pCaptain = KPlayer.GetPlayerObjById(self.nCreater)
    if pCaptain then
        local nContrib = Fuben.AdventureFuben.CAPTAIN_CONTRIB
        pCaptain.SendAward({{"Contrib", nContrib}}, false, false, Env.LogWay_AdventureFuben)
        if pCaptain.dwTeamID > 0 then
            ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Team, string.format("隊長額外獲得%d點貢獻", nContrib), pCaptain.dwTeamID)
        end
    end

    KPlayer.MapBoardcastScript(self.nMapId, "Ui:OpenWindow", "LingJueFengLayerPanel", "Win")
    self:Close()
end

function tbFuben:AddExperience()
    local tbAllPlayer = KPlayer.GetMapPlayer(self.nMapId)
    for _, pPlayer in pairs(tbAllPlayer) do
        local nExp = pPlayer.GetBaseAwardExp() * Fuben.AdventureFuben.WIN_EXPERIENCE
        pPlayer.AddExperience(nExp, Env.LogWay_AdventureFuben)
    end
end

function tbFuben:GetRate(nLevel)
    for _, tbInfo in ipairs(self.tbBossAwardRate) do
        if nLevel >= tbInfo[1] and nLevel < tbInfo[2] then
            return tbInfo[3]
        end
    end
    return 0
end

function tbFuben:AddBossAward()
    local fnExcute = function (pPlayer)
        local nRan = MathRandom(100)
        local nSend = self:GetRate(pPlayer.nLevel)
        local tbAward = {}
        if nSend > 0 and nRan <= nSend then
            table.insert(tbAward, self.tbBossAward)
        end
        if pPlayer.nLevel >= 60 then
            table.insert(tbAward, self.tbFubenAward60)
        end
        if #tbAward > 0 then
            pPlayer.SendAward(tbAward, nil, true, Env.LogWay_AdventureFuben)
            Log("AdventureFuben AddBossAward", pPlayer.dwID, #tbAward, nRan, nSend)
        end
    end
    self:AllPlayerExcute(fnExcute)
end

function tbFuben:OnClose()
    Timer:Register(Env.GAME_FPS*4, self.OnKickoutAllPlayer, self)
end

function tbFuben:OnAddRandomAngerNpc(szGroup, nX, nY, nDir, tbRanInfo)
    local nTemplateId
    local nRandom = MathRandom(1, 1000000)
    for _, tbInfo in ipairs(tbRanInfo) do
        if tbInfo[1] >= nRandom then
            nTemplateId = tbInfo[2]
            break
        end
        nRandom = nRandom - tbInfo[1]
    end

    if not nTemplateId then
        Log("[Fuben OnAddRandomAngerNpc] Error Random Rate Error")
        return
    end

    local pNpc = KNpc.Add(nTemplateId, 1, -1, self.nMapId, nX, nY, 0, nDir)
    self:AddNpcInGroup(pNpc, szGroup)
end