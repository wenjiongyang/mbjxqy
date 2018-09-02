local tbAct = Activity:GetClass("WishAct")
tbAct.tbTimerTrigger = 
{
    --[1] = {szType = "Day", Time = "4:00", Trigger = "SendAwardEmail"},
    [2] = {szType = "Day", Time = "0:01", Trigger = "SendEndAward"},
}
tbAct.tbTrigger  =
{   Init  = {},
    Start = {{"StartTimerTrigger", 1}, {"StartTimerTrigger", 2}},
    End   = {},
   -- SendAwardEmail = {},
    SendEndAward = {},
}

tbAct.KINNUM_INONETB = 3
tbAct.nSendAwardDay = 3
--tbAct.tbWishAward = {{"Item", 3591, 1}} --许愿奖励
tbAct.tbRankAward = {
    {1, {{"AddTimeTitle", 5037, 15*24*60*60}}},
    {2, {{"AddTimeTitle", 5038, 15*24*60*60}}},
    {3, {{"AddTimeTitle", 5038, 15*24*60*60}}},
    {4, {{"AddTimeTitle", 5039, 15*24*60*60}}},
    {5, {{"AddTimeTitle", 5039, 15*24*60*60}}},
    {6, {{"AddTimeTitle", 5039, 15*24*60*60}}},
}

function tbAct:OnTrigger(szTrigger)
    if szTrigger == "Start" then
        self:AddScriptDataDef()
        Activity:RegisterPlayerEvent(self, "Act_Wish_OnClientCall", "OnClientCall")
    elseif szTrigger == "End" then
        self:ClearData()
    elseif szTrigger == "SendAwardEmail" then
       -- self:SendAwardEmail()
    elseif szTrigger == "SendEndAward" then
        self:SendEndAward()
    end
end

function tbAct:SendAwardEmail()
    local nStartTime = self:GetOpenTimeInfo()
    local nStartDay = Lib:GetLocalDay(nStartTime)
    local nLocalDay = Lib:GetLocalDay()
    if nLocalDay ~= nStartDay + self.nSendAwardDay - 1 then
        return
    end
    local tbMail = {
        Title = "獨孤劍的臘八賀信",
        Text = "    臘八佳節將至，多謝諸位近日為江湖懲戒奸邪！此行頗有所獲，我等繳獲了一大批臘八粥，正好贈予諸位俠士過節！只需在服下此粥，借助幫派烤火時的熱力，便可獲得[FFFE0D]額外的烤火經驗加成[-]。粥的效力[FFFE0D]有效期23小時[-]，不必擔心誤服。\n    冬日佳節，惟願君健康安好，平安而至。",
        LevelLimit = 20,
        tbAttach = {{"Item", 3589, 1, GetTime()+24*3600}},
        nLogReazon = Env.LogWay_WishAct,
    }
    Mail:SendGlobalSystemMail(tbMail)
end

function tbAct:GetData(nKinId)
    local tbMainData = ScriptData:GetValue("WishActMain")
    tbMainData.tbKinDataSaveKey = tbMainData.tbKinDataSaveKey or {}
    tbMainData.tbDynamicKey = tbMainData.tbDynamicKey or {}
    local szDataKey = tbMainData.tbKinDataSaveKey[nKinId]
    if not szDataKey then
        local nSubLen = #tbMainData.tbDynamicKey
        szDataKey = "WishActSub_" .. nSubLen
        if nSubLen == 0 or tbMainData.tbDynamicKey[nSubLen][2] >= self.KINNUM_INONETB then
            nSubLen = nSubLen + 1
            szDataKey = "WishActSub_" .. nSubLen
            ScriptData:AddDef(szDataKey)
            table.insert(tbMainData.tbDynamicKey, {szDataKey, 1})
        else
            tbMainData.tbDynamicKey[nSubLen][2] = tbMainData.tbDynamicKey[nSubLen][2] + 1
        end
        tbMainData.tbKinDataSaveKey[nKinId] = szDataKey
    end
    local tbSubData = ScriptData:GetValue(szDataKey)
    tbSubData[nKinId] = tbSubData[nKinId] or {}
    return tbSubData[nKinId], szDataKey
end

function tbAct:CheckPlayerData(pPlayer)
    local nStartTime = self:GetOpenTimeInfo()
    local nStartDay = Lib:GetLocalDay(nStartTime)
    if nStartDay == pPlayer.GetUserValue(self.GROUP, self.DATA_VERSION) then
        return
    end

    pPlayer.SetUserValue(self.GROUP, self.DATA_VERSION, nStartDay)
    pPlayer.SetUserValue(self.GROUP, self.WISH_COUNT, 0)
    for i = self.LIKE_BEGIN, self.LIKE_END do
        pPlayer.SetUserValue(self.GROUP, i, 0)
    end
