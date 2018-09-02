Require("CommonScript/QunYingHui/QunYingHuiDef.lua");
local tbDef = QunYingHui.tbDefInfo;
QunYingHui.tbGameBase = QunYingHui.tbGameBase or {};
local tbGameBase = QunYingHui.tbGameBase;

function tbGameBase:OnCreate(nMapId, tbPlayer)
    self.nMapId   = nMapId;
    self.tbAllPlayerInfo = {};
    self.nTotalPlayerCount = 0;
    self.bGameEnd  = false;

    local tbPlayerObj = {};
    for _, nPlayerID in pairs(tbPlayer) do
        local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
        if not pPlayer then
            Log("ERROR QunYingHui Not On Line", nPlayerID);
            return;
        end

        self.nTotalPlayerCount   = self.nTotalPlayerCount + 1;
        table.insert(tbPlayerObj, pPlayer);

        Log("QunYingHui Game Player", nMapId, nPlayerID, self.nTotalPlayerCount );
    end

    for nIndex, pPlayer in pairs(tbPlayerObj) do
        local tbPos = tbDef.tbGameMapPos[nIndex];
        pPlayer.SwitchMap(nMapId, tbPos[1], tbPos[2]);
    end

    self.nPrepareTimerEnd = Timer:Register(tbDef.nFightGameTime * Env.GAME_FPS, self.OnPrepareTimeEnd, self);
    Log("QunYingHui Game OnCreate", nMapId);
end

function tbGameBase:OnDestroy(nMapId)
    if self.nStartTimer then
        Timer:Close(self.nStartTimer);
        self.nStartTimer = nil;
    end

    if self.nPreStartTimer then
        Timer:Close(self.nPreStartTimer);
        self.nPreStartTimer = nil;
    end

    if self.nPrepareTimerEnd then
        Timer:Close(self.nPrepareTimerEnd);
        self.nPrepareTimerEnd = nil;
    end

    if self.nGameEndTimer then
        Timer:Close(self.nGameEndTimer);
        self.nGameEndTimer = nil;
    end

    if self.nDmgTimer then
        Timer:Close(self.nDmgTimer);
        self.nDmgTimer = nil;
    end

    Log("QunYingHui Game OnDestroy", nMapId);
end

function tbGameBase:OnEnter(nMapId)
    local tbPlayerInfo = {};
    tbPlayerInfo.nPlayerID        = me.dwID;
    tbPlayerInfo.nTotalDmg        = 0;
    tbPlayerInfo.tbAllPartner     = {};
    tbPlayerInfo.nPlayerDmg       = 0;
    self.tbAllPlayerInfo[me.dwID] = tbPlayerInfo;
    local nEnterCount = Lib:CountTB(self.tbAllPlayerInfo);
    tbPlayerInfo.nTeamID = nEnterCount;

    -- local bRet, szMsg = QunYingHui:CheckPlayeGame(me);
    -- if not bRet then
    --     me.Msg(szMsg);
    --     me.GotoEntryPoint();
    --     return;
    -- end

    DegreeCtrl:ReduceDegree(me, tbDef.szDegreeDay, 1);
    QunYingHui:AddPlayerTotalJoin(me);

    me.nInBattleState = 1; --战场模式
    me.bForbidChangePk = 1;
    me.nFightMode = 0;
    me.SetPkMode(Player.MODE_CUSTOM, tbPlayerInfo.nTeamID);

    local _, nPosX, nPosY = me.GetWorldPos();
    me.SetTempRevivePos(self.nMapId, nPosX, nPosY);  --设置临时复活点

    self:CreatePartnerGroup(me);
    tbPlayerInfo.nOnDeathRegID = PlayerEvent:Register(me, "OnDeath", self.OnPlayerDeath, self);
    tbPlayerInfo.nPartnerDeathId = PlayerEvent:Register(me, "OnPartnerDeath", self.OnPartnerDeath, self);
    --tbPlayerInfo.nRegLoginId = PlayerEvent:Register(me, "OnLogin", self.OnLogin, self);

    if nEnterCount == self.nTotalPlayerCount  then
        if self.nStartTimer then
            Timer:Close(self.nStartTimer);
            self.nStartTimer = nil;
        end

        self.nStartTimer = Timer:Register(tbDef.nPrepareGameTime * Env.GAME_FPS, self.OnStartGame, self);

        if self.nPreStartTimer then
            Timer:Close(self.nPreStartTimer);
            self.nPreStartTimer = nil;
        end

        local nPreStartTime = (tbDef.nPrepareGameTime - 3) * Env.GAME_FPS;
        if nPreStartTime <= 0 then
            nPreStartTime = 1;
        end    

        self.nPreStartTimer = Timer:Register(nPreStartTime, self.OnPreStartGame, self);    
        self:DoShowVictoryDefeat(-1);
    end

    me.CallClientScript("Ui:ChangeUiState", Ui.STATE_GAME_FIGHT, false);
    Log("QunYingHui Game OnEnter", nMapId, me.dwID, me.szName);
