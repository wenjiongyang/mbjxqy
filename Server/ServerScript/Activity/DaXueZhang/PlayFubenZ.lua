
Require("CommonScript/Activity/DaXueZhangDef.lua");

local tbDaXueZhang = Activity.tbDaXueZhang;
local tbDef = tbDaXueZhang.tbDef;

local tbFuben = Fuben:CreateFubenClass("DaXueZhangFuben");

function tbFuben:InitTeamPlayerInfo(tbTeamAllPlayer)
    local nCurTeamIndex = 1;
    for nIndex, tbAllPlayer in pairs(tbTeamAllPlayer) do
        local tbTeamInfo = 
        {
            tbAllPlayer = {};
        };

        self.tbAllTeamInfo[nCurTeamIndex] = tbTeamInfo;

        for nPlayerID, _ in pairs(tbAllPlayer) do
            local tbPlayerInfo = 
            {
                nTeamIndex = nCurTeamIndex;
            };
            self.tbEnterAllPlayerInfo[nPlayerID] = tbPlayerInfo;
        end

        nCurTeamIndex = nCurTeamIndex + 1;    
    end
end

function tbFuben:OnPreCreate(tbTeamAllPlayer)
    self.tbAllTeamInfo = {};
    self.tbEnterAllPlayerInfo = {};
    self.tbAllTeamJiFen = {};
    self.nPlayShowEndTime = GetTime();
    self.tbRandomGatherNpcTimer = {};
    self.tbDelayDeleteNpcTimer = {};
    self.bJudgeWinFail = false;
    self.bDXZPlayEnd = false;
    self.tbFeatchAwardPlayer = {};

    self:InitTeamPlayerInfo(tbTeamAllPlayer);
    self:UpdateAllTeamJiFen();
    self:CreateUpdateDmgTime();
    Log("DaXueZhangFuben OnPreCreate", self.nMapId);
end

function tbFuben:CreateUpdateDmgTime()
    self:CloseUpdateDmgTime();
    self.nUpdateDmgTimer = Timer:Register(tbDef.nUpdateDmgTime * Env.GAME_FPS, self.OnUpdateDmgTime, self);
end

function tbFuben:OnUpdateDmgTime()
    if self.bDXZPlayEnd then
        self.nUpdateDmgTimer = nil;
        return;
    end

    self:UpdateAllTeamJiFen();
    self:DXZForeachAllPlayer({self.OnAllTeamShowInfo, self});
    return true;
end

function tbFuben:OnAllTeamShowInfo(pPlayer)
    pPlayer.CallClientScript("Player:ServerSyncData", "PlayAllTeam", self.tbAllTeamJiFen);
end

function tbFuben:CloseUpdateDmgTime()
    if self.nUpdateDmgTimer then
        Timer:Close(self.nUpdateDmgTimer);
        self.nUpdateDmgTimer = nil;
    end
end

function tbFuben:GetFightTeamInfo(nTeamIndex)
    local tbTeamInfo = self.tbAllTeamInfo[nTeamIndex];
    if not tbTeamInfo then
        tbTeamInfo = 
        {
            tbAllPlayer = {};
        };

        self.tbAllTeamInfo[nTeamIndex] = tbTeamInfo;
    end
    
    return tbTeamInfo;    
end

function tbFuben:GetTeamPlayerInfo(nPlayerID)
    local tbEnterInfo = self:GetEnterPlayerInfo(nPlayerID);
    if not tbEnterInfo then
        return;
    end

    local tbTeamInfo = self:GetFightTeamInfo(tbEnterInfo.nTeamIndex);
    local tbPlayerInfo = tbTeamInfo.tbAllPlayer[nPlayerID];
    return tbPlayerInfo;
end

function tbFuben:GetEnterPlayerInfo(nPlayerID)
    return self.tbEnterAllPlayerInfo[nPlayerID];
end

