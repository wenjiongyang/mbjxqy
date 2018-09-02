StoneMgr.INSET_COUNT_MAX = 7
StoneMgr.COMBINE_COUNT = 3
StoneMgr.COMBINE_CRYSTAL_COUNT = 4
StoneMgr.MinInsetRoleLevel = 16
StoneMgr.USER_VALUE_GROUP = 41
StoneMgr.tbAcheiveNeedInsetNum = {
  [1] = 20,
  [2] = 20,
  [3] = 20,
  [4] = 20,
  [5] = 20,
  [6] = 40
}
StoneMgr.nRedbagNeedInsertNum = 20
StoneMgr.INSET_ATTRIB_GROUP = 2
StoneMgr.tbCrystalTimeFrame = {
  [223] = "OpenLevel49",
  [224] = "OpenLevel69",
  [225] = "OpenLevel89",
  [227] = "OpenLevel119",
  [214] = "OpenLevel49",
  [215] = "OpenLevel69",
  [216] = "OpenLevel89",
  [217] = "OpenLevel119"
}
function StoneMgr:Init()
  self.tbStoneSetting = LoadTabFile("Setting/Item/Other/Stone.tab", "dddddddddddddsdddsddddsd", "TemplateId", {
    "TemplateId",
    "NextTemplateId",
    "FightPower",
    "Amulet",
    "Armor",
    "Belt",
    "Boots",
    "Cuff",
    "Helm",
    "Necklace",
    "Pendant",
    "Ring",
    "Weapon",
    "AttribType1",
    "Value11",
    "Value21",
    "Value31",
    "AttribType2",
    "Value12",
    "Value22",
    "Value32",
    "Debris",
    "Name",
    "InsetType"
  })
  local tbPreStoneIndex = {}
  for TemplateId, v in pairs(self.tbStoneSetting) do
    if v.NextTemplateId ~= 0 then
      tbPreStoneIndex[v.NextTemplateId] = TemplateId
    end
  end
  self.tbPreStoneIndex = tbPreStoneIndex
  self.tbInsetExtern = LoadTabFile("Setting/Item/InsetExtern.tab", "ddds", nil, {
    "StoneLevel",
    "NeedNum",
    "AttribLevel",
    "Img"
  })
  for nIdx, tbInfo in ipairs(self.tbInsetExtern) do
    tbInfo.nIdx = nIdx
  end
end
StoneMgr:Init()
function StoneMgr:GetCanInsetPosDes(nStoneTemplateId)
  local tbSet = self.tbStoneSetting[nStoneTemplateId]
  if not tbSet then
    return
  end
  local tbPosName = {}
  for k, szPosName in pairs(Item.EQUIPTYPE_EN_NAME) do
    if tbSet[szPosName] == 1 then
      table.insert(tbPosName, Item.EQUIPTYPE_NAME[k])
    end
  end
  if not next(tbPosName) then
    return
  end
  return table.concat(tbPosName, ", ")
end
function StoneMgr:GetCanInsetPos(nStoneTemplateId)
  local tbSet = self.tbStoneSetting[nStoneTemplateId]
  if not tbSet then
    return
  end
  local tbPosType = {}
  for k, szPosName in pairs(Item.EQUIPTYPE_EN_NAME) do
    if tbSet[szPosName] == 1 then
      table.insert(tbPosType, k)
    end
  end
  return tbPosType
end
function StoneMgr:GetLevel1Stone()
  if not self.tbStoneLevel1 then
    self.tbStoneLevel1 = {}
    for nStoneTemplateId, _ in pairs(self.tbStoneSetting) do
      if not self:IsStoneDebris(nStoneTemplateId) and not self:IsCrystal(nStoneTemplateId) then
        local nLevel = self:GetStoneLevel(nStoneTemplateId)
        if nLevel == 1 then
          table.insert(self.tbStoneLevel1, nStoneTemplateId)
        end
      end
    end
  end
  return self.tbStoneLevel1
