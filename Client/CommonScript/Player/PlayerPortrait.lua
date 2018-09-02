PlayerPortrait.Def = {SAVE_GROUP = 39}
function PlayerPortrait:StringFactionToTable(szFactions)
  local tbRet = {}
  local tbFactions = Lib:SplitStr(szFactions, "|")
  for _, v in pairs(tbFactions) do
    local nFaction = tonumber(v)
    if nFaction then
      tbRet[nFaction] = true
    end
  end
  return tbRet
end
function PlayerPortrait:LoadSetting()
  local tbSaveIdx = {}
  local tbSetting = LoadTabFile("Setting/Player/Portrait.tab", "dddssssssdd", "Id", {
    "Id",
    "FaceID",
    "BigFaceID",
    "Faction",
    "Desc",
    "Name",
    "OpenUi",
    "Icon",
    "IconAtlas",
    "Basic",
    "SaveIdx"
  })
  assert(tbSetting, "[PlayerPortrait LoadSetting Fail]")
  self.tbPortraitSetting = {}
  for _, v in pairs(tbSetting) do
    assert(not self.tbPortraitSetting[v.Id], "[PlayerPortrait LoadSetting] Error, Key Repeat")
    assert(v.Basic == 1 or v.SaveIdx > 0 and v.SaveIdx < 8160, "[PlayerPortrait LoadSetting] Error, Not Basic And SaveIdx Not Correct")
    local tbFaciton = self:StringFactionToTable(v.Faction)
    self.tbPortraitSetting[v.Id] = {
      nId = v.Id,
      nFaceId = v.FaceID,
      nBigFaceId = v.BigFaceID,
      tbFaciton = tbFaciton,
      szDesc = v.Desc,
      szName = v.Name,
      szOpenUi = v.OpenUi,
      szIcon = v.Icon,
      szIconAtlas = v.IconAtlas,
      bBasic = v.Basic == 1,
      nSaveIdx = v.SaveIdx
    }
    assert(v.Basic == 1 and v.SaveIdx == 0 or v.SaveIdx > 0, "[PlayerPortrait LoadSetting] Error, Basic And Not Basic")
    assert(not tbSaveIdx[v.Id], "[PlayerPortrait LoadSetting] Error, SaveIdx Repeat")
    if v.Basic == 1 then
      tbSaveIdx[v.Id] = true
    end
  end
end
PlayerPortrait:LoadSetting()
function PlayerPortrait:GetPortraitSetting(nPortrait)
  local tbSetting = self.tbPortraitSetting[nPortrait]
  if tbSetting and not tbSetting.szBigIcon and not tbSetting.szBigIconAtlas then
    local IconSmallAtlas, IconSmall = Npc:GetFace(tbSetting.nFaceId)
    local BigIconAtlas, BigIcon = Npc:GetFace(tbSetting.nBigFaceId)
    tbSetting.szBigIcon = BigIcon or tbSetting.szIcon
    tbSetting.szBigIconAtlas = BigIconAtlas or tbSetting.szIconAtlas
    tbSetting.szIconSmall = IconSmall or tbSetting.szIcon
    tbSetting.szIconSmallAtlas = IconSmallAtlas or tbSetting.szIconAtlas
  end
  return tbSetting or {}
end
function PlayerPortrait:GetPortraitIcon(nPortrait)
  local tbSetting = self:GetPortraitSetting(nPortrait)
  return tbSetting.szIcon, tbSetting.szIconAtlas
end
function PlayerPortrait:GetSmallIcon(nPortrait)
  local tbSetting = self.tbPortraitSetting[nPortrait]
  if tbSetting then
    local IconSmallAtlas, IconSmall = Npc:GetFace(tbSetting.nFaceId)
    return IconSmall, IconSmallAtlas
  end
  return "MaleHead", "UI/Atlas/Head/HeadAtlas.prefab"
end
function PlayerPortrait:GetPortraitBigIcon(nPortrait)
  local tbSetting = self:GetPortraitSetting(nPortrait)
  return tbSetting.szBigIcon, tbSetting.szBigIconAtlas
end
function PlayerPortrait:IsBasicPortrait(nPortrait)
  local tbSetting = self.tbPortraitSetting[nPortrait]
  if not tbSetting then
    return
  end
  return tbSetting.bBasic
end
function PlayerPortrait:GetFactionPortraits(nFaction)
  local tbRet = {}
  for _, tbSetting in pairs(self.tbPortraitSetting) do
    if tbSetting.tbFaciton[nFaction] then
      table.insert(tbRet, tbSetting)
    end
  end
  return tbRet
end
function PlayerPortrait:IsAvaliablePortraits(nPortrait)
  if self:IsBasicPortrait(nPortrait) then
    return true
  end
  local nSaveIdx = self:GetSaveIdx(nPortrait)
  if not nSaveIdx then
    return
  end
  local nSaveKey, nBit = self:GetSaveInfo(nSaveIdx)
  local nFlag = me.GetUserValue(self.Def.SAVE_GROUP, nSaveKey)
  local nRet = KLib.GetBit(nFlag, nBit)
  return nRet == 1
end
function PlayerPortrait:GetSaveIdx(nPortraitID)
  if not nPortraitID then
    return
  end
  local tbInfo = self.tbPortraitSetting[nPortraitID]
  if not tbInfo then
    return
  end
  return tbInfo.nSaveIdx
end
function PlayerPortrait:GetSaveInfo(nSaveIdx)
  if nSaveIdx == 0 then
    return
  end
  nSaveIdx = nSaveIdx - 0.1
  local nSaveKey = math.ceil(nSaveIdx / 32)
  local nBit = math.ceil(nSaveIdx % 32)
  return nSaveKey, nBit
end
function PlayerPortrait:CheckFaction(pPlayer, nPortrait)
  local tbSetting = self.tbPortraitSetting[nPortrait]
  return tbSetting and tbSetting.tbFaciton[pPlayer.nFaction]
end
function PlayerPortrait:OnAddPortrait()
  UiNotify.OnNotify(UiNotify.emNOTIFY_ADD_PORTRAIT)
end
