local tbUi = Ui:CreateClass("SystemNotice")
tbUi.nSpeed = 100
tbUi.nSpace = 0.5
tbUi.nTimeOut = 600
function tbUi:OnOpen(szMsg)
end
function tbUi:OnOpenEnd(szMsg)
  self:ShowMsg(szMsg)
end
function tbUi:ShowMsg(szMsg)
  if Ui:WindowVisible("SystemNotice") ~= 1 then
    Ui:OpenWindow("SystemNotice")
  end
  if self.bIsRuning then
    self.tbCacheMsg = self.tbCacheMsg or {}
    table.insert(self.tbCacheMsg, {
      szMsg,
      GetTime()
    })
    return
  end
  self:DoShowMsg(szMsg)
end
function tbUi:DoShowMsg(szMsg, nRecvTime)
  if nRecvTime and nRecvTime + self.nTimeOut < GetTime() then
    table.remove(self.tbCacheMsg, 1)
    self:OnFinish()
    return
  end
  self.bIsRuning = true
  self.pPanel:Label_SetText("Msg", szMsg)
  local tbSize = self.pPanel:Label_GetSize("Msg")
  local nLength = tbSize.x + 500
  local nTime = nLength / self.nSpeed
  self.pPanel:Tween_RunWhithStartPos("Msg", 500, 10, -nLength, 10, nTime)
  Timer:Register((nTime + self.nSpace) * Env.GAME_FPS, self.OnFinish, self)
end
function tbUi:OnFinish()
  if not (self.tbCacheMsg and self.tbCacheMsg[1]) or Lib:CountTB(self.tbCacheMsg) == 1 and self.tbCacheMsg[1][2] + self.nTimeOut < GetTime() then
    Ui:CloseWindow("SystemNotice")
    self.bIsRuning = false
    return
  end
  self:DoShowMsg(self.tbCacheMsg[1][1], self.tbCacheMsg[1][2])
  table.remove(self.tbCacheMsg, 1)
end
function tbUi:CheckFinish()
  if not self.tbCacheMsg or not self.tbCacheMsg[1] and not self.bIsRuning then
    return true
  end
  return false
end
function tbUi:Close()
  self.bIsRuning = false
  Ui:CloseWindow(self.UI_NAME)
end
function tbUi:RegisterEvent()
  return {
    {
      UiNotify.emNOTIFY_SHARE_PHOTO,
      self.Close,
      self
    }
  }
end
