GameSetting.Comment = GameSetting.Comment or {}
local Comment = GameSetting.Comment
Comment.Type_CardPick_SS = 1
Comment.Type_RandomFuben_SSS = 2
Comment.Type_TeamFuben_SSS = 3
Comment.Type_HeroChallenge_10 = 4
Comment.Type_HonorLevelChange = 5
Comment.Type_WhiteTiger_BOSS = 6
Comment.Type_WuLinMengZhu_First = 7
Comment.Type_RankBattle_First = 8
Comment.Type_Battle_First = 9
Comment.Type_HuaShanLunJian_First = 10
Comment.Type_TeamBattle_7 = 11
Comment.Type_FactionBattle_BigBrother = 12
Comment.Type_FactionBattle_NewbieKing = 13
Comment.tbTypeGroup = {
  [Comment.Type_RandomFuben_SSS] = 1,
  [Comment.Type_TeamFuben_SSS] = 1,
  [Comment.Type_HeroChallenge_10] = 1,
  [Comment.Type_RankBattle_First] = 2,
  [Comment.Type_WuLinMengZhu_First] = 2,
  [Comment.Type_TeamBattle_7] = 2,
  [Comment.Type_CardPick_SS] = 2,
  [Comment.Type_Battle_First] = 2,
  [Comment.Type_WhiteTiger_BOSS] = 2,
  [Comment.Type_HuaShanLunJian_First] = 3,
  [Comment.Type_FactionBattle_BigBrother] = 4,
  [Comment.Type_FactionBattle_NewbieKing] = 5,
  [Comment.Type_HonorLevelChange] = 6
}
Comment.tbGroupMonthSetting = {
  [2] = 1,
  [3] = 1,
  [4] = 1,
  [5] = 1,
  [6] = 1
}
Comment.nMonthTotalTimes = 3
Comment.tbGroupYearSetting = {
  [1] = 1
}
Comment.tbHonorTips = {
  [6] = 1,
  [7] = 1,
  [8] = 1,
  [9] = 1,
  [10] = 1,
  [11] = 1,
  [12] = 1
}
function Comment:OnEvent(nEventType, ...)
  local nGroupId = self.tbTypeGroup[nEventType]
  if not nGroupId then
    return
  end
  local tbParam = {
    ...
  }
  if nEventType == self.Type_HonorLevelChange then
    local nHonorLevel = tbParam[1]
    if not self.tbHonorTips[nHonorLevel] then
      return
    end
  end
  local tbSetting = Client:GetUserInfo("Comment")
  tbSetting.tbMonth = tbSetting.tbMonth or {}
  local bShowComment = false
  if self.tbGroupMonthSetting[nGroupId] then
    local nCurMonth = Lib:GetLocalMonth()
    tbSetting.tbMonth = tbSetting.tbMonth or {nMonth = 0}
    if tbSetting.tbMonth.nMonth ~= nCurMonth then
      tbSetting.tbMonth = {nMonth = nCurMonth, nTotalTimes = 0}
    end
    tbSetting.tbMonth[nGroupId] = tbSetting.tbMonth[nGroupId] or 0
    tbSetting.tbMonth[nGroupId] = tbSetting.tbMonth[nGroupId] + 1
    tbSetting.tbMonth.nTotalTimes = tbSetting.tbMonth.nTotalTimes + 1
    bShowComment = tbSetting.tbMonth[nGroupId] <= self.tbGroupMonthSetting[nGroupId] and tbSetting.tbMonth.nTotalTimes <= self.nMonthTotalTimes
  elseif self.tbGroupYearSetting[nGroupId] then
    local tbTime = os.date("*t", GetTime())
    tbSetting.tbYear = tbSetting.tbYear or {nYear = 0}
    if tbSetting.tbYear.nYear ~= tbTime.year then
      tbSetting.tbYear = {
        nYear = tbTime.year
      }
    end
    tbSetting.tbYear[nGroupId] = tbSetting.tbYear[nGroupId] or 0
    tbSetting.tbYear[nGroupId] = tbSetting.tbYear[nGroupId] + 1
    bShowComment = tbSetting.tbYear[nGroupId] <= self.tbGroupYearSetting[nGroupId]
  end
  if not bShowComment then
    return
  end
  Client:SaveUserInfo()
  Ui:OpenWindow("Comment")
end
