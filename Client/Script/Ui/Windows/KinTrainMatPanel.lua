local tbUi = Ui:CreateClass("KinTrainMatPanel")
local tbPerfectMatNum = {
  100,
  100,
  100,
  100,
  100
}
local MAPTEMPLATEID = 1048
function tbUi:RegisterEvent()
  return {
    {
      UiNotify.emNOTIFY_MAP_LEAVE,
      self.OnMapChange,
      self
    },
    {
      UiNotify.emNOTIFY_SYNC_KIN_TRAIN_MAT,
      self.Update,
      self
    }
  }
end
function tbUi:OnOpen(tbMatInfo)
  if not tbMatInfo or me.nMapTemplateId ~= MAPTEMPLATEID then
    return 0
  end
end
function tbUi:OnOpenEnd(tbMatInfo)
  self:Update(tbMatInfo)
end
function tbUi:OnClose()
  RemoteServer.CancelMatUpdate()
end
local fnGetPercent = function(nPercent)
  local szContent = "严重超量"
  local szColor = "[5dddff]"
  if nPercent < 0.6 then
    szContent = "严重不足"
    szColor = "[ff4545]"
  elseif nPercent < 0.8 then
    szContent = "不足"
    szColor = "[f0a51e]"
  elseif nPercent < 1 then
    szContent = "稍稍不足"
    szColor = "[fbff05]"
  elseif nPercent == 1 then
    szContent = "完美"
    szColor = "[4eff16]"
  elseif nPercent <= 1.1 then
    szContent = "稍稍超量"
  elseif nPercent <= 1.3 then
    szContent = "超量"
  end
  return szColor .. szContent
end
function tbUi:Update(tbMatInfo)
  for i = 1, 5 do
    local nColNum = tbMatInfo[i]
    local nPerfectNum = tbPerfectMatNum[i]
    local nPercent = nColNum / nPerfectNum
    local szPercent = fnGetPercent(nPercent)
    self.pPanel:Label_SetText("state" .. i, szPercent)
    nPercent = math.min(1, nPercent / 1.3)
    self.pPanel:ProgressBar_SetValue("Slider" .. i, nPercent)
  end
end
function tbUi:OnMapChange(nMapTemplateId)
  if nMapTemplateId ~= MAPTEMPLATEID then
    Ui:CloseWindow(self.UI_NAME)
  end
end
tbUi.tbOnClick = {
  BtnClose = function(self)
    Ui:CloseWindow(self.UI_NAME)
  end,
  BtnComplete = function(self)
    RemoteServer.KinTrainTryDepart()
    Ui:CloseWindow(self.UI_NAME)
  end
}
