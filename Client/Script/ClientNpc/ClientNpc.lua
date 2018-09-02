ClientNpc.tbActivityNpc = ClientNpc.tbActivityNpc or {}
function ClientNpc:LoadSetting()
  self.tbMapNpcSetting = {}
  local tbFileData = Lib:LoadTabFile("Setting/ClientNpc/MapNpc.tab", {
    MapID = 1,
    NpcID = 1,
    NpcLevel = 1,
    PosX = 1,
    PosY = 1,
    Dir = 1,
    Series = 1
  })
  for _, tbInfo in pairs(tbFileData) do
    self.tbMapNpcSetting[tbInfo.MapID] = self.tbMapNpcSetting[tbInfo.MapID] or {}
    table.insert(self.tbMapNpcSetting[tbInfo.MapID], tbInfo)
  end
  self.tbTalkMain = {}
  tbFileData = Lib:LoadTabFile("Setting/ClientNpc/TalkMain.tab", {nIntervalMin = 1, nIntervalMax = 1})
  for _, tbInfo in pairs(tbFileData) do
    self.tbTalkMain[tbInfo.szActivity] = tbInfo
  end
  self.tbTalkNpc = {}
  tbFileData = Lib:LoadTabFile("Setting/ClientNpc/TalkNpc.tab", {nNpcTID = 1})
  for _, tbInfo in pairs(tbFileData) do
    self.tbTalkNpc[tbInfo.szActivity] = self.tbTalkNpc[tbInfo.szActivity] or {}
    self.tbTalkNpc[tbInfo.szActivity][tbInfo.nNpcTID] = self.tbTalkNpc[tbInfo.szActivity][tbInfo.nNpcTID] or {}
    table.insert(self.tbTalkNpc[tbInfo.szActivity][tbInfo.nNpcTID], tbInfo.szTalk)
  end
end
ClientNpc:LoadSetting()
function ClientNpc:GetNpcPath(szFile)
  local tbPath = Lib:LoadTabFile("Setting/ClientNpc/" .. szFile, {PosX = 1, PosY = 1})
  return tbPath
end
function ClientNpc:GetMapNpc(nMapTID)
  local tbMapNpc = self.tbMapNpcSetting[nMapTID]
  return tbMapNpc
end
function ClientNpc:ClearNpc()
  for szActivity, tbAllNpc in pairs(self.tbActivityNpc) do
    for _, tbNpc in pairs(tbAllNpc) do
      for _, nNpcID in ipairs(tbNpc) do
        local pNpc = KNpc.GetById(nNpcID)
        if pNpc then
          pNpc.Delete()
        end
      end
    end
  end
  self.tbActivityNpc = {}
end
function ClientNpc:GetTalkInterval(tbMainInfo)
  return MathRandom(tbMainInfo.nIntervalMin, tbMainInfo.nIntervalMax)
