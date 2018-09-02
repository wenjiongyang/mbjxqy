local tbNpc = Npc:GetClass("ImperialTombLeader");
--只用来加经验的
local tbFieldNpc = Npc:GetClass("FieldMapNpc");

function tbNpc:DeathCalcAward(pNpc, tbDamageInfo, pKiller)
	local tbPlayer = Npc:GetDamageFirstTeam(pNpc, tbDamageInfo);
	if  tbPlayer and #tbPlayer > 0 then
		ImperialTomb:OnLeaderDeath(pNpc, tbDamageInfo, pKiller, tbPlayer)
	end

	local nMaxPos = #tbDamageInfo;
	if nMaxPos > tbFieldNpc.nMaxRankPos then
		nMaxPos = tbFieldNpc.nMaxRankPos;
	end

	local pFirstPlayer, tbFirstPlayer
	local nExperience = pNpc.GetExperience();
	if nExperience > 0 then
		pFirstPlayer, tbFirstPlayer = tbFieldNpc:CalcDeathExp(pNpc, tbDamageInfo, nMaxPos, pKiller, true)
	else
		local nFixExperience = pNpc.GetFixExperience();
		if nFixExperience > 0 then
			pFirstPlayer, tbFirstPlayer = tbFieldNpc:CalcDeathFixExp(pNpc, tbDamageInfo, nMaxPos, pKiller, true)
		end
	end
	
	if tbFirstPlayer then
		local nTotalCount = #tbFirstPlayer;
		if nTotalCount >= 2 then
			for nI = 1, nTotalCount - 1 do
				for nJ = nI + 1, nTotalCount do
					local nPlayer1 = tbFirstPlayer[nI].pPlayer.dwID;
					local nPlayer2 = tbFirstPlayer[nJ].pPlayer.dwID;
					FriendShip:AddImitityByKind(nPlayer1, nPlayer2, Env.LogWay_ImperialTomb_Leader);
				end
			end
		end
	end
end