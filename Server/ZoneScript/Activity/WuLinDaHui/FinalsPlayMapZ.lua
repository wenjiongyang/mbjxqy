if not MODULE_ZONESERVER then
    return
end
local tbFinalsDef       = WuLinDaHui.tbDef.tbFinalsGame;
local tbPlayMap         = Map:GetClass(tbFinalsDef.nFinalsMapTID);
local tbPlayMapHSLJ     = Map:GetClass(HuaShanLunJian.tbDef.tbFinalsGame.nFinalsMapTID);

local tbBaseLogic = HuaShanLunJian.tbBaseFinalsMapLogic;
local tbPreGameMgr = HuaShanLunJian.tbPreGamePreMgr;

tbPlayMap.OnDestroy = tbPlayMapHSLJ.OnDestroy
tbPlayMap.OnEnter = tbPlayMapHSLJ.OnEnter
tbPlayMap.OnLeave = tbPlayMapHSLJ.OnLeave
tbPlayMap.OnPlayerTrap = tbPlayMapHSLJ.OnPlayerTrap
tbPlayMap.OnLogin = tbPlayMapHSLJ.OnLogin

--重载
function tbPlayMap:OnCreate(nMapId)
    local tbNotFinalsData = HuaShanLunJian:GetFinalsGameNotSave();
    local nCount = Lib:CountTB(tbNotFinalsData.tbFinalsAllMapID);
    nCount = nCount + 1;
    tbNotFinalsData.tbFinalsAllMapID[nMapId] = nCount;
    tbNotFinalsData.tbFinalsAllMapIndex[nCount] = nMapId;
    Log("HSLJ Finals Map Create", nMapId, nCount);
    if nCount == 1 then
        CallZoneClientScript(-1,  "WuLinDaHui:OnFinalMapCreate", nMapId, WuLinDaHui.nOpenMathTime, WuLinDaHui.nCurGameType)
    end
end

--重载
function tbBaseLogic:GetFinalDef()
    return tbFinalsDef
end

--重载
function tbBaseLogic:DoFinalsEnd(nFightTeamID)
    self.bFinalsEnd = true;

    local tbSaveData = WuLinDaHui:GetSaveData()
    tbSaveData.nChampionId = nFightTeamID;
    
    self:SendChampionTeamMsg(nFightTeamID);

    Timer:Register(1, self.CanStopExecuteState, self); ---延迟一帧执行防止停止后同时执行OnExecuteState
    Log("HSLJ  Finals Map DoFinalsEnd", nFightTeamID);

    local tbFightTeam = tbPreGameMgr:GetFightTeamByID(nFightTeamID);
    local tbAllPlayer = tbFightTeam:GetAllPlayerID();
    local tbPlayerViewInfo = {  } -- [dwRoleId]  = { tbItems = tbItems; nLightID = nLightID, nFaction, nLevel, nFIghtPower, nTitle, szTitleName, KinName, Honor, szRoleName }
    for nPlayerID, _ in pairs(tbAllPlayer) do
        local tbRoleInfo = {};
        tbPlayerViewInfo[nPlayerID] = tbRoleInfo
        local pRole = Player:GetRoleStayInfo(nPlayerID)
        local pAsync = Player:GetAsyncData(nPlayerID)
        if pRole then
            tbRoleInfo.nFaction = pRole.nFaction
            tbRoleInfo.nLevel = pRole.nLevel
            tbRoleInfo.nHonorLevel = pRole.nHonorLevel
            tbRoleInfo.szName = pRole.szName
        end
        if pAsync then
            tbRoleInfo.nFightPower = pAsync.nFightPower
            tbRoleInfo.nLightID = pAsync.GetOpenLight();
        end

        local tbOtherInfo = Player:GetOtherTempRoleStayInfo(nPlayerID)
        if tbOtherInfo then
            local nTitleId, szTitleName, szKinName = unpack(tbOtherInfo)
            -- tbRoleInfo.nTitleId = nTitleId
            -- tbRoleInfo.szTitleName = szTitleName
            tbRoleInfo.szKinName = szKinName
        end

        --跨服上没有playerItems 的
        tbRoleInfo.tbItems = WuLinDaHui.tbCachePlayerViewItems[nPlayerID]
    end

    CallZoneClientScript(-1, "WuLinDaHui:SetChampionTeamId", WuLinDaHui.nCurGameType, nFightTeamID, tbPlayerViewInfo)
end

--重载
function tbBaseLogic:SendChampionTeamMsg(nFightTeamID)
    --TODO 改下提示 ,家族 好友的系统消息得在本服发 SendPlayerMsg
    local tbFightTeam = tbPreGameMgr:GetFightTeamByID(nFightTeamID);
    if not tbFightTeam then
        return;
    end
    local szFightName = tbFightTeam:GetName();
    local tbAllPlayer = tbFightTeam:GetAllPlayerID();
    local szPlayerTeam = "";
    for nPlayerID, _ in pairs(tbAllPlayer) do
        local tbStayInfo = Player:GetRoleStayInfo(nPlayerID);
        if tbStayInfo then
            szPlayerTeam = szPlayerTeam .. string.format("「%s」 ", tbStayInfo.szName);    
        end  
        local pPlayer = KPlayer.GetPlayerObjById(nPlayerID)
        if pPlayer then
            self:SendPlayerMsg(pPlayer, {
                szKinMsg = string.format("【武林大会】恭喜家族成员[eebb01]%%s[-]所在的[eebb01]%s[-]战队获得了[eebb01]%%s[-]冠军，成为武林至尊！", szFightName);
                szFriend = string.format("【武林大会】恭喜您的好友[eebb01]%%s[-]所在的[eebb01]%s[-]战队获得了[eebb01]%%s[-]冠军，成为武林至尊！", szFightName);
                })
        end
    end

    local tbGameFormat = tbPreGameMgr:GetGameFormat()
    local szWorldMsg = string.format("恭喜%s所在的「%s」战队获得了[eebb01]%s[-]冠军，成为武林至尊！", szPlayerTeam, szFightName, tbGameFormat.szName);
    tbPreGameMgr:SendWorldMsg(szWorldMsg)
