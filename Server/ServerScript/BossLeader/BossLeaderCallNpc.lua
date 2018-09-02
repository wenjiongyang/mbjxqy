
local tbFollowNpc = Npc:GetClass("BossLeaderCallNpc");

function tbFollowNpc:OnDeath(pKillNpc)
    if not him then
        return;
    end

    local nMasterNpcId = him.nBossLeaderMaster;
    if not nMasterNpcId then
        return;
    end

    local pMasterNpc = KNpc.GetById(nMasterNpcId);
    if not pMasterNpc then
        return;
    end

    local tbBLInfo = pMasterNpc.tbBossLeaderInfo;
    if not tbBLInfo then
        return;
    end

    local tbNpcInfo = tbBLInfo.tbNpcInfo;
    if self:HaveCallEventNpcID(tbNpcInfo.CallEventID, him.nTemplateId) then
        local tbSortDamage = him.GetDamageInfo();
        if tbSortDamage then
            tbBLInfo.tbAllCallNpcDmg = tbBLInfo.tbAllCallNpcDmg or {};
            Lib:MergeTable(tbBLInfo.tbAllCallNpcDmg, tbSortDamage)
        end
    end

    local tbCallEvent = BossLeader:GetCallEventInfo(tbNpcInfo.CallEventID, "DeathRemoveBuff");
    if tbCallEvent then
        for _, tbEvent in pairs(tbCallEvent) do
            if not Lib:IsEmptyStr(tbEvent.Param1) and not Lib:IsEmptyStr(tbEvent.Param2) then
                local nCalllNpcID = tonumber(tbEvent.Param1);
                local nBuffId = tonumber(tbEvent.Param2);
                if nCalllNpcID == him.nTemplateId then
                    pMasterNpc.RemoveSkillState(nBuffId);
                end
            end
        end
    end

    local tbCallEvent = BossLeader:GetCallEventInfo(tbNpcInfo.CallEventID, "DeathAddBuff");
    if tbCallEvent then
        for _, tbEvent in pairs(tbCallEvent) do
            if not Lib:IsEmptyStr(tbEvent.Param1) and not Lib:IsEmptyStr(tbEvent.Param2) and not Lib:IsEmptyStr(tbEvent.Param4) and not Lib:IsEmptyStr(tbEvent.Param3) then
                local nCalllNpcID = tonumber(tbEvent.Param1);
                local nBuffId = tonumber(tbEvent.Param2);
                local nBuffLevel = tonumber(tbEvent.Param3);
                local nBuffTime = tonumber(tbEvent.Param4);
                if nCalllNpcID == him.nTemplateId and nBuffTime then
                    pMasterNpc.AddSkillState(nBuffId, nBuffLevel, 0, nBuffTime);
                end
            end
        end
    end
end

function tbFollowNpc:HaveCallEventNpcID(nCallEventID, nNpcTID)
    local tbCallEvent = BossLeader:GetCallEventInfo(nCallEventID, "CalcDmg");
    if not tbCallEvent then
        return false;
    end

    for _, tbEvent in pairs(tbCallEvent) do
        if not Lib:IsEmptyStr(tbEvent.Param1) then
            local nCalllNpcID = tonumber(tbEvent.Param1);
            if nCalllNpcID == nNpcTID then
                return true;
            end
        end
    end

    return false;
end