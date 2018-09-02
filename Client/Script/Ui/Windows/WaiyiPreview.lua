local tbUi = Ui:CreateClass("WaiyiPreview")
tbUi.tbOnDrag = {
  ShowRole = function(self, szWnd, nX, nY)
    self.pPanel:NpcView_ChangeDir("ShowRole", -nX, true)
  end
}
tbUi.tbOnClick = {
  BtnClose = function(self)
    Ui:CloseWindow(self.UI_NAME)
  end,
  BtnColour = function(self)
    if self.fnCallback then
      self.fnCallback(self, self.varParam)
    end
  end,
  BtnPlus = function(self)
    Ui:OpenWindow("CommonShop", "Treasure", "tabAllShop", Item.tbChangeColor.CONSUME_ITEM)
  end,
  Arms = function(self)
    self:ChangeFeature()
    if self.nWaiyiPos == Item.EQUIPPOS_WAI_HORSE then
      self.pPanel:NpcView_ChangeDir("ShowRole", 180, false)
    end
    if self.nWaiyiPos ~= Item.EQUIPPOS_WAI_WEAPON then
      self.tbSelect[self.nWaiyiPos] = self.nSelectId
      self.nWaiyiPos = Item.EQUIPPOS_WAI_WEAPON
      self.nSelectId = self.tbSelect[self.nWaiyiPos]
    end
    self:Update()
  end,
  Clothes = function(self)
    self:ChangeFeature()
    if self.nWaiyiPos == Item.EQUIPPOS_WAI_HORSE then
      self.pPanel:NpcView_ChangeDir("ShowRole", 180, false)
    end
    if self.nWaiyiPos ~= Item.EQUIPPOS_WAIYI then
      self.tbSelect[self.nWaiyiPos] = self.nSelectId
      self.nWaiyiPos = Item.EQUIPPOS_WAIYI
      self.nSelectId = self.tbSelect[self.nWaiyiPos]
    end
    self:Update()
  end,
  Mount = function(self)
    self:ChangeHorse()
    if self.nWaiyiPos ~= Item.EQUIPPOS_WAI_HORSE then
      self.pPanel:NpcView_ChangeDir("ShowRole", 220, false)
    end
    if self.nWaiyiPos ~= Item.EQUIPPOS_WAI_HORSE then
      self.tbSelect[self.nWaiyiPos] = self.nSelectId
      self.nWaiyiPos = Item.EQUIPPOS_WAI_HORSE
      self.nSelectId = self.tbSelect[self.nWaiyiPos]
    end
    self:Update()
  end
}
function tbUi:OnOpen(nTemplateId, nFaction)
  self.pPanel:NpcView_Open("ShowRole")
  self.tbClosePage = self.tbClosePage or {}
  self.nPreviewId = Item.tbChangeColor:GetChangeId(nTemplateId)
  self.nFixFaction = me.nFaction
  if nTemplateId then
    self.nSelectId = nTemplateId
    self.nFixFaction = nFaction or self.nFixFaction
  else
    local pCurWaiYi = me.GetEquipByPos(Item.EQUIPPOS_WAIYI)
    local pCurWaiWeapon = me.GetEquipByPos(Item.EQUIPPOS_WAI_WEAPON)
    local pCurWaiHorse = me.GetEquipByPos(Item.EQUIPPOS_WAI_HORSE)
    self.nSelectId = pCurWaiYi and pCurWaiYi.dwTemplateId
    self.tbSelect = {
      [Item.EQUIPPOS_WAIYI] = pCurWaiYi and pCurWaiYi.dwTemplateId,
      [Item.EQUIPPOS_WAI_WEAPON] = pCurWaiWeapon and pCurWaiWeapon.dwTemplateId,
      [Item.EQUIPPOS_WAI_HORSE] = pCurWaiHorse and pCurWaiHorse.dwTemplateId
    }
  end
  self.nWaiyiPos = Item.EQUIPPOS_WAIYI
  if self.nSelectId then
    self.nWaiyiPos = KItem.GetEquipPos(self.nSelectId)
  end
  self.pPanel:Toggle_SetChecked("Clothes", self.nWaiyiPos == Item.EQUIPPOS_WAIYI)
  self.pPanel:Toggle_SetChecked("Arms", self.nWaiyiPos == Item.EQUIPPOS_WAI_WEAPON)
  self.pPanel:Toggle_SetChecked("Mount", self.nWaiyiPos == Item.EQUIPPOS_WAI_HORSE)
  self.nStartIndex = nil
  self.tbPart = {}
  self:CloseRoleAniTimer()
  self:Update()
  if not next(self.tbDataList) and not next(self.tbHasWaiyi) then
    self.pPanel:NpcView_Close("ShowRole")
    me.CenterMsg("您目前没有任何外装")
    return 0
  end
  if self.nStartIndex then
    self.ColourListScrollView.pPanel:ScrollViewGoToIndex("Main", self.nStartIndex)
  end
  if not self.nTimer then
    self.nTimer = Timer:Register(Env.GAME_FPS * 30, self.Update, self)
  end
