local RepresentMgr = luanet.import_type("RepresentMgr")
ArenaBattle.tbArenaData = {}
ArenaBattle.tbApply = {}
ArenaBattle.tbWatchData = {}
ArenaBattle.nWatchNpcId = ArenaBattle.nWatchNpcId or 0
ArenaBattle.nWatchArenaId = 0
ArenaBattle.tbArenaState = {}
function ArenaBattle:OnSynChallengerData(tbData)
  ArenaBattle.tbApplyData = tbData
  UiNotify.OnNotify(UiNotify.emNOTIFY_SYN_ARENA_APPLY_DATA)
end
function ArenaBattle:OnSynArenaData(tbData)
  ArenaBattle.tbArenaData = tbData
  UiNotify.OnNotify(UiNotify.emNOTIFY_SYN_ARENA_DATA)
end
function ArenaBattle:OnSynApplyData(tbData)
  ArenaBattle.tbApply = tbData
  UiNotify.OnNotify(UiNotify.emNOTIFY_SYN_PLAYER_APPLY_ARENA_DATA, "ArenaBattle", {
    ChallengeInfo = ArenaBattle.tbApply
  })
end
function ArenaBattle:SynMyApplyData()
  RemoteServer.SynMyApplyData()
end
function ArenaBattle:SynChallengerData()
  RemoteServer.SynChallengerData()
end
function ArenaBattle:SynArenaData()
  RemoteServer.SynArenaData()
end
function ArenaBattle:ApplyChallenge(nArenaId)
  if not ArenaBattle:CheckIsArenaBattleMap() then
    me.CenterMsg("请前往比武场再进行挑战")
    return
  end
  if TeamMgr:HasTeam() and not TeamMgr:IsCaptain() then
    me.CenterMsg("队长才可以申请上擂台或挑战")
    return
  end
  RemoteServer.ApplyChallenge(nArenaId)
end
function ArenaBattle:PickChallenger(tbData)
  if not ArenaBattle:CheckIsArenaBattleMap() then
    me.CenterMsg("请前往比武场再进行选择挑战者")
    return
  end
  if TeamMgr:HasTeam() and not TeamMgr:IsCaptain() then
    me.CenterMsg("擂主队伍队长才可挑选挑战者")
    return
  end
  RemoteServer.ArenaChallenge(tbData)
end
function ArenaBattle:GetArenaData()
  return self.tbArenaData
end
function ArenaBattle:GetApplyData()
  return self.tbApplyData
end
function ArenaBattle:SyncFightState(nTime)
  Ui:OpenWindow("ArenaBattleInfo", nTime)
  Timer:Register(Env.GAME_FPS, function()
    UiNotify.OnNotify(UiNotify.emNOTIFY_SYN_ARENA_TIME_DATA, nTime)
  end)
end
function ArenaBattle:SyncPlayerLeftInfo(nMyCampId, tbDmgInfo)
  local nOtherCampId = 3 - nMyCampId
  UiNotify.OnNotify(UiNotify.emNOTIFY_SYN_ARENA_DMAGE_DATA, tbDmgInfo[nMyCampId].nKillCount, tbDmgInfo[nOtherCampId].nKillCount, tbDmgInfo[nMyCampId].nTotalDmg, tbDmgInfo[nOtherCampId].nTotalDmg, tbDmgInfo.szStateInfo)
end
function ArenaBattle:OnLogin()
  if me.nMapTemplateId ~= ArenaBattle.nArenaMapId then
    return
  end
  self:OnMainState()
  self:RefreshArenaState()
  ArenaBattle:SynMyApplyData()
end
function ArenaBattle:OnMainState()
  self:EndWatch(nil)
  Ui:OpenWindow("ArenaChallengerInfoPanel", "ArenaBattle", {
    ChallengeInfo = ArenaBattle.tbApply
  })
  Ui:ChangeUiState(Ui.STATE_ArenaBattleMain, true)
end
function ArenaBattle:OnConnectLost()
  self:DoEndWatch()
end
function ArenaBattle:OnMapEnter(nTemplateID)
  if nTemplateID ~= ArenaBattle.nArenaMapId then
    return
  end
  self:OnMainState()
  self:RefreshArenaState()
  self:SynMyApplyData()
  UiNotify:RegistNotify(UiNotify.emNOTIFY_SERVER_CONNECT_LOST, self.OnConnectLost, self)
end
function ArenaBattle:OnMapLeave(nTemplateID)
  if nTemplateID ~= ArenaBattle.nArenaMapId then
    return
  end
  Ui:CloseWindow("QYHLeavePanel")
  Ui:CloseWindow("ArenaChallengerInfoPanel")
  Ui:CloseWindow("ArenaPanel")
  Ui:CloseWindow("ChallengerPanel")
  UiNotify:UnRegistNotify(UiNotify.emNOTIFY_SERVER_CONNECT_LOST, self)
  Ui:DestroyLoadShowUi()
