RecordStone.MAX_RECORD_STONE_NUM = 3
RecordStone.nCostValuePercent = 0.01
RecordStone.SAVE_GROUP = 124
function RecordStone:Init()
  self.tbRecordEquipInfo = LoadTabFile("Setting/Item/RecordStone/RecordEquip.tab", "dd", "ItemId", {"ItemId", "HoleCount"})
  self.tbStoneInfo = LoadTabFile("Setting/Item/RecordStone/RecordType.tab", "dssdssddddddd", "StoneId", {
    "StoneId",
    "Type",
    "Name",
    "SaveKey",
    "Sprite",
    "Atlas",
    "LevelMin1",
    "LevelMin2",
    "LevelMin3",
    "LevelMin4",
    "LevelMin5",
    "LevelMin6",
    "LevelMin7"
  })
  self.tbStoneInfoType = {}
  self.tbStoneInfoSaveKey = {}
  for StoneId, v in pairs(self.tbStoneInfo) do
    self.tbStoneInfoType[v.Type] = StoneId
    self.tbStoneInfoSaveKey[v.SaveKey] = StoneId
  end
  if MODULE_GAMESERVER then
    assert(RecordStone.MAX_RECORD_STONE_NUM <= 10, RecordStone.MAX_RECORD_STONE_NUM)
    local tbUsedSaveKey = {}
    for StoneId, v in pairs(self.tbStoneInfo) do
      assert(v.LevelMin1 == 0, StoneId)
      for i = 2, 7 do
        assert(v["LevelMin" .. i] >= v["LevelMin" .. i - 1], StoneId .. "," .. i)
      end
      assert(not tbUsedSaveKey[v.SaveKey], StoneId)
      assert(v.SaveKey >= 11 and v.SaveKey <= 50, StoneId)
    end
    for ItemId, v in pairs(self.tbRecordEquipInfo) do
      assert(v.HoleCount <= self.MAX_RECORD_STONE_NUM, ItemId)
    end
  end
end
function RecordStone:GetCurStoneList(pPlayer)
  local tbStoneIds = {}
  for i = 1, self.MAX_RECORD_STONE_NUM do
    local nStoneId = pPlayer.GetUserValue(self.SAVE_GROUP, i)
    if nStoneId == 0 then
      break
    else
      table.insert(tbStoneIds, nStoneId)
    end
  end
  return tbStoneIds
end
function RecordStone:GetCurStoneIndex(pPlayer, nTarStoneId)
  for i = 1, self.MAX_RECORD_STONE_NUM do
    local nStoneId = pPlayer.GetUserValue(self.SAVE_GROUP, i)
    if nStoneId == 0 then
      return
    elseif nStoneId == nTarStoneId then
      return i
    end
  end
