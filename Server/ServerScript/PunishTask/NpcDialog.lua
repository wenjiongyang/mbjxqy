
local tbNpc = Npc:GetClass("PunishTaskDialog");

function tbNpc:OnDialog()
    if not him.tbPunishTaskInfo then
        Log("Error PunishTask OnDialog Not Data", him.nTemplateId);
        return;
    end

    Dialog:Show(
    {
        Text    = "來者何人？在這晃來晃去做什麼？",
        OptList = {
            { Text = "我是來為民除害的", Callback = self.Accept, Param = {self, him.nId} },
            { Text = "額，認錯人了"},
        };
    }, me, him);
end

function tbNpc:Accept(nNpcID)
    local pNpc = KNpc.GetById(nNpcID);
    if not pNpc then
        Log("PunishTask Accept Not Npc");
        return;
    end

    local tbPunishTaskInfo = pNpc.tbPunishTaskInfo;
    if not tbPunishTaskInfo then
        Log("Error PunishTask OnDialog Not Data", pNpc.nTemplateId);
        return;
    end

    local bRetcode, szMsg, tbMember = self:CheckAccept(me, pNpc);
    if not bRetcode then
        if szMsg and szMsg ~= "" then
            me.CenterMsg(szMsg);
        end
        return;
    end

    local nLevel = 0;
    local nCount = 0;
    for _, nPlayerID in pairs(tbMember) do
        local pMember = KPlayer.GetPlayerObjById(nPlayerID);
        --DegreeCtrl:ReduceDegree(pMember, PunishTask.szDegreeName, 1);
        --EverydayTarget:AddCount(pMember, "PunishTask");
        nLevel = nLevel + pMember.nLevel;
        nCount = nCount + 1;
        LogD(Env.LOGD_ActivityPlay, pMember.szAccount, pMember.dwID, pMember.nLevel, 0, Env.LOGD_VAL_TAKE_TASK, Env.LOGD_MIS_PUNISH_TASK, nil);

        Log("Punish Task ReduceDegree", me.dwTeamID, pMember.dwID, pMember.szName);
    end

    tbPunishTaskInfo.nTeamId = me.dwTeamID;
    --tbPunishTaskInfo.tbMember = tbMember;
    tbPunishTaskInfo.nNpcId  = nil;

    pNpc.Delete();

    local tbNpcInfo = tbPunishTaskInfo.tbNpcInfo;
    nLevel = math.floor(nLevel / nCount);

    local pAttackNpc = KNpc.Add(tbNpcInfo.NpcID, nLevel, -1, tbPunishTaskInfo.nMapID, tbPunishTaskInfo.nPosX, tbPunishTaskInfo.nPosY, 0);
    if not pAttackNpc then
        return;
    end

    tbPunishTaskInfo.nNpcId = pNpc.nId;
    pAttackNpc.tbPunishTaskInfo = tbPunishTaskInfo;
    PunishTask:StartNotDeathRebirthNpc(pAttackNpc);
    Log("Punish Task Create Attack Npc", tbNpcInfo.NpcID, tbPunishTaskInfo.nTeamId);
end

function tbNpc:CheckAccept(pPlayer, pNpc)
    local nTeamId = pPlayer.dwTeamID;
    if nTeamId <= 0 then
        return false, string.format("需要隊伍人數≥%d人", PunishTask.nMinTeamCount);
    end

    local tbTeam = TeamMgr:GetTeamById(nTeamId)
    local nCaptainId = tbTeam:GetCaptainId();
    if nCaptainId ~= pPlayer.dwID then
        return false, "您不是隊長";
    end

    local tbMember     = tbTeam:GetMembers();
    local nCountMember = Lib:CountTB(tbMember);
    if PunishTask.nMinTeamCount > nCountMember then
        return false, string.format("需要隊伍人數≥%d人", PunishTask.nMinTeamCount);
    end

    local bCheckResult = true;
    for _, nPlayerID in pairs(tbMember) do
        local pMember = KPlayer.GetPlayerObjById(nPlayerID);
        if not pMember then
            local tbStayInfo = KPlayer.GetRoleStayInfo(nPlayerID);
            local szName = "有成員";
            if tbStayInfo then
                szName = "「" .. tbStayInfo.szName .. "」";
            end

            return false, szName .. "不在線上";
        end

        if PunishTask.nMinPlayerLevel > pMember.nLevel then
            return false, string.format("「%s」等級不足%d，無法參加懲惡任務", pMember.szName, PunishTask.nMinPlayerLevel);
        end

        if pNpc then
            local nNpcMapId, nNpcX, nNpcY = pNpc.GetWorldPos();
            local pMemberNpc = pMember.GetNpc();
            local nCurMapId, nMX, nMY = pMemberNpc.GetWorldPos();
            if nNpcMapId ~= nCurMapId then
                return false, "還是等所有隊員到齊後再來吧!";
            end 

            local fDists = Lib:GetDistsSquare(nNpcX, nNpcY, nMX, nMY);
            if fDists > (PunishTask.nMinDistance * PunishTask.nMinDistance) then
                return false, "還是等所有隊員到齊後再來吧";
            end    
        end

        if not Env:CheckSystemSwitch(pMember, Env.SW_PunishTask) then
            return false, "目前狀態不能參加";
        end 

        -- local nDegreeCount = DegreeCtrl:GetDegree(pMember, PunishTask.szDegreeName);
        -- if nDegreeCount <= 0 then
        --     pMember.BuyTimes(PunishTask.szDegreeName, PunishTask.nBuyActivityCount, self.BuyFinish, self, pPlayer.dwID, pMember.szName);
        --     bCheckResult = false;
        --     me.CenterMsg(string.format("%s的大盗惩恶次数不足", pMember.szName));
        -- end
    end

    if not bCheckResult then
        return false, "";
    end

    local bRet = PunishTask:TeamHaveSkillNpc(nTeamId);
    if bRet then
        return false, "必須先擊殺上一名大盜";
    end

    return true, "", tbMember;
end

function tbNpc:BuyFinish(nPlayerID, szMemberName, bRet, nCount)
    if not bRet then
        return;
    end

    local pPlayer = KPlayer.GetPlayerObjById(nPlayerID);
    if not pPlayer then
        return;
    end

    local szTips = string.format("%s購買了%s次大盜懲惡次數", szMemberName, nCount);
    if pPlayer.dwTeamID > 0 then
        ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Team, szTips, pPlayer.dwTeamID);
    end
end

