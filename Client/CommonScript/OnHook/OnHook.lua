OnHook.SAVE_ONHOOK_GROUP = 84
OnHook.OffLine_Time = 1
OnHook.Exp_Time = 2
OnHook.OnHook_Time = 3
OnHook.BaiJuWan_Time = 4
OnHook.SpecialBaiJuWan_Time = 5
OnHook.SAVE_ONHOOK_LOGIN_GROUP = 98
OnHook.Login_Time = 1
OnHook.SAVE_ONLINE_ONHOOK_GROUP = 99
OnHook.OnLine_OnHook_Time = 1
OnHook.OnHookTimeReset_Hour = 4
OnHook.OnHookTimePerDay = 86400
OnHook.MaxExpTime = 172800
OnHook.nOpenLevel = 20
OnHook.nDelayTime = 60
OnHook.nBaseRate = 0.72
OnHook.fFreeGetExpRate = 1
OnHook.fPayGetExpRate = 1.67
OnHook.fSpecialPayGetExpRate = 2.5
OnHook.szOpenDay = "OpenDay2D"
OnHook.nOpenDay = 2
OnHook.nOpenTime = 0
OnHook.OnHookType = {
  Free = 1,
  Pay = 2,
  SpecialPay = 3
}
OnHook.GetExpRate = {
  [OnHook.OnHookType.Free] = OnHook.fFreeGetExpRate,
  [OnHook.OnHookType.Pay] = OnHook.fPayGetExpRate,
  [OnHook.OnHookType.SpecialPay] = OnHook.fSpecialPayGetExpRate
}
OnHook.tbVipAddition = {
  {8, 1.1},
  {12, 1.2},
  {16, 1.3}
}
OnHook.nBaiJuWanId = 1929
OnHook.nSpecialBaiJuWanId = 1930
OnHook.nSpecialBaiJuWanOpenVip = 6
OnHook.tbOnHook = {}
OnHook.tbOnlineOnhookMap = {
  [10] = "襄阳",
  [999] = "忘忧岛"
}
OnHook.nRequestOnlineOHInterval = 60
OnHook.nNoMoveBuffId = 1058
function OnHook:CheckType(nGetType)
  for _, nType in pairs(OnHook.OnHookType) do
    if nType == tonumber(nGetType) then
      return true
    end
  end
end
function OnHook:IsHaveExpTime(pPlayer)
  local nExpTime = self:ExpTime(pPlayer)
  if nExpTime > 0 then
    local nHour, nMin = Lib:TransferSecond2NormalTime(nExpTime)
    if 0 < nHour * 60 + nMin then
      return true
    end
  end
end
function OnHook:GetVipAddition(pPlayer)
  local nVipLevel = pPlayer.GetVipLevel()
  local nVipAddition = 1
  for _, tbSetting in ipairs(OnHook.tbVipAddition) do
    local nVip = tbSetting[1]
    local nAddition = tbSetting[2]
    if nVipLevel >= nVip then
      nVipAddition = nAddition
    end
  end
  return nVipAddition
end
function OnHook:ExpTime2Exp(nExpTime, nType, nRate, nVipAddition)
  local nHour, nMin = Lib:TransferSecond2NormalTime(nExpTime)
  return math.ceil((nHour * 60 + nMin) * self.nBaseRate * self.GetExpRate[nType] * nRate * nVipAddition)
end
function OnHook:Exp2ExpTime(nExp, nType, nRate, nVipAddition)
  return math.ceil(nExp / self.nBaseRate / self.GetExpRate[nType] / nRate / nVipAddition) * 60
end
function OnHook:NowExp(pPlayer, nType, nExpTime)
  local nExpTime = nExpTime or self:ExpTime(pPlayer)
  local nRate = pPlayer.GetBaseAwardExp()
  local nVipAddition = OnHook:GetVipAddition(pPlayer)
  return self:ExpTime2Exp(nExpTime, nType, nRate, nVipAddition)
end
function OnHook:MaxOpenLevel()
  if MODULE_GAMESERVER then
    return GetMaxLevel()
  end
  if not MODULE_GAMESERVER and not MODULE_ZONESERVER then
    return self.nCurMaxLevel
  end
  return 1000
