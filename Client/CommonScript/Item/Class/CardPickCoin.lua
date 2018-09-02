local tbItem = Item:GetClass("CardPickCoin")
function tbItem:OnUse(it)
  me.CallClientScript("Ui:OpenWindow", "CardPickingResult", "CoinFreePick")
  local tbItem = CardPicker:GetRandomItem("Coin", me)
  me.SendAward({
    {
      tbItem.szItemType,
      tbItem.nItemId,
      tbItem.nCount
    }
  }, false, false, Env.LogWay_CoinPick)
  me.CallClientScript("CardPicker:OnCoinPickResult", {tbItem})
  Log("CardPicker", me.szAccount, me.dwID, "CoinItemUse", tbItem.szItemType, tbItem.nItemId, tbItem.nCount)
  return 1
end
