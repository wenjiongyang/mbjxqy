local tbAct = Activity:GetClass("ZhongQiuJie")
tbAct.szMainKey = "ZhongQiuJie"
tbAct.tbTimerTrigger = 
{ 
    [1] = {szType = "Day", Time = "23:59" , Trigger = "BalanceRankBoard"},
    [2] = {szType = "Day", Time = "4:00"  , Trigger = "ClearRankBoard"  },
    [3] = {szType = "Day", Time = "10:00" , Trigger = "SendWorldNotify" },
    [4] = {szType = "Day", Time = "13:00" , Trigger = "SendWorldNotify" },
    [5] = {szType = "Day", Time = "19:00" , Trigger = "SendWorldNotify" },
}
tbAct.tbTrigger = { Init = { },
                    Start = { {"StartTimerTrigger", 1}, {"StartTimerTrigger", 2}, {"StartTimerTrigger", 3}, {"StartTimerTrigger", 4}, {"StartTimerTrigger", 5} },
                    BalanceRankBoard = {},
                    ClearRankBoard = {},
                    SendWorldNotify = { {"WorldMsg", "各位俠士，[FFFE0D]中秋節[-]活動開始了，大家可通過查詢“[FFFE0D]最新消息[-]”瞭解活動內容！", 20} },
                    End = { },
                    }

tbAct.szMailText = "大俠，您今日參加[FFFE0D]中秋答題[-]活動，獲得了第[FFFE0D]%d[-]名，附件為獎勵，請查收！"
tbAct.tbRankAward = {
    {10, {"Item", 2876, 1}},
    {30, {"Item", 2877, 1}},
    {100, {"Contrib", 600}},
}
tbAct.tbRightCommonAward = {"Item", 2878, 1} --答对3道奖励

function tbAct:OnTrigger(szTrigger)
    if szTrigger == "Start" then
        Activity:RegisterPlayerEvent(self, "Act_EverydayTarget_Award", "OnAddEverydayAward")
        Activity:RegisterPlayerEvent(self, "Act_ZhognQiuJieAnswerCallBack", "OnAnswerCallBack")
        Activity:RegisterGlobalEvent(self, "Act_OnKinMapCreate", "OnKinMapCreate")
        Activity:RegisterGlobalEvent(self, "Act_OnKinMapDestroy", "OnKinMapDestroy")
        Activity:RegisterNpcDialog(self, 1895, {Text = "中秋答題", Callback = self.TryQuestion, Param = {self}})
        Activity:RegisterNpcDialog(self, 1895, {Text = "排行榜", Callback = self.OpenClientPanel, Param = {self, "RankBoardPanel", self.szMainKey}})
        Activity:RegisterNpcDialog(self, 1895, {Text = "瞭解詳情", Callback = self.OpenClientPanel, Param = {self, "NewInformationPanel", "Local_ZhongQiuJie"}})
        self:CreateKinMapNpc()
        DaTi:SetQuestionNum("ZhongQiuJie", self.MAX_QUESTION)
    elseif szTrigger == "BalanceRankBoard" then
        self:BalanceRankBoard()
    elseif szTrigger == "ClearRankBoard" then
        self:ClearRankBoard()
    elseif szTrigger == "End" then
        self:RemoveKinMapNpc()
        self:ClearRankBoard()
    end
    Log("ZhongQiuJie OnTrigger:", szTrigger)
end

function tbAct:OnAddEverydayAward(pPlayer, nIdx)
    if pPlayer.nLevel < self.JOIN_LEVEL then
        return
    end

    pPlayer.SendAward({{"Item", self.nEverydayTargetAward, 1}}, nil, true, Env.LogWay_ZhongQiuJie)
end

function tbAct:CreateNpc(nMapId)
    if not nMapId then
        return
    end
    if self.tbNpcInKinMap and self.tbNpcInKinMap[nMapId] then
        Log("ZhongQiuJie CreateNpc Err", nMapId, self.tbNpcInKinMap[nMapId])
        return
    end

    local pNpc = KNpc.Add(1895, 1, 0, nMapId, 4991, 3453, 0, 58)
    self.tbNpcInKinMap = self.tbNpcInKinMap or {}
    self.tbNpcInKinMap[nMapId] = pNpc.nId
end

function tbAct:RemoveNpc(nMapId)
    if not nMapId or not self.tbNpcInKinMap then
        return
    end

    local nNpcId = self.tbNpcInKinMap[nMapId]
    if not nNpcId then
        return
    end

    local pNpc = KNpc.GetById(nNpcId)
    if not pNpc then
        return
    end

    pNpc.Delete()
