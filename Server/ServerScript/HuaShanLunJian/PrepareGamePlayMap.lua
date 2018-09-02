Require("CommonScript/HuaShanLunJian/LunJianDef.lua");
Require("ServerScript/HuaShanLunJian/HuaShanLunJian.lua");
Require("ServerScript/HuaShanLunJian/HSLJPreGamePreLogic.lua");
HuaShanLunJian.tbBasePrePlayMapLogic = HuaShanLunJian.tbBasePrePlayMapLogic or {};
HuaShanLunJian.tbAllPrePlayInstLogit = HuaShanLunJian.tbAllPrePlayInstLogit or {};
HuaShanLunJian.tbClassPrePlayGame    = HuaShanLunJian.tbClassPrePlayGame or {};

local tbBaseLogic = HuaShanLunJian.tbBasePrePlayMapLogic;
local tbDef             = HuaShanLunJian.tbDef;
local tbPreGameMgr = HuaShanLunJian.tbPreGamePreMgr;
local tbPlayMap         = Map:GetClass(tbDef.tbPrepareGame.nPlayMapTID);

function HuaShanLunJian:GetPrePlayGameLogic(szClass)
    local tbClassLogic = self.tbClassPrePlayGame[szClass];
    if not tbClassLogic then
        tbClassLogic = Lib:NewClass(tbBaseLogic);
        self.tbClassPrePlayGame[szClass] = tbClassLogic;
    end

    return tbClassLogic;    
end

function tbPlayMap:OnCreate(nMapId)
    local tbInst = HuaShanLunJian.tbAllPrePlayInstLogit[nMapId];
    if not tbInst then
        local tbGameFormat = tbPreGameMgr:GetGameFormat();
        local szPKClass = tbGameFormat.szPKClass;
        local tbBaseLogicExt = nil;
        if not szPKClass then
            tbBaseLogicExt = tbBaseLogic;
        else
            tbBaseLogicExt = HuaShanLunJian:GetPrePlayGameLogic(szPKClass);
        end

        tbInst = Lib:NewClass(tbBaseLogicExt);    
        tbInst:OnCreate(nMapId);
        HuaShanLunJian.tbAllPrePlayInstLogit[nMapId] = tbInst;
    else
        Log("Error HuaShanLunJian PlayMap OnCreate Have", nMapId);
    end    

    Log("HuaShanLunJian PlayMap OnCreate", nMapId);
end

function tbPlayMap:OnDestroy(nMapId)
    local tbInst = HuaShanLunJian.tbAllPrePlayInstLogit[nMapId];
    if tbInst then
        tbInst:OnClose();
        HuaShanLunJian.tbAllPrePlayInstLogit[nMapId] = nil;
    end

    Log("HuaShanLunJian PlayMap OnDestroy", nMapId);
end

function tbPlayMap:OnEnter(nMapId)
    local tbInst = HuaShanLunJian.tbAllPrePlayInstLogit[nMapId];
    if not tbInst then
        return;
    end

    tbInst:OnEnter();
end

function tbPlayMap:OnLeave(nMapId)
    local tbInst = HuaShanLunJian.tbAllPrePlayInstLogit[nMapId];
    if not tbInst then
        return;
    end

    tbInst:OnLeave();
end

function tbPlayMap:OnLogin(nMapId)
    local tbInst = HuaShanLunJian.tbAllPrePlayInstLogit[nMapId];
    if not tbInst then
        return;
    end

    tbInst:OnLogin();
end


