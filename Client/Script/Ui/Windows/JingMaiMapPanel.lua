local tbUi = Ui:CreateClass("JingMaiMapPanel")
function tbUi:OnOpen()
end
tbUi.tbOnClick = tbUi.tbOnClick or {}
function tbUi.tbOnClick:BtnClose()
  Ui:CloseWindow(self.UI_NAME)
end
