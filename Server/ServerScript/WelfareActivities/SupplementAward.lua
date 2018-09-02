function SupplementAward:OnActivityOpen(szKey)
    local tbInfo = self.tbSupplement[szKey]
    if not tbInfo then
        return
    end

    self:RefreshTimeData()
    local tbOpenTime = ScriptData:GetValue("SupplementAward")
    local nToday = Lib:GetLocalDay(GetTime() - self.REF_TIME)
    tbOpenTime[nToday][szKey] = GetTime()
    ScriptData:AddModifyFlag("SupplementAward")
    Log("SupplementAward OnActivityOpen", szKey)
end

function SupplementAward:OnJoinActivity(pPlayer, szKey)
    local tbInfo = self.tbSupplement[szKey]
    if not tbInfo then
        Log("[SupplementAward OnJoinActivity Error]", pPlayer.dwID, szKey)
        return
    end

    pPlayer.SetUserValue(self.GROUP, tbInfo.nTimeSaveKey, GetTime())
end

function SupplementAward:OnPerDayUpdate()
    self:RefreshTimeData()

    local tbAllPlayer = KPlayer.GetAllPlayer()
    for _, pPlayer in pairs(tbAllPlayer) do
        if pPlayer then
            self:RefreshPlayerData(pPlayer)
        end
    end
    Log("SupplementAward PerDayUpdate")
end

function SupplementAward:RefreshTimeData()
    local tbOpenTime = ScriptData:GetValue("SupplementAward")
    local nToday = Lib:GetLocalDay(GetTime() - self.REF_TIME)
    if tbOpenTime[nToday] then
        return
    end

    tbOpenTime[nToday - 3] = nil
    tbOpenTime[nToday] = {}
    ScriptData:AddModifyFlag("SupplementAward")
    Log("SupplementAward RefreshTimeData", nToday)
end

function SupplementAward:OnLogin(pPlayer)
    self:RefreshTimeData()
    self:RefreshPlayerData(pPlayer)
end

function SupplementAward:IsGetDegreeTimes(szKey)
    if szKey == "Battle" then
        local szTF = (self.tbSupplement[szKey] or {})["szTranModeTF"]
        return Lib:IsEmptyStr(szTF) or GetTimeFrameState(szTF) == 0
    end

    return not Lib:IsEmptyStr(self.tbSupplement[szKey].szDegree)
end

function SupplementAward:RefreshPlayerData(pPlayer)
    local nLoginDay = Lib:GetLocalDay(pPlayer.GetUserValue(self.GROUP, self.DAY_LOGIN_TIME) - self.REF_TIME)
    local nToday = Lib:GetLocalDay(GetTime() - self.REF_TIME)
    if nToday == nLoginDay then
        return
    end

    pPlayer.SetUserValue(self.GROUP, self.SHOW_FLAG, 0)
    local nIntervalDay = nToday - nLoginDay
    local szLog = ""
    for szKey, tbInfo in pairs(self.tbSupplement) do
        local nCanSupplementTimes = 0
        if pPlayer.nLevel >= tbInfo.nLevel then
            local bGetDegree = self:IsGetDegreeTimes(szKey)
            if bGetDegree then
                if nIntervalDay == 1 then
                    nCanSupplementTimes = self:GetDegreeLastTimes(pPlayer, tbInfo)
                    local _, nYesterday = self:GetCanSupplementNum(pPlayer, szKey)
                    nCanSupplementTimes = nYesterday * self.DAY_BIT + nCanSupplementTimes
                else
                    nCanSupplementTimes = self:GetDegreeLastTimes(pPlayer, tbInfo, nIntervalDay > 2) * self.DAY_BIT
                    nCanSupplementTimes = self:GetDegreeLastTimes(pPlayer, tbInfo, nIntervalDay > 2) + nCanSupplementTimes
                end
            else
                if nIntervalDay == 1 then
                    nCanSupplementTimes = self:GetScheduleLastTimes(pPlayer, tbInfo)
                    local _, nYesterday = self:GetCanSupplementNum(pPlayer, szKey)
                    nCanSupplementTimes = nYesterday * self.DAY_BIT + nCanSupplementTimes
                else
                    nCanSupplementTimes = self:GetScheduleLastTimes(pPlayer, tbInfo)
                    nCanSupplementTimes = self:GetScheduleLastTimes(pPlayer, tbInfo, 2) * self.DAY_BIT + nCanSupplementTimes
                end
            end
        end
        pPlayer.SetUserValue(self.GROUP, tbInfo.nSupplementKey, nCanSupplementTimes)
        if nCanSupplementTimes > 0 then
            local nShowFlag = pPlayer.GetUserValue(self.GROUP, self.SHOW_FLAG)
            nShowFlag = KLib.SetBit(nShowFlag, tbInfo.nSupplementKey - self.SHOW_FLAG, 1)
            pPlayer.SetUserValue(self.GROUP, self.SHOW_FLAG, nShowFlag)
            szLog = string.format("%s|%s:%d|", szLog, szKey, nCanSupplementTimes)
        end
    end
    pPlayer.SetUserValue(self.GROUP, self.DAY_LOGIN_TIME, GetTime())
    Log("SupplementAward RefreshPlayerData", pPlayer.dwID, Lib:GetLocalDay(GetTime() - self.DAY_LOGIN_TIME), szLog)
