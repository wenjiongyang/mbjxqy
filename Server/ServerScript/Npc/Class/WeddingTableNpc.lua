local tbNpc = Npc:GetClass("WeddingTableNpc")

function tbNpc:OnDialog(szParam)
	local tbInst = Fuben.tbFubenInstance[me.nMapId]
	if not tbInst then
		me.CenterMsg("婚禮已經結束", true)
		return
	end
	if tbInst.nProcess ~= Wedding.PROCESS_WEDDINGTABLE then
		me.CenterMsg("當前階段不可食用", true)
		return
	end
	local nEatCount = tbInst.tbEatPlayer[tbInst.nFoodCount][me.dwID] or 0
	if nEatCount >= Wedding.nMaxDinnerEat then
		me.CenterMsg("你已經品嘗過這道菜了", true)
		return
	end
	local pNpc = me.GetNpc()
	if pNpc then
		if tbInst.tbRole[me.dwID] then
			pNpc.DoCommonAct(Wedding.nDinnerRoleActionID, 10002, 1, 0, 1);
		else
			pNpc.DoCommonAct(Wedding.nDinnerActionID, 10002, 1, 0, 1);
		end
	end
	me.CallClientScript("Wedding:TryEatFood", him.nId)
end

function tbNpc:OnEndProgress(dwID, nNpcId)
	local pPlayer = KPlayer.GetPlayerObjById(dwID)
	if not pPlayer then
		return
	end
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		pPlayer.CenterMsg("這道菜已經被人吃完了", true)
		return;
	end
	local tbInst = Fuben.tbFubenInstance[pNpc.nMapId]
	if not tbInst then
		pPlayer.CenterMsg("婚禮已經結束", true)
		return
	end
	tbInst:TryEat(pPlayer)
end

function tbNpc:OnBreakProgress(nPlayerId, nNpcId)

end 