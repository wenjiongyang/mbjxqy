local RepresentMgr = luanet.import_type("RepresentMgr")
local TouchMgr = luanet.import_type("TouchMgr")
local SkillController = luanet.import_type("SkillController")
local EffectMoveType = {Rotate = 0, Move = 1}
Operation.nNoOpDelayOffLineTime = 600
Operation.eTargetModeUnlimited = 0
Operation.eTargetModeNpcFirst = 1
Operation.eTargetModePlayerFirst = 2
Operation.PRECISE_UI_OFFSET_X = 0
Operation.PRECISE_UI_OFFSET_Y = 0
Operation.PRECISE_CIRCLE_EFFECT = 9149
Operation.PRECISE_ARROW_EFFECT = 9150
Operation.PRECISE_TARGET_EFFECT = 9148
function Operation:MarkOperate()
  local nNow = GetTime()
  self.nDelayOffLineTime = nNow + Operation.nNoOpDelayOffLineTime
  self.nLastOperateTime = nNow
end
function Operation:DealDelayOffline()
  local nNow = GetTime()
  if nNow % 10 ~= 0 or not self.nDelayOffLineTime then
    return
  end
  if not Login.bEnterGame or IsServerConnected() == 0 then
    return
  end
  if AutoFight:IsAuto() then
    return
  end
  if not Map:IsCityMap(me.nMapTemplateId) and not Map:IsFieldFightMap(me.nMapTemplateId) then
    return
  end
  if OnHook:IsOnLineOnHook(me) then
    return
  end
  if Wedding:IsRoleWeddingTouring() then
    return
  end
  self.nLastUpdateTime = self.nLastUpdateTime or nNow
  self.nLastOperateTime = self.nLastOperateTime or nNow
  if 0 < nNow - self.nLastOperateTime and (nNow - self.nLastUpdateTime) % 20 == 0 then
    UiNotify.OnNotify(UiNotify.emNOTIFY_NO_OPERATE_UPDATE, self.nLastOperateTime, nNow)
  end
  if me.nFightMode ~= 0 then
    return
  end
  if nNow > self.nDelayOffLineTime then
    Log("No Operation Delay Logout")
    Ui.bKickOffline = true
    CloseServerConnect()
    Ui.bKickOffline = nil
    Ui:OpenWindow("MessageBox", "您超过10分钟没有操作游戏，为避免浪费，自动帮您下线累计离线托管时间，您现在要重新上线吗？", {
      {
        Ui.ReconnectServer,
        Ui
      },
      {
        Ui.ReturnToLogin,
        Ui
      }
    }, {
      "重连",
      "返回首页"
    }, nil, nil, true)
  end
end
function Operation:ClearScreen()
end
function Operation:RecoverScreen()
end
function Operation:OnDestroyMap()
  TouchMgr.SetJoyStick(false)
  SkillController.SetJoyStick(false)
  self:ClearPreciseOPEffect()
  Operation:MarkOperate()
end
function Operation:OnMapLoaded()
  Operation:EnableWalking()
  AutoFight:ClearManualAttack()
  Operation:UpdateJoyStickMovable()
  Operation:MarkOperate()
end
function Operation:SetGuidingJoyStick(bGuid)
  UiNotify.OnNotify(UiNotify.emNOTIFY_FAKE_JOYSTICK_GUIDING, bGuid and true or false)
  TouchMgr.SetJoyStickIgnoreUI(bGuid and true or false)
end
function Operation:ShowFakeJoystick()
  UiNotify.OnNotify(UiNotify.emNOTIFY_FAKE_JOYSTICK_STATE, true)
end
function Operation:HideFakeJoystick()
  UiNotify.OnNotify(UiNotify.emNOTIFY_FAKE_JOYSTICK_STATE, false)
end
function Operation:SetJoyStickUp()
  self.bOnJoyStick = false
  TouchMgr.SetJoyStickUp()
  SkillController.SetJoyStickUp()
  self:ClearPreciseOPEffect()
