local tbItem = Item:GetClass("ProposeItem");

function tbItem:OnUse(it)	
end

function tbItem:OnClientUse(it)
    if not Wedding:CheckOpenProposeTime() then
        me.CenterMsg("暫未開放", true)
        return 1
    end
    local tbTeam = TeamMgr:GetTeamMember()
    if #tbTeam ~= 1 then
        me.CenterMsg("需與一名[FFFE0D]異性角色[-]組成[FFFE0D]2人[-]隊伍哦")
        return 1
    end
    local nMySex = Gift:CheckSex(me.nFaction)
    local nTeammateSex = Gift:CheckSex((tbTeam[1] or {}).nFaction)
    if not nMySex or not nTeammateSex or nMySex == nTeammateSex then
         me.CenterMsg("需與一名[FFFE0D]異性角色[-]組成[FFFE0D]2人[-]隊伍哦")
        return 1
    end
     local bRet, szMsg = Wedding:CheckProposeC(me, tbTeam[1].nPlayerID)
    if not bRet then
        me.CenterMsg(szMsg, true)
        return 
    end

    local fnSure = function (nPlayerID)
        local bRet, szMsg = Wedding:CheckProposeC(me, nPlayerID)
        if not bRet then
            me.CenterMsg(szMsg, true)
            return 
        end
       RemoteServer.OnWeddingRequest("TryChoosePropose");
    end
    me.MsgBox(string.format("你已經準備好向[FFFE0D]%s[-]求婚了嗎？", tbTeam[1].szName or ""), {{"求婚", fnSure, tbTeam[1].nPlayerID}, {"取消"}})
    return 1
end

