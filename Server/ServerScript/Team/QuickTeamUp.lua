--[[
TeamMgr._QuickTeamData = {
	ActivityData = {
		[ActivityId] = {},
	}
}
]]

TeamMgr.QuickTeamUp = TeamMgr.QuickTeamUp or {};
local TeamUp = TeamMgr.QuickTeamUp;
TeamUp.NextActivityId = TeamUp.NextActivityId or 1;
TeamUp._tbActivityData = TeamUp._tbActivityData or {};
TeamUp._tbTeamListData = TeamUp._tbTeamListData or {};
TeamUp._tbQuickJoinWaitingList = TeamUp._tbQuickJoinWaitingList or {};
TeamUp._tbTeamChangeListener = TeamUp._tbTeamChangeListener or {};
TeamUp.nVersion = TeamUp.nVersion or 1;

--[[
	tbShow, tbCheck, tbEnter 为Lib.CallBack所调用, 函数名为字符串..
	当中, 若tbShow, tbCheck 函数在客户端也同名实现, 则客户端也会调用

	这里Enter成功则直接 返回true..
]]

function TeamUp:RegisterActivity(szType, subtype, szName, tbCheckShow, tbCheckJoin, tbCheckEnter, tbEnter, nMinOpenMember, tbCheckHelpJoin)
	local nCurActivityId = self.NextActivityId;
	self.NextActivityId = self.NextActivityId + 1;

	self._tbActivityData[nCurActivityId] = {
		nActivityId = nCurActivityId,
		szType = szType,
		subtype = subtype,
		szName = szName,
		tbCheckShow = tbCheckShow,
		tbCheckJoin = tbCheckJoin,
		tbCheckEnter = tbCheckEnter,
		tbCheckHelpJoin = tbCheckHelpJoin,
		tbEnter = tbEnter,
		bCanHelp = tbCheckHelpJoin and true or false,
		nMinOpenMember = nMinOpenMember or 2, -- 默认开启活动最小人数为2
	};

	self._tbTeamListData[nCurActivityId] = {};
	self._tbQuickJoinWaitingList[nCurActivityId] = {};
	self.nVersion = self.nVersion + 1;

	return nCurActivityId;
end

function TeamUp:UnregisterById(nActivityId)
	if not self._tbActivityData[nActivityId] then
		return false;
	end

	self._tbActivityData[nActivityId] = nil;
	self._tbTeamListData[nCurActivityId] = nil;
	self._tbQuickJoinWaitingList[nCurActivityId] = nil;
	self.nVersion = self.nVersion + 1;

	return true;
end

function TeamUp:GetActivity(nActivityId)
	return nActivityId and self._tbActivityData[nActivityId];
end

function TeamUp:GetActivityName(nActivityId)
	if nActivityId and self._tbActivityData[nActivityId] then
		local szName = self._tbActivityData[nActivityId].szName;
		local tbActivity = self._tbActivityData[nActivityId];
		if TeamMgr.TEAM_ACTIVITY_NAME[tbActivity.szType]
			and tbActivity.szType ~= tbActivity.subtype
			then
			szName = TeamMgr.TEAM_ACTIVITY_NAME[tbActivity.szType] .. "·" .. szName;
		end
		return szName;
	end
end

local nDelayNotifyTime = 30;  -- 秒
local nMaxSendTeams = 20; -- 支
function TeamUp:GetActivityTeams4Show(nActivityId, player)
	local tbSynTeams = {};
	local tbTeamList = TeamUp:GetActivityAllTeams(nActivityId);

	for nIdx, nTeamId in ipairs(tbTeamList) do
		if nIdx > nMaxSendTeams then
			break;
		end

		local teamData = TeamMgr:GetTeamById(nTeamId);
		local captain = teamData and KPlayer.GetPlayerObjById(teamData.nCaptainID);
		if captain and not teamData:TeamFull() and nTeamId ~= player.dwTeamID then
			table.insert(tbSynTeams, {
					nTeamId = nTeamId,
					szCaptainName = captain.szName,
					nLevel = captain.nLevel,
					nFaction = captain.nFaction,
					nPortrait = captain.nPortrait,
					nHonorLevel = captain.nHonorLevel,
					nCount = teamData:GetMemberCount(),
				});
		end
	end

	local nOutTime = GetTime() + nDelayNotifyTime;
	for _, tbTeam in ipairs(tbSynTeams) do
		self._tbTeamChangeListener[tbTeam.nTeamId][player.dwID] = nOutTime;
	end

	return tbSynTeams;
