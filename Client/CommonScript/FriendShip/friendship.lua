FriendShip.tbDataType = {
  emFriendData_Type = 1,
  emFriendData_Imity = 2,
  emFriendData_Enemy_Left = 3,
  emFriendData_Enemy_Right = 4,
  emFriendData_BlackOrRequest = 5,
  emFriendData_Temp_Refuse = 6,
  emFriendData_WeddingState = 7,
  emFriendData_WeddingTime = 8
}
FriendShip.tbDataVal = {
  emFriend_Type_Invalid = 0,
  emFriend_Type_Friend = 1,
  emFriend_Type_Request_Left = 2,
  emFriend_Type_Request_Right = 3
}
local emFriendData_Type = FriendShip.tbDataType.emFriendData_Type
local emFriendData_Imity = FriendShip.tbDataType.emFriendData_Imity
local emFriendData_Enemy_Left = FriendShip.tbDataType.emFriendData_Enemy_Left
local emFriendData_Enemy_Right = FriendShip.tbDataType.emFriendData_Enemy_Right
local emFriendData_BlackOrRequest = FriendShip.tbDataType.emFriendData_BlackOrRequest
local emFriendData_Temp_Refuse = FriendShip.tbDataType.emFriendData_Temp_Refuse
local emFriendData_WeddingState = FriendShip.tbDataType.emFriendData_WeddingState
local emFriendData_WeddingTime = FriendShip.tbDataType.emFriendData_WeddingTime
local emFriend_Type_Invalid = FriendShip.tbDataVal.emFriend_Type_Invalid
local emFriend_Type_Friend = FriendShip.tbDataVal.emFriend_Type_Friend
local emFriend_Type_Request_Left = FriendShip.tbDataVal.emFriend_Type_Request_Left
local emFriend_Type_Request_Right = FriendShip.tbDataVal.emFriend_Type_Request_Right
FriendShip.SHOW_LEVEL = 10
FriendShip.nEnemyLevelLimit = 20
FriendShip.nMaxEnemyNum = 50
FriendShip.tbFriendNumLimit = {
  {1, 50},
  {11, 60},
  {21, 70},
  {31, 80},
  {41, 90},
  {51, 100}
}
FriendShip.nMaxPrivateMessages = 1000
FriendShip.nTempRefuseTime = 15
FriendShip.nWantedTimeShort = 7200
FriendShip.nWantedTimeLong = 86400
FriendShip.nWantedLongCost = 20
FriendShip.nRequsetWantedCdTime = 10
FriendShip.nRevengeAddHate = 20000
FriendShip.nRobDebrisAddHate = 10000
FriendShip.nCatchAddHate = 0
FriendShip.nMapExploreAddHate = 20000
FriendShip.nMapExploreFailAddHate = 10000
FriendShip.FIGHT_MAP = 1018
FriendShip.ENTER_POINT = {1970, 2291}
FriendShip.tbHonorProb = {
  {-3, 1},
  {-2, 1},
  {-1, 0.75},
  {0, 0.5},
  {1, 0.25},
  {2, 0},
  {3, 0}
}
FriendShip.tbImityAchivementLevel = {
  5,
  10,
  20,
  30,
  40
}
FriendShip.nTeamHelpBuffId = 2308
local fnGetFriendData
if MODULE_GAMESERVER then
  function fnGetFriendData(dwRoleId1, dwRoleId2)
    return KFriendShip.GetFriendShipValSet(dwRoleId1, dwRoleId2)
  end
else
  function fnGetFriendData(dwRoleId1, dwRoleId2)
    local dwRoleId = me.dwID == dwRoleId1 and dwRoleId2 or dwRoleId1
    return FriendShip.tbAllData[dwRoleId]
  end