function tbBaseLogic:OnCreate(nMapId)
    self.nMapId = nMapId;

    local tbNotPreData = HuaShanLunJian:GetPrepareGameNotSave();
    local tbMatchInfo = tbNotPreData.tbMatchMapTeam[nMapId];
    if not tbMatchInfo then
        Log("Error HuaShanLunJian MatchInfo", nMapId);    
        return;
    end
    tbNotPreData.tbMatchMapTeam[nMapId] = nil;
    self.tbPlayTeamFightID = {};
    self.tbPlayFightTeamInfo = {};
    self.tbFightTeamAward = {};

    if self.InitInfo then
        self:InitInfo();
    end    

    local nPlayTeam = 1;
    for nFightTeamID, _ in pairs(tbMatchInfo) do
        local tbInfo = 
        {
            nPlayTeam   = nPlayTeam;
            tbAllPlayer = {};
            tbPlayerShowInfo = {};
        }
        nPlayTeam = nPlayTeam + 1;
        self.tbPlayFightTeamInfo[nFightTeamID] = tbInfo;
        self.tbPlayTeamFightID[tbInfo.nPlayTeam] = nFightTeamID;
    end

    self:FightTeamEnterMap();
    self.nGameState = tbDef.nPlayGameStateNone;
    if self.nShowInfoTimer then
        Timer:Close(self.nShowInfoTimer);
        self.nShowInfoTimer = nil;
    end    

    local tbPreDef = tbPreGameMgr:GetPreDef()
    self.nShowInfoTimer = Timer:Register(tbPreDef.nShowInfoPlayTeamTime * Env.GAME_FPS, self.OnDelayStart, self);

    local nTotalPlayTime = tbPreDef.nPlayGameTime - tbPreDef.nShowInfoPlayTeamTime - tbPreDef.nPlayDelayTime;
    self.tbTeamPKInst = TeamPKMgr:CreatePkLogic(string.format("HSLJPrePlayMap:%s", self.nMapId), nTotalPlayTime);
    local tbGameFormat = tbPreGameMgr:GetGameFormat();
    if tbGameFormat.szPKClass and tbGameFormat.szPKClass == "PlayDuel" then
        self.tbTeamPKInst:SetFunPKEndType("PlayerNpc");
    end 
      
    self.tbTeamPKInst:SetPlayerToNpcDmg(tbDef.fPlayerToNpcDmg);
    self.tbTeamPKInst:RegOnEnd({self.PlayGameEnd, self});
    self.tbTeamPKInst:RegOnPlayerDeath({self.OnPlayerDeath, self});
    self.tbTeamPKInst:RegOnPartnerDeath({self.OnPartnerDeath, self});
    self.tbTeamPKInst:RegTeamResult({self.OnTeamResult, self});

    self:UpdateAllPlayerAccount();
    Log("HSLJ Play Map OnCreate", self.nMapId);    
end

function tbBaseLogic:OnPlayerDeath(pKiller)
    Log("HSLJ Pre Play Map OnPlayerDeath", me.dwID);
end

function tbBaseLogic:OnPartnerDeath(nPlayerID, pKiller)
    local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
    if pPlayer then
        self:PlayerUpdatePartnerShowInfo(pPlayer);
    end    

    Log("HSLJ Pre Play Map OnPartnerDeath", nPlayerID, him.szName);
end

function tbBaseLogic:OnDelayStart()
    self.nShowInfoTimer = nil;
    self.nGameState = tbDef.nPlayGameStateNone;
    if self.nDelayStartTimer then
        Timer:Close(self.nDelayStartTimer);
        self.nDelayStartTimer = nil;
    end 

    self:ForeachAllPlayer({self.PlayerGameStart, self});
    self:CloseDmgTimer();
    local tbPreDef = tbPreGameMgr:GetPreDef()
    self.nDelayStartTimer = Timer:Register(tbPreDef.nPlayDelayTime * Env.GAME_FPS, self.OnStart, self);

    Log("HSLJ Play Map OnDelayStart", self.nMapId);    
end

function tbBaseLogic:OnStart()
    self.nDelayStartTimer = nil;
    self:DoGameStart();
    Log("HSLJ Play Map OnStart", self.nMapId);    
end


