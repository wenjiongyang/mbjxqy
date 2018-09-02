local tbUi = Ui:CreateClass("Task")
local tbItem = Ui:CreateClass("TaskItem")
local tbRightPanel = {
  Task = "mainpannle",
  ValueCompose = "FragmentComposeMap"
}
tbUi.nCurSeqId = nil
tbUi.nCurPos = nil
local szBaseHideIcon = "mask"
local szBaseHideIconEffect = "NewTask_texiao"
local fHideIconEffectDelay = 2
local fFinishEffectDelay = 1.5
function tbUi:RegisterEvent()
  local tbRegEvent = {
    {
      UiNotify.emNOTIFY_UPDATE_TASK,
      self.OnTaskUpdate,
      self
    },
    {
      UiNotify.emNoTIFY_SYNC_COMMERCE_DATA,
      self.OnTaskUpdate,
      self
    },
    {
      UiNotify.emNOTIFY_VALUE_COMPOSE_FINISH,
      self.OnValueComposeFinish,
      self
    }
  }
  return tbRegEvent
end
function tbUi:InitHead()
  self.tbShowTask = {}
  self.tbHeadState = self.tbHeadState or {}
  local tbTitle = {
    "主线任务",
    "支线任务",
    "日常任务",
    "神秘碎片"
  }
  for i = 1, #tbTitle do
    table.insert(self.tbShowTask, {})
    table.insert(self.tbShowTask[i], {
      bHead = true,
      nType = i,
      bOpened = self.tbHeadState[i],
      szTitle = tbTitle[i]
    })
  end
end
function tbUi:InitSubTask()
  local tbPlayerTask = Task:GetPlayerTaskInfo(me)
  local tbCurInfo = tbPlayerTask.tbCurTaskInfo
  for _, tbInfo in pairs(tbCurInfo) do
    local tbTask = Task:GetTask(tbInfo.nTaskId)
    if tbTask then
      table.insert(self.tbShowTask[tbTask.nTaskType], {
        nTaskId = tbInfo.nTaskId,
        szTitle = tbTask.szTaskTitle
      })
    end
  end
  for szKey, tbInfo in pairs(Task.tbDailyTaskSettings) do
    if tbInfo:IsInCurTaskList() then
      table.insert(self.tbShowTask[Task.TASK_TYPE_DAILY], {
        szDailyKey = szKey,
        szTitle = tbInfo.szTitle
      })
    end
  end
  for _, nSeqId in ipairs(Compose.ValueCompose.tbShowData) do
    local tbSeqInfo = Compose.ValueCompose:GetSeqInfo(nSeqId)
    if tbSeqInfo then
      table.insert(self.tbShowTask[Task.TASK_TYPE_VALUE_COMPOSE], {
        bIsValueCompose = true,
        nSeqId = nSeqId,
        szTitle = tbSeqInfo.szDirTitle
      })
    end
  end
end
local GetTaskType = function(tbTask)
  if not tbTask or not next(tbTask) then
    return
  end
  if tbTask.nTaskId then
    local _, _, nIdx = Task:GetPlayerTaskInfo(me, tbTask.nTaskId)
    if nIdx then
      local tbTaskInfo = Task:GetTask(tbTask.nTaskId) or {}
      return tbTaskInfo.nTaskType
    end
  elseif tbTask.szDailyKey then
    local tbTaskInfo = Task.tbDailyTaskSettings[tbTask.szDailyKey]
    if tbTaskInfo.IsInCurTaskList() then
      return Task.TASK_TYPE_DAILY
    end
  elseif tbTask.bIsValueCompose then
    return Task.TASK_TYPE_VALUE_COMPOSE
  end
end
function tbUi:CloseAllOpenTab()
  for nType, tbInfo in ipairs(self.tbShowTask) do
    tbInfo[1].bOpened = false
    self.tbHeadState[nType] = false
  end
end
function tbUi:OpenTab(nTabType)
  if self.tbShowTask[nTabType] then
    self.tbShowTask[nTabType][1].bOpened = true
    self.tbHeadState[nTabType] = true
  end
