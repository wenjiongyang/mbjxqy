local tbUi = Ui:CreateClass("ChatEmotionLink")
local tbTab2Name = {
  Item = "ItemGroup",
  Companion = "CompanionGroup",
  Emotion = "EmotionGroup",
  Achievement = "AchievementGroup",
  LabelEmotion = "LabelEmotionGroup",
  HistoryMsg = "HistoryMsgGroup",
  ActionExpression = "LabelEmotionGroup"
}
function tbUi:OnOpen(pInputField, szTab, bBottom)
  self.pInputField = pInputField
  self.szCurTab = szTab or self.szCurTab or "Emotion"
  self.pPanel:ChangePosition("Main", 0, bBottom and -85 or -13)
end
function tbUi:OnOpenEnd()
  self:Switch(self.szCurTab)
  self.pPanel:Toggle_SetChecked(self.szCurTab .. "Tab", true)
  self:UpdateLocationTab()
  self:UpdateBeautyTab()
end
function tbUi:UpdateLocationTab()
  local bWhiteTigerFuben = Fuben.WhiteTigerFuben:IsMyMap(me.nMapTemplateId)
  self.pPanel:Button_SetEnabled("LocationTab", not bWhiteTigerFuben)
end
function tbUi:UpdateBeautyTab()
  local bEnable = false
  if Activity.BeautyPageant:IsInProcess() and Activity.BeautyPageant:IsSignUp() then
    bEnable = true
  end
  self.pPanel:SetActive("BeautySelection", bEnable)
  self.pPanel:Button_SetEnabled("BeautySelection", bEnable)
end
function tbUi:OnScreenClick()
  Ui:CloseWindow(self.UI_NAME)
end
function tbUi:OnClose()
  self.pInputField = nil
end
function tbUi:Switch(szTab)
  local szShowActiveName = ""
  for szKey, szName in pairs(tbTab2Name) do
    if szKey == szTab then
      szShowActiveName = szName
      self.pPanel:SetActive(szName, true)
      self[szKey .. "Update"](self)
      self.szCurTab = szTab
    elseif szShowActiveName ~= szName then
      self.pPanel:SetActive(szName, false)
    end
  end
end
function tbUi:EmotionUpdate()
  local nEmotionMax = #ChatMgr.tbChatEmotionList
  local nEmotionPerLine = 12
  local function fnSelectEmotion(emotionItem)
    self:AddEmotion(emotionItem.nIndex)
  end
  local function fnSetItem(itemObj, nIndex)
    itemObj.nIndex = nIndex
    for i = 1, nEmotionPerLine do
      local nEmotionIndex = (nIndex - 1) * nEmotionPerLine + i
      local tbEmotionInfo = ChatMgr.tbChatEmotionList[nEmotionIndex]
      if tbEmotionInfo then
        itemObj.pPanel:Sprite_SetSprite("Item" .. i, tostring(tbEmotionInfo.EmotionId), tbEmotionInfo.Atlas)
        itemObj.pPanel:Sprite_Animation("Item" .. i, tbEmotionInfo.EmotionId .. "-", tbEmotionInfo.Atlas)
        itemObj["Item" .. i].nIndex = tbEmotionInfo.EmotionId
        itemObj["Item" .. i].pPanel.OnTouchEvent = fnSelectEmotion
      end
      itemObj.pPanel:SetActive("Item" .. i, tbEmotionInfo and true or false)
    end
  end
  self.EmotionScrollView:Update(math.ceil(nEmotionMax / nEmotionPerLine), fnSetItem)
