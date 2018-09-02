Require("CommonScript/Activity/DaXueZhangDef.lua");

local tbDaXueZhang = Activity.tbDaXueZhang;
local tbDef = tbDaXueZhang.tbDef;

tbDaXueZhang.tbAllPreMapLogic = tbDaXueZhang.tbAllPreMapLogic or {};
tbDaXueZhang.tbBasePreMapLogic = tbDaXueZhang.tbBasePreMapLogic or {};
local tbPreMapLogic = tbDaXueZhang.tbBasePreMapLogic;
local tbPreMap = Map:GetClass(tbDef.nPrepareMapTID);

tbDaXueZhang.tbServerPreMapInfo = tbDaXueZhang.tbServerPreMapInfo or {};
tbDaXueZhang.tbApplyPreMapID = tbDaXueZhang.tbApplyPreMapID or {};

function tbPreMap:OnCreate(nMapId)
    tbDaXueZhang:CreatePreMapLogic(nMapId)
    Log("DaXueZhang PreMap OnCreate", nMapId);
end

function tbPreMap:OnDestroy(nMapId)
    tbDaXueZhang:ClosePreMapLogic(nMapId)
    Log("DaXueZhang PreMap OnDestroy", nMapId);
end

function tbPreMap:OnEnter(nMapId)
    local tbPrLogic = tbDaXueZhang:GetPreMapLogic(nMapId);
    if not tbPrLogic then
        return;
    end

    tbPrLogic:OnEnter();
end

function tbPreMap:OnLeave(nMapId)
    local tbPrLogic = tbDaXueZhang:GetPreMapLogic(nMapId);
    if not tbPrLogic then
        return;
    end

    tbPrLogic:OnLeave();
end

function tbPreMap:OnLogin(nMapId)
    local tbPrLogic = tbDaXueZhang:GetPreMapLogic(nMapId);
    if not tbPrLogic then
        return;
    end

    tbPrLogic:OnLogin();
end    

function tbDaXueZhang:GetServerPreMapInfo(nConnectIdx)
    local tbInfo = self.tbServerPreMapInfo[nConnectIdx];
    if not tbInfo then
        tbInfo = 
        {
            nMapId = nil;
            bApplyMap = false;
        };

        self.tbServerPreMapInfo[nConnectIdx] = tbInfo;
    end
        
    return tbInfo;    
end

function tbDaXueZhang:CreatePreMapZ()
    local nConnectIdx = Server.nCurConnectIdx;
    local tbMapInfo = self:GetServerPreMapInfo(nConnectIdx);
    if tbMapInfo.bApplyMap then
        Log("Error DaXueZhang CreatePreMapZ ApplyMap", nConnectIdx);
        return;
    end    

    local nMapId = tbMapInfo.nMapId;
    if nMapId then
        self:ClosePreMapLogic(nMapId);
    end 

    tbMapInfo.nMapId = nil;
    tbMapInfo.bApplyMap = true;

    local nCreateMapId = CreateMap(tbDef.nPrepareMapTID);
    self.tbApplyPreMapID[nCreateMapId] = nConnectIdx;
    Log("DaXueZhang CreatePreMapZ", nConnectIdx);
end

function tbDaXueZhang:GetPreMapLogic(nMapId)
    return self.tbAllPreMapLogic[nMapId];
end

function tbDaXueZhang:GetPreMapLogicByConnext(nConnectIdx)
    local tbMapInfo = self:GetServerPreMapInfo(nConnectIdx);
    if not tbMapInfo.nMapId then
        return;
    end

    local tbPrLogic = self:GetPreMapLogic(tbMapInfo.nMapId);
    return tbPrLogic;
end

