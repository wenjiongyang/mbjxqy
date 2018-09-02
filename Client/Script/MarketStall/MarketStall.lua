local eventHandlers = {
  [MarketStall.emEvent_OnItemSelled] = "OnItemSelled",
  [MarketStall.emEvent_OnItemTimeout] = "OnItemTimeout",
  [MarketStall.emEvent_OnNewSellItem] = "OnNewSellItem",
  [MarketStall.emEvent_OnUpdateMyItemPrice] = "OnUpdateMyItemPrice",
  [MarketStall.emEvent_OnCancelSellItem] = "OnCancelSellItem",
  [MarketStall.emEvent_OnGetCacheMoney] = "OnGetCacheMoney",
  [MarketStall.emEvent_OnGetMySellItemInfo] = "OnGetMySellItemInfo",
  [MarketStall.emEvent_OnGetItemList] = "OnGetItemList",
  [MarketStall.emEvent_OnUpdateAllStall] = "OnUpdateAllStall",
  [MarketStall.emEvent_OnBuyItem] = "OnBuyItem",
  [MarketStall.emEvent_OnGetAvaragePrice] = "OnGetAvaragePrice",
  [MarketStall.emEvent_OnHasLowerPrice] = "OnHasLowerPrice"
}
MarketStall.tbItemStates = {TimeOut = 2, Normal = 3}
function MarketStall:OnLogin()
  self.tbData = {
    nLastUpdateTime = 0,
    tbMyItems = {},
    tbAvaliableItems = {},
    newTimeoutItems = false,
    nCurStallType = nil,
    nCurAllStallTab = nil
  }
end
function MarketStall:OnEvent(nEvent, ...)
  local handlerName = eventHandlers[nEvent]
  assert(handlerName, string.format("nEvent=%s", nEvent))
  local handler = self[handlerName]
  assert(handler, string.format("nEvent=%s, handlerName=%s", nEvent, handlerName))
  handler(self, ...)
end
local rpc = RemoteServer.CallMarketStallFunc
function MarketStall:RefreshType(nType)
  if not nType or not self.tbAllType[nType] then
    Log("[x] MarketStall:RefreshType", nType)
    return
  end
  rpc("GetAllItems", nType)
end
function MarketStall:RefreshMine()
  rpc("GetMySellItemInfo")
end
function MarketStall:ManualRefresh()
  local cost = self:GetManualRefreshCost()
  if cost > me.GetMoney("Gold") then
    Ui:OpenWindow("CommonShop", "Recharge", "Recharge")
    me.CenterMsg("元宝不足")
    return false
  end
  rpc("UpdateAllStall", cost > 0, self.tbData.nLastUpdateTime)
  return true
end
function MarketStall:AutoRefresh()
  local cost = self:GetManualRefreshCost()
  if cost > 0 then
    return
  end
  rpc("UpdateAllStall", false, self.tbData.nLastUpdateTime)
end
function MarketStall:GetCachedMoney(nIndex)
  local nStallId
  local total = 0
  if nIndex then
    local tbData = self.tbData.tbMyItems[nIndex]
    total = tbData.nCacheMoney
    nStallId = tbData.nStallId
  else
    total = self:GetTotalCachedMoney()
  end
  if total <= 0 then
    me.CenterMsg("当前没有可领取的收益")
    return
  end
  rpc("GetCacheMoney", nStallId)
end
function MarketStall:Buy(tbData, nCount)
  if nCount <= 0 then
    return false
  end
  if nCount > tbData.nCount then
    return false
  end
  local cost = nCount * tbData.nPrice
  if cost > me.GetMoney("Gold") then
    Ui:OpenWindow("CommonShop", "Recharge", "Recharge")
    me.CenterMsg("你的元宝不足")
    return false
  end
  rpc("BuyItem", tbData.szMainType, tbData.nSubType, nCount, tbData.nPrice)
  return true
end
function MarketStall:NewSell(nIndex, nPrice, nCount)
  local tbData = self.tbData.tbAvaliableItems[nIndex]
  if not tbData then
    return
  end
  local szMainType = tbData.szMainType
  local nSubType = tbData.nSubType
  local nItemId = tbData.nItemId or nSubType
  local can, err = self:CheckCanNewSellItem(me, szMainType, nItemId, nCount, nPrice)
  if not can then
    me.CenterMsg(err)
    return false
  end
  self:SetSavedPrice(szMainType, nSubType, nPrice)
  rpc("NewSellItem", szMainType, nItemId, nCount, nPrice)
  return true
