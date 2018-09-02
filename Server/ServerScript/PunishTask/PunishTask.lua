

PunishTask.tbCreateMapNpc     = PunishTask.tbCreateMapNpc or {};
PunishTask.tbEnterMap         = PunishTask.tbEnterMap or {};
PunishTask.szCurOpenTimeFrame = PunishTask.szCurOpenTimeFrame or "";
PunishTask.nSpecialItem = 1348;

function PunishTask:LoadSetting()
    self.tbMainSetting   = {};
    self.tbMapNpcSetting = {};
    self.tbMapPosSetting = {};

    local tbFileData = Lib:LoadTabFile("ServerSetting/PunishTask/Main.tab", {NpcCount = 1, MapID = 1});
    for _, tbInfo in pairs(tbFileData) do
        self.tbMainSetting[tbInfo.TimeFrame] = self.tbMainSetting[tbInfo.TimeFrame] or {};
        self.tbMainSetting[tbInfo.TimeFrame][tbInfo.MapID] = tbInfo;
    end

    tbFileData = Lib:LoadTabFile("ServerSetting/PunishTask/MapPos.tab", {MapID = 1, PosX = 1, PosY = 1, NpcGroupID = 1, Rate = 1});
    for _, tbInfo in pairs(tbFileData) do
        self.tbMapPosSetting[tbInfo.MapID] = self.tbMapPosSetting[tbInfo.MapID] or {};
        table.insert(self.tbMapPosSetting[tbInfo.MapID], tbInfo);
    end    

    tbFileData = Lib:LoadTabFile("ServerSetting/PunishTask/MapNpc.tab", {GroupID = 1, OrgNpcID = 1, NpcID = 1, Rate = 1, IsWhilte = 1});
    for _, tbInfo in pairs(tbFileData) do
        self.tbMapNpcSetting[tbInfo.GroupID] = self.tbMapNpcSetting[tbInfo.GroupID] or {};
        local tbAllNpcGroup = self.tbMapNpcSetting[tbInfo.GroupID];
        tbInfo.tbAward    = Lib:GetAwardFromString(tbInfo.Award);
        tbInfo.tbCaptainAward = Lib:GetAwardFromString(tbInfo.CaptainAward);

        tbAllNpcGroup.nTotalRate = tbAllNpcGroup.nTotalRate or 0;
        tbAllNpcGroup.nTotalRate = tbAllNpcGroup.nTotalRate + tbInfo.Rate;
        tbAllNpcGroup.tbAllNpcInfo = tbAllNpcGroup.tbAllNpcInfo or {}; 
        table.insert(tbAllNpcGroup.tbAllNpcInfo, tbInfo);
    end    
end


function PunishTask:GetCurTimeFrame()
    local szTimeFrame = Lib:GetMaxTimeFrame(self.tbMainSetting);
    return szTimeFrame;
end  

function PunishTask:StartCreateMapNpc()
    local szTimeFrame = self:GetCurTimeFrame();   
    if not szTimeFrame or szTimeFrame == self.szCurOpenTimeFrame then
        return;
    end

    local tbMapInfo = self.tbMainSetting[szTimeFrame];
    if not tbMapInfo then
        Log("Error PunishTask StartCreateMapNpc Not Npc TimeFrame", szTimeFrame);
        return;
    end

    local szLastTimeFrame = self.szCurOpenTimeFrame;
    self.szCurOpenTimeFrame = szTimeFrame;
    for _, tbInfo in pairs(tbMapInfo) do
        local tbCurMapNpc = self:GetCreateMapNpc(tbInfo.MapID);
        local nAddNpcCount = tbInfo.NpcCount;
        local nCurNpcCount = Lib:CountTB(tbCurMapNpc);
        nAddNpcCount = nAddNpcCount - nCurNpcCount;
        if nAddNpcCount > 0 then
            self:CreateMapNpcCount(tbInfo.MapID, nAddNpcCount);  
        end

        if Map:IsTimeFrameOpen(tbInfo.MapID) then
            self.tbEnterMap[tbInfo.MapID] = 1;
        end
    end

    local nActivityId = TeamMgr:GetActivityIdByType("PunishTask", "PunishTask");
    if not nActivityId then
        TeamMgr:RegisterActivity("PunishTask", "PunishTask", "懲惡任務", 
            {"PunishTask:TeamCheckShow", 0},
            {"PunishTask:TeamCheckJoin", 0}, 
            {"PunishTask:TeamCheckEnter", 0}, 
            {"PunishTask:TeamEnterMap", 0},
            PunishTask.nMinTeamCount
            );
    end  

    self:StartTimerWhiteRefresh();
    Log("PunishTask StartCreateMapNpc", self.szCurOpenTimeFrame); 