end

function SupplementAward:GetDegreeLastTimes(pPlayer, tbInfo, bClear)
    if not Lib:IsEmptyStr(tbInfo.szTimeFrame) then
        local nOpenTime = CalcTimeFrameOpenTime(tbInfo.szTimeFrame)
        if Lib:GetLocalDay(nOpenTime - self.REF_TIME) >= Lib:GetLocalDay(GetTime() - self.REF_TIME) then
            return 0
        end
    end

    --每日答题有开启限制
    if tbInfo.szKey == "ActivityQuestion" and not ActivityQuestion:CheckYesterdayOpen(pPlayer) then
        return 0
    end

    if tbInfo.szKey == "MapExplorer" and pPlayer.nLevel >= MapExplore.MAX_LEVEL then
        return 0
    end

    local szDegree = tbInfo.szDegree
    --当玩家隔了几天没登录的情况下，必须直接刷新次数
    if bClear then
        DegreeCtrl:AddDegree(pPlayer, szDegree, 0)
        return tbInfo.nTimes
    end

    local nJoinTimes = DegreeCtrl:GetJoinCount(pPlayer, szDegree)
    --避免出现几天前参加但最近没刷新的情况
    DegreeCtrl:AddDegree(pPlayer, szDegree, 0)
    local nCanSupplementTimes = math.max(0, tbInfo.nTimes - nJoinTimes)
    --英雄挑战需判断次数的同时判断层数，避免第一次层没打过时出现补领的情况
    if tbInfo.szKey == "HeroChallenge" and (nJoinTimes > 0 or
        pPlayer.GetUserValue(HeroChallenge.tbDefInfo.nSaveGroupID, HeroChallenge.tbDefInfo.nSaveFloorCount) > 0) then
        nCanSupplementTimes = 0
        HeroChallenge:UpdatePerDayData(pPlayer)
    end
    return nCanSupplementTimes
end

SupplementAward.tbScheduleLastTimes =
{
    ["TeamBattle"] = function (self, pPlayer, nIntervalDay)
        if Lib:GetLocalWeekDay() ~= 1 or Lib:GetLocalWeekDay(GetTime() - self.REF_TIME) ~= 1 or (nIntervalDay and nIntervalDay > 1) then
            return 0
        end

        local _, _, nLastTime = TeamBattle:GetLastTimes(pPlayer)

        return nLastTime
    end,
}
function SupplementAward:GetScheduleLastTimes(pPlayer, tbInfo, nIntervalDay)
    local fnSpecialLast = self.tbScheduleLastTimes[tbInfo.szKey]
    if fnSpecialLast then
        return fnSpecialLast(self, pPlayer, nIntervalDay);
    end

    nIntervalDay = nIntervalDay or 1
    local nYesterday = Lib:GetLocalDay(GetTime() - self.REF_TIME) - nIntervalDay
    local nJoinDay = Lib:GetLocalDay(pPlayer.GetUserValue(self.GROUP, tbInfo.nTimeSaveKey) - self.REF_TIME)
    local bOpenInYestday = self:IsYesterdayOpen(tbInfo.szKey, nIntervalDay)
    if nYesterday > nJoinDay and bOpenInYestday then
        return 1
    end

    return 0
