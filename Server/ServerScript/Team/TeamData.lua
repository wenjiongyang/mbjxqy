--[[
	TeamMgr.tbAllTeamData =
	{
		[TeamID] =
		{
			nTeamID = ...
			nCaptainID = ...;
			tbApplyerList = {..}; // todo:设置上限
		}
	}
]]

TeamMgr.NextTeamID = TeamMgr.NextTeamID or 1;
TeamMgr.tbAllTeamData = TeamMgr.tbAllTeamData or {};

TeamMgr._TeamData = TeamMgr._TeamData or {};
local _TeamData = TeamMgr._TeamData;
local CTeamMgr = GetCTeamMgr();

TeamMgr.QuickTeamUp = TeamMgr.QuickTeamUp or {};
local TeamUp = TeamMgr.QuickTeamUp;

function TeamMgr:OnLogin()
	if me.dwTeamID == 0 then
		me.CallClientScript("TeamMgr:OnSynQuite");
	else
		local teamData = TeamMgr:GetTeamById(me.dwTeamID);
		if teamData then
			me.CallClientScript("TeamMgr:OnSynNewTeam", teamData.nTeamID,
				teamData.nCaptainID, teamData:GetLuaTeamMemberData(me.dwID));

			if teamData.nTargetActivityId then
				me.CallClientScript("TeamMgr:OnSynTargetActivityId", teamData.nTargetActivityId);
			end

			if teamData.nCaptainID == me.dwID then
				me.CallClientScript("TeamMgr:OnSynApplyerList", teamData.tbApplyerList);
			end
		end
	end
end

function TeamMgr:Create(nCaptainID, nMemberID, bIgnoreCheck)
	local captain = KPlayer.GetPlayerObjById(nCaptainID);
	local member = KPlayer.GetPlayerObjById(nMemberID);

	if not captain or not member
		or captain.dwTeamID ~= 0
		or member.dwTeamID ~= 0
		then
		return false;
	end

	local teamData = {
			nTeamID = TeamMgr.NextTeamID;
			nCaptainID = nCaptainID;
			tbApplyerList = {};
		};

	setmetatable(teamData, {__index = self._TeamData});
	TeamMgr.tbAllTeamData[teamData.nTeamID] = teamData;
	CTeamMgr.CreateTeam(teamData.nTeamID, nCaptainID);
	TeamUp:RemoveFromWaitingList(captain);
	captain.CallClientScript("TeamMgr:OnSynNewTeam", teamData.nTeamID,
								nCaptainID, teamData:GetLuaTeamMemberData(nCaptainID));
	local bRet, szMsg = teamData:AddMember(nMemberID, bIgnoreCheck);
	TeamMgr.NextTeamID = TeamMgr.NextTeamID + 1;
	return true, bRet, szMsg, teamData;
end

function TeamMgr:GetTeamById(nTeamID)
	return TeamMgr.tbAllTeamData[nTeamID];
end

function TeamMgr:DeleteTeam(nTeamID)
	local teamData = self:GetTeamById(nTeamID);
	if not teamData then
		return false;
	end

	local tbMembers = teamData:GetMembers();
	for _, nMemberID in pairs(tbMembers) do
		teamData:RemoveMember(nMemberID);
	end

	TeamUp:DeleteTeam(teamData);
	TeamMgr.tbAllTeamData[nTeamID] = nil;
	return true;
end


------------------TeamData-----------------------------
local function GetPlayerData(playerId)
	local player = KPlayer.GetPlayerObjById(playerId);
	local playerNpc = player and player:GetNpc();
	if playerNpc then
		local nMapId, nPosX, nPosY = player:GetWorldPos();
		return {
					nPlayerID = playerId;
					nNpcID = playerNpc.nId;
					szName = player.szName;
					nFaction = player.nFaction;
					nPortrait = player.nPortrait;
					nHonorLevel = player.nHonorLevel;
					nKinId = player.dwKinId;
					nLevel = player.nLevel;
					nMapId = nMapId;
					nMapTemplateId = player.nMapTemplateId;
					nPosX = nPosX;
					nPosY = nPosY;
					nVipLevel = player.GetVipLevel();
					nHpPercent = (playerNpc.nCurLife / playerNpc.nMaxLife * 100);
					bHelp = TeamMgr:CanQuickTeamHelp(player);
				};
	end