end
function RecordStone:CanSetCurRecordStone(pPlayer, nStoneId, nInsetPos)
  local pEquip = pPlayer.GetEquipByPos(Item.EQUIPPOS_WEAPON)
  if not pEquip then
    return false, "没有装备武器"
  end
  local nHoleNum = self:GetEquipCanInsetNum(pEquip.dwTemplateId)
  if nHoleNum <= 0 then
    return false, "只可铭刻于6阶及以上稀有及黄金武器上"
  end
  local tbStoneInfo = self:GetStoneInfo(nStoneId)
  if not tbStoneInfo then
    return false, "无效的铭刻石"
  end
  local tbStoneList = self:GetCurStoneList(pPlayer)
  nInsetPos = nInsetPos or #tbStoneList + 1
  if nHoleNum < nInsetPos then
    return false, string.format("最多使用%d个铭刻石", nHoleNum)
  end
  for i, v in ipairs(tbStoneList) do
    if v == nStoneId then
      return false, "已有同样的铭刻石"
    end
  end
  local nCost = self:GetInsetCost(nStoneId)
  if nCost > pPlayer.GetMoney("Coin") then
    return false, "消耗银两不足"
  end
  assert(#tbStoneList < 10)
  return pEquip, tbStoneInfo, tbStoneList, nCost
end
function RecordStone:GetRecordCountByStoneId(pPlayer, nStoneId)
  local tbStoneInfo = self:GetStoneInfo(nStoneId)
  if not tbStoneInfo then
    return
  end
  return pPlayer.GetUserValue(self.SAVE_GROUP, tbStoneInfo.SaveKey)
end
function RecordStone:GetEquipCanInsetNum(nItemId)
  local tbInfo = self.tbRecordEquipInfo[nItemId]
  if tbInfo then
    return tbInfo.HoleCount
  end
  return 0
end
function RecordStone:_GetRecordStoneShowInfo(dwEquipTemplateId, tbIntVals)
  local tbEquipInfo = self.tbRecordEquipInfo[dwEquipTemplateId]
  if not tbEquipInfo then
    return
  end
  local tbShowList = {}
  for i = 1, tbEquipInfo.HoleCount do
    local nVal = tbIntVals[i + Item.EQUIP_RECORD_STONE_VALUE_BEGIN - 1]
    if not nVal or nVal == 0 then
      break
    else
      local nCurNum = math.floor(nVal / 100)
      local SaveKey = nVal - 100 * nCurNum
      local nStoneId = self.tbStoneInfoSaveKey[SaveKey]
      local tbStoneInfo = self:GetStoneInfo(nStoneId)
      local nQuality = self:GetRecordNumQuality(tbStoneInfo, nCurNum)
      table.insert(tbShowList, {
        string.format("%s：%d", tbStoneInfo.Name, nCurNum),
        nQuality,
        tbStoneInfo.Sprite,
        tbStoneInfo.Atlas
      })
    end
  end
  return tbShowList
end
function RecordStone:GetRecordStoneShowInfo(pEquip)
  local tbIntVals = {}
  for i = Item.EQUIP_RECORD_STONE_VALUE_BEGIN, Item.EQUIP_RECORD_STONE_VALUE_BEGIN + self.MAX_RECORD_STONE_NUM - 1 do
    local nVal = pEquip.GetIntValue(i)
    if nVal == 0 then
      break
    else
      tbIntVals[i] = nVal
    end
  end
  return self:_GetRecordStoneShowInfo(pEquip.dwTemplateId, tbIntVals)
end
function RecordStone:GetRecordNumQuality(tbStoneInfo, nCurNum)
  local nQuality = 1
  for i = 1, 7 do
    if nCurNum < tbStoneInfo["LevelMin" .. i] then
      return nQuality
    end
    nQuality = i
  end
  return nQuality
end
function RecordStone:GetStoneInfo(nStoneId)
  return self.tbStoneInfo[nStoneId]
end
function RecordStone:GetStoneIdByType(szType)
  return self.tbStoneInfoType[szType]
end
function RecordStone:GetInsetCost(nStoneId)
  local tbBaseInfo = KItem.GetItemBaseProp(nStoneId)
  return math.floor(tbBaseInfo.nValue * self.nCostValuePercent)
end
if not MODULE_GAMESERVER then
  function RecordStone:OnClientSuccess()
    me.CenterMsg("使用铭刻石成功")
    Ui:CloseWindow("InscriptionChangePanel")
  end
  function RecordStone:DoRequestRecord(nTemplateId, nInsetPos)
    local bRet, szMsg = RecordStone:CanSetCurRecordStone(me, nTemplateId, nInsetPos)
    if not bRet then
      me.CenterMsg(szMsg)
      return
    end
    local function fnOk()
      RemoteServer.RequestRecordStoneInset(nTemplateId, nInsetPos)
    end
    local tbStoneList = RecordStone:GetCurStoneList(me)
    local szMsg
    if #tbStoneList == RecordStone.MAX_RECORD_STONE_NUM then
      szMsg = string.format("确认花费 [FFFE0D]%d银两[-] 替换已有铭刻吗？", RecordStone:GetInsetCost(nTemplateId))
    else
      szMsg = string.format("确认花费 [FFFE0D]%d银两[-] 进行铭刻吗？", RecordStone:GetInsetCost(nTemplateId))
    end
    Ui:OpenWindow("MessageBox", szMsg, {
      {fnOk},
      {}
    })
  end
end
RecordStone:Init()
