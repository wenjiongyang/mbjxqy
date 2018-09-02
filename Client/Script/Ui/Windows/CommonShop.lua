local RepresentSetting = luanet.import_type("RepresentSetting")
local CommonShop = Ui:CreateClass("CommonShop")
CommonShop.tbOnClick = CommonShop.tbOnClick or {}
function CommonShop.tbOnClick:BtnClose()
  Ui:CloseWindow(self.UI_NAME)
end
function CommonShop.tbOnClick:BtnTreasureShop()
  if self.szPage ~= "Treasure" then
    self:SelectPage("Treasure")
    self:OnOpenEnd()
  end
end
function CommonShop.tbOnClick:BtnPrestige()
  if self.szPage ~= "Renown" then
    self:SelectPage("Renown")
    self:OnOpenEnd()
  end
end
function CommonShop.tbOnClick:BtnRecharge()
  if self.szPage ~= "Recharge" then
    self:SelectPage("Recharge")
    self:OnOpenEnd()
  end
end
function CommonShop.tbOnClick:BtnDress()
  if self.szPage ~= "Dress" then
    self:SelectPage("Dress")
    self:OnOpenEnd()
  end
end
function CommonShop.tbOnClick:Label_Number()
  if not self.tbSelectItem then
    return
  end
  local function fnUpdate(nInput)
    local nResult = self:UpdateNumberInput(nInput)
    return nResult
  end
  Ui:OpenWindow("NumberKeyboard", fnUpdate)
end
function CommonShop.tbOnClick:BtnPreview()
  if not self.tbSelectItem then
    return
  end
  local nTemplateId = self.tbSelectItem.nTemplateId
  local tbItemBase = KItem.GetItemBaseProp(nTemplateId)
  local nTargetWaiyi
  if tbItemBase.szClass == "ExchangeItemByFaction" then
    nTargetWaiyi = Item:GetClass("ExchangeItemByFaction"):GetExhangeItemId(nTemplateId, me.nFaction)
  elseif Item.tbEquipExchange.tbItemSetting[nTemplateId] then
    nTargetWaiyi = Item.tbEquipExchange.tbItemSetting[nTemplateId].WaiYiItem
  end
  if not nTargetWaiyi then
    return
  end
  local tbBaseProp = KItem.GetItemBaseProp(nTargetWaiyi)
  local nFaction = me.nFaction
  if tbBaseProp.nFactionLimit > 0 and me.nFaction ~= tbBaseProp.nFactionLimit then
    nFaction = tbBaseProp.nFactionLimit
  end
  Ui:OpenWindow("WaiyiPreview", nTargetWaiyi, nFaction)
end
CommonShop.tbPageTitle = {
  Treasure = "珍宝阁",
  Recharge = "充值",
  Renown = "名望商店",
  Dress = "黎饰商店"
}
CommonShop.tbShopMoneyType = {
  Treasure = {
    "Gold",
    "Gold",
    "Gold"
  },
  Renown = {"Renown"},
  Dress = {
    "SilverBoard",
    "SilverBoard",
    "SilverBoard"
  }
}
function CommonShop:SetPageTitle()
  local szTitle = self.tbPageTitle[self.szPage]
  self.pPanel:Label_SetText("Title", szTitle)
end
local tbUiToTabName = {
  Recharge = "BtnRecharge",
  Treasure = "BtnTreasureShop",
  Renown = "BtnPrestige",
  Dress = "BtnDress"
}
function CommonShop:UpdatePageShow()
  for szPage, szName in pairs(tbUiToTabName) do
    local bShowTab = szPage == self.szPage
    self[szName].pPanel:SetActive("LabelLight", bShowTab)
    self[szName].pPanel:SetActive("Label", not bShowTab)
    self.pPanel:Toggle_SetChecked(szName, bShowTab)
  end
