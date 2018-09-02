
FriendRecall.tbWhiteList = FriendRecall.tbWhiteList or {}

function FriendRecall:OnServerStart()
	self:LoadWhiteList();
	PlayerEvent:RegisterGlobal("OnLogin", self.OnPlayerLogin, self);
end

function FriendRecall:ResetRecall(pPlayer)
	pPlayer.SetUserValue(self.Def.SAVE_GROUP, self.Def.RECALL, 0)
	pPlayer.SetUserValue(self.Def.SAVE_GROUP, self.Def.AWARD_END_TIME, 0)
	pPlayer.SetUserValue(self.Def.SAVE_GROUP, self.Def.GET_RENOWN, 0)
	pPlayer.SetUserValue(self.Def.SAVE_GROUP, self.Def.RESET_RENOWN_WEEK, 0)

	pPlayer.SetUserValue(self.Def.SAVE_GROUP, self.Def.TEAM_FUBEN_RENOWN, 0)
	pPlayer.SetUserValue(self.Def.SAVE_GROUP, self.Def.TEAM_BATTLE_RENOWN, 0)
	pPlayer.SetUserValue(self.Def.SAVE_GROUP, self.Def.PUNISH_TASK_RENOWN, 0)
	pPlayer.SetUserValue(self.Def.SAVE_GROUP, self.Def.RANDOM_FUBEN_RENOWN, 0)
	pPlayer.SetUserValue(self.Def.SAVE_GROUP, self.Def.ADVENTURE_FUBEN_RENOWN, 0)
	pPlayer.SetUserValue(self.Def.SAVE_GROUP, self.Def.INDIFFER_BATTLE_RENOWN, 0)
	pPlayer.GetScriptTable("FriendRecall").tbList = nil
end

function FriendRecall:ClearData(pPlayer)
	pPlayer.SetUserValue(self.Def.SAVE_GROUP, self.Def.ACTIVITY_VERSION, 0)
	pPlayer.SetUserValue(self.Def.SAVE_GROUP, self.Def.RECALL, 0)
	pPlayer.SetUserValue(self.Def.SAVE_GROUP, self.Def.AWARD_END_TIME, 0)
	pPlayer.SetUserValue(self.Def.SAVE_GROUP, self.Def.GET_RENOWN, 0)
	pPlayer.SetUserValue(self.Def.SAVE_GROUP, self.Def.RESET_RENOWN_WEEK, 0)
	pPlayer.SetUserValue(self.Def.SAVE_GROUP, self.Def.HAVE_RECALL_PLAYER, 0)

	pPlayer.SetUserValue(self.Def.SAVE_GROUP, self.Def.TEAM_FUBEN_RENOWN, 0)
	pPlayer.SetUserValue(self.Def.SAVE_GROUP, self.Def.TEAM_BATTLE_RENOWN, 0)
	pPlayer.SetUserValue(self.Def.SAVE_GROUP, self.Def.PUNISH_TASK_RENOWN, 0)
	pPlayer.SetUserValue(self.Def.SAVE_GROUP, self.Def.RANDOM_FUBEN_RENOWN, 0)
	pPlayer.SetUserValue(self.Def.SAVE_GROUP, self.Def.ADVENTURE_FUBEN_RENOWN, 0)
	pPlayer.SetUserValue(self.Def.SAVE_GROUP, self.Def.INDIFFER_BATTLE_RENOWN, 0)
	pPlayer.GetScriptTable("FriendRecall").tbList = nil
end

function FriendRecall:OnPlayerLogin()
	local pPlayer = me
	local tbStayInfo = KPlayer.GetRoleStayInfo(pPlayer.dwID)
	local nLastOnlineTime = tbStayInfo and tbStayInfo.nLastOnlineTime or 0
	if nLastOnlineTime <= 0 then
		return
	end

	if self:IsRecallPlayer(pPlayer)  then
		if self:IsHaveRecallAward(pPlayer) then
			self:SyncRecallAwardList(pPlayer);
			return
		else
			self:ResetRecall(pPlayer)
		end
	end

	if not self:IsInProcess() then
		return
	end

	if (nLastOnlineTime + self.Def.LAST_ONLINE_TIME_LIMIT) > GetTime()  and not self:IsInWhiteList(pPlayer) then
		return
	end

	self:SetPlayerRecalled(pPlayer)
	self:SetPlayerRecalledAwardActivated(pPlayer)
end

function FriendRecall:SetPlayerRecalled(pPlayer)
	pPlayer.SetUserValue(self.Def.SAVE_GROUP, self.Def.RECALL, 1)
	Log("FriendRecall", "SetPlayerRecalled", pPlayer.dwID)