end

function _TeamData:GetCaptainId()
	return self.nCaptainID;
end

function _TeamData:IsCaptain(nPlayerId)
	return self.nCaptainID==nPlayerId
end

function _TeamData:IsAutoAgree()
	local nCaptainId = self:GetCaptainId();
	local captain = KPlayer.GetPlayerObjById(nCaptainId or 0);
	if captain then
		return captain.GetUserValue(TeamMgr.Def.AUTO_AGREE_GROUP, TeamMgr.Def.AUTO_AGREE_KEY) >= 0;
	end

	return true;
end

function _TeamData:SetAutoAgree(bAutoAgree)
	local nCaptainId = self:GetCaptainId();
	local captain = KPlayer.GetPlayerObjById(nCaptainId or 0);
	if captain then
		return captain.SetUserValue(TeamMgr.Def.AUTO_AGREE_GROUP, TeamMgr.Def.AUTO_AGREE_KEY, bAutoAgree and 1 or -1);
	end
end

function _TeamData:GetMembers()
	return CTeamMgr.TeamGetMember(self.nTeamID) or {};
end

function _TeamData:TraversMembers(fnOperate, ...)
	for _, nMemberID in pairs(self:GetMembers()) do
		local member = KPlayer.GetPlayerObjById(nMemberID);
		if member then
			fnOperate(member, ...);
		else
			Log("TeamData:TraversMembers member not exist");
		end
	end
end

function _TeamData:GetMemberCount()
	return CTeamMgr.TeamGetMemberCount(self.nTeamID) or 0;
end

function _TeamData:TeamFull()
	return CTeamMgr.TeamGetMemberCount(self.nTeamID) >= TeamMgr.MAX_MEMBER_COUNT;
end

function _TeamData:Available2Join(pPlayer)
	if pPlayer.dwTeamID ~= 0 then
		return false, "已有隊伍";
	end

	if pPlayer.nLevel < TeamMgr.OPEN_LEVEL then
		return false, string.format("%d級以上才允許組隊", TeamMgr.OPEN_LEVEL);
	end

	if not pPlayer.CanTeamOpt() then
		return false, "所在地圖不可組隊";
	end

	if self:TeamFull() then
		return false, "隊伍已滿";
	end

	local nCaptainID = self:GetCaptainId();
	local captain = KPlayer.GetPlayerObjById(nCaptainID or 0);
	if not captain or not captain.CanTeamOpt() or captain.nState == Player.emPLAYER_STATE_ZONE  then
		return false, "隊長所在地圖不可進行隊伍操作";
	end

	return true;
end

function _TeamData:GetMemberData(nMemberId)
	return GetPlayerData(nMemberId)
end

function _TeamData:GetLuaTeamMemberData(nPlayerID)
	local tbTeamData = {};
	local tbTeamMember = self:GetMembers();
	for _, nMemberID in pairs(tbTeamMember) do
		if nMemberID ~= nPlayerID then
			local tbMemberData = GetPlayerData(nMemberID);
			table.insert(tbTeamData, tbMemberData);
		end
	end
	return tbTeamData;
end

