local tbNpc = Npc:GetClass("ImperialTombNormalBoss");

function tbNpc:OnDeath(pKillNpc)
	local nAwardId = ImperialTomb.NORMAL_BOSS_AWARD_ID[him.nTemplateId]
	if nAwardId then
		RandomAward:SendRankAwardByNpc(nAwardId, him, Env.LogWay_ImperialTomb_Normal_Boss)
	end
end
