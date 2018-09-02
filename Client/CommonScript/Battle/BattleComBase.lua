Require("CommonScript/Battle/Battle.lua")
Battle.tbClass = Battle.tbClass or {}
function Battle:CreateClass(szClass, szBaseClass)
  if szBaseClass and self.tbClass[szBaseClass] then
    self.tbClass[szClass] = Lib:NewClass(self.tbClass[szBaseClass])
  else
    self.tbClass[szClass] = {}
  end
  local tbClassInst = self.tbClass[szClass]
  local tbSeting = self.tbAllBattleSetting[szClass]
  if tbSeting then
    self.tbDotaCom.Setup(tbClassInst, tbSeting)
  end
  return tbClassInst
end
function Battle:GetClass(szClassName)
  return self.tbClass[szClassName]
end
local tbBase = Battle:CreateClass("BattleComBase")
function tbBase:Start()
  self.STATE_TRANS = Battle.STATE_TRANS[self.tbBattleSetting.nUseSchedule]
  self.nSchedulePos = 0
  self:StartSchedule()
end
function tbBase:StartSchedule()
  local tbLastSchedule = self.STATE_TRANS[self.nSchedulePos]
  if tbLastSchedule then
    Lib:CallBack({
      self[tbLastSchedule.szFunc],
      self,
      tbLastSchedule.tbParam
    })
  end
  self.nMainTimer = nil
  self.nSchedulePos = self.nSchedulePos + 1
  local tbNextSchedule = self.STATE_TRANS[self.nSchedulePos]
  if not tbNextSchedule then
    return
  end
  self.nMainTimer = Timer:Register(Env.GAME_FPS * tbNextSchedule.nSeconds, self.StartSchedule, self)
end
function tbBase:DirGotoSchedule(nPos)
  if self.nMainTimer then
    Timer:Close(self.nMainTimer)
    self.nMainTimer = nil
  end
  self.nSchedulePos = nPos
  local tbNextSchedule = self.STATE_TRANS[nPos]
  if not tbNextSchedule then
    return
  end
  self.nMainTimer = Timer:Register(Env.GAME_FPS * tbNextSchedule.nSeconds, self.StartSchedule, self)
end
function tbBase:StartFight()
  self.nFirstBloodPlayerId = nil
  self.tbTeamScore = {0, 0}
  self.tbUpdateTeamScoreTime = {0, 0}
  self.bRankUpdate = true
  local nTimeNow = GetTime()
  local function fnNofiy(pPlayer)
    pPlayer.CenterMsg("战斗开始！请各位前往前线")
    local tbInfo = self.tbPlayerInfos[pPlayer.dwID]
    tbInfo.nInBackCampTime = nTimeNow
    pPlayer.CallClientScript("Battle:UpdateBattleUiState", self.nSchedulePos + 1)
  end
  self:ForEachInMap(fnNofiy)
  self.nBattleOpen = 1
  self.nStartTime = nTimeNow
  self.nActiveTimer = Timer:Register(Env.GAME_FPS, function()
    self:Active()
    return true
  end)
end
function tbBase:StopFight()
end
function tbBase:CloseBattle()
end
function tbBase:Active()
end
function tbBase:InitPlayerBattleInfo(tbInfo)
  tbInfo.nScore = 0
  tbInfo.nRank = 1
  tbInfo.nKillPlayer = 0
  tbInfo.nKillNpc = 0
  tbInfo.nDeathCount = 0
  tbInfo.nComboCount = 0
  tbInfo.nMaxCombo = 0
  tbInfo.nComboLevel = 1
  tbInfo.nTitleLevel = 1
  tbInfo.nKillCount = 0
  tbInfo.nInBackCampTime = 0
