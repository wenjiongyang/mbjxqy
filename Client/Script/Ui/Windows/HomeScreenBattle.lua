local tbBattleUi = Ui:CreateClass("HomeScreenBattle")
tbBattleUi.nDaZuoSkill = 1013
tbBattleUi.tbUseSkill = {}
tbBattleUi.tbOnClick = {}
tbBattleUi.tbForbidBuffJumpMsg = {
  [1457] = 1
}
tbBattleUi.nShowJumpMsgTime = 2
tbBattleUi.tbBtnSkill = {
  Attack = 0,
  Skill1 = 0,
  Skill2 = 0,
  Skill3 = 0,
  Skill4 = 0,
  Skill5 = 0,
  SkillDodge = 0,
  BtnDazuo = 0
}
tbBattleUi.tbAttackEffect = {
  Attack = "texiao",
  Skill1 = "texiao1",
  Skill2 = "texiao2",
  Skill3 = "texiao3",
  Skill4 = "texiao4",
  Skill5 = "texiao5",
  SkillDodge = "texiaoSkillDodge",
  BtnDazuo = "texiaoBtnDazuo"
}
tbBattleUi.tbCanCancelChangeSkill = {
  [2218] = 1,
  [2219] = 1,
  [2220] = 1
}
tbBattleUi.nAngerSkill = 0
tbBattleUi.szAngerEffect = "nuqi_ui"
tbBattleUi.szBtnAngerName = "Skill5"
tbBattleUi.szBtnJumpName = "SkillDodge"
tbBattleUi.tbColseTimerAttack = tbBattleUi.tbColseTimerAttack or {}
tbBattleUi.tbOpenTimerAttack = tbBattleUi.tbOpenTimerAttack or {}
function tbBattleUi:IsShowForbidJumpMsg()
  if self.nShowJumpMsgTimer then
    return false
  end
  local pNpc = me.GetNpc()
  for nSkillBuff, _ in pairs(tbBattleUi.tbForbidBuffJumpMsg) do
    local tbSkillState = pNpc.GetSkillState(nSkillBuff)
    if tbSkillState then
      return true
    end
  end
  return false
end
for szBtnName, _ in pairs(tbBattleUi.tbBtnSkill) do
  tbBattleUi.tbOnClick[szBtnName] = function(self, tbGameObj)
    local nActMode = me.GetActionMode()
    if nActMode ~= Npc.NpcActionModeType.act_mode_none then
      ActionMode:CallDoActionMode(Npc.NpcActionModeType.act_mode_none, true)
      return
    end
    local pNpc = me.GetNpc()
    if szBtnName == tbBattleUi.szBtnJumpName then
      if OnHook:IsOnLineOnHook(me) and not OnHook:IsOnLineOnHookForce(me) then
        me.CenterMsg("在线托管状态下无法施展轻功")
        return
      end
      local bRet = self:IsShowForbidJumpMsg()
      if bRet then
        if self.nShowJumpMsgTimer then
          Timer:Close(self.nShowJumpMsgTimer)
          self.nShowJumpMsgTimer = nil
        end
        self.nShowJumpMsgTimer = Timer:Register(Env.GAME_FPS * tbBattleUi.nShowJumpMsgTime, function()
          self.nShowJumpMsgTimer = nil
        end)
        me.Msg("你正处于锁足状态，无法施展轻功")
      end
    end
    local nSkillId = tbBattleUi.tbBtnSkill[szBtnName]
    if nSkillId > 0 then
      if tbBattleUi.szBtnJumpName == szBtnName then
        Operation:ManualJump(nSkillId)
      else
        Operation:Attack(nSkillId, nSkillId == self.nAngerSkill)
      end
    end
    if szBtnName ~= "Attack" and self.nLongPressAttackTimer then
      Timer:Close(self.nLongPressAttackTimer)
      self.nLongPressAttackTimer = nil
    end
  end
end
function tbBattleUi.tbOnClick:BtnDazuo()
  if OnHook:IsOnLineOnHook(me) and not OnHook:IsOnLineOnHookForce(me) then
    me.CenterMsg("在线托管状态下不能打坐")
    return
  end
  local nDoing = me.GetDoing()
  if nDoing == Npc.Doing.sit then
    local _, nX, nY = me.GetWorldPos()
    me.GotoPosition(nX + 1, nY)
    return
  end
  local nActMode = me.GetActionMode()
  if nActMode ~= Npc.NpcActionModeType.act_mode_none then
    ActionMode:CallDoActionMode(Npc.NpcActionModeType.act_mode_none, true)
    return
  end
  if nDoing == Npc.Doing.stand or nDoing == Npc.Doing.run then
    me.UseSkill(tbBattleUi.tbBtnSkill.BtnDazuo, -1, me.GetNpc().nId)
  else
    me.CenterMsg("当前状态不能使用打坐")
  end
