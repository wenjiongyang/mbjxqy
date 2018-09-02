local tbItem = Item:GetClass("GoldEvoMaterial")
function tbItem:GetUseSetting(nTemplateId, nItemId)
  local tbUseSetting = {szFirstName = "使用"}
  function tbUseSetting.fnFirst()
    Ui:CloseWindow("ItemTips")
    Ui:OpenWindow("EquipmentEvolutionPanel", "Type_Evolution")
  end
  if GetTimeFrameState("OpenLevel89") == 1 then
    tbUseSetting.szFirstName = "进化"
    tbUseSetting.szSecondName = "升阶"
    function tbUseSetting.fnSecond()
      Ui:CloseWindow("ItemTips")
      Ui:OpenWindow("EquipmentEvolutionPanel", "Type_Upgrade")
    end
  end
  return tbUseSetting
end
