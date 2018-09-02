
Require("CommonScript/HuaShanLunJian/LunJianDef.lua");
local tbDef             = HuaShanLunJian.tbDef;
local tbFinalsDef       = tbDef.tbFinalsGame;
local tbGuessingDef     = tbDef.tbChampionGuessing;

HuaShanLunJian.tbFightTeamNotSave = HuaShanLunJian.tbFightTeamNotSave or {}; --战队不保存数据
HuaShanLunJian.tbPrepareGameNotSave = HuaShanLunJian.tbPrepareGameNotSave or {}; --预选赛不保存数据
HuaShanLunJian.tbFinalsGameNotSave = HuaShanLunJian.tbFinalsGameNotSave or {}; --决赛不保存数据

function HuaShanLunJian:LoadSetting()
    self.tbAllMapPosSetting = {};
    local tbFileData = Lib:LoadTabFile("Setting/HuaShanLunJian/MapPos.tab", {MapTID = 1, PosX = 1, PosY = 1});
    for nRow, tbInfo in pairs(tbFileData) do
        self.tbAllMapPosSetting[tbInfo.MapTID] = self.tbAllMapPosSetting[tbInfo.MapTID] or {};
        table.insert(self.tbAllMapPosSetting[tbInfo.MapTID], tbInfo);
    end

    self.tbAllGameFormatAward = {};
    tbFileData = Lib:LoadTabFile("Setting/HuaShanLunJian/GameFormatAward.tab", {GameFormat = 1, MinRank = 1, MaxRank = 1, MinJoin = 1, BaoDiJoin = 1});
    for nRow, tbInfo in pairs(tbFileData) do
        tbInfo.tbAllAward = {};
        if not Lib:IsEmptyStr(tbInfo["AllAward"]) then
            tbInfo.tbAllAward = Lib:GetAwardFromString(tbInfo["AllAward"]);
        end

        if not Lib:IsEmptyStr(tbInfo["BaoDiAllAward"]) then
            tbInfo.tbBaoDiAward = Lib:GetAwardFromString(tbInfo["BaoDiAllAward"]);
        end

        self.tbAllGameFormatAward[tbInfo.GameFormat] = self.tbAllGameFormatAward[tbInfo.GameFormat] or {};
        table.insert(self.tbAllGameFormatAward[tbInfo.GameFormat], tbInfo);
    end

    self.tbAllWatchPosSetting = {};
    tbFileData = Lib:LoadTabFile("Setting/HuaShanLunJian/WatchPos.tab", {MapTID = 1, Area = 1, PosX = 1, PosY = 1});
    for nRow, tbInfo in pairs(tbFileData) do
        self.tbAllWatchPosSetting[tbInfo.MapTID] = self.tbAllWatchPosSetting[tbInfo.MapTID] or {};
        self.tbAllWatchPosSetting[tbInfo.MapTID][tbInfo.Area] = self.tbAllWatchPosSetting[tbInfo.MapTID][tbInfo.Area] or {};
        table.insert(self.tbAllWatchPosSetting[tbInfo.MapTID][tbInfo.Area], tbInfo);
    end
end

HuaShanLunJian:LoadSetting();

function HuaShanLunJian:GetMapAllPosByTID(nMapTID)
    return self.tbAllMapPosSetting[nMapTID];
end

function HuaShanLunJian:GetWatchPosByArea(nMapTID, nArea)
    return self.tbAllWatchPosSetting[nMapTID][nArea]
end

function HuaShanLunJian:GetGameFormatAwardInfo(nGameFormat, nRank)
    local tbGameFormat = self.tbAllGameFormatAward[nGameFormat];
    if not tbGameFormat then
        return;
    end

    for nI, tbInfo in ipairs(tbGameFormat) do
        if tbInfo.MinRank <= nRank and nRank <= tbInfo.MaxRank then
            return tbInfo;
        end
    end
end

function HuaShanLunJian:GetFinalsGameNotSave()
    local tbNotSave = self.tbFinalsGameNotSave;
    tbNotSave.tbFinalsAllMapID = tbNotSave.tbFinalsAllMapID or {};
    tbNotSave.tbFinalsAllMapIndex = tbNotSave.tbFinalsAllMapIndex or {};

    return self.tbFinalsGameNotSave;
end

function HuaShanLunJian:GetFinalsMapIDByIndex(nIndex)
    local tbNotSave = self:GetFinalsGameNotSave();
    local tbAllMapIndex = tbNotSave.tbFinalsAllMapIndex;
    if not tbAllMapIndex then
        return;
    end

    return tbAllMapIndex[nIndex];
end

function HuaShanLunJian:GetFinalsMapIndexByID(nMapId)
    local tbNotSave = self:GetFinalsGameNotSave();
    local tbAllMapID = tbNotSave.tbFinalsAllMapID;
    if not tbAllMapID then
        return;
    end

    return tbAllMapID[nMapId];
end

function HuaShanLunJian:PlayerReportPkData(pPlayer, tbData)
    local szReportData = string.format("%s", tbData.nResult or 0);
    AssistClient:ReportQQScore(pPlayer, Env.QQReport_HSLJResult, szReportData, 0, 1);

    szReportData = string.format("%s", tbData.nKillCount or 0);
    AssistClient:ReportQQScore(pPlayer, Env.QQReport_HSLJKillCount, szReportData, 0, 1)

    szReportData = string.format("%s", tbData.nDeathCount or 0);
    AssistClient:ReportQQScore(pPlayer, Env.QQReport_HSLJDeathCount, szReportData, 0, 1)

    szReportData = string.format("%s", tbData.nPlayTime or 0);
    AssistClient:ReportQQScore(pPlayer, Env.QQReport_HSLJPlayTime, szReportData, 0, 1)

    if tbData.nResult == Env.LogRound_SUCCESS then
        Lib:CallBack({RecordStone.AddRecordCount, RecordStone, pPlayer, "HuaShan", 1});
    end    
