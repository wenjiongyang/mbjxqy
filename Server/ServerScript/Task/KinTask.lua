Task.KinTask = Task.KinTask or {};
local KinTask = Task.KinTask;

function KinTask:TryAcceptTask(nPlayerId, nLastTaskId)
	if not self:CheckOpen() then
		return;
	end

	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end

	local bRet, nTaskType, nTaskIdx = self:CheckCanAcceptTask(pPlayer);
	if not bRet then
		return;
	end

	local tbTaskInfo = self.tbType2Task[nTaskType];
	local nNewTaskId = 0;
	for i = 1, 5 do
		local nRandom = MathRandom(#tbTaskInfo);
		nNewTaskId = tbTaskInfo[nRandom];
		if nNewTaskId ~= nLastTaskId then
			break;
		end
	end

	Task:DoTaskNextStep(pPlayer, pPlayer.GetNpc().nId, nNewTaskId);
	Log("[KinTask] accept task", pPlayer.szAccount, pPlayer.dwID, pPlayer.szName, nTaskIdx, nNewTaskId);
end

function KinTask:OnFinishTask(nTaskId, nNpcId)
	if not self:CheckOpen() or not self.tbTask2Type[nTaskId] then
		return;
	end

	local _, nCurTaskIdx = self:GetTaskInfo(me);
	local bRet = DegreeCtrl:ReduceDegree(me, KinTask.DEGREE_TYPE, 1);
	if not bRet then
		return;
	end

	local nAwardIdx = KinTask.tbTaskInfo[nCurTaskIdx][2];
	local tbKinData = Kin:GetKinById(me.dwKinId);
	if tbKinData then
		tbKinData:OnFinishKinTask();
	end

	Achievement:AddCount(me, "KinTask_1", 1);
	me.SendAward(KinTask.tbAwardList[nAwardIdx], true, false, Env.LogWay_KinTaskOnFinish);
	Log("[KinTask] finish task", me.szAccount, me.dwID, me.szName, nCurTaskIdx, nTaskId);

	self:TryAcceptTask(me.dwID, nTaskId);
end


PlayerEvent:RegisterGlobal("FinishTask",                   KinTask.OnFinishTask, KinTask);