function tbBaseLogic:DoGameStart()
    self.nGameState = tbDef.nPlayGameStateStart;
    self:CloseDmgTimer();
    self.nUpdateDmageTimer = Timer:Register(tbDef.nUpateDmgTime * Env.GAME_FPS, self.UpdateAllTeamShowInfo, self)

    self.tbTeamPKInst:DoStart();
    local tbAllTeamShow = self:GetAllTeamShowInfo();
    self:ForeachAllPlayer({self.OnStartAllTeamShowInfo, self, tbAllTeamShow});
    Log("HSLJ Play Map DoGameStart", self.nMapId);
end

function tbBaseLogic:CloseDmgTimer()
    if self.nUpdateDmageTimer then
        Timer:Close(self.nUpdateDmageTimer);
        self.nUpdateDmageTimer = nil;
    end    
end

function tbBaseLogic:GetAllTeamShowInfo()
    local tbAllShowInfo = {};
    for nFightTeamID, tbTeamInfo in pairs(self.tbPlayFightTeamInfo) do
        local tbInfo = {};
        tbInfo.nDamage = self.tbTeamPKInst:GetTeamTotalDmg(tbTeamInfo.nPlayTeam);
        tbInfo.nPartner = self.tbTeamPKInst:GetTeamPartnerCount(tbTeamInfo.nPlayTeam);
        tbInfo.nKill = self.tbTeamPKInst:GetTeamKillPlayerCount(tbTeamInfo.nPlayTeam);
        tbAllShowInfo[nFightTeamID] = tbInfo;
    end

    return tbAllShowInfo;    
end

function tbBaseLogic:OnStartAllTeamShowInfo(tbShowInfo, pPlayer)
    local nFightTeamID = tbPreGameMgr:GetPlayerFightTeam(pPlayer);
    local tbAllTeamInfo = {};
    tbAllTeamInfo.nTime = self.tbTeamPKInst:GetEndResidueTime();
    tbAllTeamInfo.nTeam = nFightTeamID;
    tbAllTeamInfo.tbAllTeam = tbShowInfo;
    tbAllTeamInfo.nMapTID = pPlayer.nMapTemplateId;

    pPlayer.CallClientScript("Ui:OpenWindow", "HSLJBattleInfo", "Play", tbAllTeamInfo);
end

function tbBaseLogic:UpdateAllTeamShowInfo()
    local tbAllTeamShow = self:GetAllTeamShowInfo();
    self:ForeachAllPlayer({self.OnAllTeamShowInfo, self, tbAllTeamShow});

    return true;
end

function tbBaseLogic:OnAllTeamShowInfo(tbShowInfo, pPlayer)

    pPlayer.CallClientScript("Player:ServerSyncData", "PlayAllTeam", tbShowInfo);
end

function tbBaseLogic:PlayerGameStart(pPlayer)
    pPlayer.CallClientScript("Ui:CloseWindow", "HSLJAccount");
    pPlayer.CallClientScript("Ui:OpenWindow", "ReadyGo");
    local tbPlayerInfo = self:GetPlayerInfo(pPlayer);
    if tbPlayerInfo then
        tbPlayerInfo.nMatchTime = GetTime();
    end    
    Log("HSLJ Play Map PlayerGameStart", pPlayer.dwID, nFightTeamID);
end

function tbBaseLogic:PlayGameEnd()
    self.nGameState = tbDef.nPlayGameStateEnd;

    self:ForeachAllPlayer({self.ShowLeaveButton, self});

    if self.nEndDelayLeaveTimer then
        Timer:Close(self.nEndDelayLeaveTimer)
        self.nEndDelayLeaveTimer = nil;
    end

    local tbPreDef = tbPreGameMgr:GetPreDef()
    self.nEndDelayLeaveTimer = Timer:Register(tbPreDef.nEndDelayLeaveMap * Env.GAME_FPS, self.OnDelayPlayerLeave, self);

    self:UpdateAllPlayerAccount(true);
    self:ForeachAllPlayer({self.ShowPlayerAccount, self, 0});
    self:CloseDmgTimer();
    self:ForeachAllPlayer({self.CloseBattleShowUI, self});

    if self.PlayGameEndExt then
        self:PlayGameEndExt();
    end
    
    tbPreGameMgr:CheckUpdateCurTeamRank()

    Log("HSLJ Play Map PlayGameEnd", self.nMapId);
