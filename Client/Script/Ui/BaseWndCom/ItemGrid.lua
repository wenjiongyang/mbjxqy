local tbGrid = Ui:CreateClass("ItemGrid")
tbGrid.ANIMA_FRAM = 6
tbGrid.nTitleDefaultIcon = 790
tbGrid.tbOnClick = {
  ItemLayer = function(self)
    if self.fnClick then
      self.fnClick(self)
    end
    if Ui.bShowDebugInfo then
      local szClass = "nil"
      local nTemplate = self.nTemplate
      if self.nItemId then
        local pItem = KItem.GetItemObj(self.nItemId)
        if pItem then
          szClass = pItem.szClass
          nTemplate = pItem.dwTemplateId
        end
      end
      local szDebugInfo = "" .. "nItemId: " .. (self.nItemId or "nil") .. "\n" .. "nTemplate: " .. (nTemplate or "nil") .. "\n" .. "szClass: " .. (szClass or "nil") .. "\n" .. "nPartnerId: " .. (self.nPartnerId or "nil") .. "\n" .. "nFragNum: " .. (self.nFragNum or "nil") .. "\n" .. "szDigitalType: " .. (self.szDigitalType or "nil") .. "\n" .. "nSkillId: " .. (self.nSkillId or "nil") .. "\n" .. "nSkillLevel: " .. (self.nSkillLevel or "nil") .. "\n" .. "nFaction: " .. (self.nFaction or "nil") .. "\n" .. "nSeqId: " .. (self.nSeqId or "nil") .. "\n" .. "nTitleId: " .. (self.nTitleId or "nil") .. "\n"
      Ui:SetDebugInfo(szDebugInfo)
    end
  end
}
tbGrid.tbOnLongPress = {
  ItemLayer = function(self)
    if self.fnLongPress then
      self.fnLongPress(self)
    end
  end
}
tbGrid.tbControls = {
  bShowTip = false,
  bShowCDLayer = false,
  bShowCount = false
}
tbGrid.tbOtherConfig = {
  Exp = {
    szIconAtlas = "UI/Atlas/Item/CurrencyIcon/CurrencyIcon.prefab",
    szIcon = "ExpBig"
  },
  FactionHonor = {
    szIconAtlas = "UI/Atlas/Item/CurrencyIcon/CurrencyIcon.prefab",
    szIcon = "HonorRongBig"
  },
  BattleHonor = {
    szIconAtlas = "UI/Atlas/Item/CurrencyIcon/CurrencyIcon.prefab",
    szIcon = "HonorZhanBig"
  },
  DomainHonor = {
    szIconAtlas = "UI/Atlas/Item/CurrencyIcon/CurrencyIcon.prefab",
    szIcon = "HonorZhanBig"
  },
  HSLJHonor = {
    szIconAtlas = "UI/Atlas/Item/CurrencyIcon/CurrencyIcon.prefab",
    szIcon = "HonorZhanBig"
  },
  DXZHonor = {
    szIconAtlas = "UI/Atlas/Item/CurrencyIcon/CurrencyIcon.prefab",
    szIcon = "HonorZhanBig"
  },
  IndifferHonor = {
    szIconAtlas = "UI/Atlas/Item/CurrencyIcon/CurrencyIcon.prefab",
    szIcon = "HonorZhanBig"
  },
  VipExp = {
    szIconAtlas = "UI/Atlas/Item/Item/Item2.prefab",
    szIcon = "ExpVIP"
  }
}
tbGrid.tbOtherConfig.BasicExp = tbGrid.tbOtherConfig.Exp
function tbGrid:SetItem(nItemId, tbControls, nFaction, szHighlightAni, szHighlightAniAtlas)
  self:ClearType()
  self.nItemId = nItemId
  self.nFaction = nFaction or me.nFaction
  self.szHighlightAni = szHighlightAni
  self.szHighlightAniAtlas = szHighlightAniAtlas
  self:DefaultControls()
  for k, v in pairs(tbControls or {}) do
    self.tbControls[k] = v
  end
  self:Update()
