if not MODULE_ZONESERVER then
    return
end

local tbPreGameMgr = HuaShanLunJian.tbPreGamePreMgr;

local tbHSLJDef    = HuaShanLunJian.tbDef;
local tbWLDHDef = WuLinDaHui.tbDef;

--重载
function tbPreGameMgr:GetPreDef()
    return tbWLDHDef.tbPrepareGame
end

--重载
function tbPreGameMgr:GetPreOpenWorldMsg()
    local tbGameFormat = self:GetGameFormat()
    return string.format(tbWLDHDef.tbPrepareGame.szPreOpenWorldMsg, tbGameFormat.szName)
end

--重载
function tbPreGameMgr:PlayerKickOut(pPlayer)
    Log("WuLinDaHui PreLogicMgr PlayerKickOut", pPlayer.nMapTemplateId, pPlayer.dwID);
    pPlayer.ZoneLogout()
end

--重载
function tbPreGameMgr:PlayerKickOutMsg(szMsg, pPlayer)
    Log("WuLinDaHui PreLogicMgr PlayerKickOutMsg", pPlayer.nMapTemplateId, pPlayer.dwID, szMsg);
    if szMsg then
        CallZoneClientScript(pPlayer.nZoneIndex, "WuLinDaHui:SendPlayerMsg", pPlayer.dwID, {szMsg = szMsg })
    end

    pPlayer.ZoneLogout();    
 end 

--重载
function tbPreGameMgr:SendWorldMsg(szMsg)
    CallZoneClientScript(-1, "WuLinDaHui:SendWorldMsg", szMsg)
end

--重载
function tbPreGameMgr:TrueEndGame()
    WuLinDaHui:ClearMathInfo() --预选赛场次结束后会清除所有信息
    CallZoneClientScript(-1, "WuLinDaHui:TrueEndGame")     
end

--Z上重载
function tbPreGameMgr:GetFightTeamByID(nFightTeamID)
    return WuLinDaHui:GetFightTeamByID(nFightTeamID);
end

--Z上重载
function tbPreGameMgr:GetMaxJoinCount()
    return tbWLDHDef.nPreMatchJoinCount;
end

--重载
function tbPreGameMgr:GetPlayerFightTeam(pPlayer) --华山是返回的id 的，而武林是直接返回的对应team
    return WuLinDaHui:GetPlayerFightTeam(pPlayer, WuLinDaHui.nCurGameType);
end

--重载，跨服上的检查能否进入下一场的华山，因为都是只打一次的，可以简单处理了 TODO 
function tbPreGameMgr:CheckEnterPrepareGame(pPlayer)
    local nPreMapId = HuaShanLunJian:FindEnterPreMapId(pPlayer)
    if not nPreMapId then
        return false, "当前无准备场地图"
    end
    local nFightTeamID = self:GetPlayerFightTeam(pPlayer)
    if nFightTeamID <= 0 then
        return false, "你还没有战队，去加入或创建一个战队再来吧！";
    end
    local tbFightTeam = self:GetFightTeamByID(nFightTeamID);
    if not tbFightTeam then
        return false, "没有这个战队"
    end

    local nJoinCount = tbFightTeam:GetJoinCount();
    if nJoinCount >= self:GetMaxJoinCount()  then
        return false, "您的战队已没有剩余比赛次数";
    end
    return true, "", nPreMapId, nFightTeamID
end

--重载
function tbPreGameMgr:GetFreePreMapID()
    for nMapId, tbInst in pairs(HuaShanLunJian.tbAllPreMapLogicInst) do
        return nMapId;
    end
end

--重载
function tbPreGameMgr:GetFightTeamByID(nFightTeamID)
    return WuLinDaHui:GetFightTeamByID(nFightTeamID);
end

--重载 TODO 奖励没定
function tbPreGameMgr:SendAwardPlayGameOne(nFightTeamID1)
end

--重载
function tbPreGameMgr:SendMailAwardDuelFightTeamResult(nFightTeamID, nResult)
end

--重载
function tbPreGameMgr:OnPlayerReportData(nResult, nPlayTime, pPlayer)
end

--重载
function tbPreGameMgr:PlayerReportPkData(pPlayer, tbData)
    Log("tbPreGameMgr:PlayerReportPkData=======")
end

