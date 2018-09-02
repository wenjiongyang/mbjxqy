Item.GoldGrade = {
  [1] = 30,
  [2] = 100,
  [3] = 300,
  [4] = 1000,
  [5] = 3000,
  [6] = 10000,
  [7] = 10000
}
Item.CoinGrade = {
  [1] = 3000,
  [2] = 10000,
  [3] = 30000,
  [4] = 100000,
  [5] = 300000,
  [6] = 1000000,
  [7] = 1000000
}
Item.coinGrade = Item.CoinGrade
Item.ExpGrade = {
  [1] = 300,
  [2] = 1000,
  [3] = 3000,
  [4] = 10000,
  [5] = 30000,
  [6] = 100000,
  [7] = 100000
}
Item.JadeGrade = {
  [1] = 300,
  [2] = 1000,
  [3] = 3000,
  [4] = 10000,
  [5] = 30000,
  [6] = 100000,
  [7] = 100000
}
Item.TongBaoGrade = {
  [1] = 300,
  [2] = 1000,
  [3] = 3000,
  [4] = 10000,
  [5] = 30000,
  [6] = 100000,
  [7] = 100000
}
Item.PartnerGrade = {
  [1] = 10000,
  [2] = 50000,
  [3] = 300000,
  [4] = 900000,
  [5] = 2000000,
  [6] = 6000000,
  [7] = 16000000
}
Item.PStone0Grade = {
  [1] = 6,
  [2] = 20,
  [3] = 60,
  [4] = 200,
  [5] = 600,
  [6] = 2000,
  [7] = 2000
}
Item.PStone1Grade = {
  [1] = 6,
  [2] = 20,
  [3] = 60,
  [4] = 200,
  [5] = 600,
  [6] = 2000,
  [7] = 2000
}
Item.PStone2Grade = {
  [1] = 6,
  [2] = 20,
  [3] = 60,
  [4] = 200,
  [5] = 600,
  [6] = 2000,
  [7] = 2000
}
Item.PStone3Grade = {
  [1] = 6,
  [2] = 20,
  [3] = 60,
  [4] = 200,
  [5] = 600,
  [6] = 2000,
  [7] = 2000
}
Item.HonorGrade = {
  [1] = 300,
  [2] = 1000,
  [3] = 3000,
  [4] = 10000,
  [5] = 30000,
  [6] = 100000,
  [7] = 100000
}
Item.BiographyGrade = {
  [1] = 300,
  [2] = 1000,
  [3] = 3000,
  [4] = 10000,
  [5] = 30000,
  [6] = 100000,
  [7] = 100000
}
function Item:GetDigitalItemQuality(szType, nValue)
  local nQuality = 1
  local tbGrade = Item[szType .. "Grade"]
  if not tbGrade then
    return nQuality
  end
  for i, v in ipairs(tbGrade) do
    if nValue < v then
      nQuality = i
      break
    end
    if i == 7 and not grade then
      nQuality = 7
    end
  end
  return nQuality
end
function Item:LoadSkillItemSetting()
  self.tbSkillItem = {}
  local tbSkillItem = LoadTabFile("Setting/Item/Other/SkillItem.tab", "dddssss", nil, {
    "SkillId",
    "SkillLevel",
    "Quality",
    "Icon",
    "IconAtlas",
    "Desc",
    "Name"
  })
  for k, v in pairs(tbSkillItem) do
    self.tbSkillItem[v.SkillId] = self.tbSkillItem[v.SkillId] or {}
    self.tbSkillItem[v.SkillId][v.SkillLevel] = {
      v.Name,
      v.Icon,
      v.IconAtlas,
      v.Desc,
      v.Quality
    }
  end
  self.tbHorseShowNpc = LoadTabFile("Setting/Item/HorseShowNpc.tab", "dd", "ItemID", {"ItemID", "NpcResID"})
end
Item:LoadSkillItemSetting()
function Item:GetSkillItemSetting(nSkillId, nSkillLevel)
  if self.tbSkillItem[nSkillId] and self.tbSkillItem[nSkillId][nSkillLevel] then
    return self.tbSkillItem[nSkillId][nSkillLevel]
  end
end
function Item:GetHorseShoNpc(nItemID)
  local tbInfo = self.tbHorseShowNpc[nItemID]
  if not tbInfo then
    return 0
  end
  return tbInfo.NpcResID
end
function Item:GetItemTargetType(nTemplateId)
  local tbBaseInfo = KItem.GetItemBaseProp(nTemplateId)
  if tbBaseInfo.szClass == "Unidentify" then
    nTemplateId = KItem.GetItemExtParam(nTemplateId, 1)
    tbBaseInfo = KItem.GetItemBaseProp(nTemplateId)
  end
  return tbBaseInfo.nItemType
