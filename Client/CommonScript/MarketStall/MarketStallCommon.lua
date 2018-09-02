MarketStall.nOpenLevel = 20
MarketStall.nManualRefreshCost = 20
MarketStall.nTimeout = 86400
MarketStall.nPriceChangePrecent = 50
MarketStall.nShowCountOneType = 200
MarketStall.nUpdateStallItemListTime = 1800
MarketStall.nMyStoreMaxItems = 20
MarketStall.nMaxRandomRefreshTime = 2400
MarketStall.nJoinGlobalStallSpace = 1200
MarketStall.nStartServerJoinGlobalStallTime = 18000
MarketStall.tbForbiddenTime = {2, 10}
MarketStall.nMaxTimeFramCount = 20
MarketStall.nMaxPriceLimitTimeFrameCount = 20
MarketStall.bOpenMaxPriceLimitDynamic = true
MarketStall.nAvaragePriceCount = 10
MarketStall.nSellLimitTime = 604800
MarketStall.nSellLimitDataVersion = 1
if version_tx then
  MarketStall.bSellLimitOpen = false
else
  MarketStall.bSellLimitOpen = true
end
MarketStall.szCreateRoleTimeLimitTimeFrame = "OpenDay3C"
MarketStall.nCreateRoleTimeLimit = 3600
MarketStall.tbForbiddenTime[1] = MarketStall.tbForbiddenTime[1] * 3600
MarketStall.tbForbiddenTime[2] = MarketStall.tbForbiddenTime[2] * 3600
MarketStall.tbAllowCount = {
  [1] = true,
  [5] = true,
  [10] = true,
  [50] = true,
  [100] = true
}
MarketStall.emEvent_OnItemSelled = 1
MarketStall.emEvent_OnItemTimeout = 2
MarketStall.emEvent_OnNewSellItem = 3
MarketStall.emEvent_OnUpdateMyItemPrice = 4
MarketStall.emEvent_OnCancelSellItem = 5
MarketStall.emEvent_OnGetCacheMoney = 6
MarketStall.emEvent_OnGetMySellItemInfo = 7
MarketStall.emEvent_OnGetItemList = 8
MarketStall.emEvent_OnUpdateAllStall = 9
MarketStall.emEvent_OnBuyItem = 10
MarketStall.emEvent_OnGetAvaragePrice = 11
MarketStall.emEvent_OnHasLowerPrice = 12
function MarketStall:Load()
  local szType = "sddddddddssdd"
  local tbParam = {
    "szMainType",
    "nSubType",
    "nSellLimitType",
    "nSellLimitSubType",
    "nSellLimitLevel",
    "nType",
    "nIndex",
    "nMinPrecent",
    "nMaxPrecent",
    "szOpenTimeFrame",
    "szCloseTimeFrame",
    "nPrice",
    "nShowLimitPrecent"
  }
  for i = 1, self.nMaxTimeFramCount do
    szType = szType .. "sd"
    table.insert(tbParam, "szTimeFrame" .. i)
    table.insert(tbParam, "nPrice" .. i)
  end
  for i = 1, self.nMaxPriceLimitTimeFrameCount do
    szType = szType .. "ss"
    table.insert(tbParam, "szPriceLimitTimeFrame" .. i)
    table.insert(tbParam, "szLimitPrice" .. i)
  end
  local tbAllStallInfo = LoadTabFile("Setting/MarketStall/MarketStallItem.tab", szType, nil, tbParam)
  self.tbAllType = LoadTabFile("Setting/MarketStall/MarketTypeDef.tab", "ddsd", "nTypeId", {
    "nTypeId",
    "nShowCount",
    "szTypeName",
    "nIndex"
  })
  self.tbSellLimitInfo = {}
  self.tbAllStallInfo = {}
  for _, tbInfo in pairs(tbAllStallInfo) do
    local nType = tbInfo.nType
    assert(self.tbAllType[nType], string.format("Setting/MarketStall/MarketStallItem.tab type error !!! nType = %d", nType))
    self.tbSellLimitInfo[tbInfo.szMainType] = self.tbSellLimitInfo[tbInfo.szMainType] or {}
    self.tbSellLimitInfo[tbInfo.szMainType][tbInfo.nSubType] = {
      nType = tbInfo.nSellLimitType,
      nSubType = tbInfo.nSellLimitSubType,
      nLevel = tbInfo.nSellLimitLevel
    }
    tbInfo.nDefaultPrice = tbInfo.nPrice
    tbInfo.tbPriceInfo = {}
    for i = 1, self.nMaxTimeFramCount do
      local szTimeFrame = tbInfo["szTimeFrame" .. i]
      local nPrice = tbInfo["nPrice" .. i]
      if szTimeFrame and szTimeFrame ~= "" then
        assert(nPrice > 0, string.format("Setting/MarketStall/MarketStallItem.tab price error !!! nPrice = %d", nPrice))
        table.insert(tbInfo.tbPriceInfo, {szTimeFrame = szTimeFrame, nPrice = nPrice})
      end
    end
    tbInfo.tbPriceLimit = {}
    for i = 1, self.nMaxPriceLimitTimeFrameCount do
      local szTimeFrame = tbInfo["szPriceLimitTimeFrame" .. i]
      local szLimit = tbInfo["szLimitPrice" .. i]
      if szTimeFrame and szTimeFrame ~= "" and szLimit and szLimit ~= "" then
        local nMin, nMax = string.match(szLimit, "^(%d+)|(%d+)$")
        nMin = tonumber(nMin)
        nMax = tonumber(nMax)
        assert(nMin and nMax, "Setting/MarketStall/MarketStallItem.tab szLimitPrice error !!!")
        table.insert(tbInfo.tbPriceLimit, {
          szTimeFrame = szTimeFrame,
          nMin = nMin,
          nMax = nMax
        })
      end
    end
    if tbInfo.nShowLimitPrecent < 100 then
      tbInfo.nShowLimitPrecent = 120
    end
    tbInfo.nShowLimitPrecent = tbInfo.nShowLimitPrecent / 100
    self.tbAllStallInfo[tbInfo.szMainType] = self.tbAllStallInfo[tbInfo.szMainType] or {}
    assert(not self.tbAllStallInfo[tbInfo.szMainType][tbInfo.nSubType], "Setting/MarketStall/MarketStallItem.tab item repeat !!! ", tbInfo.szMainType, tbInfo.nSubType)
    self.tbAllStallInfo[tbInfo.szMainType][tbInfo.nSubType] = tbInfo
  end
