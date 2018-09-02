Require("CommonScript/Item/Class/Equip.lua")
local tbHorseEqiup = Item:GetClass("horse_equip")
local tbEquip = Item:GetClass("equip")
tbHorseEqiup.tbExtip = {
  [3] = {
    "OpenLevel109",
    "(开启109级上限后，可升阶到4阶)"
  }
}
function tbHorseEqiup:OnInit(pEquip)
end
function tbHorseEqiup:FormatTips(nTemplateId, pEquip)
  local tbNormal = {}
  local tbRider = {}
  local tbAttrib = KItem.GetEquipBaseProp(nTemplateId).tbBaseAttrib
  local tbBaseProp = KItem.GetItemBaseProp(nTemplateId)
  if not tbAttrib then
    return szTips
  end
  table.insert(tbNormal, {"", 1})
  table.insert(tbNormal, {
    "加成主角属性"
  })
  for i, tbMA in ipairs(tbAttrib) do
    local szDesc = tbEquip:GetMagicAttribDesc(tbMA.szName, tbMA.tbValue, 0)
    if szDesc and szDesc ~= "" then
      if tbMA.nActiveReq == Item.emEquipActiveReq_Ride then
        table.insert(tbRider, {szDesc, 1})
      else
        table.insert(tbNormal, {szDesc, 1})
      end
    end
  end
  if #tbRider > 0 then
    table.insert(tbNormal, {
      "上马后激活"
    })
    Lib:MergeTable(tbNormal, tbRider)
  end
  local szTips = self:GetHorseEnhanceTips(tbBaseProp.nLevel)
  if szTips then
    table.insert(tbNormal, {"", 1})
    table.insert(tbNormal, {szTips, 2})
  end
  if pEquip and 0 < pEquip.GetIntValue(-9996) then
    table.insert(tbNormal, {"有效期"})
    table.insert(tbNormal, {
      os.date("%Y年%m月%d日 %H:%M:%S", pEquip.GetIntValue(-9996)),
      1
    })
  end
  return tbNormal, tbBaseProp.nQuality
end
function tbHorseEqiup:GetTip(pEquip, pPlayer, bIsCompare)
  local tbBaseAttrib, nQuality = self:FormatTips(pEquip.dwTemplateId, pEquip)
  return tbBaseAttrib, nQuality
end
function tbHorseEqiup:GetTipByTemplate(nTemplateId, tbSaveRandomAttrib)
  local tbBaseAttrib, nQuality = self:FormatTips(nTemplateId)
  return tbBaseAttrib, nQuality
end
function tbHorseEqiup:OnClientUse()
  Ui:OpenWindow("HorsePanel")
end
function tbHorseEqiup:GetHorseEnhanceTips(nLevel)
  if self.tbExtip[nLevel] then
    local szTimeFrame, szDesc = unpack(self.tbExtip[nLevel])
    if GetTimeFrameState(szTimeFrame) == 1 then
      return szDesc
    end
  end
end