end

function tbBaseLogic:CloseBattleShowUI(pPlayer)
    pPlayer.CallClientScript("Ui:CloseWindow", "HSLJBattleInfo");
end

function tbBaseLogic:ShowPlayerAccount(nCloseTime, pPlayer)
    if not self.tbAllTeamShowAccount then
        return;
    end    

    local nFightTeamID = tbPreGameMgr:GetPlayerFightTeam(pPlayer);
    pPlayer.CallClientScript("Ui:OpenWindow", "HSLJAccount", self.tbAllTeamShowAccount, nFightTeamID, nCloseTime);
    pPlayer.CallClientScript("Map:SetCloseUiOnLeave", pPlayer.nMapId, "HSLJAccount"); 
end

function tbBaseLogic:OnDelayPlayerLeave()
    self.nEndDelayLeaveTimer = nil;
    self:ForeachAllPlayer({self.PlayerLeave, self});
end

function tbBaseLogic:PlayerLeave(pPlayer)
    local bRet, szMsg = tbPreGameMgr:CheckEnterPrepareGame(pPlayer,true, true)
    if bRet then
        HuaShanLunJian:EnterPrepareGame(pPlayer, true, true);
    else
        tbPreGameMgr:PlayerKickOutMsg(szMsg, pPlayer)
    end
end

function tbBaseLogic:OnTeamResult(nTeamId, nPlayState)
    local nFightTeamID = self.tbPlayTeamFightID[nTeamId];
    if nPlayState == TeamPKMgr.tbDef.nPlayWin then
        self:DoWin(nFightTeamID);
    elseif nPlayState == TeamPKMgr.tbDef.nPlayDogfall then
        self:DoDogfall(nFightTeamID);
    elseif nPlayState == TeamPKMgr.tbDef.nPlayFail then
        self:DoFail(nFightTeamID);
    end
        
    Log("HSLJ Pre Play Map OnTeamResult", self.nMapId,  nFightTeamID, nTeamId, nPlayState);
end    

function tbBaseLogic:DoWin(nFightTeamID)
    local tbFightTeamInfo = HuaShanLunJian:GetPreGameFightTeamByID(nFightTeamID);
    if tbFightTeamInfo then
        tbFightTeamInfo.nCalcResult = TeamPKMgr.tbDef.nPlayWin;
    end    

    local nPlayTime = self.tbTeamPKInst:GetPlayTotalTime();
    local tbPreDef = tbPreGameMgr:GetPreDef()
    tbPreGameMgr:AddFightTeamJiFen(nFightTeamID, true, tbPreDef.nWinJiFen, nPlayTime);
    self:ForeachAllPlayerFightTeam(nFightTeamID, {self.SendPlayerMsg, self, "您的戰隊贏得了本次比賽！"});
    self:ForeachAllPlayerFightTeam(nFightTeamID, {tbPreGameMgr.SendWinChannaelMsg, tbPreGameMgr});
    self:ForeachAllPlayerFightTeam(nFightTeamID, {self.SetPlayerMatch, self, Env.LogRound_SUCCESS});

    local tbAward = tbPreDef.tbAllAward.tbWin;
    if tbAward and not self.tbFightTeamAward[nFightTeamID] then
        self.tbFightTeamAward[nFightTeamID] = true;
        tbPreGameMgr:SendTeamPreGameMailAward(nFightTeamID, tbAward, tbPreDef.tbAwardMail.szWin);
    end

    self:ForeachAllPlayerFightTeam(nFightTeamID, {self.OnPlayerReportData, self, TeamPKMgr.tbDef.nPlayWin});    
    Log("HSLJ Pre Play Map DoWin", self.nMapId, nFightTeamID);
