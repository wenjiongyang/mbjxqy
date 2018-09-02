
Require("ServerScript/Fuben/KinNest/KinNest.lua");
local tbFuben = Fuben:CreateFubenClass("KinNestFuben");
tbFuben.KinNest = Kin.KinNest;

function tbFuben:OnPreCreate(nKinID, nResidueNpcCount, dwOwnerId)
    self.nResidueNpcCount = nResidueNpcCount;
    self.nRemainNpcCount = self.nResidueNpcCount;
    self.nFubenKinID = nKinID;
    self.nStartTime = GetTime();
    self.bOpenFireUi = false;
    self.bOpenBossUi = false;
    self.dwOwnerId = dwOwnerId;
    self.nBossLastNumber = Kin.KinNest.tbDefault.nBossNumber;
    Log("KinNestFuben OnPreCreate", nKinID, nResidueNpcCount);
end

function tbFuben:OnOpenOwnerInvitePanel()
    
end

function tbFuben:OnJoin(pPlayer)
    pPlayer.CallClientScript("Ui:OpenWindow", "HomeScreenFuben", "KinNest")
    self:SetShowTime(10)
    if self.bOpenFireUi then
        Kin.KinNest:OnUpateKinNestUi(self.nFubenKinID, self.nRemainNpcCount, self.nStartTime, false, 3, Kin.KinNest.tbDefault.nFrieTime);
    end 
    if self.bOpenBossUi then 
         Kin.KinNest:OnUpateKinNestUi(self.nFubenKinID, self.nRemainNpcCount, self.nStartTime, false, 2, Kin.KinNest.tbDefault.nBossNumber);
    end
    Kin.KinNest:OnUpateKinNestUi(self.nFubenKinID, self.nRemainNpcCount, self.nStartTime);
    Kin.KinNest:NotifyRobberPos(self.nFubenKinID);

    LogD(Env.LOGD_ActivityPlay, pPlayer.szAccount, pPlayer.dwID, pPlayer.nLevel, 0, Env.LOGD_VAL_TAKE_TASK, Env.LOGD_MIS_KINNEST, pPlayer.GetFightPower());  
end

function tbFuben:GameLost()
    local fnExcute = function (pPlayer)
        pPlayer.SendBlackBoardMsg("俠客島存在時間已結束");
        pPlayer.GotoEntryPoint();
    end
    self:AllPlayerExcute(fnExcute);
end

function tbFuben:OnAddKinRobberNpc(nLock)
    self.nLock = nLock;
    if self.nResidueNpcCount >= 25 then
        local tbNpcData = Kin.KinNest:GetRobberNpcs(self.nFubenKinID,25);

        Kin.KinNest:CleanNpcInfo(self.nFubenKinID);
        local tbNpcInfo =  Kin.KinNest:GetNpcInfo(self.nFubenKinID);
        for _, tbInfo in pairs(tbNpcData) do
            local pNpc = KNpc.Add(unpack(tbInfo.tbDialogNpc))
            if pNpc then
                tbNpcInfo[pNpc.nId] = {
                    tbFightNpc = tbInfo.tbFightNpc;
                }
                pNpc.nRobberKinId = self.nFubenKinID;
            end
        end
        self.nResidueNpcCount = self.nResidueNpcCount - 25;
    elseif self.nResidueNpcCount > 0 then
        local tbNpcData = Kin.KinNest:GetRobberNpcs(self.nFubenKinID,self.nResidueNpcCount);
        Kin.KinNest:CleanNpcInfo(self.nFubenKinID);
        local tbNpcInfo =  Kin.KinNest:GetNpcInfo(self.nFubenKinID);
        for _, tbInfo in pairs(tbNpcData) do
            local pNpc = KNpc.Add(unpack(tbInfo.tbDialogNpc))
            if pNpc then
                tbNpcInfo[pNpc.nId] = {
                    tbFightNpc = tbInfo.tbFightNpc;
                }
                pNpc.nRobberKinId = self.nFubenKinID;
            end
        end
        self.nResidueNpcCount = 0;
    else
        self:UnLock(self.nLock);
    end

    Kin.KinNest:NotifyRobberPos(self.nFubenKinID);
end

function tbFuben:OnAddKinRobberBoss(nIndex, nNum, nLock, szGroup, szPointName, bRevive, nDir, nDealyTime, nEffectId, nEffectTime)
    self:_AddNpc(nIndex, nNum, nLock, szGroup, szPointName, bRevive, nDir, nDealyTime, nEffectId, nEffectTime,szPointName);
end

function tbFuben:OnSendBossReward()
	tbFuben.KinNest:SendBossReward(self.nFubenKinID);
end

function tbFuben:OnLastRewards()
	tbFuben.KinNest:SendLastReward(self.nFubenKinID);
    tbFuben.KinNest:EndKinNest(self.nFubenKinID);
end


function tbFuben:OnEndKinNest(szTrapName,nNpcId,nX,nY)
    local tbRobberData = tbFuben.KinNest:GetKinNestInfor(self.nFubenKinID);
    self:ChangeTrap(szTrapName, nil, nil, nil, nil, "LeaveKinNest");
    KNpc.Add(nNpcId, 1, 0, tbRobberData.nMapId, nX, nY);
    tbFuben.KinNest:NotifyBonfirePos(self.nFubenKinID);
	--tbFuben.KinNest:EndKinNest(self.nFubenKinID);