end
function tbUi:InitDefaultTask()
  self.tbDefault = self.tbDefault or {}
  if self.nOpenType and self.nOpenType == Task.TASK_TYPE_VALUE_COMPOSE then
    self:CloseAllOpenTab()
    self:OpenTab(Task.TASK_TYPE_VALUE_COMPOSE)
    self.tbDefault = {
      nSeqId = self.tbOpenParam[1],
      bIsValueCompose = true
    }
    self.nCurSeqId = self.tbOpenParam[1]
    self.nCurPos = self.tbOpenParam[2]
    self:HideComposeEffect()
  else
    local tbLatelyTask = Task:GetLatelyTask()
    if tbLatelyTask and next(tbLatelyTask) then
      local szKey = tbLatelyTask[1] == Task.emTASKTYPE_SUB and "nTaskId" or "szDailyKey"
      self.tbDefault = {}
      self.tbDefault[szKey] = tbLatelyTask[2]
    end
    local nType = GetTaskType(self.tbDefault)
    if nType then
      self.tbHeadState[nType] = true
      self.tbShowTask[nType][1].bOpened = self.tbHeadState[nType]
      return
    end
    self.tbDefault = self.tbShowTask[Task.TASK_TYPE_DAILY][2] or self.tbShowTask[Task.TASK_TYPE_MAIN][2]
    if self.tbDefault then
      local nType = GetTaskType(self.tbDefault)
      self.tbHeadState[nType] = true
      self.tbShowTask[nType][1].bOpened = self.tbHeadState[nType]
    end
  end
end
function tbUi:OnOpen(nType, ...)
  self.nOpenType = nType
  self.tbOpenParam = {
    ...
  }
  Compose.ValueCompose:UpdateShowData()
  self:InitHead()
  self:InitSubTask()
  self:InitDefaultTask()
  self:Refresh()
  if self.nOpenType and self.nOpenType == Task.TASK_TYPE_VALUE_COMPOSE then
    self:UpdateComposePanel()
    self:UpdateRightPanelVisible(tbRightPanel.ValueCompose)
    if self.nCurPos then
      self:PlayGetEffect()
    end
  else
    self:UpdateDetailPanel()
    self:UpdateRightPanelVisible(tbRightPanel.Task)
  end
end
function tbUi:PlayGetEffect()
  local szHideIconName = szBaseHideIcon .. self.nCurPos
  local tbPos = self.pPanel:GetPosition(szHideIconName)
  self.pPanel:Tween_Play(szHideIconName, 0)
  self.pPanel:ChangePosition("NewTask_texiao9", tbPos.x, tbPos.y)
  self.pPanel:SetActive("NewTask_texiao9", true)
  Timer:Register(Env.GAME_FPS * fHideIconEffectDelay, self.OnGetEffectEnd, self)
end
function tbUi:OnGetEffectEnd()
  self.nCurPos = nil
  self:UpdateComposePanel()
end
function tbUi:OnClose()
  local tbLatelyTask
  if self.tbDefault.nTaskId then
    tbLatelyTask = {
      Task.emTASKTYPE_SUB,
      self.tbDefault.nTaskId
    }
  else
    tbLatelyTask = {
      Task.emTASKTYPE_DAILY,
      self.tbDefault.szDailyKey
    }
  end
  Task:SetLatelyTask(tbLatelyTask)
  Compose.ValueCompose:CheckShowRedPoint()
  self.pPanel:SetActive("MapBg", false)
