function WuLinDaHui:OnBuyTicketScuccess()
  me.CenterMsg("恭喜阁下获得参与武林大会的资格！", true)
  UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_DATA, "WLDHRefreshMainUi")
end
function WuLinDaHui:IsShowTopButton()
  local bIsAct = Activity:__IsActInProcessByType(self.szActNameYuGao)
  if bIsAct then
    return true, self.szActNameYuGao
  end
  bIsAct = Activity:__IsActInProcessByType(self.szActNameBaoMing)
  if bIsAct then
    return true, self.szActNameBaoMing
  end
  bIsAct = Activity:__IsActInProcessByType(self.szActNameMain)
  if bIsAct then
    return true, self.szActNameMain
  end
end
function WuLinDaHui:GetPlayerTeamNum()
  local nSelfCurTeamNum = 0
  for i, v in ipairs(WuLinDaHui.tbGameFormat) do
    local tbTeamInfo = Player:GetServerSyncData("WLDHFightTeamInfo" .. i)
    if tbTeamInfo and tbTeamInfo.szName then
      nSelfCurTeamNum = nSelfCurTeamNum + 1
    end
  end
  return nSelfCurTeamNum
end
function WuLinDaHui:GetMatchTimeNode(nGameType)
  local nStartTime, nEndTime = Activity:__GetActTimeInfo(self.szActNameMain)
  if not nStartTime then
    return {}
  end
  local tbTimeNode = {}
  local tbTime = os.date("*t", nStartTime + 86400 * (nGameType - 1))
  for i, v in ipairs(WuLinDaHui.tbDef.tbStartMatchTime) do
    local hour1, min1 = string.match(v, "(%d+):(%d+)")
    local nSecBegin = os.time({
      year = tbTime.year,
      month = tbTime.month,
      day = tbTime.day,
      hour = hour1,
      min = min1,
      sec = 0
    })
    table.insert(tbTimeNode, nSecBegin)
  end
  for i, v in ipairs(WuLinDaHui.tbDef.tbEndMatchTime) do
    local hour1, min1 = string.match(v, "(%d+):(%d+)")
    local nSecBegin = os.time({
      year = tbTime.year,
      month = tbTime.month,
      day = tbTime.day,
      hour = hour1,
      min = min1,
      sec = 0
    })
    table.insert(tbTimeNode, nSecBegin)
  end
  local tbTime = os.date("*t", nStartTime + 86400 * (nGameType - 1 + 4))
  local hour1, min1 = string.match(WuLinDaHui.tbDef.szFinalStartMatchTime, "(%d+):(%d+)")
  local nSecBegin = os.time({
    year = tbTime.year,
    month = tbTime.month,
    day = tbTime.day,
    hour = hour1,
    min = min1,
    sec = 0
  })
  table.insert(tbTimeNode, nSecBegin)
  local hour1, min1 = string.match(WuLinDaHui.tbDef.szFinalEndMatchTime, "(%d+):(%d+)")
  local nSecBegin = os.time({
    year = tbTime.year,
    month = tbTime.month,
    day = tbTime.day,
    hour = hour1,
    min = min1,
    sec = 0
  })
  table.insert(tbTimeNode, nSecBegin)
  return tbTimeNode
end
function WuLinDaHui:GetCLinetNowTimeNode()
  local nStartTime, nEndTime = Activity:__GetActTimeInfo(self.szActNameYuGao)
  if nStartTime and nEndTime then
    return nStartTime
  end
  local nStartTime, nEndTime = Activity:__GetActTimeInfo(self.szActNameBaoMing)
  if nStartTime and nEndTime then
    return nStartTime
  end
  local nStartTime, nEndTime = Activity:__GetActTimeInfo(self.szActNameMain)
  if not nStartTime then
    return
  end
  local nNow = GetTime()
  local tbAllTimeNodes = {}
  for nGameType, v in ipairs(self.tbGameFormat) do
    local tbTimeNode = self:GetMatchTimeNode(nGameType)
    for _, v2 in ipairs(tbTimeNode) do
      table.insert(tbAllTimeNodes, v2)
    end
  end
  table.sort(tbAllTimeNodes, function(a, b)
    return a < b
  end)
  if nNow < tbAllTimeNodes[1] then
    return
  end
  for i, v in ipairs(tbAllTimeNodes) do
    local nNextTime = tbAllTimeNodes[i + 1]
    if nNextTime then
      if v <= nNow and nNow < nNextTime then
        return v
      end
    else
      return v
    end
  end
