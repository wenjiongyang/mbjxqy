local tbSkillPanel = Ui:CreateClass("SkillPanel")
tbSkillPanel.nSubItemCount = 5
tbSkillPanel.ITEM_MINI_HEIGHT = 120
tbSkillPanel.ITEM_FULL_HEIGHT = 295
tbSkillPanel.ITEM_WEIDHT = 938
tbSkillPanel.tbOnClick = {
  BtnClose = function(self)
    Ui:CloseWindow(self.UI_NAME)
  end,
  SillPointSprite = function(self)
    Ui:OnHelpClicked("SkillHelp")
  end,
  BtnReset = function(self)
    local szMsg = ""
    if me.nMapTemplateId == ChangeFaction.tbDef.nMapTID then
      szMsg = "重置当前已分配的技能点，[FFFE0D]免费[-]重置后进行重新分配，确定吗？"
    elseif me.nLevel >= FightSkill.nCostGoldLevelResetSkill then
      local szMoneyName, szEmotion = Shop:GetMoneyName("Gold")
      szMsg = string.format("重置当前已分配的技能点，花费[FFFE0D]%d%s[-] 重置后进行重新分配，确定吗？", FightSkill.nCostGoldResetSkill, szMoneyName)
    else
      szMsg = string.format("重置当前已分配的技能点，重置后进行重新分配，确定吗？\n[FFFE0D]%s级前可免费重置[-]", FightSkill.nCostGoldLevelResetSkill)
    end
    me.MsgBox(szMsg, {
      {
        "确认",
        function()
          RemoteServer.ResetSkillPoint()
        end
      },
      {"取消"}
    })
  end,
  ChangeFaction = function(self)
    self:ChangeSkillTab("FactionPanel")
  end,
  ChangePublic = function(self)
    self:ChangeSkillTab("PublicPanel")
  end,
  BtnSkillItem = function(self)
    Ui:OpenWindow("SkillAuxiliaryPanel")
  end
}
tbSkillPanel.tbOnDrag = {
  ShowRole = function(self, szWnd, nX, nY)
    self.pPanel:NpcView_ChangeDir("ShowRole", -nX, true)
  end
}
function tbSkillPanel:OnOpen(szChangePanel)
  local pNpc = me.GetNpc()
  if pNpc.nShapeShiftNpcTID > 0 then
    me.CenterMsg("变身状态时不能操作", true)
    return 0
  end
  self.tbHeight = self.tbHeight or {}
  local tbSkillBook = Item:GetClass("SkillBook")
  tbSkillBook:UpdateRedPoint(me)
  self:ChangeFeature()
  self.szChangePanel = szChangePanel or self.szChangePanel
  self:ChangeSkillTab(self.szChangePanel or "FactionPanel")
  self.pPanel:Toggle_SetChecked("ChangeFaction", self.szChangePanel == "FactionPanel")
  self.pPanel:Toggle_SetChecked("ChangePublic", self.szChangePanel == "PublicPanel")
end
function tbSkillPanel:ChangeSkillTab(szPanel)
  self.szChangePanel = szPanel
  self.pPanel:SetActive("PublicPanel", self.szChangePanel == "PublicPanel")
  self.pPanel:SetActive("FactionPanel", self.szChangePanel == "FactionPanel")
  if self.szChangePanel == "PublicPanel" then
    self:UpdatePublicPanel()
  elseif self.szChangePanel == "FactionPanel" then
    self:UpdateFactionPanel()
  end
