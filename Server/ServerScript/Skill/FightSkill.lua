Require("CommonScript/Item/XiuLian.lua");

function FightSkill:SkillLevelUp(pPlayer, nSkillId)
    local bRet, szMsg, nBaseLevel, nNeedPoint = self:CheckSkillLeveUp(pPlayer, nSkillId);
    if not bRet then
        pPlayer.CallClientScript("Player:OnFightSkillLevelUp", false, szMsg);
        return;
    end

    self:CostPlayerSkillPoint(pPlayer, nNeedPoint);
    self:DoSkillLevelUp(pPlayer, nSkillId, 1);
    pPlayer.CallClientScript("Player:OnFightSkillLevelUp", true, nSkillId, nBaseLevel + 1);
    Log("FightSkill SkillLevelUp", pPlayer.dwID, pPlayer.szName, nSkillId, nBaseLevel + 1, nNeedPoint or 0);
end

function FightSkill:DoSkillLevelUp(pPlayer, nSkillId, nUpLevel)
    pPlayer.LevelUpFightSkill(nSkillId, nUpLevel);
    FightPower:ChangeFightPower("Skill", pPlayer);
end

function FightSkill:CostPlayerSkillPoint(pPlayer, nCostPoint)
    --local nSkillPoint = pPlayer.GetMoney("SkillPoint");
    --if not  pPlayer.CostMoney("SkillPoint", nCostPoint, Env.LogWay_SkillLevelUp) then
    --    Log("FightSkill CostPlayerSkillPoint", pPlayer.dwID, nSkillPoint, nCostPoint);
    --    Log(debug.traceback())
    --    return 
    --end
    local nToalCostPoint = pPlayer.GetUserValue(FightSkill.nSaveSkillPointGroup, FightSkill.nSaveCostSkillPoint);
    nToalCostPoint = nToalCostPoint + nCostPoint;
    pPlayer.SetUserValue(FightSkill.nSaveSkillPointGroup, FightSkill.nSaveCostSkillPoint, nToalCostPoint);
    Log("FightSkill CostPlayerSkillPoint", pPlayer.dwID, nCostPoint, nToalCostPoint);
end

function FightSkill:CheckResetSkillPoint(pPlayer, bNotJudgeGold)
    local nToalCostPoint = pPlayer.GetUserValue(FightSkill.nSaveSkillPointGroup, FightSkill.nSaveCostSkillPoint);
    if nToalCostPoint <= 0 then
        return false, "沒有重置的技能點";
    end

    if not bNotJudgeGold and pPlayer.nLevel >= FightSkill.nCostGoldLevelResetSkill and pPlayer.nMapTemplateId ~= ChangeFaction.tbDef.nMapTID then
        if FightSkill.nCostGoldResetSkill > pPlayer.GetMoney("Gold") then
            return false, string.format("元寶不足%s", FightSkill.nCostGoldResetSkill);
        end
    end    

    return true, "";  
end

function FightSkill.CostGoldResetPointCallBack(nPlayerId, bSuccess)
    if not bSuccess then
        return false;
    end

    local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
    if not pPlayer then
        return false;
    end

    local bRet, szMsg = FightSkill:CheckResetSkillPoint(pPlayer, true);
    if not bRet then
        pPlayer.CenterMsg(szMsg);
        return false;
    end

    FightSkill:ResetSkillPoint(pPlayer);
    return true;
end

function FightSkill:DoResetSkillPoint(pPlayer)
    local bRet, szMsg = self:CheckResetSkillPoint(pPlayer);
    if not bRet then
        pPlayer.CenterMsg(szMsg);
        return;
    end

    if pPlayer.nLevel >= FightSkill.nCostGoldLevelResetSkill and pPlayer.nMapTemplateId ~= ChangeFaction.tbDef.nMapTID then
        pPlayer.CostGold(FightSkill.nCostGoldResetSkill, Env.LogWay_ResetSkill, nil, FightSkill.CostGoldResetPointCallBack);
    else
        FightSkill:ResetSkillPoint(pPlayer);    
    end     
end

function FightSkill:ResetSkillPoint(pPlayer)
    local nToalCostPoint = pPlayer.GetUserValue(FightSkill.nSaveSkillPointGroup, FightSkill.nSaveCostSkillPoint);
    pPlayer.SetUserValue(FightSkill.nSaveSkillPointGroup, FightSkill.nSaveCostSkillPoint, 0);
    --pPlayer.AddMoney("SkillPoint", nToalCostPoint, Env.LogWay_ResetSkill);
    pPlayer.ResetFactionSkill();
    FightPower:ChangeFightPower("Skill", pPlayer);
    pPlayer.CenterMsg("技能點分配已重置，請重新分配");
    pPlayer.CallClientScript("Player:ServerSyncData", "SkillPanelUpdate");
    Log("ResetSkillPoint", pPlayer.dwID, pPlayer.nLevel, nToalCostPoint);
end


FightSkill.tbMagicCallScriptFun = 
{
    [XiuLian.tbDef.nXiuLianBuffId] = function (pNpc, nSkillId, nEnd, nValue1, nValue2, nValue3)
        if nEnd == 0 then
            return;
        end
            
        local pPlayer = pNpc.GetPlayer();
        if not pPlayer then
            Log("Error Not Player");
            return;
        end

        XiuLian:ResetResidueExp(pPlayer, "Buff");
    end
}

function FightSkill:MagicCallScript(pNpc, nSkillId, nEnd, nValue1, nValue2, nValue3)
    local funCallScript = FightSkill.tbMagicCallScriptFun[nSkillId];
    if funCallScript then
        funCallScript(pNpc, nSkillId, nEnd, nValue1, nValue2, nValue3);
    end     
end