end
function WuLinDaHui:IsShowRedPoint()
  local nTimeNode = self:GetCLinetNowTimeNode()
  if not nTimeNode then
    return
  end
  local nViewTime = Client:GetFlag("WLDHViewPanelTime")
  if not nViewTime or nTimeNode > nViewTime then
    return true
  end
end
function WuLinDaHui:CheckRedPoint()
  if self:IsShowRedPoint() then
    Ui:SetRedPointNotify("Activity_WLDH")
  else
    Ui:ClearRedPointNotify("Activity_WLDH")
  end
end
function WuLinDaHui:CheckRequestTeamData(nGameType)
  local szSynKey = nGameType and "WLDHFightTeamInfo" .. nGameType or "WLDHFightTeamInfo1"
  local tbFightTeam = Player:GetServerSyncData(szSynKey)
  local bReques = true
  if tbFightTeam then
    local nRequestDelay = nGameType and WuLinDaHui.tbDef.nClientRequestTeamDataInterval or 1800
    if nGameType and WuLinDaHui:IsInMap(me.nMapTemplateId) then
      nRequestDelay = WuLinDaHui.tbDef.nClientRequestTeamDataIntervalInMap
    end
    local nNow = GetTime()
    tbFightTeam.__RequesTime = tbFightTeam.__RequesTime or nNow
    if nRequestDelay > nNow - tbFightTeam.__RequesTime then
      bReques = false
    end
  end
  if bReques then
    if nGameType then
      RemoteServer.DoRequesWLDH("RequestFightTeam", nGameType)
    else
      RemoteServer.DoRequesWLDH("RequestFightTeamAll")
    end
  end
end
function WuLinDaHui:OnChangeTeamInfo(nGameType)
  Ui:CloseWindow("TeamRelatedPanel")
  Ui:CloseWindow("CreateTeamPanel")
  local tbFightTeam = Player:GetServerSyncData("WLDHFightTeamInfo" .. nGameType)
  if not tbFightTeam then
    return
  end
  local nFightTeamID = tbFightTeam.nFightTeamID
  if not nFightTeamID then
    return
  end
  local tbFightTeamShow = Player:GetServerSyncData("WLDHFightTeam:" .. nFightTeamID)
  if not tbFightTeamShow then
    return
  end
  tbFightTeamShow.__RequesTime = 0
end
function WuLinDaHui:CheckRequestTopTeamData(nGameType)
  local tbSyndata, nSynTimeVersion = Player:GetServerSyncData("WLDHTopPreFightTeamList" .. nGameType)
  local nMinInterval = WuLinDaHui:IsInMap(me.nMapTemplateId) and WuLinDaHui.tbDef.nClientRequestTeamDataIntervalInMap or WuLinDaHui.tbDef.nClientRequestTeamDataInterval
  if not nSynTimeVersion or nMinInterval <= GetTime() - nSynTimeVersion then
    RemoteServer.DoRequesWLDH("RequestTopPreFightTeamList", nGameType, nSynTimeVersion)
  end
end
function WuLinDaHui:GetGuessingTeamID(nGameType)
  local tbSyncData = Player:GetServerSyncData("WLDHGuessingData") or {}
  return tbSyncData[nGameType] or 0
end
function WuLinDaHui:CanGuessing(nGameType)
  local tbSyndata, nSynTimeVersion, nWinTeamId = Player:GetServerSyncData("WLDHTopPreFightTeamList" .. nGameType)
  if nWinTeamId then
    return
  end
  local nActStartTime, nActEndTime = Activity:__GetActTimeInfo(WuLinDaHui.szActNameMain)
  if not nActStartTime then
    return
  end
  local tbTime = os.date("*t", nActStartTime + 86400 * (nGameType - 1 + 4))
  local hour1, min1 = string.match(WuLinDaHui.tbDef.szFinalStartMatchTime, "(%d+):(%d+)")
  local nSecBegin = os.time({
    year = tbTime.year,
    month = tbTime.month,
    day = tbTime.day,
    hour = hour1,
    min = min1,
    sec = 0
  })
  if nSecBegin >= GetTime() then
    return true
  end
end
