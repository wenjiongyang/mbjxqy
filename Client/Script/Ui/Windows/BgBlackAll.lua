local tbUi = Ui:CreateClass("BgBlackAll")
function tbUi:OnOpen(alpha, nLayer)
  if alpha then
    self.pPanel:UIRect_SetAlpha("Main", alpha)
  end
  if nLayer then
    Ui.UiManager.ChangeUiLayer(self.UI_NAME, nLayer)
  end
end
function tbUi:OnClose()
  self.pPanel:UIRect_SetAlpha("Main", 1)
  Ui.UiManager.ChangeUiLayer(self.UI_NAME, Ui.LAYER_HOME)
end
