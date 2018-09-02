local tbRoleHead = Ui:CreateClass("RoleHead")
tbRoleHead.nTotalBuff = 6
tbRoleHead.tbSkillStateInfo = tbRoleHead.tbSkillStateInfo or {}
tbRoleHead.tbOnClick = {
  CurrentHead = function()
    Ui:OpenWindow("RoleInformationPanel")
  end,
  SpGoldBg = function(self)
    if me.nLevel >= Shop.SHOW_LEVEL then
      Ui:OpenWindow("CommonShop", "Recharge", "Recharge")
    end
  end,
  SpCoinBg = function(self)
    local nLevel = WelfareActivity:GetActivityOpenLevel("MoneyTreePanel")
    if nLevel <= me.nLevel then
      Ui:OpenWindow("WelfareActivity", "MoneyTreePanel")
    end
  end,
  BtnGM = function(self)
    GMCommand("GM:TestCommander()")
  end,
  BtnMount = function(self)
    local nCurAction = me.GetActionMode()
    local nActionMode = Npc.NpcActionModeType.act_mode_none
    if nCurAction == Npc.NpcActionModeType.act_mode_none then
      nActionMode = Npc.NpcActionModeType.act_mode_ride
      if AutoFight:IsAuto() then
        AutoFight:SwitchState()
      end
    end
    Guide.tbNotifyGuide:ClearNotifyGuide("MountGuide")
    ActionMode:CallDoActionMode(nActionMode, true)
  end,
  BtnPowerSaving = function(self)
    local fnAgree = function()
      Ui:SwitchSaveBatteryMode(true)
    end
    Ui:OpenWindow("MessageBox", "你确定要关闭省电模式吗？", {
      {fnAgree},
      {}
    }, {"同意", "取消"})
  end
}
function tbRoleHead:OnOpen()
  if me.dwID == 0 then
    return 0
  end
  self:UpdateALL()
  self:UpdateAllSkillState()
  self.pPanel:SetActive("BUFF", true)
  ChangeName:CheckShowRedPoint()
  self:Operation(not Operation.bOnJoyStick)
  self:OnChangeWarn(false)
  if not Sdk:IsEfunHKTW() and not Sdk:IsMsdk() then
    Guide.tbNotifyGuide:ClearNotifyGuide("BindingMailGuideAndroid")
    Guide.tbNotifyGuide:ClearNotifyGuide("BindingMailGuideIOS")
  end
end
function tbRoleHead:Operation(bShow)
  self:CheckRideHorse(bShow)
end
function tbRoleHead:CheckRideHorse(bShow)
  if bShow then
    local pEquip = me.GetEquipByPos(Item.EQUIPPOS_HORSE)
    if not pEquip or Map:IsForbidRide(me.nMapTemplateId) then
      self.pPanel:SetActive("BtnMount", false)
    else
      self.pPanel:SetActive("BtnMount", true)
    end
  else
    self.pPanel:SetActive("BtnMount", false)
  end
end
function tbRoleHead:UpdateALL()
  self:ChangePlayerHp()
  self:ChangePlayerExp()
  self:ChangePlayerLevel()
  self:ChangeFightPower()
  self:ChangeMoney()
  self:UpdateVipLevel()
  self:ChangePortrait()
  self:ChangeBattleryBtn()
  self:UpdateTeamDescBuff()
  self.pPanel:Sprite_SetSprite("FactionIcon", Faction:GetIcon(me.nFaction))
  local nQQVip = me.GetQQVipInfo()
  self.pPanel:SetActive("QQvipBg", nQQVip ~= Player.QQVIP_NONE and not Client:IsCloseIOSEntry() and not Sdk:IsOuterChannel())
  if nQQVip == Player.QQVIP_VIP then
    self.pPanel:Sprite_SetSprite("QQvip", "QQvip")
  elseif nQQVip == Player.QQVIP_SVIP then
    self.pPanel:Sprite_SetSprite("QQvip", "QQsvip")
  end
end
function tbRoleHead:UpdateVipLevel()
  local nLevel = me.GetVipLevel() or 0
  self.pPanel:Label_SetText("VipLevel", nLevel)
  self.pPanel:SetActive("VIPIcon", nLevel > 0)
  if nLevel > 0 then
    self.pPanel:Sprite_Animation("VIPIcon", Recharge.VIP_SHOW_LEVEL[nLevel])
  end
end
function tbRoleHead:ChangePlayerHp()
  local pNpc = me.GetNpc()
  if not pNpc then
    return
  end
  local fHpPer = pNpc.nCurLife / pNpc.nMaxLife
  self.pPanel:Sprite_SetFillPercent("BloodProcess", fHpPer)
  local szHp = string.format("%d / %d", pNpc.nCurLife, pNpc.nMaxLife)
  self.pPanel:Label_SetText("BloodFigure", szHp)
