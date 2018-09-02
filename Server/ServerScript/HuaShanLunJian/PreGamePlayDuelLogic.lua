

Require("CommonScript/HuaShanLunJian/LunJianDef.lua");
Require("ServerScript/HuaShanLunJian/HuaShanLunJian.lua");
Require("ServerScript/HuaShanLunJian/PrepareGamePlayMap.lua");
Require("ServerScript/HuaShanLunJian/HSLJPreGamePreLogic.lua");


local tbDef             = HuaShanLunJian.tbDef;
local tbPreDef          = tbDef.tbPrepareGame;
local tbBaseLogic       = HuaShanLunJian:GetPrePlayGameLogic("PlayDuel");
local tbPreGameMgr      = HuaShanLunJian.tbPreGamePreMgr;

function tbBaseLogic:InitInfo()
    self.tbDuelFightTeamResult = {};

    Log("HSLJ PlayDuel Pre Play Map InitInfo", self.nMapId);
end

function tbBaseLogic:GetPlayDuelPlayerID(nFightTeamID)
    local nPlayerID = tbPreGameMgr:GetPlayDuelPlayerMapID(nFightTeamID, self.nMapId);
    return nPlayerID;
end

function tbBaseLogic:SetPlayDuelPlayerResult(nFightTeamID, nResult)
    if self.tbDuelFightTeamResult[nFightTeamID] then
        return;
    end

    self.tbDuelFightTeamResult[nFightTeamID] = nResult;
    local nPlayTime = self.tbTeamPKInst:GetPlayTotalTime();
    local nPlayerID = self:GetPlayDuelPlayerID(nFightTeamID);
    if nPlayerID then
        tbPreGameMgr:SetPlayDuelPlayerResult(nFightTeamID, nPlayerID, nResult, nPlayTime)
    end

    Log("HSLJ SetPlayDuelPlayerResult", self.nMapId, nFightTeamID, nPlayerID or 0, nResult, nPlayTime);    
end

function tbBaseLogic:DoWin(nFightTeamID)
    self:SetPlayDuelPlayerResult(nFightTeamID, TeamPKMgr.tbDef.nPlayWin);

    self:ForeachAllPlayerFightTeam(nFightTeamID, {self.SendPlayerMsg, self, "您贏得了本次比賽！"});
    self:ForeachAllPlayerFightTeam(nFightTeamID, {self.SetPlayerMatch, self, Env.LogRound_SUCCESS});
    self:ForeachAllPlayerFightTeam(nFightTeamID, {self.OnPlayerReportData, self, TeamPKMgr.tbDef.nPlayWin});   
    Log("HSLJ Pre Play Map PlayDuel DoWin", self.nMapId, nFightTeamID);
end

function tbBaseLogic:DoFail(nFightTeamID)
    self:SetPlayDuelPlayerResult(nFightTeamID, TeamPKMgr.tbDef.nPlayFail);

    self:ForeachAllPlayerFightTeam(nFightTeamID, {self.SendPlayerMsg, self, "您失利了，再接再厲！"});
    self:ForeachAllPlayerFightTeam(nFightTeamID, {self.SetPlayerMatch, self, Env.LogRound_FAIL});
    self:ForeachAllPlayerFightTeam(nFightTeamID, {self.OnPlayerReportData, self, TeamPKMgr.tbDef.nPlayFail}); 
    Log("HSLJ Pre Play Map PlayDuel DoFail", self.nMapId, nFightTeamID);
end

function tbBaseLogic:DoDogfall(nFightTeamID)
    self:SetPlayDuelPlayerResult(nFightTeamID, TeamPKMgr.tbDef.nPlayDogfall);

    self:ForeachAllPlayerFightTeam(nFightTeamID, {self.SendPlayerMsg, self, "你們旗鼓相當，打成了平手！"});
    self:ForeachAllPlayerFightTeam(nFightTeamID, {self.SetPlayerMatch, self, Env.LogRound_DRAW});
    self:ForeachAllPlayerFightTeam(nFightTeamID, {self.OnPlayerReportData, self, TeamPKMgr.tbDef.nPlayDogfall}); 

    Log("HSLJ Pre Play Map PlayDuel DoDogfall", self.nMapId, nFightTeamID);
end


function tbBaseLogic:PlayGameEndExt()
    for nFightTeamID, _ in pairs(self.tbPlayFightTeamInfo) do
        if not self.tbDuelFightTeamResult[nFightTeamID] then
            self:SetPlayDuelPlayerResult(nFightTeamID, TeamPKMgr.tbDef.nPlayFail);
        end    

        tbPreGameMgr:UpdateCalcPlayDuelResult(nFightTeamID);
    end 

    Log("HSLJ Play Map PlayDuel PlayGameEndExt", self.nMapId);
end

function tbBaseLogic:UpdateAllPlayerAccount(bResult)
    local tbAllTeamShow = {};
    for nCurTeamID, tbPlayInfo in pairs(self.tbPlayFightTeamInfo) do
        local tbTeamShowInfo = tbPreGameMgr:GetPlayDuelTeamShowInfo(nCurTeamID);
        if tbTeamShowInfo then
            tbAllTeamShow[nCurTeamID] = tbTeamShowInfo;
        end        
    end

    self.tbAllTeamShowAccount = tbAllTeamShow;
end

function tbBaseLogic:PlayerLeave(pPlayer)
    local bRet, szMsg = tbPreGameMgr:CheckEnterPrepareGame(pPlayer, true, true, true);
    if bRet then
        HuaShanLunJian:EnterPrepareGame(pPlayer, true, true, true);
    else
        tbPreGameMgr:PlayerKickOutMsg(szMsg, pPlayer)
    end
end