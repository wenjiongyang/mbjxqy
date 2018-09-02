DaTi.tbRandomQuestion = {
    default = function (self, szType, nNum)
        local tbAllQuestion = self.tbAllQuestion[szType]
        local tbRandom = {}
        nNum = nNum or self:GetDayQuestionNum(szType)
        for i = 1, nNum do
            table.insert(tbRandom, MathRandom(#tbAllQuestion))
        end
        return tbRandom
    end,

    ZhongQiuJie = function (self, szType, nNum)
        local tbAllQuestion = self.tbAllQuestion[szType]
        local tbRandom = {}
        local tbPool = {}
        nNum = nNum or self:GetDayQuestionNum(szType) or #tbAllQuestion
        for i = 1, #tbAllQuestion do
            table.insert(tbPool, i)
        end
        for i = 1, nNum do
            local nIdx = MathRandom(#tbPool)
            local nId = table.remove(tbPool, nIdx)
            table.insert(tbRandom, nId)
        end
        return tbRandom
    end,
}

function DaTi:GetDayQuestionNum(szType)
    self.tbQuestionNum = self.tbQuestionNum or {
        ["Task"] = ActivityQuestion.tbTaskQuestion:GetQuestionNum(),
        ["Activity"] = ActivityQuestion.ANSWER_NUM_MAX,
    }
    return self.tbQuestionNum[szType] or 0
end

function DaTi:SetQuestionNum(szType, nNum)
    self.tbQuestionNum = self.tbQuestionNum or {}
    self.tbQuestionNum[szType] = nNum
end

function DaTi:Refresh(dwID, szType)
    local fnRandom = self.tbRandomQuestion[szType] or self.tbRandomQuestion.default
    local tbRandom = fnRandom(self, szType)
    self.tbPlayerInfo = self.tbPlayerInfo or {}
    self.tbPlayerInfo[dwID] = self.tbPlayerInfo[dwID] or {}
    self.tbPlayerInfo[dwID][szType] = tbRandom
end

function DaTi:GetPlayerQuestion(dwID, szType, nIdx)
    if not self.tbPlayerInfo or not self.tbPlayerInfo[dwID] or not self.tbPlayerInfo[dwID][szType] then
        self:Refresh(dwID, szType)
    end
    return self.tbPlayerInfo[dwID][szType][nIdx]
end

DaTi.tbAnswerCallback = {
    ["Task"] = function (...)
        ActivityQuestion.tbTaskQuestion:TryAnswer(...)
    end,
    ["Activity"] = function (...)
        ActivityQuestion:TryAnswer(...)
    end,
    ["ZhongQiuJie"] =function (...)
        Activity:OnPlayerEvent(me, "Act_ZhognQiuJieAnswerCallBack", ...)
    end,
    ["WeekendQuestion"] = function (_1, _2, bRight)
        Activity:OnPlayerEvent(me, "Act_WeekendTryAnswer", bRight)
    end
}
function DaTi:TryAnswer(pPlayer, szType, nQuestionId, nAnswerId, ...)
    local tbInfo     = self:GetQuestionInfo(szType, nQuestionId)
    local fnCallback = self.tbAnswerCallback[szType]
    fnCallback(pPlayer, nQuestionId, tbInfo.nAnswerId == nAnswerId, ...)
end

DaTi.tbBeginFunc = {
    ["Activity"] = function (self, pPlayer, nQuestionId)
        pPlayer.CallClientScript("DaTi:BeginQuestion", "Activity", nQuestionId)
    end,

    ["ZhongQiuJie"] = function (self, pPlayer, nIdx, nEndTime)
        local nQuestionId = self:GetPlayerQuestion(pPlayer.dwID, "ZhongQiuJie", nIdx)
        pPlayer.CallClientScript("DaTi:BeginQuestion", "ZhongQiuJie", nQuestionId, nEndTime)
    end,

    ["WeekendQuestion"] = function (self, pPlayer, nQuestionId, nEndTime)
        local bRet = Activity:__IsActInProcessByType("WeekendQuestion")
        if bRet then 
            pPlayer.CallClientScript("DaTi:BeginQuestion", "WeekendQuestion", nQuestionId, nEndTime)

            local tbQuestionInfo = DaTi:GetQuestionInfo("WeekendQuestion", nQuestionId)
            local szTips = string.format("%s正在回答題目：%s",pPlayer.szName,tbQuestionInfo.szTitle)
            ChatMgr:SendTeamOrSysMsg(pPlayer, szTips)
        else
            Log("[DaTi] tbBeginFunc no WeekendQuestion tbInst")
        end
       
    end
}
function DaTi:TryBeginQuestion(pPlayer, szType, ...)
    local fn = self.tbBeginFunc[szType]
    if not fn then
        return
    end
    fn(self, pPlayer, ...)
end