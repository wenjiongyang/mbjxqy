Require("CommonScript/HuaShanLunJian/LunJianDef.lua");
Require("ServerScript/HuaShanLunJian/HuaShanLunJian.lua");

HuaShanLunJian.tbPreGamePreMgr = HuaShanLunJian.tbPreGamePreMgr or {};

local tbDef    = HuaShanLunJian.tbDef;
local tbPreGameMgr = HuaShanLunJian.tbPreGamePreMgr;

------------------------ PreGameLogic----------------------------------------------------------
--重载
function tbPreGameMgr:GetPreDef()
    return tbDef.tbPrepareGame
end

function tbPreGameMgr:StartPreGame()
    local tbNotPreData = HuaShanLunJian:GetPrepareGameNotSave();
    tbNotPreData.tbPreGameFightTeam = {};

    self:PlayerKickOutAllPlayer();
    self.szShowUIMsg = "等待第1場比賽開啟";
    self.tbSortFightTeam = {};
    self:CloseOnceTimer();
    local tbPreDef = self:GetPreDef()
    self:OpenPreareTimer(tbPreDef.nPrepareTime);
    self:SendWorldMsg(self:GetPreOpenWorldMsg());
    self.nCreatePreMapTime = 0;
    self:CreatePreMap(tbPreDef.nPreGamePreMap)
    Log("HSLJ PreGameLogic StartPreGame");    
end

--重载
function tbPreGameMgr:GetPreOpenWorldMsg()
    return self:GetPreDef().szPreOpenWorldMsg
end

function tbPreGameMgr:CreatePreMap(nCount)
    self.nCreatePreMapTime = self.nCreatePreMapTime or 0;
    local nCurTime = GetTime();
    if nCurTime - self.nCreatePreMapTime <= tbDef.nPreGamePreMapTime then
        return;
    end

    self.nCreatePreMapTime = nCurTime
    local tbPreDef = self:GetPreDef();
    for nI = 1, nCount do
        CreateMap(tbPreDef.nPrepareMapTID);
    end

    Log("HSLJ PreGameLogic CreatePreMap", nCount);
end

function tbPreGameMgr:CloseAllPreGame()
    
end

function tbPreGameMgr:CloseOnceTimer()
    if self.nOnceTimer then
        Timer:Close(self.nOnceTimer);
        self.nOnceTimer = nil;
    end    
end

--重载
function tbPreGameMgr:SendWorldMsg(szMsg)
    if Lib:IsEmptyStr(szMsg) then
        return;
    end

    KPlayer.SendWorldNotify(1, 999, szMsg, 1, 1);
end

function tbPreGameMgr:OpenPreareTimer(nTime)
    local tbNotPreData = HuaShanLunJian:GetPrepareGameNotSave();
    if tbNotPreData.nPlayGameCount <= 0 then
        return false;
    end
    self:CloseOnceTimer();
    tbNotPreData.nPlayGameCount = tbNotPreData.nPlayGameCount - 1;
    self.nOnceTimer = Timer:Register(Env.GAME_FPS * nTime, self.OnEnterMatchTime, self);
    return true;
end

function tbPreGameMgr:CloseOnceTimer()
    if self.nOnceTimer then
        Timer:Close(self.nOnceTimer);
        self.nOnceTimer = nil;
    end    
end

--重载
function tbPreGameMgr:UpdateCurTeamRank(bEnd)
    --武林大会需要对目前的所有队伍进行排名，取20名 保留发送到本服
end

--每场都是正常轮完再更新数据会有点慢， 这里只有有打完的就检查更新排名
function tbPreGameMgr:CheckUpdateCurTeamRank()
    local tbPreDef = self:GetPreDef();
    if not tbPreDef.nSynTopZoneTeamDataTimeDelay then
        return
    end
    local nNow = GetTime()
    if not self.nLastUpdateCurTeamRankTime or nNow - self.nLastUpdateCurTeamRankTime >= tbPreDef.nSynTopZoneTeamDataTimeDelay then
        self.nLastUpdateCurTeamRankTime = nNow
        self:UpdateCurTeamRank()
    end
end

function tbPreGameMgr:OnEnterMatchTime()
    self:CloseOnceTimer();
    local tbPreDef = self:GetPreDef();
    local nPreTime = tbPreDef.nFreeGameTime + tbPreDef.nPlayGameTime;
    local bRetOpen = self:OpenPreareTimer(nPreTime);
    if bRetOpen then
        local tbNotPreData = HuaShanLunJian:GetPrepareGameNotSave();
        self.szShowUIMsg = string.format("等待第%s場比賽開啟", tbPreDef.nPlayerGameCount - tbNotPreData.nPlayGameCount);
        if tbPreDef.bShowMSgWhenEnterMatchTime then
            self:SendWorldMsg(tbPreDef.szPreOpenWorldMsg);
        end
    else
        self.szShowUIMsg = "比賽結束";
        self:CloseOnceTimer();
        self.nOnceTimer = Timer:Register(Env.GAME_FPS * tbPreDef.nPlayGameTime, self.OnEndGameTimer, self);
    end  

    self:FightTeamMatchPlayGame();
    self:UpdateCurTeamRank()  
    Log("HuaShanLunJian PreLogicMgr OnEnterMatchTime");    
