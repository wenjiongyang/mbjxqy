Require("CommonScript/Player/PlayerEventRegister.lua");
Require("CommonScript/BossLeader/BossLeader.lua");
Require("CommonScript/Map/Map.lua");

BossLeader.tbAllTypeData  = BossLeader.tbAllTypeData or {};
BossLeader.tbAllTypeToday = BossLeader.tbAllTypeToday or {};
BossLeader.tbCreateNpcMap = BossLeader.tbCreateNpcMap or {};
BossLeader.tbAllPlayerMapInfo = BossLeader.tbAllPlayerMapInfo or {};

BossLeader.funCreateFubenMap = function(tbMap, nMapId)
    Log("BossLeader CreateFubenMap", tbMap.nMapTemplateId, nMapId);
end

BossLeader.funOnDestroyFubenMap = function(tbMap, nMapId)
    BossLeader:OnDestroyMap(tbMap.nMapTemplateId, nMapId);
    Log("BossLeader OnDestroyFubenMap", tbMap.nMapTemplateId, nMapId);
end

BossLeader.funOnEnterFubenMap = function(tbMap, nMapId)
    BossLeader:OnEnterMap(tbMap.nMapTemplateId, nMapId)
    Log("BossLeader OnEnterFubenMap", tbMap.nMapTemplateId, nMapId);
end

BossLeader.funOnLeaveFubenMap = function(tbMap, nMapId)
    BossLeader:OnLeaveMap(tbMap.nMapTemplateId, nMapId);
    Log("BossLeader OnLeaveFubenMap", tbMap.nMapTemplateId, nMapId);
end

BossLeader.funOnPlayerTrap = function (tbMap, nMapId, szTrapName)
    BossLeader:OnPlayerTrap(tbMap.nMapTemplateId, nMapId, szTrapName);
end

BossLeader.funOnPlayerLogin = function (tbMap, nMapId)
    BossLeader:OnLoginMap(tbMap.nMapTemplateId, nMapId);
end

function BossLeader:InitFubenMap()
    for nMapTID, _ in pairs(self.tbAllTMapSetting) do
        local nMapType = Map:GetMapType(nMapTID);
        if nMapType == Map.emMap_Fuben then
            local tbMap = Map:GetClass(nMapTID);
            tbMap.OnCreate  = BossLeader.funCreateFubenMap;
            tbMap.OnDestroy = BossLeader.funOnDestroyFubenMap;
            tbMap.OnEnter   = BossLeader.funOnEnterFubenMap;
            tbMap.OnLeave   = BossLeader.funOnLeaveFubenMap;
            tbMap.OnPlayerTrap = BossLeader.funOnPlayerTrap;
            tbMap.OnLogin   = BossLeader.funOnPlayerLogin;
        end
    end    
end

BossLeader:InitFubenMap();

function BossLeader:SendCrossKinMsg(szShowMsg, nKinId)
    ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szShowMsg, nKinId);
end 

function BossLeader:RandomNpcGroup(tbMapInfo)
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
                    Log("Error BossLeader:RandomNpcGroup", tbInfo.nNpcGroupID);
                    return;
                end      
            end 
        end   
    end

    return nil;    
end

function BossLeader:AddAchievement(pPlayer, szType, tbAchievementType)
    local tbAchievement = tbAchievementType[szType];
    if not tbAchievement or Lib:IsEmptyStr(tbAchievement.szKey) then
        return;
    end

    Lib:CallZ2SOrLocalScript(pPlayer.nZoneIndex, "BossLeader:AddPlayerAchievement", pPlayer.dwID, tbAchievement.szKey, tbAchievement.nValue);  
end

function BossLeader:AddPlayerAchievement(nPlayerID, szKey, nValue)
    local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
    if not pPlayer then
        return;
    end

    Achievement:AddCount(pPlayer, szKey, nValue);        
end

function BossLeader:FriendShipAddImitity(nPlayer1, nPlayer2, nImitity, LogType)
    FriendShip:AddImitity(nPlayer1, nPlayer2, nImitity, LogType)
end

function BossLeader:TeacherOnJoinBossLeader(nPlayerID, szType)
    local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
    if not pPlayer then
        return;
    end

    TeacherStudent:OnJoinBossLeader(pPlayer, szType);
end

function BossLeader:CheckAttackFirstDmgAward(pPlayer, szType)
    local tbBossNpc = Npc:GetClass("BossLeader");
    local nSaveId = tbBossNpc.tbSaveBossLeaderDay[szType];
    if not nSaveId then
        return false;
    end    

    local nDay = pPlayer.GetUserValue(tbBossNpc.SAVE_BOSSLEADER_GROUP, nSaveId);
    if nDay >= Lib:GetLocalDay() then
        return false;
    end
     
    local tbAward = BossLeader:GetFirstDmgAward(szType);
    if not tbAward then
        return false;
    end

    return true, tbAward, nSaveId;   
end

function BossLeader:DoAttackFirstDmgAward(nPlayerId, szType)
    local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
    if not pPlayer then
        return;
    end

    local bRetcode, tbAward, nSaveId = self:CheckAttackFirstDmgAward(pPlayer, szType);
    if not bRetcode then
        return;
    end

    local tbBossNpc = Npc:GetClass("BossLeader");
    pPlayer.SetUserValue(tbBossNpc.SAVE_BOSSLEADER_GROUP, nSaveId, Lib:GetLocalDay());
    self:SendMailAward(szType, pPlayer.dwID, tbAward);
    self:AddAchievement(pPlayer, szType, self.tbFirstTouchAchievement);

    local szEveryTarget = self.tbEveryDayTarget[szType];
    if szEveryTarget then
        EverydayTarget:AddCount(pPlayer, szEveryTarget);
    end

    Log("OnByAttack First Dmg", pPlayer.szName, pPlayer.dwID, szType);   
end

function BossLeader:CreateRandomNpc(szType, nMapID, tbGroupId, nNpcCount, nNpcLevel, tbMapMaskInfo)
    if nNpcCount <= 0 then
        return;
    end  

    local tbGroupMask = {};
    if tbMapMaskInfo then
        tbGroupMask = tbMapMaskInfo;
    end
        
    for nGroupID, _ in pairs(tbGroupId) do
        local tbGroupNpc = self:GetGroupNpc(nGroupID);
        if #tbGroupNpc.tbRateNpc > 0 then
            if nNpcCount >= #tbGroupNpc.tbRateNpc then
                for _, tbInfo in pairs(tbGroupNpc.tbRateNpc) do
                    self:CreateNpc(nMapID, tbInfo, szType, false, nNpcLevel);
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
                        Log("Error BossLeader:CreateRandomNpc", szType, nMapID);
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
                                --print(nTotalRate, tbInfo.Rate, nIdex);
                                self:CreateNpc(nMapID, tbInfo, szType, false, nNpcLevel);
                                break;
                            end
    
                            nRate = nRate - tbInfo.Rate;   
                        end
                    end    
                end    
            end    
        else
            Log("ERROR BossLeader CreateRandomNpc == 0", nGroupID);
        end    
    end    
end

function BossLeader:RandomLinkGroup(tbMapInfo, tbLinkGroup)
    local tbLinkInfo = self:GetLinkMapInfo(tbMapInfo.nLinkMapID);
    if not tbLinkInfo then
        return;
    end

    local nRetNpcCount = tbLinkInfo.TotalNpcCount - tbLinkGroup.nTotalNpcCount;
    if nRetNpcCount <= 0 then
        return;
    end

    local nNeedMapCount = math.ceil(nRetNpcCount / tbLinkInfo.MaxOneNpcCount);
    local nRetMapCount = tbLinkInfo.TotalMapCount - tbLinkGroup.nMapCount;
    local nMinNpcCount = -1;
    if nNeedMapCount >= nRetMapCount then
        nMinNpcCount = nRetNpcCount % tbLinkInfo.MaxOneNpcCount;
        if nMinNpcCount <= 0 then
            nMinNpcCount = tbLinkInfo.MaxOneNpcCount;
        end    
    end 

    tbLinkGroup.nMapCount = tbLinkGroup.nMapCount + 1;
    local tbRetGroup = {};
    local nRandomCount = math.min(nRetNpcCount, tbLinkInfo.MaxOneNpcCount);
    local nNpcCount = MathRandom(nRandomCount +  1) - 1;
    if nMinNpcCount > nNpcCount then
        nNpcCount = nMinNpcCount;
    end
        
    if nNpcCount > 0 then
        for nI = 1, nNpcCount do
            local nCurRetNpcCount = tbLinkInfo.TotalNpcCount - tbLinkGroup.nTotalNpcCount;
            if nCurRetNpcCount > 0 then
                local nGroutNpcIndex = tbLinkInfo.FalseNpcGroupIndex;
                local nRetTrueCount = tbLinkInfo.TrueNpcCount - tbLinkGroup.nTrueNpcCount;

                if (nRetTrueCount > 0 and MathRandom(2) == 1) or (nCurRetNpcCount == nRetTrueCount) then
                    nGroutNpcIndex = tbLinkInfo.TrueNpcGroupIndex;
                    tbLinkGroup.nTrueNpcCount = tbLinkGroup.nTrueNpcCount + 1;
                end

                tbLinkGroup.nTotalNpcCount = tbLinkGroup.nTotalNpcCount + 1;
                table.insert(tbRetGroup, tbMapInfo.tbGroupNpc[nGroutNpcIndex].nNpcGroupID);
            end    
        end
    end
        
    return tbRetGroup;    
end

function BossLeader:CreateAllNpcGroup(szType)
    local tbTimeNpcGroup = self:GetTimeFrameNpcGroup(szType);
    assert(tbTimeNpcGroup, "CreateAllNpcGroup Not Type" ..szType);
    local tbTypeData = self:GetTypeData(szType);
    local nExtCount = tbTypeData.nExtCount;
    self.tbAllMapMaskInfo = {};
    self.tbAllLinkGroupInfo = {};

    for _, tbALLMapInfo in pairs(tbTimeNpcGroup) do
        for _, tbMapInfo in pairs(tbALLMapInfo) do

            local nMapID    = self:GetMapIDByTemplate(tbMapInfo.nMapTID);
            local nNpcLevel = tbMapInfo.nNpcLevel;

            if tbMapInfo.nLinkMapID and tbMapInfo.nLinkMapID > 0 then
                if not self.tbAllLinkGroupInfo[tbMapInfo.nLinkMapID] then
                    local tbLinkGroup = {};
                    tbLinkGroup.nTotalNpcCount = 0;
                    tbLinkGroup.nTrueNpcCount = 0;
                    tbLinkGroup.nMapCount     = 0;
                    self.tbAllLinkGroupInfo[tbMapInfo.nLinkMapID] = tbLinkGroup;
                end 

                local tbRetLink = self:RandomLinkGroup(tbMapInfo, self.tbAllLinkGroupInfo[tbMapInfo.nLinkMapID]);
                if tbRetLink then
                    for _, nGroupID in pairs(tbRetLink) do
                        local tbCurGroupId = {};
                        tbCurGroupId[nGroupID] = 1;

                        self.tbAllMapMaskInfo[nMapID] = self.tbAllMapMaskInfo[nMapID] or {};
                        self:CreateRandomNpc(szType, nMapID, tbCurGroupId, 1, nNpcLevel, self.tbAllMapMaskInfo[nMapID]);
                    end

                    Log("BossLeader RandomLinkGroup", szType, nMapID, Lib:CountTB(tbRetLink));
                end    
            else
                local tbGroupId = self:RandomNpcGroup(tbMapInfo);
                local nNpcCount = tbMapInfo.nNpcRateCount + nExtCount;
                self.tbAllMapMaskInfo[nMapID] = self.tbAllMapMaskInfo[nMapID] or {};
                self:CreateRandomNpc(szType, nMapID, tbGroupId, nNpcCount, nNpcLevel, self.tbAllMapMaskInfo[nMapID]);
            end   
        end     
    end

    self.tbAllMapMaskInfo = {};
    self.tbAllLinkGroupInfo = {};
    Log("BossLeader CreateAllNpcGroup", szType);
end

