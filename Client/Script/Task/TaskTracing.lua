Task.emTASKTYPE_DAILY = 1
Task.emTASKTYPE_SUB = 2
function Task:OnTaskUpdate(nTaskId)
  if not nTaskId then
    return
  end
  local tbTask = self.tbDailyTaskSettings[self.emDAILY_COMMERCE]
  local bNormal = false
  if nTaskId == tbTask.nTaskId then
    if not tbTask.IsInCurTaskList() then
      return
    end
  elseif nTaskId == ActivityQuestion.TASK_ID then
    if not ActivityQuestion:IsTaskDoing() then
      return
    end
  else
    local _, _, nIdx = self:GetPlayerTaskInfo(me, nTaskId)
    if not nIdx then
      return
    end
    bNormal = true
  end
  self:PushUpdatingTask(nTaskId, bNormal)
  self:SetLatelyTask({
    self.emTASKTYPE_SUB,
    nTaskId
  })
end
local szRecentTaskList = "UpdatingTaskList_TaskId"
function Task:PushUpdatingTask(nTaskId, bNormal)
  if bNormal then
    local tbTask = Task:GetTask(nTaskId)
    if tbTask.nTaskType == self.TASK_TYPE_MAIN or tbTask.nTaskType == self.TASK_TYPE_DAILY then
      return
    end
  end
  local tbTask = Client:GetUserInfo(szRecentTaskList)
  for i, nId in ipairs(tbTask) do
    if nId == nTaskId then
      table.remove(tbTask, i)
      break
    end
  end
  table.insert(tbTask, 1, nTaskId)
  Client:SaveUserInfo()
end
function Task:GetUpdatingTask()
  local tbTask = Client:GetUserInfo(szRecentTaskList)
  local tbUpdating = {}
  for i = #tbTask, 1, -1 do
    local szTitle, szDesc = self:GetTaskDesc(tbTask[i])
    if szTitle and szDesc then
      table.insert(tbUpdating, 1, {
        tbTask[i],
        szTitle,
        szDesc
      })
    else
      table.remove(tbTask, i)
    end
  end
  Client:SaveUserInfo()
  return tbUpdating, tbTask
end
function Task:UpdateTracingList()
  local _, tbTask = self:GetUpdatingTask()
  local tbTaskId = {}
  for _, nTaskId in ipairs(tbTask) do
    tbTaskId[nTaskId] = true
  end
  for _, tbInfo in pairs(self.tbDailyTaskSettings) do
    if not tbTaskId[tbInfo.nTaskId] and tbInfo.IsInCurTaskList() then
      table.insert(tbTask, tbInfo.nTaskId)
    end
  end
  local tbMyTask = self:GetPlayerTaskInfo(me)
  local tbMyTaskId = {}
  for _, tbCurTask in pairs(tbMyTask.tbCurTaskInfo) do
    local tbTaskInfo = Task:GetTask(tbCurTask.nTaskId)
    if not tbTaskId[tbCurTask.nTaskId] and tbTaskInfo.nTaskType ~= self.TASK_TYPE_MAIN then
      table.insert(tbMyTaskId, tbCurTask.nTaskId)
    end
  end
  table.sort(tbMyTaskId, function(a, b)
    return b < a
  end)
  Lib:MergeTable(tbTask, tbMyTaskId)
  Client:SaveUserInfo()
  UiNotify.OnNotify(UiNotify.emNOTIFY_UPDATE_TASK)
end
function Task:GetTaskDesc(nTaskId)
  if not nTaskId then
    return
  end
  local szTitle, szDesc = self:GetCommerceTaskInfo(nTaskId)
  if szTitle and szDesc then
    return szTitle, szDesc
  end
  szTitle, szDesc = self:GetActivityQuestionInfo(nTaskId)
  if szTitle and szDesc then
    return szTitle, szDesc
  end
  local _, _, nIdx = self:GetPlayerTaskInfo(me, nTaskId)
  if nIdx then
    local szTitle, szDesc = self:GetNormalTaskInfo(nTaskId)
    return szTitle, szDesc
  end
