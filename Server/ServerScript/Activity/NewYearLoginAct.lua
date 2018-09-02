--新年登录领奖
local tbAct = Activity:GetClass("NewYearLoginAct")
tbAct.tbTimerTrigger = 
{
    [1] = {szType = "Day", Time = "4:00" , Trigger = "RefreshOnlinePlayerData" },
}

tbAct.tbTrigger  =
{
    Init  = {},
    Start = {{"StartTimerTrigger", 1},},
    RefreshOnlinePlayerData = {},
    End   = {},
}

tbAct.GROUP = 68
tbAct.DATA_KEY = 1
tbAct.AWARD_FLAG_BEGIN = 2
tbAct.LOGIN_FLAG_BEGIN = 6

function tbAct:GetOpenTimeInfo()
    local nStartTime, nEndTime = Activity:__GetActTimeInfo(self.szKeyName)
    local nConfStartTime = Activity:GetActBeginTime(self.szKeyName)
    return math.max(nStartTime, nConfStartTime), nEndTime
end

function tbAct:OnTrigger(szTrigger)
    if szTrigger == "Init" then
        self:RefreshOnlinePlayerData()
    elseif szTrigger == "Start" then
        Activity:RegisterPlayerEvent(self, "Act_OnPlayerLogin", "OnLogin")
        Activity:RegisterPlayerEvent(self, "Act_OnPlayerLevelUp", "OnLevelUp")
        Activity:RegisterPlayerEvent(self, "Act_TryCallNewYearLoginActFunc", "OnClientCall")
        self:LoadAward()
        local nStartTime = self:GetOpenTimeInfo()
        KPlayer.BoardcastScript(1, "LoginAwards:LoadActSetting", self.tbParam[1], nStartTime)
    elseif szTrigger == "RefreshOnlinePlayerData" then
        self:RefreshOnlinePlayerData()
    end
end

function tbAct:GetCustomInfo()
    local nStartTime = self:GetOpenTimeInfo()
    return {nGroup = self.GROUP, nAwardFlag = self.AWARD_FLAG_BEGIN, nStartTime = nStartTime}
end

function tbAct:RefreshOnlinePlayerData()
    local tbAllPlayer = KPlayer.GetAllPlayer()
    for _, pPlayer in ipairs(tbAllPlayer) do
        self:RefreshData(pPlayer)
    end
end

function tbAct:LoadAward()
    self.tbAward = {}
    self.tbCost = {}
    local tbFile = Lib:LoadTabFile(self.tbParam[1])
    for _, tbInfo in ipairs(tbFile or {}) do
        local tbAward = Lib:GetAwardFromString(tbInfo.szAward)
        table.insert(self.tbAward, tbAward)
        table.insert(self.tbCost, tonumber(tbInfo.nCostGold))
    end
end

function tbAct:OnLogin(pPlayer)
    self:RefreshData(pPlayer)
    local nStartTime = self:GetOpenTimeInfo()
    pPlayer.CallClientScript("LoginAwards:LoadActSetting", self.tbParam[1], nStartTime)
end

function tbAct:OnLevelUp(pPlayer)
    if pPlayer.nLevel == LoginAwards.NEWYEAR_ACT_LEVEL then
        self:OnLogin(pPlayer)
    end
end

function tbAct:RefreshData(pPlayer)
    if pPlayer.nLevel < LoginAwards.NEWYEAR_ACT_LEVEL then
        return
    end

    local nStartTime = self:GetOpenTimeInfo()
    local nDataTime = pPlayer.GetUserValue(self.GROUP, self.DATA_KEY)
    local nDayIdx = LoginAwards:GetCurDayIdx(nStartTime)
    local function fnSetLoginFlag()
        local nSaveKey, nFlagIdx = LoginAwards:GetSaveInfo(nDayIdx, self.LOGIN_FLAG_BEGIN)
        local nFlag = pPlayer.GetUserValue(self.GROUP, nSaveKey)
        nFlag = KLib.SetBit(nFlag, nFlagIdx, 1)
        pPlayer.SetUserValue(self.GROUP, nSaveKey, nFlag)
    end
    if nDataTime < nStartTime then
        for i = self.AWARD_FLAG_BEGIN, 10 do
            pPlayer.SetUserValue(self.GROUP, i, 0)
        end

        fnSetLoginFlag()
        pPlayer.CallClientScript("LoginAwards:OnDataChange")
        Log("NewYearLoginAct Reset PlayerData", pPlayer.dwID)
    elseif GetTime() > nDataTime and Lib:IsDiffDay(LoginAwards.REFRESH_TIME, nDataTime) then
        if nDayIdx <= #self.tbAward then
            fnSetLoginFlag()
            pPlayer.CallClientScript("LoginAwards:OnDataChange")
            Log("NewYearLoginAct Add LoginDays", pPlayer.dwID, nDayIdx)
        end
    end
    pPlayer.SetUserValue(self.GROUP, self.DATA_KEY, math.max(GetTime(), nStartTime + 1))