function BossLeader:OnCreateMap(nMapTemplateId, nMapId)
    for szType, tbTypeData in pairs(self.tbAllTypeData) do
        for nCurMapID, tbAllNpcInfo in pairs(tbTypeData.tbPrepareCreateNpc) do
            if nCurMapID == nMapId then

                for _, tbNpcInfo in pairs(tbAllNpcInfo) do
                    BossLeader:CreateNpc(nCurMapID, tbNpcInfo[1], szType, true, tbNpcInfo[2])
                end
                    
                tbTypeData.tbPrepareCreateNpc[nCurMapID] = nil;
                Log("BossLeader tbPrepareCreateNpc", szType, nCurMapID); 
            end      
        end
    end
end

function BossLeader:CreateNpc(nMapID, tbNpcInfo, szType, bNotPre, nNpcLevel)
    nNpcLevel = nNpcLevel or 0;

    local bFinish = IsLoadFinishMap(nMapID);
    if not bFinish then
        if not bNotPre then
            local tbPreareNpc = self:GetPrepareNpcData(szType);
            tbPreareNpc[nMapID] = tbPreareNpc[nMapID] or {};

            table.insert(tbPreareNpc[nMapID], {tbNpcInfo, nNpcLevel});
            Log("BossLeader PreareNpc", szType, tbNpcInfo.NpcID, tbNpcInfo.NpcLevel, nMapID, tbNpcInfo.PosX, tbNpcInfo.PosY); 
        else
            Log("Error BossLeader PreareNpc", szType, tbNpcInfo.NpcID, tbNpcInfo.NpcLevel, nMapID, tbNpcInfo.PosX, tbNpcInfo.PosY); 
        end

       return;
    end

    local nCurNpcLevel = tbNpcInfo.NpcLevel;
    if nNpcLevel and nNpcLevel > 0 then
        nCurNpcLevel = nNpcLevel;
    end    
         
    local pNpc = KNpc.Add(tbNpcInfo.NpcID, nCurNpcLevel, -1, nMapID, tbNpcInfo.PosX, tbNpcInfo.PosY, 0);
    if not pNpc then
        Log("Error BossLeader CreateNpc", szType, tbNpcInfo.NpcID, tbNpcInfo.NpcLevel, nMapID, tbNpcInfo.PosX, tbNpcInfo.PosY);   
        return;
    end

    pNpc.SetByAttackCallScript(1);
    pNpc.tbBossLeaderInfo = {};
    pNpc.tbBossLeaderInfo.bIsFirstDmg = true;
    pNpc.tbBossLeaderInfo.szType = szType;
    pNpc.tbBossLeaderInfo.tbNpcInfo = tbNpcInfo;
    pNpc.tbBossLeaderInfo.tbTouchImitityPlayer = {};
    pNpc.tbBossLeaderInfo.tbTouchNpc          = {};
    pNpc.tbBossLeaderInfo.tbSinglePlayerAward = {};

    local tbCallEvent = BossLeader:GetCallEventInfo(tbNpcInfo.CallEventID, "CallNpcHP");
    if tbCallEvent then
        pNpc.tbBossLeaderInfo.nRegHpNotifyId = Npc:RegisterNpcHpChange(pNpc, function(nOldHp, nNewHp, nMaxHp)
            self:OnNpcHpChange(nOldHp, nNewHp, nMaxHp)
        end)
    end

    local tbMapNpc = self:GetCreateNpcByMap(szType, nMapID);
    tbMapNpc[pNpc.nId] = tbNpcInfo;
    local tbOpenTrapData = BossLeader:GetOpenTrapByMap(szType, nMapID);
    if not Lib:IsEmptyStr(tbNpcInfo.OpenTrap) then
        tbOpenTrapData[tbNpcInfo.OpenTrap] = {nNpcID = pNpc.nId, tbNpcInfo = tbNpcInfo};
    end

    Log("BossLeader CreateNpc", szType, tbNpcInfo.NpcID, tbNpcInfo.NpcLevel, nMapID, tbNpcInfo.PosX, tbNpcInfo.PosY, nCurNpcLevel);    
end

function BossLeader:OnNpcHpChange(nOldHp, nNewHp, nMaxHp)
    local tbBLInfo = him.tbBossLeaderInfo;
    if not tbBLInfo then
        return;
    end

    local tbNpcInfo = tbBLInfo.tbNpcInfo;
    if not tbNpcInfo then
        return;
    end

    local nOldPer = nOldHp / nMaxHp;
    local nNewPer = nNewHp / nMaxHp;

    local tbCallEvent = self:GetCallEventInfo(tbNpcInfo.CallEventID, "CallNpcHP");
    if not tbCallEvent then
        return;
    end

    tbBLInfo.tbCallNpcKey = tbBLInfo.tbCallNpcKey or {};
    for key, tbEvent in pairs(tbCallEvent) do
        if not Lib:IsEmptyStr(tbEvent.Param1) and not Lib:IsEmptyStr(tbEvent.Param2) then
            local nCalllNpcID = tonumber(tbEvent.Param1);
            local nHPPersent = tonumber(tbEvent.Param2) / 100;

            tbBLInfo.tbCallNpcKey[nCalllNpcID] = tbBLInfo.tbCallNpcKey[nCalllNpcID] or {};
            if nNewPer < nHPPersent and nHPPersent <= nOldPer and not tbBLInfo.tbCallNpcKey[nCalllNpcID][key] then
                local nMapId, nX, nY = him.GetWorldPos();
                local nLevel = him.nLevel;
                local pNpc = KNpc.Add(nCalllNpcID, nLevel, -1, nMapId, nX, nY, 0);
                if pNpc then
                    pNpc.nBossLeaderMaster = him.nId;
                    tbBLInfo.tbCallNpcKey[nCalllNpcID][key] = pNpc.nId;
                    Log("BossLeader OnNpcHpChange", him.nId, nCalllNpcID, nNewPer);
                end
            end
        end
    end
end

function BossLeader:CombineBossLeaderKinJiFen()
    local tbOldBaseData = CombineServer:GetOldScriptData("CrossBossLeaderKin")
    if not tbOldBaseData then
        return
    end

    if not tbOldBaseData.nTime then
        return;
    end

    local tbCurData = self:GetCrossAllKinSaveData();
    if tbOldBaseData.tbKin then
        for k, v in pairs(tbOldBaseData.tbKin) do
            tbCurData.tbKin[k] = v;
        end
    end
    
    if tbOldBaseData.tbCan then
        for k, v in pairs(tbOldBaseData.tbCan) do
             tbCurData.tbCan[k] = v;
        end
    end
        
    ScriptData:AddModifyFlag("CrossBossLeaderKin");
    Log("BossLeader CombineBossLeaderKinJiFen");
end

function BossLeader:GetCreateNpcByMap(szType, nMapID)
    local tbCreateNpcData = self:GetCreateNpcData(szType);
    tbCreateNpcData[nMapID] = tbCreateNpcData[nMapID] or {};
    return tbCreateNpcData[nMapID];        
end

function BossLeader:GetOpenTrapByMap(szType, nMapID)
    local tbTypeData = self:GetTypeData(szType);
    tbTypeData.tbOpenTrapData[nMapID] = tbTypeData.tbOpenTrapData[nMapID] or {};
    return tbTypeData.tbOpenTrapData[nMapID];        
end     

function BossLeader:RemoveNpc(szType, nNpcID, nMapID)
    local tbMapNpc = self:GetCreateNpcByMap(szType, nMapID);
    tbMapNpc[nNpcID] = nil;

    BossLeader:ResetUpdateDataTime(szType);    
end

function BossLeader:GetMapNpcCount(szType, nMapID)
    local tbMapNpc = self:GetCreateNpcByMap(szType, nMapID);
    local nCount = Lib:CountTB(tbMapNpc);
    return nCount;    
end

function BossLeader:RemoveCreateNpc(szType)
    local tbCreateNpcData = self:GetCreateNpcData(szType);
    for _, tbMapNpc in pairs(tbCreateNpcData) do
        for nNpcID, _ in pairs(tbMapNpc) do
            local pNpc = KNpc.GetById(nNpcID);
            if pNpc then
                pNpc.Delete();
            else
                Log("[ERROR] BossLeader RemoveCreateNpc", nNpcID);    
            end
        end    
    end
    
    local tbTypeData = self:GetTypeData(szType);
    tbTypeData.tbAllCreateNpc = {};
    tbTypeData.tbPrepareCreateNpc = {};   
end

function BossLeader:PreStartActivity(szType)
    local szMsg = BossLeader.tbWorldPreNotic[szType];
    if not Lib:IsEmptyStr(szMsg) and not MODULE_ZONESERVER then
        KPlayer.SendWorldNotify(1, 999, szMsg, 1, 1);
    end
    
    self:CreateNpcMap(szType);

    local tbTypeData = self:GetTypeData(szType);
    tbTypeData.bStartEnter = true;
    tbTypeData.tbNpcKinDmgRank = {};
    tbTypeData.tbOpenTrapData = {};

    if szType == "Boss" then
        Calendar:OnActivityBegin("FieldBoss");
    end  
    Log("BossLeader PreStartActivity", szType);
end

function BossLeader:EndActivityEnter(szType)
    local tbTypeData = self:GetTypeData(szType);
    tbTypeData.bStartEnter = false;

    Log("BossLeader EndActivityEnter", szType);
end

function BossLeader:CheckEnterFuben(pPlayer, szType, nMapTID)
    local tbTypeData = self:GetTypeData(szType);
    if not tbTypeData.bStartEnter and not self:IsOpenCrossBoss() then
        return false, "不能進入地圖";
    end

    local szShowInfo = "";
    local nMapId = nil;
    if self:HaveCrossBossServer(pPlayer) then
        nMapId = self.tbCrossBossMapInfo[nMapTID];
        if not nMapId then
            szShowInfo = "尚未開啟!";
            if self.tbCreateNpcMap[nMapTID] then
                szShowInfo = "不能進入普通地圖";
            end
                
            return false, szShowInfo;
        end
    else
        local tbMapInfo = self.tbCreateNpcMap[nMapTID];
        if not tbMapInfo then
            local szShowInfo = "尚未開啟!";
            if self.tbCrossBossMapInfo[nMapTID] then
                szShowInfo = "沒有資格進入跨服地圖";
            end

            return false, szShowInfo;
        end

        nMapId = tbMapInfo.nMapId;
    end    

    if not Env:CheckSystemSwitch(pPlayer, Env.SW_SwitchMap) then
        return false, "目前狀態不允許切換地圖"
    end

    local nMapLevel = Map:GetEnterLevel(nMapTID);
    if pPlayer.nLevel < nMapLevel then
        return false, string.format("達到%d級才可進入該地圖", nMapLevel);
    end

    if not pPlayer.CanTranOpt() then
        return false, "當前所在地圖不可進行傳送";
    end

    if not Fuben.tbSafeMap[pPlayer.nMapTemplateId] and Map:GetClassDesc(pPlayer.nMapTemplateId) ~= "fight" and not self:IsBossLeaderMap(pPlayer.nMapTemplateId) then
        return false, "所在地圖不允許進入！";
    end

    local bRet = Map:IsForbidTransEnter(pPlayer.nMapTemplateId);
    if bRet then
        return false, "目標地圖無法傳送!";
    end  

    return true, "", nMapId;
end

function BossLeader:ApplyEnterFuben(pPlayer, szType, nMapTID)
    local bRet, szMsg, nMapID = self:CheckEnterFuben(pPlayer, szType, nMapTID);
    if not bRet then
        pPlayer.CenterMsg(szMsg);
        return true;
    end

    if pPlayer.nFightMode == 1 then -- 野外传送读条
        GeneralProcess:StartProcess(pPlayer, 5 * Env.GAME_FPS, "傳送中...", self.SwitchMapDirectly, self, nMapID, nMapTID);
    else
        self:SwitchMapDirectly(nMapID, nMapTID);
    end

    return true;
end

function BossLeader:SwitchMapDirectly(nMapID, nMapTID)
    local nPosX, nPosY = Map:GetDefaultPos(nMapTID);
    if self:HaveCrossBossServer(me) then
        self:SendCrossPlayerInfo(me);
        me.SwitchZoneMap(nMapID, nPosX, nPosY);
    else
        me.SwitchMap(nMapID, nPosX, nPosY);
    end

    local nMapType = Map:GetMapType(me.nMapTemplateId);
    if nMapType == Map.emMap_Public or nMapType == Map.emMap_Public_Fuben then
        me.SetEntryPoint(); 
    end     