end

function HuaShanLunJian:GetPrepareGameNotSave()
    self.tbPrepareGameNotSave.tbPreGameFightTeam = self.tbPrepareGameNotSave.tbPreGameFightTeam or {};
    self.tbPrepareGameNotSave.tbMatchMapTeam   =  self.tbPrepareGameNotSave.tbMatchMapTeam  or {};
    return self.tbPrepareGameNotSave;
end

function HuaShanLunJian:ClearPrepareGameNotSave()
   self.tbPrepareGameNotSave = {}
end

function HuaShanLunJian:CheckUpdateGameFormat()
    if GetTimeFrameState(tbDef.szOpenTimeFrame) ~= 1 then
        return false;
    end

    local nMonthDay = Lib:GetMonthDay();
    if nMonthDay < tbDef.tbPrepareGame.nStartMonthDay or nMonthDay > tbDef.tbPrepareGame.nStartEndMonthDay then
        return false;
    end

    if nMonthDay == tbDef.tbPrepareGame.nStartMonthDay then
        local nDayTime = Lib:GetTodaySec();
        local nStartOpenTime = tbDef.tbPrepareGame.nStartOpenTime - 120;
        if nStartOpenTime > nDayTime then
            return false;
        end
    end

    return true;
end

function HuaShanLunJian:UpdateGameFormat()
    local bRet = self:CheckUpdateGameFormat();
    if not bRet then
        return;
    end

    local tbSaveData = ScriptData:GetValue("HuaShanLunJianData");
    local nCurMonth = Lib:GetLocalMonth();
    if tbSaveData.nGameMonth and tbSaveData.nGameMonth == nCurMonth then
        return;
    end

    tbSaveData.nGameFormatType = tbSaveData.nGameFormatType or 0;
    tbSaveData.nGameFormatType = tbSaveData.nGameFormatType + 1;

    if tbDef.tbChangeGameFormat then
        local nChangeFormat = tbDef.tbChangeGameFormat[tbSaveData.nGameFormatType];
        if nChangeFormat then
            Log("HSLJ UpdateGameFormat ChangeGameFormat", tbSaveData.nGameFormatType, nChangeFormat);
            tbSaveData.nGameFormatType = nChangeFormat;
        end    
    end    

    if not tbDef.tbGameFormat[tbSaveData.nGameFormatType] then
        tbSaveData.nGameFormatType = 1;
    end

    tbSaveData.nGameMonth = nCurMonth;
    tbSaveData.nPlayState = tbDef.nPlayStateNone;
    tbSaveData.tbFinalsFightTeam = {};
    tbSaveData.nFightTeamVer      = 1;
    tbSaveData.nChampionId        = 0; --冠军队伍
    tbSaveData.nGuessingVer       = 1;
    tbSaveData.bEndAward          = false; --发送决赛的奖励
    tbSaveData.nWeekDay           = Lib:GetLocalWeek();

    self.tbFightTeamNotSave.bLoadData = false;
    self.tbFightTeamNotSave.tbAllFightTeamName = {};
    self.tbFightTeamNotSave.tbAllFightTeamInst = {};

    RankBoard:ClearRank(tbDef.szRankBoard);
    Lib:CallBack({NewInformation.RemoveInfomation, NewInformation, "HSLJChampionship"});
    self:UpdateAllPlayerFightTeamID();
    self:UpdateAllPlayerGuessingVersion();
    self.tbSynctbAllMatchFightTeam = nil;
    Log("HuaShanLunJian Init CompetitionFormat", tbSaveData.nGameFormatType, tbSaveData.nGameMonth);
end

function HuaShanLunJian:GetLunJianSaveData()
    local tbSaveData = ScriptData:GetValue("HuaShanLunJianData");
    tbSaveData.nGameFormatType = tbSaveData.nGameFormatType or 0;
    tbSaveData.nGameMonth = tbSaveData.nGameMonth or 0;
    tbSaveData.nPlayState = tbSaveData.nPlayState or tbDef.nPlayStateNone;
    tbSaveData.tbFinalsFightTeam = tbSaveData.tbFinalsFightTeam or {};
    tbSaveData.nFightTeamVer      = tbSaveData.nFightTeamVer or 1;
    tbSaveData.nChampionId        = tbSaveData.nChampionId or 0;
    tbSaveData.nGuessingVer       = tbSaveData.nGuessingVer or 1;
    tbSaveData.nWeekDay           = tbSaveData.nWeekDay or 0;

    return tbSaveData;
end

function HuaShanLunJian:GetGameFormat()
    local tbSaveData = self:GetLunJianSaveData();
    local tbInfo = tbDef.tbGameFormat[tbSaveData.nGameFormatType];
    return tbInfo;
end

--是否比赛期间
function HuaShanLunJian:IsPlayGamePeriod()
    if GetTimeFrameState(tbDef.szOpenTimeFrame) ~= 1 then
        return false;
    end

    local tbSaveData = self:GetLunJianSaveData();
    local nCurMonth = Lib:GetLocalMonth();
    if not tbSaveData.nGameMonth or tbSaveData.nGameMonth ~= nCurMonth then
        return false;
    end

    local nMonthDay = Lib:GetMonthDay();
    if nMonthDay < tbDef.tbPrepareGame.nStartMonthDay or nMonthDay > tbDef.tbFinalsGame.nMonthDay then
        return false;
    end

    return true;
