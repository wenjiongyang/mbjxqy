local tbUi = Ui:CreateClass("QuickUseItem")
function tbUi:OnOpen(nItemId, szBtnName)
  self.nItemId = nItemId
  self.szBtnName = szBtnName or "使用"
  self:Update()
end
function tbUi:OnClose()
  self.nItemId = nil
  self.pPanel:Label_SetText("ItemName", "")
  self.itemframe:Clear()
end
function tbUi:Update(szBtnName)
  local pItem = KItem.GetItemObj(self.nItemId or -1)
  if not pItem then
    Timer:Register(1, Ui.CloseWindow, Ui, "QuickUseItem")
    return
  end
  self.szBtnName = szBtnName or self.szBtnName
  self.pPanel:Button_SetText("BtnUse", self.szBtnName)
  self.pPanel:Label_SetText("ItemName", pItem.szName)
  self.itemframe:SetItem(self.nItemId)
  self.itemframe.fnClick = self.itemframe.DefaultControls
end
tbUi.tbOnClick = {}
function tbUi.tbOnClick:BtnUse()
  if not self.nItemId or not KItem.GetItemObj(self.nItemId) then
    Ui:CloseWindow("QuickUseItem")
    return
  end
  RemoteServer.UseItem(self.nItemId)
end
function tbUi.tbOnClick:BtnClose()
  Ui:CloseWindow("QuickUseItem")
end
