ChangeName.ITEM_ChangeName = 2593
ChangeName.OPEN_LEVEL = 11
ChangeName.FREE_LEVEL = 30
ChangeName.SAVE_GROUP = 26
ChangeName.KEY_TIMES = 1
ChangeName.KEY_FREE = 2
ChangeName.tbPriceSetting = {800}
function ChangeName:GetChangePrice(pPlayer)
  if pPlayer.nLevel <= self.FREE_LEVEL then
    local nUseFree = pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_FREE)
    if nUseFree == 0 then
      return 0
    end
  end
  local nChangeItem = pPlayer.GetItemCountInAllPos(self.ITEM_ChangeName)
  if nChangeItem > 0 then
    return 0, true
  end
  local nChangedTimes = pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_TIMES)
  local nPrice = self.tbPriceSetting[nChangedTimes + 1]
  nPrice = nPrice or self.tbPriceSetting[#self.tbPriceSetting]
  return nPrice
end