end
function CommonShop:CheckReOpen()
  local bReOpen = false
  if Shop.nShopActStartTime then
    if Shop.tbActShopTypes then
      if Shop.tbActShopTypes.Dress then
        if CommonShop.tbTabText.Dress == CommonShop.DressShopTabs then
          CommonShop.tbTabText.Dress = CommonShop.ActDressShopTabs
          bReOpen = true
        end
      elseif CommonShop.tbTabText.Dress == CommonShop.ActDressShopTabs then
        CommonShop.tbTabText.Dress = CommonShop.DressShopTabs
        bReOpen = true
      end
      if Shop.tbActShopTypes.Treasure then
        if CommonShop.tbTabText.Treasure == CommonShop.DefaultTabs then
          CommonShop.tbTabText.Treasure = CommonShop.ActDefaultTabs
          bReOpen = true
        end
      elseif CommonShop.tbTabText.Treasure == CommonShop.ActDefaultTabs then
        CommonShop.tbTabText.Treasure = CommonShop.DefaultTabs
        bReOpen = true
      end
    end
  elseif not Shop.nShopActStartTime then
    if CommonShop.tbTabText.Treasure == CommonShop.ActDefaultTabs then
      CommonShop.tbTabText.Treasure = CommonShop.DefaultTabs
      bReOpen = true
    end
    if CommonShop.tbTabText.Dress == CommonShop.ActDressShopTabs then
      CommonShop.tbTabText.Dress = CommonShop.DressShopTabs
      bReOpen = true
    end
  end
  return bReOpen
end
function CommonShop:OnOpen(szPage, param2, param3)
  if not Recharge.IS_OPEN then
    self.pPanel:SetActive(tbUiToTabName.Recharge, false)
    if szPage == "Recharge" then
      return 0
    end
  end
  if szPage and (szPage == "Honor" or szPage == "Biography") then
    return 0
  end
  self.pPanel:SetActive("BtnDress", Recharge:CanBuyDressMoney() and true or false)
  Shop:RequestLimitInfo()
  if not szPage then
    if not self.szPage then
      szPage = "Treasure"
    else
      szPage = self.szPage
    end
  end
  self.OpenParam2 = param2
  self:SelectPage(szPage)
end
local fnFindTargetItem = function(self, nTemplateId)
  if not self.tbScrollView then
    return
  end
  for i, v in ipairs(self.tbScrollView) do
    for i2 = 1, 2 do
      if v[i2] and v[i2].nTemplateId == nTemplateId then
        return i, i2
      end
    end
  end
end
function CommonShop:OnOpenEnd(szPage, param2, param3)
  self:UpdatePageShow()
  if self.szPage == "Recharge" then
    self.Recharge:OnOpenEnd(param2, param3)
    return
  elseif self.szPage == "Treasure" or self.szPage == "Dress" then
    if self:CheckReOpen() then
      self:SelectPage(self.szPage)
    end
    self:UpdateTabPanel()
    if param3 and type(param3) == "number" then
      local nFindRow, nFindCol = fnFindTargetItem(self, param3)
      if nFindRow and nFindCol then
        self.ScrollViewGoods.pPanel:ScrollViewGoToIndex("Main", nFindRow)
        local Grid = self.ScrollViewGoods.Grid
        local szCol = "item" .. nFindCol
        for i = 0, 100 do
          local itemObj = Grid["Item" .. i]
          if itemObj then
            local goodItem = itemObj[szCol]
            if goodItem and goodItem.tbData and goodItem.tbData.nTemplateId == param3 then
              goodItem.pPanel.OnTouchEvent(goodItem)
              break
            end
          else
            break
          end
        end
      end
    end
  end
