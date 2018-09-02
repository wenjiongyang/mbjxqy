local DAY_SEC = 24*3600
function RegressionPrivilege:OnStartUp()
    MarketStall:RegisterCheckOpen("RegressionPrivilege", function(pPlayer)
        local bRet, szMsg = self:IsCloseMarketStall(pPlayer)
        return not bRet, szMsg
    end)
end

function RegressionPrivilege:ResetBeginTime(pPlayer, nBeginTime)
    pPlayer.SetUserValue(self.GROUP, self.PAUSE_FLAG, 1)
    pPlayer.SetUserValue(self.GROUP, self.ACTIVITY_TRIGGER, nBeginTime)
    pPlayer.SetUserValue(self.GROUP, self.BEGIN_TIME, nBeginTime)
    Log("RegressionPrivilege OnNewServerActOpen Freeze Privilege", pPlayer.dwID)
end

function RegressionPrivilege:OnLogin(pPlayer)
    if pPlayer.nLevel < self.Privilege_Lv then
        return
    end

    if self:IsInPrivilegeTime(pPlayer) then
        if self.tbNewServerActInfo and 
           self.tbNewServerActInfo.tbRechargeInfo[pPlayer.szAccount] and 
           pPlayer.GetUserValue(self.GROUP, self.PAUSE_FLAG) == 0 and
           pPlayer.GetUserValue(self.GROUP, self.ACTIVITY_TRIGGER) ~= self.tbNewServerActInfo.nVersion then
            self:ResetBeginTime(pPlayer, self.tbNewServerActInfo.nVersion)
        end
        return
    end

    local tbStayInfo      = KPlayer.GetRoleStayInfo(pPlayer.dwID)
    local nLastOnlineTime = tbStayInfo and tbStayInfo.nLastOnlineTime or 0
    if nLastOnlineTime <= 0 then
        return
    end

    local nOutDay = Lib:GetLocalDay() - Lib:GetLocalDay(nLastOnlineTime)
    nOutDay = math.min(self.Max_OutlineDays, nOutDay)
    if nOutDay < self.Outline_Days then
        return
    end

    if self.tbNewServerActInfo and self.tbNewServerActInfo.tbRechargeInfo[pPlayer.szAccount] then
        local nVersion = self.tbNewServerActInfo.nVersion
        if nVersion == pPlayer.GetUserValue(self.GROUP, self.ACTIVITY_TRIGGER) then
            Log("RegressionPrivilege Back More In One Activity", pPlayer.dwID, nLastOnlineTime)
            return
        end

        if GetServerCreateTime() >= self.tbNewServerActInfo.nCreateTime then
            return
        end

        if pPlayer.GetUserValue(self.GROUP, self.BEGIN_TIME) + self.Outline_Days*24*60*60 > nVersion then
            self:ResetBeginTime(pPlayer, nVersion)
            return
        end

        pPlayer.SetUserValue(self.GROUP, self.OUTLINE_DAY, nOutDay)
        pPlayer.SetUserValue(self.GROUP, self.ACTIVITY_TRIGGER, nVersion)
        pPlayer.SetUserValue(self.GROUP, self.ITEM_USED_FLAG, 0)
        Log("RegressionPrivilege Be Trigger By Activity", pPlayer.dwID, nLastOnlineTime)
        return
    end

    if self:IsInPrivilegeCD(pPlayer) then
        Log("RegressionPrivilege Normal Start Fail, InCD", pPlayer.dwID, nLastOnlineTime)
        return
    end

    pPlayer.SetUserValue(self.GROUP, self.OUTLINE_DAY, nOutDay)
    pPlayer.SetUserValue(self.GROUP, self.ACTIVITY_TRIGGER, 0)
    pPlayer.SetUserValue(self.GROUP, self.ITEM_USED_FLAG, 0)
    self:StartPrivilege(pPlayer)
    Log("RegressionPrivilege Normal Start", pPlayer.dwID, nLastOnlineTime)
end

