Require("CommonScript/Task/TaskCheckFunc.lua")
Task.tbAllTask = Task.tbAllTask or {}
Task.tbTaskAttachNpc = Task.tbTaskAttachNpc or {}
Task.nFirstTaskId = 1
Task.tbKillNpc = Task.tbKillNpc or {}
Task.TASK_TYPE_MAIN = 1
Task.TASK_TYPE_SUB = 2
Task.TASK_TYPE_DAILY = 3
Task.TASK_TYPE_VALUE_COMPOSE = 4
Task.tbExtTaskAward = {
  [43] = {
    {
      "Partner",
      96,
      1
    }
  }
}
Task.ExtInfo_JianDing = "JianDing"
Task.ExtInfo_TongBanDaShu = "TongBanDaShu"
Task.ExtInfo_YuanBaoZhaoMu = "YuanBaoZhaoMu"
Task.ExtInfo_TiShengZiZhi = "TiShengZiZhi"
Task.ExtInfo_ShanZeiMiKu = "ShanZeiMiKu"
Task.ExtInfo_DaTi = "DaTi"
Task.ExtInfo_BaiTan = "BaiTan"
Task.ExtInfo_ShangCheng = "ShangCheng"
Task.ExtInfo_TaskQuestion = "Task_DaTi"
Task.ExtInfo_ShangZhenTongBan = "ShangZhenTongBan"
Task.ExtInfo_TongBanJiaJingYan = "TongBanJiaJingYan"
Task.ExtInfo_JiangHuTrain = "JiangHuTrain"
Task.ExtInfo_UseFurniture = "UseFurniture"
Task.ExtInfo_DaiYanRenAct = "DaiYanRenAct"
Task.tbTrap2TrackInfo = Task.tbTrap2TrackInfo or {}
function Task:Init()
  local tbFileList = LoadTabFile("Setting/Task/TaskList.tab", "s", "TabFile", {"TabFile"})
  for szFilePath in pairs(tbFileList) do
    self:LoadTaskFile(szFilePath)
  end
  self:LoadTaskItem()
  Task.tbTrap2TrackInfo = {}
  local tbFile = LoadTabFile("Setting/Task/Trap2Track.tab", "dsds", nil, {
    "nMapTemplateId",
    "szTrap",
    "nTaskId",
    "szTrack"
  })
  for _, tbRow in pairs(tbFile or {}) do
    self.tbTrap2TrackInfo[tbRow.nMapTemplateId] = self.tbTrap2TrackInfo[tbRow.nMapTemplateId] or {}
    local szTrap = Lib:StrTrim(tbRow.szTrap)
    self.tbTrap2TrackInfo[tbRow.nMapTemplateId][szTrap] = self.tbTrap2TrackInfo[tbRow.nMapTemplateId][szTrap] or {}
    local tbInfo = self.tbTrap2TrackInfo[tbRow.nMapTemplateId][szTrap]
    assert(not tbInfo[tbRow.nTaskId], "load Trap2Track.tab fail !!")
    tbInfo[tbRow.nTaskId] = tbRow.szTrack
  end