end
function tbGrid:SetItemByTemplate(nTemplate, nCount, nFaction, tbControls, nFragNum)
  self:ClearType()
  self.nTemplate = nTemplate
  self.nCount = nCount
  self.nFaction = nFaction or me.nFaction
  self.nFragNum = nFragNum
  self:DefaultControls()
  for k, v in pairs(tbControls or {}) do
    self.tbControls[k] = v
  end
  self:Update()
end
function tbGrid:SetSkill(nSkillId, nSkillLevel)
  self:ClearType()
  self.nSkillLevel = nSkillLevel
  self.nSkillId = nSkillId
  local tbRec = Item:GetSkillItemSetting(nSkillId, nSkillLevel)
  local _, szIcon, szIconAtlas, _, nQuality = unpack(tbRec or {})
  local szFrameColor = Item.tbQualityColor[nQuality or 1]
  self.pPanel:Sprite_SetSprite("Color", szFrameColor)
  self.pPanel:Sprite_SetSprite("ItemLayer", szIcon or "", szIconAtlas)
  self.pPanel:SetActive("Color", true)
  self.pPanel:SetActive("ItemLayer", true)
  self.pPanel:SetActive("LabelSuffix", false)
  self.pPanel:SetActive("LightAnimation", false)
  self.pPanel:SetActive("Fragment", false)
  self.pPanel:SetActive("TagNew", false)
  self.pPanel:SetActive("CDLayer", false)
  self.pPanel:SetActive("TagTip", false)
end
function tbGrid:SetDigitalItem(szType, nValue, tbControls)
  self:ClearType()
  nValue = nValue or 0
  tbControls = tbControls or {bShowCount = true}
  self.szDigitalType = szType
  self.nCount = nValue
  local nQuality = Item:GetDigitalItemQuality(szType, nValue)
  local szFrameColor = Item.tbQualityColor[nQuality]
  local szIcon, szIconAtlas
  if Shop:IsMoneyType(szType) then
    szIcon, szIconAtlas = Shop:GetMoneyBigIcon(szType)
  elseif self.tbOtherConfig[szType] then
    if szType == "BasicExp" then
      local nBaseExp = me.GetBaseAwardExp()
      nValue = me.TrueChangeExp(nValue * nBaseExp)
    elseif szType == "Exp" then
      nValue = me.TrueChangeExp(nValue)
    end
    szIcon = self.tbOtherConfig[szType].szIcon
    szIconAtlas = self.tbOtherConfig[szType].szIconAtlas
  else
    Log("[ItemGrid] SetDigitalItem Type Error", szType)
    return
  end
  self.pPanel:Sprite_SetSprite("Color", szFrameColor)
  if szIconAtlas then
    self.pPanel:Sprite_SetSprite("ItemLayer", szIcon, szIconAtlas)
  else
    self.pPanel:Sprite_SetSprite("ItemLayer", szIcon)
  end
  if nValue > 0 then
    local OHT = 100000
    local szValue = nValue >= OHT and math.floor(nValue / 10000) .. "万" or tostring(nValue)
    self.pPanel:Label_SetText("LabelSuffix", szValue)
  end
  self.pPanel:SetActive("Color", true)
  self.pPanel:SetActive("ItemLayer", true)
  self.pPanel:SetActive("LightAnimation", false)
  self.pPanel:SetActive("Fragment", false)
  self.pPanel:SetActive("TagNew", false)
  self.pPanel:SetActive("CDLayer", tbControls.bShowCDLayer)
  self.pPanel:SetActive("TagTip", false)
  self.pPanel:SetActive("LabelSuffix", tbControls.bShowCount and nValue > 0)
end
function tbGrid:SetPartner(nPartnerId)
  self:ClearType()
  self.nPartnerId = nPartnerId
  self:DefaultControls()
  for k, v in pairs(tbControls or {}) do
    self.tbControls[k] = v
  end
  self:Update()
