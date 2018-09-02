local tbUi = Ui:CreateClass("AuctionPanel")
function tbUi:OnOpenEnd(szAuctionType, bOpenMyAuction)
  Ui:ClearRedPointNotify("KinAuctionRedPoint")
  Kin:Ask4AllAuctionData()
  Kin:AskMyAuctionData()
  self.tbCurItems = nil
  self.szCurAuctionType = szAuctionType or self.szCurAuctionType
  self.pPanel:SetActive("GainNode", false)
  self:UpdateAuctionScrollView({}, true)
  self:InitSidebar()
  Achievement:AddCount("FirstAuctionDeal_1")
  self.pPanel:SetActive("BtnMyAuction", false)
end
function tbUi:RegisterEvent()
  local tbRegEvent = {
    {
      UiNotify.emNOTIFY_SYNC_AUCTION_DATA,
      self.Update,
      self
    }
  }
  return tbRegEvent
end
function tbUi:Update(szType, bAllUpdate)
  if szType ~= "Auction" then
    return
  end
  if bAllUpdate then
    self.tbCurItems = nil
  end
  self.szCurAuctionType = Kin:AuctionGetNewOpenType() or self.szCurAuctionType
  self:InitSidebar()
end
function tbUi:InitSidebar()
  local function fnOnSelect(buttonObj, tbItem)
    self.szCurAuctionType = buttonObj and buttonObj.tbItem.szType or tbItem.szType
    self.szCurOrgType = tbItem and tbItem.szOrgType
    self:UpdateAuctionScrollView(tbItem or buttonObj.tbItem, buttonObj and true or false)
  end
  local bFirstInit = true
  local function fnSetItem(itemObj, tbNodeData, nIdx)
    local tbItem = tbNodeData.tbData or tbNodeData
    local szAuctionName = tbItem.szName or Kin.AuctionName[tbItem.szType] or tbItem.szType
    itemObj.pPanel:SetActive("BaseClass", tbNodeData.tbLeaves and true or false)
    itemObj.pPanel:SetActive("SubClass", not tbNodeData.tbLeaves)
    itemObj.BaseClass.pPanel:SetActive("Triangle", tbNodeData.tbLeaves and true or false)
    itemObj.pPanel:Label_SetText("LabelDark", szAuctionName)
    if tbNodeData.tbLeaves then
      itemObj.BaseClass.tbItem = tbItem
      itemObj.BaseClass.pPanel.OnTouchEvent = fnOnSelect
      itemObj.BaseClass.pPanel:Label_SetText("LabelLight", Kin.AuctionName[tbNodeData.szType] or tbNodeData.szType)
      if tbNodeData == self.SidebarScrollView:GetCurBaseNode() then
        Timer:Register(1, function()
          itemObj.BaseClass.pPanel:Toggle_SetChecked("Main", true)
        end)
      else
        itemObj.BaseClass.pPanel:Toggle_SetChecked("Main", false)
      end
    else
      itemObj.SubClass.tbItem = tbItem
      itemObj.SubClass.pPanel.OnTouchEvent = fnOnSelect
      itemObj.SubClass.pPanel:Label_SetText("LabelLight", szAuctionName)
      itemObj.SubClass.pPanel:Toggle_SetChecked("Main", self.szCurAuctionType == tbItem.szType)
    end
    if bFirstInit and self.szCurAuctionType == tbItem.szType then
      bFirstInit = false
      itemObj.SubClass.pPanel:Toggle_SetChecked("Main", true)
      itemObj.BaseClass.pPanel:Toggle_SetChecked("Main", true)
      fnOnSelect(nil, tbItem)
    end
  end
  local tbTree = self:GetSideBarTreeData()
  self.SidebarScrollView:SetTreeMenu(tbTree, fnSetItem, function(tbNodeData)
    self.szCurAuctionType = tbNodeData.szType
    self:UpdateAuctionScrollView(tbNodeData.tbData, true)
  end)
