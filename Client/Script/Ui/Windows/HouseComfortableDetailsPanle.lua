local tbUi = Ui:CreateClass("HouseComfortableDetailsPanle")
function tbUi:OnOpen(szType, tbShowInfo, fnOnClose)
  self:Update(szType, tbShowInfo)
  self.fnOnClose = fnOnClose
end
function tbUi:Update(szType, tbShowInfo)
  self.pPanel:Label_SetText("Title", string.format("[FFFE0D]%s[-][9BFFE9FF]当前增加舒适度数量[-]", szType))
  local tbTypeInfo = {}
  for _, tbInfo in pairs(tbShowInfo or {}) do
    local tbFurniture = House:GetFurnitureInfo(tbInfo[1])
    tbTypeInfo[tbFurniture.nLevel] = tbTypeInfo[tbFurniture.nLevel] or {nCount = 0, nTotalComfortValue = 0}
    tbTypeInfo[tbFurniture.nLevel].nCount = tbTypeInfo[tbFurniture.nLevel].nCount + 1
    tbTypeInfo[tbFurniture.nLevel].nTotalComfortValue = tbTypeInfo[tbFurniture.nLevel].nTotalComfortValue + tbFurniture.nComfortValue
  end
  local tbShow = {}
  for nLevel, tbInfo in pairs(tbTypeInfo) do
    table.insert(tbShow, {
      nLevel = nLevel,
      nCount = tbInfo.nCount,
      nTotalComfortValue = tbInfo.nTotalComfortValue
    })
  end
  table.sort(tbShow, function(a, b)
    return a.nLevel > b.nLevel
  end)
  local function fnSetItem(itemObj, index)
    local tbInfo = tbShow[index]
    itemObj.pPanel:Label_SetText("LabelInfo", string.format("[92D2FF]%s级家具：[-]%s个           [C8FF00]舒适度+%s[-]", tbInfo.nLevel, tbInfo.nCount, tbInfo.nTotalComfortValue))
  end
  self.ScrollView:Update(tbShow or {}, fnSetItem)
end
function tbUi:OnScreenClick()
  Ui:CloseWindow(self.UI_NAME)
end
function tbUi:OnClose()
  if self.fnOnClose then
    self.fnOnClose()
    self.fnOnClose = nil
  end
end