end

function tbBaseLogic:OnPlayerReportData(nResult, pPlayer)
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

function tbBaseLogic:SetPlayerMatch(nResult, pPlayer)
    local tbPlayerInfo = self:GetPlayerInfo(pPlayer);
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
    pPlayer.ActionLog(Env.LogType_Athletics, Env.LogWay_HSLJPreGame, tbLogData);    
end



function tbBaseLogic:SendPlayerMsg(szMsg, pPlayer)
    pPlayer.CenterMsg(szMsg, true);
end

function tbBaseLogic:DoFail(nFightTeamID)
    local tbFightTeamInfo = HuaShanLunJian:GetPreGameFightTeamByID(nFightTeamID);
    if tbFightTeamInfo then
        tbFightTeamInfo.nCalcResult = TeamPKMgr.tbDef.nPlayFail;
    end   

    local nPlayTime = self.tbTeamPKInst:GetPlayTotalTime()
    local tbPreDef = tbPreGameMgr:GetPreDef();
    tbPreGameMgr:AddFightTeamJiFen(nFightTeamID, false, tbPreDef.nFailJiFen, nPlayTime);
    self:ForeachAllPlayerFightTeam(nFightTeamID, {self.SendPlayerMsg, self, "您的戰隊失利了，再接再厲！"});
    self:ForeachAllPlayerFightTeam(nFightTeamID, {self.SetPlayerMatch, self, Env.LogRound_FAIL});
    local tbAward = tbPreDef.tbAllAward.tbFail;
    if tbAward and not self.tbFightTeamAward[nFightTeamID] then
        self.tbFightTeamAward[nFightTeamID] = true;
        tbPreGameMgr:SendTeamPreGameMailAward(nFightTeamID, tbAward, tbPreDef.tbAwardMail.szFail);
    end

    self:ForeachAllPlayerFightTeam(nFightTeamID, {self.OnPlayerReportData, self, TeamPKMgr.tbDef.nPlayFail});
    Log("HSLJ Pre Play Map DoFail", self.nMapId, nFightTeamID);
end

function tbBaseLogic:DoDogfall(nFightTeamID)
    local tbFightTeamInfo = HuaShanLunJian:GetPreGameFightTeamByID(nFightTeamID);
    if tbFightTeamInfo then
        tbFightTeamInfo.nCalcResult = TeamPKMgr.tbDef.nPlayDogfall;
    end   

    local nPlayTime = self.tbTeamPKInst:GetPlayTotalTime();
    local tbPreDef = tbPreGameMgr:GetPreDef()
    tbPreGameMgr:AddFightTeamJiFen(nFightTeamID, false, tbPreDef.nDogfallJiFen, nPlayTime);
    self:ForeachAllPlayerFightTeam(nFightTeamID, {self.SendPlayerMsg, self, "你們旗鼓相當，打成了平手！"});
    self:ForeachAllPlayerFightTeam(nFightTeamID, {self.SetPlayerMatch, self, Env.LogRound_DRAW});

    local tbAward = tbPreDef.tbAllAward.tbDogfall;
    if tbAward and not self.tbFightTeamAward[nFightTeamID] then
        self.tbFightTeamAward[nFightTeamID] = true;
        tbPreGameMgr:SendTeamPreGameMailAward(nFightTeamID, tbAward, tbPreDef.tbAwardMail.szDogfall);
    end

    self:ForeachAllPlayerFightTeam(nFightTeamID, {self.OnPlayerReportData, self, TeamPKMgr.tbDef.nPlayDogfall});
    Log("HSLJ Pre Play Map DoDogfall", self.nMapId, nFightTeamID);
end

