local tbItem = Item:GetClass("Jxsh_Sz")
function tbItem:OnUse(pItem)
  CollectionSystem:OnUseShenZhouKa()
  return 1
end