function tbFuben:OnJoin(pPlayer)
    local tbEnterInfo = self:GetEnterPlayerInfo(pPlayer.dwID);
    local tbTeamInfo = self:GetFightTeamInfo(tbEnterInfo.nTeamIndex);
    local tbPlayerInfo = 
    {
        nDamage = 0;
        nZoneIndex = pPlayer.nZoneIndex;
        nRank = -1;
    };

    local tbShowInfo =
    {
        szName      = pPlayer.szName,
        nPortrait   = pPlayer.nPortrait,
        nLevel      = pPlayer.nLevel,
        nHonorLevel = pPlayer.nHonorLevel,
        nFaction    = pPlayer.nFaction,
        nFightPower = pPlayer.GetFightPower();
    };
    tbPlayerInfo.tbShowInfo = tbShowInfo;

    tbTeamInfo.tbAllPlayer[pPlayer.dwID] = tbPlayerInfo;
    self:SetPlayerPKFightInfo(pPlayer);

    local pNpc = pPlayer.GetNpc();
    pPlayer.nInBattleState = 1; --战场模式
    pPlayer.bForbidChangePk = 1;
    pPlayer.nFightMode = 0;
    pPlayer.SetPkMode(Player.MODE_CUSTOM, tbEnterInfo.nTeamIndex);
    pNpc.StartDamageCounter();      -- 开启伤害计算

    self:PlayerAllShowUI(pPlayer);
    self:SetPlayerToPos(self.tbSetting.szDXZRandomBegin, pPlayer);
    tbDaXueZhang:UpdateNormalKinName(pPlayer);  
    Log("DaXueZhangFuben OnJoin", pPlayer.nZoneIndex, self.nMapId, pPlayer.dwID);
end

function tbFuben:SetPlayerPKFightInfo(pPlayer)
    pPlayer.Change2Avatar(pPlayer.nFaction, pPlayer.nLevel, 1);

    local nBuffID = self:GetPlayerStateBuff(pPlayer);
    if nBuffID then
        pPlayer.AddSkillState(nBuffID, 1, 0, 60 * 60 * Env.GAME_FPS, 1, 1);
    else
        Log("Error DaXueZhangFuben SetPlayerPKFightInfo", self.nMapId, pPlayer.dwID);
    end

    local pNpc = pPlayer.GetNpc();
    pNpc.RestoreHP();    
end

function tbFuben:GetPlayerStateBuff(pPlayer)
    local tbEnterInfo = self:GetEnterPlayerInfo(pPlayer.dwID);
    if not tbEnterInfo then
        return;
    end   

    local tbTeamBuff = self.tbSetting.tbTeamPlayerState[tbEnterInfo.nTeamIndex];
    if not tbTeamBuff then
        return;
    end

    local nSex = Gift:CheckSex(pPlayer.nFaction);
    local nBuffID = tbTeamBuff[nSex];
    return nBuffID;
end

function tbFuben:OnOut(pPlayer)
    if not self.bDXZPlayEnd then
        self:CalcPlayerTotalDmg(pPlayer);
    end    

    local pNpc = pPlayer.GetNpc();
    if pNpc.IsDeath() then
        pPlayer.Revive(1);
    end
    pNpc.ClearAllSkillCD();
    pPlayer.nInBattleState = 0; --战场模式
    pPlayer.bForbidChangePk = 0;
    pPlayer.nFightMode = 0;
    pPlayer.SetPkMode(Player.MODE_PEACE);
    pNpc.StopDamageCounter();
    pPlayer.nCanLeaveMapId = nil;

    Log("DaXueZhangFuben OnOut", pPlayer.nZoneIndex, self.nMapId, pPlayer.dwID);
end

function tbFuben:OnLogin(bReConnect)
    self:PlayerAllShowUI(me);
    tbDaXueZhang:UpdateNormalKinName(me);  
    Log("DaXueZhangFuben OnLogin", me.nZoneIndex, self.nMapId, me.dwID);
end

function tbFuben:OnShowPlayTime(nLockId, szTitle, bNotNextFrame)
    if not bNotNextFrame then
        Timer:Register(1, self.OnShowPlayTime, self, nLockId, szTitle, true);
        return;
    end

    local nEndTime = 0
    if self.tbLock[nLockId] then
        nEndTime = GetTime() + math.floor(Timer:GetRestTime(self.tbLock[nLockId].nTimerId) / Env.GAME_FPS);
    end

    self.nPlayShowEndTime = nEndTime;
    self.szFubenTitle = szTitle;
    self:DXZForeachAllPlayer({self.SetPlayerShowInfo, self});
end