end
function Operation:IsJoyStickMovable()
  if Sdk:IsPCVersion() and Client:GetFlag("ForbidJoyStickMoving") == nil then
    return false
  end
  return not Client:GetFlag("ForbidJoyStickMoving")
end
function Operation:UpdateJoyStickMovable()
  local bMovable = Operation:IsJoyStickMovable()
  TouchMgr.SetJoyStickStartMovingRate(bMovable and 1 or 1000)
end
function Operation:SetJoyStickMovable(bMovable)
  Client:SetFlag("ForbidJoyStickMoving", not bMovable)
  Operation:UpdateJoyStickMovable()
end
function Operation:DisableWalking()
  self.bOnJoyStick = false
  self.bForbidClickMap = true
  TouchMgr.SetJoyStickUp()
  TouchMgr.SetJoyStick(false)
  SkillController.SetJoyStickUp()
  SkillController.SetJoyStick(false)
  self:ClearPreciseOPEffect()
end
function Operation:EnableWalking()
  TouchMgr.SetJoyStick(true)
  self.bForbidClickMap = false
end
function Operation:GetTargetPos()
  local eDoing = me.GetDoing()
  if eDoing ~= Npc.Doing.run and eDoing ~= Npc.Doing.jump then
    return
  end
  return me.GetTargetPosition()
end
function Operation:GoDirection(nDir)
  if Decoration.bActState then
    Decoration:ExitPlayerActState(me.dwID)
    return
  end
  if not self.bOnJoyStick then
    Operation:SetPositionEffect(false)
    if Ui:WindowVisible("RockerGuidePanel") == 1 then
      Ui:CloseWindow("RockerGuidePanel")
    end
    if Ui:WindowVisible("RoleHead") == 1 then
      Ui("RoleHead"):Operation(false)
    end
  end
  if AutoFight:IsAuto() then
    AutoFight:GoDirection(nDir, Env.GAME_FPS)
  else
    me.GoDirection(nDir, Env.GAME_FPS)
    me.StartDirection(nDir)
  end
  self.nLastGoDir = nDir
  self.bOnJoyStick = true
  Operation:MarkOperate()
  AutoPath:ClearGoPath()
  Player:OnPlayerPosChange()
end
function Operation:StopGoDir()
  if AutoFight:IsAuto() then
    AutoFight:GoDirection(self.nLastGoDir, 1)
  elseif self.nLastGoDir then
    me.GoDirection(self.nLastGoDir, 1)
  end
  me.StopDirection()
  self.nLastGoDir = nil
  self.bOnJoyStick = false
  if Ui:WindowVisible("RoleHead") == 1 then
    Ui("RoleHead"):Operation(true)
  end
end
function Operation:StopMoveNow()
  local _, nX, nY = me.GetNpc().GetWorldPos()
  me.GotoPosition(nX, nY)
  me.StopDirection()
end
function Operation:ClickObj(nX, nY)
  if not Login.bEnterGame then
    return false
  end
  if self.bOnJoyStick then
    return
  end
  if self.bForbidClickMap then
    return
  end
  if nX < 0 or nY < 0 then
    return false
  end
  UiNotify.OnNotify(UiNotify.emNOTIFY_CLICKOBJ, nX, nY)
end
function Operation:ClickMap(nX, nY, bShowArrow, nWalkCloseCallbackLength)
  if not Login.bEnterGame then
    return false
  end
  if self.bOnJoyStick then
    return
  end
  if self.bForbidClickMap then
    return
  end
  if nX <= 0 or nY <= 0 then
    return false
  end
  if me.GetDoing() == Npc.Doing.jump then
    return false
  end
  if Decoration.bActState then
    Decoration:ExitPlayerActState(me.dwID)
  end
  Operation:MarkOperate()
  local bCanGetThere = false
  if AutoFight:IsAuto() then
    bCanGetThere = AutoFight:GotoPosition(nX, nY)
  else
    bCanGetThere = me.GotoPosition(nX, nY, nWalkCloseCallbackLength)
  end
  if bShowArrow and bCanGetThere then
    Operation:UnselectNpc()
    Operation:SetPositionEffect(true, nX, nY)
    AutoPath:ClearGoPath()
    Player:OnPlayerPosChange()
    return true
  end
  Operation:SetPositionEffect(false)
  return false
