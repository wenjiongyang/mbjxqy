local tbUi = Ui:CreateClass("CopyTipPanel")
function tbUi:OnOpenEnd(fnOnTouch)
  function self.Bg.pPanel.OnTouchEvent()
    Ui:CloseWindow(self.UI_NAME)
    if fnOnTouch then
      fnOnTouch()
    end
  end
end
function tbUi:OnScreenClick()
  Ui:CloseWindow(self.UI_NAME)
end