end
function MarketStall:GetVipShowCount(nCurCount, nVipLevel)
  if nVipLevel >= 17 then
    return nCurCount * 2
  elseif nVipLevel >= 10 then
    return nCurCount * 1.5
  else
    return nCurCount
  end
end
function MarketStall:GetShowCount(nType)
  local tbTypeInfo = self.tbAllType[nType]
  if not (tbTypeInfo and tbTypeInfo.nShowCount) or tbTypeInfo.nShowCount < 1 then
    return self.nShowCountOneType
  end
  return tbTypeInfo.nShowCount
end
function MarketStall:UpdatePrice(tbInfo)
  if MODULE_GAMECLIENT then
    tbInfo.dwClientPlayerId = me.dwID
  end
  tbInfo.nPrice = tbInfo.nDefaultPrice
  for _, tbPriceInfo in ipairs(tbInfo.tbPriceInfo) do
    local nPrice = tbPriceInfo.nPrice
    local szTimeFrame = tbPriceInfo.szTimeFrame
    if GetTimeFrameState(szTimeFrame) == 1 then
      tbInfo.nPrice = nPrice
    else
      tbInfo.szNextTimeFrame = szTimeFrame
      break
    end
  end
  local nMaxPrecent, nMinPrecent = tbInfo.nMaxPrecent, tbInfo.nMinPrecent
  for _, tbLimit in ipairs(tbInfo.tbPriceLimit) do
    local szTimeFrame = tbLimit.szTimeFrame
    if GetTimeFrameState(szTimeFrame) == 1 then
      nMaxPrecent, nMinPrecent = tbLimit.nMax, tbLimit.nMin
    else
      tbInfo.szNextPriceLimitTimeFrame = szTimeFrame
      break
    end
  end
  if not self.bOpenMaxPriceLimitDynamic then
    nMaxPrecent, nMinPrecent = tbInfo.nMaxPrecent, tbInfo.nMinPrecent
  end
  tbInfo.tbAllowPrice = {}
  for nCurPrecent = math.max(1900, nMaxPrecent), nMinPrecent, -self.nPriceChangePrecent do
    if nCurPrecent <= nMaxPrecent and nCurPrecent >= nMinPrecent then
      local nCurPrice = math.floor(tbInfo.nPrice * nCurPrecent / 100)
      tbInfo.tbAllowPrice[nCurPrice] = 1
    end
  end
