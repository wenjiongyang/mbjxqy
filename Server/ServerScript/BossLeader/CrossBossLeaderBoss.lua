
Require("ServerScript/BossLeader/BossLeader.lua");
BossLeader.tbCrossBossAllInfo = BossLeader.tbCrossBossAllInfo or {};

BossLeader.tbCrossBossDataInfo = BossLeader.tbCrossBossDataInfo or {};
BossLeader.tbCrossBossMapInfo = BossLeader.tbCrossBossMapInfo or {};

function BossLeader:CheckServerCrossBossInfoZ()
    self.tbCrossBossAllInfo.tbServerInfo = {};
    self.tbCrossBossAllInfo.tbKinInfo = {};
    self.tbCrossBossAllInfo.tbTimeFrame = {};
    self.tbCrossBossAllInfo.tbPlayerInfo = {};

    CallZoneClientScript(-1, "BossLeader:CheckServerCrossBossInfo");
    Log("BossLeader CheckServerCrossBossInfoZ");
end

function BossLeader:GetCrossBossServerInfo()
    if not self.tbCrossBossAllInfo.tbServerInfo then
        self.tbCrossBossAllInfo.tbServerInfo = {};
    end

    return self.tbCrossBossAllInfo.tbServerInfo;
end

function BossLeader:GetCrossBossKinInfo(nKinId)
    if not self.tbCrossBossAllInfo.tbKinInfo then
        self.tbCrossBossAllInfo.tbKinInfo = {};
    end

    local tbInfo = self.tbCrossBossAllInfo.tbKinInfo[nKinId];
    if not tbInfo then
        tbInfo = {};
        self.tbCrossBossAllInfo.tbKinInfo[nKinId] = tbInfo;
    end

    return tbInfo;
end

function BossLeader:GetCrossBossTimeFrame()
    if not self.tbCrossBossAllInfo.tbTimeFrame then
        self.tbCrossBossAllInfo.tbTimeFrame = {};
    end

    return self.tbCrossBossAllInfo.tbTimeFrame;
end

function BossLeader:GetCrossBossPlayerInfo(nPlayerID)
    if not self.tbCrossBossAllInfo.tbPlayerInfo then
        self.tbCrossBossAllInfo.tbPlayerInfo = {};
    end

    local tbInfo = self.tbCrossBossAllInfo.tbPlayerInfo[nPlayerID];
    if not tbInfo then
        tbInfo = {};
        self.tbCrossBossAllInfo.tbPlayerInfo[nPlayerID] = tbInfo;
    end

    return tbInfo;
end

function BossLeader:CrossPlayerLoginMap(pPlayer)
    if not MODULE_ZONESERVER then
        return;
    end

    pPlayer.CallClientScript("Player:ServerSyncData", "HomeBtnTast", {nMapTID = pPlayer.nMapTemplateId});
    pPlayer.CallClientScript("Player:ServerSyncData", "ForbidTeamAllInfo", pPlayer.nMapTemplateId);
    pPlayer.CallClientScript("Player:ServerSyncData", "ForbidTeamSelectPopCaptain", pPlayer.nMapTemplateId);


    local tbPlayerInfo = self:GetCrossBossPlayerInfo(pPlayer.dwID);
    local tbTeamInfo = tbPlayerInfo.tbTeamInfo;
    if tbTeamInfo then
        pPlayer.CallClientScript("TeamMgr:SyncAsyncMember", tbTeamInfo.tbAsyncMember);
        pPlayer.CallClientScript("TeamMgr:SetAsyncMapTID", pPlayer.nMapTemplateId);
    end  
end

