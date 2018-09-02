Require("CommonScript/Player/PlayerEventRegister.lua");
Require("CommonScript/HeroChallenge/HeroChallengeDef.lua");
local tbDef = HeroChallenge.tbDefInfo;
HeroChallenge.tbPlayerRankData = HeroChallenge.tbPlayerRankData or {};

function HeroChallenge:OnStartup()
    self:UpdatePlayerRankData();
end

function HeroChallenge:UpdatePlayerRankData()
    self.tbPlayerRankData = {};

    for nRank, tbInfo in pairs(RankBattle.tbRank) do
        if tbInfo.nPlayerId then
            local nFloor = self:GetRankFloor(nRank)
            if nFloor then
                local tbFloorRank = self:GetFloorPlayerRankData(nFloor);
                local tbPlayerInfo = {};
                tbPlayerInfo.nPlayerId = tbInfo.nPlayerId; --注意一定要重新开一个Table 因为RankBattle会随时变

                tbFloorRank[nRank] = tbPlayerInfo;
            end
        end
    end

    UpdateHeroChallengeData();

    local tbAllPlayer = KPlayer.GetAllPlayer();
    for _, pPlayer in pairs(tbAllPlayer) do
        self:RetsetChallengeFloor(pPlayer);
    end

    Log("HeroChallenge UpdatePlayerRankData");
end

function HeroChallenge:GetFloorPlayerRankData(nFloor)
    local tbFloorRank = self.tbPlayerRankData[nFloor];
    if not tbFloorRank then
        tbFloorRank = {};
        self.tbPlayerRankData[nFloor] = tbFloorRank;
    end

    return tbFloorRank;
end

function HeroChallenge:UpdatePerDayData(pPlayer)
    local nTime           = GetTime();
    local nLastTime       = pPlayer.GetUserValue(tbDef.nSaveGroupID, tbDef.nSavePerTime);
    local nParseTodayTime = Lib:ParseTodayTime(tbDef.szDayUpdateTime);
    local nUpdateDay      = Lib:GetLocalDay((nTime - nParseTodayTime));
    local nUpdateLastDay  = Lib:GetLocalDay((nLastTime - nParseTodayTime));
    if nUpdateDay == nUpdateLastDay then
        return;
    end

    nTime = GetTime();
    pPlayer.SetUserValue(tbDef.nSaveGroupID, tbDef.nSavePerTime, nTime);
    pPlayer.SetUserValue(tbDef.nSaveGroupID, tbDef.nSaveFloorCount, 0);
    pPlayer.SetUserValue(tbDef.nSaveGroupID, tbDef.nSaveChallengeRank, 0);
    pPlayer.SetUserValue(tbDef.nSaveGroupID, tbDef.nSaveOneExtAward, 0);
    pPlayer.SetUserValue(tbDef.nSaveGroupID, tbDef.nSaveGetAwardFlag, 0);
    pPlayer.SetUserValue(tbDef.nSaveGroupID, tbDef.nSaveChallRankType, tbDef.nChallengTypeNone);

    local nChallengeCount = pPlayer.GetUserValue(tbDef.nSaveGroupID, tbDef.nSaveChallenge);
    nChallengeCount = nChallengeCount + 1;
    pPlayer.SetUserValue(tbDef.nSaveGroupID, tbDef.nSaveChallenge, nChallengeCount);

    self:RetsetAllFloorFact(pPlayer)
end

function HeroChallenge:GetPlayerChallengeFloor(pPlayer)
    self:UpdatePerDayData(pPlayer);
    local nFloor = pPlayer.GetUserValue(tbDef.nSaveGroupID, tbDef.nSaveFloorCount);
    return nFloor;
end

function HeroChallenge:GetTotalChallenge(pPlayer)
    self:UpdatePerDayData(pPlayer);
    local nChallengeCount = pPlayer.GetUserValue(tbDef.nSaveGroupID, tbDef.nSaveChallenge);
    return nChallengeCount;
end

function HeroChallenge:GetPlayerChallengeRank(pPlayer)
    self:UpdatePerDayData(pPlayer);
    local nRank = pPlayer.GetUserValue(tbDef.nSaveGroupID, tbDef.nSaveChallengeRank);
    return nRank;
end

