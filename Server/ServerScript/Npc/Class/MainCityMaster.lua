local tbNpc = Npc:GetClass("MainCityMaster")

function tbNpc:OnDialog(szParam)
	local nTargetFaction = tonumber(szParam);
	if nTargetFaction ~= me.nFaction then
		return;
	end

	if DomainBattle:GetMasterLeaderId() ~= me.dwID then
		return;
	end

	me.CallClientScript("Ui:OpenWindow", "MainShowOffPanel", "MainCity");
end