function BossLeader:CrossPlayerEnterMap(pPlayer)
    if not MODULE_ZONESERVER then
        return;
    end

    local tbPlayerInfo = self:GetCrossBossPlayerInfo(pPlayer.dwID);
    tbPlayerInfo.nZoneIndex = pPlayer.nZoneIndex;

    if pPlayer.dwKinId > 0 then
        local tbKinInfo = self:GetCrossBossKinInfo(pPlayer.dwKinId);
        tbKinInfo.nZoneIndex = pPlayer.nZoneIndex;
    end

    local nCurMapId, nPosX, nPosY = pPlayer.GetWorldPos();
    pPlayer.SetTempRevivePos(nCurMapId, nPosX, nPosY, 0);
    --pPlayer.nInBattleState = 1; --战场模式
    pPlayer.bSelfAutoRevive = true;
    self:CheckHorseEquip(pPlayer);
    pPlayer.CallClientScript("Player:ServerSyncData", "HomeBtnTast", {nMapTID = pPlayer.nMapTemplateId});
    pPlayer.CallClientScript("Player:ServerSyncData", "ForbidTeamAllInfo", pPlayer.nMapTemplateId);
    pPlayer.CallClientScript("Player:ServerSyncData", "ForbidTeamSelectPopCaptain", pPlayer.nMapTemplateId);
    self:PlayerCreateCrossTeam(pPlayer);
    pPlayer.CallClientScript("TeamMgr:SetAsyncMapTID", pPlayer.nMapTemplateId);
end

function BossLeader:OnCrossPlayerDeath(pPlayer, pKiller)
    if not MODULE_ZONESERVER then
        return;
    end

    pPlayer.Revive(0);
    pPlayer.nFightMode = 0;
end

function BossLeader:PlayerCreateCrossTeam(pPlayer)
    if pPlayer.dwTeamID > 0 then
        return;
    end

    local tbPlayerInfo = self:GetCrossBossPlayerInfo(pPlayer.dwID);
    local tbTeamInfo = tbPlayerInfo.tbTeamInfo;
    if not tbTeamInfo then
        return;
    end  

    if not tbTeamInfo.tbMember or not Lib:HaveCountTB(tbTeamInfo.tbMember) then
        return;
    end

    local nTeamId = nil;
    for nPlayerID, _ in pairs(tbTeamInfo.tbMember) do
        local pMember = KPlayer.GetPlayerObjById(nPlayerID);
        if pMember and pMember.dwTeamID > 0 then
            nTeamId = pMember.dwTeamID;
        end
    end

    if not nTeamId then
        TeamMgr:Create(pPlayer.dwID, pPlayer.dwID);
        pPlayer.CallClientScript("TeamMgr:SyncAsyncMember", tbTeamInfo.tbAsyncMember);
        return;
    end

    local tbTeam = TeamMgr:GetTeamById(nTeamId);
    if not tbTeam then
        return;
    end

    local nCaptainId = tbTeam:GetCaptainId();
    TeamMgr:DirectAddMember(nCaptainId, pPlayer);

    if nCaptainId ~= tbTeamInfo.nCaptainId and tbTeamInfo.nCaptainId == pPlayer.dwID then
        tbTeam:ChangeCaptain(pPlayer.dwID);
    end
    pPlayer.CallClientScript("TeamMgr:SyncAsyncMember", tbTeamInfo.tbAsyncMember);
end

function BossLeader:CrossPlayerLeaveMap(pPlayer)
    if not MODULE_ZONESERVER then
        return;
    end

    pPlayer.bSelfAutoRevive = nil;
    pPlayer.ClearTempRevivePos();
end

function BossLeader:CheckHorseEquip(pPlayer)
    if not MODULE_ZONESERVER then
        return;
    end

    local pEquip = pPlayer.GetEquipByPos(Item.EQUIPPOS_HORSE);
    if pEquip then
        return;
    end

    pPlayer.ResetAsyncExtEquip(Item.EQUIPPOS_HORSE);
end

function BossLeader:GetPlayerConnectIndex(nPlayerID)
    if not MODULE_ZONESERVER then
        return;
    end

    local tbPlayerInfo = self:GetCrossBossPlayerInfo(nPlayerID);
    return tbPlayerInfo.nZoneIndex;
end

function BossLeader:GetKinConnectIndex(nKinId)
    if not MODULE_ZONESERVER then
        return;
    end

    local tbKinInfo = self:GetCrossBossKinInfo(nKinId);
    return tbKinInfo.nZoneIndex;
end