function HeroChallenge:GetPlayerOnceExtAward(pPlayer)
    self:UpdatePerDayData(pPlayer);
    local nOneAward = pPlayer.GetUserValue(tbDef.nSaveGroupID, tbDef.nSaveOneExtAward);
    return nOneAward;
end

function HeroChallenge:GetPlayerAwardFlag(pPlayer)
    self:UpdatePerDayData(pPlayer);
    local nFlage = pPlayer.GetUserValue(tbDef.nSaveGroupID, tbDef.nSaveGetAwardFlag);
    return nFlage;
end

function HeroChallenge:SetFloorFaceID(pPlayer, nFloor, nFaceId)
    if nFloor < tbDef.nSaveShowFloor or nFloor > tbDef.nSaveShowFloorEnd then
        return;
    end

    self:UpdatePerDayData(pPlayer);

    pPlayer.SetUserValue(tbDef.nSaveShowGroupID, nFloor, nFaceId);
end

function HeroChallenge:RetsetAllFloorFact(pPlayer)
    for nI = tbDef.nSaveShowFloor, tbDef.nSaveShowFloorEnd do
        pPlayer.SetUserValue(tbDef.nSaveShowGroupID, nI, 0);
    end
end

function HeroChallenge:GetPlayerChallegeType(pPlayer)
    self:UpdatePerDayData(pPlayer);
    local nType = pPlayer.GetUserValue(tbDef.nSaveGroupID, tbDef.nSaveChallRankType);
    return nType;
end

function HeroChallenge:DoChallengeMaster(pPlayer)
    local bRet, szMsg, tbChallenge = HeroChallenge:CheckChallengeMaster(pPlayer);
    if not bRet then
        pPlayer.CenterMsg(szMsg);
        return;
    end

    if not AsyncBattle:CanStartAsyncBattle(pPlayer) then
        pPlayer.CenterMsg("目前地圖無法挑戰，請先返回[FFFE0D]「襄陽城」[-]再嘗試")
        return;
    end

    if pPlayer.dwTeamID > 0 then
        pPlayer.MsgBox("組隊狀態無法進行挑戰，是否退出目前隊伍？",
            {
                {"退出隊伍", TeamMgr.QuiteTeam, TeamMgr, pPlayer.dwTeamID, pPlayer.dwID},
                {"取消"},
            })
        return;
    end

    local nChallengeID, nChallengeType = self:GetChallengeIDType(pPlayer);
    if not nChallengeID then
        pPlayer.CenterMsg("重新匹配對手");
        self:NeedResetHeroChallenge(pPlayer);
        return;
    end

    local bRet = false;
    if nChallengeType == tbDef.nChallengTypePlayer then
        bRet = self:CreateBattlePVP(pPlayer, nChallengeID, tbChallenge.Floor);
    else
        bRet = self:CreateBattlePVE(pPlayer, nChallengeID, tbChallenge.Floor);
    end

    AssistClient:ReportQQScore(pPlayer, Env.QQReport_IsJoinHeroChanllenge, 1, 0, 1)
    Log("HeroChallenge DoChallengeMaster", pPlayer.dwID, nChallengeID, nChallengeType, bRet and "true" or "false");
end

function HeroChallenge:GetChallengeIDType(pPlayer)
    local nChallengeRank = self:GetPlayerChallengeRank(pPlayer);
    local nChallengType  = self:GetPlayerChallegeType(pPlayer);
    if nChallengType == tbDef.nChallengTypeNone or nChallengeRank == 0 then
        return;
    end

    if nChallengType == tbDef.nChallengTypePlayer then
        local nPlayerId = self:GetPlayerByRank(nChallengeRank);
        if not nPlayerId then
            Log("[Error] HeroChallenge GetChallengeIDType", nChallengeRank, nChallengType);
            return;
        end

        return nPlayerId, tbDef.nChallengTypePlayer;
    end

    local nNpcTeam = self:GetNpcByRank(nChallengeRank);
    return nNpcTeam, tbDef.nChallengTypeNpc;
end