end
function Operation:RepObjSimpleTap(nRepID)
  UiNotify.OnNotify(UiNotify.emNOTIFY_REPOBJSIMPLETAP, nRepID)
  Decoration:OnRepObjSimpleTap(nRepID)
end
function Operation:RepObjLongTapStart(nID, nScreenPosX, nScreenPosY)
  UiNotify.OnNotify(UiNotify.emNOTIFY_REPOBJLONGTAPSTART, nID, nScreenPosX, nScreenPosY)
end
function Operation:RepObjTouchUp(nRepID)
  UiNotify.OnNotify(UiNotify.emNOTIFY_REPOBJTOUCHUP, nRepID)
end
function Operation:SimpleTap(nNpcID)
  if not Login.bEnterGame then
    Login:SelRole(nNpcID)
    return
  end
  local pNpc = KNpc.GetById(nNpcID)
  if not pNpc then
    return
  end
  if pNpc.nKind == Npc.KIND.dialoger then
    Operation:OnDialogerClicked(pNpc.nId)
    Operation:SetNpcSelected(nNpcID)
    return
  end
  if pNpc.nPlayerID == me.dwID then
    return
  end
  if pNpc.nKind == Npc.KIND.player and pNpc.nPlayerID ~= 0 and pNpc.nPlayerID ~= me.dwID then
    Ui:OpenWindow("RoleHeadPop", {
      pNpc.nPlayerID,
      nNpcID
    })
  end
  if AutoFight:IsAuto() then
    AutoFight:SelectNpc(nNpcID)
    return
  end
  Operation:SetNpcSelected(nNpcID)
end
function Operation:OnDialogerClicked(nNpcID)
  local pNpc = KNpc.GetById(nNpcID)
  if not pNpc then
    return
  end
  local nDistance = me.GetNpc().GetDistance(pNpc.nId)
  if nDistance > Npc.DIALOG_DISTANCE then
    local nMapId, nX, nY = pNpc.GetWorldPos()
    AutoPath:GotoAndCall(nMapId, nX, nY, function()
      Operation:OnDialogerClicked(nNpcID)
    end, Npc.DIALOG_DISTANCE)
    return
  end
  if pNpc.IsAlone() then
    GameSetting:SetGlobalObj(me, pNpc, it)
    Npc:OnDialog(him.szClass, him.szScriptParam)
    GameSetting:RestoreGlobalObj()
  else
    RemoteServer.OnSimpleTapNpc(pNpc.nId)
  end
  if pNpc.szTag ~= "NoTurn" then
    Operation:Turn2Player(pNpc)
  end
end
function Operation:SetPositionEffect(bShow, nX, nY)
  RepresentMgr.SetTargetPositionEffect(bShow, nX or 0, nY or 0)
end
function Operation:Turn2Player(pNpc)
  local npcRep = RepresentMgr.GetNpcRepresent(pNpc.nId)
  if npcRep then
    npcRep.m_fChangerDirSpeed = 45
  end
  local _, nX1, nY1 = pNpc.GetWorldPos()
  local _, nX2, nY2 = me.GetWorldPos()
  local nAngle = math.atan2(nX1 - nX2, nY1 - nY2)
  local nDir = (nAngle + math.pi) / (2 * math.pi) * 64
  pNpc.SetDir(nDir)
end
local tbJumpType = {
  DoubleClick = 1,
  Slide = 2,
  Both = 3,
  None = 4
}
local tbJumpTypeDesc = {
  [tbJumpType.None] = "关闭",
  [tbJumpType.Slide] = "滑动跳跃",
  [tbJumpType.DoubleClick] = "双击跳跃",
  [tbJumpType.Both] = "滑动双击跳跃"
}
Operation.nJumpType = Operation.nJumpType or tbJumpType.None
function Operation:SwitchJumpType()
  self.nJumpType = self.nJumpType % #tbJumpTypeDesc + 1
  local szTips = string.format("当前轻功模式为:%s", tbJumpTypeDesc[self.nJumpType])
  me.CenterMsg(szTips)
