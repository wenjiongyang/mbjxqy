local tbUi = Ui:CreateClass("ViewRolePanel")
local RepresentSetting = luanet.import_type("RepresentSetting")
tbUi.nTabPartner = 1
tbUi.nTabMiji = 2
tbUi.nTabHorseEquip = 3
tbUi.tbOnClick = {
  BtnClose = function(self)
    Ui:CloseWindow(self.UI_NAME)
  end,
  Companion1 = function(self)
    self:OnClickCompanion(1)
  end,
  Companion2 = function(self)
    self:OnClickCompanion(2)
  end,
  Companion3 = function(self)
    self:OnClickCompanion(3)
  end,
  Companion4 = function(self)
    self:OnClickCompanion(4)
  end,
  BtnTab1 = function(self)
    self.nCurShowTab = self.nTabPartner
    self:UpdateTabShow()
  end,
  BtnTab2 = function(self)
    self.nCurShowTab = self.nTabMiji
    self:UpdateTabShow()
  end,
  BtnTab3 = function(self)
    self.nCurShowTab = self.nTabHorseEquip
    self:UpdateTabShow()
  end,
  Meridian = function(self)
    local tbLearnInfo, bHasNoPartner = JingMai:GetLearnedXueWeiInfo(nil, self.pAsyncRole)
    local tbAddInfo = JingMai:GetXueWeiAddInfo(tbLearnInfo)
    Ui:OpenWindow("JingMaiTipsPanel", tbAddInfo.tbExtAttrib, tbAddInfo.tbSkill, bHasNoPartner)
  end
}
tbUi.tbOnDrag = {
  ShowRole = function(self, szWnd, nX, nY)
    self.pPanel:NpcView_ChangeDir("ShowRole", -nX, true)
  end
}
function tbUi:OnOpen(tbEquip, tbNpcRes, tbPartnerInfo, pAsyncRole)
  self.pAsyncRole = pAsyncRole
  self.nFaction = pAsyncRole.GetFaction()
  self.tbPartnerInfo = tbPartnerInfo
  self.tbEquip = tbEquip
  local szFactionName = Faction:GetName(self.nFaction)
  local tbPlayerInfo = KPlayer.GetPlayerInitInfo(self.nFaction)
  self.pPanel:Label_SetText("FactionName", string.format("%s [%s]%s[-]", szFactionName, Npc.SeriesColor[tbPlayerInfo.nSeries], Npc.Series[tbPlayerInfo.nSeries]))
  local SpFaction = Faction:GetIcon(self.nFaction)
  self.pPanel:Sprite_SetSprite("Faction", SpFaction)
  local nHonorLevel = pAsyncRole.GetHonorLevel()
  local tbHonorInfo = Player.tbHonorLevelSetting[nHonorLevel]
  if tbHonorInfo then
    self.pPanel:SetActive("PlayerHonor", true)
    self.pPanel:Sprite_Animation("PlayerHonor", tbHonorInfo.ImgPrefix)
  else
    self.pPanel:SetActive("PlayerHonor", false)
  end
  local tbRoleInfo = pAsyncRole.tbRoleInfo
  self.pPanel:Label_SetText("kinName", tbRoleInfo and tbRoleInfo.szKinName or "")
  local nPortrait = tbRoleInfo and tbRoleInfo.nPortrait or self.nFaction
  local tbPortaitSetting = PlayerPortrait:GetPortraitSetting(nPortrait)
  self.pPanel:Sprite_SetSprite("Rolehead", tbPortaitSetting.szBigIcon, tbPortaitSetting.szBigIconAtlas)
  local tbTitleInfo = tbRoleInfo and tbRoleInfo.tbTitleInfo
  if tbTitleInfo then
    local nTitleId, szTitleStr = unpack(tbTitleInfo)
    if nTitleId == 0 and Lib:IsEmptyStr(szTitleStr) then
      tbTitleInfo = nil
    end
  end
  if tbTitleInfo then
    self.pPanel:SetActive("Title", true)
    local nTitleId, szTitleStr = unpack(tbTitleInfo)
    local tbCurTemp = PlayerTitle:GetTitleTemplate(nTitleId)
    if Lib:IsEmptyStr(szTitleStr) then
      szTitleStr = tbCurTemp.Name
    end
    self.pPanel:Label_SetText("Title", szTitleStr)
    local MainColor = RepresentSetting.GetColorSet(tbCurTemp.ColorID)
    self.pPanel:Label_SetColor("Title", MainColor.r * 255, MainColor.g * 255, MainColor.b * 255)
    if 0 < tbCurTemp.GTopColorID and 0 < tbCurTemp.GBottomColorID then
      local GTopColor = RepresentSetting.GetColorSet(tbCurTemp.GTopColorID)
      local GTBottomColor = RepresentSetting.GetColorSet(tbCurTemp.GBottomColorID)
      self.pPanel:Label_SetGradientByColor("Title", GTopColor, GTBottomColor)
    else
      self.pPanel:Label_SetGradientActive("Title", false)
    end
    local ColorOuline = RepresentSetting.CreateColor(0, 0, 0, 1)
    if 0 < tbCurTemp.OutlineColorID then
      ColorOuline = RepresentSetting.GetColorSet(tbCurTemp.OutlineColorID)
    end
    self.pPanel:Label_SetOutlineColor("Title", ColorOuline)
  else
    self.pPanel:SetActive("Title", false)
  end
  local szRoleName = pAsyncRole.szName
  if tbRoleInfo then
    local szRemmarkName = FriendShip:GetRemarkName(tbRoleInfo.dwID)
    if not Lib:IsEmptyStr(szRemmarkName) then
      szRoleName = string.format("%s（%s）", szRoleName, szRemmarkName)
    end
  end
  self.pPanel:Label_SetText("szName", szRoleName)
  self.pPanel:Label_SetText("lbLevel", pAsyncRole.GetLevel())
  self.pPanel:Label_SetText("lbHP", pAsyncRole.GetMaxHp())
  self.pPanel:Label_SetText("lbAttack", pAsyncRole.GetBaseDamage())
  self.pPanel:Label_SetText("lbFight", pAsyncRole.GetFightPower())
  local tbRoleAttribs = {
    {
      "Vitality",
      "TiZhi",
      "lbTiZHi"
    },
    {
      "Strength",
      "LiLiang",
      "lbLiLiang"
    },
    {
      "Energy",
      "LingQiao",
      "lbLingQiao"
    },
    {
      "Dexterity",
      "MinJie",
      "lbMinJie"
    }
  }
  for i, v in ipairs(tbRoleAttribs) do
    local szType, szWidget, szLabel = unpack(v)
    local nVal = pAsyncRole["Get" .. szType]()
    if nVal > 0 then
      self.pPanel:SetActive(szWidget, true)
      self.pPanel:Label_SetText(szLabel, nVal)
    else
      self.pPanel:SetActive(szWidget, false)
    end
  end
  self:UpdateEquip()
  local tbEffectRest = {}
  for nI = 0, Npc.NpcResPartsDef.npc_res_part_count - 1 do
    tbEffectRest[nI] = 0
  end
  local nLightID = pAsyncRole.GetOpenLight()
  local nFactionID = pAsyncRole.GetFaction()
  if nLightID > 0 then
    tbEffectRest[Npc.NpcResPartsDef.npc_part_weapon] = OpenLight:GetFactionEffectByLight(nLightID, nFactionID)
  end
  self.pPanel:NpcView_Open("ShowRole")
  self.pPanel:NpcView_SetScale("ShowRole", 0.9)
  if tbEquip[Item.EQUIPPOS_WAIYI] then
    local pItem = KItem.GetItemObj(tbEquip[Item.EQUIPPOS_WAIYI])
    if pItem then
      local nRes = Item.tbChangeColor:GetWaiZhuanRes(pItem.dwTemplateId, self.nFaction)
      tbNpcRes[Npc.NpcResPartsDef.npc_part_body] = nRes
    end
  end
  if tbEquip[Item.EQUIPPOS_WAI_WEAPON] then
    local pItem = KItem.GetItemObj(tbEquip[Item.EQUIPPOS_WAI_WEAPON])
    if pItem then
      local nRes = Item.tbChangeColor:GetWaiZhuanRes(pItem.dwTemplateId, self.nFaction)
      tbNpcRes[Npc.NpcResPartsDef.npc_part_weapon] = nRes
    end
  end
  self:ChangeFeature(tbNpcRes, tbEffectRest)
  if self.pPanel:Toggle_GetChecked("BtnTab1") then
    self.nCurShowTab = self.nTabPartner
  elseif self.pPanel:Toggle_GetChecked("BtnTab2") then
    self.nCurShowTab = self.nTabMiji
  elseif self.pPanel:Toggle_GetChecked("BtnTab3") then
    self.nCurShowTab = self.nTabHorseEquip
  end
  self:UpdateTabShow()