end

function PunishTask:CheckMapLevel(pPlayer, nMapLevel)
    if pPlayer.nLevel < nMapLevel then
        return false, string.format("等級不足%s級", nMapLevel);
    end

    return true;   
end

function PunishTask:TeamCheckShow(nMapLevel)
    local bRet, szMsg = self:CheckMapLevel(me, nMapLevel);
    if not bRet then
        return false, szMsg;
    end

    if me.nLevel < PunishTask.nMinPlayerLevel then
        return false, string.format("等級不足%s級", PunishTask.nMinPlayerLevel);
    end    

    return true;
end

function PunishTask:PlayerTeamCheckJoin(pPlayer, nMapLevel)
    local bRet, szMsg = self:CheckMapLevel(pPlayer, nMapLevel);
    if not bRet then
        return false, szMsg;
    end

    if pPlayer.nLevel < PunishTask.nMinPlayerLevel then
        return false, string.format("等級不足%s，無法參加懲惡任務", PunishTask.nMinPlayerLevel);
    end

    local bRet = Map:CheckEnterOtherMap(pPlayer);
    if not bRet then
        return false, "不在安全區，不能進入";
    end  

    return true; 
end

function PunishTask:TeamCheckJoin(nMapLevel)   
    local bRet, szMsg = self:PlayerTeamCheckJoin(me, nMapLevel);
    if not bRet then
        return false, szMsg;
    end

    return true;
end

function PunishTask:TeamCheckEnter(nMapLevel)
    local tbNpc = Npc:GetClass("PunishTaskDialog");
    local bRetcode, szMsg = tbNpc:CheckAccept(me);
    if not bRetcode then
        return false, szMsg;
    end

    local bRet1, szMsg1 = self:CheckTeamEnterState(me, nMapLevel);
    if not bRet1 then
        return false, szMsg1;
    end

    return true;
end

function PunishTask:RandomEnterMap(nMapLevel)
    local tbAllMap = self.tbEnterMap;
    if not tbAllMap then
        return;
    end

    local nCount = Lib:CountTB(tbAllMap);
    local nRandom = MathRandom(nCount);
    for nMapID, _ in pairs(tbAllMap) do
        nRandom = nRandom - 1;
        if nRandom <= 0 then
            return nMapID;
        end    
    end    
end

function PunishTask:CheckTeamEnterMap(pPlayer, nMapLevel)
    local bRet = Map:CheckEnterOtherMap(pPlayer);
    if not bRet then
        return false, string.format("「%s」不在安全區，不能進入", pPlayer.szName);
    end

    bRet = self:CheckMapLevel(pPlayer, nMapLevel);
    if not bRet then
        return false, string.format("「%s」等級不足", pPlayer.szName);
    end

    if pPlayer.nLevel < PunishTask.nMinPlayerLevel then
        return false, string.format("等級不足%s，無法參加懲惡任務", PunishTask.nMinPlayerLevel);
    end  

    return true;    
end

