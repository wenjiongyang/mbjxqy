Kin.KinNest = Kin.KinNest or {};
local KinNest = Kin.KinNest;
KinNest.tbDefault = KinNest.tbDefault or {};

local tbDef = KinNest.tbDefault;

KinNest.nMapTemplateId = 700;   --盗贼巢穴地图
KinNest.nNpcNumber = 0;         --盗贼个数
KinNest.nNpcLevel = 0;          --盗贼等级

tbDef.nKinOpenStateWait = 1;    --等待开启状态
tbDef.nKinOpenStateOpen = 2;    --开启状态
tbDef.nKinOpenStateEnd  = 3;    --结束状态
tbDef.bKinNestActivity  = true; --是否开启巢穴

tbDef.szOpenHourTime = "18:00"; --开启的时间
tbDef.nBossNumber = 3;
tbDef.nFrieTime = 60;
tbDef.ActivityTime = 14400;
tbDef.nReviveTime = 10;
KinNest.tbBossInfo = {};
KinNest.tbAwardInfo = {};
KinNest.tbKinNestInfor = KinNest.tbKinNestInfor  or {};

KinNest.tbOpenPro = {
    [1] = 30,
    [2] = 50,
    [3] = 100,
    [4] = 100,
}

KinNest.tbNpcSetting = KinNest.tbNpcSetting 
    or LoadTabFile("ServerSetting/KinNest/KinNestNpc.tab", "ddddd", nil, {"DialogNpc", "FightNpc", "PosX", "PosY", "Series"});

function KinNest:LoadSetting()
    self.tbBossInfo = LoadTabFile(
        "ServerSetting/KinNest/KinNestBoss.tab", 
        "sdsssd","TimeFrame",
        {"TimeFrame", "FubenLevel", "BossAward", "LastAward", "BossRateAward", "BossRate"});
    for szTimeFrame, tbInfo in pairs(self.tbBossInfo ) do
        self.tbAwardInfo[szTimeFrame] = {};
        self.tbAwardInfo[szTimeFrame].tbLastAward = Lib:GetAwardFromString(tbInfo.LastAward);
        self.tbAwardInfo[szTimeFrame].tbBossAward = Lib:GetAwardFromString(tbInfo.BossAward);
        self.tbAwardInfo[szTimeFrame].tbBossRateAward = Lib:GetAwardFromString(tbInfo.BossRateAward);
        self.tbAwardInfo[szTimeFrame].nBossRate = tbInfo.BossRate;
    end
end

KinNest:LoadSetting();

function KinNest:GetKinNestInfor(nKinID)
    if not self.tbKinNestInfor[nKinID] then
        self.tbKinNestInfor[nKinID] = {
            tbNpcInfo = {},
            tbBossInfo = {},
            nMapId = 0,
            nNpcNumber = 0,
            nNpcLevel = 0,
        };
    end
    return self.tbKinNestInfor[nKinID];
end

function KinNest:GetNpcInfo(nKinID)
    local tbDate = self:GetKinNestInfor(nKinID);
    return tbDate.tbNpcInfo;
end

function KinNest:GetBossInfo(nKinID)
    local tbDate = self:GetKinNestInfor(nKinID);
    return tbDate.tbBossInfo;
end

function KinNest:CleanNpcInfo(nKinID)
    local tbDate = self:GetKinNestInfor(nKinID);
    tbDate.tbNpcInfo = {};
end

function KinNest:GetKinNestData(nKinID)
    local kinData = Kin:GetKinById(nKinID);
    if not kinData then
        return;
    end

    local tbData = kinData:GetCustomData("KinNestData");
    if not tbData.nActivateData then
        tbData.nActivateData = 0; --激活的天
        tbData.nOpenState = tbDef.nKinOpenStateEnd; --是否开启活动
    end
    return tbData;
end

function KinNest:OnLogin(pPlayer)
    -- do nothing
end