end
function MarketStall:CancelSell(nIndex)
  local tbData = self.tbData.tbMyItems[nIndex]
  rpc("CancelSellItem", tbData.nStallId)
  return true
end
function MarketStall:UpdateSell(nIndex, nCount, nPrice)
  local tbData = self.tbData.tbMyItems[nIndex]
  local can, err = self:CheckCanUpdateItemPrice(me, tbData.szMainType, tbData.nSubType, nCount, nPrice)
  if not can then
    me.CenterMsg(err)
    return false
  end
  rpc("UpdateMyItemPrice", tbData.nStallId, nPrice)
  return true
end
function MarketStall:GetAvgPrice(szMainType, nSubType)
  rpc("GetAvaragePrice", szMainType, nSubType)
  return true
end
function MarketStall:GetNextRefreshInterval()
  local now = GetTime()
  local interval = MarketStall.nUpdateStallItemListTime - (now - self.tbData.nLastUpdateTime)
  return math.min(math.max(0, interval), MarketStall.nUpdateStallItemListTime)
end
function MarketStall:GetTotalCachedMoney()
  local total = 0
  for _, v in ipairs(self.tbData.tbMyItems) do
    total = total + v.nCacheMoney
  end
  return total
end
function MarketStall:GetManualRefreshCost()
  return self:GetNextRefreshInterval() > 0 and self.nManualRefreshCost or 0
end
function MarketStall:GetAvaliableItems()
  local ret = {}
  for szMainType, tb in pairs(MarketStall.tbAllStallInfo) do
    local nType = Player.AwardType[szMainType]
    if nType == Player.award_type_item then
      for nSubType in pairs(tb) do
        local tbItems = me.FindItemInBag(nSubType)
        if tbItems and #tbItems > 0 then
          for _, pItem in ipairs(tbItems) do
            local nCount = pItem.nCount
            local nItemId = pItem.dwId
            if nCount > 0 and MarketStall:CheckCanSellItem(me, szMainType, nItemId) then
              table.insert(ret, {
                szMainType = szMainType,
                nSubType = nSubType,
                nItemId = nItemId,
                nCount = nCount
              })
            end
          end
        end
      end
    elseif nType == Player.award_type_money then
      local nCount = me.GetMoney(szMainType)
      if nCount > 0 then
        table.insert(ret, {
          szMainType = szMainType,
          nSubType = 0,
          nCount = nCount
        })
      end
    else
      print("[x] MarketStall:GetAvaliableItems, unsupported type", szMainType, nSubType, nType)
    end
  end
  table.sort(ret, function(a, b)
    local bA = self:CheckSellLimit(me, a.szMainType, a.nSubType)
    local bB = self:CheckSellLimit(me, b.szMainType, b.nSubType)
    if bA == bB then
      return a.szMainType < b.szMainType or a.szMainType == b.szMainType and a.nSubType < b.nSubType
    else
      return bA
    end
  end)
  self.tbData.tbAvaliableItems = ret
  return ret
end
function MarketStall:GetItemName(szMainType, nSubType)
  local nType = Player.AwardType[szMainType]
  if nType == Player.award_type_item then
    return KItem.GetItemShowInfo(nSubType, me.nFaction)
  elseif nType == Player.award_type_money then
    return Shop:GetMoneyName(szMainType)
  else
    print("[x] MarketStall:GetItemName, unsupported type", szMainType, nSubType, nType)
  end
end
function MarketStall:GetItemState(tbData)
  local ret = self.tbItemStates.Normal
  if tbData.nTime < GetTime() - MarketStall.nTimeout then
    ret = self.tbItemStates.TimeOut
  end
  return ret
end
function MarketStall:ClearNotifyStates()
  self.tbData.newTimeoutItems = false
  self:UpdateRedPoint()
end
function MarketStall:UpdateRedPoint()
  if self.tbData.newTimeoutItems then
    Ui:SetRedPointNotify("MarketStallMine")
  else
    Ui:ClearRedPointNotify("MarketStallMine")
  end
end
function MarketStall:_IsPosType(tbInfo, tbPosType)
  if not tbPosType or #tbPosType <= 0 then
    return true
  end
  local nType = tbInfo.nType
  local nSubType = tbInfo.nSubType
  if nType == 4 then
    local nIdFromPiece = Compose.EntityCompose:GetIdFromPiece(nSubType)
    local nPos = Item:GetItemTargetType(nIdFromPiece or nSubType)
    return Lib:IsInArray(tbPosType, nPos)
  elseif nType == 5 then
    local tbPos = StoneMgr:GetCanInsetPos(tbInfo.nSubType)
    if not tbPos then
      Log("[x] MarketStall:_IsPosType nil", tbInfo.nSubType)
    end
    for _, nPos in ipairs(tbPos or {}) do
      if Lib:IsInArray(tbPosType, nPos) then
        return true
      end
    end
    return false
  end
  return true
