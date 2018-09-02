Require("Script/Ui/Logic/Notify.lua")
local RepresentMgr = luanet.import_type("RepresentMgr")
AutoFight.OperationType = {Manual = 1, Auto = 2}
AutoFight.MANUAL_SKILL_TYPE = {
  DIR = 1,
  POS = 2,
  NPC = 3
}
AutoFight.nManualSkillTimeOut = 2
AutoFight.nRadius = 600
local OperationType = AutoFight.OperationType
local MANUAL_SKILL_TYPE = AutoFight.MANUAL_SKILL_TYPE
AutoFight.nFightState = AutoFight.nFightState or OperationType.Manual
AutoFight.tbCheckFactionSkill = {
  [6] = {
    tbSkill = {
      [708] = 1,
      [722] = 1,
      [740] = 1
    },
    nFrame = 18,
    fnCheck = function(nSkillId)
      local pNpc = me.GetNpc()
      local tbState = pNpc.GetState(Npc.STATE.NPC_HIDE)
      local nCurFrme = GetFrame()
      AutoFight.nCheckSkillFrame = AutoFight.nCheckSkillFrame or 0
      if (not tbState or 0 >= tbState.nRestFrame) and nCurFrme >= AutoFight.nCheckSkillFrame then
        return true
      end
      local tbData = AutoFight.tbCheckFactionSkill[me.nFaction]
      if not tbData or not tbData.tbSkill then
        return true
      end
      if tbData.tbSkill[nSkillId] then
        return false
      end
      if nCurFrme >= AutoFight.nCheckSkillFrame or tbState and 0 < tbState.nRestFrame then
        AutoFight.nCheckSkillFrame = nCurFrme + tbData.nFrame
      end
      AutoFight.nCheckSkillFrame = math.min(AutoFight.nCheckSkillFrame, nCurFrme + tbData.nFrame + 1)
      return true
    end
  }
}
function AutoFight:CheckFactionSkill(nSkillId)
  local tbData = self.tbCheckFactionSkill[me.nFaction]
  if not tbData then
    return true
  end
  local bRet = tbData.fnCheck(nSkillId)
  return bRet
end
function AutoFight:LoadSetting()
  local tbFile = LoadTabFile("Setting/Map/AutoFightSetting.tab", "dd", nil, {"nMapId", "nAutoFight"})
  self.tbMapSetting = {}
  for _, tbInfo in pairs(tbFile) do
    self.tbMapSetting[tbInfo.nMapId] = tbInfo.nAutoFight
  end
end
AutoFight:LoadSetting()
function AutoFight:OnEnterMap(nMapTemplateId)
  if not self.tbMapSetting[nMapTemplateId] then
    return
  end
  local nAutoType = self.tbMapSetting[nMapTemplateId] == 1 and AutoFight.OperationType.Auto or AutoFight.OperationType.Manual
  AutoFight:ChangeState(nAutoType, true)
end
function AutoFight:SwitchState()
  local nFightState = self.nFightState % 2 + 1
  self:ChangeState(nFightState)
end
function AutoFight:GetFightState()
  return self.nFightState
end
function AutoFight:ForbidAutoFight()
  self.bForbidAutoFight = true
end
function AutoFight:CancelForbid()
  self.bForbidAutoFight = false
end
function AutoFight:IsAuto()
  return AutoFight.nFightState ~= OperationType.Manual or AutoFight:IsFollowTeammate()
end
function AutoFight:ResetFightState()
  if AutoFight:IsFollowTeammate() then
    return
  end
  local nActMode = me.GetActionMode()
  if nActMode ~= Npc.NpcActionModeType.act_mode_none then
    self.nLastFightState = self:GetFightState()
    return
  end
  if self.nLastFightState then
    AutoFight:ChangeState(self.nLastFightState)
  end
