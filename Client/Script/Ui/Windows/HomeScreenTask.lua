local tbUi = Ui:CreateClass("HomeScreenTask")
tbUi.nNoOperationTime = 180
function tbUi:RegisterEvent()
  local tbRegEvent = {
    {
      UiNotify.emNOTIFY_TEAM_UPDATE,
      self.RefreshTeam,
      self
    },
    {
      UiNotify.emNOTIFY_UPDATE_TASK,
      self.UpdateTask,
      self
    },
    {
      UiNotify.emNOTIFY_HOME_TASK_FOLD,
      self.FoldTaskButton,
      self
    },
    {
      UiNotify.emNoTIFY_SYNC_COMMERCE_DATA,
      self.UpdateTask,
      self
    },
    {
      UiNotify.emNOTIFY_CHANGE_PLAYER_LEVEL,
      self.ChangePlayerLevel,
      self
    },
    {
      UiNotify.emNOTIFY_ACTIVITY_QUESTION_UPDATE,
      self.UpdateTask,
      self
    },
    {
      UiNotify.emNOTIFY_PG_INIT,
      self.OnPGInit,
      self
    },
    {
      UiNotify.emNOTIFY_PG_CLOSE,
      self.OnPGClose,
      self
    },
    {
      UiNotify.emNOTIFY_PG_PARTNER_DEATH,
      self.OnPGPartnerDeath,
      self
    },
    {
      UiNotify.emNOTIFY_PG_PARTNER_NPC_CHANGE,
      self.OnPGNpcChange,
      self
    },
    {
      UiNotify.emNOTIFY_PG_PARTNER_SWITCH_GROUP,
      self.OnPGSwitchGroup,
      self
    },
    {
      UiNotify.emNOTIFY_TASK_HAS_CHANGE,
      self.UpdateTask,
      self
    },
    {
      UiNotify.emNOTIFY_TASK_FINISH,
      self.OnFinishTask,
      self
    },
    {
      UiNotify.emNOTIFY_FORBIDDEN_PARTNER,
      self.OnForbiddenPartner,
      self
    },
    {
      UiNotify.emNOTIFY_CHANGE_PLAYER_HP,
      self.OnMyHpChanged,
      self
    },
    {
      UiNotify.emNOTIFY_SYNC_DATA,
      self.OnSyncData,
      self
    },
    {
      UiNotify.emNOTIFY_MAP_LOADED,
      self.OnMapLoaded,
      self
    },
    {
      UiNotify.emNOTIFY_CHANGE_FIGHTPARTNER_ID,
      self.OnChangePartnerFightID,
      self
    },
    {
      UiNotify.emNOTIFY_SHOWTEAM_NO_TASK,
      self.ShowNoTaskTeam,
      self
    },
    {
      UiNotify.emNOTIFY_INDIFFER_BATTLE_UI,
      self.OnIndifferBattleUpdate,
      self
    },
    {
      UiNotify.emNOTIFY_NO_OPERATE_UPDATE,
      self.OnNoOperateUpdate,
      self
    },
    {
      UiNotify.emNOTIFY_SYNC_SWITCH_PLACE,
      self.OnSwitchHousePlace,
      self
    }
  }
  return tbRegEvent
end
tbUi.tbOrgBtnPos = {
  BtnTask = {84, 121},
  BtnTeam = {184, 121}
}
tbUi.tbDefaultMapShowNoTask = {
  [ArenaBattle.nArenaMapId] = "擂场",
  [InDifferBattle.tbDefine.nReadyMapTemplateId] = "心魔幻境",
  [InDifferBattle.tbDefine.nFightMapTemplateId] = "心魔幻境"
}
function tbUi:OnOpenEnd()
  if self.bShowTeam then
    self:ShowTeamInfo()
  else
    self:ShowTaskInfo()
  end
  if self.bIsPartnerType == nil then
    self.bIsPartnerType = false
  end
  self:ChangePlayerLevel()
  if TeamMgr:HasTeam() and Map:GetClassDesc(me.nMapTemplateId) == "fuben" then
    self:ShowTeamInfo()
    self:Toggle_SetChecked("BtnTeam")
  end
  self.pPanel:SetActive("MisstionComplete", false)
  self.pPanel:SetActive("MisstionComplete_Sub", false)
  self.pPanel:SetActive("BtnInfo", self:IsActiveBtnInfo(me.nMapTemplateId))
  self.pPanel:Button_SetEnabled("BtnTask", true)
  self:FoldTaskButton()
  self.bNoShowTask = self.nNoShowTaskMapId == me.nMapTemplateId and true or false
  self:UpdateShowTaskBtn()
  if self.tbDefaultMapShowNoTask[me.nMapTemplateId] then
    self:ShowNoTaskTeam()
  end
  self:ShowTeamNumber()
  if Map:IsHouseMap(me.nMapTemplateId) then
    if House:IsIndoor(me) then
      self:FoldTaskButton(true)
    end
    self:ShowTeamInfo()
    self:ShowTaskInfo()
  end
