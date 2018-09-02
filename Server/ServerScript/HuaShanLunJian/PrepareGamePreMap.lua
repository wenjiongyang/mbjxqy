
Require("CommonScript/HuaShanLunJian/LunJianDef.lua");
Require("ServerScript/HuaShanLunJian/HuaShanLunJian.lua");
Require("ServerScript/HuaShanLunJian/HSLJPreGamePreLogic.lua");

HuaShanLunJian.tbAllPreMapLogicInst = HuaShanLunJian.tbAllPreMapLogicInst or {};
HuaShanLunJian.tbBasePreMapLogic = HuaShanLunJian.tbBasePreMapLogic or {};

local tbPreMapLogic = HuaShanLunJian.tbBasePreMapLogic;
local tbDef    = HuaShanLunJian.tbDef;
local tbPreDef = tbDef.tbPrepareGame;
local tbPreMap = Map:GetClass(tbDef.tbPrepareGame.nPrepareMapTID);
local tbPreGameMgr = HuaShanLunJian.tbPreGamePreMgr;

function tbPreMap:OnCreate(nMapId)
    local tbInst = HuaShanLunJian.tbAllPreMapLogicInst[nMapId];
    if not tbInst then
        tbInst = Lib:NewClass(tbPreMapLogic);
        tbInst:OnCreate(nMapId);
        HuaShanLunJian.tbAllPreMapLogicInst[nMapId] = tbInst;
    else
        Log("Error HuaShanLunJian PreMap OnCreate Have", nMapId);
    end    

    Log("HuaShanLunJian PreMap OnCreate", nMapId);
end

--TrueEndGame时武林大会删除本服的nmapid
function tbPreMap:OnDestroy(nMapId)
    local tbInst = HuaShanLunJian.tbAllPreMapLogicInst[nMapId];
    if tbInst then
        tbInst:OnClose();
        HuaShanLunJian.tbAllPreMapLogicInst[nMapId] = nil;
    end

    Log("HuaShanLunJian PreMap OnDestroy", nMapId);
end

function tbPreMap:OnEnter(nMapId)
    local tbInst = HuaShanLunJian.tbAllPreMapLogicInst[nMapId];
    if not tbInst then
        return;
    end

    tbInst:OnEnter();  
end

function tbPreMap:OnLeave(nMapId)
    local tbInst = HuaShanLunJian.tbAllPreMapLogicInst[nMapId];
    if not tbInst then
        return;
    end

    tbInst:OnLeave();
end

function tbPreMap:OnLogin(nMapId)
    local tbInst = HuaShanLunJian.tbAllPreMapLogicInst[nMapId];
    if not tbInst then
        return;
    end

    tbInst:OnLogin();
end

--重载
function tbPreMapLogic:OnCreate(nMapId)
    self.nMapId = nMapId;
    self.tbEnterFighTeam = {};
    self.nEnterFightTeam = 0;
    self.tbAllPlayerInfo = {};
end

function tbPreMapLogic:OnClose()

    self:ForeachAllPlayer({tbPreGameMgr.PlayerKickOut, tbPreGameMgr});
    Log("HSLJ PreMapLogic OnClose", self.nMapId);
end

function tbPreMapLogic:GetFightTeamInfo(nFightTeamID)
    local tbFightTeamInfo = HuaShanLunJian:GetPreGameFightTeamByID(nFightTeamID);
    return tbFightTeamInfo;
end 

function tbPreMapLogic:ForeachPlayerFightTeam(nFightTeamID, tbCallBack)
    local tbTeamInfo = self:GetFightTeamInfo(nFightTeamID);
    if not tbTeamInfo then
        return;
    end

    for nPlayerID, _ in pairs(tbTeamInfo.tbAllPlayer) do
        local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
        if pPlayer and pPlayer.nMapId == self.nMapId then
            Lib:MergeCallBack(tbCallBack, pPlayer);
        end    
    end    
end

