local tbItem = Item:GetClass("RegressionGift")

--等级对应的返还元宝比例
tbItem.LEVEL_GOLD_PERCENT = {
                            {1, 10},
                            {20, 10},
                            {30, 10},
                            {40, 15},
                            {50, 15},
                            {55, 15},
                            {60, 15},
                            {65, 15},
                            {70, 15},
                            {80, 20},
                            {90, 15},
                            {100, 15},
                            {110, 15},
                            {120, 15},
                            }

function tbItem:OnUse(pItem)
    return self:TryGainNewServerGift(me)
end

function tbItem:GetTip()
    local nGainLevel = me.GetUserValue(RegressionPrivilege.GROUP, RegressionPrivilege.GAINED_MAXLEVEL)
    for i, tbInfo in ipairs(self.LEVEL_GOLD_PERCENT) do
        if tbInfo[1] > nGainLevel then
            if me.nLevel >= tbInfo[1] then
                return string.format("開啟可獲得%d%%的元寶返還", tbInfo[2])
            else
                return string.format("開啟等級：%d級", tbInfo[1])
            end
        end
    end
    return "尚未開放"
end

function tbItem:TryGainNewServerGift(pPlayer)
    local nTotalRecharge = pPlayer.GetUserValue(RegressionPrivilege.GROUP, RegressionPrivilege.TOTAL_RECHARGE)
    if nTotalRecharge <= 0 then
        Log("RegressionGift Err", pPlayer.dwID)
        return
    end

    local nGainLevel = pPlayer.GetUserValue(RegressionPrivilege.GROUP, RegressionPrivilege.GAINED_MAXLEVEL)
    for i, tbInfo in ipairs(self.LEVEL_GOLD_PERCENT) do
        local nLevel = tbInfo[1]
        if nLevel > nGainLevel then
            if pPlayer.nLevel < nLevel then
                pPlayer.CenterMsg(string.format("需%d才能領取", nLevel))
                return 0
            else
                local nPercent = tbInfo[2]
                local nGold = math.floor(nTotalRecharge * nPercent / 100)
                pPlayer.SetUserValue(RegressionPrivilege.GROUP, RegressionPrivilege.GAINED_MAXLEVEL, nLevel)
                pPlayer.SendAward({{"Gold", nGold}}, true, nil, Env.LogWay_RegressionPrivilege_O2N)
                Log("RegressionGift TryGainNewServerGift", pPlayer.dwID, nLevel, nPercent)
                return i == #self.LEVEL_GOLD_PERCENT and 1 or 0
            end
        end
    end
end
