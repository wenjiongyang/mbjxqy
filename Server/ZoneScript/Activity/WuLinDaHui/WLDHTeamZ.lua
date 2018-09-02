if not MODULE_ZONESERVER then
  return
end

--这些数据在跨服上开启时WuLinDaHui:ClearMathInfo()清掉

--重载
function WuLinDaHui:GetFightTeamSavaByID(nFightTeamID)
   return WuLinDaHui.tbZoneTeamData[nFightTeamID];
end

function WuLinDaHui:GetFightTeamConnIdx(nFightTeamID)
  return self.tbFightTeamNotSave.tbAllFightTeamIdToConnIdx[nFightTeamID]
end

function WuLinDaHui:SendFightTeamDataFromZC(tbTeamSaveData, nFightTeamID, nServerIndex, szServerName, nFinalMatchPos, bSynFinalTeamEnd)
    --一个坑是因为本服上存的决赛战队id是新生成的，战队id对应的game type 值是4+nType的。为了存盘需要
    Log("WuLinDaHui:SendFightTeamDataFromZC==", nFightTeamID, nServerIndex, szServerName, nFinalMatchPos, bSynFinalTeamEnd);
    if nFinalMatchPos then
        if self.tbFightTeamNotSave.tbAllFightTeamIdToConnIdx[nFightTeamID] then --决赛开始前是所有服都把决赛队伍传过来的
            return
        end
    end
    self.tbFightTeamNotSave.tbAllFightTeamIdToConnIdx[nFightTeamID] = Server.nCurConnectIdx
    tbTeamSaveData[HuaShanLunJian.tbDef.nTeamTypeServerIdx] = nServerIndex;
    tbTeamSaveData[HuaShanLunJian.tbDef.nTeamTypeServerName] = szServerName;
    
    self.tbZoneTeamData[nFightTeamID] = tbTeamSaveData;

    local tbFightTeam = self:GetFightTeamByID(nFightTeamID)
    assert(tbFightTeam, nFightTeamID)

    self.tbFightTeamNotSave.tbAllFightTeamName[nFightTeamID] = tbFightTeam:GetName();

    if not self.bCurIsFinal then
        -- local tbFightTeamInfo = HuaShanLunJian:GetPreGameFightTeamByID(nFightTeamID);
        -- tbFightTeamInfo.nPreMapMapId = tbPreGameMgr:GetFreePreMapID(); 
    else
        if nFinalMatchPos then
            self.tbFinalsFightTeam[nFightTeamID] = {nRank = nFinalMatchPos; nPlan = 0; };
            if bSynFinalTeamEnd then
                WuLinDaHui:OnFinalTeamGetEnd()
            end
        end
    end
end