end
function OnHook:LoadSetting()
  local szTabPath = "Setting/Player/PlayerLevel.tab"
  local szParamType = "ddd"
  local szKey = "Level"
  local tbParams = {
    "Level",
    "ExpUpGrade",
    "BaseAwardExp"
  }
  local tbPlayerLevel = LoadTabFile(szTabPath, szParamType, szKey, tbParams)
  for nLevel, tbInfo in ipairs(tbPlayerLevel) do
    self.tbOnHook[nLevel] = {
      nLevel = nLevel,
      nExpUpGrade = tbInfo.ExpUpGrade,
      nBaseAwardExp = tbInfo.BaseAwardExp
    }
  end
end
OnHook:LoadSetting()
function OnHook:IsOpen(pPlayer)
  return pPlayer.nLevel >= self.nOpenLevel and GetTimeFrameState(self.szOpenDay) == 1
end
function OnHook:IsCrossDay(pPlayer, nEndTime, nStartTime)
  nEndTime = nEndTime or GetTime()
  return nEndTime >= self:CrossTime(pPlayer, nStartTime)
end
function OnHook:CrossTime(pPlayer, nStartTime)
  local nOffLineTime = nStartTime
  local nOfflineZeroTime = Lib:GetTodayZeroHour(nOffLineTime)
  local nOfflineHour, nOfflineMin, nOfflineSec = Lib:TransferSecond2NormalTime(nOffLineTime - nOfflineZeroTime)
  nOffLineTime = nOffLineTime - nOfflineMin * 60 - nOfflineSec
  local nCrossHour = (24 - (nOfflineHour - self.OnHookTimeReset_Hour)) % 24
  if nCrossHour == 0 then
    nCrossHour = 24
  end
  local nCrossTime = nOffLineTime + nCrossHour * 60 * 60
  return nCrossTime
end
function OnHook:CalcPassExpAndOnHookTime(pPlayer, nEndTime, nLastSaveTime)
  local nPassExpTime = 0
  local nRemainOnHookTime = 0
  local nOffLineTime = nLastSaveTime
  local nOnHookTime = self:OnHookTime(pPlayer)
  local nExpTime = self:ExpTime(pPlayer)
  local bIsCross = self:IsCrossDay(pPlayer, nEndTime, nOffLineTime)
  if nExpTime >= self.MaxExpTime then
    nRemainOnHookTime = nOnHookTime
    if bIsCross then
      nRemainOnHookTime = self.OnHookTimePerDay
    end
    return nPassExpTime, nRemainOnHookTime
  end
  if bIsCross then
    local nCrossTime = self:CrossTime(pPlayer, nOffLineTime)
    local nPassBeforeTime = nCrossTime - nOffLineTime
    nPassExpTime = nOnHookTime < nPassBeforeTime and nOnHookTime or nPassBeforeTime
    local nPassAfterTime = nEndTime - nCrossTime
    local nDay = math.floor(nPassAfterTime / 86400)
    nPassExpTime = nPassExpTime + nDay * self.OnHookTimePerDay
    nPassAfterTime = nPassAfterTime % 86400
    nPassExpTime = nPassExpTime + (nPassAfterTime > self.OnHookTimePerDay and self.OnHookTimePerDay or nPassAfterTime)
    nPassExpTime = nPassExpTime - self.nDelayTime
    nPassAfterTime = self:DragOutSecond(nPassAfterTime)
    nRemainOnHookTime = nPassAfterTime > self.OnHookTimePerDay and 0 or self.OnHookTimePerDay - nPassAfterTime
    if nExpTime + nPassExpTime > self.MaxExpTime then
      local nOverTime = nExpTime + nPassExpTime - self.MaxExpTime
      nRemainOnHookTime = nRemainOnHookTime + nOverTime
      if nRemainOnHookTime > self.OnHookTimePerDay then
        nRemainOnHookTime = self.OnHookTimePerDay or nRemainOnHookTime
      end
    end
  else
    local nPassTime = nEndTime - nOffLineTime - self.nDelayTime
    nPassTime = nPassTime < 0 and 0 or nPassTime
    nPassTime = self:DragOutSecond(nPassTime)
    nPassExpTime = nOnHookTime < nPassTime and nOnHookTime or nPassTime
    nRemainOnHookTime = nOnHookTime < nPassTime and 0 or nOnHookTime - nPassTime
    if nExpTime + nPassExpTime > self.MaxExpTime then
      local nOverTime = nExpTime + nPassExpTime - self.MaxExpTime
      nRemainOnHookTime = nRemainOnHookTime + nOverTime
      nRemainOnHookTime = nRemainOnHookTime > self.OnHookTimePerDay and self.OnHookTimePerDay or nRemainOnHookTime
    end
  end
  nPassExpTime = self:DragOutSecond(nPassExpTime)
  return nPassExpTime, nRemainOnHookTime
