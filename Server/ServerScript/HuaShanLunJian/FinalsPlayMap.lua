Require("CommonScript/HuaShanLunJian/LunJianDef.lua");
Require("ServerScript/HuaShanLunJian/HuaShanLunJian.lua");
Require("ServerScript/HuaShanLunJian/HSLJPreGamePreLogic.lua");

HuaShanLunJian.tbBaseFinalsMapLogic = HuaShanLunJian.tbBaseFinalsMapLogic or {};
HuaShanLunJian.tbFinalsPKLogic = HuaShanLunJian.tbFinalsPKLogic or {};
HuaShanLunJian.tbClassFinalsPKLogic = HuaShanLunJian.tbClassFinalsPKLogic or {}; 

local tbBaseLogic = HuaShanLunJian.tbBaseFinalsMapLogic;
local tbFinalsPKLogic = HuaShanLunJian.tbFinalsPKLogic;
local tbPreGameMgr = HuaShanLunJian.tbPreGamePreMgr;

local tbDef             = HuaShanLunJian.tbDef;
local tbPlayMap         = Map:GetClass(tbDef.tbFinalsGame.nFinalsMapTID);

function HuaShanLunJian:GetFinalsPlayPKLogic(szClass)
    local tbClassLogic = self.tbClassFinalsPKLogic[szClass];
    if not tbClassLogic then
        tbClassLogic = Lib:NewClass(tbFinalsPKLogic);
        self.tbClassFinalsPKLogic[szClass] = tbClassLogic;
    end

    return tbClassLogic;    
end

--重载
function tbPlayMap:OnCreate(nMapId)
    local tbNotFinalsData = HuaShanLunJian:GetFinalsGameNotSave();
    local nCount = Lib:CountTB(tbNotFinalsData.tbFinalsAllMapID);
    nCount = nCount + 1;
    tbNotFinalsData.tbFinalsAllMapID[nMapId] = nCount;
    tbNotFinalsData.tbFinalsAllMapIndex[nCount] = nMapId;

    Log("HSLJ Finals Map Create", nMapId, nCount);
end

function tbPlayMap:OnDestroy(nMapId)
    local tbNotFinalsData = HuaShanLunJian:GetFinalsGameNotSave();
    local nIndex = tbNotFinalsData.tbFinalsAllMapID[nMapId];
    tbNotFinalsData.tbFinalsAllMapID[nMapId] = nil;
    if nIndex then
       tbNotFinalsData.tbFinalsAllMapIndex[nIndex] = nil;
    end    

    if nIndex == 1 and tbNotFinalsData.tbFinalsLogicMgr then
        tbNotFinalsData.tbFinalsLogicMgr:OnClose();
        tbNotFinalsData.tbFinalsLogicMgr = nil;
    end
 
    Log("HSLJ Finals Map OnDestroy", nMapId, nIndex);
end

function tbPlayMap:OnEnter(nMapId)
    local tbNotFinalsData = HuaShanLunJian:GetFinalsGameNotSave();
    local tbLogicMgr = tbNotFinalsData.tbFinalsLogicMgr;
    if not tbLogicMgr then
        return;
    end

    tbLogicMgr:OnEnter(nMapId);    
end

function tbPlayMap:OnLeave(nMapId)
    local tbNotFinalsData = HuaShanLunJian:GetFinalsGameNotSave();
    local tbLogicMgr = tbNotFinalsData.tbFinalsLogicMgr;
    if not tbLogicMgr then
        return;
    end

    tbLogicMgr:OnLeave(nMapId);
end

function tbPlayMap:OnLogin(nMapId)
    local tbNotFinalsData = HuaShanLunJian:GetFinalsGameNotSave();
    local tbLogicMgr = tbNotFinalsData.tbFinalsLogicMgr;
    if not tbLogicMgr then
        return;
    end

    tbLogicMgr:OnLogin();
end

function tbPlayMap:OnPlayerTrap(nMapId, szTrapName)
    local tbNotFinalsData = HuaShanLunJian:GetFinalsGameNotSave();
    local tbLogicMgr = tbNotFinalsData.tbFinalsLogicMgr;
    if not tbLogicMgr then
        return;
    end

    tbLogicMgr:OnPlayerTrap(nMapId, szTrapName);
end

--重载
function tbBaseLogic:GetFinalDef()
    return tbDef.tbFinalsGame
end

function tbBaseLogic:OnCreate()
    self.nPlayerEnterCount = 0;
    self.nApplyPlayerCount = 0;
    self.tbApplyFightTeam = {};
    self.nStatePos = 0;
    self.nAgainstPlan = 0;
    self.nLastStartPos = 0;
    self.tbMatchPlayGame = {};
    self.tbFightTeamPlayLogic = {};
    self.tbChampionPlanWin = {};
    self.tbPlayingFightTeamID = {};
    self.tbAllPlayerInfo = {};
    self.bFinalsEnd = false;
    self.bFightTeamPK = false;
    self.nRecordMatchIndex = 1;
    self.tbAllMatchPlayGame = {};
    self.tbFightTeamPKLogicTimer = {};
    self.tbFightTeamWatchInfo = {};

    local tbFinalsFightTeam = tbPreGameMgr:GetAllFinalsFightTeam()
    for nFightTeamID, tbInfo in pairs(tbFinalsFightTeam) do
        self:AddMatchPlayFightTeam(tbInfo.nRank, nFightTeamID);
    end    

    self:OnExecuteState();
    Log("HSLJ Finals Map OnCreate");
end

function tbBaseLogic:GetAllMatchPlayGame()
    return self.tbAllMatchPlayGame or {};
end    

function tbBaseLogic:CloseAllPlayLogic()
    for _, tbAllLogic in pairs(self.tbFightTeamPlayLogic) do
        for _, tbLogic in pairs(tbAllLogic) do
            tbLogic:OnClose();
        end
    end

    for _, tbData in pairs(self.tbFightTeamPKLogicTimer) do
        if tbData.nTimer then
            Timer:Close();
            tbData.nTimer = nil;
        end

        local funCallBack = self[tbData.szCallType];
        if funCallBack then
            funCallBack(self, tbData);
        end    
    end

    self.tbFightTeamPKLogicTimer = {};
    self.tbFightTeamPlayLogic = {};   
end

function tbBaseLogic:GetFightTeamLogic(nIndex, nMapId)
    local tbAllLogic = self.tbFightTeamPlayLogic[nIndex];
    if not tbAllLogic then
        return;
    end

    return tbAllLogic[nMapId];
end

function tbBaseLogic:AddMatchPlayFightTeam(nIndex, nFightTeamID)
    self.tbMatchPlayGame[nIndex] = nFightTeamID;
    self:AddRecordMatchFightTeam(nIndex, nFightTeamID);
    Log("HSLJ AddMatchPlayFightTeam", nIndex, nFightTeamID);
end

function tbBaseLogic:AddRecordMatchFightTeam(nIndex, nFightTeamID)
    local tbFightTeam = tbPreGameMgr:GetFightTeamByID(nFightTeamID);
    if not tbFightTeam then
        return;
    end

    if self.nRecordMatchIndex < 0 then
        return;
    end    

    self.tbAllMatchPlayGame[self.nRecordMatchIndex] = self.tbAllMatchPlayGame[self.nRecordMatchIndex] or {};
    self.tbAllMatchPlayGame[self.nRecordMatchIndex][nIndex] = {szName = tbFightTeam:GetName(), nId = nFightTeamID};
end

function tbBaseLogic:OnExecuteState()
    if self.nExecuteStateTimer then
        Timer:Close(self.nExecuteStateTimer);
        self.nExecuteStateTimer = nil;
    end 

    self.nStatePos = self.nStatePos + 1;
    local tbStateInfo = self:GetPlayGameState(self.nStatePos);
    local nNextTime  = -1;
    if tbStateInfo and (not self.bFinalsEnd or not tbStateInfo.bCanStop) then
        if not Lib:IsEmptyStr(tbStateInfo.szWorld) then
            local tbGameFormat = tbPreGameMgr:GetGameFormat()
            tbPreGameMgr:SendWorldMsg(string.format(tbStateInfo.szWorld, tbGameFormat.szName) )
        end    
        self.bFightTeamPK = false;
        local FunBack = nil;
        if not Lib:IsEmptyStr(tbStateInfo.szCall) then
            FunBack = self["On"..tbStateInfo.szCall];
        end

        if FunBack then
            FunBack(self, self.nStatePos); 
        end

        nNextTime = tbStateInfo.nNextTime;
    end    

    if nNextTime > 0 and self.nExecuteStateTimer == nil then
        self.nExecuteStateTimer = Timer:Register(nNextTime * Env.GAME_FPS, self.OnExecuteState, self);
        self:ForeachAllPlayer({self.UpdatePlayerRightMsg, self, false});
        self:ForeachAllPlayer({self.UpdateLeavePanleUI, self});   
    end

    Log("HSLJ Finals Map OnExecuteState", self.nStatePos);    
end

function tbBaseLogic:UpdatePlayerRightMsg(bNotCheckPk, pPlayer)
    local tbStateInfo = self:GetPlayGameState(self.nStatePos);
    if not tbStateInfo then
        return;
    end

    if not bNotCheckPk then
        local tbPKLogic = self:GetPlayerFightTeamPKLogic(pPlayer);
        if tbPKLogic then
            return;
        end    
    end    

    local nTime = self:GetExecuteStateTime();
    local tbShowInfo = {}
    tbShowInfo.nTime = nTime;
    tbShowInfo.szShow = tbStateInfo.szRMsg;
    tbShowInfo.nMapTID = pPlayer.nMapTemplateId;
    tbShowInfo.szHelp = self:GetHSLJBattleInfoShowInfoHelp();
    pPlayer.CallClientScript("Ui:OpenWindow", "HSLJBattleInfo", "ShowInfo", tbShowInfo);
end

--重载
function tbBaseLogic:GetHSLJBattleInfoShowInfoHelp()
    return "HSLJFinalsNew";
end

function tbBaseLogic:UpdatePlayerShowUI(pPlayer)
    pPlayer.CallClientScript("Player:ServerSyncData", "HomeBtnTast", {nMapTID = pPlayer.nMapTemplateId});
    local tbGameFormat = tbPreGameMgr:GetGameFormat()
    if tbGameFormat.szPKClass and tbGameFormat.szPKClass == "PlayDuel" then
        pPlayer.CallClientScript("Player:ServerSyncData", "TeamBtNum", {nMapTID = pPlayer.nMapTemplateId});
    end

    pPlayer.nCanLeaveMapId = pPlayer.nMapId;
    self:UpdateLeavePanleUI(pPlayer);
    if not MODULE_ZONESERVER then
        pPlayer.CallClientScript("Ui:SetLoadShowUI", {nMapTID = pPlayer.nMapTemplateId, tbUi = {["BattleTopButton"] = 1}}); 
    end

    if tbGameFormat.bOpenPartner then    
        pPlayer.CallClientScript("Player:ServerSyncData", "TeamShowPartner", {nMapTID = pPlayer.nMapTemplateId});
    end   
end

function tbBaseLogic:UpdateLeavePanleUI(pPlayer)
    local tbShow = {["BtnLeave"] = 1};
    local tbGameFormat = tbPreGameMgr:GetGameFormat();
    if self.bFightTeamPK and tbGameFormat.szPKClass and tbGameFormat.szPKClass == "PlayDuel" then
        tbShow = {["BtnLeave"] = 1, ["BtnWitnessWar"] = 1};
    end

    local tbPKLogic = self:GetPlayerFightTeamPKLogic(pPlayer);
    if tbPKLogic and not tbPKLogic:IsEndPKSate()  then
        return;
    end    

    pPlayer.CallClientScript("Ui:OpenWindow", "QYHLeavePanel", "HSLJ", tbShow);
    pPlayer.CallClientScript("Map:SetCloseUiOnLeave", pPlayer.nMapId, "QYHLeavePanel"); 
end

function tbBaseLogic:GetCurPlan()
    return self.nAgainstPlan;
end

--重载
function tbBaseLogic:DoFinalsEnd(nFightTeamID)
    self.bFinalsEnd = true;

    local tbSaveData = HuaShanLunJian:GetLunJianSaveData();
    tbSaveData.nChampionId = nFightTeamID;
    
    self:SendChampionTeamMsg(nFightTeamID);

    Timer:Register(1, self.CanStopExecuteState, self); ---延迟一帧执行防止停止后同时执行OnExecuteState
    Log("HSLJ  Finals Map DoFinalsEnd", nFightTeamID);
end

--重载
function tbBaseLogic:SendChampionTeamMsg(nFightTeamID)
    local tbFightTeam = HuaShanLunJian:GetFightTeamByID(nFightTeamID);
    if not tbFightTeam then
        return;
    end

    local tbAllPlayer = tbFightTeam:GetAllPlayerID();
    local szFightName = tbFightTeam:GetName();
    local szPlayerTeam = "";

    for nPlayerID, _ in pairs(tbAllPlayer) do
        local tbStayInfo = KPlayer.GetRoleStayInfo(nPlayerID);
        if tbStayInfo then
            local szShowMsg = "";
            if tbStayInfo.dwKinId ~= 0 then
                szShowMsg = string.format("恭喜幫派成員「%s」所在的%s戰隊獲得了本屆華山論劍冠軍，站在了華山之巔！", tbStayInfo.szName, szFightName);
                ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szShowMsg, tbStayInfo.dwKinId);
            end

            szShowMsg = string.format("恭喜您的好友「%s」所在的%s戰隊獲得了本屆華山論劍冠軍，站在了華山之巔", tbStayInfo.szName, szFightName);
            ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Friend, szShowMsg, nPlayerID);

            szPlayerTeam = szPlayerTeam .. string.format("「%s」", tbStayInfo.szName);    
        end  
    end

    local szWorldMsg = string.format("恭喜%s所在的「%s」戰隊獲得了本屆華山論劍冠軍，站在了華山之巔！", szPlayerTeam, szFightName);
    KPlayer.SendWorldNotify(1, 999, szWorldMsg, 1, 1);      