end
function Task:CheckTaskInfo(tbRow, szIndex, value)
  local szCmdType = string.match(szIndex, "^Require_([^ ]+)$")
  if szCmdType and value ~= "" then
    if (szCmdType == "MinLevel" or szCmdType == "MaxLevel" or szCmdType == "FinishTask") and value == 0 then
      return
    end
    tbRow[szIndex] = nil
    tbRow.tbRequireInfo[szCmdType] = value
    return
  end
  szCmdType = string.match(szIndex, "^Target_([^ ]+)$")
  if szCmdType and value ~= "" and value ~= 0 then
    tbRow[szIndex] = nil
    local newValue = value
    if szCmdType == "KillNpc" then
      newValue = Lib:GetTableFromString(value)
      for nNpcTemplateId in pairs(newValue or {}) do
        self.tbKillNpc[nNpcTemplateId] = self.tbKillNpc[nNpcTemplateId] or 0
        if tbRow.bKillNpcToAllPlayer == 1 then
          self.tbKillNpc[nNpcTemplateId] = 1
        end
      end
    end
    if szCmdType == "PersonalFuben" then
      local tbInfo = Lib:SplitStr(value, "|")
      newValue = {}
      newValue.nSectionIdx = tonumber(tbInfo[1]) or 99999
      newValue.nSubSectionIdx = tonumber(tbInfo[2]) or 99999
      newValue.nFubenLevel = tonumber(tbInfo[3]) or 99999
    end
    if szCmdType == "Achievement" then
      newValue = Lib:SplitStr(value, "|")
      newValue[2] = tonumber(newValue[2]) or 1
    end
    if szCmdType == "CollectItem" then
      newValue = Lib:GetTableFromString(value)
    end
    if szCmdType == "MinLevel" then
      tbRow.nMinTargetLevel = newValue
    end
    if szCmdType == "OnTrap" then
      local tbInfo = Lib:SplitStr(value, "|")
      newValue = {}
      newValue.nMapTemplateId = tonumber(tbInfo[1])
      newValue.szTrap = tbInfo[2]
    end
    tbRow.tbTargetInfo[szCmdType] = newValue
    return
  end
  if szIndex == "ShowClientNpc" or szIndex == "DeleteClientNpc" then
    local tbInfo = Lib:SplitStr(value, "|")
    for _, szValue in ipairs(tbInfo) do
      local nValue = tonumber(szValue)
      if nValue then
        tbRow["tb" .. szIndex] = tbRow["tb" .. szIndex] or {}
        table.insert(tbRow["tb" .. szIndex], nValue)
      end
    end
  end
