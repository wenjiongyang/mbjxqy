
local tbNpc = Npc:GetClass("SampleHouseManagerNpc");

function tbNpc:OnDialog()
	local szText = Npc:GetRandomTalk(him.nTemplateId, me.nMapTemplateId);
	szText = szText or "這位元俠士，你需要建房麼？";

	local tbDlg = {};
	if House:IsTimeFrameOpen() then
		for nMapTemplateId, _ in pairs(House.tbSampleHouseSetting) do
			table.insert(tbDlg, { Text = "前往「新穎小築」", Callback = self.GotoSampleHouse, Param = { self, nMapTemplateId } });
		end
	end

	Dialog:Show(
	{
		Text	= szText,
		OptList = tbDlg,
	}, me, him);
end

function tbNpc:GotoSampleHouse(nMapTemplateId)
	SampleHouse:EnterSampleHouse(me, nMapTemplateId);
end