function tbFuben:OnRandomAddGatherNpc(nNum, nLock, szGroup, szPointName, bRevive, nUpdateTime, nDelayTime, bCreateNpc)
    self:CloseRandomGatherTimer(szGroup);
    self:CloseDelayDeleteNpcTimer(szGroup);
    if self.bDXZPlayEnd then
        return;
    end

    if bCreateNpc then
        for nI = 1, nNum, 1 do
            local nCurRate = MathRandom(self.tbSetting.TotalNpcRate);
            for nIndex, tbNpcInfo in pairs(self.tbSetting.NPC) do
                if tbNpcInfo.nRate > 0 and tbNpcInfo.nRate >= nCurRate then
                    self:AddNpc(nIndex, 1, nLock, szGroup, szPointName, bRevive, tbNpcInfo.nDir or 1);
                    break;
                end

                nCurRate = nCurRate - tbNpcInfo.nRate;    
            end    
        end

        if self.tbPointFunc and self.tbPointFunc[szPointName] then
            self.tbPointFunc[szPointName] = nil;
        end

        if nDelayTime and nDelayTime > 0 then
            self.tbDelayDeleteNpcTimer[szGroup] = Timer:Register(math.floor(nDelayTime * Env.GAME_FPS), self.OnDelayDeleteNpc, self, szGroup);
        end    
    end
        
    if nUpdateTime and nUpdateTime > 0 then
        self.tbRandomGatherNpcTimer[szGroup] = Timer:Register(math.floor(nUpdateTime * Env.GAME_FPS), self.OnRandomAddGatherNpc, self, nNum, nLock, szGroup, szPointName, bRevive, nUpdateTime, nDelayTime, true);
    end
end

function tbFuben:CloseRandomGatherTimer(szGroup)
    if self.tbRandomGatherNpcTimer[szGroup] then
        Timer:Close(self.tbRandomGatherNpcTimer[szGroup]);
        self.tbRandomGatherNpcTimer[szGroup] = nil;
    end    
end

function tbFuben:CloseDelayDeleteNpcTimer(szGroup)
    if self.tbDelayDeleteNpcTimer[szGroup] then
        Timer:Close(self.tbDelayDeleteNpcTimer[szGroup]);
        self.tbDelayDeleteNpcTimer[szGroup] = nil;
    end 
end

function tbFuben:OnDelayDeleteNpc(szGroup)
    self:CloseDelayDeleteNpcTimer(szGroup);
    if self.bDXZPlayEnd then
        return;
    end

    self:DelNpc(szGroup);
end

function tbFuben:SetPlayerShowInfo(pPlayer)
    local nTime = self.nPlayShowEndTime - GetTime();
    if nTime <= 0 then
        return;
    end    

    local tbEnterInfo = self:GetEnterPlayerInfo(pPlayer.dwID);
    if not tbEnterInfo then
        return;
    end    

    local tbAllTeamInfo = {};
    tbAllTeamInfo.nTime = nTime;
    tbAllTeamInfo.nTeam = tbEnterInfo.nTeamIndex;
    tbAllTeamInfo.tbAllTeam = self.tbAllTeamJiFen;
    tbAllTeamInfo.szType = "JiFen";
    tbAllTeamInfo.szTitle = self.szFubenTitle or "";
    tbAllTeamInfo.nMapTID = pPlayer.nMapTemplateId;
    pPlayer.CallClientScript("Ui:OpenWindow", "HSLJBattleInfo", "Play", tbAllTeamInfo);
end

function tbFuben:PlayerAllShowUI(pPlayer)
    self:SetPlayerShowInfo(pPlayer);
    pPlayer.CallClientScript("Player:ServerSyncData", "HomeBtnTast", {nMapTID = pPlayer.nMapTemplateId});

    if self.bDXZPlayEnd then
        pPlayer.nCanLeaveMapId = pPlayer.nMapId;
        pPlayer.CallClientScript("Ui:OpenWindow", "QYHLeavePanel");
        pPlayer.CallClientScript("Map:SetCloseUiOnLeave", pPlayer.nMapId, "QYHLeavePanel");   
    end    
end

function tbFuben:UpdateAllTeamJiFen()
    self.tbAllTeamJiFen = {};
    for nTeamIndex, tbTeamInfo in pairs(self.tbAllTeamInfo) do
        self:ForeachAllTeamPlayer(nTeamIndex, {self.CalcPlayerTotalDmg, self});   
    end

    for nTeamIndex, tbTeamInfo in pairs(self.tbAllTeamInfo) do
        local tbCalcInfo = 
        {
            nDamage = 0;
        };
        self.tbAllTeamJiFen[nTeamIndex] = tbCalcInfo;
        for _, tbPlayerInfo in pairs(tbTeamInfo.tbAllPlayer) do
            tbCalcInfo.nDamage = tbCalcInfo.nDamage + tbPlayerInfo.nDamage;
        end 
    end

