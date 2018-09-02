local tbNpc = Npc:GetClass("ImperialTombEmperorMirror");

function tbNpc:OnDeath(pKillNpc)
	--[[local nMapId,_,_ = him.GetWorldPos();
	ImperialTomb:OnMirrorMapEnd(nMapId, him.nId)]]
end

function tbNpc:OnByAttack()
	ImperialTomb:AddEmperorJoinInfo(me)
end