function KinNest:RandomActivity(nKinID, nRound, nNpcNumber, nLevel)
    --盗贼全灭后随即活动
    if not tbDef.bKinNestActivity then
        return false;
    end    

    local szTimeFrame = self:GetCurTimeFrame();
    if not szTimeFrame or szTimeFrame == "" then
         return false;
    end

    local tbData = self:GetKinNestData(nKinID);
    if not tbData then
        return;
    end

    local nRandom = MathRandom (1,100);
    if nRandom <= self.tbOpenPro[nRound] then
        local tbKin = Kin:GetKinById(nKinID)
        if tbKin:AddClue(1) then
            local szMsg = "從盜賊身上截獲俠客島寶藏線索，1月5日可前往俠客島，獲得額外的寶箱。"
            ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, nKinID)
        end
        --[[
        tbData.nActivateData = Lib:GetLocalDay();
        tbData.nOpenState = tbDef.nKinOpenStateWait; --是否开启活动

        local szMsg = string.format("从盗贼身上截获了「盗贼巢穴」线索，「族长」及「副族长」可以组织家族成员通过「家族总管」开启活动。（18:00~24:00可开启活动）")
        ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, nKinID);
        local tbMemberList = Kin:GetKinMembers(nKinID)
        for nMemberId, nCareer in pairs(tbMemberList) do
            if nCareer == Kin.Def.Career_Master or nCareer == Kin.Def.Career_ViceMaster then
                local tbMail = 
                {
                    To = nMemberId,
                    Text = "从盗贼身上截获了「盗贼巢穴」的线索，「族长」及「副族长」可以组织家族成员通过「家族总管」开启活动。（18:00~24:00可开启活动）",
                    nLogReazon = Env.LogWay_KinNest,
                };
        
                Mail:SendSystemMail(tbMail);
            end
        end

        local tbKinInfor = self:GetKinNestInfor(nKinID);
        tbKinInfor.nNpcNumber = nNpcNumber;
        tbKinInfor.nNpcLevel = nLevel;
        ]]

        Log("KinNest RandomActivity", nKinID or 0, nNpcNumber or 0, nLevel or 0);
        return true;
    end
end

function KinNest:CheckApplyKinNest(pPlayer)
    local tbData = self:GetKinNestData(pPlayer.dwKinId);
    if not tbData then
        return false, "未加入幫派";
    end


    local tbMemberList = Kin:GetKinMembers(pPlayer.dwKinId)

    if tbMemberList[pPlayer.dwID] ~= Kin.Def.Career_ViceMaster and tbMemberList[pPlayer.dwID] ~= Kin.Def.Career_Master then
        return false, "只有堂主和副堂主可以開啟";
    end

    if tbData.nActivateData ~= Lib:GetLocalDay() then
        return false, "活動已結束";
    end

    if tbData.nOpenState ~= tbDef.nKinOpenStateWait then
        return false, "當前沒有俠客島的線索，無法開啟";
    end   

    return true;
end

function KinNest:ForceOpen(nKinID, nNpcNumber, nLevel)
    local tbData = self:GetKinNestData(nKinID)
    if not tbData then
        Log("[x] KinNest:ForceOpen a")
        return false
    end

    local nLocalDay = Lib:GetLocalDay()
    if tbData.nActivateData==nLocalDay then
        Log("[x] KinNest:ForceOpen b")
        return false
    end

    local szTimeFrame = self:GetCurTimeFrame()
    if not szTimeFrame or szTimeFrame=="" then
        Log("[x] KinNest:ForceOpen c")
         return false
    end

    if not Kin:GetKinById(nKinID) then
        Log("[x] KinNest:ForceOpen d")
        return false
    end

    tbData.nActivateData = nLocalDay
    tbData.nOpenState = tbDef.nKinOpenStateWait

    local szMsg = string.format("已獲得前往「俠客島」及島上寶藏的線索，「族長」及「副族長」可找「幫派總管」開啟，記得通知幫派成員集合")
    ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, nKinID)

    local tbKinInfor = self:GetKinNestInfor(nKinID)
    tbKinInfor.nNpcNumber = nNpcNumber
    tbKinInfor.nNpcLevel = nLevel

    return true
