Require("CommonScript/Item/Define.lua")
Item.tbItemColor = LoadTabFile("Setting/Item/ItemColor.tab", "dssssds", "Quality", {
  "Quality",
  "Color",
  "FrameColor",
  "Animation",
  "AnimationAtlas",
  "EffectId",
  "TxtColor"
})
Item.MAX_STAR_LEVEL = 20
Item.emITEMPOS_BAG = 200
if not Item.tbClassBase then
  Item.tbClassBase = {}
end
if not Item.tbClass then
  Item.tbClass = {
    default = Item.tbClassBase,
    [""] = Item.tbClassBase
  }
end
function Item:Init()
  KItem.RegisterPos2Part(Item.EQUIPPOS_WEAPON, 1, 1)
  KItem.RegisterPos2Part(Item.EQUIPPOS_BODY, 0, 1)
  KItem.RegisterPos2Part(Item.EQUIPPOS_HORSE, 3, 1)
  KItem.RegisterPos2Part(Item.EQUIPPOS_WAIYI, 0, 2)
  KItem.RegisterPos2Part(Item.EQUIPPOS_WAI_WEAPON, 1, 2)
  KItem.RegisterPos2Part(Item.EQUIPPOS_WAI_HORSE, 3, 2)
  self.tbForbidList = {}
  self.tbUnForbidList = {}
  self:LoadItemIcon()
  self:LoadStarLevel()
  Item:GetClass("RandomItem"):LoadItemList()
  Item:GetClass("RandomItemByLevel"):LoadSetting()
  if not MODULE_GAMESERVER then
    self:LoadEquipStarColor()
  end
  self:LoadUnidentifyItem()
end
function Item:LoadUnidentifyItem()
  local tbFile = LoadTabFile("Setting/Item/Other/UnidentifyItem.tab", "dd", nil, {"ExtParam1", "TemplateId"})
  local tbUnidentifyItemList = {}
  local tbUnidentifyToId = {}
  for i, v in ipairs(tbFile) do
    tbUnidentifyItemList[v.ExtParam1] = v.TemplateId
    tbUnidentifyToId[v.TemplateId] = v.ExtParam1
  end
  self.tbUnidentifyItemList = tbUnidentifyItemList
  self.tbUnidentifyToId = tbUnidentifyToId
end
function Item:GetIdAfterIdentify(nUnidentifyId)
  return self.tbUnidentifyToId[nUnidentifyId]
end
function Item:LoadItemIcon()
  self.tbItemIcon = LoadTabFile("Setting/Item/ItemIcon.tab", "dssss", "IconId", {
    "IconId",
    "Atlas",
    "Sprite",
    "ExtAtlas",
    "ExtSprite"
  })
  if not self.tbItemIcon then
    Log("Load Item Icon Failed!!!!")
    return
  end
  self.tbItemDisIcon = LoadTabFile("Setting/Item/ItemIconDisable.tab", "dd", "IconId", {
    "IconId",
    "IconDisableId"
  }) or {}
end
function Item:GetType(nItemId)
  local tbBase = KItem.GetItemBaseProp(nItemId)
  return tbBase and tbBase.nItemType or 0
end
function Item:GetLevel(nItemId)
  local tbBase = KItem.GetItemBaseProp(nItemId)
  return tbBase and tbBase.nLevel or 0
end
function Item:GetQuality(nItemId)
  local tbBase = KItem.GetItemBaseProp(nItemId)
  return tbBase and tbBase.nQuality or 0
end
function Item:GetIcon(nIconId, bDisable)
  nIconId = bDisable and (self.tbItemDisIcon[nIconId] or {}).IconDisableId or nIconId
  local tbIcon = self.tbItemIcon[nIconId]
  return tbIcon.Atlas, tbIcon.Sprite, tbIcon.ExtAtlas, tbIcon.ExtSprite
end
function Item:LoadStarLevel()
  local szSetting = "Setting/Item/StarLevel.tab"
  self.tbStarLevelValue = {}
  local tbFile = Lib:LoadTabFile(szSetting, {ItemType = 1})
  if not tbFile then
    print("load " .. szSetting .. " failed!")
    return
  end
  for _, tbRow in pairs(tbFile) do
    if tbRow.ItemType then
      self.tbStarLevelValue[tbRow.ItemType] = {}
      for i = 1, self.MAX_STAR_LEVEL do
        self.tbStarLevelValue[tbRow.ItemType][i] = tonumber(tbRow["StartLv" .. i]) or 0
      end
    end
  end