end

function HuaShanLunJian:UpdatePlayerSaveData(pPlayer)
    local tbSaveData = self:GetLunJianSaveData();
    local nCurMonth = tbSaveData.nGameMonth;
    local nMonth = pPlayer.GetUserValue(tbDef.nSaveGroupID, tbDef.nSaveMonth);
    if nMonth == nCurMonth then
        return;
    end

    pPlayer.SetUserValue(tbDef.nSaveGroupID, tbDef.nSaveMonth, nCurMonth);
    pPlayer.SetUserValue(tbDef.nSaveGroupID, tbDef.nSaveFightTeamID, 0);

    pPlayer.SetUserValue(tbDef.nSaveGuessGroupID, tbDef.nSaveGuessVer, 0);
    pPlayer.SetUserValue(tbDef.nSaveGuessGroupID, tbDef.nSaveGuessTeam, 0);
    pPlayer.SetUserValue(tbDef.nSaveGuessGroupID, tbDef.nSaveGuessOneNote, 0);
end


function HuaShanLunJian:GetPlayerInfoByID(nPlayerID)
    local tbInfo = {};
    tbInfo.szName   = "-";
    tbInfo.nFaction = 1;

    local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
    if not pPlayer then
        local tbStayInfo = KPlayer.GetRoleStayInfo(nPlayerID);
        if tbStayInfo then
            tbInfo.szName = tbStayInfo.szName;
            tbInfo.nFaction = tbStayInfo.nFaction;
            tbInfo.nLevel = tbStayInfo.nLevel;
        end
    else
        tbInfo.szName = pPlayer.szName;
        tbInfo.nFaction = pPlayer.nFaction;
        tbInfo.nLevel = pPlayer.nLevel;
    end

    return tbInfo;
end

function HuaShanLunJian:CheckCanOpenHSLJ()
    if GetTimeFrameState(tbDef.szOpenTimeFrame) ~= 1 then
        return false;
    end

    local tbSaveData = self:GetLunJianSaveData();
    local nCurMonth = Lib:GetLocalMonth();
    if not tbSaveData.nGameMonth or tbSaveData.nGameMonth ~= nCurMonth then
        return false;
    end

    return true;
end

function HuaShanLunJian:CheckStartPrepareGame()
    local bRet = self:CheckCanOpenHSLJ();
    if not bRet then
        return false;
    end

    local nMonthDay = Lib:GetMonthDay();
    if nMonthDay < tbDef.tbPrepareGame.nStartMonthDay or nMonthDay > tbDef.tbPrepareGame.nEndMothDay then
        return false;
    end

    local tbSaveData = self:GetLunJianSaveData();
    if tbSaveData.nPlayState ~= tbDef.nPlayStateNone and
       tbSaveData.nPlayState ~= tbDef.nPlayStatePrepare and
       tbSaveData.nPlayState ~= tbDef.nPlayStateMail then
        return false;
    end

    return true;
end

--准备开启预选赛
function HuaShanLunJian:PreStartPrepareGame()
    local bRet = self:CheckStartPrepareGame();
    if not bRet then
        return;
    end

    KPlayer.SendWorldNotify(1, 999, tbDef.tbPrepareGame.szStartWorldNotify, 1, 1);
    Log("HuaShanLunJian PreStartPrepareGame");
end

--开启预选赛
function HuaShanLunJian:StartPrepareGame()
    local bRet = self:CheckStartPrepareGame();
    if not bRet then
        return;
    end

    local tbSaveData = self:GetLunJianSaveData();
    tbSaveData.nPlayState = tbDef.nPlayStatePrepare;

    local tbNotPreData = self:GetPrepareGameNotSave();
    tbNotPreData.bStart = true;
    tbNotPreData.nPlayGameCount = tbDef.tbPrepareGame.nPlayerGameCount;
    tbNotPreData.tbPreGameFightTeam = {};
    tbNotPreData.tbMatchMapTeam = {};

    self.tbPreGamePreMgr:StartPreGame()

    local tbMsgData =
    {
        szType = "HuaShanLunJian";
        nTimeOut = GetTime() + 1800;
    };

    KPlayer.BoardcastScript(tbDef.nMinPlayerLevel, "Ui:SynNotifyMsg", tbMsgData);
    Calendar:OnActivityBegin("HuaShanLunJian");
    Log("HuaShanLunJian StartPrepareGame", tbSaveData.nGameMonth);
end

--关闭预选赛
function HuaShanLunJian:CloseEnterPreGame()
    local tbNotPreData = self:GetPrepareGameNotSave();
    if not tbNotPreData.bStart then
        return;
    end

    tbNotPreData.bStart = false;
    RankBoard:Rank(tbDef.szRankBoard);
    Calendar:OnActivityEnd("HuaShanLunJian");
    Log("HuaShanLunJian EndDayPrepareGame");
end

function HuaShanLunJian:GetPrepareGameFightTeam()
    local tbNotPreData = self:GetPrepareGameNotSave();
    tbNotPreData.tbPreGameFightTeam = tbNotPreData.tbPreGameFightTeam or {};
    return tbNotPreData.tbPreGameFightTeam;
end

function HuaShanLunJian:GetPreGameFightTeamByID(nFightTeamID)
    local tbAllFightTeam = self:GetPrepareGameFightTeam();
    local tbTeamInfo = tbAllFightTeam[nFightTeamID];
    if not tbTeamInfo then
        tbTeamInfo =
        {
            nFightTeamID = nFightTeamID;
            tbAllPlayer  = {};
            nTeamId      = 0;
            tbAllMatchTeam = {};
            tbAllPlayerPKInfo = {};
            nEnemyFightTeam = 0;
            nCalcResult = TeamPKMgr.tbDef.nPlayNone;
            bMatchEmpty = false;
            nPreMapMapId = nil;
        };

        tbAllFightTeam[nFightTeamID] = tbTeamInfo;
    end
    return tbTeamInfo;
