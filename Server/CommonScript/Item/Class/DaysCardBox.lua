local tbItem = Item:GetClass("DaysCardBox")

function tbItem:CheckUse(it)
    local nLeftDay = Recharge:GetDaysCardLeftDay(me, 1)
    if nLeftDay <= 0 then
        return false, "無法開啟禮包，少俠當前不處於7日禮包時效內"
    end

    return true
end

function tbItem:OnUse(it)
    local bRet, szMsg = self:CheckUse(it)
    if not bRet then
        me.CenterMsg(szMsg)
        return
    end

    local nItemTID = KItem.GetItemExtParam(it.dwTemplateId, 1)
    if nItemTID <= 0 then
        return
    end

    me.SendAward({{"Item", nItemTID, 1}}, nil, nil, Env.LogWay_FirstRechargeAward)
    return 1
end

function tbItem:OnClientUse(it)
    local bRet, szMsg = self:CheckUse(it)
    if not bRet then
        local fnGo = function ()
            Ui:OpenWindow("WelfareActivity","RechargeGift")
        end
    
        me.MsgBox("無法開啟禮包，少俠當前不處於[FFFE0D]7日禮包[-]時效期內。", {{"前往購買", fnGo}, {"暫不購買"}})
        return 1
    end
end