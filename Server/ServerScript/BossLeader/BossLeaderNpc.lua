
local tbNpc = Npc:GetClass("BossLeader");
local SAVE_BOSSLEADER_GROUP = 8;

local tbSaveBossLeaderDay   = {["Boss"] = 1, ["Leader"] = 2, }
tbNpc.SAVE_BOSSLEADER_GROUP = SAVE_BOSSLEADER_GROUP;
tbNpc.tbSaveBossLeaderDay = tbSaveBossLeaderDay;

function tbNpc:OnDeath(pKillNpc)
    if not him then
        return;
    end

    local tbBLInfo = him.tbBossLeaderInfo;
    if not tbBLInfo or Lib:IsEmptyStr(tbBLInfo.szType) then
        Log("Error BossLeader Not Boss Leader Info", him.nTemplateId);
        return;
    end

    local nMapID, nDropPosX, nDropPosY = him.GetWorldPos();  
    if not BossLeader:HaveNpc(tbBLInfo.szType, him.nId, nMapID) then
        Log("Error BossLeader Not Boss Leader HaveNpc", him.nTemplateId);
        return;
    end
  
    tbBLInfo.nDropPosX = nDropPosX;
    tbBLInfo.nDropPosY = nDropPosY;
    tbBLInfo.nDropMapID = nMapID;
    tbBLInfo.szDropNpcName = him.szName or "";

    BossLeader:RemoveNpc(tbBLInfo.szType, him.nId, nMapID);

    local tbSortDamage = him.GetDamageInfo();
    if not tbSortDamage or #tbSortDamage <= 0 then
        return;
    end

    if tbBLInfo.tbAllCallNpcDmg then
        Lib:MergeTable(tbSortDamage, tbBLInfo.tbAllCallNpcDmg);
    end

    local function fnDamageCmp(a, b)
        return a.nTotalDamage > b.nTotalDamage;
    end

    table.sort(tbSortDamage, fnDamageCmp);

    Log("------Start BossLeader Dmg Info------", tbBLInfo.szType);
    Lib:LogTB(tbSortDamage);
    Log("------End BossLeader Dmg Info------", tbBLInfo.szType);

    local tbKinSort = {};
    local nFirstCaptainId = -1;
    local nNpcTotalDamage = 0;
    for nRank, tbDmgInfo in ipairs(tbSortDamage) do
        nNpcTotalDamage = nNpcTotalDamage + tbDmgInfo.nTotalDamage;
        local nCaptainId = -1;
        local tbTeam = nil;
        if tbDmgInfo.nTeamId > 0 then
            tbTeam = TeamMgr:GetTeamById(tbDmgInfo.nTeamId);
        end    

        if tbTeam then
            nCaptainId = tbTeam:GetCaptainId();
            self:AddTeamAward(tbBLInfo, tbDmgInfo.nTeamId, nRank); 
        elseif tbDmgInfo.nAttackRoleId > 0 then
            nCaptainId = tbDmgInfo.nAttackRoleId;
            self:AddPlayerAward(tbBLInfo, tbDmgInfo.nAttackRoleId, nRank)   
        end

        if nCaptainId > 0 then
            self:AddCaptainAward(tbBLInfo, tbKinSort, nCaptainId, nRank, tbTeam, tbDmgInfo);
            if nFirstCaptainId <= 0 then
                nFirstCaptainId = nCaptainId;
            end    
        end
    end

    self:OnDeathNotic(him, nil, nFirstCaptainId, tbBLInfo.szType, tbBLInfo.tbNpcInfo);

    BossLeader:CalcKinDmgRankAward(tbBLInfo.szType, tbKinSort, him, nMapID, nNpcTotalDamage);

    local nNpcCount = BossLeader:GetCurNpcCount(tbBLInfo.szType);
    if nNpcCount <= 0 then
        BossLeader:CloseActivity(tbBLInfo.szType);
    end

    if tbBLInfo.nRegHpNotifyId then
        Npc:UnRegisterNpcHpEvent(him.nId, tbBLInfo.nRegHpNotifyId);
        tbBLInfo.nRegHpNotifyId = nil;
    end
end

function tbNpc:AddTeamAward(tbBLInfo, nTeamId, nRank)
    local tbTeam = TeamMgr:GetTeamById(nTeamId);
    if not tbTeam then
        return;
    end

    local tbTeamPlayer = {};
    local tbMember = TeamMgr:GetMembers(nTeamId);
    for _, nPlayerID in pairs(tbMember) do
        self:AddPlayerAward(tbBLInfo, nPlayerID, nRank);

        table.insert(tbTeamPlayer, nPlayerID);    
    end

    local LogType = Env.LogWay_FieldBoss;
    if tbBLInfo.szType == "Leader" then
        LogType = Env.LogWay_FieldLeader;
    end 

    local nTotalTeam = #tbTeamPlayer;
    if nTotalTeam >= 2 then
        for nI = 1, nTotalTeam - 1 do
        for nJ = nI + 1, nTotalTeam do
                local nPlayer1 = tbTeamPlayer[nI];
                local nPlayer2 = tbTeamPlayer[nJ];
                local nImitity = BossLeader.tbKillImitityTeam[tbBLInfo.szType];
                if nImitity then
                    local nConnect = BossLeader:GetPlayerConnectIndex(nPlayer1);
                    Lib:CallZ2SOrLocalScript(nConnect, "BossLeader:FriendShipAddImitity", nPlayer1, nPlayer2, nImitity, LogType);     
                end    
            end    
        end
    end

    Log("BossLeader Add Team Award", tbBLInfo.szType, nTeamId, nRank); 
