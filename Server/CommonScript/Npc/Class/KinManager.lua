local tbNpc = Npc:GetClass("KinManager");


function tbNpc:OnDialog()
	local tbDlg = {};

	if Task.KinTask:CheckOpen() then
		table.insert(tbDlg, { Text = "幫派任務", Callback = Task.KinTask.TryAcceptTask, Param = {Task.KinTask, me.dwID} });
	end	

	local nKinNestState = Kin.KinNest:GetKinNestState(me.dwKinId);
	if nKinNestState == 1 then
		table.insert(tbDlg, { Text = "開啟俠客島", Callback = self.DoKinNest, Param = {self} });
	elseif nKinNestState == 2 then
		table.insert(tbDlg, { Text = "前往俠客島", Callback = self.DoKinNest, Param = {self} });
	end

	local fnSelfChuanGong = function(dwID,dwKinId)
		local tbKinData = Kin:GetKinById(dwKinId) 
	    if not tbKinData then
	        return
	    end
		-- local tbLevel = Kin:GetTopMemberLevel(dwKinId,ChuangGong.nSelfChuanGongLevelRank)
		-- if not tbLevel then
		-- 	Log("[KinManager] OnDialog no tbLevel",dwID,dwKinId)
		-- 	return
		-- end
		-- local nLevel = 0
		-- for k,v in ipairs(tbLevel) do
		-- 	if v.nLevel == 0 then
		-- 		break
		-- 	end
		-- 	nLevel = v.nLevel
		-- end
		Dialog:Show(
		{
		    Text    = string.format("可以消耗[FFFE0D]1次[-]被傳功次數打坐修煉，修煉完畢後可獲得經驗。[FF6464FF]注：打坐修煉所得經驗比接受傳功所得經驗少[-]"),
		    OptList = {
		   		[1] = { Text = "開始打坐修煉", Callback = ChuangGong.SelfChuanGong, Param = {ChuangGong, dwID} },
		   		[2] = {Text = "知道了"}
		    },
		}, me, him);
	end
	table.insert(tbDlg, { Text = "打坐修鍊", Callback = fnSelfChuanGong, Param = {me.dwID,me.dwKinId} });

	table.insert(tbDlg, {Text = "知道了"});

	Dialog:Show(
	{
	    Text    = "幫派的昌盛需要依靠每一位成員的努力！",
	    OptList = tbDlg,
	}, me, him);
end

function tbNpc:Donation()
	me.CallClientScript("Ui:OpenWindow", "KinVaultPanel");
end

function tbNpc:DoKinNest()
	local nKinNestState = Kin.KinNest:GetKinNestState(me.dwKinId);
	local OnOk = function ()
	     Kin.KinNest:ApplyOpenKinNest(me);
	end

	if nKinNestState == 1 then
		me.MsgBox(string.format("俠客島危機重重，最好先確保幫派成員大多線上，開啟後將給所有成員發送推送，是否確定開啟？"), { {"確定", OnOk}, {"取消"}});
	elseif nKinNestState == 2 then
		Kin.KinNest:EnterKinNest(me.dwID);
	end
end
