local tbUi = Ui:CreateClass("NewInformationPanel")
tbUi.tbEvent = tbUi.tbEvent or {}
tbUi.tbEvent.Main = {
  [UiNotify.emNOTIFY_ONSYNC_NEWINFORMATION] = "OnSyncData",
  [UiNotify.emNOTIFY_WND_OPENED] = "WndOpened",
  [UiNotify.emNOTIFY_BEAUTY_VOTE_AWARD] = "OnSubPanelNotify",
  [UiNotify.emNOTIFY_LOAD_RES_FINISH] = "LoadBodyFinish"
}
function tbUi:RegisterEvent()
  local tbEventId = {}
  local tbRegisterEvent = {}
  for _, tbInfo in pairs(self.tbEvent) do
    for nEvent in pairs(tbInfo) do
      if not tbEventId[nEvent] then
        local fnName = string.format("OnUiNotify_%d", nEvent)
        self[fnName] = function(tbMainInst, ...)
          tbMainInst:OnUiNotify(nEvent, ...)
        end
        table.insert(tbRegisterEvent, {
          nEvent,
          self[fnName]
        })
        tbEventId[nEvent] = true
      end
    end
  end
  return tbRegisterEvent
end
function tbUi:OnUiNotify(nEvent, ...)
  local szMainFunc = self.tbEvent.Main[nEvent]
  if szMainFunc then
    self[szMainFunc](self, ...)
  end
  if self.szCurKey then
    local szWndcom = NewInformation:GetActivityUi(self.szCurKey)
    local szFunc = szWndcom and self.tbEvent[szWndcom] and self.tbEvent[szWndcom][nEvent]
    if szFunc and self[szWndcom] and self[szWndcom][szFunc] then
      self[szWndcom][szFunc](self[szWndcom], ...)
    end
  end
end
function tbUi:OnOpenEnd(szKey)
  RankActivity:SynLevelRankData()
  self:Update(szKey)
  if Pandora:IsShowIcon("NewInformationPanel", "LuckyStar") then
    self.pPanel:SetActive("BtnNew", true)
    self.pPanel:SetActive("BtnLuckyStar", true)
    self.pPanel:Toggle_SetChecked("BtnLuckyStar", true)
    self.pPanel:Toggle_SetChecked("BtnNew", false)
    self.tbOnClick.BtnLuckyStar(self)
  else
    self.pPanel:SetActive("BtnNew", false)
    self.pPanel:SetActive("BtnLuckyStar", false)
  end
end
function tbUi:GetContentList()
  if not self.tbContentList then
    self.tbContentList = {}
    local tranform = self.pPanel:FindChildTransform("Content")
    local linkprefab = tranform:GetComponent("LinkPrefab")
    local pNameList = linkprefab.NodeName
    for i = 0, pNameList.Length - 1 do
      local szName = pNameList[i]
      if self.pPanel:CheckHasChildren(szName) and self[szName] then
        table.insert(self.tbContentList, szName)
      end
    end
  end
  return self.tbContentList