end
function tbUi:Refresh()
  local function fnOnSelect(itemObj)
    local tbTask = self:GetTask(itemObj._nIdx)
    if tbTask.bHead then
      itemObj.pPanel:SetActive("ArrowDown", not tbTask.bOpened)
      itemObj.pPanel:SetActive("ArrowUp", tbTask.bOpened)
    end
    self:OnSelectTask(itemObj._nIdx)
  end
  local bComposeHasFinish = Compose.ValueCompose:CheckShowRedPoint()
  local nType = GetTaskType(self.tbDefault)
  local function fnInit(itemObj, nIdx)
    local tbTask = self:GetTask(nIdx)
    itemObj.pPanel:SetActive("TaskChapter", tbTask.bHead)
    itemObj.pPanel:SetActive("TaskSections", not tbTask.bHead)
    if tbTask.bHead then
      local bArrowActive = #self.tbShowTask[tbTask.nType] > 1
      itemObj.pPanel:SetActive("ArrowUp", bArrowActive and tbTask.bOpened)
      itemObj.pPanel:SetActive("ArrowDown", bArrowActive and not tbTask.bOpened)
      local szSprite = "BtnListMain"
      itemObj.pPanel:SetActive("New1", tbTask.nType == Task.TASK_TYPE_VALUE_COMPOSE and bComposeHasFinish)
      szSprite = szSprite .. (nType == tbTask.nType and "Press" or "Normal")
      itemObj.pPanel:Sprite_SetSprite("TaskChapter", szSprite)
      itemObj.pPanel:Button_SetSprite("TaskChapter", szSprite)
      itemObj.pPanel:Label_SetText("TaskChapterTitle", tbTask.szTitle)
      itemObj.pPanel:Label_SetText("TaskChapterTitleLight", tbTask.szTitle)
      itemObj.pPanel:SetActive("TaskChapterTitleLight", tbTask.nType == nType)
      itemObj.pPanel:SetActive("TaskChapterTitle", tbTask.nType ~= nType)
    else
      local nThisType = GetTaskType(tbTask)
      local bCurTask = nType == nThisType and tbTask.nTaskId == self.tbDefault.nTaskId and tbTask.szDailyKey == self.tbDefault.szDailyKey and tbTask.nSeqId == self.tbDefault.nSeqId
      local szSprite = "BtnListSecond"
      szSprite = szSprite .. (bCurTask and "Press" or "Normal")
      itemObj.pPanel:Sprite_SetSprite("TaskSections", szSprite)
      itemObj.pPanel:Button_SetSprite("TaskSections", szSprite)
      itemObj.pPanel:Label_SetText("TaskSectionsTitle", tbTask.szTitle)
      local bRedPoint = false
      if nThisType == Task.TASK_TYPE_VALUE_COMPOSE and Compose.ValueCompose:CheckIsFinish(me, tbTask.nSeqId, true) then
        bRedPoint = true
      end
      itemObj.pPanel:SetActive("New2", bRedPoint)
    end
    itemObj._nIdx = nIdx
    itemObj.fnOnSelect = fnOnSelect
  end
  self.ScrollView:UpdateItemHeight(self:GetShowHeight())
  self.ScrollView:Update(self:GetShowTaskNum(), fnInit)
end
function tbUi:GetShowTaskNum()
  local nNum = #self.tbShowTask
  for _, tbTaskGroup in ipairs(self.tbShowTask) do
    if tbTaskGroup[1].bOpened then
      nNum = nNum + #tbTaskGroup - 1
    end
  end
  return nNum
end
function tbUi:GetShowHeight()
  local tbHeight = {}
  for _, tbTaskGroup in ipairs(self.tbShowTask) do
    table.insert(tbHeight, 80)
    if tbTaskGroup[1].bOpened then
      for i = 1, #tbTaskGroup - 1 do
        table.insert(tbHeight, 60)
      end
    end
  end
  return tbHeight
end
function tbUi:GetTask(nIdx)
  for _, tbTaskGroup in ipairs(self.tbShowTask) do
    if tbTaskGroup[1].bOpened then
      if nIdx <= #tbTaskGroup then
        return tbTaskGroup[nIdx]
      end
      nIdx = nIdx - #tbTaskGroup
    else
      if 1 == nIdx then
        return tbTaskGroup[1]
      end
      nIdx = nIdx - 1
    end
  end
end
function tbUi:HideComposeEffect()
  self.pPanel:SetActive("NewTask_texiao2", false)
  self.pPanel:SetActive("NewTask_texiao9", false)
