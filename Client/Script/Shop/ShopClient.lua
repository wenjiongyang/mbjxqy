Shop.tabUiKeyName = {
  tabActShop = "服务端传的名字",
  tabLimitShop = "每周限购",
  tabAllShop = "全部",
  tabDressWaiyiShop = "衣服外装",
  tabDressWeaponShop = "武器外装"
}
function Shop:CheckRedPoint()
  local bShowRed = false
  local nSeeShopActStartTime = Client:GetFlag("SeeShopActStartTime") or 0
  local nSeeWeek = Lib:GetLocalWeek(nSeeShopActStartTime - self.TREASURE_REFRESH)
  if nSeeWeek < Lib:GetLocalWeek(GetTime() - self.TREASURE_REFRESH) then
    bShowRed = true
    self.nLimitSynced = nil
  end
  if not bShowRed then
    local tbUiData, tbActData = Activity:GetActUiSetting("ShopAct")
    if tbUiData and tbActData and nSeeShopActStartTime < tbActData.nStartTime then
      bShowRed = true
    end
  end
  if bShowRed then
    Ui:SetRedPointNotify("CommonShopTab")
  else
    Ui:ClearRedPointNotify("CommonShopTab")
  end
end
function Shop:GetShopWares(szShopType, szTabKey, bNotCopy)
  if Shop.tbFamilyShopCharToId[szShopType] then
    return self:GetFamilyShopWares(szShopType)
  end
  local tbRet = {}
  if szShopType == "Treasure" then
    local tbShopWares = self.ShopWares[szShopType]
    if szTabKey == "tabAllShop" then
      for k, v in pairs(tbShopWares) do
        if not v.nLimitType then
          table.insert(tbRet, v)
        end
      end
    elseif szTabKey == "tabLimitShop" then
      for k, v in pairs(tbShopWares) do
        if v.nLimitType == self.WEEK_LIMIT_TYPE then
          table.insert(tbRet, v)
        end
      end
    elseif szTabKey == "tabActShop" then
      for k, v in pairs(tbShopWares) do
        if v.nLimitType == self.ACT_LIMIT_TYPE then
          table.insert(tbRet, v)
        end
      end
    end
  elseif szShopType == "Dress" then
    local tbShopWares = self.ShopWares[szShopType]
    local tbChangeColor = Item.tbChangeColor
    if szTabKey == "tabDressWeaponShop" then
      for k, v in pairs(tbShopWares) do
        if not v.nLimitType then
          local nTargetId = Item.tbEquipExchange:GetTargetItem(v.nTemplateId)
          if nTargetId then
            local nTarPart = tbChangeColor:GetChangePart(nTargetId)
            if nTarPart == 1 then
              table.insert(tbRet, v)
            end
          end
        end
      end
    elseif szTabKey == "tabActShop" then
      for k, v in pairs(tbShopWares) do
        if v.nLimitType == self.ACT_LIMIT_TYPE then
          table.insert(tbRet, v)
        end
      end
    else
      for k, v in pairs(tbShopWares) do
        if not v.nLimitType then
          local nTargetId = Item.tbEquipExchange:GetTargetItem(v.nTemplateId)
          if nTargetId then
            local nTarPart = tbChangeColor:GetChangePart(nTargetId)
            if nTarPart ~= 1 then
              table.insert(tbRet, v)
            end
          else
            table.insert(tbRet, v)
          end
        end
      end
    end
  else
    tbRet = self.ShopWares[szShopType] or {}
  end
  local tbAfterFilter = {}
  for k, v in pairs(tbRet) do
    if self:CheckWareAvaliable(v, me) then
      table.insert(tbAfterFilter, v)
    end
  end
  if #tbAfterFilter == 0 and self.tbActShopTypes and szTabKey == "tabActShop" then
    self.tbActShopTypes[szShopType] = nil
    UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_SHOP_WARE)
  end
  if not bNotCopy then
    return Lib:CopyTB(tbAfterFilter)
  else
    return tbAfterFilter
  end
end
function Shop:GetFamilyShopWares(szShopType)
  local nBuildingId = self.tbFamilyShopCharToId[szShopType]
  if not nBuildingId then
    return
  end
  if not self.FamilyPool[szShopType] then
    local nMyLevel = self:GetBuildingLevel(me, nBuildingId)
    if not self.tbLocalUpdateWareBuidLevel[nBuildingId] or nMyLevel > self.tbLocalUpdateWareBuidLevel[nBuildingId] then
      local tbShopData = {}
      self.tbFamilyShopData[szShopType] = tbShopData
      local tbWares = self.ShopWares[szShopType]
      for nLevel, v in pairs(tbWares) do
        if nLevel <= nMyLevel then
          for TemplateId, _ in pairs(v) do
            table.insert(tbShopData, {nTemplateId = TemplateId})
          end
        end
      end
      self.tbLocalUpdateWareBuidLevel[nBuildingId] = nMyLevel
    end
  end
  local tbWares = self.tbFamilyShopData[szShopType]
  if not tbWares then
    return
  end
  local tbRet = {}
  for i, v in ipairs(tbWares) do
    local tbCur = self:GetAWare(szShopType, v.nTemplateId)
    if tbCur then
      local tbWare = Lib:CopyTB1(tbCur)
      tbWare.nRemainCount = v.nCount
      tbWare.nPrice, tbWare.nDiscount = self:GetPrice(me, tbWare)
      table.insert(tbRet, tbWare)
    end
  end
  return tbRet
