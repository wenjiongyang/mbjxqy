
local tbItem = Item:GetClass("SkillMaxLevel");
tbItem.nSaveLevelGroup = 134;
tbItem.nSaveLevelMaxCount = 10;


--------策划填写------------
tbItem.tbItemLimitInfo =
{
--- 道具的ID  最大使用次数  添加的技能点  存储的ID改变通知程序
    [4579] = {nMaxCount = 5, nAdd = 1, nSaveID = 1, szSkill = "Skill2", tbSell = {"Coin", 5000}};
    [4580] = {nMaxCount = 5, nAdd = 1, nSaveID = 2, szSkill = "Skill1", tbSell = {"Coin", 5000}};
    [4581] = {nMaxCount = 5, nAdd = 1, nSaveID = 3, szSkill = "Skill3", tbSell = {"Coin", 5000}};
    [4582] = {nMaxCount = 5, nAdd = 1, nSaveID = 4, szSkill = "Skill4", tbSell = {"Coin", 5000}};
}


---------------End ---------------------

function tbItem:LoadSetting()
    self.tbSkillNameInfo = {};
    for nItemId, tbInfo in pairs(self.tbItemLimitInfo) do
        self.tbSkillNameInfo[tbInfo.szSkill] = self.tbSkillNameInfo[tbInfo.szSkill] or {};
        self.tbSkillNameInfo[tbInfo.szSkill][nItemId] = 1;
    end
end
tbItem:LoadSetting();

function tbItem:GetPlayerSkillLimit(pPlayer, szSkill)
    local tbAllInfo = self.tbSkillNameInfo[szSkill];
    if not tbAllInfo then
        return 0;
    end

    local nLimitLevel = 0;
    for nItemId, _ in pairs(tbAllInfo) do
        local tbLimitInfo = self.tbItemLimitInfo[nItemId];
        if tbLimitInfo then
            local nCount = pPlayer.GetUserValue(self.nSaveLevelGroup, tbLimitInfo.nSaveID);
            nLimitLevel = nLimitLevel + nCount * tbLimitInfo.nAdd;
        end    
    end

    return nLimitLevel;    
end    

function tbItem:CheckItemLimt(pPlayer, pItem)
    local nItemTID = pItem.dwTemplateId;
    local tbInfo = self.tbItemLimitInfo[nItemTID];
    if not tbInfo then
        return false, "不能使用目前的道具";
    end

    if tbInfo.nSaveID <= 0 or tbInfo.nSaveID > self.nSaveLevelMaxCount then
        return false, "不能使用目前的道具!";
    end

    local nCount = pPlayer.GetUserValue(self.nSaveLevelGroup, tbInfo.nSaveID);
    if nCount >= tbInfo.nMaxCount then
        return false, string.format("該道具最多使用%s個。", tbInfo.nMaxCount);
    end

    local nSkillID = FightSkill:GetSkillIdByBtnName(me.nFaction, tbInfo.szSkill);
    if not nSkillID then
        return false, "技能不存在";
    end    

    local tbSkillInfo = FightSkill:GetSkillSetting(nSkillID, 1);
    if not tbSkillInfo then
        return false, "技能不存在!";
    end

    return true, "", tbInfo, tbSkillInfo;   
end

function tbItem:OnUse(it)
    local bRet, szMsg, tbInfo, tbSkillInfo = self:CheckItemLimt(me, it);
    if not bRet then
        me.CenterMsg(szMsg);
        return;
    end  

    local nCount = me.GetUserValue(self.nSaveLevelGroup, tbInfo.nSaveID);
    nCount = nCount + 1;
    me.SetUserValue(self.nSaveLevelGroup, tbInfo.nSaveID, nCount);

    me.CenterMsg(string.format("您的技能%s增加等級上限%s級", tbSkillInfo.SkillName or "-", tbInfo.nAdd), true);
    Log("SkillMaxLevel OnUse", me.dwID, nCount, tbInfo.szSkill, it.dwTemplateId);
    return 1;
end


function tbItem:GetIntrol(dwTemplateId)
    local tbInfo = KItem.GetItemBaseProp(dwTemplateId)
    if not tbInfo then
        return
    end

    local tbLimitInfo = self.tbItemLimitInfo[dwTemplateId]
    if not tbLimitInfo or tbLimitInfo.nSaveID <= 0 then
        return
    end

    local nCount = me.GetUserValue(self.nSaveLevelGroup, tbLimitInfo.nSaveID)
    return string.format("%s\n使用數量：%d/%d", tbInfo.szIntro, nCount, tbLimitInfo.nMaxCount)
end

function tbItem:CheckSellItem(pPlayer, nItemTemplateId)
    local tbInfo = self.tbItemLimitInfo[nItemTemplateId];
    if not tbInfo or not pPlayer then
        return false;
    end

    if tbInfo.nSaveID <= 0 or tbInfo.nSaveID > self.nSaveLevelMaxCount then
        return false;
    end

    local nCount = pPlayer.GetUserValue(self.nSaveLevelGroup, tbInfo.nSaveID);
    if nCount < tbInfo.nMaxCount then
        return false;
    end

    if not tbInfo.tbSell then
        return false;
    end    

    return true, tbInfo.tbSell;
end

function tbItem:GetUseSetting(nItemTemplateId, nItemId)
    local bRet = self:CheckSellItem(me, nItemTemplateId);
    if not bRet then
        return;
    end    

    return {szFirstName = "出售", fnFirst = "SellItem", szSecondName = "使用", fnSecond = "UseItem"};
end 

-- function tbItem:GetDefineName(it)
--     local szName = KItem.GetItemShowInfo(it.dwTemplateId, me.nFaction);
--     local tbLimitInfo = self.tbItemLimitInfo[it.dwTemplateId];
--     if not tbLimitInfo or tbLimitInfo.nSaveID <= 0 then
--         return szName;
--     end

--     local nSkillID = FightSkill:GetSkillIdByBtnName(me.nFaction, tbLimitInfo.szSkill);
--     if not nSkillID then
--         return szName;
--     end    

--     local tbSkillInfo = FightSkill:GetSkillSetting(nSkillID, 1);
--     if not tbSkillInfo then
--         return szName;
--     end

--     return string.format("《%s》秘卷", tbSkillInfo.SkillName);
-- end 