function RegressionPrivilege:OnUsePrivilegeItem(pPlayer)
    if self.tbNewServerActInfo and GetServerCreateTime() >= self.tbNewServerActInfo.nCreateTime then
        Activity:OnPlayerEvent(pPlayer, "Act_OnUseRegressionPrivilegeItem")
        return
    end

    pPlayer.SetUserValue(self.GROUP, self.ITEM_USED_FLAG, 1)
    pPlayer.SetUserValue(self.GROUP, self.PAUSE_FLAG, 0)
    if not self:IsInPrivilegeTime(pPlayer) then
        self:StartPrivilege(pPlayer)
    end
    pPlayer.CenterMsg("使用成功，擺攤功能開啟")
    Log("RegressionPrivilege OnUsePrivilegeItem", pPlayer.dwID)
end

function RegressionPrivilege:StartPrivilege(pPlayer)
    if self:IsInPrivilegeTime(pPlayer) then
        pPlayer.CenterMsg("已在特權期間，不可重複開啟")
        return
    end

    local nGroup  = self.GROUP
    local nOutDay = pPlayer.GetUserValue(nGroup, self.OUTLINE_DAY)
    if nOutDay <= 0 then
        return
    end

    if nOutDay < self.Outline_Days then
        nOutDay = self.Outline_Days
        pPlayer.SetUserValue(nGroup, self.OUTLINE_DAY, nOutDay)
        Log("RegressionPrivilege StartPrivilege Warning", pPlayer.dwID)
    end

    pPlayer.SetUserValue(nGroup, self.BEGIN_TIME, GetTime())
    pPlayer.SetUserValue(nGroup, self.NEW_VERSION, 1)
    pPlayer.SetUserValue(nGroup, self.FREE_GAIN, 0)

    pPlayer.SetUserValue(nGroup, self.KINDONATE_TIMES, nOutDay)
    pPlayer.SetUserValue(nGroup, self.KINDONATE_TIMES_MAX, nOutDay)
    pPlayer.SetUserValue(nGroup, self.REFRESHSHOP_TIMES, math.ceil(nOutDay/7))
    pPlayer.SetUserValue(nGroup, self.REFRESHSHOP_TIMES_MAX, math.ceil(nOutDay/7))
    -- pPlayer.SetUserValue(nGroup, self.GIFTBOX_TIMES, nOutDay*4)
    -- pPlayer.SetUserValue(nGroup, self.GIFTBOX_TIMES_MAX, nOutDay*4)
    pPlayer.SetUserValue(nGroup, self.CHUANGONG_TIMES, nOutDay*2)
    pPlayer.SetUserValue(nGroup, self.CHUANGONG_TIMES_MAX, nOutDay*2)
    pPlayer.SetUserValue(nGroup, self.XIULIAN_TIMES, nOutDay*1800)
    pPlayer.SetUserValue(nGroup, self.XIULIAN_TIMES_MAX, nOutDay*1800)
    pPlayer.SetUserValue(nGroup, self.MONEYTREE_TIMES, nOutDay)
    pPlayer.SetUserValue(nGroup, self.MONEYTREE_TIMES_MAX, nOutDay)
    pPlayer.SetUserValue(nGroup, self.KINSTORE_TIMES, nOutDay)
    pPlayer.SetUserValue(nGroup, self.KINSTORE_TIMES_MAX, nOutDay)
    pPlayer.SetUserValue(nGroup, self.TIANJIAN_FLAG, 0)
    pPlayer.SetUserValue(nGroup, self.PAUSE_FLAG, 0)

    for _, tbActInfo in pairs(self.DOUBLE_ACT) do
        local nTimes = math.ceil(nOutDay/tbActInfo.nDayPer)
        pPlayer.SetUserValue(nGroup, tbActInfo.nSaveKey, nTimes)
        pPlayer.SetUserValue(nGroup, tbActInfo.nMaxSaveKey, nTimes)
    end
    local nDayExt = math.ceil(nOutDay/self.DayTargetEXT.nDayPer)
    pPlayer.SetUserValue(nGroup, self.DayTargetEXT.nSaveKey, nDayExt)
    pPlayer.SetUserValue(nGroup, self.DayTargetEXT.nMaxSaveKey, nDayExt)

    --充值特权
    for _, tbInfo in pairs(self.RECHARGE_AWARD) do
        local nTimes = math.ceil(nOutDay/tbInfo.nDayPer)
        pPlayer.SetUserValue(nGroup, tbInfo.nSaveKey, nTimes)
    end

    local nVipLv = pPlayer.GetVipLevel()
    local nEnergy = self:GetEnergy(nVipLv, nOutDay)
    pPlayer.SetUserValue(nGroup, self.OLD_VIPLEVEL, nVipLv)
    pPlayer.SetUserValue(nGroup, self.YUANQI_AWARD, nEnergy)

    self:SendBackEmail(pPlayer)
    DirectLevelUp:CheckPlayerData(pPlayer)
    Log("RegressionPrivilege StartPrivilege", pPlayer.dwID, nOutDay)
