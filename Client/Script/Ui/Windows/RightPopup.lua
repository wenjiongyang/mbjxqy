local tbUi = Ui:CreateClass("RightPopup")
local MAX_RIGHT_NUM = 20
local tbAllGroups = {
  Friend = {
    "CheckInformation",
    "TeamApply",
    "InviteInTeam",
    "FamilyApply",
    "ChuangGong",
    "GiftGiving",
    "DeleteFriend",
    "DelPrivateChat",
    "ApplyAsTeacher",
    "ApplyAsStudent",
    "PlayerLabel",
    "PeekPlayer",
    "EnterHome"
  },
  RankView = {
    "ChatPrivate",
    "CheckInformation",
    "TeamApply",
    "InviteInTeam",
    "FamilyApply",
    "FriendOperation",
    "EnterHome"
  },
  RankKinView = {
    "FamilyApply"
  },
  kin = {
    "ChatPrivate",
    "CheckInformation",
    "FriendOperation",
    "TeamApply",
    "InviteInTeam",
    "CareerOperation",
    "ChuangGong",
    "Promotion",
    "ChatForbid",
    "KickOut",
    "ApplyAsTeacher",
    "ApplyAsStudent",
    "EnterHome"
  },
  Team = {
    "CheckInformation",
    "FriendOperation",
    "FamilyApply",
    "ChangeTeamCaptain",
    "KickOutTeam",
    "EnterHome"
  },
  RoleSelect = {
    "ChatPrivate",
    "CheckInformation",
    "TeamApply",
    "InviteInTeam",
    "FriendOperation",
    "FamilyApply",
    "ChuangGong",
    "BlackHim",
    "PkExcercise",
    "DelPrivateChat",
    "ApplyAsTeacher",
    "ApplyAsStudent",
    "PlayerLabel",
    "EnterHome"
  },
  ChatRoleSelect = {
    "ChatPrivate",
    "CheckInformation",
    "ChatPlayerMsg",
    "TeamApply",
    "InviteInTeam",
    "FriendOperation",
    "FamilyApply",
    "ChuangGong",
    "BlackHim",
    "ApplyAsTeacher",
    "ApplyAsStudent",
    "PlayerLabel",
    "EnterHome"
  },
  FactionBattleWatch = {
    "FBWPlayer1",
    "FBWPlayer2",
    "FBWQuit"
  },
  HouseRoomerSelect = {
    "CheckInformation",
    "FriendOperation",
    "SetDecorationAccess",
    "KickRoomer"
  }
}
local tbChuangGongShow = {kin = true}
local tbButtonSetting = {
  TeamApply = {
    fnName = function(tbData)
      return "申请入队"
    end,
    fnOnClick = function(self)
      TeamMgr:Apply(self.tbData.dwTeamID, self.tbData.dwRoleId)
    end,
    fnAvaliable = function(tbData)
      if TeamMgr:HasTeam() then
        return false
      end
      if tbData.dwTeamID then
        if tbData.dwTeamID ~= 0 then
          return true
        else
          return false
        end
      end
      return true
    end
  },
  InviteInTeam = {
    fnName = function(tbData)
      return "邀请入队"
    end,
    fnOnClick = function(self)
      TeamMgr:Invite(self.tbData.dwRoleId)
    end,
    fnAvaliable = function(tbData)
      if tbData.dwTeamID then
        if tbData.dwTeamID ~= 0 then
          return false
        else
          return true
        end
      end
      return true
    end
  },
  CheckInformation = {
    fnName = function(tbData)
      return "查看信息"
    end,
    fnOnClick = function(self)
      ViewRole:OpenWindow("ViewRolePanel", self.tbData.dwRoleId)
    end,
    fnAvaliable = function(tbData)
      return true
    end
  },
  FamilyApply = {
    fnName = function(tbData)
      if tbData.dwKinId and tbData.dwKinId ~= 0 and me.dwKinId == 0 then
        return "家族申请"
      else
        return "家族邀请"
      end
    end,
    fnOnClick = function(self)
      local dwKinId = self.tbData.dwKinId
      if me.dwKinId == 0 then
        if dwKinId and dwKinId ~= 0 then
          Kin:ApplyKin(dwKinId)
        else
          me.CenterMsg("暂时获取不到他的家族")
        end
      else
        Kin:Invite(self.tbData.dwRoleId)
      end
    end,
    fnAvaliable = function(tbData)
      local dwKinId = tbData.dwKinId
      if me.dwKinId == 0 then
        if dwKinId and dwKinId ~= 0 then
          return true
        end
        return false
      else
        if dwKinId and dwKinId ~= 0 then
          return false
        end
        return true
      end
    end
  },
  GiftGiving = {
    fnName = function(tbData)
      local tbRoleInfo = FriendShip:GetFriendDataInfo(tbData.dwRoleId)
      local nSex = Gift:CheckSex(tbRoleInfo.nFaction)
      if nSex == Gift.Sex.Boy then
        return "赠送物品"
      elseif nSex == Gift.Sex.Girl then
        return "赠送物品"
      else
        return "赠送物品"
      end
    end,
    fnOnClick = function(self)
      local tbRoleInfo = FriendShip:GetFriendDataInfo(self.tbData.dwRoleId)
      Ui:OpenWindow("GiftSystem", self.tbData.dwRoleId)
    end,
    fnAvaliable = function(tbData)
      return true
    end
  },
  DeleteFriend = {
    fnName = function(tbData)
      return "删除好友"
    end,
    fnOnClick = function(self)
      FriendShip:RequetDelFriend(self.tbData.dwRoleId)
    end,
    fnAvaliable = function(tbData)
      return true
    end
  },
  FriendOperation = {
    fnName = function(tbData)
      return "申请好友"
    end,
    fnOnClick = function(self)
      FriendShip:OpenAddFriendUI({
        dwID = self.tbData.dwRoleId,
        szName = self.tbData.szName
      })
    end,
    fnAvaliable = function(tbData)
      if me.dwID == tbData.dwRoleId or FriendShip:IsFriend(me.dwID, tbData.dwRoleId) then
        return false
      end
      return true
    end
  },
  ChuangGong = {
    fnName = function(tbMemberData)
      if tbMemberData.nLevel > me.nLevel then
        return "请求传功"
      else
        return "对其传功"
      end
    end,
    fnOnClick = function(self)
      local tbMemberData = self.tbData
      local nHisLevel = tbMemberData.nLevel
      local fnRequest
      if nHisLevel < me.nLevel then
        function fnRequest()
          ChuangGong:RequestSendChuangGong(tbMemberData.nMemberId or tbMemberData.dwID, nHisLevel)
        end
        if ChuangGong:CheckMap() then
          fnRequest()
        else
          ChuangGong:GoSafe(fnRequest)
          Ui:CloseWindow("KinDetailPanel")
        end
      elseif nHisLevel > me.nLevel then
        function fnRequest()
          ChuangGong:RequestGetChuangGong(tbMemberData.nMemberId or tbMemberData.dwID, nHisLevel)
        end
        if ChuangGong:CheckMap() then
          fnRequest()
        else
          ChuangGong:GoSafe(fnRequest)
          Ui:CloseWindow("KinDetailPanel")
        end
      else
        me.CenterMsg("双方等级差不足3级，无法传功")
      end
    end,
    fnAvaliable = function(tbData)
      if tbData.szKind and tbChuangGongShow[tbData.szKind] then
        return true
      end
      local dwKinId = tbData.dwKinId
      if not (dwKinId and dwKinId ~= 0 and me.dwKinId) or me.dwKinId == 0 or me.dwKinId ~= dwKinId then
        return false
      end
      return true
    end
  },
  CareerOperation = {
    fnName = function(tbMemberData)
      return "职位任命"
    end,
    fnOnClick = function(self)
      self:SwitchScenddMenu("CareerOperation")
      return true
    end,
    fnAvaliable = function(tbMemberData)
      if Kin:AmILeader() then
        return true
      end
      local tbMyMemberData = Kin:GetMyMemberData() or {}
      if tbMyMemberData.nCareer ~= Kin.Def.Career_Master and tbMemberData.nCareer <= tbMyMemberData.nCareer then
        return false
      end
      local tbAppointAuthority = {
        Kin.Def.Authority_GrantMaster,
        Kin.Def.Authority_GrantOlder,
        Kin.Def.Authority_GrantViceMaster
      }
      local tbMyMemberData = Kin:GetMyMemberData() or {}
      for _, authority in pairs(tbAppointAuthority) do
        if Kin:CheckMyAuthority(authority) then
          return true
        end
      end
      return false
    end
  },
  Promotion = {
    fnName = function(tbMemberData)
      return "见习转正"
    end,
    fnOnClick = function(self)
      RemoteServer.OnKinRequest("PromoteMember", self.tbData.nMemberId)
    end,
    fnAvaliable = function(tbMemberData)
      return tbMemberData.nCareer == Kin.Def.Career_New and Kin:CheckMyAuthority(Kin.Def.Authority_Promotion)
    end
  },
  ChatForbid = {
    fnName = function(tbMemberData)
      local bChatForbid = tbMemberData.nForbidTime and tbMemberData.nForbidTime > GetTime()
      if bChatForbid then
        return "解除禁言"
      else
        return "聊天禁言"
      end
    end,
    fnOnClick = function(self)
      local bChatForbid = self.tbData.nForbidTime and self.tbData.nForbidTime > GetTime()
      local szMsg = string.format("确定对 [FFFE0D]%s[-] 禁言2小时吗？", self.tbData.szName)
      if bChatForbid then
        szMsg = string.format("确定要取消对 [FFFE0D]%s[-] 的禁言吗？", self.tbData.szName)
      end
      me.MsgBox(szMsg, {
        {
          "确认",
          function()
            RemoteServer.OnKinRequest("ChatForbid", self.tbData.nMemberId, bChatForbid)
          end
        },
        {"取消"}
      })
    end,
    fnAvaliable = function(tbMemberData)
      local myMemberData = Kin:GetMyMemberData()
      if not Kin:CheckMyAuthority(Kin.Def.Authority_ChatForbid) then
        return false
      end
      local nOtherCareer = Kin:GetLeaderId() == tbMemberData.nMemberId and Kin.Def.Career_Leader or tbMemberData.nCareer
      return Kin:CareerCmp(myMemberData.nCareer, nOtherCareer) > 0
    end
  },
  Retire = {
    fnName = function(tbMemberData)
      if tbMemberData.nCareer == Kin.Def.Career_Normal then
        return "强制退隐"
      else
        return "解除退隐"
      end
    end,
    fnOnClick = function(self)
      local tbMemberData = self.tbData
      if tbMemberData.nCareer == Kin.Def.Career_Normal then
        RemoteServer.OnKinRequest("ChangeRetire", tbMemberData.nMemberId, Kin.Def.Career_Retire)
        tbMemberData.nCareer = Kin.Def.Career_Retire
      elseif tbMemberData.nCareer == Kin.Def.Career_Retire then
        RemoteServer.OnKinRequest("ChangeRetire", tbMemberData.nMemberId, Kin.Def.Career_Normal)
        tbMemberData.nCareer = Kin.Def.Career_Normal
      end
    end,
    fnAvaliable = function(tbMemberData)
      return Kin:CheckMyAuthority(Kin.Def.Authority_Retire) and (tbMemberData.nCareer == Kin.Def.Career_Normal or tbMemberData.nCareer == Kin.Def.Career_Retire)
    end
  },
  KickOut = {
    fnName = function(tbData)
      return "踢出家族"
    end,
    fnOnClick = function(self)
      local tbMemberData = self.tbData
      local msg = string.format("确定要将 [FFFE0D]%s[-] 踢出家族吗？", tbMemberData.szName)
      local function fnAgree()
        RemoteServer.OnKinRequest("KickOutMember", tbMemberData.nMemberId)
        Ui:CloseWindow("MessageBox")
      end
      local fnClose = function()
        Ui:CloseWindow("MessageBox")
      end
      Ui:OpenWindow("MessageBox", msg, {
        {fnAgree},
        {fnClose}
      }, {"确定", "取消"})
    end,
    fnAvaliable = function(tbMemberData)
      local myMemberData = Kin:GetMyMemberData()
      if myMemberData.nCareer >= tbMemberData.nCareer then
        return false
      end
      return Kin:CheckMyAuthority(Kin.Def.Authority_KickOut)
    end
  },
  BlackHim = {
    fnName = function(tbData)
      return "拉黑"
    end,
    fnOnClick = function(self)
      FriendShip:BlackHim(self.tbData.dwRoleId)
    end,
    fnAvaliable = function(tbData)
      local nOtherId = tbData.dwRoleId
      return TeacherStudent:CanDelFriend(nOtherId) and SwornFriends:CanDelFriend(nOtherId) and not FriendShip:IsHeInMyBlack(nOtherId) and Wedding:CheckDelFriend(me.dwID, nOtherId)
    end
  },
  FBWPlayer1 = {
    fnName = function()
      return FactionBattle.nWatchNpcId == FactionBattle.tbWatchInfo.players[1].id and FactionBattle.tbWatchInfo.players[2].name or FactionBattle.tbWatchInfo.players[1].name
    end,
    fnOnClick = function()
      local id = FactionBattle.nWatchNpcId == FactionBattle.tbWatchInfo.players[1].id and FactionBattle.tbWatchInfo.players[2].id or FactionBattle.tbWatchInfo.players[1].id
      FactionBattle:StartWatch(id)
      Ui:CloseWindow("QYHLeavePanel")
    end,
    fnAvaliable = function()
      return true
    end
  },
  FBWPlayer2 = {
    fnName = function()
      return FactionBattle.tbWatchInfo.players[2].name
    end,
    fnOnClick = function()
      local id = FactionBattle.tbWatchInfo.players[2].id
      FactionBattle:StartWatch(id)
      Ui:CloseWindow("QYHLeavePanel")
    end,
    fnAvaliable = function()
      return FactionBattle.nWatchNpcId <= 0
    end
  },
  FBWQuit = {
    fnName = function()
      return "退出观战"
    end,
    fnOnClick = function()
      FactionBattle:EndWatch(nil, true)
      Ui:OpenWindow("QYHLeavePanel", "FactionBattle")
    end,
    fnAvaliable = function()
      return FactionBattle.nWatchNpcId > 0
    end
  },
  ChangeTeamCaptain = {
    fnName = function()
      return "移交队长"
    end,
    fnOnClick = function(self)
      TeamMgr:ChangeCaptain(self.tbData.dwRoleId)
    end,
    fnAvaliable = function()
      return TeamMgr:IsCaptain()
    end
  },
  KickOutTeam = {
    fnName = function()
      return "请离队伍"
    end,
    fnOnClick = function(self)
      TeamMgr:KickOutMember(self.tbData.dwRoleId)
    end,
    fnAvaliable = function()
      return TeamMgr:IsCaptain()
    end
  },
  ChatPrivate = {
    fnName = function()
      return "密聊"
    end,
    fnOnClick = function(self)
      ChatMgr:OpenPrivateWindow(self.tbData.dwRoleId, self.tbData)
    end,
    fnAvaliable = function(tbData)
      if tbData.bFromChatList then
        return false
      end
      return me.nLevel >= ChatMgr:GetOpenLevel(ChatMgr.ChannelType.Private)
    end
  },
  ChatPlayerMsg = {
    fnName = function()
      return "文字表情"
    end,
    fnOnClick = function(self)
      local nFromIndex = self:GetClickMenuIndex("ChatPlayerMsg")
      local tbPos = self.pPanel:GetRealPosition("item" .. nFromIndex)
      local tbPosMain = self.pPanel:GetRealPosition("Main")
      Ui:OpenWindowAtPos("ChatRightPopup", tbPos.x + 200, tbPosMain.y + 145, self.tbData.szName)
      return true
    end,
    fnAvaliable = function(tbData)
      return true
    end
  },
  PkExcercise = {
    fnName = function()
      return "切磋"
    end,
    fnOnClick = function(self)
      RemoteServer.PkExcerciseRequest(self.tbData.dwRoleId)
    end,
    fnAvaliable = function(tbData)
      return not tbData.bFromChatList
    end
  },
  DelPrivateChat = {
    fnName = function()
      return "删除密聊"
    end,
    fnOnClick = function(self)
      ChatMgr:DelPrivateChat(self.tbData.dwRoleId)
    end,
    fnAvaliable = function(tbData)
      return tbData.bFromChatList or false
    end
  },
  ApplyAsTeacher = {
    fnName = function()
      return "收徒"
    end,
    fnOnClick = function(self)
      TeacherStudent:ApplyAsTeacher(self.tbData.dwRoleId)
    end,
    fnAvaliable = function(tbData)
      return TeacherStudent:CanAddStudent(false, tbData)
    end
  },
  ApplyAsStudent = {
    fnName = function()
      return "拜师"
    end,
    fnOnClick = function(self)
      TeacherStudent:ApplyAsStudent(self.tbData.dwRoleId)
    end,
    fnAvaliable = function(tbData)
      return TeacherStudent:CanAddTeacher(false, tbData)
    end
  },
  PlayerLabel = {
    fnName = function(tbMemberData)
      return "查看祝福"
    end,
    fnOnClick = function(self)
      Activity.WomanAct:OpenLabelWindow(self.tbData.dwRoleId)
    end,
    fnAvaliable = function(tbData)
      return Activity:__IsActInProcessByType("WomanAct")
    end
  },
  PeekPlayer = {
    fnName = function()
      return "远程观战"
    end,
    fnOnClick = function(self)
      RemoteServer.PeekPlayer(self.tbData.dwRoleId)
    end,
    fnAvaliable = function(tbData)
      return true
    end
  },
  EnterHome = {
    fnName = function()
      return "访问家园"
    end,
    fnOnClick = function(self)
      RemoteServer.EnterHome(self.tbData.dwRoleId)
    end,
    fnAvaliable = function(tbData)
      local nLevel = tbData.nLevel
      if not nLevel then
        local tbRoleInfo = FriendShip:GetFriendDataInfo(tbData.dwRoleId)
        if tbRoleInfo then
          nLevel = tbRoleInfo.nLevel
        end
      end
      if nLevel and nLevel < House.nMinOpenLevel then
        return false
      end
      return GetTimeFrameState(House.szOpenTimeFrame) == 1
    end
  },
  KickRoomer = {
    fnName = function(tbData)
      return "请离家园"
    end,
    fnOnClick = function(self)
      Ui:OpenWindow("MessageBox", string.format("确定要请离 [FFFE0D]%s[-] 吗？", self.tbData.szRoleName), {
        {
          function()
            RemoteServer.MakeCheckOut(self.tbData.dwRoleId)
          end
        },
        {}
      })
    end,
    fnAvaliable = function(tbData)
      if not House:IsInOwnHouse(me) then
        return false
      end
      if Wedding:IsLover(me.dwID, tbData.dwRoleId) then
        return false
      end
      return true
    end
  },
  SetDecorationAccess = {
    fnName = function(tbData)
      if not House.tbAccessInfo[House.nAccessType_Decoration] or not House.tbAccessInfo[House.nAccessType_Decoration][tbData.dwRoleId] then
        return "允许装修"
      end
      return "禁止装修"
    end,
    fnOnClick = function(self)
      local bAccess = false
      if not House.tbAccessInfo[House.nAccessType_Decoration] or not House.tbAccessInfo[House.nAccessType_Decoration][self.tbData.dwRoleId] then
        bAccess = true
      end
      RemoteServer.ChangeHouseDecorationAccess(self.tbData.dwRoleId, bAccess)
    end,
    fnAvaliable = function(tbData)
      if not House:IsInOwnHouse(me) then
        return false
      end
      if Wedding:IsLover(me.dwID, tbData.dwRoleId) then
        return false
      end
      return true
    end
  }
}
function tbUi:InitWidhtParams()
  local tbSize = self.pPanel:Widget_GetSize("OptionGroup")
  self.nGridWidth = tbSize.x
  local tbSize = self.pPanel:Widget_GetSize("item1")
  self.nGridHeight = tbSize.y