end

function HuaShanLunJian:AddFightTeamJiFen(nFightTeamID, bWin, nJiFen, nPlayTime)
   local tbFightTeam = self:GetFightTeamByID(nFightTeamID);
   if not tbFightTeam then
        return;
   end

   if bWin then
        tbFightTeam:AddWinCount();
   end

   if nJiFen > 0 then
       tbFightTeam:AddJiFen(nJiFen);
   end

   tbFightTeam:AddPlayTime(nPlayTime);
   tbFightTeam:UpdateHSLJRankBoard();

   Log("HuaShanLunJian AddFightTeamJiFen", nFightTeamID, nJiFen, nPlayTime);
end

function HuaShanLunJian:CheckStartFinalsPlayGame()
    local bRet = self:CheckCanOpenHSLJ();
    if not bRet then
        return false;
    end

    local tbSaveData = self:GetLunJianSaveData();
    local nMonthDay = Lib:GetMonthDay();
    if nMonthDay ~= tbFinalsDef.nMonthDay then
        return false;
    end

    if tbSaveData.nPlayState ~= tbDef.nPlayStatePrepare then
        return false;
    end

    local tbNotFinalsData = self:GetFinalsGameNotSave();
    if tbNotFinalsData.bStart then
        return false;
    end

    return true;
end

function HuaShanLunJian:UpdateFinalsFightTeam(bRank)
    local tbSaveData = self:GetLunJianSaveData();
    local tbAllFightTeam = tbSaveData.tbFinalsFightTeam;
    local nTeamCount = Lib:CountTB(tbAllFightTeam);
    if nTeamCount > 0 then
        return;
    end

    local pRank = KRank.GetRankBoard(tbDef.szRankBoard)
    if not pRank then
        Log("Error UpdateFinalsFightTeam Not RankBoard");
        return
    end

    if bRank then
        RankBoard:Rank(tbDef.szRankBoard);
        Log("UpdateFinalsFightTeam Rank");
    end

    for nRank = 1, tbFinalsDef.nFrontRank do
        local tbInfo = pRank.GetRankInfoByPos(nRank - 1);
        if tbInfo then
            local tbFinalsInfo =
            {
                nRank = nRank;
                nPlan = 0;
                nNote = 0; --投注的注数
            };
            tbAllFightTeam[tbInfo.dwUnitID] = tbFinalsInfo;

            Log("HSLJ UpdateFinalsFightTeam", tbInfo.dwUnitID, nRank);
        else
            Log("HSLJ UpdateFinalsFightTeam Not Rank", nRank);
        end
    end
end

function HuaShanLunJian:GetFinalsFightTeamByID(nFightTeamID)
    local tbAllFightTeam = self:GetAllFinalsFightTeam();
    return tbAllFightTeam[nFightTeamID]
end

function HuaShanLunJian:GetAllFinalsFightTeam()
    local tbSaveData = self:GetLunJianSaveData();
    return tbSaveData.tbFinalsFightTeam;
end

--开启决赛前
function HuaShanLunJian:PreStartFinalsPlayGame()
    local bRet = self:CheckStartFinalsPlayGame();
    if not bRet then
        return;
    end


    KPlayer.SendWorldNotify(1, 999, "本屆華山論劍冠軍爭奪戰將在[FFFE0D]3分鐘[-]後開始進場，請各位參賽選手提前準備！", 1, 1);
end

--开启决赛
function HuaShanLunJian:StartFinalsPlayGame()
    local bRet = self:CheckStartFinalsPlayGame();
    if not bRet then
        return;
    end

    local tbSaveData = self:GetLunJianSaveData();
    tbSaveData.nPlayState = tbDef.nPlayStateFinals;

    local tbNotFinalsData = self:GetFinalsGameNotSave();
    tbNotFinalsData.bStart = true;
    tbNotFinalsData.tbFinalsAllMapID = {};
    tbNotFinalsData.tbFinalsAllMapIndex = {};
    local tbBaseLogic = HuaShanLunJian.tbBaseFinalsMapLogic;
    tbNotFinalsData.tbFinalsLogicMgr = Lib:NewClass(tbBaseLogic);
    tbNotFinalsData.tbFinalsLogicMgr:OnCreate();

    self:UpdateFinalsFightTeam(true);

    local tbGameFormat = self:GetGameFormat();
    local nCreateCount = 1;
    if tbGameFormat.nFinalsMapCount then
        nCreateCount = tbGameFormat.nFinalsMapCount;
    end

    for nI = 1, nCreateCount do
        CreateMap(tbFinalsDef.nFinalsMapTID);
    end

    local tbMsgData =
    {
        szType = "HuaShanLunJian";
        nTimeOut = GetTime() + 1800;
    };

    KPlayer.BoardcastScript(tbFinalsDef.nAudienceMinLevel, "Ui:SynNotifyMsg", tbMsgData);
    Calendar:OnActivityBegin("HuaShanLunJian1");
    Log("HSLJ StartFinalsPlayGame", tbSaveData.nGameMonth);
end

--关闭决赛
function HuaShanLunJian:CloseFinalsPlayGame()
    local tbNotFinalsData = self:GetFinalsGameNotSave();
    if not tbNotFinalsData.bStart then
        return;
    end

    local tbSaveData = self:GetLunJianSaveData();
    tbSaveData.nPlayState = tbDef.nPlayStateEnd;
    tbNotFinalsData.bStart = false;
    Calendar:OnActivityEnd("HuaShanLunJian1");
    Log("HSLJ CloseFinalsPlayGame");