function tbDaXueZhang:ClosePreMapLogic(nMapId)
    local tbPrLogic = self:GetPreMapLogic(nMapId);
    if not tbPrLogic then
        return;
    end

    tbPrLogic:OnClose();

    if tbPrLogic.nConnectIdx then
        local tbMapInfo = self:GetServerPreMapInfo(tbPrLogic.nConnectIdx);
        if tbMapInfo.nMapId == tbPrLogic.nMapId then
            tbMapInfo.nMapId = nil;
        end
    end

    self.tbAllPreMapLogic[nMapId] = nil;
    Log("DaXueZhang ClosePreMapLogic", nMapId);     
end

function tbDaXueZhang:CreatePreMapLogic(nMapId)
    local nConnectIdx = self.tbApplyPreMapID[nMapId];
    if not nConnectIdx then
        Log("Error DaXueZhang CreatePreMapLogic ConnectIdx", nMapId);
        return;
    end

    self.tbApplyPreMapID[nMapId] = nil;

    local tbPrLogic = self:GetPreMapLogic(nMapId);
    if tbPrLogic then
        Log("Error DaXueZhang CreatePreMapLogic tbPrLogic", nMapId, nConnectIdx);
        return;
    end

    tbPrLogic = Lib:NewClass(tbPreMapLogic);
    tbPrLogic:OnCreate(nMapId, nConnectIdx);
    self.tbAllPreMapLogic[nMapId] = tbPrLogic;

    local tbMapInfo = self:GetServerPreMapInfo(nConnectIdx);
    tbMapInfo.nMapId = nMapId;
    tbMapInfo.bApplyMap = false;

    CallZoneClientScript(nConnectIdx, "Activity.tbDaXueZhang:SendPreMapIdS", nMapId);
    Log("DaXueZhang CreatePreMapLogic PrLogic", nMapId, nConnectIdx);
end


function tbDaXueZhang:SendSyncPlayerTeamZ(tbSyncPlayer)
    local nConnectIdx = Server.nCurConnectIdx;
    local tbPrLogic = self:GetPreMapLogicByConnext(nConnectIdx);
    if not tbPrLogic then
        Log("Error DaXueZhang SendSyncPlayerTeamZ", nConnectIdx);
        return;
    end

    tbPrLogic:SetPlayerEnterTeam(tbSyncPlayer);
end

function tbDaXueZhang:KickOutPlayerOnZoneZ(nPlayerID)
    local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
    if not pPlayer then
        return;
    end

    pPlayer.ZoneLogout();
    Log("DaXueZhang KickOutPlayerOnZoneZ", Server.nCurConnectIdx, pPlayer.nZoneIndex, nPlayerID);    
end

function tbDaXueZhang:ReducePlayerCount(pPlayer, nCount)
    local nConnectIdx = pPlayer.nZoneIndex;
    
    CallZoneClientScript(nConnectIdx, "Activity.tbDaXueZhang:ReducePlayerCountS", pPlayer.dwID, nCount);
end

function tbDaXueZhang:UpdateNormalKinName(pPlayer)
    Timer:Register(2, self.OnUpdateNormalKinName, self, pPlayer.dwID);
end

function tbDaXueZhang:OnUpdateNormalKinName(nPlayerID)
    local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
    if not pPlayer then
        return;
    end

    local KinMgr = GetKinMgr();
    local szTitle = KinMgr.GetTitle(pPlayer.dwID) or "";
    if pPlayer.dwKinId ~= 0 and not Lib:IsEmptyStr(szTitle) then
        local szKinName = string.match(szTitle, "^［.*服］(.+)$");
        if szKinName then
            szKinName = string.format("%s%s", "［幫派］", szKinName);
        else
            szKinName = szTitle;    
        end

        Kin:SyncTitle(pPlayer.dwID, szKinName)
    end    
end


function tbPreMapLogic:OnCreate(nMapId, nConnectIdx)
    self.nMapId = nMapId;
    self.nConnectIdx = nConnectIdx;
    self.tbEnterTeam = {};
    self.tbSyncPlayerInfo = {};
    self.tbApplyAllTeam = {};
    self.tbAllFightTeam = {};
    self.tbAllPlayerInfo = {};
    self.nNextFightTeamID = 1;
    self.tbTeamToFightID = {};

    self.nStatePos = 0;
    self.nApplyPlayerCount = 0;
    self.tbAllMatchTeamPlay = {};

    self:OnExecuteState();
    Log("DaXueZhang PreMapLogic OnCreate", nMapId, nConnectIdx);
