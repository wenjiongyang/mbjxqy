
local function fnAllMember(tbMember, fnSc, ...)
    for _, nPlayerId in pairs(tbMember or {}) do
        local pMember = KPlayer.GetPlayerObjById(nPlayerId);
        if pMember then
            fnSc(pMember, ...);
        end
    end
end

local function fnMsg(pPlayer, szMsg)
    pPlayer.CenterMsg(szMsg);
end

function IdiomFuben:CheckCanEnter(pTarget)
    local tbTeamMember = TeamMgr:GetMembers(pTarget.dwTeamID)

    local bInProcess = Activity:__IsActInProcessByType("IdiomsAct")
    if not bInProcess then
        return false,"活動未開放",tbTeamMember
    end

    if pTarget.dwTeamID == 0 then
        return false, "請組成兩人隊伍再來",tbTeamMember
    end
  
    if #tbTeamMember ~= IdiomFuben.JOIN_MEMBER_COUNT then
        return false, string.format("隊伍人數必須為%d人",IdiomFuben.JOIN_MEMBER_COUNT),tbTeamMember
    end

    local tbTeam = TeamMgr:GetTeamById(pTarget.dwTeamID)
    local nCaptainId = tbTeam:GetCaptainId();
    if nCaptainId ~= pTarget.dwID then
    	return false,"隊長才有許可權報名",tbTeamMember
    end

    local bRet,szMsg = self:CheckDistance(pTarget)
    if not bRet then
        return false,szMsg
    end

    table.sort(tbTeamMember, function (a, b)
        return a == pTarget.dwID and b ~= pTarget.dwID
    end)

    local tbSecOK = {}
    for nIdx, nPlayerId in ipairs(tbTeamMember) do
        local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
        if not pPlayer then
            return false, "沒找到玩家",tbTeamMember
        end

        if pPlayer.nLevel < IdiomFuben.JOIN_LEVEL then
            return false, string.format("「%s」不足%d級",pPlayer.szName, IdiomFuben.JOIN_LEVEL),tbTeamMember
        end

        tbSecOK[nIdx] = Gift:CheckSex(pPlayer.nFaction)
        if DegreeCtrl:GetDegree(pPlayer, "Idioms") <= 0 then
            return false,string.format("「%s」次數不足",pPlayer.szName),tbTeamMember
        end
    end
    if tbSecOK[1] == tbSecOK[2] then
        return false, "必須異性組隊",tbTeamMember
    end

    return true,nil,tbTeamMember
end

function IdiomFuben:CheckDistance(pPlayer)
    local tbTeamMember = TeamMgr:GetMembers(pPlayer.dwTeamID)
    local pPlayer1 = KPlayer.GetPlayerObjById(tbTeamMember[1])
    local pPlayer2 = KPlayer.GetPlayerObjById(tbTeamMember[2])
    local nMapId1, nX1, nY1 = pPlayer1.GetWorldPos()
    local nMapId2, nX2, nY2 = pPlayer2.GetWorldPos()

    local szName = ""
    if pPlayer1.dwID == me.dwID then
        szName = pPlayer2.szName
    elseif pPlayer2.dwID == me.dwID then
         szName = pPlayer1.szName
    end

    if nMapId1 ~= nMapId2 then
        return false, string.format("隊友%s不在本地圖",szName)
    end

    local fDists = Lib:GetDistsSquare(nX1, nY1, nX2, nY2)
    if fDists > (self.MIN_DISTANCE * self.MIN_DISTANCE) then
        return false, string.format("隊友%s不在附近",szName)
    end

    return true
end


function IdiomFuben:TryCreateFuben(pPlayer)

    local bRet, szMsg,tbMember = self:CheckCanEnter(pPlayer);
    if not bRet then
        if not tbMember or not next(tbMember) then
            pPlayer.CenterMsg(szMsg)
        else
            fnAllMember(tbMember, fnMsg, szMsg);
        end
       ChatMgr:SendTeamOrSysMsg(pPlayer, szMsg)
       return;
    end

    local function fnSuccessCallback(nMapId)
        local function fnSucess(pPlayer, nMapId)
            pPlayer.SetEntryPoint();
            pPlayer.SwitchMap(nMapId, 0, 0);
        end
        fnAllMember(tbMember, fnSucess, nMapId);
    end

    local function fnFailedCallback()
        fnAllMember(tbMember, fnMsg, "創建副本失敗，請稍後嘗試！");
    end

    Fuben:ApplyFuben(pPlayer.dwID, IdiomFuben.nFubenMapTemplateId, fnSuccessCallback, fnFailedCallback);

    return true;
end