local tbItem = Item:GetClass("SpecialBaiJuWan")
tbItem.nAddTime = 28800
tbItem.nPrice = 240
function tbItem:OnUse(it)
  if not it.dwTemplateId then
    return
  end
  if not OnHook:IsOpen(me) then
    me.CenterMsg("离线托管尚未开放")
    return
  end
  local bRet = OnHook:OnUseBaiJuWan(me, self.nAddTime, OnHook.OnHookType.SpecialPay)
  if not bRet then
    return 0
  end
  return 1
end