end
Task.tbCheckTargetFunc = {
  KillNpc = Task.CheckTargetKillNpc,
  CollectItem = Task.CheckTargetCollectItem,
  PersonalFuben = Task.CheckTargetPersonalFuben,
  MinLevel = Task.CheckTargetMinLevel,
  ExtPoint = Task.CheckTargetExtPoint,
  Achievement = Task.CheckTargetAchievement,
  OnTrap = Task.CheckTargetOnTrap,
  EnterMap = Task.CheckTargetEnterMap,
  ExtInfo = Task.CheckTargetExtInfo
}
Task.tbCheckRequireFunc = {
  MinLevel = Task.CheckRequireMinLevel,
  MaxLevel = Task.CheckRequireMaxLevel,
  FinishTask = Task.CheckRequireFinishTask
}
function Task:LoadTaskFile(szFilePath)
  local tbFileIdxInfo = {
    {"nTaskId", "d"},
    {
      "szTaskIndex",
      "s"
    },
    {
      "szTaskTitle",
      "s"
    },
    {
      "szDetailDesc",
      "s"
    },
    {"szTaskDesc", "s"},
    {
      "nAcceptDialogId",
      "d"
    },
    {
      "szFinishDesc",
      "s"
    },
    {
      "nFinishDialogId",
      "d"
    },
    {"nTaskType", "d"},
    {
      "szTrackInfo",
      "s"
    },
    {
      "szFinishTrackInfo",
      "s"
    },
    {"bCanRepeat", "d"},
    {
      "bClientAllow",
      "d"
    },
    {
      "nAutoNextTaskId",
      "d"
    },
    {
      "nAcceptTaskNpcId",
      "d"
    },
    {
      "nFinishTaskNpcId",
      "d"
    },
    {
      "Target_KillNpc",
      "s"
    },
    {
      "Target_CollectItem",
      "s"
    },
    {
      "Target_PersonalFuben",
      "s"
    },
    {
      "Target_MinLevel",
      "d"
    },
    {
      "Target_ExtPoint",
      "d"
    },
    {
      "Target_Achievement",
      "s"
    },
    {
      "Target_EnterMap",
      "d"
    },
    {
      "Target_OnTrap",
      "s"
    },
    {
      "Target_ExtInfo",
      "s"
    },
    {
      "Require_MinLevel",
      "d"
    },
    {
      "Require_MaxLevel",
      "d"
    },
    {
      "Require_FinishTask",
      "d"
    },
    {
      "szAwardInfo",
      "s"
    },
    {
      "IsFinishGuide",
      "d"
    },
    {
      "bAutoFinish",
      "d"
    },
    {
      "bNotAutoNext",
      "d"
    },
    {
      "bShowFinish",
      "d"
    },
    {
      "bKillNpcToAllPlayer",
      "d"
    },
    {
      "ShowClientNpc",
      "s"
    },
    {
      "DeleteClientNpc",
      "s"
    },
    {
      "szOnFinishTrack",
      "s"
    },
    {
      "nNeedConfirmFinish",
      "d"
    },
    {
      "nTaskItemId",
      "d"
    }
  }
  local tbFileInfo = {
    szType = "",
    szIndex = nil,
    tbTitle = {}
  }
  for _, tbInfo in pairs(tbFileIdxInfo) do
    table.insert(tbFileInfo.tbTitle, tbInfo[1])
    tbFileInfo.szType = tbFileInfo.szType .. tbInfo[2]
  end
  local tbFile = LoadTabFile(szFilePath, tbFileInfo.szType, tbFileInfo.szIndex, tbFileInfo.tbTitle)
  if not tbFile then
    Log("[Task] Load Task File Fail !! file can not find !! ", szFilePath)
    return
  end
  self.tbAllTask = self.tbAllTask or {}
  self.tbTaskAttachNpc = self.tbTaskAttachNpc or {}
  local tbTmp = {}
  for _, tbRow in pairs(tbFile) do
    tbRow.tbTargetInfo = {}
    tbRow.tbRequireInfo = {}
    tbRow.tbAward = Lib:GetAwardFromString(tbRow.szAwardInfo)
    tbRow.szAwardInfo = nil
    if tbRow.szMainTaskIndex == "" then
      tbRow.szMainTaskIndex = nil
    end
    local tbAllKey = {}
    for szKey in pairs(tbRow) do
      tbAllKey[szKey] = 1
    end
    for szIndex in pairs(tbAllKey) do
      if szIndex == "bCanRepeat" then
        tbRow[szIndex] = tbRow[szIndex] == 1
      elseif szIndex == "bClientAllow" then
        tbRow[szIndex] = tbRow[szIndex] == 1
      else
        self:CheckTaskInfo(tbRow, szIndex, tbRow[szIndex])
      end
    end
    tbTmp[tbRow.nTaskId] = tbTmp[tbRow.nTaskId] or {}
    if tbRow.nAcceptTaskNpcId > 0 and not tbTmp[tbRow.nTaskId][tbRow.nAcceptTaskNpcId] then
      tbTmp[tbRow.nTaskId][tbRow.nAcceptTaskNpcId] = 1
      self.tbTaskAttachNpc[tbRow.nAcceptTaskNpcId] = self.tbTaskAttachNpc[tbRow.nAcceptTaskNpcId] or {}
      table.insert(self.tbTaskAttachNpc[tbRow.nAcceptTaskNpcId], tbRow.nTaskId)
    end
    if tbRow.nFinishTaskNpcId > 0 and not tbTmp[tbRow.nTaskId][tbRow.nFinishTaskNpcId] then
      tbTmp[tbRow.nTaskId][tbRow.nFinishTaskNpcId] = 1
      self.tbTaskAttachNpc[tbRow.nFinishTaskNpcId] = self.tbTaskAttachNpc[tbRow.nFinishTaskNpcId] or {}
      table.insert(self.tbTaskAttachNpc[tbRow.nFinishTaskNpcId], tbRow.nTaskId)
    end
    if self.tbAllTask[tbRow.nTaskId] then
      assert(false, string.format("[Task] repeat task id %s", tbRow.nTaskId))
    end
    self.tbAllTask[tbRow.nTaskId] = tbRow
  end
end
function Task:LoadTaskItem()
  local tbInfo = LoadTabFile("Setting/Task/TaskItem.tab", "dsddddss", "nTaskItemId", {
    "nTaskItemId",
    "szMsg",
    "nTime",
    "nMapTemplateId",
    "nX",
    "nY",
    "szAtlas",
    "szImg"
  })
  self.tbTaskItem = {}
  for nTaskId, tbTask in pairs(self.tbAllTask) do
    if tbTask.nTaskItemId and tbTask.nTaskItemId > 0 then
      self.tbTaskItem[nTaskId] = tbInfo[tbTask.nTaskItemId]
    end
  end