end
function Item:LoadEquipStarColor()
  local tbEquipStarColor = {}
  local file = LoadTabFile("Setting/Item/EquipStarColor.tab", "dddddddd", nil, {
    "StarLevel",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7"
  })
  for i, v in ipairs(file) do
    tbEquipStarColor[v.StarLevel] = v
  end
  for i = file[1].StarLevel, self.MAX_STAR_LEVEL do
    if not tbEquipStarColor[i] then
      tbEquipStarColor[i] = tbEquipStarColor[i - 1]
    end
  end
  self.tbEquipStarColor = tbEquipStarColor
end
if not MODULE_GAMESERVER then
  function Item:GetEqipShowColor(pItem, bEquiped, pPlayer)
    local szClass = pItem.szClass
    if szClass == "equip" then
      local tbRandomAttrib, nMaxQuality = Item:GetClass("equip"):GetRandomAttrib(pItem, pPlayer)
      local tbBaseAttrib, nBaseQuality = Item:GetClass("equip"):GetBaseAttrib(pItem.dwTemplateId)
      nMaxQuality = math.max(nMaxQuality, nBaseQuality)
      local nValue = pItem.nValue
      local nStarLevel = Item:GetStarLevel(pItem.nItemType, nValue)
      if self.tbEquipStarColor[nStarLevel] then
        return self.tbEquipStarColor[nStarLevel][tostring(nMaxQuality)]
      end
      return nMaxQuality
    elseif szClass == "ZhenYuan" and pItem.GetIntValue(Item.tbZhenYuan.nItemKeySKillInfo) ~= 0 then
      local nQuality = pItem.nQuality
      return Item.tbZhenYuan.tbShowColor[nQuality]
    end
  end
end
function Item:GetStarLevel(nItemType, nValue)
  local nLevel = 0
  if not self.tbStarLevelValue then
    return 0
  end
  for i, nStar in ipairs(self.tbStarLevelValue[nItemType] or {}) do
    if nStar <= nValue then
      nLevel = i
    else
      break
    end
  end
  return nLevel
end
function Item:GetQualityColor(nQuality)
  local tbColor = self.tbItemColor[nQuality] or {}
  if tbColor then
    return tbColor.Color, tbColor.FrameColor, tbColor.Animation, tbColor.AnimationAtlas, tbColor.TxtColor
  end
end
function Item:GetQualityEffect(nQuality)
  local tbColor = self.tbItemColor[nQuality]
  if tbColor then
    return tbColor.EffectId
  end
end
function Item:GetClass(szClassName, bNotCreate)
  local tbClass = self.tbClass[szClassName]
  if not tbClass and bNotCreate ~= 1 then
    tbClass = Lib:NewClass(self.tbClassBase)
    self.tbClass[szClassName] = tbClass
  end
  return tbClass
end
function Item:NewClass(szClassName, szParent)
  if self.tbClass[szClassName] then
    print("[ITEM] class " .. tostring(szClassName) .. " already exist, please check out")
    return
  end
  local tbParent = self.tbClass[szParent]
  if not tbParent then
    print("[ITEM] class" .. tostring(szParent) .. " already exist, please check out")
    return
  end
  local tbClass = Lib:NewClass(tbParent)
  self.tbClass[szClassName] = tbClass
  return tbClass
end
function Item:OnCreate(szClassName, ...)
  local tbClass = self.tbClass[szClassName] or self.tbClass.default
  return tbClass:OnCreate(...)
end
function Item:OnItemInit(szClassName, ...)
  local tbClass = self.tbClass[szClassName] or self.tbClass.default
  return tbClass:OnInit(...)
end
function Item:CheckCanSell(pItem)
  local tbClass = self.tbClass[pItem.szClass]
  if not tbClass or not tbClass.CheckCanSell then
    return true
  end
  return tbClass:CheckCanSell(pItem)
end
function Item:IsUsableItem(pPlayer, dwTemplateId)
  local tbItemBae = KItem.GetItemBaseProp(dwTemplateId)
  if not tbItemBae then
    return
  end
  local szClassName = tbItemBae.szClass
  local tbClass = self.tbClass[szClassName]
  if not tbClass or not tbClass.IsUsableItem then
    return true
  end
  return tbClass:IsUsableItem(pPlayer, dwTemplateId)
