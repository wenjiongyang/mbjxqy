Fuben.Lock = Fuben.Lock or {}
Fuben.Lock.tbBaseLock = {}
local tbBaseLock = Fuben.Lock.tbBaseLock
tbBaseLock.SERIES_LOCK = 1
tbBaseLock.PARALLEL_LOCK = 2
function tbBaseLock:InitLock(nTime, nMultiNum)
  self.tbNextLock = {}
  self.tbSerPreLock = {}
  self.tbParPreLock = {}
  self.nPreLockNum = 0
  if not self.nLockId then
    self.nLockId = 0
  end
  self.nStartState = 0
  self.nLockState = 0
  self.nTimerId = 0
  self.nTime = nTime
  self.nClose = 0
  self.nMultiNum = nMultiNum
end
function tbBaseLock:AddPreLock(...)
  local arg = {
    ...
  }
  for i, tbPreLock in pairs(arg) do
    if type(tbPreLock) == "table" and tbPreLock.tbNextLock then
      self.tbSerPreLock[tbPreLock.nLockId] = 1
      table.insert(tbPreLock.tbNextLock, {
        nType = self.SERIES_LOCK,
        tbLock = self
      })
      self.nPreLockNum = self.nPreLockNum + 1
    elseif type(tbPreLock) == "table" then
      local nParLockId = #self.tbParPreLock
      local bIsAvail = 0
      for j, tbSubLock in pairs(tbPreLock) do
        if tbSubLock.tbNextLock then
          bIsAvail = 1
          if not self.tbParPreLock[nParLockId] then
            self.tbParPreLock[nParLockId] = {}
          end
          self.tbParPreLock[nParLockId][tbSubLock.nLockId] = 1
          table.insert(tbSubLock.tbNextLock, {
            nType = self.PARALLEL_LOCK,
            tbLock = self,
            nIndex = nParLockId
          })
        end
      end
      if bIsAvail == 1 then
        self.nPreLockNum = self.nPreLockNum + 1
      end
    end
  end
end
function tbBaseLock:UnLockPreLock(nType, nLockId, nIndex)
  if self.nStartState == 1 then
    return 0
  end
  if nType == self.SERIES_LOCK then
    if self.tbSerPreLock[nLockId] then
      self.tbSerPreLock[nLockId] = nil
      self.nPreLockNum = self.nPreLockNum - 1
    end
  elseif nType == self.PARALLEL_LOCK and self.tbParPreLock[nIndex] and self.tbParPreLock[nIndex][nLockId] then
    self.tbParPreLock[nIndex] = nil
    self.nPreLockNum = self.nPreLockNum - 1
  end
  if 0 >= self.nPreLockNum then
    self:StartLock()
    return 1
  end
end
function tbBaseLock:StartLock()
  if self.nStartState == 1 or self.nClose == 1 then
    return 0
  end
  self.nStartState = 1
  if 0 < self.nTime then
    self.nTimerId = Timer:Register(self.nTime, self.TimeOut, self)
  end
  self:OnStartLock()
  if 0 >= self.nMultiNum and self.nTime == 0 then
    self:UnLock()
  end
end
function tbBaseLock:UnLock()
  if self.nLockState == 1 or self.nClose == 1 then
    return 0
  end
  self.nLockState = 1
  self:OnUnLock()
  if self.nClose == 1 then
    return 0
  end
  for i, tbLock in pairs(self.tbNextLock) do
    tbLock.tbLock:UnLockPreLock(tbLock.nType, self.nLockId, tbLock.nIndex)
  end
  self:Close()
end
function tbBaseLock:OnStartLock()
end
function tbBaseLock:OnUnLock()
end
function tbBaseLock:UnLockMulti()
  self.nMultiNum = self.nMultiNum - 1
  if self.nMultiNum <= 0 and self.nLockState == 0 and self.nStartState == 1 then
    self:UnLock()
  end
end
function tbBaseLock:TimeOut()
  self.nTimerId = 0
  if self.nLockState == 0 then
    self:UnLock()
  end
end
function tbBaseLock:IsStart()
  return self.nStartState
end
function tbBaseLock:IsLock()
  return self.nLockState
end
function tbBaseLock:GetTimeInfo()
  if not self.nTimerId or self.nTimerId <= 0 and not self.nLastTime then
    return
  end
  local nTotalTime = self.nTime or 0
  if self.nLastTime then
    return math.max(nTotalTime - self.nLastTime, 0) / Env.GAME_FPS, nTotalTime / Env.GAME_FPS
  end
  local nLastTime = Timer:GetRestTime(self.nTimerId)
  if nLastTime < 0 then
    return
  end
  return math.max(nTotalTime - nLastTime, 0) / Env.GAME_FPS, nTotalTime / Env.GAME_FPS
end
function tbBaseLock:GetNextLock()
  return self.tbNextLock
end
function tbBaseLock:Pause()
  assert(self.nMultiNum == 0)
  if not (self.nTime and not (0 >= self.nTime) and self.nTimerId) or 0 >= self.nTimerId or self.nClose == 1 then
    return
  end
  self.nLastTime = Timer:GetRestTime(self.nTimerId)
  Timer:Close(self.nTimerId)
  self.nTimerId = 0
end
function tbBaseLock:Resume()
  if self.nLastTime and self.nLastTime > 0 and self.nClose ~= 1 then
    self.nTimerId = Timer:Register(self.nLastTime, self.TimeOut, self)
    self.nLastTime = nil
  end
end
function tbBaseLock:Close()
  if self.nTimerId > 0 then
    Timer:Close(self.nTimerId)
    self.nTimerId = 0
  end
  self.nClose = 1
end