end
function tbUi:Update(szKey)
  self.tbShowAct = NewInformation:GetShowActivity() or {}
  local bHaveAct2Show = #self.tbShowAct > 0
  self.pPanel:SetActive("NoInfo", not bHaveAct2Show)
  self.pPanel:SetActive("ScrollViewCatalog", bHaveAct2Show)
  self.pPanel:SetActive("Content", bHaveAct2Show)
  if not bHaveAct2Show then
    return
  end
  self.szOldKey = self.szCurKey
  if szKey then
    self.szCurKey = szKey
  end
  local bKeyValid = false
  if self.szCurKey then
    for _, szKey in ipairs(self.tbShowAct or {}) do
      if self.szCurKey == szKey then
        bKeyValid = true
        break
      end
    end
  end
  self.szCurKey = bKeyValid and self.szCurKey or self.tbShowAct[1]
  local function fnOnSelect(btn)
    local szUi = NewInformation:GetActivityUi(self.szCurKey)
    if self[szUi].OnClose then
      self[szUi]:OnClose()
    end
    if btn.szActKeyName then
      btn.pPanel:SetActive("New", false)
      Activity:SetRedPointShow(btn.szActKeyName)
      Activity:CheckRedPoint()
    end
    if self.szCurKey ~= btn.szKey then
      NewInformation:OnSwitchTab(self.szCurKey)
    end
    self:Update(btn.szKey)
  end
  local function fnSetItem(tbItemObj, nIdx)
    local szKey = self.tbShowAct[nIdx]
    local tbActInfo = NewInformation:GetInfoDetail(szKey)
    local szShowName = Pandora:GetShowName(self.UI_NAME, tbActInfo[4])
    szShowName = szShowName or tbActInfo[2]
    Ui:UnRegisterRedPoint(tbActInfo[1])
    tbItemObj.pPanel:RegisterRedPoint("New", tbActInfo[1])
    local szActKeyName = Activity:GetActKeyName(tbActInfo[1])
    if szActKeyName then
      tbItemObj.pPanel:SetActive("New", not Activity:CheckRedPointShowed(szActKeyName))
      tbItemObj.szActKeyName = szActKeyName
    end
    tbItemObj.szKey = self.tbShowAct[nIdx]
    tbItemObj.pPanel.OnTouchEvent = fnOnSelect
    local bCurAct = self.tbShowAct[nIdx] == self.szCurKey
    tbItemObj.pPanel:SetActive("Dark", not bCurAct)
    tbItemObj.pPanel:SetActive("Light", bCurAct)
    tbItemObj.pPanel:Label_SetText("Dark", szShowName)
    tbItemObj.pPanel:Label_SetText("Light", szShowName)
    tbItemObj.pPanel:Toggle_SetChecked("Main", bCurAct)
    local nType = NewInformation:GetOperationType(szKey)
    for i = 1, 9 do
      if not tbItemObj.pPanel:CheckHasChildren("Mark" .. i) then
        break
      end
      tbItemObj.pPanel:SetActive("Mark" .. i, i == nType)
    end
  end
  self.ScrollViewCatalog:Update(#self.tbShowAct, fnSetItem)
  local tbUiList = self:GetContentList()
  for _, szUiName in ipairs(tbUiList) do
    self.pPanel:SetActive(szUiName, false)
  end
  if self.szCurKey ~= self.szOldKey then
    NewInformation:OnClickTab(self.szCurKey)
  end
  local tbData = NewInformation:GetActData(self.szCurKey)
  NewInformation:OnOpenUi(self.szCurKey)
  if tbData then
    self:OpenActivityUi(self.szCurKey, tbData)
  end
end
function tbUi:OnSyncData(szKey, tbData)
  if self.szCurKey == szKey then
    self:OpenActivityUi(self.szCurKey, tbData)
  end
end
function tbUi:OpenActivityUi(szKey, tbData)
  local szUi = NewInformation:GetActivityUi(self.szCurKey)
  self.pPanel:SetActive(szUi, true)
  self[szUi].szCurNewInfoKey = szKey
  self[szUi]:OnOpen(tbData)
end
function tbUi:OnClose()
  local tbUi = self:GetCurWndPanel()
  if tbUi and tbUi.OnClose then
    tbUi:OnClose()
  end
  self.tbShowAct = {}
  self.szOldKey = nil
  self.szCurKey = nil
  Pandora:ClosePanel(self.UI_NAME)
end
function tbUi:WndOpened(szUiName)
  if szUiName == "CommonShop" then
    Ui:CloseWindow(self.UI_NAME)
  end
end
function tbUi:GetCurWndPanel()
  if not self.szCurKey then
    return
  end
  local szUi = NewInformation:GetActivityUi(self.szCurKey)
  if not szUi then
    return
  end
  return self[szUi]
end
function tbUi:OnSubPanelNotify(nEvent, ...)
  local tbUi = self:GetCurWndPanel()
  if tbUi and type(tbUi.OnSubPanelNotify) == "function" then
    tbUi:OnSubPanelNotify(nEvent, self, ...)
  end
end
function tbUi:LoadBodyFinish(nViewId)
  local tbUi = self:GetCurWndPanel()
  if tbUi and type(tbUi.LoadBodyFinish) == "function" then
    tbUi:LoadBodyFinish(nViewId)
  end
end
tbUi.tbOnClick = {
  BtnClose = function(self)
    Ui:CloseWindow(self.UI_NAME)
  end
}
function tbUi.tbOnClick:BtnNew()
  Pandora:Hide("NewInformationPanel", "LuckyStar")
  self:Update()
end
function tbUi.tbOnClick:BtnLuckyStar()
  self.pPanel:SetActive("NoInfo", false)
  self.pPanel:SetActive("ScrollViewCatalog", false)
  self.pPanel:SetActive("Content", false)
  Ui:ClearRedPointNotify("BtnLuckyStar")
  Pandora:Open("NewInformationPanel", "LuckyStar")
end
local tbNormalUi = Ui:CreateClass("NewInformationPanel_Normal")
function tbNormalUi:OnOpen(tbData)
  local szContent = string.gsub(tbData[1] or "", "\\n", "\n")
  self.Content:SetLinkText(szContent)
  self.tbSetting = NewInformation.tbActivity[self.szCurNewInfoKey] or NewInformation.tbLocalSetting[self.szCurNewInfoKey] or {}
  local tbTextSize = self.pPanel:Label_GetPrintSize("Content")
  local tbSize = self.pPanel:Widget_GetSize("datagroup")
  self.pPanel:Widget_SetSize("datagroup", tbSize.x, 50 + tbTextSize.y)
  self.pPanel:DragScrollViewGoTop("datagroup")
  self.pPanel:UpdateDragScrollView("datagroup")
  local bShowBtn = false
  if self.tbSetting and not Lib:IsEmptyStr(self.tbSetting.szBtnName) and not Lib:IsEmptyStr(self.tbSetting.szBtnTrap) then
    bShowBtn = true
    self.pPanel:Label_SetText("NormalTxt", self.tbSetting.szBtnName)
  end
  self.pPanel:SetActive("BtnNormal", bShowBtn)
end
tbNormalUi.tbOnClick = tbNormalUi.tbOnClick or {}
function tbNormalUi.tbOnClick:BtnNormal()
  if not self.tbSetting or Lib:IsEmptyStr(self.tbSetting.szBtnTrap) then
    return
  end
  Ui.HyperTextHandle:Handle(self.tbSetting.szBtnTrap, 0, 0)
  if self.tbSetting.nBtnCloseWnd and self.tbSetting.nBtnCloseWnd == 1 then
    Ui:CloseWindow("NewInformationPanel")
  end
end