end

function tbPreMapLogic:GetFightTeamInfo(nTeamID)
    local tbInfo = self.tbAllFightTeam[nTeamID];
    if not tbInfo then
        tbInfo = 
        {
            nTeamId = 0;
            tbAllMember = {};
        };

        self.tbAllFightTeam[nTeamID] = tbInfo;
    end

    return tbInfo;    
end

function tbPreMapLogic:GetPlayerInfo(nPlayerID)
    local tbInfo = self.tbAllPlayerInfo[nPlayerID];
    if not tbInfo then
        tbInfo = 
        {
            nFightTeamId = 0;
            nZoneIndex   = 0;
        };

        self.tbAllPlayerInfo[nPlayerID] = tbInfo;
    end

    return tbInfo;    
end

function tbPreMapLogic:OnClose()
    self:KickOutAllPlayer();

    if self.nExecuteStateTimer then
        Timer:Close(self.nExecuteStateTimer);
        self.nExecuteStateTimer = nil;
    end 
end

function tbPreMapLogic:OnEnter()
    local tbPlayerInfo = self:GetPlayerInfo(me.dwID);
    tbPlayerInfo.nZoneIndex = me.nZoneIndex;
    tbPlayerInfo.nFightTeamId = 0;

    self:PlayerApplyPlay(me);
    self:UpdatePlayerRightMsg(me);
    self:UpdatePlayerUI(me);
    tbDaXueZhang:UpdateNormalKinName(me);
    Log("DaXueZhang PreMapLogic OnEnter", me.dwID, me.dwKinId);
end

function tbPreMapLogic:OnLeave()
    self:RemoveApplyPlay(me);
    me.nCanLeaveMapId = nil;
    self.tbAllPlayerInfo[me.dwID] = nil;
    tbDaXueZhang:UpdateNormalKinName(me);

    Log("DaXueZhang PreMapLogic OnEnter", me.dwID);
end

function tbPreMapLogic:OnLogin()
    self:UpdatePlayerRightMsg(me);
    self:UpdatePlayerUI(me);

    Log("DaXueZhang PreMapLogic OnLogin", me.dwID, me.dwKinId);
end

function tbPreMapLogic:RemoveApplyPlay(pPlayer)
    local nOrgTeamID = pPlayer.dwTeamID;
    local tbPlayerInfo = self:GetPlayerInfo(pPlayer.dwID);

    if tbPlayerInfo.nFightTeamId > 0 then
        self:RemoveApplyTeamID(tbPlayerInfo.nFightTeamId, pPlayer.dwID);
    end
        
    if not pPlayer.bDXZQuict and pPlayer.dwTeamID > 0 then
        TeamMgr:QuiteTeam(pPlayer.dwTeamID, pPlayer.dwID);
    end

    pPlayer.bDXZQuict = nil;    

    self.nApplyPlayerCount = self.nApplyPlayerCount - 1;

    Log("DaXueZhang RemoveApplyPlay", self.nMapId, pPlayer.dwID, nOrgTeamID);   
end

