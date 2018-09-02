
local tbNpc = Npc:GetClass("PunishTaskAttack");

function tbNpc:OnDeath()
    if not him then
        return;
    end

    local tbPunishTaskInfo = him.tbPunishTaskInfo;
    if not tbPunishTaskInfo then
        Log("Error PunishTask OnDeath Not Data", him.nTemplateId);
        return;
    end

    PunishTask:RemoveMapNpcInfo(tbPunishTaskInfo.nMapID, tbPunishTaskInfo.nIdex);
    PunishTask:StartTimerRebirthNpc(tbPunishTaskInfo.nMapID);

    if not tbPunishTaskInfo.nTeamId then
        return;
    end

    local tbTeam  = TeamMgr:GetTeamById(tbPunishTaskInfo.nTeamId);
    if not tbTeam then
        return;
    end

    local nCaptainID = tbTeam:GetCaptainId();
    local tbMember  = tbTeam:GetMembers();
    local tbAllMember = {};
    local tbNpcInfo = tbPunishTaskInfo.tbNpcInfo;
    for _, nPlayerID in pairs(tbMember) do
        self:SendPlayerAward(nPlayerID, tbNpcInfo, tbPunishTaskInfo, nCaptainID);
        table.insert(tbAllMember, nPlayerID);
    end
    FriendRecall:OnPunishTaskAward(tbMember);
    Activity:OnGlobalEvent("Act_OnJoinTeamActivity", tbMember, Env.LogWay_PunishTask)

    local nTotalCount = #tbAllMember;
    if nTotalCount >= 2 then
        for nI = 1, nTotalCount - 1 do
            for nJ = nI + 1, nTotalCount do
                local nPlayer1 = tbAllMember[nI];
                local nPlayer2 = tbAllMember[nJ];
                FriendShip:AddImitityByKind(nPlayer1, nPlayer2, Env.LogWay_PunishTask);
            end    
        end
    end      
end 

function tbNpc:SendPlayerAward(nPlayerID, tbNpcInfo, tbPunishTaskInfo, nCaptainID)
    local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
    if not pPlayer then
        return;
    end

    if pPlayer.nLevel < PunishTask.nMinPlayerLevel then
        pPlayer.CenterMsg(string.format("等級不足%s級", PunishTask.nMinPlayerLevel), true);
        return;
    end  

    local nDegreeCount = DegreeCtrl:GetDegree(pPlayer, PunishTask.szDegreeName);
    local nShowCount = nDegreeCount - 1;
    if nShowCount <= 0 then
        nShowCount = 0;
    end    
    pPlayer.Msg(string.format("今日懲惡任務獎勵剩餘%s次", nShowCount));
    Dialog:SendBlackBoardMsg(pPlayer, string.format("今日懲惡任務獎勵剩餘%s次", nShowCount));
    if nDegreeCount <= 0 then
        return;
    end

    DegreeCtrl:ReduceDegree(pPlayer, PunishTask.szDegreeName, 1);
    EverydayTarget:AddCount(pPlayer, "PunishTask");    

    Achievement:AddCount(pPlayer, "PunishTask_1", 1);
    TeacherStudent:TargetAddCount(pPlayer, "ChengEr", 1)

    if nCaptainID ~= nPlayerID then
        PunishTask:SendMailAward(nPlayerID, tbNpcInfo.tbAward);
    else
        PunishTask:SendMailAward(nPlayerID, tbNpcInfo.tbCaptainAward);
        pPlayer.CenterMsg("隊長獎勵增加20%");    
    end

    LogD(Env.LOGD_ActivityPlay, pPlayer.szAccount, pPlayer.dwID, pPlayer.nLevel, 0, Env.LOGD_VAL_FINISH_TASK, Env.LOGD_MIS_PUNISH_TASK, nil);
    local tbLogData = 
    {
        Result = Env.LogRound_SUCCESS;
    }; 
    pPlayer.ActionLog(Env.LogType_Activity, Env.LogWay_PunishTask, tbLogData);     
end   