end
function tbBase:AddScore(pPlayer, nAddScore)
  if self.nBattleOpen ~= 1 then
    return
  end
  local dwRoleId = pPlayer.dwID
  local tbInfo = self.tbPlayerInfos[dwRoleId]
  tbInfo.nScore = tbInfo.nScore + nAddScore
  local nNewTitleLevel = tbInfo.nTitleLevel
  for i = nNewTitleLevel + 1, #Battle.tbTitleLevelSet do
    local v = Battle.tbTitleLevelSet[i]
    if tbInfo.nScore < v.nNeedScore then
      break
    else
      nNewTitleLevel = i
    end
  end
  if tbInfo.nTitleLevel ~= nNewTitleLevel then
    self:UpdatePlayerTitle(pPlayer, nNewTitleLevel, tbInfo.nTitleLevel)
    tbInfo.nTitleLevel = nNewTitleLevel
  end
  self:AddTeamScore(tbInfo.nTeamIndex, nAddScore)
end
function tbBase:UpdatePlayerTitle(pPlayer, nTitleLevel, nDelTitleLevel)
end
function tbBase:AddTeamScore(nTeam, nAddScore)
  if self.nBattleOpen ~= 1 or not self.tbTeamScore[nTeam] then
    return
  end
  self.tbTeamScore[nTeam] = self.tbTeamScore[nTeam] + nAddScore
  self.tbUpdateTeamScoreTime[nTeam] = GetTime()
  self.bRankUpdate = true
end
function tbBase:UpdatePlayerRank()
  for _, tbRankInfo in ipairs(self.tbBattleRank) do
    local tbInfo = self.tbPlayerInfos[tbRankInfo.dwID]
    tbRankInfo.nScore = tbInfo.nScore
    tbRankInfo.nKillCount = tbInfo.nKillCount
    tbRankInfo.nMaxCombo = tbInfo.nMaxCombo
    tbRankInfo.nComboCount = tbInfo.nComboCount
  end
  local fnSort = function(tbRankA, tbRankB)
    return tbRankA.nScore > tbRankB.nScore
  end
  table.sort(self.tbBattleRank, fnSort)
  for i, tbRankInfo in ipairs(self.tbBattleRank) do
    self.tbPlayerInfos[tbRankInfo.dwID].nRank = i
  end
end
function tbBase:ComboKill(pPlayer, tbInfo)
  tbInfo = tbInfo or self.tbPlayerInfos[pPlayer.dwID]
  tbInfo.nComboCount = tbInfo.nComboCount + 1
  if tbInfo.nComboCount > tbInfo.nMaxCombo then
    tbInfo.nMaxCombo = tbInfo.nComboCount
  end
  pPlayer.CallClientScript("Ui:ShowComboKillCount", tbInfo.nComboCount, true)
  local nNewComboLevel = tbInfo.nComboLevel
  for i = nNewComboLevel + 1, #Battle.tbComboLevelSet do
    local v = Battle.tbComboLevelSet[i]
    if tbInfo.nComboCount < v.nComboCount then
      break
    else
      nNewComboLevel = i
    end
  end
  if tbInfo.nComboLevel ~= nNewComboLevel then
    local tbComboInfo = Battle.tbComboLevelSet[nNewComboLevel]
    tbInfo.nComboLevel = nNewComboLevel
    self:BattleFieldTips(string.format(tbComboInfo.szNotify, tbInfo.szName))
  end
  self.bRankUpdate = true
end
function tbBase:ForEachInMap(fnFunction)
end
function tbBase:BlackMsg(szMsg)
  local function fnExcute(pPlayer)
    Dialog:SendBlackBoardMsg(pPlayer, szMsg)
  end
  self:ForEachInMap(fnExcute)
end
function tbBase:BattleFieldTips(szMsg)
  local function fnNofiy(pEveryOne)
    pEveryOne.CallClientScript("Ui:OpenWindow", "BattleFieldTips", szMsg)
  end
  self:ForEachInMap(fnNofiy)