end
function tbUi:OnOpen(szKind, tbData, fnOnClose)
  self.fnOnClose = fnOnClose
  if not self.nGridWidth then
    self:InitWidhtParams()
  end
  tbData = Lib:CopyTB(tbData)
  self.tbData = tbData
  tbData.dwRoleId = tbData.dwRoleId or tbData.nMemberId
  local szName = tbData.szName
  local dwKinId = tbData.dwKinId
  tbData.dwID = tbData.dwRoleId
  if tbData.nNpcID then
    local pNpc = KNpc.GetById(tbData.nNpcID)
    if pNpc then
      tbData.dwTeamID = pNpc.dwTeamID
      szName = szName or pNpc.szName
      dwKinId = dwKinId or pNpc.dwKinId
      tbData.dwID = pNpc.nPlayerID ~= 0 and pNpc.nPlayerID or nil
    end
  end
  if not szName or not dwKinId then
    local tbRoleInfo = FriendShip:GetFriendDataInfo(tbData.dwRoleId)
    if tbRoleInfo then
      dwKinId = dwKinId or tbRoleInfo.dwKinId
      szName = szName or tbRoleInfo.szName
      tbData.nLevel = tbData.nLevel or tbRoleInfo.nLevel
      tbData.dwID = tbRoleInfo.dwID
    end
  end
  tbData.szName = szName or "对方"
  tbData.dwKinId = dwKinId
  tbData.szKind = szKind
  local tbOrginGroup = tbAllGroups[szKind]
  local tbGroup = {}
  self.tbGroup = tbGroup
  local nUseSize = 0
  for i, v in ipairs(tbOrginGroup) do
    local tbSetInfo = tbButtonSetting[v]
    local bShow = tbSetInfo.fnAvaliable(tbData)
    if bShow then
      nUseSize = nUseSize + 1
      table.insert(tbGroup, v)
      self.pPanel:SetActive("item" .. nUseSize, true)
      self.pPanel:Label_SetText("Label" .. nUseSize, tbSetInfo.fnName(tbData))
    end
  end
  if #tbGroup == 0 then
    return 0
  end
  for i = nUseSize + 1, MAX_RIGHT_NUM do
    self.pPanel:SetActive("item" .. i, false)
  end
  local nGridSize = self.pPanel
  if nUseSize <= 10 then
    self.pPanel:Widget_SetSize("OptionGroup", self.nGridWidth / 2, 6 + self.nGridHeight * nUseSize)
  else
    self.pPanel:Widget_SetSize("OptionGroup", self.nGridWidth, 6 + self.nGridHeight * 10)
  end
  self.pPanel:SetActive("OptionGroupSecond", false)