end

function tbBaseLogic:CanStopExecuteState()
    local nStatePos = self.nStatePos;
    while (true) do
        nStatePos = nStatePos + 1;
        local tbStateInfo = self:GetPlayGameState(nStatePos);
        if not tbStateInfo or not tbStateInfo.bCanStop then
            self.nStatePos = nStatePos - 1;
            self:OnExecuteState();  
            return;        
        end
    end    
end

--重载
function tbBaseLogic:OnWin(nIndex, nFightTeamID)
    self:AddMatchPlayFightTeam(nIndex, nFightTeamID);

    local nPlan = self:GetCurPlan();
    local tbFinalsDef = self:GetFinalDef()
    if nPlan == tbFinalsDef.nChampionPlan then
        local nWinCount = self.tbChampionPlanWin[nFightTeamID] or 0;
        nWinCount = nWinCount + 1;
        self.tbChampionPlanWin[nFightTeamID] = nWinCount;

        if nWinCount >= tbFinalsDef.nChampionWinCount then
            self:DoFinalsEnd(nFightTeamID);
        end 
    end

    self:ForeachAllPlayerFightTeam(nFightTeamID, {self.SendWinPlayerMsg, self});
    --self:ForeachAllPlayerFightTeam(nFightTeamID, {self.SendPlayerGameAward, self, tbFinalsDef.tbPlayGameAward});
    Log("HSLJ Finals Map OnWin", nIndex, nFightTeamID);
end


function tbBaseLogic:GetPlayingGameCount()
    local nCount = 0;
    for _, tbAllLogic in pairs(self.tbFightTeamPlayLogic) do
        for _, tbLogic in pairs(tbAllLogic) do
            if not tbLogic:IsEndPKSate() then
                nCount = nCount + 1;
            end
        end    
    end

    for _, _ in pairs(self.tbFightTeamPKLogicTimer) do
        nCount = nCount + 1;
    end    

    return nCount;    
end

function tbBaseLogic:OnPlayGameEnd(nIndex)
    local nCount = self:GetPlayingGameCount();
    if nCount <= 0 then
        self:AllPlayGameEnd();
    end  
end

function tbBaseLogic:AllPlayGameEnd()
    local tbStateInfo = self:GetPlayGameState(self.nLastStartPos);
    if tbStateInfo and tbStateInfo.szEndWorldNotify then
        local tbGameFormat = tbPreGameMgr:GetGameFormat()
        local szExtMsg = "";
        for _, nFightTeamID in pairs(self.tbMatchPlayGame) do
            local tbFightTeam = tbPreGameMgr:GetFightTeamByID(nFightTeamID);
            if tbFightTeam then
                if not Lib:IsEmptyStr(szExtMsg) then
                    szExtMsg = szExtMsg .. "、";
                end
                  
                szExtMsg = szExtMsg .. string.format("戰隊[FFFE0D]「%s」[-]", tbFightTeam:GetName());
            end    
        end

        tbPreGameMgr:SendWorldMsg(string.format(tbStateInfo.szEndWorldNotify, szExtMsg, tbGameFormat.szName))
    end

    if self.nLastStartPos == self.nStatePos then
        self:OnExecuteState();
    end
    Log("FinalsPKLogic AllPlayGameEnd");     
end

function tbBaseLogic:SendWinPlayerMsg(pPlayer)
    local tbStateInfo = self:GetPlayGameState(self.nLastStartPos);
    if not tbStateInfo then
        return;
    end

    local tbTeamMsg = tbStateInfo.tbTeamMsg;
    if not tbTeamMsg then
        return;
    end

    local tbWin = tbTeamMsg.tbWin;
    if not tbWin then
        return;
    end

    self:SendPlayerMsg(pPlayer, tbWin);
end

--重载
function tbBaseLogic:SendPlayerMsg(pPlayer, tbInfo)
    if tbInfo.szMsg then
        pPlayer.CenterMsg(tbInfo.szMsg, true);
    end

    if tbInfo.szKinMsg then
        if pPlayer.dwKinId ~= 0 then
            local szShowMsg = string.format(tbInfo.szKinMsg, pPlayer.szName);
            ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szShowMsg, pPlayer.dwKinId);
        end
    end

    if tbInfo.szFriend then
        ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Friend, string.format(tbInfo.szFriend, pPlayer.szName), pPlayer.dwID);    
    end    
end

function tbBaseLogic:SendFailPlayerMsg(pPlayer)
    local tbStateInfo = self:GetPlayGameState(self.nLastStartPos);
    if not tbStateInfo then
        return;
    end

    local tbTeamMsg = tbStateInfo.tbTeamMsg;
    if not tbTeamMsg then
        return;
    end

    local tbFail = tbTeamMsg.tbFail;
    if not tbFail then
        return;
    end

    self:SendPlayerMsg(pPlayer, tbFail);
end

function tbBaseLogic:OnFail(nIndex, nFightTeamID)
    local nPlan = self:GetCurPlan();
    local tbFinalsDef = self:GetFinalDef()
    if nPlan == tbFinalsDef.nChampionPlan then
        local tbAllPKPlan = self:GetAgainstPlanInfo(nPlan);
        local nMatchIndex = tbAllPKPlan[1].tbIndex[2];
        self:AddMatchPlayFightTeam(nMatchIndex, nFightTeamID);
    end 

    self:ForeachAllPlayerFightTeam(nFightTeamID, {self.SendFailPlayerMsg, self});
    --self:ForeachAllPlayerFightTeam(nFightTeamID, {self.SendPlayerGameAward, self, tbFinalsDef.tbPlayGameAward});
    Log("HSLJ Finals Map OnFail", nIndex, nFightTeamID);
end

function tbBaseLogic:GetExecuteStateTime()
    if not self.nExecuteStateTimer then
        return 0;
    end    

    local nTime = math.floor(Timer:GetRestTime(self.nExecuteStateTimer) / Env.GAME_FPS);
    return nTime;
end

function tbBaseLogic:OnFreedom(nState)

    Log("HSLJ Finals Map OnFreedom", nState);
end

--重载
function tbBaseLogic:OnSendAward(nState)
    if self.bFinalsAward then
        return;
    end

    self.bFinalsAward = true;
    HuaShanLunJian:FinalsFightTeamAward();
    local tbSaveData = HuaShanLunJian:GetLunJianSaveData();
    HuaShanLunJian:SendChampNewInformation(tbSaveData.nChampionId);
    Log("HSLJ Finals Map OnSendAward", nState);
end

function tbBaseLogic:OnStartPK(nState)
    if self.bFinalsEnd then
        Log("HSLJ OnStartPK All PK Plan bFinalsEnd");
        return;
    end

    local tbStateInfo = self:GetPlayGameState(nState);
    local nPlan = tbStateInfo.nPlan;
    local tbAllPKPlan = self:GetAgainstPlanInfo(nPlan);
    if not tbAllPKPlan then
        Log("Error HSLJ OnStartPK All PK Plan", nPlan);
        return;
    end

    local tbFinalsDef = self:GetFinalDef()
    if nPlan ~= tbFinalsDef.nChampionPlan then
        self.nRecordMatchIndex = self.nRecordMatchIndex + 1;
    else
        self.nRecordMatchIndex = -1;      
    end

    self.nAgainstPlan = nPlan;
    self.nLastStartPos = nState;
    local nEndTime = tbStateInfo.nNextTime - tbFinalsDef.nShowInfoPlayTeamTime - tbFinalsDef.nPlayDelayTime; --显示对阵图的时间
    self:CloseAllPlayLogic();
    local tbMatchPlayGame = self.tbMatchPlayGame;
    self.tbMatchPlayGame = {};
    self.tbPlayingFightTeamID = {};
    self.tbFightTeamWatchInfo = {};

    for nIndex, tbInfo in pairs(tbAllPKPlan) do
        local nFightTeamID1 = tbMatchPlayGame[tbInfo.tbIndex[1]] or 0;
        local nFightTeamID2 = tbMatchPlayGame[tbInfo.tbIndex[2]] or 0;
        local tbPlayInfo = {};
        tbPlayInfo[1] =
        {
            nFightTeamID = nFightTeamID1;
            tbPos        = tbInfo.tbPos[1];
        };

        tbPlayInfo[2] =
        {
            nFightTeamID = nFightTeamID2;
            tbPos        = tbInfo.tbPos[2];
        };

        for _, tbTeamInfo in pairs(tbPlayInfo) do
            if tbTeamInfo.nFightTeamID > 0 then
                self:SetFinalsFightTeamPlan(tbTeamInfo.nFightTeamID, self.nAgainstPlan);
            end    
        end 

        self.tbPlayingFightTeamID[nFightTeamID1] = nIndex;
        self.tbPlayingFightTeamID[nFightTeamID2] = nIndex;

        self:CreateFightTeamPK(nIndex, tbPlayInfo, nEndTime) 
    end
    self.bFightTeamPK = true;
    Log("HSLJ Finals Map OnStartPK", nState, nPlan);
end

--重载
function tbBaseLogic:GetFinalsFightTeamByID(nFightTeamID)
    return HuaShanLunJian:GetFinalsFightTeamByID(nFightTeamID)
end

--重载
function tbBaseLogic:SetFinalsFightTeamPlan(nFightTeamID, nPlan)
    local tbFinalsInfo = self:GetFinalsFightTeamByID(nFightTeamID);
    if not tbFinalsInfo then
        return;
    end

    if tbFinalsInfo.nPlan == nPlan then
        return;
    end

    tbFinalsInfo.nPlan = nPlan;
    Log("HSLJ SetFinalsFightTeamPlan", nFightTeamID, nPlan);
end

function tbBaseLogic:GetFightTeamWatchInfo()
   return self.tbFightTeamWatchInfo or {};
end

function tbBaseLogic:GetTeamWatchPlayerInfo(nFightTeamID)
    if nFightTeamID <= 0 then
        return;
    end

    local nIndex = self.tbPlayingFightTeamID[nFightTeamID];
    if not nIndex then
        return;
    end

    local tbTeamInfo = self:GetApplyFightTeamInfo(nFightTeamID);
    if not tbTeamInfo then
        return;
    end

    local tbTeamPlayerShow = {};
    local tbFinalsDef = self:GetFinalDef()
    for nPlayerID, tbPlayPKInfo in pairs(tbTeamInfo.tbAllPlayerPKInfo) do
        local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
        if pPlayer and pPlayer.nMapTemplateId == tbFinalsDef.nFinalsMapTID and tbPlayPKInfo.nResult == TeamPKMgr.tbDef.nPlayNone  then
            tbTeamPlayerShow[nPlayerID] = pPlayer.szName;
        end    
    end

    return tbTeamPlayerShow;     
end

function tbBaseLogic:GetApplyFightTeamPlayerCount(nFightTeamID)
    local tbApplyTeam = self:GetApplyFightTeamInfo(nFightTeamID);
    if not tbApplyTeam then
        return 0;
    end

    local nCount = Lib:CountTB(tbApplyTeam.tbAllPlayer);
    return nCount;    
end

function tbBaseLogic:CreateFightTeamPK(nIndex, tbPlayInfo, nEndTime)
    for _, tbInfo in pairs(tbPlayInfo) do
        if tbInfo.nFightTeamID > 0 then
            local nPlayCount = self:GetApplyFightTeamPlayerCount(tbInfo.nFightTeamID);
            if nPlayCount <= 0 then
                tbInfo.nFightTeamID = 0;
            end    
        end
    end    


    local nFightTeamID1 = tbPlayInfo[1].nFightTeamID;    
    local nFightTeamID2 = tbPlayInfo[2].nFightTeamID;   
    if nFightTeamID1 > 0 and nFightTeamID2 > 0 then
        self:PlayFightTeamTwo(nIndex, tbPlayInfo, nEndTime);
    elseif nFightTeamID1 > 0 or nFightTeamID2 > 0 then
        self:PlayFightTeamOne(nIndex, tbPlayInfo, nEndTime);
    else
        Log("HSLJ CreateFightTeamPK Emply", nIndex);    
    end    
end

function tbBaseLogic:PlayFightTeamOne(nIndex, tbPlayInfo, nEndTime)
    local nFightTeamID = tbPlayInfo[1].nFightTeamID;
    if nFightTeamID <= 0 then
        nFightTeamID = tbPlayInfo[2].nFightTeamID;
    end
    
    local tbTeamInfo = self:GetApplyFightTeamInfo(nFightTeamID);
    if not tbTeamInfo then
        Log("HSLJ  PlayFightTeamOne Not tbTeamInfo", nFightTeamID, nIndex)
        return;
    end

    tbTeamInfo.tbAllPlayerPKInfo = {};
    tbTeamInfo.nEnemyFightTeam = 0;
    tbTeamInfo.nCalcResult = TeamPKMgr.tbDef.nPlayNone;
    tbTeamInfo.nIndex = nIndex;    

    local tbOneInfo = self.tbFightTeamPKLogicTimer[nIndex];
    if tbOneInfo then
        Timer:Close(tbOneInfo.nTimer);
        self.tbFightTeamPKLogicTimer[nIndex] = nil;
    end 

    local tbCurOneInfo = {};
    tbCurOneInfo.nIndex = nIndex;
    tbCurOneInfo.nFightTeamID = nFightTeamID;
    tbCurOneInfo.szCallType = "OnPlayFightOneWin";
    self.tbFightTeamPKLogicTimer[nIndex] = tbCurOneInfo;
    tbCurOneInfo.nTimer = Timer:Register(1, self.OnPlayFightOneWin, self, tbCurOneInfo, true); 