end
function tbUi:ShowTeamNumber()
  if not self.TeamInfo then
    return
  end
  self.TeamInfo:UpdateShowTeamNumber()
end
function tbUi:ShowNoTaskTeam(bRelease)
  if not bRelease then
    self:ShowTeamInfo()
    self.bNoShowTask = true
    self.nNoShowTaskMapId = me.nMapTemplateId
  else
    self:ShowTaskInfo()
    self.bNoShowTask = false
    self.nNoShowTaskMapId = -1
  end
end
function tbUi:IsActiveBtnInfo(nMapTemplateId)
  if ImperialTomb:IsEmperorMapByTemplate(nMapTemplateId) or ImperialTomb:IsEmperorMirrorMapByTemplate(nMapTemplateId) or ImperialTomb:IsBossMapByTemplate(nMapTemplateId) or ImperialTomb:IsFemaleEmperorMapByTemplate(nMapTemplateId) or ImperialTomb:IsFemaleEmperorBossMapByTemplate(nMapTemplateId) or ImperialTomb:IsFemaleEmperorMirrorMapByTemplate(nMapTemplateId) then
    return true
  end
  local szOpenName = Player:GetServerSyncData("OpenBtnInfo")
  if szOpenName == string.format("BossLeaderOutputPanel:%s", nMapTemplateId or 0) then
    return true
  end
  if InDifferBattle:IsShowHomeScreenDmgBtn() then
    return true
  end
  return false
end
function tbUi:UpdateShowTaskBtn()
  local tbShow = Player:GetServerSyncData("HomeBtnTast")
  if not tbShow or tbShow.nMapTID ~= me.nMapTemplateId then
    self.pPanel:SetActive("BtnTask", true)
    self.pPanel:ChangePosition("BtnTeam", self.tbOrgBtnPos.BtnTeam[1], self.tbOrgBtnPos.BtnTeam[2])
  else
    self.pPanel:SetActive("BtnTask", false)
    self.pPanel:ChangePosition("BtnTeam", self.tbOrgBtnPos.BtnTask[1], self.tbOrgBtnPos.BtnTask[2])
    self:ShowTeamInfo()
  end
end
function tbUi:OnMapLoaded(nMapTemplateId)
  self.pPanel:SetActive("BtnInfo", self:IsActiveBtnInfo(me.nMapTemplateId))
  self:UpdateShowTaskBtn()
end
function tbUi:OnChangePartnerFightID()
  self.TeamInfo:UpdatePartnerShowInfo()
end
function tbUi:OnSyncData(szName)
  if szName == "OpenBtnInfo" then
    self.pPanel:SetActive("BtnInfo", self:IsActiveBtnInfo(me.nMapTemplateId))
  end
  self:UpdateShowTaskBtn()
  if szName == "TeamShowPartner" or string.find(szName, "TeamPartner:") then
    self:OnChangePartnerFightID()
  end
  if szName == "TeamBtNum" then
    self:ShowTeamNumber()
  end
end
function tbUi:OnIndifferBattleUpdate(szType)
  if szType ~= "room" then
    return
  end
  self.TeamInfo:Update()
  self.pPanel:SetActive("BtnInfo", self:IsActiveBtnInfo(me.nMapTemplateId))
end
function tbUi:Clear()
  self.pPanel:Label_SetText("MainTaskTitle", "")
  self.pPanel:Label_SetText("MainTaskDesc", "")
  self.pPanel:SetActive("texiao", false)