end
function CommonShop:SelectPage(szPage)
  self.szPage = szPage
  local param2 = self.OpenParam2
  if type(param2) == "number" then
    self.nSelectTab = param2
  elseif type(param2) == "string" then
    local tbPages = CommonShop.tbTabText[szPage]
    if tbPages then
      for i, v in pairs(tbPages) do
        if v == param2 then
          self.nSelectTab = i
          break
        end
      end
    end
  elseif CommonShop.tbTabText[szPage] and #CommonShop.tbTabText[szPage] == 3 then
    self.nSelectTab = 3
  else
    self.nSelectTab = 1
  end
  if self.tbShopMoneyType[szPage] and not self.tbShopMoneyType[szPage][self.nSelectTab] then
    self.nSelectTab = 1
  end
  self:SetPageTitle()
  self.pPanel:SetActive("Recharge", szPage == "Recharge")
  self.pPanel:SetActive("Shop", szPage ~= "Recharge" and szPage ~= "Renown")
  self.pPanel:SetActive("CommonShop", szPage ~= "Recharge" and szPage ~= "Renown")
  self.pPanel:SetActive("PrestigeShop", szPage == "Renown")
  self.pPanel:SetActive("BtnOperation", szPage ~= "Dress")
  self.pPanel:SetActive("BtnOperation2", szPage == "Dress")
  self.pPanel:SetActive("BtnExchange", szPage == "Dress")
  if self.szPage == "Recharge" then
    self:OnOpenRecharge()
  elseif self.szPage == "Treasure" then
    self.pPanel:SetActive("TopTabGroup", true)
    self:OnOpenCommonShop()
  elseif self.szPage == "Dress" then
    self.pPanel:SetActive("TopTabGroup", true)
    self:OnOpenCommonShop()
  elseif self.szPage == "Honor" then
    self:OnOpenCommonShop()
    self.pPanel:SetActive("TopTabGroup", false)
  elseif self.szPage == "Biography" then
    self:OnOpenCommonShop()
    self.pPanel:SetActive("TopTabGroup", false)
  elseif self.szPage == "Renown" then
    self:OnOpenRenown()
  end
end
function CommonShop:CloseWindow()
  if self.nTimer then
    Timer:Close(self.nTimer)
    self.nTimer = nil
  end
end
function CommonShop:SyncShopWare()
  if self:CheckReOpen() then
    self:SelectPage(self.szPage)
    self:UpdateTabPanel()
  end
  self:UpdateWares()
  self:UpdateRightPanel(szShopType)
end
function CommonShop:OnResponseBuy()
  self:UpdateRightPanel()
  self:UpdateWares()
end
function CommonShop:UpdateWares()
  self:UpdateShopWares()
end
function CommonShop:OnResponseSell()
  self.tbSelectItem = nil
  self:UpdateSellPanel()
  self:UpdateRightPanel()
end
function CommonShop:OnResponseRecharge()
  if self.szPage ~= "Recharge" then
    return
  end
  self:SelectPage("Recharge")
  self:OnOpenEnd()
end
function CommonShop:RefreshRenown()
  if self.szPage ~= "Renown" then
    return
  end
  self.PrestigeShop:Refresh()
end
function CommonShop:OnRefresMoney()
  self:UpdateRightPanel()
end
function CommonShop:RegisterEvent()
  local tbRegEvent = {
    {
      UiNotify.emNOTIFY_WND_CLOSED,
      self.CloseWindow
    },
    {
      UiNotify.emNOTIFY_SYNC_SHOP_WARE,
      self.SyncShopWare
    },
    {
      UiNotify.emNOTIFY_SHOP_BUY_RESULT,
      self.OnResponseBuy
    },
    {
      UiNotify.emNOTIFY_SHOP_SELL_RESULT,
      self.OnResponseSell
    },
    {
      UiNotify.emNOTIFY_RECHARGE_PANEL,
      self.OnResponseRecharge
    },
    {
      UiNotify.emNoTIFY_RENOWN_SHOP_REFRESH,
      self.RefreshRenown,
      self
    },
    {
      UiNotify.emNOTIFY_CHANGE_MONEY,
      self.OnRefresMoney
    }
  }
  return tbRegEvent
end
function CommonShop.tbOnClick:BtnOperation()
  self:DoBuy()
end
function CommonShop.tbOnClick:BtnOperation2()
  self:DoBuy()
end
function CommonShop.tbOnClick:BtnExchange()
  Recharge:RequestBuyDressMoney()
end
function CommonShop:GetShopMoneyType()
  return self.tbShopMoneyType[self.szPage][self.nSelectTab]
