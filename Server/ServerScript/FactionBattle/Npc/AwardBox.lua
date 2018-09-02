local tbNpc = Npc:GetClass("FactionAwardBox")

function tbNpc:OnCreate(szParam)
	Timer:Register(Env.GAME_FPS * FactionBattle.BOX_EXSIT_TIME, self.TimeUp, self, him.nId);
end

function tbNpc:OnDialog()
	if FactionBattle:GetBoxAwardCount(me.dwID) >= FactionBattle.BOX_MAX_GET  then
		Dialog:SendBlackBoardMsg(me, string.format(XT("本次競技每人最多可以開啟%s個寶箱"), FactionBattle.BOX_MAX_GET));
		return;
	end
	GeneralProcess:StartProcess(me, FactionBattle.PICK_BOX_TIME * Env.GAME_FPS, "開啟中...", self.EndProcess, self, me.dwID, him.nId);
end

function tbNpc:EndProcess(nPlayerId, nNpcId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end

	local pNpc = KNpc.GetById(nNpcId);

	if not pNpc then
		return;
	end

	if FactionBattle:GetBoxAwardCount(me.dwID) >= FactionBattle.BOX_MAX_GET  then
		return;
	end

	local nAwardId = FactionBattle:GetBoxAwardId()
	if nAwardId then
		local nRet, szMsg, tbAward = Item:GetClass("RandomItem"):RandomItemAward(me, nAwardId, "FactionBattleBox");
		if nRet == 1 then
			FactionBattle:AddBoxAwardRecord(me.dwID);
			me.SendAward(tbAward, true, false, Env.LogWay_FactionBattleBox);
			pNpc.Delete();
		end
	end
end

function tbNpc:TimeUp(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);

	if not pNpc then
		return;
	end

	pNpc.Delete();
end