end

function tbFuben:CalcPlayerTotalDmg(pPlayer)
    local tbPlayerInfo = self:GetTeamPlayerInfo(pPlayer.dwID);
    if not tbPlayerInfo then
        return;
    end    

    local pPlayerNpc = pPlayer.GetNpc();
    local tbDmgInfo  = pPlayerNpc.GetDamageCounter();
    tbPlayerInfo.nDamage = tbDmgInfo.nDamage;  
end

function tbFuben:ForeachAllTeamPlayer(nTeamIndex, tbCallBack)
    local tbTeamInfo = self:GetFightTeamInfo(nTeamIndex);
    if not tbTeamInfo then
        return;
    end

    for nPlayerID, _ in pairs(tbTeamInfo.tbAllPlayer) do
        local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
        if pPlayer and pPlayer.nMapId == self.nMapId then
            Lib:MergeCallBack(tbCallBack, pPlayer);
        end       
    end    
end

function tbFuben:DXZForeachAllPlayer(tbCallBack)
    for nTeamIndex, tbTeamInfo in pairs(self.tbAllTeamInfo) do
        self:ForeachAllTeamPlayer(nTeamIndex, tbCallBack); 
    end 
end

function tbFuben:OnDXZPlayEnd()
    if self.bDXZPlayEnd then
        return;
    end

    self.bDXZPlayEnd = true;
    self:JudgeWinFail();
    self:OnClose();
end

function tbFuben:OnGatherNpc(pPlayer, pNpc, szParam)
    if not pNpc then
        return;
    end

    local tbEventInfo = self.tbSetting.tbGatherNpcEvent[pNpc.nTemplateId];
    if tbEventInfo then
        local funEvent = self["GatherNpc"..tbEventInfo.szEvent];
        if funEvent then
            funEvent(self, pPlayer, pNpc, tbEventInfo.tbParam);
        end    
    end    

    pNpc.Delete();
end

function tbFuben:GatherNpcAddBuff(pPlayer, pGatherNpc, tbParam)
    if not tbParam then
        return;
    end

    if tbParam.nSkillID <= 0 then
        return;
    end     

    pPlayer.AddSkillState(tbParam.nSkillID, tbParam.nLevel, 0, math.floor(tbParam.nTime * Env.GAME_FPS), 1, 1);
end

function tbFuben:GatherNpcCastSkill(pPlayer, pGatherNpc, tbParam)
    local pNpc = pPlayer.GetNpc();
    if not pNpc or not pGatherNpc or not tbParam then
        return;
    end

    if tbParam.nSkillID <= 0 then
        return;
    end    

    local _, nX, nY = pGatherNpc.GetWorldPos();
    pNpc.CastSkill(tbParam.nSkillID, tbParam.nLevel, nX, nY);    
end

function tbFuben:OnClose()
    self:CloseUpdateDmgTime();
    for szGroup, nCurTimer in pairs(self.tbRandomGatherNpcTimer) do
        Timer:Close(nCurTimer);
    end
    self.tbRandomGatherNpcTimer = {};

    for szGroup, nCurTimer in pairs(self.tbDelayDeleteNpcTimer) do
        Timer:Close(nCurTimer);
    end    
    self.tbDelayDeleteNpcTimer = {};

    Log("DaXueZhangFuben Fuben", self.nMapId);
end

function tbFuben:OnCloseRandomGatherNpc(szGroup)
    self:CloseRandomGatherTimer(szGroup);
    self:CloseDelayDeleteNpcTimer(szGroup);
end

function tbFuben:SetPlayerToPos(szPointName, pPlayer)
    local nX, nY = self:GetPoint(szPointName);
    if not nX or not nY then
        return;
    end

    pPlayer.SetPosition(nX, nY);    
end

function tbFuben:OnPlayerToPos(szPointName)
    self:DXZForeachAllPlayer({self.SetPlayerToPos, self, szPointName});
end