function BossLeader:CheckServerCrossBossInfo()
    Log("BossLeader CheckServerCrossBossInfo");
    local tbAllTimeNpc = self.tbCrossMainSetting["Boss"];
    if not tbAllTimeNpc then
        return;
    end

    local szCurTimeFrame = Lib:GetMaxTimeFrame(tbAllTimeNpc);
    if Lib:IsEmptyStr(szCurTimeFrame) then
        return;
    end

    self:UpdateCrossSortKinJiFen();

    self.tbCrossBossMapInfo = {};
    self.tbCrossBossDataInfo = {};
    self.tbCrossBossDataInfo.nTime = GetTime();
    self.tbCrossBossDataInfo.bOpenCross = false;
    self.tbCrossBossDataInfo.bCrossIng = false;
    self.tbCrossBossDataInfo.tbAllKinTotalValue = {};
    self.tbCrossBossDataInfo.tbKinAuctionItem = {};

    local tbSaveData = self:GetCrossAllKinSaveData();
    local tbAllKinInfo = {};
    for nKinId, _ in pairs(tbSaveData.tbCan) do
        local tbKinData = Kin:GetKinById(nKinId);
        if tbKinData then
            tbAllKinInfo[nKinId] = {};
            tbAllKinInfo[nKinId].nServerIdx = GetServerListIndex();
            tbAllKinInfo[nKinId].szName = tbKinData.szName;
        end
    end

    CallZoneServerScript("BossLeader:SetServerCrossBossInfoZ", szCurTimeFrame, tbAllKinInfo);
    Log("BossLeader CheckServerCrossBossInfo Ext");
end

function BossLeader:SetServerCrossBossInfoZ(szTimeFrame, tbAllKinInfo)
    local nConnectIdx = Server.nCurConnectIdx;
    local tbCrossInfo = {};
    tbCrossInfo.szTimeFrame = szTimeFrame;
    local tbServerInfo = self:GetCrossBossServerInfo();
    tbServerInfo[nConnectIdx] = tbCrossInfo;

    local tbCrossTimeFrame = self:GetCrossBossTimeFrame();
    tbCrossTimeFrame[szTimeFrame] = tbCrossTimeFrame[szTimeFrame] or {};
    tbCrossTimeFrame[szTimeFrame][nConnectIdx] = 1;

    for nKinId, tbInfo in pairs(tbAllKinInfo) do
        local tbKinInfo = self:GetCrossBossKinInfo(nKinId);
        tbKinInfo.nZoneIndex = nConnectIdx;
        tbKinInfo.szName = tbInfo.szName;
        tbKinInfo.nServerIdx = tbInfo.nServerIdx;
    end

    Log("BossLeader SetServerCrossBossInfoZ", nConnectIdx, szTimeFrame);
end

function BossLeader:PreStartCrossBossZ()
    local tbServerInfo = self:GetCrossBossServerInfo();
    if not Lib:HaveCountTB(tbServerInfo) then
        return;
    end    

    self:PreStartActivity("Boss");

    local tbTimeFrameMapDate = {};
    for nMapTID, tbMapInfo in pairs(self.tbCreateNpcMap) do
        tbTimeFrameMapDate[tbMapInfo.szTimeFrame] = tbTimeFrameMapDate[tbMapInfo.szTimeFrame] or {};
        tbTimeFrameMapDate[tbMapInfo.szTimeFrame][nMapTID] = tbMapInfo.nMapId;
    end

    for nConnectIdx, tbInfo in pairs(tbServerInfo) do
        local tbSendInfo = tbTimeFrameMapDate[tbInfo.szTimeFrame] or {};
        CallZoneClientScript(nConnectIdx, "BossLeader:StartCrossBossServer", tbSendInfo);
    end

    Log("BossLeader PreStartCrossBossZ");   
end

function BossLeader:StartCrossBossZ()
    local tbServerInfo = self:GetCrossBossServerInfo();
    if not Lib:HaveCountTB(tbServerInfo) then
        return;
    end

    self:StartActivity("Boss", 0);

    Log("BossLeader StartCrossBossZ");
end

function BossLeader:EndCrossBossZ()

    self:CloseActivity("Boss");
    self:EndActivityEnter("Boss");

    local tbSyncData = self:GetSyncClientData("Boss");
    local tbServerInfo = self:GetCrossBossServerInfo();
    for nConnectIdx, tbInfo in pairs(tbServerInfo) do
        CallZoneClientScript(nConnectIdx, "BossLeader:EndCrossBossServer", tbSyncData);
    end

    for nPlayerID, _ in pairs(self.tbAllPlayerMapInfo) do
        local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
        if pPlayer then
            pPlayer.ZoneLogout();
        end
    end

    Log("BossLeader EndCrossBossZ");
end

