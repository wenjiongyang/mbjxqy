Require("CommonScript/Item/XiuLian.lua")
local tbItem = Item:GetClass("XiuLianZhu")
function tbItem:OnUse(pItem)
  local tbDef = XiuLian.tbDef
  local bRet = XiuLian:CanBuyXiuLianDan(me)
  if bRet then
    me.CallClientScript("Ui:OpenWindow", "CommonShop", "Treasure", "tabAllShop", tbDef.nXiuLianDanID)
    me.CallClientScript("Ui:CloseWindow", "ItemTips")
  else
    me.CallClientScript("Ui:OpenWindow", "FieldPracticePanel")
  end
end
function tbItem:GetTip(pItem)
  local tbDan = Item:GetClass("XiuLianDan")
  local szMsg = ""
  local nCount = tbDan:GetOpenResidueCount(me)
  local nResidueTime = XiuLian:GetXiuLianResidueTime(me)
  szMsg = string.format("剩余累积修炼时间：[FFFE0D]%s[-]\n累积可使用修炼丹：[FFFE0D]%s次[-]", Lib:TimeDesc(nResidueTime), nCount)
  return szMsg
end
function tbItem:GetUseSetting(nTemplateId, nItemId)
  local tbOpt = {szFirstName = "使用", fnFirst = "UseItem"}
  local bRet = XiuLian:CanBuyXiuLianDan(me)
  if bRet then
    tbOpt.szFirstName = "购买修炼丹"
  end
  return tbOpt
end
