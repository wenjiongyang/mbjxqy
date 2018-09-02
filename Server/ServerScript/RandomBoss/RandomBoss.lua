Require("CommonScript/Player/PlayerEventRegister.lua");
Require("CommonScript/RandomBoss/RandomBoss.lua");
Require("CommonScript/Map/Map.lua");

RandomBoss.tbAllTypeData  = RandomBoss.tbAllTypeData or {};
RandomBoss.tbCreateNpcMap = RandomBoss.tbCreateNpcMap or {};
RandomBoss.tbAllNpcInfo = RandomBoss.tbAllNpcInfo or {}

function RandomBoss:GetTypeData(szType)
    if not self.tbAllTypeData[szType] then
        self.tbAllTypeData[szType] = 
        {
            nExtCount = 0;
            tbAllCreateNpc = {}; 
            tbAwardTimes = {}
        };
    end

    return self.tbAllTypeData[szType];    
end

function RandomBoss:RandomNpcGroup(tbMapInfo)
    local tbGroupId = {};
    local nRandomCount = tbMapInfo.nNpcGroupRateCount;
    local nTotalRate   = tbMapInfo.nTotalGroupRate;
    if nRandomCount >= #tbMapInfo.tbGroupNpc then
        for _, tbInfo in pairs(tbMapInfo.tbGroupNpc) do
            tbGroupId[tbInfo.nNpcGroupID] = 1;
        end

        return tbGroupId;
    end    

    while true do
        if Lib:CountTB(tbGroupId) == nRandomCount then
            return tbGroupId;
        end

        local nRate = MathRandom(nTotalRate);
        for _, tbInfo in pairs(tbMapInfo.tbGroupNpc) do
            if not tbGroupId[tbInfo.nNpcGroupID] then
                if tbInfo.nRate >= nRate then
                    tbGroupId[tbInfo.nNpcGroupID] = 1;
                    nTotalRate = nTotalRate - tbInfo.nRate;
                    break;
                end
                
                nRate = nRate - tbInfo.nRate; 

                if nRate < 0 then
                    Log("Error RandomBoss:RandomNpcGroup", tbInfo.nNpcGroupID);
                    return;
                end      
            end 
        end   
    end

    return nil;    
end

function RandomBoss:CreateRandomNpc(szType, nMapID, tbGroupId, nNpcCount)
    if nNpcCount <= 0 then
        return;
    end    

    local tbGroupMask = {};
    for nGroupID, _ in pairs(tbGroupId) do
        local tbGroupNpc = self:GetGroupNpc(nGroupID);
        if #tbGroupNpc.tbRateNpc > 0 then
            if nNpcCount >= #tbGroupNpc.tbRateNpc then
                for _, tbInfo in pairs(tbGroupNpc.tbRateNpc) do
                    self:AddNpcInfo(nMapID, tbInfo, szType);
                end    
            else
                local tbRateIndex = {};
                local nTotalRate = tbGroupNpc.nTotalRate;
                local nCurCount = #tbGroupNpc.tbRateNpc;
                for nIdex, tbInfo in pairs(tbGroupNpc.tbRateNpc) do
                    if tbInfo.Mask > 0 and tbGroupMask[tbInfo.Mask] then
                        nTotalRate = nTotalRate - tbInfo.Rate;
                        nCurCount = nCurCount - 1;
                    end
                end

                while true do
                    if Lib:CountTB(tbRateIndex) == nNpcCount then
                        break;
                    end

                    if nCurCount <= 0 then
                        Log("Error RandomBoss:CreateRandomNpc", szType, nMapID);
                        return;
                    end    

                    local nRate = MathRandom(nTotalRate);
                    for nIdex, tbInfo in pairs(tbGroupNpc.tbRateNpc) do
                        if not tbRateIndex[nIdex] and (tbInfo.Mask <= 0 or not tbGroupMask[tbInfo.Mask]) then
                            if tbInfo.Rate >= nRate then
                                tbRateIndex[nIdex] = 1;
                                tbGroupMask[tbInfo.Mask] = 1;
                                nTotalRate = nTotalRate - tbInfo.Rate;
                                nCurCount = nCurCount - 1;
                                self:AddNpcInfo(nMapID, tbInfo, szType);
                                break;
                            end
    
                            nRate = nRate - tbInfo.Rate;   
                        end
                    end    
                end    
            end    
        else
            Log("ERROR RandomBoss CreateRandomNpc == 0", nGroupID);
        end    
    end    
