ChatMgr.nCacheChatMaxCount = 10;

if not MODULE_ZONESERVER then
	ChatMgr.MAX_CREATE_REQUEST_ONCE = 2
else
	ChatMgr.MAX_CREATE_REQUEST_ONCE = 10
end

ChatMgr.CREATE_REQUEST_INTERVAL = 0.5

if not MODULE_ZONESERVER then
	ChatMgr.MAX_JOIN_REQUEST_ONCE = 5
else
	ChatMgr.MAX_JOIN_REQUEST_ONCE = 20
end

ChatMgr.JOIN_REQUEST_INTERVAL = 0.5

ChatMgr.tbRoomList = ChatMgr.tbRoomList or {};
ChatMgr.tbKinRoomList = ChatMgr.tbKinRoomList or {};
ChatMgr.tbTeamRoomList = ChatMgr.tbTeamRoomList or {};
ChatMgr.tbCreateKinRoomQueue = ChatMgr.tbCreateKinRoomQueue or {};
ChatMgr.tbCreateTeamRoomQueue = ChatMgr.tbCreateTeamRoomQueue or {};
ChatMgr.tbJoinRoomQueue = ChatMgr.tbJoinRoomQueue or {};
ChatMgr.tbCrossHostRoomInfo = ChatMgr.tbCrossHostRoomInfo or nil;
ChatMgr.tbCrossHostRoomKey = ChatMgr.tbCrossHostRoomKey or {};
ChatMgr.nNextCreateHostRoomTime = ChatMgr.nNextCreateHostRoomTime or math.huge;

ChatMgr.tbDynamicChatMaxCountInfo = ChatMgr.tbDynamicChatMaxCountInfo or {};
ChatMgr.nDynamicChatMaxCountDay = ChatMgr.nDynamicChatMaxCountDay or 0;
ChatMgr.tbDynamicChatLastSendInfo = ChatMgr.tbDynamicChatLastSendInfo or {};
ChatMgr.tbHostFollowingMap = ChatMgr.tbHostFollowingMap or {};

ChatMgr.bApolloVoice = false

function ChatMgr:Init()
	if not self.nCreateRoomTimer then
		self.nCreateRoomTimer = Timer:Register(math.floor(Env.GAME_FPS * ChatMgr.CREATE_REQUEST_INTERVAL), self.OnCreateRoomTimer, self);
	end

	if not self.nJoinRoomTimer then
		self.nJoinRoomTimer = Timer:Register(math.floor(Env.GAME_FPS * ChatMgr.JOIN_REQUEST_INTERVAL), self.OnJoinRoomTimer, self);
	end

	ChatMgr:LoadFilterText()
end

function ChatMgr:OnLogin()
	local kinData = Kin:GetKinByMemberId(me.dwID);
	if kinData then
		local kinChatCache = kinData:GetChatCache();
		me.CallClientScript("ChatMgr:OnSyncChatOfflineData", {
			[ChatMgr.ChannelType.Kin] = kinChatCache;
			});
	end

	me.CallClientScript("ChatMgr:OnSyncApolloVoice", self.bApolloVoice);

	ChatMgr:CheckCrossHostNotify(me);

	ChatMgr:CheckSyncGVoiceParam(me)
end

function ChatMgr:OnLogout(pPlayer)
	if KChat.IsPlayerInCrossChannel(pPlayer.dwID) then
		ChatMgr:LeaveCrossChannel(pPlayer);
	end
end

function ChatMgr:OnReConnect(pPlayer)
	local bJoind, nAuth = KChat.IsPlayerInCrossChannel(pPlayer.dwID);
	if bJoind then
		ChatMgr:DoJoinCrossChannel(pPlayer, nAuth);
	end
end

function ChatMgr:OnTransferZone(pPlayer)
	if KChat.IsPlayerInCrossChannel(pPlayer.dwID) then
		ChatMgr:LeaveCrossChannel(pPlayer);
	end
end

function ChatMgr:CacheChatChannel(nChannelId, nSenderId, szSenderName, nFaction, nPortrait, nLevel, nHeadBg, nChatBg, szMsg, tbLinkInfo)
	if (not szMsg or szMsg == "") and not tbLinkInfo then
		--Apollo语音在翻译之前会有空的内容
		return
	end

	if nChannelId == ChatMgr.ChannelType.Kin then
		ChatMgr:CacheKinChat(nChannelId, nSenderId, szSenderName, nFaction, nPortrait, nLevel, nHeadBg, nChatBg, szMsg, tbLinkInfo);
	end

	if nChannelId == ChatMgr.ChannelType.Public then
		self.ChatAward:OnChat(nSenderId, szMsg);
	end
end

function ChatMgr:CacheKinChat(nChannelId, nSenderId, szSenderName, nFaction, nPortrait, nLevel, nHeadBg, nChatBg, szMsg, tbLinkInfo)
	local kinData = Kin:GetKinByMemberId(nSenderId);
	if not kinData then
		return;
	end

	kinData:CacheChatMsg(nChannelId, nSenderId, szSenderName, nFaction, nPortrait, nLevel, nHeadBg, nChatBg, szMsg, tbLinkInfo);
end

function ChatMgr:SendSystemMsg(nSystemMsgType, szMsg, nParam, tbLinkData)
	local nChannelId = ChatMgr:GetSystemMsgChannel(nSystemMsgType);
	nParam = nParam or 0;

	SendSystemChannelMsg(nSystemMsgType, szMsg, nChannelId, nParam, tbLinkData);
end

function ChatMgr:SendTeamOrSysMsg(pPlayer, szMsg, nParam, tbLinkData)
	if pPlayer.dwTeamID ~= 0 then
		self:SendSystemMsg(ChatMgr.SystemMsgType.Team, szMsg, pPlayer.dwTeamID, tbLinkData)
	else
		pPlayer.Msg(szMsg)
	end
end

function ChatMgr:SendPlayerMsg(nChannelId, nSenderId, szSenderName, nFaction, nPortrait, nLevel, szMsg, tbLinkData, nChannelParam)
	SendPlayerChatMsg(nChannelId, nSenderId, szSenderName, nFaction, nPortrait, nLevel, szMsg, tbLinkData, nChannelParam);
end