function tbPreMapLogic:OnEnter()
    local nFightTeamID = tbPreGameMgr:GetPlayerFightTeam(me);   -- 自己直接返回的 team了 TODO 和华山论剑的不一样
    local tbFightTeam = tbPreGameMgr:GetFightTeamByID(nFightTeamID);
    if not tbFightTeam then
        Log("Error Not tbFightTeam", me.dwID, nFightTeamID)
        return;
    end

    self:AddFightTeamPlayer(me);
    self:UpdateUIInfo(me);
    me.nCanLeaveMapId = self.nMapId;

    if not self.tbAllPlayerInfo[me.dwID] then
        self:AddFightTeamEnterCount(nFightTeamID)
    end

    local tbPlayerInfo = {};
    tbPlayerInfo.nReChangePartnerId = PlayerEvent:Register(me, "OnChangePartnerFightID", self.OnChangePartnerFightID, self);
    tbPlayerInfo.tbShowPartner = {};

    self.tbAllPlayerInfo[me.dwID] = tbPlayerInfo;
    self:PlayerUpdatePartnerShowInfo(me);
    self:SyncTeamPartnerInfo(me);

    local tbNotPreData = HuaShanLunJian:GetPrepareGameNotSave();
    if tbNotPreData.nPlayGameCount > 0 then
        me.CenterMsg(string.format("您成功報名了%s，請準備比賽！", tbPreGameMgr:GetMatchName()) , true);
    end  
    Log("HuaShanLunJian PreMapLogic OnEnter", self.nMapId, me.dwID);
end

function tbPreMapLogic:AddFightTeamEnterCount(nFightTeamID)
    if nFightTeamID <= 0 then
        Log("Error HuaShanLunJian AddFightTeamEnterCount", self.nMapId, nFightTeamID);
        return;
    end

    if not self.tbEnterFighTeam[nFightTeamID] then
        self.tbEnterFighTeam[nFightTeamID] = 0;
        self.nEnterFightTeam = self.nEnterFightTeam + 1;
    end

    self.tbEnterFighTeam[nFightTeamID] = self.tbEnterFighTeam[nFightTeamID] + 1;     
end

function tbPreMapLogic:ReduceFightTeamEnterCount(nFightTeamID)
    if nFightTeamID <= 0 then
        Log("Error HuaShanLunJian ReduceFightTeamEnterCount", self.nMapId, nFightTeamID);
        return;
    end

    if not self.tbEnterFighTeam[nFightTeamID] then
        return;
    end

    local nCount = self.tbEnterFighTeam[nFightTeamID] - 1;
    self.tbEnterFighTeam[nFightTeamID] = nCount;
    
    if nCount <= 0 then
        self.nEnterFightTeam = self.nEnterFightTeam - 1;
        self.tbEnterFighTeam[nFightTeamID] = nil;
    end
end

function tbPreMapLogic:GetFightTeamEnterCount()
    return self.nEnterFightTeam;
end

function tbPreMapLogic:PlayerUpdatePartnerShowInfo(pPlayer)
    local tbGameFormat = tbPreGameMgr:GetGameFormat();
    if not tbGameFormat.bOpenPartner then 
        return;
    end

    local nFightTeamID = tbPreGameMgr:GetPlayerFightTeam(pPlayer);
    if nFightTeamID <= 0 then
        return;
    end    

    local tbPlayerInfo = self.tbAllPlayerInfo[pPlayer.dwID];
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
    tbInfo.nFightPower = tbCurPartner.nFightPower
    tbPlayerInfo.tbShowPartner = tbInfo;

    self:ForeachPlayerFightTeam(nFightTeamID, {self.OnSyncPartnerInfo, self, tbPlayerInfo.tbShowPartner, pPlayer.dwID});
end

function tbPreMapLogic:OnSyncPartnerInfo(tbShowPartner, nPlayerID, pPlayer)
    pPlayer.CallClientScript("Player:ServerSyncData", string.format("TeamPartner:%s", nPlayerID), tbShowPartner);    