end
function MarketStall:_GetAllStallItems(nType)
  local tbRet = {}
  for szMainType, tb in pairs(self.tbAllStallInfo) do
    for nSubType, tbInfo in pairs(tb) do
      if nType == tbInfo.nType then
        local szName = ""
        if szMainType == "item" then
          szName = KItem.GetItemShowInfo(nSubType, me.nFaction)
        else
          szName = Shop:GetMoneyName(szMainType)
        end
        tbRet[nSubType] = {
          nType = tbInfo.nType,
          nIndex = tbInfo.nIndex,
          szName = szName,
          szMainType = tbInfo.szMainType,
          nSubType = tbInfo.nSubType,
          nCount = 0,
          tbItems = {}
        }
      end
    end
  end
  return tbRet
end
function MarketStall:GetShowStallItems(nType, tbPosType, bHideEmpty)
  local tbItems = self:_GetAllStallItems(nType)
  for _, tb in ipairs(self.tbFetchedStallItems or {}) do
    if tb.nType == nType then
      table.insert(tbItems[tb.nSubType].tbItems, tb)
      tbItems[tb.nSubType].nCount = tbItems[tb.nSubType].nCount + tb.nCount
    end
  end
  local tbRet = {}
  for _, tb in pairs(tbItems) do
    if (not bHideEmpty or tb.nCount > 0) and self:_IsPosType(tb, tbPosType) and MarketStall:GetPriceInfo(tb.szMainType, tb.nSubType) then
      table.insert(tbRet, tb)
    end
  end
  for _, tbInfo in pairs(tbItems) do
    table.sort(tbInfo.tbItems, function(tbA, tbB)
      return tbA.nPrice < tbB.nPrice
    end)
  end
  table.sort(tbRet, function(tbA, tbB)
    return tbA.nIndex < tbB.nIndex or tbA.nIndex == tbB.nIndex and tbA.nSubType < tbB.nSubType
  end)
  return tbRet
end
function MarketStall:OnUpdateAllStall()
  UiNotify.OnNotify(UiNotify.emNOTIFY_MARKET_STALL_REFRESH_ALL)
end
function MarketStall:OnGetItemList(nLastUpdateTime, nType, tbItems)
  self.tbFetchedStallItems = tbItems
  self.tbData.nLastUpdateTime = nLastUpdateTime
  UiNotify.OnNotify(UiNotify.emNOTIFY_MS_ITEM_LIST_CHANGE)
end
function MarketStall:SortMyItems()
  local tbItems = self.tbData.tbMyItems
  table.sort(tbItems, function(a, b)
    local sa = self:GetItemState(a)
    local sb = self:GetItemState(b)
    return sa < sb or sa == sb and a.nTime > b.nTime
  end)
  self.tbData.tbMyItems = tbItems
end
function MarketStall:OnGetMySellItemInfo(tbItems)
  self.tbData.tbMyItems = tbItems
  self:SortMyItems()
  UiNotify.OnNotify(UiNotify.emNOTIFY_MS_MY_ITEM_LIST_CHANGE)
  self:UpdateRedPoint()
end
function MarketStall:OnNewSellItem(bResult, tb)
  if not bResult then
    return
  end
  table.insert(self.tbData.tbMyItems, tb)
  self:SortMyItems()
  UiNotify.OnNotify(UiNotify.emNOTIFY_MS_MY_ITEM_LIST_CHANGE)
  local name = self:GetItemName(tb.szMainType, tb.nSubType)
  me.CenterMsg(string.format("成功上架了%s", name))
end
function MarketStall:OnCancelSellItem(bResult, tb)
  if not bResult then
    return
  end
  for i, v in ipairs(self.tbData.tbMyItems) do
    if v.nStallId == tb.nStallId then
      table.remove(self.tbData.tbMyItems, i)
      UiNotify.OnNotify(UiNotify.emNOTIFY_MS_MY_ITEM_LIST_CHANGE)
      local name = self:GetItemName(tb.szMainType, tb.nSubType)
      me.CenterMsg(string.format("你下架了%s", name))
      self:UpdateRedPoint()
      break
    end
  end