end
function Operation:DoubleTap(nPosX, nPosY)
  if self.nJumpType ~= tbJumpType.Both and self.nJumpType ~= tbJumpType.DoubleClick then
    return
  end
  if not Login.bEnterGame then
    return
  end
  if me.GetDoing() == Npc.Doing.jump then
    return false
  end
  Operation:JumpTo(nPosX, nPosY, false)
end
function Operation:Slide(nDirX, nDirY)
  if self.nJumpType ~= tbJumpType.Both and self.nJumpType ~= tbJumpType.Slide then
    return
  end
  if not Login.bEnterGame then
    return
  end
  Operation:SetPositionEffect(false)
  Operation:JumpTo(nDirX, nDirY, true)
end
function Operation:LongTapStart(nNpcID, nScreenPosX, nScreenPosY)
end
function Operation:Attack(nSkillID, bAngerSkill)
  if Operation:IsNeedOpenPreciseUI(nSkillID) then
    return
  end
  local bRet = Operation:JoyStickAttack(nSkillID)
  if bRet then
    Operation:SetPositionEffect(false)
  end
end
function Operation:_UseSkill(nSkillID, nTargetId, nDir, nX, nY)
  if nSkillID == 306 or nSkillID == 2116 then
    nTargetId = me.GetNpc().nId
  end
  local nSkillAttackType = FightSkill:GetSkillAttackType(nSkillID)
  if AutoFight:IsAuto() and not self.bOnJoyStick and nSkillAttackType ~= FightSkill.AttackType.Normal then
    local nType = AutoFight.MANUAL_SKILL_TYPE.NPC
    if (not nTargetId or nTargetId == 0) and nDir then
      AutoFight:ManualAttack(nSkillID, AutoFight.MANUAL_SKILL_TYPE.DIR, nDir)
    elseif nX and nY then
      AutoFight:ManualAttack(nSkillID, AutoFight.MANUAL_SKILL_TYPE.POS, nX, nY)
    else
      AutoFight:ManualAttack(nSkillID, AutoFight.MANUAL_SKILL_TYPE.NPC, nTargetId)
    end
  elseif nTargetId and nTargetId ~= 0 then
    return Operation:UseSkillToNpc(nSkillID, nTargetId)
  elseif nDir then
    return Operation:UseSkillToDir(nSkillID, nDir)
  elseif nX and nY then
    return Operation:UseSkillToPos(nSkillID, nX, nY)
  end
end
function Operation:JoyStickAttack(nSkillID)
  local nSkillAttackType = FightSkill:GetSkillAttackType(nSkillID)
  local nSkillAttackRadius = FightSkill:GetAttackRadius(nSkillID)
  local pNpc = me.GetNpc()
  local nDir = self.nLastGoDir or pNpc.GetDir()
  local nTargetId
  if nSkillAttackType == FightSkill.AttackType.Normal then
    if self.bOnJoyStick then
      nTargetId = pNpc.GetNearestEnemyByDir(nDir, nSkillAttackRadius)
    end
    nTargetId = nTargetId or Operation:GetNearestEnemyId(nSkillAttackRadius)
    return self:_UseSkill(nSkillID, nTargetId, nDir)
  end
  if nSkillAttackType == FightSkill.AttackType.Direction then
    if not self.bOnJoyStick then
      nTargetId = pNpc.GetNearestEnemyByDir(nDir, nSkillAttackRadius) or Operation:GetNearestEnemyId(nSkillAttackRadius)
    end
    return self:_UseSkill(nSkillID, nTargetId, nDir)
  end
  if nSkillAttackType == FightSkill.AttackType.Target then
    nTargetId = pNpc.GetNearestEnemyByDir(nDir, nSkillAttackRadius) or Operation:GetNearestEnemyId(nSkillAttackRadius)
    return self:_UseSkill(nSkillID, nTargetId)
  end
  assert(false, "SkillAttack表填错啦~~")