function ChatMgr:AddColorChatCount(player, nCount)
	local nColorTimes = player.GetUserValue(ChatMgr.COLOR_MSG_USER_VALUE_GROUP, ChatMgr.COLOR_MSG_USER_VALUE_KEY);
	player.SetUserValue(ChatMgr.COLOR_MSG_USER_VALUE_GROUP, ChatMgr.COLOR_MSG_USER_VALUE_KEY, nColorTimes + nCount);
end

function ChatMgr:AddPublicChatCount(player, nCount)
	local nLeftCount = player.GetUserValue(ChatMgr.CHAT_COUNT_USER_VALUE_GROUP, ChatMgr.PUBLIC_CHAT_USER_VALUE_KEY);
	player.SetUserValue(ChatMgr.CHAT_COUNT_USER_VALUE_GROUP, ChatMgr.PUBLIC_CHAT_USER_VALUE_KEY, nLeftCount + nCount);
end

function ChatMgr:AddCrossChatCount(player, nCount)
	local nLeftCount = player.GetUserValue(ChatMgr.CHAT_COUNT_USER_VALUE_GROUP, ChatMgr.CROSS_CHAT_USER_VALUE_KEY);
	player.SetUserValue(ChatMgr.CHAT_COUNT_USER_VALUE_GROUP, ChatMgr.CROSS_CHAT_USER_VALUE_KEY, nLeftCount + nCount);
end

function ChatMgr:ReduceColorChatCount(player, nCount)
	nCount = nCount or 1;
	local nLeftCount = player.GetUserValue(ChatMgr.COLOR_MSG_USER_VALUE_GROUP, ChatMgr.COLOR_MSG_USER_VALUE_KEY);
	if nLeftCount >= nCount then
		player.SetUserValue(ChatMgr.COLOR_MSG_USER_VALUE_GROUP, ChatMgr.COLOR_MSG_USER_VALUE_KEY, nLeftCount - nCount);
		return true;
	end
	return false;
end

function ChatMgr:ReducePublicChatCount(player, nCount)
	nCount = nCount or 1;
	if DegreeCtrl:ReduceDegree(player, "PublicChatCount", nCount) then
		return true;
	end

	local nLeftCount = player.GetUserValue(ChatMgr.CHAT_COUNT_USER_VALUE_GROUP, ChatMgr.PUBLIC_CHAT_USER_VALUE_KEY);
	if nLeftCount >= nCount then
		player.SetUserValue(ChatMgr.CHAT_COUNT_USER_VALUE_GROUP, ChatMgr.PUBLIC_CHAT_USER_VALUE_KEY, nLeftCount - nCount);
		return true;
	end
	return false;
end

function ChatMgr:ReduceCrossChatCount(player, nCount)
	nCount = nCount or 1;
	if DegreeCtrl:ReduceDegree(player, "CrossChatCount", nCount) then
		return true;
	end

	local nLeftCount = player.GetUserValue(ChatMgr.CHAT_COUNT_USER_VALUE_GROUP, ChatMgr.CROSS_CHAT_USER_VALUE_KEY);
	if nLeftCount >= nCount then
		player.SetUserValue(ChatMgr.CHAT_COUNT_USER_VALUE_GROUP, ChatMgr.CROSS_CHAT_USER_VALUE_KEY, nLeftCount - nCount);
		return true;
	end
	return false;
end

function ChatMgr:CheckSendMsg(playerId, channelId)
	local bForbid = ChatMgr:CheckChannelForbid(playerId, channelId);
	if bForbid then
		return false;
	end

	local player = KPlayer.GetPlayerObjById(playerId);
	if not player then
		return false;
	end

	if channelId == ChatMgr.ChannelType.Public then
		if not ChatMgr:ReducePublicChatCount(player, 1) then
			return false;
		end
	elseif channelId == ChatMgr.ChannelType.Color then
		if not ChatMgr:ReduceColorChatCount(player, 1) then
			return false;
		end
	elseif channelId == ChatMgr.ChannelType.Cross then
		if not ChatMgr:ReduceCrossChatCount(player, 1) then
			return false;
		end
	elseif channelId == ChatMgr.ChannelType.Kin then
		local kinMemberData = Kin:GetMemberData(playerId);
		local nLeftTime = kinMemberData and kinMemberData.nForbidTime
							and kinMemberData.nForbidTime - GetTime();
		if nLeftTime and nLeftTime > 0 then
			player.CenterMsg(string.format("你目前處於禁言中，剩餘%s", Lib:TimeDesc2(nLeftTime)));
			return false;
		end
	elseif channelId == ChatMgr.ChannelType.Nearby then
		return Map:CanNearbyChat(player.nMapTemplateId);
	end

	return true;
end

function ChatMgr:CheckChannelForbid(playerId, channelId)
	local pAsyncData = KPlayer.GetAsyncData(playerId)
	if not pAsyncData then
		return false;
	end

	local forbidType = pAsyncData.GetChatForbidType()
	local forbidEndTime = pAsyncData.GetChatForbidEndTime()
	local forbidSilence = pAsyncData.GetChatForbidSilence()

	if forbidType == ChatMgr.ForbidType.None or (forbidSilence == 1 and (channelId == ChatMgr.ChannelType.Public or channelId == ChatMgr.ChannelType.Color)) then
		--因为自言自语类型的禁言需要发给自己，返回true在c++中send的时候再判断
		return false;
	end

	if forbidType == ChatMgr.ForbidType.All or
		(forbidType == ChatMgr.ForbidType.Public and
		(channelId == ChatMgr.ChannelType.Public or channelId == ChatMgr.ChannelType.Color or channelId == ChatMgr.ChannelType.Nearby))  then

		local nCurTime = GetTime();

		if forbidEndTime == 0 or  forbidEndTime > nCurTime then
			local player = KPlayer.GetPlayerObjById(playerId);
			if player then
				if forbidEndTime == 0 then
					player.CenterMsg("你目前處於永久禁言中");
				else
					player.CenterMsg(string.format("你目前處於禁言中，剩餘%s", Lib:TimeDesc2(forbidEndTime - nCurTime)));
				end
			end

			return true;
		end
	end

	return false;
end