end
function tbUi:UpdateTabShow()
  if self.nCurShowTab == self.nTabMiji then
    self:UpdateMijiInfo()
  elseif self.nCurShowTab == self.nTabHorseEquip then
    self:UpdateHorseEquip()
  else
    self:UpdatePartnerInfo()
  end
end
function tbUi:OnClose()
  self.pPanel:NpcView_Close("ShowRole")
end
function tbUi:UpdateEquip()
  local tbEquip = self.tbEquip
  local tbStrengthen = self.pAsyncRole.GetStrengthen()
  for i = 0, Item.EQUIPPOS_MAIN_NUM - 1 do
    local tbEquipGrid = self["Equip" .. i]
    tbEquipGrid.nEquipPos = i
    tbEquipGrid.nFaction = self.nFaction
    tbEquipGrid.szItemOpt = "PlayerEquip"
    tbEquipGrid.pAsyncRole = self.pAsyncRole
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
    tbEquipGrid:SetItem(tbEquip[i], nil, self.nFaction)
    local nStrength = tbStrengthen[i + 1]
    if tbEquip[i] and nStrength > 0 then
      self.pPanel:SetActive("StrengthenLevel" .. i, true)
      self.pPanel:Label_SetText("StrengthenLevel" .. i, "+" .. nStrength)
    else
      self.pPanel:SetActive("StrengthenLevel" .. i, false)
    end
  end
  local tbEqiptHorse = self["Equip" .. Item.EQUIPPOS_HORSE]
  local nItemId = tbEquip[Item.EQUIPPOS_HORSE]
  if nItemId then
    tbEqiptHorse.nEquipPos = Item.EQUIPPOS_HORSE
    tbEqiptHorse.szItemOpt = "PlayerEquip"
    tbEqiptHorse:SetItem(nItemId, nil, self.nFaction)
    function tbEqiptHorse.fnClick(itemObj)
      if GetTimeFrameState("OpenLevel89") == 1 then
        Ui:OpenWindow("HorsePanel", tbEquip)
      else
        tbEqiptHorse:DefaultClick()
      end
    end
    tbEqiptHorse.pPanel:SetActive("Main", true)
  else
    tbEqiptHorse.pPanel:SetActive("Main", false)
  end
  local tbWayyiPos = {
    Item.EQUIPPOS_WAIYI,
    Item.EQUIPPOS_WAI_WEAPON,
    Item.EQUIPPOS_WAI_HORSE
  }
  for _, nEquipPos in ipairs(tbWayyiPos) do
    local tbEqiptWaiyi = self["Equip" .. nEquipPos]
    if tbEquip[nEquipPos] then
      self.pPanel:SetActive("FashionTitle" .. nEquipPos, false)
      tbEqiptWaiyi.nEquipPos = nEquipPos
      tbEqiptWaiyi.szItemOpt = "PlayerEquip"
      tbEqiptWaiyi:SetItem(tbEquip[nEquipPos], nil, self.nFaction)
      function tbEqiptWaiyi.fnClick(itemObj)
        local pItem = KItem.GetItemObj(itemObj.nItemId)
        if pItem then
          Ui:OpenWindow("ItemTips", "Item", nil, pItem.dwTemplateId, self.nFaction)
        end
      end
    else
      self.pPanel:SetActive("FashionTitle" .. nEquipPos, true)
      tbEqiptWaiyi:Clear()
    end
  end
  if GetTimeFrameState(Item.tbZhenYuan.szOpenTimeFrame) == 1 then
    self.pPanel:SetActive("Vitality", true)
    local tbEquipZhenYuan = self["Equip" .. Item.EQUIPPOS_ZHEN_YUAN]
    if tbEquip[Item.EQUIPPOS_ZHEN_YUAN] then
      tbEquipZhenYuan.szItemOpt = "PlayerEquip"
      tbEquipZhenYuan.nEquipPos = Item.EQUIPPOS_ZHEN_YUAN
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
function tbUi:ChangeFeature(tbNpcRes, tbEffectRest)
  local tbCopyNpcRes = Lib:CopyTB(tbNpcRes)
  for nI = 0, Npc.NpcResPartsDef.npc_res_part_count - 1 do
    if not tbCopyNpcRes[nI] then
      tbCopyNpcRes[nI] = 0
    end
  end
  tbCopyNpcRes[Npc.NpcResPartsDef.npc_part_horse] = 0
  for nPartId, nResId in pairs(tbCopyNpcRes) do
    self.pPanel:NpcView_ChangePartRes("ShowRole", nPartId, nResId)
  end
  tbEffectRest = tbEffectRest or {}
  for nPartId, nResId in pairs(tbEffectRest) do
    self.pPanel:NpcView_ChangePartEffect("ShowRole", nPartId, nResId)
  end