end

function tbPreMapLogic:SyncTeamPartnerInfo(pPlayer)
    local tbGameFormat = tbPreGameMgr:GetGameFormat();
    if not tbGameFormat.bOpenPartner then 
        return;
    end

    local nFightTeamID = tbPreGameMgr:GetPlayerFightTeam(pPlayer);
    if nFightTeamID <= 0 then
        return;
    end    

    local tbTeamInfo = self:GetFightTeamInfo(nFightTeamID);
    if not tbTeamInfo then
        return;
    end

    for nPlayerID, _ in pairs(tbTeamInfo.tbAllPlayer) do
        if nPlayerID ~= pPlayer.dwID then
            local tbPlayerInfo = self.tbAllPlayerInfo[nPlayerID];
            if tbPlayerInfo then
                pPlayer.CallClientScript("Player:ServerSyncData", string.format("TeamPartner:%s", nPlayerID), tbPlayerInfo.tbShowPartner);
            end     
        end    
    end 
end

function tbPreMapLogic:OnLogin()
    self:UpdateUIInfo(me);
    self:SyncTeamPartnerInfo(me);
end


function tbPreMapLogic:OnChangePartnerFightID()
    self:PlayerUpdatePartnerShowInfo(me);
end

function tbPreMapLogic:UpdateUIInfo(pPlayer)
    pPlayer.CallClientScript("Player:ServerSyncData", "HomeBtnTast", {nMapTID = pPlayer.nMapTemplateId});
    local tbGameFormat = tbPreGameMgr:GetGameFormat();
    if tbGameFormat.szPKClass and tbGameFormat.szPKClass == "PlayDuel" then
        pPlayer.CallClientScript("Player:ServerSyncData", "TeamBtNum", {nMapTID = pPlayer.nMapTemplateId});
    end

    pPlayer.nCanLeaveMapId = pPlayer.nMapId;
    pPlayer.CallClientScript("Ui:OpenWindow", "QYHLeavePanel", "HSLJ");
    pPlayer.CallClientScript("Map:SetCloseUiOnLeave", pPlayer.nMapId, "QYHLeavePanel"); 
    if not MODULE_ZONESERVER then
        pPlayer.CallClientScript("Ui:SetLoadShowUI", {nMapTID = pPlayer.nMapTemplateId, tbUi = {["BattleTopButton"] = 1}}); 
    end
    
    local tbShowInfo = {}
    tbShowInfo.nTime = self:GetPreLogicTime();
    tbShowInfo.szShow = self:GetShowUIMsg();
    tbShowInfo.nMapTID = pPlayer.nMapTemplateId;
    tbShowInfo.szHelp = self:GetHSLJBattleInfoShowInfoHelp()
    pPlayer.CallClientScript("Ui:OpenWindow", "HSLJBattleInfo", "ShowInfo", tbShowInfo);

    if tbGameFormat.bOpenPartner then    
        pPlayer.CallClientScript("Player:ServerSyncData", "TeamShowPartner", {nMapTID = pPlayer.nMapTemplateId});
    end    
end

--重载
function tbPreMapLogic:GetHSLJBattleInfoShowInfoHelp()
    return nil;
end

function tbPreMapLogic:GetShowUIMsg()
    return tbPreGameMgr.szShowUIMsg or "";
end

function tbPreMapLogic:GetPreLogicTime()
    return tbPreGameMgr:GetOnceTime();
end

