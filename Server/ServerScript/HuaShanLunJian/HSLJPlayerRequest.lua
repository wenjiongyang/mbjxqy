
Require("ServerScript/HuaShanLunJian/HuaShanLunJian.lua");
Require("ServerScript/HuaShanLunJian/LunJianFightTeam.lua");
Require("ServerScript/HuaShanLunJian/HSLJGuessing.lua");

local tbDef = HuaShanLunJian.tbDef;

HuaShanLunJian.tbC2SRequest = HuaShanLunJian.tbC2SRequest or {};

function HuaShanLunJian:CheckRequestFightTeamInfo(pPlayer)
    local nFightTeamID = self:GetPlayerFightTeam(pPlayer);
    if nFightTeamID <= 0 then
        return false;
    end

    local tbFightTeam = self:GetFightTeamByID(nFightTeamID);
    if not tbFightTeam then
        return false;
    end

    return true, tbFightTeam; 
end    

function HuaShanLunJian:RequestFightTeamInfo(pPlayer)
    local tbFightTeamInfo = {};
    local bRet, tbFightTeam = self:CheckRequestFightTeamInfo(pPlayer);
    if bRet and tbFightTeam then
        tbFightTeamInfo.szName = tbFightTeam:GetName();
        tbFightTeamInfo.nJoinCount = tbFightTeam:GetJoinCount();
        tbFightTeamInfo.nWinCount = tbFightTeam:GetWinCount();
        tbFightTeamInfo.nPerCount = tbFightTeam:GetPerDayCount();
        local nFightTeamID = tbFightTeam:GetID();
        local tbFinalsInfo = self:GetFinalsFightTeamByID(nFightTeamID);
        if tbFinalsInfo then
            tbFightTeamInfo.nFinals = 1;
        end

        tbFightTeamInfo.tbAllPlayer = {};
        local tbAllPlayerID = tbFightTeam:GetAllPlayerID()
        for nPlayerID, nTeamNum in pairs(tbAllPlayerID) do
            local tbStayInfo = KPlayer.GetRoleStayInfo(nPlayerID);
            if tbStayInfo then
                local tbInfo = {};
                tbInfo.szName = tbStayInfo.szName;
                tbInfo.nNum = nTeamNum;

                tbFightTeamInfo.tbAllPlayer[nPlayerID] = tbInfo; 
            end 
        end        
    end    
    self:SyncGuessingData(pPlayer);
    pPlayer.CallClientScript("Player:ServerSyncData", "HSLJFightTeamInfo", tbFightTeamInfo);
end


function HuaShanLunJian:ApplyPlayGame(pPlayer)
    local bRet = HuaShanLunJian:IsPrepareGamePeriod()
    if bRet then
        self:EnterPrepareGame(pPlayer);
        return;
    end

    local bRet = HuaShanLunJian:IsFinalsPlayGamePeriod();
    if bRet then
        self:PlayerEnterFinalsMap(pPlayer);
        return;
    end

    pPlayer.CenterMsg("未開啟活動", true);    
end

function HuaShanLunJian:GetFightTeamShowInfo(nFightTeamID)
    local tbFightTeam = self:GetFightTeamByID(nFightTeamID);
    if not tbFightTeam then
        return;
    end

    local tbShowInfo = {}
    tbShowInfo.szName = tbFightTeam:GetName();
    tbShowInfo.tbAllPlayer = {};

    local tbAllPlayerID = tbFightTeam:GetAllPlayerID()
    for nPlayerID, _ in pairs(tbAllPlayerID) do
        local tbStayInfo = KPlayer.GetRoleStayInfo(nPlayerID);
        if tbStayInfo then
            local tbInfo = {};
            tbInfo.szName = tbStayInfo.szName;
            tbInfo.nFaction = tbStayInfo.nFaction;
            tbInfo.nLevel = tbStayInfo.nLevel;
            tbInfo.nPortrait = tbStayInfo.nPortrait;
            tbInfo.nHonorLevel = tbStayInfo.nHonorLevel;
            tbInfo.nFightPower = 0;

            local pAsyncData = KPlayer.GetAsyncData(nPlayerID)
            if pAsyncData then
                tbInfo.nFightPower = pAsyncData.GetFightPower();
            end

            tbShowInfo.tbAllPlayer[nPlayerID] = tbInfo; 
        end
    end

    return tbShowInfo;
