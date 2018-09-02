local tbNpc = Npc:GetClass("ImperialTombBoss");

function tbNpc:OnDeath(pKillNpc)
	ImperialTomb:OnBossDeath(him, pKillNpc)
end

function tbNpc:OnByAttack()
	ImperialTomb:AddEmperorJoinInfo(me)
	ImperialTomb:OnBossAttack()
end