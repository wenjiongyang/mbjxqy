local tbNpc = Npc:GetClass("ImperialTombBox")

function tbNpc:OnDialog()
	GeneralProcess:StartProcessExt(me, ImperialTomb.PICK_BOX_TIME * Env.GAME_FPS, 
		true, him.nId, 300, 
		"開啟中...",
		{self.EndProcess, self,
		me.dwID, him.nId});
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

	local nMapId = pNpc.nMapId

	if pPlayer.nMapId ~= nMapId then
		return;
	end

	pNpc.Delete();

	local nTeamID = pPlayer.dwTeamID
	if nTeamID and nTeamID ~= 0 then
		local tbMember = TeamMgr:GetMembers(nTeamID)
		for _,dwID in pairs(tbMember) do
			local pTmpPlayer = KPlayer.GetPlayerObjById(dwID)
			if pTmpPlayer and pTmpPlayer.nMapId == nMapId then
				pTmpPlayer.SendAward({{"item", ImperialTomb.BOX_AWARD_ID, 1}}, nil, nil, Env.LogWay_ImperialTomb_Box);
			end
		end
	else
		pPlayer.SendAward({{"item", ImperialTomb.BOX_AWARD_ID, 1}}, nil, nil, Env.LogWay_ImperialTomb_Box);
	end
end
