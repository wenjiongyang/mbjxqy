function Lottery:OnSyncState(bIsOpen)
  self.bIsLotteryOpen = bIsOpen
  UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_LOTTERY_DATA)
end
function Lottery:IsOpen()
  if not Lottery.bIsLotteryOpen then
    RemoteServer.SyncLotteryState()
  end
  return Lottery.bIsLotteryOpen
end
function Lottery:GetTicketCount()
  local nDrawWeek = Lottery:GetDrawWeek()
  local nWeek = me.GetUserValue(self.USER_GROUP, self.USER_KEY_WEEK)
  if nDrawWeek > nWeek then
    return 0
  end
  return me.GetUserValue(self.USER_GROUP, self.USER_KEY_TICKET)
end
