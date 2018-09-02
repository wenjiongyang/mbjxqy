local tbMap = Map:GetClass(TeamBattle.PRE_MAP_ID);
function tbMap:OnCreate(nMapId)
	local tbInst = TeamBattle.tbTeamBattleMgrInstByMapId[nMapId];
	if not tbInst then
		Log("[TeamBattle] ERR ?? unknow pre map !! ", nMapId);
		Lib:LogTB(TeamBattle.tbTeamBattleMgrInstByMapId);
		return;
	end

	tbInst:OnCreatePreMap(nMapId);
end

function tbMap:OnEnter(nMapId)
	local tbInst = TeamBattle.tbTeamBattleMgrInstByMapId[nMapId];
	if not tbInst then
		Log("[TeamBattle] ERR ?? unknow pre map !! ", nMapId);
		return;
	end

	tbInst:OnEnterPreMap();
end

function tbMap:OnLeave(nMapId)
	local tbInst = TeamBattle.tbTeamBattleMgrInstByMapId[nMapId];
	if not tbInst then
		return;
	end

	tbInst:OnLeavePreMap();
end