end
function AutoFight:ChangeState(nFightState, bForce)
  if me.nFightMode == 0 and not bForce then
    self.nLastFightState = nFightState
    return
  end
  if self.bForbidAutoFight then
    return
  end
  self.orgPos = nil
  self.nLastFightState = nFightState
  if nFightState == OperationType.Manual then
    AutoFight:Stop()
    return
  end
  AutoFight:StopFollowTeammate()
  if self.nTimer then
    Timer:Close(self.nTimer)
  end
  self.nTimer = Timer:Register(3, self.Activate, self)
  AutoAI.SetTargetIndex(0)
  AutoFight:StopGoto()
  local nCurDstX, nCurDstY = Operation:GetTargetPos()
  if nCurDstX then
    AutoFight:GotoPosition(nCurDstX, nCurDstY)
  end
  AutoFight:UpdateAutoSkillList()
  self.nFightState = nFightState
  UiNotify.OnNotify(UiNotify.emNOTIFY_CHANGE_AUTOFIGHT)
end
function AutoFight:Stop()
  if self.nFightState == OperationType.Manual then
    return
  end
  if self.nTimer then
    Timer:Close(self.nTimer)
    self.nTimer = nil
  end
  AutoFight:StopGoto()
  AutoAI.SetTargetIndex(0)
  self.nFightState = OperationType.Manual
  UiNotify.OnNotify(UiNotify.emNOTIFY_CHANGE_AUTOFIGHT)
end
function AutoFight:CheckUseJiu()
  if Map:GetClassDesc(me.nMapTemplateId) ~= "fight" then
    return
  end
  if not self.nCheckJiuFrame then
    self.nCheckJiuFrame = 1
    self.nJiuItemLevel = 99
    local nJiuId = Item:GetClass("jiu").nTemplateId
    local tbBaseInfo = KItem.GetItemBaseProp(nJiuId)
    if tbBaseInfo then
      self.nJiuItemLevel = tbBaseInfo.nRequireLevel
    end
  end
  if me.nLevel < self.nJiuItemLevel then
    return
  end
  self.nCheckJiuFrame = self.nCheckJiuFrame + 1
  if self.nCheckJiuFrame % 30 == 0 and not Client:GetFlag("NotAutoUseJiu") and me.GetNpc().GetSkillState(Npc:GetClass("GouHuoNpc").nGouhuoSkillId) and not me.GetNpc().GetSkillState(Item:GetClass("jiu").nJiuSkillId) then
    local tbJius = me.FindItemInBag("jiu")
    if next(tbJius) then
      if #tbJius == 1 and tbJius[1].nCount == 1 and not Ui:CheckNotShowTips("ShowAutoBuyJiu|NEVER") then
        do
          local dwTemplateId = tbJius[1].dwTemplateId
          local function fnConfirm()
            Shop:AutoChooseItem(dwTemplateId)
          end
          me.MsgBox("[FFFE0D]陈年女儿红[-]已经饮完，是否前往购买？", {
            {
              "前往购买",
              fnConfirm
            },
            {
              "暂不购买"
            }
          }, "ShowAutoBuyJiu|NEVER")
        end
      end
      RemoteServer.UseItem(tbJius[1].dwId)
    end
  end
end
function AutoFight:Activate()
  if me.nFightMode == 0 or not self:IsAuto() then
    self.nTimer = nil
    self.nLastFightState = self:GetFightState()
    AutoFight:Stop()
    return false
  end
  local nDoing = me.GetDoing()
  if nDoing == Npc.Doing.sit then
    return true
  end
  if AutoAI.IsOnManualGo() and not self.bGuiding then
    local _, nX, nY = me.GetWorldPos()
    if self.nLastX == nX and self.nLastY == nY then
      self.nStopFrame = self.nStopFrame or 1
      self.nStopFrame = self.nStopFrame + 1
    else
      self.nStopFrame = nil
    end
    self.nLastX = nX
    self.nLastY = nY
    if self.nStopFrame and self.nStopFrame > 3 then
      self.nStopFrame = nil
      AutoFight:StopGoto()
      Operation:SetPositionEffect(false)
    end
    self.orgPos = nil
    return true
  end
  self:CheckUseJiu()
  if not AutoFight:FindTarget() then
    if me.IsInGuaJiMap() then
      self:FightTarget(0)
      self:GotoPosition(self.orgPos.x, self.orgPos.y)
      self.bGuiding = true
    end
    return true
  end
  for _, tbSkillInfo in ipairs(self.tbSkillList) do
    local nSKillId = unpack(tbSkillInfo)
    if nSKillId > 0 and me.CanCastSkill(nSKillId) and AutoFight:CheckFactionSkill(nSKillId) then
      if me.GetNpc().IsCanSkill() then
        if nSKillId == 306 or nSKillId == 2116 then
          AutoAI.SetTargetIndex(me.GetNpc().nId)
        end
        AutoAI.SetActiveSkill(nSKillId)
      end
      return true
    end
  end
  return true