end
CommonShop.DefaultTabs = {
  "tabLimitShop",
  "tabAllShop"
}
CommonShop.ActDefaultTabs = {
  "tabLimitShop",
  "tabAllShop",
  "tabActShop"
}
CommonShop.DressShopTabs = {
  "tabDressWaiyiShop",
  "tabDressWeaponShop"
}
CommonShop.ActDressShopTabs = {
  "tabDressWaiyiShop",
  "tabDressWeaponShop",
  "tabActShop"
}
CommonShop.tbTabText = {
  Treasure = CommonShop.DefaultTabs,
  Dress = CommonShop.DressShopTabs
}
CommonShop.tbTabBtn = {
  "BtnTab1",
  "BtnTab2",
  "BtnTab3"
}
CommonShop.TabsLabelSetting = {
  tabDefault = function(self, szBtnName)
    local ColorOuline = RepresentSetting.CreateColor(0, 0.32941176470588235, 0.6549019607843137, 1)
    local pPanel = self[szBtnName].pPanel
    pPanel:Label_SetOutlineColor("LabelLight", ColorOuline)
    pPanel:Label_SetOutlineColor("LabelDark", ColorOuline)
    pPanel:Label_SetColor("LabelDark", 115, 203, 213)
    pPanel:Toggle_SetChecked("Main", false)
    pPanel:Button_SetSprite("Main", "Tab2_1", 0)
    pPanel:Button_SetSprite("Main", "Tab2_2", 3)
  end,
  tabActShop = function(self, szBtnName)
    local ColorOuline = RepresentSetting.CreateColor(0.6549019607843137, 0.17647058823529413, 0, 1)
    local pPanel = self[szBtnName].pPanel
    pPanel:Label_SetOutlineColor("LabelLight", ColorOuline)
    pPanel:Label_SetOutlineColor("LabelDark", ColorOuline)
    pPanel:Label_SetColor("LabelDark", 213, 166, 115)
    pPanel:Toggle_SetChecked("Main", false)
    pPanel:Button_SetSprite("Main", "BtnNewYearShop1", 0)
    pPanel:Button_SetSprite("Main", "BtnNewYearShop2", 3)
  end
}
CommonShop.tbTabBtnIndex = {
  BtnTab1 = 1,
  BtnTab2 = 2,
  BtnTab3 = 3
}
function CommonShop:UpdateTabPanel()
  local tbTabText = self.tbTabText[self.szPage]
  if not tbTabText then
    return
  end
  if #tbTabText == 2 then
    self.pPanel:ChangePosition("BtnTab1", -199, -16)
    self.pPanel:ChangePosition("BtnTab2", -64, -16)
  else
    self.pPanel:ChangePosition("BtnTab1", -64, -16)
    self.pPanel:ChangePosition("BtnTab2", 71, -16)
  end
  for i = 1, 3 do
    local szBtnName = self.tbTabBtn[i]
    local szTxt = tbTabText[i]
    szTxt = szTxt and Shop.tabUiKeyName[szTxt]
    self.pPanel:SetActive("BtnTab" .. i, szTxt ~= nil)
    self[szBtnName].pPanel:Label_SetText("LabelLight", szTxt or "")
    self[szBtnName].pPanel:Label_SetText("LabelDark", szTxt or "")
    self.pPanel:Toggle_SetChecked("BtnTab" .. i, self.nSelectTab == i)
  end
  local szBtnName = self.tbTabBtn[self.nSelectTab]
  self:SelectTabShow(szBtnName)
end
function CommonShop:SelectTabShow(szBtnName)
  for _, szName in ipairs(self.tbTabBtn) do
    self[szName].pPanel:SetActive("LabelLight", szBtnName == szName)
    self[szName].pPanel:SetActive("LabelDark", szBtnName ~= szName)
  end
end
local ClickTab = function(self, szBtnName)
  local nIndex = self.tbTabBtnIndex[szBtnName]
  if self.nSelectTab ~= nIndex then
    self.nSelectTab = nIndex
    self.tbSelectItem = nil
    self:UpdateShopWares()
    self:UpdateRightPanel()
    self:SelectTabShow(szBtnName)
  end
