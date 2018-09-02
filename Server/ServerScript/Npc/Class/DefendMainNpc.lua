local tbNpc = Npc:GetClass("DefendMainNpc");

function tbNpc:OnDeath(pKiller)
	if not MODULE_GAMESERVER then
		return;
	end

	Fuben:OnKillNpc(him, pKiller);
	Fuben:NpcUnLock(him);
end

function tbNpc:OnEarlyDeath(pKiller)
	if MODULE_GAMESERVER then
		return;
	end
	
	Fuben:OnKillNpc(him, pKiller);
	Fuben:NpcUnLock(him);
end

function tbNpc:OnCreate()
	if not MODULE_GAMESERVER then
		return;
	end

	Fuben:OnNpcCreate(him)
end