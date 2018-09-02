local tbUi = Ui:CreateClass("TaskNotice")
tbUi.nMaxTime = 5
function tbUi:OnOpen(szMsg)
  self.nMsgId = (self.nMsgId or 0) + 1
  self.pPanel:Label_SetText("Msg", "")
  if self.nTimer then
    Timer:Close(self.nTimer)
    self.nTimer = nil
  end
  self.pPanel:Label_SetText("Msg", szMsg)
  self.nTimer = Timer:Register(self.nMaxTime * Env.GAME_FPS, self.CloseMsg, self, self.nMsgId)
end
function tbUi:OnClose()
  if self.nTimer then
    Timer:Close(self.nTimer)
    self.nTimer = nil
  end
end
function tbUi:CloseMsg(nMsgId)
  if self.nMsgId ~= nMsgId then
    return
  end
  self.nTimer = nil
  Ui:CloseWindow(self.UI_NAME)
end
