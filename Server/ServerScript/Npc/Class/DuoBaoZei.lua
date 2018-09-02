
local tbNpc = Npc:GetClass("DuoBaoZei");

function tbNpc:OnDeath(pKillNpc)
    if not him then
        return;
    end

    if not pKillNpc then
        Log("[DuoBaoZei] not pKillNpc or killer offline")
        return
    end

    local pPlayer = pKillNpc.GetPlayer();

    if not pPlayer then
        return
    end
    local nDegreeCount = DegreeCtrl:GetDegree(pPlayer, "DuoBaoZeiCount"); 
    if nDegreeCount > 0 then
        if not DegreeCtrl:ReduceDegree(pPlayer, "DuoBaoZeiCount", 1) then
            Log("DuoBaoZei DegreeCtrl:ReduceDegree fail ------");
            return 
        end
        local tbAward = Item:GetClass("CangBaoTu"):RandomDBZAward(pKillNpc.nLevel);
        pPlayer.SendAward(tbAward, true, nil, Env.LogWay_DaoBaoZaiAward);
    end

    self:SendTeamAward(pPlayer);
end

function tbNpc:SendTeamAward(pKillPlayer)

    local nTeamID = pKillPlayer.dwTeamID
    if not nTeamID or nTeamID == 0 then
        return 
    end

    local tbMember = TeamMgr:GetMembers(nTeamID)
    if not next(tbMember) then
        return 
    end

    for _,dwID in pairs(tbMember) do
        if dwID ~= pKillPlayer.dwID then
            local pPlayer = KPlayer.GetPlayerObjById(dwID)
            if pPlayer then
                local nDegreeCount = DegreeCtrl:GetDegree(pPlayer, "DuoBaoZeiCount");
                if nDegreeCount > 0 then
                    if DegreeCtrl:ReduceDegree(pPlayer, "DuoBaoZeiCount", 1) then
                        local tbAward = Item:GetClass("CangBaoTu"):RandomDBZAward(pPlayer.nLevel);
                        pPlayer.SendAward(tbAward, true, nil, Env.LogWay_DaoBaoZaiAward);
                    end
                end
            end
        end
    end
end