end
function AutoFight:GetOrgPos()
  if not self.orgPos then
    local _, x, y = me.GetWorldPos()
    self.orgPos = {x = x, y = y}
  end
  return self.orgPos
end
function AutoFight:FindTargetInCircle()
  local orgPos = self:GetOrgPos()
  return Operation:GetNearestEnemyIdByPos(self:GetAutoRadius(), orgPos.x, orgPos.y)
end
function AutoFight:FightTarget(nTargetID)
  nTargetID = nTargetID or 0
  AutoAI.SetTargetIndex(nTargetID)
  Operation:SetNpcSelected(nTargetID)
  Operation:SetPositionEffect(false)
  AutoFight:StopGoto()
end
function AutoFight:IsOutRange()
  local _, meX, meY = me.GetWorldPos()
  local orgPos = self:GetOrgPos()
  return Lib:GetDistance(meX, meY, orgPos.x, orgPos.y) >= self:GetAutoRadius()
end
function AutoFight:GetAutoRadius()
  return Map:GetAutoFightRadius(me.nMapTemplateId, me.nMapId) or self.nRadius
end
function AutoFight:FindTarget()
  local bInGuaJiMap = me.IsInGuaJiMap()
  if bInGuaJiMap and self:IsOutRange() then
    return false
  end
  local nTargetID = AutoAI.GetTargetIndex() or 0
  local nSkillID = AutoAI.GetActiveSkillId() or 0
  if me.CheckSkillAvailable2Npc(nSkillID, nTargetID) and AutoFight:CheckFactionSkill(nSkillID) then
    return true
  end
  if bInGuaJiMap then
    nTargetID = self:FindTargetInCircle()
    if nTargetID and nTargetID > 0 then
      self:FightTarget(nTargetID)
      return true
    end
  else
    nTargetID = Operation:GetNearestEnemyId()
    if nTargetID and nTargetID ~= 0 then
      self:FightTarget(nTargetID)
      return true
    end
    local nGuidX, nGuidY = Fuben:GetTargetPos()
    if nGuidX and nGuidY then
      AutoFight:GotoPosition(nGuidX, nGuidY)
      self.bGuiding = true
    end
  end
  return false
end
function AutoFight:OnNpcDeath(nNpcID)
  if nNpcID ~= AutoAI.GetTargetIndex() then
    return
  end
  local npcRep = RepresentMgr.GetNpcRepresent(nNpcID)
  if npcRep then
    npcRep:SetSelectedEffect(false, true)
  end
end
function AutoFight:ManualAttack(nSkillID, nType, nParam1, nParam2)
  if nType == MANUAL_SKILL_TYPE.NPC and not nParam1 and not AutoFight:FindTarget() then
    AutoAI.SetNextActiveSkill(0)
    return
  end
  AutoAI.SetNextActiveSkill(nSkillID, AutoFight.nManualSkillTimeOut, nType, nParam1 or 0, nParam2 or 0)
  AutoFight:StopGoto()
  Operation:SetPositionEffect(false)
end
function AutoFight:ClearManualAttack()
  AutoAI.SetNextActiveSkill(0)
end
function AutoFight:ManualJumpTo(nJumpSkillId, nX, nY, bSlide, bTrap)
  AutoAI.ManualJumpTo(nJumpSkillId, nX, nY, bSlide and true or false, bTrap and true or false)
end
function AutoFight:SelectNpc(nNpcID)
  if not (self:IsAuto() and nNpcID) or nNpcID == 0 then
    return
  end
  AutoAI.SetTargetIndex(nNpcID)
  Operation:SetNpcSelected(nNpcID)
end
function AutoFight:StopGoto()
  self.bGuiding = false
  AutoAI.GotoPosition(-1, -1)
end
function AutoFight:GotoPosition(nX, nY)
  if AutoFight:IsFollowTeammate() then
    AutoFight:FollowteammateGoto(nX, nY)
    return
  end
  self.bGuiding = false
  return AutoAI.GotoPosition(nX, nY)