end
function tbBattleUi.tbOnClick:BtnCancelChange()
  local nSkillId = self:GetChangeCancelSkillId()
  if nSkillId then
    local function fnYes()
      RemoteServer.RequestRemoveSkillState(nSkillId)
    end
    Ui:OpenWindow("MessageBox", "您确定取消变身吗", {
      {fnYes},
      {}
    }, {"同意", "取消"})
  end
end
function tbBattleUi.tbOnClick:BtnAggregate()
  RemoteServer.FocusSelfAllPet()
end
tbBattleUi.tbOnPress = tbBattleUi.tbOnPress or {}
function tbBattleUi.tbOnPress:Attack(szBtnName, bIsPress, nNow)
  if self.nLongPressAttackTimer then
    Timer:Close(self.nLongPressAttackTimer)
    self.nLongPressAttackTimer = nil
  end
  if bIsPress then
    self.nLongPressAttackTimer = Timer:Register(3, function()
      if me.nFightMode == 0 or AutoFight:IsAuto() then
        self.nLongPressAttackTimer = nil
        return false
      end
      self.tbOnClick.Attack(self)
      return true
    end)
    self:StartBtnEffect("Attack")
  end
end
for szBtnName, _ in pairs(tbBattleUi.tbBtnSkill) do
  if szBtnName ~= "Attack" then
    tbBattleUi.tbOnPress[szBtnName] = function(self, szBtn, bIsPress, nNow)
      if bIsPress then
        local nSkillId = tbBattleUi.tbBtnSkill[szBtnName]
        if nSkillId > 0 and me.nFightMode ~= Npc.FIGHT_MODE.emFightMode_None and Operation:IsNeedOpenPreciseUI(nSkillId) then
          Operation:OpenPreciseUI(nSkillId)
          return
        end
        self:StartBtnEffect(szBtnName)
      elseif Ui:WindowVisible("SkillShow") == 1 then
        Ui:CloseWindow("SkillShow")
      end
    end
  end
end
function tbBattleUi:ShowSkillInfo(nSkillId, nSkillLevel, tbWorldPos)
  local _, nSkillLevel1 = me.GetSkillLevel(nSkillId)
  local nExtLevel = 0
  if nSkillLevel1 > 0 then
    nExtLevel = me.GetAddAllFactionLevel(nSkillId)
  end
  local tbSkillShowInfo = FightSkill:GetSkillShowTipInfo(nSkillId, nSkillLevel + nExtLevel)
  tbSkillShowInfo.bMax = false
  tbSkillShowInfo.bNotNextInfo = true
  tbSkillShowInfo.nLevel = nSkillLevel
  tbSkillShowInfo.nExtLevel = nExtLevel
  tbSkillShowInfo.nMaxLevel = nSkillLevel
  Ui:OpenWindow("SkillShow", tbSkillShowInfo, tbWorldPos)
end
function tbBattleUi:StartBtnEffect(szBtnName)
  local szEffectName = tbBattleUi.tbAttackEffect[szBtnName]
  self:CloseAttackTimer(szEffectName)
  self.pPanel:SetActive(szEffectName, false)
  self.tbOpenTimerAttack[szEffectName] = Timer:Register(1, self.OpenActiveEffect, self, szEffectName)
end
function tbBattleUi:OpenActiveEffect(szName)
  self.pPanel:SetActive(szName, true)
  self.tbOpenTimerAttack[szName] = nil
  self:CloseAttackTimer(szName)
  self.tbColseTimerAttack[szName] = Timer:Register(Env.GAME_FPS * 2, self.CloseActiveEffect, self, szName)
end
function tbBattleUi:CloseActiveEffect(szName)
  self.pPanel:SetActive(szName, false)
  self.tbColseTimerAttack[szName] = nil
  self:CloseAttackTimer(szName)
end
function tbBattleUi:CloseAttackTimer(szName)
  if self.tbColseTimerAttack[szName] then
    Timer:Close(self.tbColseTimerAttack[szName])
    self.tbColseTimerAttack[szName] = nil
  end
  if self.tbOpenTimerAttack[szName] then
    Timer:Close(self.tbOpenTimerAttack[szName])
    self.tbOpenTimerAttack[szName] = nil
  end
end
function tbBattleUi:CloseAllAttackTimer()
  for _, szName in pairs(tbBattleUi.tbAttackEffect) do
    self:CloseAttackTimer(szName)
  end