end

function KinNest:ApplyOpenKinNest(pPlayer)
    local bRet, szMsg = self:CheckApplyKinNest(pPlayer);
    if not bRet then
        pPlayer.CenterMsg(szMsg);
        return;
    end

    local szMsg = string.format("「俠客島」活動已經開啟，各位成員可尋找「幫派總管」對話進入");
    ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, pPlayer.dwKinId);
    local tbMsgData = {
        szType = "KinNest";
        nTimeOut = GetTime() + Kin.RobDef.ActivityTime;
    };
    local tbMemberList = Kin:GetKinMembers(pPlayer.dwKinId)
    for nMemberId, nCareer in pairs(tbMemberList) do
        local player = KPlayer.GetPlayerObjById(nMemberId);
        if player then
            player.CallClientScript("Ui:SynNotifyMsg", tbMsgData);
        end
    end
    local tbData = self:GetKinNestData(pPlayer.dwKinId);
    tbData.nOpenState = tbDef.nKinOpenStateOpen;

    local tbKinInfor = self:GetKinNestInfor(pPlayer.dwKinId);
    local nCheckpPlayerID = pPlayer.dwID;
    local function fnSucess(nMapId)
        local pPlayer = KPlayer.GetPlayerObjById(nCheckpPlayerID);
        if not pPlayer then
            return;
        end

        tbKinInfor.nMapId = nMapId;
    end

    local function fnFailedCallback()
        local pPlayer = KPlayer.GetPlayerObjById(nCheckpPlayerID);
        if not pPlayer then
            return;
        end
        pPlayer.CenterMsg(szMsg);
    end

    Log("KinNestFuben OnPreCreate", nKinID);

    local szTimeFrame = self:GetCurTimeFrame();
    Fuben:ApplyFubenUseLevel(pPlayer.dwID, KinNest.nMapTemplateId, self.tbBossInfo[szTimeFrame].FubenLevel, fnSucess, fnFailedCallback, pPlayer.dwKinId, tbKinInfor.nNpcNumber,nCheckpPlayerID);
end

function KinNest:CheckEnterKinNest(pPlayer)
    local tbData = self:GetKinNestData(pPlayer.dwKinId);
    if not tbData then
        return false, "未加入幫派";
    end

    if tbData.nActivateData ~= Lib:GetLocalDay() then
        return false, "今天活動未開啟";
    end

    if tbData.nOpenState == tbDef.nKinOpenStateWait then
        return false, "活動還未開啟";
    end

    if tbData.nOpenState == tbDef.nKinOpenStateEnd then
        return false, "活動已結束";
    end

    if not Env:CheckSystemSwitch(pPlayer, Env.SW_KinNest) then
        return false, "目前狀態不允許參加";
    end

    return true;
end

function KinNest:EnterKinNest(nPlayerId)
    local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
    local bRet, szMsg = self:CheckEnterKinNest(pPlayer);
    if not bRet then
        pPlayer.CenterMsg(szMsg);
        return;
    end
    local tbKinInfor = self:GetKinNestInfor(pPlayer.dwKinId);
    if tbKinInfor then
        if not tbKinInfor.nMapId or tbKinInfor.nMapId<=0 then
            pPlayer.CenterMsg("進入俠客島失敗")
            return
        end
        self:SetPlayerJoined(pPlayer.dwKinId, nPlayerId)
        pPlayer.SwitchMap(tbKinInfor.nMapId, 0, 0);
    end
end