end

function tbGameBase:OnLogicLogin()
    me.CallClientScript("Ui:ChangeUiState", Ui.STATE_GAME_FIGHT, false);
    if self.nGameEndTimer then
        local nTime = math.floor(Timer:GetRestTime(self.nGameEndTimer) / Env.GAME_FPS);
        me.CallClientScript("Ui:OpenWindow", "QYHbattleInfo", nTime);
    elseif self.nGamePlayerWin then
        self:DoShowVictoryDefeat(self.nGamePlayerWin, me.dwID);
    end
    self:ShowLeaveButton(me);
    Log("QunYingHui OnLogin", me.dwID, me.szName);
end

function tbGameBase:OnPreStartGame()
    self.nPreStartTimer = nil;
    self:ForEachInMap(self.PlayerReadyGo);
end

function tbGameBase:PlayerReadyGo(pPlayer)
    pPlayer.CallClientScript("Ui:OpenWindow", "ReadyGo");
end

function tbGameBase:OnStartGame()
    if self.nPrepareTimerEnd then
        Timer:Close(self.nPrepareTimerEnd);
        self.nPrepareTimerEnd = nil;
    end

    self.nStartTimer = nil;
    self:ForEachInMap(self.PlayerStartGame);

    if self.nGameEndTimer then
        Timer:Close(self.nGameEndTimer);
        self.nGameEndTimer = nil;
    end

    if self.nDmgTimer then
        Timer:Close(self.nDmgTimer);
        self.nDmgTimer = nil;
    end

    self.nGameEndTimer = Timer:Register(tbDef.nFightGameTime * Env.GAME_FPS, self.OnTimerGameEnd, self);
    self.nDmgTimer = Timer:Register(tbDef.nUpdateDmgTime * Env.GAME_FPS, self.OnTimerUpdateDmg, self);
    Log("QunYingHui OnStartGame", self.nMapId);
end

function tbGameBase:PlayerStartGame(pPlayer)
    local tbPlayerInfo = self.tbAllPlayerInfo[pPlayer.dwID];
    pPlayer.nFightMode = 1;
    local nOtherPlayerID = 0;
    for _, tbInfo in pairs(self.tbAllPlayerInfo) do
        if tbInfo.nPlayerID ~= pPlayer.dwID then
            nOtherPlayerID = tbInfo.nPlayerID;
        end
    end

    if nOtherPlayerID > 0 then
        local tbLastPKInfo = QunYingHui:GetLastPKPlayerID(pPlayer);
        local nPlayerMatchID1 = tbLastPKInfo[1];
        tbLastPKInfo[1] = nOtherPlayerID;
        tbLastPKInfo[2] = nPlayerMatchID1;
    end

    local pPlayerNpc = pPlayer.GetNpc();
    pPlayerNpc.RestoreHP();
    pPlayerNpc.StartDamageCounter();

    for _, tbParInfo in pairs(tbPlayerInfo.tbAllPartner) do
        local pPartner = KNpc.GetById(tbParInfo.nNpcId);
        if pPartner then
            pPartner.SetAiActive(1);
        end    
    end    

    --Achievement:AddCount(pPlayer, tbDef.szAchievementKey, 1);
    pPlayer.CallClientScript("Ui:OpenWindow", "QYHbattleInfo", tbDef.nFightGameTime);
    Log("QunYingHui PlayerStartGame", self.nMapId, pPlayer.dwID, pPlayer.szName);
    LogD(Env.LOGD_ActivityPlay, pPlayer.szAccount, pPlayer.dwID, pPlayer.nLevel, 0, Env.LOGD_VAL_TAKE_TASK, Env.LOGD_MIS_QYH, pPlayer.GetFightPower());
