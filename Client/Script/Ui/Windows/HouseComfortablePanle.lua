local tbUi = Ui:CreateClass("HouseComfortablePanle")
function tbUi:OnOpen()
  self:ResetSelect()
  self:Update()
end
function tbUi:Update()
  local nComfortValue = 0
  nComfortValue, self.tbAllInfo = House:GetComfortableShowInfo()
  local nComfortLevel = House:CalcuComfortLevel(nComfortValue)
  local tbFurniture = Furniture.tbNormalFurniture
  local function fnSetItem(itemObj, index)
    local szTypeName = tbFurniture[index].szName
    itemObj.pPanel:Label_SetText("Name", string.format("[92D2FF]%s[-]", szTypeName))
    local nAddCount = House.tbComfortValueLimit[House.nHouseLevel or 1][index] or 0
    local nCurCount = math.min(#(self.tbAllInfo[index] or {}), nAddCount)
    itemObj.pPanel:Label_SetText("Number", string.format("[%s]（%s/%s）[-]", nCurCount == nAddCount and "00FF00" or "FFFFFF", nCurCount, nAddCount))
    function itemObj.BtnDetails.pPanel.OnTouchEvent()
      self:BtnDetails(index)
    end
  end
  self.ScrollView:Update(#tbFurniture, fnSetItem)
  local tbComfortSetting = House:GetComfortSetting(nComfortLevel)
  self.pPanel:Label_SetText("ComfortableLevel", string.format("[92D2FF]舒适等级：[-]%d级", nComfortLevel))
  local tbNextComfortSetting = House:GetComfortSetting(nComfortLevel + 1)
  local nNextComfort = tbNextComfortSetting and tbNextComfortSetting.nComfort or tbComfortSetting.nComfort
  self.pPanel:Label_SetText("ComfortableValue", string.format("%d / %d", nComfortValue, nNextComfort))
  self.pPanel:Sprite_SetFillPercent("Bar", math.min(nComfortValue / nNextComfort, 1))
end
function tbUi:BtnDetails(nType)
  local szName = Furniture:GetTypeName(nType)
  if not szName then
    return
  end
  if not self.tbAllInfo or not self.tbAllInfo[nType] then
    me.CenterMsg("家园内未摆放此类型家具")
    return
  end
  self:ResetSelect()
  self:SelectType(nType)
  Ui:OpenWindowAtPos("HouseComfortableDetailsPanle", 358, 0, szName, self.tbAllInfo[nType], function()
    self:ResetSelect()
  end)
end
function tbUi:SelectType(nType)
  self.nSelectIndex = nType - 1
  local tbItem = self.ScrollView.Grid["Item" .. self.nSelectIndex]
  if not tbItem then
    return
  end
  tbItem.pPanel:SetActive("Bg", true)
end
function tbUi:ResetSelect()
  if self.nSelectIndex then
    local tbItem = self.ScrollView.Grid["Item" .. self.nSelectIndex]
    if tbItem then
      tbItem.pPanel:SetActive("Bg", false)
    end
    self.nSelectIndex = nil
  end
end
function tbUi:OnScreenClick()
  Ui:CloseWindow(self.UI_NAME)
end