end
function AutoFight:GoDirection(nDir, nFrame)
  if AutoFight:IsFollowTeammate() then
    return
  end
  self.bGuiding = false
  AutoAI.SetTargetIndex(0)
  return AutoAI.GoDirection(nDir, nFrame)
end
function AutoFight:GetSetting()
  local tbSetting = Client:GetUserInfo("AutoFight")
  local tbFactionData = Client:GetUserInfo("AutoFightFaction")
  if not tbFactionData.nFaction then
    tbFactionData.nFaction = me.nFaction
  end
  local tbOrgSetting = self.tbOrgSetting
  self.tbOrgSetting = nil
  if tbFactionData.nFaction ~= me.nFaction then
    local tbCurOrg = AutoFight:ClearAutoSetting()
    tbFactionData.nFaction = me.nFaction
    AutoFight:SaveSetting()
    tbOrgSetting = tbOrgSetting or tbCurOrg
  end
  if not next(tbSetting) then
    tbOrgSetting = tbOrgSetting or {}
    local nCount = Lib:CountTB(tbSetting)
    local tbSkillInfo = FightSkill:GetFactionSkill(me.nFaction)
    for _, tbInfo in pairs(tbSkillInfo) do
      if tbInfo.IsAnger == 1 or string.find(tbInfo.BtnName, "Skill") then
        table.insert(tbSetting, {
          nSkillId = tbInfo.SkillId,
          szName = tbInfo.BtnName,
          bActive = false
        })
      end
    end
    table.sort(tbSetting, function(a, b)
      return a.szName < b.szName
    end)
    for nI, tbSetInfo in pairs(tbSetting) do
      if tbOrgSetting and tbSetInfo.szName and tbOrgSetting[tbSetInfo.szName] then
        tbSetInfo.bActive = tbOrgSetting[tbSetInfo.szName].bActive
      end
    end
    if nCount == 0 then
      AutoFight:SaveSetting()
      Log("AutoFight ChangeSetting SaveSetting")
    end
  end
  return tbSetting
end
function AutoFight:ClearAutoSetting()
  local tbOrgPos = {}
  local tbSetting = Client:GetUserInfo("AutoFight") or {}
  for nI, tbSetInfo in pairs(tbSetting) do
    if tbSetInfo.szName and not Lib:IsEmptyStr(tbSetInfo.szName) then
      local tbInfo = {}
      tbInfo.bActive = tbSetInfo.bActive
      tbOrgPos[tbSetInfo.szName] = tbInfo
    end
  end
  while #tbSetting > 0 do
    table.remove(tbSetting, 1)
  end
  return tbOrgPos
end
function AutoFight:SaveSetting()
  Client:SaveUserInfo()
end
function AutoFight:CheckUpdateSkillSetting()
  local tbSkillSetting = AutoFight:GetSetting() or {}
  local tbAllSkill = FightSkill:GetFactionSkill(me.nFaction) or {}
  for _, tbSkill1 in pairs(tbSkillSetting) do
    local bClear = true
    for _, tbSkill2 in pairs(tbAllSkill) do
      if tbSkill1.nSkillId == tbSkill2.SkillId then
        bClear = false
        break
      end
    end
    if bClear then
      return true
    end
  end
  return false
end
function AutoFight:UpdateSkillSetting()
  local bRet = AutoFight:CheckUpdateSkillSetting()
  if not bRet then
    return
  end
  local tbOrgPos = AutoFight:ClearAutoSetting()
  AutoFight.tbOrgSetting = tbOrgPos
  AutoFight:GetSetting()
  AutoFight.tbOrgSetting = nil
  AutoFight:SaveSetting()
end
function AutoFight:ClearAutoFightTarget()
  AutoAI.SetTargetIndex(0)
  AutoFight:StopGoto()
end
function AutoFight:UpdateAutoSkillList()
  self.tbSkillList = {}
  local tbSetting = self:GetSetting()
  for _, tbSkillInfo in ipairs(tbSetting) do
    local nSkillId = tbSkillInfo.nSkillId
    local nSkillLevel = me.GetSkillLevel(nSkillId)
    if tbSkillInfo.bActive and nSkillLevel > 0 then
      local tbSkillSetting = FightSkill:GetSkillSetting(nSkillId, nSkillLevel)
      local bNeedTarget = FightSkill:IsTeamFollowAttackNeedTarget(nSkillId)
      table.insert(self.tbSkillList, {
        nSkillId,
        bNeedTarget,
        tbSkillSetting.AttackRadius
      })
    end
  end
  local nAttackSkillId = FightSkill:GetSkillIdByBtnName(me.nFaction, "Attack")
  table.insert(self.tbSkillList, {nAttackSkillId})
  self.nMainAttackSkillId = nAttackSkillId