end
local tbSkillLabel = Ui:CreateClass("SkillPanelLabel")
function tbSkillPanel:UpdatePublicMiJi()
  local tbAllSkillList = {}
  local tbSkillBook = Item:GetClass("SkillBook")
  for nIndex, nNeedLevel in ipairs(tbSkillBook.tbSkillBookHoleLevel) do
    local pEquip = me.GetEquipByPos(nIndex + Item.EQUIPPOS_SKILL_BOOK - 1)
    self["SkillBookItem" .. nIndex].fnClick = nil
    self["SkillBookItem" .. nIndex]:Clear()
    if pEquip then
      self["SkillBookItem" .. nIndex]:SetItem(pEquip.dwId)
      self["SkillBookItem" .. nIndex].fnClick = self["SkillBookItem" .. nIndex].DefaultClick
      local nItemTID = pEquip.dwTemplateId
      local nBookLevel = pEquip.GetIntValue(tbSkillBook.nSaveBookLevel)
      local nBookSkillLevel = pEquip.GetIntValue(tbSkillBook.nSaveSkillLevel)
      local tbBookInfo = tbSkillBook:GetBookInfo(pEquip.dwTemplateId)
      local _, tbSkill = tbSkillBook:GetShowTipInfo(nItemTID, nBookLevel, nBookSkillLevel)
      local tbSubInfo = FightSkill:GetSkillShowTipInfo(tbSkill.nSkillID, tbSkill.nSkillLevel, tbBookInfo.MaxSkillLevel)
      table.insert(tbAllSkillList, tbSubInfo)
    end
    self.pPanel:SetActive("SkillBookEquip" .. nIndex, false)
    if nNeedLevel > me.nLevel then
      self.pPanel:SetActive("SkillBookLimite" .. nIndex, true)
      self.pPanel:Label_SetText("SkillBookLimite" .. nIndex, string.format("%s级\n开启", nNeedLevel))
    else
      self.pPanel:SetActive("SkillBookLimite" .. nIndex, false)
      if not pEquip then
        self.pPanel:SetActive("SkillBookEquip" .. nIndex, true)
      end
      self["SkillBookEquip" .. nIndex].pPanel.OnTouchEvent = function()
        local tbShowSkilBook = Ui:GetClass("SkillBookEquipPanel")
        local tbShowInfo = {}
        tbShowInfo.nItemPos = nIndex + Item.EQUIPPOS_SKILL_BOOK - 1
        local tbAllItem = tbShowSkilBook.tbShowItemClass.SkillBook(tbShowInfo)
        if #tbAllItem > 0 then
          Ui:OpenWindow("SkillBookEquipPanel", "SkillBook", nIndex + Item.EQUIPPOS_SKILL_BOOK - 1)
        else
          me.CenterMsg("少侠还没有可以装备的秘籍，用门派信物去换一本吧")
        end
      end
    end
  end
  return tbAllSkillList