end
function StoneMgr:IsStoneDebris(nDebrisId)
  if not self.tbStoneDebris then
    self.tbStoneDebris = {}
    for _, v in pairs(self.tbStoneSetting) do
      if v.Debris == 1 then
        self.tbStoneDebris[v.TemplateId] = {
          nCombineResult = v.NextTemplateId
        }
      end
    end
  end
  return self.tbStoneDebris[nDebrisId] ~= nil
end
function StoneMgr:IsCrystal(nTemplateId)
  local tbStone = self.tbStoneSetting[nTemplateId]
  if tbStone then
    return tbStone.FightPower == 0 and tbStone.Debris ~= 1
  end
end
function StoneMgr:IsStone(nTemplateId)
  local tbStone = self.tbStoneSetting[nTemplateId]
  return tbStone and not self:IsCrystal(nTemplateId) and not self:IsStoneDebris(nTemplateId)
end
function StoneMgr:IsUnique(nTemplateId)
  local tbStone = self.tbStoneSetting[nTemplateId]
  return tbStone and tbStone.InsetType ~= 0
end
function StoneMgr:GetStoneMA(nStoneTemplateId)
  local tbStone = self.tbStoneSetting[nStoneTemplateId]
  local tbMA = {
    {
      szName = tbStone.AttribType1,
      tbValue = {
        tbStone.Value11,
        tbStone.Value21,
        tbStone.Value31
      }
    },
    {
      szName = tbStone.AttribType2,
      tbValue = {
        tbStone.Value12,
        tbStone.Value22,
        tbStone.Value32
      }
    }
  }
  return tbMA
end
function StoneMgr:GetStoneAttrib(nStoneTemplateId)
  local tbStone = self.tbStoneSetting[nStoneTemplateId]
  if tbStone then
    local szDesc = FightSkill:GetMagicDesc(tbStone.AttribType1, {
      tbStone.Value11,
      tbStone.Value21,
      tbStone.Value31
    })
    local szDesc2 = ""
    if tbStone.AttribType2 ~= "" then
      szDesc2 = FightSkill:GetMagicDesc(tbStone.AttribType2, {
        tbStone.Value12,
        tbStone.Value22,
        tbStone.Value32
      })
    end
    return szDesc or "", szDesc2
  end
  return ""
end
function StoneMgr:GetStoneMagicDesc(nTemplateId)
  local tbStone = self.tbStoneSetting[nTemplateId]
  if tbStone then
    local szName1, szValue1, szName2, szValue2
    if tbStone.AttribType1 ~= "" then
      szName1, szValue1 = FightSkill:GetMagicDescSplit(tbStone.AttribType1, {
        tbStone.Value11,
        tbStone.Value21,
        tbStone.Value31
      })
    end
    if tbStone.AttribType2 ~= "" then
      szName2, szValue2 = FightSkill:GetMagicDescSplit(tbStone.AttribType2, {
        tbStone.Value12,
        tbStone.Value22,
        tbStone.Value32
      })
    end
    return szName1, szValue1, szName2, szValue2
  end
end
function StoneMgr:GetStoneQuality(nStoneTemplateId)
  local tbBaseInfo = KItem.GetItemBaseProp(nStoneTemplateId)
  return tbBaseInfo.nQuality
end
function StoneMgr:GetStoneLevel(nStoneTemplateId)
  local tbBaseInfo = KItem.GetItemBaseProp(nStoneTemplateId)
  return tbBaseInfo.nLevel
end
function StoneMgr:GetStoneMiniIcon(nStoneTemplateId)
  if nStoneTemplateId == 0 then
    return
  end
  local _, nIcon = KItem.GetItemShowInfo(nStoneTemplateId)
  local szAtlas, szIcon, szExtAtlas, szExtSprite = Item:GetIcon(nIcon)
  return szIcon, szAtlas, szExtAtlas, szExtSprite
end
function StoneMgr:GetStoneFightPower(nStoneTemplateId)
  local tbStone = self.tbStoneSetting[nStoneTemplateId]
  if tbStone then
    return tbStone.FightPower
  end