end

function tbGameBase:CreatePartnerGroup(pPlayer)
    local pPlayerNpc = pPlayer.GetNpc();
    local tbPlayerInfo = self.tbAllPlayerInfo[pPlayer.dwID];
    for nPos = 1, tbDef.nPartnerPos do
        local pPartner = pPlayer.CreatePartnerByPos(nPos)
        if pPartner then
            pPartner.AI_SetFollowNpc(pPlayerNpc.nId)
            pPartner.nIgnoreMasterDeath = 1;
            pPartner.SetPkMode(Player.MODE_CUSTOM, tbPlayerInfo.nTeamID);
            pPartner.AddFightSkill(1251, 1)     -- 免疫被击动作
            pPartner.SetAiActive(0);
            pPartner.StartDamageCounter();      -- 开启伤害计算

            local tbParInfo = {};
            tbParInfo.nNpcId = pPartner.nId;
            tbParInfo.nTotalDmg = 0;
            tbParInfo.nPartnerId = pPartner.nPartnerId;
            tbPlayerInfo.tbAllPartner[nPos] = tbParInfo;
        end    
    end
end

function tbGameBase:OnTimerGameEnd()
    self.nGameEndTimer = nil;
    local nPlayerID = self:TimeEndJudgeWin();
    self:OnGameEnd(nPlayerID);
    Log("QunYingHui OnTimerGameEnd", self.nMapId);
end

function tbGameBase:TimeEndJudgeWin()
    local tbLifeCount = self:GetLifeCount();
    local nLifeCount = #tbLifeCount;
    if nLifeCount == 0 then
        Log("QunYingHui OnTimerGameEnd Player == 0", self.nMapId);
        return 0;
    end

    table.sort(tbLifeCount, function(a, b) return a.nLifeCount > b.nLifeCount; end);
    Log("....QunYingHui Life Count Start......");
    Lib:LogTB(tbLifeCount);
    Log("....QunYingHui End......");

    local tbLifeInfo1 = tbLifeCount[1];
    if nLifeCount == 1 then
        return tbLifeInfo1.nPlayerID;
    end

    local tbLifeInfo2 = tbLifeCount[nLifeCount];
    if tbLifeInfo1.nLifeCount > tbLifeInfo2.nLifeCount then
        return tbLifeInfo1.nPlayerID;
    end

    self:UpdateAllPlayerDmg();
    local tbAllDmgInfo = {};
    for _, tbPlayerInfo in pairs(self.tbAllPlayerInfo) do
        local tbInfo = {nPlayerID = tbPlayerInfo.nPlayerID, nTotalDmg = tbPlayerInfo.nTotalDmg};
        table.insert(tbAllDmgInfo, tbInfo);
    end

    table.sort(tbAllDmgInfo, function(a, b) return a.nTotalDmg > b.nTotalDmg; end);
    local tbDmgInfo1 = tbAllDmgInfo[1];
    local tbDmgInfo2 = tbAllDmgInfo[2];

    if tbDmgInfo2 and tbDmgInfo2.nTotalDmg == tbDmgInfo1.nTotalDmg then
        tbAllDmgInfo[1].nTotalDmg = tbAllDmgInfo[1].nTotalDmg + 1;
        local tbDmgPlayer = self.tbAllPlayerInfo[tbDmgInfo1.nPlayerID];
        tbDmgPlayer.nPlayerDmg = tbDmgPlayer.nPlayerDmg + 1;
        Log("QunYingHui Add Dmg", tbDmgInfo1.nPlayerID);
    end

    Log("....QunYingHui Dmg Start......");
        Lib:LogTB(tbAllDmgInfo);
    Log("....QunYingHui End......");

    return tbDmgInfo1.nPlayerID;