end
function tbBattleUi:SetSkillBtnInfo(tbInfo)
  if tbInfo.BtnName ~= nil and tbInfo.BtnName ~= "" then
    self.pPanel:SetActive(tbInfo.BtnName, true)
    self.tbUseSkill[tbInfo.SkillId] = {
      SkillId = tbInfo.SkillId,
      szBtnName = tbInfo.BtnName,
      bShow = true,
      BtnIcon = tbInfo.BtnIcon,
      IconAltlas = tbInfo.IconAltlas,
      GainLevel = tbInfo.GainLevel or 0
    }
    local nLevel = me.GetSkillLevel(tbInfo.SkillId)
    if nLevel <= 0 then
      self.pPanel:Sprite_SetFillPercent(tbInfo.BtnName .. "CD", 1)
      self.pPanel:Label_SetText(tbInfo.BtnName .. "CDTime", "")
      self.pPanel:SetActive(tbInfo.BtnName .. "Time", false)
      self.tbUseSkill[tbInfo.SkillId].bShow = false
      if tbInfo.BtnName == self.szBtnJumpName then
        self.pPanel:SetActive(self.szBtnJumpName, false)
      end
    end
    self.tbBtnSkill[tbInfo.BtnName] = tbInfo.SkillId
    self.pPanel:SetActive(tbInfo.BtnName .. "Icon", true)
    self.pPanel:Button_SetEnabled(tbInfo.BtnName .. "Icon", true)
    if tbInfo.BtnIcon then
      self.pPanel:Sprite_SetSprite(tbInfo.BtnName .. "Icon", tbInfo.BtnIcon, tbInfo.IconAltlas)
    else
      self.pPanel:SetActive(tbInfo.BtnName .. "Icon", false)
    end
  end
  if tbInfo.IsAnger and 1 <= tbInfo.IsAnger then
    self.pPanel:SetActive(tbInfo.BtnName, false)
    self.nAngerSkill = tbInfo.SkillId
  end
end
function tbBattleUi:SetSkillSlotInfo(nSkillId)
  local tbSlotInfo = FightSkill:GetSkillSlotByID(nSkillId)
  if not tbSlotInfo then
    return
  end
  local nLevel = me.GetSkillLevel(nSkillId)
  if nLevel <= 0 then
    return
  end
  local szFindBtnName
  for _, szBtnName in ipairs(tbSlotInfo.tbBtnName) do
    local bFindName = true
    for _, tbInfo in pairs(self.tbUseSkill) do
      if tbInfo.szBtnName == szBtnName then
        bFindName = false
        break
      end
    end
    if bFindName then
      szFindBtnName = szBtnName
      break
    end
  end
  if not szFindBtnName then
    return
  end
  local tbSetInfo = {
    SkillId = nSkillId,
    BtnName = szFindBtnName,
    BtnIcon = tbSlotInfo.szIcon,
    IconAltlas = tbSlotInfo.szIconAltlas
  }
  self:SetSkillBtnInfo(tbSetInfo)
  self:UpdateSkillCD(nSkillId)
  if self.tbUseSkill[nSkillId] and self.bForbidSkill then
    self:ForbidSkillBtnUI(szFindBtnName)
    self.tbUseSkill[nSkillId].bForbidSkill = true
  end
end
function tbBattleUi:ClearBtnInfo(szBtnName)
  self.pPanel:SetActive(szBtnName, false)
  self.pPanel:SetActive(szBtnName .. "Icon", false)
  self.pPanel:Button_SetEnabled(szBtnName .. "Icon", false)
  self.pPanel:Sprite_SetCDControl(szBtnName .. "CD", 0, 0)
  self.pPanel:Sprite_SetFillPercent(szBtnName .. "CD", 1)
  self.pPanel:SetActive(szBtnName .. "CD", true)
end
function tbBattleUi:ResetUseSkill(tbShowSkillInfo, bNotAutoSkill)
  self.tbUseSkill = {}
  tbShowSkillInfo = tbShowSkillInfo or FightSkill:GetFactionSkill(me.nFaction)
  for szBtnName, _ in pairs(self.tbBtnSkill) do
    self:ClearBtnInfo(szBtnName)
  end
  for _, tbInfo in pairs(tbShowSkillInfo) do
    self:SetSkillBtnInfo(tbInfo)
  end
  for nSlotSkill, _ in pairs(FightSkill.tbFightSkillSlot) do
    self:SetSkillSlotInfo(nSlotSkill)
  end
  self:CloseAllSkillTimer()
  for nSkillID, tbInfo in pairs(self.tbUseSkill) do
    self:UpdateSkillCD(nSkillID)
  end
  if self.nShapeShiftNpcTID == 0 then
    self:UpdateAnger()
  else
    self.pPanel:SetActive(self.szBtnAngerName, false)
  end
  if not bNotAutoSkill then
    AutoFight:ResetFightState()
    self:UpdateAutoFightButton()
  else
    self.pPanel:SetActive("BtnChangeFightState", false)
    AutoFight:ChangeState(AutoFight.OperationType.Manual)
  end
  self:CheckDaZuo()