end

function BossLeader:CreateNpcMap(szType)
    local tbMapNpcGroup = self:GetTimeFrameNpcGroup(szType);
    for nMapTID, tbInfo in pairs(tbMapNpcGroup) do
        local nMapType = Map:GetMapType(nMapTID);
        if nMapType == Map.emMap_Fuben and not self.tbCreateNpcMap[nMapTID] then
            local nMapId = CreateMap(nMapTID);
            local tbMapInfo = {};
            tbMapInfo.nMapId = nMapId;
            tbMapInfo.szTimeFrame = "-";
            if tbInfo[1] then
                tbMapInfo.szTimeFrame = tbInfo[1].szTimeFrame;
            end
            self.tbCreateNpcMap[nMapTID] = tbMapInfo;
        end    
    end    
end

function BossLeader:ClearForbidPlayerPK(szType)
    local tbMapNpcGroup = self:GetTimeFrameNpcGroup(szType);
    for nMapTID, _ in pairs(tbMapNpcGroup) do
        local bFinish = IsLoadFinishMap(nMapTID);
        if bFinish then
            local tbPlayer = KPlayer.GetMapPlayer(nMapTID) or {};
            for _, pPlayer in pairs(tbPlayer) do
                pPlayer.nForbidPkMode = nil;
            end    
        end    
    end  
end

function BossLeader:UpdateAlllPlayerDmgTrap(szType)
    local tbMapNpcGroup = self:GetTimeFrameNpcGroup(szType);
    for nMapTID, _ in pairs(tbMapNpcGroup) do
        local tbMapInfo = self.tbCreateNpcMap[nMapTID];
        if tbMapInfo then
            local nMapId = tbMapInfo.nMapId;
            local bFinish = IsLoadFinishMap(nMapId);
            if bFinish then
                local tbPlayer = KPlayer.GetMapPlayer(nMapId) or {};
                for _, pPlayer in pairs(tbPlayer) do
                    self:UpdatePlayerTrap(pPlayer);
                end    
            end 
        end       
    end
end

function BossLeader:GetMapIDByTemplate(nMapTemplateId)
    local tbMapInfo = self.tbCreateNpcMap[nMapTemplateId];
    if not tbMapInfo then
        return nMapTemplateId;
    end

    return tbMapInfo.nMapId;    
end

function BossLeader:GetMapTemplateByID(nMapID)
    local nMapTemId = GetMapInfoById(nMapID);
    if not nMapTemId then
        return nMapID;
    end

    return nMapTemId;    
end

function BossLeader:OnDestroyMap(nMapTemplateId, nMapId)
    self.tbCreateNpcMap[nMapTemplateId] = nil;
end

function BossLeader:StartActivity(szType, nExtCount, bKinJiFen)
    local tbTypeData = self:GetTypeData(szType);
    if tbTypeData.bStart then
        Log("BossLeader StartActivity Have Start", szType, nExtCount);
        return;
    end

    if tbTypeData.nStartTimer then
        Timer:Close(tbTypeData.nStartTimer);
        tbTypeData.nStartTimer = nil;
    end

    if tbTypeData.nCloseTimer then
        Timer:Close(tbTypeData.nCloseTimer);
        tbTypeData.nCloseTimer = nil;
    end   
 
    self:RemoveCreateNpc(szType);
    self:ClearTypeInfo(szType);
    tbTypeData.bStart = true;   
    tbTypeData.nExtCount = nExtCount;
    tbTypeData.tbKinAuctionItem = {};
    tbTypeData.nStartTime = GetTime();
    tbTypeData.tbNpcKinDmgRank = {};
    tbTypeData.tbOpenTrapData = {};
    tbTypeData.bKinJiFen = bKinJiFen;
    self:CreateAllNpcGroup(szType);

    local szMsg = BossLeader.tbStartWorldNotice[szType];
    if not Lib:IsEmptyStr(szMsg) and not MODULE_ZONESERVER then
        KPlayer.SendWorldNotify(1, 999, szMsg, 1, 1);
    end
        
    if szType == "Boss" then
        PKValue:SetLostExpPercent(0.5);
        BossLeader:UpdateAlllPlayerDmgTrap(szType);
    end

    if szType == "Leader" then
        Calendar:OnActivityBegin("FieldLeader");
    end    

    BossLeader:ResetUpdateDataTime(szType);    
    TeacherStudent:ClearBossLeaderData()
    Log("BossLeader StartActivity", szType, nExtCount);
end

function BossLeader:TimerStartActivity(szType, tbTimerInfo)
    if not tbTimerInfo or not tbTimerInfo[1] or not tbTimerInfo[2] or tbTimerInfo[1] <= 0 or tbTimerInfo[2] <= 0 then
        Log("ERROR BossLeader TimerStartActivity Is nil", szType);
        return;
    end

    local tbTypeData = self:GetTypeData(szType);
    if tbTypeData.bStart then
        Log("ERROR BossLeader TimerStartActivity Have Start", szType);
        return;
    end    

    if tbTypeData.nStartTimer then
        Timer:Close(tbTypeData.nStartTimer);
        tbTypeData.nStartTimer = nil;
    end    

    local nRandomStartFrame = tbTimerInfo[1] * Env.GAME_FPS;
    local nEndFrame         = tbTimerInfo[2] * Env.GAME_FPS;
    local nExtCount         = tbTimerInfo[3] or 0;
    local nStartTime = MathRandom(nRandomStartFrame);
    tbTypeData.nStartTimer = Timer:Register(nStartTime, self.OnTimerStart, self, szType, nEndFrame, nExtCount);
    Log("BossLeader TimerStartActivity", szType, nRandomStartFrame, nEndFrame, nExtCount);
end

function BossLeader:OnTimerStart(szType, nEndFrame, nExtCount)
    local tbTypeData = self:GetTypeData(szType);
    tbTypeData.nStartTimer = nil;
    if tbTypeData.bStart then
        Log("ERROR BossLeader OnTimerStart Have Start", szType);
        return;
    end

    self:StartActivity(szType, nExtCount);
    tbTypeData.nCloseTimer = Timer:Register(nEndFrame, self.OnEnTimer, self, szType);    
end

function BossLeader:OnEnTimer(szType)
    local tbTypeData = self:GetTypeData(szType);
    tbTypeData.nCloseTimer = nil;
    self:CloseActivity(szType);
end

function BossLeader:ClearTypeInfo(szType)
    local tbTypeData = self:GetTypeData(szType);
    tbTypeData.nExtCount = 0;
    tbTypeData.tbAllCreateNpc = {};
    tbTypeData.tbPrepareCreateNpc = {};
    tbTypeData.tbAllKinJoinCount = {};
    tbTypeData.tbAllKinTotalValue = {};
    tbTypeData.tbKinAuctionItem = {};
    tbTypeData.bAllockAward = false;
    tbTypeData.bKinJiFen    = false;
end

function BossLeader:GetCurNpcCount(szType)
    local tbCreateNpcData = self:GetCreateNpcData(szType);
    if not tbCreateNpcData then
        return 0;
    end

    local nCount = 0;
    for _, tbMapNpc in pairs(tbCreateNpcData) do
        for nNpcID, _ in pairs(tbMapNpc) do
            nCount = nCount + 1;
        end    
    end    

    return nCount;    
end

function BossLeader:CloseActivity(szType)
    local tbTypeData = self:GetTypeData(szType);
    if not tbTypeData.bStart then
        Log("BossLeader CloseActivity Not Start", szType);
        return;
    end
    
    if szType == "Boss" then
        PKValue:SetLostExpPercent(1);

        if not MODULE_ZONESERVER then
            Calendar:OnActivityEnd("FieldBoss");
        end
    end

    if szType == "Leader" then
        BossLeader:ClearForbidPlayerPK(szType);
        Calendar:OnActivityEnd("FieldLeader");
    end    

    if tbTypeData.nCloseTimer then
        Timer:Close(tbTypeData.nCloseTimer);
        tbTypeData.nCloseTimer = nil;
    end

    if tbTypeData.nStartTimer then
        Timer:Close(tbTypeData.nStartTimer);
        tbTypeData.nStartTimer = nil;
    end    

    self:RemoveCreateNpc(szType);
    self:AllocBossLeaderAward(szType);

    tbTypeData.nExtCount = 0;
    tbTypeData.tbAllCreateNpc = {};
    tbTypeData.tbPrepareCreateNpc = {};
    tbTypeData.tbAllKinJoinCount = {};
    tbTypeData.tbAllKinTotalValue = {};
    tbTypeData.bAllockAward = true;
    tbTypeData.bStart = false;
    tbTypeData.bKinJiFen = false;
    tbTypeData.tbKinAuctionItem = {};

    local szMsg = BossLeader.tbEndWorldNotice[szType];
    if not Lib:IsEmptyStr(szMsg) and not MODULE_ZONESERVER then
        KPlayer.SendWorldNotify(1, 999, szMsg, 1, 1);
    end

    BossLeader:ResetUpdateDataTime(szType);
    TeacherStudent:ClearBossLeaderData()

    if szType == "Boss" then
        BossLeader:CloseActivityCrossBossZ();
    end
    Log("BossLeader CloseActivity", szType);
end

function BossLeader:GetPlayerDmgRank(nAwardID, nRank)
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

function BossLeader:GetTypeTodayData(szType)
    local tbTodayType = self.tbAllTypeToday[szType];
    if not tbTodayType then
        tbTodayType = {};
        tbTodayType.nCurToday = 0;
        tbTodayType.nUpdateDataTime = 0;
        self.tbAllTypeToday[szType] = tbTodayType;
    end

    local nDay = Lib:GetLocalDay();
    if tbTodayType.nCurToday ~= nDay then
        tbTodayType.nCurToday = nDay;
        tbTodayType.nUpdateDataTime = 0;
        tbTodayType.tbTimeMapDeath = {};
    end

    return tbTodayType;     
end

function BossLeader:GetTypeData(szType)
    if not self.tbAllTypeData[szType] then
        self.tbAllTypeData[szType] = 
        {
            bAllockAward = false;
            nExtCount = 0;
            tbAllCreateNpc = {};
            tbPrepareCreateNpc = {};
            tbAllKinJoinCount = {};
            tbAllKinTotalValue = {};
            tbKinAuctionItem = {};
            bStart = false;
            nStartTime = 0;
            bStartEnter = false;
            bKinJiFen   = false;
            tbNpcKinDmgRank = {}; 
            tbOpenTrapData = {};
        };
    end

    return self.tbAllTypeData[szType];    
end

function BossLeader:GetCreateNpcData(szType)
    local tbTypeData = self:GetTypeData(szType);
    return tbTypeData.tbAllCreateNpc;
end

function BossLeader:GetPrepareNpcData(szType)
    local tbTypeData = self:GetTypeData(szType);
    return tbTypeData.tbPrepareCreateNpc;
end

function BossLeader:GetKinJoinCount(szType)
    local tbTypeData = self:GetTypeData(szType);
    return tbTypeData.tbAllKinJoinCount;
end

function BossLeader:GetKinTotalValue(szType)
    local tbTypeData = self:GetTypeData(szType);
    return tbTypeData.tbAllKinTotalValue;
end

function BossLeader:GetKinTotalValueByID(szType, nKinId)
    if self.bCalcCross then
        return self:GetCrossKinTotalValue(nKinId);
    end

    local tbAllKinValue = self:GetKinTotalValue(szType);
    tbAllKinValue[nKinId] = tbAllKinValue[nKinId] or 0;
    return tbAllKinValue[nKinId];
end

function BossLeader:AddKinTotalValueByID(szType, nKinId, nValue)
    if self.bCalcCross then
        return self:AddCrossKinTotalValueByID(nKinId, nValue);
    end

    local tbAllKinValue = self:GetKinTotalValue(szType);
    local nCurValue = tbAllKinValue[nKinId] or 0;
    tbAllKinValue[nKinId] = nCurValue + nValue;
end

