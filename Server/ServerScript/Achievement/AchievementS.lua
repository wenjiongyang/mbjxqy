function Achievement:OnUpdateCount(pPlayer, szSubKind, nCount)
    if self.tbLegal[szSubKind] then
        self:AddCount(pPlayer, szSubKind, nCount);
    end
end

--player可以是玩家ID或者玩家对象，真·支持离线
function Achievement:AddCount(player, szSubKind, nAddCount)
    if not szSubKind or not self.tbSubKindSetting[szSubKind] then
        Log("Achievement AddCount Err No SubKind or SubKindErr", szSubKind, nAddCount)
        return
    end

    nAddCount = nAddCount or 1
    if nAddCount <= 0 then
        return
    end

    local pPlayer = player
    if type(player) == "number" then
        pPlayer = KPlayer.GetPlayerObjById(player)
        if not pPlayer then
            KPlayer.AddDelayCmd(player,
                string.format("Achievement:AddCount(me, '%s', %d)", szSubKind, nAddCount),
                string.format("Achievement AddCount By DelayCmd: %d, %s, %d", player, szSubKind, nAddCount))
            return
        end
    end

    if not pPlayer then
        Log("Achievement AddCount Err PlayerErr")
        return
    end

    if self:IsSubKindCompleted(pPlayer, szSubKind) then
        return
    end

    local nCurCount = self:GetSubKindCount(pPlayer, szSubKind)
    self:SaveSubKindCount(pPlayer, szSubKind, nCurCount + nAddCount)
    self:OnCountChange(pPlayer, szSubKind, nCurCount, nCurCount + nAddCount)
end

function Achievement:SetCount(pPlayer, szSubKind, nCount)
    if not pPlayer or not szSubKind or not nCount or not self.tbSubKindSetting[szSubKind] then
        return
    end

    if self:IsSubKindCompleted(pPlayer, szSubKind) then
        return
    end

    local nCurCount = self:GetSubKindCount(pPlayer, szSubKind)
    if nCount < nCurCount then
        return
    end

    self:SaveSubKindCount(pPlayer, szSubKind, nCount)
    self:OnCountChange(pPlayer, szSubKind, nCurCount, nCount)
end

function Achievement:IsSubKindCompleted(pPlayer, szSubKind)
    local nCurCount = self:GetSubKindCount(pPlayer, szSubKind)
    local nMaxCount = self:GetKindMaxCount(szSubKind)
    return nCurCount >= nMaxCount
end

function Achievement:OnCountChange(pPlayer, szSubKind, nCurCount, nNewCount)
    local tbCountList  = self:GetKindCountList(szSubKind)
    local szMainKind   = self:GetMainKindKey(szSubKind)
    local bNeedNotify  = false
    for _, tbCount in ipairs(tbCountList) do
        local nCount = tbCount[2]
        if nCurCount < nCount and nNewCount >= nCount then
            local nCompletedLevel = tbCount[1]
            pPlayer.OnEvent("OnAchievementCompleted", szMainKind, szSubKind, nCompletedLevel)

            self:SendCompleteSysMsg(pPlayer, szMainKind, nCompletedLevel)
            bNeedNotify = true

            pPlayer.TLog("TaskFlow", pPlayer.nLevel, pPlayer.GetVipLevel(), Env.LogWay_AchievementAward, self:GetGroupKey(szMainKind) * 1000 + nCompletedLevel, 1)

        end
    end

    if bNeedNotify then
        pPlayer.CallClientScript("Achievement:OnCountChange", szSubKind, nCurCount, nNewCount)
    end
end

function Achievement:SendCompleteSysMsg(pPlayer, szMainKind, nCompletedLevel)
    local szMsg = self:GetPushMsg(szMainKind, nCompletedLevel)
    if szMsg and pPlayer.dwKinId ~= 0 then
        szMsg = string.format("「%s」%s", pPlayer.szName, szMsg)
        ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, pPlayer.dwKinId, 
            { nLinkType = ChatMgr.LinkType.Achievement, szComName = pPlayer.szName, szKind = szMainKind, nLevel = nCompletedLevel })
    end
end

function Achievement:TryGainAward(pPlayer, szMainKind, nGainLevel)
    if not pPlayer or not szMainKind then
        return;
    end

    nGainLevel = nGainLevel or (self:GetGainLevel(pPlayer, szMainKind) + 1)
    if not self:CheckCanGainAward(pPlayer, szMainKind, nGainLevel) then
        return
    end

    local nMaxLevel  = self:GetMaxLevel(szMainKind)
    if nGainLevel > nMaxLevel then
        return
    end

    local bComplete = self:CheckCompleteLevel(pPlayer, szMainKind, nGainLevel)
    if not bComplete then
        return
    end

    self:SetGainLevel(pPlayer, szMainKind, nGainLevel);

    local tbAward = self:GetAwardInfo(szMainKind, nGainLevel)
    if tbAward and next(tbAward) then
        pPlayer.SendAward(tbAward, false, true, Env.LogWay_AchievementAward);
        Log("Achievement TryGainAward GetAward", pPlayer.dwID, szMainKind, nGainLevel)
    end

    pPlayer.CallClientScript("Achievement:OnGainAwardRsp", szMainKind);
end

function Achievement:CheckCanGainAward(pPlayer, szMainKind, nGainLevel)
    if not pPlayer or not szMainKind or not nGainLevel then
        return;
    end

    local nGroupID = self:GetGroupKey(szMainKind)
    if not nGroupID then
        Log("Achievement:SetGainLevel >>>>", szMainKind, nGainLevel)
        return
    end

    local nGainFlag = pPlayer.GetUserValue(self.MAINDATA_GROUD_ID, nGroupID)
    nGainFlag = KLib.GetBit(nGainFlag, nGainLevel)
    return nGainFlag == 0
end

function Achievement:SetGainLevel(pPlayer, szMainKind, nGainLevel)
    if not pPlayer or not szMainKind or not nGainLevel then
        return;
    end

    local nGroupID = self:GetGroupKey(szMainKind)
    if not nGroupID then
        Log("Achievement:SetGainLevel >>>>", szMainKind, nGainLevel)
        return
    end

    local nGainFlag = pPlayer.GetUserValue(self.MAINDATA_GROUD_ID, nGroupID)
    nGainFlag = KLib.SetBit(nGainFlag, nGainLevel, 1)
    pPlayer.SetUserValue(self.MAINDATA_GROUD_ID, nGroupID, nGainFlag)
end

function Achievement:SaveSubKindCount(pPlayer, szSubKind, nCount)
    if not pPlayer or not szSubKind or not nCount then
        return;
    end

    local nGroupKey, nValueKey = self:GetCountSaveKey(szSubKind);
    if not nGroupKey or not nValueKey then
        Log("Achievement ERR: GetSaveKey Fail ", nGroupKey);
        return;
    end

    pPlayer.SetUserValue(nGroupKey, nValueKey, nCount);
end

function Achievement:OnRequestCheckAchievementFinish(pPlayer, tbCheckAchi)
    if not tbCheckAchi then
        return
    end

    for i,v in ipairs(tbCheckAchi) do
        local szMainKind, nLevel = unpack(v)
        local bRet,nCount = self:CheckSpecilAchievementFinish(pPlayer, szMainKind, nLevel);
        if bRet then
            local szSubKind = self:GetSubKind(szMainKind, nLevel)
            if szSubKind then
                self:AddCount(pPlayer, szSubKind, nCount)
                Log("Achievement:OnRequestCheckAchievementFinish", pPlayer.dwID, szSubKind, nCount)
            end
        end    
    end
end