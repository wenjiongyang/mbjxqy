local tbUi = Ui:CreateClass("TeammateSelectPop")
function tbUi:OnOpen(tbTeammateData)
  self.tbTeammateData = tbTeammateData
  local nFollowNpcId = AutoFight:GetFollowingNpcId()
  local bCaptain = TeamMgr:IsCaptain()
  local nForbidMap = Player:GetServerSyncData("ForbidTeamSelectPopCaptain") or 0
  if nForbidMap == me.nMapTemplateId then
    bCaptain = false
  end
  if me.dwID == tbTeammateData.nPlayerID then
    self.pPanel:SetActive("LeaderPop", false)
    self.pPanel:SetActive("MemberPop", false)
    self.pPanel:SetActive("MyselfPop", true)
    self.pPanel:SetActive("BtnGroup1", not bCaptain)
    self.pPanel:SetActive("BtnGroup2", bCaptain)
    if InDifferBattle.bRegistNotofy then
      self.pPanel:SetActive("BtnSendPos1", false)
      self.pPanel:SetActive("BtnSendPos2", false)
    else
      self.pPanel:SetActive("BtnSendPos1", true)
      self.pPanel:SetActive("BtnSendPos2", true)
    end
  elseif bCaptain then
    self.pPanel:SetActive("LeaderPop", true)
    self.pPanel:SetActive("MemberPop", false)
    self.pPanel:SetActive("MyselfPop", false)
    self.pPanel:SetActive("BtnFollowAttackL", nFollowNpcId ~= tbTeammateData.nNpcID)
    self.pPanel:SetActive("BtnStopFollowAttackL", nFollowNpcId == tbTeammateData.nNpcID)
  else
    self.pPanel:SetActive("LeaderPop", false)
    self.pPanel:SetActive("MyselfPop", false)
    self.pPanel:SetActive("MemberPop", true)
    self.pPanel:SetActive("BtnFollowAttack", nFollowNpcId ~= tbTeammateData.nNpcID)
    self.pPanel:SetActive("BtnStopFollowAttack", nFollowNpcId == tbTeammateData.nNpcID)
  end
end
function tbUi:OnScreenClick()
  Ui:CloseWindow(self.UI_NAME)
end
tbUi.tbOnClick = tbUi.tbOnClick or {}
function tbUi.tbOnClick:BtnKickOut()
  if not TeamMgr:CanClientOperTeam(me.nMapTemplateId) then
    me.CenterMsg("当前地图不允许组队操作")
    return
  end
  local function fnConfirm()
    TeamMgr:KickOutMember(self.tbTeammateData.nPlayerID)
    Ui:CloseWindow(self.UI_NAME)
  end
  me.MsgBox(string.format("是否将%s踢出队伍?", self.tbTeammateData.szName), {
    {"确定", fnConfirm},
    {"取消"}
  })
end
function tbUi.tbOnClick:BtnFollowAttack()
  local nNpcId = self.tbTeammateData.nNpcID
  local tbTeammate = TeamMgr:GetMemberData(nNpcId)
  if not tbTeammate then
    me.CenterMsg("无法找到队友")
    return
  end
  if InDifferBattle:IsDeathInBattle() then
    return
  end
  if me.nMapId ~= tbTeammate.nMapId then
    me.MsgBox("队友不在本地图，是否确定继续跟战前往？", {
      {
        "确定",
        function()
          AutoFight:StartFollowTeammate(self.tbTeammateData.nNpcID)
        end
      },
      {"取消"}
    })
    Ui:CloseWindow(self.UI_NAME)
    return
  end
  AutoFight:StartFollowTeammate(self.tbTeammateData.nNpcID)
  Ui:CloseWindow(self.UI_NAME)
end
function tbUi.tbOnClick:BtnStopFollowAttack()
  if InDifferBattle:IsDeathInBattle() then
    return
  end
  AutoFight:StopFollowTeammate()
  AutoFight:ResetFightState()
  UiNotify.OnNotify(UiNotify.emNOTIFY_CHANGE_AUTOFIGHT)
  Ui:CloseWindow(self.UI_NAME)
end
function tbUi.tbOnClick:BtnTransmit()
  if InDifferBattle:IsDeathInBattle() then
    return
  end
  local tbMember = self.tbTeammateData
  if InDifferBattle.bRegistNotofy then
    InDifferBattle:GotoTeamateRoom(tbMember)
  else
    AutoPath:GotoAndCall(tbMember.nMapId, tbMember.nPosX, tbMember.nPosY, nil, nil, tbMember.nMapTemplateId)
  end
  Ui:CloseWindow(self.UI_NAME)
