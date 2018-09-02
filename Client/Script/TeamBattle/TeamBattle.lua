function TeamBattle:Init()
  Battle:RegisterManageMap(TeamBattle.PRE_MAP_ID)
  for _, tbInfo in pairs(TeamBattle.tbFightMapBeginPoint) do
    for _, tbMapInfo in pairs(tbInfo) do
      Battle:RegisterManageMap(tbMapInfo[1])
    end
  end
end
function TeamBattle:MsgCode(nCode, ...)
  local szMsg = string.format(TeamBattle.tbMsg[nCode], ...)
  me.CenterMsg(szMsg)
end
function TeamBattle:SyncPlayerCountInfo(nPlayerCount, nLastTime)
  if Ui:WindowVisible("QYHLeftInfo") ~= 1 or Ui("QYHLeftInfo").szType ~= "TeamBattlePre" then
    Ui:OpenWindow("QYHLeftInfo", "TeamBattlePre", {nLastTime, nPlayerCount})
  else
    Ui("QYHLeftInfo"):UpdateInfo({nLastTime, nPlayerCount})
  end
  UiNotify.OnNotify(UiNotify.emNOTIFY_SHOWTEAM_NO_TASK)
end
function TeamBattle:SyncPlayerLeftInfo(nMyTeamId, tbDmgInfo)
  local nOtherTeamId = 3 - nMyTeamId
  UiNotify.OnNotify(UiNotify.emNOTIFY_TEAM_BATTLE_KILL_INFO, tbDmgInfo[nMyTeamId].nKillCount, tbDmgInfo[nOtherTeamId].nKillCount, tbDmgInfo[nMyTeamId].nTotalDmg, tbDmgInfo[nOtherTeamId].nTotalDmg, tbDmgInfo.szStateInfo)
end
function TeamBattle:ShowFightResult(nMyTeamId, tbShowInfo, nWinTeamId, bShowTime)
  Ui:OpenWindow("TeamBattleAccount", nMyTeamId, tbShowInfo, nWinTeamId)
  UiNotify.OnNotify(UiNotify.emNOTIFY_TEAM_BATTLE_HIDE_SCORE, bShowTime)
end
function TeamBattle:ShowBeyInfo(nTime, bHideScore, bShowTime)
  UiNotify.OnNotify(UiNotify.emNOTIFY_TEAM_BATTLE_TIME, nTime or 0)
  UiNotify.OnNotify(UiNotify.emNOTIFY_TEAM_BATTLE_KILL_INFO, 0, 0, 0, 0, nTime and "等待匹配" or "比赛结束")
  if bHideScore then
    UiNotify.OnNotify(UiNotify.emNOTIFY_TEAM_BATTLE_HIDE_SCORE, bShowTime)
  end
end
function TeamBattle:ShowTeamInfo(nMyTeamId, tbTeamInfo)
  Ui:OpenWindow("TeamBattleAccount", nMyTeamId, tbTeamInfo)
end
function TeamBattle:SyncFightState(nTime)
  AutoFight:StopFollowTeammate()
  UiNotify.OnNotify(UiNotify.emNOTIFY_TEAM_BATTLE_TIME, nTime)
end
function TeamBattle:DealyShowTeamInfo(nDealyTime)
  if nDealyTime then
    Timer:Register(Env.GAME_FPS * nDealyTime, function()
      self:DealyShowTeamInfo()
    end)
    return
  end
  Ui:OpenWindow("HomeScreenTask")
  Timer:Register(Env.GAME_FPS, function()
    UiNotify.OnNotify(UiNotify.emNOTIFY_SHOWTEAM_NO_TASK)
  end)
end
