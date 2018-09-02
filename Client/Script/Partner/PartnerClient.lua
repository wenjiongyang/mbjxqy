function Partner:UpdateRedPoint()
  self:CheckMainRedPoint()
  self:CheckCardPickRedPoint()
  Ui:CheckRedPoint("Partner")
end
function Partner:CheckCardPickRedPoint()
  if me.nLevel < CardPicker.Def.OpenLevel then
    Ui:ClearRedPointNotify("PartnerCardPickPanel")
    return
  end
  local nNow = GetTime()
  local nNextFreePickTime = CardPicker:GetNextFreePickTime()
  local nNextCoinFreePick = CardPicker:GetNextCoinFreePickTime()
  if nNow > nNextCoinFreePick or nNow > nNextFreePickTime then
    Ui:SetRedPointNotify("PartnerCardPickPanel")
  else
    Ui:ClearRedPointNotify("PartnerCardPickPanel")
  end
end
function Partner:CheckMainRedPoint()
  if JingMai:CheckShowRedPoint() then
    Ui:SetRedPointNotify("PartnerMainPanel")
    return true
  end
  local tbPosInfo = me.GetPartnerPosInfo()
  for _, nPartnerId in pairs(tbPosInfo) do
    if self:CheckPartnerRedPoint(nPartnerId) then
      Ui:SetRedPointNotify("PartnerMainPanel")
      return true
    end
  end
  Ui:ClearRedPointNotify("PartnerMainPanel")
  return false
end
function Partner:CheckPartnerRedPoint(nPartnerId)
  local tbPartner = me.GetPartnerInfo(nPartnerId or 0)
  if not tbPartner then
    return false
  end
  return false
end
function Partner:ClearGralleryRedPoint()
  local tbInfo = Client:GetUserInfo("PartnerRedPoint")
  tbInfo.Grallery = tbInfo.Grallery or {}
  tbInfo.Grallery = {}
  Ui:CheckRedPoint("Partner")
  Client:SaveUserInfo()
end
function Partner:SetGralleryRedPoint(nPartnerId)
  local tbInfo = Client:GetUserInfo("PartnerRedPoint")
  tbInfo.Grallery = tbInfo.Grallery or {}
  local szName = GetOnePartnerBaseInfo(nPartnerId)
  if not szName then
    return
  end
  tbInfo.Grallery[nPartnerId] = 1
  Client:SaveUserInfo()
end
function Partner:GetGralleryRedPoint()
  local tbInfo = Client:GetUserInfo("PartnerRedPoint")
  tbInfo.Grallery = tbInfo.Grallery or {}
  return tbInfo.Grallery
end
function Partner:GetSkillShowInfo(nSkillId, nSkillLevel, nMaxLevel)
  nSkillLevel = math.max(nSkillLevel, 1)
  nMaxLevel = nMaxLevel or 1
  local tbSkillInfo = FightSkill:GetSkillSetting(nSkillId)
  local bMax = nSkillLevel >= nMaxLevel
  local szCurMagicDesc = FightSkill:GetSkillMagicDesc(nSkillId, nSkillLevel) or ""
  local szNextMagicDesc = nMaxLevel >= nSkillLevel + 1 and FightSkill:GetSkillMagicDesc(nSkillId, nSkillLevel + 1) or ""
  local tbSkillShowInfo = {
    nId = nSkillId,
    nLevel = nSkillLevel,
    nMaxLevel = nMaxLevel,
    bMax = bMax,
    szIcon = tbSkillInfo.Icon or "",
    szName = tbSkillInfo.SkillName or "",
    szDesc = tbSkillInfo.Desc or "",
    szProperty = tbSkillInfo.Property or "",
    nCD = tbSkillInfo.TimePerCast or 0,
    bPassive = tbSkillInfo.SkillType == 3,
    nRadius = tbSkillInfo.AttackRadius or 0,
    szCurMagicDesc = szCurMagicDesc or "",
    szNextMagicDesc = szNextMagicDesc or ""
  }
  return tbSkillShowInfo
end
function Partner:ShowSkillTips(nSkillId, nSkillLevel, nMaxLevel)
  local tbSkillShowInfo = self:GetSkillShowInfo(nSkillId, nSkillLevel, nMaxLevel)
  Ui:OpenWindow("SkillShow", tbSkillShowInfo)
end
function Partner:OnComposeSuccess(nItemTemplateId, dwId)
  UiNotify.OnNotify(UiNotify.emNOTIFY_ONCOMPOSE_CALLBACK, nItemTemplateId, dwId)
end
function Partner:PGInit()
  UiNotify.OnNotify(UiNotify.emNOTIFY_PG_INIT)
end
function Partner:PGClose()
  UiNotify.OnNotify(UiNotify.emNOTIFY_PG_CLOSE)
end
function Partner:PGForbiddenPartner()
  UiNotify.OnNotify(UiNotify.emNOTIFY_FORBIDDEN_PARTNER)
end
function Partner:PGPartnerDeath(nPos)
  UiNotify.OnNotify(UiNotify.emNOTIFY_PG_PARTNER_DEATH, nPos)
end
function Partner:PGPartnerNpcChange(bIsAdd, nNpcId, nPos)
  UiNotify.OnNotify(UiNotify.emNOTIFY_PG_PARTNER_NPC_CHANGE, bIsAdd, nNpcId, nPos)
end
function Partner:PGSwitchToGroup(nGroupId, bFixGroupID, nFirstPartnerNpcId, nSecondPartnerNpcId)
  UiNotify.OnNotify(UiNotify.emNOTIFY_PG_PARTNER_SWITCH_GROUP, nGroupId, bFixGroupID, nFirstPartnerNpcId, nSecondPartnerNpcId)
end
function Partner:PGAwarenessFinish(nPartnerId)
  UiNotify.OnNotify(UiNotify.emNOTIFY_PG_PARTNER_AWARENESS, nPartnerId)
end
function Partner:SyncHasReinitData(bHasData)
  UiNotify.OnNotify(UiNotify.emNOTIFY_PARTNER_REINITDATA, bHasData)
end
function Partner:OnGradeLevelup(nPartnerId, nGradeLevel)
  me.CenterMsg("突破成功，各项潜能上限得到提升")
  local pPartner = me.GetPartnerObj(nPartnerId)
  if not pPartner then
    return
  end
  local nOldGradeLevel = pPartner.GetGradeLevel()
  pPartner.SetGradeLevel(nGradeLevel)
  UiNotify.OnNotify(UiNotify.emNOTIFY_PARTNER_GRADE_LEVELUP, nPartnerId, nOldGradeLevel + 1, nGradeLevel + 1)
end
function Partner:ChangePartnerFightID(nPartnerId)
  local tbPartner = me.GetPartnerInfo(nPartnerId)
  if not tbPartner then
    return
  end
  UiNotify.OnNotify(UiNotify.emNOTIFY_CHANGE_FIGHTPARTNER_ID, nPartnerId)
end
