local tbAct          = Activity:GetClass("DaiYanRenAct")
tbAct.tbTimerTrigger = {}
tbAct.tbTrigger      = { 
    Init    = { }, 
    Start   = { }, 
    End     = { }, 
    SendNews= { };
}
tbAct.LEVEL = 40
tbAct.IMITITY_LV = 5

tbAct.GROUP   = 73
tbAct.VERSION = 1
tbAct.LOVER   = 2

tbAct.tbNpcTask = {
    [2326] = {nTaskId = 6023, nMapTID = 1618},
    [89]   = {nTaskId = 6027, nMapTID = 1619},
    [99]   = {nTaskId = 6030, nMapTID = 1620},
    [625]  = {nTaskId = 6033, nMapTID = 1621},
    [2279] = {nTaskId = 6036, nMapTID = 1623},
}
tbAct.START_TASK = 6020

function tbAct:OnTrigger(szTrigger)
    local fn = self["On" .. szTrigger]
    if not fn then
        return
    end

    fn(self)
end

function tbAct:OnStart()
    self.tbMap4Task = {}
    for nNpcTID, tbInfo in pairs(self.tbNpcTask) do
        local nTaskId = tbInfo.nTaskId
        local nMapTID = tbInfo.nMapTID
        self.tbMap4Task[nMapTID] = nTaskId
        Activity:RegisterNpcDialog(self, nNpcTID, {Text = "前往線索指向之地", Callback = self.TryEnterFuben, Param = {self, nTaskId, nMapTID}})
    end
    Activity:RegisterNpcDialog(self, 99, {Text = "報名參加新心相映活動", Callback = self.TryApply, Param = {self}})
    Activity:RegisterPlayerEvent(self, "DYRAct_TryAgreeApply", "TryAgreeApply")
    Activity:RegisterPlayerEvent(self, "DYRAct_TryAgreeEnterFuben", "TryAgreeEnterFuben")
    Activity:RegisterPlayerEvent(self, "Act_OnAcceptTask", "OnAcceptTask")
    Activity:RegisterGlobalEvent(self, "DYRAct_TryCompleteFuben", "OnFubenSuccess")
end

function tbAct:OnEnd()
    local tbPlayerList = KPlayer.GetAllPlayer()
    for _, pPlayer in ipairs(tbPlayerList) do
        Task:CheckTaskValidTime(pPlayer)
    end
end

function tbAct:OnAcceptTask(pPlayer, nTaskId)
    --第一次开活动时参数还没填，所以这里做个保护
    local nBeginTask = tonumber(self.tbParam[1]) or 6020
    local nEndTask = tonumber(self.tbParam[2]) or 6037
    if not nTaskId or nTaskId < nBeginTask or nTaskId > nEndTask then
        return
    end
    local _, nEndTime = self:GetOpenTimeInfo()
    Task:SetValidTime2Task(pPlayer, nTaskId, nEndTime)
end

function tbAct:CheckTeam(pPlayer)
    if not pPlayer.dwTeamID or pPlayer.dwTeamID == 0 then
        return false, "你還沒有隊伍"
    end

    local tbMember = TeamMgr:GetMembers(pPlayer.dwTeamID)
    if #tbMember ~= 2 then
        return false, "必須與[FFFE0D]報名時的異性好友結成2人組隊[-]"
    end

    local dwMember = tbMember[1] == pPlayer.dwID and tbMember[2] or tbMember[1]
    local pMember = KPlayer.GetPlayerObjById(dwMember)
    if not pMember then
        return false, "沒找到隊友"
    end

    if Gift:CheckSex(pPlayer.nFaction) == Gift:CheckSex(pMember.nFaction) or not FriendShip:IsFriend(pPlayer.dwID, dwMember) then
        return false, "你與對方並非異性的好友，請確認後在進行嘗試哦"
    end

    if FriendShip:GetFriendImityLevel(pPlayer.dwID, pMember.dwID) < self.IMITITY_LV then
        return false, string.format("雙方親密度等級需達到%d級", self.IMITITY_LV)
    end

    local nMapId1 = pPlayer.GetWorldPos()
    local nMapId2 = pMember.GetWorldPos()
    if nMapId1 ~= nMapId2 or pPlayer.GetNpc().GetDistance(pMember.GetNpc().nId) > Npc.DIALOG_DISTANCE * 3 then
        return false, "距離太遠了，與你的隊伍成員必須在一定範圍內哦"
    end

    return true, nil, pMember
