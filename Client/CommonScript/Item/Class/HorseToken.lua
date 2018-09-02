local tbItem = Item:GetClass("HorseToken")
tbItem.szEvolutionTimeFrame = "OpenLevel79"
tbItem.szEvolutionTimeFrame2 = "OpenLevel99"
tbItem.szEvolutionTimeFrame3 = "OpenLevel119"
function tbItem:GetUseSetting(nTemplateId, nItemId)
  local tbUseSetting = {szFirstName = "兑换", fnFirst = "UseItem"}
  if GetTimeFrameState(self.szEvolutionTimeFrame) == 1 then
    tbUseSetting.szSecondName = "升阶"
    function tbUseSetting.fnSecond()
      Ui:CloseWindow("ItemTips")
      Ui:OpenWindow("EquipmentEvolutionPanel", "Type_EvolutionHorse")
    end
  end
  return tbUseSetting
end
function tbItem:OnUse(pItem)
  local tbExchangeItem = Item:GetClass("ExchangeItem")
  return tbExchangeItem:OnUse(pItem)
end
function tbItem:GetIntrol(dwTemplateId)
  local tbBase = KItem.GetItemBaseProp(dwTemplateId)
  local szBaseTip = tbBase.szIntro
  if GetTimeFrameState(self.szEvolutionTimeFrame) == 1 then
    szBaseTip = szBaseTip .. "\n\n可以将50级乌云踏雪，升阶为70级绝影"
  end
  if GetTimeFrameState(self.szEvolutionTimeFrame2) == 1 then
    szBaseTip = szBaseTip .. "\n可以将70级绝影，升阶为90级万里烟云照"
  end
  if GetTimeFrameState(self.szEvolutionTimeFrame3) == 1 then
    szBaseTip = szBaseTip .. "\n可以将90级万里烟云照，升阶为 110级追风呼雷豹"
  end
  return szBaseTip
end
