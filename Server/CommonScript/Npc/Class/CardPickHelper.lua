local tbNpc = Npc:GetClass("CardPickHelper");

function tbNpc:OnDialog()
	local szText = "桃花桃花桃花，總是好運相伴~";
	local tbOptList = {};

	if version_tx then
		table.insert(tbOptList, { Text = "隨機機率公示", Callback = function () self:OpenCardPickProbInfo(); end});
		table.insert(tbOptList, { Text = "查看招募記錄", Callback = function () self:ShowCardPickHistory(); end});
	end

	Dialog:Show(
	{
		Text	= szText,
		OptList = tbOptList,
	}, me, him);
end

function tbNpc:OpenCardPickProbInfo()
	me.CallClientScript("Ui:OpenWindow", "CardPickRecordPanel", "Prob");
end

function tbNpc:ShowCardPickHistory()
	me.CallClientScript("Ui:OpenWindow", "CardPickRecordPanel", "History");
end