local tbAct = Activity:GetClass("NewServerPrivilege")
tbAct.tbTrigger = { Init = {}, Start = {}, End = {}, }
tbAct.MAX_RECHARGE = 80000

function tbAct:OnTrigger(szTrigger)
    if szTrigger == "Start" then
        self:LoadRechargeInfo()
        local nStartTime, nEndTime = self:GetOpenTimeInfo()
        local nCreateTime = Lib:ParseDateTime(self.tbParam[1])
        RegressionPrivilege:OnNewServerActOpen(nStartTime, nCreateTime, self.tbPlayerRechargeInfo)
        DirectLevelUp:OnNewServerVersionChange(nStartTime, nEndTime)
        Activity:RegisterPlayerEvent(self, "Act_OnUseRegressionPrivilegeItem", "OnUseGiftItem")
    elseif szTrigger == "End" then
        self.tbPlayerRechargeInfo = {}
        RegressionPrivilege:OnNewServerActClose()
        DirectLevelUp:OnNewServerVersionChange()
    end
end

function tbAct:LoadRechargeInfo()
    --新服读这个文件用来发送元宝奖励，老服为了鉴定哪些玩家需要领取道具解冻福利
    self.tbPlayerRechargeInfo = {}
    Log("NewServerPrivilege LoadRechargeInfo Begin", os.clock())
    for szLine in io.lines("PlayerRechargeInfo.csv") do
        local szAcc, nCount = string.match(szLine, "^([^\t]+),(%d+)")
        if szAcc and nCount then
            nCount = tonumber(nCount) > self.MAX_RECHARGE and self.MAX_RECHARGE or tonumber(nCount)
            self.tbPlayerRechargeInfo[szAcc] = nCount * 10
        end
    end

    Log("NewServerPrivilege LoadRechargeInfo End", os.clock())
end

function tbAct:OnUseGiftItem(pPlayer)
    if not self:IsNewServer() then
        return
    end

    if pPlayer.GetUserValue(RegressionPrivilege.GROUP, RegressionPrivilege.TOTAL_RECHARGE) ~= 0 then
        Log("NewServerPrivilege OnUseGiftItem Player Recharge Is 0 ", pPlayer.dwID)
        return
    end

    local nTotalRecharge = self.tbPlayerRechargeInfo[pPlayer.szAccount] or 0
    local tbAward = {{"Item", RegressionPrivilege.LEVEL_GIFT_ITEM_ID, 1}}
    if nTotalRecharge <= 0 then
        pPlayer.SetUserValue(RegressionPrivilege.GROUP, RegressionPrivilege.TOTAL_RECHARGE, -1)
        pPlayer.SendAward(tbAward, nil, true, Env.LogWay_NewServerPrivilege)
        Log("NewServerPrivilege OnUseGiftItem NewServer No Recharge", pPlayer.dwID)
        return
    end

    pPlayer.SetUserValue(RegressionPrivilege.GROUP, RegressionPrivilege.TOTAL_RECHARGE, nTotalRecharge)
    table.insert(tbAward, {"Item", RegressionPrivilege.LEVEL_GOLD_ITEM_ID, 1})
    pPlayer.SendAward(tbAward, true, true, Env.LogWay_NewServerPrivilege)
    Log("NewServerPrivilege OnUseGiftItem NewServer", pPlayer.dwID, nTotalRecharge)
end

function tbAct:IsNewServer()
    local nNewServerCreateTime = Lib:ParseDateTime(self.tbParam[1])
    local nCreateTime = GetServerCreateTime()
    return nCreateTime > nNewServerCreateTime
end