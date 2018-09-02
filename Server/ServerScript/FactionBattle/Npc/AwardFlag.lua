local tbNpc = Npc:GetClass("FactionAwardFlag")

function tbNpc:OnCreate(szParam)
	Timer:Register(Env.GAME_FPS * FactionBattle.FLAG_EXIST_TIME, self.TimeUp, self, him.nId);
end

function tbNpc:OnDialog()
	local tbTemp = him.tbFactionBattle;
	if not tbTemp or tbTemp.nWinnerId ~= me.dwID then
		return 0;
	end

	GeneralProcess:StartProcess(me, FactionBattle.PICK_BOX_TIME * Env.GAME_FPS, "發獎中...", self.EndProcess, self, me.dwID, him.nId);
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

	local tbTemp = pNpc.tbFactionBattle;
	if not tbTemp or tbTemp.nWinnerId ~= nPlayerId then
		return;
	end

	local nMapId = pNpc.nMapId;

	pNpc.Delete();

	tbTemp.tbGame:ExcuteAwardChampion();
end

function tbNpc:TimeUp(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);

	if not pNpc then
		return;
	end

	local tbTemp = pNpc.tbFactionBattle;
	if not tbTemp then
		return;
	end

	pNpc.Delete();

	tbTemp.tbGame:ExcuteAwardChampion();
end