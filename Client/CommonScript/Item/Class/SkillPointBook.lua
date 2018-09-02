local tbItem = Item:GetClass("SkillPointBook")
tbItem.nSavePointGroup = 54
tbItem.nSaveMaxCount = 10
tbItem.tbBookInfo = {
  [1430] = {
    nMaxCount = 5,
    nAddPoint = 1,
    nSaveID = 1
  },
  [1431] = {
    nMaxCount = 5,
    nAddPoint = 1,
    nSaveID = 2
  },
  [1432] = {
    nMaxCount = 5,
    nAddPoint = 1,
    nSaveID = 3
  },
  [1454] = {
    nMaxCount = 1,
    nAddPoint = 3,
    nSaveID = 4
  },
  [2591] = {
    nMaxCount = 20,
    nAddPoint = 1,
    nSaveID = 5
  },
  [2876] = {
    nMaxCount = 20,
    nAddPoint = 1,
    nSaveID = 6
  }
}
function tbItem:CheckUseSkillPoint(pPlayer, pItem)
  local nItemTID = pItem.dwTemplateId
  local tbInfo = self.tbBookInfo[nItemTID]
  if not tbInfo then
    return false, "不能使用当前的道具"
  end
  if tbInfo.nSaveID <= 0 or tbInfo.nSaveID > self.nSaveMaxCount then
    return false, "不能使用当前的道具!"
  end
  local nCount = pPlayer.GetUserValue(self.nSavePointGroup, tbInfo.nSaveID)
  if nCount >= tbInfo.nMaxCount then
    return false, string.format("该道具最多使用%s个。", tbInfo.nMaxCount)
  end
  return true, "", tbInfo
end
function tbItem:OnUse(it)
  local bRet, szMsg, tbInfo = self:CheckUseSkillPoint(me, it)
  if not bRet then
    me.CenterMsg(szMsg)
    return
  end
  local nCount = me.GetUserValue(self.nSavePointGroup, tbInfo.nSaveID)
  nCount = nCount + 1
  me.SetUserValue(self.nSavePointGroup, tbInfo.nSaveID, nCount)
  me.CenterMsg(string.format("你获得了%s点技能点", tbInfo.nAddPoint))
  me.CallClientScript("Player:ServerSyncData", "ChangeSkillPoint")
  return 1
end
function tbItem:GetIntrol(dwTemplateId)
  local tbInfo = KItem.GetItemBaseProp(dwTemplateId)
  if not tbInfo then
    return
  end
  local tbLimitInfo = self.tbBookInfo[dwTemplateId]
  if not tbLimitInfo or tbLimitInfo.nSaveID <= 0 then
    return
  end
  local nCount = me.GetUserValue(self.nSavePointGroup, tbLimitInfo.nSaveID)
  return string.format("%s\n使用数量：%d/%d", tbInfo.szIntro, nCount, tbLimitInfo.nMaxCount)
end