end
function tbUi:UpdatePartnerInfo()
  self.pPanel:SetActive("Companion", true)
  self.pPanel:SetActive("Item", false)
  local tbPartnerInfo = self.tbPartnerInfo
  for i = 1, 4 do
    local tbOneData = tbPartnerInfo[i]
    if tbOneData then
      self["Face" .. i]:SetPartnerInfo(tbOneData.tbPartnerInfo)
      self.pPanel:SetActive("Face" .. i, true)
      self.pPanel:SetActive("num" .. i, false)
    else
      self.pPanel:Sprite_SetSprite("Companion" .. i, "CompanionHeadBg_None")
      self.pPanel:SetActive("Face" .. i, false)
      self.pPanel:SetActive("num" .. i, true)
    end
  end
end
function tbUi:UpdateMijiInfo()
  self.pPanel:SetActive("Companion", false)
  self.pPanel:SetActive("Item", true)
  local tbBook = Item:GetClass("SkillBook")
  for i = 1, 4 do
    local nItemId = self.tbEquip[Item.EQUIPPOS_SKILL_BOOK + i - 1]
    local tbGrid = self["Item0" .. i]
    if nItemId and nItemId > 0 then
      local pItem = KItem.GetItemObj(nItemId)
      if pItem then
        tbGrid.pAsyncRole = self.pAsyncRole
        tbGrid.nPosIndex = Item.EQUIPPOS_SKILL_BOOK + i - 1
        tbGrid:SetItem(nItemId, nil, self.nFaction)
        tbGrid.fnClick = tbGrid.DefaultClick
      end
    else
      tbGrid:Clear()
    end
  end