function KinNest:EndKinNest(nKinId)
    local tbKinDate = self:GetKinNestData(nKinId);
    if not tbKinDate then
        Log("[x] KinNest:EndKinNest, no kin", tostring(nKinId))
        return
    end
    tbKinDate.nOpenState = tbDef.nKinOpenStateEnd;

    local tbKinInfor = self:GetKinNestInfor(nKinId);
    local tbAllPlayer = KPlayer.GetMapPlayer(tbKinInfor.nMapId);
    for _, pPlayer in pairs(tbAllPlayer) do
        if pPlayer then
            pPlayer.GotoEntryPoint()
        end
    end

    self:ClearJoinedPlayers(nKinId)
    Log("KinNest EndKinNest", nKinId or 0);
end

function KinNest:OnLeaveKinNest(pPlayer)
    pPlayer.GotoEntryPoint();
end

function KinNest:ClearJoinedPlayers(nKinId)
    self.tbJoinedPlayers = self.tbJoinedPlayers or {}
    self.tbJoinedPlayers[nKinId] = nil
end

function KinNest:SetPlayerJoined(nKinId, nPlayerId)
    self.tbJoinedPlayers = self.tbJoinedPlayers or {}
    self.tbJoinedPlayers[nKinId] = self.tbJoinedPlayers[nKinId] or {}
    self.tbJoinedPlayers[nKinId][nPlayerId] = true
end

function KinNest:GetJoinedPlayers(nKinId)
    self.tbJoinedPlayers = self.tbJoinedPlayers or {}
    return self.tbJoinedPlayers[nKinId] or {}
end

function KinNest:SendLastReward(nKinId)
    local tbKin = Kin:GetKinById(nKinId)
    local nClue = tbKin:GetClue()
    local tbRewards = Kin.NestDef.tbClueRewards[nClue]
    if not tbRewards then
        Log("[x] KinNest:SendLastReward", nKinId, nClue)
        tbRewards = Kin.NestDef.tbClueRewards[0]
    end
    tbKin:ResetClue()

    local tbAllPlayers = self:GetJoinedPlayers(nKinId)
    for nPid in pairs(tbAllPlayers) do
        local tbMember = Kin:GetMemberData(nPid)
        local bInKin = tbMember and tbMember.nKinId==nKinId
        if bInKin then
            Mail:SendSystemMail({
                To = nPid,
                Title = "俠客島獎勵",
                Text = "諸位幫派弟兄根據盜賊身上的線索，成功識破幕後黑手設下的「假俠客島」陰謀，擊敗了島上的神秘人，附件中的是武林贈予的嘉獎，請注意查收！",
                From = "幫派總管",
                tbAttach = tbRewards,
                nLogReazon = Env.LogWay_KinNest,
            })
        end
        Log("KinNest:SendLastReward", nKinId, nPid, nClue, tostring(bInKin))
    end

    --[[
    local szTimeFrame = self:GetCurTimeFrame();
    local tbAward = self.tbAwardInfo[szTimeFrame].tbLastAward;
    local tbKinInfor = self:GetKinNestInfor(nKinId);
    local tbAllPlayer = KPlayer.GetMapPlayer(tbKinInfor.nMapId);
    for _, pPlayer in pairs(tbAllPlayer) do
        if pPlayer then
            local nDegreeCount = DegreeCtrl:GetDegree(pPlayer, "KinNestDay");
            if nDegreeCount > 0 then
                DegreeCtrl:ReduceDegree(pPlayer, "KinNestDay", 1);
                pPlayer.SendAward(tbAward, true, nil, Env.LogWay_KinNest);
            else
                Log("[KinNest] Not Count SendLastReward", pPlayer.szName, pPlayer.dwKinId, pPlayer.dwID);    
            end    
        end
    end
    ]]
end