end
UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_LOADED, AutoFight.ClearAutoFightTarget, AutoFight)
UiNotify:RegistNotify(UiNotify.emNOTIFY_SYNC_PLAYER_SET_POS, AutoFight.ClearAutoFightTarget, AutoFight)
UiNotify:RegistNotify(UiNotify.emNOTIFY_AUTO_SKILL_CHANGED, AutoFight.UpdateAutoSkillList, AutoFight)
function AutoFight:FollowteammateGoto(nX, nY)
  local tbTeammate = TeamMgr:GetMemberData(self.nFollowTeammateNpcId)
  if tbTeammate then
    tbTeammate.nTargetNpcId = nil
  end
  me.GotoPosition(nX, nY)
end
function AutoFight:RegisterTeamFollow(nNpcId, nMapId)
  local tbTeammate = TeamMgr:GetMemberData(nNpcId)
  self.tbRegisterTeamFollow = nil
  if tbTeammate and nMapId == tbTeammate.nMapId then
    AutoFight:StartFollowTeammate(nNpcId)
    return
  end
  self.tbRegisterTeamFollow = {}
  self.tbRegisterTeamFollow.nNpcId = nNpcId
  self.tbRegisterTeamFollow.nMapId = nMapId
end
function AutoFight:OnUpdateTeamInfo()
  if self.tbRegisterTeamFollow then
    local nNpcId = self.tbRegisterTeamFollow.nNpcId
    local tbTeammate = TeamMgr:GetMemberData(nNpcId)
    if not tbTeammate then
      self.tbRegisterTeamFollow = nil
    else
      AutoFight:RegisterTeamFollow(nNpcId, self.tbRegisterTeamFollow.nMapId)
    end
  end
end
function AutoFight:StartFollowTeammate(nNpcId, bIgnoreNotice)
  local tbTeammate = TeamMgr:GetMemberData(nNpcId)
  local nMapId = me.GetWorldPos()
  if not tbTeammate then
    if not bIgnoreNotice then
      me.CenterMsg("无法找到队友")
    end
    return
  end
  if nMapId ~= tbTeammate.nMapId and not self:FollowTeammateChangeMap(tbTeammate) then
    return
  end
  AutoFight:Stop()
  AutoFight:StopFollowTeammate()
  self.nFollowTeammateNpcId = nNpcId
  AutoFight:UpdateAutoSkillList()
  self.nFollowTeammateTimer = Timer:Register(3, self.FollowTeammateActive, self)
  UiNotify.OnNotify(UiNotify.emNOTIFY_TEAM_UPDATE)
  UiNotify.OnNotify(UiNotify.emNOTIFY_CHANGE_AUTOFIGHT)
  me.CenterMsg(string.format("已跟战[%s]", tbTeammate.szName))
  Player:UpdateHeadState()
  self.nChangingMapForTeammateNpcId = nil
end
function AutoFight:IsFollowTeammate()
  return self.nFollowTeammateTimer and true or false
end
function AutoFight:GetFollowingNpcId()
  return self.nFollowTeammateNpcId
end
function AutoFight:StopFollowTeammate()
  if self.nFollowTeammateTimer then
    Timer:Close(self.nFollowTeammateTimer)
    self.nFollowTeammateTimer = nil
    self.nFollowTeammateNpcId = nil
    UiNotify.OnNotify(UiNotify.emNOTIFY_TEAM_UPDATE)
    Player:UpdateHeadState()
    UiNotify.OnNotify(UiNotify.emNOTIFY_CHANGE_AUTOFIGHT)
  end
  self.nChangingMapForTeammateNpcId = nil