end
CommonShop.tbOnClick.BtnTab1 = ClickTab
CommonShop.tbOnClick.BtnTab2 = ClickTab
CommonShop.tbOnClick.BtnTab3 = ClickTab
function CommonShop.tbOnClick:BtnMinus()
  self:ReduceCount()
end
function CommonShop.tbOnClick:BtnPlus()
  self:AddCount()
end
function CommonShop:AddCount()
  if not self.tbSelectItem then
    me.CenterMsg("请先选择要购买的道具")
    return
  end
  local nCount = self.tbSelectItem.nCount
  local nToCount = nCount + 1
  self:SetCount(nToCount)
end
function CommonShop:ReduceCount()
  if not self.tbSelectItem then
    me.CenterMsg("请先选择要购买的道具")
    return
  end
  local nCount = self.tbSelectItem.nCount
  local nToCount = nCount - 1
  nToCount = nToCount < 1 and 1 or nToCount
  self:SetCount(nToCount)
end
function CommonShop:SetCount(nToCount, bAjustment)
  local szMoneyType = self.tbSelectItem.szMoneyType
  local nPrice = self.tbSelectItem.nPrice
  local szIcon, szIconAtlas = Shop:GetMoneyIcon(szMoneyType)
  self.pPanel:Sprite_SetSprite("CostMoneyIcon", szIcon, szIconAtlas)
  if bAjustment then
    local nMoney = me.GetMoney(szMoneyType)
    local nMax = math.floor(nMoney / nPrice)
    nToCount = nMax
    if self.tbSelectItem.nLimitType then
      local nRemainCount = Shop:GetWareRemainCount(me, self.tbSelectItem)
      nToCount = nToCount > nRemainCount and nRemainCount or nToCount
    end
    nToCount = nToCount > 0 and nToCount or 1
  end
  if not Shop:HasEnoughMoney(me, szMoneyType, nPrice, nToCount) then
    me.CenterMsg("购买数量已达上限")
    return false
  end
  if self.tbSelectItem.nLimitType then
    local nRemainCount = Shop:GetWareRemainCount(me, self.tbSelectItem)
    if nToCount > nRemainCount then
      me.CenterMsg(nRemainCount == 0 and "库存不足" or "购买数量已达上限")
      self:SetCount(nRemainCount)
      return false
    end
  end
  self.tbSelectItem.nCount = nToCount
  self.pPanel:Label_SetText("Label_Number", nToCount)
  self.pPanel:PlayUiAnimation("ShopCountScale", false, false, {})
  self.pPanel:Label_SetText("TxtCostMoney", self.tbSelectItem.nPrice * nToCount)
  self.pPanel:Label_SetColorByName("TxtCostMoney", "White")
  return true
end
function CommonShop:UpdateNumberInput(nNum)
  if not self.tbSelectItem then
    self.pPanel:Label_SetText("Label_Number", 0)
    return
  end
  if not self:SetCount(nNum) then
    self:SetCount(self.tbSelectItem.nCount, true)
    return self.tbSelectItem.nCount
  end
  return nNum
