Compose.EntityCompose = Compose.EntityCompose or {}
local EntityCompose = Compose.EntityCompose
local nMaxChildCount = 5
EntityCompose.tbChildInfo = {}
EntityCompose.tbTargeInfo = {}
EntityCompose.tbShowFragTemplates = {}
function EntityCompose:LoadSetting()
  local szTabPath = "Setting/Item/ItemCompose/EntityCompose.tab"
  local szParamType = "dddsdd"
  local szKey = "TargetTemplateID"
  local tbParams = {
    "TargetTemplateID",
    "IsShowFrag",
    "IsHideTip",
    "ConsumeType",
    "ConsumeCount",
    "BagSort"
  }
  for i = 1, nMaxChildCount do
    szParamType = szParamType .. "dd"
    table.insert(tbParams, "ChildTemplateID" .. i)
    table.insert(tbParams, "NeedCount" .. i)
  end
  local tbSettings = LoadTabFile(szTabPath, szParamType, szKey, tbParams)
  local tbPieceToId = {}
  for nTargetTemplateID, tbRowInfo in pairs(tbSettings) do
    self.tbTargeInfo[nTargetTemplateID] = self.tbTargeInfo[nTargetTemplateID] or {}
    self.tbTargeInfo[nTargetTemplateID].nBagSort = tbRowInfo.BagSort
    if tbRowInfo.ConsumeType and tbRowInfo.ConsumeCount and tbRowInfo.ConsumeType ~= "" and tbRowInfo.ConsumeCount ~= 0 then
      self.tbTargeInfo[nTargetTemplateID].szConsumeType = tbRowInfo.ConsumeType
      self.tbTargeInfo[nTargetTemplateID].nConsumeCount = tbRowInfo.ConsumeCount
    end
    if tbRowInfo.IsHideTip and tbRowInfo.IsHideTip == 1 then
      self.tbTargeInfo[nTargetTemplateID].bIsHideTip = true
    end
    for i = 1, nMaxChildCount do
      local szChildKey = "ChildTemplateID" .. i
      if tbRowInfo[szChildKey] and tbRowInfo[szChildKey] ~= 0 then
        local nChildItemId = tbRowInfo[szChildKey]
        local nCount = tbRowInfo["NeedCount" .. i]
        self.tbChildInfo[nChildItemId] = nTargetTemplateID
        self.tbTargeInfo[nTargetTemplateID][nChildItemId] = nCount
        if tbRowInfo.IsShowFrag == 1 then
          self.tbShowFragTemplates[nChildItemId] = 1
        end
      end
    end
    tbPieceToId[tbRowInfo.ChildTemplateID1] = nTargetTemplateID
  end
  self.tbPieceToId = tbPieceToId
end
EntityCompose:LoadSetting()
function EntityCompose:CheckIsComposeMaterial(nTemplateId)
  local szMsg = "找不到该合成材料"
  if not nTemplateId then
    return false, szMsg
  end
  local nTargetID = self.tbChildInfo[nTemplateId]
  if not nTargetID then
    return false, szMsg
  end
  if not self.tbTargeInfo[nTargetID] then
    return false, szMsg
  end
  if not self.tbTargeInfo[nTargetID][nTemplateId] then
    return false, szMsg
  end
  return true
end
function EntityCompose:GetIdFromPiece(nPieceId)
  return self.tbPieceToId[nPieceId]
end
function EntityCompose:GetEquipComposeInfo(nTemplateId)
  local nTargetID = self.tbChildInfo[nTemplateId]
  local nNeedTotal = 0
  local tbTargeInfo = self.tbTargeInfo[nTargetID]
  for nChildId, nNeed in pairs(tbTargeInfo) do
    if tonumber(nChildId) then
      if nChildId ~= nTemplateId then
        return
      end
      nNeedTotal = nNeedTotal + nNeed
    end
  end
  return nTargetID, nNeedTotal
end
function EntityCompose:CheckIsCanCompose(pPlayer, nTemplateId)
  local nTargetID = self.tbChildInfo[nTemplateId]
  local bIsCan = true
  local tbTargeInfo = self.tbTargeInfo[nTargetID]
  for nChildId, nNeed in pairs(tbTargeInfo) do
    if tonumber(nChildId) then
      local nHave = pPlayer.GetItemCountInAllPos(nChildId)
      if nNeed > nHave then
        bIsCan = false
        break
      end
    end
  end
  local szTip = string.format("您的材料不足，无法合成【%s】", KItem.GetItemShowInfo(nTargetID, pPlayer.nFaction))
  return bIsCan, szTip, nTargetID
end
function EntityCompose:GetTip(it)
  if not self:CheckIsComposeMaterial(it.dwTemplateId) then
    return ""
  end
  local nTargetID = self.tbChildInfo[it.dwTemplateId]
  local tbTargeInfo = self.tbTargeInfo[nTargetID]
  local szTip = ""
  local szName = ""
  local nHave = 0
  for nChildId, nNeed in pairs(tbTargeInfo) do
    if tonumber(nChildId) and nChildId ~= it.dwTemplateId then
      szName = KItem.GetItemShowInfo(nChildId, me.nFaction)
      nHave = me.GetItemCountInAllPos(nChildId)
      szTip = szTip .. string.format("%s：[FFFE0D]%d/%d[-]\n", szName, nHave, nNeed)
    end
  end
  return szTip
end
function EntityCompose:IsNeedConsume(nTemplateId)
  local nTargetID = self.tbChildInfo[nTemplateId]
  local tbTargeInfo = self.tbTargeInfo[nTargetID]
  return tbTargeInfo.szConsumeType
end
function EntityCompose:GetConsumeInfo(nTemplateId)
  local nTargetID = self.tbChildInfo[nTemplateId]
  local tbTargeInfo = self.tbTargeInfo[nTargetID]
  return tbTargeInfo.szConsumeType, tbTargeInfo.nConsumeCount
end
function EntityCompose:GetBagSort(nTemplateId)
  local nTargetID = self.tbChildInfo[nTemplateId]
  local tbTargeInfo = self.tbTargeInfo[nTargetID]
  return tbTargeInfo.nBagSort
end
