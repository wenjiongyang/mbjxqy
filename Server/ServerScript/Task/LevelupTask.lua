Task.LevelupTask = Task.LevelupTask or {};
local LevelupTask = Task.LevelupTask;

function LevelupTask:LoadLevelupTask()
	local tbFile = LoadTabFile("Setting/Task/LevelupTask.tab", "dddd", nil, {"nLevel", "nFaction", "nTaskId", "bLoginCheck"});
	self.tbLevelupTask = {};
	for _, tbRow in pairs(tbFile) do
		self.tbLevelupTask[tbRow.nLevel] = self.tbLevelupTask[tbRow.nLevel] or {};
		if tbRow.nTaskId > 0 then
			table.insert(self.tbLevelupTask[tbRow.nLevel], {nTaskId = tbRow.nTaskId, nFaction = tbRow.nFaction, bLoginCheck = tbRow.bLoginCheck});
		end
	end
end
LevelupTask:LoadLevelupTask();

function LevelupTask:OnPlayerLevelup(nNewLevel)
	local tbTaskList = self.tbLevelupTask[nNewLevel];
	if not tbTaskList or not next(tbTaskList) then
		return;
	end

	for _, tbTaskInfo in ipairs(tbTaskList) do
		if tbTaskInfo.nFaction == 0 or tbTaskInfo.nFaction == me.nFaction then
			Task:TryAcceptTask(me, tbTaskInfo.nTaskId, me.GetNpc().nId);
		end
	end
end

function LevelupTask:OnPlayerLogin()
	local nPlayerLevel = me.nLevel;
	local nPlayerFaction = me.nFaction;
	local tbTaskList = {};
	for nLevel, tbTaskInfo in pairs(self.tbLevelupTask) do
		for _, tbInfo in pairs(tbTaskInfo) do
			if nLevel <= nPlayerLevel and tbInfo.bLoginCheck == 1 and (tbInfo.nFaction == 0 or tbInfo.nFaction == nPlayerFaction) then
				tbTaskList[tbInfo.nTaskId] = true;
			end
		end
	end

	for nTaskId in pairs(tbTaskList) do
		if not Task:GetPlayerTaskInfo(me, nTaskId)
			and Task:GetTaskFlag(me, nTaskId) ~= 1 then

			Task:TryAcceptTask(me, nTaskId, me.GetNpc().nId);
		end
	end
end

if not MODULE_ZONESERVER then
	PlayerEvent:RegisterGlobal("OnLogin",                       LevelupTask.OnPlayerLogin, LevelupTask);
end

PlayerEvent:RegisterGlobal("OnLevelUp",                     LevelupTask.OnPlayerLevelup,	LevelupTask);

