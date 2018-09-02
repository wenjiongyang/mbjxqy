if not Timer.tbTimeTable then
  Timer.tbTimeTable = {}
  Timer.tbRegister = {}
  if not Timer.nHaveUsedTimerId then
    Timer.nHaveUsedTimerId = 0
  end
  Timer.tbAttach = {}
end
function Timer:OnActive(uCurrentTime)
  local tbTime = self.tbTimeTable[uCurrentTime]
  if not tbTime then
    return
  end
  self.tbToBeClose = {}
  for nIdx, nRegisterId in pairs(tbTime) do
    if not self.tbToBeClose[nRegisterId] then
      local tbEvent = self.tbRegister[nRegisterId]
      local tbCallBack = tbEvent.tbCallBack
      local bOK, bRet = Lib:CallBack(tbCallBack)
      if not (bOK and bRet) or bRet == 0 then
        self.tbToBeClose[nRegisterId] = 1
      elseif bRet then
        local uNewTime = RegisterTimerPoint(tbEvent.nWaitTime)
        tbEvent.nWaitTime = tbEvent.nWaitTime
        tbEvent.uActiveTime = uNewTime
        local tbNewTime = self.tbTimeTable[uNewTime]
        if not tbNewTime then
          self.tbTimeTable[uNewTime] = {nRegisterId}
          tbEvent.nIdx = 1
        else
          tbEvent.nIdx = #tbNewTime + 1
          tbNewTime[tbEvent.nIdx] = nRegisterId
        end
      end
    end
  end
  for nRegisterId in pairs(self.tbToBeClose) do
    local tbEvent = self.tbRegister[nRegisterId]
    self.tbRegister[nRegisterId] = nil
    if tbEvent.uActiveTime ~= uCurrentTime then
      self.tbTimeTable[tbEvent.uActiveTime][tbEvent.nIdx] = nil
    end
    if tbEvent.OnDestroy then
      tbEvent:OnDestroy(nRegisterId)
    end
  end
  self.tbTimeTable[uCurrentTime] = nil
  self.tbToBeClose = nil
end
function Timer:UpdateTimerFrame(nChangeFrame)
  local tbTemp = {}
  for nFrame, tbTime in pairs(self.tbTimeTable) do
    tbTemp[nChangeFrame + nFrame] = tbTime
    for nIdx, nRegisterId in pairs(tbTime) do
      if self.tbRegister[nRegisterId] then
        self.tbRegister[nRegisterId].uActiveTime = self.tbRegister[nRegisterId].uActiveTime + nChangeFrame
      end
    end
  end
  self.tbTimeTable = tbTemp
end
function Timer:Register(nWaitTime, ...)
  local arg = {
    ...
  }
  local tbEvent = {
    nWaitTime = nWaitTime,
    tbCallBack = arg,
    szRegInfo = debug.traceback("Register Timer", 2)
  }
  return self:RegisterEx(tbEvent)
end
function Timer:RegisterEx(tbEvent)
  assert(tbEvent.nWaitTime > 0)
  tbEvent.uActiveTime = RegisterTimerPoint(tbEvent.nWaitTime)
  Timer.nHaveUsedTimerId = Timer.nHaveUsedTimerId + 1
  local nRegisterId = Timer.nHaveUsedTimerId
  self.tbRegister[nRegisterId] = tbEvent
  local tbNewTime = self.tbTimeTable[tbEvent.uActiveTime]
  if not tbNewTime then
    self.tbTimeTable[tbEvent.uActiveTime] = {nRegisterId}
    tbEvent.nIdx = 1
  else
    tbEvent.nIdx = #tbNewTime + 1
    tbNewTime[tbEvent.nIdx] = nRegisterId
  end
  return nRegisterId
end
function Timer:Close(nRegisterId)
  if self.tbAttach[nRegisterId] then
    print("Close Timer Error:", debug.traceback())
  end
  local tbEvent = self.tbRegister[nRegisterId]
  if not tbEvent then
    print("CloseTimerWarring", debug.traceback())
    return
  end
  if self.tbToBeClose then
    self.tbToBeClose[nRegisterId] = 1
  else
    self.tbTimeTable[tbEvent.uActiveTime][tbEvent.nIdx] = nil
    self.tbRegister[nRegisterId] = nil
    if tbEvent.OnDestroy then
      tbEvent:OnDestroy(nRegisterId)
    end
  end
end
function Timer:GetRestTime(nRegisterId)
  local tbEvent = self.tbRegister[nRegisterId]
  if not tbEvent then
    return -1
  else
    return tbEvent.uActiveTime - GetFrame()
  end
end
function Timer:GetWaitTime(nRegisterId)
  local tbEvent = self.tbRegister[nRegisterId]
  if not tbEvent then
    return -1
  else
    return tbEvent.nWaitTime
  end
end
do return end
function SomeEvent:OnTimer()
  if XXX then
    return 123
  elseif YYY then
    return 0
  else
    return
  end
end
function SomeEvent:Begin()
  self.nRegisterId = Timer:Register(1, self.OnTimer, self)
end
function SomeEvent:Stop()
  print(Timer:GetRestTime(self.nRegisterId))
  Timer:Close(self.nRegisterId)
end
Log("start timer test")
local nID = Timer:Register(45, function()
  Log("11111111111")
  return true
end)
Timer:Register(150, function()
  Timer:Close(nID)
  Log("close timer")
end)