end

function tbAct:CheckApply(pPlayer)
    if pPlayer.nLevel < self.LEVEL then
        return false, "你等級不足"
    end
    self:CheckPlayerData(pPlayer)
    if pPlayer.GetUserValue(self.GROUP, self.LOVER) > 0 then
        return false, "你已報名"
    end

    local bRet, szMsg, pTeammate = self:CheckTeam(pPlayer)
    if not bRet then
        return false, szMsg
    end

    if pTeammate.nLevel < self.LEVEL then
        return false, "隊友等級不足"
    end
    self:CheckPlayerData(pTeammate)
    if pTeammate.GetUserValue(self.GROUP, self.LOVER) > 0 then
        return false, "隊友已經和他人報名"
    end
    return true, nil, pTeammate
end

function tbAct:CheckPlayerData(pPlayer)
    local nGroup     = self.GROUP
    local nVersion   = self.VERSION
    local nStartTime = self:GetOpenTimeInfo()
    if pPlayer.GetUserValue(nGroup, nVersion) == nStartTime then
        return
    end

    pPlayer.SetUserValue(nGroup, nVersion, nStartTime)
    pPlayer.SetUserValue(nGroup, self.LOVER, 0)
end

function tbAct:TryApply()
    local pPlayer = me
    local bRet, szMsg, pTeammate = self:CheckApply(pPlayer)
    if not bRet then
        pPlayer.CenterMsg(szMsg or "")
        return
    end

    pTeammate.CallClientScript("Activity.DaiYanRen:OnGetInvite", "DYRAct_TryAgreeApply", pPlayer.dwID, pPlayer.szName)
end

function tbAct:TryAgreeApply(pPlayer, dwApply, bAgree)
    if not bAgree then
        local pTeammate = KPlayer.GetPlayerObjById(dwApply)
        if pTeammate then
            pTeammate.CenterMsg("對方拒絕了你的邀請")
        end
        return
    end

    local bRet, szMsg, pTeammate = self:CheckApply(pPlayer)
    if not bRet then
        pPlayer.CenterMsg(szMsg or "")
        return
    end

    if pTeammate.dwID ~= dwApply then
        pPlayer.CenterMsg("邀請已過期")
        return
    end

    pPlayer.SetUserValue(self.GROUP, self.LOVER, dwApply)
    pTeammate.SetUserValue(self.GROUP, self.LOVER, pPlayer.dwID)

    Task:ForceAcceptTask(pPlayer, self.START_TASK)
    Task:ForceAcceptTask(pTeammate, self.START_TASK)
    pPlayer.CallClientScript("Activity:CheckRedPoint")
    pTeammate.CallClientScript("Activity:CheckRedPoint")
    local szMsg = "已成功報名參加活動，請將[FFFE0D]左側按鈕[-]切換至[FFFE0D]任務[-]開始進行活動"
    pPlayer.CenterMsg(szMsg)
    pTeammate.CenterMsg(szMsg)
    Log("DaiYanRenAct MakeTeam:", pPlayer.dwID, pTeammate.dwID)
end

local function fnAllMember(tbMember, fnSc, ...)
    for _, nPlayerId in ipairs(tbMember or {}) do
        local pMember = KPlayer.GetPlayerObjById(nPlayerId)
        if pMember then
            fnSc(pMember, ...);
        end
    end
end