end

function tbPreGameMgr:OnEndGameTimer()
    self:CloseOnceTimer();
    self.szShowUIMsg = "離開場地";
    local tbPreDef = self:GetPreDef();
    self.nOnceTimer = Timer:Register(Env.GAME_FPS * tbPreDef.nKickOutTime, self.OnTrueEndGame, self);
    self:ForeachAllPlayer({self.UpdateUIInfo, self});
end


function tbPreGameMgr:OnTrueEndGame()
    self:UpdateCurTeamRank(true)   --时间配置上是有可能这时最后一场还没有打完的
    self:OnKickOutAllPlayer()
    self:TrueEndGame()
end

--重载 --武林大会是跨服上先自己清除了再是通知会本服清除
function tbPreGameMgr:TrueEndGame()
    
end

function tbPreGameMgr:UpdateUIInfo(pPlayer)
    local tbInst = HuaShanLunJian.tbAllPreMapLogicInst[pPlayer.nMapId];
    if not tbInst then
        Log("Error HuaShanLunJian PreLogicMgr OnEnterMatchTime tbInst", pPlayer.nMapId);    
        return;
    end

    tbInst:UpdateUIInfo(pPlayer);    
end

--Z上重载
function tbPreGameMgr:GetFightTeamByID(nFightTeamID)
    return HuaShanLunJian:GetFightTeamByID(nFightTeamID);
end

--Z上重载
function tbPreGameMgr:GetMaxJoinCount()
    local tbSaveData = HuaShanLunJian:GetLunJianSaveData();
    return HuaShanLunJian:GetPreGameJoinCount(tbSaveData.nWeekDay);
end

function tbPreGameMgr:CheckFightTeamMatchPlayGame(nFightTeamID, tbTeamInfo)
    local nCurTeamCount = Lib:CountTB(tbTeamInfo.tbAllPlayer);
    if nCurTeamCount <= 0 then
        return false, "沒有成員";
    end

    local tbFightTeam = self:GetFightTeamByID(nFightTeamID)
    if not tbFightTeam then  
        return false, "戰隊不存在";
    end

    local nJoinCount = tbFightTeam:GetJoinCount();
    local nMaxJoinCount = self:GetMaxJoinCount()
    if nJoinCount >= nMaxJoinCount then
        return false, "您的戰隊已沒有剩餘比賽次數";
    end

    local tbPreDef = self:GetPreDef();
    local nPerCount = tbFightTeam:GetPerDayCount();
    if nPerCount >= tbPreDef.nPerDayJoinCount then
        return false, "您的戰隊今日沒有剩餘比賽次數";
    end    

    return true, "", tbFightTeam;
end

function tbPreGameMgr:FightTeamMatchPlayGameFaild(nFightTeamID, szMsg)
    szMsg = szMsg or "您的戰隊已沒有剩餘比賽次數";
    self:ForeachPlayerFightTeam(nFightTeamID, {self.PlayerKickOutMsg, self, szMsg});
end  