end

function RegressionPrivilege:SendBackEmail(pPlayer)
    -- local nVipLv   = pPlayer.GetVipLevel()
    -- local nEndTime = self:GetPrivilegeTime(pPlayer)
    -- local nOut     = pPlayer.GetUserValue(self.GROUP, self.OUTLINE_DAY)
    -- local tbAward  = {{"Item", self.nClearItem, 1, nEndTime}, {"Item", 2708, 1, nEndTime}}
    -- local nEnergy  = self:GetEnergy(nVipLv, nOut)
    -- if nEnergy > 0 then
    --     table.insert(tbAward, {"Energy", nEnergy})
    -- end
    -- if nVipLv >= 4 then
    --     table.insert(tbAward, {"Item", 4759, 1, nEndTime})
    -- end

    -- table.insert(tbAward, {"SkillExp", 360*nOut})
    -- if nVipLv >= self.LvUp_VipLv then
    --     local nLevelUpTID = DirectLevelUp:GetCanBuyItem()
    --     local bHadBuy = DirectLevelUp:CheckHadBuyOne(pPlayer)
    --     if nLevelUpTID and not bHadBuy then
    --         DirectLevelUp:AddBuyedFlag(pPlayer, nLevelUpTID)
    --         table.insert(tbAward, {"Item", nLevelUpTID, 1, nEndTime})
    --         Log("RegressionPrivilege SendBackEmail With LevelUpItem", pPlayer.dwID)
    --     end
    -- end
    local tbAwardMail = {Title = "重回武林好禮相贈", From = "獨孤劍", nLogReazon = Env.LogWay_RegressionPrivilege, Text = "     情緣再鑄江湖夢！劍俠歸來正當時！少俠重回武林，令人欣慰，特備薄禮，還望少俠再創輝煌。\n     符合條件的俠士可獲得雙倍儲值重置令、專屬稱號、大量修為等免費超值福利，還有回歸活動獎勵加倍、直升丹、天劍令打折、每日福利免費重置等諸多好禮相迎，俠士一日于江湖，江湖未有一日遺忘俠士，找回摯友，再戰江湖！[c8ff00] [url=openwnd:點此瞭解詳情, RegressionPrivilegePanel] [-]", To = pPlayer.dwID}
    -- tbAwardMail.nRecyleTime = nEndTime - GetTime()
    Mail:SendSystemMail(tbAwardMail)
end

-- function RegressionPrivilege:OnVipChanged(nNewLevel, nOldLevel)
--     local pPlayer = me
--     if nOldLevel >= self.LvUp_VipLv or nNewLevel < self.LvUp_VipLv then
--         return
--     end

--     if not self:IsInPrivilegeTime(pPlayer) then
--         return
--     end

--     local nItemTID = DirectLevelUp:GetCanBuyItem()
--     if not nItemTID then
--         return
--     end

--     if DirectLevelUp:CheckHadBuyOne(pPlayer) then
--         return
--     end

--     DirectLevelUp:AddBuyedFlag(pPlayer, nItemTID)
--     local nEndTime = self:GetPrivilegeTime(pPlayer)
--     pPlayer.SendAward({{"Item", nItemTID, 1, nEndTime}}, true, nil, Env.LogWay_RegressionPrivilege)
--     Log("RegressionPrivilege OnVipChanged", pPlayer.dwID, nOldLevel, nNewLevel, nItemTID)
-- end

