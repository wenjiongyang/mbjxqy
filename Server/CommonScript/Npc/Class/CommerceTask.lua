local tbNpc = Npc:GetClass("CommerceTask")

function tbNpc:OnDialog()
	if me.nLevel < CommerceTask.START_LEVEL then
		local szDefaultText = string.format("少俠閱歷尚淺，%d級以後再來找老夫吧。", CommerceTask.START_LEVEL);
		Dialog:Show({Text = szDefaultText, OptList = {}}, me, him);
		return;
	end

	if not CommerceTask:IsTimeFrameOpen() then
		Dialog:Show({Text = "活動尚未開放，請靜候", OptList = {}}, me, him);
		return;
	end

	if CommerceTask:CanAcceptTask(me) then
		local OptList = {
			{Text = "接受", Callback = self.Accept, Param = {self}},
			{Text = "以後再說吧"},
		};
		local szDefaultText = "商會近期急缺一批貨物，不知少俠是否願意相助？";
		local tbDialogInfo = {Text = szDefaultText, OptList = OptList};
		Dialog:Show(tbDialogInfo, me, him);
	elseif CommerceTask:IsDoingTask(me) then
		CommerceTask:SyncCommerceData(me);
		local tbCommerceTask = CommerceTask:GetTaskInfo(me)
		local nFinishCount = 0
		for i = 1, 10 do
			local tbTask = tbCommerceTask.tbTask[i]
			if tbTask.bFinish then
				nFinishCount = nFinishCount + 1
			end
		end

		if nFinishCount < CommerceTask.COMPLETE_COUNT then
			me.CallClientScript("Ui:OpenWindow", "CommerceTaskPanel")
		else
			local szDefaultText = "老夫所托之事如何了？"
			local OptList = {
				{Text = "繳納貨物", Callback = CommerceTask.FinishTask, Param = {CommerceTask, me.dwID}}
			}
			local tbDialogInfo = {Text = szDefaultText, OptList = OptList};
			Dialog:Show(tbDialogInfo, me, him);
		end
	else
		local szDefaultText = "少俠今天無法再接受商會任務了";
		local tbDialogInfo = {Text = szDefaultText, OptList = {}};
		Dialog:Show(tbDialogInfo, me, him);
	end
end

function tbNpc:Accept()
	CommerceTask:AcceptTask(me);
	
	CommerceTask:SyncCommerceData(me);
	me.CallClientScript("Ui:OpenWindow", "CommerceTaskPanel")
end