end
function tbBattleUi:GetShapeShiftSkillInfo(nNpcTID)
  if nNpcTID <= 0 then
    return
  end
  local tbNpShapeShift = FightSkill:GetNpShapeShift(nNpcTID)
  if not tbNpShapeShift then
    return
  end
  local tbSkillInfo = {}
  for nIndex, tbSkill in pairs(tbNpShapeShift.tbAllSkill) do
    if nIndex >= 0 and nIndex <= 4 then
      local szBtnName = "Skill" .. nIndex
      if nIndex == 0 then
        szBtnName = "Attack"
      end
      local tbInfo = {
        SkillId = tbSkill.nSkillID,
        BtnName = szBtnName,
        BtnIcon = tbSkill.szBtnIcon,
        IconAltlas = tbNpShapeShift.szIconAltlas
      }
      tbSkillInfo[tbInfo.SkillId] = tbInfo
    end
  end
  if tbNpShapeShift.tbJumpSkill then
    local tbInfo = {
      SkillId = tbNpShapeShift.tbJumpSkill.nSkillID,
      BtnName = "SkillDodge",
      BtnIcon = tbNpShapeShift.tbJumpSkill.szBtnIcon,
      IconAltlas = tbNpShapeShift.szJumpIconAltlas
    }
    tbSkillInfo[tbInfo.SkillId] = tbInfo
  end
  return tbSkillInfo
end
function tbBattleUi:CloseAllSkillTimer()
  for _, nTimer in pairs(self.tbUpateSkillTimer) do
    Timer:Close(nTimer)
  end
  self.tbUpateSkillTimer = {}
end
function tbBattleUi:OnOpen()
  self.bForbidSkill = false
  self.tbUpateSkillTimer = self.tbUpateSkillTimer or {}
  local pNpc = me.GetNpc()
  if not pNpc then
    return
  end
  self:OnPreciseCastSkill(false)
  for _, szName in pairs(tbBattleUi.tbAttackEffect) do
    self.pPanel:SetActive(szName, false)
  end
  self.nShapeShiftNpcTID = pNpc.nShapeShiftNpcTID
  local tbNpShapeShift = self:GetShapeShiftSkillInfo(self.nShapeShiftNpcTID)
  local bNotAutoSkill = false
  if tbNpShapeShift then
    self.pPanel:Sprite_SetFillPercent("ForegroundDown", 0)
    self.pPanel:Tween_Disable("Anger")
    self.pPanel:Sprite_SetFillPercent("Anger", 0)
    bNotAutoSkill = true
  end
  self:CheckDaZuo()
  self:ResetUseSkill(tbNpShapeShift, bNotAutoSkill)
  self:UpdateActionMode()
  self:UpdateFocusAllPet()
end
function tbBattleUi:UpdateFocusAllPet(bPreciseCastSkill)
  local bShow = false
  local pNpc = me.GetNpc()
  if pNpc and me.nFightMode ~= Npc.FIGHT_MODE.emFightMode_None then
    bShow = Map:IsFocusAllPet(me.nMapTemplateId)
  end
  self.pPanel:SetActive("BtnAggregate", bShow)
  local nTime = me.nFocusAllPetTime or 0
  local nCurTime = Player.nFocusPetTime - (GetTime() - nTime)
  if nCurTime <= 0 then
    nCurTime = 0
  end
  self.pPanel:Sprite_SetCDControl("SkillAggregateCD", nCurTime, nCurTime)
end
function tbBattleUi:OnOpenEnd()
  Timer:Register(Env.GAME_FPS * 0.7, self.ResetPos, self)
end
function tbBattleUi:ResetPos()
  if not Ui:WindowVisible(self.UI_NAME) then
    return
  end
  local tbSetPosInfo = {
    "Skill1",
    "Skill2",
    "Skill3",
    "Skill4",
    "BtnDazuo",
    "SkillDodge"
  }
  for _, szWnd in pairs(tbSetPosInfo) do
    local pos = self.pPanel:GetPosition(szWnd)
    self.pPanel:Tween_Run(szWnd, pos.x, pos.y, 0.2)
  end
end
function tbBattleUi:OnClose()
  if self.nLongPressAttackTimer then
    Timer:Close(self.nLongPressAttackTimer)
    self.nLongPressAttackTimer = nil
  end
  if self.nShowJumpMsgTimer then
    Timer:Close(self.nShowJumpMsgTimer)
    self.nShowJumpMsgTimer = nil
  end
  self:CloseAllAttackTimer()
  self:CloseAllSkillTimer()
end
function tbBattleUi:UpdateAutoFightButton()
  local bAuto = AutoFight:IsAuto()
  self.pPanel:SetActive("BtnChangeFightState", true)
  local nFightState = AutoFight:GetFightState()
  self.pPanel:Button_SetSprite("BtnChangeFightState", bAuto and "BtnAutomatic" or "BtnManual", 0)
  self.BtnChangeFightState.pPanel:SetActive("tuoguan", bAuto)
  Player:UpdateHeadState()
  self:UpdateChangeFightState()
