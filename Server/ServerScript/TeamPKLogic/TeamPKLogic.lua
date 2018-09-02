
Require("ServerScript/TeamPKLogic/TeamPKDef.lua");
local tbDef = TeamPKMgr.tbDef;

TeamPKMgr.tbBaseLogic = TeamPKMgr.tbBaseLogic or {};
local tbBaseLogic = TeamPKMgr.tbBaseLogic;

function TeamPKMgr:CreatePkLogic(szName, nEndTime)
    local tbInst = Lib:NewClass(tbBaseLogic);
    tbInst:OnCreate(szName, nEndTime);
    return tbInst;
end

function tbBaseLogic:DoStart()
    if self.nGameSate ~= tbDef.nPlayStateNone then
        return;
    end
    self.nGameSate = tbDef.nPlayStateStart;
    self:ForeachAllPlayer({self.PlayerOpenStart, self});

    if self.nEndTime and self.nEndTime > 0 then
       self.nOnEndTimer = Timer:Register(self.nEndTime * Env.GAME_FPS, self.OnEndTimer, self)
    end

    self:UpdatePKEnd();
    Log("TeamPKLogic DoStart", self.szName);
end

function tbBaseLogic:OnEndTimer()
    self.nOnEndTimer = nil;
    self:DoEnd();
end    

function tbBaseLogic:PlayerOpenStart(pPlayer)
    local tbPlayerInfo = self:GetPlayerInfo(pPlayer.dwID);
    if not tbPlayerInfo then
        return;
    end

    pPlayer.nFightMode = 1;

    local pPlayerNpc = pPlayer.GetNpc();
    if pPlayerNpc then
        pPlayerNpc.RestoreHP();
    end    

    for nNpcId, _ in pairs(tbPlayerInfo.tbAllPartner) do
        local pPartner = KNpc.GetById(nNpcId);
        if pPartner then
            pPartner.SetAiActive(1);
        end    
    end
end

function tbBaseLogic:PlayerGameEnd(pPlayer)
    self:ClearPlayer(pPlayer);
end

function tbBaseLogic:DoEnd()
    self:CloseDelayDoEndTimer();
    if self.nGameSate ~= tbDef.nPlayStateStart then
        return;
    end
    self.nGameSate = tbDef.nPlayStateEnd;

    local nRestTime = self:GetEndResidueTime();
    local nPlayTime = self.nEndTime - nRestTime;
    if nPlayTime <= 0 then
        nPlayTime = 0;
    end

    self.nPlayTotalTime = nPlayTime;    

    if self.nOnEndTimer then
        Timer:Close(self.nOnEndTimer);
        self.nOnEndTimer = nil;
    end    

    self:CalculateVictoryOrDefeat();

    if self.tbRegOnTeamResult then
        for nTeam, tbTeamInfo in pairs(self.tbAllTeam) do
            self:TableCallBack(self.tbRegOnTeamResult, nTeam, tbTeamInfo.nPlayState); 
        end
    end

    if self.tbOnEndCallBack then --放在最后处理
        Lib:CallBack(self.tbOnEndCallBack);
    end
    self:ForeachAllPlayer({self.PlayerGameEnd, self});
    Log("TeamPKLogic DoEnd", self.szName);
end

function tbBaseLogic:RegTeamResult(tbCallBack)
    self.tbRegOnTeamResult = tbCallBack;
end

