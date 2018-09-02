local tbNpc = Npc:GetClass("SpokesmanTask")

function tbNpc:OnDialog()
    Dialog:Show(
    {
        Text    = "“寂寞雙煞”武功高強，少俠可結伴前往追捕。本人終身幸福托於少俠，盼少俠平安帶“又緣糕”歸來。",
        OptList = {
            { Text = "幫助挺師兄", Callback = self.TryAcceptTask, Param = {self, me.dwID, him.nId} },
        },
    }, me, him)
end

function tbNpc:TryAcceptTask(dwID, nNpcId)
    local pPlayer = KPlayer.GetPlayerObjById(dwID)
    if not pPlayer then
        return
    end

    Spokesman:TryAcceptTask(pPlayer, nNpcId)
end