function ChatMgr:CheckFactionChannelMsg(pPlayer, nChannelId)
	local nCurDay = Lib:GetLocalDay();
	if nCurDay ~= self.nDynamicChatMaxCountDay then
		self.nDynamicChatMaxCountDay = nCurDay;
		self.tbDynamicChatMaxCountInfo = {};
	end

	local playerId = pPlayer.dwID;
	local nLastSend = self.tbDynamicChatLastSendInfo[playerId];
	local nNow = GetTime();

	if nLastSend and (nLastSend + 10) > nNow then
		pPlayer.CenterMsg(string.format("還需%d秒後才能再發言", (nLastSend + 10) - nNow));
		return false;
	end

	self.tbDynamicChatLastSendInfo[playerId] = nNow;

	if not self.tbDynamicChatMaxCountInfo[playerId] then
		self.tbDynamicChatMaxCountInfo[playerId] = 0;
	end

	local nVipLevel = pPlayer.GetVipLevel();
	local nLimit = nVipLevel > 0 and 20 or 10;
	if self.tbDynamicChatMaxCountInfo[playerId] >= nLimit then
		pPlayer.CenterMsg(string.format("你今天門派頻道發言已達到%d次上限，無法再發言", nLimit));
		return false;
	end

	self.tbDynamicChatMaxCountInfo[playerId] = self.tbDynamicChatMaxCountInfo[playerId] + 1;
	return true;
end

function ChatMgr:OnChatRoomCreate(uRoomHighId, uRoomLowId, nType, nIsLarge, dwParam)
	Log("OnChatRoomCreate", uRoomHighId, uRoomLowId, nType, nIsLarge, dwParam);
	local tbRoomInfo =
	{
		szRoomId = string.format("%u%u", uRoomHighId, uRoomLowId),
		uRoomHighId = uRoomHighId,
		uRoomLowId = uRoomLowId,
		nType  = nType,
		nIsLarge = nIsLarge,
		dwParam = dwParam,
		tbMemberList = {},
	}

	ChatMgr.tbRoomList[tbRoomInfo.szRoomId] = tbRoomInfo;

	if nType == ChatMgr.RoomType.emKin then
		ChatMgr.tbKinRoomList[tbRoomInfo.dwParam] = tbRoomInfo;
		Kin:OnCreateChatRoom(dwParam, uRoomHighId, uRoomLowId)
	elseif nType == ChatMgr.RoomType.emTeam then
		ChatMgr.tbTeamRoomList[tbRoomInfo.dwParam] = tbRoomInfo;
		TeamMgr:OnCreateChatRoom(dwParam, uRoomHighId, uRoomLowId)
	elseif nType == ChatMgr.RoomType.emCrossHost then
		ChatMgr.tbCrossHostRoomInfo = tbRoomInfo;
		ChatMgr:OnCreateCrossHostRoom(uRoomHighId, uRoomLowId);
	else
		Log("[Error] Create ChatRoom unknown type", uRoomHighId, uRoomLowId, nType, nIsLarge, dwParam)
	end
end

function ChatMgr:OnCloseChatRoom(uRoomHighId, uRoomLowId, nType, nIsLarge)
	Log("OnCloseChatRoom", uRoomHighId, uRoomLowId, nType, nIsLarge);
	local szRoomId = string.format("%u%u", uRoomHighId, uRoomLowId);
	local tbRoomInfo = self.tbRoomList[szRoomId];

	if not tbRoomInfo then
		Log("[Error] Close ChatRoom not in list", uRoomHighId, uRoomLowId, nType, nIsLarge)
		return
	end

	if tbRoomInfo.nType == ChatMgr.RoomType.emKin then
		ChatMgr.tbKinRoomList[tbRoomInfo.dwParam] = nil;
	elseif tbRoomInfo.nType == ChatMgr.RoomType.emTeam then
		ChatMgr.tbTeamRoomList[tbRoomInfo.dwParam] = nil;
	elseif tbRoomInfo.nType == ChatMgr.RoomType.emCrossHost then
		ChatMgr.tbCrossHostRoomInfo = nil;
	else
		Log("[Error] Close ChatRoom unknown type", uRoomHighId, uRoomLowId, nType, nIsLarge, dwParam)
	end

	self.tbRoomList[szRoomId] = nil;
end

function ChatMgr:OnJoinChatRoom(uRoomHighId, uRoomLowId, nType, nIsLarge, dwMemberId, pPlayer)
	Log("OnJoinChatRoom", uRoomHighId, uRoomLowId, nType, nIsLarge, dwMemberId);

	local szRoomId = string.format("%u%u", uRoomHighId, uRoomLowId);
	local tbRoomInfo = self.tbRoomList[szRoomId];

	if not tbRoomInfo then
		Log("[Error] Join ChatRoom not in list", uRoomHighId, uRoomLowId, nType, nIsLarge, dwMemberId)
		return
	end

	local tbMemberInfo =
	{
		dwRoleID = pPlayer.dwID,
		szAccount = pPlayer.szAccount,
		dwMemberId = dwMemberId,
	}

	if tbRoomInfo.nType == ChatMgr.RoomType.emKin then

	elseif tbRoomInfo.nType == ChatMgr.RoomType.emTeam then

	elseif tbRoomInfo.nType == ChatMgr.RoomType.emCrossHost then

	else
		Log("[Error] Join ChatRoom unknown type", uRoomHighId, uRoomLowId, nType, nIsLarge, dwMemberId)
	end

	tbRoomInfo.tbMemberList[tbMemberInfo.dwRoleID] = tbMemberInfo;
end

function ChatMgr:OnLeaveChatRoom(uRoomHighId, uRoomLowId, nType, nIsLarge, dwMemberId, dwRoleID)
	Log("OnLeaveChatRoom", uRoomHighId, uRoomLowId, nType, nIsLarge, dwMemberId);

	local szRoomId = string.format("%u%u", uRoomHighId, uRoomLowId);
	local tbRoomInfo = self.tbRoomList[szRoomId];

	if not tbRoomInfo then
		Log("[Error] Leave ChatRoom not in list", uRoomHighId, uRoomLowId, nType, nIsLarge, dwMemberId, dwRoleID)
		return
	end

	if tbRoomInfo.nType == ChatMgr.RoomType.emKin then

	elseif tbRoomInfo.nType == ChatMgr.RoomType.emTeam then

	elseif tbRoomInfo.nType == ChatMgr.RoomType.emCrossHost then

	else
		Log("[Error] Leave ChatRoom unknown type", uRoomHighId, uRoomLowId, nType, nIsLarge, dwMemberId)
	end

	tbRoomInfo.tbMemberList[dwRoleID] = nil;