end
function Shop:GetFaimlyWareRemainClient(szShopType, nTemplateId)
  if not self.FamilyPool[szShopType] then
    return
  end
  local tbWares = self.tbFamilyShopData[szShopType]
  for _, tbWare in pairs(tbWares) do
    if tbWare.nTemplateId == nTemplateId then
      return tbWare.nCount
    end
  end
  Log("ERROR IN GetFaimlyWareRemainClient", szShopType, nTemplateId)
  return 0
end
function Shop:GetBuildingLevelClient(nBuildingId)
  local tbBuildingData = Kin:GetBuildingData(nBuildingId)
  local nBuildingLevel = tbBuildingData and tbBuildingData.nLevel or 0
  return nBuildingLevel
end
function Shop:OnSyncShopWares(szShopType, tbShopWares, nSyncTemplateId)
  local tbWares = self.ShopWares[szShopType]
  if nSyncTemplateId then
    if self:IsFamilyShop(szShopType) then
      tbWares[tbShopWares.nLevel][tbShopWares.nPool][nSyncTemplateId] = tbShopWares
    else
      tbWares[nSyncTemplateId] = tbShopWares
    end
  else
    for nTemplateId, tbWare in pairs(tbShopWares) do
      tbWares[nTemplateId] = tbWare
    end
  end
  UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_SHOP_WARE)
end
function Shop:OnSyncFamilyShopData(szShopType, tbWareData)
  self.tbFamilyShopData[szShopType] = tbWareData
  UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_SHOP_WARE)
end
function Shop:OnBuyResponse(bSuccess, szTip, nRequestIndex)
  if nRequestIndex then
    self.nRequestIndex = nRequestIndex
  end
  UiNotify.OnNotify(UiNotify.emNOTIFY_SHOP_BUY_RESULT, bSuccess)
  if szTip then
    me.CenterMsg(szTip)
  end
end
function Shop:OnSellResponse(bSuccess, szTip, nRequestIndex)
  if nRequestIndex then
    self.nRequestIndex = nRequestIndex
  end
  UiNotify.OnNotify(UiNotify.emNOTIFY_SHOP_SELL_RESULT, bSuccess)
  if szTip then
    me.CenterMsg(szTip)
  end
end
function Shop:GetLimitInfo(pPlayer, nLimitType)
  if nLimitType == self.ACT_LIMIT_TYPE then
    return self.tbActLimitInfo
  elseif nLimitType == self.Special_LIMIT_TYPE then
    return self.tbActivityLimitSell
  else
    return self.tbAllWeekLimit
  end
end
function Shop:OnSyncBuyLimitInfo(tbWeekInfo)
  self.tbAllWeekLimit = tbWeekInfo
  self.nLimitSynced = me.dwID
  UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_SHOP_WARE)
end
function Shop:OnSyncSpecailBuyLimitInfo(tbLimitInfo)
  self.tbActivityLimitSell = tbLimitInfo
  UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_SHOP_WARE)
end
function Shop:RequestLimitInfo()
  if self.nLimitSynced ~= me.dwID then
    RemoteServer.OnShopRequest("SyncBuyLimitInfo")
  end
  if Activity:__IsActInProcessByType("ShopAct") then
    local tbUiData, tbActData = Activity:GetActUiSetting("ShopAct")
    if self.nShopActStartTime ~= tbActData.nStartTime then
      self.tabUiKeyName.tabActShop = tbUiData.szName
      RemoteServer.OnShopRequest("SyncActWaresInfo")
    end
  elseif self.nShopActStartTime then
    self.nShopActStartTime = nil
    self.tbActShopTypes = nil
    self.tbActLimitInfo = {}
    UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_SHOP_WARE)
  end
end
function Shop:ConfirmSell(nItemId)
  Ui:CloseWindow("ItemTips")
  Ui:OpenWindow("ItemSellPanel", nItemId)
end
function Shop:SellFakeItem(szType, nItemTemplateId, nCount)
  Ui:CloseWindow("ItemTips")
  Ui:OpenWindow("ItemTemplateSellPanel", szType, nItemTemplateId, nCount)
