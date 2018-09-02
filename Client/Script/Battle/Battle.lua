function Battle:UpdateRankData(tbBattleRank, tbTeamScore, nLeftTime)
  local nMyRank, nCombo = 0, 0
  local dwMeId = me.dwID
  for i, v in ipairs(tbBattleRank) do
    if v.dwID == dwMeId then
      nMyRank = i
      nCombo = v.nComboCount
      break
    end
  end
  self.tbBattleRank = tbBattleRank
  self.nMyRank = nMyRank
  UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_BATTLE_REPORT, tbBattleRank, nMyRank, tbTeamScore, nLeftTime)
end
function Battle:RequetCampTeamInfo()
  RemoteServer.BattleClientRequest("RequestTeamInfo")
end
function Battle:OnSynWinTeam(nTeam)
  self.nWinTeam = nTeam
  if self.tbCurBattleSetting.szLogicClass == "BattleMoba" then
    Ui:OpenWindow("CampBattlePanel")
  else
    Ui:OpenWindow("BattleReport")
  end
end
function Battle:OnPlayerDeath(nBattleRevieTime)
  Ui:ShowComboKillCount(0, true)
  self.nBattleRevieTime = nBattleRevieTime
end
function Battle:UpdateBattleUiState(nState)
  if Ui:WindowVisible("HomeScreenBattleInfo") ~= 1 then
    Ui:OpenWindow("HomeScreenBattleInfo", nState)
  else
    Ui("HomeScreenBattleInfo"):SetEndTime(nState)
  end
end
function Battle:OnGetLowAttackBuff(nNpcId)
  local pNpc = KNpc.GetById(nNpcId)
  if not pNpc then
    return
  end
  local nBuffId, nBuffLevel, nBuffTime = unpack(Battle.tbCampSetting.tbBuidLowAttackBuff)
  pNpc.AddSkillState(nBuffId, nBuffLevel, 0, nBuffTime)
end
Battle.tbManageMap = Battle.tbManageMap or {}
Battle.tbManageMap[Battle.READY_MAP_ID] = 1
Battle.tbManageMap[Battle.ZONE_READY_MAP_ID] = 1
Battle.tbManageMap[KinBattle.PRE_MAP_ID] = 1
Battle.tbManageMap[InDifferBattle.tbDefine.nReadyMapTemplateId] = 1
function Battle:RegisterManageMap(nMapTemplateId)
  Battle.tbManageMap = Battle.tbManageMap or {}
  Battle.tbManageMap[nMapTemplateId] = 1
end
function Battle:OnEnterNewMap(nMapTemplateId)
  if self.tbCurBattleSetting then
    if self.tbCurBattleSetting.nMapTemplateId ~= nMapTemplateId then
      self:OnCloseBattleMap()
    end
    return
  end
  if not Battle.tbManageMap[nMapTemplateId] then
    self:OnCloseReadyMap()
  end
end
function Battle:OnLeaveCurMap(nMapTemplateId)
  if self.tbCurBattleSetting then
    if self.tbCurBattleSetting.nMapTemplateId == nMapTemplateId then
      self:OnCloseBattleMap()
    end
    return
  end
  if Battle.tbManageMap[nMapTemplateId] then
    self:OnCloseReadyMap()
  end
end
function Battle:OnCloseReadyMap()
  Ui:CloseWindow("QYHLeftInfo")
  Ui:ChangeUiState(0, true)
  Ui:CloseWindow("HomeScreenBattleInfo")
  UiNotify:UnRegistNotify(UiNotify.emNOTIFY_MAP_ENTER, self)
  UiNotify:UnRegistNotify(UiNotify.emNOTIFY_MAP_LEAVE, self)
end
function Battle:OnCloseBattleMap()
  self.tbTeamInfo = nil
  self.tbBattleRank = nil
  self.nWinTeam = nil
  self.nTeamIndex = nil
  self.tbCurBattleSetting = nil
  self.tbBattlePosInfos = nil
  self.nCahcheMatchTimeMonth = nil
  self.nCahcheMatchTimeSeason = nil
  self.nCahcheMatchTimeYear = nil
  self.nCahcheMatchTimeMonthNext = nil
  self.nCahcheMatchTimeYearNext = nil
  self.nClinetDataVersion = nil
  self.nBattleRevieTime = nil
  Player.tbServerSyncData.BattleCampBossBornTime = nil
  Player.tbServerSyncData.BattleScheTime = nil
  Ui:ChangeUiState(0, true)
  Ui:CloseWindow("HomeScreenBattleInfo")
  Ui:CloseWindow("CampBattleInfo")
  UiNotify:UnRegistNotify(UiNotify.emNOTIFY_MAP_ENTER, self)
  UiNotify:UnRegistNotify(UiNotify.emNOTIFY_MAP_LEAVE, self)
  UiNotify:UnRegistNotify(UiNotify.emNOTIFY_SYN_MAP_ALL_POS, self)
end
function Battle:EnterReadyMap(szType, tbParam)
  me.CenterMsg("您已成功加入报名队列，请在准备场等待", true)
  Ui:OpenWindow("QYHLeftInfo", szType, tbParam)
  if szType == "InDifferBattle" then
    Ui:CloseWindow("DreamlandJoinPanel")
  end
  local nUiState, bHide = Map:GetMapUiState(me.nMapTemplateId)
  Ui:ChangeUiState(nUiState, bHide)
  UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_ENTER, self.OnEnterNewMap, self)
  UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_LEAVE, self.OnLeaveCurMap, self)
end
function Battle:EnterFightMap(nBattleIndex, nState, nTime, tbTeamInfo, nTeamIndex)
  self.tbBattleRank = nil
  self.nWinTeam = nil
  self.nTeamIndex = nTeamIndex
  self.tbTeamInfo = tbTeamInfo
  if type(nBattleIndex) == "number" then
    self.tbCurBattleSetting = self.tbMapSetting[nBattleIndex]
  else
    self.tbCurBattleSetting = nBattleIndex
  end
  local nUiState, bHide = Map:GetMapUiState(me.nMapTemplateId)
  Ui:ChangeUiState(nUiState, bHide)
  if not tbTeamInfo then
    Ui:OpenWindow("HomeScreenBattleInfo", nState, nTime)
  else
    Ui:OpenWindow("CampBattleInfo", nState, nTime, tbTeamInfo)
  end
  UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_ENTER, self.OnEnterNewMap, self)
  UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_LEAVE, self.OnLeaveCurMap, self)
  UiNotify:RegistNotify(UiNotify.emNOTIFY_SYN_MAP_ALL_POS, self.SyncPosInfo, self)
end
function Battle:SyncPosInfo(tbPosInfos)
  if not self.tbBattleRank then
    return
  end
  self.tbBattlePosInfos = {}
  local tbMyInfo = self.tbBattleRank[self.nMyRank]
  local nMyTeamIndex = tbMyInfo.nTeamIndex
  for i, v in ipairs(self.tbBattleRank) do
    if v.nTeamIndex == nMyTeamIndex and i ~= self.nMyRank then
      local tbPos = tbPosInfos[v.dwID]
      if tbPos then
        table.insert(self.tbBattlePosInfos, tbPos)
      end
    end
  end
end
function Battle:GetMapShowPos()
  return Battle.tbBattlePosInfos or {}
end
function Battle:OnSyncKinBattleData(tbData)
  UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_KIN_BATTLE_DATA, tbData)
end
