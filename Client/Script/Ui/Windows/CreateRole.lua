local tbUi = Ui:CreateClass("CreateRole")
local tbButtonTex = {
  [1] = "FactionIcon_Tianwang",
  [2] = "FactionIcon_Emei",
  [3] = "FactionIcon_Taohua",
  [4] = "FactionIcon_Xiaoyao",
  [5] = "FactionIcon_Wudang",
  [6] = "FactionIcon_Tianren",
  [7] = "FactionIcon_Shaolin",
  [8] = "FactionIcon_Cuiyan",
  [9] = "FactionIcon_Tangmen",
  [10] = "FactionIcon_Kunlun",
  [11] = "FactionIcon_Gaibang",
  [12] = "FactionIcon_Wudu",
  [13] = "FactionIcon_Cangjian",
  [14] = "FactionIcon_Changge"
}
local tbSchoolsUI = {
  [1] = "TW",
  [2] = "EM",
  [3] = "THD",
  [4] = "XY",
  [5] = "WD",
  [6] = "TR",
  [7] = "SL",
  [8] = "CY",
  [9] = "TM",
  [10] = "KL",
  [11] = "GB",
  [12] = "WD2",
  [13] = "CJ",
  [14] = "CG"
}
local nFactionNum = #tbButtonTex
function tbUi:SetEnableSelButton(bEnable)
  self.bSelEnable = bEnable
  self.pPanel:Button_SetEnabled("BtnEnter", bEnable)
end
function tbUi:PlayUiAnimation(szUiAniName)
  self:SetEnableSelButton(false)
  self.pPanel:PlayUiAnimation(szUiAniName, false, false, {})
end
function tbUi:OnOpen(tbParam)
  local tbRoleInfo = tbParam.tbRoleInfo
  local nNpcId = tbParam.nNpcId
  local bPlayAni = tbParam.bPlayAni
  local tbSelRoleInfo = tbParam.tbSelRoleInfo
  local bHasNoCreateRole = tbParam.bHasNoCreateRole
  self.pPanel:SetActive("Anchor1", false)
  self.pPanel:SetActive("Anchor2", false)
  self.pPanel:SetActive("Anchor3", true)
  self.pPanel:SetActive("Anchor4", false)
  self.pPanel:SetActive("texiao_sikai", false)
  self.pPanel:SetActive("SelBoxs", false)
  self.pPanel:SetActive("BtnSelect", false)
  self.pPanel:SetActive("BoxBg", false)
  if bHasNoCreateRole then
    self.pPanel:SetActive("SelBoxs", true)
    if bPlayAni then
      self:PlayUiAnimation("CreateRolePanel")
    end
    return
  else
    self.pPanel:SetActive("BeginBg1", false)
    self.pPanel:SetActive("Texture2", false)
    self.pPanel:SetActive("Texture3", false)
  end
  if not tbRoleInfo then
    self.pPanel:SetActive("Anchor3", true)
    self:PlayUiAnimation("CreateRolePaneProfessionalOpen")
    return
  else
    self:PlayUiAnimation("CreateRolePaneProfessionalOpen")
    self.pPanel:SetActive("Anchor1", true)
    self.pPanel:SetActive("Anchor2", true)
    self.pPanel:SetActive("Anchor3", true)
    self.pPanel:SetActive("Anchor4", true)
  end
  self.nFaction = nNpcId
  self.tbCreateRole = tbRoleInfo.tbCreateRole
  if self.bCreated then
    self.NameInputFrame:SetText("")
    self.bCreated = false
  end
  if tbRoleInfo.tbCreateRole then
    self:ShowCreatedRole(tbRoleInfo.tbCreateRole)
  else
    self:ShowNewRole()
  end
  self:ShowSchools()
  self.nAccumulateDir = 0