end

function FriendRecall:SetPlayerRecalledAwardActivated(pPlayer)
	pPlayer.SetUserValue(self.Def.SAVE_GROUP, self.Def.AWARD_END_TIME, GetTime() + self.Def.AWARD_TIME)
	Log("FriendRecall", "SetPlayerRecalledAwardActivated", pPlayer.dwID)
end

function FriendRecall:OnLoadFriendData(pPlayer)
	self:SyncCanRecallList(pPlayer)

	if self:IsRecallPlayer(pPlayer) then
		local tbFriendRecallData = pPlayer.GetScriptTable("FriendRecall");
		if not tbFriendRecallData.tbList then
			self:RecordAwardPlayerList(pPlayer)
		end
	end

	self:SyncRecallAwardPlayerList(pPlayer);
end

function FriendRecall:RecordAwardPlayerList(pPlayer)
	local tbFriendRecallData = pPlayer.GetScriptTable("FriendRecall");
	local tbList = self:GetCanRecallList(pPlayer)
	tbFriendRecallData.tbList = {};
	--需要存盘,去除多余信息
	for nPlayerId,tbInfo in pairs(tbList) do
		tbFriendRecallData.tbList[nPlayerId] = tbInfo.nType;
	end

	self:SendRecalledMail(pPlayer, tbFriendRecallData.tbList);

	self:SyncRecallAwardList(pPlayer);

	Log("FriendRecall", "RecordAwardPlayerList", pPlayer.dwID)
	Lib:LogTB(tbFriendRecallData.tbList)
end

function FriendRecall:IsInAwardList(nRecalledPlayerId, nPlayerId)
	local pRecalledPlayer = nRecalledPlayerId
	if type(nRecalledPlayerId) == "number" then
		pRecalledPlayer = KPlayer.GetPlayerObjById(nRecalledPlayerId);
	end

	if not pRecalledPlayer then
		return false;
	end

	if not self:IsRecallPlayer(pRecalledPlayer) or not self:IsHaveRecallAward(pRecalledPlayer) then
		return false;
	end

	local tbFriendRecallData = pRecalledPlayer.GetScriptTable("FriendRecall");
	local tbList = tbFriendRecallData.tbList
	if not tbList or not tbList[nPlayerId] then
		return false;
	end

	return true, tbList[nPlayerId], pRecalledPlayer.szAccount;
end

function FriendRecall:GetCanRecallList(pPlayer, nLastOnlineTime)
	nLastOnlineTime = nLastOnlineTime or math.huge
	local tbList = {}
	local tbTSData = TeacherStudent:GetPlayerScriptTable(pPlayer)
	local  function fnCheckCanRecall(nPlayerId, nType)
		local tbStayInfo = KPlayer.GetRoleStayInfo(nPlayerId)
		if tbStayInfo.nLastOnlineTime > 0 and tbStayInfo.nLastOnlineTime < nLastOnlineTime then
			tbList[nPlayerId] = 
			{
				nType = nType,
				szAccount = tbStayInfo.szAccount,
			}
		end
	end

	for nPlayerId,_ in pairs(tbTSData.tbTeachers) do
		fnCheckCanRecall(nPlayerId, self.RecallType.TEACHER);
	end

	for nPlayerId,_ in pairs(tbTSData.tbStudents) do
		fnCheckCanRecall(nPlayerId, self.RecallType.STUDENT);
	end

	local tbAllFriends, _ = KFriendShip.GetFriendList(pPlayer.dwID);
	for nPlayerId, nImity in pairs(tbAllFriends) do
		if FriendShip:GetImityLevel(nImity) >= self.Def.IMITY_LEVEL_LIMIT then
			fnCheckCanRecall(nPlayerId, self.RecallType.FIREND);
		end
	end

	local dwKinId = pPlayer.dwKinId;
	local kinData = Kin:GetKinById(dwKinId)
	if dwKinId > 0 and kinData then
		local tbKinMembers = Kin:GetKinMembers(dwKinId)
		for nPlayerId, _ in pairs(tbKinMembers) do
			if tbAllFriends[nPlayerId] then
				fnCheckCanRecall(nPlayerId, self.RecallType.KIN);
			end
		end
	end

	return tbList;
end

