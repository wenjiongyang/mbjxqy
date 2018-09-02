local uiTips = Ui:CreateClass("EquipTips")
function uiTips:OnOpen(nItemId, nTemplateId)
  if not nTemplateId and not nItemId then
    return 0
  end
end
function uiTips:OnOpenEnd(nItemId, nTemplateId, nFaction, szOpt, tbSaveRandomAttrib, pAsyncData)
  local bIsCompare = self.UI_NAME == "CompareTips"
  if type(pAsyncData) ~= "userdata" and type(pAsyncData) ~= "table" then
    pAsyncData = nil
  end
  local pItem, nValue, szName, nIcon, nView, nQuality, nMaxAttribQuality
  self.fnBtnClick = {}
  if nItemId then
    pItem = KItem.GetItemObj(nItemId)
    if not pItem then
      return
    end
    nTemplateId = pItem and pItem.dwTemplateId or nTemplateId
    szName, nIcon, nView = pItem.GetItemShowInfo(nFaction)
    nQuality = pItem.nQuality
  else
    szName, nIcon, nView, nQuality = KItem.GetItemShowInfo(nTemplateId, nFaction)
  end
  self.nItemId = nItemId
  self.nTemplateId = nTemplateId
  local tbInfo = KItem.GetItemBaseProp(nTemplateId)
  if not tbInfo then
    return
  end
  if Item.EQUIPTYPE_NAME[tbInfo.nItemType] then
    self.pPanel:Label_SetText("TxtEquipType", Item.EQUIPTYPE_NAME[tbInfo.nItemType])
  end
  local nPrice, szMoneyType = Shop:GetSellSumPrice(me, nTemplateId, pItem and pItem.nCount or 1)
  self.nPrice = nPrice
  self.szMoneyType = szMoneyType
  if szMoneyType and nPrice then
    self.pPanel:SetActive("SalePrice", true)
    self.pPanel:Label_SetText("TxtCoin", nPrice)
    local szMoneyIcon, szMoneyIconAtlas = Shop:GetMoneyIcon(szMoneyType)
    self.pPanel:Sprite_SetSprite("Ylicon", szMoneyIcon, szMoneyIconAtlas)
  else
    self.pPanel:SetActive("SalePrice", false)
  end
  local nStrenghLevel
  if szOpt == "PlayerEquip" or szOpt == "ViewOtherEquip" or pAsyncData then
    nStrenghLevel = Strengthen:GetStrengthenLevel(pAsyncData or me, pItem.nEquipPos)
  end
  if nStrenghLevel then
    self.pPanel:Label_SetText("TxtEnhLevel", "+" .. nStrenghLevel)
    self.pPanel:SetActive("TxtEnhLevel", true)
  else
    self.pPanel:SetActive("TxtEnhLevel", false)
  end
  if nView and nView ~= 0 then
    local szIconAtlas, szIconSprite = Item:GetIcon(nView)
    self.pPanel:SetActive("ItemLayer", true)
    self.pPanel:Sprite_SetSprite("ItemLayer", szIconSprite, szIconAtlas)
  else
    self.pPanel:SetActive("ItemLayer", false)
  end
  self.pPanel:Label_SetText("TxtLevelLimit", string.format("%d级", tbInfo.nRequireLevel))
  self.pPanel:Label_SetText("TxtIntro", tbInfo.szIntro)
  self.pPanel:Label_SetText("Rank", string.format("%d阶", tbInfo.nLevel))
  local szClassName = tbInfo.szClass
  local tbClass = Item.tbClass[szClassName]
  tbClass = tbClass or self.tbClass.default
  local bEquiped = false
  local tbAttrib
  if pItem then
    local pPlayer = pAsyncData or me
    local bNotShowAll = bIsCompare
    if szOpt == "ViewOtherEquip" then
      bNotShowAll = false
    end
    local pCurEquip = me.GetEquipByPos(pItem.nEquipPos)
    if pCurEquip and pCurEquip.dwId == nItemId then
      bEquiped = true
    end
    tbAttrib, nMaxAttribQuality = tbClass:GetTip(pItem, pPlayer, bNotShowAll)
    nValue = pItem.nValue
    local tbEquips = pPlayer.GetEquips()
    local nFightPower = pItem.nFightPower
    if tbEquips[pItem.nEquipPos] and tbEquips[pItem.nEquipPos] == nItemId and not bNotShowAll then
      nFightPower = nFightPower + Strengthen:GetStrenFightPower(pPlayer, pItem.nEquipPos) + StoneMgr:GetInsetFightPower(pPlayer, pItem.nEquipPos)
    end
    self.pPanel:Label_SetText("TxtFightPower", "战力：" .. tostring(nFightPower))
    local nShowQuality = Item:GetEqipShowColor(pItem, bEquiped or pPlayer == pAsyncData, pPlayer)
    if nShowQuality then
      nQuality = nShowQuality
    end
  else
    tbSaveRandomAttrib = tbSaveRandomAttrib or Item.tbRefinement:GetCustomAttri(nTemplateId)
    tbAttrib, nMaxAttribQuality = tbClass:GetTipByTemplate(nTemplateId, tbSaveRandomAttrib)
    nValue = tbInfo.nValue
    local nFightPower = KItem.GetEquipBaseFightPower(nTemplateId)
    local bHasRandomAttrib = false
    for _, v in pairs(tbSaveRandomAttrib or {}) do
      if v ~= 0 then
        bHasRandomAttrib = true
        break
      end
    end
    if bHasRandomAttrib then
      nFightPower = nFightPower + Item.tbRefinement:GetFightPowerFromSaveAttri(tbInfo.nLevel, tbSaveRandomAttrib, tbInfo.nItemType)
    end
    self.pPanel:Label_SetText("TxtFightPower", "战力：" .. nFightPower)
  end
  self:SetTips(tbAttrib or {})
  self.pPanel:SetActive("Equipped", bEquiped)
  local szColor, szFrameColor, szAnimation, szAnimationAtlas = Item:GetQualityColor(nMaxAttribQuality or 0)
  self.pPanel:Sprite_SetSprite("Color", szFrameColor)
  if szAnimation and szAnimation ~= "" and szAnimationAtlas ~= "" then
    self.pPanel:Sprite_Animation("LightAnimation", szAnimation, szAnimationAtlas)
    local nEffect = Item:GetQualityEffect(nQuality)
    if nEffect ~= 0 then
      self.pPanel:ShowEffect("LightAnimation", nEffect, 1)
    end
  else
    self.pPanel:SetActive("LightAnimation", false)
  end
  if szName then
    self.pPanel:Label_SetText("TxtTitle", szName)
    local szNameColor = Item:GetQualityColor(nMaxAttribQuality) or "White"
    self.pPanel:Label_SetColorByName("TxtTitle", szNameColor)
  end
  local nStarLevel = Item:GetStarLevel(tbInfo.nItemType, nValue)
  local nBrightStar = math.ceil(nStarLevel / 2)
  for i = 1, 10 do
    if i <= nBrightStar then
      self.pPanel:SetActive("SprStar" .. i, true)
      if nBrightStar == i and nStarLevel % 2 == 1 then
        self.pPanel:Sprite_SetSprite("SprStar" .. i, "Star_02")
      else
        self.pPanel:Sprite_SetSprite("SprStar" .. i, "Star_01")
      end
    else
      self.pPanel:SetActive("SprStar" .. i, false)
    end
  end
  if pItem and me.GetItemInBag(nItemId) and szOpt and self.Option[szOpt] then
    self.pPanel:SetActive("BtnGroup", true)
    local nIndex = 1
    for _, tbButton in ipairs(self.Option[szOpt]) do
      local fnVisible, szBtnName, fnCallback, fnSowRedPoint = unpack(tbButton)
      if fnVisible == true or fnVisible(self) then
        local szButton = "Btn" .. nIndex
        self.pPanel:Button_SetText(szButton, szBtnName)
        self.pPanel:SetActive(szButton, true)
        self.fnBtnClick[szButton] = fnCallback
        local bShowRed = fnSowRedPoint and fnSowRedPoint(self)
        self.pPanel:SetActive("BtnNew" .. nIndex, bShowRed)
        nIndex = nIndex + 1
      end
    end
    for i = nIndex, 4 do
      local szButton = "Btn" .. i
      self.pPanel:SetActive(szButton, false)
      self.fnBtnClick[szButton] = nil
    end
  else
    self.pPanel:SetActive("BtnGroup", false)
  end
  Ui:OpenWindow("BgBlackAll", 0.7, Ui.LAYER_NORMAL)