end
function MarketStall:OnUpdateMyItemPrice(bResult, tb)
  if not bResult then
    return
  end
  for i, v in ipairs(self.tbData.tbMyItems) do
    if v.nStallId == tb.nStallId then
      self.tbData.tbMyItems[i] = tb
      self:SortMyItems()
      UiNotify.OnNotify(UiNotify.emNOTIFY_MS_MY_ITEM_LIST_CHANGE)
      local name = self:GetItemName(tb.szMainType, tb.nSubType)
      me.CenterMsg(string.format("你重新上架了%s", name))
      break
    end
  end
end
function MarketStall:OnGetCacheMoney(bResult, nMoney)
  if not bResult then
    return
  end
  me.CenterMsg(string.format("你领取了收益%d元宝", nMoney))
  self:RefreshMine()
end
function MarketStall:OnBuyItem(bResult, tb)
  local tbOld
  for _, tbItem in ipairs(self.tbFetchedStallItems) do
    if tb.szMainType == tbItem.szMainType and (tb.nSubType or 0) == (tbItem.nSubType or 0) and tb.nPrice == tbItem.nPrice then
      tbOld = tbItem
      break
    end
    if tbOld then
      break
    end
  end
  local bNeedRefresh = false
  if not tbOld then
    tbOld = {}
    tbOld.szMainType = tb.szMainType
    tbOld.nSubType = tb.nSubType or 0
    tbOld.nPrice = tb.nPrice
    tbOld.nCount = tb.nCount
    bNeedRefresh = true
  end
  if not bResult then
    local err = "商品数量已变动，请重新确认"
    if not tb.nCount or 0 >= tb.nCount then
      err = "此商品已售罄"
    elseif tbOld.nPrice ~= tb.nPrice then
      err = "商品价格已变动，请重新确认"
      tbOld.bCanceled = true
    end
    me.CenterMsg(err)
  end
  tbOld.nCount = tb.nCount or 0
  tbOld.nPrice = tb.nPrice or tbOld.nPrice
  UiNotify.OnNotify(UiNotify.emNOTIFY_MS_ITEM_SOLD, bNeedRefresh)
  if bResult then
    local name = self:GetItemName(tb.szMainType, tb.nSubType)
    me.CenterMsg(string.format("你购买了%s", name))
  end
end
function MarketStall:OnItemTimeout()
  if not self.tbData then
    return
  end
  self.tbData.newTimeoutItems = true
  self:UpdateRedPoint()
end
function MarketStall:OnItemSelled()
  if not self.tbData then
    return
  end
  self:UpdateRedPoint()
end
function MarketStall:OnGetAvaragePrice(nPrice)
  UiNotify.OnNotify(UiNotify.emNOTIFY_MS_GET_AVG_PRICE, nPrice)
end
function MarketStall:OnHasLowerPrice(szMainType, nSubType, nCount, nPrice)
  UiNotify.OnNotify(UiNotify.emNOTIFY_MS_HAS_LOWER_PRICE, szMainType, nSubType, nCount, nPrice)
end
local tbSavedPrice = {}
local GetSavedPriceKey = function(szMainType, nSubType)
  return string.format("%s%d", szMainType, nSubType)
end
function MarketStall:SetSavedPrice(szMainType, nSubType, nPrice)
  local szKey = GetSavedPriceKey(szMainType, nSubType)
  tbSavedPrice[szKey] = nPrice
end
function MarketStall:GetSavedPrice(szMainType, nSubType)
  local szKey = GetSavedPriceKey(szMainType, nSubType)
  return tbSavedPrice[szKey]
end
function MarketStall:IsTypesOpened(nTypeId, tbPos)
  for _, nPos in ipairs(tbPos) do
    if self:IsTypeOpened(nTypeId, nPos) then
      return true
    end
  end
  return false
end
function MarketStall:IsTypeOpened(nTypeId, nPosType)
  self.tbTypeOpenedCache = self.tbTypeOpenedCache or {}
  if self.tbTypeOpenedCache[nTypeId] and (not nPosType or self.tbTypeOpenedCache[nTypeId][nPosType]) then
    return true
  end
  local tbItems = self:GetShowStallItems(nTypeId, {nPosType}, false)
  for _, tbItem in ipairs(tbItems) do
    local tbCfg = self.tbAllStallInfo[tbItem.szMainType][tbItem.nSubType]
    if tbCfg then
      local szTimeFrame = tbCfg.szOpenTimeFrame
      if szTimeFrame == "" or GetTimeFrameState(szTimeFrame) == 1 then
        self.tbTypeOpenedCache[nTypeId] = self.tbTypeOpenedCache[nTypeId] or {}
        if nPosType and nPosType > 0 then
          self.tbTypeOpenedCache[nTypeId][nPosType] = true
        end
        return true
      end
    end
  end
  return false
end
