local tbNpc = Npc:GetClass("DefendAssistDialog");

function tbNpc:OnDialog()
    
    Dialog:Show(
    {
        Text    = "是否需要我來協助你對抗敵人？",
        OptList = {
            { Text = "請助我一臂之力！", Callback = self.Active, Param = {self, him.nId,me.dwID} },
            { Text = "暫時不用"},
        };
    }, me, him);
end

function tbNpc:Active(nNpcID,dwID)
    local pNpc = KNpc.GetById(nNpcID);
    if not pNpc then
        Log("DefendAssist Accept Not Npc",nNpcID,dwID);
        return;
    end
    local tbInst = Fuben.tbFubenInstance[pNpc.nMapId];
    if tbInst then
        tbInst:ActiveNpc(nNpcID,dwID)
    else
        Log("DefendAssist Accept Not tbInst",nNpcID,dwID,pNpc.nMapId);
    end
end