end
function Shop:QuickSellItem(nItemId, szDesc)
  local pItem = KItem.GetItemObj(nItemId)
  if not pItem then
    return
  end
  local nPrice, szMoneyType = self:GetSellSumPrice(me, pItem.dwTemplateId, pItem.nCount)
  if not szMoneyType or not nPrice then
    return
  end
  local function fnAgree()
    local tbToSell = {
      {
        nId = nItemId,
        nCount = pItem.nCount
      }
    }
    RemoteServer.OnShopRequest("Sell", tbToSell, self.nRequestIndex)
  end
  local szName = pItem.GetItemShowInfo(me.nFaction)
  local szMsg = ""
  if szDesc then
    szMsg = string.format(szDesc, nPrice, Shop:GetMoneyName(szMoneyType))
  else
    szMsg = string.format("您确定以 [FFFE0D]%d%s[-] 的价格卖出 [FFFE0D]%s[-] 吗？", nPrice, Shop:GetMoneyName(szMoneyType), szName)
  end
  Ui:OpenWindow("MessageBox", szMsg, {
    {fnAgree},
    {}
  }, {"同意", "取消"})
end
function Shop:ViewMyEquip(nSelItemTemplate)
  local tbBaseInfo = KItem.GetItemBaseProp(nSelItemTemplate)
  if tbBaseInfo.szClass == "Unidentify" then
    nSelItemTemplate = KItem.GetItemExtParam(nSelItemTemplate, 1)
    tbBaseInfo = KItem.GetItemBaseProp(nSelItemTemplate)
  end
  if tbBaseInfo.szClass ~= "equip" then
    return
  end
  local nSelPos = Item.EQUIPTYPE_POS[tbBaseInfo.nItemType]
  local tbEquips = me.GetEquips()
  local nWareId = tbEquips[nSelPos]
  if not nWareId then
    me.CenterMsg("您身上没有装备" .. Item.EQUIPPOS_NAME[nSelPos])
    return
  end
  Ui:OpenWindowAtPos("EquipTips", -315, 234, nWareId)
end
function Shop:MakeEquip(nId)
  local nCan, szErr = self:CanMakeEquip(me, nId)
  if not nCan then
    me.CenterMsg(szErr)
    return false
  end
  RemoteServer.OnShopRequest("MakeEquip", nId)
  return true
end
function Shop:GetEquipMakerQualities(nHouseId)
  local tbHouseItemId = self.tbEquipMakerIdMap[nHouseId]
  local tbRet = {}
  for nQuality, tb in pairs(tbHouseItemId) do
    if self:IsEquipMakerQualityOpen(nQuality) then
      local tbSetting = self.tbEquipMakerSettings[tb[1]]
      table.insert(tbRet, {
        nQuality = nQuality,
        szQualityName = tbSetting.szQualityName
      })
    end
  end
  table.sort(tbRet, function(tbA, tbB)
    return tbA.nQuality > tbB.nQuality
  end)
  return tbRet
end
function Shop:GetEquipMakerItems(nHouseId, nQuality)
  local tbRet = {}
  local tbHouseItemId = self.tbEquipMakerIdMap[nHouseId]
  for _, nId in ipairs(tbHouseItemId[nQuality] or {}) do
    table.insert(tbRet, self.tbEquipMakerSettings[nId])
  end
  return tbRet
end
function Shop:OnEquipMakerRet(nItemId)
  UiNotify.OnNotify(UiNotify.emNOTIFY_EQUIP_MAKE_RSP, nItemId)
end
function Shop:AutoChooseItem(nItemId)
  local tbAllTreaste = Shop:GetShopWares("Treasure", "tabLimitShop", true)
  for i, v in ipairs(tbAllTreaste) do
    if v.nTemplateId == nItemId then
      if Shop:GetWareRemainCount(me, v) > 0 then
        Ui:OpenWindow("CommonShop", "Treasure", "tabLimitShop", nItemId)
        Ui:CloseWindow("ItemTips")
        return true
      end
      break
    end
  end
  local tbAllTreaste = Shop:GetShopWares("Treasure", "tabAllShop", true)
  for i, v in ipairs(tbAllTreaste) do
    if v.nTemplateId == nItemId then
      Ui:OpenWindow("CommonShop", "Treasure", "tabAllShop", nItemId)
      Ui:CloseWindow("ItemTips")
      return true
    end
  end
  return false
end
function Shop:OnSyncActWaresInfo(tbWares, tbActLimitInfo, nShopActStartTime)
  for szShopType, tbTreatureWares in pairs(Shop.ShopWares) do
    for nGoodsId, v in pairs(tbTreatureWares) do
      if v.nLimitType == self.ACT_LIMIT_TYPE then
        tbTreatureWares[nGoodsId] = nil
      end
    end
  end
  local tbShowShopTypes = {}
  for k, v in pairs(tbWares) do
    if Shop:CheckWareAvaliable(v, me) then
      local szShopType = v.szShopType
      local tbTreatureWares = Shop.ShopWares[szShopType]
      tbTreatureWares[v.nGoodsId] = v
      tbShowShopTypes[szShopType] = 1
    end
  end
  self.tbActShopTypes = tbShowShopTypes
  self.tbActLimitInfo = tbActLimitInfo
  self.nShopActStartTime = nShopActStartTime
  UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_SHOP_WARE)
