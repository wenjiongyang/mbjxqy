local tbItem = Item:GetClass("PartnerProtentailItem")
function tbItem:GetUseSetting(nTemplateId, nItemId)
  if not (not Ui:WindowVisible("Partner") and nItemId) or nItemId <= 0 then
    return {}
  end
  local fnFirst = function()
    Ui:OpenWindow("Partner")
    Ui:CloseWindow("ItemTips")
  end
  return {szFirstName = "使用", fnFirst = fnFirst}
end
local tbReinitItem = Item:GetClass("PartnerReinitItem")
function tbReinitItem:GetUseSetting(nTemplateId, nItemId)
  if not (not Ui:WindowVisible("Partner") and nItemId) or nItemId <= 0 then
    return {}
  end
  local fnFirst = function()
    Ui:OpenWindow("Partner")
    Ui:CloseWindow("ItemTips")
  end
  return {szFirstName = "使用", fnFirst = fnFirst}
end