end
FriendShip.fnGetFriendData = fnGetFriendData
function FriendShip:Init()
  local tbFile = Lib:LoadTabFile("Setting/FriendShip/IntimacyLevel.tab", {
    Level = 1,
    MinIntimacy = 1,
    MaxIntimacy = 1,
    AddExpP = 1
  })
  if not tbFile then
    Log(debug.traceback())
    return
  end
  for nRow, tbInfo in ipairs(tbFile) do
    assert(nRow == tbInfo.Level, "IntimacyLevel : " .. tbInfo.Level)
  end
  FriendShip.tbIntimacyLevel = tbFile
  FriendShip.nMaxImitiy = tbFile[#tbFile].MaxIntimacy
end
function FriendShip:GetMaxFriendNum(nLevel, nVipLevel)
  local nMaxNum = 0
  for i, v in ipairs(self.tbFriendNumLimit) do
    if nLevel >= v[1] then
      nMaxNum = v[2]
    else
      break
    end
  end
  for i, v in ipairs(Recharge.tbVipExtSetting.ExFriendNum) do
    if nVipLevel < v[1] then
      break
    else
      nMaxNum = nMaxNum + v[2]
    end
  end
  return nMaxNum
end
function FriendShip:IsFriend(dwRoleId1, dwRoleId2, tbFriendData)
  tbFriendData = tbFriendData or fnGetFriendData(dwRoleId1, dwRoleId2)
  return tbFriendData and tbFriendData[emFriendData_Type] == emFriend_Type_Friend
end
function FriendShip:IsInHisTempRefuse(dwRoleId1, dwRoleId2, tbFriendData)
  tbFriendData = tbFriendData or fnGetFriendData(dwRoleId1, dwRoleId2)
  if not tbFriendData then
    return false
  end
  local nDataVal = tbFriendData[emFriendData_Temp_Refuse]
  if not nDataVal then
    return false
  end
  local nNow = GetTime()
  if dwRoleId1 < dwRoleId2 then
    if nNow < -nDataVal then
      return true
    end
  elseif nDataVal > nNow then
    return true
  end
end
function FriendShip:IsHeIsMyEnemy(dwRoleId1, dwRoleId2, tbFriendData)
  tbFriendData = tbFriendData or fnGetFriendData(dwRoleId1, dwRoleId2)
  if not tbFriendData then
    return false, 0
  end
  if dwRoleId1 < dwRoleId2 then
    if tbFriendData[emFriendData_Enemy_Left] and tbFriendData[emFriendData_Enemy_Left] > 0 then
      return true, tbFriendData[emFriendData_Enemy_Left]
    end
  elseif tbFriendData[emFriendData_Enemy_Right] and tbFriendData[emFriendData_Enemy_Right] > 0 then
    return true, tbFriendData[emFriendData_Enemy_Right]
  end
  return false, 0
end
function FriendShip:IsRequestedAdd(dwRoleId1, dwRoleId2, tbFriendData)
  tbFriendData = tbFriendData or fnGetFriendData(dwRoleId1, dwRoleId2)
  if not tbFriendData then
    return false
  end
  if dwRoleId1 < dwRoleId2 then
    if tbFriendData[emFriendData_BlackOrRequest] == emFriend_Type_Request_Left then
      return true
    end
  elseif tbFriendData[emFriendData_BlackOrRequest] == emFriend_Type_Request_Right then
    return true
  end
end
function FriendShip:IsMeRequested(dwRoleId1, dwRoleId2, tbFriendData)
  tbFriendData = tbFriendData or fnGetFriendData(dwRoleId1, dwRoleId2)
  if not tbFriendData then
    return false
  end
  if dwRoleId1 < dwRoleId2 then
    if tbFriendData[emFriendData_BlackOrRequest] == emFriend_Type_Request_Right then
      return true
    end
  elseif tbFriendData[emFriendData_BlackOrRequest] == emFriend_Type_Request_Left then
    return true
  end
end
function FriendShip:GetImityLevel(nImity)
  if not nImity or nImity == 0 then
    return
  end
  local tbIntimacyLevel = self.tbIntimacyLevel
  local nFindMax = #tbIntimacyLevel
  for i = 1, nFindMax, 4 do
    local v = tbIntimacyLevel[i]
    if nImity <= v.MaxIntimacy then
      if nImity >= v.MinIntimacy then
        return v.Level, v.MaxIntimacy
      end
      nFindMax = i
      break
    end
  end
  for i = nFindMax - 3, nFindMax do
    local v = tbIntimacyLevel[i]
    if nImity <= v.MaxIntimacy then
      return v.Level, v.MaxIntimacy
    end
  end
end
function FriendShip:GetImity(dwRoleId1, dwRoleId2, tbFriendData)
  tbFriendData = tbFriendData or fnGetFriendData(dwRoleId1, dwRoleId2)
  if not tbFriendData or tbFriendData[emFriendData_Type] ~= emFriend_Type_Friend then
    return
  end
  return tbFriendData[emFriendData_Imity]
end
function FriendShip:GetFriendImityLevel(dwRoleId1, dwRoleId2)
  local nImity = FriendShip:GetImity(dwRoleId1, dwRoleId2)
  if not nImity then
    return
  end
  return FriendShip:GetImityLevel(nImity)
end
function FriendShip:GetFriendImityExpP(nImityLevel)
  if not nImityLevel then
    return 0
  end
  local tbInfo = self.tbIntimacyLevel[nImityLevel]
  if not tbInfo then
    return 0
  end
  return tbInfo.AddExpP or 0
end
function FriendShip:GetNextRevengeTime()
  return me.GetUserValue(5, 3)
end
function FriendShip:GetRevengeCDTiem(nNow)
  local nNextTime = self:GetNextRevengeTime()
  if nNextTime == 0 then
    return 0
  end
  nNow = nNow or GetTime()
  local nCd = nNextTime - nNow
  return nCd < 0 and 0 or nCd
end
function FriendShip:GetRevengeCDMoney(nCdTime)
  return math.floor(nCdTime / 60 / 30) * 20
end
function FriendShip:GetMinusHate(nAddHate, nHisHate)
  return math.min(math.floor(nAddHate * 0.8), nHisHate)
end
function FriendShip:GetRevengetRobCoin(nHisCoin)
  return math.min(MathRandom(2000, 10000), math.floor(nHisCoin * 0.2))
end
function FriendShip:WeddingStateType()
  return emFriendData_WeddingState
end
function FriendShip:WeddingTimeType()
  return emFriendData_WeddingTime
end
