local tbItem = Item:GetClass("AddPlayerAttributeItem")
tbItem.nSaveGroup    = 63
tbItem.nSaveMaxCount = 10

tbItem.tbItemInfo =
{
    --- 道具的ID  最大使用次数  添加的属性({属性ID，添加数量})  存储的ID
    [2877] = {nMaxCount = 20000, tbAddPoint = {{1, 20}, {2, 1}, {3, 3}, {4, 50}}, nSaveID = 1}, 
    [3238] = {nMaxCount = 20000, tbAddPoint = {{1, 10}, {2, 1}, {3, 1}, {4, 10}}, nSaveID = 2},
    [3714] = {nMaxCount = 20000, tbAddPoint = {{1, 10}, {2, 1}, {3, 4}, {4, 10}}, nSaveID = 3},
    [3715] = {nMaxCount = 20000, tbAddPoint = {{1, 10}, {2, 1}, {3, 4}, {4, 10}}, nSaveID = 4},
    [3716] = {nMaxCount = 20000, tbAddPoint = {{1, 10}, {2, 1}, {3, 4}, {4, 10}}, nSaveID = 5},
	[2591] = {nMaxCount = 10, tbAddPoint = {{1, 0}, {2, 0}, {3, 0}, {4, 0}}, nSaveID = 6},
	[2871] = {nMaxCount = 10, tbAddPoint = {{1, 0}, {2, 0}, {3, 0}, {4, 0}}, nSaveID = 7},
	
}

tbItem.tbFunc4Type = {
    [1] = "AddStrength",
    [2] = "AddDexterity",
    [3] = "AddVitality",
    [4] = "AddEnergy",
}

function tbItem:CheckUse(pPlayer, pItem)
    local nItemTID = pItem.dwTemplateId
    local tbInfo = self.tbItemInfo[nItemTID]
    if not tbInfo then
        return false, "不能使用當前的道具。"
    end

    if tbInfo.nSaveID <= 0 or tbInfo.nSaveID > self.nSaveMaxCount then
        return false, "不能使用目前的道具!"
    end

    local nCount = pPlayer.GetUserValue(self.nSaveGroup, tbInfo.nSaveID)
    if nCount >= tbInfo.nMaxCount then
        return false, string.format("該道具最多使用%s個。", tbInfo.nMaxCount)
    end

    return true, "", tbInfo
end

function tbItem:OnUse(it)
    local bRet, szMsg, tbInfo = self:CheckUse(me, it)
    if not bRet then
        me.CenterMsg(szMsg)
        return
    end

    local nCount = me.GetUserValue(self.nSaveGroup, tbInfo.nSaveID)
    nCount = nCount + 1
    me.SetUserValue(self.nSaveGroup, tbInfo.nSaveID, nCount)
    for _, tbAttr in ipairs(tbInfo.tbAddPoint) do
        local szFunc = self.tbFunc4Type[tbAttr[1]]
        PlayerAttribute[szFunc](PlayerAttribute, me, tbAttr[2])
    end
    me.CenterMsg(string.format("你成功使用了%s", it.szName))
    return 1;
end

function tbItem:GetIntrol(dwTemplateId)
    local tbInfo = KItem.GetItemBaseProp(dwTemplateId)
    if not tbInfo then
        return
    end

    local tbLimitInfo = self.tbItemInfo[dwTemplateId]
    if not tbLimitInfo or tbLimitInfo.nSaveID <= 0 then
        return
    end

    local nCount = me.GetUserValue(self.nSaveGroup, tbLimitInfo.nSaveID)
    return string.format("%s\n使用數量：%d/%d", tbInfo.szIntro, nCount, tbLimitInfo.nMaxCount)
end