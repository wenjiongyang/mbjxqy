Activity.tbActivityData = Activity.tbActivityData or {}
function Activity:OnSyncActivityInfo(tbData)
  self.tbActivityData = self.tbActivityData or {}
  if Recharge:IsOnActvityDay() then
    local nEndTime = Lib:GetLocalWeekEndTime(GetTime() - 14400) + 14400
    self.tbActivityData.RechargeCardAct = {
      szKeyName = "RechargeCardAct",
      szType = "RechargeCardAct",
      nEndTime = nEndTime
    }
  end
  for _, tbInfo in pairs(tbData) do
    self.tbActivityData[tbInfo.szKeyName] = tbInfo
  end
  self:CheckRedPoint()
end
function Activity:CloseNewInfomation(szKeyName)
  if not self.tbActivityData then
    return
  end
  self.tbActivityData[szKeyName] = nil
  self:CheckRedPoint()
end
function Activity:ClearData()
  self.tbActivityData = {}
end
function Activity:CheckRedPoint()
  self:UpdateActivityData()
  local bShowRedPoint = false
  for szActKeyName, tbInfo in pairs(self.tbActivityData or {}) do
    local tbSetting = self:GetActUiSetting(szActKeyName)
    if tbSetting and tbSetting.szTitle and (not tbSetting.nShowLevel or tbSetting.nShowLevel <= me.nLevel) and not self:CheckRedPointShowed(szActKeyName) then
      bShowRedPoint = true
    end
  end
  if bShowRedPoint then
    Ui:SetRedPointNotify("NI_NormalActiveUi")
  else
    Ui:ClearRedPointNotify("NI_NormalActiveUi")
  end
end
function Activity:SetRedPointShow(szKeyName)
  local nToday = Lib:GetLocalDay()
  local tbRedPointInfo = Client:GetUserInfo("ActivityUiRedPoint")
  if tbRedPointInfo[szKeyName] and tbRedPointInfo[szKeyName] == nToday then
    return
  end
  tbRedPointInfo[szKeyName] = nToday
  local tbInfoToRemove = {}
  for szKey, nDay in pairs(tbRedPointInfo) do
    if nDay ~= nToday then
      tbInfoToRemove[szKey] = true
    end
  end
  for szKey in pairs(tbInfoToRemove) do
    tbRedPointInfo[szKey] = nil
  end
  Client:SaveUserInfo()
end
function Activity:CheckRedPointShowed(szKeyName)
  local tbSetting = self:GetActUiSetting(szKeyName)
  if tbSetting and tbSetting.fnCustomCheckRP then
    local tbInfo = self.tbActivityData[szKeyName]
    if not tbInfo then
      return true
    end
    return not tbSetting.fnCustomCheckRP(tbInfo)
  end
  local nToday = Lib:GetLocalDay()
  local tbRedPointInfo = Client:GetUserInfo("ActivityUiRedPoint")
  if tbRedPointInfo[szKeyName] and tbRedPointInfo[szKeyName] == nToday then
    return true
  end
  return false
end
function Activity:UpdateActivityData()
  local nTimeNow = GetTime()
  local tbToRemove = {}
  for szKeyName, tbInfo in pairs(self.tbActivityData or {}) do
    if nTimeNow >= tbInfo.nEndTime then
      tbToRemove[szKeyName] = true
    end
  end
  for szKeyName in pairs(tbToRemove) do
    self.tbActivityData[szKeyName] = nil
  end
end
function Activity:GetActList(tbShowAct)
  self:UpdateActivityData()
  for szActKeyName, tbInfo in pairs(self.tbActivityData or {}) do
    local tbSetting = self:GetActUiSetting(szActKeyName)
    if tbSetting and tbSetting.szTitle and (not tbSetting.nShowLevel or tbSetting.nShowLevel <= me.nLevel) then
      table.insert(tbShowAct, "___Activity___" .. szActKeyName)
    end
  end
end
function Activity:GetActUiSetting(szActKeyName)
  local tbInfo = self.tbActivityData[szActKeyName]
  if not tbInfo then
    return {}
  end
  return tbInfo.tbUiData or self:GetUiSetting(tbInfo.szType, szActKeyName), tbInfo
end
function Activity:GetNormalNewInfomationSetting(szKey)
  local szRealKey = string.match(szKey, "__SendActNewInfomation__(.+)$")
  if not szRealKey then
    return
  end
  local tbSetting = self:GetNormalNewInfomationUiSetting(szRealKey) or {}
  return tbSetting.tbData or {}
end
function Activity:GetActKeyName(szKey)
  local szActKeyName = string.match(szKey, "^___Activity___(.+)$")
  return szActKeyName
end
Activity.tbActNewInfomationSetting = Activity.tbActNewInfomationSetting or {}
function Activity:GetNormalNewInfomationUiSetting(szKey)
  if not Activity.tbActNewInfomationSetting[szKey] then
    Activity.tbActNewInfomationSetting[szKey] = {}
  end
  return Activity.tbActNewInfomationSetting[szKey]
end
Activity.tbUiSetting = Activity.tbUiSetting or {}
function Activity:GetUiSetting(szType, szKeyName)
  if not Activity.tbUiSetting[szType] and not Activity.tbUiSetting[szKeyName] then
    Activity.tbUiSetting[szType] = {}
  end
  return Activity.tbUiSetting[szType][szKeyName] or Activity.tbUiSetting[szType]
end
function Activity:__IsActInProcessByType(szType)
  self:UpdateActivityData()
  for _, tbInfo in pairs(self.tbActivityData) do
    if tbInfo.szType == szType then
      return true
    end
  end
end
function Activity:OpenActUi(szKeyName)
  local szUiKey = "___Activity___" .. szKeyName
  Ui:OpenWindow("NewInformationPanel", szUiKey)
end
function Activity:__GetActTimeInfo(szKeyName)
  local tbData = self.tbActivityData[szKeyName]
  if not tbData then
    return
  end
  return tbData.nStartTime, tbData.nEndTime
end