end

function tbGameBase:GetLifeCount()
    local tbLifeCount = {};
    for _, tbPlayerInfo in pairs(self.tbAllPlayerInfo) do
        local nLifeCount = 0;
        local pPlayer = KPlayer.GetPlayerObjById(tbPlayerInfo.nPlayerID);
        if pPlayer then
            local pNpc = pPlayer.GetNpc();
            if self:IsLife(pNpc) then
                nLifeCount = nLifeCount + 1;
            end

            for _, tbParInfo in pairs(tbPlayerInfo.tbAllPartner) do
                local pNpc = KNpc.GetById(tbParInfo.nNpcId);
                if self:IsLife(pNpc) then
                    nLifeCount = nLifeCount + 1;
                end
            end   

            local tbInfo = {nPlayerID = tbPlayerInfo.nPlayerID, nLifeCount = nLifeCount};
            table.insert(tbLifeCount, tbInfo);
        end 
    end

    return tbLifeCount;
end

function tbGameBase:IsLife(pNpc)
    if not pNpc then
        return false;
    end

    if pNpc.IsDeath() then
        return false;
    end

    local pPlayer = pNpc.GetPlayer();
    if pPlayer and pPlayer.nFightMode == Npc.FIGHT_MODE.emFightMode_Death then
        return false;
    end

    return true;
end

function tbGameBase:OnPrepareTimeEnd()
    self:ForEachInMap(self.KickOutPrepareMap);
    self.nPrepareTimerEnd = nil;
    Log("QunYingHui Game OnPrepareTimeEnd", self.nMapId);
end

function tbGameBase:ShowLeaveButton(pPlayer)
    if not self.bGameEnd then
        return;
    end

    -- pPlayer.nCanLeaveMapId = pPlayer.nMapId;
    -- pPlayer.CallClientScript("Ui:OpenWindow", "QYHLeavePanel");
    -- pPlayer.CallClientScript("Map:SetCloseUiOnLeave", pPlayer.nMapId, "QYHLeavePanel");
    pPlayer.CallClientScript("Ui:CloseWindow", "QYHbattleInfo");    
end 

function tbGameBase:KickOutPrepareMap(pPlayer)
    if QunYingHui.nEnterMapID then
        local tbPos = QunYingHui:RandomPrepareMapPos();
        pPlayer.SwitchMap(QunYingHui.nEnterMapID, tbPos[1], tbPos[2]);  --设置临时复活点
    else
        pPlayer.GotoEntryPoint();
    end
end

function tbGameBase:OnPlayerDeath(pKillerLuna)
    self:UpdateAllPlayerDmg();
    self:DeathJudgeWin();

    --me.Revive(0);
   -- me.nFightMode = Npc.FIGHT_MODE.emFightMode_Death;
    Log("QunYingHui OnPlayerDeath", self.nMapId, me.dwID, me.szName);
end

function tbGameBase:OnPartnerDeath(nPartnerId, pPartner)
    self:UpdateAllPlayerDmg();
    self:DeathJudgeWin();
end

function tbGameBase:UpdateAllPlayerDmg()
    for _, tbPlayerInfo in pairs(self.tbAllPlayerInfo) do
        local pPlayer = KPlayer.GetPlayerObjById(tbPlayerInfo.nPlayerID);
        if pPlayer then
            local pPlayerNpc = pPlayer.GetNpc();
            local tbDmgInfo = pPlayerNpc.GetDamageCounter();
            local nNpcDmg = (tbDmgInfo.nDamage - tbDmgInfo.nPlayerDamage) * tbDef.fPlayerToNpcDmg;
            tbPlayerInfo.nPlayerDmg = math.floor(nNpcDmg + tbDmgInfo.nPlayerDamage);

            for _, tbParInfo in pairs(tbPlayerInfo.tbAllPartner) do
                local pNpc = KNpc.GetById(tbParInfo.nNpcId);
                if pNpc then
                    local tbDmgInfo = pNpc.GetDamageCounter();
                    tbParInfo.nTotalDmg = tbDmgInfo.nDamage;
                end    
            end
        end
    end

    for _, tbPlayerInfo in pairs(self.tbAllPlayerInfo) do
        tbPlayerInfo.nTotalDmg = 0;
        tbPlayerInfo.nTotalDmg = tbPlayerInfo.nTotalDmg + tbPlayerInfo.nPlayerDmg;

        for _, tbParInfo in pairs(tbPlayerInfo.tbAllPartner) do
            tbPlayerInfo.nTotalDmg = tbPlayerInfo.nTotalDmg + tbParInfo.nTotalDmg;
        end
    end