end
function tbBattleUi:UpdateSkillCD(nSkillID, bNotify)
  local nSkillTimer = self.tbUpateSkillTimer[nSkillID]
  if nSkillTimer then
    Timer:Close(nSkillTimer)
    self.tbUpateSkillTimer[nSkillID] = nil
  end
  if bNotify and self.nAngerSkill and self.nAngerSkill > 0 and nSkillID == self.nAngerSkill and self.bCanOpenAnger then
    Achievement:AddCount("Angry_Normal", 1)
    self.bCanOpenAnger = nil
  end
  local pNpc = me.GetNpc()
  if not pNpc then
    return
  end
  local tbInfo = self.tbUseSkill[nSkillID]
  if not tbInfo then
    return
  end
  local szBtnName = tbInfo.szBtnName
  if not szBtnName then
    return
  end
  if self.pPanel:CheckHasChildren(szBtnName .. "Limite") then
    local nLevel = me.GetSkillLevel(nSkillID)
    if tbInfo.GainLevel and 0 < tbInfo.GainLevel and nLevel <= 0 then
      self.pPanel:Label_SetText(szBtnName .. "Limite", string.format("%s级习得", tbInfo.GainLevel))
      self.pPanel:SetActive(szBtnName .. "Limite", true)
    else
      self.pPanel:SetActive(szBtnName .. "Limite", false)
    end
  end
  if not tbInfo.bShow or tbInfo.bForbidSkill then
    return
  end
  self.pPanel:SetActive(szBtnName .. "Time", false)
  local nSkillPoint = pNpc.GetUsePoint(nSkillID)
  self.pPanel:Button_SetEnabled(szBtnName, true)
  local nNextFrame = pNpc.GetSkillNextCastTime(nSkillID)
  tbInfo.nSkillPoint = nSkillPoint
  local nLogicFrame = GetFrame()
  local nFrame = nNextFrame - nLogicFrame
  local nMaxPoint = pNpc.GetMaxPoint(nSkillID)
  if nMaxPoint > 0 then
    if nFrame <= 0 or nMaxPoint == nSkillPoint then
      local nSkillLevel = me.GetSkillLevel(tbInfo.SkillId)
      local tbSkillSet = FightSkill:GetSkillSetting(nSkillID, nSkillLevel)
      nFrame = tbSkillSet.TimePerCast
      if nMaxPoint == nSkillPoint then
        nFrame = tbSkillSet.TimePerCast * 3
      end
    end
    if nFrame > 0 then
      self.tbUpateSkillTimer[nSkillID] = Timer:Register(nFrame + 1, self.UpdateSkillCD, self, nSkillID)
    end
  end
  if nNextFrame <= 0 or nSkillPoint > 0 then
    self.pPanel:Sprite_SetCDControl(szBtnName .. "CD", 0, 0)
    if nSkillPoint > 0 then
      self.pPanel:SetActive(szBtnName .. "Time", true)
      self.pPanel:Label_SetText(szBtnName .. "Time", math.floor(nSkillPoint / 100))
    end
    return
  end
  if nFrame < 0 then
    nFrame = 0
  end
  local fTime = nFrame / Env.GAME_FPS
  local fTotalTime = fTime
  if tbInfo.bUseTotalTime then
    fTotalTime = tbInfo.fTotalTime
  end
  self.pPanel:Sprite_SetCDControl(szBtnName .. "CD", fTime, fTotalTime)
  tbInfo.fTotalTime = fTotalTime
end
function tbBattleUi:ForbidSkillBtnUI(szBtnName)
  self.pPanel:Sprite_SetCDControl(szBtnName .. "CD", 0, 0)
  self.pPanel:SetActive(szBtnName .. "CD", true)
  self.pPanel:Sprite_SetFillPercent(szBtnName .. "CD", 1)
end
function tbBattleUi:ForbidSkillUI(tbHideName)
  if self.bForbidSkill then
    return
  end
  for nSkillID, tbInfo in pairs(self.tbUseSkill) do
    if tbInfo.szBtnName and (not tbHideName or not tbHideName[tbInfo.szBtnName]) then
      self:ForbidSkillBtnUI(tbInfo.szBtnName)
      tbInfo.bForbidSkill = true
    else
      tbInfo.bForbidSkill = false
    end
  end
  self.bForbidSkill = true
end
function tbBattleUi:RemoveForbidUI()
  if not self.bForbidSkill then
    return
  end
  self.bForbidSkill = false
  for nSkillID, tbInfo in pairs(self.tbUseSkill) do
    tbInfo.bUseTotalTime = true
    tbInfo.bForbidSkill = false
    self:UpdateSkillCD(nSkillID)
    tbInfo.bUseTotalTime = false
  end
  self:UpdateAnger()