end
function tbUi:GetSideBarTreeData()
  local tbTree = {}
  local tbKinAuction = {
    szType = "家族拍卖",
    tbLeaves = {}
  }
  local tbGlobalAuction = {
    szType = "Global",
    tbLeaves = {}
  }
  local tbDealerAuction = {
    szType = "Dealer",
    tbLeaves = {}
  }
  table.insert(tbTree, tbKinAuction)
  table.insert(tbTree, tbGlobalAuction)
  local tbAuctions = Kin:GetAuctionsData()
  for _, tbAuction in pairs(tbAuctions) do
    if tbAuction.szType == "Global" then
      tbGlobalAuction.tbData = tbAuction
    elseif tbAuction.szType == "Dealer" then
      tbDealerAuction.tbData = tbAuction
      table.insert(tbTree, tbDealerAuction)
    elseif tbAuction.bOpen and next(tbAuction.tbItems) then
      table.insert(tbKinAuction.tbLeaves, tbAuction)
      if self.szCurAuctionType ~= "Global" then
        tbKinAuction.bDown = true
      end
      if not self.szCurAuctionType then
        self.szCurAuctionType = tbAuction.szType
      end
    end
  end
  self.tbGlobalAuctionTypeMap = {}
  for _, tbNode in ipairs(tbTree) do
    for nIdx, tbItem in pairs(tbNode.tbData and tbNode.tbData.tbItems or {}) do
      local szItemTypeName = Kin:AuctionGetItemType(tbItem.nItemId)
      local szItemType = szItemTypeName .. tbNode.szType
      if not self.tbGlobalAuctionTypeMap[szItemType] then
        self.tbGlobalAuctionTypeMap[szItemType] = {
          szType = szItemType,
          szName = szItemTypeName,
          szOrgType = tbNode.szType,
          tbItems = {}
        }
        table.insert(tbNode.tbLeaves, self.tbGlobalAuctionTypeMap[szItemType])
        if szItemType == self.szCurAuctionType then
          tbNode.bDown = true
        end
      end
      self.tbGlobalAuctionTypeMap[szItemType].tbItems[nIdx] = tbItem
      if not self.szCurAuctionType then
        self.szCurAuctionType = tbNode.szType
      end
    end
  end
  return tbTree