function FriendRecall:CheckResetRenownLimit(pPlayer)
	local nWeek = Lib:GetLocalWeek(GetTime() - self.Def.RENOWN_FRESH_TIME)
	local nLastRefreshWeek = pPlayer.GetUserValue(self.Def.SAVE_GROUP, self.Def.RESET_RENOWN_WEEK)
	if nWeek ~= nLastRefreshWeek then
		pPlayer.SetUserValue(self.Def.SAVE_GROUP, self.Def.RESET_RENOWN_WEEK, nWeek)
		pPlayer.SetUserValue(self.Def.SAVE_GROUP, self.Def.GET_RENOWN, 0)

		pPlayer.SetUserValue(self.Def.SAVE_GROUP, self.Def.TEAM_FUBEN_RENOWN, 0)
		pPlayer.SetUserValue(self.Def.SAVE_GROUP, self.Def.TEAM_BATTLE_RENOWN, 0)
		pPlayer.SetUserValue(self.Def.SAVE_GROUP, self.Def.PUNISH_TASK_RENOWN, 0)
		pPlayer.SetUserValue(self.Def.SAVE_GROUP, self.Def.RANDOM_FUBEN_RENOWN, 0)
		pPlayer.SetUserValue(self.Def.SAVE_GROUP, self.Def.ADVENTURE_FUBEN_RENOWN, 0)
		pPlayer.SetUserValue(self.Def.SAVE_GROUP, self.Def.INDIFFER_BATTLE_RENOWN, 0)
	end
end

function FriendRecall:GetRenownAdded(pPlayer)
	self:CheckResetRenownLimit(pPlayer)
	return pPlayer.GetUserValue(self.Def.SAVE_GROUP, self.Def.GET_RENOWN)
end

function FriendRecall:AddRenownAward(nPlayerId, szType)
	local nValue = self.Def.RENOWN_VALUE[szType]
	if not nValue then
		return
	end

	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return
	end

	local nCurAdded = self:GetRenownAdded(pPlayer);
	local nAddValue = math.min(nValue, math.abs(self.Def.MAX_RENOWN_WEEKLY - nCurAdded));

	local nSaveKey = self.Def.RENOWN_SAVE_MAP[szType]
	if nSaveKey then
		local nAwardCount = pPlayer.GetUserValue(self.Def.SAVE_GROUP, nSaveKey)
		if nAwardCount >= self.Def.MAX_RENOWN_COUNT_WEEKLY then
			pPlayer.CenterMsg(XT("本周通過此活動獲得的玩家召回額外名望已達上限"));
			return
		end

		pPlayer.SetUserValue(self.Def.SAVE_GROUP, nSaveKey, nAwardCount + 1)
	end

	if nAddValue > 0 then
		pPlayer.SendAward({{"Renown", nAddValue}}, true, true, Env.LogWay_FriendRecall_Renown)
		pPlayer.SetUserValue(self.Def.SAVE_GROUP, self.Def.GET_RENOWN, nCurAdded + nAddValue)
	end

	if nAddValue < nValue then
		pPlayer.CenterMsg(string.format(XT("本周通過玩家召回獲得的額外名望已達%d上限"), self.Def.MAX_RENOWN_WEEKLY));
	end
end

function FriendRecall:OnTeamBattleAward(tbMember)
	for _,nPlayerId1 in ipairs(tbMember) do
		for _,nPlayerId2 in ipairs(tbMember) do
			if nPlayerId1 ~= nPlayerId2  and  self:IsInAwardList(nPlayerId1, nPlayerId2) then
				self:AddRenownAward(nPlayerId2, "TeamBattle")
			end
		end
	end
end

function FriendRecall:OnPunishTaskAward(tbMember)
	for _,nPlayerId1 in pairs(tbMember) do
		for _,nPlayerId2 in pairs(tbMember) do
			if nPlayerId1 ~= nPlayerId2  and self:IsInAwardList(nPlayerId1, nPlayerId2) then
				self:AddRenownAward(nPlayerId2, "PunishTask")
			end
		end
	end
end

function FriendRecall:OnTeamFubenAward(tbMember)
	for nPlayerId1,_ in pairs(tbMember) do
		for nPlayerId2,_ in pairs(tbMember) do
			if nPlayerId1 ~= nPlayerId2  and self:IsInAwardList(nPlayerId1, nPlayerId2) then
				self:AddRenownAward(nPlayerId2, "TeamFuben")
			end
		end
	end
end

function FriendRecall:OnRandomFubenAward(tbMember)
	for nPlayerId1,_ in pairs(tbMember) do
		for nPlayerId2,_ in pairs(tbMember) do
			if nPlayerId1 ~= nPlayerId2  and self:IsInAwardList(nPlayerId1, nPlayerId2) then
				self:AddRenownAward(nPlayerId2, "RandomFuben")
			end
		end
	end
end