end
function StoneMgr:GetInsetFightPower(pPlayer, nEquipPos)
  local tbInset = pPlayer.GetInsetInfo(nEquipPos)
  local nTotal = 0
  for i, nStoneTemplateId in pairs(tbInset) do
    if nStoneTemplateId and nStoneTemplateId ~= 0 then
      nTotal = nTotal + self:GetStoneFightPower(nStoneTemplateId)
    end
  end
  return nTotal
end
function StoneMgr:GetEquipInsetAttrib(pPlayer, pEquip)
  local tbInset = pPlayer.GetInsetInfo(pEquip.nEquipPos)
  local _, szFrameColor = Item:GetQualityColor(pEquip.nInsetLevel)
  local tbRet = {}
  for i, nStoneTemplateId in pairs(tbInset) do
    if nStoneTemplateId and nStoneTemplateId ~= 0 then
      local szDesc1, szDesc2 = self:GetStoneAttrib(nStoneTemplateId)
      local tbBaseInfo = KItem.GetItemBaseProp(nStoneTemplateId)
      local szIcon, szIconAtlas, szExtAtlas, szExtSprite = self:GetStoneMiniIcon(nStoneTemplateId)
      table.insert(tbRet, {
        szDesc1,
        tbBaseInfo.nQuality,
        szIcon,
        szIconAtlas,
        szDesc2,
        tbBaseInfo.szName,
        szFrameColor,
        szExtAtlas,
        szExtSprite
      })
    end
  end
  return tbRet
end
function StoneMgr:IsFull(tbInset)
  for k, v in pairs(tbInset) do
    if v == 0 then
      return false
    end
  end
  return true
end
function StoneMgr:GetAllStoneInBag(pPlayer, bAll)
  local tbItem = pPlayer.GetItemListInBag()
  local tbStones = {}
  for _, pItem in pairs(tbItem) do
    if pItem.szClass == "Stone" then
      local nTemplateId = pItem.dwTemplateId
      if bAll or self:IsStone(nTemplateId) then
        tbStones[nTemplateId] = tbStones[nTemplateId] or 0
        tbStones[nTemplateId] = tbStones[nTemplateId] + pItem.nCount
      end
    end
  end
  return tbStones
end
function StoneMgr:CanInset(nEquipId, nStoneTemplateId, pPlayer, nInsetPos)
  local pEquip = KItem.GetItemObj(nEquipId)
  if not pEquip then
    return false, "装备不存在"
  end
  local tbData = self.tbStoneSetting[nStoneTemplateId]
  if not tbData then
    Log("[ERROR] StoneMgr:CanInset:", nStoneTemplateId)
    return false, "不存在该魂石"
  end
  local tbBaseInfo = KItem.GetItemBaseProp(nStoneTemplateId)
  if nInsetPos > pEquip.nHoleCount then
    return false, string.format("该装备只有%d个孔", pEquip.nHoleCount)
  end
  if tbBaseInfo.nLevel > pEquip.nInsetLevel then
    return false, string.format("该装备最高只能镶嵌%d级魂石", pEquip.nInsetLevel)
  end
  local szEquipPart = Item.EQUIPTYPE_EN_NAME[pEquip.nItemType]
  if tbData[szEquipPart] ~= 1 then
    return false, "装备部位不符"
  end
  if self:IsCrystal(nStoneTemplateId) then
    return false, "水晶不可镶嵌"
  end
  local tbInset = pPlayer.GetInsetInfo(pEquip.nEquipPos)
  local nOrgTemplate = tbInset[nInsetPos]
  tbInset[nInsetPos] = nil
  if self:CheckSameInsetType(tbData.InsetType, tbInset) then
    return false, "已有同类型魂石"
  end
  if nOrgTemplate and nOrgTemplate ~= 0 then
    if nOrgTemplate == nStoneTemplateId then
      return false, "魂石相同"
    end
    local tbBaseInfoOrg = KItem.GetItemBaseProp(nOrgTemplate)
    if tbBaseInfo.nLevel < tbBaseInfoOrg.nLevel then
      local nMinusLevel = tbBaseInfoOrg.nLevel - tbBaseInfo.nLevel
      local nNextTemplateId, nCombieNeedTemplate
      if nMinusLevel == 1 then
        nNextTemplateId = self:GetNextLevelStone(nStoneTemplateId)
        nCombieNeedTemplate = nStoneTemplateId
      elseif nMinusLevel == 2 then
        nCombieNeedTemplate = self:GetNextLevelStone(nStoneTemplateId)
        if nCombieNeedTemplate and nCombieNeedTemplate ~= 0 then
          nNextTemplateId = self:GetNextLevelStone(nCombieNeedTemplate)
        end
      end
      if nNextTemplateId and nNextTemplateId ~= 0 then
        if nNextTemplateId == nOrgTemplate then
          return false
        end
        local tbDataOrg = self.tbStoneSetting[nOrgTemplate]
        local tbDataNext = self.tbStoneSetting[nNextTemplateId]
        if tbDataOrg.InsetType ~= 0 and tbDataOrg.InsetType == tbDataNext.InsetType then
          return false, "已有同类型魂石"
        end
        local tbCostStoneIds, nCostCombine = self:GetCombineStoneNeed(nCombieNeedTemplate, self:GetCombineDefaulCount(nCombieNeedTemplate), pPlayer)
        if tbCostStoneIds and nCostCombine then
          return true, nil, tbCostStoneIds, nCostCombine, nNextTemplateId
        end
      end
      return false, "无法将高等级魂石替换成低等级魂石"
    end
  end
  return true