end
function tbBattleUi:UpdateSkillShow(nSkillID, nLevel)
  self:CheckDaZuo()
  local tbInfo = self.tbUseSkill[nSkillID]
  self:CheckShowJumpBtn(tbInfo)
  if not tbInfo or tbInfo.bShow then
    return
  end
  tbInfo.bShow = true
  self:UpdateSkillCD(nSkillID)
end
function tbBattleUi:GetChangeCancelSkillId()
  local pNpc = me.GetNpc()
  for nSkillId, _ in pairs(self.tbCanCancelChangeSkill) do
    if pNpc.GetSkillState(nSkillId) then
      return nSkillId
    end
  end
end
function tbBattleUi:CheckDaZuo(bPreciseCastSkill)
  local bShowCancelChangeBtn = false
  local nSkillLevel = me.GetSkillLevel(self.nDaZuoSkill)
  if nSkillLevel > 0 and self.nShapeShiftNpcTID == 0 then
    self.pPanel:SetActive("BtnDazuo", not bPreciseCastSkill)
  else
    self.pPanel:SetActive("BtnDazuo", false)
    if self.nShapeShiftNpcTID ~= 0 and self:GetChangeCancelSkillId() then
      bShowCancelChangeBtn = true
    end
  end
  self.pPanel:SetActive("BtnCancelChange", bShowCancelChangeBtn)
end
function tbBattleUi:CheckShowJumpBtn(tbInfo)
  if not tbInfo or tbInfo.szBtnName ~= self.szBtnJumpName then
    return
  end
  local nSkillLevel = me.GetSkillLevel(tbInfo.SkillId)
  if nSkillLevel > 0 then
    self.pPanel:SetActive(self.szBtnJumpName, true)
  else
    self.pPanel:SetActive(self.szBtnJumpName, false)
  end
end
function tbBattleUi:UpdateAnger()
  if self.bForbidSkill then
    return
  end
  if self.nShapeShiftNpcTID > 0 then
    return
  end
  local pNpc = me.GetNpc()
  local nAnger = pNpc.nAnger
  local fTime = nAnger / FightSkill.tbSkillIniSet.nFullAnger
  self.pPanel:Sprite_SetFillPercent("ForegroundDown", fTime)
  if not self.nLastAnger or fTime > self.nLastAnger then
    self.pPanel:Tween_FillAmountPlay("Anger", self.nLastAnger or fTime, fTime, 1)
  else
    self.pPanel:Tween_Disable("Anger")
    self.pPanel:Sprite_SetFillPercent("Anger", fTime)
  end
  self.nLastAnger = fTime
  self.pPanel:SetActive(self.szBtnAngerName, false)
  if nAnger >= FightSkill.tbSkillIniSet.nFullAnger then
    self.pPanel:SetActive(self.szBtnAngerName, true)
    self.bCanOpenAnger = true
  end
end
function tbBattleUi:SetPartner(nGroupId, bFixGroupID, nP1, nP2)
  if bFixGroupID then
    return
  end
  Log("tbBattleUi:SetPartner", nP1, nP2)
  self.tbAllPartnerSkillInfo = {}
  self:InitPartnerSkill(1, nP1)
  self:InitPartnerSkill(2, nP2)
end
function tbBattleUi:InitPartnerSkill(nIndex, nNpcId)
  do return end
  self.pPanel:SetActive("PartnerSkill" .. nIndex, false)
  if not nIndex or nIndex < 1 or nIndex > 2 then
    return
  end
end
function tbBattleUi:UpdatePartnerAnger(pNpc)
  do return end
  local tbPartnerSkillInfo = self.tbAllPartnerSkillInfo[pNpc.nId]
  if not tbPartnerSkillInfo then
    Log("[Partner] tbBattleUi:UpdatePartnerAnger ERR ?? tbPartnerSkillInfo is nil !!")
    return
  end
  local nAnger = pNpc.nAnger
  if nAnger < FightSkill.tbSkillIniSet.nFullAnger then
    return
  end
  local nIndex = tbPartnerSkillInfo.nIdx
  local tbShowSkillInfo = FightSkill:GetSkillShowInfo(tbPartnerSkillInfo.nAngerSkill)
  if not tbShowSkillInfo then
    Log("[Partner] tbBattleUi:UpdatePartnerAnger ERR ?? tbShowSkillInfo is nil !!", pNpc.nMasterNpcId, pNpc.nPartnerId, pNpc.szName, tbPartnerSkillInfo.nAngerSkill)
    return
  end
  self.pPanel:SetActive("PartnerSkill" .. nIndex, true)
  self.pPanel:Sprite_SetSprite(string.format("PartnerSkill%dIcon", nIndex), tbShowSkillInfo.BtnIcon, tbShowSkillInfo.IconAltlas)
  self.pPanel:SetActive(string.format("PartnerSkill%dCD", nIndex), false)
  self.pPanel:SetActive(string.format("PartnerSkill%dCDTime", nIndex), false)