function tbFuben:JudgeWinFail()
    if self.bJudgeWinFail then
        Log("Error DaXueZhangFuben JudgeWinFail", self.nMapId);
        return;
    end

    self.bJudgeWinFail = true;
    self:CloseUpdateDmgTime();
    self:UpdateAllTeamJiFen();

    local tbJudeIndex = {};
    for nTeamIndex, tbCalcInfo in pairs(self.tbAllTeamJiFen) do
        table.insert(tbJudeIndex, nTeamIndex); 
    end

    local nTotalIndex = #tbJudeIndex;
    if nTotalIndex <= 0 or nTotalIndex > tbDef.nMaxTeamVS then
        Log("Error DaXueZhangFuben JudgeWinFail nTotalIndex", self.nMapId, nTotalIndex);
        return;
    end    
     
    local nWinIndex = 1;
    local nFailIndex = 0;
    if nTotalIndex == tbDef.nMaxTeamVS then
        local tbTeam1 = self.tbAllTeamJiFen[tbJudeIndex[1]];
        local tbTeam2 = self.tbAllTeamJiFen[tbJudeIndex[2]];  
        if tbTeam1.nDamage > tbTeam2.nDamage then
            nWinIndex = 1;
            nFailIndex = 2;
        elseif tbTeam1.nDamage < tbTeam2.nDamage then
            nWinIndex = 2;
            nFailIndex = 1;
        else
            nWinIndex = MathRandom(2);
            nFailIndex = 1;
            if nFailIndex == nWinIndex then
                nFailIndex = 2;
            end

            local tbWinTeam = self.tbAllTeamJiFen[tbJudeIndex[nWinIndex]];
            tbWinTeam.nDamage = tbWinTeam.nDamage + tbDef.nDogfallJiFen;

            local nFindPlayer = nil;
            local nFindDmg = 0;
            local tbTeamInfo = self:GetFightTeamInfo(tbJudeIndex[nWinIndex]);
            for nPlayerID, tbPlayerInfo in pairs(tbTeamInfo.tbAllPlayer) do
                if not nFindPlayer or tbPlayerInfo.nDamage > nFindDmg then
                    nFindPlayer = nPlayerID;
                    nFindDmg = tbPlayerInfo.nDamage;
                end    
            end

            if nFindPlayer then
                local tbPlayerInfo = self:GetTeamPlayerInfo(nFindPlayer);
                tbPlayerInfo.nDamage = tbPlayerInfo.nDamage + tbDef.nDogfallJiFen;
            end               
        end  
    end

    self:WinFailSortPlayerRank();
    
    if nWinIndex > 0 then
        self:DoWinTeam(tbJudeIndex[nWinIndex]);
    end
    
    if nFailIndex > 0 then    
        self:DoFailTeam(tbJudeIndex[nFailIndex]);
    end      

    self:DXZForeachAllPlayer({self.PlayerAllShowUI, self});

    if nWinIndex > 0 then
        local tbAllTeamShowAccount = self:GetAllPlayerAccount(tbJudeIndex[nWinIndex]);
        self:DXZForeachAllPlayer({self.SetPlayerAccount, self, tbAllTeamShowAccount});
    end

    Log("DaXueZhangFuben JudgeWinFail", self.nMapId);
end

function tbFuben:WinFailSortPlayerRank()
    for _, tbTeamInfo in pairs(self.tbAllTeamInfo) do
        local tbSort = {};
        for nPlayerID, tbPlayerInfo in pairs(tbTeamInfo.tbAllPlayer) do
            local tbInfo = {};
            tbInfo.nPlayerID = nPlayerID;
            tbInfo.nDamage = tbPlayerInfo.nDamage;
            table.insert(tbSort, tbInfo);
        end
        
        table.sort(tbSort, function (a, b)
            return a.nDamage > b.nDamage;
        end); 

        for nRank, tbRank in pairs(tbSort) do
            tbTeamInfo.tbAllPlayer[tbRank.nPlayerID].nRank = nRank;
        end   
    end    
end