function KinNest:SendBossReward(nKinId)
--[[
    local tbKinInfor = self:GetKinNestInfor(nKinId);
    local tbAllPlayer = KPlayer.GetMapPlayer(tbKinInfor.nMapId);

    local szTimeFrame = self:GetCurTimeFrame();
    local tbAwardInfo = self.tbAwardInfo[szTimeFrame];
    local tbAward = tbAwardInfo.tbBossAward;

    for _, pPlayer in pairs(tbAllPlayer) do
        if pPlayer then
            local nDegreeCount = DegreeCtrl:GetDegree(pPlayer, "KinNestDay");
            if nDegreeCount > 0 then
                DegreeCtrl:ReduceDegree(pPlayer, "KinNestDay", 1);
                pPlayer.SendAward(tbAward, true, nil, Env.LogWay_KinNest);

                if tbAwardInfo.nBossRate > 0 then
                    local nRate = MathRandom(100);
                    if tbAwardInfo.nBossRate >= nRate then
                        pPlayer.SendAward(tbAwardInfo.tbBossRateAward, true, nil, Env.LogWay_KinNest);
                    end    
                end    
            else
                Log("[KinNest] Not Count SendBossReward", pPlayer.szName, pPlayer.dwKinId, pPlayer.dwID);    
            end  
        end
    end
    ]]
end

function KinNest:GetCurTimeFrame()
    local szTimeFrame = Lib:GetMaxTimeFrame(self.tbBossInfo);
    return szTimeFrame;
end  

function KinNest:GetKinNestState(nKinId)
    local tbData = self:GetKinNestData(nKinId);
    if not tbData then
        return;
    end
    return tbData.nOpenState;
end