end
function AutoFight:FollowTeammateChangeMap(tbTeammate)
  local tbGoTargetInfo = AutoPath:GetGoTargetNextActInfo(tbTeammate.nMapTemplateId, me.nMapTemplateId)
  if tbGoTargetInfo then
    local nNow = GetTime()
    if self.nNextFollowFightChangingMapActive and nNow < self.nNextFollowFightChangingMapActive then
      return true
    end
    if tbGoTargetInfo.tbPos then
      local _, nMyPosX, nMyPosY = me.GetWorldPos()
      local nMinLen = math.huge
      local tbTargePos
      for _, tbPos in ipairs(tbGoTargetInfo.tbPos) do
        local nLenSquare = Lib:GetDistsSquare(nMyPosX, nMyPosY, tbPos[1], tbPos[2])
        if nMinLen > nLenSquare then
          nMinLen = nLenSquare
          tbTargePos = tbPos
        end
      end
      if tbTargePos then
        me.GotoPosition(unpack(tbTargePos))
        self.nNextFollowFightChangingMapActive = nNow + 1
        return true
      end
    elseif tbGoTargetInfo.szOperation == "DoScript" then
      local fn = loadstring(tbGoTargetInfo.szParams)
      if fn then
        fn()
        self.nNextFollowFightChangingMapActive = nNow + 3
        return true
      end
    elseif tbGoTargetInfo.szOperation == "WhiteTigerFuben" then
      self.nNextFollowFightChangingMapActive = nNow + 1
      return Fuben.WhiteTigerFuben:FollowOperation(tbTeammate.nMapId, tbGoTargetInfo.szParams)
    end
  end
  AutoFight:StopFollowTeammate()
  local nMapId = tbTeammate.nMapId
  if tbTeammate.nMapTemplateId == Kin.Def.nKinMapTemplateId and tbTeammate.nKinId == me.dwKinId then
    nMapId = tbTeammate.nMapTemplateId
  end
  AutoPath:GotoAndCall(nMapId, tbTeammate.nPosX, tbTeammate.nPosY, function()
    AutoFight:StartFollowTeammate(self.nChangingMapForTeammateNpcId, true)
  end, 10000, tbTeammate.nMapTemplateId)
  self.nChangingMapForTeammateNpcId = tbTeammate.nNpcID
  return false
end
local GetPositionInRay = function(orgX, orgY, desX, desY, nLength)
  local nBevelLen = math.sqrt((orgX - desX) ^ 2 + (orgY - desY) ^ 2)
  local nUnitLenX = (desX - orgX) / nBevelLen
  local nUnitLenY = (desY - orgY) / nBevelLen
  return orgX + nUnitLenX * nLength, orgY + nUnitLenY * nLength
