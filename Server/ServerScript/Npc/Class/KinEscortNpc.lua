local tbNpc = Npc:GetClass("KinEscortNpc");

function tbNpc:OnCreate(szParam)
end

function tbNpc:OnDialog(szParam)
	if me.dwKinId ==0 then
		Dialog:Show({Text = "未加入幫派，無法參與活動", OptList = {}}, me, him);
		return;
	end

	if not KinEscort:IsOpen() then
		Dialog:Show({Text = "活動未開啟", OptList = {}}, me, him);
		return;
	end

	local tbKin = Kin:GetKinById(me.dwKinId);
	local nMasterID = tbKin:GetMasterId();
 	local tbAssistantMasterIDs = tbKin:GetCareerMemberIds(Kin.Def.Career_ViceMaster);
 	local nAssistantMasterID = tbAssistantMasterIDs[1] or 0;
 	if me.dwID ~= nMasterID and me.dwID ~= nAssistantMasterID then
		Dialog:Show({Text = "只有堂主和副堂主才可以接鏢", OptList = {}}, me, him);
 		return;
 	end

	local OptList = {};
 	local tbEscortData = KinEscort:GetKinEscortData(me.dwKinId);
	if tbKin:GetLastKinEscortDate()~=Lib:GetLocalDay() and tbEscortData.nState==KinEscort.States.beforeAfter then
		table.insert(OptList,{ Text = "接鏢", Callback = KinEscort.OnAcceptEscortTask, Param = {KinEscort, me.dwID, tbKin, him}});
	end

	if tbKin:GetLastKinEscortDate()==Lib:GetLocalDay() and tbEscortData.nState==KinEscort.States.prepare then
		local pCarriageNpc = KNpc.GetById(tbEscortData.nCarriageNpcId);
		if pCarriageNpc and pCarriageNpc.nQuality < #KinEscort.tbNpcTemplate then 
			table.insert(OptList,{ Text = "鏢車升階", Callback = KinEscort.OnUpgrade, Param = {KinEscort, me.dwID, me.dwKinId}});
		end

		table.insert(OptList,{ Text = "開始運鏢", Callback = KinEscort.StartEscortAndStartAddExp, Param = {KinEscort, me.dwKinId}});
	end

	Dialog:Show({
	    Text    = KinEscort.szNpcTips,
	    OptList = OptList,
	}, me, him);
end