end
for i = 1, 2 do
  tbBattleUi.tbOnClick["PartnerSkill" .. i] = function(self)
    self:OnPartnerSkillPress(i)
  end
end
function tbBattleUi.tbOnClick:BtnChangeFightState()
  Guide.tbNotifyGuide:ClearNotifyGuide("AutoFightGuide")
  if me.nFightMode == 0 then
    return
  end
  AutoFight:SwitchState()
end
tbBattleUi.tbOnLongPress = tbBattleUi.tbOnLongPress or {}
function tbBattleUi.tbOnLongPress:BtnChangeFightState(szWnd)
  Ui:OpenWindow("AutoSkillSetting")
end
for szBtnName, _ in pairs(tbBattleUi.tbBtnSkill) do
  if szBtnName ~= "Attack" and szBtnName ~= "SkillDodge" and szBtnName ~= "BtnDazuo" then
    tbBattleUi.tbOnLongPress[szBtnName] = function(self, szWnd)
      local nSkillId = tbBattleUi.tbBtnSkill[szBtnName]
      if nSkillId > 0 and me.nFightMode ~= Npc.FIGHT_MODE.emFightMode_None and Operation:IsNeedOpenPreciseUI(nSkillId) then
        return
      end
      local _, nSkillLevel = me.GetSkillLevel(nSkillId)
      if nSkillLevel > 0 then
        local WorldPos = self.pPanel:GetWorldPosition(szBtnName)
        self:ShowSkillInfo(nSkillId, nSkillLevel, {
          WorldPos.x,
          WorldPos.y,
          50,
          120
        })
      end
    end
  end
end
function tbBattleUi:OnPartnerSkillPress(nIndex)
  self.pPanel:SetActive("PartnerSkill" .. nIndex, false)
  local tbPartnerSkillInfo, nNpcId
  for nId, tbInfo in pairs(self.tbAllPartnerSkillInfo or {}) do
    if tbInfo.nIdx == nIndex then
      tbPartnerSkillInfo = tbInfo
      nNpcId = nId
      break
    end
  end
  if not tbPartnerSkillInfo then
    return
  end
  local pNpc = KNpc.GetById(nNpcId)
  if not pNpc or pNpc.nMasterNpcId ~= me.GetNpc().nId then
    return
  end
  local m, x, y = pNpc.GetWorldPos()
  if IsAlone() == 1 then
    pNpc.UseSkill(tbPartnerSkillInfo.nAngerSkill, x, y)
  else
    me.CenterMsg("现在不支持同伴在服务端释放技能~~")
  end
end
function tbBattleUi:AddSpecialState(nState, nFrame)
  local pNpc = me.GetNpc()
  if not pNpc.CheckCanSkill() then
    self:ForbidSkillUI()
  end
end
function tbBattleUi:UpdateActionMode()
  local nActMode = me.GetActionMode()
  local pNpc = me.GetNpc()
  if nActMode ~= Npc.NpcActionModeType.act_mode_none then
    self:RemoveForbidUI()
    self:ForbidSkillUI()
  elseif me.nFightMode == Npc.FIGHT_MODE.emFightMode_None then
    self:RemoveForbidUI()
    self:ForbidSkillUI({BtnDazuo = 1, SkillDodge = 1})
    Operation:ClosePreciseUI()
  else
    self:RemoveForbidUI()
  end
  self:UpdateChangeFightState()
end
function tbBattleUi:UpdateChangeFightState(bPreciseCastSkill)
  local bShow = true
  if me.nFightMode == Npc.FIGHT_MODE.emFightMode_None or self.nShapeShiftNpcTID and self.nShapeShiftNpcTID > 0 or me.nLevel < 3 then
    bShow = false
  end
  self.pPanel:SetActive("BtnChangeFightState", bShow and not bPreciseCastSkill)
  self:CheckDaZuo(bPreciseCastSkill)
  self:UpdateFocusAllPet(bPreciseCastSkill)
end
function tbBattleUi:ChangeFightState()
  self:UpdateActionMode()
end
function tbBattleUi:RemoveSpecialState(nState)
  local pNpc = me.GetNpc()
  if pNpc.CheckCanSkill() then
    self:RemoveForbidUI()
  end
end
function tbBattleUi:OnShapeShift(nNpcTID)
  self.nShapeShiftNpcTID = nNpcTID
  local tbNpShapeShift = self:GetShapeShiftSkillInfo(self.nShapeShiftNpcTID)
  local bNotAutoSkill = false
  if tbNpShapeShift then
    bNotAutoSkill = true
  end
  self.pPanel:Sprite_SetFillPercent("ForegroundDown", 0)
  self.pPanel:Tween_Disable("Anger")
  self.pPanel:Sprite_SetFillPercent("Anger", 0)
  self:ResetUseSkill(tbNpShapeShift, bNotAutoSkill)
  self:UpdateActionMode()