end

function tbBaseLogic:OnPlayFightOneWin(tbOneInfo, bClose)
    local nIndex = tbOneInfo.nIndex;
    local nFightTeamID = tbOneInfo.nFightTeamID;
    if bClose then
        self.tbFightTeamPKLogicTimer[nIndex] = nil;
    end
        
    self:OnWin(nIndex, nFightTeamID);
    local tbPreDef = tbPreGameMgr:GetPreDef()
    self:ForeachAllPlayerFightTeam(nFightTeamID, {self.OnPlayerReportData, self, TeamPKMgr.tbDef.nPlayWin, tbPreDef.nMatchEmptyTime});
    self:ForeachAllPlayerFightTeam(nFightTeamID, {self.PlayerPlayGameOneWin, self});
    self:OnPlayGameEnd(nIndex);
    Log("HSLJ Finals OnPlayFightOneWin", nIndex, nFightTeamID); 
end

function tbBaseLogic:PlayerPlayGameOneWin(pPlayer)
    local nFightTeamID = tbPreGameMgr:GetPlayerFightTeam(pPlayer);
    local tbFightTeam = tbPreGameMgr:GetFightTeamByID(nFightTeamID);
    if not tbFightTeam then
        return;
    end

    pPlayer.CenterMsg("對方戰隊沒有成員參加，系統判定本戰隊勝利", true);
end

function tbBaseLogic:OnPlayerReportData(nResult, nPlayTime, pPlayer)
    local tbData = {};
    if nResult == TeamPKMgr.tbDef.nPlayWin then
        tbData.nResult = Env.LogRound_SUCCESS;
    elseif nResult == TeamPKMgr.tbDef.nPlayFail then
        tbData.nResult = Env.LogRound_FAIL;
    elseif nResult == TeamPKMgr.tbDef.nPlayDogfall then
        tbData.nResult = Env.LogRound_DRAW;
    end
    
    tbData.nKillCount = 0;
    tbData.nDeathCount = 0;
    tbData.nPlayTime = nPlayTime;

    tbPreGameMgr:PlayerReportPkData(pPlayer, tbData)
end

function tbBaseLogic:PlayFightTeamTwo(nIndex, tbPlayInfo, nEndTime)
    local nFightTeamID1 = tbPlayInfo[1].nFightTeamID;
    local nFightTeamID2 = tbPlayInfo[2].nFightTeamID;

    local tbTeamInfo1 = self:GetApplyFightTeamInfo(nFightTeamID1);
    tbTeamInfo1.tbAllPlayerPKInfo = {};
    tbTeamInfo1.nEnemyFightTeam = nFightTeamID2;
    tbTeamInfo1.nCalcResult = TeamPKMgr.tbDef.nPlayNone;
    tbTeamInfo1.nIndex = nIndex;

    local tbTeamInfo2 = self:GetApplyFightTeamInfo(nFightTeamID2);
    tbTeamInfo2.tbAllPlayerPKInfo = {};
    tbTeamInfo2.nEnemyFightTeam = nFightTeamID1;
    tbTeamInfo2.nCalcResult = TeamPKMgr.tbDef.nPlayNone;
    tbTeamInfo2.nIndex = nIndex;

    local tbGameFormat = tbPreGameMgr:GetGameFormat()
    local szPKClass = tbGameFormat.szPKClass or "Normal";
    local funCallBack = self[szPKClass.."CreateFightTeamPK"];
    if funCallBack then
        funCallBack(self, nIndex, tbPlayInfo, nEndTime);
    end

    local tbTeamWatchInfo = {};
    local tbFightTeam1 = tbPreGameMgr:GetFightTeamByID(nFightTeamID1);
    local tbWatchData1 = {szName = tbFightTeam1:GetName(), nId = nFightTeamID1};  
    table.insert(tbTeamWatchInfo, tbWatchData1);  

    local tbFightTeam2 = tbPreGameMgr:GetFightTeamByID(nFightTeamID2);
    local tbWatchData2 = {szName = tbFightTeam2:GetName(), nId = nFightTeamID2};
    table.insert(tbTeamWatchInfo, tbWatchData2);  

    table.insert(self.tbFightTeamWatchInfo, tbTeamWatchInfo);    
end

function tbBaseLogic:NormalCreateFightTeamPK(nIndex, tbPlayInfo, nEndTime)
    local nFightTeamID1 = tbPlayInfo[1].nFightTeamID;
    local nFightTeamID2 = tbPlayInfo[2].nFightTeamID;
    local nEnterMapId = HuaShanLunJian:GetFinalsMapIDByIndex(1);

    local tbTeamInfo1 = self:GetApplyFightTeamInfo(nFightTeamID1);
    tbTeamInfo1.tbAllPlayerPKInfo = {};
    local tbTeamInfo2 = self:GetApplyFightTeamInfo(nFightTeamID2);
    tbTeamInfo2.tbAllPlayerPKInfo = {};

    for nPlayerID, _ in pairs(tbTeamInfo1.tbAllPlayer) do
        local tbInfo1 = {};
        tbInfo1.nMapId = nEnterMapId;
        tbInfo1.nResult = TeamPKMgr.tbDef.nPlayNone;
        tbTeamInfo1.tbAllPlayerPKInfo[nPlayerID] = tbInfo1;
    end
    
    for nPlayerID, _ in pairs(tbTeamInfo2.tbAllPlayer) do
        local tbInfo2 = {};
        tbInfo2.nMapId = nEnterMapId;
        tbInfo2.nResult = TeamPKMgr.tbDef.nPlayNone;
        tbTeamInfo2.tbAllPlayerPKInfo[nPlayerID] = tbInfo2;
    end

    local tbBaseLogicExt = self:GetNewFinalsPKLogic();
    local tbPlayLogic = Lib:NewClass(tbBaseLogicExt);
    tbPlayLogic:OnCreate(self, nEnterMapId, nIndex, tbPlayInfo, nEndTime);
    self.tbFightTeamPlayLogic[nIndex] = self.tbFightTeamPlayLogic[nIndex] or {};
    self.tbFightTeamPlayLogic[nIndex][nEnterMapId] = tbPlayLogic; 
end

function tbBaseLogic:GetNewFinalsPKLogic()
    local tbGameFormat = tbPreGameMgr:GetGameFormat();
    local szPKClass = tbGameFormat.szPKClass;
    local tbBaseLogicExt = nil;
    if not szPKClass then
        tbBaseLogicExt = tbFinalsPKLogic;
    else
        tbBaseLogicExt = HuaShanLunJian:GetFinalsPlayPKLogic(szPKClass);
    end

    return tbBaseLogicExt; 
end    

function tbBaseLogic:InitPlayDuelFighTeamInfo(nFightTeamID)
    local tbFightTeam = tbPreGameMgr:GetFightTeamByID(nFightTeamID);
    local tbTeamInfo = self:GetApplyFightTeamInfo(nFightTeamID);
    tbTeamInfo.tbAllPlayerPKInfo = {};

    for nPlayerID, _ in pairs(tbTeamInfo.tbAllPlayer) do
        local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
        if pPlayer then
            local nTeamNum = tbFightTeam:GetPlayerNum(nPlayerID);
            local tbShowInfo =
            {
                szName      = pPlayer.szName,
                nPortrait   = pPlayer.nPortrait,
                nLevel      = pPlayer.nLevel,
                nHonorLevel = pPlayer.nHonorLevel,
                nFaction    = pPlayer.nFaction,
                nFightPower = pPlayer.GetFightPower();
                nTeamPos    = nTeamNum;
                nResult     = 0; --用来显示的
            }

            local tbInfo = {};
            tbInfo.nMapId = -1;
            tbInfo.nResult = TeamPKMgr.tbDef.nPlayNone;
            tbInfo.nPlayTime = 0;
            tbInfo.tbShowInfo = tbShowInfo;
            tbTeamInfo.tbAllPlayerPKInfo[nPlayerID] = tbInfo;
        end
    end
end

function tbBaseLogic:PlayDuelCreateFightTeamPK(nIndex, tbPlayInfo, nEndTime)
    local nFightTeamID1 = tbPlayInfo[1].nFightTeamID;
    local nFightTeamID2 = tbPlayInfo[2].nFightTeamID;

    self:InitPlayDuelFighTeamInfo(nFightTeamID1);
    self:InitPlayDuelFighTeamInfo(nFightTeamID2);

    local tbGameFormat = tbPreGameMgr:GetGameFormat();
    local nTotalNum = tbGameFormat.nFightTeamCount;
    for nNum = 1, nTotalNum do
        self:PlayDuelFightTeamPK(nIndex, tbPlayInfo, nEndTime, nNum);
    end

    local tbUptateData = self.tbFightTeamPKLogicTimer[nIndex];
    if tbUptateData then
        Timer:Close(tbUptateData.nTimer);
        self.tbFightTeamPKLogicTimer[nIndex] = nil;
    end 

    local tbCurData = {};
    tbCurData.nIndex = nIndex;
    tbCurData.nFightTeamID1 = nFightTeamID1;
    tbCurData.nFightTeamID2 = nFightTeamID2;
    tbCurData.szCallType = "OnUpdateUpdateCalcPlayDuel";
    self.tbFightTeamPKLogicTimer[nIndex] = tbCurData;
    tbCurData.nTimer = Timer:Register(1, self.OnUpdateUpdateCalcPlayDuel, self, tbCurData, true, true); 
end

function tbBaseLogic:OnUpdateUpdateCalcPlayDuel(tbData, bClose, bGameEnd)
    local nIndex = tbData.nIndex;
    local nFightTeamID1 = tbData.nFightTeamID1;
    local nFightTeamID2 = tbData.nFightTeamID2;

    if bClose then
        self.tbFightTeamPKLogicTimer[nIndex] = nil;
    end
    
    self:UpdateCalcPlayDuelResult(nFightTeamID1, bGameEnd);
    self:UpdateCalcPlayDuelResult(nFightTeamID2, bGameEnd);
end

function tbBaseLogic:GetPlayDuelFightTeamWinTime(nFightTeamID)
    local tbTeamInfo = self:GetApplyFightTeamInfo(nFightTeamID);
    if not tbTeamInfo then
        return 0, 0;
    end

    local tbGameFormat = tbPreGameMgr:GetGameFormat();
    local nTotalNum = tbGameFormat.nFightTeamCount;
    local nWinCount = 0;
    local nTotalTime = 0;
    local nTeamCount = Lib:CountTB(tbTeamInfo.tbAllPlayerPKInfo)
    local tbPreDef = tbPreGameMgr:GetPreDef()
    for _, tbInfo in pairs(tbTeamInfo.tbAllPlayerPKInfo) do
        if tbInfo.nResult == TeamPKMgr.tbDef.nPlayWin then
            nWinCount = nWinCount + 1;
        end

        local nPlayTime = tbInfo.nPlayTime or tbPreDef.nMatchEmptyTime;
        nTotalTime = nTotalTime + nPlayTime;     
    end

    if nTotalNum > nTeamCount then
        nTotalTime = nTotalTime + (nTotalNum - nTeamCount) * tbPreDef.nMatchEmptyTime
    end

    nTotalTime = math.floor(nTotalTime / nTotalNum);
    return nWinCount, nTotalTime;  
end

function tbBaseLogic:UpdateCalcPlayDuelResult(nFightTeamID, bGameEnd)
    local tbTeamInfo1 = self:GetApplyFightTeamInfo(nFightTeamID);
    if not tbTeamInfo1 then
        return;
    end

    if tbTeamInfo1.nTimerCalcPlayDuel then
        Timer:Close(tbTeamInfo1.nTimerCalcPlayDuel);
        tbTeamInfo1.nTimerCalcPlayDuel = nil;
    end    

    local nFightTeamID1 = nFightTeamID;
    local nFightTeamID2 = tbTeamInfo1.nEnemyFightTeam;
    local tbTeamInfo2 = nil;
    if nFightTeamID2 > 0 then
        tbTeamInfo2 = self:GetApplyFightTeamInfo(nFightTeamID2);
    end

    if not tbTeamInfo2 then
        Log("Error HSLJ Finals UpdateCalcPlayDuelResult tbTeamInfo2", nFightTeamID);
        return;
    end

    if tbTeamInfo2.nTimerCalcPlayDuel then
        Timer:Close(tbTeamInfo2.nTimerCalcPlayDuel);
        tbTeamInfo2.nTimerCalcPlayDuel = nil;
    end 

    if tbTeamInfo1.nCalcResult ~= TeamPKMgr.tbDef.nPlayNone or tbTeamInfo2.nCalcResult ~= TeamPKMgr.tbDef.nPlayNone then
        return;
    end

    for _, tbInfo in pairs(tbTeamInfo1.tbAllPlayerPKInfo) do
        if tbInfo.nResult == TeamPKMgr.tbDef.nPlayNone then
            return;
        end
    end
    
    for _, tbInfo in pairs(tbTeamInfo2.tbAllPlayerPKInfo) do
        if tbInfo.nResult == TeamPKMgr.tbDef.nPlayNone then
            return;
        end        
    end

    local nWinCount1, nTotalTime1 = self:GetPlayDuelFightTeamWinTime(nFightTeamID1);
    local nWinCount2, nTotalTime2 = self:GetPlayDuelFightTeamWinTime(nFightTeamID2);
    local nWinTeamId;

    if nWinCount1 > nWinCount2 then
        self:SetDuelFightTeamResult(nFightTeamID1, TeamPKMgr.tbDef.nPlayWin, nTotalTime1);
        self:SetDuelFightTeamResult(nFightTeamID2, TeamPKMgr.tbDef.nPlayFail, nTotalTime2);
        nWinTeamId = nFightTeamID1;

    elseif nWinCount1 < nWinCount2 then
        self:SetDuelFightTeamResult(nFightTeamID1, TeamPKMgr.tbDef.nPlayFail, nTotalTime1);
        self:SetDuelFightTeamResult(nFightTeamID2, TeamPKMgr.tbDef.nPlayWin, nTotalTime2); 
        nWinTeamId = nFightTeamID2;

    elseif nWinCount2 == nWinCount1 then
        self:SetDuelFightTeamResult(nFightTeamID1, TeamPKMgr.tbDef.nPlayDogfall, nTotalTime1);
        self:SetDuelFightTeamResult(nFightTeamID2, TeamPKMgr.tbDef.nPlayDogfall, nTotalTime2); 

    else
        Log("Error HSLJ  Finals UpdateCalcPlayDuelResult", nFightTeamID1, nWinCount1, nFightTeamID2, nWinCount2);    
        return;
    end

    local tbAllTeamShowAccount = self:GetPlayerDuelAllShowInfo(nFightTeamID1, nFightTeamID2);
    if tbAllTeamShowAccount then
        local tbFinalsDef = self:GetFinalDef()
        self:ForeachPlayDuelFightTeam(nFightTeamID1, {self.ShowPlayerAccountLogic, self, tbAllTeamShowAccount, tbFinalsDef.nShowInfoPlayTeamTime});
        self:ForeachPlayDuelFightTeam(nFightTeamID2, {self.ShowPlayerAccountLogic, self, tbAllTeamShowAccount, tbFinalsDef.nShowInfoPlayTeamTime});
        if nWinTeamId then
            self:ForeachAllPlayerFightTeam(nWinTeamId, {self.SendWinPlayerMsg, self});
        end
    end
    
    if bGameEnd then
        self:OnPlayGameEnd(tbTeamInfo1.nIndex);
    end 
    Log("HSLJ Finals UpdateCalcPlayDuelResult", nFightTeamID1, nWinCount1, nFightTeamID2, nWinCount2);        
