local tbNpc = Npc:GetClass("KinRobber");

function tbNpc:OnCreate(szParam)
	
end

function tbNpc:OnDialog(szParam)
	Dialog:Show(
	{
	    Text    = "看什麼看？再不離去別怪小爺對你不客氣！",
	    OptList = {
	        { Text = "小賊，看打！", Callback = self.StartFightRobber, Param = {self, me.dwID, him.nId}},
			{ Text = "賊匪兇悍，先行離開"},
	    },
	}, me, him)
end

function tbNpc:StartFightRobber(nPlayerId, nNpcId)
	local player = KPlayer.GetPlayerObjById(nPlayerId or 0);
	local pNpc = KNpc.GetById(nNpcId or 0);
	if not pNpc or not player then
		return;
	end

	local team = TeamMgr:GetTeamById(player.dwTeamID);
	if not team then
		player.CenterMsg("隊伍人數需[FFFE0D]≥2人[FFFE0D]");
		return;
	end

	if player.dwID ~= team:GetCaptainId() then
		player.CenterMsg("您不是隊長");
		return;
	end

	local nInMapMemberCount = 0;
	local tbTeamMembers = team:GetMembers();
	for _, nMemberId in pairs(tbTeamMembers) do
		local member = KPlayer.GetPlayerObjById(nMemberId);
		if member then
			if member.nMapId == player.nMapId and member.dwKinId == player.dwKinId then
				nInMapMemberCount = nInMapMemberCount + 1;
			end
		end
	end

	if nInMapMemberCount < 2 then
		player.CenterMsg("需要隊伍本地圖人數≥2人");
		return;
	end
	
	local function fDo()
		local nKinId = pNpc.nRobberKinId;
		local kinData = nKinId and Kin:GetKinById(nKinId);
		local bSuccess = Kin.KinNest:OnKinRobberActivate(pNpc, player.dwTeamID, player.dwKinId, player);
		if bSuccess == false and kinData then
			kinData:OnKinRobberActivate(pNpc, player.dwTeamID, player);
		end
	end

	if player.nMapTemplateId~=Kin.Def.nKinNestMapTemplateId and DegreeCtrl:GetDegree(player, "KinRobReward")<1 then
		player.MsgBox("今日已無剩餘領獎次數，可以把機會留給幫派中需要的弟兄，是否仍要繼續挑戰？",
					{{"確定", fDo}, {"取消"}})
	else
		fDo()
	end
end

function tbNpc:OnDeath(pKiller)
	local nKinId = him.nRobberKinId;
	local kinData = nKinId and Kin:GetKinById(nKinId);
	if not kinData then
		local tbFubenDeath = Npc:GetClass("FubenDeath");
		tbFubenDeath:OnDeath(pKiller);
		return;
	end

	kinData:OnRobberDeath(him, pKiller.nPlayerID);
end