end
function tbUi:OnSelectTask(nIdx)
  local tbSelTask = self:GetTask(nIdx)
  if tbSelTask.bHead then
    local nTaskNum = #self.tbShowTask[tbSelTask.nType]
    self.tbHeadState[tbSelTask.nType] = nTaskNum > 1 and not self.tbHeadState[tbSelTask.nType] or false
    tbSelTask.bOpened = self.tbHeadState[tbSelTask.nType]
    if nTaskNum <= 1 then
      if tbSelTask.nType == Task.TASK_TYPE_VALUE_COMPOSE then
        me.CenterMsg("当前没有碎片线索")
      else
        local tbTitle = {
          "主线",
          "支线",
          "日常",
          "神秘碎片"
        }
        local szMsg = string.format("当前没有【%s】任务", tbTitle[tbSelTask.nType] or "主线")
        me.CenterMsg(szMsg)
      end
    end
  elseif tbSelTask.bIsValueCompose then
    self.nCurSeqId = tbSelTask.nSeqId
    self.tbDefault = {
      nSeqId = tbSelTask.nSeqId,
      bIsValueCompose = true
    }
    self:UpdateComposePanel(tbSelTask)
    self:UpdateRightPanelVisible(tbRightPanel.ValueCompose)
    self:HideComposeEffect()
  else
    self.tbDefault = {
      nTaskId = tbSelTask.nTaskId,
      szDailyKey = tbSelTask.szDailyKey
    }
    self:UpdateDetailPanel(tbSelTask)
    self:UpdateRightPanelVisible(tbRightPanel.Task)
  end
  self:Refresh()
end
function tbUi:GetTaskDesc(tbTask)
  local szTaskDesc, szDetailDesc = "", ""
  local bGiveUp, bAwards
  if tbTask.nTaskId then
    local tbTaskInfo = Task:GetTask(tbTask.nTaskId)
    szTaskDesc = tbTaskInfo.szTaskDesc .. Task:GetTaskExtInfo(nTaskId)
    szDetailDesc = tbTaskInfo.szDetailDesc
    bGiveUp = false
    bAwards = Task.KinTask.tbTask2Type[tbTask.nTaskId] and true or #tbTaskInfo.tbAward > 0
  elseif tbTask.szDailyKey then
    local tbDaily = Task.tbDailyTaskSettings[tbTask.szDailyKey]
    szTaskDesc = tbDaily.szTarget
    szDetailDesc = tbDaily.szMsg
    bGiveUp = tbDaily.OnGiveUp
    bAwards = tbDaily.bShowAwards
  end
  return szTaskDesc, szDetailDesc, bGiveUp, bAwards
end
function tbUi:ClearDetailPanel()
  self.pPanel:Label_SetText("TaskTarget", "")
  self.pPanel:Label_SetText("TaskMsg", "")
  self.pPanel:SetActive("BtnGiveUp", false)
  self.pPanel:SetActive("AwardsGroup", false)
end
function tbUi:UpdateDetailPanel(tbTask)
  tbTask = tbTask or self.tbDefault
  if not tbTask or not next(tbTask) then
    self:ClearDetailPanel()
    return
  end
  local szTaskDesc, szDetailDesc, bGiveUp, bAwards = self:GetTaskDesc(tbTask)
  self.pPanel:Label_SetText("TaskTarget", szTaskDesc)
  self.pPanel:Label_SetText("TaskMsg", szDetailDesc)
  self.pPanel:SetActive("BtnGiveUp", bGiveUp)
  self.pPanel:SetActive("AwardsGroup", bAwards)
  if tbTask.nTaskId then
    do
      local tbTaskInfo = Task:GetTask(tbTask.nTaskId)
      local tbAward = tbTaskInfo.tbAward
      if Task.KinTask.tbTask2Type[tbTask.nTaskId] then
        tbAward = Task.KinTask:GetShowTask(me)
      end
      self:UpdateItemFrame(tbAward)
      function self.tbOnClick.BtnGo()
        Ui:CloseWindow("Task")
        Task:OnTrack(tbTaskInfo.nTaskId)
        Task:OnTaskUpdate(tbTaskInfo.nTaskId)
        UiNotify.OnNotify(UiNotify.emNOTIFY_UPDATE_TASK, nTaskId)
      end
    end
  elseif tbTask.szDailyKey then
    do
      local tbDaily = Task.tbDailyTaskSettings[tbTask.szDailyKey]
      if tbDaily.OnGiveUp then
        function self.tbOnClick.BtnGiveUp()
          Ui:CloseWindow("Task")
          tbDaily.OnGiveUp()
        end
      end
      function self.tbOnClick.BtnGo()
        Ui:CloseWindow("Task")
        tbDaily.OnTrack()
      end
      if tbDaily.tbAward then
        self:UpdateItemFrame(tbDaily.tbAward)
      end
    end
  end
