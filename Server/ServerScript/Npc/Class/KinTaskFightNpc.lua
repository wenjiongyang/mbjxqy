local tbNpc = Npc:GetClass("KinTaskFightNpc");
tbNpc.nTimeout = 60 * 10;
function tbNpc:OnCreate()
	him.nTimerId = Timer:Register(self.nTimeout * Env.GAME_FPS, self.OnTimeout, self, him.nId);
end

function tbNpc:OnDeath()
	Timer:Close(him.nTimerId);
	him.nTimerId = nil;

	KNpc.Add(him.nCurNpctemplateId, 10, 0, him.nCurMapId, him.nCurX, him.nCurY, 0);
end

function tbNpc:OnTimeout(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return;
	end

	KNpc.Add(pNpc.nCurNpctemplateId, 10, 0, pNpc.nCurMapId, pNpc.nCurX, pNpc.nCurY, 0);
	pNpc.Delete();
end