end
function Task:MarcoReplace(tbRow)
  local tbTips = {
    "szTaskTitle",
    "szDetailDesc",
    "szTaskDesc",
    "szFinishDesc",
    "szTrackInfo",
    "szFinishTrackInfo",
    "szOnFinishTrack"
  }
  local szAcceptTaskNpcName = tbRow.nAcceptTaskNpcId > 0 and KNpc.GetNameByTemplateId(tbRow.nAcceptTaskNpcId) or "？"
  local szFinishTaskNpcName = 0 < tbRow.nFinishTaskNpcId and KNpc.GetNameByTemplateId(tbRow.nFinishTaskNpcId) or "？"
  local szPersonalFubenName = "？"
  if tbRow.tbTargetInfo and tbRow.tbTargetInfo.PersonalFuben then
    local tbTargetInfo = tbRow.tbTargetInfo.PersonalFuben
    szPersonalFubenName = PersonalFuben:GetSectionName(tbTargetInfo.nSectionIdx, tbTargetInfo.nSubSectionIdx, tbTargetInfo.nFubenLevel) or "？"
  end
  for _, szTips in pairs(tbTips) do
    tbRow[szTips] = string.gsub(tbRow[szTips], "$T", tbRow.nTaskId)
    tbRow[szTips] = string.gsub(tbRow[szTips], "$A", tbRow.nAcceptTaskNpcId)
    tbRow[szTips] = string.gsub(tbRow[szTips], "$F", tbRow.nFinishTaskNpcId)
    tbRow[szTips] = string.gsub(tbRow[szTips], "$NA", szAcceptTaskNpcName)
    tbRow[szTips] = string.gsub(tbRow[szTips], "$NF", szFinishTaskNpcName)
    tbRow[szTips] = string.gsub(tbRow[szTips], "$NP", szPersonalFubenName)
  end
end
Task:Init()
function Task:Setup()
  for _, tbRow in pairs(self.tbAllTask) do
    self:MarcoReplace(tbRow)
  end
end
function Task:HaveAcceptTask(pPlayer, nTaskId)
  if not nTaskId then
    return false
  end
  local tbTask = self:GetPlayerTaskInfo(pPlayer, nTaskId)
  if not tbTask then
    return false
  end
  return true
end
function Task:GetPlayerTaskInfo(pPlayer, nTaskId)
  local tbTask = pPlayer.GetScriptTable("Task")
  tbTask.tbRecord = tbTask.tbRecord or {}
  tbTask.tbCurTaskInfo = tbTask.tbCurTaskInfo or {}
  if nTaskId then
    for nIndex, tbCurTask in pairs(tbTask.tbCurTaskInfo) do
      if tbCurTask.nTaskId == nTaskId then
        return tbCurTask, tbTask, nIndex
      end
    end
    return nil
  end
  return tbTask
end
function Task:GetPlayerCurTask(pPlayer)
  local tbTask = pPlayer.GetScriptTable("Task")
  tbTask.tbRecord = tbTask.tbRecord or {}
  tbTask.tbCurTaskInfo = tbTask.tbCurTaskInfo or {}
  local tbResult = {}
  for _, tbCurTask in pairs(tbTask.tbCurTaskInfo) do
    tbResult[tbCurTask.nTaskId] = tbCurTask
  end
  return tbResult
end
function Task:GetTaskDataInfo(nTaskId, szType)
  local tbDstTask = self:GetTask(nTaskId)
  return ((tbDstTask or {}).tbTargetInfo or {})[szType]
end
function Task:SavePlayerTaskInfo(pPlayer)
  pPlayer.SaveScriptTable("Task")
end
function Task:SetTaskFlag(pPlayer, nTaskId, nFlag)
  local tbTask = self:GetPlayerTaskInfo(pPlayer)
  if not tbTask then
    return
  end
  if not nFlag or nFlag ~= 0 then
    nFlag = 1
  end
  if nFlag == 0 then
    Log("Task:SetTaskFlag >>", pPlayer.szName, nTaskId, nFlag)
  end
  Lib:SetTableBit(tbTask.tbRecord, nTaskId, nFlag)
end
function Task:GetTaskFlag(pPlayer, nTaskId)
  local tbTask = self:GetPlayerTaskInfo(pPlayer)
  if not tbTask then
    return 0
  end
  return Lib:GetTableBit(tbTask.tbRecord, nTaskId)
end
function Task:IsFinish(pPlayer, nTaskId)
  return self:GetTaskFlag(pPlayer, nTaskId) == 1