function PunishTask:CheckTeamEnterState(pPlayer, nMapLevel)
    local nTeamId = pPlayer.dwTeamID;
    if nTeamId <= 0 then
        return false, "不是隊長";
    end

    local tbTeam = TeamMgr:GetTeamById(nTeamId)
    local nCaptainId = tbTeam:GetCaptainId();
    if nCaptainId ~= pPlayer.dwID then
        return false, "不是隊長!";
    end

    local tbMember  = tbTeam:GetMembers();
    for _, nPlayerID in pairs(tbMember) do
        local pMember = KPlayer.GetPlayerObjById(nPlayerID);
        if not pMember then
            return false, "有隊員不在線不能進入";
        end

        local bRet, szMsg = PunishTask:CheckTeamEnterMap(pMember, nMapLevel)
        if not bRet then
            return false, szMsg;
        end    
    end

    return true, "", tbTeam; 
end

function PunishTask:TeamEnterMap(nMapLevel)
    local bRet, szMsg, tbTeam = self:CheckTeamEnterState(me, nMapLevel);
    if not bRet then
        me.CenterMsg(szMsg);
        return;
    end    

    local nMapTID = self:RandomEnterMap(nMapLevel);
    if not nMapTID then
        Log("[Error] PunishTask RandomEnterMap", nMapLevel);
        return false;
    end  

    local nCaptainId = me.dwID;
    local pPlayerNpc = me.GetNpc();
    local tbMember  = tbTeam:GetMembers();
    for _, nPlayerID in pairs(tbMember) do
        local pMember = KPlayer.GetPlayerObjById(nPlayerID);
        local nPosX, nPosY = Map:GetDefaultPos(nMapTID);
        pMember.SwitchMap(nMapTID, nPosX, nPosY);
        if nPlayerID ~= nCaptainId then
            pMember.CallClientScript("AutoFight:RegisterTeamFollow", pPlayerNpc.nId, nMapTID);
        end        
    end    

    return true;
end

function PunishTask:OnCreateMap(nMapTemplateId, nMapId)
    local tbAllMapInfo = self.tbMainSetting[self.szCurOpenTimeFrame];
    if not tbAllMapInfo then
        return;
    end

    local tbMapInfo = tbAllMapInfo[nMapTemplateId];
    if not tbMapInfo then
        return;
    end

    local tbCurMapNpc = self:GetCreateMapNpc(tbMapInfo.MapID);
    local nAddNpcCount = tbMapInfo.NpcCount;
    local nCurNpcCount = Lib:CountTB(tbCurMapNpc);
    nAddNpcCount = nAddNpcCount - nCurNpcCount;
    if nAddNpcCount <= 0 then
        return;
    end

    self:CreateMapNpcCount(tbMapInfo.MapID, nAddNpcCount);    
end

function PunishTask:StartTimerWhiteRefresh()
    if self.nTimerWhiteRefresh then
        return;
    end

    local nCurTime = Lib:GetLocalDayTime();
    local nTimerTime = 0;
    if nCurTime > self.tbWhiteRefresh[1] and nCurTime < self.tbWhiteRefresh[2] then
        nTimerTime = self.tbWhiteRefresh[2] - nCurTime;
    end

    if nTimerTime <= 60 then
        nTimerTime = self.nPerWhiteRefresh;
    end

    local nTimerFrame = nTimerTime * Env.GAME_FPS;
    self.nTimerWhiteRefresh = Timer:Register(nTimerFrame, self.OnTimerWhiteRefresh, self);
    Log("PunishTask StartTimerWhiteRefresh", self.szCurOpenTimeFrame, nTimerTime); 
end