end

function TeamUp:GetActivityAllTeams(nActivityId)
	return self._tbTeamListData[nActivityId] or {};
end

function TeamUp:TeamInfoChanged(teamData, bQuite)
	local tbListener = self._tbTeamChangeListener[teamData.nTeamID] or {};
	local nCount = bQuite and 0 or teamData:GetMemberCount();
	local nNow = GetTime();
	for nPlayerId, nOutTime in pairs(tbListener) do
		local player = KPlayer.GetPlayerObjById(nPlayerId);
		if player and nNow < nOutTime then
			player.CallClientScript("TeamMgr:OnSynQuickTeamsInfo",
				teamData.nTargetActivityId,
				teamData.nTeamID, nCount);
		else
			tbListener[nPlayerId] = nil;
		end
	end
end

function TeamUp:ResetTeamListener(nTeamId)
	self._tbTeamChangeListener[nTeamId] = {};
end

function TeamUp:GetActivityIdByType(szType, subtype)
	for nActivityId, tbData in pairs(self._tbActivityData) do
		if tbData.szType == szType and tbData.subtype == subtype then
			return nActivityId;
		end
	end
end

function TeamUp:CheckEnter(nPlayerId, nActivityId)
	local player = KPlayer.GetPlayerObjById(nPlayerId);
	if not player or player.dwTeamID == 0 then
		return false, "找不到隊伍";
	end

	local teamData = TeamMgr:GetTeamById(player.dwTeamID);
	if not teamData then
		return false, "找不到隊伍";
	end

	-- 通用检查，若有玩家处于单机副本中，则无法进入活动
	for _, nMemberID in pairs(teamData:GetMembers()) do
		local member = KPlayer.GetPlayerObjById(nMemberID);
		if member then
			if member.nState == Player.emPLAYER_STATE_ALONE then
				return false, string.format("「%s」所在地圖無法進入活動", member.szName);
			end
		else
			return false, "隊友掉線了";
		end
	end

	local tbActivity = self:GetActivity(nActivityId);

	GameSetting:SetGlobalObj(player);
	local tbRet = {Lib:CallBack(tbActivity.tbCheckEnter)};
	GameSetting:RestoreGlobalObj();

	return unpack(tbRet, 2);
end

function TeamUp:Enter(nPlayerId, nActivityId)
	local player = KPlayer.GetPlayerObjById(nPlayerId);
	if not player or player.dwTeamID == 0 then
		return false;
	end

	local teamData = TeamMgr:GetTeamById(player.dwTeamID);
	if not teamData then
		return false;
	end

	local tbActivity = self:GetActivity(nActivityId);

	GameSetting:SetGlobalObj(player);
	local tbRet = {Lib:CallBack(tbActivity.tbEnter)};
	GameSetting:RestoreGlobalObj();

	teamData:ChangeTargetActivity();
	TeamUp:ClearActivitySelect(teamData:GetMembers());

	-- 成功进入, 接入成就
	if tbRet[2] then
		teamData:TraversMembers(function (member)
			Achievement:AddCount(member, "QuickTeamUp_Normal");
		end);
	end

	return unpack(tbRet, 2);
end

function TeamUp:Check(player, nActivityId)
	local tbActivity = self:GetActivity(nActivityId);
	if not tbActivity then
		return false;
	end

	GameSetting:SetGlobalObj(player);
	local tbRet = {Lib:CallBack(tbActivity.tbCheckJoin)};
	GameSetting:RestoreGlobalObj();
	return unpack(tbRet, 2);
end

function TeamUp:CheckHelp(player, nActivityId)
	local tbActivity = self:GetActivity(nActivityId);
	if not tbActivity or not tbActivity.tbCheckHelpJoin then
		return false;
	end

	GameSetting:SetGlobalObj(player);
	local tbRet = {Lib:CallBack(tbActivity.tbCheckHelpJoin)};
	GameSetting:RestoreGlobalObj();
	return unpack(tbRet, 2);