end
function OnHook:DragOutSecond(nTime)
  local nHour, nMin = Lib:TransferSecond2NormalTime(nTime)
  return nHour * 60 * 60 + nMin * 60
end
function OnHook:CheckCommond(pPlayer)
  if not self:IsOpen(pPlayer) then
    return false, "离线托管尚未开放"
  end
  local nExpTime = self:ExpTime(pPlayer)
  if nExpTime < 60 then
    return false, "没有可领取的离线经验"
  end
  return true
end
function OnHook:CheckIsMaxOpenLevel(pPlayer)
  local nHaveExp = pPlayer.GetExp()
  local nNextExp = self.tbOnHook[pPlayer.nLevel].nExpUpGrade
  return pPlayer.nLevel >= self:MaxOpenLevel() and nHaveExp >= nNextExp
end
function OnHook:UpdatePlayerLoginTime()
  me.nLastLoginTime = GetTime()
  if MODULE_GAMESERVER then
    me.CallClientScript("OnHook:UpdatePlayerLoginTime")
  end
end
function OnHook:PayTips(pPlayer, nPayType)
  local szTip = ""
  local nExpTime = self:ExpTime(pPlayer)
  local nBaiJuWanTime = self:GetBaiJuWanTime(pPlayer, nPayType)
  if nExpTime > nBaiJuWanTime then
    local nExtraExpTime = nExpTime - nBaiJuWanTime
    local nPerBaiJuWanTime, nPerBaiJuWanPrice, nItemId = self:GetPerBaiJuWanInfo(nPayType)
    local nHaveNum = pPlayer.GetItemCountInAllPos(nItemId)
    local nNeedNum = math.ceil(nExtraExpTime / nPerBaiJuWanTime)
    local nUseNum = nHaveNum > nNeedNum and nNeedNum or nHaveNum
    local nLackNum = nNeedNum - nHaveNum
    szTip = szTip .. "\n（"
    if nHaveNum > 0 then
      szTip = szTip .. string.format("已拥有[FFFE0D]%d个[-]%s", nHaveNum, KItem.GetItemShowInfo(nItemId, pPlayer.nFaction))
    end
    if nLackNum > 0 then
      if nHaveNum > 0 then
        szTip = szTip .. "，"
      end
      local nNeedPay = nLackNum * nPerBaiJuWanPrice
      local _, szMoneyEmotion = Shop:GetMoneyName("Gold")
      local szNeedBuy = string.format("需再购买[FFFE0D]%d个[-]", nLackNum)
      if nHaveNum <= 0 then
        szNeedBuy = szNeedBuy .. KItem.GetItemShowInfo(nItemId, pPlayer.nFaction)
      end
      local szNeedPay = string.format("，花费[FFFE0D]%d[-]%s", nNeedPay, szMoneyEmotion)
      szTip = szTip .. szNeedBuy .. szNeedPay
    end
    szTip = szTip .. "）"
  end
  return szTip
end
function OnHook:CheckSpecialBaiJuWanIsOpen(pPlayer)
  local nVipLevel = pPlayer.GetVipLevel()
  return nVipLevel >= self.nSpecialBaiJuWanOpenVip or self:SpecialBaiJuWanTime(pPlayer) >= 60
end
function OnHook:CheckSpecialPayType(pPlayer)
  return pPlayer.GetVipLevel() < self.nSpecialBaiJuWanOpenVip and self:SpecialBaiJuWanTime(pPlayer) >= 60
end
function OnHook:GetBaiJuWanTime(pPlayer, nPayType)
  if nPayType == OnHook.OnHookType.Pay then
    return self:BaiJuWanTime(pPlayer)
  elseif nPayType == OnHook.OnHookType.SpecialPay then
    return self:SpecialBaiJuWanTime(pPlayer)
  end
  return 0
end
function OnHook:GetBaiJuWanSaveKey(nPayType)
  if nPayType == OnHook.OnHookType.Pay then
    return self.BaiJuWan_Time
  elseif nPayType == OnHook.OnHookType.SpecialPay then
    return self.SpecialBaiJuWan_Time
  end
