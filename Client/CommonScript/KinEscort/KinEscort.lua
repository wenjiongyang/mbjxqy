KinEscort.nSaveKeyUserValueId = 48
KinEscort.nRefDateKey = 1
KinEscort.nKinIdKey = 2
KinEscort.nRobCountKey = 3
KinEscort.nMinAttendLevel = 30
function KinEscort:IsLevelEnough(pPlayer)
  return pPlayer.nLevel >= self.nMinAttendLevel
end
function KinEscort:GetDegree()
  local remain = 1
  local total = 1
  while me.GetUserValue(self.nSaveKeyUserValueId, self.nRefDateKey) == Lib:GetLocalDay() and me.GetUserValue(self.nSaveKeyUserValueId, self.nKinIdKey) > 0 do
    remain = 0
    do break end
    break
  end
  return remain, total
end