end

function tbNpc:SendSinglePlayerAward(tbBLInfo, nPlayerID, nRank)
    tbBLInfo.tbSinglePlayerAward = tbBLInfo.tbSinglePlayerAward or {};
    local tbSinglePlayerAward = tbBLInfo.tbSinglePlayerAward;
    if tbSinglePlayerAward[nPlayerID] then
        Log("BossLeader SinglePlayerAward Have", nPlayerID, tbBLInfo.szType, nRank);
        return;   
    end

    tbSinglePlayerAward[nPlayerID] = nRank;

    local tbAllAward = BossLeader:GetPlayerDmgRank(tbBLInfo.tbNpcInfo.PlayerAwardID, nRank);
    if tbAllAward then
        local nDropPosX = nil;
        local nDropPosY = nil;
        local szDropNpcName = tbBLInfo.szDropNpcName or "";
        local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
        if pPlayer then
            local nPlayerMapID = pPlayer.GetWorldPos();
            if nPlayerMapID == tbBLInfo.nDropMapID then
                nDropPosX = tbBLInfo.nDropPosX;
                nDropPosY = tbBLInfo.nDropPosY;
            end  
        end    

        BossLeader:AddPlayerRankAward(tbBLInfo.szType, nPlayerID, tbAllAward, nDropPosX, nDropPosY, szDropNpcName);
    end    
end

function tbNpc:AddPlayerAward(tbBLInfo, nPlayerID, nRank)
    if not tbBLInfo.tbTouchNpc[nPlayerID] then
        return;
    end    

    if not MODULE_ZONESERVER then
        local bSingleAward = BossLeader.tbSinglePlayerRank[tbBLInfo.szType];
        if bSingleAward then
            self:SendSinglePlayerAward(tbBLInfo, nPlayerID, nRank);   
        end 
    end
        
    local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
    if pPlayer then
        local LogType = Env.LogWay_FieldBoss;
        if tbBLInfo.szType == "Leader" then
            LogType = Env.LogWay_FieldLeader;
        end 
    
        local tbLogData = 
        {
            Result = Env.LogRound_SUCCESS;
            nRank = nRank;
        };
        pPlayer.ActionLog(Env.LogType_Activity, LogType, tbLogData);

        if BossLeader.nAchievementRank >= nRank then
            BossLeader:AddAchievement(pPlayer, tbBLInfo.szType, BossLeader.tbKillNpcAchievementRank);
        end
    end
        
    Log("BossLeader Add Player Award", tbBLInfo.szType, nPlayerID, nRank); 
end

function tbNpc:AddCaptainAward(tbBLInfo, tbKinSort, nCaptainId, nRank, tbTeam, tbDmgInfo)
    local nKinId = self:GetPlayerKinID(nCaptainId);
    if nKinId <= 0 then
        return;
    end

    local nCurtDmg = tbKinSort[nKinId];
    if nCurtDmg then
        tbKinSort[nKinId] = nCurtDmg + tbDmgInfo.nTotalDamage;
        return;
    end    

    tbKinSort[nKinId] = tbDmgInfo.nTotalDamage;

    local tbPrestige = BossLeader.tbDmgRankPrestige[tbBLInfo.szType];
    if tbPrestige then
        local nPrestige = tbPrestige[nRank];
        local nConnect = BossLeader:GetKinConnectIndex(nKinId);
        Lib:CallZ2SOrLocalScript(nConnect, "BossLeader:AddKinPrestige", nKinId, nPrestige, tbBLInfo.szType);     
    end

    Log("BossLeader Add Captain Award", tbBLInfo.szType, nCaptainId, nRank);   
end