function tbBaseLogic:CalculateVictoryOrDefeat()
    local tbCalcAllTeam = {};
    local tbFind = nil;
    for nTeam, tbTeamInfo in pairs(self.tbAllTeam) do
        local nPlayerCount = tbTeamInfo.nTotalPlayerCount;
        local nTotalDmg = self:GetTeamTotalDmg(nTeam);
        local nNpcCount = tbTeamInfo.nTotalNpcCount;
        local tbInfo =
        {
            nPlayerCount = nPlayerCount;
            nTotalDmg    = nTotalDmg;
            nNpcCount    = nNpcCount;
            nTeam        = nTeam;
        };

        if not tbFind then
            tbFind = tbInfo;
        else
            if tbInfo.nPlayerCount > tbFind.nPlayerCount then
                tbFind = tbInfo;
            elseif tbInfo.nPlayerCount == tbFind.nPlayerCount and tbInfo.nNpcCount > tbFind.nNpcCount then
                tbFind = tbInfo;
            elseif tbInfo.nPlayerCount == tbFind.nPlayerCount and tbInfo.nNpcCount == tbFind.nNpcCount and tbInfo.nTotalDmg > tbFind.nTotalDmg then
                tbFind = tbInfo;
            end    
        end

        tbCalcAllTeam[nTeam] = tbInfo;
        tbTeamInfo.tbEndResult = tbInfo;  
    end

    Log("TeamPKLogic CalculateVictoryOrDefeat Start", self.szName);
    Lib:LogTB(tbCalcAllTeam);
    Log("TeamPKLogic CalculateVictoryOrDefeat End", self.szName);

    if not tbFind then
        return;
    end    

    for nTeam, tbInfo in pairs(tbCalcAllTeam) do
        if nTeam ~= tbFind.nTeam then
           if tbInfo.nPlayerCount == tbFind.nPlayerCount and 
                tbInfo.nNpcCount  == tbFind.nNpcCount and
                tbInfo.nTotalDmg  == tbFind.nTotalDmg then

                local tbTeamInfo = self:GetTeamInfo(nTeam);
                tbTeamInfo.nPlayState = tbDef.nPlayDogfall;

                local tbFindTeamInfo = self:GetTeamInfo(tbFind.nTeam);
                tbFindTeamInfo.nPlayState = tbDef.nPlayDogfall;
           else
                local tbTeamInfo = self:GetTeamInfo(nTeam);
                tbTeamInfo.nPlayState = tbDef.nPlayFail;
           end 
        end    
    end

    local tbFindTeamInfo = self:GetTeamInfo(tbFind.nTeam);
    if tbFindTeamInfo.nPlayState == tbDef.nPlayNone then
        tbFindTeamInfo.nPlayState = tbDef.nPlayWin;
    end   
end

function tbBaseLogic:GetTeamTotalDmg(nTeam)
    local tbTeamInfo = self:GetTeamInfo(nTeam);
    if not tbTeamInfo then
        return 0;
    end

    local nTotalDmg  = 0;
    for nPlayerID, tbPlayerInfo in pairs(tbTeamInfo.tbAllPlayer) do
        if tbPlayerInfo.bIsDeath then
            nTotalDmg = nTotalDmg + tbPlayerInfo.nTotalDmg;
        else
            local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
            if pPlayer then
                local pPlayerNpc = pPlayer.GetNpc();
                local tbDmgInfo  = pPlayerNpc.GetDamageCounter();
                local nNpcDmg    = (tbDmgInfo.nDamage - tbDmgInfo.nPlayerDamage) * self.fPlayerToNpcDmg;
                tbPlayerInfo.nTotalDmg = math.floor(nNpcDmg + tbDmgInfo.nPlayerDamage);
                nTotalDmg = nTotalDmg + tbPlayerInfo.nTotalDmg;
            end    
        end

        for nPartnerID, tbPartnerInfo in pairs(tbPlayerInfo.tbAllPartner) do
            if tbPartnerInfo.bIsDeath then
                nTotalDmg = nTotalDmg + tbPartnerInfo.nTotalDmg;
            else    
                local pPartner = KNpc.GetById(nPartnerID);
                if pPartner then
                    local tbDmgInfo  = pPartner.GetDamageCounter();
                    tbPartnerInfo.nTotalDmg = tbDmgInfo.nDamage;
                end 
                nTotalDmg = nTotalDmg + tbPartnerInfo.nTotalDmg;
            end    
        end    
    end

    return nTotalDmg;
end

function tbBaseLogic:GetTeamPartnerCount(nTeam)
    local tbTeamInfo = self:GetTeamInfo(nTeam);
    if not tbTeamInfo then
        return 0;
    end

    local nTotalCount  = 0;
    for nPlayerID, tbPlayerInfo in pairs(tbTeamInfo.tbAllPlayer) do
        for nPartnerID, tbPartnerInfo in pairs(tbPlayerInfo.tbAllPartner) do
            if  not tbPartnerInfo.bIsDeath then 
                nTotalCount = nTotalCount + 1;
            end    
        end
    end

    return nTotalCount;    
end

