Require("CommonScript/Skill/FightSkill.lua")
Require("CommonScript/Item/XiuLian.lua")
Require("CommonScript/Shop/Shop.lua")
FightSkill.tbFightSkillSlot = FightSkill.tbFightSkillSlot or {}
function FightSkill:LoadSettingC()
  FightSkill.tbSkillStateEffect = LoadTabFile("Setting/Skill/StateEffect.tab", "dssssd", "StateEffectId", {
    "StateEffectId",
    "MagicDesc",
    "Icon",
    "IconAtlas",
    "StateName",
    "NotShowTime"
  })
  for _, tbInfo in pairs(FightSkill.tbSkillStateEffect) do
    if not Lib:IsEmptyStr(tbInfo.MagicDesc) then
      tbInfo.MagicDesc = Lib:Str2LunStr(tbInfo.MagicDesc)
    end
  end
  self.tbSkillSlotSetting = {}
  local tbFileData = Lib:LoadTabFile("Setting/Skill/SkillSlot.tab", {SkillID = 1})
  for _, tbInfo in pairs(tbFileData) do
    local tbSlotInfo = {}
    tbSlotInfo.nSkillId = tbInfo.SkillID
    tbSlotInfo.szIconAltlas = tbInfo.IconAltlas
    tbSlotInfo.szIcon = tbInfo.Icon
    tbSlotInfo.tbBtnName = {}
    for nI = 1, 5 do
      if tbInfo["BtnName" .. nI] and not Lib:IsEmptyStr(tbInfo["BtnName" .. nI]) then
        table.insert(tbSlotInfo.tbBtnName, tbInfo["BtnName" .. nI])
      end
    end
    self.tbSkillSlotSetting[tbSlotInfo.nSkillId] = tbSlotInfo
  end
end
FightSkill:LoadSettingC()
function FightSkill:GetSkillSlotByID(nSkillId)
  return self.tbSkillSlotSetting[nSkillId]
end
function FightSkill:OnAddFightSkill(nSkillId, nLevel)
  local tbSlotInfo = self:GetSkillSlotByID(nSkillId)
  if tbSlotInfo then
    Timer:Register(1, self.AddFightSkillSlot, self, nSkillId)
  end
end
function FightSkill:OnRemoveSkillState(nSkillId)
  local nCount = Lib:CountTB(self.tbFightSkillSlot)
  if nCount > 0 then
    Timer:Register(3, self.UpdateHaveSkillSlot, self)
  end
end
function FightSkill:UpdateHaveSkillSlot()
  local nCount = Lib:CountTB(self.tbFightSkillSlot)
  if nCount <= 0 then
    return
  end
  local pNpc = me.GetNpc()
  if not pNpc then
    return
  end
  local tbRemove = {}
  for nSkillId, _ in pairs(self.tbFightSkillSlot) do
    local nLevel = me.GetSkillLevel(nSkillId)
    if nLevel <= 0 then
      tbRemove[nSkillId] = 1
    end
  end
  for nSkillId, _ in pairs(tbRemove) do
    self:RemoveFightSkillSlot(nSkillId)
  end
end
function FightSkill:AddFightSkillSlot(nSkillId)
  self:UpdateHaveSkillSlot()
  local tbSlot = self:GetSkillSlotByID(nSkillId)
  if not tbSlot then
    return
  end
  local pNpc = me.GetNpc()
  if not pNpc then
    return
  end
  local nLevel = me.GetSkillLevel(nSkillId)
  if nLevel <= 0 then
    return
  end
  self.tbFightSkillSlot[nSkillId] = 1
  UiNotify.OnNotify(UiNotify.emNOTIFY_ADD_SKILL_SLOT, nSkillId)
end
function FightSkill:RemoveFightSkillSlot(nSkillId)
  if not self.tbFightSkillSlot[nSkillId] then
    return
  end
  self.tbFightSkillSlot[nSkillId] = nil
  UiNotify.OnNotify(UiNotify.emNOTIFY_REMOVE_SKILL_SLOT, nSkillId)
end
function FightSkill:OnAddAnger(pNpc, nAnger)
  local pPlayer = pNpc.GetPlayer()
  if pPlayer then
    Ui("HomeScreenBattle"):UpdateAnger()
  end
  if pNpc.nMasterNpcId == me.GetNpc().nId then
    Ui("HomeScreenBattle"):UpdatePartnerAnger(pNpc)
  end