end
function Operation:SetNpcSelected(nNpcID)
  if Ui.bShowDebugInfo then
    local pNpc = KNpc.GetById(nNpcID)
    if pNpc then
      local szDebugInfo = "" .. "nId: " .. pNpc.nId .. "\n" .. "szName: " .. pNpc.szName .. "\n" .. "nLevel: " .. pNpc.nLevel .. "\n" .. "nTemplateId: " .. pNpc.nTemplateId .. "\n" .. "szClass: " .. pNpc.szClass .. "\n" .. "szScriptParam: " .. pNpc.szScriptParam .. "\n"
      Ui:SetDebugInfo(szDebugInfo)
    end
  end
  local eDoing = me.GetDoing()
  if eDoing == Npc.Doing.stand then
    me.GetNpc().SetDirToNpc(nNpcID or 0)
  end
  local nCurSelectNpcId = RepresentMgr.GetTargetSelectNpcId()
  if not nNpcID or nNpcID == 0 or nNpcID == nCurSelectNpcId then
    return
  end
  local npcRep = RepresentMgr.GetNpcRepresent(nNpcID)
  if npcRep then
    me.nAttackSkillId = me.nAttackSkillId or FightSkill:GetSkillIdByBtnName(me.nFaction, "Attack")
    local bCanAttack = me.CheckSkillAvailable2Npc(me.nAttackSkillId, nNpcID) and true or false
    if not bCanAttack then
      npcRep:SetSelectedEffect(true, bCanAttack)
      npcRep:PlayNpcEffect(13, 1, false)
    end
  end
end
function Operation:UnselectNpc()
  AutoAI.SetTargetIndex(0)
  local nCurSelectNpcId = RepresentMgr.GetTargetSelectNpcId()
  if nCurSelectNpcId == 0 then
    return
  end
  local npcRep = RepresentMgr.GetNpcRepresent(nCurSelectNpcId)
  if npcRep then
    npcRep:SetSelectedEffect(false, false)
  end
end
function Operation:ManualJump(nJumpSkillId)
  local pNpc = me.GetNpc()
  local nDir = self.nLastGoDir or pNpc and pNpc.GetDir()
  if not nDir then
    return
  end
  local nDistance, nDstX, nDstY = me.GetCanMoveDistance(nDir, 100)
  if nDistance <= 0 then
    return
  end
  self:DoJump(nJumpSkillId, nDstX, nDstY, false, false)
end
function Operation:JumpTo(nX, nY, bSlide)
  local nJumpSkillId = Faction:GetJumpSkillId(me.nFaction, 10)
  self:DoJump(nJumpSkillId, nX, nY, bSlide, false)
end
function Operation:ForceJump(nX, nY, nSkillKindId)
  local nJumpSkillId = Faction:GetJumpSkillId(me.nFaction, nSkillKindId or 2)
  self:DoJump(nJumpSkillId, nX, nY, false, true)
end
function Operation:DoJump(nJumpSkillId, nX, nY, bSlide, bTrap)
  local nDoing = me.GetDoing()
  if AutoFight:IsAuto() and nDoing ~= Npc.Doing.sit then
    AutoFight:ManualJumpTo(nJumpSkillId, nX, nY, bSlide, bTrap)
  else
    me.JumpTo(nJumpSkillId, nX, nY, bSlide, bTrap)
  end
  if nDoing == Npc.Doing.jump then
    Operation:SetPositionEffect(false)
  end