end

function tbBaseLogic:SetDuelFightTeamResult(nFightTeamID, nResult, nPlayTime)
    local tbTeamInfo = self:GetApplyFightTeamInfo(nFightTeamID);
    if not tbTeamInfo then
        return;
    end

   if tbTeamInfo.nCalcResult ~= TeamPKMgr.tbDef.nPlayNone then
        return;
    end

    local szResultMsg = nil;
    local nCurResult = nResult;
    if nCurResult == TeamPKMgr.tbDef.nPlayDogfall then
        local tbCurFinalsInfo = self:GetFinalsFightTeamByID(nFightTeamID);
        nCurResult = TeamPKMgr.tbDef.nPlayFail;

        if tbTeamInfo.nEnemyFightTeam then
            local tbFightTeam = tbPreGameMgr:GetFightTeamByID(tbTeamInfo.nEnemyFightTeam)
            local szFightTeamName = tbFightTeam:GetName();
            local tbFinalsInfo1 = self:GetFinalsFightTeamByID(tbTeamInfo.nEnemyFightTeam);
            if tbFinalsInfo1.nRank > tbCurFinalsInfo.nRank then
                nCurResult = TeamPKMgr.tbDef.nPlayWin;
                szResultMsg = string.format("本來是平局，由於本戰隊的預選賽排名比戰隊:「%s」高所以判定勝利", szFightTeamName or "-");
            else
                nCurResult = TeamPKMgr.tbDef.nPlayFail;
                szResultMsg = string.format("本來是平局，由於本戰隊的預選賽排名比戰隊:「%s」低所以判定失敗", szFightTeamName or "-");     
            end
        end          
    end 

    tbTeamInfo.nCalcResult = nCurResult;

    if nCurResult == TeamPKMgr.tbDef.nPlayWin then
        self:OnWin(tbTeamInfo.nIndex, nFightTeamID);

    elseif nCurResult == TeamPKMgr.tbDef.nPlayFail then
        self:OnFail(tbTeamInfo.nIndex, nFightTeamID);
  
    else    
        Log("Error HSLJ Finals SetDuelFightTeamResult Type", nFightTeamID, nCurResult, nResult, nPlayTime);
    end

    if szResultMsg and szResultMsg ~= "" then
        self:ForeachAllPlayerFightTeam(nFightTeamID, {self.PlayerBottomMsg, self, szResultMsg});
    end    
    Log("HSLJ Finals SetDuelFightTeamResult", nFightTeamID, nCurResult, nResult, nPlayTime);
end

function tbBaseLogic:PlayerBottomMsg(szMsg, pPlayer)
    pPlayer.Msg(szMsg);
end

function tbBaseLogic:GetPlayDuelTeamShowInfo(nFightTeamID)
    local tbTeamInfo = self:GetApplyFightTeamInfo(nFightTeamID);
    if not tbTeamInfo then
        return;
    end

    local tbFightTeam = tbPreGameMgr:GetFightTeamByID(nFightTeamID);
    if not tbFightTeam then
        return;
    end

    local tbTeamShowInfo = {};
    tbTeamShowInfo.tbAllPlayer = {};
    tbTeamShowInfo.szName = tbFightTeam:GetName();
    tbTeamShowInfo.nResult = tbTeamInfo.nCalcResult;

    for nPlayerId, tbPKInfo in pairs(tbTeamInfo.tbAllPlayerPKInfo) do
        tbPKInfo.tbShowInfo.nResult = tbPKInfo.nResult;
        table.insert(tbTeamShowInfo.tbAllPlayer, tbPKInfo.tbShowInfo);
    end 

    return tbTeamShowInfo;  
end

function tbBaseLogic:PlayDuelFightTeamPK(nIndex, tbPlayInfo, nEndTime, nNum)
    local nFightTeamID1 = tbPlayInfo[1].nFightTeamID;
    local nFightTeamID2 = tbPlayInfo[2].nFightTeamID;
    local tbFightTeam1 = tbPreGameMgr:GetFightTeamByID(nFightTeamID1);
    if not tbFightTeam1 then
        Log("Error HSLJ PlayDuelFightTeamPK tbFightTeam1", nFightTeamID1, nFightTeamID2);
        return;
    end

    local tbFightTeam2 = tbPreGameMgr:GetFightTeamByID(nFightTeamID2);
    if not tbFightTeam2 then
        Log("Error HSLJ PlayDuelFightTeamPK tbFightTeam2", nFightTeamID1, nFightTeamID2);
        return;
    end

    local tbTeamInfo1 = self:GetApplyFightTeamInfo(nFightTeamID1);
    local tbTeamInfo2 = self:GetApplyFightTeamInfo(nFightTeamID2);

    local nPlayer1 = tbFightTeam1:FindPlayerIDByNum(nNum);
    local tbPlayerPKInfo1 = nil;
    if nPlayer1 then
        tbPlayerPKInfo1 = tbTeamInfo1.tbAllPlayerPKInfo[nPlayer1];
    end
    
    local nPlayer2 = tbFightTeam2:FindPlayerIDByNum(nNum);
    local tbPlayerPKInfo2 = nil;
    if nPlayer2 then
        tbPlayerPKInfo2 = tbTeamInfo2.tbAllPlayerPKInfo[nPlayer2];
    end

    if not tbPlayerPKInfo1 or not tbPlayerPKInfo2 then
        local tbPreDef = tbPreGameMgr:GetPreDef()

        if tbPlayerPKInfo1 then
            self:SetPlayDuelPlayerResult(nFightTeamID1, nPlayer1, TeamPKMgr.tbDef.nPlayWin, tbPreDef.nMatchEmptyTime);
        end
        
        if tbPlayerPKInfo2 then
            self:SetPlayDuelPlayerResult(nFightTeamID2, nPlayer2, TeamPKMgr.tbDef.nPlayWin, tbPreDef.nMatchEmptyTime);
        end

        local tbAllTeamShowAccount = self:GetPlayerDuelAllShowInfo(nFightTeamID1, nFightTeamID2);
        if tbAllTeamShowAccount then
            local tbFinalsDef = self:GetFinalDef()
            if nPlayer1 and tbPlayerPKInfo1 then
                local pPlayer1 = KPlayer.GetPlayerObjById(nPlayer1);
                if pPlayer1 then
                    self:ShowPlayerAccountLogic(tbAllTeamShowAccount, tbFinalsDef.nShowInfoPlayTeamTime, pPlayer1);
                    pPlayer1.CenterMsg("本場比賽無戰鬥發生，直接產生結果", true);

                    self:OnPlayerReportData(TeamPKMgr.tbDef.nPlayWin, tbPreDef.nMatchEmptyTime, pPlayer1);
                end    
            end

            if nPlayer2 and tbPlayerPKInfo2 then
                local pPlayer2 = KPlayer.GetPlayerObjById(nPlayer2);
                if pPlayer2 then
                    self:ShowPlayerAccountLogic(tbAllTeamShowAccount, tbFinalsDef.nShowInfoPlayTeamTime, pPlayer2);
                    pPlayer2.CenterMsg("本場比賽無戰鬥發生，直接產生結果", true);

                    self:OnPlayerReportData(TeamPKMgr.tbDef.nPlayWin, tbPreDef.nMatchEmptyTime, pPlayer2);
                end    
            end
        end

        return;
    end
    
    local nEnterMapId = HuaShanLunJian:GetFinalsMapIDByIndex(nNum);
    tbPlayerPKInfo1.nMapId = nEnterMapId;
    tbPlayerPKInfo2.nMapId = nEnterMapId;

    local tbBaseLogicExt = self:GetNewFinalsPKLogic();
    local tbPlayLogic = Lib:NewClass(tbBaseLogicExt);
    tbPlayLogic:OnCreate(self, nEnterMapId, nIndex, tbPlayInfo, nEndTime);
    self.tbFightTeamPlayLogic[nIndex] = self.tbFightTeamPlayLogic[nIndex] or {};
    self.tbFightTeamPlayLogic[nIndex][nEnterMapId] = tbPlayLogic; 
end

function tbBaseLogic:SetPlayDuelPlayerResult(nFightTeamID, nPlayerID, nResult, nPlayTime)
    local tbTeamInfo = self:GetApplyFightTeamInfo(nFightTeamID);
    local tbPlayerPKInfo = tbTeamInfo.tbAllPlayerPKInfo[nPlayerID];
    if not tbPlayerPKInfo then
        return;
    end

    if tbPlayerPKInfo.nResult ~= TeamPKMgr.tbDef.nPlayNone then
        return;
    end    

    tbPlayerPKInfo.nResult = nResult;
    tbPlayerPKInfo.nPlayTime = nPlayTime;
    Log("HSLJ Finals SetPlayDuelPlayerResult", nFightTeamID, nPlayerID, nResult, nPlayTime);
end

function tbBaseLogic:GetPlayDuelPlayerMapID(nFightTeamID, nMapId)
    local tbTeamInfo = self:GetApplyFightTeamInfo(nFightTeamID);
    if not tbTeamInfo then
        return;
    end

    for nPlayerID, tbInfo in pairs(tbTeamInfo.tbAllPlayerPKInfo) do
        if tbInfo.nMapId == nMapId then
            return nPlayerID;
        end    
    end  
end

function tbBaseLogic:GetPlayerDuelAllShowInfo(nFightTeamID1, nFightTeamID2)
    local tbAllTeamShowAccount = {};
    local tbTeamShowInfo = self:GetPlayDuelTeamShowInfo(nFightTeamID1);
    if tbTeamShowInfo then
        tbAllTeamShowAccount[nFightTeamID1] = tbTeamShowInfo;
    end

    local tbTeamShowInfo2 = self:GetPlayDuelTeamShowInfo(nFightTeamID2);
    if tbTeamShowInfo2 then
        tbAllTeamShowAccount[nFightTeamID2] = tbTeamShowInfo2;
    end

    return tbAllTeamShowAccount;   
end

function tbBaseLogic:ShowPlayerAccountLogic(tbAllTeamShowAccount, nCloseTime, pPlayer)
    if not tbAllTeamShowAccount then
        return;
    end    

    local nFightTeamID = tbPreGameMgr:GetPlayerFightTeam(pPlayer);
    pPlayer.CallClientScript("Ui:OpenWindow", "HSLJAccount", tbAllTeamShowAccount, nFightTeamID, nCloseTime);
    --pPlayer.CallClientScript("Map:SetCloseUiOnLeave", pPlayer.nMapId, "HSLJAccount"); 
end

function tbBaseLogic:ForeachPlayDuelFightTeam(nFightTeamID, tbCallBack)
    local tbTeamInfo = self:GetApplyFightTeamInfo(nFightTeamID);
    if not tbTeamInfo then
        return;
    end

    local tbFinalsDef = self:GetFinalDef()
    for nPlayerID, _ in pairs(tbTeamInfo.tbAllPlayerPKInfo) do
        local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
        if pPlayer then
            local nMapTID = pPlayer.nMapTemplateId;
            if nMapTID == tbFinalsDef.nFinalsMapTID then
                Lib:MergeCallBack(tbCallBack, pPlayer);
            end
        end    
    end 
end    

function tbBaseLogic:OnStopPK(nState)
    self:CloseAllPlayLogic();

    Log("HSLJ Finals Map OnStopPK", nState);
end

--重载
function tbBaseLogic:OnKickOutAllPlayer(nState)
    self:ForeachAllPlayer({tbPreGameMgr.PlayerKickOut, tbPreGameMgr});
    Log("HSLJ Finals Map OnKickOutAllPlayer", nState);
end

function tbBaseLogic:GetAgainstPlanInfo(nPlan)
    local tbFinalsDef = self:GetFinalDef()
    return tbFinalsDef.tbAgainstPlan[nPlan];
end    

function tbBaseLogic:GetPlayGameState(nState)
    local tbFinalsDef = self:GetFinalDef()
    return tbFinalsDef.tbPlayGameState[nState];