end
FightSkill.tbSkillDesc = LoadTabFile("Setting/Skill/SkillDesc.tab", "ds", "SkillId", {"SkillId", "MagicDesc"})
function FightSkill:GetSkillMagicDesc(nSkillId, nSkillLevel)
  local tbSetting = self.tbSkillDesc[nSkillId]
  if not tbSetting then
    return ""
  end
  local szMagicDesc = FightSkill:GetSkillMagicDescEx(tbSetting.MagicDesc, nSkillId, nSkillLevel)
  return szMagicDesc
end
function FightSkill:GetSkillMagicDescEx(szMagicDesc, nSkillId, nSkillLevel, tbSkillMagic)
  local tbMagicValue = {}
  tbSkillMagic = tbSkillMagic or KFightSkill.GetSkillAllMagic(nSkillId, nSkillLevel)
  self:FormatMagicAttrib(tbSkillMagic, tbMagicValue, nSkillLevel)
  for szKey, szValue in pairs(tbMagicValue) do
    local szFind = string.match(szMagicDesc, szKey .. "/(%d[.%d]+)")
    if szFind and szFind ~= "" then
      szValue = tostring(math.abs(tonumber(szValue)) / tonumber(szFind))
      szValue = string.format("%.1f", szValue)
      szValue = string.gsub(szValue, "%.0", "")
      szMagicDesc = string.gsub(szMagicDesc, szKey .. "/(%d[.%d]+)", szValue)
    else
      local szCurValue = szValue
      local nValue = tonumber(szValue)
      if nValue ~= nil then
        szCurValue = tostring(math.abs(nValue))
      end
      szMagicDesc = string.gsub(szMagicDesc, szKey, szCurValue)
    end
  end
  return szMagicDesc
end
function FightSkill:FormatMagicAttrib(tbSkillMagic, tbMagicValue, nSkillLevel)
  for _, tbMA in pairs(tbSkillMagic) do
    local bUserDesc = string.find(tbMA.szName, "userdesc_000")
    if bUserDesc then
      for i = 1, 3 do
        local nDescSkillId = tbMA.tbValue[i]
        if nDescSkillId ~= 0 then
          local tbDescSkillMagic = KFightSkill.GetSkillAllMagic(nDescSkillId, nSkillLevel)
          self:FormatMagicAttrib(tbDescSkillMagic, tbMagicValue)
        end
      end
    else
      for i = 1, 3 do
        local szValue = tostring(tbMA.tbValue[i])
        local szKey = tbMA.szName .. i
        tbMagicValue[szKey] = szValue
      end
    end
  end
end
FightSkill.tbSkillAttackType = LoadTabFile("Setting/Skill/AttackSkill.tab", "ddd", "SkillId", {
  "SkillId",
  "AttackType",
  "AutoFightTarget"
})
FightSkill.AttackType = {
  Normal = 1,
  Direction = 2,
  Target = 3
}
function FightSkill:GetSkillAttackType(nSkillId)
  if self.tbSkillAttackType[nSkillId] then
    return self.tbSkillAttackType[nSkillId].AttackType
  end
  return FightSkill.AttackType.Normal
end
function FightSkill:IsTeamFollowAttackNeedTarget(nSkillId)
  local tbSkillInfo = self.tbSkillAttackType[nSkillId] or {}
  return tbSkillInfo.AutoFightTarget == 1
end
FightSkill.tbStateFunDesc = {
  [XiuLian.tbDef.nXiuLianBuffId] = function(nSkillId, nSkillLevel)
    local tbStateEffect = FightSkill:GetStateEffectBySkill(nSkillId, nSkillLevel)
    if not tbStateEffect then
      return ""
    end
    local szMagicDesc = FightSkill:GetSkillMagicDescEx(tbStateEffect.MagicDesc, nSkillId, nSkillLevel)
    local nResidueExp = me.GetUserValue(XiuLian.tbDef.nSaveGroupID, XiuLian.tbDef.nSaveResidueExp)
    return string.format(szMagicDesc, math.floor(XiuLian.tbDef.nAddExpPercent / 100), nResidueExp)
  end,
  [613] = function(nSkillId, nSkillLevel)
    local tbStateEffect = FightSkill:GetStateEffectBySkill(nSkillId, nSkillLevel)
    if not tbStateEffect then
      return ""
    end
    local szMagicDesc = FightSkill:GetSkillMagicDescEx(tbStateEffect.MagicDesc, nSkillId, nSkillLevel)
    local tbSkillMagic = KFightSkill.GetSkillAllMagic(nSkillId, nSkillLevel)
    local tbMagic = {
      0,
      0,
      0
    }
    for _, tbInfo in pairs(tbSkillMagic) do
      if tbInfo.szName == "magicshield" then
        tbMagic = tbInfo.tbValue
      end
    end
    local nAddDmgP = me.GetSkillAddShield(613)
    return string.format(szMagicDesc, math.floor((tbMagic[1] + nAddDmgP) * me.nDexterity / 100))
  end,
  [FriendShip.nTeamHelpBuffId] = function(nSkillId, nSkillLevel)
    return FriendShip:GetTeamAddExpDesc()
  end,
  [Shop.MONEY_DEBT_BUFF] = function(nSkillId, nSkillLevel)
    return Player:GetMoneyDebtDesc()
  end
}
function FightSkill:GetSkillStateMagicDesc(nSkillId, nSkillLevel, tbSkillMagic)
  local tbStateEffect = FightSkill:GetStateEffectBySkill(nSkillId, nSkillLevel)
  if not tbStateEffect then
    return ""
  end
  local funDescFun = self.tbStateFunDesc[nSkillId]
  if funDescFun then
    return funDescFun(nSkillId, nSkillLevel)
  end
  local szMagicDesc = FightSkill:GetSkillMagicDescEx(tbStateEffect.MagicDesc, nSkillId, nSkillLevel, tbSkillMagic)
  return szMagicDesc