function HeroChallenge:RetsetChallengeFloor(pPlayer)
    local nFloor = self:GetPlayerChallengeFloor(pPlayer);
    nFloor = nFloor + 1;
    local tbChallenge = self:GetFloorInfo(nFloor);
    if not tbChallenge then
        return;
    end

    local nFindType = tbDef.nChallengTypePlayer;
    local nChallengeCount = self:GetTotalChallenge(pPlayer);
    if tbChallenge.IsNpc == 1 or nChallengeCount == -1 then --TODO 第一天
        nFindType = tbDef.nChallengTypeNpc;
    end

    local nChallengeID   = 0;
    local nChallengeRank = 0;
    local nChallengeType = 0;
    if nFindType == tbDef.nChallengTypePlayer then
        nChallengeID, nChallengeRank, nChallengeType = self:RandomChallengePlayer(nFloor, pPlayer.dwID);
    else
        nChallengeID, nChallengeRank, nChallengeType = self:RandomChallengeNpc(nFloor);
    end

    pPlayer.SetUserValue(tbDef.nSaveGroupID, tbDef.nSaveChallengeRank, nChallengeRank);
    pPlayer.SetUserValue(tbDef.nSaveGroupID, tbDef.nSaveChallRankType, nChallengeType);

    if nChallengeType == tbDef.nChallengTypePlayer then
        local tbPlayerSync = KPlayer.GetRoleStayInfo(nChallengeID);
        self:SetFloorFaceID(pPlayer, nFloor, tbPlayerSync and tbPlayerSync.nPortrait or 0);
    else
        local tbNpcTeamInfo = RankBattle.tbNpcSetting[nChallengeID];
        self:SetFloorFaceID(pPlayer, nFloor, tbNpcTeamInfo and tbNpcTeamInfo.Faction or 0);
    end
    self:SyncCurChallengeInfo(pPlayer, true);
    Log("HeroChallenge RetsetChallengeFloor", pPlayer.dwID, nFloor, nFindType, nChallengeID, nChallengeRank, nChallengeType);
    return nChallengeID, nChallengeRank, nChallengeType;
end


function HeroChallenge:RandomChallengePlayer(nFloor, nExcludeID)
    for nI = nFloor, 1, -1 do
        local nPlayerId, nRank = self:RandomFloorRankPlayer(nI, nExcludeID);
        if nPlayerId then
            return nPlayerId, nRank, tbDef.nChallengTypePlayer;
        end
    end

    for nI = nFloor + 1, self.nMaxRankFloor, 1 do
        local nPlayerId, nRank = self:RandomFloorRankPlayer(nI, nExcludeID);
        if nPlayerId then
            return nPlayerId, nRank, tbDef.nChallengTypePlayer;
        end
    end

    local nNpcTeam, nRank = self:RandomChallengeNpc(nFloor);
    return nNpcTeam, nRank, tbDef.nChallengTypeNpc;
end

function HeroChallenge:RandomFloorRankPlayer(nFloor, nExcludeID)
    local tbFloorRank = self:GetFloorPlayerRankData(nFloor);
    local nTotalCount = Lib:CountTB(tbFloorRank);
    if nTotalCount <= 0 then
        return;
    end


    local nRate = MathRandom(nTotalCount);
    for nRank, tbPlayerInfo in pairs(tbFloorRank) do
        nRate = nRate - 1;
        if nRate <= 0 and tbPlayerInfo.nPlayerId ~= nExcludeID then
            return tbPlayerInfo.nPlayerId, nRank;
        end
    end

    if nTotalCount >= 2 then
        for nRank, tbPlayerInfo in pairs(tbFloorRank) do
            if tbPlayerInfo.nPlayerId ~= nExcludeID then
                return tbPlayerInfo.nPlayerId, nRank;
            end
        end
    end
end

function HeroChallenge:RandomChallengeNpc(nFloor)
    local nNpcTeam, nRank = self:RandomFloorRankNpc(nFloor);
    return nNpcTeam, nRank, tbDef.nChallengTypeNpc;
end

function HeroChallenge:RandomFloorRankNpc(nFloor)
    local tbChallenge = self:GetFloorInfo(nFloor);
    local nRank = MathRandom(tbChallenge.MinRank, tbChallenge.MaxRank);

    for _, tbNpcInfo in pairs(RankBattle.tbRoomSetting) do
        if tbNpcInfo.BeginNo <= nRank and nRank <= tbNpcInfo.EndNo then
            return tbNpcInfo.NpcTeam, nRank;
        end
    end