end

function tbBaseLogic:CloseAllTimer()
    if self.nExecuteStateTimer then
        Timer:Close(self.nExecuteStateTimer);
        self.nExecuteStateTimer = nil;
    end    
end

function tbBaseLogic:OnClose()
    self:ForeachAllPlayer({tbPreGameMgr.PlayerKickOut, tbPreGameMgr});
    self:CloseAllTimer();
    Log("HSLJ Finals OnClose");
end

function tbBaseLogic:ForeachAllPlayer(tbCallBack)
    for nPlayerID, tbInfo in pairs(self.tbAllPlayerInfo) do
        local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
        if pPlayer and pPlayer.nMapId == tbInfo.nMapId then
            Lib:MergeCallBack(tbCallBack, pPlayer);
        end    
    end
end

function tbBaseLogic:ForeachAllPlayerFightTeam(nFightTeamID, tbCallBack)
    local tbApplyFightTeam = self:GetApplyFightTeamInfo(nFightTeamID);
    if not tbApplyFightTeam then
        return;
    end

    for nPlayerID, _ in pairs(tbApplyFightTeam.tbAllPlayer) do
        local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
        if pPlayer then
            local tbPlayerInfo = self:GetPlayerInfo(nPlayerID);
            if tbPlayerInfo and pPlayer.nMapId == tbPlayerInfo.nMapId then
                Lib:MergeCallBack(tbCallBack, pPlayer); 
            end
        end    
    end    
end

function tbBaseLogic:OnEnter(nMapId)
    self:AddPlayerCount()
    me.nInBattleState = 1; --战场模式
    me.bForbidChangePk = 1;
    me.nFightMode = 0;
    me.SetPkMode(Player.MODE_PEACE);
    local tbPlayerInfo = {};
    tbPlayerInfo.nReChangePartnerId = PlayerEvent:Register(me, "OnChangePartnerFightID", self.OnChangePartnerFightID, self);
    tbPlayerInfo.tbShowPartner = {};
    tbPlayerInfo.nMapId = nMapId;
    tbPlayerInfo.nWatchIndex = -1;
    self.tbAllPlayerInfo[me.dwID] = tbPlayerInfo;

    local pNpc = me.GetNpc();
    pNpc.AI_SetPlayerCanFollow(0);  

    self:ApplyFightTeamPlayer(me);
    self:UpdatePlayerRightMsg(true, me);
    self:UpdatePlayerShowUI(me);
    self:OnEnterMapPKLogic(me);
    Log("HSLJ Finals Map OnEnter", nMapId, me.dwID);
end

function tbBaseLogic:OnEnterMapPKLogic(pPlayer)
    local tbPKLogic = self:GetPlayerFightTeamPKLogic(pPlayer, pPlayer.nMapId);
    if not tbPKLogic then
        return;
    end

    tbPKLogic:OnEnterMap(pPlayer);     
end

function tbBaseLogic:OnLogin()
    self:ResetPlayerAllUI(me);
end

function tbBaseLogic:ResetPlayerAllUI(pPlayer)
    self:UpdatePlayerRightMsg(false, pPlayer);
    self:UpdatePlayerShowUI(pPlayer);
    self:SyncTeamPartnerInfo(pPlayer);
    
    if self.bFightTeamPK then
        local tbPKLogic = self:GetPlayerFightTeamPKLogic(pPlayer, pPlayer.nMapId);
        if tbPKLogic and pPlayer.nFightMode == 1 then
            tbPKLogic:OnStartAllTeamShowInfo(tbPKLogic.tbAllTeamShow, pPlayer);
            pPlayer.CallClientScript("Ui:CloseWindow", "BattleTopButton");  
        end
    end   
end


function tbBaseLogic:OnChangePartnerFightID()
    self:PlayerUpdatePartnerShowInfo(me);
end

function tbBaseLogic:OnLeave(nMapId)
    self:ReducePlayerCount()
    self:RemoveApplyFightTeamPlayer(me);

    local pNpc = me.GetNpc();
    if pNpc.IsDeath() then
        me.Revive(1);
    end

    pNpc.AI_SetPlayerCanFollow(1);
    pNpc.ClearAllSkillCD();
    pNpc.ClearForceSyncSet();
    me.nInBattleState = 0; --战场模式
    me.bForbidChangePk = 0;
    me.nFightMode = 0;
    me.SetPkMode(Player.MODE_PEACE);
    pNpc.StopDamageCounter();
    me.nCanLeaveMapId = nil;
    me.bHSLJQuitePKTeam = nil;
    CommonWatch:DoEndWatch(me);
    local tbPlayerInfo = self:GetPlayerInfo(me.dwID);
    if not tbPlayerInfo then
        return;
    end


    if tbPlayerInfo.nReChangePartnerId then
        PlayerEvent:UnRegister(me, "OnChangePartnerFightID", tbPlayerInfo.nReChangePartnerId);
        tbPlayerInfo.nReChangePartnerId = nil;
    end  

    self.tbAllPlayerInfo[me.dwID] = nil;    
    Log("HSLJ Finals Map OnLeave", nMapId, me.dwID);
end

function tbBaseLogic:OnPlayerTrap(nMapId, szTrapName)
    local _, _, nInNu = string.find(szTrapName, "watch_in(%d)");
    if nInNu then
        self:WatchInArea(me, tonumber(nInNu));
    end
    
    local _, _, nOutNu = string.find(szTrapName, "watch_out(%d)");
    if nOutNu then
        self:WatchOutArea(me, tonumber(nOutNu));
    end
end

function tbBaseLogic:WatchInArea(pPlayer, nNu)
    local tbGameFormat = tbPreGameMgr:GetGameFormat();
    if tbGameFormat.szPKClass and tbGameFormat.szPKClass == "PlayDuel" then
        return;
    end    

    local nCurPlan = self:GetCurPlan();
    local nLogicIndex = nNu;
    local tbFinalsDef = self:GetFinalDef()
    if nLogicIndex ~= 0 and nCurPlan == tbFinalsDef.nChampionPlan then
        return;
    end    

    if nLogicIndex == 0 and nCurPlan == tbFinalsDef.nChampionPlan then
        nLogicIndex = 1;
    end    

    local tbPKLogic = self:GetFightTeamLogic(nLogicIndex, pPlayer.nMapId);
    if not tbPKLogic then
        return;
    end

    local bRet = tbPKLogic:IsEndPKSate();
    if bRet then
        return;
    end

    tbPKLogic:AddWatchPlayer(pPlayer);
end

function tbBaseLogic:WatchOutArea(pPlayer, nNu)
    local nCurPlan = self:GetCurPlan();
    local nLogicIndex = nNu;
    local tbFinalsDef = self:GetFinalDef()
    if nLogicIndex == 0 and nCurPlan == tbFinalsDef.nChampionPlan then
        nLogicIndex = 1;
    end    

    local tbPKLogic = self:GetFightTeamLogic(nLogicIndex, pPlayer.nMapId);
    if not tbPKLogic then
        return;
    end

    tbPKLogic:RemoveWatchPlayer(pPlayer);

    local tbPlayerInfo = self:GetPlayerInfo(pPlayer.dwID);
    if tbPlayerInfo then
        tbPlayerInfo.nWatchIndex = -1;
    end 
end

function tbBaseLogic:CheckWatchPlayerByID(pSelfPlayer, nPlayerID)
    local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
    if not pPlayer then
        return false, "觀看不線上";
    end

    local tbPKLogic = self:GetPlayerFightTeamPKLogic(pPlayer);
    if not tbPKLogic then
        return false, "尚未開啟比賽";
    end

    if tbPKLogic.nMapId ~= pPlayer.nMapId then
        return false, "尚未開啟比賽!";
    end

    if tbPKLogic:IsEndPKSate() then
        return false, "比賽已經結束";
    end

    local tbPlayerInfo = self:GetPlayerInfo(pSelfPlayer.dwID);
    if not tbPlayerInfo then
        return false, "不能操作";
    end

    local tbFinalsDef = self:GetFinalDef()
    if pSelfPlayer.nMapTemplateId ~= tbFinalsDef.nFinalsMapTID then
        return false, "不在觀看地圖";
    end 

    return true, "", pPlayer, tbPKLogic;      
end

function tbBaseLogic:WatchPlayerByID(pPlayer, nPlayerID, bAutoFinsh)
    local bRet, szMsg, pWatchPlayer, tbPKLogic = self:CheckWatchPlayerByID(pPlayer, nPlayerID);
    if not bRet then
        pPlayer.CenterMsg(szMsg, true);
        return;
    end 

    local nWatchIndex = tbPKLogic:GetWatchArea();
    local tbPlayerInfo = self:GetPlayerInfo(pPlayer.dwID);
    if tbPlayerInfo.nWatchIndex ~= nWatchIndex or pPlayer.nMapId ~= tbPKLogic.nMapId then
        local tbFinalsDef = self:GetFinalDef()
        if pPlayer.nMapId ~= tbPKLogic.nMapId then
            local tbAllPos   = HuaShanLunJian:GetMapAllPosByTID(tbFinalsDef.nFinalsMapTID);
            local nTotalCount = #tbAllPos;
            local nRandIndex = MathRandom(nTotalCount);
            local tbEnterPos = tbAllPos[nRandIndex];
            pPlayer.SwitchMap(tbPKLogic.nMapId, tbEnterPos.PosX, tbEnterPos.PosY);
            bAutoFinsh = false;
        end

        if bAutoFinsh then
            tbPKLogic:AddWatchPlayer(pPlayer, true);
            local pWatchNpc = pWatchPlayer.GetNpc();
            pPlayer.CallClientScript("CommonWatch:DoStartWatch", pWatchNpc.nId);
            tbPlayerInfo.nWatchIndex = nWatchIndex;
        else
            local tbAllPos1   = HuaShanLunJian:GetWatchPosByArea(tbFinalsDef.nFinalsMapTID, nWatchIndex);
            local nTotalCount1 = #tbAllPos1;
            local nRandIndex1 = MathRandom(nTotalCount1);
            local tbEnterPos1 = tbAllPos1[nRandIndex1];

            local tbAutoData = {};
            tbAutoData.szType = "HSLJ";
            tbAutoData.nMapId = tbPKLogic.nMapId;
            tbAutoData.nDstX = tbEnterPos1.PosX;
            tbAutoData.nDstY = tbEnterPos1.PosY;
            tbAutoData.nMapTemplateId = pPlayer.nMapTemplateId;
            tbAutoData.tbParam = {nPlayerID};

            pPlayer.CallClientScript("CommonWatch:AutoPathWatch", tbAutoData);         
        end    
    else
        local pWatchNpc = pWatchPlayer.GetNpc();
        pPlayer.CallClientScript("CommonWatch:DoStartWatch", pWatchNpc.nId);    
    end    
end

--重载
function tbBaseLogic:AddPlayerCount(pPlayer)
    self.nPlayerEnterCount = self.nPlayerEnterCount + 1;
end

--重载
function tbBaseLogic:ReducePlayerCount(pPlayer) --武林大会就只是控制检查观众人数
    self.nPlayerEnterCount = self.nPlayerEnterCount - 1;
end

-- --重载
function tbBaseLogic:AddApplyPlayerCount()
    self.nApplyPlayerCount = self.nApplyPlayerCount + 1
end

-- --重载
function tbBaseLogic:ReduceApplyPlayerCount()
    self.nApplyPlayerCount = self.nApplyPlayerCount - 1
end

function tbBaseLogic:GetPlayerCount()
    return self.nPlayerEnterCount;
end

function tbBaseLogic:GetApplyPlayerCount()
    return self.nApplyPlayerCount;
end

function tbBaseLogic:GetApplyFightTeamInfo(nFightTeamID)
    local tbTeamInfo =  self.tbApplyFightTeam[nFightTeamID];
    if tbTeamInfo then
        return tbTeamInfo;
    end

    if nFightTeamID <= 0 then
        return;
    end

    local tbFinalsInfo = self:GetFinalsFightTeamByID(nFightTeamID);
    if not tbFinalsInfo then
        return;
    end

    local tbFightTeam = tbPreGameMgr:GetFightTeamByID(nFightTeamID);
    if not tbFightTeam then
        return;
    end

    if not tbTeamInfo then
        tbTeamInfo = 
        {
            nFightTeamID = nFightTeamID;
            tbAllPlayer  = {};
            nTeamId      = 0;

            tbAllPlayerPKInfo = {};
            nEnemyFightTeam = 0;
            nCalcResult = TeamPKMgr.tbDef.nPlayNone;
        };

        self.tbApplyFightTeam[nFightTeamID] = tbTeamInfo;
    end

    return tbTeamInfo;
end

function tbBaseLogic:GetPlayerInfo(nPlayerID)
    return self.tbAllPlayerInfo[nPlayerID];    
end