end
function tbUi:UpdateItemFrame(tbAwards)
  local nAwardLen = 0
  for nIdx, tbInfo in ipairs(tbAwards) do
    local szItName = "itemframe" .. nIdx
    self.pPanel:SetActive(szItName, true)
    self[szItName]:SetGenericItem(tbInfo)
    nAwardLen = nAwardLen + 1
    self[szItName].fnClick = self[szItName].DefaultClick
  end
  for nIdx = nAwardLen + 1, 6 do
    if self["itemframe" .. nIdx] then
      self.pPanel:SetActive("itemframe" .. nIdx, false)
    else
      break
    end
  end
end
function tbUi:UpdateComposePanel(tbTask)
  tbTask = tbTask or self.tbDefault
  local nSeqId = tbTask.nSeqId
  if not nSeqId or nSeqId == 0 then
    self.pPanel:SetActive(tbRightPanel.ValueCompose, false)
    return
  end
  local tbSeqInfo = Compose.ValueCompose:GetSeqInfo(nSeqId)
  if not tbSeqInfo or not next(tbSeqInfo) then
    return
  end
  local nValueCount = tbSeqInfo.nAllCount
  local szDes = ""
  local nDesPos = Compose.ValueCompose:GetHaveValueNum(me, nSeqId)
  for nPos = 1, nValueCount do
    local szHideIcon = szBaseHideIcon .. nPos
    self.pPanel:SetActive(szHideIcon, true)
    self.pPanel:Tween_Disable(szHideIcon)
    self.pPanel:Widget_ChangeAlpha(szHideIcon, 1)
    if Compose.ValueCompose:CheckIsHaveValue(me, nSeqId, nPos) then
      self.pPanel:SetActive(szHideIcon, false)
    end
    if self.nCurPos and self.nCurPos == nPos then
      self.pPanel:SetActive(szHideIcon, true)
    end
  end
  szDes = tbSeqInfo["szItemDes" .. nDesPos] or ""
  self.pPanel:Label_SetText("Tip", szDes)
  local szTexturePath = tbSeqInfo.szBGMapPath
  self.pPanel:Texture_SetTexture("MapBg", szTexturePath)
  self.pPanel:SetActive("MapBg", true)
  local bIsFinish = Compose.ValueCompose:CheckIsFinish(me, nSeqId, true)
  self.pPanel:SetActive("BtnCompose", bIsFinish)
end
function tbUi:OnTaskUpdate()
  Ui:OpenWindow(self.UI_NAME)
end
function tbUi:UpdateRightPanelVisible(szShowPanel)
  for _, szPanelName in pairs(tbRightPanel) do
    self.pPanel:SetActive(szPanelName, false)
  end
  self.pPanel:SetActive(szShowPanel, true)
end
tbUi.tbOnClick = {
  BtnClose = function()
    Ui:CloseWindow("Task")
  end,
  BtnGiveUp = function()
  end,
  BtnGo = function()
  end,
  BtnCompose = function(self)
    if not self.nCurSeqId then
      me.CenterMsg("请选择需要合成的物品")
      return
    end
    self.pPanel:SetActive("BtnCompose", false)
    self.pPanel:SetActive("NewTask_texiao2", false)
    self.pPanel:SetActive("NewTask_texiao2", true)
    Timer:Register(Env.GAME_FPS * fFinishEffectDelay, function()
      Compose.ValueCompose:TryComposeValue(self.nCurSeqId)
    end)
  end
}
function tbUi:OnValueComposeFinish(nNextSeqId, nFinishSeqId)
  self.nCurSeqId = nNextSeqId
  self:InitHead()
  self:InitSubTask()
  self.tbDefault = {
    nSeqId = self.nCurSeqId,
    bIsValueCompose = true
  }
  self:Refresh()
  self:UpdateComposePanel()
  local nTempleteId = Compose.ValueCompose:GetSeqTempleteId(nFinishSeqId)
  local szName = ""
  if nTempleteId then
    local pItem = KItem.GetItemBaseProp(nTempleteId)
    if pItem then
      szName = pItem.szName
    end
  end
  me.CenterMsg(string.format("恭喜合成【%s】", szName))
end
tbItem.tbOnClick = {
  TaskChapter = function(self)
    self.fnOnSelect(self)
  end,
  TaskSections = function(self)
    self.fnOnSelect(self)
  end
}
