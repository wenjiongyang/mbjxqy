BiWuZhaoQin.tbFinalData = {}
function BiWuZhaoQin:OnSynFinalData(tbData)
  BiWuZhaoQin.tbFinalData = {}
  if tbData and next(tbData) then
    BiWuZhaoQin.tbFinalData = self:FormatFinalData(tbData)
  end
end
function BiWuZhaoQin:FormatFinalData(tbData)
  local tbFinalData = {}
  local tbRoundPlayer = tbData.tbPlayer
  local tbFinalPlayer = tbData.tbFinalPlayer or {}
  local nFinalRound = tbData.nFinalRound
  local fnSort = function(a, b)
    return a.nSeq < b.nSeq
  end
  for nRound, tbPlayer in pairs(tbRoundPlayer) do
    local nCount = Lib:CountTB(tbPlayer)
    local nPos = 0
    if nCount == 1 then
      nPos = 4
    elseif nCount <= 2 then
      nPos = 3
    elseif nCount <= 4 then
      nPos = 2
    elseif nCount <= 8 then
      nPos = 1
    end
    if nPos > 0 then
      tbFinalData[nPos] = {}
      for dwID, _ in pairs(tbPlayer) do
        local tbPlayerInfo = tbFinalPlayer[dwID]
        if tbPlayerInfo then
          table.insert(tbFinalData[nPos], tbPlayerInfo)
        end
      end
      if #tbFinalData[nPos] >= 2 then
        table.sort(tbFinalData[nPos], fnSort)
      end
      if nRound == nFinalRound and 0 < nCount % 2 and nCount ~= 1 then
        table.insert(tbFinalData[nPos], 1, {})
      end
    end
  end
  return tbFinalData
end
function BiWuZhaoQin:GetFinalData()
  return BiWuZhaoQin.tbFinalData
end
function BiWuZhaoQin:OnShowTeamInfo(nCampId, tbCampInfo, nWinCamp)
  Ui:OpenWindow("ArenaAccount", nCampId, tbCampInfo, nWinCamp)
end
function BiWuZhaoQin:SyncPlayerLeftInfo(nMyCampId, tbDmgInfo)
  local nOtherCampId = 3 - nMyCampId
  UiNotify.OnNotify(UiNotify.emNOTIFY_SYN_ARENA_DMAGE_DATA, tbDmgInfo[nMyCampId].nKillCount, tbDmgInfo[nOtherCampId].nKillCount, tbDmgInfo[nMyCampId].nTotalDmg, tbDmgInfo[nOtherCampId].nTotalDmg, tbDmgInfo.szStateInfo)
end
function BiWuZhaoQin:SyncFightState(nTime)
  Ui:OpenWindow("ArenaBattleInfo", nTime)
  Timer:Register(Env.GAME_FPS, function()
    UiNotify.OnNotify(UiNotify.emNOTIFY_SYN_ARENA_TIME_DATA, nTime)
  end)
end
function BiWuZhaoQin:OnFightingState(nTime)
  self:FightingState()
  self:SyncFightState(nTime)
end
function BiWuZhaoQin:FightingState()
  Ui:CloseWindow("RoleHeadPop")
end
function BiWuZhaoQin:OnEnterFightMap()
  Ui:CloseWindow("QYHLeavePanel")
  Ui:CloseWindow("QYHLeftInfo")
  UiNotify.OnNotify(UiNotify.emNOTIFY_REFRESH_QYH_BTN, "BiWuZhaoQin", {
    "BtnWitnessWar"
  })
end
function BiWuZhaoQin:SynPreMapState(nTime, nType, nProcess, nFightState)
  local szProgress = BiWuZhaoQin.tbProcessDes[nProcess] or BiWuZhaoQin.szProcessEndDes
  local tbMatchSetting = BiWuZhaoQin.tbMatchSetting[nType]
  if tbMatchSetting then
    Ui:OpenWindow("QYHLeftInfo", tbMatchSetting.szUiKey, {
      szProgress,
      nTime or 0,
      BiWuZhaoQin.tbFightStateDes[nFightState] or "-"
    })
  else
    Ui:OpenWindow("QYHLeftInfo", "BiWuZhaoQinEnd", {szProgress})
  end
  Map:SetCloseUiOnLeave(me.nMapId, "QYHLeavePanel")
  Ui:CloseWindow("RoleHeadPop")
end
function BiWuZhaoQin:OnLeaveArena()
  Ui:CloseWindow("ArenaBattleInfo")
end
function BiWuZhaoQin:OnClientMapLeave(nTemplateID)
  if nTemplateID ~= BiWuZhaoQin.nPreMapTID then
    return
  end
  BiWuZhaoQin.tbFinalData = {}
  Ui:CloseWindow("QYHLeavePanel")
  Ui:CloseWindow("QYHLeftInfo")
  Ui:CloseWindow("ArenaBattleInfo")
  Ui:CloseWindow("ArenaAccount")
  Ui:CloseWindow("FightTablePanel")
end