end
function Shop:OnSyncActBuyLimitInfo(tbActLimitInfo)
  self.tbActLimitInfo = tbActLimitInfo
  UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_SHOP_WARE)
end
function Shop:RenownShopRefresh()
  if not self:ShouldRenownShopRefresh(me) then
    return
  end
  RemoteServer.OnShopRequest("RenownShopRefresh")
end
function Shop:RenownShopBuy(nId, nCount)
  local bOk, szErr = self:RenownShopCheckBeforeBuy(me, nId, nCount)
  if not bOk then
    me.CenterMsg(szErr)
    return
  end
  local tbSetting = self.tbRenownShop[nId]
  RemoteServer.OnShopRequest("RenownShopBuy", nId, nCount, tbSetting.nPrice)
end
function Shop:RenownShopRefreshed()
  UiNotify.OnNotify(UiNotify.emNoTIFY_RENOWN_SHOP_REFRESH)
end
function Shop:RenownShopBought(tbInfo)
  me.CenterMsg("购买成功")
  UiNotify.OnNotify(UiNotify.emNoTIFY_RENOWN_SHOP_REFRESH)
end
function Shop:RenownShopGetItems()
  local tbRet = {}
  for nId, tbSetting in pairs(self.tbRenownShop) do
    local nCount = me.GetUserValue(self.nRenownShopSaveGrp, nId)
    if nCount ~= 0 then
      table.insert(tbRet, {
        nId = nId,
        nIndex = tbSetting.nIndex,
        nItemId = tbSetting.nItemId,
        nPrice = tbSetting.nPrice,
        nLeft = nCount < 0 and 0 or nCount
      })
    end
  end
  table.sort(tbRet, function(tbA, tbB)
    return tbA.nIndex < tbB.nIndex or tbA.nIndex == tbB.nIndex and tbA.nId < tbB.nId
  end)
  return tbRet
end
Shop.tbBuyNotiyMsgFunc = {
  waiyi_exchange = function(nTemplateId, tbItemBase)
    local nTargetId = Item.tbEquipExchange:GetTargetItem(nTemplateId)
    if nTargetId then
      local tbBaseTar = KItem.GetItemBaseProp(nTargetId)
      if tbBaseTar.nFactionLimit > 0 then
        local szColor = tbBaseTar.nFactionLimit == me.nFaction and "FFFE0D" or "FF0000"
        return string.format("您即将购买[%s]%s[-]永久外装，此外装仅[%s]%s人士[-]可使用，切换其他门派后该外装即无法使用。您确认要购买吗？", szColor, tbItemBase.szName, szColor, Faction:GetName(tbBaseTar.nFactionLimit))
      end
    end
  end,
  ProposeItem = function(nTemplateId, tbItemBase)
    local nCount = me.GetItemCountInBags(nTemplateId)
    if nCount > 0 then
      return string.format("背包中已有[FFFE0D]%s[-]，确定要继续购买吗？", tbItemBase.szName)
    end
  end
}
function Shop:TryBuyItem(bKinStore, szShopType, nTemplateId, nGoodsId, nbuyCount, nPrice)
  local fnYes
  if bKinStore then
    function fnYes()
      RemoteServer.OnShopRequest("Buy", szShopType, nTemplateId, nbuyCount, nPrice, Shop.nRequestIndex)
    end
  else
    function fnYes()
      RemoteServer.OnShopRequest("BuyGoods", szShopType, nGoodsId, nbuyCount, nPrice, Shop.nRequestIndex)
    end
  end
  local szMsg
  local tbItemBase = KItem.GetItemBaseProp(nTemplateId)
  local fnNotiyMsgFunc = self.tbBuyNotiyMsgFunc[tbItemBase.szClass]
  if fnNotiyMsgFunc then
    szMsg = fnNotiyMsgFunc(nTemplateId, tbItemBase)
  end
  if szMsg then
    me.MsgBox(szMsg, {
      {"确认", fnYes},
      {"取消"}
    })
  else
    fnYes()
  end
end
function Shop:ClinetInit()
  self.tbFamilyShopData = {
    DrugShop = {},
    WarShop = {}
  }
  self.nLimitSynced = nil
  self.nShopActStartTime = nil
  self.tbActLimitInfo = {}
  self.tbLocalUpdateWareBuidLevel = {}
  self.nRequestIndex = 0
end
Shop:ClinetInit()
