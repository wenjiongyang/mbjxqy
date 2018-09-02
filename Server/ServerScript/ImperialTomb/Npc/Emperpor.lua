local tbNpc = Npc:GetClass("ImperialTombEmperor");

function tbNpc:OnDeath(pKillNpc)
	ImperialTomb:OnEmperorDeath(him, pKillNpc)
end

function tbNpc:OnByAttack()
	ImperialTomb:AddEmperorJoinInfo(me)
	ImperialTomb:OnEmperorAttack()
end