end
function ArenaBattle:Go2Arena()
  self:DoEndWatch()
  Ui:CloseWindow("WatchMenuPanel")
  Ui:CloseWindow("RoleHeadPop")
  Ui:CloseWindow("WelfareActivity")
  Ui:CloseWindow("CalendarPanel")
  Ui:CloseWindow("StrongerPanel")
  Ui:CloseWindow("NewInformationPanel")
  Ui:CloseWindow("HomeScreenCommunity")
end
function ArenaBattle:TurnArenaManDirect()
  self:WaitingState()
end
function ArenaBattle:OnPlayerLeave()
  Ui:CloseWindow("ArenaBattleInfo")
  Ui:OpenWindow("ArenaChallengerInfoPanel", "ArenaBattle", {
    ChallengeInfo = ArenaBattle.tbApply
  })
  Ui:CloseWindow("HomeScreenBattleInfo")
  Ui:CloseWindow("RoleHeadPop")
  Ui:CloseWindow("ChallengerPanel")
  Ui:ChangeUiState(Ui.STATE_ArenaBattleMain, true)
  UiNotify.OnNotify(UiNotify.emNOTIFY_REFRESH_QYH_BTN, "ArenaBattle", {
    "BtnLeave",
    "BtnWitnessWar",
    "BtnChallenge"
  })
end
function ArenaBattle:OnShowTeamInfo(nCampId, tbCampInfo, nWinCamp)
  Ui:OpenWindow("ArenaAccount", nCampId, tbCampInfo, nWinCamp)
  self:FightingState()
end
function ArenaBattle:OnFightingState(nTime)
  self:FightingState()
  self:SyncFightState(nTime)
end
function ArenaBattle:WaitingChooseState(nTime)
  self:WaitingState()
  Ui:OpenWindow("ArenaChallengerInfoPanel", "ArenaBattle", {
    ChallengeTitle = {
      szText = "请选择挑战者：",
      nTime = nTime
    }
  })
  Timer:Register(Env.GAME_FPS, function()
    UiNotify.OnNotify(UiNotify.emNOTIFY_REFRESH_QYH_BTN_TEXIAO, {
      "BtnChallenge"
    }, true)
  end)
end
function ArenaBattle:WaitingState()
  if Ui.nChangeUiState ~= Ui.STATE_ArenaBattleWait then
    Ui:ChangeUiState(Ui.STATE_ArenaBattleWait)
  end
  Ui:CloseWindow("ArenaChallengerInfoPanel")
  Ui:CloseWindow("ArenaPanel")
  Ui:CloseWindow("ArenaBattleInfo")
  Ui:CloseWindow("RoleHeadPop")
  Ui:OpenWindow("QYHLeavePanel", "ArenaBattle", {BtnLeave = true, BtnChallenge = true})
  Ui:SetLoadShowUI({
    nMapTID = ArenaBattle.nArenaMapId,
    tbUi = {BattleTopButton = 1}
  })
end
function ArenaBattle:FightingState()
  Ui:ChangeUiState(Ui.STATE_ArenaBattleFight)
  UiNotify.OnNotify(UiNotify.emNOTIFY_REFRESH_QYH_BTN, "ArenaBattle", {
    "BtnLeave",
    "BtnWitnessWar",
    "BtnChallenge"
  })
  Ui:CloseWindow("ArenaPanel")
  Ui:CloseWindow("ArenaChallengerInfoPanel")
  Ui:CloseWindow("ChallengerPanel")
  Ui:CloseWindow("RoleHeadPop")
end
function ArenaBattle:OnWaitingState()
  self:WaitingState()
  Ui:OpenWindow("ArenaChallengerInfoPanel", "ArenaBattle", {
    ChallengeTitle = {
      szText = "等待挑战者..."
    }
  })
  Timer:Register(Env.GAME_FPS, function()
    UiNotify.OnNotify(UiNotify.emNOTIFY_REFRESH_QYH_BTN_TEXIAO, {
      "BtnChallenge"
    })
  end)
end
function ArenaBattle:OnPlayerDeath()
  Ui:CloseWindow("HomeScreenBattleInfo")
end
function ArenaBattle:OnSynArenaState(nArenaId, bState)
  if not nArenaId then
    return
  end
  ArenaBattle.tbArenaState[nArenaId] = bState
end
function ArenaBattle:CheckWatchArenaIsFighting()
  return self.tbArenaState[self.nWatchArenaId]
end
function ArenaBattle:RefreshArenaState()
  RemoteServer.RefreshArenaState()
end
function ArenaBattle:OnRefreshArenaState(tbFightingArena)
  ArenaBattle.tbArenaState = {}
  for _, nArenaId in ipairs(tbFightingArena) do
    ArenaBattle.tbArenaState[nArenaId] = true
  end
end
function ArenaBattle:ForceStopWatch()
  self:DoEndWatch()
  UiNotify.OnNotify(UiNotify.emNOTIFY_REFRESH_QYH_BTN, "ArenaBattle", {
    "BtnLeave",
    "BtnWitnessWar",
    "BtnChallenge"
  })
  Ui:CloseWindow("WatchMenuPanel")
end
function ArenaBattle:CheckIsArenaBattleMap()
  if me.nMapTemplateId == ArenaBattle.nArenaMapId then
    return true
  end