end
function Task:GetTaskState(pPlayer, nTaskId, nNpcId)
  local tbPlayerTask = self:GetPlayerTaskInfo(pPlayer, nTaskId)
  if tbPlayerTask then
    if self:CheckCanFinishTask(pPlayer, nTaskId, -1) then
      return self.STATE_CAN_FINISH
    end
    local pNpc = KNpc.GetById(nNpcId or -1)
    local tbTask = self:GetTask(nTaskId)
    if not pNpc or pNpc and pNpc.nTemplateId == tbTask.nFinishTaskNpcId then
      return self.STATE_ON_DING
    end
    return self.STATE_NONE
  end
  if self:CheckCanAcceptTask(pPlayer, nTaskId, -1) then
    return self.STATE_CAN_ACCEPT
  end
  return self.STATE_NONE
end
function Task:CommonCheck(pPlayer, nTaskId, nNpcId, bIsCheckAccept)
  if not pPlayer then
    return false, "异常"
  end
  local tbTask = self:GetTask(nTaskId)
  if not tbTask then
    return false, "无此任务！"
  end
  if not bIsCheckAccept then
    local tbCollectItem = tbTask.tbTargetInfo.CollectItem or {}
    for nItemId, nNeedCount in pairs(tbCollectItem) do
      if nNeedCount > pPlayer.GetItemCountInAllPos(nItemId) then
        return false, "任务道具不足！"
      end
    end
  end
  local nFlag = self:GetTaskFlag(pPlayer, nTaskId)
  if nFlag == 1 and not tbTask.bCanRepeat then
    return false, "不能重复完成此任务！"
  end
  local nNeedNpcId = tbTask.nFinishTaskNpcId
  if bIsCheckAccept then
    nNeedNpcId = tbTask.nAcceptTaskNpcId
  end
  local pNpc
  if nNpcId ~= -1 then
    pNpc = KNpc.GetById(nNpcId)
    if not pNpc then
      return false, "你在找谁呢？"
    end
    if nNeedNpcId ~= 0 and pNpc.nTemplateId ~= nNeedNpcId then
      return false, "目标错误！"
    end
    if pPlayer.GetNpc().GetDistance(nNpcId) > Npc.DIALOG_DISTANCE then
      return false, "距离太远了！"
    end
  end
  return true, "", tbTask, pNpc
end
function Task:CheckCanFinishTask(pPlayer, nTaskId, nNpcId)
  local bRet, szMsg, tbTask, pNpc = self:CommonCheck(pPlayer, nTaskId, nNpcId, false)
  if not bRet then
    return false, szMsg
  end
  local tbTargetInfo = self:GetTaskTargetInfo(pPlayer, nTaskId)
  if not tbTargetInfo then
    return false, "没有接取过此任务！"
  end
  for szType, value in pairs(tbTask.tbTargetInfo) do
    local fnCheckTargetFunc = self.tbCheckTargetFunc[szType]
    if not fnCheckTargetFunc then
      return false, "" .. szType .. " 未定义目标！"
    end
    local bOK, bRet, szMsg = Lib:CallBack({
      fnCheckTargetFunc,
      self,
      pPlayer,
      nTaskId,
      value,
      tbTargetInfo[szType]
    })
    if not bOK or not bRet then
      return false, szMsg or "未知原因，无法完成任务！"
    end
  end
  return true
end
function Task:CheckCanAcceptTask(pPlayer, nTaskId, nNpcId)
  local bRet, szMsg, tbTask, pNpc = self:CommonCheck(pPlayer, nTaskId, nNpcId, true)
  if not bRet then
    return false, szMsg
  end
  local tbTargetInfo = self:GetTaskTargetInfo(pPlayer, nTaskId)
  if tbTargetInfo then
    return false, "已接取此任务！"
  end
  for szFunc, value in pairs(tbTask.tbRequireInfo) do
    local fnCheckRequireFunc = self.tbCheckRequireFunc[szFunc]
    if not fnCheckRequireFunc then
      return false, "" .. szFunc .. " 未定义条件！"
    end
    local bOK, bRet, szMsg = Lib:CallBack({
      fnCheckRequireFunc,
      self,
      pPlayer,
      value
    })
    if not bOK or not bRet then
      return false, szMsg or "未知原因，无法完成任务！"
    end
  end
  return true, "", tbTask
end
function Task:GetTaskTargetInfo(pPlayer, nTaskId)
  local tbPlayerTask = self:GetPlayerTaskInfo(pPlayer, nTaskId)
  if not tbPlayerTask then
    return
  end
  tbPlayerTask.tbTargetInfo = tbPlayerTask.tbTargetInfo or {}
  return tbPlayerTask.tbTargetInfo
