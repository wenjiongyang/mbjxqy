local tbBase = Battle:CreateClass("BattleAlone", "BattleComBase")
local tbBaseClass = Battle:GetClass("BattleComBase")
local tbDotaCom = Battle.tbDotaCom
local tbBattleSetting = Battle.tbAllBattleSetting.BattleAlone
function Battle:OnNpcDeath(him, pKiller)
  if not me.bInBattleAlone then
    return
  end
  tbBase:OnNpcDeath(him, pKiller)
end
function Battle:BeginClinetBattle()
  me.nFakeLevel = tbBattleSetting.nMeLevel
  me.bInBattleAlone = true
  UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_LOADED, tbBase.Init, tbBase)
  UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_LEAVE, tbBase.EndBattle, tbBase)
end
function tbBase:EndBattle(nTemplateID)
  me.bInBattleAlone = nil
  me.nFakeLevel = nil
  me.ClearTempRevivePos()
  me.GetNpc().SetTitleID(self.nOrgTitleId)
  if self.nOnReviveRegID then
    PlayerEvent:UnRegister(me, "OnRevive", self.nOnReviveRegID)
    self.nOnReviveRegID = nil
  end
  if self.nOnDeathRegID then
    PlayerEvent:UnRegister(me, "OnDeath", self.nOnDeathRegID)
    self.nOnDeathRegID = nil
  end
  if self.nOnKillNpcRegID then
    PlayerEvent:UnRegister(me, "OnKillNpc", self.nOnKillNpcRegID)
    self.nOnKillNpcRegID = nil
  end
  UiNotify:UnRegistNotify(UiNotify.emNOTIFY_MAP_LOADED, self)
  UiNotify:UnRegistNotify(UiNotify.emNOTIFY_MAP_LEAVE, self)
  if self.nMainTimer then
    Timer:Close(self.nMainTimer)
    self.nMainTimer = nil
  end
  if self.nActiveTimer then
    Timer:Close(self.nActiveTimer)
    self.nActiveTimer = nil
  end
end
function tbBase:GenRoleId()
  if not self.nGenId then
    self.nGenId = me.dwID
  end
  self.nGenId = self.nGenId + 1
  return self.nGenId
end
local function InitPlayerBUff()
  local pNpc = me.GetNpc()
  local nBuffID = tbBattleSetting.tbFactionBuff[me.nFaction]
  if nBuffID then
    pNpc.AddSkillState(nBuffID, 1, 0, 864000 * Env.GAME_FPS, 0, 1)
  end
  local nBornBUffId, nBornBuffLevel = unpack(tbBattleSetting.tbBornBuff)
  pNpc.AddSkillState(nBornBUffId, nBornBuffLevel, 0, 864000 * Env.GAME_FPS, 0, 1)
  pNpc.RestoreHP()
end
function tbBase:Init(nMapTemplateID)
  self.tbBattleSetting = tbBattleSetting
  assert(nMapTemplateID == tbBattleSetting.nMapTemplateId)
  local nMyFaction = me.nFaction
  local nMyLevel = me.nLevel
  local nMyTeamIndex = 1
  local tbPlayerInfos = {}
  self.tbPlayerInfos = tbPlayerInfos
  tbPlayerInfos[me.dwID] = {
    nTeamIndex = nMyTeamIndex,
    szName = me.szName,
    nFaction = nMyFaction,
    dwID = me.dwID,
    bPlayer = true
  }
  InitPlayerBUff()
  for nTeamIndex = 1, 2 do
    for nFaction = 1, 6 do
      if nTeamIndex ~= nMyTeamIndex or nFaction ~= nMyFaction then
        self:InitNpcData(nTeamIndex, nFaction)
      end
    end
  end
  self.tbBattleRank = {}
  for dwRoleId, v in pairs(tbPlayerInfos) do
    table.insert(self.tbBattleRank, {
      dwID = dwRoleId,
      nFaction = v.nFaction,
      szName = v.szName,
      nTeamIndex = v.nTeamIndex,
      nScore = 0,
      nKillCount = 0,
      nMaxCombo = 0,
      nComboCount = 0
    })
    self:InitPlayerBattleInfo(v)
    self:InitLockTarget(v)
  end
  me.GetNpc().SetPkMode(0)
  me.SetTempRevivePos(me.nMapId, unpack(Battle:GetRandInitPos(nMyTeamIndex, tbBattleSetting)))
  self.nOnReviveRegID = PlayerEvent:Register(me, "OnRevive", self.OnPlayerRevive, self)
  self.nOnDeathRegID = PlayerEvent:Register(me, "OnDeath", self.OnPlayerDeath, self)
  self.nOnKillNpcRegID = PlayerEvent:Register(me, "OnKillNpc", self.OnKillNpc, self)
  self.nOrgTitleId = PlayerTitle:GetPlayerTitleData().nActivateTitle or 0
  self:UpdatePlayerTitle(me, 1)
  tbDotaCom.Init(self)
  self.bOpenDialogId = true
  local function fnStart()
    if not self.bOpenDialogId then
      return
    end
    self.bOpenDialogId = false
    me.CenterMsg(string.format("你加入了%s", tbBattleSetting.tbTeamNames[nMyTeamIndex]))
    Battle:EnterFightMap(tbBattleSetting)
    self:Start()
  end
  if tbBattleSetting.nOpenDialogId then
    Ui:TryPlaySitutionalDialog(tbBattleSetting.nOpenDialogId, nil, {fnStart})
  else
    fnStart()
  end