end

function HuaShanLunJian:CheckInformFinalsFightTeamList()
    local bRet = self:CheckCanOpenHSLJ();
    if not bRet then
        return false;
    end

    local nMonthDay = Lib:GetMonthDay();
    if nMonthDay ~= tbFinalsDef.nMonthDay then
        return false;
    end

    return true;
end

--决赛的名单
function HuaShanLunJian:InformFinalsFightTeamList()
    local bRet = self:CheckInformFinalsFightTeamList();
    if not bRet then
        return;
    end

    local pRank = KRank.GetRankBoard(tbDef.szRankBoard)
    if not pRank then
        Log("Error InformFinalsFightTeamList Not RankBoard");
        return
    end

    RankBoard:Rank(tbDef.szRankBoard);
    --local tbSaveData = self:GetLunJianSaveData();
    --tbSaveData.tbFinalsFightTeam = {};
    self:UpdateFinalsFightTeam(false);
    self:SendInformFinalsListInfo();
    Log("HSLJ InformFinalsFightTeamList");
end

function HuaShanLunJian:SendInformFinalsListInfo()
    local pRank = KRank.GetRankBoard(tbDef.szRankBoard)
    if not pRank then
        Log("Error InformFinalsFightTeamList Not RankBoard");
        return
    end

    local tbAllTeamNewInfo = {};
    for nRank = 1, tbFinalsDef.nFrontRank do
        local tbInfo = pRank.GetRankInfoByPos(nRank - 1);
        if tbInfo then
            local tbFightTeam = self:GetFightTeamByID(tbInfo.dwUnitID);
            if tbFightTeam then
                local tbTeamNewInfo = {};
                tbTeamNewInfo.szName = tbFightTeam:GetName();
                tbTeamNewInfo.nJiFen = tbFightTeam:GetJiFen();
                tbTeamNewInfo.nWin   = tbFightTeam:GetWinCount();
                tbTeamNewInfo.nTime  = tbFightTeam:GetPlayTime();
                tbTeamNewInfo.nId    = tbFightTeam:GetID();
                tbAllTeamNewInfo[nRank] = tbTeamNewInfo;

                local tbAllPlayer = tbFightTeam:GetAllPlayerID();
                for nPlayerID, _ in pairs(tbAllPlayer) do
                    local tbMail =
                    {
                        To = nPlayerID,
                        Text = tbFinalsDef.szInformFinals;
                    }
                    Mail:SendSystemMail(tbMail);
                end
                Log("InformFinalsFightTeamList FightTeam", nRank, tbInfo.dwUnitID);
            end
        end
    end

    NewInformation:AddInfomation("HSLJEightRank", GetTime() + 24 * 60 * 60, tbAllTeamNewInfo);

    local szContent = tbDef.szEightRankMail;
    local tbMail =
    {
        Title = "華山論劍",
        Text = szContent,
        LevelLimit = tbDef.nMinPlayerLevel,
    };

    Mail:SendGlobalSystemMail(tbMail)
end

function HuaShanLunJian:FinalsFightTeamAward()
    local tbSaveData = self:GetLunJianSaveData();
    if tbSaveData.bEndAward then
        Log("Error HSLJ FinalsFightTeamAward bEndAward");
        return;
    end

    tbSaveData.bEndAward = true;

    self:GameFormatFightTeamAward();
    self:ChampionGuessingAward();
    self:ChampionFightTeamStatue();

    local tbSaveData = self:GetLunJianSaveData();
    HuaShanLunJian:ForeachPlayer(tbSaveData.nChampionId, function (nPlayerId)
        local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
        if not pPlayer then
            return;
        end

        pPlayer.CallClientScript("GameSetting.Comment:OnEvent", GameSetting.Comment.Type_HuaShanLunJian_First);
    end);

    Lib:CallBack({self.ChampionAchievement, self});
    Log("HSLJ FinalsFightTeamAward", tbSaveData.nChampionId);
end

function HuaShanLunJian:ChampionAchievement()
    local tbSaveData = self:GetLunJianSaveData();
    local tbFightTeam = self:GetFightTeamByID(tbSaveData.nChampionId);
    if not tbFightTeam then
        return;
    end

    local tbAllPlayer = tbFightTeam:GetAllPlayerID();
    for nPlayerID, _ in pairs(tbAllPlayer) do
        Achievement:AddCount(nPlayerID, "HuaShanLunJian_1", 1);
    end
end

function HuaShanLunJian:ForeachPlayer(nTeamId, fn)
    local tbFightTeam = self:GetFightTeamByID(nTeamId);
    if not tbFightTeam then
        return;
    end

    local tbAllPlayer = tbFightTeam:GetAllPlayerID();
    for nPlayerID, _ in pairs(tbAllPlayer) do
        fn(nPlayerID);
    end
end

function HuaShanLunJian:ChampionFightTeamStatue()
    Map:ClearMapStatue(tbDef.nStatueMapID, "HuaShanLunJian");

    local tbStatueSave = self:GetPlayerStatueSave();
    tbStatueSave.nType = 0;
    tbStatueSave.tbAllPlayer = {};

    local tbSaveData = self:GetLunJianSaveData();
    if tbSaveData.nChampionId <= 0 then
        return;
    end

    local tbFightTeam = self:GetFightTeamByID(tbSaveData.nChampionId);
    if not tbFightTeam then
        return;
    end

    tbStatueSave.nType = tbSaveData.nGameFormatType;
    tbStatueSave.tbAllPlayer = {};

    local tbAllPlayer = tbFightTeam:GetAllPlayerID();
    for nPlayerID, _ in pairs(tbAllPlayer) do
        table.insert(tbStatueSave.tbAllPlayer, nPlayerID);
    end

    self:CreateChampionStatue();
    Log("HSLJ ChampionFightTeamStatue", tbSaveData.nChampionId);