end
function Operation:UseSkillToNpc(nSkillID, nNpcID)
  if nSkillID == 306 or nSkillID == 2116 then
    nNpcID = me.GetNpc().nId
  end
  if not nNpcID or nNpcID == 0 then
    nNpcID = me.GetNpc().nId
  end
  if not me.CanCastSkill(nSkillID) then
    return false
  end
  local bRet = me.UseSkill(nSkillID, -1, nNpcID)
  if self.bOnJoyStick then
    self:GoDirection(self.nLastGoDir)
  end
  return bRet
end
function Operation:UseSkillToPos(nSkillID, nPosX, nPosY)
  local bRet = me.UseSkill(nSkillID, nPosX, nPosY)
  if self.bOnJoyStick then
    self:GoDirection(self.nLastGoDir)
  end
  return bRet
end
function Operation:UseSkillToDir(nSkillID, nDir)
  local bRet = me.UseSkillToDir(nSkillID, nDir)
  if self.bOnJoyStick then
    self:GoDirection(self.nLastGoDir)
  end
  return bRet
end
function Operation:OnGatherClicked(pNpc)
  local bMature, nMatureId, nUnMatureId, nMatureTime = CommerceTask:ResolveGatherParam(pNpc.szScriptParam)
  if not CommerceTask:GatherThingInTask(me, nMatureId) then
    return
  end
  local nMapTemplateId, nX1, nY1 = pNpc.GetWorldPos()
  local _, nX2, nY2 = me.GetWorldPos()
  local nDistance = math.abs(nX2 - nX1) + math.abs(nY2 - nY1)
  if nDistance > 300 then
    local function fnCallBack()
      RemoteServer.OnSimpleTapNpc(pNpc.nId)
    end
    AutoPath:GotoAndCall(nMapTemplateId, nX1, nY1, fnCallBack)
  else
    RemoteServer.OnSimpleTapNpc(pNpc.nId)
  end
end
function Operation:GetNearestEnemyId(nRadius)
  local pNpc = me.GetNpc()
  if not pNpc then
    return
  end
  nRadius = nRadius or 10000
  local nSelectMode = Operation:GetSelectTargetMode()
  local nRelationUnlimited = 2 ^ Npc.RELATION.enemy
  if nSelectMode == Operation.eTargetModeNpcFirst then
    return pNpc.GetNearestNpcIdByRelation(nRelationUnlimited + 2 ^ Npc.RELATION.npc, nRadius) or pNpc.GetNearestNpcIdByRelation(nRelationUnlimited, nRadius)
  elseif nSelectMode == Operation.eTargetModePlayerFirst then
    return pNpc.GetNearestNpcIdByRelation(nRelationUnlimited + 2 ^ Npc.RELATION.player, nRadius) or pNpc.GetNearestNpcIdByRelation(nRelationUnlimited, nRadius)
  end
  return pNpc.GetNearestNpcIdByRelation(nRelationUnlimited, nRadius)
end
function Operation:GetNearestEnemyIdByPos(nRadius, nX, nY)
  nRadius = nRadius or 10000
  local nRelationUnlimited = 2 ^ Npc.RELATION.enemy
  local nSelectMode = Operation:GetSelectTargetMode()
  if nSelectMode == Operation.eTargetModeNpcFirst then
    return AutoAI.GetNearestNpcByPosition(nX, nY, nRadius, nRelationUnlimited + 2 ^ Npc.RELATION.npc) or AutoAI.GetNearestNpcByPosition(nX, nY, nRadius, nRelationUnlimited)
  elseif nSelectMode == Operation.eTargetModePlayerFirst then
    return AutoAI.GetNearestNpcByPosition(nX, nY, nRadius, nRelationUnlimited + 2 ^ Npc.RELATION.player) or AutoAI.GetNearestNpcByPosition(nX, nY, nRadius, nRelationUnlimited)
  end
  return AutoAI.GetNearestNpcByPosition(nX, nY, nRadius, nRelationUnlimited)
end
function Operation:OnTouchReturn(szTopUi, bClose)
  if szTopUi then
    if bClose then
      Ui:CloseWindow(szTopUi)
    elseif szTopUi ~= "" then
      local tbWnd = Ui(szTopUi)
      if tbWnd and tbWnd.OnTouchReturn then
        tbWnd:OnTouchReturn()
      end
    end
  else
    Sdk:Exit()
  end