end

function tbAct:CheckWish(pPlayer, szMsg, nWishType, bNotCheckGold)
    if GetTime() >= self.nTrueEndTime then
        return false, self.nErrCode_NoInTime
    end
    self:CheckPlayerData(pPlayer)
    if pPlayer.GetUserValue(self.GROUP, self.WISH_COUNT) > 0 then
        return false, self.nErrCode_NoWishTime
    end

    local kinData = Kin:GetKinById(pPlayer.dwKinId)
    if not kinData then
        return false, self.nErrCode_NoKin
    end

    local bRet, nErrCode = self:CheckWishContent(szMsg)
    if not bRet then
        return false, nErrCode
    end

    if nWishType == self.Wish_Type_Pay then
        if not bNotCheckGold and pPlayer.GetMoney("Gold") < self.nPayWishCost then
            return false, self.nErrCode_LackGold
        end
    end

    return true
end

function tbAct:TryWish(pPlayer, szMsg, nWishType)
    if not nWishType or (nWishType ~= self.Wish_Type_Free and nWishType ~= self.Wish_Type_Pay) then
        return
    end

    local bRet, nErrCode = self:CheckWish(pPlayer, szMsg, nWishType)
    if not bRet then
        pPlayer.CenterMsg(pPlayer, self.tbErrMsg[nErrCode])
        return
    end

    if nWishType == self.Wish_Type_Free then
        self:DoWish(pPlayer.dwID, true, nil, szMsg, nWishType)
    elseif nWishType == self.Wish_Type_Pay then
        local function fnCostCallback(nPlayerId, bSuccess, szBillNo, szMsg, nWishType)
            return self:DoWish(nPlayerId, bSuccess, szBillNo, szMsg, nWishType)
        end
        -- CostGold谨慎调用, 调用前请搜索 _LuaPlayer.CostGold 查看使用说明, 它处调用时请保留本注释
        local bRet = pPlayer.CostGold(self.nPayWishCost, Env.LogWay_WishAct, nil, fnCostCallback, szMsg, nWishType);
        if not bRet then
            pPlayer.CenterMsg("支付失敗請稍後再試！");
            Log("[WishAct] fnCostCallback fail", pPlayer.dwID, pPlayer.szName, szMsg, nWishType)
        end
    end
end

function tbAct:DoWish(nPlayerId, bSuccess, szBillNo, szMsg, nWishType)
    if not bSuccess then
        return false, "支付失敗請稍後再試！";
    end

    local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
    if not pPlayer then
        return false, "扣除手續費中途, 您掉線了！";
    end

    local bRet, nErrCode = self:CheckWish(pPlayer, szMsg, nWishType, true)
    if not bRet then
        pPlayer.CenterMsg(pPlayer, self.tbErrMsg[nErrCode])
        return false, self.tbErrMsg[nErrCode]
    end

    pPlayer.SetUserValue(self.GROUP, self.WISH_COUNT, 1)
    local tbKinData, szKey = self:GetData(pPlayer.dwKinId)
    local tbWishData = {
        pPlayer.dwID,
        pPlayer.szName,
        pPlayer.nPortrait,
        pPlayer.nFaction,
        0,
        szMsg,
    }
    table.insert(tbKinData, tbWishData)
    ScriptData:AddModifyFlag(szKey)

    local tbAward = self.tbWishAward and self.tbWishAward[nWishType]
    if tbAward then
        local tbTempAward = Lib:CopyTB(tbAward)
        tbTempAward[1][4] = self.nTrueEndTime
        pPlayer.SendAward(tbTempAward, true, false, Env.LogWay_WishAct)
    end
    
    if #tbKinData <= 10 then
        pPlayer.CallClientScript("Activity.WishAct:OnDataUpdate", "Wish", tbWishData)
    end

    local szTip = string.format("%s在幫派許願樹上掛上自己的願望：「%s」", pPlayer.szName, szMsg)
    if nWishType == self.Wish_Type_Free then
        if pPlayer.dwKinId > 0 then
            ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szTip, pPlayer.dwKinId);
        end
    elseif nWishType == self.Wish_Type_Pay then
        szTip = string.format("%s在幫派許願樹許下自訂願望「%s」", pPlayer.szName, szMsg)
        if pPlayer.dwKinId > 0 then
            ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szTip, pPlayer.dwKinId);
        end
        KPlayer.SendWorldNotify(0, 999, szTip, 1, 1);
    end

    pPlayer.CenterMsg("許願成功")

    Log("WishAct AddWish", pPlayer.dwID, szMsg)
end