function BossLeader:HaveNpc(szType, nNpcID, nMapID)
    local tbMapNpc = self:GetCreateNpcByMap(szType, nMapID);
    if not tbMapNpc[nNpcID] then
        return false;
    end

    return true;    
end

function BossLeader:AddKinJoinCount(szType, pPlayer)
    local tbKinJoinCount = self:GetKinJoinCount(szType);
    tbKinJoinCount[pPlayer.dwKinId] = tbKinJoinCount[pPlayer.dwKinId] or {};
    local tbKinPlayer = tbKinJoinCount[pPlayer.dwKinId];
    if tbKinPlayer[pPlayer.dwID] then
        return;
    end

    tbKinPlayer[pPlayer.dwID] = true; 
    local nPrestige = BossLeader.tbJoinPrestige[szType];
    Lib:CallZ2SOrLocalScript(pPlayer.nZoneIndex, "BossLeader:AddKinPrestige", pPlayer.dwKinId, nPrestige, szType);   

    if szType == "Boss" then
        Dialog:SendBlackBoardMsg(pPlayer, "成功參與挑戰本次名將，可享受幫派分紅");
        pPlayer.Msg("成功參與挑戰本次名將，可享受幫派分紅");
    end    
end

function BossLeader:AddKinPrestige(nKinId, nPrestige, szType)
    if not nPrestige or nPrestige <= 0 or nKinId <= 0 then
        return;
    end

    local tbKinData = Kin:GetKinById(nKinId);
    if not tbKinData then
        return;
    end

    tbKinData:AddPrestige(nPrestige, szType == "Leader" and Env.LogWay_FieldLeader or Env.LogWay_FieldBoss);    
end

function BossLeader:GetKinAuctionInfo(szType, nKindID)
    if self.bCalcCross then
        return self:GetCrossKinAuctionInfo(nKindID);
    end

    local tbTypeData  = self:GetTypeData(szType);
    tbTypeData.tbKinAuctionItem[nKindID] = tbTypeData.tbKinAuctionItem[nKindID] or {};
    return tbTypeData.tbKinAuctionItem[nKindID];
end

function BossLeader:AddKinAuctionItem(szType, nKindID, nItemTID, nCount)
    if self.bCalcCross then
        return self:AddCrossKinAuctionItem(nKindID, nItemTID, nCount)
    end

    if nCount <= 0 then
        return;
    end

    local tbKinAuction = self:GetKinAuctionInfo(szType, nKindID);
    tbKinAuction[nItemTID] = tbKinAuction[nItemTID] or 0;
    tbKinAuction[nItemTID] = tbKinAuction[nItemTID] + nCount;
    Log("BossLeader AddKinAuctionItem", szType, nKindID, nItemTID, nCount);    
end

function BossLeader:SendKinNotify(nKindID, bWorldNotice, bKinNotice, szNpcName, szInfoMsg)
    local szExtMsg = "";
    if self.bCalcCross then
        szExtMsg = "【跨服】"
    end

    if bKinNotice then
        local szShowMsg = string.format("恭喜本幫派挑戰%s, 獲得了%s", szNpcName or "", szInfoMsg);
        ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szExtMsg..szShowMsg, nKindID);
    end
    
    if bWorldNotice then
        local szKinName = self:GetKinNameById(nKindID);
        local szShowMsg = string.format("恭喜%s幫派挑戰%s, 獲得了%s", szKinName or "-", szNpcName or "", szInfoMsg);
        KPlayer.SendWorldNotify(1, 999, szExtMsg..szShowMsg, 1, 1);
    end 
end

function BossLeader:GetKinAuctionItem(szType, nKindID, nItemTID)
    local tbKinAuction = self:GetKinAuctionInfo(szType, nKindID);
    return tbKinAuction[nItemTID] or 0;
end

function BossLeader:GetKinDmgRankValue(tbTimeDmgRankValue, szType, nRank, bIsFalse, nCalcValueType)
    local szCurType = szType;
    if bIsFalse then
        szCurType = "False"..szType;
    end

    local tbCalcValue = tbTimeDmgRankValue[-1];
    if nCalcValueType and tbTimeDmgRankValue[nCalcValueType] then
        tbCalcValue = tbTimeDmgRankValue[nCalcValueType];
    end    

    local tbTypeRankValue = tbCalcValue[szCurType];
    if not tbTypeRankValue then
        return;
    end

    return tbTypeRankValue[nRank];   
end

function BossLeader:SendLastDmgPlayerAward(szType, nPlayerID, nLastDmgID)
    local tbLastAwardInfo = self:GetLastPlayerAward(nLastDmgID);
    if not tbLastAwardInfo then
        return;
    end

    local tbAllAward = {};
    for _, tbAward in pairs(tbLastAwardInfo.tbAllAward) do
        local tbAddAward = {};
        if tbAward[1] == "AddTimeTitle" then
            local nTime = GetTime() + tbAward[3];
            tbAddAward = {"AddTimeTitle", tbAward[2], nTime};
        else
            tbAddAward = tbAward;
        end

        table.insert(tbAllAward, tbAddAward);
    end

    self:SendMailAward(szType, nPlayerID, tbAllAward);
end

function BossLeader:CalcKinDmgRankAward(szType, tbKinDmg, pBossNpc, nMapID, nNpcTotalDamage)
    if szType ~= "Boss" or not pBossNpc then
        return;
    end

    local tbBLInfo = pBossNpc.tbBossLeaderInfo;
    local tbNpcInfo = tbBLInfo.tbNpcInfo;
    local tbTypeData = self:GetTypeData(szType);
    local nLastDmgPlayerID = pBossNpc.GetLastDmgMePlayerID();
    local nLastDmgKinID = 0;
    if nLastDmgPlayerID > 0 then
        local tbRoleInfo = KPlayer.GetRoleStayInfo(nLastDmgPlayerID);
        nLastDmgKinID = tbRoleInfo.dwKinId;

        if tbNpcInfo.LastAwardID > 0 then
            local nConnect = BossLeader:GetPlayerConnectIndex(nLastDmgPlayerID);
            Lib:CallZ2SOrLocalScript(nConnect, "BossLeader:SendLastDmgPlayerAward", szType, nLastDmgPlayerID, tbNpcInfo.LastAwardID);   
        end
        Log("CalcKinDmgRankAward LastDmgKinID", nLastDmgKinID or 0, nLastDmgPlayerID, pBossNpc.nTemplateId, nNpcTotalDamage);
    end

    local tbSortKinDmg = {};
    for nKinId, nTotalDmg in pairs(tbKinDmg) do
        local nHPPercent = nTotalDmg * 100 / nNpcTotalDamage;
        if tbBLInfo.nFirstTouchKin and tbBLInfo.nFirstTouchKin == nKinId then
            nHPPercent = nHPPercent + BossLeader.nFirstLastDmgMJHPPercent;
        end

        if nLastDmgKinID == nKinId then
            nHPPercent = nHPPercent + BossLeader.nFirstLastDmgMJHPPercent;
        end

        nHPPercent = nHPPercent * BossLeader.nHPPercentParam;    
        table.insert(tbSortKinDmg, {nKinId = nKinId, nHPPercent = nHPPercent});
    end    

    local function fnDamageKinCmp(a, b)
        return a.nHPPercent > b.nHPPercent;
    end
    
    local szTrapName = tbNpcInfo.OpenTrap;
    if Lib:IsEmptyStr(szTrapName) then
        szTrapName = "TrapName";
    end

    local tbMapKinDmgRank = self:GetMapKinDmgRank(szType, nMapID);
    tbMapKinDmgRank.tbEndDmdKinRank[szTrapName] = tbMapKinDmgRank.tbEndDmdKinRank[szTrapName] or {};
    local tbDmgKinRank = tbMapKinDmgRank.tbEndDmdKinRank[szTrapName];
    tbMapKinDmgRank.tbTrapNpc[szTrapName] = pBossNpc.nTemplateId;

    local tbNpcExtInfo = {};
    tbNpcExtInfo.nRowIndex = tbNpcInfo.nRowIndex;
    tbNpcExtInfo.nNpcID = tbNpcInfo.NpcID;
    tbNpcExtInfo.nGroupID = tbNpcInfo.GroupID;

    table.sort(tbSortKinDmg, fnDamageKinCmp);
    for nRank, tbKinInfo in ipairs(tbSortKinDmg) do
        local nJoinCount = self:GetKinTotalJoinCount(szType, tbKinInfo.nKinId);
        if not MODULE_ZONESERVER then
            local bRet = self:CalcKinDmgTotalValue(szType, tbKinInfo, tbNpcExtInfo, nJoinCount, nRank);
            if not bRet then
                break;
            end

            if tbTypeData.bKinJiFen then
                self:AddCrossKinJiFen(tbKinInfo.nKinId, tbNpcInfo.NpcID, nRank);
            end
        else
            local nConnectIdx = self:GetKinConnectIndex(tbKinInfo.nKinId);
            CallZoneClientScript(nConnectIdx, "BossLeader:CrossCalcKinDmgTotalValue", szType, tbKinInfo, tbNpcExtInfo, nJoinCount, nRank);
        end

        if nRank <= self.nShowMaxRank then
            local nCurHPPercent = math.max(BossLeader.nMinHPPercent, tbKinInfo.nHPPercent);
            nCurHPPercent = math.floor(nCurHPPercent);
            local szKinName = self:GetKinNameById(tbKinInfo.nKinId);
            tbDmgKinRank[nRank] = {szKinName or "-", nCurHPPercent};
        end
            
        self:CalcKinAchievement(szType, tbKinInfo.nKinId, tbBLInfo, nRank);   
    end    
end

function BossLeader:GetKinNameById(nKinId)
    local tbKin = Kin:GetKinById(nKinId);
    if tbKin then
        return tbKin.szName;
    end

    if MODULE_ZONESERVER then
        local tbKinInfo = self:GetCrossBossKinInfo(nKinId);
        if tbKinInfo and tbKinInfo.szName then
            local szName = string.format("［%s服］%s", tbKinInfo.nServerIdx or 0, tbKinInfo.szName);
            return szName;
        end 
    end
end

function BossLeader:CalcKinDmgTotalValue(szType, tbKinInfo, tbNpcExtInfo, nJoinCount, nRank) 
    local tbNpcInfo = self:GetGroupNpcInfoByIndex(tbNpcExtInfo.nRowIndex);
    if not tbNpcInfo then
        Log("Error BossLeader CalcKinDmgTotalValue", tbNpcExtInfo.nRowIndex, tbNpcExtInfo.nNpcID, tbNpcExtInfo.nGroupID);
        return false;
    end

    if tbNpcInfo.NpcID ~= tbNpcExtInfo.nNpcID or tbNpcInfo.GroupID ~= tbNpcExtInfo.nGroupID then
        Log("Error BossLeader CalcKinDmgTotalValue Ext", tbNpcExtInfo.nRowIndex, tbNpcExtInfo.nNpcID, tbNpcExtInfo.nGroupID, tbNpcInfo.NpcID, tbNpcInfo.GroupID);
        return false;
    end

    local tbTimeDmgRankValue = self:GetKinTimeDmgRankValue();
    local tbTimeFrameInfo = self:GetTimeFrameSetting();
    local tbTypeData = self:GetTypeData(szType);
    local nRankValue = self:GetKinDmgRankValue(tbTimeDmgRankValue, szType, nRank, tbNpcInfo.IsFalse == 1, tbNpcInfo.CalcValueType);
    if not nRankValue then
        return false;
    end

    local nCurHPPercent = math.max(BossLeader.nMinHPPercent, tbKinInfo.nHPPercent);
    nCurHPPercent = math.floor(nCurHPPercent);
    nRankValue = nRankValue * nCurHPPercent / 100;   

    local nValueParam = tbNpcInfo.ValueParam;
    if nValueParam <= 0 then
        nValueParam = 1000;
    end

    local nPlayerBaseValue = self:GetPlayerBaseValue();
    local fValue =  nValueParam / 1000;
    local nCuRankValue = nRankValue * fValue;
    local nMaxTotalValue = nJoinCount * nPlayerBaseValue;
    local nKinTotalValue = self:GetKinTotalValueByID(szType, tbKinInfo.nKinId);
    local nTotalValue = nKinTotalValue + nCuRankValue;
    if nTotalValue >= nMaxTotalValue then
        nCuRankValue = nMaxTotalValue - nKinTotalValue;
    end    

    if nCuRankValue > 0 then
        self:AddKinTotalValueByID(szType, tbKinInfo.nKinId, nCuRankValue)

        self:CalcKinDmgSoul(szType, tbKinInfo.nKinId, nCuRankValue, tbNpcInfo, tbTimeFrameInfo); --同伴
        self:CalcKinDmgMJSoulStone(szType, tbKinInfo.nKinId, nCuRankValue, tbNpcInfo, tbTimeFrameInfo);
        self:CalcKinDmgMingJiangHonor(szType, tbKinInfo.nKinId, nCuRankValue, tbNpcInfo, tbTimeFrameInfo);
        self:CalcKinDmgExtRamdomItem(szType, tbKinInfo.nKinId, nCuRankValue, tbNpcInfo, tbTimeFrameInfo);
        --self:CalKinDmgItem(szType, tbKinInfo.nKinId, nCuRankValue, tbNpcInfo)
        self:CalcKinDmgKinValueAward(szType, tbKinInfo.nKinId, nCuRankValue, tbNpcInfo, tbTimeFrameInfo);
    end
        
    Log("BossLeader CalcKinDmgRankAward", szType, tbKinInfo.nKinId, nCuRankValue, nCurHPPercent, nMaxTotalValue);
    return true;