function tbPreMapLogic:PlayerApplyPlay(pPlayer, nEnterTeamId)
    if pPlayer.dwTeamID > 0 then
        TeamMgr:QuiteTeam(pPlayer.dwTeamID, pPlayer.dwID);
        Log("Error DaXueZhang PreMapLogic QuiteTeam", self.nMapId, pPlayer.dwID);
    end    

    local tbSyncPlayer = self:GetSyncPlayerInfo(pPlayer.dwID);
    if (tbSyncPlayer and tbSyncPlayer.nServerTeamId > 0) or nEnterTeamId then
        local bCreateTeam = true;
        local bAddEnterTeam = false;
        if not nEnterTeamId then
            nEnterTeamId = self:GetEnterTeamId(tbSyncPlayer.nServerTeamId);
            bAddEnterTeam = true;
        end
            
        if nEnterTeamId and nEnterTeamId > 0 then
            local bAddTeamMember = true;
            local nFightTeamID1 = self.tbTeamToFightID[nEnterTeamId];
            if nFightTeamID1 then
                local tbFightTeam1 = self:GetFightTeamInfo(nFightTeamID1);
                local nCount1 = Lib:CountTB(tbFightTeam1.tbAllMember);
                if nCount1 >= tbDef.nTeamCount then
                    bAddTeamMember = false;
                    Log("Error DaXueZhang PreMapLogic DirectAddMember AddTeamMember", self.nMapId, pPlayer.dwID);
                end    
            end    

            local tbTeam = TeamMgr:GetTeamById(nEnterTeamId);
            if tbTeam and bAddTeamMember then
                local tbMember  = tbTeam:GetMembers();
                local nMemberCount = Lib:CountTB(tbMember);
                if nMemberCount < tbDef.nTeamCount then
                    local nCaptainId = tbTeam:GetCaptainId();
                    local bRet = TeamMgr:DirectAddMember(nCaptainId, pPlayer);
                    if not bRet then
                        Log("Error DaXueZhang PreMapLogic DirectAddMember", self.nMapId, pPlayer.dwID);
                    end
                else
                    bCreateTeam = false;    
                end    
            end   
        end

        if pPlayer.dwTeamID <= 0 and bCreateTeam then
            TeamMgr:Create(pPlayer.dwID, pPlayer.dwID);

            if bAddEnterTeam then
                self.tbEnterTeam[tbSyncPlayer.nServerTeamId] = pPlayer.dwTeamID;
            end    
        end      
    end

    local nFightTeamID = self.tbTeamToFightID[pPlayer.dwTeamID];
    if not nFightTeamID then
        self.nNextFightTeamID = self.nNextFightTeamID + 1;
        nFightTeamID = self.nNextFightTeamID;

        local tbFightTeam = self:GetFightTeamInfo(nFightTeamID);
        tbFightTeam.nTeamId = pPlayer.dwTeamID;

        if pPlayer.dwTeamID > 0 then
            self.tbTeamToFightID[pPlayer.dwTeamID] = nFightTeamID;
        end
    end
          
    self:AddApplyTeamID(nFightTeamID, pPlayer.dwID);
    self.nApplyPlayerCount = self.nApplyPlayerCount + 1;
    Log("DaXueZhang PlayerApplyPlay", self.nMapId, pPlayer.dwID, pPlayer.dwTeamID); 
end

function tbPreMapLogic:GetApplyAllTeam(nCount)
    local tbTeamCount = self.tbApplyAllTeam[nCount];
    if not tbTeamCount then
        tbTeamCount = {};
        self.tbApplyAllTeam[nCount] = tbTeamCount;
    end

    return tbTeamCount;    
end

function tbPreMapLogic:AddApplyTeamID(nTeamId, nPlayerID)
    local tbPlayerInfo = self:GetPlayerInfo(nPlayerID);
    tbPlayerInfo.nFightTeamId = nTeamId;

    local tbFightTeam = self:GetFightTeamInfo(nTeamId);
    local tbMember = tbFightTeam.tbAllMember;
    local nCurCount = Lib:CountTB(tbMember);
    if nCurCount >= tbDef.nTeamCount or tbMember[nPlayerID] then
        Log("DaXueZhang AddApplyTeamID", self.nMapId, nTeamId, nPlayerID);
        return;
    end    

    if nCurCount > 0 then
        local tbTeamCount = self:GetApplyAllTeam(nCurCount);
        tbTeamCount[nTeamId] = nil;
    end

    local nTeamCount = nCurCount + 1;
    local tbCurTeamCount = self:GetApplyAllTeam(nTeamCount);
    tbCurTeamCount[nTeamId] = 1;
    tbFightTeam.tbAllMember[nPlayerID] = 1;
