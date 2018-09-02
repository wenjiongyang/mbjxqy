local tbUi = Ui:CreateClass("AutoSkillSetting")
local nAutoSkillCount = FightSkill.NORMAL_SKILL_COUNT + 1
function tbUi:RegisterEvent()
  local tbRegEvent = {
    {
      UiNotify.emNOTIFY_MAP_LEAVE,
      self.AutoClose
    },
    {
      UiNotify.emNOTIFY_FINISH_PERSONALFUBEN,
      self.AutoClose
    },
    {
      UiNotify.emNOTIFY_SHOW_DIALOG,
      self.AutoClose
    }
  }
  return tbRegEvent
end
function tbUi:OnOpenEnd()
  local tbSetting = AutoFight:GetSetting()
  local nBegin = 1
  local nEnd = nAutoSkillCount
  for i = 1, nAutoSkillCount do
    local tbSkill = tbSetting[i]
    local nLevel = me.GetSkillLevel(tbSkill.nSkillId)
    if nLevel > 0 then
      self["SkillIcon" .. nBegin].tbSkill = tbSkill
      tbSkill.bShow = true
      nBegin = nBegin + 1
    else
      self["SkillIcon" .. nEnd].tbSkill = tbSkill
      tbSkill.bActive = false
      tbSkill.bShow = false
      nEnd = nEnd - 1
    end
  end
  local nJiuId = Item:GetClass("jiu").nTemplateId
  local nCount = me.GetItemCountInAllPos(nJiuId) or 0
  self.itemframe:SetItemByTemplate(nJiuId, nCount)
  self.itemframe.fnClick = self.itemframe.DefaultClick
  self:Update()
  local nSelectMode = Operation:GetSelectTargetMode()
  if nSelectMode == Operation.eTargetModeUnlimited then
    self.pPanel:Toggle_SetChecked("Unlimited", true)
  elseif nSelectMode == Operation.eTargetModeNpcFirst then
    self.pPanel:Toggle_SetChecked("NPC", true)
  elseif nSelectMode == Operation.eTargetModePlayerFirst then
    self.pPanel:Toggle_SetChecked("Player", true)
  end
  Guide.tbNotifyGuide:ClearNotifyGuide("AutoFightSettingGuide")
end
function tbUi:OnClose()
  local bNpcFirst = self.pPanel:Toggle_GetChecked("NPC")
  local bPlayerFirst = self.pPanel:Toggle_GetChecked("Player")
  local nSelectMode = Operation.eTargetModeUnlimited
  if bNpcFirst then
    nSelectMode = Operation.eTargetModeNpcFirst
  elseif bPlayerFirst then
    nSelectMode = Operation.eTargetModePlayerFirst
  end
  Operation:SetSelectTargetMode(nSelectMode)
  Ui.UiManager.DisableDragSprite()
end
function tbUi:Update()
  for i = 1, nAutoSkillCount do
    local skillObj = self["SkillIcon" .. i]
    skillObj.pPanel:SetActive("Main", skillObj.tbSkill.bShow)
    if skillObj.tbSkill.bShow then
      local tbIcon, _ = FightSkill:GetSkillShowInfo(skillObj.tbSkill.nSkillId)
      skillObj.pPanel:Toggle_SetChecked("Main", skillObj.tbSkill.bActive)
      skillObj.pPanel:SetActive("Mark", not skillObj.tbSkill.bActive)
      skillObj.pPanel:Sprite_SetSprite("Main", tbIcon.szIconSprite, tbIcon.szIconAtlas)
      local tbSkillFactionInfo = FightSkill:GetSkillFactionInfo(skillObj.tbSkill.nSkillId) or {}
      local bAngerSkill = tbSkillFactionInfo.IsAnger == 1
      skillObj.pPanel:SetActive("AngerSkill", bAngerSkill)
    end
  end
  self.pPanel:Toggle_SetChecked("CheckBoxItem", not Client:GetFlag("NotAutoUseJiu") or false)
  self.pPanel:Toggle_SetChecked("CheckBoxItem2", not Ui:CheckNotShowTips("ShowAutoBuyJiu|NEVER"))
  local tbSetting = AutoFight:GetSetting()
  for i = 1, nAutoSkillCount do
    tbSetting[i] = self["SkillIcon" .. i].tbSkill
  end
end
tbUi.tbOnClick = {}
function tbUi.tbOnClick:BtnClose()
  AutoFight:SaveSetting()
  UiNotify.OnNotify(UiNotify.emNOTIFY_AUTO_SKILL_CHANGED)
  Ui:CloseWindow("AutoSkillSetting")
end
function tbUi.tbOnClick:CheckBoxItem()
  if self.pPanel:Toggle_GetChecked("CheckBoxItem") then
    Client:ClearFlag("NotAutoUseJiu")
  else
    Client:SetFlag("NotAutoUseJiu")
  end
end
function tbUi.tbOnClick:CheckBoxItem2()
  if self.pPanel:Toggle_GetChecked("CheckBoxItem2") then
    Ui:SetNotShowTips("ShowAutoBuyJiu|NEVER", false)
  else
    Ui:SetNotShowTips("ShowAutoBuyJiu|NEVER", true)
  end
end
tbUi.tbOnDrag = {}
tbUi.tbOnDrop = {}
for i = 1, nAutoSkillCount do
  tbUi.tbOnDrag["SkillIcon" .. i] = function(self, szWnd, ...)
    self:StartDrag(i, szWnd)
  end
  tbUi.tbOnDrop["SkillIcon" .. i] = function(self, szWnd, szDropWnd)
    self:OnDropSwitch(szWnd, szDropWnd)
  end
  tbUi.tbOnClick["SkillIcon" .. i] = function(self)
    local skillObj = self["SkillIcon" .. i]
    skillObj.tbSkill.bActive = skillObj.pPanel:Toggle_GetChecked("Main")
    self:Update()
  end
end
function tbUi:StartDrag(nPosId, szWnd)
  local orgObj = self[szWnd]
  if orgObj.tbSkill.bShow then
    local tbIcon, _ = FightSkill:GetSkillShowInfo(orgObj.tbSkill.nSkillId)
    self.pPanel:StartDrag(tbIcon.szIconAtlas, tbIcon.szIconSprite)
  end
end
function tbUi:OnDropSwitch(szWnd, szDropWnd)
  local szPosIdx = string.match(szWnd, "^SkillIcon(%d)")
  local szDropPosIdx = string.match(szDropWnd, "^SkillIcon(%d)")
  if not szPosIdx or not szDropPosIdx then
    return
  end
  local orgObj = self[szWnd]
  local targetObj = self[szDropWnd]
  if not orgObj.tbSkill.bShow or not targetObj.tbSkill.bShow then
    return
  end
  orgObj.tbSkill, targetObj.tbSkill = targetObj.tbSkill, orgObj.tbSkill
  self:Update()
end
function tbUi:AutoClose()
  Ui:CloseWindow("AutoSkillSetting")
end