end
function tbBattleUi:RemoveShapeShift(nNpcTID)
  if self.nShapeShiftNpcTID == 0 then
    return
  end
  self:ResetUseSkill()
  self.nShapeShiftNpcTID = 0
  self:UpdateActionMode()
end
function tbBattleUi:OnUpdateSkillCD(nSkillID)
  self:UpdateSkillCD(nSkillID, true)
end
function tbBattleUi:ChangePlayerLevel()
  self:UpdateActionMode()
end
function tbBattleUi:OnWndOpened(szUiName)
  if szUiName == "SituationalDialogue" and self.nLongPressAttackTimer then
    Timer:Close(self.nLongPressAttackTimer)
    self.nLongPressAttackTimer = nil
  end
end
function tbBattleUi:ForbiddenOperation()
  if self.nLongPressAttackTimer then
    Timer:Close(self.nLongPressAttackTimer)
    self.nLongPressAttackTimer = nil
  end
end
function tbBattleUi:OnPreciseCastSkill(bStart)
  self.pPanel:SetActive("SkillCancel", bStart)
  self:UpdateChangeFightState(bStart)
end
function tbBattleUi:OnPreciseTouchUp()
  if self.pPanel:IsFingerHoverOn("SkillCancel") then
    Operation:SetCancelPreciseCast(true)
  end
end
function tbBattleUi:OnLoadedMap(nMapTID)
  self:UpdateFocusAllPet()
end
function tbBattleUi:OnUpdateSkillPoint(nSkillID, nPoint)
  if not self.tbUseSkill then
    return
  end
  local tbInfo = self.tbUseSkill[nSkillID]
  if not tbInfo then
    return
  end
  tbInfo.nSkillPoint = tbInfo.nSkillPoint or 0
  if tbInfo.nSkillPoint == nPoint then
    return
  end
  self:OnUpdateSkillCD(nSkillID)
end
function tbBattleUi:OnAddSkillSlot(nSkillId)
  self:SetSkillSlotInfo(nSkillId)
end
function tbBattleUi:OnRemoveSkillSlot(nSkillId)
  local tbSlotInfo = self.tbUseSkill[nSkillId]
  if not tbSlotInfo then
    return
  end
  self:ClearBtnInfo(tbSlotInfo.szBtnName)
  self.tbUseSkill[nSkillId] = nil
end
function tbBattleUi:RegisterEvent()
  local tbRegEvent = {
    {
      UiNotify.emNoTIFY_SKILL_CD,
      self.OnUpdateSkillCD
    },
    {
      UiNotify.emNOTIFY_ADD_SKILL,
      self.UpdateSkillShow
    },
    {
      UiNotify.emNOTIFY_CHANGE_AUTOFIGHT,
      self.UpdateAutoFightButton
    },
    {
      UiNotify.emNOTIFY_ADD_SPECIAL_STATE,
      self.AddSpecialState
    },
    {
      UiNotify.emNOTIFY_REMOVE_SPECIAL_STATE,
      self.RemoveSpecialState
    },
    {
      UiNotify.emNOTIFY_SHAPE_SHIFT,
      self.OnShapeShift
    },
    {
      UiNotify.emNOTIFY_REMOVE_SHAPE_SHIFT,
      self.RemoveShapeShift
    },
    {
      UiNotify.emNOTIFY_CHANGE_PLAYER_LEVEL,
      self.ChangePlayerLevel
    },
    {
      UiNotify.emNOTIFY_WND_OPENED,
      self.OnWndOpened
    },
    {
      UiNotify.emNOTIFY_FORBIDDEN_OPERATION,
      self.ForbiddenOperation
    },
    {
      UiNotify.emNOTIFY_PG_PARTNER_SWITCH_GROUP,
      self.SetPartner
    },
    {
      UiNotify.emNOTIFY_CHANGE_ACTION_MODE,
      self.UpdateActionMode
    },
    {
      UiNotify.emNOTIFY_CHANGE_FIGHT_STATE,
      self.ChangeFightState
    },
    {
      UiNotify.emNOTIFY_MAP_LOADED,
      self.OnLoadedMap
    },
    {
      UiNotify.emNOTIFY_PRECISE_CAST,
      self.OnPreciseCastSkill
    },
    {
      UiNotify.emNOTIFY_PRECISE_TOUCH_UP,
      self.OnPreciseTouchUp
    },
    {
      UiNotify.emNOTIFY_SKILL_USE_POINT,
      self.OnUpdateSkillPoint
    },
    {
      UiNotify.emNOTIFY_ADD_SKILL_SLOT,
      self.OnAddSkillSlot
    },
    {
      UiNotify.emNOTIFY_REMOVE_SKILL_SLOT,
      self.OnRemoveSkillSlot
    }
  }
  return tbRegEvent
end