end
local LIGHT_LEVEL = 30
function tbUi:RefreshTask()
  local tbMainTask = Task:GetCurMainTask(me)
  if not tbMainTask then
    self:Clear()
    return
  end
  local szExtInfo = Task:GetTaskExtInfo(tbMainTask.nTaskId)
  local nTaskState = Task:GetTaskState(me, tbMainTask.nTaskId, -1)
  if nTaskState == Task.STATE_CAN_FINISH then
    self.pPanel:Label_SetText("MainTaskDesc", tbMainTask.szFinishDesc .. szExtInfo)
  else
    self.pPanel:Label_SetText("MainTaskDesc", tbMainTask.szTaskDesc .. szExtInfo)
  end
  self.pPanel:Label_SetText("MainTaskTitle", tbMainTask.szTaskTitle)
  self.pPanel:SetActive("texiao", me.nLevel <= LIGHT_LEVEL)
  local nLastStep, nItem = Task:GetAwardPreview(tbMainTask.nTaskId)
  if nItem then
    self.pPanel:SetActive("Container", true)
    self.pPanel:SetActive("ReadyTime", false)
    self.itemframe:SetItemByTemplate(nItem)
    self.itemframe.fnClick = self.itemframe.DefaultClick
  else
    self.pPanel:SetActive("Container", false)
  end
end
function tbUi:OnFinishTask(nTaskId)
  if not self.pPanel:IsActive("TaskInfo") then
    return
  end
  local tbTask = Task:GetTask(nTaskId)
  if tbTask and tbTask.nTaskType == Task.TASK_TYPE_MAIN then
    self:PlayMisstionAni("MisstionComplete")
  end
end
function tbUi:PlayMisstionAni(szAniName)
  self.pPanel:SetActive(szAniName, true)
  Timer:Register(Env.GAME_FPS * 2, function()
    if Ui:WindowVisible("HomeScreenTask") == 1 then
      Ui("HomeScreenTask").pPanel:SetActive(szAniName, false)
    end
  end)
end
function tbUi:OnForbiddenPartner()
  self.PartnerInfo:SetForbiddenPartner()
  self:FoldTaskButton(true)
end
function tbUi:ShowTaskInfo()
  self.pPanel:SetActive("TaskInfo", true)
  self.pPanel:SetActive("TeamInfo", false)
  self.pPanel:SetActive("PartnerInfo", false)
  self:Toggle_SetChecked("BtnTask")
  self:RefreshTask()
  self:RefreshSubTask()
  self.bShowTeam = false
end
function tbUi:ShowTeamInfo()
  self.pPanel:SetActive("TaskInfo", false)
  self.pPanel:SetActive("TeamInfo", not self.bIsPartnerType)
  self.pPanel:SetActive("PartnerInfo", self.bIsPartnerType)
  self:Toggle_SetChecked("BtnTeam")
  if not self.bIsPartnerType then
    self:RefreshTeam("MemberChanged")
  end
  self.bShowTeam = true
  self:ShowTeamNumber()
end
function tbUi:CallPartnerGroup(szFunc, ...)
  if me.nLevel <= PersonalFuben.NoviceLevel then
    return
  end
  if not self.PartnerInfo[szFunc] then
    assert(false, "HomeScreenTask CallPartnerGroup fail !!" .. szFunc)
    return
  end
  self.PartnerInfo[szFunc](self.PartnerInfo, ...)
end
function tbUi:SetPartnerType(bIsPartnerType)
  if me.nLevel <= PersonalFuben.NoviceLevel then
    return
  end
  self.bIsPartnerType = bIsPartnerType
  if self.bIsPartnerType then
    self:Toggle_SetChecked("BtnTeam")
    self:ShowTeamInfo()
  else
    self.PartnerInfo:Close()
  end
end
function tbUi:RefreshTeam(szInfo, bShowTeamSetting, szSubType)
  if szInfo == "MemberChanged" then
    self.TeamInfo:Init()
  end
  if szSubType == "AddMember" then
    self:ShowTeamInfo()
  end
  if szInfo == "new" then
    self:ShowTeamInfo()
    Ui:ClearRedPointNotify("TeamBtnNew")
  end
  if szInfo == "NewApplyer" or szInfo == "NewInvite" then
    Ui:SetRedPointNotify("TeamBtnNew")
  end
  if bShowTeamSetting then
    local nActivityId = TeamMgr:GetCurActivityId()
    if nActivityId then
      Ui:OpenWindow("TeamPanel", "TeamActivity", nil, nil, nil, nActivityId)
    end
  end
  self.TeamInfo:Update()
end
function tbUi:OnMyHpChanged()
  if TeamMgr:HasTeam() then
    self.TeamInfo:Update()
  end
