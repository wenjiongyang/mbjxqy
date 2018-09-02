local tbNpc = Npc:GetClass("RandomBoss");

local SAVE_RANDOMBOSS_GROUP = 90;

local tbSaveRandomBossDay   = {["CangBaoTuBoss"] = 1}
tbNpc.SAVE_RANDOMBOSS_GROUP = SAVE_RANDOMBOSS_GROUP;

tbNpc.AwardType =                           -- 每天限制获取的奖励类型
{
    PlayerAward = 1,                        -- 玩家个人奖励
    KinPrestige = 2,                        -- 家族声望
}

function tbNpc:OnDeath(pKillNpc)
    if not him then
        return;
    end

    local tbBLInfo = him.tbRandomBossInfo;
    if not tbBLInfo or Lib:IsEmptyStr(tbBLInfo.szType) then
        Log("Error RandomBoss Not Boss Info", him.nTemplateId);
        return;
    end

    local nMapID, nDropPosX, nDropPosY = him.GetWorldPos();  
    if not RandomBoss:HaveNpc(tbBLInfo.szType, him.nId, nMapID) then
        Log("Error RandomBoss Not Boss HaveNpc", him.nTemplateId);
        return;
    end
  
    tbBLInfo.nDropPosX = nDropPosX;
    tbBLInfo.nDropPosY = nDropPosY;
    tbBLInfo.nDropMapID = nMapID;
    tbBLInfo.szDropNpcName = him.szName or "";

    RandomBoss:RemoveNpc(tbBLInfo.szType, him.nId, nMapID);

    local tbSortDamage = him.GetDamageInfo();
    if not tbSortDamage or #tbSortDamage <= 0 then
        return;
    end

    local function fnDamageCmp(a, b)
        return a.nTotalDamage > b.nTotalDamage;
    end

    table.sort(tbSortDamage, fnDamageCmp);

    Log("------Start RandomBoss Dmg Info------", tbBLInfo.szType);
    Lib:LogTB(tbSortDamage);
    Log("------End RandomBoss Dmg Info------", tbBLInfo.szType);

    local tbKinSort = {};

    for nRank, tbDmgInfo in ipairs(tbSortDamage) do

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
        end
    end
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
     local bHaveTimes = RandomBoss:IsHaveAwardTimes(tbBLInfo.szType,self.AwardType.KinPrestige,nCaptainId)
    if not bHaveTimes then
        return 
    end

    tbKinSort[nKinId] = tbDmgInfo.nTotalDamage;

    local tbPrestige = RandomBoss.tbDmgRankPrestige[tbBLInfo.szType];
    if tbPrestige then
        local nPrestige = tbPrestige[nRank];
        RandomBoss:AddKinPrestige(nKinId, nPrestige);
        RandomBoss:ReduceAwardTimes(tbBLInfo.szType,self.AwardType.KinPrestige,nCaptainId)
    end

    Log("RandomBoss Add Captain Award", tbBLInfo.szType, nCaptainId, nRank);   
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

    local nTotalTeam = #tbTeamPlayer;
    if nTotalTeam >= 2 then
        for nI = 1, nTotalTeam - 1 do
        for nJ = nI + 1, nTotalTeam do
                local nPlayer1 = tbTeamPlayer[nI];
                local nPlayer2 = tbTeamPlayer[nJ];
                local nImitity = RandomBoss.tbKillImitityTeam[tbBLInfo.szType];
                if nImitity then
                    FriendShip:AddImitity(nPlayer1, nPlayer2, nImitity, Env.LogWay_RandomBoss);
                end    
            end    
        end
    end

    Log("RandomBoss Add Team Award", tbBLInfo.szType, nTeamId, nRank); 
end

function tbNpc:AddPlayerAward(tbBLInfo, nPlayerID, nRank)
    local bHaveTimes = RandomBoss:IsHaveAwardTimes(tbBLInfo.szType,self.AwardType.PlayerAward,nPlayerID)
    if not bHaveTimes then
        return 
    end
    if not tbBLInfo.tbTouchNpc[nPlayerID] then
        return;
    end    

    local bSingleAward = RandomBoss.tbSinglePlayerRank[tbBLInfo.szType];
    if bSingleAward then
        self:SendSinglePlayerAward(tbBLInfo, nPlayerID, nRank);   
    end 

    local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
    if pPlayer then
        local LogType = Env.LogWay_RandomBoss;
    
        local tbLogData = 
        {
            Result = Env.LogRound_SUCCESS;
            nRank = nRank;
        };
        pPlayer.ActionLog(Env.LogType_Activity, LogType, tbLogData);
    end
        
    Log("RandomBoss Add Player Award", tbBLInfo.szType, nPlayerID, nRank); 
