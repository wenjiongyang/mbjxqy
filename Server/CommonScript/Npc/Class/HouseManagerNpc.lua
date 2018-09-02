
local tbNpc = Npc:GetClass("HouseManagerNpc");

function tbNpc:OnDialog()
	local szText = Npc:GetRandomTalk(him.nTemplateId, me.nMapTemplateId);
	szText = szText or "這位元俠士，你需要建房麼？";
	
	if me.nHouseState ~= 1 and Task:GetTaskFlag(me, House.nFinishHouseTaskId) == 1 then
		Dialog:Show(
		{
			Text	= "這位元俠士，你需要建房麼？",
			OptList = {{ Text = "獲得家園", Callback = function ()
				House:Create(me, 1);
			end, Param = {}}},
		}, me, him);
		return;
	end

	for _, nTaskId in pairs(House.tbAllHouseTask) do
		if Task:GetPlayerTaskInfo(me, nTaskId) then
			szText = "大俠，不知所托之事如何了？切莫耽誤了家園建造進度……";
			break;
		end
	end

	local tbDlg = {};

	if House:CheckOpen(me) then
		if Task:GetPlayerTaskInfo(me, House.nSecondHouseTaskId) then
			table.insert(tbDlg, { Text = "建造家園", Callback = function ()
				Task:DoAddExtPoint(me, House.nSecondHouseTaskId, 1);
			end, Param = {}});

			szText = "這位元俠士，你需要建房麼？";
		end

		local tbHouse = House:GetHouse(me.dwID);
		if tbHouse and tbHouse.nStartLeveupTime then
			local tbSetting = House.tbHouseSetting[tbHouse.nLevel];
			if tbHouse.nStartLeveupTime + tbSetting.nLevelupTime <= GetTime() then
				szText = "大俠，您的家園升級擴建已經完成了哦！";
				table.insert(tbDlg, { Text = "好的，有勞姑娘。[FFFE0D]（完成家園升級）[-]", Callback = self.DoHouseLevelup, Param = {self} });
			end
		end

		if tbHouse then
			table.insert(tbDlg, { Text = "我要回家", Callback = self.GoHome, Param = {self} })
		end
	end

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

function tbNpc:DoHouseLevelup()
	House:DoLevelUp(me);
end

function tbNpc:GoHome()
	House:GoMyHome(me);
end

function tbNpc:GotoSampleHouse(nMapTemplateId)
	SampleHouse:EnterSampleHouse(me, nMapTemplateId);
end
