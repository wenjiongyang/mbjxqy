
function TeamBattle:CheckStart()
	local bCross = false;
	if GetTimeFrameState(TeamBattle.szCrossOpenTimeFrame) == 1 and not MODULE_ZONESERVER then
		bCross = true;
	end

	self.nExtType = self:GetCurrentLeagueType()

	local nWeekDay = Lib:GetLocalWeekDay();
	for _, nWD in pairs(TeamBattle.tbRefreshDay) do
		if nWD == nWeekDay then
			self:PreStartTeamBattle(TeamBattle.nPreMapTime, bCross);
			return;
		end
	end
end

function TeamBattle:PreStartTeamBattle(nPreTime, bCross, nType)
	nPreTime = nPreTime or TeamBattle.nPreMapTime;
	if not MODULE_ZONESERVER then
		local tbMsgData =
		{
			szType = "TeamBattle",
			nTimeOut = GetTime() + nPreTime,
		};

		local tbPlayer = KPlayer.GetAllPlayer();
		for _, pPlayer in pairs(tbPlayer) do
			if pPlayer.nLevel >= TeamBattle.nMinLevel and TeamBattle:GetLastTimes(pPlayer) > 0 then
				pPlayer.CallClientScript("Ui:SynNotifyMsg", tbMsgData);
			end
		end

		Calendar:OnActivityBegin("TeamBattle");
		SupplementAward:OnActivityOpen("TeamBattle");
	end

	local tbBattleMgr = {};
	setmetatable(tbBattleMgr, {__index = self.tbMgrClass});

	local nMapId = CreateMap(self.PRE_MAP_ID);
	tbBattleMgr:Init(nMapId, nPreTime, bCross, nType);

	self.nCurPreMapId = nMapId;
	self.tbCurBattleMgr = tbBattleMgr;

	self.tbTeamBattleMgrInstByMapId = self.tbTeamBattleMgrInstByMapId or {};
	self.tbTeamBattleMgrInstByMapId[nMapId] = tbBattleMgr;

	if not MODULE_ZONESERVER then
		KPlayer.SendWorldNotify(1, 999, TeamBattle.szStartNotifyInfo, 1, 1);
	else
		CallZoneClientScript(-1, "TeamBattle:OnSyncLeaguePreMap", nType, nMapId, false);
	end
end

