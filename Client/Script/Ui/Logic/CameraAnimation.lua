local WAIT = 0
local WAIT_TIME = 1
local INPROGRESS = 2
local FINISH = 3
function CameraAnimation:LoadSetting()
  local tbSetting = Lib:LoadTabFile("Setting/Ui/CameraAnimation.tab", {nId = 1, nIndex = 1})
  assert(tbSetting, "[CameraAnimation LoadSetting] Not Found File")
  self.tbAnimation = {}
  for _, tbInfo in ipairs(tbSetting or {}) do
    local nId = tbInfo.nId
    self.tbAnimation[nId] = self.tbAnimation[nId] or {}
    local fnGetParam = function(szParam)
      if Lib:IsEmptyStr(szParam) then
        return 0, 0
      end
      local nOnIdx, nOnTime = unpack(Lib:SplitStr(szParam, "|"))
      return tonumber(nOnIdx) or 0, tonumber(nOnTime) or 0
    end
    assert(Lib:IsEmptyStr(tbInfo.szOnStart) or Lib:IsEmptyStr(tbInfo.szOnFinish), "[CameraAnimation LoadSetting] EventErr")
    local nOnStartIdx, nOnStartTime = fnGetParam(tbInfo.szOnStart)
    local nOnFinishIdx, nOnFinishTime = fnGetParam(tbInfo.szOnFinish)
    local fnGetOperation = function(szOperation)
      local tbInfo = Lib:SplitStr(szOperation, "|")
      local szFuncName = unpack(tbInfo)
      local tbParam = {}
      for i = 1, #tbInfo do
        if not tbInfo[i] then
          return
        end
        table.insert(tbParam, tonumber(tbInfo[i]) or tbInfo[i])
      end
      return tbParam
    end
    local tbAllOperation = {}
    for i = 1, 99 do
      local szOperation = tbInfo["szOperation" .. i]
      if Lib:IsEmptyStr(szOperation) then
        break
      end
      local tbOperation = fnGetOperation(szOperation)
      table.insert(tbAllOperation, tbOperation)
    end
    self.tbAnimation[nId][tbInfo.nIndex] = {
      nOnStartIdx = nOnStartIdx,
      nOnStartTime = nOnStartTime,
      nOnFinishIdx = nOnFinishIdx,
      nOnFinishTime = nOnFinishTime,
      tbOperation = tbAllOperation
    }
  end
end
CameraAnimation:LoadSetting()
function CameraAnimation:Start(nId)
  self:Stop()
  self.tbCurAnimation = self.tbAnimation[nId]
  if not self.tbCurAnimation then
    Log("[CameraAnimation Start] Err", nId)
    return
  end
  for _, tbInfo in ipairs(self.tbCurAnimation) do
    tbInfo.nState = WAIT
  end
  self.nCurAnimationId = nId
  self.nCurFrame = 1
  self.tbOpendUi = {}
  if self.nActivateTimer then
    Timer:Close(self.nActivateTimer)
  end
  self.nActivateTimer = Timer:Register(1, self.Activate, self)
  Log("CameraAnimation Start", nId)
end
function CameraAnimation:Activate()
  if not self.nCurAnimationId then
    self.nActivateTimer = nil
    return
  end
  for nEventId, tbInfo in ipairs(self.tbCurAnimation) do
    tbInfo.nState = tbInfo.nState or WAIT
    tbInfo.nTimeFrame = tbInfo.nTimeFrame or 0
    if tbInfo.nState == WAIT then
      local nOnStartIdx = tbInfo.nOnStartIdx
      local nOnFinishIdx = tbInfo.nOnFinishIdx
      if nOnStartIdx > 0 then
        local tbPreEvent = self.tbCurAnimation[nOnStartIdx]
        if tbPreEvent.nState == INPROGRESS or tbPreEvent.nState == FINISH then
          tbInfo.nState = WAIT_TIME
          tbInfo.nTimeFrame = self.nCurFrame + tbInfo.nOnStartTime * Env.GAME_FPS
        end
      elseif nOnFinishIdx > 0 then
        local tbFinishEvent = self.tbCurAnimation[nOnFinishIdx]
        if tbFinishEvent.nState == FINISH then
          if 0 < tbFinishEvent.nOnFinishTime then
            tbInfo.nState = WAIT_TIME
            tbInfo.nTimeFrame = GetTime() + tbInfo.nOnFinishTime * Env.GAME_FPS
          else
            self:StartEvent(nEventId)
          end
        end
      else
        self:StartEvent(nEventId)
      end
    elseif tbInfo.nState == WAIT_TIME and tbInfo.nTimeFrame <= self.nCurFrame then
      self:StartEvent(nEventId)
    end
  end
  self.nCurFrame = self.nCurFrame + 1
  local bContinue = self:CheckInProgress()
  if not bContinue then
    self:Stop()
  end
  return bContinue
end
function CameraAnimation:CheckInProgress()
  for nEventId, tbInfo in ipairs(self.tbCurAnimation) do
    if tbInfo.nState ~= FINISH then
      return true
    end
  end
