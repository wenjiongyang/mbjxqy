Require("CommonScript/HuaShanLunJian/LunJianDef.lua");
Require("ServerScript/HuaShanLunJian/HuaShanLunJian.lua");
Require("ServerScript/HuaShanLunJian/FinalsPlayMap.lua");


local tbDef             = HuaShanLunJian.tbDef;
local tbFinalsDef       = tbDef.tbFinalsGame;
local tbFinalsPKLogic   = HuaShanLunJian:GetFinalsPlayPKLogic("PlayDuel");

function tbFinalsPKLogic:InitInfo()
    self.tbDuelFightTeamResult = {};

    Log("HSLJ PlayDuel Pre Play Map InitInfo", self.nMapId);
end

function tbFinalsPKLogic:GetPlayDuelPlayerID(nFightTeamID)
    local nPlayerID = self.tbMapLogic:GetPlayDuelPlayerMapID(nFightTeamID, self.nMapId);
    return nPlayerID;
end

function tbFinalsPKLogic:SetPlayDuelPlayerResult(nFightTeamID, nResult)
    if self.tbDuelFightTeamResult[nFightTeamID] then
        return;
    end

    self.tbDuelFightTeamResult[nFightTeamID] = nResult;
    local nPlayTime = self.tbTeamPKInst:GetPlayTotalTime();
    local nPlayerID = self:GetPlayDuelPlayerID(nFightTeamID);
    if nPlayerID then
        self.tbMapLogic:SetPlayDuelPlayerResult(nFightTeamID, nPlayerID, nResult, nPlayTime)
    end

    Log("HSLJ SetPlayDuelPlayerResult", self.nMapId, nFightTeamID, nPlayerID or 0, nResult, nPlayTime);    
end


function tbFinalsPKLogic:DoWin(nFightTeamID)
    self:SetPlayDuelPlayerResult(nFightTeamID, TeamPKMgr.tbDef.nPlayWin);

    self:ForeachFightTeamPlayer(nFightTeamID, {self.SetPlayerMatch, self, Env.LogRound_SUCCESS});
    self:ForeachFightTeamPlayer(nFightTeamID, {self.OnPlayerReportData, self, TeamPKMgr.tbDef.nPlayWin});  
end


function tbFinalsPKLogic:DoFail(nFightTeamID)
    self:SetPlayDuelPlayerResult(nFightTeamID, TeamPKMgr.tbDef.nPlayFail);

    self:ForeachFightTeamPlayer(nFightTeamID, {self.SetPlayerMatch, self, Env.LogRound_FAIL});
    self:ForeachFightTeamPlayer(nFightTeamID, {self.OnPlayerReportData, self, TeamPKMgr.tbDef.nPlayFail});  
end

function tbFinalsPKLogic:UpdateAllPlayerAccount(bResult)
    local tbAllTeamShow = {};
    for nCurTeamID, tbPlayInfo in pairs(self.tbPlayFightTeam) do
        local tbTeamShowInfo = self.tbMapLogic:GetPlayDuelTeamShowInfo(nCurTeamID);
        if tbTeamShowInfo then
            tbAllTeamShow[nCurTeamID] = tbTeamShowInfo;
        end   
    end

    self.tbAllTeamShowAccount = tbAllTeamShow;
end

function tbFinalsPKLogic:PlayGameEndExt()
    for nFightTeamID, _ in pairs(self.tbPlayFightTeam) do
        if not self.tbDuelFightTeamResult[nFightTeamID] then
            self:SetPlayDuelPlayerResult(nFightTeamID, TeamPKMgr.tbDef.nPlayFail);
        end    

        self.tbMapLogic:UpdateCalcPlayDuelResult(nFightTeamID);
    end 

    Log("HSLJ Play Map PlayDuel PlayGameEndExt", self.nMapId);
end