function tbBaseLogic:GetTeamKillCount(nTeam)
    local tbTeamInfo = self:GetTeamInfo(nTeam);
    if not tbTeamInfo then
        return 0;
    end

    local nTotalCount  = 0;
    for nPlayerID, tbPlayerInfo in pairs(tbTeamInfo.tbAllPlayer) do
        nTotalCount = nTotalCount + tbPlayerInfo.nKillCount;
        for nPartnerID, tbPartnerInfo in pairs(tbPlayerInfo.tbAllPartner) do
            nTotalCount = nTotalCount + tbPartnerInfo.nKillCount;
        end
    end

    return nTotalCount;    
end

function tbBaseLogic:GetTeamKillPlayerCount(nTeam)
    local tbTeamInfo = self:GetTeamInfo(nTeam);
    if not tbTeamInfo then
        return 0;
    end

    local nTotalCount  = 0;
    for nPlayerID, tbPlayerInfo in pairs(tbTeamInfo.tbAllPlayer) do
        nTotalCount = nTotalCount + tbPlayerInfo.nKillPlayerCount;
    end

    return nTotalCount;    
end

function tbBaseLogic:RegOnEnd(tbCallBack)
    self.tbOnEndCallBack = tbCallBack;
end

function tbBaseLogic:RegOnPlayerDeath(tbCallBack)
    self.tbOnPlayerDeath = tbCallBack;
end

function tbBaseLogic:RegOnPartnerDeath(tbCallBack)
    self.tbOnPartnerDeath = tbCallBack;
end

function tbBaseLogic:OnCreate(szName, nEndTime)
    self.szName = szName or "TeamPKMgr";
    self.tbAllTeam = {};
    self.tbPlayerTeamID = {};
    self.nGameSate = tbDef.nPlayStateNone;
    self.nEndTime = nEndTime or 0;
    self.nPlayTotalTime = nil;
    self.szFunPKEnd = "Player";
    self.fPlayerToNpcDmg = 1.0;
    Log("TeamPKLogic OnCreate", self.szName);
end

function tbBaseLogic:SetFunPKEndType(szType)
    self.szFunPKEnd = szType;
end

function tbBaseLogic:SetPlayerToNpcDmg(fRate)
    self.fPlayerToNpcDmg = fRate;
end

function tbBaseLogic:GetGameState()
    return self.nGameSate;
end

function tbBaseLogic:IsEndPKSate()
    local nGameState = self:GetGameState();
    if nGameState ~= tbDef.nPlayStateEnd then
        return false;
    end

    return true; 
end

function tbBaseLogic:GetEndResidueTime()
    if not self.nOnEndTimer then
        return 0;
    end    

    local nTime = math.floor(Timer:GetRestTime(self.nOnEndTimer) / Env.GAME_FPS);
    return nTime;
end

function tbBaseLogic:GetPlayTotalTime()
    if self.nPlayTotalTime then
        return self.nPlayTotalTime;
    end

    local nRestTime = self:GetEndResidueTime();
    local nPlayTime = self.nEndTime - nRestTime;
    if nPlayTime <= 0 then
        nPlayTime = 0;
    end

    return nPlayTime;   
end

function tbBaseLogic:GetTeamInfo(nTeam)
    local tbTeamInfo = self.tbAllTeam[nTeam];
    return tbTeamInfo;    
end

function tbBaseLogic:GetPlayerInfo(dwPlayerID)
    local nTeam = self:GetPlayerTeamID(dwPlayerID);
    local tbTeamInfo = self:GetTeamInfo(nTeam);
    if not tbTeamInfo then
        return;
    end

    local tbPlayerInfo = tbTeamInfo.tbAllPlayer[dwPlayerID];
    return tbPlayerInfo;    
end

function tbBaseLogic:GetPlayerAllPartner(dwPlayerID)
    local tbPlayerInfo = self:GetPlayerInfo(dwPlayerID);
    if not tbPlayerInfo then
        return;
    end    
    return tbPlayerInfo.tbAllPartner;
end

function tbBaseLogic:GetPlayerTeamID(nPlayerID)
    local nTeam = self.tbPlayerTeamID[nPlayerID] or 0;
    return nTeam;
end