function KinNest:GetRobberNpcs(nKinId,nNpcNumber)
    local tbKinInfor = self:GetKinNestInfor(nKinId);
    local nNpcCount = nNpcNumber;
    local nNpcLevel = tbKinInfor.nNpcLevel;

    if nNpcCount > #self.tbNpcSetting then
        nNpcCount = #self.tbNpcSetting;
    end

    local tbResult = {};
    local fnSelect = Lib:GetRandomSelect(#self.tbNpcSetting);
    for i = 1, nNpcCount do
        local tbNpcInfo = self.tbNpcSetting[fnSelect()];
        table.insert(tbResult, {
            tbDialogNpc = {
                tbNpcInfo.DialogNpc,
                nNpcLevel,
                tbNpcInfo.Series,
                tbKinInfor.nMapId,
                tbNpcInfo.PosX,
                tbNpcInfo.PosY,
            };

            tbFightNpc = {
                tbNpcInfo.FightNpc,
                nNpcLevel,
                tbNpcInfo.Series,
                tbKinInfor.nMapId,
                tbNpcInfo.PosX,
                tbNpcInfo.PosY,
            };
        });
    end

    return tbResult;
end

function KinNest:OnKinRobberActivate(pNpc, nTeamId, nKinId, pPlayer)
    local tbData = self:GetKinNestData(nKinId);
    if not tbData then
        Log("[x] KinNest:OnKinRobberActivate, no kin", tostring(nKinId), pPlayer.dwID)
        return false
    end
    if tbData.nOpenState ~= tbDef.nKinOpenStateOpen then
        return false;
    end
    local tbRobberData = self:GetKinNestInfor(nKinId);
    local tbDialogNpcInfo = tbRobberData.tbNpcInfo[pNpc.nId];
    if not tbDialogNpcInfo then
        return false;
    end

    for _, tbNpcInfo in pairs(tbRobberData.tbNpcInfo or {}) do
        if tbNpcInfo.nTeamId == nTeamId then
            if pPlayer then
                pPlayer.CenterMsg("一次只能打一個幫派盜賊");
            end

            return true;
        end
    end

    tbRobberData.tbNpcInfo[pNpc.nId] = nil;
    pNpc.Delete();

    local pFightNpc = KNpc.Add(unpack(tbDialogNpcInfo.tbFightNpc));
    if pFightNpc then
        tbRobberData.tbNpcInfo[pFightNpc.nId] = {
            nTeamId = nTeamId;
        }
        pFightNpc.nRobberKinId = self.nKinId;
    end

    return true;
end

function KinNest:OnUpateKinNestUi(nKinId, nNpcNumber, nOpenTime, bOutPlayer, nState, nValue)
    local tbRobberData = self:GetKinNestInfor(nKinId);
    local nLastTime     = tbDef.ActivityTime - GetTime() + nOpenTime
    local tbAllPlayer   = KPlayer.GetMapPlayer(tbRobberData.nMapId);
    local  tbDate = {
        nNpcNumber = nNpcNumber;
        nLastTime = nLastTime;
        nPlayerNumber = #tbAllPlayer;
    };
    if nState == 2 then
        tbDate.bBossNumber = true;
        tbDate.nBossNumber = nValue;
    end

    if nState == 3 then
        tbDate.bFireTimer = true;
        tbDate.nFireTimer = nValue;
    end


    if bOutPlayer == true then
        tbDate.nPlayerNumber = tbDate.nPlayerNumber - 1;
    end

    --[[
    for _, pKinNester in pairs(tbAllPlayer) do
        pKinNester.CallClientScript("Ui:OpenWindow", "KinNestDisplay", tbDate);
    end
    ]]
end

function KinNest:NotifyRobberPos(nKinId)
    local tbRobberData = self:GetKinNestInfor(nKinId);
    local tbPos = {};
    for nNpcId, _ in pairs(tbRobberData.tbNpcInfo) do
        local pNpc = KNpc.GetById(nNpcId);
        if pNpc then
            local _, nX, nY = pNpc.GetWorldPos();
            table.insert(tbPos, {nX, nY});
        end
    end

    local tbBossInfo =  self:GetBossInfo(nKinId);
    for nId, tbDate in pairs(tbBossInfo) do
        table.insert(tbPos, {tbDate[1], tbDate[2]});
    end
    local tbMemberList = Kin:GetKinMembers(nKinId);

    for nMemberId, nCareer in pairs(tbMemberList) do
        local player = KPlayer.GetPlayerObjById(nMemberId);
        if player then
            player.CallClientScript("Map:OnSyncNpcsPos", "Robber", tbPos);
        end
    end
end

function KinNest:NotifyBonfirePos(nKinId,nX,nY)
    local tbPos = {};

    if nX and nY then
        table.insert(tbPos, {nX, nY});
    end
    
    local tbMemberList = Kin:GetKinMembers(nKinId);
    for nMemberId, nCareer in pairs(tbMemberList) do
        local player = KPlayer.GetPlayerObjById(nMemberId);
        if player then
            player.CallClientScript("Map:OnSyncNpcsPos", "Bonfire", tbPos);
        end
    end
end

function KinNest:ActivityCalendarInterface(nPlayerId)
    local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
    if not pPlayer then
        return
    end
    local nState = self:GetKinNestState(pPlayer.dwKinId);
    if nState == tbDef.nKinOpenStateWait then
        local tbMemberList = Kin:GetKinMembers(pPlayer.dwKinId) 
        if tbMemberList[pPlayer.dwID] ~= Kin.Def.Career_ViceMaster and tbMemberList[pPlayer.dwID] ~= Kin.Def.Career_Master then
            self:ApplyOpenKinNest(pPlayer);
        else
            self:JumpInKin(pPlayer);
        end
    end

    if nState == tbDef.nKinOpenStateOpen then
        self:EnterKinNest(nPlayerId);
    end
end

function KinNest:JumpInKin(pPlayer)
    local KinData =  Kin:GetKinById(pPlayer.dwKinId);
    pPlayer.CallClientScript("Kin:GoKinMap");
    KinData:CallWithMap(function ()
        local nMapId = KinData:GetMapId();
        if nMapId > 0 then
            pPlayer.CallClientScript("Ui.HyperTextHandle:Handle", "[url=npc:KinManager, 266,1004]");
        end 
    end);
end