end

function BossLeader:CalcKinAchievement(szType, nKind, tbBLInfo, nRank)
    if nRank > BossLeader.nAchievementKinRank or not tbBLInfo.tbTouchNpc then
        return;
    end

    for nPlayerID, _ in pairs(tbBLInfo.tbTouchNpc) do
        local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
        if pPlayer and pPlayer.dwKinId == nKind then
            BossLeader:AddAchievement(pPlayer, szType, BossLeader.tbKillKinAchievement);
        end    
    end    
end

function BossLeader:CalcKinDmgKinValueAward(szType, nKinId, nRankValue, tbNpcInfo, tbTimeFrameInfo)
    if not tbNpcInfo.ValueGroupID then
        return;
    end

    if tbNpcInfo.ValueGroupID <= 0 then
        return;
    end    

    local tbValueAward = self:GetKinValueAward(tbNpcInfo.ValueGroupID);
    if not tbValueAward then
        return;
    end

    for _, tbItemInfo in pairs(tbValueAward) do
        local nCurValue = nRankValue * tbItemInfo.Param;
        if nCurValue > 0 and tbItemInfo.ItemID > 0 then
            local nItemValue = KItem.GetBaseValue(tbItemInfo.ItemID);
            local szGuaranteeKey = string.format("BossLeader_%s_%s", szType, tbItemInfo.ItemID);
            local nItemCount = 0;
            if tbItemInfo.NotSave == 1 then
                nItemCount = RandomAward:GetKinAwardCount(nKinId, nCurValue, nItemValue, szGuaranteeKey);
            else
                nItemCount = RandomAward:GetKinGuaranteeAwardCount(nKinId, nCurValue, nItemValue, szGuaranteeKey);
            end

            if nItemCount > 0 then
                self:AddKinAuctionItem(szType, nKinId, tbItemInfo.ItemID, nItemCount);

                local szNpcName   = KNpc.GetNameByTemplateId(tbNpcInfo.NpcID);
                local szItemName = KItem.GetItemShowInfo(tbItemInfo.ItemID);
                local szMsg = string.format("%s個%s", nItemCount, szItemName);
                local szTrueNpc = "(真身)";
                if tbNpcInfo and tbNpcInfo.IsFalse == 1 then
                    szTrueNpc = "(分身)";
                end

                szNpcName = szNpcName..szTrueNpc;  
                self:SendKinNotify(nKinId, true, true, szNpcName, szMsg);
            end

            Log("CalcKinDmgKinValueAward ", szType, nKinId, tbItemInfo.ItemID, nItemCount, nCurValue);    
        end       
    end    
end    

function BossLeader:CalcKinDmgExtRamdomItem(szType, nKinId, nRankValue, tbNpcInfo, tbTimeFrameInfo)
    if not Lib:HaveCountTB(tbNpcInfo.tbExtRandomItemID) then
        return;
    end

    for nIndex, nItemID in pairs(tbNpcInfo.tbExtRandomItemID) do

        local nRandomValue = tbTimeFrameInfo.tbNExtRandomParam[nIndex] or 0;
        if tbNpcInfo.CalcValueType and tbTimeFrameInfo.tbCalcValue[tbNpcInfo.CalcValueType] then
            nRandomValue = tbTimeFrameInfo.tbCalcValue[tbNpcInfo.CalcValueType].tbExtRandomParam[nIndex] or 0;
        end    

        if nRandomValue > 0 and nItemID > 0 then
            local nCurValue = nRankValue * nRandomValue;
            local nExtItemValue = KItem.GetBaseValue(nItemID);
            local fExtItemCount = nCurValue / nExtItemValue;
            local nExtItemCount = self:RateRandomCount(fExtItemCount);
            self:AddKinAuctionItem(szType, nKinId, nItemID, nExtItemCount);

            if nExtItemCount > 0 then
                local szNpcName   = KNpc.GetNameByTemplateId(tbNpcInfo.NpcID);
                local szItemName = KItem.GetItemShowInfo(nItemID);
                local szMsg = string.format("%s個%s", nExtItemCount, szItemName);
                local szTrueNpc = "(真身)";
                if tbNpcInfo and tbNpcInfo.IsFalse == 1 then
                    szTrueNpc = "(分身)";
                end

                szNpcName = szNpcName..szTrueNpc;  
                self:SendKinNotify(nKinId, true, true, szNpcName, szMsg);
            end

            Log("CalcKinDmgExtRamdomItem ", szType, nKinId, nItemID, nExtItemCount, fExtItemCount, nRandomValue);
        end      
    end
end

function BossLeader:CalcKinDmgMingJiangHonor(szType, nKinId, nRankValue, tbNpcInfo, tbTimeFrameInfo)
    local nLingPai = BossLeader.nMJHonorID;
    if tbNpcInfo.LingPai and tbNpcInfo.LingPai > 0 then
        nLingPai = tbNpcInfo.LingPai;
    end

    local nRandomValue = tbTimeFrameInfo.RandomMJLingParam;
    if tbNpcInfo.CalcValueType and tbTimeFrameInfo.tbCalcValue[tbNpcInfo.CalcValueType] then
        nRandomValue = tbTimeFrameInfo.tbCalcValue[tbNpcInfo.CalcValueType].RandomMJLingParam;
    end

    local nBaseValue = KItem.GetBaseValue(nLingPai);
    local nCurValue = nRankValue * nRandomValue / nBaseValue;
    local nCount = self:RateRandomCount(nCurValue);
    self:AddKinAuctionItem(szType, nKinId, nLingPai, nCount);

    if nCount > 0 then
        local szNpcName   = KNpc.GetNameByTemplateId(tbNpcInfo.NpcID);
        local szItemName = KItem.GetItemShowInfo(nLingPai);
        local szMsg = string.format("%s個%s", nCount, szItemName);
        local szTrueNpc = "(真身)";
        if tbNpcInfo and tbNpcInfo.IsFalse == 1 then
            szTrueNpc = "(分身)";
        end
        szNpcName = szNpcName..szTrueNpc; 

        self:SendKinNotify(nKinId, true, true, szNpcName, szMsg);
    end
    Log("CalcKinDmgMingJiangHonor ", szType, nKinId, nCount, nCurValue, nRandomValue);
end

function BossLeader:CalcKinDmgSoul(szType, nKinId, nRankValue, tbNpcInfo, tbTimeFrameInfo)
    if tbNpcInfo.SoulStoneID <= 0 then
        return;
    end

    local nRandomValue = tbTimeFrameInfo.RandomSoulParam;
    if tbNpcInfo.CalcValueType and tbTimeFrameInfo.tbCalcValue[tbNpcInfo.CalcValueType] then
        nRandomValue = tbTimeFrameInfo.tbCalcValue[tbNpcInfo.CalcValueType].RandomSoulParam;
    end    

    local nCurValue = nRankValue * nRandomValue;
    local nStoneValue = KItem.GetBaseValue(tbNpcInfo.SoulStoneID);
    local fStoneCount = nCurValue / nStoneValue;
    local nStoneCount = self:RateRandomCount(fStoneCount);
    self:AddKinAuctionItem(szType, nKinId, tbNpcInfo.SoulStoneID, nStoneCount);

    if nStoneCount > 0 then
        local szNpcName   = KNpc.GetNameByTemplateId(tbNpcInfo.NpcID);
        local szItemName = KItem.GetItemShowInfo(tbNpcInfo.SoulStoneID);
        local szMsg = string.format("%s個%s", nStoneCount, szItemName);
        local szTrueNpc = "(真身)";
        if tbNpcInfo and tbNpcInfo.IsFalse == 1 then
            szTrueNpc = "(分身)";
        end

        szNpcName = szNpcName..szTrueNpc;  
        self:SendKinNotify(nKinId, true, true, szNpcName, szMsg);
    end

    Log("CalcKinDmgSoul ", szType, nKinId, nStoneCount, fStoneCount, nRandomValue);   
end

function BossLeader:CalcKinDmgMJSoulStone(szType, nKinId, nRankValue, tbNpcInfo, tbTimeFrameInfo)
    if tbNpcInfo.MJSoulStoneID <= 0 then
        return;
    end

    local nRandomValue = tbTimeFrameInfo.RandomMJStoneParam;
    if tbNpcInfo.CalcValueType and tbTimeFrameInfo.tbCalcValue[tbNpcInfo.CalcValueType] then
        nRandomValue = tbTimeFrameInfo.tbCalcValue[tbNpcInfo.CalcValueType].RandomMJStoneParam;
    end

    local nCurValue = nRankValue * nRandomValue;
    local nStoneValue = KItem.GetBaseValue(tbNpcInfo.MJSoulStoneID);
    local fStoneCount = nCurValue / nStoneValue;
    local nStoneCount = self:RateRandomCount(fStoneCount);
    self:AddKinAuctionItem(szType, nKinId, tbNpcInfo.MJSoulStoneID, nStoneCount);

    if nStoneCount > 0 then
        local szNpcName   = KNpc.GetNameByTemplateId(tbNpcInfo.NpcID);
        local szItemName = KItem.GetItemShowInfo(tbNpcInfo.MJSoulStoneID);
        local szMsg = string.format("%s個%s", nStoneCount, szItemName);
        local szTrueNpc = "(真身)";
        if tbNpcInfo and tbNpcInfo.IsFalse == 1 then
            szTrueNpc = "(分身)";
        end
        szNpcName = szNpcName .. szTrueNpc; 

        self:SendKinNotify(nKinId, true, true, szNpcName, szMsg);
    end

    Log("CalcKinDmgMJSoulStone ", szType, nKinId, nStoneCount, fStoneCount, nRandomValue);   
end 

function BossLeader:RandomKinItemAward(tbKinItemAward, nToalCount)
    local tbHideItemIdex = {};
    local tbItemCount = {};
    local nTotalRate = tbKinItemAward.nTotalRate;
    local nGetCount = 0;
    for nI = 1, nToalCount do
        local nCurRate = MathRandom(nTotalRate);

        for nIndex, tbInfo in pairs(tbKinItemAward.tbAllItem) do
            if not tbHideItemIdex[nIndex] then

                if tbInfo.Rate >= nCurRate then

                    local nItemCount = tbItemCount[nIndex] or 0;
                    tbItemCount[nIndex] = nItemCount + 1;

                    nGetCount = nGetCount + 1;

                    tbHideItemIdex[nIndex] = 1;
                    nTotalRate = nTotalRate - tbInfo.Rate;

                    if nTotalRate <= 0 then
                        nTotalRate = tbKinItemAward.nTotalRate;
                        tbHideItemIdex = {};
                    end

                    break;
                end

                nCurRate = nCurRate - tbInfo.Rate;   
            end    
        end
    end

    assert(nGetCount == nToalCount);
    return tbItemCount;    
end