function BossLeader:CloseActivityCrossBossZ()
    if not MODULE_ZONESERVER then
        return;
    end

    local tbServerInfo = self:GetCrossBossServerInfo();
    for nConnectIdx, tbInfo in pairs(tbServerInfo) do
        CallZoneClientScript(nConnectIdx, "BossLeader:CloseActivityCrossBoss");
    end
end

function BossLeader:EndCrossBossServer(tbSyncData)

    self.tbCrossBossMapInfo = {};
    self.tbCrossBossDataInfo.bOpenCross = false;
    self.tbCrossBossDataInfo.tbEndSyncData = tbSyncData;
    Log("BossLeader EndCrossBossServer");
end

function BossLeader:CloseActivityCrossBoss()

    self.tbCrossBossDataInfo.bCrossIng = false;
    Calendar:OnActivityEnd("FieldCrossBoss");
    local szMsg = self.tbEndWorldNotice["Boss"];
    if not Lib:IsEmptyStr(szMsg) then
        KPlayer.SendWorldNotify(1, 999, "【跨服】" .. szMsg, 1, 1);
    end

    Log("BossLeader CloseActivityCrossBoss");
end

function BossLeader:StartCrossBossServer(tbMapDate)
    for nMapTID, nMapId in pairs(tbMapDate) do
        self.tbCrossBossMapInfo[nMapTID] = nMapId;
        Log("BossLeader SetCanCrossServer Map Info", nMapTID, nMapId);

    end

    self.tbCrossBossDataInfo.tbAllKinTotalValue = {};
    self.tbCrossBossDataInfo.tbKinAuctionItem = {};
    self.tbCrossBossDataInfo.bOpenCross = true;
    self.tbCrossBossDataInfo.bCrossIng = true;
    self.tbCrossBossDataInfo.tbEndSyncData = nil;
    self.tbCrossBossDataInfo.nTime = GetTime();
    Calendar:OnActivityBegin("FieldCrossBoss");
    Log("BossLeader StartCrossBossServer");
end

function BossLeader:SendCrossPlayerInfo(pPlayer)
    local nTeamId = pPlayer.dwTeamID;
    local tbTeamInfo = {};
    tbTeamInfo.tbMember = {};
    tbTeamInfo.nCaptainId = 0;
    tbTeamInfo.tbAsyncMember = {};
    if nTeamId > 0 then
        local tbTeam = TeamMgr:GetTeamById(nTeamId);
        if tbTeam then
            tbTeamInfo.nCaptainId = tbTeam:GetCaptainId();
            local tbMember = tbTeam:GetMembers();
            for _, nPlayerID in pairs(tbMember) do
                tbTeamInfo.tbMember[nPlayerID] = nTeamId;
            end

            tbTeamInfo.tbAsyncMember = tbTeam:GetLuaTeamMemberData(pPlayer.dwID);    
        end
    end

    local tbPlayerInfo = {};
    tbPlayerInfo.tbTeamInfo = tbTeamInfo;
    CallZoneServerScript("BossLeader:SendCrossPlayerInfoZ", pPlayer.dwID, tbPlayerInfo);
end

function BossLeader:SendCrossPlayerInfoZ(nPlayerID, tbSendInfo)
    local nConnectIdx = Server.nCurConnectIdx;
    local tbPlayerInfo = self:GetCrossBossPlayerInfo(nPlayerID);
    tbPlayerInfo.nZoneIndex = nConnectIdx;
    tbPlayerInfo.tbTeamInfo = tbSendInfo.tbTeamInfo;

    Log("BossLeader SendCrossPlayerInfoZ", nConnectIdx, nPlayerID);
end

function BossLeader:CrossCalcKinDmgTotalValue(szType, tbKinInfo, tbNpcExtInfo, nJoinCount, nRank)
    Log("BossLeader CrossCalcKinDmgTotalValue", szType, nJoinCount, nRank);
    self.bCalcCross = true;
    Lib:CallBack({self.CalcKinDmgTotalValue, self, szType, tbKinInfo, tbNpcExtInfo, nJoinCount, nRank});
    self.bCalcCross = nil;
    Log("BossLeader CrossCalcKinDmgTotalValue End", szType, nJoinCount, nRank);
end