end
local tbKeyFun = {
  a = function()
    Operation:Attack(410)
  end,
  s = function()
    Operation:Attack(407)
  end,
  d = function()
    Operation:Attack(406)
  end,
  f = function()
    Operation:Attack(412)
  end,
  w = function()
    Operation:Attack(401)
  end
}
function Operation:KeyDown(szKeys)
  if not Login.bEnterGame then
    return
  end
  for i = 1, #szKeys do
    local szKey = string.sub(szKeys, i, i)
    if tbKeyFun[szKey] then
      tbKeyFun[szKey]()
    end
  end
end
function Operation:GetSelectTargetMode()
  return Client:GetFlag("SelectTargetMode") or Operation.eTargetModeUnlimited
end
function Operation:SetSelectTargetMode(nMode)
  Client:SetFlag("SelectTargetMode", nMode or Operation.eTargetModeUnlimited)
end
function Operation:SetPreciseSkillOp()
  Ui:GetPlayerSetting().nPreciseSkillOp = math.mod((Ui:GetPlayerSetting().nPreciseSkillOp or 0) + 1, 2)
end
function Operation:IsPreciseSkillOp()
  local tbUserSet = Ui:GetPlayerSetting()
  return tbUserSet.nPreciseSkillOp == 1
end
function Operation:IsNeedOpenPreciseUI(nSkillID)
  return FightSkill.tbPreciseCastSkill[nSkillID] and self:IsPreciseSkillOp()
end
function Operation:OpenPreciseUI(nSkillID)
  SkillController.SetJoyStick(true)
  self.nCurPreciseCastSkill = nSkillID
  UiNotify.OnNotify(UiNotify.emNOTIFY_PRECISE_CAST, true)
  self.bCancelPreciseCast = false
  local pNpc = me.GetNpc()
  if not pNpc then
    return
  end
  local npcRep = RepresentMgr.GetNpcRepresent(pNpc.nId)
  if not npcRep then
    return
  end
  self.tbCurSkillPreciseInfo = FightSkill.tbPreciseCastSkill[nSkillID]
  if not self.tbCurSkillPreciseInfo then
    return
  end
  local nCastRadius = self.tbCurSkillPreciseInfo.CastRadius / 100
  local nDamageRadius = self.tbCurSkillPreciseInfo.DamageRadius / 100
  npcRep:PlayNpcEffect(self.PRECISE_CIRCLE_EFFECT, 1, true)
  npcRep:SetEffectScale(self.PRECISE_CIRCLE_EFFECT, nCastRadius, 1, nCastRadius)
  if self.tbCurSkillPreciseInfo.CastType == "direction" then
    SkillController.BindNpcEffect(EffectMoveType.Rotate, pNpc.nId, self.PRECISE_ARROW_EFFECT, nCastRadius, 0.05)
    npcRep:PlayNpcEffect(self.PRECISE_ARROW_EFFECT, 1, true)
    npcRep:SetEffectScale(self.PRECISE_ARROW_EFFECT, nCastRadius * 0.7, 1, nCastRadius)
    npcRep:SetEffectDir(self.PRECISE_ARROW_EFFECT, (pNpc.GetDir() + Env.LOGIC_MAX_DIR / 2) % Env.LOGIC_MAX_DIR)
  elseif self.tbCurSkillPreciseInfo.CastType == "target" then
    SkillController.BindNpcEffect(EffectMoveType.Move, pNpc.nId, self.PRECISE_TARGET_EFFECT, nCastRadius, 0.05)
    npcRep:PlayNpcEffect(self.PRECISE_TARGET_EFFECT, 1, true)
    npcRep:SetEffectRotate(self.PRECISE_TARGET_EFFECT, 0, 0, 0)
    npcRep:SetEffectScale(self.PRECISE_TARGET_EFFECT, nDamageRadius, 1, nDamageRadius)
    local nTargetId = Operation:GetNearestEnemyId(self.tbCurSkillPreciseInfo.CastRadius)
    if nTargetId and nTargetId ~= 0 then
      local pNpc = KNpc.GetById(nTargetId)
      if pNpc then
        local _, nX, nY = pNpc.GetWorldPos()
        npcRep:SetEffectWorldPosition(self.PRECISE_TARGET_EFFECT, nX, nY)
      end
    end
  end
  self.nStartControllerDir = SkillController.GetJoyStickDir()