end

function tbPreMapLogic:RemoveApplyTeamID(nTeamId, nPlayerID)
    local tbPlayerInfo = self:GetPlayerInfo(nPlayerID);
    tbPlayerInfo.nFightTeamId = 0;

    local tbFightTeam = self:GetFightTeamInfo(nTeamId);
    local tbMember = tbFightTeam.tbAllMember;
    local nTeamCount = Lib:CountTB(tbMember);
    if nTeamCount <= 0 or not tbMember[nPlayerID] then
        Log("DaXueZhang RemoveApplyTeamID", self.nMapId, nTeamId, nPlayerID);
        return;
    end    

    local tbTeamCount = self:GetApplyAllTeam(nTeamCount);
    tbTeamCount[nTeamId] = nil;

    local nCurCount = nTeamCount - 1;
    if nCurCount > 0 then
        local tbCurTeamCount = self:GetApplyAllTeam(nCurCount);
        tbCurTeamCount[nTeamId] = 1; 
    end

    tbFightTeam.tbAllMember[nPlayerID] = nil;
    if nCurCount <= 0 then

        local nTrueTeamID = tbFightTeam.nTeamId;
        if nTrueTeamID > 0 then
            self.tbTeamToFightID[nTrueTeamID] = nil;
        end

        self.tbAllFightTeam[nTeamId] = nil;
    end 
end

function tbPreMapLogic:GetEnterTeamId(nServerTeamId)
    return self.tbEnterTeam[nServerTeamId];
end

function tbPreMapLogic:GetSyncPlayerInfo(nPlayerID)
    return self.tbSyncPlayerInfo[nPlayerID];
end

function tbPreMapLogic:SetPlayerEnterTeam(tbSyncPlayer)
    for nPlayerID, tbInfo in pairs(tbSyncPlayer) do
        local tbPlayerInfo = {};
        tbPlayerInfo.nServerTeamId = tbInfo.nTeamId;
        self.tbSyncPlayerInfo[nPlayerID] = tbPlayerInfo;
    end    
end

function tbPreMapLogic:GetPlayGameState(nState)
    return tbDef.tbPreMapState[nState];
end

function tbPreMapLogic:OnExecuteState()
    if self.nExecuteStateTimer then
        Timer:Close(self.nExecuteStateTimer);
        self.nExecuteStateTimer = nil;
    end 

    self.nStatePos = self.nStatePos + 1;
    local nCurStatePos = self.nStatePos;
    local tbStateInfo = self:GetPlayGameState(self.nStatePos);
    local nNextTime  = -1;
    if tbStateInfo then  
        local FunBack = nil;
        if not Lib:IsEmptyStr(tbStateInfo.szCall) then
            FunBack = self["On"..tbStateInfo.szCall];
        end

        if FunBack then
            FunBack(self, self.nStatePos); 
        end

        nNextTime = tbStateInfo.nNextTime;
    end    

    if nNextTime > 0 and self.nExecuteStateTimer == nil and nCurStatePos == self.nStatePos then
        self.nExecuteStateTimer = Timer:Register(nNextTime * Env.GAME_FPS, self.OnExecuteState, self);
        self:ForeachAllPlayer({self.UpdatePlayerRightMsg, self});
    end

    Log("DaXueZhang PreMapLogic OnExecuteState", nCurStatePos, self.nStatePos);    
end

function tbPreMapLogic:GetExecuteStateTime()
    if not self.nExecuteStateTimer then
        return 0;
    end    

    local nTime = math.floor(Timer:GetRestTime(self.nExecuteStateTimer) / Env.GAME_FPS);
    return nTime;
end

