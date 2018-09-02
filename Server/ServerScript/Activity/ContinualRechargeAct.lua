local tbAct     = Activity:GetClass("ContinualRechargeAct")
tbAct.tbTimerTrigger = 
{ 
    [1] = {szType = "Day", Time = "0:00" , Trigger = "RefreshOnlinePlayerData"},
}
tbAct.tbTrigger = {Init = {}, Start = {{"StartTimerTrigger", 1}}, End = {}, RefreshOnlinePlayerData = {}}

function tbAct:OnTrigger(szTrigger)
    if szTrigger == "Start" then
        self:LoadAward()
        self.nRechargeGold = tonumber(self.tbParam[2])
        Activity:RegisterPlayerEvent(self, "OnRecharge", "OnRecharge")
        Activity:RegisterPlayerEvent(self, "Act_OnPlayerLogin", "CheckPlayerData")
        self:RefreshOnlinePlayerData()
    elseif szTrigger == "RefreshOnlinePlayerData" then
        self:RefreshOnlinePlayerData()
    end
end

function tbAct:LoadAward()
    local tbFile = Lib:LoadTabFile(self.tbParam[1], {nParam = 1})
    self.tbEverydayAward = {}
    self.tbSpecialAward = {}
    for _, tbInfo in ipairs(tbFile) do
        if tbInfo.szType == "everyday" then
            self.tbEverydayAward[tbInfo.nParam] = Lib:GetAwardFromString(tbInfo.szAward)
        elseif tbInfo.szType == "specialday" then
            local tbAward = Lib:GetAwardFromString(tbInfo.szAward)
            self.tbSpecialAward[tbInfo.nParam] = {nContinualDay = tbInfo.nParam, tbAward = tbAward}
        end
    end
end

function tbAct:OnRecharge(pPlayer, nGoldRMB, nCardRMB, nChargeGold)
    self:CheckPlayerData(pPlayer)
    local nTodayRecharge = Recharge:GetActContinualData(pPlayer, Recharge.KEY_ACT_CONTINUAL_RECHARGE)
    nTodayRecharge = nTodayRecharge + nChargeGold
    Recharge:SetActContinualData(pPlayer, Recharge.KEY_ACT_CONTINUAL_RECHARGE, nTodayRecharge)
    if nTodayRecharge < self.nRechargeGold then
        return
    end

    if Recharge:GetActContinualData(pPlayer, Recharge.KEY_ACT_CONTINUAL_FLAG) > 0 then
        return
    end

    local nContinual = Recharge:GetActContinualData(pPlayer, Recharge.KEY_ACT_CONTINUAL_DAYS) + 1
    Recharge:SetActContinualData(pPlayer, Recharge.KEY_ACT_CONTINUAL_DAYS, nContinual)
    Recharge:SetActContinualData(pPlayer, Recharge.KEY_ACT_CONTINUAL_FLAG, 1)
    local tbAward = self:GetCurDayAward()
    pPlayer.SendAward(tbAward, true, false, Env.LogWay_ContinualRechargeAct)
    if self.tbSpecialAward[nContinual] then
        pPlayer.SendAward(self.tbSpecialAward[nContinual].tbAward, true, false, Env.LogWay_ContinualRechargeAct)
    end
end

function tbAct:RefreshOnlinePlayerData()
    local tbPlayer = KPlayer.GetAllPlayer()
    for _, pPlayer in pairs(tbPlayer) do
        self:CheckPlayerData(pPlayer)
    end
end