--重载
function tbPreGameMgr:GetGameFormat()
    return WuLinDaHui.tbGameFormat[WuLinDaHui.nCurGameType]
end

--重载
 function tbPreGameMgr:GetMatchName()
     return "武林大会"
 end

--重载
 function tbPreGameMgr:SendTeamPreGameMailAward(nFightTeamID, tbAllAward, szContent)
     Log("tbPreGameMgr:SendTeamPreGameMailAward====== TODO") --TODO 
 end

 --跨服重载
function tbPreGameMgr:AddFightTeamJiFen(nFightTeamID, bWin, nJiFen, nPlayTime)
    WuLinDaHui:AddFightTeamJiFen(nFightTeamID, bWin, nJiFen, nPlayTime);
    
    local nConnectIdx = WuLinDaHui:GetFightTeamConnIdx(nFightTeamID)
    CallZoneClientScript(nConnectIdx, "WuLinDaHui:AddFightTeamJiFen", nFightTeamID, bWin, nJiFen, nPlayTime)
end

--重载
function tbPreGameMgr:UpdateCurTeamRank(bPreEnd)
    --武林大会需要对目前的所有队伍进行排名，取20名 保留发送到本服
    local tbRankTeamIds = {} --{ ID = ID. nRakVal = val }
    local tbAllFightTeam = HuaShanLunJian:GetPrepareGameFightTeam();
    for nFightTeamID,v in pairs(WuLinDaHui.tbZoneTeamData) do
        local tbTeamInst = WuLinDaHui:GetFightTeamByID(nFightTeamID);
        table.insert(tbRankTeamIds, { nFightTeamID, tbTeamInst:GetRankValue() })
    end

    --不可以在本服再排一次，不然有可能因为rankValue值一样 sort 出现和跨服的排名不同
    table.sort( tbRankTeamIds, function (a, b)
        return a[2] > b[2]
    end )

    local tbSaveRankData = {}; 
    for i = 1, tbWLDHDef.nPreRankSaveCount do
        local v = tbRankTeamIds[i]
        if v then
            local tbTeamInst = WuLinDaHui:GetFightTeamByID(v[1]);
            table.insert(tbSaveRankData, tbTeamInst.tbSaveData)
        end
    end

    CallZoneClientScript(-1,  "WuLinDaHui:SynTopRankPreMatchTeams", tbSaveRankData, WuLinDaHui.nCurGameType)
    CallZoneClientScript(-1,  "WuLinDaHui:SynCurAllTeamRanks", tbRankTeamIds, bPreEnd, WuLinDaHui.nCurGameType) --这个没有排行榜了，所以直接传回本服设战队的排行值

    if bPreEnd then --预选赛已经完， 产生16强 ,确认需求同步的角色id
        local tbNeedSynRoleInfoIds = {};
        for i = 1, tbWLDHDef.tbFinalsGame.nFrontRank do
            local v = tbRankTeamIds[i]
            if v then
                local nFightTeamID = v[1]
                local tbTeamInst = WuLinDaHui:GetFightTeamByID(nFightTeamID);
                for dwRoleId,v2 in pairs(tbTeamInst:GetAllPlayerID()) do
                    table.insert(tbNeedSynRoleInfoIds, dwRoleId)    
                end
            end
        end

        KPlayer.ClearTempRoleStayInfo()
        CallZoneClientScript(-1,  "WuLinDaHui:SynNeedSyncRoleIds", tbNeedSynRoleInfoIds, WuLinDaHui.nCurGameType)        
    end
end

--重载
function tbPreGameMgr:GetAllFinalsFightTeam()
    return WuLinDaHui.tbFinalsFightTeam or {};    
end

--重载
function tbPreGameMgr:SendWinChannaelMsg(pPlayer, bFinal)
    local tbGameDef = bFinal and tbWLDHDef.tbFinalsGame or tbWLDHDef.tbPrepareGame
    local szKinMsg = tbGameDef.szWinNotifyInKin
    local szFriendMsg = tbGameDef.szWinNotifyInFriend
    if not szKinMsg or szFriendMsg then
        return
    end

    CallZoneClientScript(pPlayer.nZoneIndex, "WuLinDaHui:SendPlayerMsg", pPlayer.dwID, {szKinMsg = szKinMsg, szFriend = szFriendMsg })
end