function _TeamData:AddMember(nMemberID, bIgnoreCheck)
	local member = KPlayer.GetPlayerObjById(nMemberID);
	if not member then
		return false, "玩家已下線";
	end

	if not bIgnoreCheck then
		local bRet, szInfo = self:Available2Join(member);
		if not bRet then
			return false, szInfo;
		end
	end

	TeamUp:RemoveFromWaitingList(member);
	if not CTeamMgr.TeamAddMember(self.nTeamID, nMemberID) then
		return false, "添加隊伍成員失敗";
	end

	member.CallClientScript("TeamMgr:OnSynNewTeam", self.nTeamID,
							self.nCaptainID, self:GetLuaTeamMemberData(nMemberID));

	if self.nTargetActivityId then
		member.CallClientScript("TeamMgr:OnSynTargetActivityId", self.nTargetActivityId);
	end

	local tbMembers = self:GetMembers();
	local tbNewMemberData = GetPlayerData(nMemberID);
	for _, nOtherMemberID in pairs(tbMembers) do
		if nOtherMemberID ~= nMemberID and tbNewMemberData then
			local other = KPlayer.GetPlayerObjById(nOtherMemberID);
			if other then
				other.CallClientScript("TeamMgr:OnSynAddMember", tbNewMemberData)
			end
		end
	end

	self:UpdateCamp();
	TeamUp:TeamInfoChanged(self);

	SwornFriends:UpdateTeamBuff(self:GetMembers())

	FriendRecall:OnTeamMemberAdd(self.nTeamID, self.nCaptainID, self:GetMembers(), nMemberID);

	return true;
end

function _TeamData:RemoveMember(nMemberID)
	CTeamMgr.TeamRemoveMember(self.nTeamID, nMemberID);

	local tbMembers = self:GetMembers();
	for _, nOtherMemberID in pairs(tbMembers) do
		if nOtherMemberID ~= nMemberID then
			local other = KPlayer.GetPlayerObjById(nOtherMemberID);
			if other then
				other.CallClientScript("TeamMgr:OnSynRemoveMember", nMemberID);
			end
		end
	end

	local member = KPlayer.GetPlayerObjById(nMemberID);
	if member then
		member.CallClientScript("TeamMgr:OnSynQuite");
		member.RestoreCamp();
		TeamMgr:SetQuickTeamHelpState(false, member);
	end

	if self.nCaptainID == nMemberID then
		self:UpdateCaptain();
	end

	local bExist = next(tbMembers);
	if bExist then
		TeamUp:DealWaitingList(self);
	end

	TeamUp:TeamInfoChanged(self, not bExist);

	SwornFriends:UpdateTeamBuff(self:GetMembers(), nMemberID)

	FriendRecall:OnTeamMemberRemove(self.nTeamID, self.nCaptainID, self:GetMembers(), nMemberID);

	return true;
end

function _TeamData:UpdateCaptain()
	local nCaptainID = 0;
	local nLevel = 0;
	for _, nPlayerID in pairs(self:GetMembers()) do
		local player = KPlayer.GetPlayerObjById(nPlayerID);
		if player then
			local playerLevel = player.nLevel;
			if playerLevel > nLevel then
				nCaptainID = nPlayerID;
				nLevel = playerLevel;
			end
		end
	end

	if nCaptainID == 0 then
		return;
	end

	local player = KPlayer.GetPlayerObjById(nCaptainID);
	local szTips = string.format("「%s」成為新隊長", player.szName);
	ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Team, szTips, self.nTeamID);
	self:ChangeCaptain(nCaptainID);
end

function _TeamData:ChangeCaptain(nTargetPlayerID)
	local targetPlayer = KPlayer.GetPlayerObjById(nTargetPlayerID);
	if not targetPlayer or self.nTeamID ~= targetPlayer.dwTeamID then
		return false, "目標玩家不在當前隊伍";
	end

	if self.nCaptainID == nTargetPlayerID then
		return false, "目標玩家已經是隊長了";
	end

	local nPreCaptainId = self.nCaptainID;
	self.nCaptainID = nTargetPlayerID;

	local tbMembers = self:GetMembers();
	for _, nMemberID in pairs(tbMembers) do
		local member = KPlayer.GetPlayerObjById(nMemberID);
		if member then
			member.CallClientScript("TeamMgr:OnSynChangeCaptain", nTargetPlayerID);
		end
	end

	targetPlayer.CallClientScript("TeamMgr:OnSynApplyerList", self.tbApplyerList);
	targetPlayer.OnEvent("OnTeamCaptainChanged", nPreCaptainId, targetPlayer.dwID);

	self:UpdateCamp();
	return true;
end