function tbBaseLogic:CreateTeamInfo(nTeam)
    local tbTeamInfo = self.tbAllTeam[nTeam];
    if not tbTeamInfo then
        tbTeamInfo = 
        {
            nTotalNpcCount = 0;
            nTotalPlayerCount = 0;
            nPlayState     = tbDef.nPlayNone;
            tbAllPlayer = {};
        };

        self.tbAllTeam[nTeam] = tbTeamInfo;
    end
end

function tbBaseLogic:AddPlayer(pPlayer, nTeam)
    self:CreateTeamInfo(nTeam);
    local tbTeamInfo = self:GetTeamInfo(nTeam);
    if not tbTeamInfo then
        return;
    end

    if tbTeamInfo.tbAllPlayer[pPlayer.dwID] then
        Log("Error TeamPKLogic AddPlayer", self.szName, pPlayer.dwID, nTeam);
        return;
    end

    self.tbPlayerTeamID[pPlayer.dwID] = nTeam;

    local tbPlayerInfo =    
    {
        tbRegID         = {};
        tbAllPartner    = {};
        nTotalDmg       = 0;
        bIsDeath        = false;
        nTeam           = nTeam;
        nKillCount      = 0;
        nKillPlayerCount = 0;
        bLeavePK       = false;
    };
    tbTeamInfo.tbAllPlayer[pPlayer.dwID] = tbPlayerInfo;
    local tbRegID = tbPlayerInfo.tbRegID;
    tbRegID.nOnDeathRegID = PlayerEvent:Register(pPlayer, "OnDeath", self.OnPlayerDeath, self);
    tbRegID.nOnLeaveMapRegID = PlayerEvent:Register(pPlayer, "OnLeaveMap", self.OnLeaveMap, self);

    local pNpc = pPlayer.GetNpc();
    pPlayer.nInBattleState = 1; --战场模式
    pPlayer.bForbidChangePk = 1;
    pPlayer.nFightMode = 0;
    pPlayer.SetPkMode(Player.MODE_CUSTOM, nTeam);
    pNpc.StartDamageCounter();      -- 开启伤害计算

   self:AddTeamNpcCount(nTeam, 1, true); 
    Log("TeamPKLogic AddPlayer", self.szName, pPlayer.dwID, nTeam);   
end

function tbBaseLogic:CreatePartnerByPos(pPlayer, nPartnerStart, nPartnerEnd)
    if not nPartnerStart or not nPartnerEnd then
        return;
    end

    for nPos = nPartnerStart, nPartnerEnd do
        local pPartner = pPlayer.CreatePartnerByPos(nPos)
        if pPartner then
            self:AddPartnerInfo(pPlayer, pPartner);
        end
    end
end

function tbBaseLogic:CreatePartnerByID(pPlayer, nPartnerID)
    if not nPartnerID or nPartnerID <= 0 then
        return;
    end

    local pPartner = pPlayer.CreatePartnerByID(nPartnerID)
    if not pPartner then
        return;
    end

    self:AddPartnerInfo(pPlayer, pPartner);
end

function tbBaseLogic:AddPartnerInfo(pPlayer, pPartner)
    local nTeam = self:GetPlayerTeamID(pPlayer.dwID);
    local pPlayerNpc = pPlayer.GetNpc();
    local tbPlayerInfo = self:GetPlayerInfo(pPlayer.dwID);
    if not tbPlayerInfo then
        return;
    end

    local tbAllPartner = tbPlayerInfo.tbAllPartner;

    pPartner.AI_SetFollowNpc(pPlayerNpc.nId)
    pPartner.AI_SetFollowDistance(tbDef.nNpcFollowDis);
    pPartner.nIgnoreMasterDeath = 1;
    pPartner.SetPkMode(Player.MODE_CUSTOM, nTeam);
    pPartner.AddFightSkill(tbDef.nPartnerImmuneSkill, 1)     -- 免疫被击动作
    pPartner.SetAiActive(0);
    pPartner.StartDamageCounter();      -- 开启伤害计算
    --pPartner.SetMasterNpcId(0);
    pPartner.nTeamMasterNpcID = pPlayerNpc.nId;
    local tbPartnerInfo = 
    {
        bIsDeath = false;
        nTotalDmg = 0;
        nID       = pPartner.nId;
        nPartner  = nPos;
        nKillCount = 0;
        nKillPlayerCount = 0;
    };

    tbAllPartner[pPartner.nId] = tbPartnerInfo;
    self:AddTeamNpcCount(nTeam, 1); 
    Npc:RegNpcOnDeath(pPartner, self.OnPartnerDeath, self, pPlayer.dwID);
    Log("TeamPKLogic AddPartnerInfo", self.szName, pPlayer.dwID, pPartner.szName);