end
function tbRoleHead:ChangeBattleryBtn()
  if Ui.bOnSaveBatteryMode then
    self.pPanel:SetActive("BtnPowerSaving", true)
  else
    self.pPanel:SetActive("BtnPowerSaving", false)
  end
end
function tbRoleHead:ChangePlayerExp()
end
function tbRoleHead:ChangePlayerLevel(nOrgLevel, nCurLevel)
  self.pPanel:Label_SetText("LBLevel", me.nFakeLevel and me.nFakeLevel or me.nLevel)
end
function tbRoleHead:ChangeFightPower(nFightPower)
  local pNpc = me.GetNpc()
  if not pNpc then
    return
  end
  local nFightPower = pNpc.GetFightPower()
  self.pPanel:Label_SetText("FightPowerText", nFightPower)
end
function tbRoleHead:ChangeMoney()
  self.pPanel:Label_SetText("CoinCount", me.GetMoney("Coin"))
  self.pPanel:Label_SetText("GoldCount", me.GetMoney("Gold"))
end
function tbRoleHead:ChangePortrait()
  local tbSetting = PlayerPortrait:GetPortraitSetting(me.nPortrait) or {}
  self.pPanel:Sprite_SetSprite("CurrentHead", tbSetting.szIcon, tbSetting.szIconAtlas)
end
function tbRoleHead:BtnBuff()
  self:Refresh()
  if not self.tbSkillStateInfo or not next(self.tbSkillStateInfo) then
    return
  end
  Ui:OpenWindow("BuffTip", self.tbSkillStateInfo)
end
function tbRoleHead:ClearAllSkillSate(bNotClearInfo)
  for nI = 1, tbRoleHead.nTotalBuff do
    self.pPanel:SetActive("BUFF" .. nI, false)
  end
  if not bNotClearInfo then
    self.tbSkillStateInfo = {}
  end
end
function tbRoleHead:UpdateAllSkillState()
  self:ClearAllSkillSate()
  local pNpc = me.GetNpc()
  if not pNpc then
    return
  end
  local tbAllSkillState = pNpc.GetAllSkillState() or {}
  for _, tbState in pairs(tbAllSkillState) do
    self:AddSkillState(tbState)
  end
end
function tbRoleHead:GetSkillStateIndex(nCurSkillId)
  for nIndex, tbInfo in pairs(self.tbSkillStateInfo) do
    if tbInfo.nSkillId == nCurSkillId then
      return nIndex, true
    end
  end
  local nTotalCount = #self.tbSkillStateInfo
  return nTotalCount + 1, false
end
function tbRoleHead:AddSkillState(tbState)
  if not tbState or tbState.nEndFrame <= 0 then
    return
  end
  if not FightSkill:IsShowSkillState(tbState.nSkillId, tbState.nSkillLevel) then
    return
  end
  local nFrame = tbState.nEndFrame - GetFrame()
  if nFrame <= 0 then
    return
  end
  local nIndex = self:GetSkillStateIndex(tbState.nSkillId)
  self.tbSkillStateInfo[nIndex] = {
    nSkillId = tbState.nSkillId
  }
  if nIndex > tbRoleHead.nTotalBuff then
    return
  end
  local szBuffName = "BUFF" .. nIndex
  local tbStateEffect = FightSkill:GetStateEffectBySkill(tbState.nSkillId, tbState.nSkillLevel)
  self.pPanel:SetActive(szBuffName, true)
  self.pPanel:Sprite_SetSprite(szBuffName, tbStateEffect.Icon, tbStateEffect.IconAtlas)
  local fTime = nFrame / Env.GAME_FPS
  local fTotalTime = tbState.nTotalFrame / Env.GAME_FPS
  self.pPanel:Sprite_SetCDControl("Mask" .. nIndex, fTime, fTotalTime)
end
tbRoleHead.tbOnClick.BUFF = tbRoleHead.BtnBuff
function tbRoleHead:OnAddSkillState(nSkillId)
  local pNpc = me.GetNpc()
  local tbState = pNpc.GetSkillState(nSkillId)
  self:AddSkillState(tbState)
  self:Refresh()
end
function tbRoleHead:Refresh()
  local pNpc = me.GetNpc()
  if not pNpc then
    return
  end
  for nIndex, tbInfo in pairs(self.tbSkillStateInfo) do
    local tbState = pNpc.GetSkillState(tbInfo.nSkillId)
    if not tbState or tbState.nEndFrame <= 0 then
      self:RemoveSkillState(tbInfo.nSkillId)
    end
  end
