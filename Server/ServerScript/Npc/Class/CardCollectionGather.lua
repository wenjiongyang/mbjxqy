local tbNpc = Npc:GetClass("CardCollectionGather")

function tbNpc:OnCreate()
    him.nGatheredTimes = 0
    him.tbOpenPlayer = {}
end

function tbNpc:OnDialog(szParam)
    if him.IsDelayDelete() then
        return
    end

    if him.tbOpenPlayer[me.dwID] then
        me.CenterMsg("您已經獲取過道具了")
        return
    end

    local tbParams = Lib:SplitStr(him.szScriptParam, "|")
    local nCardId = tonumber(tbParams[1])
    local nWaitTime = tonumber(tbParams[3] or 5)
    GeneralProcess:StartProcess(me, nWaitTime*Env.GAME_FPS, "開啟中", self.EndProcess, self, me.dwID, him.nId, nCardId)
end

function tbNpc:EndProcess(nPlayerId, nNpcId, nCardTemplateId)
    local pNpc = KNpc.GetById(nNpcId)
    local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
    if not pNpc or pNpc.IsDelayDelete() or not pPlayer then
        return
    end

    local tbParams = Lib:SplitStr(pNpc.szScriptParam, "|")
    local nCanGatherTimes = tonumber(tbParams[2] or 1)
    if pNpc.nGatheredTimes >= nCanGatherTimes then
        return
    end

    pNpc.nGatheredTimes = pNpc.nGatheredTimes + 1
    if pNpc.nGatheredTimes >= nCanGatherTimes then
        pNpc.Delete()
    end
    pNpc.tbOpenPlayer[nPlayerId] = true
    CollectionSystem:AddCard(pPlayer, nCardTemplateId, CollectionSystem.GATHER)
end