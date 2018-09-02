--江湖试炼
SeriesFuben.tbPlayerInfo = SeriesFuben.tbPlayerInfo or {}
SeriesFuben.tbMap4Player = SeriesFuben.tbMap4Player or {}

function SeriesFuben:OnLogin(pPlayer)
    self:HandleTask(pPlayer)
end

function SeriesFuben:CheckTask(pPlayer)
    local nAcceptFlag  = pPlayer.GetUserValue(self.TASK_GROUP, self.TASK_FLAG)
    local nCurFubenIdx = self:GetCurIdx(pPlayer)
    if nAcceptFlag == 0 then
        return nCurFubenIdx > self:GetFubenCount()
    end

    local tbInfo = self:GetFubenInfo(nCurFubenIdx)
    return tbInfo and tbInfo.ReqLevel > self.CLOSE_LEVEL
end

function SeriesFuben:HandleTask(pPlayer)
    local bComplete = self:CheckTask(pPlayer)
    if bComplete then
        Task:OnTaskExtInfo(pPlayer, Task.ExtInfo_JiangHuTrain)
    end
end

function SeriesFuben:OnAcceptTask(nTaskId)
    if self.nTaskId ~= nTaskId then
        return
    end

    me.SetUserValue(self.TASK_GROUP, self.TASK_FLAG, 1)
end
PlayerEvent:RegisterGlobal("AcceptTask", SeriesFuben.OnAcceptTask, SeriesFuben)

function SeriesFuben:CheckEnterFuben(nFubenIdx)
    local bRet, szMsg = self:CheckCanEntry(nFubenIdx)
    if not bRet then
        return bRet, szMsg
    end

    if self.tbPlayerInfo[me.dwID] then
        Log("[SeriesFuben TryEntry] Fail AlreadyInMap Or Map's Creating")
        return false, "正在進入，請稍後"
    end

    return true
end

function SeriesFuben:TryEntry()
    local nFubenIdx = self:GetCurIdx(me)
    local bRet, szMsg = self:CheckEnterFuben(nFubenIdx)
    if not bRet then
        me.CenterMsg(szMsg or "請重試")
        return
    end

    self:TryCreateMap(me, nFubenIdx)
end

function SeriesFuben:TryCreateMap(pPlayer, nFubenIdx)
    local tbFubenInfo = self:GetFubenInfo(nFubenIdx)
    local nMapId = CreateMap(tbFubenInfo.MapTemplateId)
    if not nMapId then
        Log("SeriesFuben CreateMapErr", pPlayer.dwID, nFubenIdx)
        return
    end

    self.tbPlayerInfo[pPlayer.dwID] = {nMapId = nMapId, nFubenIdx = nFubenIdx, tbPartnerList = {}, tbSubstitute = {}, tbDeathPartnerList = {}}
    self.tbMap4Player[nMapId] = pPlayer.dwID
    Log("[SeriesFuben TryCreateMap] CreateSuccess", pPlayer.dwID, nMapId)
end

function SeriesFuben:OnCreateMap(nMapTemplateId, nMapId)
    if not self:IsMyMap(nMapTemplateId) then
        return
    end

    local nPlayerId = self.tbMap4Player[nMapId]
    if not nPlayerId then
        Log("[SeriesFuben Create Emtry Map]", nMapId, nMapTemplateId)
        return
    end

    local tbData  = self.tbPlayerInfo[nPlayerId]
    local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
    if not tbData or not pPlayer then
        Log("[SeriesFuben Player Or Data Is Null After Map Created]", nMapId, nMapTemplateId, type(pPlayer), type(tbData))
        return
    end

    -- 强制退队
    if pPlayer.dwTeamID ~= 0 then
        TeamMgr:QuiteTeam(pPlayer.dwTeamID, pPlayer.dwID)
    end
    pPlayer.SetEntryPoint()
    pPlayer.SwitchMap(nMapId, self:GetPos(tbData.nFubenIdx, "PlayerPos"))

    tbData.nStartTimer = Timer:Register(Env.GAME_FPS * 8, function ()
        self:StartFuben(nPlayerId)
    end)
end

