Require("ServerScript/BossLeader/BossLeaderNpc.lua")
local tbNpc = Npc:GetClass("BossLeaderDung");
local tbNpcBoss = Npc:GetClass("BossLeader");

local FubenMgr = Fuben.DungeonFubenMgr    

local szType = "Leader"

function tbNpc:OnCreate()
    him.SetByAttackCallScript(1);
    him.tbBossLeaderInfo = {};
    him.tbBossLeaderInfo.bIsFirstDmg = true;
    him.tbBossLeaderInfo.szType = szType;
    him.tbBossLeaderInfo.tbNpcInfo = tbNpcInfo;
end

function tbNpc:OnByAttack()
    if not me or not him then
        return;
    end

    local tbBLInfo = him.tbBossLeaderInfo;
    if not tbBLInfo or Lib:IsEmptyStr(tbBLInfo.szType) then
        Log("Error BossLeader Not Boss Leader Info", him.nTemplateId);
        return;
    end

    local bRetcode, tbAward, nSaveId = tbNpcBoss:CheckFirstDmgAward(me, him, tbBLInfo.szType);
    if not bRetcode then
        return;
    end

    me.SetUserValue(tbNpcBoss.SAVE_BOSSLEADER_GROUP, nSaveId, Lib:GetLocalDay());
    me.SendAward(tbAward, true, false, Env.LogWay_DungLeaderOnAttack);
    Log("OnByAttack First Dmg", me.szName, me.dwID);    
end

function tbNpc:OnDeath()
    if not him then
        return
    end
    local tbInst = Fuben.tbFubenInstance[him.nMapId];
    if not tbInst then
        return
    end
    
    
    local nAwardId = FubenMgr.tbBossAwardSetting[him.nTemplateId]
    assert(nAwardId)

    local nBossAwardNum = FubenMgr.nBossAwardNum

    local tbKillAward = BossLeader:GetPlayerDmgRank(nAwardId, 1)
    tbKillAward = tbKillAward.tbAward

    for i,v in ipairs(tbKillAward) do
        if v[1] == "item" then
            v[3] = nBossAwardNum
        end
    end
    local tbMsg = {szNpcName = "神秘洞窟" .. him.szName};
    local _, nPosX, nPosY = him.GetWorldPos();
    local fnExcute = function (pPlayer)
        pPlayer.DropAward(nPosX, nPosY, tbMsg, tbKillAward, Env.LogWay_DungLeaderDeath, him.nTemplateId);
    end
    tbInst:AllPlayerExcute(fnExcute);
end