function tbAct:CheckPlayerData(pPlayer)
    local nStartTime   = self:GetOpenTimeInfo()
    local bNotThisSess = Recharge:GetActContinualData(pPlayer, Recharge.KEY_ACT_CONTINUAL_SESSION_TIME) ~= nStartTime
    local nDataDay     = Recharge:GetActContinualData(pPlayer, Recharge.KEY_ACT_CONTINUAL_DATA_DAY)
    local nRecharge    = Recharge:GetActContinualData(pPlayer, Recharge.KEY_ACT_CONTINUAL_RECHARGE)
    local nLocalDay    = Lib:GetLocalDay()
    Recharge:SetActContinualData(pPlayer, Recharge.KEY_ACT_CONTINUAL_DATA_DAY, nLocalDay)
    if nLocalDay - nDataDay >= 1 or bNotThisSess then
        Recharge:SetActContinualData(pPlayer, Recharge.KEY_ACT_CONTINUAL_FLAG, 0)
        Recharge:SetActContinualData(pPlayer, Recharge.KEY_ACT_CONTINUAL_RECHARGE, 0)
        if bNotThisSess then
            Recharge:SetActContinualData(pPlayer, Recharge.KEY_ACT_CONTINUAL_SESSION_TIME, nStartTime)
            Recharge:SetActContinualData(pPlayer, Recharge.KEY_ACT_CONTINUAL_DAYS, 0)
        end
    end
end

function tbAct:GetCurDayAward()
    local nLocalDay = Lib:GetLocalDay()
    local nBeginDay = Lib:GetLocalDay(Activity:GetActBeginTime(self.szKeyName))
    return self.tbEverydayAward[nLocalDay - nBeginDay + 1] or self.tbEverydayAward[1]
end

function tbAct:GetUiData()
    if not self.tbUiData then
        local tbData = {}
        tbData.nShowLevel = 1
        tbData.szTitle = "連續儲值活動"
        tbData.nBottomAnchor = 0

        local nStartTime, nEndTime = self:GetOpenTimeInfo()
        local tbTime1 = os.date("*t", nStartTime)
        local tbTime2 = os.date("*t", nEndTime)
        tbData.szContent = string.format([[活動時間：[c8ff00]%d年%d月%d日0點-%d月%d日24點[-]
活動內容：
  每日[FFFF00]儲值達到指定額度（[c8ff00]有且僅有儲值額度直接兌換的元寶計算入內，系統贈送的元寶不計入累計儲值金額[-]）[-]，均將獲得一份獎勵，每日僅限獲得一次，[FFFF00]凌晨0點[-]結算，連續儲值[FFFF00]3天/7天[-]將獲得一份額外獎勵，活動期間若中途某一天未儲值，累計天數也將為您保留。
        ]], tbTime1.year, tbTime1.month, tbTime1.day, tbTime2.month, tbTime2.day)

        tbData.szBtnText = "前去儲值"
        tbData.szBtnTrap = "[url=openwnd:test, CommonShop, 'Recharge', 'Recharge']";

        tbData.tbSubInfo = {}
        local tbDesc = self:GetAwardDesc(self.tbEverydayAward[1])
        table.insert(tbData.tbSubInfo, {szType = "Item3", szSub = "ContinualRecharge_Day", nParam = self.nRechargeGold, tbItemList = self.tbEverydayAward[1], tbItemName = tbDesc, tbBgSprite = {"BtnListFifthSpecial", "NewBTn"}})

        for _, tbInfo in pairs(self.tbSpecialAward) do
            local tbDesc = self:GetAwardDesc(tbInfo.tbAward)
            table.insert(tbData.tbSubInfo, {szType = "Item3", szSub = "ContinualRecharge", nParam = tbInfo.nContinualDay, tbItemList = tbInfo.tbAward, tbItemName = tbDesc})
        end
        self.tbUiData = tbData
    end
    return self.tbUiData
end

function tbAct:GetAwardDesc(tbAward)
    local tbDesc = {}
    for _, tbInfo in ipairs(tbAward) do
        local nAwardType = Player.AwardType[tbInfo[1]]
        if nAwardType == Player.award_type_item then
            local szName = KItem.GetItemShowInfo(tbInfo[2])
            table.insert(tbDesc, szName)
        elseif nAwardType == Player.award_type_money then
            local szName = Shop:GetMoneyName(tbInfo[1])
            table.insert(tbDesc, szName)
        else
            table.insert(tbDesc, "其他獎勵")
        end
    end
    return tbDesc
end