function tbPreGameMgr:FightTeamMatchPlayGame()
    self.tbSortFightTeam = {};
    local tbAllFightTeam = HuaShanLunJian:GetPrepareGameFightTeam();
    local tbPreDef = self:GetPreDef()
    for nFightTeamID, tbTeamInfo in pairs(tbAllFightTeam) do
        local bRet, szMsg, tbFightTeam = self:CheckFightTeamMatchPlayGame(nFightTeamID, tbTeamInfo);
        if bRet then
            local fWinPer = tbPreDef.nDefWinPercent;
            local nJoinCount = tbFightTeam:GetJoinCount();
            if nJoinCount > 0 then
                local nWinCount = tbFightTeam:GetWinCount();
                fWinPer = nWinCount / nJoinCount;
            end

            local nWinPerValue = math.floor(fWinPer * 100);
            local nSortValue = nWinPerValue * 1000 + tbFightTeam:GetJiFen();
            local tbInfo = 
            {
                nFightTeamID = nFightTeamID;
                fWinPer      = fWinPer;
                tbTeamInfo   = tbTeamInfo;
                nSortValue   = nSortValue;
            }

            table.insert(self.tbSortFightTeam, tbInfo);
        else
            self:FightTeamMatchPlayGameFaild(nFightTeamID, szMsg);    
        end       
    end

    local nTotalCount = #self.tbSortFightTeam;
    if nTotalCount <= 0 then
        return;
    end    

    table.sort(self.tbSortFightTeam, function (a, b) return a.nSortValue > b.nSortValue; end)

    while(#self.tbSortFightTeam > 0) do
        local nFirstIndex = #self.tbSortFightTeam;
        local tbFirstInfo = self.tbSortFightTeam[nFirstIndex];
        local bFindFront = false;
        if not tbFirstInfo.tbTeamInfo.bMatchEmpty then
            bFindFront = true;
            nFirstIndex = 1;
        end

        tbFirstInfo = self.tbSortFightTeam[nFirstIndex];
        local tbFirstTeam = tbFirstInfo.tbTeamInfo;
        local nFightTeamID1 = tbFirstInfo.nFightTeamID;

        table.remove(self.tbSortFightTeam, nFirstIndex);
        local nMatchIndex = self:FindMatchFightTeam(tbFirstTeam, bFindFront);
        local nFightTeamID2 = nil;
        if nMatchIndex and nMatchIndex > 0 then
            local tbMatchInfo = self.tbSortFightTeam[nMatchIndex];
            nFightTeamID2 = tbMatchInfo.nFightTeamID;
            table.remove(self.tbSortFightTeam, nMatchIndex);
        end 
            
        self:OnPlayGame(nFightTeamID1, nFightTeamID2);
    end
end

function tbPreGameMgr:FindMatchFightTeam(tbFirstTeam, bFindFront)
    local nTotalCount = #self.tbSortFightTeam;
    if nTotalCount <= 0 then
        return;
    end

    local tbPreDef = self:GetPreDef()
    local nMaxFindCount = tbPreDef.nMatchMaxFindCount;
    local tbFindIndex = {};
    local nStart = 1;
    local nEnd = math.min(nMaxFindCount, nTotalCount); 
    local nAdd = 1;
    if not bFindFront then
        nStart = nTotalCount;
        nEnd   = math.max((nTotalCount - nMaxFindCount + 1), 1);
        nAdd   = -1;
    end

    for nI = nStart, nEnd, nAdd do
        local tbFindInfo = self.tbSortFightTeam[nI];
        if not tbFirstTeam.tbAllMatchTeam[tbFindInfo.nFightTeamID] then
            if tbFindInfo.tbTeamInfo.bMatchEmpty then
                return nI;
            end

            table.insert(tbFindIndex, nI);
        end    
    end     

    if #tbFindIndex <= 0 then
        for nI = nStart, nEnd, nAdd do
            table.insert(tbFindIndex, nI);  
        end 
    end
    
    local nFindCount = #tbFindIndex;
    local nRandIndex = MathRandom(nFindCount);
    return tbFindIndex[nRandIndex];
end

function tbPreGameMgr:GetOnceTime()
    if not self.nOnceTimer then
        return 0;
    end    

    local nTime = math.floor(Timer:GetRestTime(self.nOnceTimer) / Env.GAME_FPS);
    return nTime;
end

function tbPreGameMgr:OnPlayGame(nFightTeamID1, nFightTeamID2)
   if not nFightTeamID2 then
        self:PlayGameOne(nFightTeamID1)
   else
        self:PlayGameTwo(nFightTeamID1, nFightTeamID2);
   end 
end

--重载
function tbPreGameMgr:GetPlayerFightTeam(pPlayer)
    return HuaShanLunJian:GetPlayerFightTeam(pPlayer);
end

--重载
function tbPreGameMgr:GetFightTeamByID(nFightTeamID)
    return HuaShanLunJian:GetFightTeamByID(nFightTeamID);
end

--重载
function tbPreGameMgr:CheckEnterPrepareGame(...)
    return HuaShanLunJian:CheckEnterPrepareGame(...);
end

function tbPreGameMgr:PlayerMatchGameEmpty(pPlayer)
    local nFightTeamID = self:GetPlayerFightTeam(pPlayer);
    local tbFightTeam = self:GetFightTeamByID(nFightTeamID);
    if not tbFightTeam then
        return;
    end

    self:UpdateUIInfo(pPlayer);
    local tbPreDef = self:GetPreDef()   
    pPlayer.CenterMsg(string.format("戰隊輪空，判定獲勝，比賽時間增加%s", Lib:TimeDesc(tbPreDef.nMatchEmptyTime)));
    pPlayer.Msg(string.format("您的戰隊輪空了，系統判定閣下勝利，戰隊比賽時間增加%s。請等待下一場比賽開始！", Lib:TimeDesc(tbPreDef.nMatchEmptyTime)));

    local bRet, szMsg = self:CheckEnterPrepareGame(pPlayer, true, true)
    if not bRet then
        self:PlayerKickOutMsg(szMsg, pPlayer)
    end
end

--跨服重载
function tbPreGameMgr:AddFightTeamJiFen(nFightTeamID1, bWin, nJiFen, nPlayTime)
    HuaShanLunJian:AddFightTeamJiFen(nFightTeamID1, bWin, nJiFen, nPlayTime);
end

function tbPreGameMgr:PlayGameOne(nFightTeamID1)
    local tbTeamInfo = self:GetFightTeamInfo(nFightTeamID1);
    tbTeamInfo.bMatchEmpty = true;
    tbTeamInfo.tbAllPlayerPKInfo = {};
    tbTeamInfo.nEnemyFightTeam = 0;
    tbTeamInfo.nCalcResult = TeamPKMgr.tbDef.nPlayNone;

    local tbFightTeam = self:GetFightTeamByID(nFightTeamID1);
    if not tbFightTeam then
        Log("Error HuaShanLunJian PlayGameOne Not Fight Team", nFightTeamID1);
        return;
    end

    tbFightTeam:AddJoinCount();
    tbTeamInfo.nCalcResult = TeamPKMgr.tbDef.nPlayWin;
    local tbPreDef = self:GetPreDef()
    self:AddFightTeamJiFen(nFightTeamID1, true, tbPreDef.nWinJiFen, tbPreDef.nMatchEmptyTime)

    self:ForeachPlayerFightTeam(nFightTeamID1, {self.PlayerMatchGameEmpty, self});
    self:ForeachPlayerFightTeam(nFightTeamID1, {self.OnPlayerReportData, self, TeamPKMgr.tbDef.nPlayWin, tbPreDef.nMatchEmptyTime});

    --奖励还没定，所以这里就先只是替换掉 TODO 
    self:SendAwardPlayGameOne(nFightTeamID1)

    Log("HuaShanLunJian PlayGameOne", nFightTeamID1);
end

--重载 
function tbPreGameMgr:SendAwardPlayGameOne(nFightTeamID1)
    local tbPreDef = self:GetPreDef()
    local tbAward = tbPreDef.tbAllAward.tbWin;
    if tbAward then
        HuaShanLunJian:SendTeamPreGameMailAward(nFightTeamID1, tbAward, tbPreDef.tbAwardMail.szWin);
    end
end

--重载
function tbPreGameMgr:OnPlayerReportData(nResult, nPlayTime, pPlayer)
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

    HuaShanLunJian:PlayerReportPkData(pPlayer, tbData);
end

--重载
function tbPreGameMgr:PlayerReportPkData(pPlayer, tbData)
   HuaShanLunJian:PlayerReportPkData(pPlayer, tbData); 
end


--重载
function tbPreGameMgr:GetGameFormat()
    return HuaShanLunJian:GetGameFormat()
end

function tbPreGameMgr:PlayGameTwo(nFightTeamID1, nFightTeamID2)
    local tbFightTeam1 = self:GetFightTeamByID(nFightTeamID1);
    if not tbFightTeam1 then
        Log("Error HuaShanLunJian PlayGameTwo tbFightTeam1", nFightTeamID1, nFightTeamID2);
        return;
    end

    local tbFightTeam2 = self:GetFightTeamByID(nFightTeamID2);
    if not tbFightTeam2 then
        Log("Error HuaShanLunJian PlayGameTwo tbFightTeam2", nFightTeamID1, nFightTeamID2);
        return;
    end    

    local tbTeamInfo1 = self:GetFightTeamInfo(nFightTeamID1);
    tbTeamInfo1.bMatchEmpty = false;
    tbTeamInfo1.tbAllMatchTeam[nFightTeamID2] = 1;
    tbTeamInfo1.tbAllPlayerPKInfo = {};
    tbTeamInfo1.nEnemyFightTeam = nFightTeamID2;
    tbTeamInfo1.nCalcResult = TeamPKMgr.tbDef.nPlayNone;
    tbFightTeam1:AddJoinCount();

    local tbTeamInfo2 = self:GetFightTeamInfo(nFightTeamID2);
    tbTeamInfo2.bMatchEmpty = false;
    tbTeamInfo2.tbAllMatchTeam[nFightTeamID1] = 1;
    tbTeamInfo2.tbAllPlayerPKInfo = {};
    tbTeamInfo2.nEnemyFightTeam = nFightTeamID1;
    tbTeamInfo2.nCalcResult = TeamPKMgr.tbDef.nPlayNone;
    tbFightTeam2:AddJoinCount();

    local tbGameFormat = self:GetGameFormat();
    local szPKClass = tbGameFormat.szPKClass or "Normal";
    local funCallBack = self[szPKClass.."CreatePKMap"];
    if funCallBack then
        funCallBack(self, nFightTeamID1, nFightTeamID2);
    end    

    Log("HuaShanLunJian PlayGameTwo", nFightTeamID1, nFightTeamID2);
end

function tbPreGameMgr:NormalCreatePKMap(nFightTeamID1, nFightTeamID2)
    local tbNotPreData = HuaShanLunJian:GetPrepareGameNotSave();
    local tbPreDef = self:GetPreDef()
    local nCreateMapID = CreateMap(tbPreDef.nPlayMapTID);
    local tbPlayTeam = {};
    tbPlayTeam[nFightTeamID1] = 1;
    tbPlayTeam[nFightTeamID2] = 2;
    tbNotPreData.tbMatchMapTeam[nCreateMapID] = tbPlayTeam;

    local tbTeamInfo1 = self:GetFightTeamInfo(nFightTeamID1);
    tbTeamInfo1.tbAllPlayerPKInfo = {};
    local tbTeamInfo2 = self:GetFightTeamInfo(nFightTeamID2);
    tbTeamInfo2.tbAllPlayerPKInfo = {};

    for nPlayerID, _ in pairs(tbTeamInfo1.tbAllPlayer) do
        local tbInfo1 = {};
        tbInfo1.nMapId = nCreateMapID;
        tbTeamInfo1.tbAllPlayerPKInfo[nPlayerID] = tbInfo1;
    end
    
    for nPlayerID, _ in pairs(tbTeamInfo2.tbAllPlayer) do
        local tbInfo2 = {};
        tbInfo2.nMapId = nCreateMapID;
        tbTeamInfo2.tbAllPlayerPKInfo[nPlayerID] = tbInfo2;
    end

    Log("HuaShanLunJian NormalCreatePKMap", nCreateMapID, nFightTeamID1, nFightTeamID2);
end

function tbPreGameMgr:InitPlayDuelFighTeamInfo(nFightTeamID)
    local tbFightTeam = self:GetFightTeamByID(nFightTeamID);
    local tbTeamInfo = self:GetFightTeamInfo(nFightTeamID);
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

function tbPreGameMgr:ForeachPlayDuelFightTeam(nFightTeamID, tbCallBack)
    local tbTeamInfo = self:GetFightTeamInfo(nFightTeamID);
    if not tbTeamInfo then
        return;
    end
    local tbPreDef = self:GetPreDef()
    for nPlayerID, _ in pairs(tbTeamInfo.tbAllPlayerPKInfo) do
        local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
        if pPlayer then
            local nMapTID = pPlayer.nMapTemplateId;
            if nMapTID == tbPreDef.nPrepareMapTID or nMapTID == tbPreDef.nPlayMapTID then
                Lib:MergeCallBack(tbCallBack, pPlayer);
            end
        end    
    end 
end

function tbPreGameMgr:ShowPlayerAccount(tbAllTeamShowAccount, nCloseTime, pPlayer)
    if not tbAllTeamShowAccount then
        return;
    end    

    local nFightTeamID = self:GetPlayerFightTeam(pPlayer);
    pPlayer.CallClientScript("Ui:OpenWindow", "HSLJAccount", tbAllTeamShowAccount, nFightTeamID, nCloseTime);
    --pPlayer.CallClientScript("Map:SetCloseUiOnLeave", pPlayer.nMapId, "HSLJAccount"); 
end

function tbPreGameMgr:GetPlayDuelTeamShowInfo(nFightTeamID)
    local tbTeamInfo = self:GetFightTeamInfo(nFightTeamID);
    if not tbTeamInfo then
        return;
    end

    local tbFightTeam = self:GetFightTeamByID(nFightTeamID);
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

function tbPreGameMgr:GetPlayerDuelAllShowInfo(nFightTeamID1, nFightTeamID2)
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


function tbPreGameMgr:PlayDuelCreatePKMap(nFightTeamID1, nFightTeamID2)
    self:InitPlayDuelFighTeamInfo(nFightTeamID1);
    self:InitPlayDuelFighTeamInfo(nFightTeamID2);

    local tbGameFormat = self:GetGameFormat();
    local nTotalNum = tbGameFormat.nFightTeamCount;
    for nNum = 1, nTotalNum do
        self:PlayDuelFightTeamPK(nFightTeamID1, nFightTeamID2, nNum);
    end

    local tbTeamInfo1 = self:GetFightTeamInfo(nFightTeamID1);
    if tbTeamInfo1.nTimerCalcPlayDuel then
        Timer:Close(tbTeamInfo1.nTimerCalcPlayDuel);
        tbTeamInfo1.nTimerCalcPlayDuel = nil;
    end    
    tbTeamInfo1.nTimerCalcPlayDuel = Timer:Register(1, self.UpdateCalcPlayDuelResult, self, nFightTeamID1);

    local tbTeamInfo2 = self:GetFightTeamInfo(nFightTeamID2);
    if tbTeamInfo2.nTimerCalcPlayDuel then
        Timer:Close(tbTeamInfo2.nTimerCalcPlayDuel);
        tbTeamInfo2.nTimerCalcPlayDuel = nil;
    end
    tbTeamInfo2.nTimerCalcPlayDuel = Timer:Register(1, self.UpdateCalcPlayDuelResult, self, nFightTeamID2);   

    Log("HSLJ PlayDuelCreatePKMap", nFightTeamID1, nFightTeamID2);
end

function tbPreGameMgr:GetPlayDuelFightTeamWinTime(nFightTeamID)
    local tbTeamInfo = self:GetFightTeamInfo(nFightTeamID);
    if not tbTeamInfo then
        return 0, 0;
    end

    local tbGameFormat = self:GetGameFormat();
    local nTotalNum = tbGameFormat.nFightTeamCount;
    local nWinCount = 0;
    local nTotalTime = 0;
    local nTeamCount = Lib:CountTB(tbTeamInfo.tbAllPlayerPKInfo)
    local tbPreDef = self:GetPreDef();
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


function tbPreGameMgr:UpdateCalcPlayDuelResult(nFightTeamID)
    local tbTeamInfo1 = self:GetFightTeamInfo(nFightTeamID);
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
        tbTeamInfo2 = self:GetFightTeamInfo(nFightTeamID2);
    end

    if not tbTeamInfo2 then
        Log("Error HSLJ UpdateCalcPlayDuelResult tbTeamInfo2", nFightTeamID);
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
        Log("Error HSLJ UpdateCalcPlayDuelResult", nFightTeamID1, nWinCount1, nFightTeamID2, nWinCount2);    
        return;
    end

    local tbAllTeamShowAccount = self:GetPlayerDuelAllShowInfo(nFightTeamID1, nFightTeamID2);
    if tbAllTeamShowAccount then
        local tbPreDef = self:GetPreDef();
        self:ForeachPlayDuelFightTeam(nFightTeamID1, {self.ShowPlayerAccount, self, tbAllTeamShowAccount, tbPreDef.nShowInfoPlayTeamTime});
        self:ForeachPlayDuelFightTeam(nFightTeamID2, {self.ShowPlayerAccount, self, tbAllTeamShowAccount, tbPreDef.nShowInfoPlayTeamTime});
        if nWinTeamId then
            self:ForeachPlayDuelFightTeam(nWinTeamId, {self.SendWinChannaelMsg, self});
        end
    end
        
    Log("HSLJ UpdateCalcPlayDuelResult", nFightTeamID1, nWinCount1, nFightTeamID2, nWinCount2);        
end

function tbPreGameMgr:SetDuelFightTeamResult(nFightTeamID, nResult, nPlayTime)
    local tbTeamInfo = self:GetFightTeamInfo(nFightTeamID);
    if not tbTeamInfo then
        return;
    end

   if tbTeamInfo.nCalcResult ~= TeamPKMgr.tbDef.nPlayNone then
        return;
    end 

    tbTeamInfo.nCalcResult = nResult;

    
    local tbPreDef = self:GetPreDef();
    if nResult == TeamPKMgr.tbDef.nPlayWin then
        self:AddFightTeamJiFen(nFightTeamID, true,  tbPreDef.nWinJiFen, nPlayTime);
    elseif nResult == TeamPKMgr.tbDef.nPlayFail then
        self:AddFightTeamJiFen(nFightTeamID, false, tbPreDef.nFailJiFen, nPlayTime);
        
    elseif nResult == TeamPKMgr.tbDef.nPlayDogfall then
        self:AddFightTeamJiFen(nFightTeamID, false, tbPreDef.nDogfallJiFen, nPlayTime);
    else    
        Log("Error HSLJ SetDuelFightTeamResult Type", nFightTeamID, nResult, nPlayTime);
    end
    self:SendMailAwardDuelFightTeamResult(nFightTeamID, nResult)
    
    Log("HSLJ SetDuelFightTeamResult", nFightTeamID, nResult, nPlayTime);
end

--Z上重载
function tbPreGameMgr:SendMailAwardDuelFightTeamResult(nFightTeamID, nResult)
    local tbPreDef = self:GetPreDef();
    local tbAward;
    local szMailInfo;
    if nResult == TeamPKMgr.tbDef.nPlayWin then
        tbAward = tbPreDef.tbAllAward.tbWin;
        szMailInfo = tbPreDef.tbAwardMail.szWin;
    elseif nResult == TeamPKMgr.tbDef.nPlayFail then
        tbAward = tbPreDef.tbAllAward.tbFail;
        szMailInfo = tbPreDef.tbAwardMail.szFail;
        
    elseif nResult == TeamPKMgr.tbDef.nPlayDogfall then
        tbAward = tbPreDef.tbAllAward.tbDogfall;
        szMailInfo = tbPreDef.tbAwardMail.szDogfall;
    else    
        Log("Error HSLJ SetDuelFightTeamResult Type", nFightTeamID, nResult, nPlayTime);
    end
    if tbAward and szMailInfo then
        HuaShanLunJian:SendTeamPreGameMailAward(nFightTeamID, tbAward, szMailInfo);
    end    
end


function tbPreGameMgr:PlayDuelFightTeamPK(nFightTeamID1, nFightTeamID2, nNum)
    local tbFightTeam1 = self:GetFightTeamByID(nFightTeamID1);
    if not tbFightTeam1 then
        Log("Error HSLJ PlayDuelFightTeamPK tbFightTeam1", nFightTeamID1, nFightTeamID2);
        return;
    end

    local tbFightTeam2 = self:GetFightTeamByID(nFightTeamID2);
    if not tbFightTeam2 then
        Log("Error HSLJ PlayDuelFightTeamPK tbFightTeam2", nFightTeamID1, nFightTeamID2);
        return;
    end

    local tbTeamInfo1 = self:GetFightTeamInfo(nFightTeamID1);
    local tbTeamInfo2 = self:GetFightTeamInfo(nFightTeamID2);

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

    local tbPreDef = self:GetPreDef()
    if not tbPlayerPKInfo1 or not tbPlayerPKInfo2 then
        if tbPlayerPKInfo1 then
            self:SetPlayDuelPlayerResult(nFightTeamID1, nPlayer1, TeamPKMgr.tbDef.nPlayWin, tbPreDef.nMatchEmptyTime);
        end
        
        if tbPlayerPKInfo2 then
            self:SetPlayDuelPlayerResult(nFightTeamID2, nPlayer2, TeamPKMgr.tbDef.nPlayWin, tbPreDef.nMatchEmptyTime);
        end

        local tbAllTeamShowAccount = self:GetPlayerDuelAllShowInfo(nFightTeamID1, nFightTeamID2);
        if tbAllTeamShowAccount then
            if nPlayer1 and tbPlayerPKInfo1 then
                local pPlayer1 = KPlayer.GetPlayerObjById(nPlayer1);
                if pPlayer1 then
                    self:ShowPlayerAccount(tbAllTeamShowAccount, tbPreDef.nShowInfoPlayTeamTime, pPlayer1);
                    pPlayer1.CenterMsg("本場比賽無戰鬥發生，直接產生結果", true);
                    self:UpdateUIInfo(pPlayer1);

                    self:OnPlayerReportData(TeamPKMgr.tbDef.nPlayWin, tbPreDef.nMatchEmptyTime, pPlayer1);
                end    
            end

            if nPlayer2 and tbPlayerPKInfo2 then
                local pPlayer2 = KPlayer.GetPlayerObjById(nPlayer2);
                if pPlayer2 then
                    self:ShowPlayerAccount(tbAllTeamShowAccount, tbPreDef.nShowInfoPlayTeamTime, pPlayer2);
                    pPlayer2.CenterMsg("本場比賽無戰鬥發生，直接產生結果", true);
                    self:UpdateUIInfo(pPlayer2);
                    
                    self:OnPlayerReportData(TeamPKMgr.tbDef.nPlayWin, tbPreDef.nMatchEmptyTime, pPlayer2);
                end    
            end
        end
                
        return;
    end
    
    local tbNotPreData = HuaShanLunJian:GetPrepareGameNotSave();
    local nCreateMapID = CreateMap(tbPreDef.nPlayMapTID);
    local tbPlayTeam = {};
    tbPlayTeam[nFightTeamID1] = 1;
    tbPlayTeam[nFightTeamID2] = 2;
    tbNotPreData.tbMatchMapTeam[nCreateMapID] = tbPlayTeam;

    tbPlayerPKInfo1.nMapId = nCreateMapID;
    tbPlayerPKInfo2.nMapId = nCreateMapID;
end

function tbPreGameMgr:SetPlayDuelPlayerResult(nFightTeamID, nPlayerID, nResult, nPlayTime)
    local tbTeamInfo = self:GetFightTeamInfo(nFightTeamID);
    local tbPlayerPKInfo = tbTeamInfo.tbAllPlayerPKInfo[nPlayerID];
    if not tbPlayerPKInfo then
        return;
    end

    if tbPlayerPKInfo.nResult ~= TeamPKMgr.tbDef.nPlayNone then
        return;
    end    

    tbPlayerPKInfo.nResult = nResult;
    tbPlayerPKInfo.nPlayTime = nPlayTime;
    Log("HSLJ SetPlayDuelPlayerResult", nFightTeamID, nPlayerID, nResult, nPlayTime);
end

function tbPreGameMgr:GetPlayDuelPlayerMapID(nFightTeamID, nMapId)
    local tbTeamInfo = self:GetFightTeamInfo(nFightTeamID);
    if not tbTeamInfo then
        return;
    end

    for nPlayerID, tbInfo in pairs(tbTeamInfo.tbAllPlayerPKInfo) do
        if tbInfo.nMapId == nMapId then
            return nPlayerID;
        end    
    end  
end    

function tbPreGameMgr:OnKickOutAllPlayer()
    self:CloseOnceTimer();
    self:PlayerKickOutAllPlayer();
end

function tbPreGameMgr:PlayerKickOutAllPlayer()
    self:ForeachAllPlayer({self.PlayerKickOut, self});
end

function tbPreGameMgr:ForeachPlayerFightTeam(nFightTeamID, tbCallBack)
    local tbTeamInfo = self:GetFightTeamInfo(nFightTeamID);
    if not tbTeamInfo then
        return;
    end

    for nPlayerID, _ in pairs(tbTeamInfo.tbAllPlayer) do
        local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
        if pPlayer and pPlayer.nMapId == tbTeamInfo.nPreMapMapId then
            Lib:MergeCallBack(tbCallBack, pPlayer);
        end    
    end    
end

function tbPreGameMgr:ForeachAllPlayer(tbCallBack)
    for nMapId, tbInst in pairs(HuaShanLunJian.tbAllPreMapLogicInst) do
        local tbPlayer = KPlayer.GetMapPlayer(nMapId);
        for _, pPlayer in pairs(tbPlayer) do
            if pPlayer then
                Lib:MergeCallBack(tbCallBack, pPlayer);
            end    
        end
    end
end

function tbPreGameMgr:GetFightTeamInfo(nFightTeamID)
    local tbFightTeamInfo = HuaShanLunJian:GetPreGameFightTeamByID(nFightTeamID);
    return tbFightTeamInfo;
end

--重载
function tbPreGameMgr:PlayerKickOut(pPlayer)
    pPlayer.GotoEntryPoint();
    Log("HuaShanLunJian PreLogicMgr PlayerKickOut", pPlayer.nMapTemplateId, pPlayer.dwID);
end

--重载
function tbPreGameMgr:PlayerKickOutMsg(szMsg, pPlayer)
    if szMsg then
        pPlayer.CenterMsg(szMsg, true);
    end

    pPlayer.GotoEntryPoint();    
 end 

--重载
 function tbPreGameMgr:GetMatchName()
     return "華山論劍"
 end

--重载
 function tbPreGameMgr:SendTeamPreGameMailAward(nFightTeamID, tbAllAward, szContent)
     HuaShanLunJian:SendTeamPreGameMailAward(nFightTeamID, tbAllAward, szContent)
 end

 function tbPreGameMgr:SetPlayerTeamTitle(pPlayer, nPlayTeam)
     local nFightTeamID = self:GetPlayerFightTeam(pPlayer);
    if nFightTeamID <= 0 then
        return;
    end

    local tbFightTeam = self:GetFightTeamByID(nFightTeamID);
    if not tbFightTeam then
        return;
    end

    local szName = tbFightTeam:GetName();
    local szText = string.format("戰隊·%s", szName);
    pPlayer.SetShowTitle(tbDef.nFightTeamShowTitle[nPlayTeam] or 0, szText);
    pPlayer.LockTitle(true);
 end

 function tbPreGameMgr:ClearPlayerTeamTitle(pPlayer)
    pPlayer.ClearShowTitle()
    pPlayer.LockTitle(nil);
end

--重载
function tbPreGameMgr:GetAllFinalsFightTeam()
   return HuaShanLunJian:GetAllFinalsFightTeam(); 
end

--重载
function tbPreGameMgr:SendWinChannaelMsg(pPlayer, bFinal)
    local szKinMsg, szFriendMsg;
    local tbGameFormat = self:GetGameFormat()
    local tbGameDef = bFinal and tbDef.tbFinalsGame or tbDef.tbPrepareGame
    if tbGameDef.szWinNotifyInKin then
        szKinMsg = string.format(tbGameDef.szWinNotifyInKin, pPlayer.szName)
        if pPlayer.dwKinId ~= 0 then
            ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szKinMsg, pPlayer.dwKinId)
        end
    end
    if tbGameDef.szWinNotifyInFriend then
        szFriendMsg = string.format(tbGameDef.szWinNotifyInFriend, pPlayer.szName)
        ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Friend, szFriendMsg, pPlayer.dwID);
    end
end

--重载
function tbPreGameMgr:GetFreePreMapID()
    local tbPreDef = self:GetPreDef()
    for nMapId, tbInst in pairs(HuaShanLunJian.tbAllPreMapLogicInst) do
        local  nCount = tbInst:GetFightTeamEnterCount();
        if nCount < tbPreDef.nMaxEnterTeamCount then
            return nMapId;
        end    
    end
    return; 
end