end
function tbBase:OnKillPlayer(pPlayerNpc, pDeader, nComboLevel, nTitleLevel)
  if not self.nFirstBloodPlayerId then
    self.nFirstBloodPlayerId = true
    self:BattleFieldTips(string.format("%s击败了%s，拿到第一滴血", pPlayerNpc.szName, pDeader.szName))
  end
  local tbDeadTitileInfo = Battle.tbComboLevelSet[nComboLevel]
  if tbDeadTitileInfo.szKilledNotify then
    self:BattleFieldTips(string.format(tbDeadTitileInfo.szKilledNotify, pPlayerNpc.szName, pDeader.szName))
  end
  local dwRoleId = pPlayerNpc.dwID
  local tbKillerInfo = self.tbPlayerInfos[dwRoleId]
  local nScore = Battle.tbTitleLevelSet[nTitleLevel].nKillAddScore
  tbKillerInfo.nKillCount = tbKillerInfo.nKillCount + 1
  self:AddScore(pPlayerNpc, nScore)
  self:ComboKill(pPlayerNpc, tbKillerInfo)
end
function tbBase:CheckStayInCamp(nTimeNow)
  local function fnCheck(pPlayer)
    local tbInfo = self.tbPlayerInfos[pPlayer.dwID]
    if tbInfo.nInBackCampTime ~= 0 and nTimeNow - tbInfo.nInBackCampTime > self.tbBattleSetting.BACK_IN_CAMP_TIME then
      self:GotoFrontBattle(pPlayer)
    end
  end
  self:ForEachInMap(fnCheck)
end
function tbBase:GotoFrontBattle(pPlayer)
  local tbInfo = self.tbPlayerInfos[pPlayer.dwID]
  if self.tbBattleSetting.tbPosBattle then
    local tbPos = self.tbBattleSetting.tbPosBattle[tbInfo.nTeamIndex]
    pPlayer.SetPosition(unpack(tbPos[MathRandom(#tbPos)]))
    local nSkillId, nSkillLevel, nSkillTime = unpack(Battle.tbRevieBuff)
    pPlayer.AddSkillState(nSkillId, nSkillLevel, 0, nSkillTime * Env.GAME_FPS)
  end
  pPlayer.GetNpc().SetPkMode(3, tbInfo.nTeamIndex)
  tbInfo.nInBackCampTime = 0
end
function tbBase:SetWinTeam(nWinTeam)
  self.nBattleOpen = 0
  if not nWinTeam then
    if self.tbTeamScore[1] > self.tbTeamScore[2] then
      nWinTeam = 1
    elseif self.tbTeamScore[1] < self.tbTeamScore[2] then
      nWinTeam = 2
    else
      if self.tbUpdateTeamScoreTime[1] < self.tbUpdateTeamScoreTime[2] then
        nWinTeam = 1
      else
        nWinTeam = 2
      end
      Log("Battle StopFight result", self.nMapId, unpack(self.tbUpdateTeamScoreTime))
    end
  end
  local nWinAddPer = Battle.WIN_ADD_SCORE_PER
  for _, v in ipairs(self.tbBattleRank) do
    local tbInfo = self.tbPlayerInfos[v.dwID]
    if tbInfo.nTeamIndex == nWinTeam then
      v.nScore = math.floor(v.nScore * nWinAddPer)
      tbInfo.nScore = v.nScore
    end
  end
  self.bRankUpdate = true
  self:SyncAllInfo(GetTime())
  if self.nActiveTimer then
    Timer:Close(self.nActiveTimer)
    self.nActiveTimer = nil
  end
  Log("BattleWinTeam", self.nMapId, nWinTeam, self.tbTeamScore[1], self.tbTeamScore[2])
  return nWinTeam
end
function tbBase:GotoBackBattle(pPlayer)
  local tbInfo = self.tbPlayerInfos[pPlayer.dwID]
  pPlayer.SetPosition(unpack(Battle:GetRandInitPos(tbInfo.nTeamIndex, self.tbBattleSetting)))
  pPlayer.GetNpc().SetPkMode(0)
  tbInfo.nInBackCampTime = GetTime()
end