end
function OnHook:GetPerBaiJuWanInfo(nPayType)
  if nPayType == OnHook.OnHookType.Pay then
    return Item:GetClass("BaiJuWan").nAddTime, Item:GetClass("BaiJuWan").nPrice, self.nBaiJuWanId
  elseif nPayType == OnHook.OnHookType.SpecialPay then
    return Item:GetClass("SpecialBaiJuWan").nAddTime, Item:GetClass("SpecialBaiJuWan").nPrice, self.nSpecialBaiJuWanId
  end
end
function OnHook:CheckStartOnlineHook(pPlayer)
  if not self:IsOpen(pPlayer) then
    return false, "在线托管尚未开放"
  end
  if not self.tbOnlineOnhookMap[pPlayer.nMapTemplateId] then
    return false, "仅在城市、新手村和家园才可以托管"
  end
  if not Map:IsCityMap(pPlayer.nMapTemplateId) then
    return false, "只能在城市开启在线托管"
  end
  if OnHook:OnHookTime(pPlayer) < 60 and not self:IsCrossDay(pPlayer, GetTime(), self:LoginTime(pPlayer)) then
    return false, "今日托管时间已用完"
  end
  if self:OnLineOnHookTime(pPlayer) > 0 then
    return false, "目前已经开启在线挂机"
  end
  return true
end
function OnHook:CheckEndOnlineHook(pPlayer)
  if not self:IsOpen(pPlayer) then
    return false, "离线托管尚未开放"
  end
  return true
end
function OnHook:IsOnLineOnHook(pPlayer)
  return self:OnLineOnHookTime(pPlayer) > 0
end
function OnHook:IsOnLineOnHookForce(pPlayer)
  return self:IsOnLineOnHook(pPlayer) and House:IsInNormalHouse(pPlayer)
end
function OnHook:LastSaveTime(pPlayer)
  local tbStayInfo = KPlayer.GetRoleStayInfo(pPlayer.dwID)
  return tbStayInfo and tbStayInfo.nLastOnlineTime or 0
end
function OnHook:LastOfflineTime(pPlayer)
  return pPlayer.GetUserValue(self.SAVE_ONHOOK_GROUP, self.OffLine_Time)
end
function OnHook:ExpTime(pPlayer)
  return pPlayer.GetUserValue(self.SAVE_ONHOOK_GROUP, self.Exp_Time)
end
function OnHook:OnHookTime(pPlayer)
  return pPlayer.GetUserValue(self.SAVE_ONHOOK_GROUP, self.OnHook_Time)
end
function OnHook:BaiJuWanTime(pPlayer)
  return pPlayer.GetUserValue(self.SAVE_ONHOOK_GROUP, self.BaiJuWan_Time)
end
function OnHook:SpecialBaiJuWanTime(pPlayer)
  return pPlayer.GetUserValue(self.SAVE_ONHOOK_GROUP, self.SpecialBaiJuWan_Time)
end
function OnHook:LoginTime(pPlayer)
  return pPlayer.GetUserValue(self.SAVE_ONHOOK_LOGIN_GROUP, self.Login_Time)
end
function OnHook:OnLineOnHookTime(pPlayer)
  return pPlayer.GetUserValue(self.SAVE_ONLINE_ONHOOK_GROUP, self.OnLine_OnHook_Time)
end
function OnHook:GetOnHookTime(pPlayer)
  local nLoginTime = self:LoginTime(pPlayer)
  if nLoginTime and nLoginTime ~= 0 then
    local bIsCross = self:IsCrossDay(pPlayer, GetTime(), nLoginTime)
    if bIsCross then
      return self.OnHookTimePerDay
    end
  end
  return self:OnHookTime(pPlayer)
end
function OnHook:CheckRequestOnlineOH(pPlayer)
  if pPlayer.nRequestStartOnlineOHTime and GetTime() < pPlayer.nRequestStartOnlineOHTime then
    local nInterval = pPlayer.nRequestStartOnlineOHTime - GetTime()
    local nSecond = nInterval > 0 and nInterval or 0
    return false, string.format("托管操作太频繁了,请%d秒之后再尝试", nSecond)
  end
  return true
end
function OnHook:CheckIsShowSpecialTip(pPlayer)
  return pPlayer.GetVipLevel() >= self.nSpecialBaiJuWanOpenVip
end