end

function ChatMgr:CreateKinChatRoom(dwKinId)
	Log("CreateKinChatRoom", dwKinId)
	local tbRoomInfo = self.tbKinRoomList[dwKinId];
	if tbRoomInfo then
		return
	end

	if self.tbCreateKinRoomQueue[dwKinId] then
		return
	end

	self.tbCreateKinRoomQueue[dwKinId] = dwKinId;
end

function ChatMgr:CreateTeamChatRoom(dwTeamID)
	Log("CreateTeamChatRoom", dwTeamID)
	local tbRoomInfo = self.tbTeamRoomList[dwTeamID];
	if tbRoomInfo then
		return
	end

	if self.tbCreateTeamRoomQueue[dwTeamID] then
		return
	end

	self.tbCreateTeamRoomQueue[dwTeamID] = dwTeamID;
end


function ChatMgr:IsKinHaveChatRoom(dwKinId)
	return self.tbKinRoomList[dwKinId] ~= nil;
end

function ChatMgr:IsTeamHaveChatRoom(dwTeamID)
	return self.tbTeamRoomList[dwTeamID] ~= nil;
end

function ChatMgr:GetRoomInfoByPlayer(pPlayer, nChatRoomType)
	local tbRoomInfo;

	if KChat.IsPlayerInCrossChannel(pPlayer.dwID) then
		if nChatRoomType == ChatMgr.ChannelType.Cross then
			return self.tbCrossHostRoomInfo;
		else
			if ChatMgr:IsCrossHost(pPlayer) then
				Log("Chatting Cross Host Can not join other chat room");
				return nil;
			end
		end
	end

	if pPlayer.dwKinId > 0 then
		tbRoomInfo = self.tbKinRoomList[pPlayer.dwKinId];
		if tbRoomInfo then
			return tbRoomInfo
		end
	end
	if pPlayer.GetNpc().dwTeamID > 0 then
		tbRoomInfo = self.tbTeamRoomList[pPlayer.GetNpc().dwTeamID]
		if tbRoomInfo then
			return tbRoomInfo
		end
	end

	Log("[Error] GetRoomInfoByPlayer player have no kin and not Team", pPlayer.dwID, pPlayer.szName, pPlayer.dwKinId, pPlayer.GetNpc().dwTeamID)
end

function ChatMgr:JoinChatRoom(pPlayer, nPrivilege, nChatRoomType)
	Log("JoinChatRoom", pPlayer.dwID, pPlayer.dwKinId, pPlayer.dwTeamID)

	local tbRoomInfo = self:GetRoomInfoByPlayer(pPlayer, nChatRoomType)
	if not tbRoomInfo then
		Log("[Error] JoinChatRoom no create", pPlayer.dwID, pPlayer.szName, pPlayer.dwKinId, pPlayer.dwTeamID)
		return
	end

	local nPlayerId = pPlayer.dwID;
	if KChat.IsPlayerInCrossChannel(nPlayerId) and nChatRoomType ~= ChatMgr.ChannelType.Cross then
		ChatMgr:LeaveCrossChannel(pPlayer);
	end

	if self.tbJoinRoomQueue[nPlayerId] then
		return
	end

	self.tbJoinRoomQueue[nPlayerId] = {nPrivilege, nChatRoomType};
end

function ChatMgr:LeaveChatRoom(pPlayer)
	local nPlayerId = pPlayer.dwID;
	Log("LeaveChatRoom", nPlayerId, pPlayer.szName)
	self.tbJoinRoomQueue[nPlayerId] = nil
	return KChat.LeaveChatRoom(nPlayerId);
end

function ChatMgr:LeaveKinChatRoom(pPlayer)

	local nPlayerId = pPlayer.dwID;

	Log("LeaveKinChatRoom", nPlayerId, pPlayer.szName, pPlayer.dwKinId, tostring(ChatMgr:IsKinHaveChatRoom(pPlayer.dwKinId)))
	if KChat.IsPlayerInCrossChannel(pPlayer.dwID) then
		Log("LeaveKinChatRoom But In Cross Room");
		return;
	end

	self.tbJoinRoomQueue[nPlayerId] = nil;
	return KChat.LeaveChatRoom(nPlayerId);
end

function ChatMgr:CloseChatRoom(uRoomHighId, uRoomLowId)
	return KChat.CloseChatRoom(uRoomHighId, uRoomLowId);
end

function ChatMgr:ClearRoleChatMsgOnClient(dwRoleID)
	if not dwRoleID then
		return
	end

	local tbPlayer = KPlayer.GetAllPlayer();
	for _, pPlayer in pairs(tbPlayer) do
		pPlayer.CallClientScript("ChatMgr:ClearRoleChatMsg", dwRoleID);
	end
end

function ChatMgr:OnCreateRoomTimer()
	local nCount = 0;
	for key,dwKinId in pairs(self.tbCreateKinRoomQueue) do
		local ret = KChat.CreateKinChatRoom(dwKinId);
		if not ret then
			Log("CreateKinChatRoom Fail",  tostring(dwKinId));
		end
		self.tbCreateKinRoomQueue[key] = nil
		nCount = nCount + 1;
		if nCount >= ChatMgr.MAX_CREATE_REQUEST_ONCE then
			break;
		end
	end

	for key,dwTeamID in pairs(self.tbCreateTeamRoomQueue) do
		local ret = KChat.CreateTeamChatRoom(dwTeamID);
		if not ret then
			Log("CreateTeamChatRoom Fail",  tostring(dwTeamID));
		end
		self.tbCreateTeamRoomQueue[key] = nil
		nCount = nCount + 1;
		if nCount >= ChatMgr.MAX_CREATE_REQUEST_ONCE then
			break;
		end
	end

	local nNow = GetTime();
	if nNow > ChatMgr.nNextCreateHostRoomTime and next(ChatMgr.tbCrossHostRoomKey or {}) then
		ChatMgr.nNextCreateHostRoomTime = nNow + 5;
		local bRet = KChat.CreatLargeChatRoomByRoomId(unpack(ChatMgr.tbCrossHostRoomKey));
		if not bRet then
			Log("Create Cross Host ChatRoom Fail", self.szCrossHostRoomKey);
		end
	end

	return true;
