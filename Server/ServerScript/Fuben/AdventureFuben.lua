Fuben.AdventureFuben = Fuben.AdventureFuben or {};
local AdventureFuben = Fuben.AdventureFuben;

AdventureFuben.MIN_PLAYER_COUNT = 1     --最低进入人数
AdventureFuben.MAX_PLAYER_COUNT = 4     --不够此人数有提醒
AdventureFuben.MIN_LEVEL        = 13    --最低等级
AdventureFuben.MAP_TEMPLATEID   = 500   --地图id
AdventureFuben.REVIVE_TIME      = 5    --复活时间
AdventureFuben.WIN_EXPERIENCE   = 60    --通关基准经验
AdventureFuben.ACTIVITY_NAME    = "山賊秘窟"
AdventureFuben.CAPTAIN_CONTRIB  = 60

function AdventureFuben:Init()
    TeamMgr:RegisterActivity("AdventureFuben", "AdventureFuben", self.ACTIVITY_NAME,
        {"Fuben.AdventureFuben:QTCanShow"},
        {"Fuben.AdventureFuben:QTCanJoin"},
        {"Fuben.AdventureFuben:QTCheckEnter"},
        {"Fuben.AdventureFuben:QTEnterFuben"}, AdventureFuben.MIN_PLAYER_COUNT);
end

function AdventureFuben:QTCanShow()
    return self:CanEnterFubenCommon(me);
end

function AdventureFuben:QTCanJoin()
    return self:CheckPlayerCanEnterFuben(me);
end

function AdventureFuben:QTCheckEnter()
    return self:CheckCanCreateFuben(me);
end

function AdventureFuben:QTEnterFuben()
    return self:CreateFuben(me.dwID);
end

function AdventureFuben:CanEnterFubenCommon(pPlayer)
    if pPlayer.nLevel < self.MIN_LEVEL then
        return false, string.format("等級不足%d，無法參加山賊秘窟", self.MIN_LEVEL)
    end

    return true
end

function AdventureFuben:CheckPlayerCanEnterFuben(pPlayer)
    local bResult, szMsg = self:CanEnterFubenCommon(pPlayer);
    if not bResult then
        return false, szMsg;
    end

    if DegreeCtrl:GetDegree(pPlayer, "AdventureFuben") < 1 then
        return false,  self.ACTIVITY_NAME .. "次數不足";
    end

    if pPlayer.CheckNeedArrangeBag() then
        return false, "背包道具數量過多，請整理一下";
    end

    if not Fuben.tbSafeMap[pPlayer.nMapTemplateId] and Map:GetClassDesc(pPlayer.nMapTemplateId) ~= "fight" then
        return false, "所在地圖不允許進入副本";
    end

    if Map:GetClassDesc(pPlayer.nMapTemplateId) == "fight" and pPlayer.nFightMode ~= 0 then
        return false, "不在安全區，不允許進入副本";
    end

    return true;
end

function AdventureFuben:CheckCanCreateFuben(pPlayer)
    if not Env:CheckSystemSwitch(pPlayer, Env.SW_AdventureFuben) then
        return false, "目前狀態不允許參加"
    end
    
    local tbMember = TeamMgr:GetMembers(pPlayer.dwTeamID);
    if not tbMember or #tbMember <= 0 then
        tbMember = { pPlayer.dwID };
    end

    local teamData = TeamMgr:GetTeamById(pPlayer.dwTeamID);
    if teamData and teamData.nCaptainID ~= pPlayer.dwID then
        return false, "只有隊長才可以開啟副本！";
    end

    if #tbMember < self.MIN_PLAYER_COUNT then
        return false, string.format("隊伍人數不足 %d，無法開啟副本！", self.MIN_PLAYER_COUNT), tbMember;
    end

    if #tbMember > self.MAX_PLAYER_COUNT then
        return false, string.format("隊伍人數超過 %d，無法開啟副本！", self.MAX_PLAYER_COUNT), tbMember;
    end

    for _, nPlayerId in pairs(tbMember) do
        local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
        if not pPlayer then
            return false, "未知隊伍成員，無法開啟副本！", tbMember;
        end

        local bRet, szMsg = self:CheckPlayerCanEnterFuben(pPlayer);
        if not bRet then
            return false, "「" .. pPlayer.szName .. "」" .. szMsg, tbMember;
        end
    end

    return true, "", tbMember
end

function AdventureFuben:CreateFuben(dwID)
    local pPlayer = KPlayer.GetPlayerObjById(dwID)
    if not pPlayer then
        Log("[AdventureFuben CreateFuben] Warning, Player Maybe Offline:", dwID)
        return
    end

    local function fnAllMember(tbMember, fnSc, ...)
        for _, nPlayerId in pairs(tbMember or {}) do
            local pMember = KPlayer.GetPlayerObjById(nPlayerId)
            if pMember then
                fnSc(pMember, ...)
            end
        end
    end

    local function fnMsg(pPlayer, szMsg)
        pPlayer.CenterMsg(szMsg)
    end

    local bRet, szMsg, tbMember = self:CheckCanCreateFuben(pPlayer)
    if not bRet then
        fnAllMember(tbMember, fnMsg, szMsg)
        return;
    end

    local function AddImitity()
        local nMember = #tbMember
        for nIdx, nMemberId in ipairs(tbMember) do
            for nMemberIdx = nIdx + 1, nMember do
                if not tbMember[nMemberIdx] then
                    break
                end

                FriendShip:AddImitityByKind(nMemberId, tbMember[nMemberIdx], Env.LogWay_AdventureFuben)
            end
        end
    end

    local function fnSuccessCallback(nMapId)
        local function fnSucess(pPlayer, nMapId)
            pPlayer.SetEntryPoint();
            pPlayer.SwitchMap(nMapId, 0, 0);
        end
        fnAllMember(tbMember, fnSucess, nMapId);

        AddImitity()

        FriendRecall:OnAdventureFubenAward(tbMember);
        Activity:OnGlobalEvent("Act_OnJoinTeamActivity", tbMember, Env.LogWay_AdventureFuben)

    end

    local function fnFailedCallback()
        fnAllMember(tbMember, fnMsg, "創建副本失敗，請稍後嘗試！");
    end

    Fuben:ApplyFuben(pPlayer.dwID, self.MAP_TEMPLATEID, fnSuccessCallback, fnFailedCallback, pPlayer.dwID)
    return true
end

--[[
    直接进入奇遇秘境指令
    local dwID = me.dwID
    local pPlayer = KPlayer.GetPlayerObjById(dwID)
    local function fnSuccessCallback(nMapId)
        pPlayer.SetEntryPoint();
        pPlayer.SwitchMap(nMapId, 0, 0);
    end

    local function fnFailedCallback()
        pPlayer.CenterMsg("创建副本失败，请稍后尝试！");
    end

    Fuben:ApplyFuben(dwID, 500, fnSuccessCallback, fnFailedCallback)
]]