function RegressionPrivilege:TryGainFreeGift(pPlayer, nId)
    if not self:IsNewVersionPlayer(pPlayer) then
        return
    end

    if not self:CheckFreeGain(pPlayer, nId) then
        return
    end

    local bRet, szMsg = RegressionPrivilege:CheckFreeGainExt(pPlayer, nId)
    if not bRet then
        pPlayer.CenterMsg(szMsg)
        return
    end

    local nFreeGain = pPlayer.GetUserValue(self.GROUP, self.FREE_GAIN)
    nFreeGain = KLib.SetBit(nFreeGain, nId, 1)
    pPlayer.SetUserValue(self.GROUP, self.FREE_GAIN, nFreeGain)
    local tbAward = self:GetFreeGainAward(pPlayer, nId)
    pPlayer.SendAward(tbAward, false, true, Env.LogWay_RegressionPrivilege)
    pPlayer.CenterMsg("領取成功")
    pPlayer.CallClientScript("RegressionPrivilege:OnBuyCallBack")
    Log("RegressionPrivilege TryGainFreeGift", pPlayer.dwID, nId)
end

function RegressionPrivilege:CheckCanBuyDiscdTianJian(pPlayer)
    if not self:IsInPrivilegeTime(pPlayer) then
        return false, "不是回歸玩家，不能購買"
    end

    if pPlayer.GetUserValue(self.GROUP, self.TIANJIAN_FLAG) > 0 then
        return false, "已經購買過了"
    end

    return true
end

function RegressionPrivilege:TryBuyDiscdTianJian(pPlayer)
    local bRet, szMsg = self:CheckCanBuyDiscdTianJian(pPlayer)
    if not bRet then
        pPlayer.CenterMsg(szMsg)
        return
    end

    local fnCostCallback = function (nPlayerId, bSuccess, szBillNo)
        return self:BuyTJSuccess(nPlayerId, bSuccess)
    end

    -- CostGold谨慎调用, 调用前请搜索 _LuaPlayer.CostGold 查看使用说明, 它处调用时请保留本注释
    local bRet = pPlayer.CostGold(self.tbTianJian.nPrice, Env.LogWay_RegressionPrivilege, nil, fnCostCallback)
    if not bRet then
        pPlayer.CenterMsg("支付失敗，請重試")
    end
end

function RegressionPrivilege:BuyTJSuccess(nPlayerId, bSuccess)
    local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
    if not pPlayer then
        return false, "玩家已下線"
    end

    if not bSuccess then
        return false, "購買失敗"
    end

    local bRet, szMsg = self:CheckCanBuyDiscdTianJian(pPlayer)
    if not bRet then
        return false, szMsg
    end

    local nTJ = pPlayer.GetUserValue(self.GROUP, self.TIANJIAN_FLAG)
    pPlayer.SetUserValue(self.GROUP, self.TIANJIAN_FLAG, nTJ + 1)
    pPlayer.SendAward({{"Item", self.tbTianJian.nItemTID, 1}}, true, nil, Env.LogWay_RegressionPrivilege)
    return true
end

function RegressionPrivilege:TryBuyKinDonate(pPlayer)
    if pPlayer.dwKinId == 0 then
        pPlayer.CenterMsg("當前沒有幫派，無法重置")
        return
    end

    local nCanRecoverTimes = pPlayer.GetUserValue(self.GROUP, self.KINDONATE_TIMES)
    if nCanRecoverTimes <= 0 then
        pPlayer.CenterMsg("可重置次數不足")
        return
    end
    local szDegreeKey = "DonationCount"
    local nMax = DegreeCtrl:GetMaxDegree(szDegreeKey, pPlayer)
    local nCur = DegreeCtrl:GetDegree(pPlayer, szDegreeKey)
    if nCur >= nMax then
        pPlayer.CenterMsg("次數已滿，不需重置")
        return
    end

    pPlayer.SetUserValue(self.GROUP, self.KINDONATE_TIMES, nCanRecoverTimes - 1)
    DegreeCtrl:AddDegree(pPlayer, szDegreeKey, nMax - nCur)
    pPlayer.CenterMsg("今日捐獻次數已重置，可以重新捐獻")
    pPlayer.CallClientScript("RegressionPrivilege:OnBuyCallBack")
    pPlayer.CallClientScript("Ui:OpenWindow", "KinVaultPanel")
    Log("RegressionPrivilege TryBuyKinDonate", pPlayer.dwID, nCanRecoverTimes, nMax, nCur)
end