end
function tbSkillPanel:UpdatePublicPanel()
  local tbSkillBook = Item:GetClass("SkillBook")
  tbSkillBook:UpdateRedPoint(me)
  self.pPanel:Label_SetText("PublicSkillTitle", "秘籍、同伴护主、经脉技能")
  self.pPanel:Sprite_SetSprite("FactionIcon2", Faction:GetWordIcon(me.nFaction))
  local tbSetting = PlayerPortrait:GetPortraitSetting(me.nPortrait)
  self.pPanel:Sprite_SetSprite("RoleHead", tbSetting.szBigIcon or "", tbSetting.szBigIconAtlas)
  local nGrowExp = tbSkillBook:UpdateGrowXiuLianExp(me)
  self.pPanel:Label_SetText("SkillBookExp", string.format("当前修为：%s/%s\n（40级后，每4分钟自动增长1点）", me.GetMoney(tbSkillBook.szSkillBookExpName) + nGrowExp, tbSkillBook.nMaxXiuLianExp))
  local tbAllSkillList = {}
  local tbSkillList = self:UpdatePublicMiJi()
  if Lib:HaveCountTB(tbSkillList) then
    table.insert(tbAllSkillList, tbSkillList)
  end
  local tbProtectSkill = Partner:GetPartnerProtectSkillInfo(me)
  if Lib:HaveCountTB(tbProtectSkill) then
    local tbPartnerSkillList = {}
    for _, tbSkillInfo in ipairs(tbProtectSkill) do
      if tbSkillInfo.bActive then
        local tbSubInfo = FightSkill:GetSkillShowTipInfo(tbSkillInfo.nSkillId, tbSkillInfo.nSkillLevel, tbSkillInfo.nMaxSkillLevel)
        tbSubInfo.bPartner = true
        table.insert(tbPartnerSkillList, tbSubInfo)
      end
    end
    table.insert(tbAllSkillList, tbPartnerSkillList)
  end
  local tbLearnInfo = JingMai:GetLearnedXueWeiInfo(me)
  local tbAddInfo = JingMai:GetXueWeiAddInfo(tbLearnInfo)
  if tbAddInfo and tbAddInfo.tbSkill and #tbAddInfo.tbSkill >= 0 then
    local tbJingMaiSkillList = {}
    for _, tbInfo in ipairs(tbAddInfo.tbSkill) do
      local nSkillId, nSkillLevel, nMaxSkillLevel = unpack(tbInfo)
      local tbSubInfo = FightSkill:GetSkillShowTipInfo(nSkillId, nSkillLevel, nMaxSkillLevel)
      tbSubInfo.bJingMai = true
      table.insert(tbJingMaiSkillList, tbSubInfo)
    end
    table.insert(tbAllSkillList, tbJingMaiSkillList)
  end
  local tbZhenYuanSkillInfo = Item:GetClass("ZhenYuan"):GetZhenYuanSkillAttribTip(me)
  if tbZhenYuanSkillInfo then
    local tbZhenYuanSkillList = {}
    local nSkillId, nSkillLevel, nMaxSkillLevel = unpack(tbZhenYuanSkillInfo)
    local tbSubInfo = FightSkill:GetSkillShowTipInfo(nSkillId, nSkillLevel, nMaxSkillLevel)
    table.insert(tbZhenYuanSkillList, tbSubInfo)
    table.insert(tbAllSkillList, tbZhenYuanSkillList)
  end
  local function fnSetItem(tbItemObj, nIndex)
    local tbCurSkillList = tbAllSkillList[nIndex]
    for nSub = 1, self.nSubItemCount do
      local tbSkillInfo = tbCurSkillList[nSub]
      if tbSkillInfo then
        tbItemObj.pPanel:SetActive("SkillItem" .. nSub, true)
        local tbSubItem = tbItemObj["SkillItem" .. nSub]
        tbSubItem.tbParentObj = tbItemObj
        tbSubItem:PublicUpdateInfo(nSub, tbSkillInfo)
      else
        tbItemObj.pPanel:SetActive("SkillItem" .. nSub, false)
      end
    end
  end
  local nUpdateCount = #tbAllSkillList
  self.ScrollView2:Update(nUpdateCount, fnSetItem)
end
function tbSkillPanel:UpdateFactionPanel()
  self:UpdateSkillList()
  self:ChangeMoney()
  local szIcon = Faction:GetBigIcon(me.nFaction)
  if not Lib:IsEmptyStr(szIcon) then
    self.pPanel:Sprite_SetSprite("FactionIcon", szIcon)
  end
end
function tbSkillPanel:ChangeFeature()
  self.pPanel:NpcView_Open("ShowRole")
  local tbNpcRes, tbEffectRes = me.GetNpcResInfo()
  local tbFactionScale = {
    0.92,
    1,
    1.15,
    1
  }
  local fScale = tbFactionScale[me.nFaction] or 1
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
  self.pPanel:NpcView_SetScale("ShowRole", fScale)
end
function tbSkillPanel:OnClose()
  Ui:CloseWindow("SkillShow")
  self.pPanel:NpcView_Close("ShowRole")
end
function tbSkillPanel:ChangeMoney()
  local nToalCostPoint = FightSkill:GetTotalSkillPoint(me)
  local nCurSkillPoint = FightSkill:GetCurSkillPoint(me)
  self.pPanel:Label_SetText("TxtExp", string.format("%s/%s", nCurSkillPoint, nToalCostPoint))
  local tbSkillBook = Item:GetClass("SkillBook")
  tbSkillBook:UpdateRedPoint(me)