end
local tbDelayEvent = {PlayCameraAnimation = 1, TryPlaySitutionalDialog = 1}
function CameraAnimation:StartEvent(nEventId)
  local tbEvent = self.tbCurAnimation[nEventId]
  tbEvent.nState = INPROGRESS
  local bDelayEvent = false
  for _, tbOperation in pairs(tbEvent.tbOperation) do
    bDelayEvent = bDelayEvent or tbDelayEvent[tbOperation[1]]
    self:DoOperation(unpack(tbOperation))
  end
  self.nInProgressEventId = bDelayEvent and nEventId or nil
  tbEvent.nState = bDelayEvent and INPROGRESS or FINISH
end
function CameraAnimation:OnPlayCameraAnimationFinish()
  if self:OnDelayEventFinish() then
    self:StopCameraAnimation()
  end
end
function CameraAnimation:OnDialogCloseOpenUi()
  self:OnDelayEventFinish()
end
function CameraAnimation:OnDelayEventFinish()
  if not self.nCurAnimationId or not self.nInProgressEventId then
    return
  end
  local tbEvent = self.tbCurAnimation[self.nInProgressEventId]
  tbEvent.nState = FINISH
  self.nInProgressEventId = nil
  return true
end
function CameraAnimation:Stop()
  if not self.nCurAnimationId then
    return
  end
  self:CloseAllUi()
  self:StopCameraAnimation()
  self.nCurAnimationId = nil
  self.nActivateTimer = nil
  Ui:ResetCameraAni()
  Log("CameraAnimation Stop")
end
function CameraAnimation:DoOperation(szFuncName, ...)
  self[szFuncName](self, ...)
end
function CameraAnimation:PlayCameraAnimation(szAnimation)
  self:StopCameraAnimation()
  Ui.CameraMgr.PlayCameraAnimation(szAnimation)
end
function CameraAnimation:StopCameraAnimation()
  if self.nInProgressEventId then
    local tbEvent = self.tbCurAnimation[self.nInProgressEventId]
    tbEvent.nState = FINISH
    self.nInProgressEventId = nil
  end
  Ui.CameraMgr.LeaveCameraAnimationState()
end
function CameraAnimation:OpenUi(szUi, ...)
  Ui:OpenWindow(szUi, ...)
  self.tbOpendUi[szUi] = true
end
function CameraAnimation:CloseUi(szUi)
  Ui:CloseWindow(szUi)
  self.tbOpendUi[szUi] = false
end
function CameraAnimation:SetRepresentObjVisible(bShow)
  bShow = bShow or false
  Ui.Effect.ShowAllRepresentObj(bShow)
  Ui:SetAllUiVisable(bShow)
end
function CameraAnimation:ShowAllRepresentObj()
  self:SetRepresentObjVisible(true)
end
function CameraAnimation:HideAllRepresentObj()
  self:SetRepresentObjVisible(false)
end
function CameraAnimation:ShowAllNpcObj()
  Ui.Effect.ShowAllRepresentObj(true)
end
function CameraAnimation:HideAllNpcObj()
  Ui.Effect.ShowAllRepresentObj(false)
end
function CameraAnimation:ShowAllUi()
  Ui:SetAllUiVisable(true)
end
function CameraAnimation:HideAllUi()
  Ui:SetAllUiVisable()
end
function CameraAnimation:CloseAllUi()
  if not self.nCurAnimationId then
    return
  end
  for szUi, bIsOpen in pairs(self.tbOpendUi or {}) do
    if bIsOpen then
      Ui:CloseWindow(szUi)
    end
  end
  self.tbOpendUi = nil
end
function CameraAnimation:PlayCameraEffect(nId)
  Ui:PlayCameraEffect(nId)
end
function CameraAnimation:PlayEffect(nId, nX, nY, nZ, nRenderPos)
  Ui:PlayEffect(nId, nX, nY, nZ, nRenderPos)
end
function CameraAnimation:PlayFactionEffect(...)
  local tbEffect = {
    ...
  }
  local nFactionEffect = tbEffect[me.nFaction]
  if nFactionEffect then
    self:PlayEffect(nFactionEffect, 0, 0, 0, 1)
  end
end
function CameraAnimation:TryPlaySitutionalDialog(...)
  Ui:TryPlaySitutionalDialog(...)
end
UiNotify:RegistNotify(UiNotify.emNOTIFY_ON_CLOSE_DIALOG, CameraAnimation.OnDialogCloseOpenUi, CameraAnimation)
function CameraAnimation:OnMapLoaded(nMapTemplateID)
  if nMapTemplateID ~= 10 then
    return
  end
  local bHadEnter = Client:GetFlag("IsHadEnterCity")
  if bHadEnter then
    return
  end
  local nMapId, nX, nY = me.GetWorldPos()
  Operation:ClickMap(nX, nY)
  self:Start(2)
  Client:SetFlag("IsHadEnterCity", true)
end