end

function tbFuben:OnLeaveKinNest()
    tbFuben.KinNest:OnLeaveKinNest(me);
end

function tbFuben:OnUpateKinNestUiBoss()
    self.bOpenFireUi = false;
    self.bOpenBossUi = true;
    Kin.KinNest:OnUpateKinNestUi(self.nFubenKinID, self.nRemainNpcCount, self.nStartTime, false, 2, Kin.KinNest.tbDefault.nBossNumber);
end

function tbFuben:OnUpateKinNestUiFire()
    tbFuben.KinNest:NotifyBonfirePos(self.nFubenKinID,8264,5179);
    self.bOpenFireUi = true;
    self.bOpenBossUi = false;
    Kin.KinNest:OnUpateKinNestUi(self.nFubenKinID, self.nRemainNpcCount, self.nStartTime, false, 3, Kin.KinNest.tbDefault.nFrieTime);
end

function tbFuben:OnKillNpc(pNpc, pKiller)
    local tbRobberData = tbFuben.KinNest:GetKinNestInfor(self.nFubenKinID);
    local tbFightNpcInfo = tbRobberData.tbNpcInfo[pNpc.nId];

    if not tbFightNpcInfo then
        self.nBossLastNumber = self.nBossLastNumber - 1;
        Kin.KinNest:OnUpateKinNestUi(self.nFubenKinID, self.nRemainNpcCount, self.nStartTime, false, 2, self.nBossLastNumber);
        tbFuben.KinNest:SendBossReward(self.nFubenKinID);

        local tbBossInfo =  Kin.KinNest:GetBossInfo(self.nFubenKinID);
        tbBossInfo[pNpc.nId] = nil;

        Kin.KinNest:NotifyRobberPos(self.nFubenKinID);
        return;
    end
    tbRobberData.tbNpcInfo[pNpc.nId] = nil;

    local team = tbFightNpcInfo.nTeamId and TeamMgr:GetTeamById(tbFightNpcInfo.nTeamId);
    if team then
        local tbTeamMembers = team:GetMembers();
        for _, nMemberId in pairs(tbTeamMembers) do
            local kinMember = Kin:GetMemberData(nMemberId);
            if kinMember then
                kinMember:SendKillRobberReward();
            end
        end
    end
    if Lib:CountTB(tbRobberData.tbNpcInfo) == 0 then
        self:UnLock(self.nLock);
        self.bGateOpened = false;
    end
    -- 击杀盗贼者与所在队伍好友,亲密度加50
    --local killer = KPlayer.GetPlayerObjById(pKiller.nPlayerID) or {};

    local killer = KPlayer.GetPlayerObjById(pKiller.nPlayerID) or {};

    Achievement:AddCount(killer, "FamilyRobber_1");
    local tbTeamMembers = TeamMgr:GetMembers(killer.dwTeamID or 0);
    for _, nPlayerID in pairs(tbTeamMembers) do
        if nPlayerID ~= pKiller.nPlayerID then
            FriendShip:AddImitityByKind(nPlayerID, pKiller.nPlayerID, Env.LogWay_KinRobber);
        end
    end
    self.nRemainNpcCount = self.nRemainNpcCount - 1;
    Kin.KinNest:OnUpateKinNestUi(self.nFubenKinID, self.nRemainNpcCount, self.nStartTime);
    Kin.KinNest:NotifyRobberPos(self.nFubenKinID);
end

function tbFuben:OnOut(pPlayer)
    Kin.KinNest:OnUpateKinNestUi(self.nFubenKinID, self.nRemainNpcCount, self.nStartTime,true);
    pPlayer.CallClientScript("Ui:CloseWindow", "HomeScreenFuben");
    pPlayer.CallClientScript("Ui:CloseWindow", "KinNestDisplay");
end

function tbFuben:OnPlayerDeath()
    me.Revive(0);
    me.AddSkillState(Fuben.RandomFuben.DEATH_SKILLID, 1, 0, 10000);
    me.nFightMode = 2;
    Timer:Register(Kin.KinNest.tbDefault.nReviveTime * Env.GAME_FPS, self.DoRevive, self, me.dwID);
    --客户端显示一个倒计时 todo
end

function tbFuben:ClearDeathState(pPlayer)
    pPlayer.RemoveSkillState(Fuben.RandomFuben.DEATH_SKILLID);
    pPlayer.nFightMode = 1;
end

function tbFuben:DoRevive(nPlayerId)
    local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
    if not pPlayer then

        return;
    end

    if pPlayer.nFightMode ~= 2 then
        return;
    end

    if self.tbSetting.tbBeginPoint then
        pPlayer.SetPosition(unpack(self.tbSetting.tbBeginPoint));
    end
    self:ClearDeathState(pPlayer);
end


function tbFuben:OnAddNpc(pNpc,szPointName)
    if not szPointName then
        return;
    end
    local tbNpcPoint = self.tbNpcPoint[szPointName];
    local tbBossInfo =  Kin.KinNest:GetBossInfo(self.nFubenKinID);
    tbBossInfo[pNpc.nId] = {tbNpcPoint[1][1],tbNpcPoint[1][2]}
    Kin.KinNest:NotifyRobberPos(self.nFubenKinID);
end
