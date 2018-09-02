Achievement.tbMainSetting = {}
Achievement.tbSubKindSetting = {}
Achievement.MAINDATA_GROUD_ID = 29
Achievement.TB_COUNT_DATA_ID = {30, 52}
Achievement.TB_COUNT_DATA_ID_APP10 = {70, 71}
Achievement.KIND_MAXLEVEL = 5
Achievement.tbLegal = {
  Chat_Private = true,
  Chat_Voice = true,
  Angry_Normal = true,
  Chat_Public = true,
  Chat_Emotion = true,
  Chat_Color = true,
  FirstAuctionDeal_1 = true
}
function Achievement:LoadSetting()
  local tbSetting = Lib:LoadTabFile("Setting/Achievement/Achievement.tab", {KeyID = 1, UiGroupID = 1})
  for _, tbInfo in ipairs(tbSetting) do
    assert(not self.tbMainSetting[tbInfo.Kind], "[Achievement] LoadSetting, MainKind repeat " .. tbInfo.Kind)
    self.tbMainSetting[tbInfo.Kind] = {
      nKeyID = tbInfo.KeyID,
      nMaxLevel = 0,
      tbSubKind = {},
      tbLevelInfo = {},
      nGroup = tbInfo.UiGroupID
    }
  end
  local tbKey = {
    Level = 1,
    FinishCount = 1,
    AwardTemplateId = 1,
    AwardCount = 1,
    AwardTitle = 1,
    NeedPush = 1,
    ListType = 1
  }
  local tbLevelSetting = Lib:LoadTabFile("Setting/Achievement/AchievementLevel.tab", tbKey)
  for _, tbInfo in ipairs(tbLevelSetting) do
    local szSubKind = tbInfo.SubKind
    self.tbSubKindSetting[szSubKind] = self.tbSubKindSetting[szSubKind] or {
      szMainKind = tbInfo.ParentKind,
      tbCount = {}
    }
    table.insert(self.tbSubKindSetting[szSubKind].tbCount, {
      tbInfo.Level,
      tbInfo.FinishCount
    })
    local tbMain = self.tbMainSetting[tbInfo.ParentKind]
    tbInfo.tbAward = Lib:GetAwardFromString(tbInfo.Award)
    if 0 < tbInfo.AwardTitle then
      table.insert(tbInfo.tbAward, {
        "AddTimeTitle",
        tbInfo.AwardTitle,
        -1
      })
    end
    tbMain.tbLevelInfo[tbInfo.Level] = tbInfo
    tbMain.nMaxLevel = math.max(tbMain.nMaxLevel, tbInfo.Level)
  end
  local MAX_BIT = 255
  for szMainKind, tbInfo in pairs(self.tbMainSetting) do
    assert(tbInfo.nMaxLevel > 0 and tbInfo.nMaxLevel == #tbInfo.tbLevelInfo, "[Achievement] LoadSetting, SubKind Level Error " .. szMainKind)
    local tbKeyTemp = {}
    local nKeyIdx = 0
    local nBegin = (tbInfo.nKeyID - 1) * self.KIND_MAXLEVEL
    for _, tbLevelInfo in ipairs(tbInfo.tbLevelInfo) do
      local szSubKind = tbLevelInfo.SubKind
      if not tbKeyTemp[szSubKind] then
        nKeyIdx = nKeyIdx + 1
        tbKeyTemp[szSubKind] = 1
        assert(nKeyIdx <= 10, "[Achievement LoadSetting Level Max Then 10" .. szMainKind)
        local nValueKey = nBegin + (nKeyIdx > self.KIND_MAXLEVEL and nKeyIdx - self.KIND_MAXLEVEL or nKeyIdx)
        local nGroupIdx = math.ceil(nValueKey / MAX_BIT)
        self.tbSubKindSetting[szSubKind].nGroupKey = nKeyIdx > self.KIND_MAXLEVEL and self.TB_COUNT_DATA_ID_APP10[nGroupIdx] or self.TB_COUNT_DATA_ID[nGroupIdx]
        self.tbSubKindSetting[szSubKind].nValueKey = nValueKey % MAX_BIT == 0 and MAX_BIT or nValueKey % MAX_BIT
      end
    end
  end
  for _, tbInfo in pairs(self.tbSubKindSetting) do
    table.sort(tbInfo.tbCount, function(c1, c2)
      return c1[1] < c2[1]
    end)
  end
end
Achievement:LoadSetting()
function Achievement:IsAllFinish(pPlayer, szMainKind)
  local nCompletedLevel = self:GetCompletedLevel(pPlayer, szMainKind) or -1
  local nMaxLevel = self:GetMaxLevel(szMainKind)
  return nCompletedLevel >= nMaxLevel
end
function Achievement:GetCompletedLevel(pPlayer, szMainKind)
  if not pPlayer or not szMainKind then
    return 0
  end
  local tbLevelInfo = self.tbMainSetting[szMainKind].tbLevelInfo
  local nMaxLevel = self:GetMaxLevel(szMainKind)
  local nCompletedLevel = 0
  for nLevel = 1, nMaxLevel do
    local tbLevelInfo = self:GetLevelInfo(szMainKind, nLevel)
    local nCurCount = self:GetSubKindCount(pPlayer, tbLevelInfo.SubKind)
    local nComCount = tbLevelInfo.FinishCount
    if nCurCount >= nComCount then
      nCompletedLevel = nLevel
    else
      break
    end
  end
  return nCompletedLevel
end
function Achievement:GetGainLevel(pPlayer, szMainKind)
  if not pPlayer or not szMainKind then
    return
  end
  local tbMainInfo = self.tbMainSetting[szMainKind]
  if not tbMainInfo then
    Log("Achievement:GetGainLevel >>>>", szMainKind)
    return
  end
  local nMaxLevel = tbMainInfo.nMaxLevel
  local nGainFlag = pPlayer.GetUserValue(self.MAINDATA_GROUD_ID, tbMainInfo.nKeyID)
  local nGainLevel = 0
  for i = 1, nMaxLevel do
    local nBit = KLib.GetBit(nGainFlag, i)
    if nBit == 0 then
      break
    end
    nGainLevel = i
  end
  return nGainLevel
end
function Achievement:GetGroupKey(szMainKind)
  local tbMainInfo = self.tbMainSetting[szMainKind]
  if not tbMainInfo then
    Log("Achievement:GetGroupKey >>>>", szMainKind)
    return
  end
  local nKeyID = tbMainInfo.nKeyID
  return nKeyID
end
function Achievement:GetCountSaveKey(szSubKind)
  local tbSubInfo = self.tbSubKindSetting[szSubKind]
  if not tbSubInfo then
    Log("Achievement:GetCountSaveKey, not found such subkind >>>>", szSubKind)
    return
  end
  return tbSubInfo.nGroupKey, tbSubInfo.nValueKey
end
function Achievement:GetSubKindCount(pPlayer, szSubKind)
  if not pPlayer or not szSubKind then
    return
  end
  local nGroupKey, nValueKey = self:GetCountSaveKey(szSubKind)
  if not nGroupKey or not nValueKey then
    Log("Achievement:GetSubKindCount, not fount such subkind >>>>", szSubKind)
    return 0
  end
  local nCount = pPlayer.GetUserValue(nGroupKey, nValueKey)
  return nCount
end
function Achievement:GetMainKindKey(szSubKind)
  local tbSubInfo = self.tbSubKindSetting[szSubKind]
  if not tbSubInfo then
    Log("Achievement:GetMainKind >>>>", szSubKind)
    return
  end
  return tbSubInfo.szMainKind
end
function Achievement:GetCurrentSubKind(pPlayer, szMainKind)
  local tbMainInfo = self.tbMainSetting[szMainKind]
  if not tbMainInfo then
    Log("Achievement:GetCurrentSubKind >>>>", szMainKind)
    return
  end
  local nCurLevel = self:GetCompletedLevel(pPlayer, szMainKind) + 1
  local nMaxLevel = self:GetMaxLevel(szMainKind)
  nCurLevel = math.min(nMaxLevel, nCurLevel)
  local tbInfo = tbMainInfo.tbLevelInfo[nCurLevel]
  return tbInfo.SubKind
end
function Achievement:GetMaxLevel(szMainKind)
  local tbMainInfo = self.tbMainSetting[szMainKind] or {}
  return tbMainInfo.nMaxLevel or 999
end
function Achievement:GetLevelInfo(szMainKind, nLevel)
  local tbMainInfo = self.tbMainSetting[szMainKind]
  if not tbMainInfo then
    return
  end
  local tbLevelInfo = tbMainInfo.tbLevelInfo
  return tbLevelInfo[nLevel]
end
function Achievement:GetAwardInfo(szMainKind, nLevel)
  local tbInfo = self:GetLevelInfo(szMainKind, nLevel)
  if not tbInfo then
    return
  end
  return tbInfo.tbAward, tbInfo.AwardTitle
end
function Achievement:GetFinishCount(szMainKind, nLevel)
  local tbInfo = self:GetLevelInfo(szMainKind, nLevel) or {}
  return tbInfo.FinishCount or 999
end
function Achievement:CheckCompleteLevel(pPlayer, szMainKind, nLevel)
  if not pPlayer or not szMainKind then
    return
  end
  local tbMainInfo = self.tbMainSetting[szMainKind]
  if not tbMainInfo then
    return
  end
  local tbInfo = tbMainInfo.tbLevelInfo[nLevel]
  if not tbInfo then
    return
  end
  local nFinCount = tbInfo.FinishCount
  local szSubKind = tbInfo.SubKind
  local nCurCount = self:GetSubKindCount(pPlayer, szSubKind)
  if nFinCount <= nCurCount then
    return true
  end
end
function Achievement:GetKindMaxCount(szSubKind)
  local tbCountList = self:GetKindCountList(szSubKind)
  local nCountLen = #tbCountList
  return tbCountList[nCountLen][2]
end
function Achievement:GetKindCountList(szSubKind)
  local tbSubInfo = self.tbSubKindSetting[szSubKind]
  return tbSubInfo.tbCount
end
function Achievement:GetPushMsg(szMainKind, nLevel)
  local tbLevelInfo = self:GetLevelInfo(szMainKind, nLevel) or {}
  if tbLevelInfo.NeedPush == 1 then
    local szMsg = string.format("达成了<成就：%s>", tbLevelInfo.Title)
    return szMsg
  end
end
function Achievement:GetSubKind(szMainKind, nLevel)
  local tbLevelInfo = self:GetLevelInfo(szMainKind, nLevel)
  if not tbLevelInfo then
    return
  end
  local szSubKind = tbLevelInfo.SubKind
  return szSubKind
end
Achievement.tbSpecilCheck = {
  EnhanceMaster = function(pPlayer, nLevel)
    local nNeedLevel = Strengthen.tbAchievementLevel[nLevel]
    if not nNeedLevel then
      return
    end
    local tbStrengthen = pPlayer.GetStrengthen()
    local nCount = 0
    for nEquipPos = Item.EQUIPPOS_HEAD, Item.EQUIPPOS_PENDANT do
      local nNowLevel = tbStrengthen[nEquipPos + 1]
      if nNeedLevel <= nNowLevel then
        nCount = nCount + 1
      else
        break
      end
    end
    if nCount >= 10 then
      return true, nCount
    end
  end,
  InsetMaster = function(pPlayer, nLevel)
    local tbInsetLv = StoneMgr:GetInsetLevelCount(pPlayer)
    local nLimitCount = StoneMgr.tbAcheiveNeedInsetNum[nLevel]
    if not nLimitCount then
      return
    end
    return tbInsetLv[nLevel] and nLimitCount <= tbInsetLv[nLevel]
  end
}
function Achievement:CheckSpecilAchievementFinish(pPlayer, szMainKind, nLevel)
  local fnFunc = self.tbSpecilCheck[szMainKind]
  if not fnFunc then
    return
  end
  return fnFunc(pPlayer, nLevel)
end