end

function ChatMgr:OnJoinRoomTimer()
	local nCount = 0;
	for nPlayerId, tbInfo in pairs(self.tbJoinRoomQueue) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if  pPlayer then
			local nPrivilege, nChatRoomType = unpack(tbInfo);
			local tbRoomInfo = self:GetRoomInfoByPlayer(pPlayer, nChatRoomType);
			if tbRoomInfo then
				local ret = KChat.JoinChatRoom(tbRoomInfo.uRoomHighId, tbRoomInfo.uRoomLowId, pPlayer.dwID, nPrivilege);
				if not ret then
					Log("JoinChatRoom Fail",  pPlayer.dwID, pPlayer.dwKinId, pPlayer.dwTeamID, tbRoomInfo.uRoomHighId, tbRoomInfo.uRoomLowId);
				end
			end
		end

		self.tbJoinRoomQueue[nPlayerId] = nil
		nCount = nCount + 1;
		if nCount >= ChatMgr.MAX_JOIN_REQUEST_ONCE then
			break;
		end
	end
	return true;
end

function ChatMgr:CheckPlayerChatActionBQ(pPlayer, nChatID)
	local pNpc = pPlayer.GetNpc();
    if not pNpc then
        return false, "無法使用動作表情";
    end

    if pNpc.nShapeShiftNpcTID > 0 and not Npc.tbActionBQNpcID[pNpc.nShapeShiftNpcTID] then
        return false, "變身狀態下無法使用動作表情";
    end

    local tbChatInfo = self:GetActionBQInfo(pNpc.nShapeShiftNpcTID, nChatID);
    if not tbChatInfo then
    	return false, "聊天資訊錯誤！";
    end

    if pPlayer.nFightMode ~= Npc.FIGHT_MODE.emFightMode_None then
    	return false, "戰鬥狀態下無法使用動作表情";
    end

    local nResult = pNpc.CanChangeDoing(Npc.Doing.skill);
    local nActRes = pNpc.GetActionResType();
    if nResult == 0 and nActRes == 0 then
        return false, "當前狀態不能用動作表情";
    end

    return true, "", tbChatInfo;
end

function ChatMgr:PlayerChatActionBQ(pPlayer, nChatID)
	local bRet, szMsg, tbChatInfo = self:CheckPlayerChatActionBQ(pPlayer, nChatID);
	if not bRet then
		pPlayer.CenterMsg(szMsg, true);
		return;
	end

	local pNpc = pPlayer.GetNpc();
	if not pNpc then
		return;
	end

	local szSendMsg = tbChatInfo.Content;
	if not Lib:IsEmptyStr(szSendMsg) then
		szSendMsg = string.gsub(szSendMsg, "$M", pPlayer.szName) or szSendMsg;
		ChatMgr:SendPlayerMsg(ChatMgr.ChannelType.Nearby, pPlayer.dwID, pPlayer.szName, pPlayer.nFaction, pPlayer.nPortrait, pPlayer.nLevel, szSendMsg);
	end

	if tbChatInfo.ActionID > 0 then
		local nCurActMode = pPlayer.GetActionMode();
    	if nCurActMode ~= Npc.NpcActionModeType.act_mode_none then
    		ActionMode:DoForceNoneActMode(pPlayer);
    	end

		pNpc.DoCommonAct(tbChatInfo.ActionID, tbChatInfo.ActionEvent or 0, tbChatInfo.ActionLoop or 0, 0, 1);
	end
end

function ChatMgr:OnApolloAuth(pPlayer, uMainId, szMainUrl1, szMainUrl2, uMainIp1, uMainIp2, uSlaveId, szSlaveUrl1, szSlaveUrl2, uSlaveIp1, uSlaveIp2, uExpireTime, szAuthKey)

	Log("OnApolloAuth", pPlayer.dwID, uMainId, szMainUrl1, szMainUrl2, uMainIp1, uMainIp2, uSlaveId, szSlaveUrl1, szSlaveUrl2, uSlaveIp1, uSlaveIp2, uExpireTime, szAuthKey);

	pPlayer.CallClientScript("ChatMgr:OnApolloAuth", uMainId, szMainUrl1, szMainUrl2, uMainIp1, uMainIp2, uSlaveId, szSlaveUrl1, szSlaveUrl2, uSlaveIp1, uSlaveIp2, uExpireTime, szAuthKey);
end

function ChatMgr:SetApolloVoiceEnable(bEnable)
	self.bApolloVoice = bEnable
	KPlayer.BoardcastScript(1, "ChatMgr:OnSyncApolloVoice", self.bApolloVoice);
end

function ChatMgr:SetCrossHostAuth(pPlayer, nAuth)
	if nAuth ~= ChatMgr.ChatCrossAuthType.emHost
		and ChatMgr:IsCrossHost(pPlayer)
		and KChat.IsPlayerInCrossChannel(pPlayer.dwID)
		then
		ChatMgr:LeaveCrossChannel(pPlayer);
		pPlayer.CenterMsg("您已被取消主播許可權");
	end

	pPlayer.SetUserValue(ChatMgr.CHAT_CROSS_AUTH_GROUP, ChatMgr.CHAT_CROSS_AUTH_KEY, nAuth);
	return true;
end

