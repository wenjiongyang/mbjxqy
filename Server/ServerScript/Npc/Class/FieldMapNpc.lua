
local tbFieldNpc = Npc:GetClass("FieldMapNpc");
tbFieldNpc.nGouHuoTime      = 15 * 60; --篝火时效
tbFieldNpc.nGouHuoBaseExp   = 66.7; --每分钟篝火基准经验（0.667点体力经验）
tbFieldNpc.nPeriodTime      = 6; --每多少秒加一次
tbFieldNpc.nGouHuoTotalRate = 100000; --篝火掉落的概率计算总值
tbFieldNpc.nMaxRankPos      = 3; --输出伤害前3名拥有奖励分配
tbFieldNpc.fCtrlExpParam    = 1.0; --经验分配的调节系数
tbFieldNpc.szGouHuoAchievement = "XiuLian_2"; --篝火成就
tbFieldNpc.fMaxMemberMainP   = 0.6; --队员共享经验不得超过主打者的经验
tbFieldNpc.fExperienceScale  = 0.001; --实际基准经验 = Experience * 该值

function tbFieldNpc:DeathCalcAward(pNpc, tbDamageInfo, pKiller)
    local nMaxPos = #tbDamageInfo;
    if nMaxPos > self.nMaxRankPos then
        nMaxPos = self.nMaxRankPos;
    end

    local nExperience = pNpc.GetExperience();
    if nExperience > 0 then    
        local pFirstPlayer, tbFirstPlayer = self:CalcDeathExp(pNpc, tbDamageInfo, nMaxPos, pKiller);
        if pFirstPlayer and tbFirstPlayer then
            self:CallGouHuo(pFirstPlayer, pNpc, tbFirstPlayer);
        end
    else
        local nFixExperience = pNpc.GetFixExperience();
        if nFixExperience > 0 then
            local pFirstPlayer, tbFirstPlayer = self:CalcDeathFixExp(pNpc, tbDamageInfo, nMaxPos, pKiller);
            if pFirstPlayer and tbFirstPlayer then
                self:CallGouHuo(pFirstPlayer, pNpc, tbFirstPlayer);
            end
        end    
    end        
end

function tbFieldNpc:CalcDeathFixExp(pNpc, tbDamageInfo, nMaxPos, pKiller, bWithoutXiuLian)
    local pKillerPlayer = nil;
    if pKiller then
        pKillerPlayer = pKiller.GetPlayer();
    end

    local nMainAttackID = nil;   
    if pKillerPlayer then
        nMainAttackID = pKillerPlayer.dwID;
    end

    local nExperience = pNpc.GetFixExperience();
    local nNpcLevel   = pNpc.nLevel;
    local nNpcMaxLife = pNpc.nMaxLife;
    local pFirstPlayer = nil;
    local tbFirstPlayer = nil;
    for nI = 1, nMaxPos do
        local tbDamage = tbDamageInfo[nI];
        if tbDamage then
            local tbPlayer, pCaptain, nTotalLevel, bMainAttack = Npc:GetAssignPlayer(pNpc, tbDamage, Npc.nMaxAwardLen, nMainAttackID);
            if tbPlayer and #tbPlayer > 0 then
                if nI == 1 then
                    pFirstPlayer = pCaptain;
                    tbFirstPlayer = tbPlayer;
                end 

                local nTotalCount = #tbPlayer;
                local nBaseExp    = nExperience * tbDamage.nTotalDamage / nNpcMaxLife;
                local fFactor     = math.sqrt(nTotalCount);
                local nMemberExp  = nBaseExp * self.fCtrlExpParam * fFactor / nTotalLevel;

                local nMainAttackExp = 0;
                local nMaxMemberExp =  0;
                if bMainAttack then
                    nMainAttackExp = nBaseExp * (100 + nTotalCount) / 100;
                    nMaxMemberExp = nMainAttackExp * self.fMaxMemberMainP;
                end

                for _, tbPlayerInfo in pairs(tbPlayer) do
                    local pPlayer = tbPlayerInfo.pPlayer;
                    local nAddExp = 0;
                    local nAddExpP = 0;
                    if pPlayer.dwID == nMainAttackID then
                        nAddExp = nMainAttackExp;
                    else
                        nAddExp = nMemberExp * pPlayer.nLevel;
                        if nMaxMemberExp > 0 and nAddExp > nMaxMemberExp then
                            nAddExp = nMaxMemberExp;
                        end

                        if bMainAttack and nMainAttackID and nMainAttackID > 0 then
                            local nImityLevel = FriendShip:GetFriendImityLevel(pPlayer.dwID, nMainAttackID);
                            nAddExpP = FriendShip:GetFriendImityExpP(nImityLevel);
                        end    
                    end

                    nAddExp = nAddExp * (100 + nAddExpP) / 100;
                    if nAddExp > 0 then
                        if bWithoutXiuLian then
                            pPlayer.AddExperience(nAddExp, Env.LogWay_NpcDropAward);
                        else
                            Player:AddXiuLianExp(pPlayer, nAddExp, nNpcLevel,true);
                        end
                    end        
                end    
            end
        end       
    end

    return pFirstPlayer, tbFirstPlayer;
