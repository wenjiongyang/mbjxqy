local tbUi = Ui:CreateClass("WelfareActivity")
function tbUi:RegisterEvent()
  local tbRegEvent = {
    {
      UiNotify.emNOTIFY_WELFARE_UPDATE,
      self.OnActivityUpdate,
      self
    },
    {
      UiNotify.emNOTIFY_MONEYTREE_RESPOND,
      self.OnRespondMoneyTree,
      self
    },
    {
      UiNotify.emNOTIFY_MONEYTREE_DATA_UPDATE,
      self.OnMoneyTreeUpdate,
      self
    },
    {
      UiNotify.emNOTIFY_ONHOOK_GET_EXP_FINISH,
      self.OnOnHookUpdate,
      self
    },
    {
      UiNotify.emNOTIFY_SUPPLEMENT_RSP,
      self.OnRespondSupplement,
      self
    },
    {
      UiNotify.emNOTIFY_UPDATE_QQ_VIP_INFO,
      self.OnUpdateQQVipInfo,
      self
    }
  }
  return tbRegEvent
end
tbUi.tbSelectNoPage = {}
function tbUi:OnOpen(szWndType)
  if szWndType then
    local minLevel = WelfareActivity:GetActivityOpenLevel(szWndType)
    if minLevel and minLevel > me.nLevel then
      me.CenterMsg(string.format("%d级开启", minLevel))
      return 0
    end
  end
end
function tbUi:OnOpenEnd(szWndType, ...)
  self.szCurWndType = szWndType
  self:InitActiveActivity()
  self:Update(szWndType, ...)
  for i, tbInfo in ipairs(self.tbActiveList) do
    if tbInfo.szKey == self.szCurWndType then
      self.ScrollViewCatalog.pPanel:ScrollViewGoToIndex("Main", i)
      break
    end
  end
  for i, tbInfo in ipairs(self.tbActiveList) do
    if WelfareActivity.tbCheckRedPoint[tbInfo.szKey] then
      WelfareActivity.tbCheckRedPoint[tbInfo.szKey]()
    end
  end
end
function tbUi:OnClose()
  self:ExecuteActFunc("SupplementPanel", "OnClose")
  self:ExecuteActFunc("MoneyTreePanel", "OnClose")
  self:ExecuteActFunc("FirstRecharge", "OnClose")
  self:ExecuteActFunc("GrowInvest", "OnClose")
end
function tbUi:InitActiveActivity()
  self.tbActiveList = WelfareActivity:GetActivityList()
end
function tbUi:Update(szWndType, ...)
  self:CheckWndType(szWndType)
  self:UpdateActivityList()
  self:UpdateRightPanel()
  if not self.szCurWndType then
    Log("[WelfareActivity Update] Error")
    return
  end
  self:ExecuteActFunc(self.szCurWndType, "OnOpen", ...)
end
function tbUi:CheckWndType(szWndType)
  self.szCurWndType = szWndType or self.szCurWndType
  for _, tbInfo in pairs(self.tbActiveList) do
    if tbInfo.szKey == self.szCurWndType then
      return
    end
  end
  if #self.tbActiveList > 0 then
    self.szCurWndType = self.tbActiveList[1].szKey
  end
end
function tbUi:OnActivityUpdate(szWndType)
  if self.szCurWndType == szWndType then
    self:UpdateActivityList()
    self:ExecuteActFunc(self.szCurWndType, "OnOpen")
  end
end
function tbUi:UpdateActivityList()
  local function fnOnSelect(btn)
    self:ExecuteActFunc(self.szCurWndType, "OnClose")
    if self.tbSelectNoPage[szTouchKey] then
      self.tbSelectNoPage[szTouchKey]()
      return
    end
    local szTouchKey = self.tbActiveList[btn.nIdx].szKey
    self:Update(szTouchKey)
    Guide.tbNotifyGuide:ClearNotifyGuide(szTouchKey)
  end
  local function fnSetItem(itemObj, nIdx)
    local tbActivity = self.tbActiveList[nIdx]
    local szRedPoint = tbActivity.szRedPointKey
    local bActive = szRedPoint ~= "" and true or false
    Ui:UnRegisterRedPoint("NG_" .. tbActivity.szKey)
    itemObj.pPanel:RegisterRedPoint("texiao", "NG_" .. tbActivity.szKey)
    if bActive then
      Ui:UnRegisterRedPoint(szRedPoint)
      itemObj.pPanel:RegisterRedPoint("Redmark", szRedPoint)
    else
      itemObj.pPanel:SetActive("Redmark", false)
    end
    local szSprite = tbActivity.szKey == self.szCurWndType and "BtnWelfare_02" or "BtnWelfare_01"
    itemObj.pPanel:Label_SetText("FamilyName", tbActivity.szName)
    itemObj.pPanel:Label_SetText("FamilyName1", tbActivity.szName)
    itemObj.pPanel:Sprite_SetSprite("Main", szSprite)
    itemObj.pPanel:Toggle_SetChecked("Main", tbActivity.szKey == self.szCurWndType)
    itemObj.pPanel:SetActive("NYLabel", tbActivity.bShowNewIcon or false)
    itemObj.nIdx = nIdx
    itemObj.pPanel.OnTouchEvent = fnOnSelect
  end
  self.ScrollViewCatalog:Update(#self.tbActiveList, fnSetItem)
end
function tbUi:UpdateRightPanel()
  local tbAllActKey = WelfareActivity:GetAllActivityKey() or {}
  for _, szKey in pairs(tbAllActKey) do
    if self[szKey] then
      self.pPanel:SetActive(szKey, szKey == self.szCurWndType)
    end
  end
end
function tbUi:OnRespondMoneyTree(tbGain)
  self:ExecuteActFunc("MoneyTreePanel", "OnRespond", tbGain)
end
function tbUi:OnMoneyTreeUpdate()
  self:ExecuteActFunc("MoneyTreePanel", "Update")
end
function tbUi:OnOnHookUpdate()
  self:ExecuteActFunc("OnHook", "Update")
end
function tbUi:OnRespondSupplement()
  self:ExecuteActFunc("SupplementPanel", "Update")
end
function tbUi:OnUpdateQQVipInfo()
  self:ExecuteActFunc("QQVipPrivilege", "Update")
end
function tbUi:ExecuteActFunc(szKey, szFunc, ...)
  local tbInst = self[szKey]
  if not tbInst then
    return
  end
  if not tbInst[szFunc] then
    return
  end
  tbInst[szFunc](tbInst, ...)
end
tbUi.tbOnClick = {
  BtnClose = function(self)
    Ui:CloseWindow("WelfareActivity")
  end
}