end

function HeroChallenge:GetNpcByRank(nRank)
    for _, tbNpcInfo in pairs(RankBattle.tbRoomSetting) do
        if tbNpcInfo.BeginNo <= nRank and nRank <= tbNpcInfo.EndNo then
            return tbNpcInfo.NpcTeam;
        end
    end
end

function HeroChallenge:GetPlayerByRank(nRank)
    local nFloor = self:GetRankFloor(nRank)
    local tbFloorRank = self:GetFloorPlayerRankData(nFloor);
    local tbInfo = tbFloorRank[nRank];
    if  not tbInfo then
        return;
    end

    return tbInfo.nPlayerId;
end

function HeroChallenge:PlayerRandomExtAward(pPlayer)
    local tbRateAward = self:GetExtAwardRate(pPlayer.nLevel);
    if not tbRateAward then
        return;
    end

    local nIsOne = self:GetPlayerOnceExtAward(pPlayer);
    local nTotalRate = 0;
    local tbAllRateAward = {};
    for _, tbExtAward in pairs(tbRateAward.tbAllExtAward) do
        if nIsOne == 0 or tbExtAward.nIsOne == 0 then
            nTotalRate = nTotalRate + tbExtAward.nRate;
            table.insert(tbAllRateAward, tbExtAward);
        end
    end

    if nTotalRate <= 0 then
        return;
    end

    local nCurRate = MathRandom(nTotalRate);
    local tbFindAward = nil;
    for _, tbExtAward in pairs(tbAllRateAward) do
        if tbExtAward.nRate >= nCurRate then
            tbFindAward = tbExtAward;
            break;
        end

        nCurRate = nCurRate - tbExtAward.nRate;
    end

    if not tbFindAward then
        Log("Error HeroChallenge PlayerRandomExtAward", pPlayer.dwID);
        return;
    end

    if tbFindAward.nIsOne > 0 then
        pPlayer.SetUserValue(tbDef.nSaveGroupID, tbDef.nSaveOneExtAward, 1);
    end

    local bDoubleAward, szMsg, tbFinalAward = RegressionPrivilege:GetDoubleAward(pPlayer, "HeroChallenge", tbFindAward.tbAward)
    pPlayer.SendAward(tbFinalAward, nil, true, Env.LogWay_HeroChallenge);
    if szMsg then
        pPlayer.CenterMsg(szMsg, true)
    end
    Log("HeroChallenge PlayerRandomExtAward", pPlayer.dwID, tbFindAward.nIsOne);
end

function HeroChallenge:DoChallengeWin(pPlayer, nFloor, nStartTime)
    local nCurFloor = self:GetPlayerChallengeFloor(pPlayer);
    nCurFloor = nCurFloor + 1;
    if nCurFloor ~= nFloor then
        Log("[ERROR] HeroChallenge DoChallengeWin", pPlayer.dwID, nFloor, nCurFloor);
        return;
    end


    pPlayer.SetUserValue(tbDef.nSaveGroupID, tbDef.nSaveFloorCount, nCurFloor);
    pPlayer.SetUserValue(tbDef.nSaveGroupID, tbDef.nSaveChallengeRank, 0);
    pPlayer.SetUserValue(tbDef.nSaveGroupID, tbDef.nSaveChallRankType, tbDef.nChallengTypeNone);

    local nCount = DegreeCtrl:GetDegree(pPlayer, tbDef.szHeroChallengeCount);
    local nMaxCount = DegreeCtrl:GetMaxDegree(tbDef.szHeroChallengeCount, pPlayer);
    local nAddCount = nMaxCount - nCount;
    if nAddCount > 0 then
        DegreeCtrl:AddDegree(pPlayer, tbDef.szHeroChallengeCount, nAddCount);
    end

    self:RetsetChallengeFloor(pPlayer);


    local szAchievement = tbDef.tbFloorAchievement[nFloor];
    if not Lib:IsEmptyStr(szAchievement) then
        Achievement:AddCount(pPlayer, szAchievement, 1);
    end

    local nCurTime = GetTime() - nStartTime;
    local tbLogData =
    {
        Result = Env.LogRound_SUCCESS;
        nMatchTime = nCurTime;
        SubActivityType = nFloor;
    };
    pPlayer.ActionLog(Env.LogType_AsynAthletics, Env.LogWay_HeroChallenge, tbLogData);
    Log("HeroChallenge DoChallengeWin", pPlayer.dwID, nFloor);

    if nFloor == 10 and pPlayer.dwKinId ~= 0 then
        local kinData = Kin:GetKinById(pPlayer.dwKinId);
        if kinData then
            kinData:InsertHeroChallengeWin10Name(pPlayer.szName);
        end

        local szShowMsg = string.format("幫派成員%s，勢不可擋，一舉打通十項英雄挑戰！", pPlayer.szName);
        ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szShowMsg, pPlayer.dwKinId);
    end
    if nFloor>=6 then
        TeacherStudent:TargetAddCount(pPlayer, "ChallegeHero6", 1)
    end
    if nFloor>=10 then
        TeacherStudent:TargetAddCount(pPlayer, "ChallegeHero10", 1)
        pPlayer.CallClientScript("GameSetting.Comment:OnEvent", GameSetting.Comment.Type_HeroChallenge_10);
    end

    AssistClient:ReportQQScore(pPlayer, Env.QQReport_HeroChanllengeFloor, nCurFloor, 0, 1)
    EverydayTarget:AddCount(pPlayer, "HeroChallenge");
    pPlayer.CallClientScript("HeroChallenge:OnHeroChallengeFloorWin", nCurFloor);