end
local nFollowTeammateDistance = 650
local nNextFollowAttackEnemeyTime = 0
local nFollowTeammateAttackFailCount = 0
function AutoFight:FollowTeammateActive()
  local tbTeammate = TeamMgr:GetMemberData(self.nFollowTeammateNpcId)
  if not tbTeammate then
    AutoFight:StopFollowTeammate()
    AutoFight:ChangeState(OperationType.Auto)
    return false
  end
  if Map:IsMapOnLoading() then
    return true
  end
  local nMapId, nMyPosX, nMyPosY = me.GetWorldPos()
  if nMapId ~= tbTeammate.nMapId then
    return self:FollowTeammateChangeMap(tbTeammate)
  end
  self.nChangingMapForTeammateNpcId = nil
  if InDifferBattle.bRegistNotofy and InDifferBattle:GotoTeamateRoom(tbTeammate) then
    return true
  end
  local pTeammateNpc = KNpc.GetById(self.nFollowTeammateNpcId)
  if not pTeammateNpc then
    me.GotoPosition(tbTeammate.nPosX, tbTeammate.nPosY)
    tbTeammate.nTargetNpcId = nil
    return true
  end
  local _, nTeammateX, nTeammateY = pTeammateNpc.GetWorldPos()
  local nDisSquare = Lib:GetDistsSquare(nMyPosX, nMyPosY, nTeammateX, nTeammateY)
  if nDisSquare > nFollowTeammateDistance ^ 2 then
    local nX, nY = GetPositionInRay(nTeammateX, nTeammateY, nMyPosX, nMyPosY, nFollowTeammateDistance * 0.3)
    if GetBarrierInfo(nMapId, nX, nY) == 0 then
      me.GotoPosition(nX, nY)
    else
      me.GotoPosition(nTeammateX, nTeammateY)
    end
    tbTeammate.nTargetNpcId = nil
    nNextFollowAttackEnemeyTime = GetTime() + 4
    return true
  end
  self:CheckUseJiu()
  local nActMode = me.GetActionMode()
  if nActMode ~= Npc.NpcActionModeType.act_mode_none then
    ActionMode:CallDoActionMode(Npc.NpcActionModeType.act_mode_none, true)
    return true
  end
  local nNow = GetTime()
  local nEnemyNpcId = tbTeammate.nTargetNpcId
  if not nEnemyNpcId or nNow > tbTeammate.nAttackTimeOut then
    tbTeammate.nTargetNpcId = nil
  end
  local pEnmemy = KNpc.GetById(nEnemyNpcId or 0)
  if not pEnmemy then
    nEnemyNpcId = me.GetNpc().GetLastDamageNpcId()
    pEnmemy = KNpc.GetById(nEnemyNpcId or 0)
    if not pEnmemy or nNow < nNextFollowAttackEnemeyTime then
      return true
    end
  end
  if not me.CheckSkillAvailable2Npc(self.nMainAttackSkillId, nEnemyNpcId) then
    return true
  end
  local _, nEnemyX, nEnemyY = pEnmemy.GetWorldPos()
  local nEnemyDisSquare = Lib:GetDistsSquare(nMyPosX, nMyPosY, nEnemyX, nEnemyY)
  for _, tbSkillInfo in ipairs(self.tbSkillList) do
    local nSkillId, bNeedTarget, nAttackRadius = unpack(tbSkillInfo)
    if nSkillId > 0 and me.CanCastSkill(nSkillId) and AutoFight:CheckFactionSkill(nSkillId) then
      if bNeedTarget and nEnemyDisSquare > (nAttackRadius * 0.8) ^ 2 then
        me.GotoPosition(nEnemyX, nEnemyY)
        return true
      end
      if Operation:UseSkillToNpc(nSkillId, nEnemyNpcId) then
        nFollowTeammateAttackFailCount = 0
        return true
      end
    end
  end
  local nDoing = me.GetDoing()
  if nDoing == Npc.Doing.ctrl_run_attack then
    me.GotoPosition(nEnemyX, nEnemyY)
    return true
  end
  nFollowTeammateAttackFailCount = nFollowTeammateAttackFailCount + 1
  if nFollowTeammateAttackFailCount > 4 and nDoing == Npc.Doing.stand then
    me.GotoPosition(nEnemyX, nEnemyY)
  end
  return true
end
function AutoFight:OnBreakGreneralProcess(bProcessShow)
  if not bProcessShow or not self.nChangingMapForTeammateNpcId then
    return
  end
  local nMapId, nMyPosX, nMyPosY = me.GetWorldPos()
  local tbTeammate = TeamMgr:GetMemberData(self.nChangingMapForTeammateNpcId)
  if not tbTeammate or nMapId == tbTeammate.nMapId then
    return
  end
  local nX, nY = Map:GetDefaultPos(me.nMapTemplateId)
  AutoPath:GotoAndCall(me.nMapTemplateId, nX, nY, function()
    AutoPath:GotoAndCall(tbTeammate.nMapId, tbTeammate.nPosX, tbTeammate.nPosY, function()
      AutoFight:StartFollowTeammate(self.nChangingMapForTeammateNpcId, true)
    end, 10000)
  end, 100)
end
UiNotify:RegistNotify(UiNotify.emNOTIFY_BREAK_GENERALPROCESS, AutoFight.OnBreakGreneralProcess, AutoFight)
function AutoFight:OnDeath()
  if Map:GetMapType(me.nMapTemplateId) == Map.emMap_Public and AutoFight:IsFollowTeammate() and me.nPkMode ~= Player.MODE_PEACE then
    AutoFight:StopFollowTeammate()
  end
end
function AutoFight:ChangeHand()
  AutoFight:ChangeState(OperationType.Manual, true)
end
PlayerEvent:RegisterGlobal("OnDeath", AutoFight.OnDeath, AutoFight)
function AutoFight:StopAll()
  AutoFight:Stop()
  AutoFight:StopFollowTeammate()
end
