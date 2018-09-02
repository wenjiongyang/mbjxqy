local tbNpc = Npc:GetClass("FubenDeath")
function tbNpc:OnDeath(pKiller)
  if not MODULE_GAMESERVER then
    return
  end
  Fuben:OnKillNpc(him, pKiller)
  Fuben:NpcUnLock(him)
  SeriesFuben:OnKillNpc(him, pKiller)
end
function tbNpc:OnEarlyDeath(pKiller)
  if MODULE_GAMESERVER then
    return
  end
  Fuben:OnKillNpc(him, pKiller)
  Fuben:NpcUnLock(him)
end