function SeriesFuben:StartFuben(nPlayerId)
    local tbData  = self.tbPlayerInfo[nPlayerId]
    local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
    if not tbData or not pPlayer then
        Log("SeriesFuben BeginTrain Err", nPlayerId, type(tbData), type(pPlayer))
        return
    end

    tbData.nStartTimer   = nil
    tbData.nDeathEventId = PlayerEvent:Register(pPlayer, "OnDeath", self.OnPlayerDeath, self)
    local tbFubenInfo    = self:GetFubenInfo(tbData.nFubenIdx)
    tbData.nCloseTimer   = Timer:Register(Env.GAME_FPS * tbFubenInfo.Time, function ()
        self:TimeOut(tbData.nMapId, nPlayerId)
    end)
    
    self:CreateNpc(nPlayerId, tbData.nMapId, tbData.nFubenIdx)
    pPlayer.CallClientScript("SeriesFuben:OnTrainBegin", tbFubenInfo.Time)
end

function SeriesFuben:OnEnterMap(nMapTemplateId, nMapId)
    if not self:IsMyMap(nMapTemplateId) then
        return
    end
    
    local tbData = self.tbPlayerInfo[me.dwID]
    if not tbData then
        Log("[SeriesFuben OnEnterMap Err]", nMapTemplateId, nMapId)
        return
    end

    self:CreatePartner(me)
    self:SyncPartnerInfo(me)
    AssistClient:ReportQQScore(me, Env.QQReport_IsJoinSeriesFuben, 1, 0, 1)
end

function SeriesFuben:CreatePartner(pPlayer)
    local nCreateNum = 0
    local nPlayerId = pPlayer.dwID
    local tbData = self.tbPlayerInfo[nPlayerId]

    local nX, nY = self:GetPos(self.tbPlayerInfo[nPlayerId].nFubenIdx, "PlayerPos")
    for i = 1, 4 do
        if nCreateNum >= 2 then
            table.insert(tbData.tbSubstitute, i)
        else
            local pNpc = pPlayer.CreatePartnerByPos(i)
            if pNpc then
                pNpc.SetPosition(nX, nY)
                Npc:RegNpcOnDeath(pNpc, self.OnPartnerDeath, self, nPlayerId)
                pNpc.AI_SetFollowNpc(pPlayer.GetNpc().nId)
                pNpc.AI_SetFollowDistance(3000)
                tbData.tbPartnerList[i] = pNpc.nId
                nCreateNum = nCreateNum + 1
            end
        end
    end
end

function SeriesFuben:OnPartnerDeath(nPlayerId)
    local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
    if not pPlayer then
        return
    end
    
    local tbData = self.tbPlayerInfo[nPlayerId]
    if not tbData then
        return
    end

    tbData.tbDeathPartnerList[him.nId] = true
    self:AddSubstitute(pPlayer, tbData)
    self:SyncPartnerInfo(pPlayer)
end

function SeriesFuben:AddSubstitute(pPlayer, tbData)
    if not next(tbData.tbSubstitute) then
        return
    end

    local nPos = tbData.tbSubstitute[1]
    table.remove(tbData.tbSubstitute, 1)

    local pNpc = pPlayer.CreatePartnerByPos(nPos)
    if pNpc then
        local nPlayerId = pPlayer.dwID
        local nX, nY    = self:GetPos(self.tbPlayerInfo[nPlayerId].nFubenIdx, "PlayerPos")
        pNpc.SetPosition(nX, nY)
        Npc:RegNpcOnDeath(pNpc, self.OnPartnerDeath, self, nPlayerId)
        pNpc.AI_SetFollowNpc(pPlayer.GetNpc().nId)
        pNpc.AI_SetFollowDistance(3000)
        tbData.tbPartnerList[nPos] = pNpc.nId
    end
end

function SeriesFuben:CreateNpc(nPlayerId, nMapId, nFubenIdx)
    local tbFubenInfo = self:GetFubenInfo(nFubenIdx)
    local nX, nY = self:GetPos(nFubenIdx, "BossPos")
    local nNpcNum = 0
    local pNpc = KNpc.Add(tbFubenInfo.BossTemplateId, tbFubenInfo.BossLevel, -1, nMapId, nX, nY, 0, 1)
    if pNpc then
        nNpcNum = nNpcNum + 1
    end
    for _, tbNpc in ipairs(tbFubenInfo.tbNpcList) do
        nX, nY = unpack(tbNpc)
        pNpc = KNpc.Add(tbFubenInfo.EnemyTemplate, tbFubenInfo.EnemyLevel, -1, nMapId, nX, nY, 0, 1)
        if pNpc then
            nNpcNum = nNpcNum + 1
        end
    end

    self.tbPlayerInfo[nPlayerId].nNpcNum = nNpcNum
    self.tbPlayerInfo[nPlayerId].nKillNpcNum = 0