end

function HeroChallenge:DoChallengeAward(pPlayer, nFloor)
    local bRet, szMsg, tbChallenge = self:CheckChallengeAward(pPlayer, nFloor);
    if not bRet then
        pPlayer.CenterMsg(szMsg);
        return;
    end

    local nAwardFlag = self:GetPlayerAwardFlag(pPlayer);
    local nFloorFlag = KLib.BitOperate(1, "<<", nFloor);
    local nCurAwardFlag = KLib.BitOperate(nAwardFlag, "|", nFloorFlag);
    pPlayer.SetUserValue(tbDef.nSaveGroupID, tbDef.nSaveGetAwardFlag, nCurAwardFlag);

    pPlayer.SendAward(tbChallenge.tbAllAward, true, nil, Env.LogWay_HeroChallenge);
    self:PlayerRandomExtAward(pPlayer);
    pPlayer.CallClientScript("Player:ServerSyncData", "HeroChallenge");
    Log("HeroChallenge DoChallengeAward", pPlayer.dwID, nFloor);
end

function HeroChallenge:DoChallengeFail(pPlayer, nFloor, nStartTime)
    local nCurFloor = self:GetPlayerChallengeFloor(pPlayer);
    nCurFloor = nCurFloor + 1;
    if nCurFloor ~= nFloor then
        Log("[ERROR] HeroChallenge DoChallengeFail", pPlayer.dwID, nFloor, nCurFloor);
        return;
    end

    DegreeCtrl:ReduceDegree(pPlayer, tbDef.szHeroChallengeCount, 1);
    local nCount = DegreeCtrl:GetDegree(pPlayer, tbDef.szHeroChallengeCount);

    local nCurTime = GetTime() - nStartTime;
    local tbLogData =
    {
        Result = Env.LogRound_FAIL;
        nMatchTime = nCurTime;
        SubActivityType = nFloor;
    };
    pPlayer.ActionLog(Env.LogType_AsynAthletics, Env.LogWay_HeroChallenge, tbLogData);
    pPlayer.CallClientScript("HeroChallenge:OnHeroChallengeFloorFaild", nCurFloor);
    Log("HeroChallenge DoChallengeFail", pPlayer.dwID, nFloor, nCount);
end

function HeroChallenge:CreateBattlePVP(pPlayer, nEnemyId, nFloor)
    local nBattleKey = GetTime();

	if not AsyncBattle:CreateAsyncBattle(pPlayer, tbDef.nFightMapID, tbDef.tbEnterMapPos, "HeroChallengePVP", nEnemyId, nBattleKey, {nFloor, GetTime()}) then
		Log("Error!! HeroChallenge:CreateBattlePVP Failed!")
		return;
	end


    Log("HeroChallenge CreateBattlePVP", pPlayer.dwID, nEnemyId, nFloor);
    return true;