end
function tbSkillPanel:UpdateSkillList()
  self:ChangeMoney()
  local tbFactionSkill = FightSkill:GetFactionSkill(me.nFaction)
  self.tbSkillList = {}
  for _, tbInfo in pairs(tbFactionSkill) do
    local nSkillId = tbInfo.SkillId
    local _, nSkillLevel = me.GetSkillLevel(nSkillId)
    local nSkillInfoLevel = nSkillLevel
    if not nSkillInfoLevel or nSkillInfoLevel <= 0 then
      nSkillInfoLevel = 1
    end
    local nReqLevel, nCoin, nExp, nPoint = FightSkill:GetSkillLevelUpNeed(nSkillId, nSkillLevel)
    local bMax = nSkillLevel >= FightSkill:GetSkillMaxLevel(nSkillId) + FightSkill:GetSkillLimitAddLevel(me, nSkillId)
    local nExtLevel = 0
    if nSkillLevel > 0 then
      nExtLevel = me.GetAddAllFactionLevel(nSkillId)
    end
    local tbSkillInfo = FightSkill:GetSkillSetting(nSkillId, nSkillInfoLevel + nExtLevel)
    local szCurMagicDesc, szNextMagicDesc = self:FormatMagicDesc(nSkillId, nSkillLevel, nExtLevel)
    if tbInfo.SortInUI ~= 0 then
      local tbSkillListInfo = {
        nId = nSkillId,
        nLevel = nSkillLevel,
        nReqLevel = nReqLevel,
        nCoin = nCoin,
        nExp = nExp,
        nPoint = nPoint,
        bMax = bMax,
        szIcon = tbSkillInfo.Icon or "",
        szName = tbSkillInfo.SkillName or "",
        szDesc = tbSkillInfo.Desc or "",
        szProperty = tbSkillInfo.Property or "",
        nCD = tbSkillInfo.TimePerCast or 0,
        bPassive = tbSkillInfo.SkillType == FightSkill.SkillTypeDef.skill_type_passivity,
        nRadius = tbSkillInfo.AttackRadius or 0,
        nGainLevel = tbInfo.GainLevel,
        nSort = tbInfo.SortInUI,
        szBtnName = tbInfo.BtnName,
        szBtnIcon = tbInfo.BtnIcon,
        szIconAltlas = tbInfo.IconAltlas,
        szCurMagicDesc = szCurMagicDesc or "",
        szNextMagicDesc = szNextMagicDesc or "",
        nExtLevel = nExtLevel
      }
      local bCanLevelUp = nReqLevel <= me.nLevel
      local bGet = 1 <= tbSkillListInfo.nLevel
      tbSkillListInfo.bCanLevelUp = false
      if bCanLevelUp and bGet and not tbSkillListInfo.bMax then
        tbSkillListInfo.bCanLevelUp = true
      end
      if tbSkillInfo.IsAura then
        tbSkillListInfo.bPassive = true
      end
      table.insert(self.tbSkillList, tbSkillListInfo)
    end
  end
  table.sort(self.tbSkillList, function(item1, item2)
    return item1.nSort < item2.nSort
  end)
  local function fnSetItem(tbItemObj, nIndex)
    for nSub = 1, self.nSubItemCount do
      local nSkillIndex = (nIndex - 1) * self.nSubItemCount + nSub
      local tbSkillInfo = self.tbSkillList[nSkillIndex]
      if tbSkillInfo then
        tbItemObj.pPanel:SetActive("SkillItem" .. nSub, true)
        local tbSubItem = tbItemObj["SkillItem" .. nSub]
        tbSubItem.tbParentObj = tbItemObj
        tbSubItem:UpdateInfo(nSub, tbSkillInfo)
      else
        tbItemObj.pPanel:SetActive("SkillItem" .. nSub, false)
      end
    end
  end
  local nUpdateCount = #self.tbSkillList
  self.ScrollView:Update(math.ceil(nUpdateCount / self.nSubItemCount), fnSetItem)
  if Ui:WindowVisible("SkillShow") == 1 then
    local tbSkillShow = Ui("SkillShow")
    if tbSkillShow and tbSkillShow.tbSkillInfo then
      local tbInfo = self:GetSkillInfo(tbSkillShow.tbSkillInfo.nId)
      if tbInfo then
        tbSkillShow:UpdateInfo(tbInfo)
      end
    end
  end