end
function uiTips:SetTips(tbAttribs)
  local tbHeight = {}
  local function fnSetItem(itemObj, nIndex)
    local tbDesc = tbAttribs[nIndex]
    local nHeight = itemObj:SetText(tbDesc, self)
    tbHeight[nIndex] = nHeight
    self.ScrollView:UpdateItemHeight(tbHeight)
  end
  self.ScrollView:Update(#tbAttribs, fnSetItem)
  self.ScrollView:UpdateItemHeight(tbHeight)
  self.ScrollView:GoTop()
  self:CheckShowDown()
end
function uiTips:CheckShowDown()
  self.pPanel:SetActive("down", not self.ScrollView.pPanel:ScrollViewIsBottom())
end
function uiTips:UseEquip()
  if not self.nItemId then
    return
  end
  local bRet = Player:UseEquip(self.nItemId)
  if not bRet then
    return
  end
  Ui:CloseWindow(self.UI_NAME)
end
function uiTips:UnuseEquip()
  if not self.nItemId then
    return
  end
  local pItem = KItem.GetItemObj(self.nItemId)
  if not pItem then
    return
  end
  RemoteServer.UnuseEquip(pItem.nEquipPos)
  Ui:CloseWindow(self.UI_NAME)
end
function uiTips:Refinement()
  if not self.nItemId then
    return
  end
  local pItem = KItem.GetItemObj(self.nItemId)
  if not pItem then
    return
  end
  local pCurEquip = me.GetEquipByPos(pItem.nEquipPos)
  if pCurEquip then
    Ui:OpenWindow("RefinementPanel", self.nItemId, pCurEquip.dwId)
    Ui:CloseWindow(self.UI_NAME)
  end
end
function uiTips:Enhance()
  if not self.nItemId then
    return
  end
  local pItem = KItem.GetItemObj(self.nItemId)
  if not pItem then
    return
  end
  Ui:OpenWindow("StrengthenPanel", "Strengthen", self.nItemId)
  Ui:CloseWindow(self.UI_NAME)
end
function uiTips:Inset()
  if not self.nItemId then
    return
  end
  local pItem = KItem.GetItemObj(self.nItemId)
  if not pItem then
    return
  end
  Ui:OpenWindow("StrengthenPanel", "Inset", self.nItemId)
  Ui:CloseWindow(self.UI_NAME)
end
function uiTips:Sell()
  if not self.nItemId then
    return
  end
  Shop:ConfirmSell(self.nItemId)
  Ui:CloseWindow(self.UI_NAME)
end
function uiTips:Exchange(...)
  if not self.nItemId then
    return
  end
  local fnAgree = function(nItemId)
    RemoteServer.EquipExchange(nItemId)
  end
  local pItem = KItem.GetItemObj(self.nItemId)
  if not pItem then
    me.CenterMsg("装备不存在！")
    return
  end
  local bRet, szMsg = Item.tbEquipExchange:CanExchange(pItem.dwTemplateId, me)
  if not bRet then
    Ui:OpenWindow("MessageBox", szMsg, {
      {}
    }, {"确定"})
    return
  end
  local bRet, nCost = Item.tbEquipExchange:GetCost(pItem.dwTemplateId)
  if not bRet then
    return
  end
  Ui:OpenWindow("MessageBox", string.format("收藏装备会变为外装，需要[FFFE0D]消耗%d银两[-]，装备上所有[FFFE0D]属性将会消失[-]。您确定收藏此装备吗？", nCost), {
    {
      fnAgree,
      self.nItemId
    },
    {}
  }, {"同意", "取消"})
  Ui:CloseWindow(self.UI_NAME)
end
function uiTips:TrainAttrib()
  Ui:OpenWindow("RefinePanel", self.nItemId)
  Ui:CloseWindow(self.UI_NAME)
end
function uiTips:DoUpgrade()
  Ui:OpenWindow("EquipmentEvolutionPanel", "Type_Upgrade", self.nItemId)
  Ui:CloseWindow(self.UI_NAME)
end
function uiTips:DoEvolutionHorse()
  Ui:OpenWindow("EquipmentEvolutionPanel", "Type_EvolutionHorse", self.nItemId)
  Ui:CloseWindow(self.UI_NAME)
end
function uiTips:LevelUpSKill()
  Ui:OpenWindow("VitalitySkillPanel")
  Ui:CloseWindow(self.UI_NAME)
end
function uiTips:RefineSkill()
  Item.tbZhenYuan:RequestRefineSkill(self.nItemId)
end
function uiTips:CanEvolutionHorse()
  if not self.nItemId then
    return false
  end
  local pEquip = me.GetItemInBag(self.nItemId)
  if not pEquip then
    return false
  end
  if not pEquip.nEquipPos then
    return false
  end
  if not Item.tbHorseItemPos[pEquip.nEquipPos] then
    return false
  end
  if not Item.GoldEquip:CanEvolutionTarItem(pEquip.dwTemplateId) then
    return false
  end
  return true
end
function uiTips:CanUpgrade()
  if not self.nItemId then
    return false
  end
  local pEquip = me.GetItemInBag(self.nItemId)
  if not pEquip then
    return false
  end
  local dwTemplateId = pEquip.dwTemplateId
  local tbSetting = Item.GoldEquip:GetUpgradeSetting(dwTemplateId)
  if not tbSetting then
    return false
  end
  local TarItem = tbSetting.TarItem
  local tbBaseInfo = KItem.GetItemBaseProp(TarItem)
  if me.nLevel < tbBaseInfo.nRequireLevel then
    return false
  end
  return true
end
function uiTips:CanTrainAtrri()
  if not self.nItemId then
    return false
  end
  local pEquip = me.GetItemInBag(self.nItemId)
  if not pEquip or pEquip.GetBaseIntValue(Item.EQUIP_VALUE_TRAIN_ATTRI_LEVEL) == 0 then
    return false
  end
  if self:CanUpgrade() then
    return false
  end
  return true
end
function uiTips:CanUseEquip()
  if not self.nItemId then
    return false
  end
  return true
end
function uiTips:CanEnhance()
  if not self.nItemId then
    return false
  end
  return true
end
function uiTips:CanRefinement()
  local bCanRefinement = false
  if self.nItemId then
    local pItem = KItem.GetItemObj(self.nItemId)
    if pItem and pItem.IsEquip() == 1 then
      local pCurEquip = me.GetEquipByPos(pItem.nEquipPos)
      if pCurEquip then
        local bRef = Item.tbRefinement:CanRefinement(pCurEquip, pItem, true)
        bCanRefinement = bRef
      end
    end
  end
  return bCanRefinement
end
function uiTips:CanSell()
  if self.nItemId and self.szMoneyType and self.nPrice then
    return true
  end
  return false
end
function uiTips:CanRefineSkill()
  return Item.tbZhenYuan:CanRefineSkill(me, self.nItemId)
end
function uiTips:CanInset()
  if me.nLevel < StoneMgr.MinInsetRoleLevel then
    return false
  end
  local pItem = KItem.GetItemObj(self.nItemId)
  if not pItem then
    return false
  end
  if pItem.nHoleCount and pItem.nHoleCount <= 0 then
    return false
  end
  return true
end
function uiTips:CanStrengthen()
  if me.nLevel < Strengthen.OPEN_LEVEL then
    return false
  end
  local pItem = KItem.GetItemObj(self.nItemId)
  if not pItem then
    return false
  end
  local nEquipPos = KItem.GetEquipPos(pItem.dwTemplateId)
  if nEquipPos < 0 or nEquipPos >= Item.EQUIPPOS_MAIN_NUM then
    return false
  end
  return true
end
function uiTips:CanUnuseEquip()
  if not self.nItemId then
    return
  end
  local pItem = me.GetItemInBag(self.nItemId)
  if not pItem then
    return
  end
  return true
end
function uiTips:CanExchange()
  local pItem = KItem.GetItemObj(self.nItemId)
  if not pItem then
    return false
  end
  local dwTemplateId = pItem.dwTemplateId
  return Item.tbEquipExchange:CanExchange(dwTemplateId, me)
end
function uiTips:CanLevelUpSKill()
  return Item.tbZhenYuan:CanSkillLevelUp(me, self.nItemId)
end
function uiTips:ShowEnhanceRedpoint()
  local pItem = KItem.GetItemObj(self.nItemId)
  if not pItem then
    return false
  end
  return Strengthen:CanStrengthen(me, pItem.nEquipPos, pItem.nLevel)
end
function uiTips:ShowInsetRedpoint()
  return StoneMgr:CheckInsetUpgradeFlag(self.nItemId)
end
function uiTips:ShowDoUpgradeRedpoint()
  local pItem = KItem.GetItemObj(self.nItemId)
  if not pItem then
    return false
  end
  return Item.GoldEquip:CanUpgrade(me, pItem.dwTemplateId)
end
function uiTips:ShowDoEvolutionHorseRed()
  local pItem = KItem.GetItemObj(self.nItemId)
  if not pItem then
    return false
  end
  return Item.GoldEquip:CanEvolution(me, pItem.dwTemplateId)
end
uiTips.Option = {
  ItemBox = {
    {
      uiTips.CanUseEquip,
      "穿上",
      uiTips.UseEquip
    },
    {
      uiTips.CanRefinement,
      "洗练",
      uiTips.Refinement
    },
    {
      uiTips.CanExchange,
      "收藏",
      uiTips.Exchange
    },
    {
      uiTips.CanEvolutionHorse,
      "升阶",
      uiTips.DoEvolutionHorse,
      uiTips.ShowDoEvolutionHorseRed
    },
    {
      uiTips.CanSell,
      "出售",
      uiTips.Sell
    },
    {
      uiTips.CanRefineSkill,
      "技能洗练",
      uiTips.RefineSkill
    }
  },
  PlayerEquip = {
    {
      uiTips.CanUnuseEquip,
      "卸下",
      uiTips.UnuseEquip
    },
    {
      uiTips.CanStrengthen,
      "强化",
      uiTips.Enhance,
      uiTips.ShowEnhanceRedpoint
    },
    {
      uiTips.CanInset,
      "镶嵌",
      uiTips.Inset,
      uiTips.ShowInsetRedpoint
    },
    {
      uiTips.CanTrainAtrri,
      "精炼",
      uiTips.TrainAttrib
    },
    {
      uiTips.CanUpgrade,
      "升阶",
      uiTips.DoUpgrade,
      uiTips.ShowDoUpgradeRedpoint
    },
    {
      uiTips.CanEvolutionHorse,
      "升阶",
      uiTips.DoEvolutionHorse,
      uiTips.ShowDoEvolutionHorseRed
    },
    {
      uiTips.CanLevelUpSKill,
      "技能升级",
      uiTips.LevelUpSKill
    }
  }
}
function uiTips:OnButtonClick(szWnd)
  if self.fnBtnClick[szWnd] then
    self.fnBtnClick[szWnd](self)
  end
end
function uiTips:OnScreenClick(szClickUi)
  if szClickUi ~= "CompareTips" and szClickUi ~= "EquipTips" then
    Ui:CloseWindow(self.UI_NAME)
  end
end
function uiTips:OnTipsClose(szWnd)
  if szWnd == "CompareTips" or szWnd == "EquipTips" or szWnd == "StoneTipsPanel" then
    Ui:CloseWindow(self.UI_NAME)
  end
end
function uiTips:OnClose()
  if Ui:WindowVisible("CompareTips") == 1 and Ui:WindowVisible("EquipTips") == 1 then
    return
  end
  Ui:CloseWindow("BgBlackAll")
end
function uiTips:OnResponseSell(bSuccess)
  if bSuccess then
    Ui:CloseWindow(self.UI_NAME)
  end
end
uiTips.tbOnClick = {
  Btn1 = uiTips.OnButtonClick,
  Btn2 = uiTips.OnButtonClick,
  Btn3 = uiTips.OnButtonClick,
  Btn4 = uiTips.OnButtonClick
}
function uiTips:RegisterEvent()
  local tbRegEvent = {
    {
      UiNotify.emNOTIFY_WND_CLOSED,
      self.OnTipsClose
    },
    {
      UiNotify.emNOTIFY_SHOP_SELL_RESULT,
      self.OnResponseSell
    }
  }
  return tbRegEvent
end
local tbEquipAttribItem = Ui:CreateClass("EquipAttribItem")
function tbEquipAttribItem:SetText(tbDesc, pParent)
  self.pParent = pParent
  local szText, nColor, szIcon, szAtlas, szText2, szStoneName, szEquipFrameColor, szExtAtlas, szExtSprite = unpack(tbDesc)
  local nStyle
  if type(szText) == "table" then
    nStyle = 3
  elseif not nColor then
    nStyle = 1
    if Lib:Utf8Len(szText) > 20 then
      nStyle = 4
    end
  elseif szIcon then
    nStyle = 2
    if type(nColor) == "string" then
      nStyle = 5
    end
  else
    nStyle = 3
  end
  local nHeight = 26
  self.pPanel:SetActive("line1", true)
  self.pPanel:SetActive("line2", false)
  self.pPanel:SetActive("line3", false)
  self.pPanel:SetActive("line4", false)
  self.pPanel:ChangePosition("Text", 2, 0)
  if nStyle == 1 then
    self.pPanel:SetActive("TxtClass", true)
    self.pPanel:Label_SetText("TxtClass", szText)
    self.pPanel:SetActive("Text", false)
    self.pPanel:Label_SetGradientColor("Text", "Blue")
    self.pPanel:SetActive("icon", false)
  elseif nStyle == 2 then
    local szColor, szFrameColor = Item:GetQualityColor(nColor)
    szFrameColor = szEquipFrameColor or szFrameColor
    if szText2 and szStoneName then
      self.pPanel:SetActive("line1", false)
      self.pPanel:SetActive("line2", true)
      if szText ~= "" then
        szText = szStoneName .. "\n" .. szText
      else
        szText = szStoneName
      end
      if szText2 ~= "" then
        szText = szText .. "\n" .. szText2
      end
      self.pPanel:Label_SetText("Text2", szText)
      self.pPanel:Label_SetColorByName("Text2", szColor or "White")
      self.pPanel:Sprite_SetSprite("Color", szFrameColor)
      self.pPanel:Sprite_SetSprite("ItemLayer", szIcon, szAtlas)
      if szExtAtlas and szExtAtlas ~= "" and szExtSprite and szExtSprite ~= "" then
        self.pPanel:Sprite_SetSprite("ItemLayer2", szExtSprite, szExtAtlas)
        self.pPanel:SetActive("ItemLayer2", true)
      else
        self.pPanel:SetActive("ItemLayer2", false)
      end
      nHeight = 74
    else
      self.pPanel:Label_SetText("Text", szText)
      self.pPanel:SetActive("Text", true)
      self.pPanel:SetActive("TextExt", false)
      self.pPanel:SetActive("TxtClass", false)
      self.pPanel:ChangePosition("Text", 34, 0)
      self.pPanel:Label_SetColorByName("Text", szColor or "White")
      self.pPanel:SetActive("icon", true)
      self.pPanel:Sprite_SetSprite("icon", szIcon, szAtlas)
    end
  elseif nStyle == 4 then
    self.pPanel:SetActive("line1", false)
    self.pPanel:SetActive("line3", true)
    self.pPanel:Label_SetText("Text3", szText)
    local tbTextSize = self.pPanel:Label_GetPrintSize("Text3")
    nHeight = tbTextSize.y
  elseif nStyle == 5 then
    self.pPanel:SetActive("line1", false)
    self.pPanel:SetActive("line4", true)
    self.pPanel:Sprite_SetSprite("SkillItem", szIcon, szAtlas)
    self.pPanel:Label_SetText("SkillName", szText)
    self.pPanel:Label_SetText("SkillLevel", nColor)
    local tbSize = self.pPanel:Widget_GetSize("SkillItem")
    nHeight = tbSize.y
  else
    if type(szText) == "table" then
      self.pPanel:SetActive("Text", true)
      self.pPanel:SetActive("TextExt", true)
      self.pPanel:Label_SetText("Text", szText[1])
      local szColor = Item:GetQualityColor(szText[2])
      self.pPanel:Label_SetColorByName("Text", szColor or "White")
      self.pPanel:Label_SetText("TextExt", szText[3])
      szColor = Item:GetQualityColor(szText[4])
      self.pPanel:Label_SetColorByName("TextExt", szColor or "White")
    else
      self.pPanel:SetActive("Text", true)
      self.pPanel:SetActive("TextExt", false)
      self.pPanel:Label_SetText("Text", szText)
      local szColor = type(nColor) == "string" and nColor or Item:GetQualityColor(nColor)
      self.pPanel:Label_SetColorByName("Text", szColor or "White")
    end
    self.pPanel:SetActive("TxtClass", false)
    self.pPanel:SetActive("icon", false)
  end
  self.pPanel:SetActive("Main", true)
  self.pPanel:Widget_SetSize("Main", 392, nHeight)
  return nHeight
end
tbEquipAttribItem.tbOnDrag = {
  Main = function(self, szWnd, nX, nY)
  end
}
tbEquipAttribItem.tbOnDragEnd = {
  Main = function(self, szWnd, nX, nY)
    self.pParent:CheckShowDown()
  end
}