end

function tbGameBase:OnTimerUpdateDmg()
    self:UpdateAllPlayerDmg();
    local tbDmgInfo = {};
    for _, tbPlayerInfo in pairs(self.tbAllPlayerInfo) do
        tbDmgInfo[tbPlayerInfo.nPlayerID] = tbPlayerInfo.nTotalDmg;
    end

    self:ForEachInMap(self.UpdatePlayerUIDmg, tbDmgInfo);
    return true;
end

function tbGameBase:UpdatePlayerUIDmg(pPlayer, tbDmgInfo)
    pPlayer.CallClientScript("Player:SetActiveRunTimeData", "QYHbattleInfo", tbDmgInfo);
end

function tbGameBase:DeathJudgeWin()
    local nPlayerLose = nil;
    for _, tbPlayerInfo in pairs(self.tbAllPlayerInfo) do
        local pPlayer = KPlayer.GetPlayerObjById(tbPlayerInfo.nPlayerID);
        local bNotDeath = false;
        if pPlayer then
            local pNpc = pPlayer.GetNpc();
            if self:IsLife(pNpc) then
                bNotDeath = true
            end

            for _, tbParInfo in pairs(tbPlayerInfo.tbAllPartner) do
                local pNpc = KNpc.GetById(tbParInfo.nNpcId);
                if self:IsLife(pNpc) then
                    bNotDeath = true;
                end
            end    
        end

        if not bNotDeath then
            nPlayerLose = tbPlayerInfo.nPlayerID;
            break;
        end
    end

    if not nPlayerLose then
        return;
    end

    local nPlayerWin = 0;
    for _, tbPlayerInfo in pairs(self.tbAllPlayerInfo) do
        if nPlayerLose ~= tbPlayerInfo.nPlayerID then
            nPlayerWin = tbPlayerInfo.nPlayerID;
            break;
        end
    end

    Log("QunYingHui DeathJudgeWin", self.nMapId, nPlayerWin);
    self:OnGameEnd(nPlayerWin);
end

function tbGameBase:DoWinPlayer(nPlayerWin)
    if not nPlayerWin then
        Log("QunYingHui Not Player nil");
        return;
    end

    local pWinPlayer = KPlayer.GetPlayerObjById(nPlayerWin);
    if not pWinPlayer then
        Log("QunYingHui Not Player", nPlayerWin);
        return;
    end

    QunYingHui:AddPlayerWinCount(pWinPlayer);
    QunYingHui:AddPlayerJiFen(pWinPlayer, tbDef.nWinJiFen);

    local nWinCount = QunYingHui:GetPlayerDayWinCount(pWinPlayer);
    if nWinCount >= tbDef.nWinCountNotice then
        local szMsg = string.format(tbDef.szWorldNotice, pWinPlayer.szName, nWinCount);
        KPlayer.SendWorldNotify(1, 999, szMsg, 1, 1);
        --ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.System, szMsg);
    end

    LogD(Env.LOGD_ActivityPlay, pWinPlayer.szAccount, pWinPlayer.dwID, pWinPlayer.nLevel, 0, Env.LOGD_VAL_FINISH_TASK, Env.LOGD_MIS_QYH, pWinPlayer.GetFightPower());
    local tbLogData =
    {
        Result = Env.LogRound_SUCCESS;
        nMatchTime = self.nMatchTime or 0; --消耗的时间
        nScore = tbDef.nWinJiFen;
    };
    pWinPlayer.ActionLog(Env.LogType_Athletics, Env.LogWay_QunYingHui, tbLogData);
    self:ShowLeaveButton(pWinPlayer);
    Log("QunYingHui DoWinPlayer", self.nMapId, pWinPlayer.szName, pWinPlayer.dwID);