end
local tbPos2Part = {
  [Item.EQUIPPOS_WAIYI] = 0,
  [Item.EQUIPPOS_WAI_WEAPON] = 1,
  [Item.EQUIPPOS_WAI_HORSE] = 3
}
function tbUi:Update()
  self.nGroupCount = 0
  self.tbWaiyiList = {}
  self.tbDataList = {}
  self.tbHeight = {}
  self.tbChangeId = {}
  local tbAllWaiyi = me.FindItemInPlayer("waiyi")
  self.tbHasWaiyi = {}
  self.tbNameSubDesc = {}
  self.nEquipTemplateId = 0
  local pCurWaiZhuang = me.GetEquipByPos(self.nWaiyiPos)
  if pCurWaiZhuang then
    self.nEquipTemplateId = pCurWaiZhuang.dwTemplateId
  end
  self.nPart = tbPos2Part[self.nWaiyiPos]
  if self.nPreviewId then
    self.pPanel:SetActive("Tab", false)
  else
    self.pPanel:SetActive("Tab", true)
    local pWaiyi = me.GetEquipByPos(Item.EQUIPPOS_WAIYI)
    local pWaiWeapon = me.GetEquipByPos(Item.EQUIPPOS_WAI_WEAPON)
    local pWaiHorse = me.GetEquipByPos(Item.EQUIPPOS_WAI_HORSE)
    self.Clothes:SetItemByTemplate(pWaiyi and pWaiyi.dwTemplateId)
    self.Arms:SetItemByTemplate(pWaiWeapon and pWaiWeapon.dwTemplateId)
    self.Mount:SetItemByTemplate(pWaiHorse and pWaiHorse.dwTemplateId)
  end
  local tbTimeOutChangeId = {}
  for _, pCurItem in pairs(tbAllWaiyi) do
    local nTemplateId = pCurItem.dwTemplateId
    local nTimeOut = pCurItem.GetBaseIntValue(4)
    self.tbHasWaiyi[nTemplateId] = 1
    if Item.tbChangeColor.tbColorItem[nTemplateId] then
      local nChangeId = Item.tbChangeColor:GetChangeId(nTemplateId)
      self.tbChangeId[nChangeId] = self.tbChangeId[nChangeId] or {}
      if nTimeOut > 0 then
        tbTimeOutChangeId[nChangeId] = math.max(tbTimeOutChangeId[nChangeId] or 0, nTimeOut)
      end
      table.insert(self.tbChangeId[nChangeId], pCurItem.dwId)
    end
  end
  local nCurTime = GetTime()
  for _, tbGroup in ipairs(Item.tbChangeColor.tbSortGroup) do
    if not self.nPreviewId and self.tbChangeId[tbGroup.nId] and tbGroup.nPart == self.nPart or tbGroup.nId == self.nPreviewId then
      local szGroupName = tbGroup.tbNameList[self.nFixFaction]
      local tbBaseProp = KItem.GetItemBaseProp(tbGroup.tbItemSort[1])
      if tbBaseProp.nFactionLimit == 0 or self.nFixFaction == tbBaseProp.nFactionLimit then
        table.insert(self.tbDataList, szGroupName)
        if tbTimeOutChangeId[tbGroup.nId] and 0 < tbTimeOutChangeId[tbGroup.nId] then
          self.tbNameSubDesc[#self.tbDataList] = Lib:TimeDesc13(tbTimeOutChangeId[tbGroup.nId] - nCurTime)
        end
        table.insert(self.tbHeight, 50)
        for _, nTemplateId in ipairs(tbGroup.tbItemSort) do
          local szName = KItem.GetItemShowInfo(nTemplateId, self.nFixFaction)
          self.tbWaiyiList[nTemplateId] = {
            nTemplateId,
            szName,
            tbGroup.nPart,
            self.tbHasWaiyi[nTemplateId],
            tbGroup.nId,
            self.STATE_NONE
          }
          if not self.tbClosePage[szGroupName] then
            local varLastNode = self.tbDataList[#self.tbDataList]
            if type(varLastNode) == "string" or #varLastNode > 1 then
              table.insert(self.tbDataList, {})
              table.insert(self.tbHeight, 90)
              varLastNode = self.tbDataList[#self.tbDataList]
            end
            table.insert(varLastNode, nTemplateId)
          end
          if not self.nSelectId then
            self.nSelectId = nTemplateId
          end
          if self.nSelectId == nTemplateId then
            self.nStartIndex = #self.tbDataList
          end
        end
      end
    end
  end
  self:RefreshList()
  return true
end
tbUi.STATE_NONE = 1
tbUi.STATE_CHANGEABLE = 2
tbUi.STATE_HAS = 3
tbUi.STATE_EQUIPING = 4
tbUi.tbStateDesc = {
  "未获得",
  "可染色",
  "[6cdd00]已拥有[-]",
  "[6cdd00]装备中[-]"
}
function tbUi:SetEquipInfo(pButton, nTemplateId, fnClickCallback)
  local data = self.tbWaiyiList[nTemplateId]
  local nTemplateId, szName, nPart, nHasWaiyi, nChangeId, nState = unpack(data)
  nState = self.STATE_NONE
  if self.tbChangeId[nChangeId] and #self.tbChangeId[nChangeId] > 0 then
    nState = self.STATE_CHANGEABLE
  end
  if nHasWaiyi then
    nState = self.STATE_HAS
    pButton.pPanel:SetActive("Gray", false)
  else
    pButton.pPanel:SetActive("Gray", true)
  end
  if nTemplateId == self.nEquipTemplateId then
    nState = self.STATE_EQUIPING
    pButton.pPanel:SetActive("Equip", true)
  else
    pButton.pPanel:SetActive("Equip", false)
  end
  data[6] = nState
  pButton.pPanel:Label_SetText("TxtItemName", szName)
  pButton.pPanel:Label_SetText("TxtPrice", self.tbStateDesc[nState])
  pButton.nTemplateId = nTemplateId
  pButton.pPanel.OnTouchEvent = fnClickCallback
  pButton.pPanel:Toggle_SetChecked("Main", self.nSelectId == nTemplateId)
  pButton.Item:SetItemByTemplate(nTemplateId, nil, self.nFixFaction)
end
function tbUi:RefreshList()
  function self.fnOnSelect(btn)
    local data = self.tbWaiyiList[btn.nTemplateId]
    if not data then
      return
    end
    local nTemplateId, szName, nPart, nHasWaiyi, nChangeId, nState = unpack(data)
    local nRes = Item.tbChangeColor:GetWaiZhuanRes(nTemplateId, self.nFixFaction)
    local tbSetting = Item.tbChangeColor.tbColorItem[nTemplateId]
    self.nSelectId = nTemplateId
    if nPart == Npc.NpcResPartsDef.npc_part_horse then
      self:ChangeHorse(self.nSelectId)
    else
      self:ChangeFeature(nPart, nRes)
    end
    if nState == self.STATE_CHANGEABLE then
      self.pPanel:SetActive("BtnColour", true)
      self.pPanel:Button_SetText("BtnColour", "染色")
      self.pPanel:SetActive("Consume", true)
      local nCount = me.GetItemCountInAllPos(Item.tbChangeColor.CONSUME_ITEM)
      self.pPanel:Label_SetText("Consume", string.format("消耗：外装染色剂 %d/%d", nCount, tbSetting.nCost))
      self.fnCallback = self.DoChangeColor
    elseif nState == self.STATE_EQUIPING then
      self.pPanel:SetActive("BtnColour", true)
      self.pPanel:SetActive("Consume", false)
      self.pPanel:Button_SetText("BtnColour", "卸下")
      self.fnCallback = self.DoUnEquip
      self.varParam = KItem.GetEquipPos(nTemplateId)
    elseif nState == self.STATE_HAS then
      self.pPanel:SetActive("BtnColour", true)
      self.pPanel:SetActive("Consume", false)
      self.pPanel:Button_SetText("BtnColour", "装备")
      self.fnCallback = self.DoEquip
    else
      self.pPanel:SetActive("Consume", false)
      self.pPanel:SetActive("BtnColour", false)
      self.fnCallback = nil
    end
  end
  function self.fnOnBannerClick(btn)
    self.tbClosePage[btn.szGroupName] = not self.tbClosePage[btn.szGroupName]
    self:Update()
  end
  local function fnSetItem(itemObj, index)
    local varData = self.tbDataList[index]
    local szSubDesc = self.tbNameSubDesc[index]
    if type(varData) == "table" then
      itemObj.pPanel:SetActive("BtnName", false)
      for i = 1, 2 do
        local nTemplateId = varData[i]
        local tbData = self.tbWaiyiList[nTemplateId]
        if tbData then
          itemObj.pPanel:SetActive("item" .. i, true)
          self:SetEquipInfo(itemObj["item" .. i], nTemplateId, self.fnOnSelect)
        else
          itemObj.pPanel:SetActive("item" .. i, false)
        end
      end
    elseif type(varData) == "string" then
      itemObj.pPanel:SetActive("BtnName", true)
      if szSubDesc then
        itemObj.BtnName.pPanel:Label_SetText("Name", string.format("%s(%s)", varData, szSubDesc))
      else
        itemObj.BtnName.pPanel:Label_SetText("Name", varData)
      end
      itemObj.BtnName.pPanel.OnTouchEvent = self.fnOnBannerClick
      itemObj.BtnName.szGroupName = varData
      itemObj.pPanel:SetActive("item1", false)
      itemObj.pPanel:SetActive("item2", false)
      if self.tbClosePage[varData] then
        itemObj.BtnName.pPanel:Sprite_SetSprite("Mark", "ListMarkNormal")
      else
        itemObj.BtnName.pPanel:Sprite_SetSprite("Mark", "ListMarkPress")
      end
    end
  end
  self.ColourListScrollView:UpdateItemHeight(self.tbHeight)
  self.ColourListScrollView:Update(self.tbDataList, fnSetItem)
  if self.nSelectId then
    self.fnOnSelect({
      nTemplateId = self.nSelectId
    })
  else
    if self.nWaiyiPos == Item.EQUIPPOS_WAI_HORSE then
      self:ChangeHorse()
    else
      self:ChangeFeature()
    end
    self.pPanel:SetActive("BtnColour", false)
    self.pPanel:SetActive("Consume", false)
  end
end
function tbUi:DoChangeColor()
  local nChangeId = Item.tbChangeColor:GetChangeId(self.nSelectId)
  if not self.tbChangeId or not self.tbChangeId[nChangeId] then
    me.CenterMsg("您没有这件外装的其他颜色，不能染色")
    return
  end
  local fnAgree = function(nItemId, nTargetId)
    RemoteServer.DoChangeEquipColor(nItemId, nTargetId)
  end
  local nItemId = self.tbChangeId[nChangeId][1]
  if nItemId then
    local tbSetting = Item.tbChangeColor.tbColorItem[self.nSelectId]
    local tbBaseProp = KItem.GetItemBaseProp(Item.tbChangeColor.CONSUME_ITEM)
    local szName = KItem.GetItemShowInfo(self.nSelectId, self.nFixFaction)
    Ui:OpenWindow("MessageBox", string.format("你确定要染成[fffe0d]%s[-]吗？\n需要消耗%d个%s", szName, tbSetting.nCost, tbBaseProp.szName), {
      {
        fnAgree,
        nItemId,
        self.nSelectId
      },
      {}
    }, {"同意", "取消"})
  end
end
function tbUi:DoEquip()
  local nChangeId = Item.tbChangeColor:GetChangeId(self.nSelectId)
  for _, nId in ipairs(self.tbChangeId[nChangeId]) do
    local pItem = me.GetItemInBag(nId)
    if pItem and pItem.dwTemplateId == self.nSelectId then
      RemoteServer.UseEquip(pItem.dwId)
      return
    end
  end
end
function tbUi:DoUnEquip(nPos)
  RemoteServer.UnuseEquip(nPos)
end
function tbUi:ChangeFeature(nChangePart, nWaiZhuanRes)
  if nChangePart then
    self.tbPart[nChangePart] = nWaiZhuanRes
  end
  local tbNpcRes, tbEffectRes
  if self.nFixFaction == me.nFaction then
    tbNpcRes, tbEffectRes = me.GetNpcResInfo()
  else
    local tbFactionInfo = KPlayer.GetPlayerInitInfo(self.nFixFaction)
    tbNpcRes, tbEffectRes = {}, {}
    tbNpcRes[0] = tbFactionInfo.nBodyResId
    tbNpcRes[1] = tbFactionInfo.nWeaponResId
    for i = 0, Npc.NpcResPartsDef.npc_res_part_count - 1 do
      tbNpcRes[i] = tbNpcRes[i] or 0
      tbEffectRes[i] = 0
    end
  end
  local tbFactionScale = {
    0.92,
    1,
    1.15,
    1
  }
  local fScale = tbFactionScale[self.nFixFaction] or 1
  self.pPanel:SetActive("ShowRole", true)
  for nPartId, nResId in pairs(tbNpcRes) do
    local nCurResId = nResId
    if nPartId == Npc.NpcResPartsDef.npc_part_horse then
      nCurResId = 0
    elseif self.tbPart[nPartId] then
      nCurResId = self.tbPart[nPartId]
    end
    self.pPanel:NpcView_ChangePartRes("ShowRole", nPartId, nCurResId)
  end
  self.pPanel:NpcView_SetScale("ShowRole", fScale)
  if self.bLoadRoleRes then
    self:PlayRoleAnimation()
  end
end
function tbUi:ChangeHorse(dwTemplateId)
  local nNpcRes
  if dwTemplateId then
    nNpcRes = Item:GetHorseShoNpc(dwTemplateId)
  end
  if not nNpcRes then
    local pHorse = me.GetEquipByPos(Item.EQUIPPOS_WAI_HORSE) or me.GetEquipByPos(Item.EQUIPPOS_HORSE)
    if pHorse then
      nNpcRes = Item:GetHorseShoNpc(pHorse.dwTemplateId)
    end
  end
  if nNpcRes then
    self.pPanel:SetActive("ShowRole", true)
    self.pPanel:NpcView_ShowNpc("ShowRole", nNpcRes)
    self.pPanel:NpcView_ChangePartRes("ShowRole", Npc.NpcResPartsDef.npc_part_weapon, 0)
    self.pPanel:NpcView_SetScale("ShowRole", 0.8)
  else
    self.pPanel:SetActive("ShowRole", false)
  end
end
function tbUi:OnClose()
  self.pPanel:NpcView_Close("ShowRole")
  self:CloseRoleAniTimer()
  if self.nTimer then
    Timer:Close(self.nTimer)
    self.nTimer = nil
  end
end
function tbUi:OnSyncItem(nItemId)
  self:Update()
end
function tbUi:PlayStandAnimaion()
  self.nPlayStTimer = nil
  if self.nWaiyiPos ~= Item.EQUIPPOS_WAI_HORSE then
    self.pPanel:NpcView_PlayAnimation("ShowRole", "st", 0.1, true)
  else
    self.pPanel:NpcView_PlayAnimation("ShowRole", "hst", 0, true)
  end
end
function tbUi:PlayNextRoleAnimation(szAni)
  self.nPlayNextTimer = nil
  if self.nWaiyiPos ~= Item.EQUIPPOS_WAI_HORSE then
    self.pPanel:NpcView_PlayAnimation("ShowRole", szAni, 0, false)
    if self.nPlayStTimer then
      Timer:Close(self.nPlayStTimer)
      self.nPlayStTimer = nil
    end
    self.nPlayStTimer = Timer:Register(2, self.PlayStandAnimaion, self)
    self.nPlayNextTimer = nil
    self:PlayRoleAnimation()
  end
end
function tbUi:PlayRoleAnimation()
  local tbSkillIniSet = FightSkill.tbSkillIniSet
  local nTotalID = #tbSkillIniSet.tbActStandID
  if nTotalID <= 0 then
    return 0
  end
  local nFrame = tbSkillIniSet.nActStandMinFrame
  local nMaxFrame = tbSkillIniSet.nActStandMaxFrame - tbSkillIniSet.nActStandMinFrame
  if nMaxFrame > 0 then
    nFrame = MathRandom(nMaxFrame) + tbSkillIniSet.nActStandMinFrame
  end
  local nAniIndex = MathRandom(nTotalID)
  local nActId = tbSkillIniSet.tbActStandID[nAniIndex]
  local tbActionInfo = Npc:GetNpcActionInfo(nActId)
  if self.nPlayNextTimer then
    Timer:Close(self.nPlayNextTimer)
    self.nPlayNextTimer = nil
  end
  if not tbActionInfo then
    return
  end
  local pNpc = me.GetNpc()
  if not pNpc then
    return
  end
  local nActFrame = pNpc.GetActionFrame(nActId)
  if nActFrame <= 2 then
    nActFrame = 70
  end
  self.nPlayNextTimer = Timer:Register(nFrame + nActFrame, self.PlayNextRoleAnimation, self, tbActionInfo.ActName)
end
function tbUi:CloseRoleAniTimer()
  if self.nPlayStTimer then
    Timer:Close(self.nPlayStTimer)
    self.nPlayStTimer = nil
  end
  if self.nPlayNextTimer then
    Timer:Close(self.nPlayNextTimer)
    self.nPlayNextTimer = nil
  end
end
function tbUi:OnLoadResFinish()
  if self.nWaiyiPos == Item.EQUIPPOS_WAI_HORSE then
    self.pPanel:NpcView_PlayAnimation("ShowRole", "hst", 0, true)
  else
    self:PlayRoleAnimation()
    self.bLoadRoleRes = true
  end
end
function tbUi:RegisterEvent()
  local tbRegEvent = {
    {
      UiNotify.emNOTIFY_SYNC_ITEM,
      self.OnSyncItem
    },
    {
      UiNotify.emNOTIFY_LOAD_RES_FINISH,
      self.OnLoadResFinish,
      self
    }
  }
  return tbRegEvent
end