end
function CommonShop:UpdateRightPanel()
  if self.szPage == "Recharge" then
    return
  end
  local szTxtPay, szTxtOperation
  szTxtPay = "花费"
  szTxtOperation = "购买"
  self.pPanel:Button_SetText("BtnOperation", szTxtOperation)
  self.pPanel:Label_SetText("TxtPay", szTxtPay)
  self.pPanel:Label_SetText("TxtCostMoney", 0)
  local nPrice, szMoneyType = 0, self.tbShopMoneyType[self.szPage][self.nSelectTab]
  if self.tbSelectItem then
    local nCount = self.tbSelectItem.nCount
    szMoneyType = self:GetShopMoneyType()
    nPrice = self.tbSelectItem.nPrice * nCount
    if Shop:HasEnoughMoney(me, szMoneyType, self.tbSelectItem.nPrice, nCount) then
      self.pPanel:Label_SetColorByName("TxtCostMoney", "White")
    else
      self.pPanel:Label_SetColorByName("TxtCostMoney", "Red")
    end
    self.pPanel:Label_SetText("Label_Number", self.tbSelectItem.nCount or 1)
    local tbBaseInfo = KItem.GetItemBaseProp(self.tbSelectItem.nTemplateId)
    local szTitle = KItem.GetItemShowInfo(self.tbSelectItem.nTemplateId, me.nFaction)
    local szDetail = string.gsub(tbBaseInfo.szIntro, "\\n", "\n")
    local szShowTxt = szDetail
    if tbBaseInfo.szClass == "Stone" then
      szShowTxt = ""
      local szName1, szValue1, szName2, szValue2 = StoneMgr:GetStoneMagicDesc(self.tbSelectItem.nTemplateId)
      if szValue1 then
        szShowTxt = string.format("效果：[FAFFA3]%s  %s[-]\n\n", szName1, szValue1)
      end
      if szValue2 then
        szShowTxt = szShowTxt .. string.format("效果：[FAFFA3]%s  %s[-]\n\n", szName2, szValue2)
      end
      local szInsetPosDes = StoneMgr:GetCanInsetPosDes(self.tbSelectItem.nTemplateId)
      if szInsetPosDes then
        szShowTxt = string.format("%s镶嵌位置：[FAFFA3]%s[-]\n\n镶嵌等级：[FAFFA3]%d级[-]\n\n", szShowTxt, szInsetPosDes, tbBaseInfo.nRequireLevel)
      end
      szShowTxt = szShowTxt .. szDetail
    elseif tbBaseInfo.szClass == "XiuLianDan" then
      local tbItem = Item:GetClass("XiuLianDan")
      szShowTxt = tbItem:GetShopTip({})
    elseif tbBaseInfo.szClass == "ChuangGongDan" then
      local bUse = ChuangGong:IsUsedChuangGongDan(me)
      if bUse then
        szShowTxt = szShowTxt .. "\n\n\n\n\n\n[ff0000]                     今日已使用[-]"
      end
    elseif tbBaseInfo.szClass == "waiyi_exchange" then
      local szTip = Item:GetClass("waiyi_exchange"):GetIntrol(self.tbSelectItem.nTemplateId)
      if not Lib:IsEmptyStr(szTip) then
        szShowTxt = szTip
      end
    end
    local bShowBtnPreview = false
    if tbBaseInfo.szClass == "waiyi_exchange" then
      bShowBtnPreview = true
    elseif tbBaseInfo.szClass == "ExchangeItemByFaction" then
      local nExhangeItem = Item:GetClass("ExchangeItemByFaction"):GetExhangeItemId(self.tbSelectItem.nTemplateId, me.nFaction)
      local tbItemBase = KItem.GetItemBaseProp(nExhangeItem)
      if tbItemBase.szClass == "waiyi" then
        bShowBtnPreview = true
      end
    end
    self.pPanel:SetActive("PanelBtns", bShowBtnPreview)
    if self.tbSelectItem.nLimitType then
      local nRemainCount = Shop:GetWareRemainCount(me, self.tbSelectItem)
      local szRemainDesc
      if nRemainCount == 0 then
        szRemainDesc = "[ff6464]还可购买：0个[-]"
      else
        szRemainDesc = string.format("[64fa50]还可购买：%d个[-]", nRemainCount)
      end
      szShowTxt = szShowTxt .. [[


]] .. szRemainDesc
    end
    local tbWareInfo = Shop:GetGoodsWare(self.szPage, self.tbSelectItem.nGoodsId)
    if tbWareInfo and tbWareInfo.nMinLevel and tbWareInfo.nMinLevel > me.nLevel then
      szShowTxt = szShowTxt .. string.format("\n\n[ff6464]%d级后可购买[-]", tbWareInfo.nMinLevel)
    end
    self.pPanel:Label_SetText("TxtDetailTitle", szTitle)
    self.pPanel:Label_SetText("TxtDesc", szShowTxt)
    self.pPanel:SetActive("DetailPanel", true)
    local tbTextSize2 = self.pPanel:Label_GetPrintSize("TxtDesc")
    local tbSize = self.pPanel:Widget_GetSize("datagroup")
    self.pPanel:Widget_SetSize("datagroup", tbSize.x, 50 + tbTextSize2.y)
    self.pPanel:DragScrollViewGoTop("datagroup")
    self.pPanel:UpdateDragScrollView("datagroup")
  else
    self.pPanel:SetActive("DetailPanel", false)
    self.pPanel:Label_SetText("Label_Number", 0)
    self.pPanel:SetActive("PanelBtns", false)
  end
  local szIcon, szIconAtlas = Shop:GetMoneyIcon(szMoneyType)
  self.pPanel:Sprite_SetSprite("CostMoneyIcon", szIcon, szIconAtlas)
  self.pPanel:Sprite_SetSprite("HasMoneyIcon", szIcon, szIconAtlas)
  self.pPanel:Label_SetText("TxtCostMoney", nPrice)
  self.pPanel:Label_SetText("TxtHaveMoney", me.GetMoney(szMoneyType))
  self:CheckCountdown()