end
function Item:GetItemPosShowInfo(nTemplateId)
  local nType = self:GetItemTargetType(nTemplateId)
  local nPos = Item.EQUIPTYPE_POS[nType]
  return Item.EQUIPPOS_NAME[nPos], nPos
end
Item.tbItemFunc = {
  NeedChooseItem = function(tbPos, nItemTemplateId, nItemId)
    Item:GetClass("NeedChooseItem"):TryOpenUi(tbPos.x, tbPos.y, nItemTemplateId, nItemId)
  end,
  SkillBook = function(tbPos, nItemTemplateId, nItemId, tbInfo)
    local pCurEquip
    if nItemId then
      local pItem = KItem.GetItemObj(nItemId)
      if pItem and tbInfo.pAsyncRole and not me.GetItemInBag(nItemId) then
        if tbInfo.pAsyncRole.GetFaction() == me.nFaction then
          local tbBook = Item:GetClass("SkillBook")
          local nLowestTypeId = tbBook:GetLowestBookId(pItem.dwTemplateId)
          for nIndex, nNeedLevel in ipairs(tbBook.tbSkillBookHoleLevel) do
            local pEquip = me.GetEquipByPos(nIndex + Item.EQUIPPOS_SKILL_BOOK - 1)
            if pEquip then
              local nMyLowestTypeId = tbBook:GetLowestBookId(pEquip.dwTemplateId)
              if nMyLowestTypeId == nLowestTypeId then
                pCurEquip = pEquip
                break
              end
            end
          end
        elseif tbInfo.nPosIndex then
          pCurEquip = me.GetEquipByPos(tbInfo.nPosIndex)
        end
      end
    end
    if not pCurEquip then
      local szItemOpt
      if nItemId and not me.GetItemInBag(nItemId) then
        szItemOpt = "ViewEquip"
      end
      Ui:OpenWindowAtPos("SkillCheatsPanel", tbPos.x, tbPos.y, nItemId, nItemTemplateId, tbInfo.tbRandomAtrrib or {}, szItemOpt)
    else
      Ui:OpenWindowAtPos("SkillCheatsPanel", 133, 15, nItemId, nItemTemplateId, tbInfo.tbRandomAtrrib or {}, "ViewEquip")
      Ui:OpenWindowAtPos("SkillCheatsComparePanel", -269, 15, pCurEquip.dwId, pCurEquip.dwTemplateId, tbInfo.tbRandomAtrrib or {}, "ViewEquip")
    end
  end,
  Stone = function(tbPos, nItemTemplateId, nItemId)
    if StoneMgr:IsStone(nItemTemplateId) then
      Ui:OpenWindowAtPos("StoneTipsPanel", 0, 0, nItemId, nItemTemplateId)
    else
      Ui:OpenWindowAtPos("ItemTips", tbPos.x, tbPos.y, "Item", nItemId, nItemTemplateId)
    end
  end,
  waiyi = function(tbPos, nItemTemplateId, nItemId, tbInfo)
    Ui:OpenWindowAtPos("ItemTips", tbPos.x, tbPos.y, "Item", nItemId, nItemTemplateId, tbInfo.nFaction)
  end,
  CollectionItem = function(tbPos, nItemTemplateId, nItemId, tbInfo)
    Ui:OpenWindowAtPos("CardCollection", tbPos.x, tbPos.y, nItemTemplateId, nItemId, tbInfo.tbRandomAtrrib or {})
  end,
  JuanZhou = function(tbPos, nItemTemplateId, nItemId, tbInfo)
    Ui:OpenWindowAtPos("JuanZhouPanel", tbPos.x, tbPos.y, nItemTemplateId, nItemId)
  end,
  PlayerPortraitItem_NoSex = function(tbPos, nItemTemplateId, nItemId)
    Ui:OpenWindowAtPos("PortraitItemPreviewPanel", tbPos.x, tbPos.y, nItemTemplateId, nItemId)
  end
}
function Item:ShowItemDetail(tbInfo, tbPos)
  local tbShowPos = tbPos or {x = -1, y = -1}
  if tbInfo.nItemId and tbInfo.nItemId ~= 0 then
    local pItem = KItem.GetItemObj(tbInfo.nItemId)
    if Item.tbItemFunc[pItem.szClass] then
      Item.tbItemFunc[pItem.szClass](tbShowPos, pItem.dwTemplateId, tbInfo.nItemId, tbInfo)
    elseif pItem and pItem.IsEquip() == 1 then
      local pCurEquip = me.GetEquipByPos(pItem.nEquipPos)
      if pCurEquip and pCurEquip.dwId ~= tbInfo.nItemId then
        Ui:OpenWindowAtPos("EquipTips", 133, 234, tbInfo.nItemId, nil, tbInfo.nFaction, tbInfo.szItemOpt, nil, tbInfo.pAsyncRole or 1)
        local szItemOpt
        if not me.GetItemInBag(tbInfo.nItemId) then
          szItemOpt = "ViewOtherEquip"
        end
        Ui:OpenWindowAtPos("CompareTips", -315, 234, pCurEquip.dwId, nil, nil, szItemOpt)
      else
        if not tbPos then
          tbShowPos = {x = -84, y = 234}
        end
        Ui:OpenWindowAtPos("EquipTips", tbShowPos.x, tbShowPos.y, tbInfo.nItemId, nil, tbInfo.nFaction or me.nFaction, tbInfo.szItemOpt, nil, tbInfo.pAsyncRole or 1)
      end
    else
      Ui:OpenWindowAtPos("ItemTips", tbShowPos.x, tbShowPos.y, "Item", tbInfo.nItemId, tbInfo.nTemplate)
    end
  elseif tbInfo.nTemplate and tbInfo.nTemplate ~= 0 then
    local tbBaseInfo = KItem.GetItemBaseProp(tbInfo.nTemplate)
    local nEquipPos = KItem.GetEquipPos(tbInfo.nTemplate)
    if Item.tbItemFunc[tbBaseInfo.szClass] then
      Item.tbItemFunc[tbBaseInfo.szClass](tbShowPos, tbInfo.nTemplate, nil, tbInfo)
    elseif nEquipPos then
      local pCurEquip = me.GetEquipByPos(nEquipPos)
      if pCurEquip and not tbInfo.tbRandomAtrrib then
        local tbMySavedRandomAttrib
        if tbBaseInfo.nDetailType == Item.DetailType_Gold then
          tbMySavedRandomAttrib = Item.tbRefinement:GetSaveRandomAttrib(pCurEquip)
        end
        Ui:OpenWindowAtPos("EquipTips", 133, 234, false, tbInfo.nTemplate, tbInfo.nFaction, tbInfo.szItemOpt, tbMySavedRandomAttrib)
        Ui:OpenWindowAtPos("CompareTips", -315, 234, pCurEquip.dwId)
      else
        if not tbPos then
          tbShowPos = {x = -84, y = 234}
        end
        Ui:OpenWindowAtPos("EquipTips", tbShowPos.x, tbShowPos.y, false, tbInfo.nTemplate, tbInfo.nFaction, tbInfo.szItemOpt, tbInfo.tbRandomAtrrib)
      end
    else
      Ui:OpenWindowAtPos("ItemTips", tbShowPos.x, tbShowPos.y, "Item", nil, tbInfo.nTemplate, tbInfo.nFaction or me.nFaction)
    end
  elseif tbInfo.szDigitalType then
    Ui:OpenWindowAtPos("ItemTips", tbShowPos.x, tbShowPos.y, "Digit", tbInfo.szDigitalType, tbInfo.nCount)
  elseif tbInfo.nSkillId then
    Ui:OpenWindowAtPos("ItemTips", tbShowPos.x, tbShowPos.y, "Skill", tbInfo.nSkillId, tbInfo.nSkillLevel)
  elseif tbInfo.nPartnerId then
    Ui:OpenWindowAtPos("PartnerDetail", tbShowPos.x, tbShowPos.y, nil, nil, nil, tbInfo.nPartnerId)
  elseif tbInfo.nSeqId then
    Ui:OpenWindowAtPos("ItemTips", tbShowPos.x, tbShowPos.y, "ComposeValue", tbInfo.nSeqId)
  elseif tbInfo.nTitleId then
    Ui:OpenWindowAtPos("ItemTips", tbShowPos.x, tbShowPos.y, "AddTimeTitle", tbInfo.nTitleId)
  end
end
function Item:ShowStoneCompareTips(nItemTemplateId, nItemId)
  if StoneMgr:IsStone(nItemTemplateId) then
    local tbPosType = StoneMgr:GetCanInsetPos(nItemTemplateId)
    local nPos = Item.EQUIPTYPE_POS[tbPosType[1]]
    local pCurEquip = me.GetEquipByPos(nPos)
    if pCurEquip then
      Ui:OpenWindowAtPos("CompareTips", -315, 234, pCurEquip.dwId, nil, nil, szItemOpt)
      Ui:OpenWindowAtPos("StoneTipsPanel", 170, 0, nItemId, nItemTemplateId)
    else
      Ui:OpenWindowAtPos("StoneTipsPanel", 0, 0, nItemId, nItemTemplateId)
    end
  else
    Ui:OpenWindowAtPos("ItemTips", 0, 0, "Item", nItemId, nItemTemplateId)
  end
end