function tbPreMapLogic:AddFightTeamPlayer(pPlayer)
    local nFightTeamID = tbPreGameMgr:GetPlayerFightTeam(pPlayer);
    if nFightTeamID <= 0 then
        Log("Error LunJian AddFightTeamPlayer", self.nMapId, pPlayer.dwID);
        return;
    end

    local tbTeamInfo = self:GetFightTeamInfo(nFightTeamID);
    if not tbTeamInfo then
        Log("Error LunJian AddFightTeamPlayer TeamInfo", self.nMapId, pPlayer.dwID);
        return;
    end

    if tbTeamInfo.tbAllPlayer[pPlayer.dwID] then
        tbTeamInfo.tbAllPlayer[pPlayer.dwID] = nil;
        Log("Error LunJian AddFightTeamPlayer Have Player", nFightTeamID, pPlayer.dwID);
    end    

    local nCurTeamCount = Lib:CountTB(tbTeamInfo.tbAllPlayer);
    if nCurTeamCount <= 0 or tbTeamInfo.nTeamId <= 0 then
        if pPlayer.dwTeamID <= 0 then
            TeamMgr:Create(pPlayer.dwID, pPlayer.dwID);     
        end

        tbTeamInfo.nTeamId = pPlayer.dwTeamID;  
    else
        if pPlayer.dwTeamID ~= tbTeamInfo.nTeamId then
            local tbTeam = TeamMgr:GetTeamById(tbTeamInfo.nTeamId);
            if tbTeam then
                local nCaptainId = tbTeam:GetCaptainId();
                local bRet = TeamMgr:DirectAddMember(nCaptainId, pPlayer);
                if not bRet then
                    Log("Error  AddFightTeamPlayer DirectAddMember", self.nMapId, pPlayer.dwID);
                end
            end     
        end   
    end

    local tbTeam = TeamMgr:GetTeamById(tbTeamInfo.nTeamId);
    if tbTeam then
        local tbMember = tbTeam:GetMembers();
        local tbQuiteTeam = {};
        for _, nPlayerID in pairs(tbMember) do
            local pMember = KPlayer.GetPlayerObjById(nPlayerID);
            if pMember then
                local nMemberTeamID = tbPreGameMgr:GetPlayerFightTeam(pMember);
                if nMemberTeamID ~= nFightTeamID then
                    tbQuiteTeam[nPlayerID] = pMember;
                end
            end
        end

        for _, pMember in pairs(tbQuiteTeam) do
            TeamMgr:QuiteTeam(pMember.dwTeamID, pMember.dwID);
        end   
    end
        
    tbTeamInfo.tbAllPlayer[pPlayer.dwID] = 1;
    tbTeamInfo.nPreMapMapId = self.nMapId;
    Log("LunJian AddFightTeamPlayer", self.nMapId, pPlayer.dwID, nFightTeamID, nCurTeamCount + 1);
end

function tbPreMapLogic:RemoveFightTeamPlayer(pPlayer)
    local nFightTeamID = tbPreGameMgr:GetPlayerFightTeam(pPlayer);
    if nFightTeamID <= 0 then
        Log("Error LunJian AddFightTeamPlayer", self.nMapId, pPlayer.dwID);
        return;
    end

    local tbTeamInfo = self:GetFightTeamInfo(nFightTeamID);
    if not tbTeamInfo then
        return;
    end

    local bQuiteTam = true;
    if pPlayer.bHSLJQuitePKTeam then
        bQuiteTam = false;
        pPlayer.bHSLJQuitePKTeam = nil;   
    end
        
    if tbTeamInfo.tbAllPlayer[pPlayer.dwID] then
        if pPlayer.dwTeamID ~= 0 and bQuiteTam then
            TeamMgr:QuiteTeam(pPlayer.dwTeamID, pPlayer.dwID);
        end
            
        tbTeamInfo.tbAllPlayer[pPlayer.dwID] = nil;
    end
    
    local nCurTeamCount = Lib:CountTB(tbTeamInfo.tbAllPlayer);
    if nCurTeamCount <= 0 then
        tbTeamInfo.nPreMapMapId = nil;
    end  
    Log("LunJian RemoveFightTeamPlayer", self.nMapId, pPlayer.dwID, nFightTeamID, nCurTeamCount);     
end