end
function tbUi.tbOnClick:BtnTransferLeader()
  if not TeamMgr:CanClientOperTeam(me.nMapTemplateId) then
    me.CenterMsg("当前地图不允许组队操作")
    return
  end
  local function fnConfirm()
    TeamMgr:ChangeCaptain(self.tbTeammateData.nPlayerID)
    Ui:CloseWindow(self.UI_NAME)
  end
  me.MsgBox(string.format("是否将%s设为队长?", self.tbTeammateData.szName), {
    {"确定", fnConfirm},
    {"取消"}
  })
end
function tbUi.tbOnClick:BtnSendPos1()
  local nNow = GetTime()
  if self.nNextSendPosTime and nNow < self.nNextSendPosTime then
    me.CenterMsg("发送坐标过于频繁")
    return
  end
  self.nNextSendPosTime = nNow + 5
  local nMapId, nPosX, nPosY = Decoration:GetPlayerSettingOrgPos(me)
  local szMapName = me.szMapName
  local nMapTemplateId = me.nMapTemplateId
  if ImperialTomb:IsEmperorMapByTemplate(nMapTemplateId) or ImperialTomb:IsBossMapByTemplate(nMapTemplateId) or ImperialTomb:IsFemaleEmperorMapByTemplate(nMapTemplateId) or ImperialTomb:IsFemaleEmperorBossMapByTemplate(nMapTemplateId) then
    local nTmpMapId
    nMapTemplateId, nTmpMapId, nPosX, nPosY = ImperialTomb:GetCurRoomEnterPos()
    nMapId = nMapTemplateId
    szMapName = Map:GetMapName(nMapTemplateId)
  end
  if House.nHouseMapId and nMapId == House.nHouseMapId then
    szMapName = string.format("%s的家", House.szName)
  end
  local szLocaltion = string.format("<%s(%d,%d)>我在这里#36#36#36", szMapName, nPosX * Map.nShowPosScale, nPosY * Map.nShowPosScale)
  ChatMgr:SetChatLink(ChatMgr.LinkType.Position, {
    nMapId,
    nPosX,
    nPosY,
    nMapTemplateId
  })
  ChatMgr:SendMsg(ChatMgr.ChannelType.Team, szLocaltion)
end
function tbUi.tbOnClick:BtnLeaveTeam1()
  if not TeamMgr:CanClientOperTeam(me.nMapTemplateId) then
    me.CenterMsg("当前地图不允许组队操作")
    return
  end
  local function fnConfirm()
    TeamMgr:Quite()
    Ui:CloseWindow(self.UI_NAME)
  end
  me.MsgBox("是否退出队伍?", {
    {"确定", fnConfirm},
    {"取消"}
  })
end
function tbUi.tbOnClick:BtnTeammateBack()
  local nNow = GetTime()
  if self.nNextTeammateBackTime and nNow < self.nNextTeammateBackTime then
    me.CenterMsg("队员召回操作过于频繁，请稍后再试")
    return
  end
  self.nNextTeammateBackTime = nNow + 5
  TeamMgr:AskTeammate2Follow()
  Ui:CloseWindow(self.UI_NAME)
end
function tbUi.tbOnClick:BtnCancelBack()
  local nNow = GetTime()
  if self.nNextTeammateCancelBackTime and nNow < self.nNextTeammateCancelBackTime then
    me.CenterMsg("取消跟战操作过于频繁，请稍后再试")
    return
  end
  self.nNextTeammateCancelBackTime = nNow + 5
  TeamMgr:AskTeammateNot2Follow()
  Ui:CloseWindow(self.UI_NAME)
end
tbUi.tbOnClick.BtnFollowAttackL = tbUi.tbOnClick.BtnFollowAttack
tbUi.tbOnClick.BtnTransmitL = tbUi.tbOnClick.BtnTransmit
tbUi.tbOnClick.BtnStopFollowAttackL = tbUi.tbOnClick.BtnStopFollowAttack
tbUi.tbOnClick.BtnSendPos2 = tbUi.tbOnClick.BtnSendPos1
tbUi.tbOnClick.BtnLeaveTeam2 = tbUi.tbOnClick.BtnLeaveTeam1