end


function HuaShanLunJian:RequestFightTeamShowInfo(pPlayer, nFightTeamID)
    local tbFightTeam = self:GetFightTeamByID(nFightTeamID);
    if not tbFightTeam then
        return;
    end

    local tbShowInfo = self:GetFightTeamShowInfo(nFightTeamID);
    pPlayer.CallClientScript("Player:ServerSyncData", "HSLJFightTeam:"..nFightTeamID, tbShowInfo);
end

function HuaShanLunJian:RequestHSLJChampion(pPlayer)
    local tbSaveData = HuaShanLunJian:GetLunJianSaveData();
    local nChampionId = tbSaveData.nChampionId;
    if nChampionId <= 0 then
        return;
    end
        
    local tbShowInfo = self:GetFightTeamShowInfo(nChampionId);
    pPlayer.CallClientScript("Player:ServerSyncData", "HSLJChampion", tbShowInfo);
end

function HuaShanLunJian:CheckRequestFinalsFightData(pPlayer)
    local tbNotFinalsData = self:GetFinalsGameNotSave();
    if not tbNotFinalsData.bStart then
        return false;
    end

    local nMainID = HuaShanLunJian:GetFinalsMapIDByIndex(1);
    if not nMainID then
        return false;
    end

    local tbFinalsInst = self:GetMainFinalsLogic();
    if not tbFinalsInst then
        return false;
    end

    return true, tbFinalsInst;
end

function HuaShanLunJian:RequestFinalsFightData(pPlayer)
    local tbAllMatchFightTeam = nil;
    local bRet, tbFinalsInst = self:CheckRequestFinalsFightData(pPlayer);
    if bRet then
        tbAllMatchFightTeam = tbFinalsInst:GetAllMatchPlayGame();
    end

    if not tbAllMatchFightTeam then
        tbAllMatchFightTeam = self.tbSynctbAllMatchFightTeam;
    end

    if not tbAllMatchFightTeam then    
        local tbSaveData = self:GetLunJianSaveData();
        local tbAllFightTeam = tbSaveData.tbFinalsFightTeam;
        if Lib:HaveCountTB(tbAllFightTeam) then
            self.tbSynctbAllMatchFightTeam = {};
            self.tbSynctbAllMatchFightTeam[1] = {};
            for nFightTeamID, tbInfo in pairs(tbAllFightTeam) do
                local tbFightTeam = self:GetFightTeamByID(nFightTeamID);
                if tbFightTeam then
                    self.tbSynctbAllMatchFightTeam[1][tbInfo.nRank] = {szName = tbFightTeam:GetName(), nId = nFightTeamID};
                end    
            end    
        end

        tbAllMatchFightTeam = self.tbSynctbAllMatchFightTeam;
    end

    if tbAllMatchFightTeam then
        self.tbSynctbAllMatchFightTeam = tbAllMatchFightTeam;    
        self:UpdatePlayerSaveData(pPlayer);
        self:SyncGuessingData(pPlayer);
        pPlayer.CallClientScript("Player:ServerSyncData", "HSLJFinalsMatch", tbAllMatchFightTeam);
    end    
end

function HuaShanLunJian:RequestGameStateData(pPlayer)
    local tbSaveData = self:GetLunJianSaveData();
    local tbInfo = {};
    tbInfo.nPlayState = tbSaveData.nPlayState;
    tbInfo.nGameFormatType = tbSaveData.nGameFormatType;
    tbInfo.nGameMonth = tbSaveData.nGameMonth;
    tbInfo.nWeekDay   = tbSaveData.nWeekDay;
    self:UpdatePlayerSaveData(pPlayer);
    self:SyncGuessingData(pPlayer);
    pPlayer.CallClientScript("Player:ServerSyncData", "HSLJStateData", tbInfo);
end