function tbAct:CheckFuben(pPlayer, nTaskId)
    self:CheckPlayerData(pPlayer)
    if pPlayer.GetUserValue(self.GROUP, self.LOVER) == 0 then
        return false, "隊伍中有人尚未報名"
    end

    local bRet, szMsg, pTeammate = self:CheckTeam(pPlayer)
    if not bRet then
        return bRet, szMsg
    end

    for _, pCheck in ipairs({pPlayer, pTeammate}) do
        local nState = Task:GetTaskState(pCheck, nTaskId)
        if nState ~= Task.STATE_ON_DING then
            return false, "必須兩人均進行到任務同一步驟才能夠繼續進行"
        end
    end

    self:CheckPlayerData(pTeammate)
    if pTeammate.GetUserValue(self.GROUP, self.LOVER) == 0 then
        return false, "隊友尚未報名"
    end

    if pPlayer.GetUserValue(self.GROUP, self.LOVER) ~= pTeammate.dwID or 
        pTeammate.GetUserValue(self.GROUP, self.LOVER) ~= pPlayer.dwID then
        return false, "隊伍成員並非與你一同報名的異性好友"
    end

    for _, pCheck in ipairs({pPlayer, pTeammate}) do
        if not Env:CheckSystemSwitch(pCheck, Env.SW_SwitchMap) then
            return false, "目前狀態不允許切換地圖"
        end

        if not Fuben.tbSafeMap[pCheck.nMapTemplateId] and Map:GetClassDesc(pCheck.nMapTemplateId) ~= "fight" then
            return false, "所在地圖不允許進入副本！";
        end

        if Map:GetClassDesc(pCheck.nMapTemplateId) == "fight" and pCheck.nFightMode ~= 0 then
            return false, "非安全區不允許進入副本！";
        end
    end
    return true, nil, pTeammate
end

function tbAct:TryEnterFuben(nTaskId, nMapTID)
    local pPlayer = me
    if not nTaskId then
        return
    end

    local bRet, szMsg, pTeammate = self:CheckFuben(pPlayer, nTaskId)
    if not bRet then
        pPlayer.CenterMsg(szMsg)
        return
    end

    pTeammate.CallClientScript("Activity.DaiYanRen:OnGetInvite", "DYRAct_TryAgreeEnterFuben", pPlayer.dwID, pPlayer.szName, nTaskId, nMapTID)
end

function tbAct:TryAgreeEnterFuben(pPlayer, dwApply, bAgree, tbParam)
    if not bAgree then
        local pTeammate = KPlayer.GetPlayerObjById(dwApply)
        if pTeammate then
            pTeammate.CenterMsg("對方拒絕了你的邀請")
        end
        return
    end

    local nTaskId, nMapTID = unpack(tbParam)
    local bRet, szMsg, pTeammate = self:CheckFuben(pPlayer, nTaskId)
    if not bRet then
        pPlayer.CenterMsg(szMsg)
        return
    end

    if pTeammate.dwID ~= dwApply then
        pPlayer.CenterMsg("邀請已過期")
        return
    end


    local nP1ID, nP2ID = pPlayer.dwID, pTeammate.dwID
    local tbMember = {nP1ID, nP2ID}
    local function fnSuccessCallback(nMapId)
        local function fnSucess(pPlayer, nMapId)
            pPlayer.SetEntryPoint()
            pPlayer.SwitchMap(nMapId, 0, 0)
        end
        fnAllMember(tbMember, fnSucess, nMapId)
    end

    local function fnFailedCallback()
        fnAllMember(tbMember, function (pPlayer)
            pPlayer.CenterMsg("創建副本失敗，請稍後嘗試！")
        end)
    end

    Fuben:ApplyFuben(nP1ID, nMapTID, fnSuccessCallback, fnFailedCallback, nP1ID, nP2ID, nMapTID)
end

function tbAct:OnFubenSuccess(tbPlayer, nMapTID)
    local dwPlayer1, dwPlayer2 = unpack(tbPlayer or {})
    if not dwPlayer1 or not dwPlayer2 then
        return
    end

    local pPlayer1 = KPlayer.GetPlayerObjById(dwPlayer1)
    local pPlayer2 = KPlayer.GetPlayerObjById(dwPlayer2)
    if not pPlayer1 or not pPlayer2 then
        return
    end

    Task:OnTaskExtInfo(pPlayer1, Task.ExtInfo_DaiYanRenAct)
    Task:OnTaskExtInfo(pPlayer2, Task.ExtInfo_DaiYanRenAct)
    Log("DaiYanRenAct CompleteFuben:", dwPlayer1, dwPlayer2, nMapTID)
end