local tbItemBox = Ui:CreateClass("ItemBox")
local RepresentSetting = luanet.import_type("RepresentSetting")
local tbToggle = {
  TogNoCount = 0,
  TogNormal = 1,
  TogEquip = 2,
  TogPartnerEquip = 3,
  TogAll = 4
}
local ITEM_PER_LINE = 4
local MIN_LINE = 5
local ITEM_TYPE = {
  [Item.PARTNER] = tbToggle.TogPartnerEquip,
  [Item.EQUIP_WAIYI] = tbToggle.TogNoCount,
  [Item.EQUIP_WAI_WEAPON] = tbToggle.TogNoCount,
  [Item.EQUIP_WAI_HORSE] = tbToggle.TogNoCount
}
local ITEM_CLASS_TYPE = {
  Stone = {
    tbToggle.TogEquip
  },
  equip = {
    tbToggle.TogEquip,
    tbToggle.TogNormal
  },
  horse = {
    tbToggle.TogEquip,
    tbToggle.TogNormal
  },
  horse_equip = {
    tbToggle.TogEquip,
    tbToggle.TogNormal
  },
  ZhenYuan = {
    tbToggle.TogEquip,
    tbToggle.TogNormal
  },
  Unidentify = {
    tbToggle.TogEquip,
    tbToggle.TogNormal
  },
  ComposeMeterial = "CheckCoposeable",
  EquipMeterial = "CheckCoposeable",
  MysteryStone = {
    tbToggle.TogEquip
  },
  TaskItem = {},
  EmptyItemClass = {},
  QuickBuyFromMS = {}
}
local ITEM_CLASS_SORT = {
  XiuLianZhu = 1,
  BeautyPageantPaper = 2,
  BeautyPageantVote = 3,
  EmptyXinDeBook = 5,
  XinDeBook = 6,
  WeddingWelcome = 8,
  MarriagePaper = 9,
  UnidentifyScriptItem = 10
}
local ITEM_CLASS_SORT_FUN = {
  EquipMeterial = function(dwTemplateId)
    local nRet = Compose.EntityCompose:GetBagSort(dwTemplateId)
    return nRet
  end
}
local _SORT_KEY = {
  Item.EQUIP_EX,
  Item.EQUIP_WEAPON,
  Item.EQUIP_ARMOR,
  Item.EQUIP_RING,
  Item.EQUIP_NECKLACE,
  Item.EQUIP_AMULET,
  Item.EQUIP_BOOTS,
  Item.EQUIP_BELT,
  Item.EQUIP_HELM,
  Item.EQUIP_CUFF,
  Item.EQUIP_PENDANT,
  Item.EQUIP_ZHEN_YUAN,
  Item.ITEM_SCRIPT,
  Item.PARTNER
}
local SORT_KEY = {}
for nIdx, nType in ipairs(_SORT_KEY) do
  SORT_KEY[nType] = nIdx + 100
