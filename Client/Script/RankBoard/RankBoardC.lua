function RankBoard:OnGetRanBoadData(tbData, szKey, nPage, tbMyRankInfo)
  self.tbAllData[szKey][nPage] = tbData
  self.tbUpdateDataTime[szKey] = self.tbUpdateDataTime[szKey] or {}
  self.tbUpdateDataTime[szKey][nPage] = GetTime()
  if tbMyRankInfo then
    self.tbMyRankInfo[szKey] = tbMyRankInfo
  end
  UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_RANKBOARD_DATA, szKey, nPage)
end
function RankBoard:CheckUpdateData(szKey, nPage)
  if not self.tbAllData[szKey] then
    return
  end
  local tbData = RankBoard.tbAllData[szKey][nPage]
  local bHasMy = self.tbMyRankInfo[szKey] and true or false
  if not tbData then
    RemoteServer.OpenRankBoard(szKey, nPage, not bHasMy)
    return
  end
  local nUpdateTime = self.tbUpdateDataTime[szKey] and self.tbUpdateDataTime[szKey][nPage]
  if not nUpdateTime or GetTime() - nUpdateTime > self.nRequestDelay then
    RemoteServer.OpenRankBoard(szKey, nPage, true)
  end
  return tbData
end
function RankBoard:ClientInit()
  self.tbAllData = {}
  self.tbUpdateDataTime = {}
  self.tbMyRankInfo = {}
  for k, v in pairs(self.tbSetting) do
    self.tbAllData[k] = {}
  end
end
RankBoard:ClientInit()