end
function ClientNpc:GetTalkMsg(szActivity, nNpcTID)
  local tbMsg = self.tbTalkNpc[szActivity] and self.tbTalkNpc[szActivity][nNpcTID]
  if not tbMsg then
    return
  end
  local szMsg = tbMsg[MathRandom(1, #tbMsg)]
  local tbMainInfo = self.tbTalkMain[szActivity] or {}
  local szFunction = tbMainInfo.szFormatTalkFunc
  if not Lib:IsEmptyStr(szFunction) and string.find(szFunction, ":") then
    local szTable, szFunc = string.match(szFunction, "^(.*):(.*)$")
    local tb = loadstring("return " .. szTable)()
    szMsg = tb[szFunc](tb, szMsg)
  end
  return szMsg
end
function ClientNpc:CloseTalkTimer()
  if self.nTalkTimer then
    Timer:Close(self.nTalkTimer)
    self.nTalkTimer = nil
  end
end
function ClientNpc:DoTalk(tbMainInfo)
  local tbActivityNpc = self.tbActivityNpc[tbMainInfo.szActivity] or {}
  for nNpcTID, tbNpc in pairs(tbActivityNpc) do
    for _, nNpcID in ipairs(tbNpc) do
      local pNpc = KNpc.GetById(nNpcID)
      if pNpc then
        local szBubble = self:GetTalkMsg(tbMainInfo.szActivity, nNpcTID)
        if szBubble then
          pNpc.BubbleTalk(string.format(szBubble), tbMainInfo.szDuration)
        end
      end
    end
  end
end
function ClientNpc:CheckOpenTalkTimer()
  for szActivity, tbAllNpc in pairs(self.tbActivityNpc) do
    for nNpcTID, tbNpc in pairs(tbAllNpc) do
      if self:GetTalkMsg(szActivity, nNpcTID) then
        return true
      end
    end
  end
end
function ClientNpc:StartTalk()
  self.nTime = 0
  self.tbTalking = {}
  self.tbTalkInterval = {}
  if self:CheckOpenTalkTimer() then
    self.nTalkTimer = Timer:Register(Env.GAME_FPS, function()
      self.nTime = self.nTime + 1
      for szActivity, tbMainInfo in pairs(self.tbTalkMain) do
        if not self.tbTalking[szActivity] then
          self.tbTalking[szActivity] = true
          self.tbTalkInterval[szActivity] = (self.tbTalkInterval[szActivity] or 0) + self:GetTalkInterval(tbMainInfo)
        end
        local nTalkInterval = self.tbTalkInterval[szActivity]
        if self.nTime == nTalkInterval then
          self.tbTalking[szActivity] = nil
          self:DoTalk(tbMainInfo)
        end
      end
      return true
    end)
  end
end
function ClientNpc:OnEnterMap(nMapTID, tbForce)
  self:CloseTalkTimer()
  local tbMapNpc = self:GetMapNpc(nMapTID)
  if not tbMapNpc then
    return
  end
  self:ClearNpc()
  for _, tbNpcInfo in pairs(tbMapNpc) do
    if Lib:IsEmptyStr(tbNpcInfo.IsActivity) or Activity:__IsActInProcessByType(tbNpcInfo.IsActivity) or tbForce and tbForce[tbNpcInfo.IsActivity] then
      local pNpc = KNpc.Add(tbNpcInfo.NpcID, tbNpcInfo.NpcLevel, tbNpcInfo.Series or -1, 0, tbNpcInfo.PosX, tbNpcInfo.PosY, 0, tbNpcInfo.Dir)
      if pNpc then
        if not Lib:IsEmptyStr(tbNpcInfo.FindPathFile) then
          local tbPath = self:GetNpcPath(tbNpcInfo.FindPathFile)
          pNpc.AI_ClearMovePathPoint()
          for _, tbPos in ipairs(tbPath) do
            pNpc.AI_AddMovePos(tbPos.PosX, tbPos.PosY)
          end
          self:StartFindPath(pNpc.nId)
        end
        local szActivity = Lib:IsEmptyStr(tbNpcInfo.IsActivity) and "Default" or tbNpcInfo.IsActivity
        self.tbActivityNpc[szActivity] = self.tbActivityNpc[szActivity] or {}
        self.tbActivityNpc[szActivity][tbNpcInfo.NpcID] = self.tbActivityNpc[szActivity][tbNpcInfo.NpcID] or {}
        table.insert(self.tbActivityNpc[szActivity][tbNpcInfo.NpcID], pNpc.nId)
      end
    end
  end
  self:StartTalk()
end
function ClientNpc:StartFindPath(nNpcID)
  local pNpc = KNpc.GetById(nNpcID)
  if not pNpc then
    return
  end
  pNpc.SetActiveForever(1)
  pNpc.AI_StartPath()
  pNpc.tbOnArrive = {
    self.StartFindPath,
    self,
    nNpcID
  }
end