function FriendRecall:OnAdventureFubenAward(tbMember)
	for _,nPlayerId1 in pairs(tbMember) do
		for _,nPlayerId2 in pairs(tbMember) do
			if nPlayerId1 ~= nPlayerId2  and  self:IsInAwardList(nPlayerId1, nPlayerId2) then
				self:AddRenownAward(nPlayerId2, "AdventureFuben")
			end
		end
	end
end

function FriendRecall:SendRecalledMail(pPlayer, tbList)

	local szContent = string.format(XT([[俠士 %s 已重新回到精彩紛呈的江湖，如今與他組隊參加活動，將獲得[FFFE0D]親密度獲取增加100%%\n野外打怪經驗加成+5%%、攻擊力+70、全抗+70、生命+1500[-]的增益狀態，並且一同參與[FFFE0D]組隊秘境、淩絕峰、山賊秘窟、懲惡任務、通天塔、心魔幻境[-]還將額外獲得名望獎勵，有效期[FFFE0D]30[-]天]]), pPlayer.szName)

	local tbMail = {Title = "重聚江湖", From = pPlayer.szName, Text = szContent}

	for nPlayerId,_ in pairs(tbList) do
		tbMail.To = nPlayerId
		Mail:SendSystemMail(tbMail)
	end
end

function FriendRecall:OnInDifferBattleTeamImity(tbRetData)
	for dwRole1, v in pairs(tbRetData) do
		for dwRole2, nImitity in pairs(v) do
			local pPlayer = KPlayer.GetPlayerObjById(dwRole1);
			if pPlayer and self:IsRecallPlayer(pPlayer) and self:IsHaveRecallAward(pPlayer) and self:IsInAwardList(pPlayer, dwRole2) then
				self:AddRenownAward(dwRole2, "InDifferBattle")
			end

			pPlayer = KPlayer.GetPlayerObjById(dwRole2);
			if pPlayer and self:IsRecallPlayer(pPlayer) and self:IsHaveRecallAward(pPlayer) and self:IsInAwardList(pPlayer, dwRole1) then
				self:AddRenownAward(dwRole1, "InDifferBattle")
			end
		end
	end
end

function FriendRecall:OnShareInfoRsp(pPlayer, szRetData)
	if not self:IsInProcess() then
		return
	end

	pPlayer.CallClientScript("FriendRecall:OnServerShareResult", true)
end

--同步我在谁的福利成员列表内
function FriendRecall:SyncRecallAwardPlayerList(pPlayer)
	local nMePlayerId = pPlayer.dwID
	local tbAllFriends, _ = KFriendShip.GetFriendList(nMePlayerId);
	for nPlayerId, nImity in pairs(tbAllFriends) do
		local bInList, nType, szAccount = self:IsInAwardList(nPlayerId, nMePlayerId)
		if bInList then
			pPlayer.CallClientScript("FriendRecall:SyncRecallAwardPlayer", {nPlayerId, nType, szAccount})
		end
	end
end

--同步被召回玩家的福利成员列表
function FriendRecall:SyncRecallAwardList(pPlayer)
	local tbList = pPlayer.GetScriptTable("FriendRecall").tbList or {}

	pPlayer.CallClientScript("FriendRecall:SyncRecallAwardList", tbList)

	for nPlayerId,nType in pairs(tbList) do
		local pCallPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pCallPlayer then
			pCallPlayer.CallClientScript("FriendRecall:SyncRecallAwardPlayer", {pPlayer.dwID, nType, pPlayer.szAccount})
		end
	end
end

function FriendRecall:SyncCanRecallList(pPlayer)
	if not self:IsInProcess() then
		return
	end

	local nNow = GetTime()
	local nLastOnlineTime = nNow - self.Def.LAST_ONLINE_TIME_LIMIT;

	if not pPlayer.tbFriendCanRecallList or ((pPlayer.nLastReshRecallList + self.Def.RESH_LIST_INTERVAL) < nNow) then
		pPlayer.tbFriendCanRecallList = self:GetCanRecallList(pPlayer, nLastOnlineTime)
		pPlayer.nLastReshRecallList = nNow

		if Lib:CountTB(pPlayer.tbFriendCanRecallList) > 0 then
			pPlayer.SetUserValue(self.Def.SAVE_GROUP, self.Def.HAVE_RECALL_PLAYER, 1)
		else
			pPlayer.SetUserValue(self.Def.SAVE_GROUP, self.Def.HAVE_RECALL_PLAYER, 0)
		end
	end

	pPlayer.CallClientScript("FriendRecall:SyncCanRecallList", pPlayer.tbFriendCanRecallList, pPlayer.GetUserValue(self.Def.SAVE_GROUP, self.Def.HAVE_RECALL_PLAYER))
