
Require("CommonScript/QunYingHui/QunYingHuiDef.lua");
local tbDef = QunYingHui.tbDefInfo;
QunYingHui.tbMapGameInstance = QunYingHui.tbMapGameInstance or {};
QunYingHui.tbMapMatchPlayer = QunYingHui.tbMapMatchPlayer or {};
QunYingHui.tbAllPlayerLastPK = QunYingHui.tbAllPlayerLastPK or {};
QunYingHui.tbAllPlayerDayPK = QunYingHui.tbAllPlayerDayPK or {};
QunYingHui.tbAllPlayerDayWin = QunYingHui.tbAllPlayerDayWin or {};

local nStateSeasonStart = 1;
local nStateSeasonEnd   = 2;

function QunYingHui:CheckPlayeGame(pPlayer, bCheckMap)
    if not self.bStartGame then
        return false, "群英會尚未開啟";
    end

    if not self.nEnterMapID then
        self:CreateEnterMap();
        return false, "群英會尚未開啟！";
    end    

    local nDegreeCount = DegreeCtrl:GetDegree(pPlayer, tbDef.szDegreeDay);
    if nDegreeCount <= 0 then
        return false, "當日的比賽次數不足";
    end

    local bRet = Map:CheckEnterOtherMap(pPlayer);
    if not bRet and bCheckMap then
        return false, "非安全區不能進入";
    end

    if pPlayer.nLevel < tbDef.nMinLevel then
        return false, "等級不足"..tbDef.nMinLevel;
    end    

    return true, "";
end

function QunYingHui:PlayerSignUpGame(pPlayer)
    local bRet, szMsg = self:CheckPlayeGame(pPlayer, true);
    if not bRet then
        pPlayer.CenterMsg(szMsg);
        return;
    end

    pPlayer.SetEntryPoint()
    local tbPos = QunYingHui:RandomPrepareMapPos();
    pPlayer.SwitchMap(self.nEnterMapID, tbPos[1], tbPos[2]);    
end

function QunYingHui:GetPlayerDayWinCount(pPlayer)
    self:UpdatePlayerSaveData(pPlayer);
    local nWinCount = pPlayer.GetUserValue(tbDef.nSaveGroupID, tbDef.nSaveDayWin);
    return nWinCount;
end

function QunYingHui:GetPlayerTotalWinCount(pPlayer)
    self:UpdatePlayerSaveData(pPlayer);
    local nWinCount = pPlayer.GetUserValue(tbDef.nSaveGroupID, tbDef.nSaveWinCount);
    local nTotalJoin = pPlayer.GetUserValue(tbDef.nSaveGroupID, tbDef.nSaveTotalJoin);
    return nWinCount, nTotalJoin;    
end

function QunYingHui:AddPlayerTotalJoin(pPlayer)
    self:UpdatePlayerSaveData(pPlayer);
    local nTotalJoin = pPlayer.GetUserValue(tbDef.nSaveGroupID, tbDef.nSaveTotalJoin);
    nTotalJoin = nTotalJoin + 1;
    pPlayer.SetUserValue(tbDef.nSaveGroupID, tbDef.nSaveTotalJoin, nTotalJoin);
    EverydayTarget:AddCount(pPlayer, "QunYingHui");
    
    if not self.tbAllPlayerDayWin[pPlayer.dwID] then
        self.tbAllPlayerDayWin[pPlayer.dwID] = 0;
    end
        
    return nTotalJoin;
end

function QunYingHui:AddPlayerWinCount(pPlayer)
    self:UpdatePlayerSaveData(pPlayer);
    local nWinCount = pPlayer.GetUserValue(tbDef.nSaveGroupID, tbDef.nSaveWinCount);
    nWinCount = nWinCount + 1;
    pPlayer.SetUserValue(tbDef.nSaveGroupID, tbDef.nSaveWinCount, nWinCount);

    local nDayWinCount = pPlayer.GetUserValue(tbDef.nSaveGroupID, tbDef.nSaveDayWin);
    nDayWinCount = nDayWinCount + 1;
    pPlayer.SetUserValue(tbDef.nSaveGroupID, tbDef.nSaveDayWin, nDayWinCount);

    Kin:RedBagOnEvent(pPlayer, Kin.tbRedBagEvents.qyh_win, nDayWinCount);

    self.tbAllPlayerDayWin[pPlayer.dwID] = nDayWinCount;
    -- local tbPKInfo = self:GetPlayerDayPKInfo(pPlayer.dwID);
    -- tbPKInfo.nWinCount = tbPKInfo.nWinCount + 1;
        
    return nWinCount;
end