end

function tbAct:CreateKinMapNpc()
    Kin:TraverseKin(function (kinData)
        if not kinData:IsMapOpen() then
            return
        end

        self:CreateNpc(kinData:GetMapId())
    end);
    Log("ZhongQiuJie CreateNpc")
end

function tbAct:RemoveKinMapNpc()
    Kin:TraverseKin(function (kinData)
        if not kinData:IsMapOpen() then
            return
        end

        self:RemoveNpc(kinData:GetMapId())
    end)
    Log("ZhongQiuJie DeleteNpc")
end

function tbAct:OnKinMapCreate(nMapId)
    self:CreateNpc(nMapId)
    Log("ZhongQiuJie OnKinMapCreate", nMapId)
end

function tbAct:OnKinMapDestroy(nMapId)
    self:RemoveNpc(nMapId)
    Log("ZhongQiuJie OnKinMapDestroy", nMapId)
end

function tbAct:TryQuestion()
    local bRet, szMsg = self:CheckCanAnswer(me)
    if not bRet then
        me.CenterMsg(szMsg)
        return
    end
    me.MsgBox("題目回答過程中不適合中斷，您確定開始答題？", {{"確認", self.ConfirmBeginAnswer, self}, {"取消"}})
end

function tbAct:OpenClientPanel(...)
    me.CallClientScript("Ui:OpenWindow", ...)
end

function tbAct:GetRankAward(nRank, nRightNum)
    local tbAward = {}
    for _, tbInfo in ipairs(self.tbRankAward) do
        if nRank <= tbInfo[1] then
            table.insert(tbAward, tbInfo[2])
            break
        end
    end

    if nRightNum >= 3 then
        table.insert(tbAward, self.tbRightCommonAward)
    end

    return tbAward
end

--结算排行榜
function tbAct:BalanceRankBoard()
    RankBoard:Rank(self.szMainKey)

    local tbRankPlayer = RankBoard:GetRankBoardWithLength(self.szMainKey, 99999, 1)
    local tbMail = {Title = "中秋節答題", From = "", nLogReazon = Env.LogWay_ZhongQiuJie}
    local nSendNum = 0
    for nRank, tbRankInfo in ipairs(tbRankPlayer or {}) do
        local tbAward = self:GetRankAward(nRank, tbRankInfo.nHighValue)
        if not next(tbAward) then
            break
        end
        local szMailText = string.format(self.szMailText, nRank)
        tbMail.Text = szMailText
        tbMail.To = tbRankInfo.dwUnitID
        tbMail.tbAttach = tbAward
        Mail:SendSystemMail(tbMail)
        nSendNum = nRank
    end
    Log("ZhongQiuJie BalanceRankBoard", nSendNum)
end

function tbAct:ClearRankBoard()
    RankBoard:ClearRank(self.szMainKey)
end

function tbAct:CommonCheck(pPlayer)
    if pPlayer.nLevel < 20 then
        return false, "等級不足"
    end

    local nCurTime = Lib:GetTodaySec()
    if nCurTime >= self.CLEARING_TIME or nCurTime < self.REFRESH_TIME then
        return false, "不在答題時間內"
    end

    return true
end

function tbAct:CheckCanAnswer(pPlayer)
    local bRet, szMsg = self:CommonCheck(pPlayer)
    if not bRet then
        return bRet, szMsg
    end

    self:RefreshData(pPlayer)
    local nLastBeginTime = pPlayer.GetUserValue(self.nSaveGroup, self.BEGIN_TIME)
    local nCompleteNum = pPlayer.GetUserValue(self.nSaveGroup, self.COMPLETE_NUM)
    if nLastBeginTime > 0 and GetTime() - nLastBeginTime > self.TIME_OUT then
        local nTotalTime = pPlayer.GetUserValue(self.nSaveGroup, self.TOTAL_TIME) + self.TIME_OUT
        nCompleteNum = nCompleteNum + 1
        pPlayer.SetUserValue(self.nSaveGroup, self.COMPLETE_NUM, nCompleteNum)
        pPlayer.SetUserValue(self.nSaveGroup, self.BEGIN_TIME, 0)
        pPlayer.SetUserValue(self.nSaveGroup, self.TOTAL_TIME, nTotalTime)

        local tbAward = {}
        table.insert(tbAward, self.tbQuestionAward_Wrong)
        pPlayer.SendAward(tbAward, nil, true, Env.LogWay_ZhongQiuJie)
        RankBoard:UpdateRankVal(self.szMainKey, pPlayer.dwID, pPlayer.GetUserValue(self.nSaveGroup, self.RIGHT_NUM),  9999 - nTotalTime)
    end
    if nCompleteNum >= self.MAX_QUESTION then
        return false, "今天的答題已完成"
    end

    return true