end
function tbSkillPanel:GetSkillInfo(nSkillId)
  for _, tbInfo in pairs(self.tbSkillList) do
    if tbInfo.nId == nSkillId then
      return tbInfo
    end
  end
end
function tbSkillPanel:UpdateSubItem(tbSubItem, nSub, tbSkillInfo)
end
function tbSkillPanel:FormatMagicDesc(nSkillId, nSkillLevel, nExtLevel)
  local szCurMagicDesc, szNextMagicDesc
  local nMaxLevel = FightSkill:GetSkillMaxLevel(nSkillId) + FightSkill:GetSkillLimitAddLevel(me, nSkillId)
  nExtLevel = nExtLevel or 0
  if nSkillLevel == -1 then
    szCurMagicDesc = ""
    szNextMagicDesc = FightSkill:GetSkillMagicDesc(nSkillId, 1)
  elseif nSkillLevel == nMaxLevel then
    szCurMagicDesc = FightSkill:GetSkillMagicDesc(nSkillId, nSkillLevel + nExtLevel)
    szNextMagicDesc = ""
  else
    szCurMagicDesc = FightSkill:GetSkillMagicDesc(nSkillId, nSkillLevel + nExtLevel)
    szNextMagicDesc = FightSkill:GetSkillMagicDesc(nSkillId, nSkillLevel + 1 + nExtLevel)
  end
  return szCurMagicDesc, szNextMagicDesc
end
function tbSkillPanel:OnResponseSkillLevelUp(bSuccess, param1, param2)
  if not bSuccess then
    me.CenterMsg(param1)
    return
  end
  local nSkillId = param1
  local nSkillLevel = param2
  local szSkillName = ""
  for k, v in pairs(self.tbSkillList) do
    if v.nId == nSkillId then
      szSkillName = v.szName
    end
  end
  me.CenterMsg("升级成功")
  self:UpdateSkillList()
end
function tbSkillPanel:OnSyncData(szType)
  local tbSkillBook = Item:GetClass("SkillBook")
  tbSkillBook:UpdateRedPoint(me)
  if szType == "SkillPanelUpdate" then
    self:UpdateSkillList()
  elseif (szType == "SkillBookLevelUp" or szType == "RecycleSkillBook") and self.szChangePanel == "PublicPanel" then
    self:UpdatePublicPanel()
  end
end
function tbSkillPanel:OnSyncItem()
  if self.szChangePanel == "PublicPanel" then
    self:UpdatePublicPanel()
  end
  local tbSkillBook = Item:GetClass("SkillBook")
  tbSkillBook:UpdateRedPoint(me)
end
function tbSkillPanel:RegisterEvent()
  local tbRegEvent = {
    {
      UiNotify.emNOTIFY_SKILL_LEVELUP,
      self.OnResponseSkillLevelUp
    },
    {
      UiNotify.emNOTIFY_CHANGE_MONEY,
      self.ChangeMoney
    },
    {
      UiNotify.emNOTIFY_SYNC_DATA,
      self.OnSyncData
    },
    {
      UiNotify.emNOTIFY_SYNC_ITEM,
      self.OnSyncItem
    }
  }
  return tbRegEvent