end

function HuaShanLunJian:GetFinalsFightTeamRank(nFightTeamID)
    if not self.tbFinalsFightTeamRank then
        return;
    end

    return self.tbFinalsFightTeamRank[nFightTeamID];    
end

function HuaShanLunJian:GameFormatFightTeamAward()
    self.tbPlayerFetchFinalsAward = {};
    self.tbFinalsFightTeamRank = {};

    local tbSaveData = self:GetLunJianSaveData();
    local tbSortValue = {};
    local tbAllFightTeam = self:GetAllFinalsFightTeam();
    for nFightTeamID, tbInfo in pairs(tbAllFightTeam) do
        local nValue = tbInfo.nPlan * 1000 + tbInfo.nRank;
        if tbSaveData.nChampionId > 0 and tbSaveData.nChampionId == nFightTeamID then
            nValue = 1;
        end

        local tbTeamValue = {};
        tbTeamValue.nFightTeamID = nFightTeamID;
        tbTeamValue.nValue = nValue;
        tbTeamValue.nPreRank = tbInfo.nRank;
        tbTeamValue.nPlan = tbInfo.nPlan;
        table.insert(tbSortValue, tbTeamValue);    
    end

    table.sort(tbSortValue, function (a, b)
        return a.nValue < b.nValue;
    end)

    for nRank, tbInfo in pairs(tbSortValue) do
        local nCurRank = nRank;
        local nMinRank = math.floor(tbInfo.nPlan / 2 + 1);
        nMinRank = math.max(nMinRank, 2);
        nCurRank = math.max(nMinRank, nCurRank);

        if tbSaveData.nChampionId > 0 and tbSaveData.nChampionId == tbInfo.nFightTeamID then
            nCurRank = 1;
        end
 
        local tbValue = {};
        tbValue.nRank = nCurRank;
        tbValue.nValue = tbInfo.nValue;
        tbValue.nPreRank = tbInfo.nPreRank;
        tbValue.nPlan = tbInfo.nPlan;
        self.tbFinalsFightTeamRank[tbInfo.nFightTeamID] = tbValue;
    end 

    Log("..............HSLJ FinalsFightTeam Rank.................");
    Lib:LogTB(self.tbFinalsFightTeamRank);
    Log("..............HSLJ FinalsFightTeam Rank.................");

    for nVer = 1, tbDef.nMaxFightTeamVer - 1 do
        local bRet = self:HaveFightTeamSavaData(nVer);
        if bRet then
            self:SendGameFormatFightTeamByV(nVer);
        else
            break;
        end
    end

    Log("HSLJ GameFormatFightTeamAward");
end

function HuaShanLunJian:SendGameFormatFightTeamByV(nVersion)
    local tbTeamSaveData = self:GetFightTeamSavaData(nVersion);
    if not tbTeamSaveData then
        return;
    end

    local pRank = KRank.GetRankBoard(tbDef.szRankBoard)
    if not pRank then
        return
    end

    for nFightTeamID, _ in pairs(tbTeamSaveData.tbAllTeam) do
        local nRank, nPrePos = self:GetGameFormatTeamRank(nFightTeamID, pRank);
        if nRank then
            self:SendGameFormatTeamAward(nFightTeamID, nRank);

            local tbFightTeam = self:GetFightTeamByID(nFightTeamID);
            if nPrePos and tbFightTeam then
                tbFightTeam:AddCalendarCompleteAct(nPrePos);  
            end    
        end
    end

    Log("HSLJ SendGameFormatFightTeamByV", nVersion);
end

function HuaShanLunJian:CheckSendGameFormatTeamAward(nFightTeamID, nRank)
    if not nRank then
        return false, "Not Rank";
    end

    local tbFightTeam = self:GetFightTeamByID(nFightTeamID);
    if not tbFightTeam then
        return false, "Not FightTeam";
    end

    local tbSaveData = self:GetLunJianSaveData();
    local tbAwardInfo = self:GetGameFormatAwardInfo(tbSaveData.nGameFormatType, nRank);
    if not tbAwardInfo then
        return false, "Not AwardInfo";
    end

    local nJoinCount = tbFightTeam:GetJoinCount();
    if tbAwardInfo.MinJoin > 0 and nJoinCount < tbAwardInfo.MinJoin then
        return false, "Min Join Count";
    end

    local tbAllAward = tbAwardInfo.tbAllAward;
    if tbAwardInfo.BaoDiJoin > 0 and nJoinCount >= tbAwardInfo.BaoDiJoin and tbAwardInfo.tbBaoDiAward then
        tbAllAward = tbAwardInfo.tbBaoDiAward;
    end

    return true, "", tbFightTeam, tbAwardInfo, tbAllAward;
end

