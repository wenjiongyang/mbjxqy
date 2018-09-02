
Require("CommonScript/Npc/NpcDefine.lua");
Require("CommonScript/Item/Define.lua");


ActionMode.nFightRideTime = 10; --战斗状态读条时间

ActionMode.tbChangeActModeEquip =
{
    [Npc.NpcActionModeType.act_mode_ride] = {nEquipPos = Item.EQUIPPOS_HORSE; szName = "上馬"};
};

function ActionMode:GetActModeEquip(nActMode)
    return self.tbChangeActModeEquip[nActMode];
end

function ActionMode:CheckDoChangeActionMode(pPlayer, nActMode)

    if OnHook:IsOnLineOnHook(pPlayer) and not OnHook:IsOnLineOnHookForce(pPlayer) then
        return false, "線上託管狀態下不能使用";
    end

    if not nActMode then
        return false, "不能改變騎馬";
    end

    local nCurActMode = pPlayer.GetActionMode();
    if nCurActMode == nActMode then
        return false, "不能改變騎馬！";
    end

    if nActMode == Npc.NpcActionModeType.act_mode_none then
        return true, "";
    end

    local tbActModeInfo = self:GetActModeEquip(nActMode);
    if not tbActModeInfo then
        return false, "不能改變動作模式!";
    end

    local pPlayerNpc = pPlayer.GetNpc();
    local nResult = pPlayerNpc.CanChangeDoing(Npc.Doing.skill);
    if nResult == 0 then
        return false, string.format("正在使用技能不能%s", tbActModeInfo.szName);
    end

    local nMapTID = pPlayer.nMapTemplateId;
    if Map:IsForbidRide(nMapTID) then
        return false, string.format("目前地圖不能%s", tbActModeInfo.szName);
    end

    local pEquip = pPlayer.GetEquipByPos(tbActModeInfo.nEquipPos);
    if not pEquip then
        return false, "未上陣";
    end

    local pNpc = pPlayer.GetNpc();
    if not pNpc then
        return false, "無法上馬";
    end

    if pNpc.nShapeShiftNpcTID > 0 then
        return false, string.format("處於變身狀態時不能%s", tbActModeInfo.szName);
    end

    if not pPlayer.nLastRideTime then
        pPlayer.nLastRideTime = 0;
    end

    local nCurTime = GetTime();
    if pPlayer.nFightMode ~= Npc.FIGHT_MODE.emFightMode_None and (nCurTime - pPlayer.nLastRideTime) <= ActionMode.nFightRideTime then
        return false, string.format("%s太累了，稍等一會", tbActModeInfo.szName);
    end

    if pPlayer.bTempForbitMount then
        return false, "您現在暫時不能上馬"
    end

    local bRet, szMsg = House:CheckCanRide(pPlayer);
    if not bRet then
        return false, szMsg;
    end

    return true, "";
end

function ActionMode:DoChangeActionMode(pPlayer, nActMode, bNotMsg)
    local bRet, szMsg = self:CheckDoChangeActionMode(pPlayer, nActMode);
    if not bRet then
        if not bNotMsg then
            pPlayer.CenterMsg(szMsg);
        end
        return;
    end

    pPlayer.DoChangeActionMode(nActMode);
    if nActMode ~= Npc.NpcActionModeType.act_mode_none then
        pPlayer.nLastRideTime = GetTime();
    end
end

function ActionMode:OnEnterMap(pPlayer, nMapTemplateId)
    local nCurActMode = pPlayer.GetActionMode();
    if nCurActMode == Npc.NpcActionModeType.act_mode_none then
        return;
    end

    if not Map:IsForbidRide(nMapTemplateId) then
        return;
    end

    ActionMode:DoForceNoneActMode(pPlayer, "目前地圖不能騎馬！");
end

function ActionMode:DoForceNoneActMode(pPlayer, szMsg)
    local nCurActMode = pPlayer.GetActionMode();
    if nCurActMode == Npc.NpcActionModeType.act_mode_none then
        return;
    end

    self:DoChangeActionMode(pPlayer, Npc.NpcActionModeType.act_mode_none, true);
    if szMsg then
        pPlayer.CenterMsg(szMsg);
    end
end

function ActionMode:ServerSendActMode(pPlayer)
    local nActMode = pPlayer.GetActionMode();
    pPlayer.CallClientScript("ActionMode:ClientActionMode", nActMode);
end

function ActionMode:ClientActionMode(nActMode)
    local nCurActMode = me.GetActionMode();
    if nCurActMode == nActMode then
        return;
    end

    me.DoChangeActionMode(nActMode);
end

function ActionMode:CallDoActionMode(nActionMode, bMsg)
    local nCurAction = me.GetActionMode();
    if nCurAction == nActionMode then
        return;
    end

    local bAuto = AutoFight:IsAuto();
    if bAuto and nActionMode ~= Npc.NpcActionModeType.act_mode_none then
        if bMsg then
            me.CenterMsg("自動戰鬥不能騎馬，請切換手動戰鬥");
        end
        return;
    end

    if IsAlone() == 1 then
        ActionMode:DoChangeActionMode(me, nActionMode);
    else
        RemoteServer.ChangeActionMode(nActionMode);
    end
end