end
function tbUi:OnClose()
  if self.fnOnClose then
    self.fnOnClose()
    self.fnOnClose = nil
  end
end
function tbUi:GetClickMenuIndex(szFrom)
  local nFromIndex = 1
  for i, v in ipairs(self.tbGroup) do
    if v == szFrom then
      nFromIndex = i
      break
    end
  end
  return nFromIndex
end
function tbUi:SwitchScenddMenu(szFrom)
  local bActive = self.pPanel:IsActive("OptionGroupSecond")
  if not bActive then
    local nFromIndex = self:GetClickMenuIndex(szFrom)
    local tbTarPos = self.pPanel:GetWorldPosition("item" .. nFromIndex)
    tbTarPos = self.pPanel:GetRelativePosition("Main", tbTarPos.x, tbTarPos.y)
    self.pPanel:ChangePosition("OptionGroupSecond", tbTarPos.x + 200, tbTarPos.y)
  end
  self.pPanel:SetActive("OptionGroupSecond", not bActive)
end
function tbUi:OnClickItem(nIndex)
  local tbSetInfo = tbButtonSetting[self.tbGroup[nIndex]]
  if not tbSetInfo.fnOnClick(self) then
    Ui:CloseWindow(self.UI_NAME)
  end
end
tbUi.tbOnClick = {}
for i = 1, MAX_RIGHT_NUM do
  tbUi.tbOnClick["item" .. i] = function(self)
    self:OnClickItem(i)
  end