function tbFuben:DoWinTeam(nTeamIndex)
    local tbTeamInfo = self:GetFightTeamInfo(nTeamIndex);
    if not tbTeamInfo then
        Log("Error DaXueZhangFuben DoWinTeam", self.nMapId, nTeamIndex);
        return;
    end

    for nPlayerID, tbPlayerInfo in pairs(tbTeamInfo.tbAllPlayer) do
        if not self.tbFeatchAwardPlayer[nPlayerID] then

            self.tbFeatchAwardPlayer[nPlayerID] = 1;
            CallZoneClientScript(tbPlayerInfo.nZoneIndex, "Activity.tbDaXueZhang:SendPlayerMailAwardS", nPlayerID, tbDef.nWinType, tbPlayerInfo.nRank);
            Log("DaXueZhangFuben DoWinTeam", tbPlayerInfo.nZoneIndex, nPlayerID, tbPlayerInfo.nRank);
        end    
    end

    local tbAwardInfo = tbDef.tbPlayerAward.tbWin;
    if tbAwardInfo.szMsg then
        self:ForeachAllTeamPlayer(nTeamIndex, {self.SendPlayerMsg, self, tbAwardInfo.szMsg});
    end

    Log("DaXueZhangFuben DoWinTeam", self.nMapId, nTeamIndex);        
end

function tbFuben:SendPlayerMsg(szMsg, pPlayer)
    pPlayer.CenterMsg(szMsg, true);
end

function tbFuben:DoFailTeam(nTeamIndex)
    local tbTeamInfo = self:GetFightTeamInfo(nTeamIndex);
    if not tbTeamInfo then
        Log("Error DaXueZhangFuben DoFailTeam", self.nMapId, nTeamIndex);
        return;
    end

    for nPlayerID, tbPlayerInfo in pairs(tbTeamInfo.tbAllPlayer) do
        if not self.tbFeatchAwardPlayer[nPlayerID] then
            self.tbFeatchAwardPlayer[nPlayerID] = 1;

            CallZoneClientScript(tbPlayerInfo.nZoneIndex, "Activity.tbDaXueZhang:SendPlayerMailAwardS", nPlayerID, tbDef.nFailType, tbPlayerInfo.nRank);
            
            Log("DaXueZhangFuben DoFailTeam", tbPlayerInfo.nZoneIndex, nPlayerID, tbPlayerInfo.nRank);
        end    
    end

    local tbAwardInfo = tbDef.tbPlayerAward.tbFail;
    if tbAwardInfo.szMsg then
        self:ForeachAllTeamPlayer(nTeamIndex, {self.SendPlayerMsg, self, tbAwardInfo.szMsg});
    end

    Log("DaXueZhangFuben DoFailTeam", self.nMapId, nTeamIndex);           
end

function tbFuben:OnKickOutAllTeam()
    self:DXZForeachAllPlayer({self.DXZPlayerKickOut, self});
end

function tbFuben:DXZPlayerKickOut(pPlayer)
    pPlayer.ZoneLogout();
end

function tbFuben:GetAllPlayerAccount(nWinTeam)
    local tbAllTeamShow = {};
    for nCurTeamID, tbPlayInfo in pairs(self.tbAllTeamInfo) do
        local tbTeamShowInfo = {};
        tbTeamShowInfo.tbAllPlayer = {};
        tbTeamShowInfo.szName = "";
        local tbRankAward = {};
        if nCurTeamID == nWinTeam then
            tbTeamShowInfo.nResult = 1;
            tbRankAward = tbDef.tbPlayerAward.tbWin.tbRankAward;
        else
            tbTeamShowInfo.nResult = 2;
            tbRankAward = tbDef.tbPlayerAward.tbFail.tbRankAward;
        end      

        for nPlayerID, tbPlayerInfo in pairs(tbPlayInfo.tbAllPlayer) do
            local tbShowInfo = tbPlayerInfo.tbShowInfo;
            tbShowInfo.nJiFen = tbPlayerInfo.nDamage;
            tbShowInfo.nRank = tbPlayerInfo.nRank;
            if self.bDXZPlayEnd then
                tbShowInfo.tbAward = tbRankAward[tbPlayerInfo.nRank];
                tbTeamShowInfo.tbAllPlayer[tbPlayerInfo.nRank] = tbShowInfo;
            else
                table.insert(tbTeamShowInfo.tbAllPlayer, tbShowInfo);
            end    
        end

        tbAllTeamShow[nCurTeamID] = tbTeamShowInfo;    
    end

    return tbAllTeamShow;
end

function tbFuben:SetPlayerAccount(tbAllTeamShowAccount, pPlayer)
    local tbEnterInfo = self:GetEnterPlayerInfo(pPlayer.dwID);
    if not tbEnterInfo then
        return;
    end

    pPlayer.CallClientScript("Ui:OpenWindow", "HSLJAccount", tbAllTeamShowAccount, tbEnterInfo.nTeamIndex, 10);
end
