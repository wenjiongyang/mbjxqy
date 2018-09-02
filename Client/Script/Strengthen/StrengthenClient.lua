function Strengthen:MegerMA(tbValue1, tbValue2)
  local tbRet = {}
  for i, v in ipairs(tbValue1) do
    tbRet[i] = v + tbValue2[i]
  end
  return tbRet
end
function Strengthen:GetEquipStrengthenInfo(pPlayer, nTemplateId, nEquipPos)
  local tbAttrib = KItem.GetEquipBaseProp(nTemplateId).tbBaseAttrib
  local tbStrengthen = pPlayer.GetStrengthen()
  local nStrenLevel = tbStrengthen[nEquipPos + 1]
  local tbRet = {}
  for i, tbMA in ipairs(tbAttrib) do
    local tbCurValue = self:GetAttribValues(tbMA.szName, nStrenLevel)
    local szCurName, szCurValue = "", nil
    if tbCurValue then
      local tbValue = self:MegerMA(tbCurValue, tbMA.tbValue)
      szCurName, szCurValue = FightSkill:GetMagicDescSplit(tbMA.szName, tbValue)
    end
    local szNextName, szNextValue = "", nil
    if nStrenLevel < self.STREN_LEVEL_MAX then
      local tbNextValue = self:GetAttribValues(tbMA.szName, nStrenLevel + 1)
      local tbValue = self:MegerMA(tbNextValue, tbMA.tbValue)
      szNextName, szNextValue = FightSkill:GetMagicDescSplit(tbMA.szName, tbValue)
    end
    tbRet[i] = {
      tbCur = {szName = szCurName, szValue = szCurValue},
      tbNext = {szName = szNextName, szValue = szNextValue}
    }
  end
  return tbRet
end
function Strengthen:OnResponse(bSuccess, szInfo, nEquipPos, nNewEnhanceLevel, nCurFightPower, nOrgFightPower)
  if bSuccess and nEquipPos and nNewEnhanceLevel then
    if szInfo then
      local tbEquip = me.GetEquips()
      local nEquipId = tbEquip[nEquipPos]
      local pEquip = me.GetItemInBag(nEquipId)
      szInfo = string.format("你的%s成功强化到+%d", pEquip.szName, nNewEnhanceLevel)
    end
    me.SetStrengthen(nEquipPos, nNewEnhanceLevel)
    self:UpdateEnhAtrrib(me)
    UiNotify.OnNotify(UiNotify.emNOTIFY_CHANGE_ADD_FIGHT_POWER)
  end
  if szInfo then
    UiNotify.OnNotify(UiNotify.emNOTIFY_STRENGTHEN_RESULT, bSuccess, nCurFightPower, nOrgFightPower)
  end
end
function Strengthen:CanEquipUpgrade(nItemId)
  if not nItemId then
    return false
  end
  local pItem = KItem.GetItemObj(nItemId)
  if not pItem then
    return false
  end
  local nEquipPos = pItem.nEquipPos
  if StoneMgr:CheckInsetUpgradeFlag(nItemId) then
    return true
  end
  local bRet = Strengthen:CanStrengthen(me, nEquipPos, pItem.nLevel)
  if bRet then
    return true
  end
  return Item.GoldEquip:CanUpgrade(me, pItem.dwTemplateId)
end
