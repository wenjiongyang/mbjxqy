function Compose:LoadSetting()
  self.tbComposeInfo = {}
  local tbSettings = Lib:LoadTabFile("Setting/Partner/RuneCompose.tab", {
    ObjTemplateID = 1,
    ChildTemplateID1 = 1,
    NeedNum1 = 0,
    ChildTemplateID2 = 1,
    NeedNum2 = 0,
    ChildTemplateID3 = 1,
    NeedNum3 = 0
  })
  for _, tbItem in pairs(tbSettings or {}) do
    local tbComposeInfo = {}
    for nIdx = 1, 3 do
      if 0 < tbItem["ChildTemplateID" .. nIdx] and 0 < tbItem["NeedNum" .. nIdx] then
        table.insert(tbComposeInfo, {
          nChildTemplateID = tbItem["ChildTemplateID" .. nIdx],
          nNeedNum = tbItem["NeedNum" .. nIdx]
        })
      else
        break
      end
    end
    self.tbComposeInfo[tbItem.ObjTemplateID] = tbComposeInfo
  end
end
Compose:LoadSetting()
function Compose:GetConsumeInfo(nTemplateID)
  return self.tbComposeInfo[nTemplateID]
end
function Compose:SetCurItem(nTargetID, nCurItemID)
  self.tbCurItem = {nTargetID = nTargetID, nCurItemID = nCurItemID}
end
function Compose:GetCurItem()
  if not self.tbCurItem then
    return
  end
  local tbTarget = self:GetConsumeInfo(self.tbCurItem.nTargetID)
  if not tbTarget then
    return self.tbCurItem.nCurItemID, 1
  end
  for i = 1, 3 do
    if tbTarget[i] and tbTarget[i].nChildTemplateID == self.tbCurItem.nCurItemID then
      return self.tbCurItem.nCurItemID, tbTarget[i].nNeedNum
    end
  end
  return self.tbCurItem.nCurItemID, 1
end
function Compose:ClearCurItem()
  self.tbCurItem = nil
end
function Compose:CheckCanEquip(nItemTemplateID)
  local nHaveNum = me.GetItemCountInAllPos(nItemTemplateID)
  if nHaveNum > 0 then
    return true
  end
  local tbComposeInfo = self:GetConsumeInfo(nItemTemplateID)
  if not tbComposeInfo then
    return
  end
  for _, tbInfo in pairs(tbComposeInfo) do
    local nHaveNum = me.GetItemCountInAllPos(tbInfo.nChildTemplateID)
    if nHaveNum < tbInfo.nNeedNum then
      return
    end
  end
  return true
end
function Compose:IsForPartnerEquip(szClass)
  return szClass and (szClass == "PartnerEquip" or szClass == "PartnerScroll")
end