end

function tbAct:GetAward(nIdx)
    local tbAward = Lib:CopyTB(self.tbAward[nIdx])
    for _, tbInfo in ipairs(tbAward) do
        if Player.AwardType[tbInfo[1]] == Player.award_type_item and tbInfo[4] then
            tbInfo[4] = GetTime() + tbInfo[4]
        end
    end
    return tbAward
end

function tbAct:CheckCanGetAward(pPlayer, nIdx)
    self:RefreshData(pPlayer)
    if nIdx > 32*(self.LOGIN_FLAG_BEGIN - self.AWARD_FLAG_BEGIN) then
        Log("NewYearLoginAct Not Support")
        return false, "領取失敗"
    end
    if nIdx > #self.tbAward then
        return false, "該天沒有獎勵可以領取"
    end
    local nStartTime = self:GetOpenTimeInfo()
    local nDayIdx = LoginAwards:GetCurDayIdx(nStartTime)
    if nIdx > nDayIdx then
        return false, "暫不可領"
    end
    local nSaveKey, nFlagIdx = LoginAwards:GetSaveInfo(nIdx, self.AWARD_FLAG_BEGIN)
    local nFlag = pPlayer.GetUserValue(self.GROUP, nSaveKey)
    if KLib.GetBit(nFlag, nFlagIdx) > 0 then
        return false, "不可重複領取"
    end

    return true
end

function tbAct:TryGetAward(pPlayer, nIdx)
    local bRet, szMsg = self:CheckCanGetAward(pPlayer, nIdx)
    if not bRet then
        pPlayer.CenterMsg(szMsg)
        return
    end

    local nSaveKey, nFlagIdx = LoginAwards:GetSaveInfo(nIdx, self.LOGIN_FLAG_BEGIN)
    local nFlag = pPlayer.GetUserValue(self.GROUP, nSaveKey)
    if KLib.GetBit(nFlag, nFlagIdx) > 0 then
        self:OnGetAwardSuccess(pPlayer, nIdx)
    else
        pPlayer.CostGold(self.tbCost[nIdx], Env.LogWay_NewYearLoginAct, nil, function (nPlayerId, bSuccess)
            local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
            if not pPlayer then
                return false, "離線了"
            end

            if not bSuccess then
                return false, "儲值失敗"
            end

            local bRet, szMsg = self:CheckCanGetAward(pPlayer, nIdx)
            if not bRet then
                return false, szMsg
            end
            self:OnGetAwardSuccess(pPlayer, nIdx, true)
            return true
        end)
    end
end

function tbAct:OnGetAwardSuccess(pPlayer, nIdx, bGold)
    local nSaveKey, nFlagIdx = LoginAwards:GetSaveInfo(nIdx, self.AWARD_FLAG_BEGIN)
    local nFlag = pPlayer.GetUserValue(self.GROUP, nSaveKey)
    nFlag = KLib.SetBit(nFlag, nFlagIdx, 1)
    pPlayer.SetUserValue(self.GROUP, nSaveKey, nFlag)

    local tbAward = self:GetAward(nIdx)
    pPlayer.SendAward(tbAward, true, false, Env.LogWay_NewYearLoginAct)
    pPlayer.CallClientScript("LoginAwards:OnGetActAwardsCallback", nIdx)
    Log("NewYearLoginAct TryGetAward", pPlayer.dwID, nIdx, nFlag, bGold and "Gold" or "Free")
end

local tbSafeCall = {
    ["RefreshData"] = true,
    ["TryGetAward"] = true,
}
function tbAct:OnClientCall(pPlayer, szFunc, ...)
    if not tbSafeCall[szFunc] then
        return
    end

    self[szFunc](self, pPlayer, ...)
end