end
function StoneMgr:CheckSameInsetType(InsetType, tbInset)
  if InsetType ~= 0 then
    for k, nHansInsetId in pairs(tbInset) do
      if nHansInsetId ~= 0 then
        local tbTarData = self.tbStoneSetting[nHansInsetId]
        if tbTarData.InsetType == InsetType then
          return true
        end
      end
    end
  end
end
function StoneMgr:GetNextLevelStone(nTemplateId)
  local tbStone = self.tbStoneSetting[nTemplateId]
  if tbStone then
    return tbStone.NextTemplateId
  end
end
function StoneMgr:GetStoneLevelQueue(nTemplateId)
  local tbLevelQueue = {nTemplateId}
  local nPreStoneId = self.tbPreStoneIndex[nTemplateId]
  if nPreStoneId then
    table.insert(tbLevelQueue, 1, nPreStoneId)
    local nPreStoneId2 = self.tbPreStoneIndex[nPreStoneId]
    if nPreStoneId2 then
      table.insert(tbLevelQueue, 1, nPreStoneId2)
    end
  end
  local nNextStoneId = self:GetNextLevelStone(nTemplateId)
  if nNextStoneId and nNextStoneId ~= 0 then
    table.insert(tbLevelQueue, nNextStoneId)
    local nNextStoneId2 = self:GetNextLevelStone(nNextStoneId)
    if nNextStoneId2 and nNextStoneId2 ~= 0 then
      table.insert(tbLevelQueue, nNextStoneId2)
    end
  end
  return tbLevelQueue
end
function StoneMgr:GetPreStoneId(nStoneTemplateId)
  return self.tbPreStoneIndex[nStoneTemplateId]
end
function StoneMgr:GetCombineShowInfo(pPlayer, nStoneTemplateId)
  local tbSQ = {}
  local nCurStoneId = nStoneTemplateId
  for i = 1, 10 do
    local nPreStone = self:GetPreStoneId(nCurStoneId)
    if not nPreStone then
      break
    end
    table.insert(tbSQ, 1, nPreStone)
    nCurStoneId = nPreStone
  end
  if #tbSQ <= 0 then
    return
  end
  local nDefaultCombineCount = self:GetCombineDefaulCount(nStoneTemplateId)
  local nTotalNeedCount = 1
  local nNeedItemId = nStoneTemplateId
  local nHaveCount = 0
  for i = #tbSQ, 1, -1 do
    nNeedItemId = tbSQ[i]
    nTotalNeedCount = nTotalNeedCount * nDefaultCombineCount
    nHaveCount = nHaveCount * nDefaultCombineCount
    local nC = pPlayer.GetItemCountInBags(nNeedItemId)
    nHaveCount = nHaveCount + nC
  end
  return nTotalNeedCount, nHaveCount, nNeedItemId