end
function tbUi:UpdateAuctionScrollView(tbAuctionData, bManualSwitch)
  local nNow = GetTime()
  self.tbCurItems = self.tbCurItems or {}
  if bManualSwitch then
    self.tbCurItems = {}
  end
  local tbItems = self.tbCurItems
  tbAuctionData = tbAuctionData or Kin:GetAuction(self.szCurAuctionType) or {}
  self.tbCurAuctionData = tbAuctionData
  if not next(tbItems) or bManualSwitch then
    for _, tbItem in pairs(tbAuctionData.tbItems or {}) do
      if not tbItem.bSold and nNow < tbItem.nTimeOut then
        table.insert(tbItems, tbItem)
      end
    end
  else
    for nIdx, tbItem in pairs(tbItems) do
      if tbAuctionData.tbItems[tbItem.nId] then
        tbItems[nIdx] = tbAuctionData.tbItems[tbItem.nId]
      else
        tbItem.bSold = true
      end
    end
  end
  if not next(tbItems) then
    tbAuctionData.bOpen = false
  end
  table.sort(tbItems, function(a, b)
    if a.nOrgPrice == b.nOrgPrice then
      return a.nId < b.nId
    end
    return a.nOrgPrice > b.nOrgPrice
  end)
  self.tbAuctionItemObjMaps = {}
  local pScrollView = self.ItemsScrollView
  local function fnSetItem(itemObj, nIdx)
    pScrollView:CheckShowGridMax(itemObj, nIdx)
    local tbItem = tbItems[nIdx]
    self.tbAuctionItemObjMaps[itemObj] = true
    itemObj:Init(tbItem, tbAuctionData, self)
    itemObj:UpdateTime(tbAuctionData)
  end
  pScrollView:Update(#tbItems, fnSetItem, 9, self.BackTop, self.BackBottom)
  self:UpdateOtherInfo(tbItems)
  local function fnCountdown()
    for itemObj, _ in pairs(self.tbAuctionItemObjMaps) do
      itemObj:UpdateTime(tbAuctionData)
    end
    return true
  end
  if self.nAuctionItemsTimer then
    Timer:Close(self.nAuctionItemsTimer)
    self.nAuctionItemsTimer = nil
  end
  if fnCountdown() and next(tbItems) then
    self.nAuctionItemsTimer = Timer:Register(Env.GAME_FPS, fnCountdown)
  end
end
function tbUi:UpdateOtherInfo(tbItems)
  local bShowNoKin = not Kin:HasKin() and self.szCurAuctionType == "家族拍卖"
  self.pPanel:SetActive("NoFamily", bShowNoKin)
  self.pPanel:SetActive("NoAuction", #tbItems == 0 and not bShowNoKin)
  local tbAuctionData = self.tbCurAuctionData
  local tbPlayerIds = tbAuctionData.tbPlayerIds or {}
  local bJoin = tbPlayerIds[me.dwID]
  local bOpen = tbAuctionData.nStartTime and GetTime() >= tbAuctionData.nStartTime
  if bJoin and bOpen then
    self.pPanel:SetActive("GainNode", true)
    local nTotalGold = tbAuctionData.nLastLeftGold or 0
    for nId, tbItem in pairs(tbAuctionData.tbItems) do
      if tbItem.bSold or tbItem.nBidderId then
        nTotalGold = nTotalGold + tbItem.nCurPrice
      else
        nTotalGold = nTotalGold + tbItem.nOrgPrice * Kin.AuctionDef.nRecycleRate
      end
    end
    local nJoinMember = tbAuctionData.nBonusCount or Lib:CountTB(tbAuctionData.tbPlayerIds)
    local nGoldEach = math.floor(nTotalGold / nJoinMember)
    self.pPanel:Label_SetText("TxtGold", nGoldEach)
    local nMinGold = Kin:AuctionGetMinBonusPrice(tbAuctionData.szType)
    local szMinTip = ""
    if nGoldEach < nMinGold then
      local _, szMoneyEmotion = Shop:GetMoneyName("Gold")
      szMinTip = string.format("(本次保底分红:%s%d)", szMoneyEmotion, nMinGold)
    end
    self.pPanel:Label_SetText("TxtMinGoldInfo", szMinTip)
    self.pPanel:Label_SetText("TxtJoinInfo", "预计本场拍卖结束后您可以获得分红：")
  elseif tbAuctionData.szType == "Dealer" and tbAuctionData.bOpen or tbAuctionData.szOrgType == "Dealer" then
    self.pPanel:SetActive("GainNode", true)
    local nTotalGold = 0
    local tbBidders = {}
    local tbAuctionData = Kin:GetAuction("Dealer")
    for nId, tbItem in pairs(tbAuctionData.tbItems) do
      if tbItem.nBidderId then
        tbBidders[tbItem.nBidderId] = tbBidders[tbItem.nBidderId] or 0
        tbBidders[tbItem.nBidderId] = tbBidders[tbItem.nBidderId] + tbItem.nCurPrice
      end
    end
    for nPlayerId, nCost in pairs(tbBidders) do
      local nRedBagId = Kin.Auction:GetDealerLuckybagIdByCost(nCost)
      if nRedBagId then
        nTotalGold = nTotalGold + (Kin:RedBagGetBaseGold(nRedBagId) or 0)
      end
    end
    self.pPanel:Label_SetText("TxtGold", nTotalGold)
    self.pPanel:Label_SetText("TxtMinGoldInfo", "")
    self.pPanel:Label_SetText("TxtJoinInfo", "预计本场拍卖结束后世界红包总金额：")
  else
    self.pPanel:SetActive("GainNode", false)
  end
end
function tbUi:OnClose()
  if self.nAuctionItemsTimer then
    Timer:Close(self.nAuctionItemsTimer)
    self.nAuctionItemsTimer = nil
  end
  self.tbAuctionItemObjMaps = nil
end
tbUi.tbOnClick = tbUi.tbOnClick or {}
function tbUi.tbOnClick:BtnClose()
  Ui:CloseWindow(self.UI_NAME)
end
function tbUi.tbOnClick:BtnAuctionRecord()
  local szAuctionType = self.szCurAuctionType
  if self.tbGlobalAuctionTypeMap[self.szCurAuctionType] then
    szAuctionType = self.tbGlobalAuctionTypeMap[self.szCurAuctionType].szOrgType
  end
  if not Kin:HasKin() and szAuctionType ~= "Global" and szAuctionType ~= "Dealer" then
    me.CenterMsg("少侠你还未加入家族，无法查看家族拍卖记录")
    return
  end
  Ui:OpenWindow("AuctionRecordPanel", szAuctionType)
end
function tbUi.tbOnClick:BtnMyAuction()
  Ui:OpenWindow("MyAuctionPanel")
end
function tbUi.tbOnClick:BtnJoinFamily()
  if not Kin:HasKin() then
    Ui:OpenWindow("KinJoinPanel")
    Ui:CloseWindow(self.UI_NAME)
  end
end
local tbSidebarItemUi = Ui:CreateClass("AuctionSidebarItem")
local tbItemUi = Ui:CreateClass("AuctionItem")
tbItemUi.tbOnDrag = {
  Main = function(self, szWnd, nX, nY)
    self.pScrollView:OnDragList(nY)
  end
}
tbItemUi.tbOnDragEnd = {
  Main = function(self)
    self.pScrollView:OnDragEndList()
  end
}
function tbItemUi:Init(tbItemData, tbAuctionData, rootPanel)
  self.rootPanel = rootPanel
  self.tbItemData = tbItemData
  self.szType = tbAuctionData.szOrgType or tbAuctionData.szType
  self.pPanel:Label_SetText("TxtCurPrice", tbItemData.nCurPrice)
  self.pPanel:Label_SetText("TxtMaxPrice", tbItemData.nMaxPrice)
  self.Item:SetItemByTemplate(tbItemData.nItemId, tbItemData.nCount, me.nFaction)
  self.Item.fnClick = self.Item.DefaultClick
  local szItemName = KItem.GetItemShowInfo(tbItemData.nItemId, me.nFaction)
  self.pPanel:Label_SetText("TxtName", szItemName)
  local szBidAdd = tbItemData.nBidderId == me.dwID and "加价" or "竞价"
  self.pPanel:Label_SetText("TxtBidAdd", szBidAdd)
  if me.dwID == tbItemData.nBidderId then
    self.pPanel:SetActive("TxtMyState2", false)
    self.pPanel:SetActive("TxtMyState", true)
    self.pPanel:Label_SetText("TxtMyState", "您的出价最高")
  elseif me.dwID == tbItemData.nOwnerId then
    self.pPanel:SetActive("TxtMyState2", false)
    self.pPanel:SetActive("TxtMyState", true)
    self.pPanel:Label_SetText("TxtMyState", "您的拍卖品")
  else
    self.pPanel:SetActive("TxtMyState2", tbItemData.nBidderId and true or false)
    self.pPanel:SetActive("TxtMyState", false)
  end
  self.pPanel:Sprite_SetSprite("Main", tbItemData.nBidderId == me.dwID and "BtnListThirdPress" or "BtnListThirdNormal")
end
function tbItemUi:UpdateTime(tbAuctionData)
  local nNow = GetTime()
  local szTimeInfo = ""
  local tbItemData = self.tbItemData
  local nLeftTime = tbItemData.nStartTime and tbItemData.nStartTime - nNow
  nLeftTime = nLeftTime or tbAuctionData.nStartTime and tbAuctionData.nStartTime - nNow
  if nLeftTime and nLeftTime > 0 then
    local szLeftTime = Lib:TimeDesc3(nLeftTime)
    szTimeInfo = string.format("%s开始", szLeftTime)
  else
    nLeftTime = tbItemData.nTimeOut - nNow
    if nLeftTime < 0 or tbItemData.bSold then
      szTimeInfo = "已结束"
    else
      szTimeInfo = Lib:TimeDesc3(nLeftTime)
    end
  end
  self.pPanel:Label_SetText("TxtLeftTime", szTimeInfo)
  self.pPanel:SetActive("MarkSellOut", tbItemData.bSold or nNow > tbItemData.nTimeOut and tbItemData.nBidderId)
  self.pPanel:SetActive("MarkLiupai", nNow > tbItemData.nTimeOut and not tbItemData.bSold and not tbItemData.nBidderId)
end
tbItemUi.tbOnClick = tbItemUi.tbOnClick or {}
function tbUi:CheckBid(tbItemData, szAuctionType)
  if not tbItemData.nTimeOut then
    me.CenterMsg(self.szBidTips or "未开启")
    return false
  end
  local nNow = GetTime()
  local tbAuctionData = Kin:GetAuction(szAuctionType)
  if tbAuctionData.nStartTime and nNow < tbAuctionData.nStartTime then
    local szLeftTime = Lib:TimeDesc3(tbAuctionData.nStartTime - nNow)
    me.CenterMsg(string.format("%s后开始拍卖", szLeftTime))
    return false
  end
  if tbItemData.nStartTime and nNow < tbItemData.nStartTime then
    local szLeftTime = Lib:TimeDesc3(tbItemData.nStartTime - nNow)
    me.CenterMsg(string.format("%s后开始拍卖", szLeftTime))
    return false
  end
  if tbItemData.bSold or tbItemData.nTimeOut == 0 then
    me.CenterMsg("已经被拍走了")
    return false
  end
  if me.dwID == tbItemData.nOwnerId then
    me.CenterMsg("不能竞拍自己的拍卖品")
    return false
  end
  return true
end
function tbItemUi.tbOnClick:BtnBidAdd()
  local tbItemData = self.tbItemData
  if not self.rootPanel.CheckBid(self.rootPanel, tbItemData, self.szType) then
    return
  end
  local nBidPrice = tbItemData.nCurPrice
  if tbItemData.nBidderId then
    nBidPrice = tbItemData.nCurPrice + math.ceil(tbItemData.nOrgPrice * Kin.AuctionDef.nAddRatePerTime)
  end
  local nCurGold = me.GetMoney("Gold")
  local nRealCost = nBidPrice
  if me.dwID == tbItemData.nBidderId then
    nRealCost = nBidPrice - tbItemData.nCurPrice
  end
  if nCurGold < nRealCost then
    Ui:OpenWindow("CommonShop", "Recharge", "Recharge")
    return
  end
  local szItemName = KItem.GetItemShowInfo(tbItemData.nItemId, me.nFaction)
  if nBidPrice >= tbItemData.nMaxPrice then
    local szMsg = string.format("你的出价已经达到了一口价（[FFFE0D]%d元宝[-]），是否一口价买下[FFFE0D]【%s】[-]？", tbItemData.nMaxPrice, szItemName)
    local function fnConfirm()
      RemoteServer.OnActionRequest("BidOver", self.szType, tbItemData.nId, tbItemData.nMaxPrice)
    end
    me.MsgBox(szMsg, {
      {"确认", fnConfirm},
      {"取消"}
    })
    return
  else
    local szMsg = string.format("确定要花费 [FFFE0D]%d元宝[-] 参与\n[FFFE0D]【%s】[-]的竞拍吗？", nBidPrice, szItemName)
    if tbItemData.nBidderId == me.dwID then
      szMsg = string.format("你当前出价最高，确定要花费 [FFFE0D]%d元宝[-] 加价竞拍[FFFE0D]【%s】[-]吗？", nRealCost, szItemName)
    end
    local function fnConfirm()
      RemoteServer.OnActionRequest("Bid", self.szType, tbItemData.nId, nBidPrice)
    end
    me.MsgBox(szMsg, {
      {"确认", fnConfirm},
      {"取消"}
    })
  end
end
function tbItemUi.tbOnClick:BtnBidOver()
  local tbItemData = self.tbItemData
  if not self.rootPanel.CheckBid(self.rootPanel, tbItemData, self.szType) then
    return
  end
  local nCurGold = me.GetMoney("Gold")
  local nRealCost = tbItemData.nMaxPrice
  if me.dwID == tbItemData.nBidderId then
    nRealCost = tbItemData.nMaxPrice - tbItemData.nCurPrice
  end
  if nCurGold < nRealCost then
    Ui:OpenWindow("CommonShop", "Recharge", "Recharge")
    return
  end
  local szItemName = KItem.GetItemShowInfo(tbItemData.nItemId, me.nFaction)
  local szMsg = string.format("确定要花费 [FFFE0D]%d元宝[-] 一口价购买\n[FFFE0D]【%s】[-]吗？", tbItemData.nMaxPrice, szItemName)
  if me.dwID == tbItemData.nBidderId then
    szMsg = string.format("你当前出价最高[FFFE0D]（%d元宝）[-]，确定要再增加 [FFFE0D]%d元宝[-] 一口价购买\n[FFFE0D]【%s】[-]吗？", tbItemData.nCurPrice, nRealCost, szItemName)
  end
  local function fnConfirm()
    RemoteServer.OnActionRequest("BidOver", self.szType, tbItemData.nId, tbItemData.nMaxPrice)
  end
  me.MsgBox(szMsg, {
    {"确认", fnConfirm},
    {"取消"}
  })
end