function TeamBattle:CheckCanJoinPreMap(pPlayer, bIsSignle, nType)
	nType = nType or self.TYPE_NORMAL;
	if nType == self.TYPE_NORMAL and (not self.tbCurBattleMgr or not self.tbCurBattleMgr.bIsLoadOK) then
		return false, self.emMsgHasNoBattle;
	end

	if nType ~= self.TYPE_NORMAL and not self.bLeaguePreMapLoadOK then
		return false, self.emMsgHasNoBattle;
	end

	if nType == self.TYPE_NORMAL and not self.tbCurBattleMgr.bIsPreTime then
		return false, self.emMsgHasFight;
	end

	if nType ~= self.TYPE_NORMAL and not self.bLeagueIsPreTime then
		return false, self.emMsgHasFight;
	end

	local teamData = TeamMgr:GetTeamById(pPlayer.dwTeamID);
	if bIsSignle and teamData then
		return false, self.emMsgNotNeedTeam;
	end

	if not bIsSignle and not teamData then
		return false, self.emMsgNeedTeam;
	end

	if teamData and teamData.nCaptainID ~= pPlayer.dwID then
		return false, self.emMsgNotTeamCaptain;
	end

	local tbMember = TeamMgr:GetMembers(pPlayer.dwTeamID);
	if teamData and tbMember and #tbMember ~= self.nTeamMemeber then
		return false, self.emMsgTeamMemeberErr, {self.nTeamMemeber};
	end

	local nTodayZeroTime = Lib:GetTodayZeroHour();
	if tbMember then
		for _, nPlayerId in pairs(tbMember) do
			local pMember = KPlayer.GetPlayerObjById(nPlayerId);
			if not pMember then
				return false, self.emMsgMemberOffline;
			end

			if not Env:CheckSystemSwitch(pMember, Env.SW_TeamBattle) then
				return false, self.emMsgMemberSystemSwitch, {pMember.szName};
			end

			if nType == self.TYPE_NORMAL and TeamBattle:GetLastTimes(pMember) < 1 then
				return false, self.emMsgMemberTimesErr, {pMember.szName};
			end

			if nType == self.TYPE_NORMAL and self.nExtType ~= self.TYPE_NORMAL and TeamBattle:CheckTicket(pMember, self.nExtType, nTodayZeroTime) then
				return false, self.emMsgMemberHasLeagueTicket, {pMember.szName};
			end

			if nType ~= self.TYPE_NORMAL and not TeamBattle:CheckTicket(pMember, self.nExtType, nTodayZeroTime) then
				return false, self.emMsgMemberLeagueTicket, {pMember.szName};
			end

			if nType == self.TYPE_NORMAL and pMember.nLevel < self.nMinLevel then
				return false, self.emMsgMemberMinLevel, {pMember.szName, self.nMinLevel};
			end

			if not Fuben.tbSafeMap[pMember.nMapTemplateId] and Map:GetClassDesc(pMember.nMapTemplateId) ~= "fight" then
				return false, self.emMsgMemberSafeMap, {pMember.szName};
			end

			if Map:GetClassDesc(pMember.nMapTemplateId) == "fight" and pMember.nFightMode ~= 0 then
				return false, self.emMsgMemberNotSafePoint, {pMember.szName};
			end

			if not pMember.nState == Player.emPLAYER_STATE_ALONE then
				return false, self.emMsgMemberAloneState, {pMember.szName};
			end
		end
	end

	if not Env:CheckSystemSwitch(pPlayer, Env.SW_TeamBattle) then
		return false, self.emMsgSystemSwitch;
	end

	if nType == self.TYPE_NORMAL and TeamBattle:GetLastTimes(pPlayer) < 1 then
		return false, self.emMsgTimesErr;
	end

	if nType ~= self.TYPE_NORMAL and not TeamBattle:CheckTicket(pPlayer, nType, nTodayZeroTime) then
		return false, self.emMsgLeagueTicket;
	end

	if nType == self.TYPE_NORMAL and pPlayer.nLevel < self.nMinLevel then
		return false, self.emMsgMinLevel, {self.nMinLevel};
	end

	if not Fuben.tbSafeMap[pPlayer.nMapTemplateId] and Map:GetClassDesc(pPlayer.nMapTemplateId) ~= "fight"  then
		return false, self.emMsgSafeMap;
	end

	if Map:GetClassDesc(pPlayer.nMapTemplateId) == "fight" and pPlayer.nFightMode ~= 0 then
		return false, self.emMsgNotSafePoint;
	end

	if not pPlayer.nState == Player.emPLAYER_STATE_ALONE then
		return false, self.emMsgAloneState;
	end

	return true;
end

function TeamBattle:TryJoinPreMap(pPlayer, bIsSignle)
	local nTodayZeroTime = Lib:GetTodayZeroHour();
	local nType = self.TYPE_NORMAL;
	if self.nExtType and self.nExtType ~= self.TYPE_NORMAL and TeamBattle:CheckTicket(pPlayer, self.nExtType, nTodayZeroTime) then
		nType = self.nExtType
	end
	local bRet, nCode, tbParam = self:CheckCanJoinPreMap(pPlayer, bIsSignle, nType);
	if not bRet then
		if bIsSignle or nCode == self.emMsgNotTeamCaptain then
			self:SendMsgCode(pPlayer, nCode, unpack(tbParam or {}));
		else
			local tbMember = TeamMgr:GetMembers(pPlayer.dwTeamID) or {};
			if #tbMember <= 0 then
				table.insert(tbMember, pPlayer.dwID);
			end
			for _, nMemberId in pairs(tbMember) do
				self:SendMsgCode(nMemberId, nCode, unpack(tbParam or {}));
			end
		end
		return;
	end

	if bIsSignle then
		if nType == self.TYPE_NORMAL then
			self.tbCurBattleMgr:UpdatePlayerTeamInfo(pPlayer.dwID);
		else
			CallZoneServerScript("TeamBattle.tbCurBattleMgr:UpdatePlayerTeamInfo", pPlayer.dwID);
		end
		self:SwitchToPreMap(pPlayer, nType);
	else
		if nType == self.TYPE_NORMAL then
			local nTeamId = self.tbCurBattleMgr:GetTeamId();
			local tbMember = TeamMgr:GetMembers(pPlayer.dwTeamID);
			for _, nPlayerId in pairs(tbMember) do
				local pMember = KPlayer.GetPlayerObjById(nPlayerId);
				self:SwitchToPreMap(pMember, nType);
				self.tbCurBattleMgr:UpdatePlayerTeamInfo(nPlayerId, nTeamId);
			end
		else
			CallZoneServerScript("TeamBattle.tbCurBattleMgr:NotifyTeamEnter", pPlayer.dwID);
			local tbMember = TeamMgr:GetMembers(pPlayer.dwTeamID);
			for _, nPlayerId in pairs(tbMember) do
				local pMember = KPlayer.GetPlayerObjById(nPlayerId);
				CallZoneServerScript("TeamBattle.tbCurBattleMgr:UpdateLeaguePlayerTeamInfo", nPlayerId, pPlayer.dwID);
				self:SwitchToPreMap(pMember, nType);
			end
		end
	end