function ChatMgr:SendCrossHostNotify(tbHostInfo, bNew)
	if not bNew then
		local szMsg = string.format("主播「%s」目前已經下播，我們下期再見！", tbHostInfo.szName or "null");
		KPlayer.SendWorldNotify(1, 1000, szMsg, ChatMgr.ChannelType.Public, 1);
		return;
	end

	local nSendCount = 3;
	local szServerName = Sdk:GetServerDesc(tbHostInfo.nServerId) or "某服";
	local szMsg = string.format("來自%s的「%s」登入了主播頻道，與眾俠士暢談江湖趣事，歡迎大家前往聊天欄【主播】頻道一撩！", szServerName, tbHostInfo.szName);
	local function fnSend()
		if not ChatMgr:HasCrossHosters() then
			return false;
		end

		KPlayer.SendWorldNotify(1, 1000, szMsg, ChatMgr.ChannelType.Public, 1);
		nSendCount = nSendCount - 1;
		return nSendCount > 0;
	end

	if fnSend() then
		Timer:Register(Env.GAME_FPS * 60, fnSend);
	end

	-- 对所有关注该主播的玩家发送最新消息
	local tbFollowers = ChatMgr.tbHostFollowingMap[tbHostInfo.nPlayerId or 0] or {};
	local tbNofityData = {
		szType = "CrossHostStart",
		nTimeOut = GetTime() + 60,
		szHostName = tbHostInfo.szName,
	};

	for nFollowerId, _ in pairs(tbFollowers) do
		local pFollower = KPlayer.GetPlayerObjById(nFollowerId);
		if pFollower then
			pFollower.CallClientScript("Ui:SynNotifyMsg", tbNofityData);
		end
	end
end

function ChatMgr:AddCrossHostFollowMap(nHostId, nFollowerId)
	self.tbHostFollowingMap[nHostId] = self.tbHostFollowingMap[nHostId] or {};
	self.tbHostFollowingMap[nHostId][nFollowerId] = true;
end

function ChatMgr:RemoveCrossHostFollowMap(nHostId, nFollowerId)
	self.tbHostFollowingMap[nHostId] = self.tbHostFollowingMap[nHostId] or {};
	self.tbHostFollowingMap[nHostId][nFollowerId] = nil;
end

function ChatMgr:CheckCrossHostNotify(pPlayer)
	local tbCurFollowList = ChatMgr:GetCrossHostFollowings(pPlayer);
	local tbCurHostInfo = unpack(ChatMgr:GetCurCrossHostInfo());
	for _, nHostId in ipairs(tbCurFollowList) do
		ChatMgr:AddCrossHostFollowMap(nHostId, pPlayer.dwID);

		if tbCurHostInfo and tbCurHostInfo.nPlayerId == nHostId then
			pPlayer.CallClientScript("Ui:SynNotifyMsg", {
				szType = "CrossHostStart",
				nTimeOut = GetTime() + 60,
				szHostName = tbCurHostInfo.szName,
			});
		end
	end
end

local function GetDiffHosts(tbOrg, tbNew)
	local tbDiffList = {};
	local function fnEqual(a, b)
		return a.nPlayerId == b.nPlayerId;
	end

	for _, tbHostInfo in ipairs(tbOrg) do
		if Lib:GetCountInTable(tbNew, fnEqual, tbHostInfo) == 0 then
			table.insert(tbDiffList, {tbHostInfo, false});
		end
	end

	for _, tbHostInfo in ipairs(tbNew) do
		if Lib:GetCountInTable(tbOrg, fnEqual, tbHostInfo) == 0 then
			table.insert(tbDiffList, {tbHostInfo, true});
		end
	end

	return tbDiffList;
end

function ChatMgr:SetHostInfo(...)
	local tbOldHostsInfo = self.tbCurCrossHostInfo or {};
	local tbHostExtraInfo = {};
	self.tbCurCrossHostInfo = {};
	local tbHostsInfo = { ... };
	for _, tbHostInfo in ipairs(tbHostsInfo) do
		local szHostName, nPlayerId, nServerId = unpack(tbHostInfo);
		local tbHostDetail = self.tbHostInfoList[nPlayerId] or {};
		table.insert(self.tbCurCrossHostInfo, {
				szName = tbHostDetail.Name or szHostName;
				nPlayerId = nPlayerId;
				nServerId = nServerId;
				szHeadUrl = tbHostDetail.HeadUrl;
			});
	end

	local tbDiffList = GetDiffHosts(tbOldHostsInfo, self.tbCurCrossHostInfo);
	for _, tbInfo in ipairs(tbDiffList) do
		local tbHostInfo, bNew = unpack(tbInfo);
		ChatMgr:SendCrossHostNotify(tbHostInfo, bNew);
	end

	local tbCrossPlayersId = KChat.GetCrossChannelPlayerIds();

	for nPlayerId, _ in pairs(tbCrossPlayersId) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			pPlayer.CallClientScript("ChatMgr:OnSyncCurCrossHostInfo", self.tbCurCrossHostInfo);
		end
	end

	if ChatMgr:HasCrossHosters() then
		if not ChatMgr.tbCrossHostRoomInfo then
			ChatMgr.nNextCreateHostRoomTime = 0;
		end
	else
		ChatMgr.tbCrossHostRoomInfo = nil;
		ChatMgr.nNextCreateHostRoomTime = math.huge;
	end
end

local tbJoinHostErrMsg = {
	[1] = "當前主播已滿員，您無法加入直播";
	[2] = "您當前正在直播，無法再次加入";
};

function ChatMgr:OnReqHostRespond(nPlayerId, nErrCode)
	Log("ChatMgr:OnReqHostRespond", nPlayerId, nErrCode);
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end

	if nErrCode ~= 0 then
		pPlayer.CenterMsg(tbJoinHostErrMsg[nErrCode] or tbJoinHostErrMsg[1]);
		return;
	end

	ChatMgr:DoJoinCrossChannel(pPlayer, ChatMgr.ChatCrossAuthType.emHost);
end

function ChatMgr:OnSyncCrossChatRoomInfo(uRoomHighId, uRoomLowId)
	Log("ChatMgr:OnSyncCrossChatRoomInfo", uRoomHighId, uRoomLowId);
	ChatMgr.tbCrossHostRoomKey = {uRoomHighId, uRoomLowId};
	ChatMgr.szCrossHostRoomKey = string.format("%u%u", uRoomHighId, uRoomLowId);
end

function ChatMgr:OnCreateCrossHostRoom(uRoomHighId, uRoomLowId)
	local tbCrossPlayersId = KChat.GetCrossChannelPlayerIds();
	for nPlayerId, nAuth in pairs(tbCrossPlayersId) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			local nPrivilege = ChatMgr.RoomPrivilege.emAudience;
			if nAuth == ChatMgr.ChatCrossAuthType.emHost then
				nPrivilege = ChatMgr.RoomPrivilege.emSpeaker;
			end
			ChatMgr:JoinChatRoom(pPlayer, nPrivilege, ChatMgr.ChannelType.Cross);
		end
	end
	ChatMgr.nNextCreateHostRoomTime = math.huge;