function BossLeader:GetKinItemValue(tbKinAllItem)
    for _, tbInfo in pairs(tbKinAllItem) do
        local nItemValue = KItem.GetBaseValue(tbInfo.ItemID);

        return nItemValue;
    end

    return 0;    
end

function BossLeader:CalKinDmgItem(szType, nKinId, nRankValue, tbNpcInfo)
    if tbNpcInfo.KinItemAwardID <= 0 then
        return;
    end

    local tbKinItemAward = self:GetKinItemAward(tbNpcInfo.KinItemAwardID);
    if not tbKinItemAward then
        Log("[ERROR]BossLeader CalKinDmgItem", szType, nKinId, tbNpcInfo.KinItemAwardID);
        return;
    end    

    local nItemValue = self:GetKinItemValue(tbKinItemAward.tbAllItem);
    if nItemValue <= 0 then
        Log("[ERROR]BossLeader CalKinDmgItem Value", szType, nKinId, tbNpcInfo.KinItemAwardID, nItemValue);
        return;
    end

    local nCurValue = nRankValue * BossLeader.nItemAwardValueParam;
    local fItemCount = nCurValue / nItemValue;
    local nItemCount = self:RateRandomCount(fItemCount);
    if nItemCount <= 0 then
        Log("BossLeader CalKinDmgItem ", szType, nKinId, nItemCount, fItemCount);   
        return;
    end

    local szInfoMsg = "";
    local nWorldNotice = 0;
    local nKinNotice   = 0;
    local tbItemCount = self:RandomKinItemAward(tbKinItemAward, nItemCount);
    for nIndex, nCount in pairs(tbItemCount) do
        local tbAwardInfo = tbKinItemAward.tbAllItem[nIndex];

        self:AddKinAuctionItem(szType, nKinId, tbAwardInfo.ItemID, nCount);

        if tbAwardInfo.WorldNotice == 1 or tbAwardInfo.KinNotice == 1 then
            nWorldNotice = tbAwardInfo.WorldNotice;
            nKinNotice = tbAwardInfo.KinNotice;

            local szName = KItem.GetItemShowInfo(tbAwardInfo.ItemID);
            if szInfoMsg ~= "" then
                szInfoMsg = szInfoMsg .. ",";
            end

            szInfoMsg = szInfoMsg .. string.format("%s個%s", nCount, szName);
        end     
    end
        
    if szInfoMsg ~= "" then
        local szNpcName   = KNpc.GetNameByTemplateId(tbNpcInfo.NpcID);
        local szTrueNpc = "(真身)";
        if tbNpcInfo and tbNpcInfo.IsFalse == 1 then
            szTrueNpc = "(分身)";
        end
        szNpcName = szNpcName..szTrueNpc; 

        self:SendKinNotify(nKinId, nWorldNotice == 1, nKinNotice == 1, szNpcName, szInfoMsg);
    end
         
    Log("BossLeader CalKinDmgItem!!", szType, nKinId, nItemCount, fItemCount);   
end


function BossLeader:AllocBossLeaderAward(szType)
    local tbTypeData = self:GetTypeData(szType);
    if tbTypeData.bAllockAward then
        Log("BossLeader bAllockAward", szType);
        return;
    end

    tbTypeData.bAllockAward = true;
    
    self:AllocKinAward(szType);
    self:AllocPlayerAward(szType);  

    Log("BossLeader AllocBossLeaderAward", szType);
end

function BossLeader:GetKinTotalJoinCount(szType, nKinId)
    local tbJoinKinCount = self:GetKinJoinCount(szType);
    local tbPlayer = tbJoinKinCount[nKinId];
    if not tbPlayer then
        return 0;
    end    

    return Lib:CountTB(tbPlayer);
end  

function BossLeader:AllocKinAward(szType)
    local tbJoinKinCount = self:GetKinJoinCount(szType);
    for nKinId, tbPlayerIds in pairs(tbJoinKinCount) do
        if not MODULE_ZONESERVER then
            self:SendKinAward(szType, nKinId, tbPlayerIds);
        else
            local nConnectIdx = self:GetKinConnectIndex(nKinId);
            CallZoneClientScript(nConnectIdx, "BossLeader:CrossSendKinAward", szType, nKinId, tbPlayerIds);
        end    
    end  

    Log("BossLeader AllocKinAward", szType);
end

function BossLeader:AddPlayerRankAward(szType, nPlayerID, tbAllAward, nDropX, nDropY, szDropNpcName)
    if not tbAllAward then
        Log("Error BossLeader AddPlayerRankAward", szType, nPlayerID);
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

function BossLeader:AllocPlayerAward(szType)

   
    Log("BossLeader AllocPlayerAward", szType);
end

function BossLeader:RateRandomCount(fValue)
    local nCount = math.floor(fValue);
    local nRateCount = (fValue - nCount) * 10000;

    if nRateCount > 0 then
        local nCurRate = MathRandom(10000);
        if nRateCount >= nCurRate then
            nCount = nCount + 1;
        end    
    end

    return nCount;
end

function BossLeader:GetKinRankValueParam(tbRankValue, nRank)
    if not tbRankValue then
        return 0;
    end

    for _, tbInfo in pairs(tbRankValue) do
        if tbInfo.nMinRank <= nRank and nRank <= tbInfo.nMaxRank then
            return tbInfo.nValue;
        end    
    end

    return 0;    
end

function BossLeader:CalcBaoDiKinAward(szType, nKinId, nJoinCount)
    if not BossLeader.tbBaoDiKinAward[szType] then
        return;
    end

    local nBaoDiValue = BossLeader.nBaoDiAwardValue * nJoinCount;
    local tbTimeFrameInfo = BossLeader:GetTimeFrameSetting();
    self:CalcBaoDiMJLingAward(szType, nKinId, nBaoDiValue, tbTimeFrameInfo);
    self:CalcBaoDiItemAward(szType, nKinId, nBaoDiValue, tbTimeFrameInfo);
    Log("CalcBaoDiKinAward", szType, nKinId);
end

function BossLeader:CalcBaoDiItemAward(szType, nKinId, nBaoDiValue, tbTimeFrameInfo)
    if not Lib:HaveCountTB(tbTimeFrameInfo.tbBaoDiAward) then
        return;
    end
    
    for _, tbBaoDi in pairs(tbTimeFrameInfo.tbBaoDiAward) do
        if tbBaoDi.BaoDiItemID > 0 then
            local nBaseValue = KItem.GetBaseValue(tbBaoDi.BaoDiItemID);
            local nCurValue = nBaoDiValue * tbBaoDi.BaoDiItemParam / nBaseValue;
            local nCount = self:RateRandomCount(nCurValue);
            self:AddKinAuctionItem(szType, nKinId, tbBaoDi.BaoDiItemID, nCount);

            if nCount > 0 then
                local szNpcName   = "歷代名將";
                local szItemName = KItem.GetItemShowInfo(tbBaoDi.BaoDiItemID);
                local szMsg = string.format("%s個%s", nCount, szItemName);
                self:SendKinNotify(nKinId, tbBaoDi.BaoDiItemWorldMsg == 1, tbBaoDi.BaoDiItemKinMsg == 1, szNpcName, szMsg);
            end

            Log("CalcBaoDiItemAward", szType, nKinId, tbBaoDi.BaoDiItemID, nBaoDiValue, nCurValue);
        end    
    end     
end    

function BossLeader:CalcBaoDiMJLingAward(szType, nKinId, nBaoDiValue, tbTimeFrameInfo)
    local nBaseValue = KItem.GetBaseValue(BossLeader.nMJHonorID);
    local nCurValue = nBaoDiValue * tbTimeFrameInfo.BaoDiMJLingParam / nBaseValue;
    local nCount = self:RateRandomCount(nCurValue);
    self:AddKinAuctionItem(szType, nKinId, BossLeader.nMJHonorID, nCount);

    if nCount > 0 then
        local szNpcName   = "歷代名將";
        local szItemName = KItem.GetItemShowInfo(BossLeader.nMJHonorID);
        local szMsg = string.format("%s個%s", nCount, szItemName);
        self:SendKinNotify(nKinId, true, false, szNpcName, szMsg);
    end

    Log("CalcBaoDiMJLingAward", szType, nKinId, nBaoDiValue, nCurValue);
end

function BossLeader:SendKinAward(szType, nKinId, tbPlayerIds)
    local nJoinCount = Lib:CountTB(tbPlayerIds);
    self:CalcBaoDiKinAward(szType, nKinId, nJoinCount);

    local tbAuctionAward = self:GetKinAuctionInfo(szType, nKinId);
    local nTotalCount = Lib:CountTB(tbAuctionAward);
    if nTotalCount > 0 then
        local tbSendAward = {};
        for nItemID, nCount in pairs(tbAuctionAward) do
            if nCount > 0 then
                table.insert(tbSendAward, {nItemID, nCount});
            end    
        end

        self:AuctionKinAward(szType, nKinId, tbSendAward, tbPlayerIds);    
    end       
end

function BossLeader:AuctionKinAward(szType, nKinId, tbAllAward, tbPlayerIds)
    local szDesc  = self.tbKinAwardDesc[szType] or "";
    Kin:AddAuction(nKinId, "BossLeader_"..szType, tbPlayerIds, tbAllAward, szDesc);
    Log("BossLeader AuctionKinAward-----", szType, nKinId);
    Lib:LogTB(tbAllAward);
    Log("BossLeader AuctionKinAward-----", szType, nKinId);
end

function BossLeader:SendDropAward(pPlayer, tbAward, nLogType, nPosX, nPosY, szDropNpcName)
    local tbMsgInfo = {};
    tbMsgInfo.szNpcName = szDropNpcName or "";
    pPlayer.DropAward(nPosX, nPosY, tbMsgInfo, tbAward, nLogType, nil, false, true);
end

function BossLeader:SendMailAward(szType, nPlayerID, tbAward, nDropX, nDropY, szDropNpcName)
    local nLogType = Env.LogWay_FieldBoss;
    if szType == "Leader" then
        nLogType = Env.LogWay_FieldLeader;
    end
            
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

    Log("BossLeader SendMailAward PlayerID", nPlayerID)
end

function BossLeader:GetMapNpcTimeDeath(szType)
    local tbTypeData = self:GetTypeData(szType);
    local tbTodayType = self:GetTypeTodayData(szType);
    local tbTimeMap = tbTodayType.tbTimeMapDeath[tbTypeData.nStartTime];
    if not tbTimeMap then
        tbTimeMap = {};
        tbTodayType.tbTimeMapDeath[tbTypeData.nStartTime] = tbTimeMap;
    end

    return tbTimeMap;
end

function BossLeader:GetNpcDeathInfo(szType, nMapTID)
    local tbTimeMap = self:GetMapNpcTimeDeath(szType);
    local tbCurMapNpcInfo = tbTimeMap[nMapTID];
    if not tbCurMapNpcInfo then
        tbCurMapNpcInfo = {};
        tbTimeMap[nMapTID] = tbCurMapNpcInfo;
    end
        
    return tbCurMapNpcInfo;
end

function BossLeader:AddNpcDeathInfo(szType, nPlayerID, tbNpcInfo, nMapTID)
    local tbStayInfo = KPlayer.GetRoleStayInfo(nPlayerID);
    if not tbStayInfo then
        Log("[ERROR]BossLeader AddNpcDeathInfo", szType, nPlayerID);
        return;
    end

    if tbNpcInfo.IsFalse == 1 and tbNpcInfo.IsRecordDeath ~= 1 then
        return;
    end    

    local tbNpcDeath = self:GetNpcDeathInfo(szType, nMapTID); 
    local tbDeathInfo = {};
    tbDeathInfo.szPlayerName = tbStayInfo.szName;

    local szKinName = self:GetKinNameById(tbStayInfo.dwKinId);
    tbDeathInfo.szKinName = szKinName or "-";
    tbDeathInfo.tbNpcInfo = tbNpcInfo;
    table.insert(tbNpcDeath, tbDeathInfo);    
end