function tbNpc:OnDeathNotic(pNpc, pKillNpc, nFirstCaptainId, szType, tbNpcInfo)
    if not pNpc then
        return;
    end    

    local szMapNotice = BossLeader.tbMapAllKillNotice[szType];
    local nMapCount = BossLeader:GetMapNpcCount(szType, pNpc.nMapId);
    if szMapNotice and nMapCount <= 0 then
        local szMapName = Map:GetMapName(pNpc.nMapTemplateId);
        local szMsg = string.format(szMapNotice, szMapName);
        local szExtMsg = "";
        if MODULE_ZONESERVER then
            szExtMsg = "【跨服】"
        end

        KPlayer.SendWorldNotify(1, 999, szExtMsg..szMsg, 1, 1);
    end

    local szDeathNotic = BossLeader.tbNpcKillNotice[szType];
    if szDeathNotic and tbNpcInfo.IsFalse ~= 1 then
        local szDeathName = "";
        if pKillNpc then
            szDeathName = pKillNpc.szName;
        elseif nFirstCaptainId > 0 then
            local tbStayInfo = KPlayer.GetRoleStayInfo(nFirstCaptainId);
            szDeathName = tbStayInfo.szName;
        end

        if not Lib:IsEmptyStr(szDeathName) then
            local szMsg = string.format(szDeathNotic, pNpc.szName, szDeathName);
            local szExtMsg = "";
            if MODULE_ZONESERVER then
                szExtMsg = "【跨服】"
            end
            KPlayer.SendWorldNotify(1, 999, szExtMsg..szMsg, 1, 1);
        end    
    end


    if szDeathNotic then
        BossLeader:AddNpcDeathInfo(szType, nFirstCaptainId, tbNpcInfo, pNpc.nMapTemplateId);
    end       
end

function tbNpc:GetPlayerKinID(nPlayerID)
    local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
    local nKinId = 0;
    if pPlayer then
        nKinId = pPlayer.dwKinId;
    else
        local tbStayInfo = KPlayer.GetRoleStayInfo(nPlayerID);
        if tbStayInfo then
            nKinId = tbStayInfo.dwKinId;
        end    
    end

    return nKinId;
end


function tbNpc:OnByAttack()
    if not me or not him then
        return;
    end

    local tbBLInfo = him.tbBossLeaderInfo;
    if not tbBLInfo or Lib:IsEmptyStr(tbBLInfo.szType) then
        Log("Error BossLeader Not Boss Leader Info", him.nTemplateId);
        return;
    end
    
    local nMapID = him.GetWorldPos();      
    if not BossLeader:HaveNpc(tbBLInfo.szType, him.nId, nMapID) then
        Log("Error BossLeader Not Boss Leader HaveNpc", him.nTemplateId);
        return;
    end 

    if me.dwKinId > 0 then
        BossLeader:AddKinJoinCount(tbBLInfo.szType, me);

        if not tbBLInfo.nFirstTouchKin then
            tbBLInfo.nFirstTouchKin = me.dwKinId;
            Log("BossLeader nFirstTouchKin", him.nTemplateId, me.dwKinId, tbBLInfo.nFirstTouchKin);
        end  
    end

    if tbBLInfo.szType == "Leader" then
        me.nForbidPkMode = Player.MODE_PEACE;
        if me.nPkMode == Player.MODE_PEACE or me.nPkMode == Player.MODE_EXCERCISE then
            Player:ChangePKMode(me, Player.MODE_PK);
            me.SendBlackBoardMsg("攻擊野外首領，強制切為幫派模式");
        end
    end    

    local bTouchNpc = tbBLInfo.tbTouchNpc[me.dwID]; 
    tbBLInfo.tbTouchNpc[me.dwID] = true;  

    local tbTouchImitityPlayer = tbBLInfo.tbTouchImitityPlayer;
    local nImitity = BossLeader.tbTouchImitityTeam[tbBLInfo.szType];
    if me.dwTeamID > 0 and not tbTouchImitityPlayer[me.dwID] and nImitity then
        local LogType = Env.LogWay_FieldBoss;
        if tbBLInfo.szType == "Leader" then
            LogType = Env.LogWay_FieldLeader;
        end 
        tbTouchImitityPlayer[me.dwID] = true;
        local tbMember = TeamMgr:GetMembers(me.dwTeamID);
        for _, nPlayerID in pairs(tbMember) do
            if nPlayerID ~= me.dwID then
                tbTouchImitityPlayer[nPlayerID] = true;
                Lib:CallZ2SOrLocalScript(me.nZoneIndex, "BossLeader:FriendShipAddImitity", me.dwID, nPlayerID, nImitity, LogType);  
            end    
        end    
    end

    Lib:CallZ2SOrLocalScript(me.nZoneIndex, "BossLeader:TeacherOnJoinBossLeader", me.dwID, tbBLInfo.szType);  

    if not bTouchNpc and him.tbBossLeaderInfo and him.tbBossLeaderInfo.bIsFirstDmg then
        Lib:CallZ2SOrLocalScript(me.nZoneIndex, "BossLeader:DoAttackFirstDmgAward", me.dwID, tbBLInfo.szType);  
    end      
end

function tbNpc:CheckFirstDmgAward(pPlayer, pNpc, szType)
    if not pNpc.tbBossLeaderInfo then
        return false;
    end

    if not pNpc.tbBossLeaderInfo.bIsFirstDmg then
        return false;
    end

    local nSaveId = tbSaveBossLeaderDay[szType];
    if not nSaveId then
        return false;
    end    

    local nDay = pPlayer.GetUserValue(SAVE_BOSSLEADER_GROUP, nSaveId);
    if nDay >= Lib:GetLocalDay() then
        return false;
    end
     
    local tbAward = BossLeader:GetFirstDmgAward(szType);
    if not tbAward then
        return false;
    end

    return true, tbAward, nSaveId;    
end