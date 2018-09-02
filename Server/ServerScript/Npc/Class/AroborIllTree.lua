local tbNpc     = Npc:GetClass("AroborFlower")
function tbNpc:OnDialog()
    local nType = tonumber(him.szScriptParam) or 0
    if nType == 0 then
        local tbTmp = him.tbTmp or {}
        local bCanTalk
        for _, dwID in ipairs(tbTmp) do
            if dwID == me.dwID then
                bCanTalk = true
            end
        end
        if not Activity:__IsActInProcessByType("ArborDayCure") or not bCanTalk then
            Dialog:Show(
            {
                Text    = "這裡好冷啊",
                OptList = {},
            }, me, him)
            return 
        end
    end

    if self.fnGetTitle then
        local tbIllType = self.fnGetTitle(self.tbInst, me)
        me.CallClientScript("Ui:OpenWindow", "GrowFlowersPanel", tbIllType, nType)
    end
end

function tbNpc:OnChangeTitleActBegin(fn, tbInst)
    self.fnGetTitle = fn
    self.tbInst     = tbInst
end

function tbNpc:OnChangeTitleActEnd()
    self.fnGetTitle = nil
    self.tbInst     = nil
end

local tbDeathNpc = Npc:GetClass("AroborDeathNpc")
function tbDeathNpc:OnDeath(pKiller)
    if not him.nArborPlayer or not him.nArborLover then
        Log("AroborIllDeathNpc Not Create By Act")
        return
    end

    local pPlayer = KPlayer.GetPlayerObjById(him.nArborPlayer) or KPlayer.GetPlayerObjById(him.nArborLover)
    if not pPlayer then
        Log("AroborIllDeathNpc OnDeath Error", him.nArborPlayer, him.nArborLover)
        return
    end
    Activity:OnPlayerEvent(pPlayer, "Act_ArobrNpcEvent", "OnNpcDeath", him)
end

local tbBoxNpc = Npc:GetClass("AroborBoxOrGather")
tbBoxNpc.tbTemplate = {
    [2200] = {"安撫中...", "OnGetGather"},
    [2201] = {"採集中...", "OnGetGather"},
    [2202] = {"正在打開...", "OnBoxOpen"},
}
function tbBoxNpc:OnDialog()
    if not him.nArborPlayer or not him.nArborLover then
        Log("AroborIllBox Not Create By Act")
        return
    end

    if not self.tbTemplate[him.nTemplateId] then
        return
    end

    if me.dwID ~= him.nArborPlayer and me.dwID ~= him.nArborLover then
        return 
    end

    GeneralProcess:StartProcess(me, 30 * Env.GAME_FPS, self.tbTemplate[him.nTemplateId][1], self.EndProcess, self, me.dwID, him.nId)
end

function tbBoxNpc:EndProcess(nPlayerId, nNpcId)
    local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
    if not pPlayer then
        return
    end

    local pNpc = KNpc.GetById(nNpcId)
    if not pNpc or pNpc.IsDelayDelete() then
        return
    end
    Activity:OnPlayerEvent(pPlayer, "Act_ArobrNpcEvent", self.tbTemplate[pNpc.nTemplateId][2], pNpc)
end