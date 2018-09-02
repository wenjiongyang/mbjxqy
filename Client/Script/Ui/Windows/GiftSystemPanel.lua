local tbUi = Ui:CreateClass("GiftSystem")
local tbAct = Activity.WomanAct
local emPLAYER_STATE_NORMAL = 2
local nNumPerRow = 7
tbUi.HideUI = {
  BtnGive = true,
  Txt1 = true,
  Txt2 = true,
  ScrollViewItem = true,
  Number = true,
  ScrollViewHead = true
}
function tbUi:OnOpen(nFriendDwId, tbItemInfo)
  Gift:UpdateGiftData()
  self:UpdateAllFriendData(nFriendDwId, tbItemInfo)
end
function tbUi:OnOpenEnd()
  if not self.tbAllFriend or not next(self.tbAllFriend) then
    for szUiName, _ in pairs(self.HideUI) do
      self.pPanel:SetActive(szUiName, false)
    end
    self.pPanel:SetActive("NoFriends", true)
    self.pPanel:SetActive("SelectFriends", true)
    self:UpdateVipPrivilegeDesc()
    return
  else
    for szUiName, _ in pairs(self.HideUI) do
      self.pPanel:SetActive(szUiName, true)
    end
    self.pPanel:SetActive("NoFriends", false)
    self.pPanel:SetActive("SelectFriends", false)
  end
  self:InitBaseData()
  self:UpdateFriendList(true)
  self:UpdateGiftList()
  self:UpdateBottomInfo()
  self:UpdateVipPrivilegeDesc()
end
function tbUi:RefreshUi()
  self:UpdateFriendList()
  self:UpdateGiftList()
  self:UpdateBottomInfo()
end
function tbUi:UpdateVipPrivilegeDesc()
  local szDesc = Recharge:GetVipPrivilegeDesc("WaiYi") or ""
  self.pPanel:Label_SetText("Tip02", szDesc)
  szDesc = Recharge:GetVipPrivilegeDesc("FriendImity") or ""
  self.pPanel:Label_SetText("Tip01", szDesc)
end
function tbUi:InitBaseData()
  self.nCurDwId = self.tbAllFriend[1].dwID
  self.nFaction = self.tbAllFriend[1].nFaction
  self.szName = self.tbAllFriend[1].szName
  self.nGiftType = 1
  self.nSend = 0
  self.nCurItemId = 0
end
function tbUi:IsOnline(nIdx)
  local tbRoleInfo = self.tbAllFriend[nIdx]
  return tbRoleInfo.nState == emPLAYER_STATE_NORMAL