function RegressionPrivilege:TryRefreshShop(pPlayer)
    if pPlayer.nLevel < Shop.SHOW_LEVEL then
        pPlayer.CenterMsg("等級不足，無法重置")
        return
    end

    local nRefreshTimes = pPlayer.GetUserValue(self.GROUP, self.REFRESHSHOP_TIMES)
    if nRefreshTimes <= 0 then
        pPlayer.CenterMsg("重置次數已用完")
        return
    end

    nRefreshTimes = nRefreshTimes - 1
    pPlayer.SetUserValue(self.GROUP, self.REFRESHSHOP_TIMES, nRefreshTimes)
    Shop:RefreshLimitInfo(pPlayer)
    pPlayer.CallClientScript("RegressionPrivilege:OnBuyCallBack")
    pPlayer.CallClientScript("Ui:OpenWindow", "CommonShop", "Treasure")
    pPlayer.CenterMsg("商城優惠購買次數已重置，已為俠士跳轉到優惠商城")
    Log("RegressionPrivilege TryRefreshShop", pPlayer.dwID, nRefreshTimes)
end

function RegressionPrivilege:TryRestoreChuanGong(pPlayer)
    local nCanRecoverTimes = pPlayer.GetUserValue(self.GROUP, self.CHUANGONG_TIMES)
    if nCanRecoverTimes <= 0 then
        return
    end

    if pPlayer.nLevel < ChuangGong.nGetMinLevel then
        pPlayer.CenterMsg("等級不足，無法領取")
        return
    end

    nCanRecoverTimes = nCanRecoverTimes - 1
    pPlayer.SetUserValue(self.GROUP, self.CHUANGONG_TIMES, nCanRecoverTimes)
    DegreeCtrl:AddDegree(pPlayer, "ChuangGong", 1)
    pPlayer.CenterMsg("成功領取了1次被傳功次數")
    pPlayer.CallClientScript("RegressionPrivilege:OnBuyCallBack")
    Log("RegressionPrivilege TryRestoreChuanGong", pPlayer.dwID, nCanRecoverTimes)
end

function RegressionPrivilege:CheckXiulanTime(pPlayer)
    local nCanRecoverTime = pPlayer.GetUserValue(self.GROUP, self.XIULIAN_TIMES)
    if nCanRecoverTime <= 0 then
        return false, "沒有可領取的修煉時間"
    end

    local nCount = pPlayer.GetItemCountInAllPos(1422) --修炼珠
    if nCount <= 0 then
        return false, "沒有修煉珠，無法領取修煉時間"
    end

    local nCanResidueTime = XiuLian.tbDef.nMaxAddXiuLianTime - XiuLian:GetXiuLianResidueTime(pPlayer)
    if nCanResidueTime <= 0 then
        return false, "累積修煉時間已達上限"
    end
    return true, _, math.min(nCanRecoverTime, nCanResidueTime)
end

function RegressionPrivilege:TryAddXiulianTime(pPlayer)
    if not self:IsNewVersionPlayer(pPlayer) then
        return
    end

    local bRet, szMsg, nRecoverTime = self:CheckXiulanTime(pPlayer)
    if not bRet then
        pPlayer.CenterMsg(szMsg)
        return
    end

    local nLastTime = pPlayer.GetUserValue(self.GROUP, self.XIULIAN_TIMES) - nRecoverTime
    pPlayer.SetUserValue(self.GROUP, self.XIULIAN_TIMES, nLastTime)
    XiuLian:AddXiuLianResiduTime(pPlayer, nRecoverTime)
    pPlayer.CenterMsg(string.format("成功領取了%s小時的10倍修煉時間", Lib:TimeDesc(nRecoverTime)))
    pPlayer.CallClientScript("RegressionPrivilege:OnBuyCallBack")
    Log("RegressionPrivilege TryAddXiulianTime", pPlayer.dwID, nRecoverTime)
end

