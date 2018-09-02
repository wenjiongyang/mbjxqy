local tbItem = Item:GetClass("SanShengShi")
function tbItem:GetUseSetting(nItemTemplateId, nItemId)
  local fnUse = function()
    Ui.HyperTextHandle:Handle("[url=npc:月老, 2371, 10]", 0, 0)
    Ui:CloseWindow("ItemTips")
    Ui:CloseWindow("ItemBox")
  end
  return {
    szFirstName = "预定婚礼",
    fnFirst = fnUse
  }
end