end

function tbBaseLogic:ForeachAllPlayer(tbCallBack)
    for _, tbTeamInfo in pairs(self.tbAllTeam) do
        for nPlayerID, tbPlayerInfo in pairs(tbTeamInfo.tbAllPlayer) do
            local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
            if pPlayer and not tbPlayerInfo.bLeavePK then
                self:TableCallBack(tbCallBack, pPlayer);
            end
        end        
    end 
end

function tbBaseLogic:OnLeaveMap()
    local tbPlayerInfo = self:GetPlayerInfo(me.dwID);
    if not tbPlayerInfo then
        return;
    end

    if self.nGameSate == tbDef.nPlayStateStart then
        local pNpc = me.GetNpc();
        if not tbPlayerInfo.bIsDeath then
            self:RecordNpcDeath(tbPlayerInfo.nTeam, pNpc, tbPlayerInfo);
        end

        for nPartnerID, tbPartnerInfo in pairs(tbPlayerInfo.tbAllPartner) do
            local pPartner = KNpc.GetById(nPartnerID);
            if pPartner and not tbPartnerInfo.bIsDeath then
                self:RecordNpcDeath(tbPlayerInfo.nTeam, pPartner, tbPartnerInfo);
            end    
        end    
    end

    tbPlayerInfo.bLeavePK = true;
    self:ClearPlayer(me);
    Log("TeamPKLogic OnLeaveMap", self.szName, me.dwID);
end    

function tbBaseLogic:OnPlayerDeath(pKiller)
    if self.nGameSate ~= tbDef.nPlayStateStart then
        Log("TeamPKLogic OnPlayerDeath State", self.szName, me.dwID, self.nGameSate);
        return;
    end

    local nTeam = self:GetPlayerTeamID(me.dwID);
    if not nTeam then
        Log("TeamPKLogic OnPlayerDeath", self.szName, me.dwID);
        return;
    end

    local tbPlayerInfo = self:GetPlayerInfo(me.dwID);
    if not tbPlayerInfo then
        Log("Err TeamPKLogic OnPlayerDeath Info", self.szName, me.dwID);
        return;
    end    

    me.Revive(1);
    --me.SetPkMode(Player.MODE_PEACE);
    me.nFightMode = Npc.FIGHT_MODE.emFightMode_Death;
    me.AddSkillState(tbDef.nDeathSkillState, 1, 0, 10000);
    self:RecordKillerCount(pKiller, true);
    local pNpc = me.GetNpc();
    self:RecordNpcDeath(nTeam, pNpc, tbPlayerInfo);

    if self.tbOnPlayerDeath then
        self:TableCallBack(self.tbOnPlayerDeath, pKiller);
    end

    Log("TeamPKLogic OnPlayerDeath", self.szName, me.dwID, tbPlayerInfo.nTotalDmg);
end

function tbBaseLogic:TableCallBack(tbCallBack, ...)
    Lib:MergeCallBack(tbCallBack, ...);
end

function tbBaseLogic:RecordNpcDeath(nTeam, pNpc, tbRecord)
    if tbRecord.bIsDeath then
        Log("TeamPKLogic RecordNpcDeath IS Death", self.szName, nTeam, pNpc.szName);
        return;
    end    

    local bIsPlayer = false;
    local pPlayer = pNpc.GetPlayer();
    if pPlayer then
        bIsPlayer = true;
    end

    local tbDmgInfo     = pNpc.GetDamageCounter();
    local nCurTotalDmg = tbDmgInfo.nDamage;
    if bIsPlayer then
        local nNpcDmg = (tbDmgInfo.nDamage - tbDmgInfo.nPlayerDamage) * self.fPlayerToNpcDmg;
        nCurTotalDmg = math.floor(nNpcDmg + tbDmgInfo.nPlayerDamage);
    end    

    tbRecord.bIsDeath = true;
    tbRecord.nTotalDmg = nCurTotalDmg;
    pNpc.StopDamageCounter();

    self:ReduceTeamNpcCount(nTeam, bIsPlayer);
    Log("TeamPKLogic RecordNpcDeath", self.szName, nTeam, pNpc.szName, tbRecord.nTotalDmg);  
