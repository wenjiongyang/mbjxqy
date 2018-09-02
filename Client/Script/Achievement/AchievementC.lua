Achievement.tbGroup = {
  {
    szName = "闯荡江湖",
    tbKind = {}
  },
  {
    szName = "情义江湖",
    tbKind = {}
  },
  {
    szName = "神兵宝甲",
    tbKind = {}
  },
  {
    szName = "江湖福利",
    tbKind = {}
  },
  {
    szName = "江湖历练",
    tbKind = {}
  },
  {
    szName = "竞技比武",
    tbKind = {}
  },
  {
    szName = "攻城夺宝",
    tbKind = {}
  }
}
function Achievement:InitGroup()
  for szMainKind, tbInfo in pairs(self.tbMainSetting) do
    table.insert(self.tbGroup[tbInfo.nGroup].tbKind, szMainKind)
  end
end
Achievement:InitGroup()
function Achievement:GetGainData(szMainKind)
  if not szMainKind then
    return
  end
  local szSubKind = self:GetCurrentSubKind(me, szMainKind)
  local nCompletedLevel = self:GetCompletedLevel(me, szMainKind)
  local nGainLevel = self:GetGainLevel(me, szMainKind)
  local nCount = self:GetSubKindCount(me, szSubKind)
  return nCompletedLevel, nGainLevel, nCount
end
function Achievement:GetTitleAndDesc(szMainKind, nLevel)
  local tbLevelInfo = self:GetLevelInfo(szMainKind, nLevel)
  if not tbLevelInfo then
    return "", ""
  end
  return tbLevelInfo.Title, tbLevelInfo.Desc
end
function Achievement:GetAchievementNum()
  local nNum = 0
  for szKind, _ in pairs(self.tbMainSetting) do
    nNum = nNum + self:GetMaxLevel(szKind)
  end
  return nNum
end
function Achievement:GetCompleteNum()
  local nCompleteNum = 0
  for szKind, _ in pairs(self.tbMainSetting) do
    local nCompletedLevel = self:GetCompletedLevel(me, szKind)
    nCompleteNum = nCompleteNum + nCompletedLevel
  end
  return nCompleteNum
end
function Achievement:GetCompleteList()
  local tbList = {}
  for szKind, _ in pairs(self.tbMainSetting) do
    local nCompletedLevel = self:GetCompletedLevel(me, szKind)
    if nCompletedLevel > 0 then
      table.insert(tbList, {szKind = szKind, nLevel = nCompletedLevel})
    end
  end
  return tbList
end
function Achievement:GetIdByKind(szMainKind)
  local nGroupID = self:GetGroupKey(szMainKind)
  return nGroupID
end
function Achievement:GetKindById(nId)
  for szKind, tbInfo in pairs(self.tbMainSetting) do
    if tbInfo.nKeyID == nId then
      return szKind
    end
  end
end
function Achievement:AddCount(szSubKind, nCount)
  if self.tbLegal[szSubKind] then
    local tbSubInfo = self.tbSubKindSetting[szSubKind] or {}
    local szMainKind = tbSubInfo.szMainKind
    local bAllFinish = self:IsAllFinish(me, szMainKind)
    if not bAllFinish then
      RemoteServer.UpdateAchievementKindData(szSubKind, nCount or 1)
    end
  end
end
function Achievement:OnGainAwardRsp(szKind)
  local nGroup = self.tbMainSetting[szKind].nGroup
  self:RefreshGroupList(nGroup)
  self:CheckRedPoint()
  UiNotify.OnNotify(UiNotify.emNOTIFY_ACHIEVEMENT_DATA_SYNC)