function tbBaseLogic:ApplyFightTeamPlayer(pPlayer)
    local nFightTeamID = tbPreGameMgr:GetPlayerFightTeam(pPlayer);
    if nFightTeamID <= 0 then
        return;
    end

    local tbFinalsInfo = self:GetFinalsFightTeamByID(nFightTeamID);
    if not tbFinalsInfo then
        return;
    end

    local tbFightTeam = tbPreGameMgr:GetFightTeamByID(nFightTeamID);
    if not tbFightTeam then
        Log("Error HSLJ ApplyFightTeamPlayer", pPlayer.dwID, nFightTeamID);
        return;
    end

    if not tbFightTeam:HavePlayerID(pPlayer.dwID) then
        Log("Error HSLJ ApplyFightTeamPlayer HavePlayerID", pPlayer.dwID, nFightTeamID);   
        return;
    end

    local tbTeamInfo = self:GetApplyFightTeamInfo(nFightTeamID);
    if tbTeamInfo.tbAllPlayer[pPlayer.dwID] then
        tbTeamInfo.tbAllPlayer[pPlayer.dwID] = nil;
        Log("Error HSLJ Finals ApplyFightTeamPlayer Have Player", nFightTeamID, pPlayer.dwID);
    end    

    local nCurTeamCount = Lib:CountTB(tbTeamInfo.tbAllPlayer);
    if nCurTeamCount <= 0 or tbTeamInfo.nTeamId <= 0 then
        if pPlayer.dwTeamID <= 0 then
            TeamMgr:Create(pPlayer.dwID, pPlayer.dwID);     
        end

        tbTeamInfo.nTeamId = pPlayer.dwTeamID;  
    else
        if pPlayer.dwTeamID ~= tbTeamInfo.nTeamId then
            local tbTeam = TeamMgr:GetTeamById(tbTeamInfo.nTeamId);
            if tbTeam then
                local nCaptainId = tbTeam:GetCaptainId();
                local bRet = TeamMgr:DirectAddMember(nCaptainId, pPlayer);
                if not bRet then
                    Log("Error Finals DirectAddMember", pPlayer.dwID);
                end
            end        
        end   
    end

    local tbTeam = TeamMgr:GetTeamById(tbTeamInfo.nTeamId);
    if tbTeam then
        local tbMember = tbTeam:GetMembers();
        local tbQuiteTeam = {};
        for _, nPlayerID in pairs(tbMember) do
            local pMember = KPlayer.GetPlayerObjById(nPlayerID);
            if pMember then
                local nMemberTeamID = tbPreGameMgr:GetPlayerFightTeam(pMember);
                if nMemberTeamID ~= nFightTeamID then
                    tbQuiteTeam[nPlayerID] = pMember;
                end
            end
        end

        for _, pMember in pairs(tbQuiteTeam) do
            TeamMgr:QuiteTeam(pMember.dwTeamID, pMember.dwID);
        end   
    end
        
    tbTeamInfo.tbAllPlayer[pPlayer.dwID] = 1;
    self:AddApplyPlayerCount()

    self:PlayerUpdatePartnerShowInfo(pPlayer);
    self:SyncTeamPartnerInfo(pPlayer);
    --tbPreGameMgr:SetPlayerTeamTitle(pPlayer, 1);
    Log("HSLJ Finals ApplyFightTeamPlayer", pPlayer.dwID, nFightTeamID, nCurTeamCount + 1);
end

function tbBaseLogic:PlayerUpdatePartnerShowInfo(pPlayer, tbTeamPKInst)
    local tbGameFormat = tbPreGameMgr:GetGameFormat();
    if not tbGameFormat.bOpenPartner then 
        return;
    end

    local nFightTeamID = tbPreGameMgr:GetPlayerFightTeam(pPlayer);
    if nFightTeamID <= 0 then
        return;
    end

    local tbFinalsInfo = self:GetFinalsFightTeamByID(nFightTeamID);
    if not tbFinalsInfo then
        return;
    end    

    local tbPlayerInfo = self:GetPlayerInfo(pPlayer.dwID);
    if not tbPlayerInfo then
        return;
    end

    local nPartnerID = pPlayer.GetFightPartnerID();
    if nPartnerID <= 0 then
        return;
    end

    local tbCurPartner = pPlayer.GetPartnerInfo(nPartnerID);
    if not tbCurPartner then
        return;
    end

    local tbInfo = {};
    tbInfo.nNpcTemplateId =  tbCurPartner.nNpcTemplateId;
    tbInfo.nQualityLevel = tbCurPartner.nQualityLevel;
    tbInfo.nLevel = tbCurPartner.nLevel;
    tbInfo.nFightPower = tbCurPartner.nFightPower;

    if tbTeamPKInst ~= nil then
        local tbAllPartner = tbTeamPKInst:GetPlayerAllPartner(pPlayer.dwID);
        for nNpcId, tbPartnerInfo in pairs(tbAllPartner) do
            tbInfo.nNpcId = nNpcId;
            tbInfo.bDeath = tbPartnerInfo.bIsDeath;
            break;
        end
    end
        
    tbPlayerInfo.tbShowPartner = tbInfo;
    self:ForeachAllPlayerFightTeam(nFightTeamID, {self.OnSyncPartnerInfo, self, tbPlayerInfo.tbShowPartner, pPlayer.dwID});
end

function tbBaseLogic:OnSyncPartnerInfo(tbShowPartner, nPlayerID, pPlayer)
    pPlayer.CallClientScript("Player:ServerSyncData", string.format("TeamPartner:%s", nPlayerID), tbShowPartner);    
end

function tbBaseLogic:SyncTeamPartnerInfo(pPlayer)
    local tbGameFormat = tbPreGameMgr:GetGameFormat();
    if not tbGameFormat.bOpenPartner then 
        return;
    end

    local nFightTeamID = tbPreGameMgr:GetPlayerFightTeam(pPlayer);
    if nFightTeamID <= 0 then
        return;
    end    

    local tbTeamInfo = self:GetApplyFightTeamInfo(nFightTeamID);
    if not tbTeamInfo then
        return;
    end

    for nPlayerID, _ in pairs(tbTeamInfo.tbAllPlayer) do
        if nPlayerID ~= pPlayer.dwID then
            local tbPlayerInfo = self:GetPlayerInfo(nPlayerID);
            if tbPlayerInfo then
                pPlayer.CallClientScript("Player:ServerSyncData", string.format("TeamPartner:%s", nPlayerID), tbPlayerInfo.tbShowPartner); 
            end     
        end    
    end 
end

function tbBaseLogic:RemoveApplyFightTeamPlayer(pPlayer)
    local nFightTeamID = tbPreGameMgr:GetPlayerFightTeam(pPlayer);
    if nFightTeamID <= 0 then
        return;
    end

    local tbTeamInfo = self:GetApplyFightTeamInfo(nFightTeamID);
    if not tbTeamInfo then
        return;
    end

    if tbTeamInfo.tbAllPlayer[pPlayer.dwID] then
        tbTeamInfo.tbAllPlayer[pPlayer.dwID] = nil;
    end

    local bQuiteTeam = true;
    if pPlayer.bHSLJQuitePKTeam then
        bQuiteTeam = false;
        pPlayer.bHSLJQuitePKTeam = nil;  
    end    

    if pPlayer.dwTeamID ~= 0 and bQuiteTeam then
        TeamMgr:QuiteTeam(pPlayer.dwTeamID, pPlayer.dwID);
    end

    self:ReduceApplyPlayerCount()
    local nCurTeamCount = Lib:CountTB(tbTeamInfo.tbAllPlayer);

    self:FightTeamPlayerLeaveMap(pPlayer);
    tbPreGameMgr:ClearPlayerTeamTitle(pPlayer);
    Log("HSLJ RemoveApplyFightTeamPlayer", pPlayer.dwID, nFightTeamID, nCurTeamCount);     
end

function tbBaseLogic:FightTeamPlayerLeaveMap(pPlayer)
    local tbPKLogic = self:GetPlayerFightTeamPKLogic(pPlayer, pPlayer.nMapId);
    if not tbPKLogic then 
        return;
    end

    local tbPlayerInfo = tbPKLogic:GetPlayerPKInfo(pPlayer);
    if not tbPlayerInfo then
        return;
    end

    local tbFightTeamInfo = tbPKLogic:GetPlayFightTeam(nFightTeamID);
    if tbFightTeamInfo then
        tbFightTeamInfo.tbAllPlayer[pPlayer.dwID] = nil;
    end 
end

function tbBaseLogic:GetPlayerFightTeamPKLogic(pPlayer, nMapId)
    local nFightTeamID = tbPreGameMgr:GetPlayerFightTeam(pPlayer);
    if nFightTeamID <= 0 then
        return;
    end

    if not self.bFightTeamPK then
        return;
    end

    local nIndex = self.tbPlayingFightTeamID[nFightTeamID]; 
    if not nIndex then  
        return;
    end

    if not nMapId then
        local tbTeamInfo = self:GetApplyFightTeamInfo(nFightTeamID);
        if not tbTeamInfo then
            return;
        end

        local tbPlayerPKInfo = tbTeamInfo.tbAllPlayerPKInfo[pPlayer.dwID];
        if not tbPlayerPKInfo or not tbPlayerPKInfo.nMapId then
            return;
        end

        nMapId = tbPlayerPKInfo.nMapId;
    end   

    local tbPKLogic = self:GetFightTeamLogic(nIndex, nMapId);
    if not tbPKLogic then 
        return;
    end

    return tbPKLogic;
end

-------------------===============
function tbFinalsPKLogic:OnCreate(tbMapLogic, nMapLogicId, nIndex, tbPlayInfo, nEndTime)
    self.tbMapLogic = tbMapLogic;
    self.nIndex = nIndex;
    self.nEndTime = nEndTime or 0;
    self.tbPlayFightTeam = {};
    self.tbPlayTeamFightID = {};
    self.tbAllTeamShowAccount = {};
    self.tbAllWatchPlayer = {};
    self.nMapId = nMapLogicId;

    if self.InitInfo then
        self:InitInfo();
    end    

    self.tbTeamPKInst = TeamPKMgr:CreatePkLogic(string.format("HSLJFinalsPK:%s", nIndex), self.nEndTime);
    local tbGameFormat = tbPreGameMgr:GetGameFormat();
    if tbGameFormat.szPKClass and tbGameFormat.szPKClass == "PlayDuel" then
        self.tbTeamPKInst:SetFunPKEndType("PlayerNpc");
    end   
    
    self.tbTeamPKInst:SetPlayerToNpcDmg(tbDef.fPlayerToNpcDmg);
    self.tbTeamPKInst:RegOnEnd({self.PlayGameEnd, self});
    self.tbTeamPKInst:RegTeamResult({self.OnTeamResult, self});
    self.tbTeamPKInst:RegOnPartnerDeath({self.OnPartnerDeath, self});
    self.bKickOutAllPlayer = false;
    local nPKTeamID = 0;
    for _, tbInfo in pairs(tbPlayInfo) do
        nPKTeamID = nPKTeamID + 1;
        if tbInfo.nFightTeamID > 0 then
            self:AddPlayFightTeam(nPKTeamID, tbInfo);
        end

        self.tbPlayTeamFightID[nPKTeamID] = tbInfo.nFightTeamID;
        Log("HSLJ OnCreate FinalsPKLogic", self.nIndex, nPKTeamID, tbInfo.nFightTeamID);     
    end

    self:ForeachAllPlayer({self.ShowInfoRMsg, self, "準備開始"});
    self:UpdateAllPlayerAccount();

    local tbFinalsDef = tbBaseLogic:GetFinalDef();
    self:ForeachAllPlayer({self.ShowPlayerAccount, self, tbFinalsDef.nShowInfoPlayTeamTime});
    self:ForeachAllPlayer({self.TeamShowPartner, self, true});
    self:ForeachAllPlayer({self.PlayerUpdatePartnerShowInfo, self});
    self:ForeachAllPlayer({self.AddToForceSyncPlayer, self});
    self:ForeachAllPlayer({self.CloseLeavePanelUi, self});
    self:CloseOneTimer();
    self.nOneTimer = Timer:Register(tbFinalsDef.nShowInfoPlayTeamTime * Env.GAME_FPS, self.OnDelayStart, self); 
end

function tbFinalsPKLogic:CloseLeavePanelUi(pPlayer)
    pPlayer.CallClientScript("Ui:CloseWindow", "QYHLeavePanel");
end

function tbFinalsPKLogic:AddToForceSyncPlayer(pPlayer)
    local pNpc = pPlayer.GetNpc();
    if not pNpc then
        return;
    end

    for _, tbTeamInfo in pairs(self.tbPlayFightTeam) do
        for nPlayerID, _ in pairs(tbTeamInfo.tbAllPlayer) do
            if nPlayerID ~= pPlayer.dwID then
                local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
                if pPlayer then
                    pNpc.AddToForceSyncSet(nPlayerID);
                end    
            end    
        end    
    end 
end

function tbFinalsPKLogic:OnPartnerDeath(nPlayerID, pKiller)
    local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
    if pPlayer then
        self:PlayerUpdatePartnerShowInfo(pPlayer);
    end    

    Log("HSLJ Pre Play Map OnPartnerDeath", nPlayerID, him.szName);
end

function tbFinalsPKLogic:PlayerUpdatePartnerShowInfo(pPlayer)
    self.tbMapLogic:PlayerUpdatePartnerShowInfo(pPlayer, self.tbTeamPKInst);
end

function tbFinalsPKLogic:ShowPlayerAccount(nCloseTime, pPlayer)
    if not self.tbAllTeamShowAccount then
        return;
    end    

    local nFightTeamID = tbPreGameMgr:GetPlayerFightTeam(pPlayer);
    pPlayer.CallClientScript("Ui:OpenWindow", "HSLJAccount", self.tbAllTeamShowAccount, nFightTeamID, nCloseTime);
    pPlayer.CallClientScript("Map:SetCloseUiOnLeave", pPlayer.nMapId, "HSLJAccount"); 
end

function tbFinalsPKLogic:OnDelayStart()
    self:CloseOneTimer();
    local tbFinalsDef = tbBaseLogic:GetFinalDef();
    self.nOneTimer = Timer:Register(tbFinalsDef.nPlayDelayTime * Env.GAME_FPS, self.OnDelayDoStart, self);
    self:ForeachAllPlayer({self.PlayerDelayStart, self}); 
end

function tbFinalsPKLogic:TeamShowPartner(bForbid, pPlayer)
    local tbGameFormat = tbPreGameMgr:GetGameFormat();
    if not tbGameFormat.bOpenPartner then
        return;
    end

    pPlayer.CallClientScript("Player:ServerSyncData", "TeamShowPartner", {nMapTID = pPlayer.nMapTemplateId, bForbid = bForbid});
