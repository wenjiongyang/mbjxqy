HousePlant.LAND_ID = 4427
HousePlant.PLANT_COST = 200
HousePlant.RIPEN_TIME = 604800
HousePlant.STATE_NULL = -1
HousePlant.STATE_NORMAL = 0
HousePlant.STATE_RIPEN = 100
HousePlant.STATE_WATER = 1
HousePlant.STATE_FERTILIZE = 2
HousePlant.STATE_DISINFESTATION = 3
HousePlant.tbSickStateSetting = {
  {
    szDesc = "缺水",
    szCureTool = "水壶",
    szCureNotify = "本次浇水，树丛的成熟时间加快[FFFE0D]%s[-]",
    szFailedMsg = "泥土看起来非常湿润，无需浇水"
  },
  {
    szDesc = "缺肥",
    szCureTool = "肥料",
    szCureNotify = "本次施肥，树丛的成熟时间加快[FFFE0D]%s[-]",
    szFailedMsg = "泥土看起来十分肥沃，无需施肥"
  },
  {
    szDesc = "生虫",
    szCureTool = "除虫剂",
    szCureNotify = "本次除虫，树丛的成熟时间加快[FFFE0D]%s[-]",
    szFailedMsg = "植物看起来很健康，无需除虫"
  }
}
HousePlant.CURE_COST = 50
HousePlant.CURE_TIME_NORMAL = 3600
HousePlant.CURE_TIME_COST = 7200
HousePlant.CURE_COST_AWARD = 500
HousePlant.CURE_INTIMACY = 50
HousePlant.CURE_INTIMACY_COST = 100
HousePlant.CURE_TIMES_REFRESH_TIME = 14400
HousePlant.tbSickGapSetting = {
  {nHour = 2, nSickGap = 7200},
  {nHour = 10, nSickGap = 14400},
  {nHour = 24, nSickGap = 7200}
}
if MODULE_GAMESERVER then
  function HousePlant:LoadLevelRatioSetting(szFile, nMaxIndex, szKey)
    local tbSetting = {}
    local szType = "s"
    local tbCol = {
      "szTimeFrame"
    }
    for i = 1, nMaxIndex do
      szType = szType .. "dd"
      table.insert(tbCol, "nRatio" .. i)
      table.insert(tbCol, szKey .. i)
    end
    local tbFile = LoadTabFile(szFile, szType, nil, tbCol)
    for _, tbRow in pairs(tbFile) do
      local tbLevelSetting = {}
      tbLevelSetting.szTimeFrame = tbRow.szTimeFrame
      assert(tbLevelSetting.szTimeFrame ~= "")
      local tbRand = {}
      local nTotalRatio = 0
      for i = 1, nMaxIndex do
        local nRatio = tbRow["nRatio" .. i]
        assert(nRatio >= 0, szFile)
        table.insert(tbRand, {
          nResult = tbRow[szKey .. i],
          nRatio = nRatio
        })
        nTotalRatio = nTotalRatio + nRatio
      end
      assert(nTotalRatio == 1000, szFile)
      tbLevelSetting.tbRand = tbRand
      table.insert(tbSetting, tbLevelSetting)
    end
    return tbSetting
  end
  HousePlant.tbCropCountSetting = HousePlant:LoadLevelRatioSetting("Setting/HousePlant/CropCount.tab", 4, "nCount")
  HousePlant.tbCropItemSetting = HousePlant:LoadLevelRatioSetting("Setting/HousePlant/CropItem.tab", 5, "nItem")
  function HousePlant:RandResult(tbRand)
    local nRand = MathRandom(1, 1000)
    local nCurValue = 0
    for _, tbInfo in ipairs(tbRand) do
      nCurValue = nCurValue + tbInfo.nRatio
      if nRand <= nCurValue then
        return tbInfo.nResult
      end
    end
    assert(false, "failed to rand: " .. nRand)
    return -1
  end
  function HousePlant:GetCropSetting(tbSetting)
    local tbResult
    for _, tbInfo in ipairs(tbSetting) do
      if GetTimeFrameState(tbInfo.szTimeFrame) ~= 1 then
        break
      end
      tbResult = tbInfo
    end
    return tbResult
  end
  function HousePlant:RandCropCount()
    local tbSetting = self:GetCropSetting(self.tbCropCountSetting)
    return self:RandResult(tbSetting.tbRand)
  end
  function HousePlant:GetCropAward()
    local nCount = self:RandCropCount()
    if nCount <= 0 then
      return
    end
    local tbAward = {}
    local tbSetting = self:GetCropSetting(self.tbCropItemSetting)
    for i = 1, nCount do
      local nItemId = self:RandResult(tbSetting.tbRand)
      table.insert(tbAward, {
        "item",
        nItemId,
        1
      })
    end
    return tbAward
  end
  function HousePlant:CalcuSickTime()
    local nCurTime = GetTime()
    local nDayHour = Lib:GetLocalDayHour(nCurTime)
    for _, tbSetting in ipairs(self.tbSickGapSetting) do
      if nDayHour <= tbSetting.nHour then
        return nCurTime + tbSetting.nSickGap
      end
    end
  end
end
function HousePlant:IsSickState(nState)
  return HousePlant.tbSickStateSetting[nState] and true or false
end