end
function ArenaBattle:SendResultTip(szTip)
  if szTip and szTip ~= "" then
    me.Msg(szTip)
    local nNpcId = AutoAI.GetNpcIdByTemplateId(ArenaBattle.nArenaManagerNpcId)
    if nNpcId then
      local pNpc = KNpc.GetById(nNpcId)
      if pNpc then
        pNpc.BubbleTalk(szTip, ArenaBattle.szArenaManagerNpcBubbleTalkTime)
      end
    end
  end
end
function ArenaBattle:OnNoFightingEnterMap()
  Ui:CloseWindow("HomeScreenBattleInfo")
  Ui:CloseWindow("ArenaBattleInfo")
  Ui:CloseWindow("ArenaAccount")
  Ui:CloseWindow("WatchMenuPanel")
  UiNotify.OnNotify(UiNotify.emNOTIFY_REFRESH_QYH_BTN, "ArenaBattle", {
    "BtnLeave",
    "BtnWitnessWar",
    "BtnChallenge"
  })
end
function ArenaBattle:ShowComboKillCount(nComboCount, bNotHide)
  Ui:OpenWindow("HomeScreenBattleInfo", nil, nil, nComboCount, bNotHide)
end
function ArenaBattle:OnAutoChooseStop()
  self:OnWaitingState()
end
function ArenaBattle:SyncWatchInfo(tbData, nArenaId)
  ArenaBattle.tbWatchData = tbData
  self.nWatchArenaId = nArenaId
  self:AddShowRepNpc()
  Ui:OpenWindow("QYHLeavePanel", "ArenaBattle", {BtnWitnessWar = true})
end
function ArenaBattle:OnWatchTrapOut()
  RepresentMgr.ClearShowRepNpc()
  UiNotify.OnNotify(UiNotify.emNOTIFY_REFRESH_QYH_BTN, "ArenaBattle", {
    "BtnWitnessWar"
  })
end
function ArenaBattle:AddShowRepNpc()
  local tbPlayerData = self.nWatchArenaId and ArenaBattle.tbWatchData[self.nWatchArenaId]
  if not tbPlayerData then
    return tbData
  end
  for nCamp, tbPlayer in ipairs(tbPlayerData) do
    for _, tbPlayerInfo in ipairs(tbPlayer) do
      if tbPlayerInfo[2] then
        RepresentMgr.AddShowRepNpc(tbPlayerInfo[2])
      end
    end
  end
end
function ArenaBattle:StartWatch(nNpcId)
  if not self:CheckWatchArenaIsFighting() then
    me.CenterMsg("该擂台已经结束或者阵容改变")
    return
  end
  Operation:DisableWalking()
  Ui:ChangeUiState(Ui.STATE_WATCH_FIGHT)
  BindCameraToNpc(nNpcId, 220)
  self.nWatchNpcId = nNpcId
  UiNotify.OnNotify(UiNotify.emNOTIFY_REFRESH_WATCH, self:GetWatchData())
  return true
end
function ArenaBattle:GetWatchData()
  local tbData = {}
  local tbPlayerData = self.nWatchArenaId and ArenaBattle.tbWatchData[self.nWatchArenaId]
  if not tbPlayerData then
    return tbData
  end
  local tbWatch = {}
  for nCamp, tbPlayer in ipairs(tbPlayerData) do
    tbWatch[nCamp] = {}
    for _, tbPlayerInfo in ipairs(tbPlayer) do
      table.insert(tbWatch[nCamp], {
        name = tbPlayerInfo[1],
        id = tbPlayerInfo[2]
      })
    end
  end
  tbData = {
    nCurWatchId = ArenaBattle.nWatchNpcId,
    szType = "ArenaBattleWatch",
    tbPlayer = tbWatch
  }
  return tbData
end
function ArenaBattle:EndWatch(nNpcId, keepBtn)
  if nNpcId and nNpcId ~= self.nWatchNpcId then
    return
  end
  if not keepBtn then
    UiNotify.OnNotify(UiNotify.emNOTIFY_REFRESH_QYH_BTN, "ArenaBattle", {
      "BtnWitnessWar"
    })
  end
  self:DoEndWatch()
end
function ArenaBattle:DoEndWatch()
  if not self.nWatchNpcId or self.nWatchNpcId <= 0 then
    return
  end
  local pNpc = me.GetNpc()
  if pNpc then
    BindCameraToNpc(pNpc.nId, 220)
  end
  Ui:ChangeUiState(Ui.STATE_ArenaBattleMain, true)
  self.nWatchNpcId = 0
  Operation:EnableWalking()
  UiNotify.OnNotify(UiNotify.emNOTIFY_REFRESH_WATCH, self:GetWatchData())
end
function ArenaBattle:SynAllWatchingState(nNpcId)
  if nNpcId and nNpcId == self.nWatchNpcId then
    self:EndWatch(nNpcId, true)
    me.CenterMsg("您观战的玩家已经死亡或者掉线，请选择其他玩家进行观战", true)
  else
    UiNotify.OnNotify(UiNotify.emNOTIFY_REFRESH_WATCH, self:GetWatchData())
  end
end