function PunishTask:OnTimerWhiteRefresh()
    local tbMapCount = {};
    for nMapID, tbAllMapInfo in pairs(self.tbCreateMapNpc) do
        for nIndex, tbNpcDataInfo in pairs(tbAllMapInfo) do
            if not tbNpcDataInfo.nNpcId then
                tbAllMapInfo[nIndex] = nil;
                Log("Error PunishTask OnTimerWhiteRefresh Not Npc", nIndex, nMapID);
            else
                if not tbNpcDataInfo.nTeamId and tbNpcDataInfo.tbNpcInfo.IsWhilte > 0 then
                    local pNpc = KNpc.GetById(tbNpcDataInfo.nNpcId);
                    if pNpc then
                        pNpc.Delete();
                    else
                       Log("Error PunishTask OnTimerWhiteRefresh Not Npc", nIndex, nMapID);     
                    end

                    tbAllMapInfo[nIndex] = nil;
                    tbMapCount[nMapID] = tbMapCount[nMapID] or 0;
                    tbMapCount[nMapID] = tbMapCount[nMapID] + 1;
                end   
            end

        end    
    end

    for nMapID, nCount in pairs(tbMapCount) do
        if nCount > 0 then
            self:CreateMapNpcCount(nMapID, nCount);
        end
            
        Log("PunishTask OnTimerWhiteRefresh", nMapID, nCount);     
    end    
        
    self.nTimerWhiteRefresh = nil;
    self:StartTimerWhiteRefresh();
end

function PunishTask:CreateMapNpcCount(nMapID, nTotalCount)
    if nTotalCount <= 0 then
        Log("Error PunishTask CreateMapNpcCount", nMapID, nTotalCount);
        return;
    end    

    local tbResult = self:RandomMapNpc(nMapID, nTotalCount);
    if not tbResult then
        Log("Error PunishTask CreateMapNpcCount Result", nMapID, nTotalCount);
        return;    
    end

    local nCount = 0;
    for nIndex, _ in pairs(tbResult) do
        self:CreateNpc(nIndex, nMapID);
        nCount = nCount + 1;
    end

    Log("PunishTask CreateMapNpcCount Npc", nMapID, nCount, nTotalCount);  
end

function  PunishTask:GetCreateMapNpc(nMapID)
    if not self.tbCreateMapNpc[nMapID] then
        self.tbCreateMapNpc[nMapID] = {};
    end
    
    return self.tbCreateMapNpc[nMapID];    
end

function PunishTask:RemoveMapNpcInfo(nMapID, nIndex)
    local tbCurMapNpc      = self:GetCreateMapNpc(nMapID);
    local tbPunishTaskInfo = tbCurMapNpc[nIndex];
    if tbPunishTaskInfo and tbPunishTaskInfo.nNotDeathTimer then
        Timer:Close(tbPunishTaskInfo.nNotDeathTimer);
        tbPunishTaskInfo.nNotDeathTimer = nil;
    end

    tbCurMapNpc[nIndex] = nil;
    Log("PunishTask RemoveMapNpcInfo", nMapID, nIndex);  
end

function PunishTask:RebirthNpc(nMapID)
    local tbAllMapInfo = self.tbMainSetting[self.szCurOpenTimeFrame];
    if not tbAllMapInfo then
        Log("Error PunishTask RebirthNpc Not Map", self.szCurOpenTimeFrame, nMapID);
        return;
    end

    local tbMapInfo = tbAllMapInfo[nMapID];
    if not tbMapInfo then
        Log("PunishTask RebirthNpc Not Map", self.szCurOpenTimeFrame, nMapID);
        return;
    end

    local tbCurMapNpc  = self:GetCreateMapNpc(tbMapInfo.MapID);
    local nCurNpcCount = Lib:CountTB(tbCurMapNpc);
    if nCurNpcCount >= tbMapInfo.NpcCount then
        Log("PunishTask RebirthNpc Npc Count Not Add", self.szCurOpenTimeFrame, nMapID, nCurNpcCount, tbMapInfo.NpcCount);
        return;
    end

    self:CreateMapNpcCount(nMapID, 1);
    Log("PunishTask RebirthNpc", self.szCurOpenTimeFrame, nMapID);  
end