function BossLeader:CrossSendKinAward(szType, nKinId, tbPlayerIds)
    Log("BossLeader CrossSendKinAward", szType, nKinId);
    self.bCalcCross = true;
    Lib:CallBack({self.SendKinAward, self, szType, nKinId, tbPlayerIds});
    self.bCalcCross = nil;
    Log("BossLeader CrossSendKinAward End", szType, nKinId);
end

function BossLeader:GetCrossKinTotalValue(nKinId)
    local tbAllKinTotalValue = self.tbCrossBossDataInfo.tbAllKinTotalValue;
    if not tbAllKinTotalValue then
        self.tbCrossBossDataInfo.tbAllKinTotalValue = {};
        tbAllKinTotalValue = self.tbCrossBossDataInfo.tbAllKinTotalValue;
    end

    tbAllKinTotalValue[nKinId] = tbAllKinTotalValue[nKinId] or 0;
    return tbAllKinTotalValue[nKinId];
end

function BossLeader:AddCrossKinTotalValueByID(nKinId, nValue)
    local nCurValue = self:GetCrossKinTotalValue(nKinId);
    self.tbCrossBossDataInfo.tbAllKinTotalValue[nKinId] = nCurValue + nValue;
end

function BossLeader:GetCrossKinAuctionInfo(nKindID)
    local tbKinAuctionItem = self.tbCrossBossDataInfo.tbKinAuctionItem;
    if not tbKinAuctionItem then
        self.tbCrossBossDataInfo.tbKinAuctionItem = {};
        tbKinAuctionItem = self.tbCrossBossDataInfo.tbKinAuctionItem;
    end

    tbKinAuctionItem[nKindID] = tbKinAuctionItem[nKindID] or {};
    return tbKinAuctionItem[nKindID];
end

function BossLeader:AddCrossKinAuctionItem(nKindID, nItemTID, nCount)
    if nCount <= 0 then
        return;
    end

    local tbKinAuction = self:GetCrossKinAuctionInfo(nKindID);
    tbKinAuction[nItemTID] = tbKinAuction[nItemTID] or 0;
    tbKinAuction[nItemTID] = tbKinAuction[nItemTID] + nCount;
    Log("BossLeader AddCrossKinAuctionItem", nKindID, nItemTID, nCount);    
end

function BossLeader:HaveCrossBossServer(pPlayer)
    if MODULE_ZONESERVER then
        return false;
    end

    local tbSaveData = self:GetCrossAllKinSaveData();
    if not tbSaveData.tbCan[pPlayer.dwKinId] then
        return false;
    end

    if not BossLeader:IsActOpenCross() then
        return false;
    end

    return true;
end

function BossLeader:CrossClientRequestData(szType, nPlayerID)
    local tbSyncData = self:ClientRequestData(szType);
    if not tbSyncData then
        return;
    end

    CallZoneClientScript(Server.nCurConnectIdx, "BossLeader:PlayerCrossClientRequestData", nPlayerID, szType, tbSyncData);
end

function BossLeader:PlayerCrossClientRequestData(nPlayerID, szType, tbSyncData)
    local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
    if not pPlayer then
        return;
    end

    pPlayer.CallClientScript("BossLeader:OnSyncMapData", szType, tbSyncData);
end


function BossLeader:AddCrossKinJiFen(nKinId, nNpcID, nRank)
    local tbCrossNpc = self:GetCrossKinJiFenNpc();
    if not tbCrossNpc then
        return;
    end

    if not tbCrossNpc[nNpcID] then
        return;
    end

    local nJiFen = self.tbCrossKinJiFenRank[nRank];
    if not nJiFen then
        return;
    end
    
    local tbSaveData = self:GetCrossAllKinSaveData();
    local tbSaveKin = tbSaveData.tbKin;
    tbSaveKin[nKinId] = tbSaveKin[nKinId] or 0;
    tbSaveKin[nKinId] = tbSaveKin[nKinId] + nJiFen;

    Log("BossLeader AddCrossKinJiFen", nKinId, nNpcID, nRank);
end

