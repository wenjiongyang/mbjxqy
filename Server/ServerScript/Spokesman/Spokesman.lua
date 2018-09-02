Spokesman.TASK_ID = 6000
Spokesman.FINISH_TASKID = 6009
Spokesman.OPEN_LEVEL = 15
Spokesman.CLOSE_TIME = "2016/6/30" --结束时间，注意：不包括这天

function Spokesman:CheckCanAcceptTask(pPlayer)
    if pPlayer.nLevel < self.OPEN_LEVEL then
        return false, "等級不足"
    end

    if not self:IsInActivityTime() then
        return false, "不在活動時間內"
    end

    local bCanAccept, szMsg, _ = Task:CheckCanAcceptTask(me, self.TASK_ID, -1)
    return bCanAccept, szMsg
end

function Spokesman:TryAcceptTask(pPlayer, nNpcId)
    local bRet, szMsg = self:CheckCanAcceptTask(pPlayer)
    if not bRet then
        pPlayer.CenterMsg(szMsg)
        return
    end

    --如果已经完成了这个任务，任务系统会有相应处理
    bRet = Task:TryAcceptTask(pPlayer, self.TASK_ID, nNpcId)
    if not bRet then
        pPlayer.CenterMsg("任務接受失敗")
        return
    end
    Log("[Spokesman TryAcceptTask] Success", pPlayer.dwID, nNpcId, GetTime())
end

function Spokesman:IsInActivityTime()
    local nCloseTime = Lib:ParseDateTime(self.CLOSE_TIME)
    return GetTime() < nCloseTime
end

function Spokesman:OnNewDayBegin()
    if self:IsInActivityTime() then
        return
    end

    local tbPlayer = KPlayer.GetAllPlayer()
    for _, pPlayer in ipairs(tbPlayer) do
        if self:CheckAcceptedTask(pPlayer) then
            self:DeleteTask(pPlayer)
        end
    end
    Log("[Spokesman] DeleteTask")
end

function Spokesman:OnPlayerLogin(pPlayer)
    if self:CheckAcceptedTask(pPlayer) and not self:IsInActivityTime() then
        self:DeleteTask(pPlayer)
    end
end

function Spokesman:CheckAcceptedTask(pPlayer)
    local _1, _2, nIdx = Task:GetPlayerTaskInfo(pPlayer, self.TASK_ID)
    return nIdx
end

function Spokesman:DeleteTask(pPlayer)
    Task:ForceAbortTask(pPlayer, self.TASK_ID)
    Log("[Spokesman] DeletePlayerTask", pPlayer.dwID)
end

function Spokesman:OnPlayerFinishTask(nTaskId)
    if nTaskId ~= self.FINISH_TASKID then
        return
    end

    ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.System, me.szName .. "完成終於等到你，手牽紅線，助成挺哥、小緣天仙配！")
end
PlayerEvent:RegisterGlobal("FinishTask", Spokesman.OnPlayerFinishTask, Spokesman)