end
function tbUi:OnAniEnd(szAni)
end
function tbUi:OnOpenEnd(tbParam)
  local function fnClick(itemBtn)
    local nFaction = itemBtn.nFaction
    if self.bLockButton then
      return
    end
    if not self.bSelEnable then
      return
    end
    if IS_OLD_SERVER and (nFaction == 13 or nFaction == 14) then
      me.CenterMsg("暂未开放，敬请期待")
      return
    end
    itemBtn.pPanel:Toggle_SetChecked("Main", true)
    Login:SelRole(nFaction)
  end
  local tbSelRoleInfo = tbParam.tbSelRoleInfo
  local nNpcId = tbParam.nNpcId
  local bShowedSelRole = false
  local function fnSetItem(itemObj, nFaction)
    local v = tbSelRoleInfo[nFaction]
    local szButTex = tbButtonTex[nFaction]
    itemObj.pPanel:Button_SetSprite("Btn", v.tbCreateRole and szButTex .. "03" or szButTex .. "01", 1)
    itemObj.pPanel:Button_SetSprite("Btn", szButTex .. "02", 3)
    itemObj.pPanel:Toggle_SetChecked("Btn", nNpcId == nFaction)
    local bShowNew = nFaction >= #tbSelRoleInfo - 1
    itemObj.Btn.pPanel:SetActive("New", bShowNew)
    if nNpcId == nFaction then
      bShowedSelRole = true
    end
    itemObj.Btn.nFaction = nFaction
    itemObj.Btn.pPanel.OnTouchEvent = fnClick
  end
  self.ScrollView:Update(tbSelRoleInfo, fnSetItem)
  if not Client:GetFlag("LoginShowNewFaction" .. #tbSelRoleInfo) then
    self.ScrollView:GoBottom()
    Client:SetFlag("LoginShowNewFaction" .. #tbSelRoleInfo, true)
  else
    self.ScrollView.pPanel:ScrollViewGoToIndex("Main", nNpcId)
  end
  self:OnDragSelGridEnd()
end
function tbUi:HideOptButtons()
  self.pPanel:SetActive("Anchor2", false)
  self.pPanel:SetActive("Anchor3", false)
end
function tbUi:ShowSchools()
  for k, v in pairs(tbSchoolsUI) do
    self.pPanel:SetActive(v, k == self.nFaction)
  end
end
function tbUi:ShowCreatedRole(tbCreateRole)
  self.pPanel:SetActive("NameInputFrame", false)
  self.pPanel:SetActive("Dice", false)
  if tbCreateRole.tbOhters then
    local szSelName
    self.pPanel:PopupList_Clear("BtnSelect")
    for i, v in ipairs(tbCreateRole.tbOhters) do
      local szVal = string.format("%s(%d)", v.szName, v.nLevel)
      self.pPanel:PopupList_AddItem("BtnSelect", szVal)
      if v.szName == tbCreateRole.szName then
        szSelName = szVal
      end
    end
    if szSelName then
      self.pPanel:PopupList_Select("BtnSelect", szSelName)
    end
    self.pPanel:SetActive("BtnSelect", true)
  else
    self.pPanel:SetActive("BtnSelect", false)
  end
end
function tbUi:ShowNewRole()
  if XinShouLogin:IsOpenFunben() then
    self.pPanel:SetActive("NameInputFrame", false)
    self.pPanel:SetActive("Dice", false)
  else
    self.pPanel:SetActive("NameInputFrame", true)
    self.pPanel:SetActive("Dice", true)
  end
  self.pPanel:Button_SetEnabled("BtnEnter", true)
end
function tbUi:OnCreateRoleRespond(nCode, nRoleID)
  self.bLockButton = nil
  if nCode ~= 0 then
    self.bCreated = false
  else
    Login:LoginRole(nRoleID)
  end
end
function tbUi:OnConnectServerEnd()
  self.bLockButton = nil
end
function tbUi:LockButton()
  if self.bLockButton then
    return
  end
  self.bLockButton = true
  Timer:Register(Env.GAME_FPS * 3, function()
    self.bLockButton = nil
  end)
end
function tbUi:OnMapLoaded()
  Ui:CloseWindow(self.UI_NAME)
end
function tbUi:OnDragSelGridEnd()
  self.pPanel:SetActive("BtnArrow1", not self.ScrollView:IsTop())
  self.pPanel:SetActive("BtnArrow2", not self.ScrollView:IsBottom())
end
tbUi.tbOnClick = {}
function tbUi.tbOnClick:BtnArrow1()
  self.ScrollView:GoTop()
  self:OnDragSelGridEnd()
end
function tbUi.tbOnClick:BtnArrow2()
  self.ScrollView:GoBottom()
  self:OnDragSelGridEnd()
end
function tbUi.tbOnClick:BtnEnter()
  if self.bLockButton then
    return
  end
  if not self.tbCreateRole then
    if not Login:CheckRoleCountLimit() then
      return
    end
    if XinShouLogin:IsOpenFunben() then
      Login:EnterXinShouFuben()
    else
      local szName = self.NameInputFrame:GetText()
      if not Login:CheckNameinValid(szName) then
        return
      end
      self:LockButton()
      CreateRole(szName, self.nFaction)
    end
    self.bCreated = true
  else
    local nBanEndTime = self.tbCreateRole.nBanEndTime
    local szBanReason = self.tbCreateRole.szBanReason
    local nNoTimeNotice = 0
    if szBanReason then
      szBanReason, nNoTimeNotice = string.gsub(szBanReason, "(%[no_time_notice%])", "")
    end
    local szBanInfo
    if nBanEndTime < 0 then
      if szBanReason == nil or szBanReason == "" then
        if nNoTimeNotice > 0 then
          szBanInfo = XT("此角色已被冻结")
        else
          szBanInfo = XT("此角色已被永久冻结")
        end
      elseif nNoTimeNotice > 0 then
        szBanInfo = string.format(XT("此角色由于%s已被冻结", szBanReason))
      else
        szBanInfo = string.format(XT("此角色由于%s已被永久冻结", szBanReason))
      end
    elseif nBanEndTime > 0 and nBanEndTime > GetTime() then
      if szBanReason == nil or szBanReason == "" then
        if nNoTimeNotice > 0 then
          szBanInfo = XT("此角色已被冻结")
        else
          szBanInfo = string.format(XT("此角色已被冻结，解冻时间%s"), Lib:GetTimeStr3(nBanEndTime))
        end
      elseif nNoTimeNotice > 0 then
        szBanInfo = string.format(XT("此角色由于%s已被冻结", szBanReason))
      else
        szBanInfo = string.format(XT("此角色由于%s已被冻结\n解冻时间%s"), szBanReason, Lib:GetTimeStr3(nBanEndTime))
      end
    end
    if szBanInfo then
      Ui:OpenWindow("MessageBox", szBanInfo, {
        {}
      }, {"确认"}, nil, nil, true)
      return
    end
    self:LockButton()
    Login:LoginRole(self.tbCreateRole.nRoleID)
  end
end
tbUi.tbOnDrag = {}
tbUi.tbUiPopupOnChange = {}
function tbUi.tbUiPopupOnChange:BtnSelect(szWndName, val)
  for i, v in ipairs(self.tbCreateRole.tbOhters) do
    if string.format("%s(%d)", v.szName, v.nLevel) == val then
      Login:SwitchRoleSelIndex(self.tbCreateRole, i)
      self:ShowCreatedRole(self.tbCreateRole)
      return
    end
  end
end
function tbUi:OnClose()
  self.bLockButton = nil
  self:SetEnableSelButton(false)
end
function tbUi:OnBtnEnterResponse()
  self.bLockButton = nil
end
function tbUi.tbOnClick:Dice()
  local szName = Login:GetRandomName(nil, self.nFaction)
  for i = 1, 3 do
    if CheckNameAvailable(szName) then
      break
    end
  end
  self.NameInputFrame:SetText(szName)
end
function tbUi.tbOnClick:BtnTitles()
  Ui.ToolFunction.DirPlayCGMovie("OpenCG.mp4")
end
function tbUi:RegisterEvent()
  local tbRegEvent = {
    {
      UiNotify.emNOTIFY_SYNC_PLAYER_DATA_END,
      self.OnBtnEnterResponse
    },
    {
      UiNotify.emNOTIFY_CREATE_ROLE_RESPOND,
      self.OnCreateRoleRespond
    },
    {
      UiNotify.emNOTIFY_CONNECT_SERVER_END,
      self.OnConnectServerEnd
    },
    {
      UiNotify.emNOTIFY_MAP_LOADED,
      self.OnMapLoaded
    }
  }
  return tbRegEvent
end
local tbGrid = Ui:CreateClass("SelRoleGrid")
tbGrid.tbOnDrag = {
  Btn = function(self)
  end
}
tbGrid.tbOnDragEnd = {
  Btn = function(self)
    Ui("CreateRole"):OnDragSelGridEnd()
  end
}