end

function tbAct:ConfirmBeginAnswer()
    local bRet, szMsg = self:CheckCanAnswer(me)
    if not bRet then
        me.CenterMsg(szMsg)
        return
    end
    local nBeginTime = me.GetUserValue(self.nSaveGroup, self.BEGIN_TIME)
    if nBeginTime == 0 then
        me.SetUserValue(self.nSaveGroup, self.BEGIN_TIME, GetTime())
    end
    local nEndTime = (nBeginTime == 0 and GetTime() or nBeginTime) + self.TIME_OUT
    DaTi:TryBeginQuestion(me, self.szMainKey, me.GetUserValue(self.nSaveGroup, self.COMPLETE_NUM) + 1, nEndTime)
end

function tbAct:RefreshData(pPlayer)
    local nLastSaveTime = pPlayer.GetUserValue(self.nSaveGroup, self.DATA_TIME)
    if Lib:IsDiffDay(self.REFRESH_TIME, nLastSaveTime) then
        pPlayer.SetUserValue(self.nSaveGroup, self.DATA_TIME, GetTime())
        pPlayer.SetUserValue(self.nSaveGroup, self.BEGIN_TIME, 0)
        pPlayer.SetUserValue(self.nSaveGroup, self.COMPLETE_NUM, 0)
        pPlayer.SetUserValue(self.nSaveGroup, self.TOTAL_TIME, 0)
        pPlayer.SetUserValue(self.nSaveGroup, self.RIGHT_NUM, 0)
        DaTi:Refresh(pPlayer.dwID, self.szMainKey)
        return true
    end
end

function tbAct:OnAnswerCallBack(pPlayer, nQuestionId, bRight, bTimeOut)
    local bRet, szMsg = self:CommonCheck(pPlayer)
    if not bRet then
        pPlayer.CenterMsg(szMsg)
        pPlayer.CallClientScript("DaTi:CloseUi")
        return
    end

    if self:RefreshData(pPlayer) then
        pPlayer.CenterMsg("這輪答題已結束，請重新開始")
        return
    end

    local nBeginTime = pPlayer.GetUserValue(self.nSaveGroup, self.BEGIN_TIME)
    if nBeginTime == 0 then
        Log("ZhongQiuJie OnAnswerCallBack Err", pPlayer.dwID)
        return
    end
    local nCompleteNum = pPlayer.GetUserValue(self.nSaveGroup, self.COMPLETE_NUM)
    nCompleteNum = nCompleteNum + 1
    if nCompleteNum > self.MAX_QUESTION then
        pPlayer.CenterMsg("今日答題已結束")
        return
    end

    local nTime = math.min(GetTime() - nBeginTime, self.TIME_OUT)
    pPlayer.SetUserValue(self.nSaveGroup, self.BEGIN_TIME, 0)
    pPlayer.SetUserValue(self.nSaveGroup, self.TOTAL_TIME, pPlayer.GetUserValue(self.nSaveGroup, self.TOTAL_TIME) + nTime)
    pPlayer.SetUserValue(self.nSaveGroup, self.COMPLETE_NUM, nCompleteNum)
    if bTimeOut or nTime > self.TIME_OUT then
        pPlayer.CenterMsg("回答已超時")
    elseif bRight then
        pPlayer.SetUserValue(self.nSaveGroup, self.RIGHT_NUM, pPlayer.GetUserValue(self.nSaveGroup, self.RIGHT_NUM) + 1)
    end
    local tbAward = {}
    table.insert(tbAward, bRight and self.tbQuestionAward_Right or self.tbQuestionAward_Wrong)
    pPlayer.SendAward(tbAward, nil, true, Env.LogWay_ZhongQiuJie)
    RankBoard:UpdateRankVal(self.szMainKey, pPlayer.dwID, pPlayer.GetUserValue(self.nSaveGroup, self.RIGHT_NUM),  9999 - pPlayer.GetUserValue(self.nSaveGroup, self.TOTAL_TIME))
    if nCompleteNum >= self.MAX_QUESTION then
        pPlayer.CenterMsg("今日答題已結束")
        pPlayer.CallClientScript("DaTi:CloseUi")
        return
    end

    self:ConfirmBeginAnswer()
end