end

function HeroChallenge:OnChallengePVP(pPlayer, nResult, tbBattleObj, nFloor, nStartTime)
    if nResult == 1 then --成功
        self:DoChallengeWin(pPlayer, nFloor, nStartTime);
    else
        self:DoChallengeFail(pPlayer, nFloor, nStartTime);
    end

    Log("HeroChallenge OnChallengePVP", pPlayer.dwID, nResult, nFloor);
end

AsyncBattle:ResgiterBattleType("HeroChallengePVP", HeroChallenge, HeroChallenge.OnChallengePVP, nil, tbDef.nFightMapID);


function HeroChallenge:CreateBattlePVE(pPlayer, nEnemyId, nFloor)
    local nBattleKey = GetTime();

    if not AsyncBattle:CreateAsyncBattle(pPlayer, tbDef.nFightMapID, tbDef.tbEnterMapPos, "HeroChallengePVE", nEnemyId, nBattleKey, {nFloor, GetTime()}) then
		Log("Error!! HeroChallenge:CreateBattlePVP Failed!")
		return;
	end

    Log("HeroChallenge CreateBattlePVE", pPlayer.dwID, nEnemyId, nFloor);
    return true;
end

function HeroChallenge:OnChallengePVE(pPlayer, nResult, tbBattleObj, nFloor, nStartTime)
    if nResult == 1 then --成功
        self:DoChallengeWin(pPlayer, nFloor, nStartTime);
    else
        self:DoChallengeFail(pPlayer, nFloor, nStartTime);
    end

    Log("HeroChallenge OnChallengePVE", pPlayer.dwID, nResult, nFloor);
end

AsyncBattle:ResgiterBattleType("HeroChallengePVE", HeroChallenge, HeroChallenge.OnChallengePVE, nil, tbDef.nFightMapID);

function HeroChallenge:UpdatePlayerData(pPlayer)
    self:NeedResetHeroChallenge(pPlayer);
    self:SyncCurChallengeInfo(pPlayer);
end

function HeroChallenge:NeedResetHeroChallenge(pPlayer)
    local nFloor = self:GetPlayerChallengeFloor(pPlayer);
    nFloor = nFloor + 1;
    local tbChallenge = self:GetFloorInfo(nFloor);
    if not tbChallenge then
        return;
    end

    local nChallengeID = self:GetChallengeIDType(pPlayer);
    if nChallengeID then
        return;
    end

    self:RetsetChallengeFloor(pPlayer);
end

function HeroChallenge:SyncCurChallengeInfo(pPlayer, bReset)
    if not bReset and pPlayer.tbHeroChallengeSync then
        pPlayer.CallClientScript("HeroChallenge:UpdateCurChallengeInfo", pPlayer.tbHeroChallengeSync);
        return;
    end

    local nChallengeID, nChallengeType = self:GetChallengeIDType(pPlayer);
    if not nChallengeID then
        return;
    end

    local tbSyncInfo = {};
    if nChallengeType == tbDef.nChallengTypePlayer then
        local tbPlayerSync = KPlayer.GetRoleStayInfo(nChallengeID);
        local pPlayerSync = KPlayer.GetHeroAsyncData(nChallengeID);
        if pPlayerSync and tbPlayerSync then
            tbSyncInfo[1] = {}
            tbSyncInfo[1][1] = tbPlayerSync.szName;
            tbSyncInfo[1][2] = pPlayerSync.nLevel;
            tbSyncInfo[1][3] = pPlayerSync.nFaction;
            tbSyncInfo[1][4] = pPlayerSync.nFightPower;

            for nI = 1, 4 do
                local nPartnerId, nPartnerLevel, nFightPower = pPlayerSync.GetPartnerInfo(nI);
                if nPartnerId and nPartnerId ~= 0 then
                    tbSyncInfo[nI + 1] = {nPartnerId, nPartnerLevel, nFightPower}
                end
            end
        end
    else
        tbSyncInfo[1] = nChallengeID;
        tbSyncInfo[2] = "Npc";
    end

    pPlayer.tbHeroChallengeSync = tbSyncInfo;
    pPlayer.CallClientScript("HeroChallenge:UpdateCurChallengeInfo", pPlayer.tbHeroChallengeSync);
end