end
function FightSkill:GetStateEffect(nStateEffectID)
  return self.tbSkillStateEffect[nStateEffectID]
end
function FightSkill:GetStateEffectBySkill(nSkillId, nSkillLevel)
  local tbSkillInfo = FightSkill:GetSkillSetting(nSkillId, nSkillLevel)
  if not tbSkillInfo or tbSkillInfo.StateEffectId <= 0 then
    return
  end
  local tbStateEffect = self:GetStateEffect(tbSkillInfo.StateEffectId)
  return tbStateEffect
end
function FightSkill:InitResetMagicType()
  KFightSkill.ChangeMagicIdName(114, "playerdmg_npc_p")
  KFightSkill.ResetMagicNameId()
  Log("FightSkill InitResetMagicType")
end
function FightSkill:GetSkillShowTipInfo(nSkillId, nSkillLevel, nSkillMaxLevel)
  local tbSkillInfo = FightSkill:GetSkillSetting(nSkillId, nSkillLevel)
  local nMaxLevel = nSkillMaxLevel or nSkillLevel
  local bMax = nSkillLevel >= nMaxLevel
  local szCurMagicDesc = FightSkill:GetSkillMagicDesc(nSkillId, nSkillLevel) or ""
  local szNextMagicDesc = nMaxLevel >= nSkillLevel + 1 and FightSkill:GetSkillMagicDesc(nSkillId, nSkillLevel + 1) or ""
  local tbSkillShowInfo = {
    nId = nSkillId,
    nLevel = nSkillLevel,
    nMaxLevel = nMaxLevel,
    bMax = bMax,
    szIcon = tbSkillInfo.Icon or "",
    szIconAltlas = tbSkillInfo.IconAtlas or "",
    szName = tbSkillInfo.SkillName or "",
    szDesc = tbSkillInfo.Desc or "",
    szProperty = tbSkillInfo.Property or "",
    nCD = tbSkillInfo.TimePerCast or 0,
    bPassive = tbSkillInfo.SkillType == FightSkill.SkillTypeDef.skill_type_passivity,
    nRadius = tbSkillInfo.AttackRadius or 0,
    szCurMagicDesc = szCurMagicDesc or "",
    szNextMagicDesc = szNextMagicDesc or ""
  }
  return tbSkillShowInfo
end
function FightSkill:IsShowSkillState(nSkillId, nSkillLevel)
  local tbSkillInfo = FightSkill:GetSkillSetting(nSkillId, nSkillLevel)
  if not tbSkillInfo or tbSkillInfo.StateEffectId <= 0 then
    return false
  end
  local tbStateEffect = self:GetStateEffect(tbSkillInfo.StateEffectId)
  if not tbStateEffect then
    return false
  end
  if Lib:IsEmptyStr(tbStateEffect.MagicDesc) or Lib:IsEmptyStr(tbStateEffect.Icon) then
    return false
  end
  return true
end
FightSkill.tbMagicCallScriptFun = {}
function FightSkill:MagicCallScript(pNpc, nSkillId, nEnd, nValue1, nValue2, nValue3)
  local funCallScript = FightSkill.tbMagicCallScriptFun[nSkillId]
  if funCallScript then
    funCallScript(pNpc, nSkillId, nEnd, nValue1, nValue2, nValue3)
  end
end
FightSkill.tbPreciseCastSkill = LoadTabFile("Setting/Skill/PreciseCastSkill.tab", "dsdd", "SkillId", {
  "SkillId",
  "CastType",
  "CastRadius",
  "DamageRadius"
})
