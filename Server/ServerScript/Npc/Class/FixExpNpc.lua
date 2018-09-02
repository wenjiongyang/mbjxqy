
local tbFieldNpc = Npc:GetClass("FixExpNpc");

function tbFieldNpc:DeathCalcAward(pNpc, tbDamageInfo, pKiller)
    local nExperience = pNpc.GetExperience();
    if nExperience <= 0 then
        return;
    end

    local tbPlayer = Npc:GetDamageFirstTeam(pNpc, tbDamageInfo);
    if not tbPlayer or #tbPlayer <= 0 then
        return;
    end

    for _, tbPlayerInfo in pairs(tbPlayer) do
        local pPlayer = tbPlayerInfo.pPlayer;
        pPlayer.AddExperience(nExperience, Env.LogWay_FixExpNpc);
    end
end

local tbBasicFieldNpc = Npc:GetClass("FixBasicExpNpc");
function tbBasicFieldNpc:DeathCalcAward(pNpc, tbDamageInfo, pKiller)
    local nExperience = pNpc.GetExperience();
    if nExperience <= 0 then
        return;
    end

    local tbPlayer = Npc:GetDamageFirstTeam(pNpc, tbDamageInfo);
    if not tbPlayer or #tbPlayer <= 0 then
        return;
    end

    for _, tbPlayerInfo in pairs(tbPlayer) do
        local pPlayer = tbPlayerInfo.pPlayer;
        local nPlayerBaseExp = pPlayer.GetBaseAwardExp();
        local nAddEXP = nExperience * nPlayerBaseExp;                 
        pPlayer.AddExperience(nAddEXP, Env.LogWay_FixExpNpc);
    end
end
 