end
function Operation:ClosePreciseUI()
  SkillController.SetJoyStickUp()
  self:ClearPreciseOPEffect()
end
function Operation:IsCancelPreciseCast()
  return self.bCancelPreciseCast
end
function Operation:OnSkillControllerTouchStart()
end
function Operation:OnSkillControllerTouchUp()
  UiNotify.OnNotify(UiNotify.emNOTIFY_PRECISE_TOUCH_UP)
  UiNotify.OnNotify(UiNotify.emNOTIFY_PRECISE_CAST, false)
  if not self.nCurPreciseCastSkill then
    self:ClearPreciseOPEffect()
    return
  end
  local nSkillId = self.nCurPreciseCastSkill
  self.nCurPreciseCastSkill = nil
  if self:IsCancelPreciseCast() then
    self:ClearPreciseOPEffect()
    return
  end
  self:SetCancelPreciseCast(true)
  if self.tbCurSkillPreciseInfo.CastType == "direction" then
    local nDir = SkillController.GetJoyStickDir()
    if nDir < 0 or self.nStartControllerDir == nDir then
      local pNpc = me.GetNpc()
      if pNpc then
        nDir = pNpc.GetDir()
      end
    end
    self:_UseSkill(nSkillId, nil, nDir)
  elseif self.tbCurSkillPreciseInfo.CastType == "target" then
    local vecPos = SkillController.GetTargetPos()
    self:_UseSkill(nSkillId, nil, nil, vecPos.x, vecPos.y)
  end
  self:ClearPreciseOPEffect()
end
function Operation:ClearPreciseOPEffect()
  local pNpc = me.GetNpc()
  if not pNpc then
    return
  end
  local npcRep = RepresentMgr.GetNpcRepresent(pNpc.nId)
  if not npcRep then
    return
  end
  npcRep:ClearPlayNpcEffect(self.PRECISE_CIRCLE_EFFECT, true)
  npcRep:ClearPlayNpcEffect(self.PRECISE_ARROW_EFFECT, true)
  npcRep:ClearPlayNpcEffect(self.PRECISE_TARGET_EFFECT, true)
end
function Operation:SetCancelPreciseCast(bCancel)
  self.bCancelPreciseCast = bCancel
end
Operation.tbKEY2BUTTON = {
  R1 = "SkillDodge",
  R2 = "Attack",
  L1 = "BtnDazuo",
  L2 = "Skill5",
  A = "Skill1",
  B = "Skill4",
  X = "Skill2",
  Y = "Skill3"
}
function Operation:OnGamesirStickClick(szKeyName)
  if not Login.bEnterGame then
    return
  end
  local tbUiBattle = Ui("HomeScreenBattle")
  local szButton = self.tbKEY2BUTTON[szKeyName]
  if tbUiBattle and szButton and tbUiBattle.tbOnClick[szButton] then
    tbUiBattle.tbOnClick[szButton](tbUiBattle)
  end
end
function Operation:InitGamesir()
  if version_tx then
    TouchMgr.InitGamesirStick()
  end
end
function Operation:ConnectGamesir()
  if version_tx then
    TouchMgr.TryConnectGamesir()
  end
end
function Operation:OnHorseClick()
  if not Login.bEnterGame then
    return
  end
  local tbUiBattle = Ui("RoleHead")
  if tbUiBattle and tbUiBattle.tbOnClick.BtnMount then
    tbUiBattle.tbOnClick.BtnMount(tbUiBattle)
  end
end