end


function TeamBattle:SwitchToPreMap(pPlayer, nType)
	pPlayer.CallClientScript("Ui:CloseWindow", "TeamBattlePanel");
	if nType == self.TYPE_NORMAL then
		pPlayer.SetEntryPoint();
		pPlayer.SwitchMap(self.nCurPreMapId, unpack(self.tbPreMapBeginPos[MathRandom(#self.tbPreMapBeginPos)]));
	else
		pPlayer.SwitchZoneMap(self.nLeaguePreMapId, unpack(self.tbPreMapBeginPos[MathRandom(#self.tbPreMapBeginPos)]));
	end
end

function TeamBattle:GetTopMapId()
	if not self.nTopMapId then
		return;
	end

	local nMapTemplateId = GetMapInfoById(self.nTopMapId);
	if not nMapTemplateId then
		self.nTopMapId = nil;
	end

	return self.nTopMapId;
end

function TeamBattle:SwitchToTopMap(pPlayer, bCross)
	local nTopMapId = self:GetTopMapId();
	if nTopMapId then
		pPlayer.SwitchMap(nTopMapId, unpack(self.tbTopPoint[MathRandom(#self.tbTopPoint)]));
	else
		if not self.bInCreateTopMap then
			self.bInCreateTopMap = true

			if MODULE_ZONESERVER or bCross then
				CreateMap(TeamBattle.TOP_MAP_ID_CROSS);
			else
				CreateMap(TeamBattle.TOP_MAP_ID);
			end
		end

		self.tbCacheTopPlayer = self.tbCacheTopPlayer or {};
		self.tbCacheTopPlayer[pPlayer.dwID] = true;
	end
end

function TeamBattle:OnTopMapCreate(nMapId)
	self.nTopMapId = nMapId;
	self.bInCreateTopMap = false;
	for nPlayerId in pairs(self.tbCacheTopPlayer or {}) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			pPlayer.SwitchMap(nMapId, unpack(self.tbTopPoint[MathRandom(#self.tbTopPoint)]));
		end
	end

	self.tbCacheTopPlayer = nil;
end

function TeamBattle:GoBack(pPlayer)
	if MODULE_ZONESERVER then
		pPlayer.ZoneLogout();
	else
		pPlayer.GotoEntryPoint();
	end
end

--------------------------------------------------------------------------------------
function TeamBattle:RegisterTopMap(nMapTemplateId)
	local tbMap = Map:GetClass(nMapTemplateId);
	function tbMap:OnCreate(nMapId)
		TeamBattle:OnTopMapCreate(nMapId);
	end

	local function KickoutPlayer(nPlayerId, nMapId)
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if not pPlayer or pPlayer.nMapId ~= nMapId then
			return;
		end

		if MODULE_ZONESERVER then
			pPlayer.ZoneLogout();
		else
			pPlayer.GotoEntryPoint();
		end
	end

	function tbMap:OnEnter(nMapId)
		me.nFightMode = 1;
		me.nCanLeaveMapId = me.nMapId;
		me.CallClientScript("Ui:OpenWindow", "QYHLeavePanel");
		me.CallClientScript("Map:SetCloseUiOnLeave", nMapId, "QYHLeavePanel");
		me.CallClientScript("TeamBattle:DealyShowTeamInfo", 3);
		Timer:Register(Env.GAME_FPS * TeamBattle.nTopMapTime, KickoutPlayer, me.dwID, nMapId);
	end
end

TeamBattle:RegisterTopMap(TeamBattle.TOP_MAP_ID);
if TeamBattle.TOP_MAP_ID_CROSS ~= TeamBattle.TOP_MAP_ID then
	TeamBattle:RegisterTopMap(TeamBattle.TOP_MAP_ID_CROSS);
end