function BossLeader:GetSyncClientData(szType)
    local tbTypeData = self.tbAllTypeData[szType];
    local tbSyncData = {};
    tbSyncData[1] = {}; --存活的数据
    tbSyncData[2] = {}; --死亡的数据
    tbSyncData[3] = 0;
    tbSyncData[4] = tbTypeData.nStartTime;
    if tbTypeData.bStart then
        tbSyncData[3] = 1;
    elseif tbTypeData.bAllockAward then
        tbSyncData[3] = 2;
    end    

    local tbCreateNpcData = self:GetCreateNpcData(szType);
    for nMapID, tbAllNpc in pairs(tbCreateNpcData) do
        local nMapTID = self:GetMapTemplateByID(nMapID);
        local tbCurMapInfo = tbSyncData[1][nMapTID];
        if not tbCurMapInfo then
            tbCurMapInfo = {};
            tbSyncData[1][nMapTID] = tbCurMapInfo;
        end
            
        for _, tbNpcInfo in pairs(tbAllNpc) do
            table.insert(tbCurMapInfo, tbNpcInfo.NpcID);
        end    
    end

    local tbTodayType = self:GetTypeTodayData(szType);
    for nStartTime, tbMapDeathNpc in pairs(tbTodayType.tbTimeMapDeath) do
        local tbTimeMap = {};
        tbSyncData[2][nStartTime] = tbTimeMap;

        for nMapTID, tbAllNpcDeath in pairs(tbMapDeathNpc) do

            local tbCurMapInfo = tbTimeMap[nMapTID];
            if not tbCurMapInfo then
                tbCurMapInfo = {};
                tbTimeMap[nMapTID] = tbCurMapInfo;
            end

            for _, tbNpcDeath in pairs(tbAllNpcDeath) do
                local tbSyncNpcInfo = {};
                tbSyncNpcInfo[1] = tbNpcDeath.szPlayerName;
                tbSyncNpcInfo[2] = tbNpcDeath.szKinName;
                tbSyncNpcInfo[3] = tbNpcDeath.tbNpcInfo.NpcID;
                table.insert(tbCurMapInfo, tbSyncNpcInfo);
            end    
        end    
    end 

    return tbSyncData;  
end

function BossLeader:ResetUpdateDataTime(szType)
    local tbTodayType = self:GetTypeTodayData(szType);
    tbTodayType.nUpdateDataTime = 0;
end

function BossLeader:ClientRequestData(szType)
    local tbTypeData = self.tbAllTypeData[szType];
    if not tbTypeData then
        return;
    end

    local tbTodayType = self:GetTypeTodayData(szType);
    local nCurTime = GetTime();
    if (nCurTime - tbTodayType.nUpdateDataTime) > 60 then
        tbTodayType.tbSyncData = self:GetSyncClientData(szType);
        tbTodayType.nUpdateDataTime = nCurTime;
    end

    local tbSyncData = tbTodayType.tbSyncData or {}; 
    return tbSyncData;
end    

function BossLeader:OnEnterMap(nMapTemplateId, nMapId)
    self:CrossPlayerEnterMap(me);
    self:SetPlayerPkMode(me);
    --me.AddSkillState(1517, 1, 0, 10 * Env.GAME_FPS, 0, 1);
    me.nCanLeaveMapId = me.nMapId;
    me.bOpenComboSkill = true;
    me.szComboSkillFun = "FieldBoss";
    me.CallClientScript("Ui:OpenWindow", "QYHLeavePanel");
    me.CallClientScript("Map:SetCloseUiOnLeave", me.nMapId, "QYHLeavePanel");
    me.nEnterBossTime = GetTime();

    local tbPlayerInfo = {};
    tbPlayerInfo.nOnDeathRegID = PlayerEvent:Register(me, "OnDeath", self.OnPlayerDeath, self);
    self.tbAllPlayerMapInfo[me.dwID] = tbPlayerInfo;
    --me.CallClientScript("BossLeader:BlackMsg", "Boss", nMapTemplateId);
end

function BossLeader:OnLoginMap(nMapTemplateId, nMapId)
    me.CallClientScript("Ui:OpenWindow", "QYHLeavePanel");
    me.CallClientScript("Map:SetCloseUiOnLeave", me.nMapId, "QYHLeavePanel");
    self:CrossPlayerLoginMap(me);    
end

function BossLeader:OnPlayerDeath(pKiller)
    self:OnCrossPlayerDeath(me, pKiller)

    if not pKiller then
        return;
    end

    local pPlayer = pKiller.GetPlayer();
    if not pPlayer then
        return;
    end

    if not BossLeader:IsBossLeaderMap(pPlayer.nMapTemplateId, "Boss") then
        return;
    end

    local tbTypeData = self:GetTypeData("Boss");
    if not tbTypeData.bStart then
        return;
    end

    Lib:CallBack({RecordStone.AddRecordCount, RecordStone, pPlayer, "Boss", 1});
    Log("BossLeader:OnPlayerDeath");
end

function BossLeader:SetPlayerPkMode(pPlayer)
    pPlayer.SetPkMode(Player.MODE_PK);
end

function BossLeader:OnLeaveMap(nMapTemplateId, nMapId)
    self:CrossPlayerLeaveMap(me);

    local nBossTime = me.nEnterBossTime;
    me.SetPkMode(Player.MODE_PEACE);
    me.szCurTrapName = nil;
    me.bOpenComboSkill = nil;
    me.szComboSkillFun = nil;
    me.nEnterBossTime  = nil;
    self:UpdatePlayerTrap(me);
    me.CallClientScript("Ui:OpenWindow", "BossLeaderPanel", "Boss");

    if nBossTime then
        local nMatchTime = GetTime() - nBossTime;
        local tbLogData = 
        {
            Result = Env.LogRound_SUCCESS;
            nMatchTime = nMatchTime;
        };
        me.ActionLog(Env.LogType_Activity, Env.LogWay_FieldBoss, tbLogData);
    end

    local tbPlayerInfo = self.tbAllPlayerMapInfo[me.dwID];
    if tbPlayerInfo then
        if tbPlayerInfo.nOnDeathRegID then
            PlayerEvent:UnRegister(me, "OnDeath", tbPlayerInfo.nOnDeathRegID);
            tbPlayerInfo.nOnDeathRegID = nil;
        end    
    end

    self.tbAllPlayerMapInfo[me.dwID] = nil;        
end

function BossLeader:OnPlayerTrap(nMapTemplateId, nMapID, szTrapName)
    me.szCurTrapName = szTrapName;
    self:UpdatePlayerTrap(me);   
end

function BossLeader:UpdatePlayerTrap(pPlayer)
    local nMapId = pPlayer.nMapId;
    local szTrapName = pPlayer.szCurTrapName or "-";
    local tbOpenTrapData = BossLeader:GetOpenTrapByMap("Boss", nMapId);
    if tbOpenTrapData[szTrapName] then
        pPlayer.CallClientScript("Player:ServerSyncData", "OpenBtnInfo", string.format("BossLeaderOutputPanel:%s", pPlayer.nMapTemplateId));

        if pPlayer.dwKinId > 0 then
            BossLeader:AddKinJoinCount("Boss", pPlayer);
        end    
    else
        pPlayer.CallClientScript("Player:ServerSyncData", "OpenBtnInfo", "--"); 
    end  
end

function BossLeader:GetMapKinDmgRank(szType, nMapID)
    local tbTypeData = self:GetTypeData(szType);
    if not tbTypeData.tbNpcKinDmgRank[nMapID] then
        tbTypeData.tbNpcKinDmgRank[nMapID] = 
        {
            tbLastRequestTime = {};
            tbEndDmdKinRank = {};
            tbSyncInfo      = {};
            tbTrapNpc       = {};
        };
    end

    local tbMapKinDmgRank = tbTypeData.tbNpcKinDmgRank[nMapID];
    tbMapKinDmgRank.tbEndDmdKinRank = tbMapKinDmgRank.tbEndDmdKinRank  or {}; 
    tbMapKinDmgRank.tbSyncInfo      = tbMapKinDmgRank.tbSyncInfo or {};
    tbMapKinDmgRank.tbLastRequestTime = tbMapKinDmgRank.tbLastRequestTime or {};
    tbMapKinDmgRank.tbTrapNpc       = tbMapKinDmgRank.tbTrapNpc or {};
    return tbMapKinDmgRank;
end


function BossLeader:GetPlayerKinID(nPlayerID)
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

function BossLeader:GetCalDmCallNpc(pNpc, nCalcDmgCallNpc)
    local  tbBLInfo = pNpc.tbBossLeaderInfo;
    if not tbBLInfo then
        return;
    end

    local tbAllCallNpc = tbBLInfo.tbCallNpcKey;
    if not nCalcDmgCallNpc or not tbAllCallNpc then
        return;
    end

    if not tbAllCallNpc[nCalcDmgCallNpc] then
        return;
    end

    local tbAllSortDamage = {};
    for _, nNpcID in pairs(tbAllCallNpc[nCalcDmgCallNpc]) do
        local pCallNpc = KNpc.GetById(nNpcID);
        if pCallNpc then
            local tbSortDamage = pCallNpc.GetDamageInfo();
            if tbSortDamage then
                Lib:MergeTable(tbAllSortDamage, tbSortDamage);
            end
        end
    end

    return tbAllSortDamage;
end