function HuaShanLunJian:SyncFinalsWatchData(pPlayer)
    local bRet, tbFinalsInst = self:CheckRequestFinalsFightData(pPlayer);
    if not bRet then
        return;
    end

    local tbSyncData = tbFinalsInst:GetFightTeamWatchInfo(); 
    pPlayer.CallClientScript("Player:ServerSyncData", "HSLJTeamWatchData", tbSyncData);
end  

function HuaShanLunJian:SyncWatchTeamPlayerData(pPlayer, nFightTeamID)
    local bRet, tbFinalsInst = self:CheckRequestFinalsFightData(pPlayer);
    if not bRet then
        return;
    end

    local tbSyncData = tbFinalsInst:GetTeamWatchPlayerInfo(nFightTeamID);
    pPlayer.CallClientScript("Player:ServerSyncData", string.format("HSLJWatchPlayer:%s", nFightTeamID), tbSyncData);
end

function HuaShanLunJian:PlayerWatchTeamPlayer(pPlayer, nPlayerID, bAutoFinsh)
    local bRet, tbFinalsInst = self:CheckRequestFinalsFightData(pPlayer);
    if not bRet then
        return;
    end

    tbFinalsInst:WatchPlayerByID(pPlayer, nPlayerID, bAutoFinsh);
end

HuaShanLunJian.tbC2SRequest =
{
    ["RequestFightTeam"] = function (pPlayer)
        HuaShanLunJian:RequestFightTeamInfo(pPlayer);
    end;

    ["CreateFightTeam"] = function (pPlayer, szTeamName)
        if Lib:IsEmptyStr(szTeamName) then
            Log("Error PlayerCreateFightTeam IsEmptyStr", pPlayer.dwID)
            return;
        end

        HuaShanLunJian:PlayerCreateFightTeam(pPlayer.dwID, szTeamName);       
    end;

    ["JoinFightTeam"] = function (pPlayer)
        HuaShanLunJian:PlayerJoinFightTeam(pPlayer.dwID);
    end;

    ["QuitFightTeam"] = function (pPlayer)
        HuaShanLunJian:PlayerQuitFightTeam(pPlayer.dwID)
    end;

    ["ApplyPlayGame"] = function (pPlayer)
        HuaShanLunJian:ApplyPlayGame(pPlayer);
    end;

    ["RequestFinalsData"] = function (pPlayer)
         HuaShanLunJian:RequestFinalsFightData(pPlayer)
    end;

    ["RequestStateData"] = function (pPlayer)
        HuaShanLunJian:RequestGameStateData(pPlayer);
    end;

    ["RequestFightTeamShow"] = function (pPlayer, nFightTeamID)
        if type(nFightTeamID) ~= "number" then
            return;
        end

        HuaShanLunJian:RequestFightTeamShowInfo(pPlayer, nFightTeamID)
    end;

    ["RequestHSLJChampion"] = function (pPlayer)
        HuaShanLunJian:RequestHSLJChampion(pPlayer)
    end;
    ["ChampionGuessing"] = function (pPlayer, nFightTeamID)
        if type(nFightTeamID) ~= "number" then
            return;
        end

        HuaShanLunJian:PlayerChampionGuessing(pPlayer, nFightTeamID)
    end;

    ["ChangeTeamNum"] = function (pPlayer, tbPlayerNum)
        if type(tbPlayerNum) ~= "table" then
            return;
        end 
           
        HuaShanLunJian:ChangeFightTeamPlayerNum(pPlayer, tbPlayerNum)
    end;

    ["SyncFinalsWatchData"] = function (pPlayer)
        HuaShanLunJian:SyncFinalsWatchData(pPlayer);
    end;

   ["SyncWatchTeamPlayerData"] = function (pPlayer, nFightTeamID)
        if type(nFightTeamID) ~= "number" then
            return;
        end
        
        HuaShanLunJian:SyncWatchTeamPlayerData(pPlayer, nFightTeamID)
   end;

   ["PlayerWatchTeamPlayer"] = function (pPlayer, nPlayerID, bAutoFinsh)
        if type(nPlayerID) ~= "number" then
            return;
        end

        HuaShanLunJian:PlayerWatchTeamPlayer(pPlayer, nPlayerID, bAutoFinsh)
   end;
   
}