end

function tbFinalsPKLogic:PlayerDelayStart(pPlayer)
    pPlayer.CallClientScript("Ui:OpenWindow", "ReadyGo");
end   

function tbFinalsPKLogic:OnDelayDoStart()
    self:CloseOneTimer();
    self:CloseDmgTimer();
    self.nUpdateDmageTimer = Timer:Register(tbDef.nUpateDmgTime * Env.GAME_FPS, self.UpdateAllTeamShowInfo, self);

    self.tbTeamPKInst:DoStart();

    self.tbAllTeamShow = self:GetAllTeamShowInfo();
    self:ForeachAllPlayer({self.OnStartAllTeamShowInfo, self, self.tbAllTeamShow});
    self:ForeachAllPlayer({self.SetPlayerAiActive, self, 1});
end

function tbFinalsPKLogic:CloseHomeScreenTask(bClose, pPlayer)
    local tbGameFormat = tbPreGameMgr:GetGameFormat();
    if tbGameFormat.szPKClass and tbGameFormat.szPKClass == "PlayDuel" then
        if bClose then
            pPlayer.CallClientScript("Ui:ForbidShowUI", "HomeScreenTask", pPlayer.nMapTemplateId, true);
        else
            pPlayer.CallClientScript("Ui:ForbidShowUI", "HomeScreenTask", pPlayer.nMapTemplateId, false);
            pPlayer.CallClientScript("Ui:OpenWindow", "HomeScreenTask");
        end    
    end
end

function tbFinalsPKLogic:SetPlayerAiActive(nState, pPlayer)
    local pNpc = pPlayer.GetNpc();
    if not pNpc then
        return;
    end    
    --pNpc.AI_SetPlayerCanFollow(nState); 
end

function tbFinalsPKLogic:CloseDmgTimer()
    if self.nUpdateDmageTimer then
        Timer:Close(self.nUpdateDmageTimer);
        self.nUpdateDmageTimer = nil;
    end    
end

function tbFinalsPKLogic:UpdateAllTeamShowInfo()
    self.tbAllTeamShow = self:GetAllTeamShowInfo();
    self:ForeachAllPlayer({self.OnAllTeamShowInfo, self, self.tbAllTeamShow});

    return true;
end

function tbFinalsPKLogic:OnAllTeamShowInfo(tbShowInfo, pPlayer)

    pPlayer.CallClientScript("Player:ServerSyncData", "PlayAllTeam", tbShowInfo);
end

function tbFinalsPKLogic:OnStartAllTeamShowInfo(tbShowInfo, pPlayer)
    local nTime = self.tbTeamPKInst:GetEndResidueTime();
    if nTime <= 0 then
        return;
    end

    local nFightTeamID = tbPreGameMgr:GetPlayerFightTeam(pPlayer);
    local tbAllTeamInfo = {};
    tbAllTeamInfo.nTime = nTime;
    tbAllTeamInfo.nTeam = nFightTeamID;
    tbAllTeamInfo.tbAllTeam = tbShowInfo;
    tbAllTeamInfo.nMapTID = pPlayer.nMapTemplateId;

    pPlayer.CallClientScript("Ui:OpenWindow", "HSLJBattleInfo", "Play", tbAllTeamInfo);
    pPlayer.CallClientScript("Ui:CloseWindow", "QYHLeavePanel");
    self:CloseHomeScreenTask(true, pPlayer);
end

function tbFinalsPKLogic:GetAllTeamShowInfo()
    local tbAllShowInfo = {};
    for nFightTeamID, tbTeamInfo in pairs(self.tbPlayFightTeam) do
        local tbInfo = {};
        tbInfo.nDamage = self.tbTeamPKInst:GetTeamTotalDmg(tbTeamInfo.nPKTeamID);
        tbInfo.nPartner = self.tbTeamPKInst:GetTeamPartnerCount(tbTeamInfo.nPKTeamID);
        tbInfo.nKill = self.tbTeamPKInst:GetTeamKillPlayerCount(tbTeamInfo.nPKTeamID);
        tbAllShowInfo[nFightTeamID] = tbInfo;
    end

    return tbAllShowInfo;    
end

function tbFinalsPKLogic:PlayGameEnd()
    self:ForeachAllPlayer({self.ShowInfoRMsg, self, "結算"});
    self:UpdateAllPlayerAccount(true);
    local tbFinalsDef = tbBaseLogic:GetFinalDef();
    self:ForeachAllPlayer({self.ShowPlayerAccount, self, tbFinalsDef.nShowInfoPlayTeamTime});
    self:CloseOneTimer();
    self.nOneTimer = Timer:Register(tbFinalsDef.nEndDelayLeaveMap * Env.GAME_FPS, self.DoAllPlayerKickOut, self);

    for nPlayerID, _ in pairs(self.tbAllWatchPlayer) do
        local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
        if pPlayer and pPlayer.nMapId == self.nMapId then
            CommonWatch:DoEndWatch(pPlayer);
        end    
    end

    self.tbAllWatchPlayer = {};

    if self.PlayGameEndExt then
        self:PlayGameEndExt();
    end

    self.tbMapLogic:OnPlayGameEnd(self.nIndex);
end

function tbFinalsPKLogic:ShowInfoRMsg(szRMsg, pPlayer)
    local tbShowInfo = {}
    tbShowInfo.szShow = szRMsg;
    tbShowInfo.nMapTID = pPlayer.nMapTemplateId;
    pPlayer.CallClientScript("Ui:OpenWindow", "HSLJBattleInfo", "ShowInfo", tbShowInfo);
end

function tbFinalsPKLogic:DoAllPlayerKickOut()
    self:CloseOneTimer();

    if not self.bKickOutAllPlayer then  
        self.bKickOutAllPlayer = true;
        self:ForeachAllPlayer({self.KickOutPlayer, self});
    end
end

function tbFinalsPKLogic:OnTeamResult(nTeamId, nPlayState)
    local nFightTeamID = self.tbPlayTeamFightID[nTeamId];
    if nFightTeamID <= 0 then
        return;
    end

    local nCurPlayState = nPlayState;
    if nCurPlayState == TeamPKMgr.tbDef.nPlayDogfall then
        local tbCurFinalsInfo = tbBaseLogic:GetFinalsFightTeamByID(nFightTeamID);
        nCurPlayState = TeamPKMgr.tbDef.nPlayFail;

        for _, nFightTeamID1 in pairs(self.tbPlayTeamFightID) do
            if nFightTeamID1 ~= nFightTeamID then
                local tbFinalsInfo1 = tbBaseLogic:GetFinalsFightTeamByID(nFightTeamID1);
                if tbFinalsInfo1.nRank > tbCurFinalsInfo.nRank then
                    nCurPlayState = TeamPKMgr.tbDef.nPlayWin;
                end   
            end    
        end    
    end
    
    local tbFightTeamInfo = self:GetPlayFightTeam(nFightTeamID)
    tbFightTeamInfo.nResultState = nCurPlayState 
    if nCurPlayState == TeamPKMgr.tbDef.nPlayWin then
        self:DoWin(nFightTeamID);
    elseif nCurPlayState == TeamPKMgr.tbDef.nPlayFail then
        self:DoFail(nFightTeamID);
    end

    Log("HSLJ FinalsPKLogic", self.nIndex, nTeamId, nPlayState, nCurPlayState);
end

function tbFinalsPKLogic:DoWin(nFightTeamID)
    self.tbMapLogic:OnWin(self.nIndex, nFightTeamID);
    self:ForeachFightTeamPlayer(nFightTeamID, {self.SetPlayerMatch, self, Env.LogRound_SUCCESS});
    self:ForeachFightTeamPlayer(nFightTeamID, {self.OnPlayerReportData, self, TeamPKMgr.tbDef.nPlayWin});  
end

function tbFinalsPKLogic:OnPlayerReportData(nResult, pPlayer)
    local tbData = {};
    if nResult == TeamPKMgr.tbDef.nPlayWin then
        tbData.nResult = Env.LogRound_SUCCESS;
    elseif nResult == TeamPKMgr.tbDef.nPlayFail then
        tbData.nResult = Env.LogRound_FAIL;
    elseif nResult == TeamPKMgr.tbDef.nPlayDogfall then
        tbData.nResult = Env.LogRound_DRAW;
    end
    
    local tbPKInfo = self.tbTeamPKInst:GetPlayerInfo(pPlayer.dwID);
    if not tbPKInfo then
        return;
    end    

    tbData.nKillCount = tbPKInfo.nKillPlayerCount or 0;
    tbData.nDeathCount = 0;
    if tbPKInfo.bIsDeath then
        tbData.nDeathCount = 1;
    end 

    tbData.nPlayTime = self.tbTeamPKInst:GetPlayTotalTime();
    tbPreGameMgr:PlayerReportPkData(pPlayer, tbData);
end

function tbFinalsPKLogic:SetPlayerMatch(nResult, pPlayer)
    local tbPlayerInfo = self:GetPlayerPKInfo(pPlayer);
    if not tbPlayerInfo then
        return;
    end

    local nMatchTime = tbPlayerInfo.nMatchTime or 0;
    local nCurTime = GetTime() - nMatchTime;
    local tbLogData =
    {
        Result = nResult;
        nMatchTime = nCurTime;
    };
    pPlayer.ActionLog(Env.LogType_Athletics, Env.LogWay_HSLJFinalsGame, tbLogData);  --TODO WLDH tlog
end


function tbFinalsPKLogic:DoFail(nFightTeamID)
    self.tbMapLogic:OnFail(self.nIndex, nFightTeamID);
    self:ForeachFightTeamPlayer(nFightTeamID, {self.SetPlayerMatch, self, Env.LogRound_FAIL});
    self:ForeachFightTeamPlayer(nFightTeamID, {self.OnPlayerReportData, self, TeamPKMgr.tbDef.nPlayFail});  
end

function tbFinalsPKLogic:KickOutPlayer(pPlayer)
    self.tbTeamPKInst:ClearPlayer(pPlayer);
    self.tbMapLogic:PlayerUpdatePartnerShowInfo(pPlayer);
    self.tbMapLogic:UpdatePlayerRightMsg(true, pPlayer);
    self.tbMapLogic:UpdatePlayerShowUI(pPlayer);
    self:SetPlayerAiActive(0, pPlayer);
    local pNpc = pPlayer.GetNpc();
    pNpc.ClearAllSkillCD();
    pNpc.ClearForceSyncSet();
    local tbFinalsDef = tbBaseLogic:GetFinalDef();
    local tbAllPos   = HuaShanLunJian:GetMapAllPosByTID(tbFinalsDef.nFinalsMapTID);
    local nTotalCount = #tbAllPos;
    local nRandIndex = MathRandom(nTotalCount);
    local tbEnterPos = tbAllPos[nRandIndex];
    local nMainID = HuaShanLunJian:GetFinalsMapIDByIndex(1);
    if nMainID == self.nMapId then
        pPlayer.SetPosition(tbEnterPos.PosX, tbEnterPos.PosY);
    else
        pPlayer.bHSLJQuitePKTeam = true;
        pPlayer.SwitchMap(nMainID, tbEnterPos.PosX, tbEnterPos.PosY);
    end    
    tbPreGameMgr:ClearPlayerTeamTitle(pPlayer);
    self:CloseHomeScreenTask(false, pPlayer);
end

function tbFinalsPKLogic:UpdateAllPlayerAccount(bResult)
    local tbAllTeamShow = {};
    for nCurTeamID, tbPlayInfo in pairs(self.tbPlayFightTeam) do
        local tbFightTeam = tbPreGameMgr:GetFightTeamByID(nCurTeamID);
        local tbTeamShowInfo = {};
        tbTeamShowInfo.tbAllPlayer = {};
        tbTeamShowInfo.szName = tbFightTeam:GetName();

        if bResult and self.tbTeamPKInst then
            tbTeamShowInfo.nResult = tbPlayInfo.nResultState or 0;
        end    

        for nPlayerID, _ in pairs(tbPlayInfo.tbAllPlayer) do

            local tbShowInfo = {};
            local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
            if pPlayer then
                tbShowInfo.szName      = pPlayer.szName;
                tbShowInfo.nPortrait   = pPlayer.nPortrait;
                tbShowInfo.nLevel      = pPlayer.nLevel;
                tbShowInfo.nHonorLevel = pPlayer.nHonorLevel;
                tbShowInfo.nFaction    = pPlayer.nFaction;
                tbShowInfo.nFightPower = pPlayer.GetFightPower();
            end    


            if bResult and self.tbTeamPKInst then
                local tbTeamPlayerInfo = self.tbTeamPKInst:GetPlayerInfo(nPlayerID);
                if tbTeamPlayerInfo then
                    tbShowInfo.nKillCount = tbTeamPlayerInfo.nKillPlayerCount;
                    tbShowInfo.nDamage    = tbTeamPlayerInfo.nTotalDmg;

                    if tbTeamPlayerInfo.tbAllPartner then
                        for nPartnerID, tbPartnerInfo in pairs(tbTeamPlayerInfo.tbAllPartner) do
                            tbShowInfo.nDamage  = tbShowInfo.nDamage + tbPartnerInfo.nTotalDmg;   
                        end
                    end     
                end    
            end

            table.insert(tbTeamShowInfo.tbAllPlayer, tbShowInfo);
        end

        tbAllTeamShow[nCurTeamID] = tbTeamShowInfo;    
    end

    self.tbAllTeamShowAccount = tbAllTeamShow;
end