end
function Task:GetTask(nTaskId)
  return self.tbAllTask[nTaskId]
end
function Task:GetTaskItem(nTaskId)
  return self.tbTaskItem[nTaskId]
end
function Task:GetCurMainTask(pPlayer)
  local tbPlayerTask = Task:GetPlayerTaskInfo(pPlayer)
  local tbCurInfo = tbPlayerTask.tbCurTaskInfo
  for _, tbInfo in pairs(tbCurInfo) do
    local tbTask = Task:GetTask(tbInfo.nTaskId)
    if tbTask and tbTask.nTaskType == Task.TASK_TYPE_MAIN then
      return tbTask
    end
  end
  return
end
function Task:GetTaskByNpcTemplateId(nNpcTemplateId)
  return self.tbTaskAttachNpc[nNpcTemplateId]
end
function Task:TraverseTask(fun, ...)
  for nTaskId in pairs(self.tbAllTask) do
    fun(nTaskId, ...)
  end
end
function Task:ForceAbortTask(pPlayer, nTaskId)
  local _, tbPlayerTask, nIndex = self:GetPlayerTaskInfo(pPlayer, nTaskId)
  if tbPlayerTask and nIndex then
    table.remove(tbPlayerTask.tbCurTaskInfo, nIndex)
  end
  if MODULE_GAMESERVER then
    pPlayer.CallClientScriptWhithPlayer("Task:ForceAbortTask", nTaskId)
  else
    Task:UpdateTaskInfo(nTaskId)
  end
end
function Task:CheckCanClientAccetp(nTaskId)
  local tbTask = self:GetTask(nTaskId)
  if not tbTask or tbTask.bClientAllow or not tbTask.bCanRepeat then
    return true
  end
  return false
end
function Task:CheckIsTaskTrap(pPlayer, nMapTemplateId, szTrapName)
  if self.tbTrap2TrackInfo[nMapTemplateId] and self.tbTrap2TrackInfo[nMapTemplateId][szTrapName] then
    return true
  end
  return false
end
function Task:GetTaskTrapTrack(pPlayer, nMapTemplateId, szTrapName)
  if not self.tbTrap2TrackInfo[nMapTemplateId] or not self.tbTrap2TrackInfo[nMapTemplateId][szTrapName] then
    return false
  end
  local tbInfo = self.tbTrap2TrackInfo[nMapTemplateId][szTrapName]
  for nTaskId, szTrack in pairs(tbInfo) do
    local tbTask = self:GetPlayerTaskInfo(me, nTaskId)
    if tbTask then
      return true, szTrack
    end
  end
  return false
end
function Task:SetValidTime2Task(pPlayer, nTaskId, nEndTime)
  local tbCurTask = self:GetPlayerTaskInfo(pPlayer, nTaskId)
  if not tbCurTask then
    return
  end
  tbCurTask.nValidTime = nEndTime
  if MODULE_GAMESERVER then
    self:SavePlayerTaskInfo(pPlayer)
    pPlayer.CallClientScriptWhithPlayer("Task:SetValidTime2Task", nTaskId, nEndTime)
  end
end
function Task:CheckTaskValidTime(pPlayer)
  local tbTask = pPlayer.GetScriptTable("Task")
  tbTask.tbRecord = tbTask.tbRecord or {}
  tbTask.tbCurTaskInfo = tbTask.tbCurTaskInfo or {}
  local tb2RemoveTask = {}
  local tbRemoveTaskId = {}
  for nIdx, tbInfo in ipairs(tbTask.tbCurTaskInfo) do
    if tbInfo.nValidTime and tbInfo.nValidTime <= GetTime() then
      table.insert(tb2RemoveTask, nIdx)
      table.insert(tbRemoveTaskId, tbInfo.nTaskId)
    end
  end
  if #tb2RemoveTask == 0 then
    return
  end
  for i = #tb2RemoveTask, 1, -1 do
    table.remove(tbTask.tbCurTaskInfo, tb2RemoveTask[i])
  end
  if MODULE_GAMESERVER then
    self:SavePlayerTaskInfo(pPlayer)
    pPlayer.CallClientScriptWhithPlayer("Task:CheckTaskValidTime")
  else
    self:OnTaskTimeout(tbRemoveTaskId)
  end
end
