local tbFuben = Fuben:CreateFubenClass("WhiteTigerFubenCross")
tbFuben.FLOOR_2 = 2
tbFuben.FLOOR_4 = 4

tbFuben.NPC_VALUE = 
{
    [Fuben.WhiteTigerFuben.CROSS_BOSS_TID] = 1280000,
    [Fuben.WhiteTigerFuben.CROSS_FLOOR_BOSS_TID] = 480000,
}
tbFuben.PLAYER_VALUE = 30000

function tbFuben:OnPreCreate()
    self.tbComboInfo = {}
    self.tbRoomBoss = {}
    self.tbKinKillValue = {}
    self.tbKinJoinPlayer = {}
end

function tbFuben:OnLogin(bReConnect)
    self:OpenFubenTips(me)
end

function tbFuben:OnJoin(pPlayer)
    pPlayer.bForbidChangePk = 0
    pPlayer.SetPkMode(Player.MODE_PK)
    pPlayer.bForbidChangePk = 1

    local nKinId = pPlayer.dwKinId
    self.tbKinJoinPlayer[nKinId] = self.tbKinJoinPlayer[nKinId] or {}
    self.tbKinJoinPlayer[nKinId][pPlayer.dwID] = true
    self:OpenFubenTips(pPlayer)
    Log("WhiteTigerFuben_Cross OnJoin:", pPlayer.dwID, nKinId)
end

function tbFuben:OpenFubenTips(pPlayer)
    local tbInfo = {self.nShowEndTime or 0, self.bClose == 1, true}
    pPlayer.CallClientScript("Ui:OpenWindow", "HomeScreenFuben", "WhiteTigerFuben", tbInfo)
    if self.tbCacheProgressInfo then
        me.CallClientScript("Fuben:SetFubenProgress", unpack(self.tbCacheProgressInfo))
    end
end

function tbFuben:OnPlayerDeath(pKiller)
    self:Back2World(me)

    if not pKiller then
        return
    end
    local pPlayer = pKiller.GetPlayer()
    if pPlayer then
        -- Achievement:AddCount(pPlayer, "WhiteTiger_2")

        local dwID = pPlayer.dwID
        self.tbComboInfo[dwID] = self.tbComboInfo[dwID] and self.tbComboInfo[dwID] + 1 or 1
        pPlayer.CallClientScript("Ui:ShowComboKillCount", self.tbComboInfo[dwID])
        if pPlayer.dwKinId > 0 then
            local nCombo = self.tbComboInfo[dwID]
            if nCombo >= 20 and nCombo <= 100 and nCombo%10 == 0 then
                local szMsg = string.format("「%s」在白虎堂中，連斬%d人！", pPlayer.szName, nCombo)
                -- ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, pPlayer.dwKinId)
            end
        end
    end
end

function tbFuben:Back2World(pPlayer)
    local nPlayerId = pPlayer.dwID
    local nWs = Fuben.WhiteTigerFuben:GetWsByKinId(pPlayer)
    if nWs then
        CallZoneClientScript(nWs, "Fuben.WhiteTigerFuben:OnLeaveCross", nPlayerId)
    end
    -- 注意，此处凶险，如果在OnDeath里面Logout会导致宕机
    Timer:Register(1, function ()
        local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
        if not pPlayer then
            return
        end
        pPlayer.Revive(0)
        pPlayer.ZoneLogout()
        Log("WhiteTigerFuben_Cross Back2World", nPlayerId)
    end)
end

function tbFuben:AddNpc(nIndex, nNum, nLock, szGroup, szPointName, bRevive, nDir, nDealyTime, nEffectId, nEffectTime, ...)
    self:_AddNpc(nIndex, nNum, nLock, szGroup, szPointName, bRevive, nDir, nDealyTime, nEffectId, nEffectTime, ...)
end

function tbFuben:OnAddNpc(pNpc, nFloor, nRoomIdx)
    if not pNpc or not nFloor or not nRoomIdx then
        return
    end
    if nFloor == self.FLOOR_2 or nFloor == self.FLOOR_4 then
        self.tbRoomBoss[pNpc.nId] = {nFloor = nFloor, nRoomIdx = nRoomIdx}
    end
end

-- 删除特定组的NPC
function tbFuben:DelNpc(szGroup)
    if not self.tbNpcGroup[szGroup] then
        Log("[Fuben]DelNpc szGroup is not Exist", szGroup);
        return;
    end

    for _, nId in pairs(self.tbNpcGroup[szGroup]) do
        local pNpc = KNpc.GetById(nId);
        if pNpc then
            local tbRoomInfo = self.tbRoomBoss[pNpc.nId]
            if tbRoomInfo then
                if tbRoomInfo.nFloor == self.FLOOR_4 then
                    local nKinId = self:CalcBossDamage(pNpc)
                    Fuben.WhiteTigerFuben:SendCrossAward(self.nMapId, self.tbKinKillValue, self.tbKinJoinPlayer, nKinId)
                else
                    self:CalcBossHpPercent(pNpc)
                end
                self.tbRoomBoss[pNpc.nId] = nil
            end
            pNpc.Delete();
        end
    end
    self.tbNpcGroup[szGroup] = nil;