end

--重载
function tbBaseLogic:SendPlayerMsg(pPlayer, tbInfo)
    CallZoneClientScript(pPlayer.nZoneIndex, "WuLinDaHui:SendPlayerMsg", pPlayer.dwID, tbInfo)
end

--重载
function tbBaseLogic:OnSendAward(nState)
    if self.bFinalsAward then
        return;
    end

    self.bFinalsAward = true;
    --更新战队排名，通知发奖
    local tbSaveData = WuLinDaHui:GetSaveData()
    local nChampionId = tbSaveData.nChampionId
    local tbAllFightTeam = WuLinDaHui.tbFinalsFightTeam
    local tbRankTeamIds = {} --{ ID = ID. nRakVal = val }
    for nFightTeamID, tbInfo in pairs(tbAllFightTeam) do
        local nValue = tbInfo.nPlan * 1000 + tbInfo.nRank;
        if nChampionId and  nChampionId == nFightTeamID then
            nValue = 1;
        end
        table.insert(tbRankTeamIds, {nFightTeamID, nValue});    
    end
    table.sort(tbRankTeamIds, function (a, b)
        return a[2] < b[2]
    end)


    if not self.bFinalsEnd then
        local nFightTeamID = tbRankTeamIds[1] and tbRankTeamIds[1][1]
        if nFightTeamID then
            Log("WLDH tbBaseLogic:OnSendAward EndBySendAward ", nFightTeamID)
            self:DoFinalsEnd(nFightTeamID)    
        end
    end

    CallZoneClientScript(-1,  "WuLinDaHui:SynCurAllTeamRanks", tbRankTeamIds, false, WuLinDaHui.nCurGameType, true) --这个没有排行榜了，所以直接传回本服设战队的排行值
    CallZoneClientScript(-1, "WuLinDaHui:SendFinalAward", WuLinDaHui.nCurGameType)
end

--重载
function tbBaseLogic:GetFinalsFightTeamByID(nFightTeamID)
    return WuLinDaHui:GetFinalsFightTeamByID(nFightTeamID)
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
    CallZoneClientScript(-1, "WuLinDaHui:SetFinalsFightTeamPlan", nFightTeamID, nPlan)
    Log("HSLJ SetFinalsFightTeamPlan", nFightTeamID, nPlan);
end

function tbBaseLogic:CheckPlayerCountNotifyZC()
    local nTotalCount = self.nPlayerEnterCount + self.nApplyPlayerCount
    if nTotalCount + 4 >= tbFinalsDef.nEnterPlayerCount then --在满的进出边缘时同步给本服
        CallZoneClientScript(-1,"WuLinDaHui:SynFinalMapGuestCount", nTotalCount)
    end
end

--重载
--只记录观众的进入个数就好了， 冠军队伍是不限制人数的
function tbBaseLogic:AddPlayerCount(pPlayer)
    self.nPlayerEnterCount = self.nPlayerEnterCount + 1;
    self:CheckPlayerCountNotifyZC()
end

--重载
function tbBaseLogic:ReducePlayerCount(pPlayer)
    self.nPlayerEnterCount = self.nPlayerEnterCount - 1;
    self:CheckPlayerCountNotifyZC()
end

-- --重载
function tbBaseLogic:AddApplyPlayerCount()
    self.nApplyPlayerCount = self.nApplyPlayerCount + 1
    self:CheckPlayerCountNotifyZC()
end

-- --重载
function tbBaseLogic:ReduceApplyPlayerCount()
    self.nApplyPlayerCount = self.nApplyPlayerCount - 1
    self:CheckPlayerCountNotifyZC()
end

--重载
function tbBaseLogic:GetHSLJBattleInfoShowInfoHelp()
    return "WLDHFinalsNew" .. WuLinDaHui.nCurGameType;
end

--重载
function tbBaseLogic:OnKickOutAllPlayer(nState)
    self:ForeachAllPlayer({tbPreGameMgr.PlayerKickOut, tbPreGameMgr});
    tbPreGameMgr:TrueEndGame() 
    Log("HSLJ Finals Map OnKickOutAllPlayer", nState);
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
    else
        --武林大会的客户端显示是根据 Plan的，所以晋级的话先设置上对应的 plan
        local nNextPlan = math.floor(nPlan / 2)
        if tbFinalsDef.tbAgainstPlan[nNextPlan] then
            self:SetFinalsFightTeamPlan(nFightTeamID, nNextPlan);
        end
    end

    self:ForeachAllPlayerFightTeam(nFightTeamID, {self.SendWinPlayerMsg, self});
    --self:ForeachAllPlayerFightTeam(nFightTeamID, {self.SendPlayerGameAward, self, tbFinalsDef.tbPlayGameAward});
    Log("HSLJ Finals Map OnWin", nIndex, nFightTeamID);
end