function tbPreMapLogic:OnLeave()
    self:RemoveFightTeamPlayer(me);
    me.nCanLeaveMapId = nil;
    me.bHSLJQuitePKTeam = nil;  
    me.CallClientScript("Player:ServerSyncData", "HomeBtnTast");

    local tbPlayerInfo = self.tbAllPlayerInfo[me.dwID];
    if tbPlayerInfo then


        if tbPlayerInfo.nReChangePartnerId then
            PlayerEvent:UnRegister(me, "OnChangePartnerFightID", tbPlayerInfo.nReChangePartnerId);
            tbPlayerInfo.nReChangePartnerId = nil;
        end    

        self.tbAllPlayerInfo[me.dwID] = nil;
    end

    local nFightTeamID = tbPreGameMgr:GetPlayerFightTeam(me);
    self:ReduceFightTeamEnterCount(nFightTeamID)    
    Log("LunJian OnLeave", self.nMapId, me.dwID);     
end


function tbPreMapLogic:ForeachAllPlayer(tbCallBack)
    local tbPlayer = KPlayer.GetMapPlayer(self.nMapId);
    for _, pPlayer in pairs(tbPlayer) do
        if pPlayer then
            Lib:MergeCallBack(tbCallBack, pPlayer);
        end    
    end
end

--------------------------------------------------

function HuaShanLunJian:FindEnterPreMapId(pPlayer)
    local nFightTeamID = tbPreGameMgr:GetPlayerFightTeam(pPlayer);
    if nFightTeamID <= 0 then
        return;
    end

    local tbFightTeamInfo = self:GetPreGameFightTeamByID(nFightTeamID);
    if tbFightTeamInfo.nPreMapMapId then
        return tbFightTeamInfo.nPreMapMapId;
    end

    local nMapId = tbPreGameMgr:GetFreePreMapID()
    return nMapId;   
end


function HuaShanLunJian:CheckEnterPrepareGame(pPlayer, bNotCheckMap, bOnePlayer, bNotTeamCount)
    if not Lib:HaveCountTB(self.tbAllPreMapLogicInst) then
        return false, "華山論劍比賽尚未開啟！";
    end

    local tbNotPreData = self:GetPrepareGameNotSave();
    if not tbNotPreData.bStart then
        return false, "今日華山論劍預選賽已結束！";
    end

    if tbDef.nMinPlayerLevel > pPlayer.nLevel then
        return false, string.format("等級不足%d級", tbDef.nMinPlayerLevel);
    end

    local nFightTeamID = self:GetPlayerFightTeam(pPlayer);
    if nFightTeamID <= 0 then
        return false, "你還沒有戰隊，去加入或創建一個戰隊再來吧！";
    end

    local nEnterPreMapID = self:FindEnterPreMapId(pPlayer);
    if not nEnterPreMapID then
        tbPreGameMgr:CreatePreMap(tbDef.nNextPreGamePreMap);
        return false, "正在創建準備場，請稍後再進入";
    end  

    local tbFightTeam = self:GetFightTeamByID(nFightTeamID);
    if not tbFightTeam then
        return false, "沒有這個戰隊"
    end

    local bRet = tbFightTeam:HavePlayerID(pPlayer.dwID);
    if not bRet then
        return false, "戰隊不存在你的資訊，請跟客服人員聯繫！";
    end 

    local tbSaveData = HuaShanLunJian:GetLunJianSaveData();
    local nMaxJoinCount = HuaShanLunJian:GetPreGameJoinCount(tbSaveData.nWeekDay);
    local nJoinCount = tbFightTeam:GetJoinCount();
    if nJoinCount >= nMaxJoinCount and not bNotTeamCount then
        return false, "您的戰隊已沒有剩餘比賽次數";
    end

    local nPerCount = tbFightTeam:GetPerDayCount();
    if nPerCount >= tbPreDef.nPerDayJoinCount and not bNotTeamCount then
        return false, "您的戰隊今天沒有剩餘比賽次數";
    end    

    bRet = Map:CheckEnterOtherMap(pPlayer);
    if not bRet and not bNotCheckMap then
        return false, "非安全區不能進入";
    end   

    local nTeamId = pPlayer.dwTeamID;
    if nTeamId > 0 and not bOnePlayer then
        local tbTeam = TeamMgr:GetTeamById(nTeamId)
        local nCaptainId = tbTeam:GetCaptainId();
        if nCaptainId ~= pPlayer.dwID then
            return false, "您不是隊長";
        end

        local tbMember = tbTeam:GetMembers();
        for _, nPlayerID in pairs(tbMember) do
            local pMember = KPlayer.GetPlayerObjById(nPlayerID);
            if not pMember then
                return false, "有玩家不線上！"
            end

            local nMemberTeamID = self:GetPlayerFightTeam(pMember);
            if nMemberTeamID ~= nFightTeamID then
                return false, string.format("%s不是同一個戰隊", pMember.szName);
            end

            bRet = tbFightTeam:HavePlayerID(pMember.dwID);
            if not bRet then
                return false, string.format("戰隊不存在%s的資訊，請跟客服人員聯繫！!", pMember.szName);
            end  

            bRet = Map:CheckEnterOtherMap(pMember);
            if not bRet and not bNotCheckMap then
                return false, string.format("「%s」非安全區不能進入", pMember.szName);
            end    
        end        
    end

    return true, "", nEnterPreMapID, nFightTeamID;