end
MarketStall:Load()
function MarketStall:GetPriceInfo(szMainType, nSubType)
  local tbInfo = (self.tbAllStallInfo[szMainType] or {})[nSubType or 0]
  if not tbInfo then
    return
  end
  if MODULE_GAMECLIENT and me.dwID ~= tbInfo.dwClientPlayerId then
    self:UpdatePrice(tbInfo)
  end
  if tbInfo.szOpenTimeFrame and tbInfo.szOpenTimeFrame ~= "" and GetTimeFrameState(tbInfo.szOpenTimeFrame) ~= 1 then
    return
  end
  if tbInfo.szCloseTimeFrame and tbInfo.szCloseTimeFrame ~= "" and GetTimeFrameState(tbInfo.szCloseTimeFrame) == 1 then
    return
  end
  if not tbInfo.tbAllowPrice or tbInfo.szNextTimeFrame and GetTimeFrameState(tbInfo.szNextTimeFrame) == 1 or tbInfo.szNextPriceLimitTimeFrame and GetTimeFrameState(tbInfo.szNextPriceLimitTimeFrame) == 1 then
    self:UpdatePrice(tbInfo)
  end
  return tbInfo.nPrice, tbInfo.tbAllowPrice
end
function MarketStall:GetItemType(szMainType, nSubType)
  local tbInfo = (self.tbAllStallInfo[szMainType] or {})[nSubType or 0]
  if not tbInfo then
    return
  end
  return tbInfo.nType, tbInfo.nShowLimitPrecent
end
function MarketStall:CheckOpen()
  if MarketStall.bClose then
    return false
  end
  return true
end
function MarketStall:GetStallAward(szMainType, nSubType, nCount)
  if not nSubType or nSubType <= 0 then
    return {szMainType, nCount}
  end
  return {
    szMainType,
    nSubType,
    nCount
  }
end
function MarketStall:GetStallAwardName(szMainType, nSubType, nFaction)
  local nType = Player.AwardType[szMainType]
  local szName = "道具名"
  if nType == Player.award_type_item then
    szName = KItem.GetItemShowInfo(nSubType, nFaction)
  elseif nType == Player.award_type_money then
    szName = Shop:GetMoneyName(szAwardType)
  end
  return szName
end
function MarketStall:RegisterCheckOpen(szType, fnCheck)
  self.tbCheckOpen = self.tbCheckOpen or {}
  self.tbCheckOpen[szType] = fnCheck
end
function MarketStall:IsMarketOpen(pPlayer)
  if GetTimeFrameState(self.szCreateRoleTimeLimitTimeFrame) == 1 and GetTime() - pPlayer.dwCreateTime < self.nCreateRoleTimeLimit then
    return false, "新建角色24小时后开启摆摊"
  end
  if pPlayer.nLevel < self.nOpenLevel then
    return false, string.format("%d级后开放摆摊", self.nOpenLevel)
  end
  for szType, fnCheck in pairs(self.tbCheckOpen or {}) do
    local bRet, szMsg = fnCheck(pPlayer)
    if not bRet then
      return bRet, szMsg
    end
  end
  return true