end
function Item:CheckUsable(pItem, szClassName)
  local tbClass = self.tbClass[szClassName]
  tbClass = tbClass or self.tbClass.default
  local nTemplateId = pItem.dwTemplateId
  if self.tbForbidList[szClassName] and not self.tbUnForbidList[szClassName] then
    return 0, "很遗憾，系统检测到该道具异常，暂时无法使用。"
  end
  if pItem.nUseLevel > me.nLevel then
    return 0, string.format("%d级之后可使用", pItem.nUseLevel)
  end
  return tbClass:CheckUsable(pItem)
end
function Item:NotifyItem(pPlayer, nId, tbMsg)
  local pItem = pPlayer.GetItemInBag(nId)
  if not pItem then
    print("Notify Unexsit Item " .. nId)
    return
  end
  local szClassName = pItem.szClass
  local tbClass = self.tbClass[szClassName]
  if tbClass and tbClass.OnNotifyItem then
    tbClass:OnNotifyItem(pPlayer, pItem, tbMsg)
  end
end
function Item:UseItem(nId)
  local pItem = me.GetItemInBag(nId)
  if not pItem then
    print("Unexsit Item " .. nId)
    return
  end
  local szClassName = pItem.szClass
  local dwTemplateId = pItem.dwTemplateId
  local bRet, nOpenRetCode = pcall(self.OnUse, self, pItem)
  if not bRet then
    self.tbForbidList[szClassName] = true
    Log(nOpenRetCode)
    Log(debug.traceback())
  end
  Log(string.format("Item:OnUse dwTemplateId:%d, bRet:%s, nOpenRetCode:%s, player:%d", dwTemplateId, bRet and "ok" or "fail", type(nOpenRetCode) == "number" and nOpenRetCode or "nil", me.dwID))
end
function Item:UseAllItem(nId)
  local pItem = me.GetItemInBag(nId)
  if not pItem then
    print("Unexsit Item " .. nId)
    return
  end
  local szClassName = pItem.szClass
  local dwTemplateId = pItem.dwTemplateId
  local bRet, nOpenRetCode = pcall(self.OnUseAll, self, pItem)
  if not bRet then
    self.tbForbidList[szClassName] = true
    Log(nOpenRetCode)
    Log(debug.traceback())
  end
  Log(string.format("Item:OnUseAll dwTemplateId:%d, bRet:%s, nOpenRetCode:%s, player:%d", dwTemplateId, bRet and "ok" or "fail", type(nOpenRetCode) == "number" and nOpenRetCode or "nil", me.dwID))
end
function Item:OnUse(pItem)
  local szClassName = pItem.szClass
  local nRet, szMsg = self:CheckUsable(pItem, szClassName)
  if nRet ~= 1 then
    if szMsg then
      me.CenterMsg(szMsg)
    end
    return 0
  end
  local tbClass = self.tbClass[szClassName]
  local nRetCode = 0
  if tbClass and tbClass.OnUse then
    nRetCode = tbClass:OnUse(pItem)
    if nRetCode and nRetCode > 0 then
      assert(Item:Consume(pItem, nRetCode) == 1)
    end
  end
  return nRetCode
end
function Item:Consume(pItem, nCount)
  local nCurCount = pItem.nCount
  if nCount > 0 and nCount < nCurCount then
    pItem.SetCount(nCurCount - nCount, Env.LogWay_UseItem)
    Log(string.format("Item:Consume SetCount dwTemplateId:%d, nCurCount:%d, nCount:%d, player:%d", pItem.dwTemplateId, nCurCount, nCount, me.dwID))
  elseif nCurCount == nCount then
    pItem.Delete(Env.LogWay_UseItem)
    Log(string.format("Item:Consume Delete dwTemplateId:%d, player:%d", pItem.dwTemplateId, me.dwID))
  else
    return 0
  end
  return 1
end
function Item:IsMainEquipPos(nEquipPos)
  if nEquipPos >= 0 and nEquipPos < Item.EQUIPPOS_MAIN_NUM then
    return true
  end
  return false
end
local tbFubActiveReqDesc = {
  [Item.emEquipActiveReq_Ride] = function(szMagicName, tbMagic)
    return "上马激活"
  end
}
function Item:GetActiveReqDesc(nActiveReq)
  local fnMsg = tbFubActiveReqDesc[nActiveReq]
  if not fnMsg then
    return
  end
  return fnMsg()