end

function tbNpc:SendSinglePlayerAward(tbBLInfo, nPlayerID, nRank)
    tbBLInfo.tbSinglePlayerAward = tbBLInfo.tbSinglePlayerAward or {};
    local tbSinglePlayerAward = tbBLInfo.tbSinglePlayerAward;
    if tbSinglePlayerAward[nPlayerID] then
        Log("RandomBoss SinglePlayerAward Have", nPlayerID, tbBLInfo.szType, nRank);
        return;   
    end

    tbSinglePlayerAward[nPlayerID] = nRank;

    local tbAllAward = RandomBoss:GetPlayerDmgRank(tbBLInfo.tbNpcInfo.PlayerAwardID, nRank);
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

        RandomBoss:AddPlayerRankAward(tbBLInfo.szType, nPlayerID, tbAllAward, nDropPosX, nDropPosY,szDropNpcName);
        RandomBoss:ReduceAwardTimes(tbBLInfo.szType,self.AwardType.PlayerAward,nPlayerID)
    end    
end

function tbNpc:OnByAttack()
    if not me or not him then
        return;
    end

    local tbBLInfo = him.tbRandomBossInfo;
    if not tbBLInfo or Lib:IsEmptyStr(tbBLInfo.szType) then
        Log("Error RandomBoss Not Boss Info", him.nTemplateId);
        return;
    end
    
    local nMapID = him.GetWorldPos();    

    if not RandomBoss:HaveNpc(tbBLInfo.szType, him.nId, nMapID) then
        Log("Error RandomBoss Not Boss HaveNpc", him.nTemplateId);
        return;
    end 

    me.nForbidPkMode = Player.MODE_PEACE;
    if me.nPkMode == Player.MODE_PEACE then
        Player:ChangePKMode(me, Player.MODE_PK);
        me.SendBlackBoardMsg("攻擊野外首領，強制切為幫派模式");
    end    
    
    tbBLInfo.tbTouchNpc[me.dwID] = true;

    local tbTouchImitityPlayer = tbBLInfo.tbTouchImitityPlayer;
    local nImitity = RandomBoss.tbTouchImitityTeam[tbBLInfo.szType];
    if me.dwTeamID > 0 and not tbTouchImitityPlayer[me.dwID] and nImitity then
        tbTouchImitityPlayer[me.dwID] = true;
        local tbMember = TeamMgr:GetMembers(me.dwTeamID);
        for _, nPlayerID in pairs(tbMember) do
            if nPlayerID ~= me.dwID then
                tbTouchImitityPlayer[nPlayerID] = true;
                FriendShip:AddImitity(me.dwID, nPlayerID, nImitity, Env.LogWay_RandomBoss);
            end    
        end    
    end    

    local bRetcode, tbAward, nSaveId = tbNpc:CheckFirstDmgAward(me, him, tbBLInfo.szType);
    if not bRetcode then
        return;
    end

    me.SetUserValue(SAVE_RANDOMBOSS_GROUP, nSaveId, Lib:GetLocalDay());
    RandomBoss:SendMailAward(tbBLInfo.szType, me.dwID, tbAward);

    Log("OnByAttack First Dmg", me.szName, me.dwID, tbBLInfo.szType);    
end

function tbNpc:CheckFirstDmgAward(pPlayer, pNpc, szType)

    if not pNpc.tbRandomBossInfo then
        return false;
    end

    if not pNpc.tbRandomBossInfo.bIsFirstDmg then
        return false;
    end

    local nSaveId = tbSaveRandomBossDay[szType];
    if not nSaveId then
        return false;
    end    

    local nDay = pPlayer.GetUserValue(SAVE_RANDOMBOSS_GROUP, nSaveId);
    if nDay >= Lib:GetLocalDay() then
        return false;
    end
     
    local tbAward = RandomBoss:GetFirstDmgAward(szType);
    if not tbAward then
        return false;
    end

    return true, tbAward, nSaveId;    
end