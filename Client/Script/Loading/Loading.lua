function Loading:DoStartLoading(nMapTemplateId, nType)
  PreloadResource:OnChangeMap(nMapTemplateId)
  DoLoadMap(nMapTemplateId, nType)
  Ui:ShowAllRepresentObj(true)
  self.nLoadingTimerId = nil
end
function Loading:StartLoadData(nMapTemplateId, nType)
  self.nCurLeaveMapId = Map.nCurLeaveMapId
  self.bLoadMapFinish = false
  Ui:SetForbiddenOperation(false)
  Ui:SetAllUiVisable(true)
  SetGameWorldScale(1)
  Operation:SetGuidingJoyStick(false)
  local nCurMapTemplateId = self.nDstMaptemplateId
  self.nDstMaptemplateId = nMapTemplateId
  self.nType = nType
  if self.nLoadingTimerId then
    Timer:Close(self.nLoadingTimerId)
    self.nLoadingTimerId = nil
  end
  self.nLoadingTimerId = Timer:Register(3, self.DoStartLoading, self, nMapTemplateId, nType)
  Ui:OpenWindow("MapLoading", nMapTemplateId, nCurMapTemplateId)
  Log("Loading StartLoadData", nMapTemplateId, nType)
end
function Loading:StartLoadScene()
  if self.nUpdateTimerId then
    Timer:Close(self.nUpdateTimerId)
    self.nUpdateTimerId = nil
  end
  self.nRealPercent = 0.5
  local function fnUpdatePercent()
    if self.nRealPercent < 1 then
      self.nRealPercent = math.max(Ui.ToolFunction.GetLoadMapPercent(), self.nRealPercent)
      local fPreloadPer = (1 - PreloadResource:GetLoadPercent()) * 0.3
      self.nRealPercent = self.nRealPercent - fPreloadPer
      if fPreloadPer >= 0.001 and self.nRealPercent > 1 then
        self.nRealPercent = self.nRealPercent - 0.01
      end
    end
    if self.nRealPercent >= 1 then
      self.nUpdateTimerId = nil
      self:LoadingFinish()
      return
    end
    return true
  end
  self.nUpdateTimerId = Timer:Register(1, fnUpdatePercent)
end
function Loading:LoadingFinish(bDealyOk)
  ResetLogicFrame()
  XinShouLogin:OnMapLodingEnd()
  if not bDealyOk then
    Timer:Register(8, self.LoadingFinish, self, true)
    return
  end
  self.bLoadMapFinish = true
  if self.nDstMaptemplateId ~= 0 then
    Operation:OnMapLoaded()
  end
  Ui:CloseWindow("MapLoading")
  Map:OnMapLoaded(self.nDstMaptemplateId)
end
function Loading:IsLoadMapFinish()
  return self.bLoadMapFinish
end