end
function CommonShop:DoBuy()
  if not self.tbSelectItem then
    me.CenterMsg("你没有选中物品")
    return
  end
  local szMoneyType = self.tbSelectItem.szMoneyType
  local nbuyCount = self.tbSelectItem.nCount
  local nTemplateId = self.tbSelectItem.nTemplateId
  local nGoodsId = self.tbSelectItem.nGoodsId
  local bSuccess, szInfo = Shop:CanBuyGoodsWare(me, self.szPage, nGoodsId, nbuyCount)
  if not bSuccess then
    me.CenterMsg(szInfo)
    return
  end
  Shop:TryBuyItem(false, self.szPage, nTemplateId, nGoodsId, nbuyCount, self.tbSelectItem.nPrice)
end
local fnOnClickWare = function(self, buttonObj)
  buttonObj.pPanel:Toggle_SetChecked("Main", true)
  if self.tbSelectItem and self.tbSelectItem.nTemplateId == buttonObj.tbData.nTemplateId then
  else
    self.tbSelectItem = {
      nTemplateId = buttonObj.tbData.nTemplateId,
      nGoodsId = buttonObj.tbData.nGoodsId,
      nPrice = buttonObj.tbData.nPrice,
      nCount = 1,
      szMoneyType = buttonObj.tbData.szMoneyType,
      nLimitType = buttonObj.tbData.nLimitType,
      nLimitNum = buttonObj.tbData.nLimitNum
    }
    self:UpdateRightPanel()
  end
end
local function fnSetWareItem(self, goodItem, tbData)
  goodItem.pPanel:Label_SetText("TxtPrice", tbData.nPrice)
  local tbBaseInfo = KItem.GetItemBaseProp(tbData.nTemplateId)
  local szName = KItem.GetItemShowInfo(tbData.nTemplateId, me.nFaction)
  goodItem.pPanel:Label_SetText("TxtItemName", szName)
  local szIcon, szIconAtlas = Shop:GetMoneyIcon(tbData.szMoneyType)
  goodItem.pPanel:Sprite_SetSprite("MoneyIcon", szIcon, szIconAtlas)
  self:SetGoodTip(tbData, goodItem)
  local bCheck = false
  if self.tbSelectItem and self.tbSelectItem.nTemplateId == tbData.nTemplateId then
    bCheck = true
  end
  goodItem.pPanel:Toggle_SetChecked("Main", bCheck)
  local tbControls = {}
  local bOutOfStock = false
  if tbData.nLimitType then
    local nRemainCount = Shop:GetWareRemainCount(me, tbData)
    tbControls.bShowCDLayer = nRemainCount == 0
    bOutOfStock = nRemainCount == 0
  else
    tbControls.bShowCDLayer = false
  end
  goodItem.Item:SetItemByTemplate(tbData.nTemplateId, nil, me.nFaction, tbControls)
  if bOutOfStock then
    goodItem.pPanel:SetActive("TagDT", true)
    goodItem.pPanel:Sprite_SetSprite("TagDT", "OutOfStock")
  else
    goodItem.pPanel:SetActive("TagDT", false)
  end
  function goodItem.pPanel.OnTouchEvent(buttonObj)
    fnOnClickWare(self, buttonObj)
  end
  function goodItem.Item.fnClick(itemGrid)
    fnOnClickWare(self, goodItem)
  end
  goodItem.tbData = tbData