function tbPreMapLogic:UpdatePlayerRightMsg(pPlayer)
    local tbStateInfo = self:GetPlayGameState(self.nStatePos);
    if not tbStateInfo then
        return;
    end

    local nTime = self:GetExecuteStateTime();
    local tbShowInfo = {}
    tbShowInfo.nTime = nTime;
    tbShowInfo.szShow = tbStateInfo.szRMsg;
    tbShowInfo.nMapTID = pPlayer.nMapTemplateId;
    pPlayer.CallClientScript("Ui:OpenWindow", "HSLJBattleInfo", "ShowInfo", tbShowInfo);
end

function tbPreMapLogic:UpdatePlayerUI(pPlayer)
    pPlayer.CallClientScript("Player:ServerSyncData", "HomeBtnTast", {nMapTID = pPlayer.nMapTemplateId});

    pPlayer.nCanLeaveMapId = pPlayer.nMapId;
    pPlayer.CallClientScript("Ui:OpenWindow", "QYHLeavePanel");
    pPlayer.CallClientScript("Map:SetCloseUiOnLeave", pPlayer.nMapId, "QYHLeavePanel");   
end

function tbPreMapLogic:OnFreedom(nStatePos)
    
    Log("DaXueZhang PreMapLogic OnFreedom", self.nMapId, nStatePos);
end

function tbPreMapLogic:OnStartPlay(nStatePos)
    self:MatchingAllTeam();
    self:MatchingAllTeamToPK();
    self:MatchingAllTeamEmply();
    Log("DaXueZhang PreMapLogic OnStartPlay", self.nMapId, nStatePos);
end

function tbPreMapLogic:OnGameEnd(nStatePos)
    self:KickOutAllPlayer();
    Log("DaXueZhang PreMapLogic OnStartPlay", self.nMapId, nStatePos);
end

function tbPreMapLogic:PlayerKickOut(pPlayer)
    pPlayer.ZoneLogout() 
end

function tbPreMapLogic:KickOutAllPlayer()
    self:ForeachAllPlayer({self.PlayerKickOut, self});
end

function tbPreMapLogic:ForeachAllPlayer(tbCallBack)
    local tbPlayer = KPlayer.GetMapPlayer(self.nMapId);
    if not tbPlayer then
        return;
    end

    for _, pPlayer in pairs(tbPlayer) do
        Lib:MergeCallBack(tbCallBack, pPlayer);
    end
end


function tbPreMapLogic:MatchingAllTeam()
    local nMinMatchCount = tbDef.nTeamCount * tbDef.nMaxTeamVS;
    if self.nApplyPlayerCount < nMinMatchCount then
        return;
    end

    self:CombinationAllTeam();

    Log("-------DaXueZhang MatchingAllTeam Start----------", self.nMapId);
    Lib:LogTB(self.tbApplyAllTeam);
    Log("-------DaXueZhang MatchingAllTeam End----------", self.nMapId);

end

function tbPreMapLogic:MatchingAllTeamEmply()
    for nTeam = tbDef.nTeamCount, 1, -1 do
        local tbTeamCount = self:GetApplyAllTeam(nTeam); 
        for nId, _ in pairs(tbTeamCount) do
            if nTeam ~= tbDef.nTeamCount or not self.tbAllMatchTeamPlay[nId] then
                self:ForeachTeamPlayer(nId, {self.SendPlayerMsg, self, tbDef.szMatchEmpyMsg});
            end    
        end    
    end 
end

function tbPreMapLogic:SendPlayerMsg(szMsg, pPlayer)
    pPlayer.CenterMsg(szMsg, true);
end

function tbPreMapLogic:ForeachTeamPlayer(nId, tbCallBack)
    local tbFightTeam = self:GetFightTeamInfo(nId);
    for nPlayerID, _ in pairs(tbFightTeam.tbAllMember) do
        local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
        if pPlayer and pPlayer.nMapId == self.nMapId then
            Lib:MergeCallBack(tbCallBack, pPlayer);
        end    
    end    
end