end

function tbGameBase:DoFailPlayer(nPlayerFail)
    if not nPlayerFail then
        return;
    end

    local pFailPlayer = KPlayer.GetPlayerObjById(nPlayerFail);
    if not pFailPlayer then
        Log("QunYingHui Not FailPlayer", nPlayerFail);
        return;
    end

    QunYingHui:AddPlayerJiFen(pFailPlayer, tbDef.nFailJiFen);
    LogD(Env.LOGD_ActivityPlay, pFailPlayer.szAccount, pFailPlayer.dwID, pFailPlayer.nLevel, 0, Env.LOGD_VAL_FINISH_TASK, Env.LOGD_MIS_QYH, pFailPlayer.GetFightPower());
    local tbLogData =
    {
        Result = Env.LogRound_FAIL;
        nMatchTime = self.nMatchTime or 0; --消耗的时间
        nScore = tbDef.nFailJiFen; --活动的分数
    };
    pFailPlayer.ActionLog(Env.LogType_Athletics, Env.LogWay_QunYingHui, tbLogData);
    self:ShowLeaveButton(pFailPlayer);
    Log("QunYingHui DoFailPlayer", self.nMapId, pFailPlayer.szName, pFailPlayer.dwID);
end

function tbGameBase:EndMatchTime()
    if self.nMatchTime then
        return;
    end

    self.nMatchTime = tbDef.nFightGameTime;
    if self.nGameEndTimer then
        local nTime = math.floor(Timer:GetRestTime(self.nGameEndTimer) / Env.GAME_FPS);
        self.nMatchTime = self.nMatchTime - nTime;
    end
end

function tbGameBase:OnGameEnd(nPlayerWin)
    if self.bGameEnd then
        return;
    end

    self:EndMatchTime();
    if self.nGameEndTimer then
        Timer:Close(self.nGameEndTimer);
        self.nGameEndTimer = nil;
    end

    if self.nDmgTimer then
        Timer:Close(self.nDmgTimer);
        self.nDmgTimer = nil;
    end

    self.bGameEnd  = true;
    self:DoWinPlayer(nPlayerWin);

    local nPlayerFail = 0;
    for nPlayerID, _ in pairs(self.tbAllPlayerInfo) do
        if nPlayerID ~= nPlayerWin then
            nPlayerFail = nPlayerID;
        end
    end

    self:DoFailPlayer(nPlayerFail);
    self:DoShowVictoryDefeat(nPlayerWin);

    local funChangeMode = function (tbLogic, pPlayer)
        pPlayer.SetPkMode(0);
    end

    self:ForEachInMap(funChangeMode);
    self.nGamePlayerWin = nPlayerWin;
    Timer:Register(tbDef.nGameEndKickOutMapTime * Env.GAME_FPS, self.OnTmerKickOutPrepareMap, self);
    Log("QunYingHui OnGameEnd", nPlayerWin);
end