end

function ChatMgr:OnChatServerDisconnect()
	local tbCrossPlayersId = KChat.GetCrossChannelPlayerIds();
	for nPlayerId, nAuth in pairs(tbCrossPlayersId) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			ChatMgr:LeaveCrossChannel(pPlayer);
		end
	end
	self.tbCurCrossHostInfo = {};
	ChatMgr.nNextCreateHostRoomTime = math.huge;
end

function ChatMgr:GetCurCrossHostInfo()
	return self.tbCurCrossHostInfo or {};
end

function ChatMgr:HasCrossHosters()
	return next(self.tbCurCrossHostInfo or {}) and true or false;
end

function ChatMgr:JoinCrossChannel()
	if not KChat.IsChatServerConnected() then
		return false, "主播頻道暫時不可用，請稍後再試";
	end

	if not ChatMgr:HasCrossHosters() then
		return false, "當前沒有正在直播的主播，無法加入頻道";
	end

	
	local dwTeamID = me.GetNpc().dwTeamID
	if dwTeamID > 0 and ChatMgr:IsTeamHaveChatRoom(dwTeamID) then
		return false, "您當前在隊伍語音房間，暫時不可收聽主播頻道";
	end

	return ChatMgr:DoJoinCrossChannel(me, ChatMgr.ChatCrossAuthType.emNone);
end

function ChatMgr:JoinCrossChannelHost()
	if not KChat.IsChatServerConnected() then
		return false, "主播頻道暫時不可用，請稍後再試";
	end

	if not ChatMgr:IsCrossHost(me) then
		return false, "您沒有主播許可權";
	end

	KChat.RequesteHostAuth(me.dwID);
	return true;
end

function ChatMgr:DoJoinCrossChannel(pPlayer, nAuth)
	KChat.AddPlayerToCrossChannel(pPlayer.dwID, nAuth);
	local bJoined = KChat.IsPlayerInCrossChannel(pPlayer.dwID);

	if bJoined and ChatMgr.tbCrossHostRoomInfo then
		local nPrivilege = ChatMgr.RoomPrivilege.emAudience;
		if nAuth == ChatMgr.ChatCrossAuthType.emHost then
			nPrivilege = ChatMgr.RoomPrivilege.emSpeaker;
		end
		ChatMgr:JoinChatRoom(pPlayer, nPrivilege, ChatMgr.ChannelType.Cross);
		pPlayer.TLog("JoinCrossChannel", pPlayer.nLevel)
	end

	ChatMgr:AskCrossHostInfo(pPlayer);
	return true;
end

function ChatMgr:LeaveCrossChannel(pPlayer)
	pPlayer = pPlayer or me;
	KChat.DelPlayerFromCrossChannel(pPlayer.dwID);
	ChatMgr:LeaveChatRoom(pPlayer);
	ChatMgr:AskCrossHostInfo(pPlayer);
	return true;
end

function ChatMgr:AskCrossHostInfo(pPlayer)
	pPlayer = pPlayer or me;
	pPlayer.CallClientScript("ChatMgr:OnSyncCurCrossHostInfo", self.tbCurCrossHostInfo);
	local bJoined, nAuth = KChat.IsPlayerInCrossChannel(pPlayer.dwID);
	pPlayer.CallClientScript("ChatMgr:OnSyncCrossChannelState", bJoined, nAuth);
	return true;
end

function ChatMgr:AskCrossHostState(bLocalState)
	local bHasHost = ChatMgr:HasCrossHosters();
	if bLocalState ~= bHasHost then
		me.CallClientScript("ChatMgr:OnSynCrossHostState", bHasHost);
	end

	return true;
end

function ChatMgr:Ask4CrossHostList(nVerison)
	local tbHostSchedule, tbHostScheduleDetail, nScheduleVersion = ChatMgr:GetChatHostScheduleInfo();
	if nVerison ~= nScheduleVersion then
		me.CallClientScript("ChatMgr:OnSynChatHostList", tbHostSchedule, tbHostScheduleDetail, nScheduleVersion);
	end
	return true;
end

function ChatMgr:UpdateHostFollowInfo(pPlayer, tbHostList)
	local nMaxHostCount = ChatMgr.CHAT_CROSS_HOST_FOLLOW_END - ChatMgr.CHAT_CROSS_HOST_FOLLOW_START + 1;
	while #tbHostList > nMaxHostCount do
		table.remove(tbHostList, 1);
	end

	for nIdx = 1, nMaxHostCount do
		local nKey = ChatMgr.CHAT_CROSS_HOST_FOLLOW_START + nIdx - 1;
		local nCurHostId = pPlayer.GetUserValue(ChatMgr.CHAT_CROSS_HOST_FOLLOW_GROUP, nKey);
		local nNewHostId = tbHostList[nIdx] or 0;
		if nCurHostId == nNewHostId and nCurHostId == 0 then
			break;
		end

		if nCurHostId ~= nNewHostId then
			pPlayer.SetUserValue(ChatMgr.CHAT_CROSS_HOST_FOLLOW_GROUP, nKey, nNewHostId);
		end
	end
	pPlayer.CallClientScript("ChatMgr:OnHostFollowChanged");
end

function ChatMgr:FollowHostOpt(nHostId, bFollow)
	local tbCurFollowList = ChatMgr:GetCrossHostFollowings(me);
	if bFollow then
		for _, nFollowedHostId in ipairs(tbCurFollowList) do
			if nFollowedHostId == nHostId then
				return false, "已關注該主播";
			end
		end
		table.insert(tbCurFollowList, nHostId);
		ChatMgr:AddCrossHostFollowMap(nHostId, me.dwID);
		me.TLog("FollowCrossHost", 1, nHostId);
	else
		local bHasRemoved = false;
		for nIdx, nFollowedHostId in ipairs(tbCurFollowList) do
			if nFollowedHostId == nHostId then
				table.remove(tbCurFollowList, nIdx);
				bHasRemoved = true;
				break;
			end
		end
		if not bHasRemoved then
			return false, "尚未關注該主播";
		end
		ChatMgr:RemoveCrossHostFollowMap(nHostId, me.dwID);
		me.TLog("FollowCrossHost", 0, nHostId);
	end

	ChatMgr:UpdateHostFollowInfo(me, tbCurFollowList);
	return true;