end

function SupplementAward:IsYesterdayOpen(szKey, nIntervalDay)
    local tbOpenTime = ScriptData:GetValue("SupplementAward")
    local nYesterday = Lib:GetLocalDay(GetTime() - self.REF_TIME) - nIntervalDay
    if not tbOpenTime[nYesterday] or not tbOpenTime[nYesterday][szKey] then
        return
    end

    local nOpenDay = Lib:GetLocalDay(tbOpenTime[nYesterday][szKey] - self.REF_TIME)
    return nOpenDay == nYesterday
end

function SupplementAward:CheckSupplement(pPlayer, szKey, nNum)
    local tbInfo = self.tbSupplement[szKey]
    if not tbInfo then
        return false, "數據異常"
    end

    local nCanGet = self:GetCanSupplementNum(pPlayer, szKey)
    if nCanGet == 0 then
        return false, "沒有可補領獎勵"
    end

    if nCanGet < nNum then
        return false, string.format("只能補領%d次獎勵", nCanGet)
    end

    return true
end

function SupplementAward:TryGetAward(szKey, nNum, bCoin)
    nNum = nNum or 1
    local bRet, szMsg = self:CheckSupplement(me, szKey, nNum)
    if not bRet then
        me.CenterMsg(szMsg)
        return
    end

    local tbInfo = self:GetInfo(szKey)
    if bCoin then
        if not me.CostMoney("Coin", tbInfo.nPrice_Coin * nNum, Env.LogWay_SupplementAward) then
            me.CenterMsg("銀兩扣除失敗")
            return
        end

        self:DoGetAward(me, szKey, nNum, bCoin)
    else
        local nItemNum = me.GetItemCountInAllPos(self.ITEM_TYPE_TID)
        if nItemNum >= nNum then
            if me.ConsumeItemInBag(self.ITEM_TYPE_TID, nNum, Env.LogWay_SupplementAward) then
                self:DoGetAward(me, szKey, nNum)
                me.CenterMsg("獎勵找回成功")
                Log("SupplementAward TryGetAward UseItem", nItemNum)
            end
            return
        end
        me.CostGold(tbInfo.nPrice * nNum, Env.LogWay_SupplementAward, nil, function (nPlayerId, bSuccess)
            local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
            if not pPlayer then
                return false, "離線了"
            end

            if not bSuccess then
                return false, "補領失敗"
            end

            local bRet, szMsg = self:CheckSupplement(pPlayer, szKey, nNum)
            if not bRet then
                return false, szMsg
            end
            self:DoGetAward(pPlayer, szKey, nNum)
            return true
        end)
    end
end

function SupplementAward:DoGetAward(pPlayer, szKey, nNum, bCoin)
    local tbInfo  = self.tbSupplement[szKey]
    local szAward = bCoin and tbInfo.szAward_Coin or tbInfo.szAward
    local tbAward = Lib:GetAwardFromString(szAward)
    local _, nYesterday, nTheDayBeforeYesterday = self:GetCanSupplementNum(pPlayer, szKey)
    local nCurTimes = nYesterday + nTheDayBeforeYesterday - nNum
    if nTheDayBeforeYesterday >= nNum then
        nCurTimes = (nTheDayBeforeYesterday - nNum) * self.DAY_BIT + nYesterday
    end
    pPlayer.SetUserValue(self.GROUP, tbInfo.nSupplementKey, nCurTimes)
    if tbAward and next(tbAward) then
        for _, tbSingleAward in ipairs(tbAward) do
            tbSingleAward[#tbSingleAward] = tbSingleAward[#tbSingleAward] * nNum
        end
        pPlayer.SendAward(tbAward, false, true, Env.LogWay_SupplementAward)
    end
    pPlayer.CallClientScript("SupplementAward:OnRespon")
    Log("SupplementAward DoGetAward", pPlayer.dwID, szKey, nNum, nCurTimes, nYesterday, nTheDayBeforeYesterday)
end