end

function TeamUp:GetActivitySyncList(nVersion)
	if self.nVersion == nVersion then
		return;
	end

	local tbList = {};
	for nActivityId, tbActivity in pairs(self._tbActivityData) do
		local _, bRet = Lib:CallBack(tbActivity.tbCheckShow);
		if bRet then
			table.insert(tbList, {
				nActivityId = nActivityId,
				szType = tbActivity.szType,
				subtype = tbActivity.subtype,
				szName = tbActivity.szName,
				bCanHelp = tbActivity.bCanHelp,
				nMinOpenMember = tbActivity.nMinOpenMember,
			});
		end
	end

	return tbList, self.nVersion;
end

function TeamUp:CheckActivitySelect(tbMembers, nActivityId)
	for _, nMemberID in pairs(tbMembers) do
		local member = KPlayer.GetPlayerObjById(nMemberID) or {};
		if member.nTargetTeamActivityId ~= nActivityId then
			return false;
		end
	end

	return true;
end

function TeamUp:ClearActivitySelect(tbMembers)
	for _, nMemberID in pairs(tbMembers) do
		local member = KPlayer.GetPlayerObjById(nMemberID);
		if member then
			member.nTargetTeamActivityId = nil;
		end
	end

	return true;
end

function TeamUp:Add2TeamList(nActivityId, teamData)
	local tbTeamList = self._tbTeamListData[nActivityId];
	if not tbTeamList then
		return false;
	end

	table.insert(tbTeamList, teamData.nTeamID);
	return true;
end

function TeamUp:RemoveFromeTeamList(nActivityId, teamData)
	local tbTeamList = self._tbTeamListData[nActivityId];
	if not tbTeamList then
		return false;
	end

	for nIdx, nTeamId in ipairs(tbTeamList) do
		if nTeamId == teamData.nTeamID then
			table.remove(tbTeamList, nIdx);
			return true;
		end
	end

	return true;
end

function TeamUp:DealWaitingList(teamData)
	if teamData:TeamFull() then
		return false;
	end

	local tbWaiting = self._tbQuickJoinWaitingList[teamData.nTargetActivityId];
	if not tbWaiting then
		return false;
	end

	local tbToDelete = {};
	local bAutoAgree = teamData:IsAutoAgree();
	for nIdx, nMemberId in ipairs(tbWaiting) do
		local member = KPlayer.GetPlayerObjById(nMemberId);
		if member and member.dwTeamID == 0 then
			if bAutoAgree then
				teamData:AddMember(nMemberId);
			else
				teamData:Add2ApplyerList(member, teamData.nTargetActivityId);
			end

			if teamData:TeamFull() then
				break;
			end
		else
			table.insert(tbToDelete, 1, nIdx);
		end
	end

	for _, nIdx in ipairs(tbToDelete) do
		table.remove(tbWaiting, nIdx);
	end

	return true;
end

function TeamUp:Add2WaitingJoinList(tbActivitys, player)
	for nActivityId, _ in pairs(tbActivitys) do
		local tbWaiting = self._tbQuickJoinWaitingList[nActivityId];
		if tbWaiting then
			table.insert(tbWaiting, player.dwID);
		end
	end

	player.tbQuickTeamWaitingActivitys = tbActivitys;
	return true;
end

function TeamUp:RemoveFromWaitingList(player)
	local nPlayerId = player.dwID;
	local tbActivitys = player.tbQuickTeamWaitingActivitys or {};
	for nActivityId, _ in pairs(tbActivitys) do
		local tbWaiting = self._tbQuickJoinWaitingList[nActivityId];
		if tbWaiting then
			for nIdx, nMemberId in ipairs(tbWaiting) do
				if nMemberId == nPlayerId then
					table.remove(tbWaiting, nIdx);
					break;
				end
			end
		end
	end

	player.tbQuickTeamWaitingActivitys = nil;
end

function TeamUp:DeleteTeam(teamData)
	self:RemoveFromeTeamList(teamData.nTargetActivityId, teamData);
	self._tbTeamChangeListener[teamData.nTeamID] = nil;
end
