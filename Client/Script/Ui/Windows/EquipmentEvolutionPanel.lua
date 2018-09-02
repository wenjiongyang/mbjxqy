local tbUi = Ui:CreateClass("EquipmentEvolutionPanel")
tbUi.tbOnClick = {
  BtnClose = function(self)
    Ui:CloseWindow(self.UI_NAME)
  end
}
tbUi.tbUiTextSettingAll = {
  Type_Evolution = {
    Title = "进化",
    ShowTip = "*6阶稀有装备，可进化为\n黄金装备",
    BtnName = "进化"
  },
  Type_Upgrade = {
    Title = "升阶",
    ShowTip = "低阶黄金装备，可升阶为更高一阶的黄金装备",
    BtnName = "升阶"
  },
  Type_EvolutionHorse = {
    Title = "升阶",
    ShowTip = "坐骑与3阶坐骑装备可升阶为更高阶的坐骑与坐骑装备",
    BtnName = "升阶"
  }
}
function tbUi:OnOpen(szType, nItemId)
  szType = szType or "Type_Evolution"
  self.szType = szType
  self.tbUiTextSetting = self.tbUiTextSettingAll[szType]
  if not self.tbUiTextSetting then
    return 0
  end
  self:InitEquipList(nItemId)
  if nItemId then
    self.nSelectEquipId = nItemId
  else
    self.nSelectEquipId = self:GetAutoSelelctItem()
  end
  if not self.nSelectEquipId then
    me.CenterMsg("您身上没有符合条件的装备")
    return 0
  end
  self.Evolution.pPanel:Label_SetText("Title", self.tbUiTextSetting.Title)
  self.Evolution.pPanel:Label_SetText("EvolutionTip", self.tbUiTextSetting.ShowTip)
  self.Evolution.pPanel:Button_SetText("BtnEvolution", self.tbUiTextSetting.BtnName)
  self:UpdateEquips()
  self:UpdateMain(self.nSelectEquipId)
  self.pPanel:SetActive("jinhuachenggong", false)
  self.Evolution.pPanel:SetActive("ModelTexture", true)
  self.Evolution.pPanel:NpcView_Open("ShowRole")
  self.Evolution.pPanel:NpcView_ShowNpc("ShowRole", 1124)
  self.Evolution.pPanel:NpcView_SetScale("ShowRole", 0.9)
  self.Evolution.pPanel:NpcView_ChangeDir("ShowRole", 180, false)
end
function tbUi:InitEquipList(nItemId)
  local nKind = self.szType == "Type_EvolutionHorse" and 1 or 0
  local tbAllEquips = me.GetEquips(nKind)
  self.tbEquips = {}
  local bFindItemId = false
  for nPos, nEquipId in pairs(tbAllEquips) do
    if nEquipId == nItemId then
      bFindItemId = true
    end
    local tbData = self:GetEquipListItemData(nEquipId)
    if tbData then
      table.insert(self.tbEquips, tbData)
    end
  end
  if self.szType == "Type_EvolutionHorse" and nItemId and not bFindItemId then
    local tbData = self:GetEquipListItemData(nItemId)
    if tbData then
      table.insert(self.tbEquips, tbData)
    end
  end
end
function tbUi:GetAutoSelelctItem()
  if self.tbEquips then
    local tbFirst = self.tbEquips[1]
    if tbFirst then
      return tbFirst.nItemId
    end
  end
end
function tbUi:GetEquipListItemData(nEquipId)
  local pItem = me.GetItemInBag(nEquipId)
  if not pItem then
    return
  end
  local nTarItem
  if self.szType == "Type_Evolution" then
    nTarItem = Item.GoldEquip:CanEvolutionTarItem(pItem.dwTemplateId)
  elseif self.szType == "Type_EvolutionHorse" then
    if not pItem.nEquipPos or not Item.tbHorseItemPos[pItem.nEquipPos] then
      return
    end
    nTarItem = Item.GoldEquip:CanEvolutionTarItem(pItem.dwTemplateId)
  else
    nTarItem = Item.GoldEquip:CanUpgradeTarItem(pItem.dwTemplateId)
  end
  if not nTarItem then
    return
  end
  local nPos = pItem.nEquipPos
  local bUpgrade, szMsg = Item.GoldEquip:CanEvolution(me, pItem.dwTemplateId)
  local szName = pItem.GetItemShowInfo(me.nFaction)
  return {
    nPos = nPos,
    nItemType = pItem.nItemType,
    szName = szName,
    nSrcItem = pItem.dwTemplateId,
    nEquipLevel = pItem.nLevel,
    nItemId = pItem.dwId,
    nTarItem = nTarItem,
    bUpgrade = bUpgrade
  }