end
local tbChangeTabPanel = {
  BtnRole = "PlayerDetail",
  BtnAttribute = "AttributeDetail"
}
tbItemBox.tbOnClick = {
  BtnRole = function(self)
    self:ChangeTabPanel("BtnRole")
  end,
  BtnAttribute = function(self)
    self:ChangeTabPanel("BtnAttribute")
  end,
  BtnClose = function(self)
    Ui:CloseWindow(self.UI_NAME)
  end,
  TogNormal = function(self, szName)
    self:UpdateItemList(tbToggle.TogNormal)
    self:SelectPageShow(szName)
  end,
  TogEquip = function(self, szName)
    self:UpdateItemList(tbToggle.TogEquip)
    self:SelectPageShow(szName)
  end,
  TogPartnerEquip = function(self, szName)
    self:UpdateItemList(tbToggle.TogPartnerEquip)
    self:SelectPageShow(szName)
  end,
  TogAll = function(self, szName)
    self:UpdateItemList(tbToggle.TogAll)
    self:SelectPageShow(szName)
  end,
  BtnEnhanceAttrib = function(self)
    Ui:OpenWindow("EquipStarAttribTips", "Enhance")
  end,
  BtnInsetAttrib = function(self)
    Ui:OpenWindow("EquipStarAttribTips", "Inset")
  end,
  Btndetail = function(self)
    Ui:OpenWindow("RoleAttrib")
  end,
  BtnChange = function(self)
    Ui:OpenWindow("TitleChangePanel")
  end,
  BtnFashion = function(self)
    Ui:OpenWindow("WaiyiPreview")
  end,
  Mounts = function(self)
    if GetTimeFrameState("OpenLevel89") == 1 then
      Ui:OpenWindow("HorsePanel")
    end
  end,
  Meridian = function(self)
    local tbLearnInfo, bHasPartnerInPos = JingMai:GetLearnedXueWeiInfo(me)
    local tbAddInfo = JingMai:GetXueWeiAddInfo(tbLearnInfo)
    Ui:OpenWindow("JingMaiTipsPanel", tbAddInfo.tbExtAttrib, tbAddInfo.tbSkill, bHasPartnerInPos, true)
  end
}
tbItemBox.tbOnDrag = {
  ShowRole = function(self, szWnd, nX, nY)
    self.pPanel:NpcView_ChangeDir("ShowRole", -nX, true)
  end
}
function tbItemBox:OnOpen(szPage, dwHightlightItem, szHighlightAni, szHighlightAniAtlas)
  self.dwHightlightItem = dwHightlightItem
  self.szHighlightAni = szHighlightAni or "item1_"
  self.szHighlightAniAtlas = szHighlightAni or "UI/Atlas/ItemGrid/ItemGrid.prefab"
  self.pPanel:SetActive("texiaotiaozhan1", false)
  self.pPanel:SetActive("texiaotiaozhan2", false)
  self.pPanel:SetActive("texiao_TW", false)
  self.pPanel:SetActive("BtnEnhanceAttrib", me.nLevel >= 15)
  self.pPanel:SetActive("BtnInsetAttrib", me.nLevel >= 27)
  local bJingMaiOpen = JingMai:CheckOpen(me)
  self.pPanel:SetActive("Meridian", bJingMaiOpen)
  self.szPage = szPage or "TogNormal"
  self:CloseRoleAniTimer()
  self:ChangeTabPanel(self.szCurTagPanel or "BtnRole", true)
  self:UpdateItemType()
  self:UpdateItemList(tbToggle[self.szPage])
  self:UpdateEquip()
  self:ChangePlayerExp()
  self:UpdateTitleInfo()
  self:CheckCanUpgrade()
end
function tbItemBox:OnOpenEnd()
  self.pPanel:Toggle_SetChecked(self.szPage, true)
  self:SelectPageShow("TogNormal")
  self:ShowExAttribLevel()
end
function tbItemBox:ChangeTabPanel(szCurBtn, bFirst)
  if not bFirst and self.szCurTagPanel == "BtnRole" then
    self.pPanel:NpcView_Close("ShowRole")
  end
  self.szCurTagPanel = szCurBtn
  for szBtn, szPanel in pairs(tbChangeTabPanel) do
    if szBtn ~= szCurBtn then
      self.pPanel:SetActive(szPanel, false)
    else
      self.pPanel:SetActive(szPanel, true)
    end
  end
  if self.szCurTagPanel == "BtnRole" then
    self.pPanel:NpcView_Open("ShowRole")
    self:ChangeFeature()
  elseif self.szCurTagPanel == "BtnAttribute" then
    self.AttributeDetail:OnOpen()
  end
end
function tbItemBox:CheckCanUpgrade()
  local tbEquip = me.GetEquips()
  local tbStrengthen = me.GetStrengthen()
  for i = 0, Item.EQUIPPOS_MAIN_NUM - 1 do
    local bCanUpgrade = false
    local nItemId = tbEquip[i]
    local nStrenLevel
    if nItemId then
      bCanUpgrade = Strengthen:CanEquipUpgrade(nItemId)
      nStrenLevel = 0 < tbStrengthen[i + 1] and tbStrengthen[i + 1] or nil
    end
    self.pPanel:SetActive("UpgradeFlag" .. i, bCanUpgrade)
    self.pPanel:Label_SetText("StrengthenLevel" .. i, nStrenLevel and "+" .. nStrenLevel or "")
  end
  local bCanUpgrade = Item.GoldEquip:IsShowHorseUpgradeRed(me)
  self.pPanel:SetActive("UpgradeFlag10", bCanUpgrade)