end

--适用于华山论剑和武林大会的了
function HuaShanLunJian:EnterPrepareGame(pPlayer, bNotCheckMap, bOnePlayer, bNotTeamCount)
    local bRet, szMsg, nEnterPreMapID, nFightTeamID = tbPreGameMgr:CheckEnterPrepareGame(pPlayer, bNotCheckMap, bOnePlayer, bNotTeamCount);
    if not bRet then
        pPlayer.CenterMsg(szMsg);
        return;
    end

    local tbFightTeamInfo = HuaShanLunJian:GetPreGameFightTeamByID(nFightTeamID);
    tbFightTeamInfo.nPreMapMapId = nEnterPreMapID;

    local tbPreMap = self.tbAllPreMapLogicInst[nEnterPreMapID];
    if not tbPreMap then
        Log("Errpr HuaShanLunJian EnterPrepareGame PreMap", pPlayer.dwID);
        return;
    end    

    local tbPreDef = tbPreGameMgr:GetPreDef()
    local tbAllPos   = HuaShanLunJian:GetMapAllPosByTID(tbPreDef.nPrepareMapTID); --TODO 点配置到一起吧
    local nTotalCount = #tbAllPos;
    local nRandIndex = MathRandom(nTotalCount);
    local tbEnterPos = tbAllPos[nRandIndex];

    local nTeamId = pPlayer.dwTeamID;
    if nTeamId > 0 and not bOnePlayer then
        local tbTeam = TeamMgr:GetTeamById(nTeamId)
        local tbMember = tbTeam:GetMembers();
        for _, nPlayerID in pairs(tbMember) do
            local pMember = KPlayer.GetPlayerObjById(nPlayerID);
            pMember.SetEntryPoint();
            pMember.SwitchMap(nEnterPreMapID, tbEnterPos.PosX, tbEnterPos.PosY);
            Log("HuaShanLunJian EnterPrepareGame", pMember.dwID);
        end
    else
        if not bNotCheckMap then
            pPlayer.SetEntryPoint();
        end
            
        pPlayer.SwitchMap(nEnterPreMapID, tbEnterPos.PosX, tbEnterPos.PosY);
        Log("HuaShanLunJian EnterPrepareGame", pPlayer.dwID);
    end

    local nFreeMapId = tbPreGameMgr:GetFreePreMapID();
    if not nFreeMapId then
        tbPreGameMgr:CreatePreMap(tbDef.nNextPreGamePreMap);
    end      
end