function tbPreMapLogic:MatchingAllTeamToPK()
    self.tbAllMatchTeamPlay = {};
    local tbTeamCount = self:GetApplyAllTeam(tbDef.nTeamCount);
    local tbTeamID = {};
    for nId, _ in pairs(tbTeamCount) do
        if not self.tbAllMatchTeamPlay[nId] then
            tbTeamID[nId] = 1;

            local nCount = Lib:CountTB(tbTeamID);
            if nCount == tbDef.nMaxTeamVS then
                for nId, _ in pairs(tbTeamID) do
                    self.tbAllMatchTeamPlay[nId] = 1;
                end

                self:CreateMatchingTeamMap(tbTeamID);
                tbTeamID = {};
            end
        end        
    end       
end

function tbPreMapLogic:CreateMatchingTeamMap(tbTeamID)
    local nCreatePlayer = nil;
    local tbTeamAllPlayer = {};
    for nTeamID, _ in pairs(tbTeamID) do
        local tbFightTeam = self:GetFightTeamInfo(nTeamID);
        local tbAllPlayer = {};
        local tbAllMember = tbFightTeam.tbAllMember;
        for nPlayerID, _ in pairs(tbAllMember) do
            local pMember = KPlayer.GetPlayerObjById(nPlayerID);
            if not pMember then
                Log("Error DaXueZhang Member CreateMatchingTeamMap", nTeamID, nPlayerID);
                return;
            end

            tbAllPlayer[nPlayerID] = 1;

            if not nCreatePlayer then
                nCreatePlayer = nPlayerID;
            end    
        end    

        table.insert(tbTeamAllPlayer, tbAllPlayer);
    end

    if not nCreatePlayer then
        return;
    end    

    local fnSuccess = function (nMapId)
        self:SendTeamPlayerMap(nMapId, tbTeamAllPlayer);
    end

    local fnFailed = function ()
        Log("Error DaXueZhang CreateMatchingTeamMap fnFailed", nCreatePlayer);    
    end

    Fuben:ApplyFuben(nCreatePlayer, tbDef.nPlayMapTID, fnSuccess, fnFailed, tbTeamAllPlayer);
end

function tbPreMapLogic:SendTeamPlayerMap(nMapId, tbTeamAllPlayer)
    for _, tbAllPlayer in pairs(tbTeamAllPlayer) do
        for nPlayerID, _ in pairs(tbAllPlayer) do
            local pMember = KPlayer.GetPlayerObjById(nPlayerID);
            if pMember then
                tbDaXueZhang:ReducePlayerCount(pMember, -1);
                pMember.bDXZQuict = true;
                pMember.SwitchMap(nMapId, 10, 10);
                Log("DaXueZhang SendTeamPlayerMap", nPlayerID, nMapId);  
            else
                Log("Error DaXueZhang SendTeamPlayerMap", nPlayerID, nMapId);    
            end
        end    
    end    
end


function tbPreMapLogic:CombinationAllTeam()
    local nStartTeam = tbDef.nTeamCount - 1;
    for nTeamCount = nStartTeam, 1, -1 do
        local tbMatch = tbDef.tbMatchingCount[nTeamCount];
        if tbMatch then
            for _, nCount in ipairs(tbMatch) do
                self:CombinationTeamCount(nTeamCount, nCount);
            end
        end        
    end    
end

function tbPreMapLogic:CombinationTeamCount(nTeamCount, nFindCount)
    local tbTeamCount = self:GetApplyAllTeam(nTeamCount);
    if not Lib:HaveCountTB(tbTeamCount) then
        return;
    end

    local tbFindTeam = self:GetApplyAllTeam(nFindCount);
    if not Lib:HaveCountTB(tbFindTeam) then
        return;
    end

    local nNeedCount = math.floor((tbDef.nTeamCount - nTeamCount) / nFindCount);
    if nNeedCount <= 0 then
        Log("Error DaXueZhang CombinationTeamCount", self.nMapId, nTeamCount, nFindCount, nNeedCount);
        return;
    end    

    while true do
        local nTeamID = nil;
        for nId, _ in pairs(tbTeamCount) do
            nTeamID = nId;
            break;
        end

        if not nTeamID then
            return;
        end

        local nTeamKinId = self:GetApplyTeamKinID(nTeamID);
        local tbFindID = self:FindCombinationTeam(tbFindTeam, nTeamKinId, nNeedCount, nTeamID);
        if not tbFindID then
            return;
        end    

        local bRet = self:AddCombinationApplyTeam(nTeamID, tbFindID);
        if not bRet then
            Log("Error DaXueZhang CombinationTeamCount AddCombinationApplyTeam", nTeamID);
            return;
        end    
    end

    Log("DaXueZhang CombinationTeamCount", nTeamID, nFindCount);   