end
function tbItemBox:ShowExAttribLevel()
  local bChange = false
  local tbLastShowExAttribLevel = Client:GetUserInfo("LastShowExAttribLevel")
  if me.nEnhExIdx then
    local tbSetting = Strengthen:GetEnhExAttrib(me.nEnhExIdx)
    self.pPanel:Label_SetText("EnhAttribInfo", tostring(me.nEnhExIdx))
    self.pPanel:Button_SetSprite("BtnEnhanceAttrib", tbSetting.Img)
    if Ui.UiManager.GetTopPanelName() == self.UI_NAME and tbSetting.EnhLevel ~= tbLastShowExAttribLevel.EnhLevel then
      bChange = true
      tbLastShowExAttribLevel.EnhLevel = tbSetting.EnhLevel
      self.pPanel:SetActive("texiao_TW", true)
      self.pPanel:PlayUiAnimation("Role&Bagpannle_qianghua", false, false, {
        "self.pPanel:SetActive('texiaotiaozhan1', true)",
        "self:ShowLabelScale('EnhAttribInfo')"
      })
    end
  else
    self.pPanel:Label_SetText("EnhAttribInfo", "0")
  end
  if me.nInsetExIdx then
    local tbSetting = StoneMgr:GetInsetExAttrib(me.nInsetExIdx)
    self.pPanel:Label_SetText("InsetAttribInfo", tostring(me.nInsetExIdx))
    self.pPanel:Button_SetSprite("BtnInsetAttrib", tbSetting.Img)
    if Ui.UiManager.GetTopPanelName() == self.UI_NAME and tbSetting.StoneLevel ~= tbLastShowExAttribLevel.StoneLevel then
      bChange = true
      tbLastShowExAttribLevel.StoneLevel = tbSetting.StoneLevel
      self.pPanel:SetActive("texiao_TW", true)
      self.pPanel:PlayUiAnimation("Role&Bagpannle_qianghua", false, false, {
        "self.pPanel:SetActive('texiaotiaozhan2', true)",
        "self:ShowLabelScale('InsetAttribInfo')"
      })
    end
  else
    self.pPanel:Label_SetText("InsetAttribInfo", "0")
  end
  if bChange then
    Client:SaveUserInfo()
  end
end
function tbItemBox:ShowLabelScale(szAttribInfo)
  Timer:Register(1, function(...)
    self[szAttribInfo].pPanel:PlayUiAnimation("EnhanceLabelScale", false, false, {})
  end)
  self.pPanel:SetActive("texiao_TW", false)
  self.pPanel:SetActive("texiaotiaozhan1", false)
  self.pPanel:SetActive("texiaotiaozhan2", false)
end
function tbItemBox:SelectPageShow(szBtnName)
end
function tbItemBox:UpdateTitleInfo()
  PlayerTitle:SetTitleLabel(self, "Title")
end
function tbItemBox:OnClose()
  if self.szCurTagPanel == "BtnRole" then
    self.pPanel:NpcView_Close("ShowRole")
  elseif self.szCurTagPanel == "BtnMounts" then
    self.pPanel:NpcView_Close("HorseView")
  end
  self:CloseRoleAniTimer()