function PunishTask:RandomMapNpc(nMapID, nNpcCount)
    local tbMapNpcPos = self.tbMapPosSetting[nMapID];
    if not tbMapNpcPos then
        Log("Error PunishTask RandomMapNpc", nMapID);
        return;
    end

    local tbCurMapNpc = self:GetCreateMapNpc(nMapID);
    local tbRateNpc = {};
    local nTotalRate = 0;
    for nIdex, tbNpcPos in pairs(tbMapNpcPos) do
        if not tbCurMapNpc[nIdex] then
            tbRateNpc[nIdex] = tbNpcPos.Rate;
            nTotalRate = nTotalRate + tbNpcPos.Rate;
        end    
    end

    local nCount = Lib:CountTB(tbRateNpc);
    if nNpcCount >= nCount then
        return tbRateNpc;
    end

    local tbResult = {};
    local nCreateCount = nNpcCount;
    while nCreateCount > 0 do

        local nRate = MathRandom(nTotalRate);

        for nIdex, nNpcRate in pairs(tbRateNpc) do
            if nNpcRate >= nRate then
                tbResult[nIdex] = nNpcRate;
                tbRateNpc[nIdex] = nil;
                nTotalRate = nTotalRate - nNpcRate;
                nCreateCount = nCreateCount - 1;
                break;
            end

            nRate = nRate - nNpcRate;    
        end    
    end

    return tbResult;    
end

function PunishTask:RandomNpcGroup(nNpcGroupID)
    local tbNpcGroup = self.tbMapNpcSetting[nNpcGroupID];
    if not tbNpcGroup then
        Log("Error PunishTask RandomNpcGroup GroupID", nNpcGroupID);
        return;
    end

    local nCurRate = MathRandom(tbNpcGroup.nTotalRate);

    for _, tbNpcInfo in pairs(tbNpcGroup.tbAllNpcInfo) do
        if tbNpcInfo.Rate >= nCurRate then
            return tbNpcInfo;
        end

        nCurRate = nCurRate - tbNpcInfo.Rate;    
    end    
end

function PunishTask:CreateNpc(nIdex, nMapID)
    local nMapTemId = GetMapInfoById(nMapID);
    if not nMapTemId then
        Log("PunishTask CreateNpc Map Not Map", nMapID, nIdex);
        return;
    end

    local tbMapNpcPos = self.tbMapPosSetting[nMapID];
    if not tbMapNpcPos then
        Log("Error PunishTask CreateNpc Map Map", nMapID, nIdex);
        return;
    end  

    local tbNpcPos = tbMapNpcPos[nIdex];
    if not tbNpcPos then
        Log("Error PunishTask CreateNpc Map Index", nMapID, nIdex);
        return;
    end

    local tbCurMapNpc = self:GetCreateMapNpc(nMapID);
    if tbCurMapNpc[nIdex] then
        Log("Error PunishTask CreateNpc Map Have Index", nMapID, nIdex);
        return;
    end

    local tbNpcInfo = self:RandomNpcGroup(tbNpcPos.NpcGroupID);
    if not tbNpcInfo then
        Log("Error PunishTask CreateNpc Map Not Groupd", nMapID, nIdex, tbNpcPos.NpcGroupID);
        return;
    end    
        
    local pNpc = KNpc.Add(tbNpcInfo.OrgNpcID, 1, 1, nMapID, tbNpcPos.PosX, tbNpcPos.PosY, 0, MathRandom(Env.LOGIC_MAX_DIR));
    if not pNpc then
        Log("Error PunishTask CreateNpc Npc", tbNpcInfo.OrgNpcID, nMapID, tbNpcPos.PosX, tbNpcPos.PosY);   
        return;
    end

    local tbCrateNpcData = {};
    tbCrateNpcData.nIdex = nIdex;
    tbCrateNpcData.nMapID = nMapID;
    tbCrateNpcData.nPosX  = tbNpcPos.PosX;
    tbCrateNpcData.nPosY  = tbNpcPos.PosY;
    tbCrateNpcData.tbNpcInfo = tbNpcInfo;
    tbCrateNpcData.nNpcId = pNpc.nId;
    pNpc.tbPunishTaskInfo = tbCrateNpcData;
    tbCurMapNpc[nIdex] = tbCrateNpcData;
