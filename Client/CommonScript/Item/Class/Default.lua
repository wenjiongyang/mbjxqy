local tbDefault = Item:GetClass("default")
function tbDefault:OnItemInit()
end
function tbDefault:OnInit()
end
function tbDefault:OnCreate()
end
function tbDefault:CheckUsable()
  return 1
end
function tbDefault:OnClientUse(pItem)
  return 0
end
function tbDefault:GetTitle(pItem)
  return pItem.szName
end
function tbDefault:GetPrefixTip()
  return ""
end
function tbDefault:GetTip(nState)
  return ""
end
function tbDefault:GetTipByTemplate(nTemplateId, nFaction)
  return ""
end
function tbDefault:CheckCanSell(pItem)
  return true
end
