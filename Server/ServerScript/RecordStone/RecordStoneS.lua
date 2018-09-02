
function RecordStone:SetCurRecordStone(pPlayer, nStoneId, nInsetPos)
    local pEquip, tbStoneInfo, tbStoneList, nCoinCost = self:CanSetCurRecordStone(pPlayer, nStoneId, nInsetPos)
    if not pEquip then
        return
    end

    if not pPlayer.CostMoney("Coin", nCoinCost, Env.LogWay_RecordStone) then
        return
    end

    if pPlayer.ConsumeItemInBag(nStoneId, 1, Env.LogWay_RecordStone) ~= 1 then
        return
    end

    if nInsetPos <= #tbStoneList then
        pPlayer.SetUserValue(self.SAVE_GROUP, nInsetPos, nStoneId) 
    else
        pPlayer.SetUserValue(self.SAVE_GROUP, #tbStoneList + 1, nStoneId) 
    end
    
    --将UserValue更新到武器上，换武器时依然保留，但是非合适的
    self:UpdateCurRecoreStoneToEquip(pPlayer, Item.EQUIPPOS_WEAPON);
    pPlayer.CallClientScript("RecordStone:OnClientSuccess")
end

function RecordStone:UpdateCurRecoreStoneToEquip(pPlayer, nPos)
    if nPos ~=  Item.EQUIPPOS_WEAPON then
        return
    end
    local pEquip = pPlayer.GetEquipByPos(nPos)
    if not pEquip then
        return
    end 
    local nHoleNum = self:GetEquipCanInsetNum(pEquip.dwTemplateId)
    local nHasValIndex = 0
    if nHoleNum > 0 then
        local tbStoneList = self:GetCurStoneList(pPlayer)
        for i, nStoneId in ipairs(tbStoneList) do
            if i > nHoleNum then
                break;
            end

            local tbStoneInfo = self:GetStoneInfo(nStoneId)
            if not tbStoneInfo then
                Log(debug.traceback(), nStoneId)
                break;
            end

            local nCurNum = pPlayer.GetUserValue(self.SAVE_GROUP, tbStoneInfo.SaveKey)
            pEquip.SetIntValue( i + Item.EQUIP_RECORD_STONE_VALUE_BEGIN - 1,  tbStoneInfo.SaveKey + 100 * nCurNum) --合并省下intval
            nHasValIndex = i;
        end
    end
    --应用时都是遇到0就断掉了，所以只最多多设1个0了
    if nHasValIndex + 1 <= self.MAX_RECORD_STONE_NUM then
        pEquip.SetIntValue(nHasValIndex + 1 + Item.EQUIP_RECORD_STONE_VALUE_BEGIN - 1, 0)
    end
end

function RecordStone:ClearEquipRecord( pPlayer, nPos )
    if nPos ~= Item.EQUIPPOS_WEAPON then
        return
    end

    local pEquip = pPlayer.GetEquipByPos(nPos)
    if not pEquip then
        return
    end
    pEquip.SetIntValue(Item.EQUIP_RECORD_STONE_VALUE_BEGIN, 0)
end

function RecordStone:AddRecordCount(pPlayer, szType, nCount)
    local nStoneId = self:GetStoneIdByType(szType)
    if not nStoneId then
        return
    end
    local pEquip = pPlayer.GetEquipByPos(Item.EQUIPPOS_WEAPON)
    if not pEquip then
        return
    end 

    --已镶嵌位置的UserValue是不清的
    if not self.tbRecordEquipInfo[pEquip.dwTemplateId] then
        return
    end

    local nRecordIndex = self:GetCurStoneIndex(pPlayer, nStoneId)
    if not nRecordIndex then
        return
    end

    nCount = nCount or 1;

    local tbStoneInfo = self:GetStoneInfo(nStoneId)
    local nCurNum = pPlayer.GetUserValue(self.SAVE_GROUP, tbStoneInfo.SaveKey) + nCount
    pPlayer.SetUserValue(self.SAVE_GROUP, tbStoneInfo.SaveKey, nCurNum)
    pEquip.SetIntValue( nRecordIndex + Item.EQUIP_RECORD_STONE_VALUE_BEGIN - 1,  tbStoneInfo.SaveKey + 100 * nCurNum) 
end

