local tbNpc = Npc:GetClass("IndifferBattleNpc")

function tbNpc:OnDeath(pKiller)
	InDifferBattle:OnNpcDeath(him, pKiller)
end