end
function MarketStall:IsMyStoreFull(pPlayer)
  if MODULE_GAMESERVER then
    local tbPlayerInfo = self.tbStallInfoByPlayer[pPlayer.dwID] or {}
    return Lib:CountTB(tbPlayerInfo) >= self.nMyStoreMaxItems
  else
    return #self.tbData.tbMyItems >= self.nMyStoreMaxItems
  end
end
function MarketStall:GetSellCost(nTotalPrice)
  return math.max(math.ceil(nTotalPrice * 0.01), 1)
end
function MarketStall:CheckCanSellItem(pPlayer, szMainType, nSubType)
  local nAwardType = Player.AwardType[szMainType]
  if not nAwardType then
    return false, "上架物品未知"
  end
  local nCurCount = 0
  local pItem
  if nAwardType == Player.award_type_item then
    pItem = pPlayer.GetItemInBag(nSubType)
    if not pItem then
      return false, "无效道具，不可出售"
    end
    local tbInfo = (self.tbAllStallInfo[szMainType] or {})[pItem.dwTemplateId]
    if not tbInfo then
      return false, "此物品不可上架"
    end
    if tbInfo.szCloseTimeFrame and tbInfo.szCloseTimeFrame ~= "" and GetTimeFrameState(tbInfo.szCloseTimeFrame) == 1 then
      return false, "陈旧物品，不能上架"
    end
    if pItem.nPos ~= Item.emITEMPOS_BAG then
      return false, "只有背包内的道具才可以摆摊"
    end
    local bCanSell = Item:CheckCanSell(pItem)
    if not bCanSell then
      return false, "此物品不可出售"
    end
    nCurCount = pItem.nCount
  elseif nAwardType == Player.award_type_money then
    nCurCount = pPlayer.GetMoney(szMainType)
  else
    return false, "上架物品类型未知！"
  end
  local _, tbPriceInfo = self:GetPriceInfo(szMainType, pItem and pItem.dwTemplateId or nSubType)
  if not tbPriceInfo then
    return false, "不可上架物品"
  end
  return true, "", nCurCount, pItem, tbPriceInfo
end
function MarketStall:CheckCanNewSellItem(pPlayer, szMainType, nSubType, nCount, nPrice, bIgnorCheckCost)
  if self:IsMyStoreFull(pPlayer) then
    return false, "不能上架更多物品"
  end
  if not self.tbAllowCount[nCount] then
    return false, "上架物品数量有误"
  end
  local bRet, szMsg, nCurCount, pItem, tbPriceInfo = self:CheckCanSellItem(pPlayer, szMainType, nSubType)
  if not bRet then
    return false, szMsg
  end
  local bCanSell, nLastTime = self:CheckSellLimit(pPlayer, szMainType, pItem and pItem.dwTemplateId or nSubType)
  if not bCanSell then
    return false, string.format("%s后才可以上架此物品", Lib:TimeDesc6(nLastTime))
  end
  if not bIgnorCheckCost and nCount > nCurCount then
    return false, "大侠没有这么多物品呀！"
  end
  if not tbPriceInfo or not tbPriceInfo[nPrice] then
    return false, "这东西不能使用这个价格上架哟！"
  end
  local nCost = self:GetSellCost(nCount * nPrice)
  local nHasGold = pPlayer.GetMoney("Gold")
  if not bIgnorCheckCost and nCost > nHasGold then
    return false, "手续费不足，无法上架"
  end
  return true, "", nCost, pItem
end
function MarketStall:CheckCanUpdateItemPrice(pPlayer, szMainType, nSubType, nCount, nPrice, bIgnorCheckCost)
  if nCount <= 0 then
    return false, "此物品已经售完，无需重新上架！"
  end
  local _, tbPriceInfo = self:GetPriceInfo(szMainType, nSubType)
  if not tbPriceInfo or not tbPriceInfo[nPrice] then
    return false, "这东西不能使用这个价格上架哟！"
  end
  local bCanSell, nLastTime = self:CheckSellLimit(pPlayer, szMainType, nSubType)
  if not bCanSell then
    return false, string.format("%s后才可以重新上架此物品", Lib:TimeDesc6(nLastTime))
  end
  local nCost = math.max(math.ceil(nCount * nPrice * 0.01), 1)
  local nHasGold = pPlayer.GetMoney("Gold")
  if not bIgnorCheckCost and nCost > nHasGold then
    return false, "手续费不足，无法上架"
  end
  return true, "", nCost