end
function tbBase:InitLockTarget(tbInfo)
  local nEnemyIndex = tbInfo.nTeamIndex == 1 and 2 or 1
  if not tbInfo.nNpcId then
    return
  end
  local pNpc = KNpc.GetById(tbInfo.nNpcId)
  if not pNpc then
    return
  end
  for k, v in pairs(self.tbPlayerInfos) do
    if v.nTeamIndex == nEnemyIndex then
      if v.bPlayer then
        pNpc.AddAiLockTarget(me.GetNpc().nId)
      else
        pNpc.AddAiLockTarget(v.nNpcId)
      end
    end
  end
end
function tbBase:InitNpcData(nTeamIndex, nFaction, dwOldId)
  local tbInfo
  if dwOldId then
    tbInfo = self.tbPlayerInfos[dwOldId]
    assert(tbInfo)
    nFaction = tbInfo.nFaction
    nTeamIndex = tbInfo.nTeamIndex
  end
  local nX, nY = unpack(Battle:GetRandInitPos(nTeamIndex, tbBattleSetting))
  local pNpc = KPlayer.AddFakePlayer(nFaction, tbBattleSetting.nHimLevel, me.nMapId, nX, nY)
  pNpc.SetCamp(0)
  assert(pNpc)
  Npc:RegNpcOnDeath(pNpc, self.OnFakePlayerDeath, self)
  local tbSkillList = FightSkill:GetFakePlayerSkillList(nFaction, me.nLevel)
  for _, v in ipairs(tbSkillList) do
    local nSkillId, nLevel = unpack(v)
    pNpc.AddFightSkill(nSkillId, nLevel)
  end
  pNpc.AddFightSkill(1251, 1)
  local tbAttribList = RankBattle.tbAttrib[tbBattleSetting.nFakeAttriId]
  if tbAttribList then
    for _, tbAttrib in pairs(tbAttribList) do
      pNpc.ChangeAttribValue(tbAttrib.szAttribType, unpack(tbAttrib.tbValue))
    end
  end
  pNpc.SetCurLife(pNpc.nMaxLife)
  pNpc.SetPkMode(0)
  pNpc.nFightMode = 1
  pNpc.SetAi("Setting/Npc/Ai/BattleFakePlayer.ini")
  pNpc.SetAiActive(1)
  pNpc.szName = tbInfo and tbInfo.szName or Login:GetRandomName()
  local tbMovePath = tbBattleSetting.tbMovePathIndex[nTeamIndex]
  pNpc.nMovePath = tbMovePath[MathRandom(#tbMovePath)]
  dwOldId = dwOldId or self:GenRoleId()
  pNpc.dwID = dwOldId
  function pNpc.CallClientScript()
  end
  function pNpc.Msg()
  end
  function pNpc.CenterMsg()
  end
  if not tbInfo then
    tbInfo = {
      nTeamIndex = nTeamIndex,
      szName = pNpc.szName,
      nFaction = nFaction,
      nNpcId = pNpc.nId,
      dwID = dwOldId,
      nTitleLevel = 1
    }
    self.tbPlayerInfos[dwOldId] = tbInfo
  else
    tbInfo.nNpcId = pNpc.nId
  end
  self:UpdatePlayerTitle(pNpc, tbInfo.nTitleLevel)
  return pNpc
end
function tbBase:FakePlayerStartAttack(pNpc, tbInfo)
  pNpc.SetPkMode(3, tbInfo.nTeamIndex)
  pNpc.AI_ClearMovePathPoint()
  for _, Pos in ipairs(self.tbMovePath[pNpc.nMovePath]) do
    pNpc.AI_AddMovePos(unpack(Pos))
  end
  pNpc.AI_StartPath()
end
function tbBase:StartFight()
  tbBaseClass.StartFight(self)
  tbDotaCom.StartFight(self)
  self.nLastRefreshFakePlayerTime = 0
  for dwID, v in pairs(self.tbPlayerInfos) do
    if v.bPlayer then
      me.GetNpc().SetPkMode(3, v.nTeamIndex)
    else
      local pNpc = KNpc.GetById(v.nNpcId)
      if pNpc then
        self:FakePlayerStartAttack(pNpc, v)
      end
    end
  end
end
function tbBase:StopFight(nSetWinTeam)
  local nWinTeam = self:SetWinTeam(nSetWinTeam)
  local function fnEndFight(pNpc)
    pNpc.nFightMode = 0
    local tbInfo = self.tbPlayerInfos[pNpc.dwID]
    pNpc.SetPosition(unpack(Battle:GetRandInitPos(tbInfo.nTeamIndex, tbBattleSetting)))
  end
  self:ForEachFakePlayerInMap(fnEndFight)
  local tbTeamNames = tbBattleSetting.tbTeamNames
  local szWinNotify = "本方势如破竹，大获全胜"
  local szLostNotify = "本方力战不敌，鸣金收兵"
  local tbInfo = self.tbPlayerInfos[me.dwID]
  if nWinTeam == tbInfo.nTeamIndex then
    me.CenterMsg(szWinNotify, true)
  else
    me.CenterMsg(szLostNotify, true)
  end
  self:GotoBackBattle(me)
  me.GetNpc().SetPkMode(0)
  local szMsg = string.format("大侠你获得了%d分, 排名第%d", tbInfo.nScore, tbInfo.nRank)
  Ui:OpenWindow("BattleFieldTips", szMsg)
  me.Msg(szMsg)
  self:SynWinTeam(nWinTeam)
end
function tbBase:CloseBattle()
  RemoteServer.LeaveAloneBattle()
end
function tbBase:Active()
  local nTimeNow = GetTime()
  self:CheckStayInCamp(nTimeNow)
  self:SyncAllInfo(nTimeNow)
  tbDotaCom.Active(self, nTimeNow)
  if nTimeNow - self.nLastRefreshFakePlayerTime >= 3 then
    local fnUpdateFakePlayer = function(pFakePlayer)
      pFakePlayer.SetActiveForever(1)
    end
    self:ForEachFakePlayerInMap(fnUpdateFakePlayer)
    self.nLastRefreshFakePlayerTime = nTimeNow
  end
end
function tbBase:UpdatePlayerTitle(pPlayer, nTitleLevel, nDelTitleLevel)
  local dwRoleId = pPlayer.dwID
  if dwRoleId == me.dwID then
    pPlayer = me.GetNpc()
  end
  if nDelTitleLevel then
    pPlayer.SetTitleID(0)
  end
  if nTitleLevel then
    local tbInfo = self.tbPlayerInfos[dwRoleId]
    pPlayer.SetTitleID(Battle.tbTitleLevelSet[nTitleLevel].tbTitleID[tbInfo.nTeamIndex])
  end
end
function tbBase:ForEachInMap(fnFunction)
  fnFunction(me)
end
function tbBase:OnPlayerRevive(nType)
  local nRevMapId, nX, nY, nRevFightMode = me.GetTempRevivePos()
  if me.nMapId ~= nRevMapId then
    return
  end
  me.SetPosition(nX, nY)
  if nRevFightMode then
    me.nFightMode = nRevFightMode
  end
end
function tbBase:OnPlayerDeath(pKillerLuna)
  me.Revive(0)
  local pMeNpc = me.GetNpc()
  pMeNpc.SetPkMode(0)
  pMeNpc.ClearAllSkillCD()
  InitPlayerBUff()
  local tbMyInfo = self.tbPlayerInfos[me.dwID]
  tbMyInfo.nDeathCount = tbMyInfo.nDeathCount + 1
  tbMyInfo.nComboCount = 0
  local nDeadComboLevel = tbMyInfo.nComboLevel
  tbMyInfo.nComboLevel = 1
  me.CallClientScript("Ui:ShowComboKillCount", 0, true)
  tbMyInfo.nInBackCampTime = GetTime()
  if not pKillerLuna then
    return
  end
  local dwKillerId = pKillerLuna.dwID
  if not self.tbPlayerInfos[dwKillerId] then
    return
  end
  self:OnKillPlayer(pKillerLuna, me, nDeadComboLevel, tbMyInfo.nTitleLevel)
end
function tbBase:OnKillNpc()
  if him.dwID then
    return
  end
  tbDotaCom.OnKillNpc(self, me)
end
function tbBase:OnFakePlayerDeath(pKiller)
  local dwID = him.dwID
  if not dwID then
    return
  end
  local pNpc = self:InitNpcData(nil, nil, dwID)
  local tbMyInfo = self.tbPlayerInfos[dwID]
  self:InitLockTarget(tbMyInfo)
  self:FakePlayerStartAttack(pNpc, tbMyInfo)
  tbMyInfo.nDeathCount = tbMyInfo.nDeathCount + 1
  tbMyInfo.nComboCount = 0
  tbMyInfo.nInBackCampTime = GetTime()
  if not pKiller then
    return
  end
  if pKiller.GetPlayer() then
    pKiller = pKiller.GetPlayer()
  end
  if not pKiller.dwID then
    return
  end
  self:OnKillPlayer(pKiller, him, tbMyInfo.nComboLevel, tbMyInfo.nTitleLevel)
  if pKiller.dwID == me.dwID then
    me.CenterMsg(string.format("你击伤了「%s」！", him.szName), true)
  end
end
function tbBase:OnNpcDeath(him, pKiller)
  tbDotaCom.OnNpcDeath(self, him, pKiller)
  if pKiller and pKiller.dwID and pKiller.szClass == "BattleFakePlayer" then
    tbDotaCom.OnKillNpc(self, pKiller)
  end
  for nTeamIndex, nTemplateId in ipairs(tbBattleSetting.tbHomeBuildingId) do
    if him.nTemplateId == nTemplateId then
      self:StopFight(nTeamIndex == 1 and 2 or 1)
      self:DirGotoSchedule(3)
      break
    end
  end
end
function tbBase:ForEachFakePlayerInMap(fnFunction)
  for k, v in pairs(self.tbPlayerInfos) do
    if v.nNpcId then
      local pNpc = KNpc.GetById(v.nNpcId)
      if pNpc then
        fnFunction(pNpc)
      end
    end
  end
end
function tbBase:SyncAllInfo(nTimeNow)
  if self.bRankUpdate then
    self:UpdatePlayerRank()
    Battle:UpdateRankData(self.tbBattleRank, self.tbTeamScore, math.floor(Timer:GetRestTime(self.nMainTimer) / Env.GAME_FPS))
    self.bRankUpdate = false
  end
  local bSyncPos = nTimeNow % 3 == 0
  if bSyncPos then
    do
      local tbAllPos = {
        {},
        {}
      }
      local function fnGetPosInfo(pNpc)
        local dwRoleId = pNpc.dwID
        local tbInfo = self.tbPlayerInfos[dwRoleId]
        local _, x, y = pNpc.GetWorldPos()
        tbAllPos[tbInfo.nTeamIndex][dwRoleId] = {nX = x, nY = y}
      end
      self:ForEachFakePlayerInMap(fnGetPosInfo)
      local tbInfo = self.tbPlayerInfos[me.dwID]
      Battle:SyncPosInfo(tbAllPos[tbInfo.nTeamIndex])
    end
  end
end
function tbBase:SynWinTeam(nWinTeam)
  Battle:OnSynWinTeam(nWinTeam)
end