end

function PunishTask:TeamHaveSkillNpc(nTeamId)
    for _, tbMapNpc in pairs(self.tbCreateMapNpc) do
        for _, tbNpcData in pairs(tbMapNpc) do
            if tbNpcData.nTeamId and tbNpcData.nTeamId == nTeamId then
                return true;
            end
        end    
    end

    return false;    
end

function PunishTask:StartNotDeathRebirthNpc(pNpc)
    local tbPunishTaskInfo = pNpc.tbPunishTaskInfo;
    if not tbPunishTaskInfo then
        Log("Error PunishTask StartNotDeathRebirthNpc");   
        return;
    end    

    if tbPunishTaskInfo.nNotDeathTimer then
        Timer:Close(tbPunishTaskInfo.nNotDeathTimer);
        tbPunishTaskInfo.nNotDeathTimer = nil;
    end

    local nTimerFrame = self.nNotDeathRebirthTime * Env.GAME_FPS;
    tbPunishTaskInfo.nNotDeathTimer = Timer:Register(nTimerFrame, self.OnTimerNotDeathRebirthNpc, self, pNpc.nId);
end

function PunishTask:OnTimerNotDeathRebirthNpc(nNpcId)
    local pNpc = KNpc.GetById(nNpcId);
    if not pNpc then
        return;
    end

    local tbPunishTaskInfo = pNpc.tbPunishTaskInfo;
    if not tbPunishTaskInfo then
        Log("Error PunishTask OnTimerNotDeathRebirthNpc");   
        return;
    end  

    self:RemoveMapNpcInfo(tbPunishTaskInfo.nMapID, tbPunishTaskInfo.nIdex);
    pNpc.Delete();
    self:RebirthNpc(tbPunishTaskInfo.nMapID);
    Log("PunishTask OnTimerNotDeathRebirthNpc", tbPunishTaskInfo.nMapID, tbPunishTaskInfo.nIdex);     
end

function PunishTask:StartTimerRebirthNpc(nMapID)
    local nTimerTime = 1;
    local nCurTime = Lib:GetLocalDayTime();
    for _, tbTimeInfo in pairs(self.tbAttackRebirthTime) do
        if tbTimeInfo.tbTime[1] <= nCurTime and nCurTime <= tbTimeInfo.tbTime[2] then
            nTimerTime = tbTimeInfo.nRebirthTime;
            break;
        end    
    end

    local nTimerFrame = nTimerTime * Env.GAME_FPS;
    Timer:Register(nTimerFrame, self.RebirthNpc, self, nMapID);
    Log("PunishTask StartTimerRebirthNpc", nTimerTime, nMapID);  
end

function PunishTask:SendMailAward(nPlayerID, tbAward)
    local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
    if pPlayer then
        for _, tbInfo in pairs(tbAward) do
            if tbInfo[1] == "item" and tbInfo[2] == self.nSpecialItem then
                local szTips = string.format("「%s」獲得了【秘境線索】", pPlayer.szName);
                ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Team, szTips, pPlayer.dwTeamID);
                break;
            end
        end 

        pPlayer.SendAward(tbAward, nil, true, Env.LogWay_PunishTask);
    else    
        local tbMail =
        {
            To = nPlayerID,
            Text = "";
            tbAttach = tbAward,
            nLogReazon = Env.LogWay_PunishTask,
        };

        Mail:SendSystemMail(tbMail);
    end
        
    Log("PunishTask SendMailAward PlayerID", nPlayerID)
end



PunishTask:LoadSetting();