end
function Achievement:OnCountChange(szSubKind, nOld, nNew)
  local tbCount = self:GetKindCountList(szSubKind)
  local szMainKind = self:GetMainKindKey(szSubKind)
  local nComLevel = self:GetCompletedLevel(me, szMainKind)
  for i = #tbCount, 1, -1 do
    local tbInfo = tbCount[i]
    local nLevel = tbInfo[1]
    local nCount = tbInfo[2]
    if nOld < nCount and nNew >= nCount and nComLevel >= nLevel then
      Ui:OpenWindow("AchievementDisplay", szMainKind, nLevel)
      break
    end
  end
  local nGroup = self.tbMainSetting[szMainKind].nGroup
  self:RefreshGroupList(nGroup)
  self:CheckRedPoint()
  UiNotify.OnNotify(UiNotify.emNOTIFY_ACHIEVEMENT_DATA_SYNC)
end
function Achievement:GetKindGainNum(nGroup)
  local tbKind = (self.tbGroup[nGroup] or {}).tbKind
  local nGainNum = 0
  for _, szKind in ipairs(tbKind or {}) do
    local nCompletedLevel = self:GetCompletedLevel(me, szKind)
    local nGainLevel = self:GetGainLevel(me, szKind)
    if nCompletedLevel > nGainLevel then
      nGainNum = nGainNum + 1
    end
  end
  return nGainNum
end
function Achievement:RefreshGroupList(nGroup)
  local tbKind = (self.tbGroup[nGroup] or {}).tbKind
  local tbTemp = {}
  for _, szKind in ipairs(tbKind or {}) do
    local nCompletedLevel, nGainLevel, nCount = self:GetGainData(szKind)
    local nMaxLevel = self:GetMaxLevel(szKind)
    local nSort = 10
    if nGainLevel < nCompletedLevel then
      nSort = 100
    elseif nGainLevel >= nMaxLevel then
      nSort = 0
    end
    table.insert(tbTemp, {szKind, nSort})
  end
  table.sort(tbTemp, function(k1, k2)
    return k1[2] > k2[2]
  end)
  local tbGroupKind = {}
  for _, tbInfo in ipairs(tbTemp) do
    table.insert(tbGroupKind, tbInfo[1])
  end
  self.tbGourpState = self.tbGourpState or {}
  self.tbGourpState[nGroup] = tbGroupKind
end
function Achievement:GetGroupAchList(nGroup)
  self.tbGourpState = self.tbGourpState or {}
  if not self.tbGourpState[nGroup] then
    self:RefreshGroupList(nGroup)
  end
  local tbAchList = self.tbGourpState[nGroup]
  return tbAchList
end
function Achievement:GetListByType(nType)
  local tbList = {}
  for szMainKind, tbKindInfo in pairs(self.tbMainSetting) do
    for nLv, tbInfo in pairs(tbKindInfo.tbLevelInfo) do
      if tbInfo.ListType == nType then
        table.insert(tbList, {szMainKind, nLv})
      end
    end
  end
  return tbList
end
function Achievement:GetGroupByKind(szMainKind)
  local tbSetting = self.tbMainSetting[szMainKind] or {}
  return tbSetting.nGroup
end
function Achievement:CheckRedPoint()
  Ui:ClearRedPointNotify("Achievement_Btn")
  for nIdx, _ in ipairs(self.tbGroup) do
    local nCanGainNum = self:GetKindGainNum(nIdx)
    if nCanGainNum > 0 then
      Ui:SetRedPointNotify("Achievement_Btn")
      break
    end
  end
end
function Achievement:CheckSpecilAchievement()
  if self.bClientChecked then
    return
  end
  self.bClientChecked = true
  local tbCheckAchi = {}
  self:GetMissAchievement(tbCheckAchi, "EnhanceMaster", #Strengthen.tbAchievementLevel)
  self:GetMissAchievement(tbCheckAchi, "InsetMaster", 6)
  if next(tbCheckAchi) then
    RemoteServer.RequestCheckAchievementFinish(me, tbCheckAchi)
  end
end
function Achievement:GetMissAchievement(tbCheckAchi, szMainKind, nMaxLevel)
  for nLevel = 1, nMaxLevel do
    local bFinish = Achievement:CheckCompleteLevel(me, szMainKind, nLevel)
    if not bFinish and self:CheckSpecilAchievementFinish(me, szMainKind, nLevel) then
      table.insert(tbCheckAchi, {szMainKind, nLevel})
    end
  end
end