end
function tbUi:UpdateEquips()
  local function fnClick(ButtonObj)
    self.nSelectEquipId = ButtonObj.nItemId
    ButtonObj.pPanel:Toggle_SetChecked("Main", true)
    self:UpdateMain(ButtonObj.nItemId)
  end
  local function fnClickItem(itemframe)
    fnClick(itemframe.parent)
  end
  local function fnSetItem(itemObj, nIndex)
    local tbData = self.tbEquips[nIndex]
    itemObj.pPanel:Toggle_SetChecked("Main", self.nSelectEquipId == tbData.nItemId)
    itemObj.pPanel:SetActive("StoneIconGroup", false)
    itemObj.pPanel:SetActive("TxtStren", false)
    itemObj.pPanel:Label_SetText("TxtName", tbData.szName)
    itemObj.itemframe:SetItem(tbData.nItemId)
    itemObj.itemframe.parent = itemObj
    itemObj.itemframe.fnClick = fnClickItem
    itemObj.nItemId = tbData.nItemId
    itemObj.pPanel.OnTouchEvent = fnClick
    itemObj.pPanel:SetActive("UpgradeFlag", tbData.bUpgrade)
  end
  self.Evolution.ScrollViewStrengthenEquip:Update(#self.tbEquips, fnSetItem)
end
function tbUi:GetEquipInfo(nItemId)
  for i, v in ipairs(self.tbEquips) do
    if v.nItemId == nItemId then
      return v
    end
  end
end
function tbUi:GetShowAttrib(tbAttribSrc)
  local tbRet = {}
  for _, tbDesc in ipairs(tbAttribSrc) do
    if not string.find(tbDesc[1], "上马激活") then
      local _, _, szMagicName, szVal = string.find(tbDesc[1], "(.*)[ ]+(+%d+%%?)")
      if szMagicName then
        tbRet[szMagicName] = szVal
      end
    end
  end
  return tbRet
end
function tbUi:UpdateMain(nItemId)
  local curPanel = self.Evolution
  if not nItemId then
    curPanel.EquipItem2:Clear()
    curPanel.pPanel:SetActive("ConsumptionStren", false)
    return
  end
  local tbData = self:GetEquipInfo(nItemId)
  curPanel.EquipItem2:SetItem(nItemId)
  curPanel.EquipItem2.fnClick = curPanel.EquipItem2.DefaultClick
  curPanel.EquipItem3:SetItemByTemplate(tbData.nTarItem)
  curPanel.EquipItem3.fnClick = curPanel.EquipItem3.DefaultClick
  local tbEquip = Item:GetClass("equip")
  local tbAttribSrc = tbEquip:GetBaseAttrib(tbData.nSrcItem, nil, me)
  local tbAttribTar = tbEquip:GetBaseAttrib(tbData.nTarItem, nil, me)
  local tbSrc = self:GetShowAttrib(tbAttribSrc)
  local tbDest = self:GetShowAttrib(tbAttribTar)
  local nMaxLine = 5
  local i = 0
  for szMagicName2, szVal2 in pairs(tbDest) do
    i = i + 1
    local szVal1 = tbSrc[szMagicName2] or ""
    curPanel.pPanel:Label_SetText("TxtEvolutionName" .. i, szMagicName2)
    curPanel.pPanel:Label_SetText("TxtEvolutionCur" .. i, szVal1)
    curPanel.pPanel:Label_SetText("TxtEvolutionNext" .. i, szVal2)
    local _, _, Val1, szPercent1 = string.find(szVal1, "[^%d]*(%d+)(%%?)")
    local _, _, Val2, szPercent2 = string.find(szVal2, "[^%d]*(%d+)(%%?)")
    local nVal1 = tonumber(Val1)
    local nVal2 = tonumber(Val2)
    if nVal1 and nVal2 and nVal1 < nVal2 then
      curPanel.pPanel:Label_SetText("TxtEvolutionExtent" .. i, string.format("+%d%s", nVal2 - nVal1, szPercent1))
    elseif nVal2 and not nVal1 then
      curPanel.pPanel:Label_SetText("TxtEvolutionExtent" .. i, szVal2)
    else
      curPanel.pPanel:Label_SetText("TxtEvolutionExtent" .. i, "")
    end
    curPanel.pPanel:SetActive("EvolutionWidget" .. i, true)
    if nMaxLine <= i then
      break
    end
  end
  for i2 = i + 1, nMaxLine do
    curPanel.pPanel:SetActive("EvolutionWidget" .. i2, false)
  end
  local tbSuitAttirs, tbActiveNeedNum = Item.GoldEquip:GetSuitAttrib(tbData.nTarItem, me)
  if tbSuitAttirs then
    curPanel.pPanel:SetActive("Suit", true)
    local szTxtAttris = ""
    for i, v in ipairs(tbSuitAttirs) do
      szTxtAttris = szTxtAttris .. v[1] .. "\n"
    end
    curPanel.pPanel:Label_SetText("SuitNum", szTxtAttris)
  else
    curPanel.pPanel:SetActive("Suit", false)
  end
  curPanel.pPanel:SetActive("ConsumptionStren", true)
  local tbSetting
  if self.szType == "Type_Evolution" or self.szType == "Type_EvolutionHorse" then
    tbSetting = Item.GoldEquip:GetEvolutionSetting(tbData.nSrcItem)
  else
    tbSetting = Item.GoldEquip:GetUpgradeSetting(tbData.nSrcItem)
  end
  for i = 1, 2 do
    local nCosumeItem = tbSetting["CosumeItem" .. i]
    local nConsumeCount = tbSetting["ConsumeCount" .. i]
    local tbGrid = curPanel["CostItem" .. i]
    if nCosumeItem ~= 0 then
      tbGrid.pPanel:SetActive("Main", true)
      curPanel.pPanel:SetActive("ItemName" .. i, true)
      curPanel.pPanel:SetActive("TxtConsume" .. i, true)
      tbGrid:SetItemByTemplate(nCosumeItem)
      tbGrid.fnClick = tbGrid.DefaultClick
      local tbItemBase = KItem.GetItemBaseProp(nCosumeItem)
      curPanel.pPanel:Label_SetText("ItemName" .. i, tbItemBase.szName)
      local nExistCount = me.GetItemCountInAllPos(nCosumeItem)
      curPanel.pPanel:Label_SetText("TxtConsume" .. i, string.format("%d/%d", nExistCount, nConsumeCount))
      curPanel.pPanel:Label_SetColorByName("TxtConsume" .. i, nConsumeCount > nExistCount and "Red" or "White")
    else
      tbGrid.pPanel:SetActive("Main", false)
      curPanel.pPanel:SetActive("ItemName" .. i, false)
      curPanel.pPanel:SetActive("TxtConsume" .. i, false)
    end
  end
  if self.szType == "Type_Upgrade" then
    local tbSrcItems = me.FindItemInPlayer(tbSetting.CosumeItem1)
    local pOriSrcItem = tbSrcItems and tbSrcItems[1]
    if pOriSrcItem then
      curPanel.CostItem1:SetItem(pOriSrcItem.dwId)
    end
  end
  function curPanel.BtnEvolution.pPanel.OnTouchEvent(...)
    if self.szType == "Type_Evolution" or self.szType == "Type_EvolutionHorse" then
      self:DoEvolution()
    else
      self:DoUpgrade()
    end
  end
end
function tbUi:DoEvolution()
  if not self.nSelectEquipId then
    me.CenterMsg("请选择装备")
    return
  end
  local pEquip = KItem.GetItemObj(self.nSelectEquipId)
  if not pEquip then
    return
  end
  local bRet, szMsg = Item.GoldEquip:CanEvolution(me, pEquip.dwTemplateId)
  if not bRet then
    if szMsg then
      me.CenterMsg(szMsg)
    end
    return
  end
  RemoteServer.DoEquipEvolution(self.nSelectEquipId)
  self.Evolution.pPanel:Button_SetEnabled("BtnEvolution", false)
  Timer:Register(math.floor(Env.GAME_FPS * 1.6), function()
    self.Evolution.pPanel:Button_SetEnabled("BtnEvolution", true)
  end)
end
function tbUi:DoUpgrade()
  if not self.nSelectEquipId then
    me.CenterMsg("请选择装备")
    return
  end
  local pEquip = KItem.GetItemObj(self.nSelectEquipId)
  if not pEquip then
    return
  end
  local bRet, szMsg = Item.GoldEquip:CanUpgrade(me, pEquip.dwTemplateId)
  if not bRet then
    if szMsg then
      me.CenterMsg(szMsg)
    end
    return
  end
  Item.GoldEquip:DoClietnUpgrade(pEquip)
end
function tbUi:OnResponse(bRet)
  self.pPanel:SetActive("jinhuachenggong", false)
  local fnQHTime = self.Evolution.pPanel:NpcView_PlayAnimation("ShowRole", "qh", 0.1, 1)
  if fnQHTime > 0 then
    if self.nTimerQH then
      Timer:Close(self.nTimerQH)
    end
    local nDelayTime = math.floor(Env.GAME_FPS * fnQHTime * 2 - 5)
    self.nTimerQH = Timer:Register(nDelayTime, function()
      self.Evolution.pPanel:NpcView_PlayAnimation("ShowRole", "st", 0.2, 1)
      self.nTimerQH = nil
      if bRet then
        self.pPanel:SetActive("jinhuachenggong", true)
      end
    end)
    if bRet then
      self.nTimerRefreshUi = Timer:Register(nDelayTime + 5, function()
        self.nTimerRefreshUi = nil
        self:InitEquipList()
        self:UpdateEquips()
        self:UpdateMain()
      end)
    end
  end
end
function tbUi:OnClose()
  self.nSelectEquipId = nil
  self.tbEquips = nil
  self.Evolution.pPanel:SetActive("ModelTexture", false)
  self.Evolution.pPanel:NpcView_Close("ShowRole")
  if self.nTimerRefreshUi then
    Timer:Close(self.nTimerRefreshUi)
    self.nTimerRefreshUi = nil
  end
end
function tbUi:RegisterEvent()
  local tbRegEvent = {
    {
      UiNotify.emNOTIFY_EQUIP_EVOLUTION,
      self.OnResponse
    }
  }
  return tbRegEvent
end