end
function Task:GetNormalTaskInfo(nTaskId)
  local tbTmpTask = self:GetTask(nTaskId)
  if not tbTmpTask then
    return
  end
  local szEndInfo = Task:GetTaskExtInfo(nTaskId)
  local nTaskState = self:GetTaskState(me, nTaskId, -1)
  local szDesc = nTaskState == Task.STATE_CAN_FINISH and tbTmpTask.szFinishDesc or tbTmpTask.szTaskDesc
  if nTaskId ~= 6002 then
    szDesc = szDesc .. szEndInfo
  end
  return tbTmpTask.szTaskTitle, szDesc
end
function Task:GetCommerceTaskInfo(nTaskId)
  local tbTaskInfo = self.tbDailyTaskSettings[self.emDAILY_COMMERCE]
  if nTaskId ~= tbTaskInfo.nTaskId then
    return
  end
  if tbTaskInfo.IsInCurTaskList() then
    return tbTaskInfo.szTitle, tbTaskInfo.szTarget
  end
end
function Task:GetActivityQuestionInfo(nTaskId)
  if nTaskId ~= ActivityQuestion.TASK_ID then
    return
  end
  if ActivityQuestion:IsTaskDoing() then
    local szTitle, szDesc = ActivityQuestion:GetCurQuestionDesc()
    return szTitle, szDesc
  end
end
function Task:TrackUpdatingTask(nTaskId)
  if not nTaskId then
    return
  end
  if CommerceTask:IsCommerceTask(nTaskId) then
    local tbDailyTask = Task.tbDailyTaskSettings[Task.szDailyDefaultKey]
    tbDailyTask.OnTrack()
  elseif ActivityQuestion:IsActQuesTask(nTaskId) then
    ActivityQuestion:OnTrack()
  else
    Task:OnTrack(nTaskId)
  end
end
function Task:IsCanSubmit(nTaskId)
  if not nTaskId then
    return
  end
  if CommerceTask:IsCommerceTask(nTaskId) or ActivityQuestion:IsActQuesTask(nTaskId) then
    return
  else
    local nTaskState = self:GetTaskState(me, nTaskId)
    return nTaskState == Task.STATE_CAN_FINISH
  end
end
local tbPreview = Lib:LoadTabFile("Setting/Task/TaskAwardPreview.tab", {
  TaskIdBegin = 1,
  TaskIdEnd = 1,
  ItemTemplateId = 1
})
function Task:GetAwardPreview(nTaskId)
  if not nTaskId then
    return
  end
  for _, tbInfo in ipairs(tbPreview) do
    if nTaskId >= tbInfo.TaskIdBegin and nTaskId <= tbInfo.TaskIdEnd then
      return tbInfo.TaskIdEnd - nTaskId, tbInfo.ItemTemplateId
    end
  end
end
function Task:OnTaskTimeout(tbNeedUpdate)
  for _, nTaskId in ipairs(tbNeedUpdate or {}) do
    self:UpdateTaskInfo(nTaskId)
  end
end
function Task:OnCommerceTaskUpdate()
  self:SetLatelyTask({
    self.emTASKTYPE_DAILY,
    self.emDAILY_COMMERCE
  })
end
local szRecentTask = "LatelyTask"
function Task:SetLatelyTask(tbTaskInfo)
  local tbTask = Client:GetUserInfo(szRecentTask)
  tbTask[1] = tbTaskInfo[1]
  tbTask[2] = tbTaskInfo[2]
  Client:SaveUserInfo()
end
function Task:GetLatelyTask()
  local tbTask = Client:GetUserInfo(szRecentTask)
  if tbTask and next(tbTask) then
    return {
      tbTask[1],
      tbTask[2]
    }
  end
end