function tbGameBase:DoShowVictoryDefeat(nPlayerWin, nSendPlayerID)
    local tbAllShowInfo = {};
    for _, tbPlayerInfo in pairs(self.tbAllPlayerInfo) do
        local pPlayer = KPlayer.GetPlayerObjById(tbPlayerInfo.nPlayerID);
        if pPlayer then
            local pNpc = pPlayer.GetNpc();
            local tbShowInfo = {};
            tbShowInfo.szName = pPlayer.szName;
            tbShowInfo.nLevel = pPlayer.nLevel;
            tbShowInfo.nFaction = pPlayer.nFaction;
            tbShowInfo.nPortrait = pPlayer.nPortrait;
            tbShowInfo.nHonorLevel = pPlayer.nHonorLevel;
            tbShowInfo.nFightValue = pNpc.GetFightPower();
            tbShowInfo.nTotalDmg   = tbPlayerInfo.nTotalDmg;
            local tbPlayerShowInfo = {};
            tbAllShowInfo[pPlayer.dwID] = tbPlayerShowInfo;
            tbPlayerShowInfo[0] = tbShowInfo;

            -- for nPartnerPos, tbParInfo in pairs(tbPlayerInfo.tbAllPartner) do
            --     local tbPartnerData = pPlayer.GetPartnerInfo(tbParInfo.nPartnerId);
            --     if tbPartnerData then
            --         local tbPartnerInfo = {};
            --         tbPartnerInfo.szName = tbPartnerData.szName;
            --         tbPartnerInfo.nLevel = tbPartnerData.nLevel;
            --         tbPartnerInfo.nTemplateID = tbPartnerData.nNpcTemplateId;
            --         tbPartnerInfo.nFightValue = tbPartnerData.nFightPower;
            --         tbPartnerInfo.nTotalDmg   = tbParInfo.nTotalDmg or 0;
            --         tbPartnerInfo.nGradeLevel = tbPartnerData.nGradeLevel;
            --         tbPartnerInfo.nGrowthLevel = tbPartnerData.nGrowthLevel;
            --         tbPartnerInfo.nQualityLevel = tbPartnerData.nQualityLevel;
            --         tbPlayerShowInfo[nPartnerPos] = tbPartnerInfo;
            --     else
            --         Log("Error QunYingHui DoShowVictoryDefeat", pPlayer.szName, pPlayer.dwID, tbParInfo.nPartnerId, nPartnerPos);
            --     end
            -- end            
        end
    end

   local funBackShowInfo = function (tbLogic, pPlayer)
        if not nSendPlayerID or nSendPlayerID == pPlayer.dwID then
            pPlayer.CallClientScript("Ui:OpenWindow", "QYHAccount", nPlayerWin, tbAllShowInfo);
        end
   end

   self:ForEachInMap(funBackShowInfo);
end

function tbGameBase:OnTmerKickOutPrepareMap()
    self:ForEachInMap(self.KickOutPrepareMap);
end

function tbGameBase:OnLeave(nMapId)
    local pNpc = me.GetNpc();

    if pNpc.IsDeath() then
        me.Revive(0);
    end

    me.nInBattleState = 0; --战场模式
    me.bForbidChangePk = 0;
    me.nFightMode = 0;
    me.SetPkMode(0);
    me.ClearTempRevivePos();
    pNpc.StopDamageCounter();
    Partner:ClosePartner(me);
    pNpc.RestoreHP();
    me.CallClientScript("Ui:CloseWindow", "QYHAccount");
    me.CallClientScript("Ui:ChangeUiState");
    local tbPlayerInfo = self.tbAllPlayerInfo[me.dwID]
    if not tbPlayerInfo then
        Log("Error!!! QunYingHui map miss tbPlayerInfos", nMapId, me.dwID, me.szName)
        return
    end

    if tbPlayerInfo.nOnDeathRegID then
        PlayerEvent:UnRegister(me, "OnDeath", tbPlayerInfo.nOnDeathRegID);
        tbPlayerInfo.nOnDeathRegID = nil;
    end

    if tbPlayerInfo.nPartnerDeathId then
        PlayerEvent:UnRegister(me, "OnPartnerDeath", tbPlayerInfo.nPartnerDeathId);
        tbPlayerInfo.nPartnerDeathId = nil;
    end

    -- if tbPlayerInfo.nRegLoginId then
    --     PlayerEvent:UnRegister(me, "OnLogin", tbPlayerInfo.nRegLoginId);
    --     tbPlayerInfo.nRegLoginId = nil;
    -- end

    self.tbAllPlayerInfo[me.dwID] = nil;
    Log("QunYingHui Game OnLeave", nMapId, me.dwID, me.szName);
end

function tbGameBase:ForEachInMap(fnFunction, ...)
    local tbPlayer = KPlayer.GetMapPlayer(self.nMapId);
    for _, pPlayer in ipairs(tbPlayer) do
        fnFunction(self, pPlayer, ...);
    end
end