function HuaShanLunJian:SendGameFormatTeamAward(nFightTeamID, nRank)
    local bRet, szMsg, tbFightTeam, tbAwardInfo, tbGetAllAward = self:CheckSendGameFormatTeamAward(nFightTeamID, nRank);
    if not bRet then
        Log("HSLJ SendGameFormatTeamAward", nFightTeamID, nRank, szMsg);
        return;
    end

    local tbAllAward = {};
    for _, tbAward in pairs(tbGetAllAward) do
        local tbAddAward = {};
        if tbAward[1] == "AddTimeTitle" then
            local nTime = GetTime() + tbAward[3];
            tbAddAward = {"AddTimeTitle", tbAward[2], nTime};
        else
            tbAddAward = tbAward;
        end

        table.insert(tbAllAward, tbAddAward);
    end

    self.tbPlayerFetchFinalsAward = self.tbPlayerFetchFinalsAward or {};
    local tbAllPlayer = tbFightTeam:GetAllPlayerID();
    for nPlayerID, _ in pairs(tbAllPlayer) do
        if not self.tbPlayerFetchFinalsAward[nPlayerID] then
            self.tbPlayerFetchFinalsAward[nPlayerID] = 1;

            local tbMail =
            {
                To = nPlayerID,
                Title = "華山論劍",
                Text = tbAwardInfo.MailConent;
                nLogReazon = Env.LogWay_HSLJFinalsAward;
                tbAttach = tbAllAward,
            }

            Mail:SendSystemMail(tbMail);
            Log("HSLJ SendGameFormatTeamAward FightTeam", nFightTeamID, nPlayerID, nRank);
        else
            Log("Error HSLJ SendGameFormatTeamAward Have Player", nFightTeamID, nPlayerID, nRank);
        end
    end
end

function HuaShanLunJian:GetGameFormatTeamRank(nFightTeamID, pRank)
    local tbSaveData = self:GetLunJianSaveData();
    local tbInfo = pRank.GetRankInfoByID(nFightTeamID);
    local nPrePos = -1;
    if tbInfo then
        nPrePos = tbInfo.nPosition;
    end
        
    if tbSaveData.nChampionId == nFightTeamID then
        return 1, nPrePos;
    end

    local tbFinalsRank = self:GetFinalsFightTeamRank(nFightTeamID);
    if tbFinalsRank then
        return tbFinalsRank.nRank, nPrePos;
    end

    --local tbInfo = pRank.GetRankInfoByID(nFightTeamID)
    if not tbInfo then
        return tbDef.nGameMaxRank, nPrePos;
    end

    if tbInfo.nPosition <= 0 then
        return tbDef.nGameMaxRank, nPrePos;
    end

    if tbInfo.nPosition <= tbFinalsDef.nFrontRank then
        Log("Error HuaShanLunJian GetGameFormatTeamRank", nFightTeamID, tbInfo.nPosition);
        return;
    end

    return tbInfo.nPosition, nPrePos;
end

function HuaShanLunJian:ChampionGuessingAward()
    local tbSaveData = self:GetLunJianSaveData();
    if tbSaveData.nChampionId <= 0 then
        Log("Error HSLJ ChampionGuessingAward nChampionId", tbSaveData.nChampionId);
        return;
    end

    local tbChampionFightTeam = self:GetFightTeamByID(tbSaveData.nChampionId);
    if not tbChampionFightTeam then
        Log("Error HSLJ ChampionGuessingAward GetFightTeamByID", tbSaveData.nChampionId);
        return;
    end

    local tbChampion = self:GetFinalsFightTeamByID(tbSaveData.nChampionId);
    if not tbChampion then
        Log("Error HSLJ ChampionGuessingAward tbChampion", tbSaveData.nChampionId);
        return;
    end

    local nPerOneGold = tbGuessingDef.nOneNoteGold;
    self.tbFetchGuessingAward = {};

    local szChampionName = tbChampionFightTeam:GetName();
    for nV = 1, tbDef.nMaxGuessingVer - 1 do
        local bRet = self:HaveGuessingSavaData(nV);
        if bRet then
            self:SendGuessingAwardByVersion(nV, tbSaveData.nChampionId, nPerOneGold, szChampionName);
        else
            break;
        end
    end
    Log("HSLJ ChampionGuessingAward", nPerOneGold, tbSaveData.nChampionId);
end

function HuaShanLunJian:SendGuessingAwardByVersion(nVersion, nChampionId, nPerOneGold, szChampionName)
    local tbGuessing = self:GetGuessingSavaData(nVersion);
    if not tbGuessing then
        return;
    end

    self.tbFetchGuessingAward = self.tbFetchGuessingAward or {};
    for nPlayerID, tbSaveInfo in pairs(tbGuessing.tbAllPlayer) do
        if tbSaveInfo[tbDef.nGuessTypeTeam] == nChampionId and nPerOneGold > 0 then
            if not self.tbFetchGuessingAward[nPlayerID] then
                self.tbFetchGuessingAward[nPlayerID] = 1;

                local nOneNote = tbSaveInfo[tbDef.nGuessTypeOneNote];
                local nGold = nPerOneGold;
                local tbAward = {{"Gold", nGold}};
                local szMailCoent = string.format(tbGuessingDef.szAwardMail, szChampionName, nGold);
                local tbMail =
                {
                    To = nPlayerID,
                    Title = "華山論劍",
                    Text = szMailCoent;
                    nLogReazon = Env.LogWay_HSLJGuessing;
                    tbAttach = tbAward,
                }
                Mail:SendSystemMail(tbMail);

                Log("HSLJ SendGuessingAwardByVersion Player", nPlayerID, nGold, nChampionId, nOneNote, nPerOneGold);
            else
                Log("Erro HSLJ SendGuessingAwardByVersion Player", nPlayerID, nGold, nChampionId, nOneNote, nPerOneGold);
            end
        end
    end
    Log("HSLJ SendGuessingAwardByVersion", nVersion, nChampionId, nPerOneGold);
end

function HuaShanLunJian:GetGuessingTotalOneNote()
    local nTotalOneNote = 0;
    local tbAllFinalsTeam = self:GetAllFinalsFightTeam();
    for nFightTeamID, tbInfo in pairs(tbAllFinalsTeam) do
        nTotalOneNote = nTotalOneNote + tbInfo.nNote;
    end

    return nTotalOneNote;
