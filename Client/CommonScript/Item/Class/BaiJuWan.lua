local tbItem = Item:GetClass("BaiJuWan")
tbItem.nAddTime = 28800
tbItem.nPrice = 48
function tbItem:OnUse(it)
  if not it.dwTemplateId then
    return
  end
  if not OnHook:IsOpen(me) then
    me.CenterMsg("离线托管尚未开放")
    return
  end
  local nRet = OnHook:OnUseBaiJuWan(me, self.nAddTime, OnHook.OnHookType.Pay)
  if not nRet then
    return 0
  end
  return 1
end