function tbBaseLogic:CloseAllTimer()
    if self.nShowInfoTimer then
        Timer:Close(self.nShowInfoTimer);
        self.nShowInfoTimer = nil;
    end

    if self.nDelayStartTimer then
        Timer:Close(self.nDelayStartTimer);
        self.nDelayStartTimer = nil;
    end

    if self.nEndDelayLeaveTimer then
        Timer:Close(self.nEndDelayLeaveTimer);
        self.nEndDelayLeaveTimer = nil;
    end

    self:CloseDmgTimer(); 
end


function tbBaseLogic:CheckFightTeamEnterMap(nFightTeamID) 
    local tbFightTeam = tbPreGameMgr:GetFightTeamByID(nFightTeamID);
    if not tbFightTeam then
        return false, "Error, HuaShanLunJian CheckFightTeam Not Team";
    end

    local tbFightTeamInfo = HuaShanLunJian:GetPreGameFightTeamByID(nFightTeamID);
    if not tbFightTeamInfo then
        return false, "Error, HuaShanLunJian CheckFightTeam FightTeamInfo";
    end    

    return true, "", tbFightTeam, tbFightTeamInfo;
end

function tbBaseLogic:GetPlayFightTeam(nFightTeamID)
    return self.tbPlayFightTeamInfo[nFightTeamID];
end

function tbBaseLogic:FightTeamEnterMap()
    local tbPreDef = tbPreGameMgr:GetPreDef()
    for nFightTeamID, tbPlayInfo in pairs(self.tbPlayFightTeamInfo) do
        local bRet, szMsg, tbFightTeam, tbFightTeamInfo = self:CheckFightTeamEnterMap(nFightTeamID);
        if bRet then
            for nPlayerID, _ in pairs(tbFightTeamInfo.tbAllPlayer) do
                local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
                if pPlayer then
                    local tbShowInfo =
                    {
                        szName      = pPlayer.szName,
                        nPortrait   = pPlayer.nPortrait,
                        nLevel      = pPlayer.nLevel,
                        nHonorLevel = pPlayer.nHonorLevel,
                        nFaction    = pPlayer.nFaction,
                        nFightPower = pPlayer.GetFightPower();
                    }

                    tbPlayInfo.tbPlayerShowInfo[nPlayerID] = tbShowInfo;

                    local tbPlayerPKInfo = tbFightTeamInfo.tbAllPlayerPKInfo[nPlayerID];
                    if tbPlayerPKInfo and tbPlayerPKInfo.nMapId == self.nMapId then
                        local tbEnterPos = tbPreDef.tbPlayMapEnterPos[tbPlayInfo.nPlayTeam];
                        pPlayer.bHSLJQuitePKTeam = true;
                        pPlayer.SwitchMap(self.nMapId, tbEnterPos[1], tbEnterPos[2]);
                    end    
                else
                    Log("Error HSLJ FightTeamEnterMap", nFightTeamID, self.nMapId, nPlayerID);        
                end
            end    
        else
            Log(szMsg);  
        end   
    end 
end

function tbBaseLogic:OnClose()
    self:CloseAllTimer();
    Log("HSLJ Play Map OnClose", self.nMapId);
end