end
function tbUi:OnScreenClick()
  Ui:CloseWindow(self.UI_NAME)
end
local GetItems = function(nCareer)
  local tbItems = {}
  local tbMemberList = Kin:GetMemberList()
  for _, tbData in pairs(tbMemberList or {}) do
    if tbData.nCareer == nCareer then
      table.insert(tbItems, {
        nMemberId = tbData.nMemberId,
        szName = tbData.szName
      })
    end
  end
  return tbItems
end
local tbBtn2Career = {
  Position1 = Kin.Def.Career_Master,
  Position2 = Kin.Def.Career_ViceMaster,
  Position3 = Kin.Def.Career_Elder,
  Position4 = Kin.Def.Career_Mascot
}
for szBtnName, nCareer in pairs(tbBtn2Career) do
  tbUi.tbOnClick[szBtnName] = function(self)
    if self.tbData.nCareer == nCareer then
      me.CenterMsg(string.format("%s已经是%s了", self.tbData.szName, Kin.Def.Career_Name[nCareer]))
      return
    end
    local authority = Kin.Def.Career2Authority[nCareer]
    if not Kin:CheckMyAuthority(authority) then
      me.CenterMsg("无权任命")
      return
    end
    if Kin:IsCareerClosed(nCareer) then
      me.CenterMsg("敬请期待！")
      return
    end
    local nMaxCount = Kin:GetCareerMaxCount(nCareer)
    if nMaxCount <= 0 then
      me.CenterMsg("3级家族后开放此职位")
      return Ui:CloseWindow(self.UI_NAME)
    end
    local nCurCount = #GetItems(nCareer)
    if nMaxCount <= nCurCount then
      Ui:OpenWindow("KinChangeCareer", self.tbData.nMemberId, nCareer, self.tbData.szName)
      Ui:CloseWindow(self.UI_NAME)
      return
    end
    Kin:ChangeCareer(self.tbData.nMemberId, nCareer)
    Ui:CloseWindow(self.UI_NAME)
  end
end