function tbAct:TryLike(pPlayer, nTarPlayerId)
    local nRet, nErrCode = self:CheckLike(pPlayer, nTarPlayerId)
    if not nRet then
        pPlayer.CenterMsg(self.tbErrMsg[nErrCode])
        return
    end

    for i = self.LIKE_BEGIN, self.LIKE_END do
        if pPlayer.GetUserValue(self.GROUP, i) == 0 then
            pPlayer.SetUserValue(self.GROUP, i, nTarPlayerId)
            break
        end
    end

    local tbData, szKey = self:GetData(pPlayer.dwKinId)
    local nIndex = nRet
    tbData[nIndex][self.LIKE] = tbData[nIndex][self.LIKE] + 1
    local nInsertPos
    for i = nIndex - 1, 1, -1 do
        if tbData[nIndex][self.LIKE] <= tbData[i][self.LIKE] then
            break
        end
        nInsertPos = i
    end
    if nInsertPos then
        local tbInfo = table.remove(tbData, nIndex)
        table.insert(tbData, nInsertPos, tbInfo)
    end
    ScriptData:AddModifyFlag(szKey)
    pPlayer.CallClientScript("Activity.WishAct:OnDataUpdate", "Like", {nTarPlayerId})
    pPlayer.CenterMsg("點贊成功")
    Log("WishAct TryLike", pPlayer.dwKinId, nTarPlayerId, nIndex, nInsertPos)
end

function tbAct:AddScriptDataDef()
    local tbMainData = ScriptData:GetValue("WishActMain")
    tbMainData.tbKinDataSaveKey = tbMainData.tbKinDataSaveKey or {}
    tbMainData.tbDynamicKey = tbMainData.tbDynamicKey or {}
    for _, tbInfo in ipairs(tbMainData.tbDynamicKey) do
        ScriptData:AddDef(tbInfo[1])
    end
end

function tbAct:SendEndAward()
    local nTrueEndDay = Lib:GetLocalDay(self.nTrueEndTime)
    local nLocalDay = Lib:GetLocalDay()
    if nLocalDay ~= nTrueEndDay then
        return
    end

    local tbMainData = ScriptData:GetValue("WishActMain")
    tbMainData.tbKinDataSaveKey = tbMainData.tbKinDataSaveKey or {}
    for nKinId, szSaveKey in pairs(tbMainData.tbKinDataSaveKey) do
        local tbData = ScriptData:GetValue(szSaveKey)
        for nRank, tbInfo in ipairs(tbData[nKinId] or {}) do
            local tbAward = self:GetAward(nRank)
            if not tbAward then
                break
            end
            local nPlayerId = tbInfo[self.PLAYERID]
            local szContent = string.format("恭喜俠士在幫派許願活動中排名第%d，獲得稱號獎勵", nRank)
            local tbMail = {Title = "許願排名獎勵", From = "幫派總管", nLogReazon = Env.LogWay_WishAct, Text = szContent, To = nPlayerId, tbAttach = tbAward}
            Mail:SendSystemMail(tbMail)
            Log("WishAct SendEndAward ok", nKinId, nPlayerId, nRank)
        end
    end
    Log("WishAct SendEndAward >>")
end

function tbAct:GetAward(nRank)
    for _, tbInfo in ipairs(self.tbRankAward) do
        if nRank <= tbInfo[1] then
            local tbAllReward = Lib:CopyTB(tbInfo[2])
            local tbFormatReward = {}
            for _,tbReward in ipairs(tbAllReward) do
                if tbReward[1] == "AddTimeTitle" then
                    tbReward[3] = tbReward[3] + GetTime()
                end
                table.insert(tbFormatReward,tbReward)
            end
            return tbFormatReward
        end
    end
end

function tbAct:ClearData()
    local tbMainData = ScriptData:GetValue("WishActMain")
    tbMainData.tbKinDataSaveKey = tbMainData.tbKinDataSaveKey or {}
    tbMainData.tbDynamicKey = tbMainData.tbDynamicKey or {}
    for _, tbInfo in ipairs(tbMainData.tbDynamicKey) do
        ScriptData:SaveValue(tbInfo[1], {})
    end
    ScriptData:SaveValue("WishActMain", {})
end

function tbAct:TryGetData(pPlayer)
    local kinData = Kin:GetKinById(pPlayer.dwKinId)
    if not kinData then
        return
    end

    self:CheckPlayerData(pPlayer)
    local tbData = self:GetData(pPlayer.dwKinId)
    pPlayer.CallClientScript("Activity.WishAct:OnDataUpdate", "Data", tbData)
end

tbAct.tbSafeCall = {
    ["TryLike"] = true,
    ["TryWish"] = true,
    ["TryGetData"] = true,
}
function tbAct:OnClientCall(pPlayer, szFunc, ...)
    if not self.tbSafeCall[szFunc] then
        return
    end
    self[szFunc](self, pPlayer, ...)
end