function tbBaseLogic:OnEnter()
    local nFightTeamID = tbPreGameMgr:GetPlayerFightTeam(me);
    local tbFightTeamInfo = self:GetPlayFightTeam(nFightTeamID);
    if not tbFightTeamInfo then
        Log("Error HSLJ Play Map OnEnter Not Have Info", self.nMapId, nFightTeamID, me.dwID);
        me.GotoEntryPoint();
        return;
    end

    local tbPlayerInfo = {};
    me.nInBattleState = 1; --战场模式
    me.bForbidChangePk = 1;
    me.nFightMode = 0;
    me.SetPkMode(Player.MODE_PEACE);

    tbPlayerInfo.nKillCount = 0;
    tbPlayerInfo.tbShowPartner = {};
    tbPlayerInfo.nMatchTime = GetTime();


    local tbGameFormat = tbPreGameMgr:GetGameFormat();
    self.tbTeamPKInst:AddPlayer(me, tbFightTeamInfo.nPlayTeam, nPartnerStart, nPartnerEnd);
    if tbGameFormat.bOpenPartner then
        local nPartnerID = me.GetFightPartnerID();
        self.tbTeamPKInst:CreatePartnerByID(me, nPartnerID);
    elseif tbGameFormat.nPartnerPos and tbGameFormat.nPartnerPos > 0 then
        self.tbTeamPKInst:CreatePartnerByPos(me, 1, tbGameFormat.nPartnerPos)    
    end
    tbFightTeamInfo.tbAllPlayer[me.dwID] = tbPlayerInfo;

    if self.nShowInfoTimer then
        self:ShowPlayerAccount(0, me);
    elseif self.nDelayStartTimer then
        me.CallClientScript("Ui:OpenWindow", "ReadyGo");
    end

    self:PlayerUpdatePartnerShowInfo(me);
    self:SyncTeamPartnerInfo(me);
    self:UpdateUIInfo(me);
    tbPreGameMgr:SetPlayerTeamTitle(me, tbFightTeamInfo.nPlayTeam);
    Log("HSLJ Play Map OnEnter", me.dwID, self.nMapId, nFightTeamID);
end

function tbBaseLogic:UpdateUIInfo(pPlayer)
    pPlayer.CallClientScript("Player:ServerSyncData", "HomeBtnTast", {nMapTID = pPlayer.nMapTemplateId});
    local tbGameFormat = tbPreGameMgr:GetGameFormat();
    if tbGameFormat.bOpenPartner then    
        pPlayer.CallClientScript("Player:ServerSyncData", "TeamShowPartner", {nMapTID = pPlayer.nMapTemplateId, bForbid = true});
    end

    if tbGameFormat.szPKClass and tbGameFormat.szPKClass == "PlayDuel" then
        pPlayer.CallClientScript("Ui:ForbidShowUI", "HomeScreenTask", pPlayer.nMapTemplateId, true);
    end        
end

function tbBaseLogic:PlayerUpdatePartnerShowInfo(pPlayer)
    local tbGameFormat = tbPreGameMgr:GetGameFormat();
    if not tbGameFormat.bOpenPartner then 
        return;
    end

    local nFightTeamID = tbPreGameMgr:GetPlayerFightTeam(pPlayer);
    if nFightTeamID <= 0 then
        return;
    end    

    local tbPlayerInfo = self:GetPlayerInfo(pPlayer);
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
    local tbAllPartner = self.tbTeamPKInst:GetPlayerAllPartner(pPlayer.dwID);
    for nNpcId, tbPartnerInfo in pairs(tbAllPartner) do
        tbInfo.nNpcId = nNpcId;
        tbInfo.bDeath = tbPartnerInfo.bIsDeath;
        break;
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

    local tbTeamInfo = self:GetPlayFightTeam(nFightTeamID);
    if not tbTeamInfo then
        return;
    end

    for nPlayerID, tbPlayerInfo in pairs(tbTeamInfo.tbAllPlayer) do
        if nPlayerID ~= pPlayer.dwID then
            pPlayer.CallClientScript("Player:ServerSyncData", string.format("TeamPartner:%s", nPlayerID), tbPlayerInfo.tbShowPartner);  
        end    
    end 
end

function tbBaseLogic:UpdateAllPlayerAccount(bResult)
    local tbAllTeamShow = {};
    for nCurTeamID, tbPlayInfo in pairs(self.tbPlayFightTeamInfo) do
        local tbFightTeam = tbPreGameMgr:GetFightTeamByID(nCurTeamID);
        local tbTeamShowInfo = {};
        tbTeamShowInfo.tbAllPlayer = {};
        tbTeamShowInfo.szName = tbFightTeam:GetName();

        if bResult and self.tbTeamPKInst then
            local tbTeamInfo = self.tbTeamPKInst:GetTeamInfo(tbPlayInfo.nPlayTeam);
            if tbTeamInfo then
                tbTeamShowInfo.nResult = tbTeamInfo.nPlayState;
            end    
        end    

        for nPlayerID, tbShowInfo in pairs(tbPlayInfo.tbPlayerShowInfo) do
            
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