function QunYingHui:AddPlayerJiFen(pPlayer, nAddJiFen)
    if nAddJiFen <= 0 then
        return;
    end

    self:UpdatePlayerSaveData(pPlayer);
    local nJiFen     = pPlayer.GetUserValue(tbDef.nSaveGroupID, tbDef.nSaveJiFen);
    local nLastJiFen = nJiFen;
    nJiFen = nJiFen + nAddJiFen;
    pPlayer.SetUserValue(tbDef.nSaveGroupID, tbDef.nSaveJiFen, nJiFen);

    for nAddValue = 1, nAddJiFen, 1 do
        local nCurJiFen = nLastJiFen + nAddValue;
        local tbAward = QunYingHui:RandomPlayerJiFenAward(pPlayer, nCurJiFen);
        if tbAward then
            local tbMail =
            {
                To = pPlayer.dwID,
                Title = "群英會",
                Text = string.format(tbDef.MailConent, nCurJiFen);
                nLogReazon = Env.LogWay_QunYingHui;
                tbAttach = tbAward,
            }

            Mail:SendSystemMail(tbMail);
        end

        Log("QunYingHui AddPlayerJiFen", pPlayer.dwID, nCurJiFen);    
    end   
end

function QunYingHui:GetPlayerJiFen(pPlayer)
    self:UpdatePlayerSaveData(pPlayer);
    local nJiFen = pPlayer.GetUserValue(tbDef.nSaveGroupID, tbDef.nSaveJiFen);
    return nJiFen;
end 

function QunYingHui:UpdatePlayerSaveData(pPlayer)
    local nDay     = pPlayer.GetUserValue(tbDef.nSaveGroupID, tbDef.nSaveDayTime);
    local nCurDay  = Lib:GetLocalDay();
    if nDay ~= nCurDay then
        pPlayer.SetUserValue(tbDef.nSaveGroupID, tbDef.nSaveDayTime, nCurDay);
        pPlayer.SetUserValue(tbDef.nSaveGroupID, tbDef.nSaveDayWin, 0);
        pPlayer.SetUserValue(tbDef.nSaveGroupID, tbDef.nSaveJiFen, 0);

    end
end

function QunYingHui:GetLastPKPlayerID(pPlayer)
    local tbLastInfo = self.tbAllPlayerLastPK[pPlayer.dwID];
    if not tbLastInfo then
        tbLastInfo = {};
        for nI = 1, 2 do
            tbLastInfo[nI] = 0;
        end    
        self.tbAllPlayerLastPK[pPlayer.dwID] = tbLastInfo;  
    end

    return tbLastInfo; 
end    

function QunYingHui:GetPlayerWinRate(pPlayer)
    local nWinCount, nTotalWin = self:GetPlayerTotalWinCount(pPlayer);
    if nTotalWin == 0 then
        return tbDef.fDefWinRate;
    end

    return nWinCount / nTotalWin;    
end

function QunYingHui:FirstStartGame()
    -- local tbData = ScriptData:GetValue("QunYingHuiData");
    -- if tbData.nGameState == nStateSeasonStart then
    --      Log("ERROR QunYingHui FirstStartGame", tbData.nGameState or "nil");
    --     return;
    -- end    

    -- tbData.nGameState = nStateSeasonStart;

    -- RankBoard:ClearRank("qunyinghui");

    -- self:StartGame();
    Log("QunYingHui FirstStartGame");
end

function QunYingHui:StartGame()
    -- local tbData = ScriptData:GetValue("QunYingHuiData");
    -- if tbData.nGameState ~= nStateSeasonStart then
    --     Log("ERROR QunYingHui Not StartGame", tbData.nGameState or "nil");
    --     return;
    -- end

    if self.bStartGame then
        Log("ERROR QunYingHui StartGame");
        return;
    end

    if self.nEndGameTimer then
        Timer:Close(self.nEndGameTimer);
        self.nEndGameTimer = nil;
    end 

    --self.bEndSendAward = false;
    self.tbAllPlayerDayPK = {};
    self.bStartGame = true;
    self.bEndSendEndAward = false;
    self.bCanSendGameAward = false;
    self.nEnterPKPlayerCount = 0;
    self:CreateEnterMap();
    self.nTotalMatchCount = tbDef.nTotalMatchCount;
    self.tbAllPlayerDayWin = {};
    if self.nTimerMatch then
        Timer:Close(self.nTimerMatch);
        self.nTimerMatch = nil;
    end    

    KPlayer.SendWorldNotify(1, 999, "群英會開始報名了！", 1, 1);
    self.nTimerMatch = Timer:Register(tbDef.nStartTimeMatch * Env.GAME_FPS, self.OnTimerGameMatch, self);
    Calendar:OnActivityBegin("QunYingHui");
    local tbMsgData =
    {
        szType = "QunYingHui";
        nTimeOut = GetTime() + 1800;
    };

    KPlayer.BoardcastScript(tbDef.nMinLevel, "Ui:SynNotifyMsg", tbMsgData);
    Log("QunYingHui StartGame");