end

function SeriesFuben:SyncPartnerInfo(pPlayer)
    local tbData = self.tbPlayerInfo[pPlayer.dwID]
    pPlayer.CallClientScript("Player:SetActiveRunTimeData", "AsyncBattle", {tbData.tbPartnerList, tbData.tbDeathPartnerList})
end

function SeriesFuben:OnKillNpc(pNpc)
    local nMapId = pNpc.nMapId
    local nPlayerId = self.tbMap4Player[nMapId]
    if not nPlayerId then
        return
    end

    local tbData = self.tbPlayerInfo[nPlayerId]
    tbData.nKillNpcNum = tbData.nKillNpcNum + 1

    if self:CheckSuccess(nPlayerId) then
        self:DoCompleteOneFuben(nMapId, nPlayerId)
    end
end

function SeriesFuben:CheckSuccess(nPlayerId)
    local tbData = self.tbPlayerInfo[nPlayerId]
    return tbData.nKillNpcNum >= tbData.nNpcNum
end

function SeriesFuben:DoCompleteOneFuben(nMapId, nPlayerId)
    local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
    if pPlayer then
        local nCurIdx = pPlayer.GetUserValue(self.GROUP, self.CUR_INDEX_KEY) + 1
        pPlayer.SetUserValue(self.GROUP, self.CUR_INDEX_KEY, nCurIdx)

        local tbAward = self:GetAward(nCurIdx) or {}
        pPlayer.SendAward(tbAward, false, true, Env.LogWay_SeriesFuben)
        pPlayer.CallClientScript("Ui:OpenWindow", "LingJueFengLayerPanel", "Win")
        pPlayer.CallClientScript("SeriesFuben:ResetTaskDesc")
        Timer:Register(Env.GAME_FPS * 3, function ()
            self:KickOutPlayer(nPlayerId)
        end)

        self:HandleTask(pPlayer)
        Log("SeriesFuben DoCompleteOneFuben", nPlayerId, nCurIdx)
    else
        Log("[SeriesFuben DoCompleteOneFuben Err]", nMapId, nPlayerId)
    end
    self:ClearMap(nMapId, nPlayerId)
end

function SeriesFuben:OnPlayerDeath()
    self:ClearMap(me.nMapId, me.dwID)
    me.CenterMsg("挑戰失敗")
    me.CallClientScript("SeriesFuben:OnFubenClose")
    Log("[SeriesFuben PlayerDeath]", me.dwID, me.nMapId)
end

function SeriesFuben:TimeOut(nMapId, nPlayerId)
    local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
    if pPlayer then
        pPlayer.CenterMsg("時間已耗盡，挑戰失敗")
        self:KickOutPlayer(nPlayerId)
    end

    local tbData = self.tbPlayerInfo[nPlayerId]
    if tbData then
        tbData.nCloseTimer = nil
    end
    self:ClearMap(nMapId, nPlayerId)
    Log("SeriesFuben TimeOut", nMapId, nPlayerId)
end

function SeriesFuben:KickOutPlayer(nPlayerId)
    local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
    if not pPlayer then
        return
    end

    pPlayer.GotoEntryPoint()
    pPlayer.CallClientScript("SeriesFuben:OnFubenClose")
end

function SeriesFuben:OnLogout(pPlayer)
    local tbData = self.tbPlayerInfo[pPlayer.dwID]
    if not tbData then
        return
    end

    self:ClearMap(pPlayer.nMapId, pPlayer.dwID)
    Log("SeriesFuben OnLogout", pPlayer.dwID, pPlayer.nMapId)
end

function SeriesFuben:ClearMap(nMapId, nPlayerId)
    if nMapId then
        self.tbMap4Player[nMapId] = nil
    end

    if not nPlayerId then
        Log("SeriesFuben ClearMap Err", nMapId)
        return
    end

    local tbData = self.tbPlayerInfo[nPlayerId]
    self.tbPlayerInfo[nPlayerId] = nil
    if not tbData then
        Log("[SeriesFuben ClearMap Data Null]", nPlayerId)
        return
    end
    
    local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
    if pPlayer then
        PlayerEvent:UnRegister(pPlayer, "OnDeath", tbData.nDeathEventId)
    end

    if tbData.nStartTimer then
        Timer:Close(tbData.nStartTimer)
        tbData.nStartTimer = nil
    end

    if tbData.nCloseTimer then
        Timer:Close(tbData.nCloseTimer)
        tbData.nCloseTimer = nil
    end
end