function tbBaseLogic:OnLogin()
    self:ShowLeaveButton(me);
    self:UpdateUIInfo(me);
    self:SyncTeamPartnerInfo(me);
    if self.tbTeamPKInst then
        local nTime = self.tbTeamPKInst:GetEndResidueTime();
        if nTime > 0 then
            local tbAllTeamShow = self:GetAllTeamShowInfo();
            self:OnStartAllTeamShowInfo(tbAllTeamShow, me);
        end    
    end    
end


function tbBaseLogic:ShowLeaveButton(pPlayer)
    local nState = self.nGameState;
    local tbPreDef = tbPreGameMgr:GetPreDef()
    if nState == tbPreDef.nPlayGameStateEnd then
        pPlayer.nCanLeaveMapId = pPlayer.nMapId;
        pPlayer.CallClientScript("Ui:OpenWindow", "QYHLeavePanel");
        pPlayer.CallClientScript("Map:SetCloseUiOnLeave", pPlayer.nMapId, "QYHLeavePanel");         
    end     
end   

function tbBaseLogic:GetPlayerInfo(pPlayer)
    local nFightTeamID = tbPreGameMgr:GetPlayerFightTeam(pPlayer);
    local tbFightTeamInfo = self:GetPlayFightTeam(nFightTeamID);
    if not tbFightTeamInfo then
        return;
    end

    local tbPlayerInfo = tbFightTeamInfo.tbAllPlayer[pPlayer.dwID];
    return tbPlayerInfo;
end

function tbBaseLogic:OnLeave()
    local pNpc = me.GetNpc();
    if pNpc.IsDeath() then
        me.Revive(1);
    end
    pNpc.ClearAllSkillCD();
    me.nInBattleState = 0; --战场模式
    me.bForbidChangePk = 0;
    me.nFightMode = 0;
    me.SetPkMode(Player.MODE_PEACE);
    pNpc.StopDamageCounter();
    me.nCanLeaveMapId = nil;
    tbPreGameMgr:ClearPlayerTeamTitle(me);
    me.CallClientScript("Ui:ForbidShowUI", "HomeScreenTask", me.nMapTemplateId, false);

    local tbPlayerInfo = self:GetPlayerInfo(me);
    if not tbPlayerInfo then
        Log("ERROR HSLJ OnLeave Not tbPlayerInfo");
        return;
    end    


    local nFightTeamID = tbPreGameMgr:GetPlayerFightTeam(me);
    local tbFightTeamInfo = self:GetPlayFightTeam(nFightTeamID);
    if tbFightTeamInfo then
        tbFightTeamInfo.tbAllPlayer[me.dwID] = nil;
    end 

    Log("HSLJ Play Map OnLeave", me.dwID, self.nMapId);
end

function tbBaseLogic:ForeachAllPlayerFightTeam(nFightTeamID, tbCallBack)
    local tbPlayFightTeam = self:GetPlayFightTeam(nFightTeamID);
    if not tbPlayFightTeam then
        return;
    end

    for nPlayerID, _ in pairs(tbPlayFightTeam.tbAllPlayer) do
        local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
        if pPlayer and self.nMapId == pPlayer.nMapId then
            Lib:MergeCallBack(tbCallBack, pPlayer);
        end    
    end 
end

function tbBaseLogic:ForeachAllPlayer(tbCallBack)
    local tbPlayer = KPlayer.GetMapPlayer(self.nMapId);
    for _, pPlayer in pairs(tbPlayer) do
        if pPlayer then
            Lib:MergeCallBack(tbCallBack, pPlayer);
        end    
    end
end