end

function ChatMgr:SetNamePrefixByName(pPlayer, szPrefixType, nExpireTime)
	local nPrefixId = ChatMgr.NamePrefixType[szPrefixType];
	if not nPrefixId then
		return false;
	end

	return ChatMgr:SetNamePrefixById(pPlayer, nPrefixId, nExpireTime);
end

function ChatMgr:SetNamePrefixById(pPlayer, nPrefixId, nExpireTime)
	if nPrefixId <= 0 or nPrefixId > ChatMgr.CHAT_NAME_PREFIRX_MAX_KEY then
		Log("SetNamePrefixById Error", nPrefixId);
		return false;
	end

	pPlayer.SetUserValue(ChatMgr.CHAT_NAME_PREFIRX_SAVE_GROUP, nPrefixId, nExpireTime);
	pPlayer.CenterMsg(string.format("您獲得「%s」聊天首碼", ChatMgr:GetNamePrefixInfo(nPrefixId).Desc or "某"));
	pPlayer.CallClientScript("ChatMgr:OnNamePrefixInfoChanged", nPrefixId);
	Log("SetNamePrefixById", pPlayer.dwID, nPrefixId, nExpireTime);
	return true;
end

function ChatMgr:CheckPlayerNamePrefixInfo()
	local pRank = KRank.GetRankBoard("FightPower")
	if pRank then
		local tbInfo = pRank.GetRankInfoByID(me.dwID)
		if tbInfo and tbInfo.nPosition >= 1 and tbInfo.nPosition <= 10 then
			local nPrefixId = ChatMgr.NamePrefixType.PowerTop10;
			me.SetUserValue(ChatMgr.CHAT_NAME_PREFIRX_SAVE_GROUP, nPrefixId, GetTime() + 3600);
		end
	end
	return true;
end

function ChatMgr:SetCurrentNamePrefixInfo(nPrefixId)
	if nPrefixId <= 0 or nPrefixId > ChatMgr.CHAT_NAME_PREFIRX_MAX_KEY then
		return false, "非法聊天首碼類型";
	end

	local nNow = GetTime();
	local nTimeOut = me.GetUserValue(ChatMgr.CHAT_NAME_PREFIRX_SAVE_GROUP, nPrefixId);
	if nNow > nTimeOut then
		return false, "聊天首碼已過期";
	end

	me.SetUserValue(ChatMgr.CHAT_NAME_PREFIRX_SAVE_GROUP, ChatMgr.CHAT_NAME_PREFIRX_CURRUNT_SELECT_KEY, nPrefixId);
	me.CenterMsg(string.format("首碼成功設置為「%s」", ChatMgr:GetNamePrefixInfo(nPrefixId).Desc or "某"));
	Log("SetCurrentNamePrefixInfo", me.dwID, nPrefixId)
	return true;
end

local tbChatClientInterface = {
	JoinCrossChannel          = true;
	LeaveCrossChannel         = true;
	AskCrossHostInfo          = true;
	JoinCrossChannelHost      = true;
	Ask4CrossHostList         = true;
	FollowHostOpt             = true;
	AskCrossHostState         = true;
	CheckPlayerNamePrefixInfo = true;
	SetCurrentNamePrefixInfo  = true;
};

local tbCrossHostRequest = {
	JoinCrossChannel     = true;
	LeaveCrossChannel    = true;
	AskCrossHostInfo     = true;
	JoinCrossChannelHost = true;
}

function ChatMgr:DoChatRequest(szType, ...)
	if tbCrossHostRequest[szType]
		and not ChatMgr:IsCrossHostChannelOpen()
		then
		me.CenterMsg("主播頻道暫時不可用，請稍後再試");
		return;
	end

	if tbChatClientInterface[szType] then
		local bRet, szNoticeMsg = ChatMgr[szType](ChatMgr, ...);
		if not bRet then
			me.CenterMsg(szNoticeMsg);
		end
	else
		assert(false, szType);
	end
end

---------------------------------------------------------------------------

function ChatMgr:ReloadChatHostInfo()
	self.tbHostInfoList = LoadTabFile("ChatHostSetting.tab", "dsss", "PlayerId", {"PlayerId", "Name", "HeadUrl", "Signature"}, 1, 1) or {};
	self.tbHostSchedule = LoadTabFile("ChatHostSchedule.tab", "dss", nil, {"PlayerId", "TimeDesc", "TimeOut"}, 1, 1) or {};

	self.nHostScheduleVersion = self.nHostScheduleVersion or 0;
	self.nHostScheduleVersion = self.nHostScheduleVersion + 1;

	self.tbHostScheduleDetail = {};
	for _, tbInfo in ipairs(self.tbHostSchedule) do
		if not self.tbHostScheduleDetail[tbInfo.PlayerId] then
			self.tbHostScheduleDetail[tbInfo.PlayerId] = self.tbHostInfoList[tbInfo.PlayerId];
		end
		tbInfo.TimeOut = Lib:ParseDateTime(tbInfo.TimeOut);
	end

	Log("ChatMgr:ReloadChatHostInfo", self.nHostScheduleVersion);
	-- Lib:Tree(self.tbHostInfoList);
end

ChatMgr:ReloadChatHostInfo();

function ChatMgr:GetChatHostScheduleInfo()
	return self.tbHostSchedule, self.tbHostScheduleDetail, self.nHostScheduleVersion;
end

function ChatMgr:OnGVoiceInit(nEnable, szAppId, szAppKey)
	self.bEnableGVoice = nEnable == 1;
	self.szGVoiceAppId = szAppId;
	self.szGVoiceAppKey = szAppKey;
end

function ChatMgr:CheckSyncGVoiceParam(pPlayer)
	if not self.bEnableGVoice then
		return
	end

	me.CallClientScript("ChatMgr:OnSyncGVoiceParam", self.szGVoiceAppId, self.szGVoiceAppKey);
end