local tbNpc = Npc:GetClass("MuBeiNpc");

function tbNpc:OnDialog()
	local tbOptList = {
		{Text = "查看石碑", Callback = self.TryWorship, Param = {self, him.nId, me.dwID}}
	}
	 Dialog:Show(
    {
        Text    = "一塊看起來飽經風霜的古樸石碑，上面的文字已經有些模糊，但卻依然屹立不倒",
        OptList = tbOptList,
    }, me, him);
end

function tbNpc:TryWorship(nNpcID, dwID)
	local pNpc = KNpc.GetById(nNpcID);
    if not pNpc then
        Log("MuBeiNpc Not Npc", nNpcID, dwID);
        return;
    end

    local pPlayer = KPlayer.GetPlayerObjById(dwID)
    if not pPlayer then
    	return
    end

    local tbInst = Fuben.tbFubenInstance[pNpc.nMapId];
    if tbInst then
    	if tbInst.bStart then
    		pPlayer.CenterMsg("已經查看過石碑")
    		return 
    	end
    	if tbInst.nUsePlayerId ~= dwID then
    		pPlayer.CenterMsg("需要擁有地圖進入此地的人才能查看哦")
    		return 
    	end
        tbInst:StartWorship(dwID)
    else
        Log("MuBeiNpc Not tbInst", nNpcID, dwID, pNpc.nMapId);
    end
end