end
function tbGrid:SetEquipDebris(nTemplateId, nIndex)
  self:SetItemByTemplate(nTemplateId, nil, nil, nil, nIndex or 0)
end
function tbGrid:SetGenericItemTemplate(nTemplate, nCount)
  self:SetItemByTemplate(nTemplate, nCount)
end
function tbGrid:SetComposeValue(nSeqId)
  self:ClearType()
  self.nSeqId = nSeqId
  self:Update()
end
function tbGrid:SetTitleItem(nTitleId)
  self:ClearType()
  self.nTitleId = nTitleId
  self:Update()
end
local tbSetGridFunc = {
  [Player.award_type_item] = tbGrid.SetGenericItemTemplate,
  [Player.award_type_partner] = tbGrid.SetPartner,
  [Player.award_type_special_partner] = tbGrid.SetPartner,
  [Player.award_type_equip_debris] = tbGrid.SetEquipDebris,
  [Player.award_type_compose_value] = tbGrid.SetComposeValue,
  [Player.award_type_add_timetitle] = tbGrid.SetTitleItem
}
function tbGrid:SetGenericItem(tbData)
  if not tbData or not next(tbData) then
    Log("ItemGrid:SetGenericItem Error, param is error")
    return
  end
  local szType = tbData[1]
  local fnSetGrid = tbSetGridFunc[Player.AwardType[szType]]
  if fnSetGrid then
    fnSetGrid(self, unpack(tbData, 2))
  else
    self:SetDigitalItem(unpack(tbData))
  end
end
function tbGrid:ClearType()
  self.nItemId = nil
  self.nTemplate = nil
  self.nPartnerId = nil
  self.nFragNum = nil
  self.szDigitalType = nil
  self.nSkillId = nil
  self.nSkillLevel = nil
  self.nFaction = nil
  self.nSeqId = nil
  self.nTitleId = nil
end
function tbGrid:Clear()
  self:ClearType()
  self:DefaultControls()
  self:Update()
end
function tbGrid:DefaultControls()
  for k, v in pairs(self.tbControls) do
    self.tbControls[k] = false
  end