end
function StoneMgr:GetHasCurStoneId(pPlayer, nStoneTemplateId)
  local nHasCount = pPlayer.GetItemCountInAllPos(nStoneTemplateId)
  local nFindStone = nStoneTemplateId
  local nDefaultCombineCount = self:GetCombineDefaulCount(nStoneTemplateId)
  local nFindCombine = nDefaultCombineCount
  for i = 1, 6 do
    local nPreStoneId = self.tbPreStoneIndex[nFindStone]
    if not nPreStoneId then
      break
    end
    local nHasCur = pPlayer.GetItemCountInAllPos(nPreStoneId)
    local nSameNum = nHasCur / nFindCombine
    local tbBaseInfo = KItem.GetItemBaseProp(nFindStone)
    nHasCount = nHasCount + nSameNum
    nFindCombine = nDefaultCombineCount * nFindCombine
    nFindStone = nPreStoneId
  end
  return math.floor(nHasCount)
end
function StoneMgr:GetCombineStoneNeed(nStoneTemplateId, nNeedNum, pPlayer, bUseVirtulNum, nEquipPos)
  local tbVirtualStones = {}
  if bUseVirtulNum and nEquipPos then
    local tbInset = pPlayer.GetInsetInfo(nEquipPos)
    for k, v in pairs(tbInset) do
      if v == nStoneTemplateId then
        tbVirtualStones[nStoneTemplateId] = {k}
        break
      end
    end
    if next(tbVirtualStones) then
      local tbTotalStone, nTotalCost = self:_GetCombineStoneNeed(nStoneTemplateId, nNeedNum, pPlayer, tbVirtualStones)
      if tbTotalStone then
        return tbTotalStone, nTotalCost
      end
    end
    tbVirtualStones = {}
    for k, v in pairs(tbInset) do
      tbVirtualStones[v] = tbVirtualStones[v] or {}
      table.insert(tbVirtualStones[v], k)
    end
    return self:_GetCombineStoneNeed(nStoneTemplateId, nNeedNum, pPlayer, tbVirtualStones)
  end
  return self:_GetCombineStoneNeed(nStoneTemplateId, nNeedNum, pPlayer, {})