function _TeamData:UpdateCamp()
	local pCaptain = KPlayer.GetPlayerObjById(self.nCaptainID);
	if not pCaptain then
		return;
	end

	self:TraversMembers(function (member)
		local pNpc = member and member.GetNpc();
		if pNpc then
			pNpc.SetCamp(pCaptain.nOrgCamp or Npc.CampTypeDef.camp_type_player);
		end
	end)
end

function _TeamData:Quite(nMemberID)
	if CTeamMgr.TeamGetMemberCount(self.nTeamID) <= 1 then
		TeamMgr:DeleteTeam(self.nTeamID);
		return true;
	end

	self:RemoveMember(nMemberID);
	return true;
end

function _TeamData:Add2ApplyerList(applyer, nActivityId)
	for _, tbData in ipairs(self.tbApplyerList) do
		if tbData.nID == applyer.dwID then
			return false;
		end
	end

	local szKinName = ""
	local nKinId = applyer.dwKinId
	local tbKin = Kin:GetKinById(nKinId)
	if tbKin then
		szKinName = tbKin.szName
	end
	local tbApplyData = {
					nID = applyer.dwID,
					szName = applyer.szName,
					szKinName = szKinName,
					nLevel = applyer.nLevel,
					nFaction = applyer.nFaction,
					nPortrait = applyer.nPortrait,
					nHonorLevel = applyer.nHonorLevel,
					nActivityId = nActivityId,
					nTime = GetTime()};

	table.insert(self.tbApplyerList, tbApplyData);

	local captain = KPlayer.GetPlayerObjById(self.nCaptainID);
	if captain then
		captain.CallClientScript("TeamMgr:OnSynAddApplyerTable", tbApplyData);
	end
	return true;
end

function _TeamData:RemoveFromApplyerList(nApplyerId)
	for nIdx, tbData in ipairs(self.tbApplyerList) do
		if tbData.nID == nApplyerId then
			table.remove(self.tbApplyerList, nIdx);
			return tbData;
		end
	end

	return false;
end

function _TeamData:ClearApplyerList()
	self.tbApplyerList = {};
end

----------------------------快速组队相关----------------------------------------
function _TeamData:ChangeTargetActivity(nActivityId)
	if self.nTargetActivityId == nActivityId then
		return true;
	end

	local szActivityName = TeamUp:GetActivityName(nActivityId);
	local tbMembers = self:GetMembers() or {};
	for _, nMemberID in pairs(tbMembers) do
		local member = KPlayer.GetPlayerObjById(nMemberID);
		if member then
			TeamMgr:SetQuickTeamHelpState(false, member);
			if nActivityId then
				local bRet, szInfo = TeamUp:Check(member, nActivityId);
				if not bRet then
					local bCanHelp = TeamUp:CheckHelp(member, nActivityId);
					if bCanHelp then
						TeamMgr:SetQuickTeamHelpState(true, member);
						member.CenterMsg("進入助戰狀態，參與活動不消耗次數也無法獲得獎勵！", true, ChatMgr.SystemMsgType.Team);
					else
						local szTips = string.format("「%s」%s", member.szName, szInfo or "");
						self:SendTeamInfo(szTips);
						return false;
					end
				end
			end
		end
	end

	TeamUp:RemoveFromeTeamList(self.nTargetActivityId, self);
	TeamUp:Add2TeamList(nActivityId, self);

	local szTips = nil;
	if szActivityName then
		szTips = string.format("目前隊伍目標更換為：%s", szActivityName);
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Team, szTips, self.nTeamID);
	end

	self.nTargetActivityId = nActivityId;
	self:TraversMembers(function (member)
		member.CallClientScript("TeamMgr:OnSynTargetActivityId", nActivityId);
		if szTips then
			member.CenterMsg(szTips);
		end
	end);

	TeamUp:DealWaitingList(self);
	TeamUp:ResetTeamListener(self.nTeamID);
	TeamUp:TeamInfoChanged(self, true);
	return true;
end

function _TeamData:GetTargetActivityId()
	return self.nTargetActivityId;
end


function _TeamData:SendTeamInfo(szMsg)
	ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Team, szMsg, self.nTeamID);
	self:TraversMembers(function (member)
		member.CenterMsg(szMsg);
	end);
end
