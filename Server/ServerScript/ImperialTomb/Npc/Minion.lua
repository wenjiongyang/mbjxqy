local tbNpc = Npc:GetClass("ImperialTombMinion");
--只用来加经验的
local tbFieldNpc = Npc:GetClass("FieldMapNpc");

function tbNpc:DeathCalcAward(pNpc, tbDamageInfo, pKiller)

	local nMaxPos = #tbDamageInfo;
	if nMaxPos > tbFieldNpc.nMaxRankPos then
		nMaxPos = tbFieldNpc.nMaxRankPos;
	end

	local nExperience = pNpc.GetExperience();
	if nExperience > 0 then
		tbFieldNpc:CalcDeathExp(pNpc, tbDamageInfo, nMaxPos, pKiller, true)
	else
		local nFixExperience = pNpc.GetFixExperience();
		if nFixExperience > 0 then
			tbFieldNpc:CalcDeathFixExp(pNpc, tbDamageInfo, nMaxPos, pKiller, true)
		end
	end
end