function BossLeader:UpdateClientKinDmgRank(szType, nMapID, szTrapName, nNpcID)
    local pNpc = KNpc.GetById(nNpcID);
    if not pNpc then
        return;
    end

    local tbSortDamage = pNpc.GetDamageInfo();
    if not tbSortDamage or #tbSortDamage <= 0 then
        return;
    end

    local tbBLInfo = pNpc.tbBossLeaderInfo;
    local tbNpcInfo = tbBLInfo.tbNpcInfo or {};
    if tbNpcInfo.CallEventID > 0 then
        local tbCallEvent = self:GetCallEventInfo(tbNpcInfo.CallEventID, "CalcDmg");
        if tbCallEvent then
            for _, tbEvent in pairs(tbCallEvent) do
                if not Lib:IsEmptyStr(tbEvent.Param1) then
                    local nCalllNpcID = tonumber(tbEvent.Param1);
                    local tbCallDmg = self:GetCalDmCallNpc(pNpc, nCalllNpcID);
                    if tbCallDmg then
                        Lib:MergeTable(tbSortDamage, tbCallDmg);
                    end
                end
            end
        end
    end

    if tbBLInfo.tbAllCallNpcDmg then
        Lib:MergeTable(tbSortDamage, tbBLInfo.tbAllCallNpcDmg);
    end

    local function fnDamageCmp(a, b)
        return a.nTotalDamage > b.nTotalDamage;
    end
    table.sort(tbSortDamage, fnDamageCmp);

    local tbKinSort = {};
    local nFirstCaptainId = -1;
    for nRank, tbDmgInfo in ipairs(tbSortDamage) do

        local nCaptainId = -1;
        local tbTeam = nil;
        if tbDmgInfo.nTeamId > 0 then
            tbTeam = TeamMgr:GetTeamById(tbDmgInfo.nTeamId);
        end    
        if tbTeam then
            nCaptainId = tbTeam:GetCaptainId();
        elseif tbDmgInfo.nAttackRoleId > 0 then
            nCaptainId = tbDmgInfo.nAttackRoleId;
        end

        if nCaptainId > 0 then
            local nKinId = self:GetPlayerKinID(nCaptainId)
            if nKinId > 0 then
                local szKinName = self:GetKinNameById(nKinId);
                szKinName = szKinName or "-";
                local nCurtDmg  = 0;
                if tbKinSort[szKinName] and tbKinSort[szKinName].nTotalDmg then
                    nCurtDmg = tbKinSort[szKinName].nTotalDmg;
                end
                    
                tbKinSort[szKinName] = {nKinId = nKinId, nTotalDmg = nCurtDmg + tbDmgInfo.nTotalDamage};
            end    
        end    
    end

    local nNpcTotalDamage = pNpc.nMaxLife;
    if tbNpcInfo and tbNpcInfo.NpcMaxLife > 0 then
        nNpcTotalDamage = tbNpcInfo.NpcMaxLife;
    end

    local tbSortDmg = {};
    for szKinName, tbInfo in pairs(tbKinSort) do
        local nHPPercent = tbInfo.nTotalDmg * 100 / nNpcTotalDamage;
        if tbBLInfo.nFirstTouchKin and tbBLInfo.nFirstTouchKin == tbInfo.nKinId then
            nHPPercent = nHPPercent + BossLeader.nFirstLastDmgMJHPPercent;
        end

        nHPPercent = nHPPercent * BossLeader.nHPPercentParam;
        table.insert(tbSortDmg, {szKinName, nHPPercent});
    end

    local function fnKinDamage(a, b)
        return a[2] > b[2];
    end
    table.sort(tbSortDmg, fnKinDamage);

    local tbMapKinDmgRank = self:GetMapKinDmgRank(szType, nMapID);
    tbMapKinDmgRank.tbSyncInfo[szTrapName] = {};
    tbMapKinDmgRank.tbTrapNpc[szTrapName] = pNpc.nTemplateId;
    local nMaxRank = math.min(self.nShowMaxRank, #tbSortDmg);
    for nI = 1, nMaxRank do

        local tbInfo = tbSortDmg[nI];
        tbInfo[2] = math.max(BossLeader.nMinHPPercent, tbInfo[2]);
        tbInfo[2] = math.floor(tbInfo[2]);

        tbMapKinDmgRank.tbSyncInfo[szTrapName][nI] = tbInfo;
    end
end

function BossLeader:ClientRequestKinDmgRank(pPlayer, szType)
    local szTrapName = pPlayer.szCurTrapName;
    local nMapID     = pPlayer.GetWorldPos();
    local tbOpenTrapData = BossLeader:GetOpenTrapByMap(szType, nMapID);
    local tbTrapData = tbOpenTrapData[szTrapName];
    if not tbTrapData then
        return;
    end    


    local tbTypeData = self:GetTypeData(szType);
    local tbMapKinDmgRank = self:GetMapKinDmgRank(szType, nMapID);
    local tbSyncInfo = nil;
    if tbMapKinDmgRank.tbEndDmdKinRank[szTrapName] then
        tbSyncInfo = tbMapKinDmgRank.tbEndDmdKinRank[szTrapName];
    else
        local nCurTime = GetTime();
        tbMapKinDmgRank.tbLastRequestTime[szTrapName] = tbMapKinDmgRank.tbLastRequestTime[szTrapName] or 0;
        if (nCurTime - tbMapKinDmgRank.tbLastRequestTime[szTrapName]) > 10 then

            self:UpdateClientKinDmgRank(szType, nMapID, szTrapName, tbTrapData.nNpcID);
            tbMapKinDmgRank.tbLastRequestTime[szTrapName] = nCurTime;

        end
        
        tbSyncInfo = tbMapKinDmgRank.tbSyncInfo[szTrapName];
    end    

    pPlayer.CallClientScript("Player:ServerSyncData", "BossLeader_"..pPlayer.nMapTemplateId, tbSyncInfo or {}, tbMapKinDmgRank.tbTrapNpc[szTrapName] or 0);   
end    

-- ===================================================IDIP用到=================================================================

function BossLeader:PlayerDmgInfo(dwID,szType)

    local nPlayerTotalDmg = 0
    local nPlayerRank = 0
    local nKinTotalDmg = 0
    local nKinRank = 0
    local pPlayer = KPlayer.GetPlayerObjById(dwID)
    local bIsOnBossMap = false
    if pPlayer then
        bIsOnBossMap = self:CheckPlayerIsBossMap(pPlayer.nMapId,szType);
    end
    if not pPlayer or not bIsOnBossMap then                                            -- 玩家不在线或者不在Boss地图                                      
        nPlayerTotalDmg,nPlayerRank,nKinTotalDmg,nKinRank = self:GetPlayerMaxDmgInfo(dwID,szType);
    else
        local nNpcId = self:NearestBossNpcId(pPlayer,szType)
        if nNpcId == 0 then                                                             -- boss地图所有Boss被击杀
            nPlayerTotalDmg,nPlayerRank,nKinTotalDmg,nKinRank = self:GetPlayerMaxDmgInfo(dwID,szType);
        else
            nPlayerTotalDmg,nPlayerRank,nKinTotalDmg,nKinRank = self:GetPlayerNearestDmgInfo(dwID,nNpcId);           -- 返回离玩家最近的Boss数据
        end
        
    end
    return nPlayerTotalDmg,nPlayerRank,nKinTotalDmg,nKinRank
end

-- 当前Boss地图中距离玩家最近的boss伤害信息
function BossLeader:GetPlayerNearestDmgInfo(dwID,nNpcId)
    local nPlayerTotalDmg,nPlayerRank = self:GetPlayerDmgInfo(nNpcId,dwID)
    local nKinTotalDmg,nKinRank = self:GetPlayerKinDmgInfo(nNpcId,dwID);
    return nPlayerTotalDmg,nPlayerRank,nKinTotalDmg,nKinRank
end

-- 所有Boss中伤害排名最高的信息（取家族伤害最高的那只Boss数据）
function BossLeader:GetPlayerMaxDmgInfo(dwID,szType)
    local nPlayerTotalDmg,nPlayerBestRank,nKinTotalDmg,nKinBestRank = 0,0,0,0
    local tbTypeData = self:GetTypeData(szType);
    local tbAllCreateNpc = tbTypeData.tbAllCreateNpc;
    local nMyKinId = self:GetPlayerKinID(dwID)
    for _,tbInfo in pairs(tbAllCreateNpc) do
        for nNpcId,_ in pairs(tbInfo) do
            if nMyKinId > 0 then                            -- 有家族按家族排名最高的Boss数据
                local nKinDmg,nKinRank = self:GetPlayerKinDmgInfo(nNpcId,dwID)
                if nKinRank ~= 0 then
                    if nKinBestRank == 0 then
                        nKinTotalDmg,nKinBestRank = nKinDmg,nKinRank
                        nPlayerTotalDmg,nPlayerBestRank = self:GetPlayerDmgInfo(nNpcId,dwID)
                    elseif nKinBestRank > nKinRank then
                        nKinTotalDmg,nKinBestRank = nKinDmg,nKinRank
                        nPlayerTotalDmg,nPlayerBestRank = self:GetPlayerDmgInfo(nNpcId,dwID)
                    end
                end
            else                                            -- 没家族按个人排名最高的Boss数据
                local nPlayerDmg,nPlayerRank = self:GetPlayerDmgInfo(nNpcId,dwID)
                if nPlayerRank ~= 0 then
                    if nPlayerBestRank == 0 then
                        nPlayerTotalDmg,nPlayerBestRank = nPlayerDmg,nPlayerRank
                    elseif nPlayerBestRank > nPlayerRank then
                        nPlayerTotalDmg,nPlayerBestRank = nPlayerDmg,nPlayerRank
                    end
                end
            end
        end
    end

    return nPlayerTotalDmg,nPlayerBestRank,nKinTotalDmg,nKinBestRank
end

-- 找出距离玩家最近的Boss
function BossLeader:NearestBossNpcId(pPlayer,szType)

    local nBossNpcId = 0
    local nMyMapId,nMyPosX,nMyPosY = pPlayer.GetWorldPos(); 
    local tbTypeData = self:GetTypeData(szType);
    local tbAllCreateNpc = tbTypeData.tbAllCreateNpc;
    for nBossMapId,tbInfo in pairs(tbAllCreateNpc) do
        if nBossMapId == nMyMapId then
            local nNearestDis = 999999999;
            for nNpcId,_ in pairs(tbInfo) do
                local pNpc = KNpc.GetById(nNpcId);
                if pNpc then
                    local _,nNpcX,nNpcY = pNpc.GetWorldPos()
                    local nDis = math.floor(math.sqrt(math.pow((nMyPosX - nNpcX),2) + math.pow((nMyPosY - nNpcY),2)));
                    if nDis < nNearestDis then
                        nBossNpcId = nNpcId
                        nNearestDis = nDis
                    end
                end
            end
        end
    end
    return nBossNpcId;
end

-- 返回玩家对npc的伤害和排名
function BossLeader:GetPlayerDmgInfo(nNpcId,dwID)
    local nTotalDamage = 0
    local nMyRank = 0

    local pBossNpc = KNpc.GetById(nNpcId);
    if not pBossNpc then
        return nTotalDamage,nMyRank;
    end

    local tbSortDamage = pBossNpc.GetDamageInfo();
   
    if not tbSortDamage or #tbSortDamage <= 0 then
        return nTotalDamage,nMyRank;
    end

    local function fnDamageCmp(a, b)
       return a.nTotalDamage > b.nTotalDamage;
    end

    table.sort(tbSortDamage, fnDamageCmp);

    for nRank, tbDmgInfo in ipairs(tbSortDamage) do
        local bIsSearched = false
        local tbMember = nil
        if tbDmgInfo.nTeamId and tbDmgInfo.nTeamId > 0 then
            tbMember = TeamMgr:GetMembers(tbDmgInfo.nTeamId);
        end
        if tbMember and next(tbMember) then
            for _,nPlayerID in pairs(tbMember) do
                if nPlayerID == dwID then
                    nTotalDamage = tbDmgInfo.nTotalDamage
                    nMyRank = nRank
                    bIsSearched = true
                    break;
                end
            end
        elseif tbDmgInfo.nAttackRoleId and tbDmgInfo.nAttackRoleId == dwID then
            nTotalDamage = tbDmgInfo.nTotalDamage
            nMyRank = nRank
            bIsSearched = true
        end

        if bIsSearched then
            break;
        end
    end

    return nTotalDamage,nMyRank;
end

-- 检查玩家是否处于Boss地图
function BossLeader:CheckPlayerIsBossMap(nPlayerMapID,szType)
    local tbTypeData = self:GetTypeData(szType);
    local tbAllCreateNpc = tbTypeData.tbAllCreateNpc;
    for nMapID,_ in pairs(tbAllCreateNpc) do
        if nMapID == nPlayerMapID then
            return true
        end
    end
end

-- 返回玩家家族排名和伤害
function BossLeader:GetPlayerKinDmgInfo(nNpcId,dwID)
    local nTotalDamage = 0
    local nMyKinRank = 0
    local nMyKinId = self:GetPlayerKinID(dwID)
    if nMyKinId <= 0 then
        return nTotalDamage,nMyKinRank;
    end

    local pBossNpc = KNpc.GetById(nNpcId);
    if not pBossNpc then
        return nTotalDamage,nMyKinRank;
    end

     local tbDmg = pBossNpc.GetDamageInfo();
    if not tbDmg or #tbDmg <= 0 then
        return nTotalDamage,nMyKinRank;
    end

    local tbKinTemp = {}
    for _,tbDmgInfo in pairs(tbDmg) do
        local nRoleID = -1
        local tbTeam = nil;
        if tbDmgInfo.nTeamId > 0 then
            tbTeam = TeamMgr:GetTeamById(tbDmgInfo.nTeamId);
        end   
        if tbTeam then
            nRoleID = tbTeam:GetCaptainId();
        elseif tbDmgInfo.nAttackRoleId > 0 then
            nRoleID = tbDmgInfo.nAttackRoleId;
        end
        if nRoleID > 0 then
            local nKinId = self:GetPlayerKinID(nRoleID)
            if nKinId and nKinId > 0 then
                if not tbKinTemp[nKinId] then
                    tbKinTemp[nKinId]                  = {}
                    tbKinTemp[nKinId].nTotalDamage     = 0
                    tbKinTemp[nKinId].nKinId          = nKinId
                end
                tbKinTemp[nKinId].nTotalDamage = tbKinTemp[nKinId].nTotalDamage + tbDmgInfo.nTotalDamage
            end
        end
    end

    local tbSortKinDmg = {}
    for _,tbDmgInfo in pairs(tbKinTemp) do
        table.insert(tbSortKinDmg,tbDmgInfo)
    end

    if #tbSortKinDmg <= 0 then
        return nTotalDamage,nMyKinRank;
    end

    local function fnDamageCmp(a, b)
        return a.nTotalDamage > b.nTotalDamage;
    end

    table.sort(tbSortKinDmg, fnDamageCmp);

    for nRank,tbDmgInfo in ipairs(tbSortKinDmg) do
        if nMyKinId == tbDmgInfo.nKinId then
            nTotalDamage = tbDmgInfo.nTotalDamage
            nMyKinRank    = nRank
            break
        end
    end

    return nTotalDamage,nMyKinRank;
end