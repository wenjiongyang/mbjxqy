local tbItem = Item:GetClass("CardPickGold")
function tbItem:OnUse(it)
  me.CallClientScript("Ui:OpenWindow", "CardPickingResult", "GoldFreePick")
  local tbItem = CardPicker:GetRandomItem("Gold", me)
  me.SendAward({
    {
      tbItem.szItemType,
      tbItem.nItemId,
      tbItem.nCount
    }
  }, false, false, Env.LogWay_CoinPick)
  me.CallClientScript("CardPicker:OnCoinPickResult", {tbItem})
  Log("CardPicker", me.szAccount, me.dwID, "GoldItemUse", tbItem.szItemType, tbItem.nItemId, tbItem.nCount)
  return 1
end