end
function Item:OnUseAll(pItem)
  local szClassName = pItem.szClass
  local nRet, szMsg = self:CheckUsable(pItem, szClassName)
  if nRet ~= 1 then
    if szMsg then
      me.CenterMsg(szMsg)
    end
    return 0
  end
  local tbClass = self.tbClass[szClassName]
  local nRetCode = 0
  if tbClass and tbClass.OnUseAll then
    nRetCode = tbClass:OnUseAll(pItem)
    if nRetCode and nRetCode > 0 then
      assert(Item:Consume(pItem, nRetCode) == 1)
    end
  end
  return nRetCode
end
function Item:UseEquip(nId, bSlient, nEquipPos)
  local pEquip = me.GetItemInBag(nId)
  if not pEquip then
    print("Unexsit Equip " .. nId)
    return
  end
  if pEquip.nUseLevel > me.nLevel then
    return
  end
  local nEquipType = pEquip.nItemType
  if not Lib:IsEmptyStr(pEquip.szClass) then
    local tbEquipClass = Item:GetClass(pEquip.szClass)
    if tbEquipClass.CheckUseEquip then
      local bRet, szMsg = tbEquipClass:CheckUseEquip(me, pEquip, nEquipPos)
      if not bRet then
        me.CenterMsg(szMsg)
        return
      end
    else
      nEquipPos = -1
    end
  else
    nEquipPos = -1
  end
  RecordStone:ClearEquipRecord(me, pEquip.nEquipPos)
  self:ClearEquipString(me, pEquip.nEquipPos)
  local nResult = me.UseEquip(nId, nEquipPos or -1)
  if nResult == 1 then
    nEquipPos = pEquip.nEquipPos
    self.GoldEquip:UpdateSuitAttri(me)
    self.GoldEquip:UpdateTrainAttri(me, nEquipPos)
    RecordStone:UpdateCurRecoreStoneToEquip(me, nEquipPos)
    self:UpdateEquipPosString(me, nEquipPos)
    FightPower:ChangeFightPower(FightPower:GetFightPowerTypeByEquipPos(nEquipPos), me, bSlient)
    if nEquipPos == Item.EQUIPPOS_HORSE then
      local szEquipName = KItem.GetItemShowInfo(pEquip.dwTemplateId, me.nFaction)
      me.CenterMsg(string.format("%s上阵成功", szEquipName))
    end
    TeacherStudent:OnChangeEquip(me)
  end
  Log(string.format("Item:UseEquip pPlayer:%d, dwTemplateId:%d, nId:%d, nPos:%d", me.dwID, pEquip.dwTemplateId, nId, pEquip.nEquipPos))
end
function Item:UnuseEquip(nPos)
  RecordStone:ClearEquipRecord(me, nPos)
  self:ClearEquipString(me, nPos)
  me.UnuseEquip(nPos)
  self.GoldEquip:UpdateSuitAttri(me)
  self.GoldEquip:UpdateTrainAttri(me, nPos)
  FightPower:ChangeFightPower(FightPower:GetFightPowerTypeByEquipPos(nPos), me)
  Log(string.format("Item:UnuseEquip pPlayer:%d, nPos:%d", me.dwID, nPos))
end
function Item:UseChooseItem(nId, tbChoose)
  local pItem = me.GetItemInBag(nId)
  if not pItem then
    print("UseChooseItem Error Unexsit Item " .. nId)
    return
  end
  local szClassName = pItem.szClass
  local tbClass = self.tbClass[szClassName]
  if tbClass and tbClass.OnSelectItem then
    local nRetCode = tbClass:OnSelectItem(pItem, tbChoose)
    if nRetCode and nRetCode > 0 then
      local nCurCount = pItem.nCount
      if nRetCode <= nCurCount then
        assert(self:Consume(pItem, nRetCode) == 1)
      else
        assert(me.ConsumeItemInAllPos(pItem.dwTemplateId, nRetCode, Env.LogWay_UseItem) == nRetCode)
      end
    end
  end
end
function Item:ClientUseItem(nItemId)
  if not nItemId then
    return
  end
  local pItem = me.GetItemInBag(nItemId)
  if not pItem then
    return
  end
  local szClassName = pItem.szClass
  local tbClass = self.tbClass[szClassName]
  if tbClass and tbClass.OnClientUse then
    local nRetCode = tbClass:OnClientUse(pItem)
    if nRetCode and nRetCode > 0 then
      return
    end
  end
  RemoteServer.UseItem(nItemId)