end    

function tbFieldNpc:CalcDeathExp(pNpc, tbDamageInfo, nMaxPos, pKiller, bWithoutXiuLian)
    local pKillerPlayer = nil;
    if pKiller then
        pKillerPlayer = pKiller.GetPlayer();
    end

    local nMainAttackID = nil;   
    if pKillerPlayer then
        nMainAttackID = pKillerPlayer.dwID;
    end

    local nExperience = pNpc.GetExperience();
    nExperience = nExperience * tbFieldNpc.fExperienceScale;
    local nNpcLevel   = pNpc.nLevel;
    local nNpcMaxLife = pNpc.nMaxLife;
    local pFirstPlayer = nil;
    local tbFirstPlayer = nil;
    for nI = 1, nMaxPos do
        local tbDamage = tbDamageInfo[nI];
        if tbDamage then
            local tbPlayer, pCaptain, nTotalLevel, bMainAttack = Npc:GetAssignPlayer(pNpc, tbDamage, Npc.nMaxAwardLen, nMainAttackID);
            if tbPlayer and #tbPlayer > 0 then
                if nI == 1 then
                    pFirstPlayer = pCaptain;
                    tbFirstPlayer = tbPlayer;
                end 

                local nBaseExp    = nExperience * tbDamage.nTotalDamage / nNpcMaxLife;

                for _, tbPlayerInfo in pairs(tbPlayer) do
                    local pPlayer = tbPlayerInfo.pPlayer;
                    local nAddExpP = 0;
                    if bMainAttack and pPlayer.dwID ~= nMainAttackID and nMainAttackID and nMainAttackID > 0 then
                        local nImityLevel = FriendShip:GetFriendImityLevel(pPlayer.dwID, nMainAttackID);
                        nAddExpP = FriendShip:GetFriendImityExpP(nImityLevel);
                    end    

                    local nPlayerBaseExp = pPlayer.GetBaseAwardExp();
                    local nAddExp = nPlayerBaseExp * nBaseExp * (100 + nAddExpP) / 100;
                    if nAddExp > 0 then
                        if bWithoutXiuLian then
                            pPlayer.AddExperience(nAddExp, Env.LogWay_NpcDropAward);
                        else
                            Player:AddXiuLianExp(pPlayer, nAddExp, nNpcLevel, true);
                        end
                    end        
                end    
            end
        end       
    end

    return pFirstPlayer, tbFirstPlayer;
end

function tbFieldNpc:CallGouHuo(pCaptain, pNpc, tbFirstPlayer)
    local nGouHuoRate = pNpc.GetGouHuoRate();
    if nGouHuoRate <= 0 then
        return;
    end

    if not pCaptain then
        return;
    end    

    local nRate = MathRandom(tbFieldNpc.nGouHuoTotalRate);
    if nRate > nGouHuoRate then
        return;
    end

    if tbFirstPlayer then
        local tbAllMember = {};
        for _, tbPlayerInfo in pairs(tbFirstPlayer) do
            Achievement:AddCount(tbPlayerInfo.pPlayer, tbFieldNpc.szGouHuoAchievement, 1);
            table.insert(tbAllMember, tbPlayerInfo.pPlayer.dwID);
        end

        local nTotalCount = #tbAllMember;
        if nTotalCount >= 2 then
            for nI = 1, nTotalCount - 1 do
                for nJ = nI + 1, nTotalCount do
                    local nPlayer1 = tbAllMember[nI];
                    local nPlayer2 = tbAllMember[nJ];
                    FriendShip:AddImitityByKind(nPlayer1, nPlayer2, Env.LogWay_KillFieldMapNpc);
                end    
            end
        end     
    end    

    local nGouHuoX, nGouHuoY = pNpc.GetDeathPos();
    if nGouHuoX <= 0 and nGouHuoY <= 0 then
        local _, nX, nY = pNpc.GetWorldPos();
        nGouHuoX = nX;
        nGouHuoY = nY;
    end
        
    local tbGouhuoNpc = Npc:GetClass("GouHuoNpc");
    tbGouhuoNpc:CallTeamGouhuoNpc(pCaptain, nGouHuoX, nGouHuoY, tbFieldNpc.nGouHuoTime, tbFieldNpc.nGouHuoBaseExp, tbFieldNpc.nPeriodTime, 1);
end  