end
function MarketStall:OnSyncSelllLimitData(tbData)
  if MODULE_GAMESERVER then
    return
  end
  local tbPlayerInfo = me.GetScriptTable("MarketStall")
  tbPlayerInfo.tbSellLimitInfo = tbData
end
function MarketStall:GetSellLimitInfo(pPlayer)
  local tbPlayerInfo = pPlayer.GetScriptTable("MarketStall")
  tbPlayerInfo.tbSellLimitInfo = tbPlayerInfo.tbSellLimitInfo or {}
  if not tbPlayerInfo.tbSellLimitInfo.nVersion or tbPlayerInfo.tbSellLimitInfo.nVersion ~= self.nSellLimitDataVersion then
    tbPlayerInfo.tbSellLimitInfo = {
      nVersion = self.nSellLimitDataVersion
    }
  end
  return tbPlayerInfo.tbSellLimitInfo
end
function MarketStall:CheckSellLimit(pPlayer, szMainType, nSubType)
  if not self.bSellLimitOpen then
    return true
  end
  local tbLimitInfo = (self.tbSellLimitInfo[szMainType] or {})[nSubType or 0]
  if not tbLimitInfo then
    Log("[MarketStall] get tbLimitInfo fail !!", szMainType, nSubType or 0)
    return true
  end
  local nCurType = tbLimitInfo.nType
  local nCurSubType = tbLimitInfo.nSubType
  local nCurLevel = tbLimitInfo.nLevel
  local tbSellLimitInfo = self:GetSellLimitInfo(pPlayer)
  local tbLimit = tbSellLimitInfo[nCurType]
  if not tbLimit then
    return true
  end
  local nBuyTime = 0
  for nLevel, tbInfo in pairs(tbLimit) do
    if nLevel <= nCurLevel then
      for nSubLimitType, nTime in pairs(tbInfo) do
        if nLevel < nCurLevel or nSubLimitType == nCurSubType then
          nBuyTime = math.max(nTime, nBuyTime)
        end
      end
    end
  end
  local nLastTime = self.nSellLimitTime - (GetTime() - nBuyTime)
  return nLastTime <= 0, nLastTime
end
function MarketStall:OnBuyItem_SellLimit(nSellLimitType, nSellLimitSubType, nSellLimitLevel, nTime, pPlayer)
  if not self.bSellLimitOpen then
    return
  end
  if MODULE_GAMESERVER then
    pPlayer.CallClientScript("MarketStall:OnBuyItem_SellLimit", nSellLimitType, nSellLimitSubType, nSellLimitLevel, nTime)
  else
    pPlayer = me
  end
  local tbSellLimitInfo = self:GetSellLimitInfo(pPlayer)
  tbSellLimitInfo[nSellLimitType] = tbSellLimitInfo[nSellLimitType] or {}
  tbSellLimitInfo[nSellLimitType][nSellLimitLevel] = tbSellLimitInfo[nSellLimitType][nSellLimitLevel] or {}
  tbSellLimitInfo[nSellLimitType][nSellLimitLevel][nSellLimitSubType] = nTime
end
function MarketStall:TipBuyItemFromMarket(pPlayer, nItemId, szTipsInfo)
  if MODULE_GAMESERVER then
    pPlayer.CallClientScript("MarketStall:TipBuyItemFromMarket", nil, nItemId, szTipsInfo)
    return
  end
  pPlayer = pPlayer or me
  if not szTipsInfo then
    local szItemName = KItem.GetItemShowInfo(nItemId, pPlayer.nFaction)
    szTipsInfo = string.format("[FFFE0D]%s[-]数量不足，是否前往摆摊购买？", szItemName)
  end
  pPlayer.MsgBox(szTipsInfo, {
    {
      "前往",
      function()
        Ui:OpenWindow("MarketStallPanel", 1, nil, "item", nItemId)
      end
    },
    {"取消"}
  })
end