end

function RandomBoss:CreateAllNpcGroup(szType)
     
     self.tbAllNpcInfo[szType] = {}
    local tbTimeNpcGroup, szTimeFrame = self:GetTimeFrameNpcGroup(szType); 
    assert(tbTimeNpcGroup, "CreateAllNpcGroup Not Type" ..szType);
    local tbTypeData = self:GetTypeData(szType);
    local nExtCount = tbTypeData.nExtCount;
    for _, tbALLMapInfo in pairs(tbTimeNpcGroup) do       
        for _, tbMapInfo in pairs(tbALLMapInfo) do
            local tbGroupId = self:RandomNpcGroup(tbMapInfo);
            local nNpcCount = tbMapInfo.nNpcRateCount + nExtCount;
            local nMapID    = tbMapInfo.nMapTID;
            self:CreateRandomNpc(szType, nMapID, tbGroupId, nNpcCount);
        end     
    end

    Log("RandomBoss CreateAllNpcGroup", szType, szTimeFrame);
end

function RandomBoss:AddNpcInfo(nMapID, tbNpcInfo, szType, bNotPre)
   table.insert(self.tbAllNpcInfo[szType],tbNpcInfo)
end


function RandomBoss:RandomOneBoss(nMapID,nPosX,nPosY,szType)

    if not self.tbAllNpcInfo[szType] or not next(self.tbAllNpcInfo[szType]) then
        return
    end
    local nHit = MathRandom(#self.tbAllNpcInfo[szType])

    local tbNpcInfo = self.tbAllNpcInfo[szType][nHit]
    if not tbNpcInfo then
        return
    end
    local pNpc = KNpc.Add(tbNpcInfo.NpcID, tbNpcInfo.NpcLevel, -1, nMapID, nPosX, nPosY, 0);
    if not pNpc then
       Log("Error RandomBoss CreateNpc", szType, tbNpcInfo.NpcID, tbNpcInfo.NpcLevel, nMapID, tbNpcInfo.PosX, tbNpcInfo.PosY);   
       return;
    end
    pNpc.SetByAttackCallScript(1);
    pNpc.tbRandomBossInfo = {};
    pNpc.tbRandomBossInfo.bIsFirstDmg = true;
    pNpc.tbRandomBossInfo.szType = szType;
    pNpc.tbRandomBossInfo.tbNpcInfo = tbNpcInfo;
    pNpc.tbRandomBossInfo.tbTouchImitityPlayer = {};
    pNpc.tbRandomBossInfo.tbTouchNpc          = {};
    pNpc.tbRandomBossInfo.tbSinglePlayerAward = {};

    local tbMapNpc = self:GetCreateNpcByMap(szType, nMapID);
    tbMapNpc[pNpc.nId] = tbNpcInfo;

    Log("RandomBoss CreateNpc", szType, tbNpcInfo.NpcID, tbNpcInfo.NpcLevel, nMapID, nPosX, nPosY); 
    return true
end

function RandomBoss:GetCreateNpcData(szType)
    local tbTypeData = self:GetTypeData(szType);
    return tbTypeData.tbAllCreateNpc;
end

function RandomBoss:GetCreateNpcByMap(szType, nMapID)
    local tbCreateNpcData = self:GetCreateNpcData(szType);
    tbCreateNpcData[nMapID] = tbCreateNpcData[nMapID] or {};
    return tbCreateNpcData[nMapID];        
end

function RandomBoss:HaveNpc(szType, nNpcID, nMapID)
    local tbMapNpc = self:GetCreateNpcByMap(szType, nMapID);
    if not tbMapNpc[nNpcID] then
        return false;
    end

    return true;    
end

function RandomBoss:SendMailAward(szType, nPlayerID, tbAward, nDropX, nDropY, szDropNpcName)
    local nLogType = Env.LogWay_RandomBoss;
            
    local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
    if pPlayer and nDropX and nDropY then
        self:SendDropAward(pPlayer, tbAward, nLogType, nDropX, nDropY, szDropNpcName);
    elseif pPlayer then
        pPlayer.SendAward(tbAward, false, true, nLogType);
    else      
        local tbMail =
        {
            To = nPlayerID,
            Text= self.tbSendMailTxt[szType];
            tbAttach = tbAward,
            nLogReazon = nLogType,
        };

        Mail:SendSystemMail(tbMail);
    end 

    Log("RandomBoss SendMailAward PlayerID", nPlayerID)
end

function RandomBoss:SendDropAward(pPlayer, tbAward, nLogType, nPosX, nPosY, szDropNpcName)
    local tbMsgInfo = {};
    tbMsgInfo.szNpcName = szDropNpcName or "";
    pPlayer.DropAward(nPosX, nPosY, tbMsgInfo, tbAward, nLogType, nil, false, true);
end

function RandomBoss:RemoveNpc(szType, nNpcID, nMapID)
    local tbMapNpc = self:GetCreateNpcByMap(szType, nMapID);
    tbMapNpc[nNpcID] = nil;
end

function RandomBoss:GetPlayerDmgRank(nAwardID, nRank)
    local tbPlayerAward = self.tbAllPlayerDmgRank[nAwardID];
    if not tbPlayerAward then
        Log("Error Not Player Dmg Rank", nAwardID, nRank);
        return nil;
    end

    local tbAllAward = tbPlayerAward[nRank];
    if not tbAllAward then
        tbAllAward = tbPlayerAward[-1];
    end    

    return tbAllAward;   
end

function RandomBoss:AddPlayerRankAward(szType, nPlayerID, tbAllAward, nDropX, nDropY, szDropNpcName)
    if not tbAllAward then
        Log("Error RandomBoss AddPlayerRankAward", szType, nPlayerID);
        return;
    end    

    if #tbAllAward.tbAward > 0  then
        self:SendMailAward(szType, nPlayerID, tbAllAward.tbAward, nDropX, nDropY, szDropNpcName);
    end
        
    if tbAllAward.nRateAward and tbAllAward.nRateAward > 0 then
        local nRate = MathRandom(100);
        if tbAllAward.nRateAward >= nRate and #tbAllAward.tbRateAward > 0 then
            self:SendMailAward(szType, nPlayerID, tbAllAward.tbRateAward, nDropX, nDropY, szDropNpcName);
        end    
    end
end

function RandomBoss:AddKinPrestige(nKinId, nPrestige, szType)
    if not nPrestige or nPrestige <= 0 or nKinId <= 0 then
        return;
    end

    local tbKinData = Kin:GetKinById(nKinId);
    if not tbKinData then
        return;
    end

    tbKinData:AddPrestige(nPrestige, Env.LogWay_RandomBoss);    
end


----------------------------每天限制奖励相关（不存盘）

function RandomBoss:GetAwardTimes(szType,nAwardType,nPlayerID)
    local nDay = Lib:GetLocalDay()
    local tbTypeData = self:GetTypeData(szType);
    local tbAwardTimes =  tbTypeData.tbAwardTimes;
    tbAwardTimes[nAwardType] = tbAwardTimes[nAwardType] or {}
    tbAwardTimes[nAwardType][nPlayerID] = tbAwardTimes[nAwardType][nPlayerID] or {}
    tbAwardTimes[nAwardType][nPlayerID].Times = tbAwardTimes[nAwardType][nPlayerID].Times or self.MaxBossKillTimes
    tbAwardTimes[nAwardType][nPlayerID].nDay = tbAwardTimes[nAwardType][nPlayerID].nDay or nDay
    if tbAwardTimes[nAwardType][nPlayerID].nDay < nDay then
        tbAwardTimes[nAwardType][nPlayerID].Times = self.MaxBossKillTimes
        tbAwardTimes[nAwardType][nPlayerID].nDay = nDay
    end
    return tbAwardTimes[nAwardType][nPlayerID].Times
end

function RandomBoss:ReduceAwardTimes(szType,nAwardType,nPlayerID)
    local tbTypeData = self:GetTypeData(szType);
    local tbAwardTimes =  tbTypeData.tbAwardTimes;
    tbAwardTimes[nAwardType][nPlayerID].Times = tbAwardTimes[nAwardType][nPlayerID].Times - 1
end

function RandomBoss:IsHaveAwardTimes(szType,nAwardType,nPlayerID)
    return self:GetAwardTimes(szType,nAwardType,nPlayerID) > 0
end