end

function tbFuben:CalcBossHpPercent(pNpc)
    local nCurLife = pNpc.nCurLife
    local nMax = pNpc.nMaxLife or 1
    local nPercent = (nMax - nCurLife)/nMax
    if nPercent <= 0 or nPercent > 1 then
        Log("WhiteTigerFubenCrossBase CalcBossHpPercent Err", self.nMapId, pNpc.nId, pNpc.nTemplateId, nPercent)
        return
    end

    local tbRoomInfo = self.tbRoomBoss[pNpc.nId]
    local nKinId = Fuben.WhiteTigerFuben:GetKinIdByMap(self.nMapId, tbRoomInfo.nRoomIdx)
    if not nKinId then
        return
    end

    local nValue = nPercent * self.NPC_VALUE[pNpc.nTemplateId]
    self.tbKinKillValue[nKinId] = self.tbKinKillValue[nKinId] or 0
    self.tbKinKillValue[nKinId] = self.tbKinKillValue[nKinId] + nValue
    Log("CalcBossHpPercent:", nKinId, self.tbKinKillValue[nKinId], pNpc.nTemplateId, nPercent)
end

function tbFuben:CalcBossDamage(pNpc)
    local tbKin, tbKinSort = Fuben.WhiteTigerFuben:GetKillNpcKin(pNpc)
    local nMaxLife = pNpc.nMaxLife
    local nBossValue = self.NPC_VALUE[pNpc.nTemplateId]
    for nKinId, nDamage in pairs(tbKinSort) do
        local nPercent = nDamage/nMaxLife
        local nValue = nPercent * nBossValue
        self.tbKinKillValue[nKinId] = self.tbKinKillValue[nKinId] or 0
        self.tbKinKillValue[nKinId] = self.tbKinKillValue[nKinId] + nValue
    end
    Lib:LogTB(self.tbKinKillValue)
    return tbKin[1]
end

function tbFuben:OnKillNpc(pNpc, pKiller)
    if not self.tbRoomBoss[pNpc.nId] then
        return
    end
    local nKillKinId = self:CalcBossDamage(pNpc)
    self.tbRoomBoss[pNpc.nId] = nil
    if pNpc.nTemplateId ~= Fuben.WhiteTigerFuben.CROSS_BOSS_TID then
        return
    end
    self:SendRedbag(pKiller)
    self:CalcKinValue()
    Fuben.WhiteTigerFuben:SendCrossAward(self.nMapId, self.tbKinKillValue, self.tbKinJoinPlayer, nKillKinId)
end

function tbFuben:SendRedbag(pKiller)
    if pKiller.GetPlayer() then
        pKiller = pKiller.GetPlayer()
    end

    if not pKiller.dwID then
        return
    end

    local nWs = Fuben.WhiteTigerFuben:GetWsByKinId(pKiller)
    if nWs then
        CallZoneClientScript(nWs, "Fuben.WhiteTigerFuben:OnCrossTopBossKill", pKiller.dwID)
    end
end

function tbFuben:CalcKinValue()
    for nKinId, nValue in pairs(self.tbKinKillValue or {}) do
        local nJoinNum = 0
        for nPlayerId, _ in pairs(self.tbKinJoinPlayer[nKinId] or {}) do
            nJoinNum = nJoinNum + 1
        end
        self.tbKinKillValue[nKinId] = math.min(nValue, nJoinNum * self.PLAYER_VALUE)
        Log("WhiteTigerFuben_Cross CalcKinValue:", self.tbKinKillValue[nKinId], nKinId, nJoinNum, nValue)
    end
end

-- 关闭房间，但不走让所有玩家离开副本流程，保证死亡事件的有效性，避免躺尸
function tbFuben:Close()
    -- 删除循环任务
    for szType in pairs(self.tbCycleInfo or {}) do
        self:CloseCycle(szType);
    end

    -- 删除剩余的NPC
    for szGroup, _ in pairs(self.tbNpcGroup) do
        self:DelNpc(szGroup);
    end

    for _, tbLock in pairs(self.tbLock) do
        tbLock:Close();
    end

    if self.OnClose then
        self:OnClose();
    end

    self.bClose = 1;
end

function tbFuben:OnClose()
    local fnShowLeave = function (pPlayer)
        pPlayer.CallClientScript("Ui:OpenWindow", "HomeScreenFuben", "WhiteTigerFuben", {0, true, true})
    end
    self:AllPlayerInMapExcute(fnShowLeave)
end

function tbFuben:OnLeaveMap(pPlayer)
    pPlayer.bForbidChangePk = 0
    local nWs = Fuben.WhiteTigerFuben:GetWsByKinId(pPlayer)
    if nWs then
        CallZoneClientScript(nWs, "Fuben.WhiteTigerFuben:OnLeaveCross", pPlayer.dwID, self.tbComboInfo[pPlayer.dwID] or 0)
    end
end