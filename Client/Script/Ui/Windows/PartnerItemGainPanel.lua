local tbUi = Ui:CreateClass("PartnerItemGainPanel")
function tbUi:OnOpen(nPartnerId)
  if not nPartnerId then
    return 0
  end
  self.nPartnerId = nPartnerId
  self.nItemTemplateID = KItem.GetTemplateIdByPartner(nPartnerId)
  if 0 >= self.nItemTemplateID then
    return 0
  end
  self:Update()
end
function tbUi:Update()
  local tbAllPartnerBaseInfo = Partner:GetAllPartnerBaseInfo()
  local tbBaseInfo = tbAllPartnerBaseInfo[self.nPartnerId]
  self.pPanel:Label_SetText("Label", tbBaseInfo.szName or "")
  self.itemframe:SetGenericItem({
    "Item",
    self.nItemTemplateID
  })
  self:UpdateGainList()
end
function tbUi:UpdateGainList()
  local tbGainInfo = OutputTable:GetOutputList(self.nItemTemplateID)
  local function fnOnClick(itemObj)
    local tbInfo = tbGainInfo[itemObj.nIndex]
    OutputTable:GotoGainUi(tbInfo)
  end
  local function fnSetItem(itemObj, nIdx)
    local bEnable, szDesc, szBgSprite, szIcon = OutputTable:GetGainInfo(tbGainInfo[nIdx])
    itemObj.pPanel:Label_SetText("Label", szDesc)
    itemObj.pPanel:Sprite_SetSprite("Main", szBgSprite)
    itemObj.pPanel:Sprite_SetSprite("Icon", szIcon)
    itemObj.nIndex = nIdx
    itemObj.pPanel.OnTouchEvent = bEnable and fnOnClick
  end
  self.ScrollView:Update(#tbGainInfo, fnSetItem)
end
function tbUi:OnScreenClick()
  Ui:CloseWindow(self.UI_NAME)
end
tbUi.tbOnClick = {}
function tbUi.tbOnClick:BtnBack()
  Ui:CloseWindow(self.UI_NAME)
end