end
function tbUi:FoldTaskButton(bFold)
  self.pPanel:Button_SetCheck("BtnFold", bFold or false)
  self.pPanel:ChangeRotate("BtnFold", 0, bFold and 180 or 0, 0, 0)
  self.pPanel:ChangePosition("MainInfo", bFold and -300 or 0, -280, 0)
  UiNotify.OnNotify(UiNotify.emNOTIFY_ON_HOME_TASK_FOLD, bFold)
end
function tbUi:UpdateTask(nTaskId)
  self:RefreshTask()
  self:RefreshSubTask(nTaskId)
end
function tbUi:RefreshSubTask(nTaskId)
  self:UpdateSubTask()
  local function fnSetItem(itemObj, nIdx)
    local tbInfo = self.tbSubTask[nIdx]
    local szTitle, szDesc = tbInfo[2], tbInfo[3]
    itemObj.pPanel:Label_SetText("TaskTitle", szTitle)
    itemObj.pPanel:Label_SetText("TaskObject", szDesc)
    function itemObj.pPanel.OnTouchEvent()
      self:TrackSubTask(nIdx)
    end
  end
  self.ScrollView:Update(#self.tbSubTask, fnSetItem)
  self.ScrollView:GoTop()
  if nTaskId and self.tbSubTask and next(self.tbSubTask) then
    local nFirstTaskId = self.tbSubTask[1][1]
    if nFirstTaskId == nTaskId and Task:IsCanSubmit(nTaskId) then
      self:PlayMisstionAni("MisstionComplete_Sub")
    end
  end
end
function tbUi:ChangePlayerLevel()
  self.pPanel:SetActive("BtnFold", me.nLevel > PersonalFuben.NoviceLevel)
  self.pPanel:SetActive("BtnTeam", me.nLevel > PersonalFuben.NoviceLevel)
end
function tbUi:Toggle_SetChecked(szName)
  self.pPanel:Toggle_SetChecked("BtnTask", szName == "BtnTask")
  self.pPanel:Toggle_SetChecked("BtnTeam", szName == "BtnTeam")
end
function tbUi:UpdateSubTask()
  self.tbSubTask = Task:GetUpdatingTask()
end
function tbUi:TrackSubTask(nIdx)
  if self.tbSubTask and self.tbSubTask[nIdx] then
    Task:TrackUpdatingTask(self.tbSubTask[nIdx][1])
  end
end
function tbUi:OnPGInit()
  self:SetPartnerType(true)
  self.PartnerInfo:Init()
end
function tbUi:OnPGClose()
  self:SetPartnerType(false)
end
function tbUi:OnPGPartnerDeath(nPos)
  self.PartnerInfo:OnPartnerDeath(nPos)
end
function tbUi:OnPGNpcChange(bIsAdd, nNpcId, nPos)
  if bIsAdd then
    self.PartnerInfo:OnAddPartnerNpc(nNpcId, nPos)
  else
    self.PartnerInfo:OnRemovePartnerNpc(nNpcId)
  end
end
function tbUi:OnPGSwitchGroup(nGroupId, bFixGroupID)
  if bFixGroupID then
    self.PartnerInfo:SwitchToGroup(nGroupId, bFixGroupID)
  end
end
function tbUi:OnNoOperateUpdate(nLastOperateTime, nTimeNow)
  if Ui:WindowVisible("SituationalDialogue") or Ui:WindowVisible("TaskFinish") then
    return
  end
  if me.nLevel <= 5 or me.nLevel >= 40 or nTimeNow - nLastOperateTime < self.nNoOperationTime then
    return
  end
  local tbTask = Task:GetCurMainTask(me)
  if tbTask.tbTargetInfo.MinLevel and tbTask.tbTargetInfo.MinLevel > me.nLevel then
    return
  end
  self.nAutoFinishTaskId = tbTask.nTaskId
  self.tbOnClick.MainTask(self)
end
function tbUi:OnSwitchHousePlace()
  self:FoldTaskButton(House:IsIndoor(me))
end
tbUi.tbOnClick = {}
function tbUi.tbOnClick:BtnFold()
  local bPush = self.pPanel:Button_GetCheck("BtnFold")
  local szAni = bPush and "HomeScreenTaskRetract" or "HomeScreenTaskStretch"
  self.pPanel:PlayUiAnimation(szAni, false, false, {})
  UiNotify.OnNotify(UiNotify.emNOTIFY_ON_HOME_TASK_FOLD, bPush)
end
function tbUi.tbOnClick:MainTask()
  local szMapType = Map:GetClassDesc(me.nMapTemplateId)
  if szMapType == "fuben" or szMapType == "battle" then
    me.CenterMsg("当前地图无法自动进行任务")
    return
  end
  local tbMainTask = Task:GetCurMainTask(me)
  if not tbMainTask then
    self:Clear()
    return
  end
  Task:OnTrack(tbMainTask.nTaskId)
end
function tbUi.tbOnClick:BtnTask()
  if self.bNoShowTask then
    self:ShowTeamInfo()
    me.CenterMsg("当前地图不可切换到任务列表")
    return
  end
  self:Toggle_SetChecked("BtnTask")
  if self.pPanel:IsActive("TaskInfo") then
    local szMapType = Map:GetClassDesc(me.nMapTemplateId)
    if szMapType == "fuben" or szMapType == "battle" then
      me.CenterMsg("当前地图无法打开任务界面")
      return
    end
    Ui:OpenWindow("Task")
    return
  end
  self:ShowTaskInfo()
end
function tbUi.tbOnClick:BtnTeam()
  local nForbidMap = Player:GetServerSyncData("ForbidTeamAllInfo") or 0
  if nForbidMap == me.nMapTemplateId then
    me.CenterMsg("当前地图不能操作")
    return
  end
  self:Toggle_SetChecked("BtnTeam")
  local bRedPoint = self.pPanel:IsActive("NewTeamApply")
  local bOnTeamTab = self.pPanel:IsActive("TeamInfo")
  if (bOnTeamTab or bRedPoint) and not self.bIsPartnerType then
    Ui:OpenWindow("TeamPanel", "TeamDetail", bRedPoint)
    Ui:ClearRedPointNotify("TeamBtnNew")
  end
  if bOnTeamTab and self.bIsPartnerType then
    me.CenterMsg("当前不允许使用组队")
  end
  self:ShowTeamInfo()
end
function tbUi.tbOnClick:BtnInfo()
  local nMapTemplateId = me.nMapTemplateId
  if ImperialTomb:IsEmperorMapByTemplate(nMapTemplateId) or ImperialTomb:IsEmperorMirrorMapByTemplate(nMapTemplateId) then
    Ui:OpenWindow("BossLeaderOutputPanel", "ImperialTomb", "秦始皇", ImperialTomb.EMPEROR_RANK_TIPS, ImperialTomb:GetEmperorDmgInfo())
  elseif ImperialTomb:IsFemaleEmperorMapByTemplate(nMapTemplateId) or ImperialTomb:IsFemaleEmperorMirrorMapByTemplate(nMapTemplateId) then
    Ui:OpenWindow("BossLeaderOutputPanel", "ImperialTomb", "武则天", ImperialTomb.FEMALE_EMPEROR_RANK_TIPS, ImperialTomb:GetEmperorDmgInfo())
  elseif ImperialTomb:IsBossMapByTemplate(nMapTemplateId) then
    local tbDmg, szTargetName = ImperialTomb:GetBossDmgInfo(me.nMapId)
    szTargetName = szTargetName or ImperialTomb:GetBossNameByIndex(ImperialTomb.nMapParam) or ""
    Ui:OpenWindow("BossLeaderOutputPanel", "ImperialTombBoss", szTargetName, ImperialTomb.BOSS_RANK_TIPS, tbDmg)
  elseif ImperialTomb:IsFemaleEmperorBossMapByTemplate(nMapTemplateId) then
    local tbDmg, szTargetName = ImperialTomb:GetBossDmgInfo(me.nMapId)
    szTargetName = szTargetName or ImperialTomb:GetBossNameByIndex(ImperialTomb.nMapParam) or ""
    Ui:OpenWindow("BossLeaderOutputPanel", "ImperialTombBoss", szTargetName, ImperialTomb.FEMALE_BOSS_RANK_TIPS, tbDmg)
  elseif InDifferBattle.bRegistNotofy then
    InDifferBattle:CheckOpenIsShowHomeScreenDmgBtn()
  else
    local szOpenName = Player:GetServerSyncData("OpenBtnInfo")
    if szOpenName == string.format("BossLeaderOutputPanel:%s", nMapTemplateId or 0) then
      Ui:OpenWindow("BossLeaderOutputPanel", "BossLeader")
    end
  end
end