end
function tbRoleHead:ResetAddSkillState()
  self:ClearAllSkillSate(true)
  local pNpc = me.GetNpc()
  for _, tbInfo in pairs(self.tbSkillStateInfo) do
    local tbState = pNpc.GetSkillState(tbInfo.nSkillId)
    self:AddSkillState(tbState)
  end
end
function tbRoleHead:RemoveSkillState(nSkillId)
  local nIndex, bExist = self:GetSkillStateIndex(nSkillId)
  if not bExist then
    return
  end
  table.remove(self.tbSkillStateInfo, nIndex)
  self:ResetAddSkillState()
end
function tbRoleHead:OnRemoveSkillState(nSkillId)
  self:RemoveSkillState(nSkillId)
end
function tbRoleHead:OnMapLoaded(nMapTID)
  self:CheckRideHorse(not Operation.bOnJoyStick)
end
function tbRoleHead:OnSyncItem()
  self:CheckRideHorse(not Operation.bOnJoyStick)
end
function tbRoleHead:OnDelItem()
  self:CheckRideHorse(not Operation.bOnJoyStick)
end
function tbRoleHead:OnChangeDoSit(nCurDoing, enoing)
end
function tbRoleHead:UpdateTeamDescBuff()
  if self:ChekcAddTeamDescBuffEx() then
    self:ChekcAddTeamDescBuff()
  end
end
function tbRoleHead:ChekcAddTeamDescBuffEx()
  local szMsg, bNeedCheck = FriendShip:GetTeamAddExpDesc()
  if not bNeedCheck then
    self.nTimerTeamDescBuff = nil
    if not me.GetNpc() then
      return
    end
    me.GetNpc().RemoveSkillState(FriendShip.nTeamHelpBuffId)
    return
  end
  if not Lib:IsEmptyStr(szMsg) then
    me.GetNpc().AddSkillState(FriendShip.nTeamHelpBuffId, 1, 0, 61 * Env.GAME_FPS, 1, 1)
  else
    me.GetNpc().RemoveSkillState(FriendShip.nTeamHelpBuffId)
  end
  return true
end
function tbRoleHead:ChekcAddTeamDescBuff()
  if self.nTimerTeamDescBuff then
    return
  end
  self.nTimerTeamDescBuff = Timer:Register(Env.GAME_FPS * 60, self.ChekcAddTeamDescBuffEx, self)
end
function tbRoleHead:OnChangeWarn(bShow)
  self.pPanel:SetActive("canxiejinggao", false)
  if bShow then
    self.pPanel:SetActive("canxiejinggao", true)
  end
end
function tbRoleHead:RegisterEvent()
  local tbRegEvent = {
    {
      UiNotify.emNOTIFY_CHANGE_PLAYER_HP,
      self.ChangePlayerHp
    },
    {
      UiNotify.emNOTIFY_CHANGE_PLAYER_EXP,
      self.ChangePlayerExp
    },
    {
      UiNotify.emNOTIFY_CHANGE_PLAYER_LEVEL,
      self.ChangePlayerLevel
    },
    {
      UiNotify.emNOTIFY_CHANGE_ADD_FIGHT_POWER,
      self.ChangeFightPower
    },
    {
      UiNotify.emNOTIFY_CHANGE_MONEY,
      self.ChangeMoney
    },
    {
      UiNotify.emNOTIFY_CHANGE_VIP_LEVEL,
      self.UpdateVipLevel
    },
    {
      UiNotify.emNOTIFY_CHANGE_PORTRAIT,
      self.ChangePortrait
    },
    {
      UiNotify.emNOTIFY_ADD_SKILL_STATE,
      self.OnAddSkillState
    },
    {
      UiNotify.emNOTIFY_REMOVE_SKILL_STATE,
      self.OnRemoveSkillState
    },
    {
      UiNotify.emNOTIFY_SYNC_ITEM,
      self.OnSyncItem
    },
    {
      UiNotify.emNOTIFY_DEL_ITEM,
      self.OnDelItem
    },
    {
      UiNotify.emNOTIFY_MAP_LOADED,
      self.OnMapLoaded
    },
    {
      UiNotify.emNOTIFY_CHANGE_SIT,
      self.OnChangeDoSit
    },
    {
      UiNotify.emNOTIFY_UPDATE_QQ_VIP_INFO,
      self.UpdateALL
    },
    {
      UiNotify.emNOTIFY_CHANGE_SAVE_BATTERY_MODE,
      self.ChangeBattleryBtn
    },
    {
      UiNotify.emNOTIFY_TEAM_UPDATE,
      self.UpdateTeamDescBuff
    },
    {
      UiNotify.emNOTIFY_CHANG_ROLE_WARN,
      self.OnChangeWarn
    }
  }
  return tbRegEvent
end