end
function Item:NotifyTimeOut(dwTemplateId, nCount)
  local szItemName = KItem.GetItemShowInfo(dwTemplateId, me.nFaction)
  local szMsg = string.format("您的物品%s已过期！", szItemName)
  me.CenterMsg(szMsg)
  me.Msg(szMsg)
  local tbBaseProp = KItem.GetItemBaseProp(dwTemplateId)
  if tbBaseProp and self.tbClass[tbBaseProp.szClass] and self.tbClass[tbBaseProp.szClass].OnTimeOut then
    self.tbClass[tbBaseProp.szClass]:OnTimeOut(dwTemplateId, nCount)
  end
end
function Item:GetItemTimeOut(pItem)
  if pItem and pItem.GetIntValue(-9996) > 0 then
    return os.date("%Y年%m月%d日 %H:%M:%S", pItem.GetIntValue(-9996))
  end
end
function Item:GoAndUseItem(nMapId, nX, nY, nItemId)
  if MODULE_GAMESERVER then
    return
  end
  Ui:CloseWindow("ItemBox")
  Ui:CloseWindow("ItemTips")
  local pItem = KItem.GetItemObj(nItemId)
  if not pItem then
    return
  end
  local function fnOnArive()
    RemoteServer.UseItem(nItemId)
  end
  AutoPath:GotoAndCall(nMapId, nX, nY, fnOnArive)
end
function Item:GetExtBagCount(pPlayer)
  if MODULE_GAMESERVER and pPlayer.nTempExtBagCount then
    return pPlayer.nTempExtBagCount
  end
  local nExtBagCount = 0
  for _, tbInfo in pairs(self.tbExtBagSetting) do
    local nSaveId, nBagCount = unpack(tbInfo)
    local nUsedCount = self:GetExtBagValue(pPlayer, nSaveId)
    nExtBagCount = nExtBagCount + nUsedCount * nBagCount
  end
  pPlayer.nTempExtBagCount = nExtBagCount
  return nExtBagCount
end
function Item:GetExtBagUserValueId(nId)
  local nUserId = math.floor((nId - 1) / 4) + 1
  local nByteIndex = nId % 4 == 0 and 4 or nId % 4
  return nUserId, nByteIndex
end
function Item:GetExtBagValue(pPlayer, nId)
  local nUserId, nByteIndex = self:GetExtBagUserValueId(nId)
  local nUserValue = pPlayer.GetUserValue(self.EXT_USER_VALUE_GROUP, nUserId)
  return KLib.GetByte(nUserValue, nByteIndex)
end
function Item:SetExtBagValue(pPlayer, nId, nValue)
  if nValue > 127 then
    return false
  end
  local nUserId, nByteIndex = self:GetExtBagUserValueId(nId)
  local nUserValue = pPlayer.GetUserValue(self.EXT_USER_VALUE_GROUP, nUserId)
  local nNewValue = KLib.SetByte(nUserValue, nByteIndex, nValue)
  pPlayer.SetUserValue(self.EXT_USER_VALUE_GROUP, nUserId, nNewValue)
  pPlayer.nTempExtBagCount = nil
  return true
end
function Item:SetEquipPosString(pPlayer, nPos, szString)
  pPlayer.tbEquipString = pPlayer.tbEquipString or {}
  pPlayer.tbEquipString[nPos] = szString
  local pEquip = pPlayer.GetEquipByPos(nPos)
  if not pEquip then
    return
  end
  pEquip.SetStrValue(1, szString)
end
function Item:UpdateEquipPosString(pPlayer, nPos)
  if not pPlayer.tbEquipString then
    return
  end
  if not pPlayer.tbEquipString[nPos] or pPlayer.tbEquipString[nPos] == "" then
    return
  end
  local pEquip = pPlayer.GetEquipByPos(nPos)
  if not pEquip then
    return
  end
  pEquip.SetStrValue(1, pPlayer.tbEquipString[nPos])
end
function Item:ClearEquipString(pPlayer, nPos)
  if not pPlayer.tbEquipString then
    return
  end
  if not pPlayer.tbEquipString[nPos] or pPlayer.tbEquipString[nPos] == "" then
    return
  end
  local pEquip = pPlayer.GetEquipByPos(nPos)
  if not pEquip then
    return
  end
  pEquip.SetStrValue(1, "")
end