end

function QunYingHui:GetPlayerDayPKInfo(nPlayerID)
    local tbPKInfo = self.tbAllPlayerDayPK[nPlayerID];
    if not tbPKInfo then
        tbPKInfo = {};
        tbPKInfo.bFetchAward = false;
        tbPKInfo.nWinCount = 0;
        self.tbAllPlayerDayPK[nPlayerID] = tbPKInfo;
    end
    
    return tbPKInfo;
end

function QunYingHui:GetMatchTime()
    if not self.nTimerMatch then
        return 0;
    end    

    local nTime = math.floor(Timer:GetRestTime(self.nTimerMatch) / Env.GAME_FPS);
    return nTime;
end

function QunYingHui:OnTimerGameMatch()
    self.nTimerMatch = nil;
    if not self.bStartGame then
        return;
    end

    self.nTotalMatchCount = self.nTotalMatchCount or 0;
    if self.nTotalMatchCount <= 0 then
        return;
    end    

    self.nTimerMatch = Timer:Register(tbDef.nPerTimeMatch * Env.GAME_FPS, self.OnTimerGameMatch, self); 
    if not self.nEnterMapID then
        return;
    end    

    self.nTotalMatchCount = self.nTotalMatchCount - 1;
    Log("QunYingHui OnTimerGameMatch", self.nTotalMatchCount);

    if self.nTotalMatchCount == 0 then
        local nEndTime = tbDef.nPrepareGameTime  + tbDef.nFightGameTime + tbDef.nGameEndKickOutMapTime + 30; --准备时间
        if self.nEndGameTimer then
            Timer:Close(self.nEndGameTimer);
            self.nEndGameTimer = nil;
        end    
        self.nEndGameTimer = Timer:Register(nEndTime * Env.GAME_FPS, self.OnTimerEndGame, self);
    end 
    
    local tbMatchEmptyPlayer = {};
    local tbMapPlayer  = KPlayer.GetMapPlayer(self.nEnterMapID);
    local tbSortPlayer = {};

    for _, pPlayer in pairs(tbMapPlayer) do
        local bRet, szMsg = self:CheckPlayeGame(pPlayer);
        if bRet then
            local tbPlayerInfo = {};
            tbPlayerInfo.pPlayer = pPlayer;
            tbPlayerInfo.fWinRate = self:GetPlayerWinRate(pPlayer);
            table.insert(tbSortPlayer, tbPlayerInfo);
            tbMatchEmptyPlayer[pPlayer.dwID] = 1;
        else
            pPlayer.Msg(szMsg);
            pPlayer.GotoEntryPoint();
        end    
    end

    if #tbSortPlayer < tbDef.nMatchPlayerCount then
        self:MatchEmptyEndGame(tbMatchEmptyPlayer); 
        return;
    end

    local funSort = function (a, b)
        return a.fWinRate > b.fWinRate;
    end

    table.sort(tbSortPlayer, funSort);

    while(#tbSortPlayer >= tbDef.nMatchPlayerCount) do

        local pPlayer1 = tbSortPlayer[1].pPlayer;
        local pPlayer2 = nil;
        local nLastIndex = nil;
        table.remove(tbSortPlayer, 1);

        local tbPKPlayer = self:GetLastPKPlayerID(pPlayer1);
        for nIndex, tbInfo in ipairs(tbSortPlayer) do
            local pCurPlayer = tbInfo.pPlayer;
            local tbCurPKPlayer = self:GetLastPKPlayerID(pCurPlayer);

            if tbPKPlayer[1] ~= pCurPlayer.dwID and tbPKPlayer[2] ~= pCurPlayer.dwID and
               tbCurPKPlayer[1] ~= pPlayer1.dwID and tbCurPKPlayer[2] ~= pPlayer1.dwID then
                pPlayer2 = pCurPlayer;
                table.remove(tbSortPlayer, nIndex);
                break;
            end

            if tbPKPlayer[1] ~= pCurPlayer.dwID and tbCurPKPlayer[1] ~= pPlayer1.dwID and not nLastIndex then
                nLastIndex = nIndex;
            end     
        end    

        if not pPlayer2 then
            local nFindIndex = nil;
            if nLastIndex then
                nFindIndex = nLastIndex;
            end

            if not nFindIndex then
                local nTotalCount = #tbSortPlayer;
                if nTotalCount % 2 == 1 then
                    nFindIndex = 1;
                end
            end        

            if nFindIndex and tbSortPlayer[nFindIndex] then
                pPlayer2 = tbSortPlayer[nFindIndex].pPlayer;
                table.remove(tbSortPlayer, nFindIndex);
            end    
        end    

        if pPlayer1 and pPlayer2 then
            local nMapMatchID = CreateMap(tbDef.nGameTempMapID);
            local tbMapMatchID = self:GetMatchInfo(nMapMatchID);
            tbMapMatchID.tbPlayer = {pPlayer1.dwID, pPlayer2.dwID};
            tbMatchEmptyPlayer[pPlayer1.dwID] = nil;
            tbMatchEmptyPlayer[pPlayer2.dwID] = nil;
            Log("QunYingHui GameMatch", nMapMatchID, pPlayer1.dwID, pPlayer2.dwID);
        else
            Log("QunYingHui OnTimerGameMatch Find Not Player", pPlayer1.dwID);
        end    
    end 

    self:MatchEmptyEndGame(tbMatchEmptyPlayer);    
    return;
end

function QunYingHui:MatchEmptyEndGame(tbMatchEmptyPlayer)
    if not tbMatchEmptyPlayer then
        return;
    end

    for nPlayerID, _ in pairs(tbMatchEmptyPlayer) do
        local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
        if pPlayer and pPlayer.nMapId == self.nEnterMapID then
            QunYingHui:UpdatePlayerUiShow(pPlayer);
        end    
    end    
end

function QunYingHui:UpdatePlayerUiShow(pPlayer)
    if self.nTotalMatchCount == 0 then
        pPlayer.CallClientScript("Ui:OpenWindow", "QYHLeftInfo", "QunYingHuiEnd");
        pPlayer.CallClientScript("Ui:CloseWindow", "HSLJBattleInfo");
    else
        local tbShowInfo = {}
        tbShowInfo.nTime = QunYingHui:GetMatchTime();
        tbShowInfo.szShow = string.format("等待第%s輪匹配中", tbDef.nTotalMatchCount - self.nTotalMatchCount + 1);
        tbShowInfo.nMapTID = pPlayer.nMapTemplateId;
        pPlayer.CallClientScript("Ui:OpenWindow", "HSLJBattleInfo", "ShowInfo", tbShowInfo);
    end  
end

function QunYingHui:GetMatchInfo(nMapID)
    local tbMatchInfo = self.tbMapMatchPlayer[nMapID];
    if not tbMatchInfo then
        local tbInfo    = {};
        tbInfo.nMapID   = nMapID;
        tbInfo.tbPlayer = {};
        self.tbMapMatchPlayer[nMapID] = tbInfo;
        tbMatchInfo = tbInfo
    end

    return tbMatchInfo;   
end

function QunYingHui:CreateEnterMap()
    if self.nEnterMapID then
        return;
    end

    if self.bStartCreateEnterMap then
        return;
    end    

    self.bStartCreateEnterMap = true;
    CreateMap(tbDef.nPrepareTempMapID);
end

function QunYingHui:RandomPrepareMapPos()
    local nCount = #tbDef.tbPrepareMapPos;
    local nIndex = MathRandom(nCount);
    return tbDef.tbPrepareMapPos[nIndex];
end

function QunYingHui:OnTimerEndGame()
    self.nEndGameTimer = nil;
    self:EndGame();
    Log("QunYingHui:OnTimerEndGame");
end

function QunYingHui:EndGame()
    if not self.bStartGame then
        Log("Error QunYingHui EndGame Not Start");
        return;
    end

    if self.nEndGameTimer then
        Timer:Close(self.nEndGameTimer);
        self.nEndGameTimer = nil;
    end 

    self.bStartGame = false;
    self.bCanSendGameAward = true;

    if self.nTimerMatch then
        Timer:Close(self.nTimerMatch);
        self.nTimerMatch = nil;
    end

    KPlayer.SendWorldNotify(1, 999, "群英會已經結束了！", 1, 1);
    self:KickOutPrepareMap();

    if self.nTimerEndPlayerAward then
        Timer:Close(self.nTimerEndPlayerAward);
        self.nTimerEndPlayerAward = nil;
    end    

    if self.nEnterPKPlayerCount <= 0 then
        self:SendGameEndPlayerAward();
    else
        self.nTimerEndPlayerAward = Timer:Register(5 * 60 * Env.GAME_FPS, self.OnTimerGameEndPlayerAward, self)
    end
    Calendar:OnActivityEnd("QunYingHui");
    Log("QunYingHui EndGame");
end

function QunYingHui:OnTimerGameEndPlayerAward()
    self.nTimerEndPlayerAward = nil;
    self:SendGameEndPlayerAward();
    Log("QunYingHui OnTimerGameEndPlayerAward");
end

function QunYingHui:OnLeavePKLogic()
    if self.nEnterPKPlayerCount > 0 then
        return;
    end

    if self.bStartGame then
        return;
    end

    if not self.bCanSendGameAward then
        return;
    end

    self.bCanSendGameAward = false;
    self:SendGameEndPlayerAward();
    Log("QunYingHui OnLeavePKLogic");
end

function QunYingHui:SendGameEndPlayerAward()
    if self.nTimerEndPlayerAward then
        Timer:Close(self.nTimerEndPlayerAward);
        self.nTimerEndPlayerAward = nil;
    end  

    self.bCanSendGameAward = false;
    if self.bEndSendEndAward then
        return;
    end

    for nPlayerID, nDayWinCount in pairs(self.tbAllPlayerDayWin) do
        Lib:CallBack({Calendar.OnCompleteAct, Calendar, nPlayerID, "QunYingHui", nDayWinCount})   
    end    

    self.bEndSendEndAward = true;
    Log("QunYingHui OnSendGameEndPlayerAward"); 
end    

function QunYingHui:KickOutPrepareMap()
    if not self.nEnterMapID then
        return;
    end

    local tbPlayer = KPlayer.GetMapPlayer(self.nEnterMapID);
    for _, pPlayer in ipairs(tbPlayer) do
        pPlayer.GotoEntryPoint();
    end
end

function QunYingHui:SeasonEndGame()
    -- local tbData = ScriptData:GetValue("QunYingHuiData");
    -- if tbData.nGameState ~= nStateSeasonStart then
    --     Log("Error QunYingHui SeasonEndGame", tbData.nGameState or "nil");
    --     return;
    -- end    

    -- if self.bEndSendAward then
    --     Log("QunYingHui Error EndSendAward Have");
    --     return;
    -- end

    -- self.bEndSendAward = true;
    -- if self.bStartGame then
    --     self:EndGame();
    -- end

    -- --tbData.nGameState = nStateSeasonEnd;
    -- self:SendSeasonRankAward();
    Log("QunYingHui SeasonEndGame");
end

function QunYingHui:SendSeasonRankAward()
    Log("QunYingHui SendSeasonRankAward");
end

function QunYingHui:GetJiFenAward(nJiFen)
    return self.tbJiFenAwardSetting[nJiFen];
end

function QunYingHui:RandomPlayerJiFenAward(pPlayer, nJiFen)
    local tbJiFenAward = self:GetJiFenAward(nJiFen);
    if not tbJiFenAward then
        return;
    end

    local tbSendAward = {};
    for _, tbAward in pairs(tbJiFenAward.tbAllAward) do
        table.insert(tbSendAward, tbAward);
    end

    local nCurRate = MathRandom(tbDef.nTotalExtRate);
    if tbJiFenAward.nExtRate > 0 and nCurRate <= tbJiFenAward.nExtRate then
        for _, tbAward1 in pairs(tbJiFenAward.tbExtAward) do
            table.insert(tbSendAward, tbAward1);
        end

        if tbJiFenAward.tbExtAward[1] and tbJiFenAward.tbExtAward[1][1] == "Item" then
            local szItemName = KItem.GetItemShowInfo(tbJiFenAward.tbExtAward[1][2]);
            local szShowMsg = string.format(tbDef.szWorldExtNotice, pPlayer.szName, szItemName);
            KPlayer.SendWorldNotify(1, 999, szShowMsg, 1, 1);
        end
    end

    return tbSendAward;   
end

function QunYingHui:Init()
    self.tbJiFenAwardSetting = {};

    local tbFileData = Lib:LoadTabFile("Setting/QunYingHui/WinAward.tab", {JiFen = 1, ExtRate = 1});
    for _, tbInfo in pairs(tbFileData) do
        local tbJiFenAward = {};
        tbJiFenAward.tbAllAward = Lib:GetAwardFromString(tbInfo.Awards);
        tbJiFenAward.tbExtAward = Lib:GetAwardFromString(tbInfo.ExtAward);
        tbJiFenAward.nExtRate = tbInfo.ExtRate;
        self.tbJiFenAwardSetting[tbInfo.JiFen] = tbJiFenAward;
    end
end

QunYingHui:Init();