end
tbGrid.tbFunTagNew = {
  ZhenYuan = function(self, pItem)
    if pItem.GetIntValue(Item.tbZhenYuan.nItemKeySKillInfo) ~= 0 then
      self.pPanel:Sprite_SetSprite("TagNew", "itemtag_skill")
      self.pPanel:SetActive("TagNew", true)
      self.pPanel:ChangePosition("TagNew", -27, -27)
    else
      self.pPanel:SetActive("TagNew", false)
    end
  end
}
function tbGrid:Update()
  local szName, nIcon, nView, szCount
  local szFrameColor = "itemframebg"
  local szAnimation, szAnimationAtlas, szColor, pItem, nQuality
  if self.nItemId then
    pItem = KItem.GetItemObj(self.nItemId)
    if pItem then
      self.nTemplate = pItem.dwTemplateId
      nQuality = pItem.nQuality
      if pItem.IsEquip() == 1 then
        local nShowQUanli = Item:GetEqipShowColor(pItem, self.szItemOpt == "PlayerEquip", self.pAsyncRole or me)
        if nShowQUanli then
          nQuality = nShowQUanli
        end
      end
      szName, nIcon, nView = pItem.GetItemShowInfo(self.nFaction)
      szColor, szFrameColor, szAnimation, szAnimationAtlas = Item:GetQualityColor(nQuality)
      if 1 < pItem.nMaxCount and 1 < pItem.nCount then
        szCount = tostring(pItem.nCount)
      end
    end
  elseif self.nTemplate then
    szName, nIcon, nView, nQuality = KItem.GetItemShowInfo(self.nTemplate, self.nFaction)
    local tbSaveRandomAttrib = Item.tbRefinement:GetCustomAttri(self.nTemplate)
    if tbSaveRandomAttrib then
      local _, nMaxAttribQuality = Item:GetClass("equip"):GetTipByTemplate(self.nTemplate, tbSaveRandomAttrib)
      if nMaxAttribQuality then
        nQuality = nMaxAttribQuality
      end
    end
    szColor, szFrameColor, szAnimation, szAnimationAtlas = Item:GetQualityColor(nQuality)
    if szName and (type(self.nCount) == "number" and 1 < self.nCount or type(self.nCount) == "string") then
      szCount = tostring(self.nCount)
    end
  elseif self.nPartnerId then
    local _, _, nNpcTemplateId = GetOnePartnerBaseInfo(self.nPartnerId)
    nIcon = KNpc.GetNpcShowInfo(nNpcTemplateId)
    local nValue = Partner:GetPartnerValueByTemplateId(self.nPartnerId)
    local nQuality = Item:GetDigitalItemQuality("Partner", nValue)
    szFrameColor = Item.tbQualityColor[nQuality] or Item.DEFAULT_COLOR
  elseif self.nSeqId then
    nIcon = Compose.ValueCompose:GetShowInfo(self.nSeqId)
    szFrameColor = Item.DEFAULT_COLOR
  elseif self.nTitleId then
    nIcon = self.nTitleDefaultIcon
    szFrameColor = Item.DEFAULT_COLOR
    local tbTitle = PlayerTitle:GetTitleTemplate(self.nTitleId)
    if tbTitle then
      szFrameColor = Item.tbQualityColor[tbTitle.Quality] or Item.DEFAULT_COLOR
      if tbTitle.Icon > 0 then
        nIcon = tbTitle.Icon
      end
    end
  end
  if self.nTemplate then
    self.nFragNum = Compose.EntityCompose.tbShowFragTemplates[self.nTemplate]
  end
  if self.nFragNum then
    local szAtlas = "UI/Atlas/NewAtlas/Panel/NewPanel.prefab"
    local szSprite = "itemfragmnet"
    self.pPanel:Sprite_SetSprite("Fragment", szSprite, szAtlas)
    self.pPanel:SetActive("Fragment", true)
  else
    self.pPanel:SetActive("Fragment", false)
  end
  szAnimation = self.szHighlightAni or szAnimation
  szAnimationAtlas = self.szHighlightAniAtlas or szAnimationAtlas
  self.pPanel:Sprite_SetSprite("Color", szFrameColor)
  if szAnimation and szAnimation ~= "" and szAnimationAtlas ~= "" then
    self.pPanel:Sprite_Animation("LightAnimation", szAnimation, szAnimationAtlas, self.ANIMA_FRAM)
    self.pPanel:HideEffect("LightAnimation")
    if pItem and self.szItemOpt == "PlayerEquip" then
      local nEffect = Item:GetQualityEffect(nQuality)
      if nEffect ~= 0 then
        self.pPanel:ShowEffect("LightAnimation", nEffect, 1)
      end
    end
  else
    self.pPanel:SetActive("LightAnimation", false)
    self.pPanel:Sprite_SetEnable("LightAnimation", false)
  end
  if nIcon then
    local szIconAtlas, szIconSprite
    if self.nPartnerId then
      szIconAtlas, szIconSprite = Npc:GetFace(nIcon)
    else
      local szExtAtlas, szExtSprite
      szIconAtlas, szIconSprite, szExtAtlas, szExtSprite = Item:GetIcon(nIcon)
      if not self.nFragNum and szExtAtlas and szExtAtlas ~= "" and szExtSprite and szExtSprite ~= "" then
        self.pPanel:Sprite_SetSprite("Fragment", szExtSprite, szExtAtlas)
        self.pPanel:SetActive("Fragment", true)
      elseif self.szFragmentSprite then
        self.pPanel:Sprite_SetSprite("Fragment", self.szFragmentSprite, self.szFragmentAtlas)
        self.pPanel:SetActive("Fragment", true)
      end
    end
    self.pPanel:SetActive("ItemLayer", true)
    self.pPanel:Sprite_SetSprite("ItemLayer", szIconSprite, szIconAtlas)
  else
    self.pPanel:SetActive("ItemLayer", false)
  end
  if szCount then
    self.pPanel:SetActive("LabelSuffix", true)
    self.pPanel:Label_SetText("LabelSuffix", szCount)
  else
    self.pPanel:SetActive("LabelSuffix", false)
  end
  self:SetTagTip()
  if pItem and self.tbFunTagNew[pItem.szClass] then
    self.tbFunTagNew[pItem.szClass](self, pItem)
  else
    self.pPanel:SetActive("TagNew", false)
  end
  local bUseable = true
  if pItem and me.GetItemInBag(pItem.dwId) then
    bUseable = Item:CheckUsable(pItem, pItem.szClass) == 1
  end
  if not bUseable then
    self.pPanel:SetActive("CDLayer", true)
    self.pPanel:Sprite_SetSprite("CDLayer", "itemframeDisable")
  else
    self.pPanel:Sprite_SetSprite("CDLayer", "itemframeCDL")
    self.pPanel:SetActive("CDLayer", self.tbControls.bShowCDLayer)
  end
