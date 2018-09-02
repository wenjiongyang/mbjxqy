local tbItem = Item:GetClass("GoldEvoMaterialMap")
function tbItem:GetUseSetting(nTemplateId, nItemId)
  local tbUseSetting = {szFirstName = "使用"}
  function tbUseSetting.fnFirst()
    Ui:CloseWindow("ItemTips")
    local nEquipId = Item.GoldEquip:GetCosumeItemAutoSelectEquipId(me, nTemplateId)
    Ui:OpenWindow("EquipmentEvolutionPanel", "Type_Evolution", nEquipId)
  end
  if Shop:CanSellWare(me, nItemId, 1) then
    tbUseSetting.fnSecond = "SellItem"
    tbUseSetting.szSecondName = "出售"
  end
  return tbUseSetting
end