function BossLeader:GetCrossAllKinSaveData()
    local tbSaveData = ScriptData:GetValue("CrossBossLeaderKin"); 
    local nUpdateTime = self.nCrossDayTime * 24 * 60 * 60;
    local nCurTime = Lib:GetLocalWeek(GetTime() - nUpdateTime);
    if not tbSaveData.nTime or tbSaveData.nTime ~= nCurTime then
        tbSaveData.nTime = nCurTime;
        tbSaveData.tbKin = {};
        tbSaveData.tbCan = {};
        Log("BossLeader GetCrossAllKinSaveData", nCurTime, Lib:GetLocalWeek());
    end

    return tbSaveData;
end

function BossLeader:UpdateCrossSortKinJiFen()
    if not BossLeader:IsActOpenCross() then
        return;
    end

    local tbSaveData = self:GetCrossAllKinSaveData();
    if not Lib:HaveCountTB(tbSaveData.tbKin) then
        return;
    end
    
    if not Lib:HaveCountTB(tbSaveData.tbCan) then
        local tbSortJiFen = {};
        for nKinId, nJiFen in pairs(tbSaveData.tbKin) do
            local tbKinInfo = {};
            tbKinInfo.nKinId = nKinId;
            tbKinInfo.nJiFen = nJiFen;
            Log("BossLeader UpdateCrossSortInsert", tbKinInfo.nKinId, tbKinInfo.nJiFen);
            table.insert(tbSortJiFen, tbKinInfo);
        end

        table.sort(tbSortJiFen, function (a, b)
            return a.nJiFen > b.nJiFen;
        end);

        for nI = 1, self.nCanCrossFront, 1 do
            local tbInfo = tbSortJiFen[nI];
            if tbInfo then
                tbSaveData.tbCan[tbInfo.nKinId] = nI;

                Log("BossLeader UpdateCrossSortKinJiFen", nI, tbInfo.nKinId, tbInfo.nJiFen);
            end    
        end
    end

    Log("BossLeader UpdateCrossSortKinJiFen Ext");
end

function BossLeader:IsActOpenCross()
    if Activity:__IsActInProcessByType("CloseActBLBoss") then
        return false;
    end

    return true;
end

function BossLeader:SendCrossKinMail(bSendWorld)
    local tbSaveData = self:GetCrossAllKinSaveData();
    if not Lib:HaveCountTB(tbSaveData.tbKin) then
        return;
    end

    if not BossLeader:IsActOpenCross() then
        return;
    end

    self:UpdateCrossSortKinJiFen();

    local nWeekDay = Lib:GetLocalWeekDay();
    local nEndTime = 0;
    if nWeekDay > self.nCrossDayTime then
        nEndTime = (7 - nWeekDay + self.nCrossDayTime) * 24 * 60 * 60;    
    end

    local tbTime = os.date("*t", GetTime());
    local nCurTime = os.time({year = tbTime.year, month = tbTime.month, day = tbTime.day, hour = 0, min = 0, sec = 0}) + nEndTime;
    tbTime = os.date("*t", nCurTime);
    local szOpenTime = string.format("%s-%s-%s 22:00", tbTime.year, tbTime.month, tbTime.day);
    local szAllKinName = "";
    for nKinId, nRank in pairs(tbSaveData.tbCan) do
        local tbKin = Kin:GetKinById(nKinId);
        if tbKin then
            Mail:SendKinMail({
                KinId = nKinId,
                Text = string.format(self.tbEndJiFenCrossKinMail.szContent, tbKin.szName, szOpenTime),
                From = self.tbEndJiFenCrossKinMail.szTitle,
            })

            if Lib:IsEmptyStr(szAllKinName) then
                szAllKinName = tbKin.szName;
            else
                szAllKinName = szAllKinName.."、" .. tbKin.szName
            end
            ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, self.szEndJiFenKinNotice, nKinId);
        end
    end

    if not Lib:IsEmptyStr(szAllKinName) and bSendWorld then
        KPlayer.SendWorldNotify(1, 999, string.format(self.szEndJiFenWorldNotice, szAllKinName), 1, 1);
    end
        
    Log("BossLeader SendCrossKinMail");
end

function BossLeader:IsOpenCrossBoss()
    return self.tbCrossBossDataInfo.bOpenCross;
end

function BossLeader:IsCrossBossMap(nMapTID, nMapId)
    if not self:IsOpenCrossBoss() then
        return false;
    end

    if not self.tbCrossBossMapInfo[nMapTID] then
        return false;
    end

    if self.tbCrossBossMapInfo[nMapTID] ~= nMapId then
        return false;
    end

    return true;
end