end
function tbItemBox:ChangePlayerExp()
end
function tbItemBox:UpdateEquip()
  local tbEquip = me.GetEquips(1)
  self.tbShowEquip = {}
  for i = 0, Item.EQUIPPOS_MAIN_NUM - 1 do
    local tbEquipGrid = self["Equip" .. i]
    tbEquipGrid.nEquipPos = i
    tbEquipGrid.szItemOpt = "PlayerEquip"
    tbEquipGrid.fnClick = tbEquipGrid.DefaultClick
    if i == Item.EQUIPPOS_RING and tbEquip[i] then
      local pItem = KItem.GetItemObj(tbEquip[i])
      if pItem and pItem.GetStrValue(1) then
        tbEquipGrid.szFragmentSprite = "MarriedMark"
        tbEquipGrid.szFragmentAtlas = "UI/Atlas/NewAtlas/Panel/NewPanel.prefab"
      else
        tbEquipGrid.szFragmentSprite = nil
        tbEquipGrid.szFragmentAtlas = nil
      end
    end
    tbEquipGrid:SetItem(tbEquip[i])
    if tbEquip[i] and tbEquip[i] > 0 then
      self.tbShowEquip[tbEquip[i]] = true
    end
  end
  local tbEqiptHorse = self["Equip" .. Item.EQUIPPOS_HORSE]
  if tbEquip[Item.EQUIPPOS_HORSE] then
    tbEqiptHorse.nEquipPos = Item.EQUIPPOS_HORSE
    tbEqiptHorse.szItemOpt = "PlayerEquip"
    if GetTimeFrameState("OpenLevel89") == 1 then
      function tbEqiptHorse.fnClick()
        Ui:OpenWindow("HorsePanel")
      end
    else
      tbEqiptHorse.fnClick = tbEqiptHorse.DefaultClick
    end
    tbEqiptHorse:SetItem(tbEquip[Item.EQUIPPOS_HORSE])
    tbEqiptHorse.pPanel:SetActive("Main", true)
  else
    tbEqiptHorse.pPanel:SetActive("Main", false)
  end
  if GetTimeFrameState(Item.tbZhenYuan.szOpenTimeFrame) == 1 then
    self.pPanel:SetActive("Vitality", true)
    local tbEquipZhenYuan = self["Equip" .. Item.EQUIPPOS_ZHEN_YUAN]
    if tbEquip[Item.EQUIPPOS_ZHEN_YUAN] then
      tbEquipZhenYuan.nEquipPos = Item.EQUIPPOS_ZHEN_YUAN
      tbEquipZhenYuan.szItemOpt = "PlayerEquip"
      tbEquipZhenYuan:SetItem(tbEquip[Item.EQUIPPOS_ZHEN_YUAN])
      tbEquipZhenYuan.fnClick = tbEquipZhenYuan.DefaultClick
      tbEquipZhenYuan.pPanel:SetActive("Main", true)
    else
      tbEquipZhenYuan.pPanel:SetActive("Main", false)
    end
  else
    self.pPanel:SetActive("Vitality", false)
  end
end
function tbItemBox:UpdateItemType()
  self.tbItemLists = {}
  for _, nType in pairs(tbToggle) do
    self.tbItemLists[nType] = {}
  end
  local nCount = 0
  local tbItem = me.GetItemListInBag()
  for nIdx, pItem in ipairs(tbItem) do
    local nType = ITEM_TYPE[pItem.nItemType]
    local szClass = pItem.szClass
    local tbType = ITEM_CLASS_TYPE[szClass]
    local nSort = ITEM_CLASS_SORT[szClass]
    local nSortParam = ITEM_CLASS_SORT_FUN[szClass] and ITEM_CLASS_SORT_FUN[szClass](pItem.dwTemplateId) or 0
    local tbData = {
      nKey1 = nSort or SORT_KEY[pItem.nItemType] or 1000,
      nKey2 = pItem.nDetailType * 10000 + nSortParam,
      nKey3 = pItem.GetSingleValue(),
      nItemId = pItem.dwId,
      dwTemplateId = pItem.dwTemplateId
    }
    if nType ~= tbToggle.TogNoCount then
      table.insert(self.tbItemLists[tbToggle.TogAll], tbData)
      nCount = nCount + 1
    end
    if type(tbType) == "table" then
      for _, i in ipairs(tbType) do
        table.insert(self.tbItemLists[i], tbData)
      end
    elseif type(tbType) == "string" and self[tbType] then
      local fnFunction = self[tbType]
      local tbTypeByCheck = fnFunction(self, pItem)
      for _, i in ipairs(tbTypeByCheck or {}) do
        if self.tbItemLists[i] then
          table.insert(self.tbItemLists[i], tbData)
        end
      end
    elseif nType and self.tbItemLists[nType] then
      table.insert(self.tbItemLists[nType], tbData)
    else
      table.insert(self.tbItemLists[tbToggle.TogNormal], tbData)
    end
  end
  self.pPanel:Label_SetText("LabItemCount", string.format("%d / %d", nCount, GameSetting.MAX_COUNT_IN_BAG + Item:GetExtBagCount(me)))