end

function tbPreMapLogic:AddCombinationApplyTeam(nTeamID, tbFindID)
    local tbFightTeam = self:GetFightTeamInfo(nTeamID);
    local nTrueTeamId = tbFightTeam.nTeamId;
    if nTrueTeamId <= 0 then
        local tbCopyMember = Lib:CopyTB1(tbFightTeam.tbAllMember);
        local nCurCount = Lib:CountTB(tbCopyMember);
        if nCurCount ~= 1 then
            return;
        end    

        for nPlayerID, _ in pairs(tbCopyMember) do
            local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
            if pPlayer then
                self:RemoveApplyPlay(pPlayer);
                self:PlayerApplyPlay(pPlayer, 0);
                nTrueTeamId = pPlayer.dwTeamID;
                break;
            end
        end

    end
    
    if nTrueTeamId <= 0 then
        Log("DaXueZhang AddCombinationApplyTeam", self.nMapId, nTeamID);
        return;
    end    

    for nId, _ in pairs(tbFindID) do
        local tbCurFightTeam = self:GetFightTeamInfo(nId);
        local tbCopyMember = Lib:CopyTB1(tbCurFightTeam.tbAllMember);
        for nPlayerID, _ in pairs(tbCopyMember) do
            local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
            if pPlayer then
                self:RemoveApplyPlay(pPlayer);
                self:PlayerApplyPlay(pPlayer, nTrueTeamId);
            end    
        end    
    end

    local nFightTeamID = self.tbTeamToFightID[nTrueTeamId];
    tbFightTeam = self:GetFightTeamInfo(nFightTeamID);
    local nCount = Lib:CountTB(tbFightTeam.tbAllMember);
    if nCount ~= tbDef.nTeamCount then
        return;
    end

    return true;    
end

function tbPreMapLogic:FindCombinationTeam(tbFindTeam, nFindKinID, nFindCount, nTeamID)
    local tbFindID = {};
    for nId, _ in pairs(tbFindTeam) do
        local nKindId = self:GetApplyTeamKinID(nId);
        if nTeamID ~= nId and not tbFindID[nId] and (nKindId == nFindKinID or nFindKinID == 0) then
            tbFindID[nId] = 1;
            nFindCount = nFindCount - 1;

            if nFindCount <= 0 then
                return tbFindID;
            end    
        end    
    end

    for nId, _ in pairs(tbFindTeam) do
        if not tbFindID[nId] and nTeamID ~= nId then
            tbFindID[nId] = 1;
            nFindCount = nFindCount - 1;

            if nFindCount <= 0 then
                return tbFindID;
            end    
        end    
    end

    return;   
end

function tbPreMapLogic:GetApplyTeamKinID(nId)
    local tbFightTeam = self:GetFightTeamInfo(nId);
    if tbFightTeam.nTeamId > 0 then
        local tbTeam = TeamMgr:GetTeamById(tbFightTeam.nTeamId);
        if tbTeam then
            local nCaptainId = tbTeam:GetCaptainId();
            local pCaptain = KPlayer.GetPlayerObjById(nCaptainId);
            if pCaptain then
                return pCaptain.dwKinId;
            end  
        end    
    end    

    for nPlayerID, _ in pairs(tbFightTeam.tbAllMember) do
        local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
        if pPlayer then
            return pPlayer.dwKinId;
        end    
    end

    return 0;  
end