end
tbGrid.tbFunTagTip = {
  SkillBook = function(pItem)
    if pItem.nUseLevel > me.nLevel then
      return
    end
    local tbBook = Item:GetClass("SkillBook")
    local bRet = tbBook:HaveSkillBook(me, pItem.dwTemplateId)
    if bRet then
      return
    end
    local nEquipPos = tbBook:FinEmptyHole(me)
    if not nEquipPos then
      return
    end
    local bRet, szMsg = tbBook:CheckUseEquip(me, pItem, nEquipPos)
    if not bRet then
      return
    end
    local tbBookInfo = tbBook:GetBookInfo(pItem.dwTemplateId)
    if not tbBookInfo then
      return
    end
    if tbBookInfo.LimitFaction > 0 and tbBookInfo.LimitFaction ~= me.nFaction then
      return
    end
    return "itemtag_kezhuangbei"
  end
}
function tbGrid:SetTagTip()
  if not self.tbControls.bShowTip then
    self.pPanel:SetActive("TagTip", false)
    return
  end
  local szImage
  if self.nItemId then
    local pItem = KItem.GetItemObj(self.nItemId)
    if pItem and self.tbFunTagTip[pItem.szClass] then
      szImage = self.tbFunTagTip[pItem.szClass](pItem)
    elseif pItem and pItem.IsEquip() == 1 then
      local pCurEquip = me.GetEquipByPos(pItem.nEquipPos)
      if not pCurEquip then
        if pItem.nUseLevel <= me.nLevel then
          szImage = "itemtag_kezhuangbei"
        end
      elseif pCurEquip.dwId ~= self.nItemId then
        if pItem.nRealLevel > pCurEquip.nRealLevel and pItem.nUseLevel <= me.nLevel then
          szImage = "itemtag_kezhuangbei"
        elseif Item.tbRefinement:IsCanDoRefinementItemPos(pItem.nEquipPos) and Item.tbRefinement:CanRefinement(pCurEquip, pItem, false) then
          szImage = "itemtag_kexilian"
        end
      end
    elseif pItem and (pItem.szClass == "Unidentify" or pItem.szClass == "UnidentifyScriptItem" or pItem.szClass == "UnidentifyZhenYuan") then
      szImage = "itemtag_weijianding"
    elseif pItem and (pItem.szClass == "ComposeMeterial" or pItem.szClass == "EquipMeterial") then
      if Compose.EntityCompose:CheckIsCanCompose(me, pItem.dwTemplateId) then
        szImage = "itemtag_kehecheng"
      end
    elseif pItem and pItem.szClass == "JuanZhou" and Item:GetClass("JuanZhou"):CheckCanCommitInBag(pItem.dwTemplateId) then
      szImage = "itemtag_yiwancheng"
    end
  end
  if szImage then
    self.pPanel:SetActive("TagTip", true)
    self.pPanel:Sprite_SetSprite("TagTip", szImage)
  else
    self.pPanel:SetActive("TagTip", false)
  end
end
function tbGrid:DefaultClick()
  Item:ShowItemDetail(self)
end
