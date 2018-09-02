local tbNpc = Npc:GetClass("ConcentricFruitNpc");

function tbNpc:OnDialog()
	local tbPlayer = him.tbTmp and him.tbTmp.tbPlayer
	if not tbPlayer then
		return
	end
	if not tbPlayer[me.dwID] then
		me.CenterMsg("當前是新郎、新娘的小遊戲環節，賓客只需圍觀起哄！")
		return
	end
	GeneralProcess:StartProcessExt(me, Wedding.nConcentricFruitWaitTime * Env.GAME_FPS, true, 0, 0, "食用中", {self.OnEndProgress, self, me.dwID, him.nId}, {self.OnBreakProgress, self, me.dwID, him.nId});
end

function tbNpc:OnEndProgress(nPlayerId, nNpcId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return;
	end
	local tbPlayer = pNpc.tbTmp and pNpc.tbTmp.tbPlayer
	if not tbPlayer or not tbPlayer[nPlayerId] then
		return
	end
	local nMapId = pNpc.nMapId
	if pPlayer.nMapId ~= nMapId then
		return;
	end
	local nNowTime = GetTime()
	pNpc.tbTmp.tbTime = pNpc.tbTmp.tbTime or {}
	pNpc.tbTmp.tbTime[nPlayerId] = nNowTime
	local nOtherPlayerId = self:GetOtherPlayerId(tbPlayer, nPlayerId) or 0
	local pOtherPlayer = KPlayer.GetPlayerObjById(nOtherPlayerId)
	if not pOtherPlayer then
		pPlayer.CenterMsg("找不到另一半？？", true)
		return
	end
	local tbInst = Fuben.tbFubenInstance[nMapId];
	if not tbInst then
		return
	end
	local nOtherTime = pNpc.tbTmp.tbTime[nOtherPlayerId]
	if not nOtherTime then
		Dialog:SendBlackBoardMsg(pPlayer, "對方正在食用，請等待結果");
		return 
	end
	if nNowTime - nOtherTime <= Wedding.nConcentricFruitHitTime then
		pNpc.tbTmp.bSuccess = true
		tbInst:ConcentricFruitSuccess(pNpc)
	else
		-- 防止刚喊完失败就成功(延迟宣布结果)
		Timer:Register(Env.GAME_FPS * Wedding.nConcentricFruitHitTime, self.CheckFail, self, pNpc.nId);
	end
end

function tbNpc:CheckFail(nNpcId)
	-- 成功会删掉NPC,成功则不提示失败
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc or pNpc.tbTmp.bSuccess then
		return;
	end
	local tbInst = Fuben.tbFubenInstance[pNpc.nMapId];
	if not tbInst then
		return
	end

	tbInst:ConcentricFruitFail(pPlayer)
	pNpc.tbTmp.tbTime = nil
end

function tbNpc:GetOtherPlayerId(tbPlayer, nPlayerId)
	if not tbPlayer[nPlayerId] then
		return
	end
	local nCount = 0
	local nOtherPlayerId
	for dwID in pairs(tbPlayer or {}) do
		nCount = nCount + 1
		if dwID ~= nPlayerId then
			nOtherPlayerId = dwID
		end
	end
	return nCount == 2 and nOtherPlayerId
end

function tbNpc:OnBreakProgress(nPlayerId, nNpcId)

end