end

function FriendRecall:DoServerRecall(pPlayer, szTargetAccount, nType)
	if not self:IsInProcess() then
		return
	end

	Log("DoServerRecall", pPlayer.dwID, szTargetAccount, nType);

	local szTitle = self.RecallDesc[nType].szTitle
	local szDesc = self.RecallDesc[nType].szDesc
	if not szTitle or not szDesc then
		return
	end

	AssistClient:ShareInfo(pPlayer, szTargetAccount, szTitle, szDesc, "MSG_INVITE")
end

function FriendRecall:OnTeamMemberAdd(nTeamID, nCaptainID, tbMembers, nMemberID)
	for _,nPlayerId1 in ipairs(tbMembers) do
		local pPlayer1 = KPlayer.GetPlayerObjById(nPlayerId1)
		if pPlayer1 then
			pPlayer1.RemoveSkillState(self.Def.TEAM_BUFF_ID);
		end
	end

	for _,nPlayerId1 in ipairs(tbMembers) do
		for _,nPlayerId2 in ipairs(tbMembers) do
			if self:IsInAwardList(nPlayerId1, nPlayerId2) then
				local pPlayer1 = KPlayer.GetPlayerObjById(nPlayerId1)
				local pPlayer2 = KPlayer.GetPlayerObjById(nPlayerId2)
				if pPlayer1 then
					pPlayer1.AddSkillState(self.Def.TEAM_BUFF_ID, 1, 3, Env.GAME_FPS*self.Def.TEAM_BUFF_TIME, 1, 1)
				end
				if pPlayer2 then
					pPlayer2.AddSkillState(self.Def.TEAM_BUFF_ID, 1, 3, Env.GAME_FPS*self.Def.TEAM_BUFF_TIME, 1, 1)
				end
			end
		end
	end
end

function FriendRecall:OnTeamMemberRemove(nTeamID, nCaptainID, tbMembers, nMemberID)
	local pPlayer = KPlayer.GetPlayerObjById(nMemberID)
	if pPlayer then
		pPlayer.RemoveSkillState(self.Def.TEAM_BUFF_ID);
	end


	for _,nPlayerId1 in ipairs(tbMembers) do
		local pPlayer1 = KPlayer.GetPlayerObjById(nPlayerId1)
		if pPlayer1 then
			pPlayer1.RemoveSkillState(self.Def.TEAM_BUFF_ID);
		end
	end

	for _,nPlayerId1 in ipairs(tbMembers) do
		for _,nPlayerId2 in ipairs(tbMembers) do
			if self:IsInAwardList(nPlayerId1, nPlayerId2) then
				local pPlayer1 = KPlayer.GetPlayerObjById(nPlayerId1)
				local pPlayer2 = KPlayer.GetPlayerObjById(nPlayerId2)
				if pPlayer1 then
					pPlayer1.AddSkillState(self.Def.TEAM_BUFF_ID, 1, 3, Env.GAME_FPS*self.Def.TEAM_BUFF_TIME, 1, 1)
				end
				
				if pPlayer2 then
					pPlayer2.AddSkillState(self.Def.TEAM_BUFF_ID, 1, 3, Env.GAME_FPS*self.Def.TEAM_BUFF_TIME, 1, 1)
				end
			end
		end
	end
end

function FriendRecall:LoadWhiteList()
	self.tbWhiteList = LoadTabFile("friend_recall_white_list.tab", "s", "OpenId", {"OpenId"}, 1, 1)
	Log("FriendRecall", "LoadWhiteList")
	if self.tbWhiteList  then
		Lib:LogTB(self.tbWhiteList)
	end
end

function FriendRecall:IsInWhiteList(pPlayer)
	if not self.tbWhiteList then
		return false
	end

	if not self.tbWhiteList[pPlayer.szAccount] then
		return false
	end

	if pPlayer.dwCreateTime + self.Def.LAST_ONLINE_TIME_LIMIT > GetTime() then
		return false
	end

	return true
end

FriendRecall.tbClientSafeCall = {
	SyncCanRecallList = 1,
	DoServerRecall = 1,
}

function FriendRecall:OnClientCall(pPlayer, szFunc, ...)
	if not szFunc or not self[szFunc] or not self.tbClientSafeCall[szFunc] then
		Log("FriendRecall Try Call NotSafeFunc", pPlayer.dwID, szFunc)
		return
	end

	self[szFunc](self, pPlayer, ...)
end