function RegressionPrivilege:TryRestoreMoneyTree(pPlayer)
    local nCurTimes = pPlayer.GetUserValue(self.GROUP, self.MONEYTREE_TIMES)
    if nCurTimes <= 0 then
        pPlayer.CenterMsg("可領取次數不足")
        return
    end

    local bHaveFree = MoneyTree:IsHaveFreeTimes(pPlayer)
    pPlayer.SetUserValue(self.GROUP, self.MONEYTREE_TIMES, nCurTimes - 1)
    local nMoney = MoneyTree:DoShaking(pPlayer)
    if bHaveFree then
        MoneyTree:RestoreFreeTimes(pPlayer)
    end

    pPlayer.CenterMsg(string.format("俠士消耗免費次數搖錢，獲得%d銀兩", nMoney))
    pPlayer.CallClientScript("RegressionPrivilege:OnBuyCallBack")
    Log("RegressionPrivilege TryRestoreMoneyTree", pPlayer.dwID, nCurTimes - 1)
end

function RegressionPrivilege:TryRefreshKinStore(pPlayer)
    if not self:IsNewVersionPlayer(pPlayer) then
        return
    end
    if pPlayer.dwKinId == 0 then
        pPlayer.CenterMsg("當前沒有幫派，無法重置")
        return
    end

    if Shop:GetBuildingLevelServer(pPlayer, Kin.Def.Building_DrugStore) <= 0 then
        pPlayer.CenterMsg("珍寶坊尚未開放")
        return
    end

    local nCanRecoverTimes = pPlayer.GetUserValue(self.GROUP, self.KINSTORE_TIMES)
    if nCanRecoverTimes <= 0 then
        pPlayer.CenterMsg("可重置次數不足")
        return
    end

    Shop:RefreshFamilyShopWare(pPlayer);
    local tbFamilyShopData = pPlayer.GetScriptTable("FamilyShop")
    tbFamilyShopData.nLastDay = Lib:GetLocalDay(GetTime() - Shop.FAMILY_SHOP_REFRESH)

    pPlayer.SetUserValue(self.GROUP, self.KINSTORE_TIMES, nCanRecoverTimes - 1)
    pPlayer.CenterMsg("已刷新珍寶坊商品，俠士可進行購買")
    pPlayer.CallClientScript("RegressionPrivilege:OnBuyCallBack")
    pPlayer.CallClientScript("Ui:OpenWindow", "KinStore", Kin.Def.Building_DrugStore)
    Log("RegressionPrivilege TryRefreshKinStore", pPlayer.dwID, nCanRecoverTimes)
end

function RegressionPrivilege:OnBuyBackGiftSuccess(pPlayer, nGroupIdx, nBuyCount)
    if not self:IsInPrivilegeTime(pPlayer) or not self:IsNewVersionPlayer(pPlayer) then
        return nBuyCount
    end
    if pPlayer.GetVipLevel() < RegressionPrivilege.nRechargeVipLv then
        return nBuyCount
    end
    for _, tbInfo in ipairs(self.RECHARGE_AWARD) do
        if tbInfo.nRechargeIdx == nGroupIdx then
            local nSaveKey = tbInfo.nSaveKey
            local nLastTimes = pPlayer.GetUserValue(self.GROUP, nSaveKey)
            if nLastTimes > 0 then
                local nBuyTimes = math.min(nLastTimes, nBuyCount)
                local tbAllAward = {}
                for i = 1, nBuyTimes do
                    Lib:MergeTable(tbAllAward, tbInfo.tbAward)
                end
                pPlayer.SetUserValue(self.GROUP, nSaveKey, nLastTimes - nBuyTimes)
                pPlayer.SendAward(tbAllAward, true, true, Env.LogWay_RegressionPrivilege)
                pPlayer.CallClientScript("RegressionPrivilege:OnBuyCallBack")
                Log("RegressionPrivilege OnBuyBackGiftSuccess", pPlayer.dwID, nGroupIdx, nBuyCount, nLastTimes, nBuyTimes)
                return nBuyCount - nBuyTimes
            end
            Log("RegressionPrivilege OnBuyBackGiftSuccess Not Times", pPlayer.dwID, nGroupIdx, nBuyCount, nLastTimes)
            return nBuyCount
        end
    end
    Log("RegressionPrivilege OnBuyBackGiftSuccess GroupIdx Err", pPlayer.dwID, nGroupIdx, nBuyCount)
    return nBuyCount
end