end
function tbItemBox:UpdateItemList(nType)
  self.nShowType = nType or self.nShowType
  if self.tbItemLists[self.nShowType] then
    self.tbItemList = self.tbItemLists[self.nShowType]
  end
  local fnSort = function(tbA, tbB)
    if tbA.nKey1 == tbB.nKey1 then
      if tbA.nKey2 == tbB.nKey2 then
        if tbA.nKey3 == tbB.nKey3 then
          return tbA.nItemId < tbB.nItemId
        end
        return tbA.nKey3 > tbB.nKey3
      end
      return tbA.nKey2 < tbB.nKey2
    end
    return tbA.nKey1 < tbB.nKey1
  end
  table.sort(self.tbItemList, fnSort)
  self.tbShowItem = {}
  local function fnSetItem(tbItemGrid, index)
    local nStart = (index - 1) * ITEM_PER_LINE
    for i = 1, ITEM_PER_LINE do
      local tbItem = self.tbItemList[nStart + i]
      local nItemId = tbItem and tbItem.nItemId
      local tbGridParams = {bShowTip = true}
      local szHighlightAni, szHighlightAniAtlas
      if self.dwHightlightItem and self.dwHightlightItem == (tbItem and tbItem.dwTemplateId) then
        szHighlightAni = self.szHighlightAni
        szHighlightAniAtlas = self.szHighlightAniAtlas
      end
      tbItemGrid:SetItem(i, nItemId, nil, "ItemBox", tbGridParams, szHighlightAni, szHighlightAniAtlas)
      if nItemId then
        self.tbShowItem[nItemId] = tbItemGrid:GetGrid(i)
      end
    end
  end
  self.ScrollView:Update(math.max(math.ceil(#self.tbItemList / ITEM_PER_LINE), MIN_LINE), fnSetItem)
end
function tbItemBox:CheckCoposeable(pItem)
  local tbBag = {}
  if Compose.EntityCompose:CheckIsCanCompose(me, pItem.dwTemplateId) then
    table.insert(tbBag, tbToggle.TogNormal)
  end
  if pItem.szClass == "EquipMeterial" then
    table.insert(tbBag, tbToggle.TogEquip)
  end
  return tbBag
end
function tbItemBox:OnSyncItem(nItemId, bUpdateAll)
  if self.bStopUpdateAtOnce then
    return
  end
  if bUpdateAll == 1 then
    self:UpdateItemType()
    self:UpdateItemList()
    self:UpdateEquip()
  else
    if self.tbShowItem[nItemId] and self.tbShowItem[nItemId].nItemId == nItemId then
      self.tbShowItem[nItemId]:SetItem(nItemId, {bShowTip = true})
    end
    if self.tbShowEquip[nItemId] then
      self:UpdateEquip()
    end
  end
  self:CheckCanUpgrade()
end
function tbItemBox:OnDelItem(nItemId)
  self:UpdateItemType()
  self:UpdateItemList()
  self:UpdateEquip()
end
function tbItemBox:UpdateBaseAttrib()
end
function tbItemBox:ChangeFeature()
  local tbNpcRes, tbEffectRes = me.GetNpcResInfo()
  local nNpcResID, nBodyResId = me.GetNpc().GetFeature()
  local tbFactionScale = {
    0.92,
    1,
    1.15,
    1,
    1,
    1,
    0.92,
    1,
    1,
    1,
    1,
    1.15
  }
  local fScale = tbFactionScale[me.nFaction] or 1
  if nBodyResId and nBodyResId > 0 then
    for nPartId, nResId in pairs(tbNpcRes) do
      local nCurResId = nResId
      if nPartId == Npc.NpcResPartsDef.npc_part_horse then
        nCurResId = 0
      end
      self.pPanel:NpcView_ChangePartRes("ShowRole", nPartId, nCurResId)
    end
    for nPartId, nResId in pairs(tbEffectRes) do
      self.pPanel:NpcView_ChangePartEffect("ShowRole", nPartId, nResId)
    end
  else
    for nPartId, nResId in pairs(tbNpcRes) do
      self.pPanel:NpcView_ChangePartRes("ShowRole", nPartId, 0)
    end
    for nPartId, nResId in pairs(tbEffectRes) do
      self.pPanel:NpcView_ChangePartEffect("ShowRole", nPartId, 0)
    end
    self.pPanel:NpcView_ShowNpc("ShowRole", nNpcResID)
  end
  self.pPanel:NpcView_SetScale("ShowRole", fScale)
  if self.bLoadRoleRes then
    self:PlayRoleAnimation()
  end
end
function tbItemBox:OnSyncItemsBegin()
  self.bStopUpdateAtOnce = true
  if not self.nStopUpdateTimer then
    self.nStopUpdateTimer = Timer:Register(Env.GAME_FPS * 1, self.OnStopUpdateTimer, self)
  end
end
function tbItemBox:OnSyncItemsEnd()
  self.bStopUpdateAtOnce = false
  if self.nStopUpdateTimer then
    Timer:Close(self.nStopUpdateTimer)
    self.nStopUpdateTimer = nil
  end
  self:OnSyncItem(0, 1)
end
function tbItemBox:OnStopUpdateTimer()
  self.bStopUpdateAtOnce = false
  self.nStopUpdateTimer = nil
  self:OnSyncItem(0, 1)
end
function tbItemBox:AutoClose()
  Ui:CloseWindow(self.UI_NAME)
end
function tbItemBox:OnWindowCloese(szWndName)
  if szWndName ~= self.UI_NAME and szWndName ~= "EquipTips" and szWndName ~= "BgBlackAll" and self.szCurTagPanel == "BtnRole" and self.bLoadRoleRes then
    self.pPanel:NpcView_PlayAnimation("ShowRole", "st", 0.1, true)
  end
  if Ui.UiManager.GetTopPanelName() ~= self.UI_NAME then
    return
  end
  self:ShowExAttribLevel()
end
function tbItemBox:PlayStandAnimaion()
  self.nPlayStTimer = nil
  self.pPanel:NpcView_PlayAnimation("ShowRole", "st", 0.1, true)
end
function tbItemBox:PlayNextRoleAnimation(szAni)
  self.pPanel:NpcView_PlayAnimation("ShowRole", szAni, 0, false)
  if self.nPlayStTimer then
    Timer:Close(self.nPlayStTimer)
    self.nPlayStTimer = nil
  end
  self.nPlayStTimer = Timer:Register(2, self.PlayStandAnimaion, self)
  self.nPlayNextTimer = nil
  self:PlayRoleAnimation()
end
function tbItemBox:PlayRoleAnimation()
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
function tbItemBox:CloseRoleAniTimer()
  if self.nPlayStTimer then
    Timer:Close(self.nPlayStTimer)
    self.nPlayStTimer = nil
  end
  if self.nPlayNextTimer then
    Timer:Close(self.nPlayNextTimer)
    self.nPlayNextTimer = nil
  end
end
function tbItemBox:OnLoadResFinish()
  if self.szCurTagPanel == "BtnMounts" then
    self.pPanel:NpcView_ChangeDir("HorseView", 220, false)
  elseif self.szCurTagPanel == "BtnRole" then
    self:PlayRoleAnimation()
    self.bLoadRoleRes = true
  end
end
function tbItemBox:OnSyncData(szType)
  if szType == "PlayerAttribute" and self.szCurTagPanel == "BtnAttribute" then
    self.AttributeDetail:SetData()
  end
end
function tbItemBox:RegisterEvent()
  local tbRegEvent = {
    {
      UiNotify.emNOTIFY_SYNC_ITEM,
      self.OnSyncItem
    },
    {
      UiNotify.emNOTIFY_DEL_ITEM,
      self.OnDelItem
    },
    {
      UiNotify.emNOTIFY_CHANGE_PLAYER_EXP,
      self.ChangePlayerExp
    },
    {
      UiNotify.emNOTIFY_CHANGE_FEATURE,
      self.ChangeFeature
    },
    {
      UiNotify.emNOTIFY_UPDATE_TITLE,
      self.UpdateTitleInfo
    },
    {
      UiNotify.emNOTIFY_STRENGTHEN_RESULT,
      self.CheckCanUpgrade
    },
    {
      UiNotify.emNOTIFY_INSET_RESULT,
      self.CheckCanUpgrade
    },
    {
      UiNotify.emNOTYFY_SYNC_ITEMS_BEGIN,
      self.OnSyncItemsBegin
    },
    {
      UiNotify.emNOTIFY_SYNC_DATA,
      self.OnSyncData
    },
    {
      UiNotify.emNOTIFY_LOAD_RES_FINISH,
      self.OnLoadResFinish,
      self
    },
    {
      UiNotify.emNOTYFY_SYNC_ITEMS_END,
      self.OnSyncItemsEnd
    },
    {
      UiNotify.emNOTIFY_SHOW_DIALOG,
      self.AutoClose
    },
    {
      UiNotify.emNOTIFY_WND_CLOSED,
      self.OnWindowCloese
    }
  }
  return tbRegEvent
end