end
local tbSkillSubItem = Ui:CreateClass("SkillSubItem")
function tbSkillSubItem:UpdateInfo(nSub, tbSkillInfo)
  local function fnUpgradeSkill(buttonObj)
    local nSkillId = tbSkillInfo.nId
    if tbSkillInfo.nSort == 1 then
      Guide.tbNotifyGuide:ClearNotifyGuide("SkillUpGrade")
    end
    local bRet, szMsg = FightSkill:CheckSkillLeveUp(me, nSkillId)
    if not bRet then
      me.CenterMsg(szMsg)
      return
    end
    RemoteServer.OnSkillLevelUp(nSkillId)
  end
  local nReqLevel = FightSkill:GetSkillLevelUpNeed(tbSkillInfo.nId, tbSkillInfo.nLevel)
  local nReqBaseLevel = FightSkill:GetSkillLevelUpNeed(tbSkillInfo.nId, 0)
  local bCanBaseLevelUp = nReqBaseLevel <= me.nLevel
  local bCanLevelUp = nReqLevel <= me.nLevel
  local bGet = tbSkillInfo.nLevel >= 1
  local function fnSkillIcon(buttonObj)
    if not tbSkillInfo then
      return
    end
    if tbSkillInfo.nSort == 1 then
      Guide.tbNotifyGuide:ClearNotifyGuide("SkillUpGrade")
    end
    Ui:OpenWindow("SkillShow", tbSkillInfo)
  end
  self.BtnUpgrade.pPanel:UnRegisterRedPoint("GuideTips")
  if tbSkillInfo.nSort == 1 then
    Ui:UnRegisterRedPoint("NG_SkillUpGrade")
    self.BtnUpgrade.pPanel:RegisterRedPoint("GuideTips", "NG_SkillUpGrade")
  else
    self.BtnUpgrade.pPanel:SetActive("GuideTips", false)
  end
  self.pPanel.OnTouchEvent = fnSkillIcon
  self.pPanel:SetActive("CompanionSkillIcon", false)
  if bGet and bCanBaseLevelUp then
    self.pPanel:SetActive("TxtNotLearn", false)
    self.pPanel:SetActive("BtnUpgrade", true)
    self.pPanel:SetActive("TxtLevel", true)
    self.PassIveSkillIcon.pPanel:SetActive("PassIveSkillMark", false)
    self.ActiveSkillIcon.pPanel:SetActive("ActiveSkillMark", false)
  else
    self.tbSkillInfo = nil
    self.pPanel:Label_SetText("TxtName", tbSkillInfo.szName)
    if tbSkillInfo.bPassive then
      self.pPanel:SetActive("PassIveSkillIcon", true)
      self.pPanel:SetActive("ActiveSkillIcon", false)
      self.PassIveSkillIcon.pPanel:SetActive("PassIveSkillMark", true)
      self.pPanel:Sprite_SetSprite("PassIveSkillIcon", tbSkillInfo.szIcon, tbSkillInfo.szIconAltlas)
      self.pPanel:Button_SetSprite("PassIveSkillIcon", tbSkillInfo.szIcon)
      self.PassIveSkillIcon.pPanel.OnTouchEvent = fnSkillIcon
    else
      self.pPanel:SetActive("PassIveSkillIcon", false)
      self.pPanel:SetActive("ActiveSkillIcon", true)
      self.ActiveSkillIcon.pPanel:SetActive("ActiveSkillMark", true)
      self.pPanel:Sprite_SetSprite("ActiveSkillIcon", tbSkillInfo.szIcon, tbSkillInfo.szIconAltlas)
      self.pPanel:Button_SetSprite("ActiveSkillIcon", tbSkillInfo.szIcon)
      self.ActiveSkillIcon.pPanel.OnTouchEvent = fnSkillIcon
    end
    local szReqBaseLevel = string.format("%.1f", nReqBaseLevel)
    szReqBaseLevel = string.gsub(szReqBaseLevel, "%.0", "")
    self.pPanel:SetActive("TxtNotLearn", true)
    self.pPanel:Label_SetText("TxtNotLearn", szReqBaseLevel .. "级习得")
    self.pPanel:SetActive("TxtLevel", false)
    self.pPanel:SetActive("BtnUpgrade", false)
    return
  end
  self.pPanel:SetActive("TxtLevel", bGet)
  local nExtSkillLevel = tbSkillInfo.nExtLevel or 0
  self.pPanel:Label_SetText("TxtLevel", string.format("等级:%s/%s", tbSkillInfo.nLevel + nExtSkillLevel, FightSkill:GetSkillMaxLevel(tbSkillInfo.nId) + FightSkill:GetSkillLimitAddLevel(me, tbSkillInfo.nId)))
  self.pPanel:Label_SetText("TxtName", tbSkillInfo.szName)
  self.pPanel:SetActive("BtnUpgrade", not tbSkillInfo.bMax and bGet)
  if tbSkillInfo.bPassive then
    self.pPanel:SetActive("PassIveSkillIcon", true)
    self.pPanel:SetActive("ActiveSkillIcon", false)
    self.pPanel:Sprite_SetSprite("PassIveSkillIcon", tbSkillInfo.szIcon, tbSkillInfo.szIconAltlas)
    self.pPanel:Button_SetSprite("PassIveSkillIcon", tbSkillInfo.szIcon)
    self.PassIveSkillIcon.pPanel.OnTouchEvent = fnSkillIcon
  else
    self.pPanel:SetActive("PassIveSkillIcon", false)
    self.pPanel:SetActive("ActiveSkillIcon", true)
    self.pPanel:Sprite_SetSprite("ActiveSkillIcon", tbSkillInfo.szIcon, tbSkillInfo.szIconAltlas)
    self.pPanel:Button_SetSprite("ActiveSkillIcon", tbSkillInfo.szIcon)
    self.ActiveSkillIcon.pPanel.OnTouchEvent = fnSkillIcon
  end
  self.tbSkillInfo = tbSkillInfo
  if bCanLevelUp and bGet then
    self.pPanel:Button_SetSprite("BtnUpgrade", "Tab3_2")
  else
    self.pPanel:Button_SetSprite("BtnUpgrade", "Tab3_1")
  end
  self.BtnUpgrade.pPanel.OnTouchEvent = fnUpgradeSkill
