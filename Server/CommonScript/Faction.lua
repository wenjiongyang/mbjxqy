
Faction.MAX_JUMPSKILL_COUNT = 10;

function Faction:Init()
	local tbParam = {"nId", "szName", "szIcon", "szBigIcon", "szWordIcon", "szSelectIcon", "StatueNpc"};
	local szType = "dsssssd";
	for i = 1, self.MAX_JUMPSKILL_COUNT do
		table.insert(tbParam, "nJumpSkillId" .. i);
		szType = szType .. "d";
	end

	self.tbFactionInfo = LoadTabFile("Setting/Faction/faction.tab", szType, "nId", tbParam);
	if not self.tbFactionInfo then
		Log("error!! Load Faction info faild")
		return;
	end
end

if not Faction.tbFactionInfo then
	Faction:Init();
end

Faction.MAX_FACTION_COUNT = Lib:CountTB(Faction.tbFactionInfo);

function Faction:GetIcon(nFaction)
	local tbInfo = self.tbFactionInfo[nFaction]
	if tbInfo then
		return tbInfo.szIcon
	end
	return ""
end

function Faction:GetBigIcon(nFaction)
	local tbInfo = self.tbFactionInfo[nFaction]
	if tbInfo then
		return tbInfo.szBigIcon
	end
	return ""
end

function Faction:GetWordIcon(nFaction)
	local tbInfo = self.tbFactionInfo[nFaction]
	if tbInfo then
		return tbInfo.szWordIcon
	end
	return ""
end

function Faction:GetBGSelectIcon(nFaction)
	local tbInfo = self.tbFactionInfo[nFaction]
	if tbInfo then
		return tbInfo.szSelectIcon
	end
	return ""
end

function Faction:GetName(nFaction)
	local tbInfo = self.tbFactionInfo[nFaction]
	if tbInfo then
		return tbInfo.szName;
	end
	return ""
end

function Faction:GetJumpSkillId(nFaction, nJSkillKind)
	local tbFaction = self.tbFactionInfo[nFaction];
	assert(tbFaction);

	local nSkillId = tbFaction["nJumpSkillId" .. nJSkillKind] or 0;
	return nSkillId == 0 and tbFaction.nJumpSkillId1 or nSkillId;
end

function Faction:GetFactionStatue(nFaction)
	local tbFaction = self.tbFactionInfo[nFaction];
	return tbFaction.StatueNpc;
end