end
function tbUi:UpdateHorseEquip()
  self.pPanel:SetActive("Companion", false)
  self.pPanel:SetActive("Item", true)
  local tbPoses = {
    Item.EQUIPPOS_REIN,
    Item.EQUIPPOS_SADDLE,
    Item.EQUIPPOS_PEDAL
  }
  for i = 1, 4 do
    local tbGrid = self["Item0" .. i]
    local nPos = tbPoses[i]
    if nPos and self.tbEquip[nPos] then
      tbGrid:SetItem(self.tbEquip[nPos])
      tbGrid.fnClick = tbGrid.DefaultClick
    else
      tbGrid:Clear()
    end
  end
end
function tbUi:OnClickCompanion(nIndex)
  local tbInfo = self.tbPartnerInfo[nIndex]
  if not tbInfo then
    return
  end
  local tbLearnInfo = JingMai:GetLearnedXueWeiInfo(nil, self.pAsyncRole)
  local tbAllAddAttribInfo = JingMai:GetXueWeiAddInfo(tbLearnInfo)
  local tbPartnerAttribInfo = JingMai:MgrPartnerAttrib(tbInfo.tbPartnerAttribInfo, JingMai:GetAttribInfo(tbAllAddAttribInfo.tbExtPartnerAttrib))
  Ui:OpenWindow("PartnerDetail", tbInfo.tbPartnerInfo, tbPartnerAttribInfo, tbInfo.tbPartnnerSkillInfo, nil, nil, tbAllAddAttribInfo)
end
