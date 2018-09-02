PlayerAttribute.tbDef = PlayerAttribute.tbDef or {}
local tbDef = PlayerAttribute.tbDef
tbDef.nSaveGroupID = 112
tbDef.nMaxSaveID = 10
tbDef.nStrengthType = 1
tbDef.nDexterityType = 2
tbDef.nVitalityType = 3
tbDef.nEnergyType = 4
tbDef.tbAttributeGroup = {
  [tbDef.nStrengthType] = {
    nSaveID = 1,
    nAttributeID = 201,
    szName = "力量"
  },
  [tbDef.nDexterityType] = {
    nSaveID = 2,
    nAttributeID = 202,
    szName = "敏捷"
  },
  [tbDef.nVitalityType] = {
    nSaveID = 3,
    nAttributeID = 203,
    szName = "体质"
  },
  [tbDef.nEnergyType] = {
    nSaveID = 4,
    nAttributeID = 204,
    szName = "灵巧"
  }
}
function PlayerAttribute:SetAutoAttributeValue(pNpc, nType, nValue)
  if nType == tbDef.nStrengthType then
    pNpc.SetAutoStrength(nValue)
  elseif nType == tbDef.nDexterityType then
    pNpc.SetAutoDexterity(nValue)
  elseif nType == tbDef.nVitalityType then
    pNpc.SetAutoVitality(nValue)
  elseif nType == tbDef.nEnergyType then
    pNpc.SetAutoEnergy(nValue)
  end
end
function PlayerAttribute:GetAttributInfo(nType)
  local tbInfo = tbDef.tbAttributeGroup[nType]
  if not tbInfo then
    return
  end
  local bRet = self:CheckSaveID(tbInfo.nSaveID)
  if not bRet then
    return
  end
  return tbInfo
end
function PlayerAttribute:CheckSaveID(nSaveID)
  if nSaveID <= 0 or nSaveID >= tbDef.nMaxSaveID then
    return false
  end
  return true
end
function PlayerAttribute:UpdateAsyncPlayerAllAttrib(pPlayerAsync, pNpc)
  for nType, tbInfo in pairs(tbDef.tbAttributeGroup) do
    local bRet = self:CheckSaveID(tbInfo.nSaveID)
    if bRet then
      local nVal = pPlayerAsync.GetPlayerAttribute(tbInfo.nSaveID)
      if nVal > 0 then
        self:SetAutoAttributeValue(pNpc, nType, nVal)
      end
    end
  end
end