end

function tbBaseLogic:ClosePlayerReg(pPlayer)
    local tbPlayerInfo = self:GetPlayerInfo(pPlayer.dwID);
    if not tbPlayerInfo then
        return;
    end    

    local tbRegID = tbPlayerInfo.tbRegID;
    if tbRegID.nOnDeathRegID then
        PlayerEvent:UnRegister(pPlayer, "OnDeath", tbRegID.nOnDeathRegID);
        tbRegID.nOnDeathRegID = nil;
    end

    if tbRegID.nOnLeaveMapRegID then
        PlayerEvent:UnRegister(pPlayer, "OnLeaveMap", tbRegID.nOnLeaveMapRegID);
        tbRegID.nOnLeaveMapRegID = nil;
    end    
end

function tbBaseLogic:ClearPlayer(pPlayer)
    local tbPlayerInfo = self:GetPlayerInfo(pPlayer.dwID);
    if not tbPlayerInfo then
        return;
    end    

    local pPlayerNpc  = pPlayer.GetNpc();
    if pPlayerNpc.IsDeath() then
        pPlayer.Revive(1);
    end

    pPlayerNpc.RestoreHP();
    pPlayerNpc.ClearAllSkillCD();
    --pPlayer.nInBattleState = 0; --战场模式
    --pPlayer.bForbidChangePk = 0;
    pPlayer.SetPkMode(Player.MODE_PEACE);
    pPlayer.nFightMode = 0;

    local tbStateInfo = pPlayerNpc.GetSkillState(tbDef.nDeathSkillState);
    if tbStateInfo then
        pPlayerNpc.RemoveSkillState(tbDef.nDeathSkillState);
    end

    for nPartnerID, _ in pairs(tbPlayerInfo.tbAllPartner) do
        local pPartner = KNpc.GetById(nPartnerID);
        if pPartner then
            pPartner.Delete();
        end    
    end    

    self:ClosePlayerReg(pPlayer);
end

function tbBaseLogic:AddTeamNpcCount(nTeam, nCount, bIsPlayer)
    local tbTeamInfo = self:GetTeamInfo(nTeam);
    if not tbTeamInfo then
        return;
    end

    tbTeamInfo.nTotalNpcCount = tbTeamInfo.nTotalNpcCount + nCount;

    if bIsPlayer then
        tbTeamInfo.nTotalPlayerCount = tbTeamInfo.nTotalPlayerCount + nCount;
    end    
end

function tbBaseLogic:ReduceTeamNpcCount(nTeam, bIsPlayer)
    self:AddTeamNpcCount(nTeam, -1, bIsPlayer);
    self:UpdatePKEnd();
end

function tbBaseLogic:PlayerCheckUpdatePKEnd()
    local nHaveTeam = 0;
    for _, tbTeamInfo in pairs(self.tbAllTeam) do
        if tbTeamInfo.nTotalPlayerCount > 0 then
            nHaveTeam = nHaveTeam + 1;
        end
            
        if nHaveTeam >= 2 then
            return false;
        end    
    end

    return true;
end

function tbBaseLogic:PlayerNpcCheckUpdatePKEnd()
    local nPlayerHaveTeam = 0;
    local nNpcHaveTeam = 0;
    for _, tbTeamInfo in pairs(self.tbAllTeam) do
        if tbTeamInfo.nTotalPlayerCount > 0 then
            nPlayerHaveTeam = nPlayerHaveTeam + 1;
        end 

        if tbTeamInfo.nTotalNpcCount > 0 then
            nNpcHaveTeam = nNpcHaveTeam + 1;
        end
            
        if nPlayerHaveTeam >= 2 then
            return false;
        end

        if nPlayerHaveTeam == 1 and nNpcHaveTeam >= 2 then
            return false;
        end    
    end

    return true;
end