end
function StoneMgr:_GetCombineStoneNeed(nStoneTemplateId, nNeedNum, pPlayer, tbVirtualStones)
  local tbTotalStone = {}
  local nFindStone = nStoneTemplateId
  local nTotalCost = 0
  local nDefaultCombineCount = StoneMgr:GetCombineDefaulCount(nStoneTemplateId)
  for i = 1, 10 do
    local nHasCur = pPlayer.GetItemCountInAllPos(nFindStone)
    local nSameNum = math.min(nHasCur, nNeedNum)
    nNeedNum = nNeedNum - nSameNum
    if nSameNum > 0 then
      table.insert(tbTotalStone, {nFindStone, nSameNum})
    end
    local tbInsetedInfo = tbVirtualStones[nFindStone]
    if tbInsetedInfo then
      local nHasCur = #tbInsetedInfo
      local nSameNum = math.min(nHasCur, nNeedNum)
      nNeedNum = nNeedNum - nSameNum
      if nSameNum > 0 then
        for i2 = 1, nSameNum do
          table.insert(tbTotalStone, {
            nFindStone,
            1,
            table.remove(tbVirtualStones[nFindStone])
          })
        end
      end
    end
    if nNeedNum <= 0 and next(tbTotalStone) then
      local tbTotalStoneCopy = Lib:CopyTB(tbTotalStone)
      for j = 9, 1, -1 do
        if not next(tbTotalStoneCopy) then
          break
        end
        local nLastItemId, nLastItemNum = unpack(table.remove(tbTotalStoneCopy))
        local nNextItemId = self:GetNextLevelStone(nLastItemId)
        local tbNewLast = tbTotalStoneCopy[#tbTotalStoneCopy]
        local bMerNext = false
        if tbNewLast and tbNewLast[1] == nNextItemId then
          tbNewLast[2] = tbNewLast[2] + nLastItemNum / nDefaultCombineCount
        elseif tbNewLast and tbNewLast[1] == nLastItemId then
          tbNewLast[2] = tbNewLast[2] + nLastItemNum
          bMerNext = true
        elseif nNextItemId and nNextItemId ~= 0 then
          table.insert(tbTotalStoneCopy, {
            nNextItemId,
            nLastItemNum / nDefaultCombineCount
          })
        end
        local _, nCurCost = self:GetCombineCost(nLastItemId, nLastItemNum)
        if not nCurCost then
          break
        end
        if not bMerNext then
          nTotalCost = nTotalCost + nCurCost
          if nNextItemId and nNextItemId ~= 0 then
            local tbItembaseNext = KItem.GetItemBaseProp(nNextItemId)
            local tbItembaseFind = KItem.GetItemBaseProp(nStoneTemplateId)
            if tbItembaseNext.nLevel > tbItembaseFind.nLevel then
              break
            end
          end
        end
      end
      return tbTotalStone, math.floor(nTotalCost)
    end
    nFindStone = self.tbPreStoneIndex[nFindStone]
    if not nFindStone then
      return
    end
    nNeedNum = nNeedNum * nDefaultCombineCount
  end
end
function StoneMgr:CanCombine(pPlayer, nTemplateId, nCreateCount)
  if nCreateCount < 1 then
    return false, "数量错误"
  end
  local nNextTemplateId = self:GetNextLevelStone(nTemplateId)
  if not nNextTemplateId or nNextTemplateId == 0 then
    return false, "已达最高等级"
  end
  local nDefaultCombineCount = self.COMBINE_COUNT
  if StoneMgr:IsCrystal(nTemplateId) then
    nDefaultCombineCount = self.COMBINE_CRYSTAL_COUNT
    local szTimeFrame = StoneMgr.tbCrystalTimeFrame[nNextTemplateId]
    if szTimeFrame and GetTimeFrameState(szTimeFrame) ~= 1 then
      return false, "合成时间轴还未开放"
    end
  end
  local nCombineCount = nDefaultCombineCount * nCreateCount
  local nHasCount = pPlayer.GetItemCountInAllPos(nTemplateId)
  if nCombineCount > nHasCount then
    return false, "数量不足"
  end
  if pPlayer.GetMoney("Coin") < self:GetCombineCost(nTemplateId, nCombineCount) then
    return false, "银两不足"
  end
  return true
end
function StoneMgr:GetCombineDefaulCount(nTemplateId)
  return StoneMgr:IsCrystal(nTemplateId) and self.COMBINE_CRYSTAL_COUNT or self.COMBINE_COUNT
end
function StoneMgr:GetCombineCost(nStoneTemplateId, nCombineCount)
  local nDefaultCombineCount = self:GetCombineDefaulCount(nStoneTemplateId)
  nCombineCount = nCombineCount or nDefaultCombineCount
  local nNextTemplateId = StoneMgr:GetNextLevelStone(nStoneTemplateId)
  if not nNextTemplateId or nNextTemplateId == 0 then
    return 0
  end
  local tbBaseInfo = KItem.GetItemBaseProp(nNextTemplateId)
  local fResult = nCombineCount / nDefaultCombineCount * tbBaseInfo.nValue * 0.1 / 10
  return math.floor(fResult), fResult
end
function StoneMgr:GetRemoveInsetCost(nStoneTemplateId)
  local tbBaseInfo = KItem.GetItemBaseProp(nStoneTemplateId)
  local nVal = tbBaseInfo.nValue * 0.005
  return math.floor(nVal), nVal
end
function StoneMgr:GetInsetValue(pPlayer, nEquipPos)
  local nInsetValue = 0
  local tbInset = pPlayer.GetInsetInfo(nEquipPos)
  for _, nStoneTemplateId in pairs(tbInset) do
    if nStoneTemplateId and nStoneTemplateId ~= 0 then
      local tbBaseInfo = KItem.GetItemBaseProp(nStoneTemplateId)
      local nValue = tbBaseInfo.nValue
      nInsetValue = nInsetValue + nValue
    end
  end
  return nInsetValue
end
function StoneMgr:GetInsetValueKey(nEquipPos, nInsetPos)
  return 10 * nEquipPos + nInsetPos
end
function StoneMgr:GetInsetAsyncKey(nEquipPos, nInsetPos)
  if nInsetPos > 5 then
    return 50 + nEquipPos * 3 + (nInsetPos - 5)
  else
    return nEquipPos * 5 + nInsetPos
  end
end
function StoneMgr:UpdateInsetInfo(pPlayer, nEquipPos, bFullCheck)
  for nInsetPos = 1, self.INSET_COUNT_MAX do
    local nStoneId = pPlayer.GetUserValue(self.USER_VALUE_GROUP, self:GetInsetValueKey(nEquipPos, nInsetPos))
    if nStoneId > 0 then
      pPlayer.SetInsetInfo(nEquipPos, nInsetPos, nStoneId)
    elseif bFullCheck then
      pPlayer.RemoveInset(nEquipPos, nInsetPos)
    end
  end
end
function StoneMgr:GetInsetLevelCount(pPlayer)
  local tbInsetLv = {}
  local nMaxLevel = 0
  for nEquipPos = Item.EQUIPPOS_HEAD, Item.EQUIPPOS_PENDANT do
    for nInsetPos = 1, self.INSET_COUNT_MAX do
      local nStoneId = pPlayer.GetUserValue(self.USER_VALUE_GROUP, self:GetInsetValueKey(nEquipPos, nInsetPos))
      if nStoneId > 0 then
        local tbBaseInfo = KItem.GetItemBaseProp(nStoneId)
        tbInsetLv[tbBaseInfo.nLevel] = (tbInsetLv[tbBaseInfo.nLevel] or 0) + 1
        nMaxLevel = nMaxLevel > tbBaseInfo.nLevel and nMaxLevel or tbBaseInfo.nLevel
      end
    end
  end
  for i = nMaxLevel, 1, -1 do
    tbInsetLv[i] = (tbInsetLv[i] or 0) + (tbInsetLv[i + 1] or 0)
  end
  return tbInsetLv
end
function StoneMgr:UpdateInsetAttrib(pPlayer)
  pPlayer.nInsetExIdx = nil
  self.tbInsetLv = self:GetInsetLevelCount(pPlayer)
  local nAttribLv = 0
  for nIdx = #self.tbInsetExtern, 1, -1 do
    local tbAttribRequir = self.tbInsetExtern[nIdx]
    if self.tbInsetLv[tbAttribRequir.StoneLevel] and self.tbInsetLv[tbAttribRequir.StoneLevel] >= tbAttribRequir.NeedNum then
      nAttribLv = tbAttribRequir.AttribLevel
      pPlayer.nInsetExIdx = nIdx
      break
    end
  end
  if nAttribLv > 0 then
    pPlayer.ApplyInsetExAttrib(nAttribLv)
  else
    pPlayer.RemoveExternAttrib(self.INSET_ATTRIB_GROUP)
  end
  local nInsetAchiveLevel = 0
  local nRedbagInsertLevel = 0
  for nLevel, nNum in ipairs(self.tbInsetLv) do
    local nAchiveLimit = self.tbAcheiveNeedInsetNum[nLevel]
    if nAchiveLimit and nNum >= nAchiveLimit then
      nInsetAchiveLevel = nLevel
    end
    if nNum >= self.nRedbagNeedInsertNum then
      nRedbagInsertLevel = nLevel
    end
  end
  return nInsetAchiveLevel, nRedbagInsertLevel
end
function StoneMgr:GetInsetExAttrib(nIndex)
  local tbSetting = self.tbInsetExtern[nIndex]
  if not tbSetting then
    return
  end
  if not tbSetting.tbAttrib then
    tbSetting.tbAttrib = KItem.GetInsetExAttrib(tbSetting.AttribLevel)
  end
  return tbSetting
end