end
function tbSkillSubItem:PublicUpdateInfo(nSub, tbSkillInfo)
  local function fnSkillIcon(buttonObj)
    if not tbSkillInfo then
      return
    end
    Ui:OpenWindow("SkillShow", tbSkillInfo)
  end
  self.pPanel:SetActive("TxtLevel", true)
  self.pPanel:Label_SetText("TxtLevel", string.format("等级:%s/%s", tbSkillInfo.nLevel, tbSkillInfo.nMaxLevel or tbSkillInfo.nLevel))
  self.pPanel:Label_SetText("TxtName", tbSkillInfo.szName)
  self.pPanel:SetActive("BtnUpgrade", false)
  self.pPanel:SetActive("CompanionSkillIcon", false)
  self.pPanel:SetActive("PassIveSkillIcon", false)
  self.pPanel:SetActive("ActiveSkillIcon", false)
  if tbSkillInfo.bPartner or tbSkillInfo.bJingMai then
    self.pPanel:SetActive("CompanionSkillIcon", true)
    self.pPanel:Sprite_SetSprite("CompanionSkillIcon", tbSkillInfo.szIcon, tbSkillInfo.szIconAltlas)
    self.pPanel:Button_SetSprite("CompanionSkillIcon", tbSkillInfo.szIcon)
    self.CompanionSkillIcon.pPanel.OnTouchEvent = fnSkillIcon
  elseif tbSkillInfo.bPassive then
    self.pPanel:SetActive("PassIveSkillIcon", true)
    self.pPanel:Sprite_SetSprite("PassIveSkillIcon", tbSkillInfo.szIcon, tbSkillInfo.szIconAltlas)
    self.pPanel:Button_SetSprite("PassIveSkillIcon", tbSkillInfo.szIcon)
    self.PassIveSkillIcon.pPanel.OnTouchEvent = fnSkillIcon
  else
    self.pPanel:SetActive("ActiveSkillIcon", true)
    self.pPanel:Sprite_SetSprite("ActiveSkillIcon", tbSkillInfo.szIcon, tbSkillInfo.szIconAltlas)
    self.pPanel:Button_SetSprite("ActiveSkillIcon", tbSkillInfo.szIcon)
    self.ActiveSkillIcon.pPanel.OnTouchEvent = fnSkillIcon
  end
  self.tbSkillInfo = tbSkillInfo
end