end
function tbUi:UpdateFriendList(bIsGoTop)
  local function fnOnClick(itemObj)
    self.bOnline = itemObj.bOnline
    self.nCurDwId = itemObj.dwID
    self.nFaction = itemObj.nFaction
    self.szName = itemObj.szName
    self.nGiftType = 1
    self.nSend = 0
    self.nLevel = itemObj.nLevel
    self:UpdateGiftList()
    self:UpdateBottomInfo()
  end
  local function fnSetItem(itemObj, nIdx)
    local tbRoleInfo = self.tbAllFriend[nIdx]
    local szName = tbRoleInfo.szName or self.tbAllFriend[nIdx].szWantedName
    local nLevel = tbRoleInfo.nLevel
    itemObj.pPanel:Label_SetText("Label", szName)
    itemObj.pPanel:Label_SetText("lbLevel", nLevel)
    local SpFaction = Faction:GetIcon(tbRoleInfo.nFaction)
    itemObj.pPanel:Sprite_SetSprite("SpFaction", SpFaction)
    local szPortrait, szAltas = PlayerPortrait:GetSmallIcon(tbRoleInfo.nPortrait or tbRoleInfo.nFaction)
    local bOnline = self:IsOnline(nIdx)
    if bOnline then
      itemObj.pPanel:Sprite_SetSprite("SpRoleHead", szPortrait, szAltas)
    else
      itemObj.pPanel:Sprite_SetSpriteGray("SpRoleHead", szPortrait, szAltas)
    end
    itemObj.pPanel:Button_SetSprite("Main", bOnline and "BtnListThirdNormal" or "BtnListThirdDisabled", 1)
    itemObj.bOnline = bOnline
    itemObj.dwID = tbRoleInfo.dwID
    itemObj.nFaction = tbRoleInfo.nFaction
    itemObj.szName = szName
    itemObj.nLevel = nLevel
    itemObj.pPanel.OnTouchEvent = fnOnClick
    itemObj.pPanel:Toggle_SetChecked("Main", false)
    if self.nCurDwId == tbRoleInfo.dwID then
      itemObj.pPanel:Toggle_SetChecked("Main", true)
      fnOnClick(itemObj)
    end
  end
  self.ScrollViewHead:Update(#self.tbAllFriend, fnSetItem)
  if bIsGoTop then
    self.ScrollViewHead:GoTop()
  end
end
function tbUi:UpdateGiftList()
  self.tbAllGift = Gift:GetAllCanSendGift(self.nFaction, self.nCurDwId, self.bOnline, self.nLevel)
  if not self.tbAllGift or not next(self.tbAllGift) and self.tbAllFriend and next(self.tbAllFriend) then
    self.pPanel:SetActive("NoGoods", true)
    self.tbAllGift = {}
  else
    self.pPanel:SetActive("NoGoods", false)
  end
  self.nCurItemId = self.tbAllGift[1] and self.tbAllGift[1].nItemId or 0
  local function fnSetItem(itemObj, nIdx)
    local nCur = (nIdx - 1) * nNumPerRow + 1
    local nStep = nCur + nNumPerRow - 1
    local tbRowList = self:UpdateRowInfo(nCur, nStep)
    self:SetItem(itemObj, nIdx, tbRowList)
  end
  local nRow = math.ceil(#self.tbAllGift / nNumPerRow)
  self.ScrollViewItem:Update(nRow, fnSetItem)
end
function tbUi:UpdateRowInfo(nCur, nStep)
  local tbRowList = {}
  for index = nCur, nStep do
    if self.tbAllGift[index] then
      table.insert(tbRowList, self.tbAllGift[index])
    end
  end
  return tbRowList
end
function tbUi:Select(itemObj, nRemainSend)
  for i = 0, 100 do
    local pObj = self.ScrollViewItem.Grid["Item" .. i]
    if not pObj then
      break
    end
    for j = 1, 100 do
      local cObj = pObj["item" .. j]
      if not cObj then
        break
      end
      cObj.pPanel:SetActive("Select", false)
    end
  end
  itemObj.pPanel:SetActive("Select", nRemainSend > 0)
end
function tbUi:ClearObj()
  for i = 0, 100 do
    local pObj = self.ScrollViewItem.Grid["Item" .. i]
    if not pObj then
      break
    end
    for j = 1, 100 do
      local cObj = pObj["item" .. j]
      if not cObj then
        break
      end
      if cObj.nSend and cObj.nHave then
        cObj.nSend = 0
        local nSend = cObj.nSend
        local nHave = cObj.nHave
        local szCount = nSend < 1 and string.format("%d", nHave) or string.format("%d/%d", nSend, nHave)
        cObj.pPanel:Label_SetText("LabelSuffix", szCount)
        cObj.pPanel:SetActive("LabelSuffix", 0 < cObj.nHave)
        cObj.MinusSign.pPanel:SetActive("Main", nSend > 0)
      end
    end
  end
end
function tbUi:SetItem(itemObj, index, tbRowList)
  local function fnClickItem(itemObj)
    if self.nCurItemId ~= itemObj.nItemId then
      self:ClearObj()
    end
    self.nCurItemId = itemObj.nItemId
    self.nGiftType = itemObj.nGiftType
    local nMaxSend = Gift:MaxTimes(self.nGiftType, self.nCurItemId) or 0
    local nHave = itemObj.nHave
    if nHave <= 0 then
      return
    end
    local nSend = itemObj.nSend
    nSend = nSend + 1
    nSend = nHave < nSend and nHave or nSend
    local nRemainSend = Gift:RemainTimes(self.nCurDwId, self.nGiftType, self.nCurItemId)
    if (nRemainSend <= 0 or nSend > nRemainSend) and nMaxSend ~= Gift.Times.Forever then
      me.CenterMsg("剩余赠送次数不足")
    end
    nSend = nMaxSend ~= Gift.Times.Forever and nSend > nRemainSend and nRemainSend or nSend
    if nMaxSend == Gift.Times.Forever then
      self:Select(itemObj, 1)
    else
      self:Select(itemObj, nRemainSend)
    end
    itemObj.nSend = nSend
    self.nSend = nSend
    local szCount = nSend < 1 and string.format("%d", nHave) or string.format("%d/%d", nSend, nHave)
    itemObj.pPanel:Label_SetText("LabelSuffix", szCount)
    itemObj.pPanel:SetActive("MinusSign", nSend > 0)
    self:UpdateBottomInfo(true)
    Item:ShowItemDetail({
      nTemplate = itemObj.nItemId,
      nFaction = self.nFaction
    }, {x = 370, y = -1})
  end
  local function fnClickMinus(itemObj)
    local parentObj = itemObj.parentObj
    if self.nCurItemId ~= parentObj.nItemId then
      self:ClearObj()
    end
    self.nCurItemId = parentObj.nItemId
    self.nFaction = parentObj.nFaction
    self.nGiftType = parentObj.nGiftType
    local nHave = parentObj.nHave
    if nHave <= 0 then
      return
    end
    local nSend = parentObj.nSend
    nSend = nSend - 1
    nSend = nSend < 1 and 0 or nSend
    parentObj.nSend = nSend
    self.nSend = nSend
    self:Select(itemObj.parentObj, nSend)
    local szCount = nSend < 1 and string.format("%d", nHave) or string.format("%d/%d", nSend, nHave)
    parentObj.pPanel:Label_SetText("LabelSuffix", szCount)
    itemObj.pPanel:SetActive("Main", nSend > 0)
    parentObj.pPanel:SetActive("Select", nSend > 0)
    self:UpdateBottomInfo(true)
  end
  for i, tbInfo in ipairs(tbRowList) do
    if tbInfo then
      local nItemId = tbInfo.nItemId
      itemObj["item" .. i].nItemId = nItemId
      itemObj["item" .. i].nGiftType = tbInfo.nGiftType
      itemObj["item" .. i].nHave = me.GetItemCountInAllPos(nItemId)
      itemObj["item" .. i].nSend = 0
      local nHave = itemObj["item" .. i].nHave
      local nSend = itemObj["item" .. i].nSend
      local szCount = nSend < 1 and string.format("%d", nHave) or string.format("%d/%d", nSend, nHave)
      itemObj["item" .. i].pPanel:Label_SetText("LabelSuffix", szCount)
      itemObj["item" .. i].pPanel:SetActive("LabelSuffix", itemObj["item" .. i].nHave > 0)
      itemObj["item" .. i].pPanel.OnTouchEvent = fnClickItem
      itemObj["item" .. i].MinusSign.parentObj = itemObj["item" .. i]
      itemObj["item" .. i].MinusSign.pPanel.OnTouchEvent = fnClickMinus
      itemObj["item" .. i].MinusSign.pPanel:SetActive("Main", itemObj["item" .. i].nSend > 0)
      local szName, nIcon, nView, nQuality = KItem.GetItemShowInfo(nItemId, self.nFaction)
      local szIconAtlas, szIconSprite = Item:GetIcon(nIcon)
      itemObj["item" .. i].pPanel:Sprite_SetSprite("ItemLayer", szIconSprite, szIconAtlas)
      itemObj["item" .. i].pPanel:SetActive("ItemLayer", true)
      itemObj["item" .. i].pPanel:SetActive("Select", false)
      local _, szIcon = Item:GetQualityColor(nQuality)
      itemObj["item" .. i].pPanel:Sprite_SetSprite("Color", szIcon)
      itemObj["item" .. i].pPanel:SetActive("Main", true)
    end
  end
  self:CheckObj(itemObj, tbRowList)
end
function tbUi:CheckObj(itemObj, tbRowList)
  local rowNum = #tbRowList
  if rowNum < nNumPerRow then
    rowNum = rowNum + 1
    for i = rowNum, nNumPerRow do
      itemObj.pPanel:SetActive("item" .. i, false)
    end
  end
end
local tbHideBottomUi = {
  Txt1 = true,
  Txt2 = true,
  Txt3 = true,
  Number = true
}
function tbUi:UpdateBottomInfo(bChooseItem)
  for szUiName, _ in pairs(tbHideBottomUi) do
    self.pPanel:SetActive(szUiName, false)
  end
  if bChooseItem then
    self.pPanel:SetActive("Txt1", true)
    self.pPanel:SetActive("Txt2", true)
    self.pPanel:SetActive("Number", true)
    local nGiftType = self.nGiftType
    local dwID = self.nCurDwId
    local nSend = self.nSend or 0
    local nRemainSend = Gift:RemainTimes(dwID, nGiftType, self.nCurItemId) or 0
    local nMaxSend = Gift:MaxTimes(nGiftType, self.nCurItemId) or 0
    local nWillSend = nMaxSend - nRemainSend + nSend
    nWillSend = nMaxSend < nWillSend and nMaxSend or nWillSend
    local nRate = Gift.Rate[nGiftType] or 0
    if nGiftType == Gift.GiftType.MailGift then
      nRate = Gift:GetMailAddImitity(nGiftType, self.nCurItemId) or 0
    end
    local nAddImitity = nRate * nSend
    local szName = self.szName or ""
    nWillSend = bChooseItem and nWillSend or 0
    local nPercent = nWillSend / nMaxSend
    local szPercent = nMaxSend == Gift.Times.Forever and "-/-" or string.format("%d / %d", nWillSend, nMaxSend)
    if nMaxSend == Gift.Times.Forever then
      nPercent = 0
    end
    self.pPanel:Sprite_SetFillPercent("NumberBar", nPercent)
    self.pPanel:Label_SetText("Txt1", string.format("[92D2FF]与[FFFE0D]%s[-]亲密度增加：[-]%d", szName, nAddImitity))
    self.pPanel:Label_SetText("NumberTxt", szPercent)
    local szItemName = KItem.GetItemShowInfo(self.nCurItemId, me.nFaction) or ""
    local bReset = Gift:GetIsReset(nGiftType, self.nCurItemId)
    local szChoseTip = bReset and string.format("[92D2FF]今日已赠送[FFFE0D]%s[-]数量[-]", szItemName) or string.format("[92D2FF]已赠送[FFFE0D]%s[-]数量[-]", szItemName)
    local szNoChoseTip = bReset and "今日已赠送数量" or "已赠送数量"
    local szItemTips = bChooseItem and szChoseTip or szNoChoseTip
    self.pPanel:Label_SetText("Txt2", szItemTips)
  else
    self.pPanel:SetActive("Txt3", true)
  end
end
function tbUi:UpdateAllFriendData(nFriendDwId, tbItemInfo)
  local tbAllFriend = FriendShip:GetAllFriendData()
  local function fnSort(a, b)
    if a.nState == emPLAYER_STATE_NORMAL and b.nState == emPLAYER_STATE_NORMAL then
      return a.nImity > b.nImity
    elseif a.nState == emPLAYER_STATE_NORMAL then
      return true
    elseif b.nState == emPLAYER_STATE_NORMAL then
      return false
    else
      return a.nImity > b.nImity
    end
  end
  table.sort(tbAllFriend, fnSort)
  local tbTemp = Lib:CopyTB(tbAllFriend)
  local tbAllFriendTemp = {}
  local tbRoleInfo
  if nFriendDwId then
    for index, tbInfo in ipairs(tbTemp) do
      if tbInfo.dwID == nFriendDwId then
        tbRoleInfo = tbInfo
        table.remove(tbTemp, index)
        break
      end
    end
  end
  if tbRoleInfo then
    table.insert(tbAllFriendTemp, tbRoleInfo)
  end
  for index, tbInfo in ipairs(tbTemp) do
    if not (tbItemInfo and tbItemInfo.nGiftType and tbItemInfo.nItemId) or Gift:CheckItemFriend(tbItemInfo.nGiftType, tbItemInfo.nItemId, tbInfo.dwID) then
      table.insert(tbAllFriendTemp, tbInfo)
    end
  end
  self.tbAllFriend = tbAllFriendTemp
end
tbUi.tbOnClick = {
  BtnClose = function(self)
    Ui:CloseWindow("GiftSystem")
  end,
  BtnGive = function(self)
    if not self.nSend or self.nSend < 1 then
      me.CenterMsg("请选择要赠送的物品")
      return
    end
    local bNeedSure = Gift:CheckNeedSure(self.nGiftType, self.nCurItemId)
    if bNeedSure then
      local szSureTip = "确定要赠送吗"
      if self.nGiftType == Gift.GiftType.MailGift then
        local tbInfo = Gift:GetMailGiftItemInfo(self.nCurItemId)
        if not tbInfo then
          me.CenterMsg("请选择要赠送的物品")
          return
        end
        if tbInfo.tbData.szSureTip then
          szSureTip = tbInfo.tbData.szSureTip
        end
      end
      me.MsgBox(szSureTip, {
        {
          "确定",
          function()
            RemoteServer.SendGift(self.nGiftType, self.nCurDwId, self.nSend, self.nCurItemId)
          end
        },
        {"取消"}
      })
    else
      RemoteServer.SendGift(self.nGiftType, self.nCurDwId, self.nSend, self.nCurItemId)
    end
  end
}
function tbUi:RegisterEvent()
  local tbRegEvent = {
    {
      UiNotify.emNOTIFY_SYN_GIFT_DATA_FINISH,
      self.RefreshUi,
      self
    }
  }
  return tbRegEvent
end