end

function HuaShanLunJian:AddPlayerHonorBox(pPlayer, nHonor, nLogReazon, nLogReazon2)
    local nCurHonor = pPlayer.GetUserValue(tbDef.nSaveHonorGroupID, tbDef.nSaveHonorValue);
    nCurHonor = nCurHonor + nHonor;
    local nBoxCount = math.floor(nCurHonor / tbDef.nHSLJHonorBox);
    local nRetHonor = math.floor(nCurHonor % tbDef.nHSLJHonorBox);

    pPlayer.SetUserValue(tbDef.nSaveHonorGroupID, tbDef.nSaveHonorValue, nRetHonor);

    if nBoxCount > 0 then
        local tbAward = {{"item", tbDef.nHSLJHonorBoxItem, nBoxCount}};
        pPlayer.SendAward(tbAward, true, nil, nLogReazon, nLogReazon2)
    end

    Log("HSLJ AddPlayerHonorBox", pPlayer.dwID, nHonor, nCurHonor, nBoxCount, nRetHonor);
end


function HuaShanLunJian:OnServerStartup()
    if GetTimeFrameState(tbDef.szOpenTimeFrame) ~= 1 then
        return;
    end
    self:UpdateAllPlayerFightTeamID();
    self:UpdateAllPlayerGuessingVersion();
    self:CreateChampionStatue();
    self:UpdateGameFormat();
end

function HuaShanLunJian:GetPlayerStatueSave()
    local tbSaveData = ScriptData:GetValue("HSLJPlayerStatue");
    tbSaveData.nType = tbSaveData.nType or 0;
    tbSaveData.tbAllPlayer = tbSaveData.tbAllPlayer or {};
    return tbSaveData;
end

function HuaShanLunJian:CreateChampionStatue()
    Map:ClearMapStatue(tbDef.nStatueMapID, "HuaShanLunJian");
    local tbStatueSave = self:GetPlayerStatueSave();
    local tbFormat = tbDef.tbGameFormat[tbStatueSave.nType];
    if not tbFormat then
        return;
    end

    local tbShowStatue = tbFormat.tbStatueInfo;
    if not tbShowStatue then
        return;
    end

    local tbTypeStatue = Map:GetMapStatueType(tbDef.nStatueMapID, "HuaShanLunJian");
    tbTypeStatue.tbMiniMap = {};
    tbTypeStatue.tbMiniMap["HSLJ_diaoxiang"] = "華山論劍冠軍";

    for nIndex, nPlayerID in ipairs(tbStatueSave.tbAllPlayer) do
        local nStatueTID, szName = self:GetPlayerStatueInfo(nPlayerID);
        local tbShowPos = tbShowStatue.tbAllPos[nIndex];
        if nStatueTID and tbShowPos and szName then
            local tbStatue = {};
            tbStatue.nNpcTID = nStatueTID;
            tbStatue.nX = tbShowPos[1];
            tbStatue.nY = tbShowPos[2];
            tbStatue.nDir = tbShowPos[3] or 0;
            tbStatue.nTitleID = tbShowStatue.nTitleID;
            tbStatue.szName = szName;
            Map:AddMapStatue(tbDef.nStatueMapID, "HuaShanLunJian", tbStatue)
        end
    end
end

function HuaShanLunJian:GetPlayerStatueInfo(nPlayerID)
    local pRole = KPlayer.GetRoleStayInfo(nPlayerID)
    if not pRole then
        return
    end

    local nNpcTID = tbDef.tbFactionStatueNpc[pRole.nFaction];
    return nNpcTID, pRole.szName;
end

function HuaShanLunJian:CombineHuaShanLunJian()
    RankBoard:ClearRank(tbDef.szRankBoard);

    local tbStatueSave = self:GetPlayerStatueSave();
    tbStatueSave.nType = 0;
    tbStatueSave.tbAllPlayer = {};

    for nVer = 1, tbDef.nMaxFightTeamVer - 1 do
        local bRet = self:HaveFightTeamSavaData(nVer);
        if bRet then
            local tbTeamSave     = self:GetFightTeamSavaData(nVer);
            tbTeamSave.tbAllTeam = {};
            tbTeamSave.nCount    = 0;
        else
            break;
        end
    end

    local tbLunJinSava = self:GetLunJianSaveData();
    tbLunJinSava.tbFinalsFightTeam = {};
    tbLunJinSava.nChampionId = 0;
    Log("HSLJ CombineHuaShanLunJian");
end

function HuaShanLunJian:SendTeamPreGameMailAward(nFightTeamID, tbAllAward, szContent)
    if not tbAllAward then
        Log("Err HSLJ SendTeamPreGameMailAward Not AllAward", nFightTeamID);
        return;
    end

    local tbFightTeam = self:GetFightTeamByID(nFightTeamID);
    if not tbFightTeam then
        Log("Err HSLJ SendTeamPreGameMailAward Not FightTeam", nFightTeamID);
        return;
    end

    local tbAllPlayer = tbFightTeam:GetAllPlayerID();
    for nPlayerID, _ in pairs(tbAllPlayer) do
        local tbMail =
        {
            To = nPlayerID,
            Title = "華山論劍",
            Text = szContent or "華山論劍預選賽獎勵";
            nLogReazon = Env.LogWay_HSLJPreAward;
            tbAttach = tbAllAward,
        }

        Mail:SendSystemMail(tbMail);
        Log("HSLJ SendTeamPreGameMailAward FightTeam", nFightTeamID, nPlayerID);
    end
end