end
function CommonShop:OnOpenCommonShop()
  local nNow = GetTime()
  Client:SetFlag("SeeShopActStartTime", nNow)
  Shop:CheckRedPoint()
  self:UpdateShopWares()
  self:UpdateRightPanel()
end
function CommonShop:UpdateShopWares()
  if self.szPage == "Recharge" then
    return
  end
  local szMoneyType = self:GetShopMoneyType()
  assert(szMoneyType)
  local szTabKey = self.nSelectTab
  if CommonShop.tbTabText[self.szPage] then
    szTabKey = CommonShop.tbTabText[self.szPage][szTabKey]
  end
  local tbView = Shop:GetShopWares(self.szPage, szTabKey)
  table.sort(tbView, function(item1, item2)
    return item1.nSort < item2.nSort
  end)
  self.tbScrollView = {}
  for i, v in ipairs(tbView) do
    if i % 2 == 1 then
      table.insert(self.tbScrollView, {
        [1] = v
      })
    else
      self.tbScrollView[i / 2][2] = v
    end
  end
  local function fnSetItem(itemObj, index)
    for i = 1, 2 do
      local tbData = self.tbScrollView[index][i]
      if tbData then
        itemObj.pPanel:SetActive("item" .. i, true)
        local goodItem = itemObj["item" .. i]
        fnSetWareItem(self, goodItem, tbData)
      else
        itemObj.pPanel:SetActive("item" .. i, false)
      end
    end
  end
  self.ScrollViewGoods:Update(#self.tbScrollView, fnSetItem)
end
function CommonShop:SetGoodTip(tbData, goodItem)
  if tbData.nDiscount and tbData.nDiscount ~= 0 then
    local szDiscountIcon = "Discount" .. tbData.nDiscount
    goodItem.pPanel:Sprite_SetSprite("TipIcon", szDiscountIcon)
    goodItem.pPanel:SetActive("TipIcon", true)
  elseif tbData.New then
    goodItem.pPanel:Sprite_SetSprite("TipIcon", "New")
    goodItem.pPanel:SetActive("TipIcon", true)
  elseif tbData.bHotTip then
    goodItem.pPanel:Sprite_SetSprite("TipIcon", "Hot")
    goodItem.pPanel:SetActive("TipIcon", true)
  elseif not Lib:IsEmptyStr(tbData.szOpenTime) then
    goodItem.pPanel:Sprite_SetSprite("TipIcon", "TimeLimit")
    goodItem.pPanel:SetActive("TipIcon", true)
  else
    goodItem.pPanel:SetActive("TipIcon", false)
  end
end
function CommonShop:CheckCountdown()
  local bShowCountDown = false
  local bShowActShopTime = false
  if self.szPage == "Treasure" and not self.nTimer and self.nSelectTab then
    local szTabKey = CommonShop.tbTabText.Treasure[self.nSelectTab]
    if szTabKey == "tabLimitShop" then
      bShowCountDown = true
    elseif szTabKey == "tabActShop" then
      local szBtnName = self.tbTabBtn[self.nSelectTab]
      if self[szBtnName].pPanel:IsActive("Main") then
        bShowActShopTime = true
      end
    end
  end
  self.pPanel:SetActive("TxtTimeLimit", bShowCountDown)
  self.pPanel:SetActive("NewYearTimes", false)
end
function CommonShop:OnClose()
  self.tbSelectItem = nil
end
function CommonShop:OnOpenRenown()
  self.PrestigeShop:OnOpenEnd()
end
function CommonShop:OnOpenRecharge()
  self.Recharge:OnOpenEnd()
end
