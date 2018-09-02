local emPLAYER_STATE_NORMAL = 2
local nInviteInterval = 60
local tbUi = Ui:CreateClass("DungeonInviteList")
local tbGrid = Ui:CreateClass("DungeonInviteListGrid")
function tbGrid:SetData(tbData)
  self.tbData = tbData
  if tbData.nImity then
    self.pPanel:SetActive("Intimity", true)
    if tbData.nImityLevel then
      self.pPanel:Label_SetText("IntimacyLevel", tbData.nImityLevel .. "级")
      self.pPanel:ProgressBar_SetValue("IntimacyBar", math.min(tbData.nImity / tbData.nMaxImity, 1))
      self.pPanel:Label_SetText("lbImityDesc", string.format("%d/%d", tbData.nImity, tbData.nMaxImity))
    end
  else
    self.pPanel:SetActive("Intimity", false)
  end
  local tbHonorInfo
  if tbData.nHonorLevel then
    tbHonorInfo = Player.tbHonorLevelSetting[tbData.nHonorLevel]
  end
  if tbHonorInfo then
    self.pPanel:SetActive("lbRoleName", true)
    self.pPanel:SetActive("lbRoleName2", false)
    self.pPanel:Label_SetText("lbRoleName", tbData.szName)
    self.pPanel:Sprite_Animation("PlayerTitle", tbHonorInfo.ImgPrefix)
  else
    self.pPanel:SetActive("lbRoleName", false)
    self.pPanel:SetActive("lbRoleName2", true)
    self.pPanel:Label_SetText("lbRoleName2", tbData.szName)
  end
  self.pPanel:Label_SetText("lbLevel", tbData.nLevel)
  local SpFaction = Faction:GetIcon(tbData.nFaction)
  local szPortrait, szAltas = PlayerPortrait:GetSmallIcon(tbData.nPortrait or tbData.nFaction)
  self.pPanel:Sprite_SetSprite("SpFaction", SpFaction)
  self.pPanel:Sprite_SetSprite("SpRoleHead", szPortrait, szAltas)
  self.pPanel:Toggle_SetChecked("CheckTeam", self.tbData.bCheck and true or false)
  if not Lib:IsEmptyStr(tbData.szNpcKinName) then
    self.pPanel:SetActive("FamilyName", true)
    self.pPanel:Label_SetText("FamilyName", tbData.szNpcKinName)
  else
    self.pPanel:SetActive("FamilyName", false)
  end
end
tbGrid.tbOnClick = {}
function tbGrid.tbOnClick:CheckTeam()
  self.tbData.bCheck = not self.tbData.bCheck
end
function tbUi:OnCreate()
  self.tbInvited = {}
end
function tbUi:OnOpenEnd(szType, fnInvite)
  self.fnInvite = fnInvite
  self.szType = szType
  self:UpdateTabBtn()
  local bIsTeamInvite = self.szType == "TeamInvite"
  self.pPanel:SetActive("tabNearby", bIsTeamInvite)
  self.pPanel:SetActive("tabFamily", Kin:HasKin())
  self.pPanel:SetActive("btnCenterInvite", bIsTeamInvite)
  self.pPanel:SetActive("btnInvite", not bIsTeamInvite)
  self.pPanel:SetActive("btnInviteAll", not bIsTeamInvite)
  self.pPanel:SetActive("btnRandomlySelected", not bIsTeamInvite)
end
function tbUi:Invite(dwID, bNotNotify)
  if self:IsInInterVal(dwID) then
    return
  end
  if self.fnInvite then
    self.fnInvite(dwID)
    return
  end
  RemoteServer.DungeonFubenInvite(dwID, bNotNotify)
end
function tbUi:IsInInterVal(dwRoleId)
  local nTimeNow = GetTime()
  if not self.tbInvited[dwRoleId] then
    self.tbInvited[dwRoleId] = nTimeNow + nInviteInterval
    return
  end
  if nTimeNow > self.tbInvited[dwRoleId] then
    self.tbInvited[dwRoleId] = nTimeNow + nInviteInterval
    return
  end
  return true
end
function tbUi:ShowNearBy()
  self.pPanel:SetActive("ScrollViewFriends", false)
  self.pPanel:SetActive("ScrollViewKin", false)
  self.pPanel:SetActive("ScrollViewNearby", true)
  local tbNpcs = me.GetNpc().GetNearbyNpcByRelation(Npc.RELATION_TYPE.Allow, Npc.RELATION.player)
  local szPatern = string.gsub(Kin.Def.szFullTitleFormat, "%%s", "(%%C+)")
  local tbItems = {}
  for _, tbNpc in pairs(tbNpcs) do
    local pNpc = KNpc.GetById(tbNpc.nNpcId or 0)
    if pNpc and pNpc.nPlayerID ~= 0 and pNpc.dwTeamID == 0 then
      table.insert(tbItems, {
        dwID = pNpc.nPlayerID,
        szName = pNpc.szName,
        nFaction = pNpc.nFaction,
        nLevel = pNpc.nLevel,
        nHonorLevel = pNpc.nHonorLevel or 0,
        szNpcKinName = string.match(pNpc.szKinTitle or "", szPatern)
      })
    end
  end
  local function fnSetNpcs(itemClass, index)
    itemClass:SetData(tbItems[index])
  end
  self.tbAllNearby = tbItems
  self.ScrollViewNearby:Update(tbItems, fnSetNpcs)