function RegressionPrivilege:GetDoubleAward(pPlayer, szAct, tbSrcAward)
    if not pPlayer then
        return false, nil, tbSrcAward
    end

    if not self:IsInPrivilegeTime(pPlayer) or not self:IsNewVersionPlayer(pPlayer) then
        return false, nil, tbSrcAward
    end

    local tbInfo = self.DOUBLE_ACT[szAct]
    if not tbInfo then
        return false, nil, tbSrcAward
    end

    local nLastTime = pPlayer.GetUserValue(self.GROUP, tbInfo.nSaveKey)
    if nLastTime <= 0 then
        return false, nil, tbSrcAward
    end

    local tbFinalAward
    if tbSrcAward then
        tbFinalAward = {unpack(tbSrcAward)}
        local nSrcAwardLen = #tbSrcAward
        for i = 1, nSrcAwardLen do
            tbFinalAward[nSrcAwardLen + i] = tbSrcAward[i]
        end
    end
    nLastTime = nLastTime - 1
    pPlayer.SetUserValue(self.GROUP, tbInfo.nSaveKey, nLastTime)
    Log("RegressionPrivilege ReduceDoubleAward Times:", pPlayer.dwID, szAct, nLastTime)
    return true, tbInfo.szMsg, tbFinalAward
end

function RegressionPrivilege:OnGainEverydayTargetAward(pPlayer, nAwardIdx)
    if not self:IsInPrivilegeTime(pPlayer) then
        return
    end

    if not self:IsNewVersionPlayer(pPlayer) then
        return
    end

    local nLastTime = pPlayer.GetUserValue(self.GROUP, self.DayTargetEXT.nSaveKey)
    if nLastTime <= 0 then
        return
    end

    local tbAward = self.tbDayTargetAward[nAwardIdx]
    if not tbAward then
        return
    end

    nLastTime = nLastTime - 1
    pPlayer.SetUserValue(self.GROUP, self.DayTargetEXT.nSaveKey, nLastTime)
    pPlayer.SendAward(tbAward, true, false, Env.LogWay_RegressionPrivilege)
    pPlayer.CenterMsg("每日目標回歸額外獎勵", true)
    Log("RegressionPrivilege OnGainEverydayTargetAward", pPlayer.dwID, nLastTime, nAwardIdx)
end

function RegressionPrivilege:OnNewServerActOpen(nVersion, nCreateTime, tbRechargeInfo)
    self.tbNewServerActInfo = {nVersion = nVersion, nCreateTime = nCreateTime, tbRechargeInfo = tbRechargeInfo}

    local tbAllPlayer = KPlayer.GetAllPlayer()
    for _, pPlayer in ipairs(tbAllPlayer) do
        if self:IsInPrivilegeTime(pPlayer) and tbRechargeInfo[pPlayer.szAccount] then
            self:ResetBeginTime(pPlayer, nVersion)
            Log("RegressionPrivilege OnNewServerActOpen Freeze Privilege", pPlayer.dwID)
        end
    end
end

function RegressionPrivilege:OnNewServerActClose()
    self.tbNewServerActInfo = nil
end

function RegressionPrivilege:IsInPrivilegeCD(pPlayer)
    local nCurPrivilege = pPlayer.GetUserValue(self.GROUP, self.BEGIN_TIME)
    return nCurPrivilege + self.Privilege_CD > GetTime()
end

RegressionPrivilege.tbClientSafeCall = {
    TryBuyKinDonate      = 1,
    TryRefreshShop       = 1,
    TryRestoreChuanGong  = 1,
    TryRestoreMoneyTree  = 1,
    TryBuyDiscdTianJian  = 1,
    TryAddXiulianTime    = 1,
    TryGainFreeGift      = 1,
    TryRefreshKinStore   = 1,
}
function RegressionPrivilege:OnClientCall(pPlayer, szFunc, ...)
    if not szFunc or not self[szFunc] or not self.tbClientSafeCall[szFunc] then
        Log("RegressionPrivilege Try Call NotSafeFunc", pPlayer.dwID, szFunc)
        return
    end

    if not self:IsInPrivilegeTime(pPlayer) then
        pPlayer:CenterMsg("不是回歸玩家，不能進行該操作")
        return
    end

    if pPlayer.GetUserValue(self.GROUP, self.PAUSE_FLAG) > 0 and self.tbNewServerActInfo then
        return
    end

    self[szFunc](self, pPlayer, ...)
end