end
function tbUi:ItemUpdate()
  local tbItems = {}
  local tbEquip = me.GetEquips(1)
  for i = 0, Item.EQUIPPOS_NUM do
    if tbEquip[i] then
      table.insert(tbItems, {
        Id = tbEquip[i],
        bEquiped = true
      })
    end
  end
  local tbStoneMap = {}
  for nEquipPos = Item.EQUIPPOS_HEAD, Item.EQUIPPOS_PENDANT do
    local tbInset = me.GetInsetInfo(nEquipPos) or {}
    for i = 1, StoneMgr.INSET_COUNT_MAX do
      local nTemplateId = tbInset[i]
      if nTemplateId and nTemplateId ~= 0 and not tbStoneMap[nTemplateId] then
        tbStoneMap[nTemplateId] = true
        table.insert(tbItems, {nTemplateId = nTemplateId, bEquiped = true})
      end
    end
  end
  local tbItemInBag = me.GetItemListInBag()
  table.sort(tbItemInBag, function(a, b)
    if a.nItemType == b.nItemType then
      if a.nDetailType == b.nDetailType then
        if a.GetSingleValue() == b.GetSingleValue() then
          return a.dwId < b.dwId
        end
        return a.GetSingleValue() > b.GetSingleValue()
      end
      return a.nDetailType < b.nDetailType
    end
    return a.nItemType < b.nItemType
  end)
  for _, pItem in ipairs(tbItemInBag) do
    table.insert(tbItems, {
      Id = pItem.dwId,
      bEquiped = false
    })
  end
  local function fnSelectItem(itemObj)
    self:AddItem(itemObj.Id or 0, itemObj.nTemplateId or 0)
  end
  local function fnSetItem(itemObj, nRow)
    for i = 1, 8 do
      local nIndex = (nRow - 1) * 8 + i
      local item = tbItems[nIndex]
      itemObj.pPanel:SetActive("item" .. i, item and true or false)
      if item then
        if item.Id then
          itemObj["item" .. i]:SetItem(item.Id)
          itemObj["item" .. i].Id = item.Id
          itemObj["item" .. i].nTemplateId = nil
        else
          itemObj["item" .. i]:SetItemByTemplate(item.nTemplateId)
          itemObj["item" .. i].nTemplateId = item.nTemplateId
          itemObj["item" .. i].Id = nil
        end
        itemObj["item" .. i].fnClick = fnSelectItem
        itemObj["item" .. i].pPanel:SetActive("TagTip", item.bEquiped)
        if item.bEquiped then
          itemObj["item" .. i].pPanel:Sprite_SetSprite("TagTip", "itemtag_yizhuangbei")
        end
      end
    end
  end
  self.ItemScrollView:Update(math.ceil(#tbItems / 8), fnSetItem)
end
function tbUi:CompanionUpdate()
  local tbPartners = me.GetAllPartner()
  local tbItems = {}
  for nId, tbItem in pairs(tbPartners) do
    tbItem.nId = nId
    table.insert(tbItems, tbItem)
  end
  table.sort(tbItems, function(a, b)
    if a.nQualityLevel == b.nQualityLevel then
      return a.nFightPower > b.nFightPower
    else
      return a.nQualityLevel < b.nQualityLevel
    end
  end)
  local function fnSelectPartner(partnerObj)
    self:AddPartner(partnerObj.tbPartner)
  end
  local function fnSetItem(itemObj, nIndex)
    local tbItem1 = tbItems[3 * nIndex - 2]
    local tbItem2 = tbItems[3 * nIndex - 1]
    local tbItem3 = tbItems[3 * nIndex]
    itemObj.pPanel:SetActive("Item1", tbItem1 and true or false)
    itemObj.pPanel:SetActive("Item2", tbItem2 and true or false)
    itemObj.pPanel:SetActive("Item3", tbItem3 and true or false)
    if tbItem1 then
      itemObj.Item1:Init(tbItem1)
      itemObj.Item1.tbPartner = tbItem1
      itemObj.Item1.pPanel.OnTouchEvent = fnSelectPartner
    end
    if tbItem2 then
      itemObj.Item2:Init(tbItem2)
      itemObj.Item2.tbPartner = tbItem2
      itemObj.Item2.pPanel.OnTouchEvent = fnSelectPartner
    end
    if tbItem3 then
      itemObj.Item3:Init(tbItem3)
      itemObj.Item3.tbPartner = tbItem3
      itemObj.Item3.pPanel.OnTouchEvent = fnSelectPartner
    end
  end
  self.PartnerScrollView:Update(math.ceil(#tbItems / 3), fnSetItem)
end
function tbUi:AchievementUpdate()
  local tbItems = Achievement:GetCompleteList()
  local function fnSelectAchievement(ButtonObj)
    self:AddAchievement(unpack(ButtonObj.tbParams))
  end
  local function fnSetItem(itemObj, nIndex)
    for i = 1, 4 do
      local tbItem = tbItems[(nIndex - 1) * 4 + i]
      itemObj.pPanel:SetActive("Item" .. i, tbItem ~= nil)
      if tbItem then
        itemObj["Item" .. i]:SetContent(tbItem.szKind, tbItem.nLevel)
        itemObj["Item" .. i].tbParams = {
          tbItem.szKind,
          tbItem.nLevel
        }
        itemObj["Item" .. i].pPanel.OnTouchEvent = fnSelectAchievement
      end
    end
  end
  self.AchievementScrollView:Update(math.ceil(#tbItems / 4), fnSetItem)
end
local tbQuickChatMsg = LoadTabFile("Setting/Chat/QuickChatMsg.tab", "ss", nil, {"Title", "Content"})
function tbUi:LabelEmotionUpdate()
  local tbItems = tbQuickChatMsg
  local function fnSelectItem(btnObj)
    local szMsg = btnObj.tbItem.Content
    szMsg = string.gsub(szMsg, "$M", me.szName) or szMsg
    self:AddMsg(szMsg)
  end
  local function fnSetItem(itemObj, nIndex)
    for i = 1, 3 do
      local tbItem = tbItems[(nIndex - 1) * 3 + i]
      itemObj.pPanel:SetActive("Item" .. i, tbItem and true or false)
      if tbItem then
        itemObj["Item" .. i].pPanel:Label_SetText("Label" .. i, tbItem.Title)
        itemObj["Item" .. i].tbItem = tbItem
        itemObj["Item" .. i].pPanel.OnTouchEvent = fnSelectItem
      end
    end
  end
  self.LabelScrollView:Update(math.ceil(#tbItems / 3), fnSetItem)
end
function tbUi:ActionExpressionUpdate()
  local tbAllItem = {}
  local pNpc = me.GetNpc()
  local tbBQActionType = ChatMgr:GetActionBQType(pNpc.nShapeShiftNpcTID)
  for _, tbInfo in pairs(tbBQActionType) do
    if tbInfo.ChatID > 0 then
      table.insert(tbAllItem, tbInfo)
    end
  end
  table.sort(tbAllItem, function(a, b)
    return a.ChatID < b.ChatID
  end)
  local fnSelectItem = function(btnObj)
    if InDifferBattle.bRegistNotofy then
      me.CenterMsg("当前暂不可用")
      return
    end
    if not btnObj.tbItem then
      me.CenterMsg("操作错误！", true)
      return
    end
    Lib:CallBack({
      ChatMgr.ChatDecorate.TryCheckValid,
      ChatMgr.ChatDecorate
    })
    RemoteServer.SendChatBQ(btnObj.tbItem.ChatID)
    Ui:CloseWindow("ChatEmotionLink")
    Ui:CloseWindow("ChatLargePanel")
  end
  local function fnSetItem(itemObj, nIndex)
    for i = 1, 3 do
      local tbItem = tbAllItem[(nIndex - 1) * 3 + i]
      itemObj.pPanel:SetActive("Item" .. i, tbItem and true or false)
      if tbItem then
        itemObj["Item" .. i].pPanel:Label_SetText("Label" .. i, tbItem.Name)
        itemObj["Item" .. i].tbItem = tbItem
        itemObj["Item" .. i].pPanel.OnTouchEvent = fnSelectItem
      end
    end
  end
  self.LabelScrollView:Update(math.ceil(#tbAllItem / 3), fnSetItem)
end
function tbUi:HistoryMsgUpdate()
  local tbItems = ChatMgr:GetRecentMsgs()
  local function fnSelectItem(btnObj)
    self:AddMsg(btnObj.szMsg)
  end
  local function fnSetItem(itemObj, nIndex)
    for i = 1, 3 do
      local szMsg = tbItems[(nIndex - 1) * 3 + i]
      itemObj.pPanel:SetActive("Item" .. i, szMsg and true or false)
      if szMsg then
        itemObj["Item" .. i].pPanel:Label_SetText("Label" .. i, ChatMgr:CutMsg(szMsg, 11))
        itemObj["Item" .. i].szMsg = szMsg
        itemObj["Item" .. i].pPanel.OnTouchEvent = fnSelectItem
      end
    end
  end
  self.HistoryMsgScrollView:Update(math.ceil(#tbItems / 3), fnSetItem)
  self.HistoryMsgScrollView:GoTop()
end
tbUi.tbOnClick = tbUi.tbOnClick or {}
for szKey, _ in pairs(tbTab2Name) do
  tbUi.tbOnClick[szKey .. "Tab"] = function(self)
    self:Switch(szKey)
  end
end
function tbUi.tbOnClick:LocationTab()
  self:AddLocation()
end
function tbUi.tbOnClick:BtnClose()
  Ui:CloseWindow("ChatEmotionLink")
end
function tbUi.tbOnClick:BeautySelection()
  local tbAct = Activity.BeautyPageant
  local nChannelId = self.pInputField.pChatLarge.nChannelId
  local bFriend = nChannelId == ChatMgr.nChannelFriendName
  local nType = tbAct.MSG_CHANNEL_TYPE.NORMAL
  local nParam = nChannelId
  if bFriend then
    nType = tbAct.MSG_CHANNEL_TYPE.PRIVATE
    nParam = self.pInputField.pChatLarge.nNowChatFriendId
  elseif nChannelId >= ChatMgr.nDynChannelBegin then
    nType = tbAct.MSG_CHANNEL_TYPE.FACTION
  end
  tbAct:SendMsg(nType, nParam)
  self.pInputField:UpdateCdExpression()
  if bFriend then
    self.pInputField.pChatLarge:UpdateChatList()
  end
end
function tbUi:AddEmotion(nEmotionIdx)
  local szMsg = self.pInputField.pPanel:Input_GetText("InputField") or ""
  local szEmotion = string.format("#%d", nEmotionIdx)
  szMsg = szMsg .. szEmotion
  if Lib:Utf8Len(szMsg) > ChatMgr.nMaxMsgLengh then
    me.CenterMsg("输入的内容超出上限")
    return
  end
  self.pInputField.pPanel:Input_SetText("InputField", szMsg)
end
function tbUi:AddLocation()
  local nMapId, nPosX, nPosY = Decoration:GetPlayerSettingOrgPos(me)
  local szMsg = self.pInputField.pPanel:Input_GetText("InputField") or ""
  local nMapTemplateId = me.nMapTemplateId
  local szMapName = Map:GetMapDescInChat(nMapTemplateId)
  if ImperialTomb:IsEmperorMapByTemplate(nMapTemplateId) or ImperialTomb:IsBossMapByTemplate(nMapTemplateId) or ImperialTomb:IsFemaleEmperorMapByTemplate(nMapTemplateId) or ImperialTomb:IsFemaleEmperorBossMapByTemplate(nMapTemplateId) then
    local nTmpMapId
    nMapTemplateId, nTmpMapId, nPosX, nPosY = ImperialTomb:GetCurRoomEnterPos()
    nMapId = nMapTemplateId
    szMapName = Map:GetMapDescInChat(nMapTemplateId)
  end
  if House.nHouseMapId and me.nMapId == House.nHouseMapId then
    szMapName = string.format("%s的家", House.szName)
  end
  local szLocaltion = string.format("<%s(%d,%d)>", szMapName, nPosX * Map.nShowPosScale, nPosY * Map.nShowPosScale)
  szMsg = szLocaltion .. string.gsub(szMsg, "^(<.+>)(.*)$", "%2")
  if Lib:Utf8Len(szMsg) > ChatMgr.nMaxMsgLengh then
    me.CenterMsg("输入的内容超出上限")
    return
  end
  if nMapTemplateId == Kin.Def.nKinMapTemplateId then
    nMapId = Kin.Def.nKinMapTemplateId
  end
  self.pInputField.pPanel:Input_SetText("InputField", szMsg)
  ChatMgr:SetChatLink(ChatMgr.LinkType.Position, {
    nMapId,
    nPosX,
    nPosY,
    nMapTemplateId
  })
end
function tbUi:AddPartner(tbPartner)
  local szMsg = self.pInputField.pPanel:Input_GetText("InputField") or ""
  local szPartner = string.format("<%s>", tbPartner.szName)
  szMsg = szPartner .. string.gsub(szMsg, "^(<.+>)(.*)$", "%2")
  if Lib:Utf8Len(szMsg) > ChatMgr.nMaxMsgLengh then
    me.CenterMsg("输入的内容超出上限")
    return
  end
  self.pInputField.pPanel:Input_SetText("InputField", szMsg)
  ChatMgr:SetChatLink(ChatMgr.LinkType.Partner, tbPartner.nId)
end
function tbUi:AddMsg(szMsg)
  self.pInputField.pPanel:Input_SetText("InputField", szMsg)
end
function tbUi:AddAchievement(szKind, nLevel)
  local szMsg = self.pInputField.pPanel:Input_GetText("InputField") or ""
  local szName = Achievement:GetTitleAndDesc(szKind, nLevel)
  local szName = string.format("成就：%s", szName)
  local szAchievement = string.format("<%s>", szName)
  szMsg = szAchievement .. string.gsub(szMsg, "^(<.+>)(.*)$", "%2")
  if Lib:Utf8Len(szMsg) > ChatMgr.nMaxMsgLengh then
    me.CenterMsg("输入的内容超出上限")
    return
  end
  self.pInputField.pPanel:Input_SetText("InputField", szMsg)
  local nId = Achievement:GetIdByKind(szKind)
  ChatMgr:SetChatLink(ChatMgr.LinkType.Achievement, nId * 100 + nLevel)
end
function tbUi:AddItem(nId, nTemplateId)
  local szName = ""
  local itemObj = KItem.GetItemObj(nId)
  if itemObj then
    szName = itemObj.GetItemShowInfo()
  else
    szName = KItem.GetItemShowInfo(nTemplateId, me.nFaction)
  end
  if Lib:IsEmptyStr(szName) then
    return
  end
  local szMsg = self.pInputField.pPanel:Input_GetText("InputField") or ""
  local szItem = string.format("<%s>", szName)
  szMsg = szItem .. string.gsub(szMsg, "^(<.+>)(.*)$", "%2")
  if Lib:Utf8Len(szMsg) > ChatMgr.nMaxMsgLengh then
    me.CenterMsg("输入的内容超出上限")
    return
  end
  self.pInputField.pPanel:Input_SetText("InputField", szMsg)
  ChatMgr:SetChatLink(ChatMgr.LinkType.Item, {nId, nTemplateId})
end
local tbPartnerItem = Ui:CreateClass("ChatPartnerItem")
function tbPartnerItem:Init(tbItem)
  if version_tx then
    self.pPanel:Label_SetText("Level", string.format("%s级", tbItem.nLevel))
  else
    self.pPanel:Label_SetText("Level", "Lv." .. tbItem.nLevel)
  end
  self.pPanel:Label_SetText("PartnerName", tbItem.szName)
  self.Face:SetPlayerPartnerWhithoutLevel(tbItem.nId)
end