function tbFinalsPKLogic:AddPlayFightTeam(nPKTeamID, tbPlayInfo)
    local tbTeamInfo = self.tbMapLogic:GetApplyFightTeamInfo(tbPlayInfo.nFightTeamID);
    if not tbTeamInfo then
        return;
    end

    local tbPlayTeam = {};
    tbPlayTeam.nPKTeamID = nPKTeamID;
    tbPlayTeam.nFightTeamID = tbPlayInfo.nFightTeamID;
    tbPlayTeam.tbAllPlayer = {};
    tbPlayTeam.tbEnterMapPlayer = {};
    self.tbPlayFightTeam[tbPlayTeam.nFightTeamID] = tbPlayTeam;

    for nPlayerID, _ in pairs(tbTeamInfo.tbAllPlayer) do
        local tbPlayPKInfo = tbTeamInfo.tbAllPlayerPKInfo[nPlayerID];
        if tbPlayPKInfo and tbPlayPKInfo.nMapId == self.nMapId then
            local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
            if pPlayer then
                if pPlayer.nMapId == self.nMapId then
                    pPlayer.SetPosition(tbPlayInfo.tbPos[1], tbPlayInfo.tbPos[2]);
                    self:AddPlayerPlayPK(pPlayer);
                else
                    tbPlayTeam.tbEnterMapPlayer[pPlayer.dwID] = 1;
                    pPlayer.bHSLJQuitePKTeam = true;
                    pPlayer.SwitchMap(self.nMapId, tbPlayInfo.tbPos[1], tbPlayInfo.tbPos[2]); 
                end
            end
        end        
    end

    Log("HSLJ FinalsPKLogic AddPlayFightTeam", self.nIndex, nPKTeamID, tbPlayInfo.nFightTeamID);
end

function tbFinalsPKLogic:CheckAddPlayerPlayPK(pPlayer)
    local nFightTeamID = tbPreGameMgr:GetPlayerFightTeam(pPlayer);
    if nFightTeamID <= 0 then
        return false, "CheckAddPlayerPlayPK Not FightTeamID";
    end

    local tbTeamInfo = self.tbMapLogic:GetApplyFightTeamInfo(nFightTeamID);
    if not tbTeamInfo then
        return false, "CheckAddPlayerPlayPK Not tbTeamInfo";
    end

    local tbPlayPKInfo = tbTeamInfo.tbAllPlayerPKInfo[pPlayer.dwID];
    if not tbPlayPKInfo then
        return false, "CheckAddPlayerPlayPK Not tbPlayPKInfo";
    end

    if tbPlayPKInfo.nMapId ~= self.nMapId then
        return false, "CheckAddPlayerPlayPK Not self.nMapId";
    end

    if pPlayer.nMapId ~= self.nMapId then
        return false, "CheckAddPlayerPlayPK Not pPlayer.nMapId";
    end    
        
    local tbPlayTeam = self.tbPlayFightTeam[nFightTeamID];
    if not tbPlayTeam then
        return false, "CheckAddPlayerPlayPK Not tbPlayTeam";
    end

    return true, "", tbPlayTeam, nFightTeamID;   
end

function tbFinalsPKLogic:OnEnterMap(pPlayer)
    local nFightTeamID = tbPreGameMgr:GetPlayerFightTeam(pPlayer);
    if nFightTeamID <= 0 then
        return;
    end

    local tbPlayTeam = self.tbPlayFightTeam[nFightTeamID];
    if not tbPlayTeam then
        return;
    end

    if not tbPlayTeam.tbEnterMapPlayer[pPlayer.dwID] then
        return;
    end

    tbPlayTeam.tbEnterMapPlayer[pPlayer.dwID] = nil;
    self:AddPlayerPlayPK(pPlayer);

    self:ShowInfoRMsg("準備開始", pPlayer);
    local tbFinalsDef = tbBaseLogic:GetFinalDef();
    self:ShowPlayerAccount(tbFinalsDef.nShowInfoPlayTeamTime, pPlayer);
    self:TeamShowPartner(true, pPlayer);
    self:PlayerUpdatePartnerShowInfo(pPlayer);
    self:AddToForceSyncPlayer(pPlayer);
    self:CloseLeavePanelUi(pPlayer);

    Log("HSLJ FinalsPKLogic:OnEnterMap", pPlayer.dwID, pPlayer.nMapId);  
end    

function tbFinalsPKLogic:AddPlayerPlayPK(pPlayer)
    local bRet, szMsg, tbPlayTeam, nFightTeamID = self:CheckAddPlayerPlayPK(pPlayer);
    if not bRet then
        Log("HSLJ FinalsPKLogic:AddPlayerPlayPK", szMsg, pPlayer.dwID);
        return;
    end    

    local tbGameFormat = tbPreGameMgr:GetGameFormat();
    CommonWatch:DoEndWatch(pPlayer);
    local tbPlayerInfo = {};
    tbPlayerInfo.nMatchTime = GetTime();
    tbPlayTeam.tbAllPlayer[pPlayer.dwID] = tbPlayerInfo;

    self.tbTeamPKInst:AddPlayer(pPlayer, tbPlayTeam.nPKTeamID);
    if tbGameFormat.bOpenPartner then
        local nPartnerID = pPlayer.GetFightPartnerID();
        self.tbTeamPKInst:CreatePartnerByID(pPlayer, nPartnerID);
    elseif tbGameFormat.nPartnerPos and tbGameFormat.nPartnerPos > 0 then
        self.tbTeamPKInst:CreatePartnerByPos(pPlayer, 1, tbGameFormat.nPartnerPos)       
    end

    tbPreGameMgr:SetPlayerTeamTitle(pPlayer, tbPlayTeam.nPKTeamID);
    self:CloseHomeScreenTask(true, pPlayer);
end

function tbFinalsPKLogic:CloseOneTimer()
    if self.nOneTimer then
        Timer:Close(self.nOneTimer);
        self.nOneTimer = nil;
    end      
end

function tbFinalsPKLogic:GetPlayFightTeam(nFightTeamID)
    return self.tbPlayFightTeam[nFightTeamID];
end    

function tbFinalsPKLogic:GetPlayerPKInfo(pPlayer)
    local nFightTeamID = tbPreGameMgr:GetPlayerFightTeam(pPlayer);
    local tbFightTeamInfo = self:GetPlayFightTeam(nFightTeamID);
    if not tbFightTeamInfo then
        return;
    end

    local tbPlayerInfo = tbFightTeamInfo.tbAllPlayer[pPlayer.dwID];
    return tbPlayerInfo;
end

function tbFinalsPKLogic:OnClose()
    self:CloseOneTimer();
    self:CloseDmgTimer();
    local bRet = self.tbTeamPKInst:IsEndPKSate();
    if not bRet then
        self.tbTeamPKInst:DoEnd();
    end 
    self:DoAllPlayerKickOut();   
end

function tbFinalsPKLogic:IsEndPKSate()
    return self.tbTeamPKInst:IsEndPKSate(); 
end

function tbFinalsPKLogic:ForeachFightTeamPlayer(nFightTeamID, tbCallBack)
    local tbTeamInfo = self:GetPlayFightTeam(nFightTeamID);
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

function tbFinalsPKLogic:ForeachAllPlayer(tbCallBack)
    for _, tbTeamInfo in pairs(self.tbPlayFightTeam) do
        for nPlayerID, _ in pairs(tbTeamInfo.tbAllPlayer) do
            local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
            if pPlayer and pPlayer.nMapId == self.nMapId then
                Lib:MergeCallBack(tbCallBack, pPlayer);
            end    
        end    
    end    
end

function tbFinalsPKLogic:WatchTeamPlayerNpcID(tbWatchTeamNpcID, pPlayer)
    local pNpc = pPlayer.GetNpc();
    if not pNpc then
        return;
    end

    if not self.tbTeamPKInst then
        return;
    end    

    local tbHideNpc = {};
    local tbAllPartner = self.tbTeamPKInst:GetPlayerAllPartner(pPlayer.dwID);
    if tbAllPartner then
        for nPartnerID, tbPartnerInfo in pairs(tbAllPartner) do
            local pPartner = KNpc.GetById(nPartnerID);
            if pPartner then
                tbHideNpc[nPartnerID] = 1;
            end    
        end
    end    

    local nFightTeamID = tbPreGameMgr:GetPlayerFightTeam(pPlayer);
    tbWatchTeamNpcID[nFightTeamID] = tbWatchTeamNpcID[nFightTeamID] or {};
    tbWatchTeamNpcID[nFightTeamID][pNpc.nId] = {tbSyncHide = tbHideNpc};    
end


function tbFinalsPKLogic:AddWatchPlayer(pPlayer, bNotChangeUi)
    local tbWatchTeamNpcID = {};
    self:ForeachAllPlayer({self.WatchTeamPlayerNpcID, self, tbWatchTeamNpcID});
    CommonWatch:WatchNpc(pPlayer, tbWatchTeamNpcID, bNotChangeUi);
    self.tbAllWatchPlayer[pPlayer.dwID] = 1;
end

function tbFinalsPKLogic:RemoveWatchPlayer(pPlayer)
    self.tbAllWatchPlayer[pPlayer.dwID] = nil;
    CommonWatch:DoEndWatch(pPlayer);
end

function tbFinalsPKLogic:GetWatchArea()
    local nWatchIndex = self.nIndex;
    local nCurPlan = self.tbMapLogic:GetCurPlan();
    local tbFinalsDef = tbBaseLogic:GetFinalDef();
    if nWatchIndex == 1 and nCurPlan == tbFinalsDef.nChampionPlan then
        nWatchIndex = 0;
    end

    return nWatchIndex;
end

--------------------------

function HuaShanLunJian:GetMainFinalsLogic()
    local nMainID = HuaShanLunJian:GetFinalsMapIDByIndex(1);
    if not nMainID then
        return;
    end

    local tbNotFinalsData = self:GetFinalsGameNotSave();
    local tbInst = tbNotFinalsData.tbFinalsLogicMgr;
    return tbInst;
end


function HuaShanLunJian:CheckPlayerEnterFinalsMap(pPlayer)
    local tbNotFinalsData = self:GetFinalsGameNotSave();
    if not tbNotFinalsData.bStart then
        return false, "尚未開啟"
    end

    local nMainID = HuaShanLunJian:GetFinalsMapIDByIndex(1);
    if not nMainID then
        return false, "地圖尚未開啟";
    end

    local tbFinalsInst = self:GetMainFinalsLogic();
    if not tbFinalsInst then
        return false, "地圖尚未開啟!";
    end

    local tbFinalsDef = tbDef.tbFinalsGame
    if pPlayer.nLevel < tbFinalsDef.nAudienceMinLevel then
        return false, string.format("等級不足%s無法參加", tbFinalsDef.nAudienceMinLevel);
    end    

    local bRet = Map:CheckEnterOtherMap(pPlayer);
    if not bRet then
        return false, "非安全區不能進入";
    end   

    local nFightTeamID = self:GetPlayerFightTeam(pPlayer);
    local nTeamId = pPlayer.dwTeamID;
    local nAddPlayerCount = 1;
    if nTeamId > 0 then
        local tbTeam = TeamMgr:GetTeamById(nTeamId)
        local nCaptainId = tbTeam:GetCaptainId();
        if nCaptainId ~= pPlayer.dwID then
            return false, "您不是隊長";
        end

        local tbMember = tbTeam:GetMembers();
        nAddPlayerCount = 0;
        for _, nPlayerID in pairs(tbMember) do
            local pMember = KPlayer.GetPlayerObjById(nPlayerID);
            if not pMember then
                return false, "有玩家不線上！"
            end

            local nMemberTeamID = self:GetPlayerFightTeam(pMember);
            if nMemberTeamID ~= nFightTeamID then
                return false, string.format("%s不是同一個戰隊", pMember.szName);
            end

            bRet = Map:CheckEnterOtherMap(pMember);
            if not bRet then
                return false, string.format("「%s」非安全區不能進入", pMember.szName);
            end

            nAddPlayerCount = nAddPlayerCount + 1;    
        end        
    end

    local nPlayerCount = tbFinalsInst:GetPlayerCount();
    local nApplyCount = tbFinalsInst:GetApplyPlayerCount();
    nPlayerCount = nPlayerCount + nAddPlayerCount - nApplyCount;
    if nPlayerCount > tbFinalsDef.nEnterPlayerCount then

        local tbFinalsInfo = self:GetFinalsFightTeamByID(nFightTeamID);
        if not tbFinalsInfo then
            return false, "進入的人數已滿";
        end 

    end

    return true, "", nMainID;        
end

function HuaShanLunJian:PlayerEnterFinalsMap(pPlayer)
    local tbFinalsDef = tbDef.tbFinalsGame
    local bRet, szMsg, nEnterPreMapID = self:CheckPlayerEnterFinalsMap(pPlayer);
    if not bRet then
        pPlayer.CenterMsg(szMsg, true);
        return;
    end

    local tbAllPos   = self:GetMapAllPosByTID(tbFinalsDef.nFinalsMapTID);
    local nTotalCount = #tbAllPos;
    local nRandIndex = MathRandom(nTotalCount);
    local tbEnterPos = tbAllPos[nRandIndex];

    local nTeamId = pPlayer.dwTeamID;
    if nTeamId > 0 then
        local tbTeam = TeamMgr:GetTeamById(nTeamId)
        local tbMember = tbTeam:GetMembers();
        for _, nPlayerID in pairs(tbMember) do
            local pMember = KPlayer.GetPlayerObjById(nPlayerID);
            pMember.SetEntryPoint();
            pMember.SwitchMap(nEnterPreMapID, tbEnterPos.PosX, tbEnterPos.PosY);
            Log("HuaShanLunJian PlayerEnterFinalsMap", pMember.dwID);
        end
    else
        pPlayer.SetEntryPoint();
        pPlayer.SwitchMap(nEnterPreMapID, tbEnterPos.PosX, tbEnterPos.PosY);
        Log("HuaShanLunJian PlayerEnterFinalsMap", pPlayer.dwID);
    end      
end