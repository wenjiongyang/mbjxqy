local tbNpc = Npc:GetClass("GatherBox")

--直接执行，不走对话框形式，所以没用Activity:RegisterNpcDialog
function tbNpc:OnDialog()
    Activity:OnPlayerEvent(me, "Act_TryOpenGatherBox", him)
end