end
function tbUi:ShowFriends()
  self.pPanel:SetActive("ScrollViewFriends", true)
  self.pPanel:SetActive("ScrollViewKin", false)
  self.pPanel:SetActive("ScrollViewNearby", false)
  local tbAllFriend = FriendShip:GetAllFriendData()
  local tbQualifiedFriends = {}
  for i, v in ipairs(tbAllFriend) do
    if v.nState == emPLAYER_STATE_NORMAL then
      table.insert(tbQualifiedFriends, v)
    end
  end
  local fnSort = function(a, b)
    if a.nImity == b.nImity then
      return a.nHonorLevel > b.nHonorLevel
    else
      return a.nImity > b.nImity
    end
  end
  table.sort(tbQualifiedFriends, fnSort)
  local function fnSetFriend(itemClass, index)
    itemClass:SetData(tbQualifiedFriends[index])
  end
  self.tbAllFriends = tbQualifiedFriends
  self.ScrollViewFriends:Update(tbQualifiedFriends, fnSetFriend)
end
function tbUi:OnShowKin()
  self.pPanel:SetActive("ScrollViewFriends", false)
  self.pPanel:SetActive("ScrollViewKin", true)
  self.pPanel:SetActive("ScrollViewNearby", false)
  if me.dwKinId == 0 then
    return
  end
  Kin:UpdateMemberList()
  self:ShowKin()
end
function tbUi:ShowKin()
  local tbAllMembers = Kin:GetMemberList()
  if not tbAllMembers then
    return
  end
  local tbOnLineState = Kin:GetMemberState()
  local tbOnLineMembers = {}
  for i, v in ipairs(tbAllMembers) do
    if v.nMemberId ~= me.dwID and tbOnLineState[v.nMemberId] then
      table.insert(tbOnLineMembers, v)
    end
  end
  local fnSort = function(a, b)
    return a.nCareer < b.nCareer
  end
  table.sort(tbOnLineMembers, fnSort)
  local function fnSetKin(itemClass, index)
    itemClass:SetData(tbOnLineMembers[index])
  end
  self.tbAllKins = tbOnLineMembers
  self.ScrollViewKin:Update(tbOnLineMembers, fnSetKin)
end
function tbUi:InviteALl()
  local tbAll = self.tbAllFriends
  if self.pPanel:Button_GetCheck("tabFamily") then
    tbAll = self.tbAllKins
  elseif self.pPanel:Button_GetCheck("tabNearby") then
    tbAll = self.tbAllNearby
  end
  if not tbAll or not next(tbAll) then
    me.CenterMsg("当前没有成员可以邀请")
    return
  end
  for i, v in ipairs(tbAll) do
    local dwID = v.dwID or v.nMemberId
    self:Invite(dwID, true)
  end
  me.CenterMsg("一键邀请成功")
end
function tbUi:UpdateKinData(szType)
  if szType ~= "MemberList" then
    return
  end
  self:ShowKin()
end
function tbUi:UpdateTabBtn()
  if not self.szSelTab then
    if me.dwKinId ~= 0 then
      self.szSelTab = "tabFamily"
    else
      self.szSelTab = "tabFriend"
    end
  end
  self.pPanel:Toggle_SetChecked("tabFriend", self.szSelTab == "tabFriend")
  self.pPanel:Toggle_SetChecked("tabFamily", self.szSelTab == "tabFamily")
  self.pPanel:Toggle_SetChecked("tabNearby", self.szSelTab == "tabNearby")
  if self.szSelTab == "tabFriend" then
    self:ShowFriends()
  elseif self.szSelTab == "tabNearby" then
    self:ShowNearBy()
  else
    self:OnShowKin()
  end
end
tbUi.tbOnClick = {}
function tbUi.tbOnClick:tabFriend()
  self.szSelTab = "tabFriend"
  self:ShowFriends()
end
function tbUi.tbOnClick:tabFamily()
  self.szSelTab = "tabFamily"
  self:OnShowKin()
end
function tbUi.tbOnClick:tabNearby()
  self.szSelTab = "tabNearby"
  self:ShowNearBy()
end
function tbUi.tbOnClick:btnInvite()
  local bHasInvite = false
  if self.pPanel:IsActive("ScrollViewFriends") then
    for i, v in ipairs(self.tbAllFriends) do
      if v.bCheck then
        self:Invite(v.dwID)
        bHasInvite = true
      end
    end
  elseif self.pPanel:IsActive("ScrollViewKin") then
    for i, v in ipairs(self.tbAllKins) do
      if v.bCheck then
        self:Invite(v.nMemberId)
        bHasInvite = true
      end
    end
  elseif self.pPanel:IsActive("ScrollViewNearby") then
    for i, v in ipairs(self.tbAllNearby) do
      if v.bCheck then
        self:Invite(v.dwID)
        bHasInvite = true
      end
    end
  end
  if bHasInvite then
    me.CenterMsg("已向侠士发出邀请，请静待回音")
  else
    me.CenterMsg("尚未选中侠士")
  end
end
tbUi.tbOnClick.btnCenterInvite = tbUi.tbOnClick.btnInvite
function tbUi.tbOnClick:btnInviteAll()
  self:InviteALl()
end
function tbUi.tbOnClick:btnRandomlySelected()
  local nNow = GetTime()
  if self.nLastRandomInviteTime and nNow < self.nLastRandomInviteTime + 60 then
    me.CenterMsg("招募函已发出，请等待其他侠士接受邀请")
    return
  end
  self.nLastRandomInviteTime = nNow
  RemoteServer.DungeonFubeRandomInvite()
end
function tbUi.tbOnClick:btnClose()
  Ui:CloseWindow(self.UI_NAME)
end
function tbUi:OnEnterMap()
  Ui:CloseWindow(self.UI_NAME)
end
function tbUi:RegisterEvent()
  local tbRegEvent = {
    {
      UiNotify.emNOTIFY_SYNC_KIN_DATA,
      self.UpdateKinData,
      self
    },
    {
      UiNotify.emNOTIFY_MAP_ENTER,
      self.OnEnterMap,
      self
    }
  }
  return tbRegEvent
end