function tbBaseLogic:UpdatePKEnd()
    local szFun = self.szFunPKEnd or "Player";
    local funUpdatePK = self[szFun.."CheckUpdatePKEnd"];
    if not funUpdatePK then
        return;
    end

    local bRetCheck = funUpdatePK(self);
    if not bRetCheck then
        return;
    end    

    if self.nGameSate ~= tbDef.nPlayStateEnd then
        self:CloseDelayDoEndTimer();
        self.nDelayEndTimer = Timer:Register(1, self.OnDelayDoEnd, self); --延迟一帧结束 因为不延迟的话有可能导致有些事件未执行就结束了
    end    
end

function tbBaseLogic:CloseDelayDoEndTimer()
    if self.nDelayEndTimer then
        Timer:Close(self.nDelayEndTimer);
        self.nDelayEndTimer = nil;
    end    
end

function tbBaseLogic:OnDelayDoEnd()
    self:CloseDelayDoEndTimer();
    self:DoEnd();
end

function tbBaseLogic:OnPartnerDeath(nPlayerID, pKiller)
    if self.nGameSate ~= tbDef.nPlayStateStart then
        return;
    end

    local tbPlayerInfo = self:GetPlayerInfo(nPlayerID);
    if not tbPlayerInfo then
        Log("TeamPKLogic Error OnPartnerDeath Not tbPlayerInfo");
        return;
    end

    local nTeam        = tbPlayerInfo.nTeam;
    local tbAllPartner = tbPlayerInfo.tbAllPartner;
    local tbPartnerInfo = tbAllPartner[him.nId];
    if not tbPartnerInfo then
        Log("TeamPKLogic Error OnPartnerDeath Not Info", self.szName, nPlayerID, nTeam, him.szName);
        return;
    end

    if tbPartnerInfo.bIsDeath then
        Log("TeamPKLogic OnPartnerDeath is Death", self.szName, nPlayerID, nTeam, him.szName);
        return;
    end    

    self:RecordKillerCount(pKiller);
    self:RecordNpcDeath(nTeam, him, tbPartnerInfo);

     if self.tbOnPartnerDeath then
        self:TableCallBack(self.tbOnPartnerDeath, nPlayerID, pKiller);
    end
    Log("TeamPKLogic OnPartnerDeath", self.szName, tbPartnerInfo.nPartner, nPlayerID, tbPartnerInfo.nTotalDmg);
end

function tbBaseLogic:RecordKillerCount(pKiller, bIsPlayer)
    if not pKiller then
        return;
    end

    local pPlayer = pKiller.GetPlayer();
    if pPlayer then
        local tbPlayerInfo = self:GetPlayerInfo(pPlayer.dwID);
        if not tbPlayerInfo then
            return;
        end

        tbPlayerInfo.nKillCount = tbPlayerInfo.nKillCount + 1;

        if bIsPlayer then
            tbPlayerInfo.nKillPlayerCount = tbPlayerInfo.nKillPlayerCount + 1;
        end    
        Log("TeamPKLogic RecordKillerCount Player", self.szName, pPlayer.dwID, tbPlayerInfo.nKillCount, tbPlayerInfo.nKillPlayerCount);    
        return;
    end

    local nMasterNpcId = pKiller.nTeamMasterNpcID;
    if not nMasterNpcId then
        return;
    end

    if nMasterNpcId <= 0 then
        return;
    end    

    local pMasterNpc = KNpc.GetById(nMasterNpcId);
    if not pMasterNpc then
        return;
    end

    local pMasterPlayer = pMasterNpc.GetPlayer();
    if not pMasterPlayer then
        return;
    end

    local tbMasterInfo = self:GetPlayerInfo(pMasterPlayer.dwID);
    if not tbMasterInfo then
        return;
    end

    local tbPartnerInfo = tbMasterInfo.tbAllPartner[pKiller.nId];
    if not tbPartnerInfo then
        return;
    end

    tbPartnerInfo.nKillCount = tbPartnerInfo.nKillCount + 1;

    if bIsPlayer then
        tbPartnerInfo.nKillPlayerCount = tbPartnerInfo.nKillPlayerCount + 1;
    end
    Log("TeamPKLogic RecordKillerCount", self.szName, pMasterPlayer.dwID, pKiller.szName, tbPartnerInfo.nKillCount, tbPartnerInfo.nKillPlayerCount);
end    