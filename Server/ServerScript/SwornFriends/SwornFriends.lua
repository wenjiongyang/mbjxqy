-- requests
local tbValidRequests = {
	ConnectReq = true,
	DisconnectReq = true,
	ChangePersonalTitle = true,
}

function SwornFriends:OnRequest(szFunc, ...)
	if not tbValidRequests[szFunc] then
		Log("[x] SwornFriends:OnRequest, invalid req", szFunc, ...)
		return
	end

	if self.bClosed then
		me.CenterMsg("結拜系統正在維護中")
		return
	end

	local func = self[szFunc]
	if not func then
		Log("[x] SwornFriends:OnRequest, unknown req", szFunc, ...)
		return
	end

	local bSuccess, szErr = func(self, ...)
	if bSuccess==false and szErr then
		me.CenterMsg(szErr)
		return
	end
end

function SwornFriends:_GetRelativeName(pMe, nPid)
	local szName = "你"
	if nPid~=pMe.dwID then
		local pStay = KPlayer.GetRoleStayInfo(nPid)
		szName = pStay and pStay.szName or "隊友"
	end
	return szName
end

function SwornFriends:CheckBeforeConnect(pPlayer)
	local nTeamId = pPlayer.dwTeamID
	local tbTeam = TeamMgr:GetTeamById(nTeamId)
	if not tbTeam then
		return false, "沒有隊伍"
	end

	if tbTeam:GetCaptainId()~=pPlayer.dwID then
		return false, "你不是隊長"
	end

	local tbMembers = TeamMgr:GetMembers(nTeamId)
	local nMemberCount = #tbMembers
	if nMemberCount<self.Def.nMinPlayer or nMemberCount>self.Def.nMaxPlayer then
		return false, string.format("結拜需%d~%d人", self.Def.nMinPlayer, self.Def.nMaxPlayer)
	end

	for _, nPid in ipairs(tbMembers) do
		if self:_GetConnectInfo(nPid) then
			return false, string.format("%s已有結拜關係，不能再次結拜", self:_GetRelativeName(pPlayer, nPid))
		end
	end

	local nItemCount, nPid = self:_GetPlayersMinItemCount(tbMembers, self.Def.nConnectItemId)
	if nItemCount<=0 then
		local pStay = KPlayer.GetRoleStayInfo(nPid)
		return false, string.format("%s當前沒有金蘭譜", self:_GetRelativeName(pPlayer, nPid))
	end
	
	local nMinLevel, nPid = self:_GetPlayersMinLevel(tbMembers)
	if nMinLevel<self.Def.nMinLevel then
		return false, string.format("%s的等級不足%d級", self:_GetRelativeName(pPlayer, nPid), self.Def.nMinLevel)
	end
	local nMinImitity, nPid1, nPid2 = self:_GetPlayersMinImityLevel(tbMembers)
	if nMinImitity<self.Def.nMinImitity then
		local pStay1 = KPlayer.GetRoleStayInfo(nPid1)
		local pStay2 = KPlayer.GetRoleStayInfo(nPid2)
		return false, (pStay1 and pStay2) and 
			string.format("%s與%s的親密度不足%d級", pStay1.szName, pStay2.szName, self.Def.nMinImitity) or
			string.format("親密度不足%d級", self.Def.nMinImitity)
	end

	return true
end

function SwornFriends:CanDelFriend(nId1, nId2)
	return not self:IsConnected(nId1, nId2)
end

function SwornFriends:ConnectReq(tbMainTitle)
	local bValid, szErr = self:CheckBeforeConnect(me)
	if not bValid then
		return false, szErr
	end

	local tbMembers = TeamMgr:GetMembers(me.dwTeamID)
	local bValid, szRet = self:_GenMainTitle(tbMainTitle[1], tbMainTitle[2], #tbMembers)
	if not bValid then
		return false, szRet
	end

	return self:_DoConnect(tbMembers, szRet)
end

function SwornFriends:_DoConnect(tbPids, szMainTitle)
	for _, nPid in ipairs(tbPids) do
		local pPlayer = KPlayer.GetPlayerObjById(nPid)
		if not pPlayer or pPlayer.ConsumeItemInBag(self.Def.nConnectItemId, 1, Env.LogWay_SwornFriends)~=1 then
			Log("[x] SwornFriends:_DoConnect, ConsumeItemInBag failed", nPid, tostring(pPlayer))
			return false, "消耗結拜道具失敗"
		end
	end

	local tbData = {szMainTitle, {}}
	for _, nPid in ipairs(tbPids) do
		tbData[2][nPid] = ""
		self._tbConnections[nPid] = tbData
	end
	self:_ScriptDataAdd(tbData)
	self._tbUsedMainTitles[szMainTitle] = true

	for _, nPid in ipairs(tbPids) do
		local pPlayer = KPlayer.GetPlayerObjById(nPid)
		if pPlayer then
			pPlayer.AddItem(self.Def.nPersonalTitleItemId, 1, nil, Env.LogWay_SwornFriends)
			self:_PushConnectIds(pPlayer)
		end
	end

	self:UpdateTeamBuff(tbPids)
	self:_SwitchMap(tbPids)
	Log("SwornFriends:_DoConnect", tbData[1], table.concat(tbPids, ","))
end

function SwornFriends:_SwitchMap(tbPids)
	local bAllSameMap = true
	self._tbReadyPids = self._tbReadyPids or {}
	self._tbMapRegister = self._tbMapRegister or {}
	for i, nPid in ipairs(tbPids) do
		local pPlayer = KPlayer.GetPlayerObjById(nPid)
		if pPlayer then
			pPlayer.CallClientScript("AutoFight:StopFollowTeammate")
			local bDiffMap = pPlayer.nMapId~=self.Def.nSwornMapId
			if bDiffMap then
				bAllSameMap = false
				if self._tbMapRegister[nPid] then
					PlayerEvent:UnRegister(pPlayer, "OnEnterMap", self._tbMapRegister[nPid])
				end
				self._tbMapRegister[nPid] = PlayerEvent:Register(pPlayer, "OnEnterMap", function()
					PlayerEvent:UnRegister(pPlayer, "OnEnterMap", self._tbMapRegister[nPid])

					self._tbReadyPids[nPid] = true
					if self:_IsAllPlayersReady(tbPids) then
						self._tbReadyPids[nPid] = nil
						local nWait = math.max(5, self.Def.nActionWaitTime*2)
						Timer:Register(Env.GAME_FPS*nWait, self._PlaySwornActions, self, tbPids)
					end
				end)

				self._tbReadyPids[nPid] = nil
			end

			pPlayer.SetEntryPoint()
			pPlayer.SwitchMap(self.Def.nSwornMapId, unpack(self.Def.tbConnectPos[i]))
		end
	end

	if bAllSameMap then
		Timer:Register(Env.GAME_FPS*self.Def.nActionWaitTime, self._PlaySwornActions, self, tbPids)
	end
end

function SwornFriends:_IsAllPlayersReady(tbPids)
	for _, nPid in ipairs(tbPids) do
		if not self._tbReadyPids[nPid] then
			return false
		end
	end
	return true
end

function SwornFriends:Test(pMe)
	local tbPids = TeamMgr:GetMembers(pMe.dwTeamID)
	self:_PlaySwornActions(tbPids)
end

function SwornFriends:_PlaySwornActions(tbPids)
	local tbIdNames = {}
	local tbNames = {}
	local tbNpcIds = {}
	for _, nPid in ipairs(tbPids) do
		local pPlayer = KPlayer.GetPlayerObjById(nPid)
		if pPlayer then
			tbIdNames[nPid] = pPlayer.szName
			table.insert(tbNames, pPlayer.szName)
			table.insert(tbNpcIds, pPlayer.GetNpc().nId)
		end
	end

	local szNames = table.concat(tbNames, "、")
	local nTotalWords = 0
    nTotalWords = nTotalWords + #Lib:GetUft8Chars(SwornFriends.Def.szText1)
    nTotalWords = nTotalWords + #Lib:GetUft8Chars(szNames)
    nTotalWords = nTotalWords + #Lib:GetUft8Chars(SwornFriends.Def.szText2)

    local nConnectSkillTime = nTotalWords*self.Def.nSwornTextInterval + self.Def.nConnectSkillDelay

	for i, nPid in ipairs(tbPids) do
		local pPlayer = KPlayer.GetPlayerObjById(nPid)
		if pPlayer then
			ActionMode:DoForceNoneActMode(pPlayer)
			pPlayer.CallClientScript("Ui:HideOthers", tbNpcIds)

			self:_PushConnectSuccess(pPlayer, tbIdNames)

			local pNpc = pPlayer.GetNpc()
			if pNpc then
				pPlayer.SwitchMap(self.Def.nSwornMapId, unpack(self.Def.tbConnectPos[i]))
				pNpc.DoCommonAct(self.Def.nConnectActId, 10001, 0, 0, 1)
				pNpc.SetDirToPos(unpack(self.Def.tbSkillCastPoint))

				-- 禁止移动buff
				pNpc.AddSkillState(1064, 1, 3, Env.GAME_FPS*nConnectSkillTime, 1, 1)
			end
		end
	end
	Timer:Register(Env.GAME_FPS*nConnectSkillTime, self._FinishConnectionAction, self, tbPids)
end

function SwornFriends:_GenMainTitle(szHead, szTail, nMemberCount)
	local nHeadLen = Lib:Utf8Len(szHead or "")
	local nTailLen = Lib:Utf8Len(szTail or "")
	if nHeadLen<=0 or nTailLen<=0 then
		return false, "請填寫結拜稱號的首部和尾部"
	end
	if nHeadLen>self.Def.nTitleHeadMax or nHeadLen<self.Def.nTitleHeadMin or nTailLen>self.Def.nTitleTailMax or nTailLen<self.Def.nTitleTailMin then
		return false, string.format("首部%d-%d字元，尾部%d~%d字元", self.Def.nTitleHeadMin, self.Def.nTitleHeadMax, self.Def.nTitleTailMin, self.Def.nTitleTailMax)
	end

	if not CheckNameAvailable(szHead) or not CheckNameAvailable(szTail) then
		return false, "稱號中含有敏感詞"
	end

	local szTitle = string.format("%s%s%s", szHead, SwornFriends:GetMemberCountDesc(nMemberCount), szTail)
	if self:_IsMainTitleUsed(szTitle) then
		return false, "這個結拜稱號已被其他玩家使用"
	end
	return true, szTitle
end

function SwornFriends:_GetPlayersMinItemCount(tbPlayerIds, nItemId)
	local nMin, nPlayerId = math.huge, 0
	for _, nPid in ipairs(tbPlayerIds) do
		local pPlayer = KPlayer.GetPlayerObjById(nPid)
		if not pPlayer then
			nMin, nPlayerId = 0, nPid
			break
		end
		local nCount = pPlayer.GetItemCountInBags(nItemId)
		if nCount<nMin then
			nMin, nPlayerId = nCount, nPid
		end
	end
	return nMin, nPlayerId
end

function SwornFriends:_GetPlayersMinLevel(tbPlayerIds)
	local nMin, nPlayerId = math.huge, 0
	for _, nPid in ipairs(tbPlayerIds) do
		local pPlayer = KPlayer.GetPlayerObjById(nPid) or KPlayer.GetRoleStayInfo(nPid)
		if not pPlayer then
			nMin, nPlayerId = 0, nPid
			break
		end

		if pPlayer.nLevel<nMin then
			nMin, nPlayerId = pPlayer.nLevel, nPid
		end
	end
	return nMin, nPlayerId
end

function SwornFriends:_GetPlayersMinImityLevel(tbPlayerIds)
	local nMin, nPlayerId1, nPlayerId2 = math.huge, 0, 0
	local nCount = #tbPlayerIds
	for nIdx, nPid1 in ipairs(tbPlayerIds) do
		for i=nIdx+1, nCount do
			local nPid2 = tbPlayerIds[i]
			local nImity = FriendShip:GetFriendImityLevel(nPid1, nPid2) or 0
			if nImity<nMin then
				nMin, nPlayerId1, nPlayerId2 = nImity, nPid1, nPid2
			end
		end
	end
	return nMin, nPlayerId1, nPlayerId2
end

function SwornFriends:CheckBeforeDisconnect(pPlayer)
	local nPid = pPlayer.dwID
	local tbInfo = self:_GetConnectInfo(nPid)
	if not tbInfo then
		return false, "你沒有結拜"
	end
	return true
end

function SwornFriends:DisconnectReq()
	local bOk, szErr = self:CheckBeforeDisconnect(me)
	if not bOk then
		return false, szErr
	end

	local nMyId = me.dwID
	self:_DeletePlayerTitle(me)

	local tbInfo = self:_GetConnectInfo(nMyId)
	tbInfo[2][nMyId] = nil
	if not next(tbInfo[2]) then
		self._tbUsedMainTitles[tbInfo[1]] = nil
		tbInfo[1], tbInfo[2] = nil, nil
		tbInfo.bClear = true
	end

	self:_ScriptDataModified(nMyId)

	self._tbConnections[nMyId] = nil
	self._tbPidSlotMap[nMyId] = nil

	self:_PushConnectIds(me)
	me.Msg("你已結束結拜關係")
	for nPid in pairs(tbInfo[2] or {}) do
		local pPlayer = KPlayer.GetPlayerObjById(nPid)
		if pPlayer then
			self:_PushConnectIds(pPlayer)
			pPlayer.Msg(string.format("%s已與你結束結拜關係", me.szName))
		end
		Log("SwornFriends:DisconnectReq", me.dwID, nPid)
	end

	local nTeamId = me.dwTeamID
	if nTeamId and nTeamId>0 then
		local tbMembers = TeamMgr:GetMembers(nTeamId)
		self:UpdateTeamBuff(tbMembers)
	end
end

function SwornFriends:CheckBeforeChangePersonalTitle(pPlayer)
	local tbInfo = self:_GetConnectInfo(pPlayer.dwID)
	if not tbInfo then
		return false, "你沒有結拜"
	end
	return true
end

function SwornFriends:ChangePersonalTitle(szTitle, bConsumeItem)
	local bOk, szErr = self:CheckBeforeChangePersonalTitle(me)
	if not bOk then
		return false, szErr
	end

	local nMyId = me.dwID
	local tbInfo = self:_GetConnectInfo(nMyId)

	local nLen = Lib:Utf8Len(szTitle or "")
	if nLen<=0 then
		return false, "請填寫結拜稱號"
	end
	if nLen>self.Def.nPersonalTitleMax or nLen<self.Def.nPersonalTitleMin then
		return false, string.format("個人稱號%d-%d字元", self.Def.nPersonalTitleMin, self.Def.nPersonalTitleMax)
	end

	if not CheckNameAvailable(szTitle) then
		return false, "稱號中含有敏感詞"
	end

	for nPid, sz in pairs(tbInfo[2]) do
		if sz==szTitle then
			return false, nPid==nMyId and "你已經是這個稱號了" or "這個稱號已被其他結拜成員使用"
		end
	end

	if bConsumeItem and me.ConsumeItemInBag(self.Def.nPersonalTitleItemId, 1, Env.LogWay_SwornFriends)~=1 then
		Log("[x] SwornFriends:ChangePersonalTitle, ConsumeItemInBag failed", me.dwID)
		return false, "消耗道具失敗"
	end

	tbInfo[2][nMyId] = szTitle
	self:_ScriptDataModified(nMyId)

	self:_SetPlayerTitle(me, tbInfo[1], szTitle)
end

function SwornFriends:_DeletePlayerTitle(pPlayer)
	local nTitleId = self.Def.nTitleId
	pPlayer.DeleteTitle(nTitleId, true)
end

function SwornFriends:_SetPlayerTitle(pPlayer, szMainTitle, szPersonalTitle)
	self:_DeletePlayerTitle(pPlayer)

	local nTitleId = self.Def.nTitleId
	local szTitle = string.format("%s之%s", szMainTitle, szPersonalTitle)
	pPlayer.AddTitle(nTitleId, 0, true, false, szTitle)
end

function SwornFriends:_PushConnectIds(pPlayer)
	local tbIds = {}
	local nMyId = pPlayer.dwID
	local tbInfo = self:_GetConnectInfo(nMyId)
	local szMainTitle = ""
	local bConnected = false
	if tbInfo then
		szMainTitle = tbInfo[1] or ""
		bConnected = true
		for nId in pairs(tbInfo[2]) do
			if nId~=nMyId then
				table.insert(tbIds, nId)
			end
		end
	end
	pPlayer.CallClientScript("SwornFriends:OnPushToClient", "connectids", tbIds, szMainTitle, bConnected)
end

function SwornFriends:_PushConnectSuccess(pPlayer, tbIdNames)
	local tbNames = {}
	for nId, szName in pairs(tbIdNames) do
		if nId==pPlayer.dwID then
			table.insert(tbNames, 1, szName)
		else
			table.insert(tbNames, szName)
		end
	end
	pPlayer.CallClientScript("SwornFriends:OnPushToClient", "connected", tbNames)
end

function SwornFriends:_FinishConnectionAction(tbIds)
	for _, nId in ipairs(tbIds) do
		local pPlayer = KPlayer.GetPlayerObjById(nId)
		if pPlayer then
			local pNpc = pPlayer.GetNpc()
			if pNpc then
				pNpc.RestoreAction()
			end
			pPlayer.CallClientScript("Ui:OpenWindow", "SwornFriendsConnected")
			pPlayer.CallClientScript("Ui:ShowOthers")
		end
	end
end

function SwornFriends:OnLogin(pPlayer)
	self:_PushConnectIds(pPlayer)
end

function SwornFriends:OnAddHate(nFriendId, pEnemy, nVal)
	local tbInfo = self:_GetConnectInfo(nFriendId)
	if not tbInfo then return end

	local nEnemyId = pEnemy.dwID
	for nPid in pairs(tbInfo[2]) do
		if nPid~=nFriendId and nPid~=nEnemyId then
			local pStay = KPlayer.GetRoleStayInfo(nPid)
			FriendShip:AddHate(pStay, pEnemy, nVal, true)
			Log("SwornFriends:OnAddHate", nFriendId, nEnemyId, nVal, nPid)
		end
	end
end

function SwornFriends:OnStartup()
	self._tbConnections = {}
	self._tbUsedMainTitles = {}
	self._tbPidSlotMap = {}
	self._nMaxSlot = ScriptData:GetValue("SwornFriendsMaxSlot")
	if type(self._nMaxSlot)~="number" then
		self:_SetMaxSlot(1)
	end

	for nSlot=1, self._nMaxSlot do
		local szKey = self:_ScriptDataGetKey(nSlot)
		ScriptData:AddDef(szKey)
		local tbValue = ScriptData:GetValue(szKey)
		local bModified = false
		for i=#tbValue, 1, -1 do
			if tbValue[i].bClear then
				table.remove(tbValue, i)
				bModified = true
			end
		end
		if bModified then
			ScriptData:AddModifyFlag(szKey)
		end
		Log("SwornFriends:OnStartup", nSlot, self._nMaxSlot, #tbValue)

		for _, tbData in ipairs(tbValue) do
			local szMainTitle = tbData[1]
			self._tbUsedMainTitles[szMainTitle] = true

			for nPid in pairs(tbData[2]) do
				self._tbConnections[nPid] = tbData
				self._tbPidSlotMap[nPid] = nSlot
			end
		end
	end
end

function SwornFriends:GetFriendsId(nMyId)
	local tbRet = {}
	local tbInfo = self:_GetConnectInfo(nMyId)
	if not tbInfo then
		return tbRet
	end

	for nPid in pairs(tbInfo[2]) do
		if nPid~=nMyId then
			table.insert(tbRet, nPid)
		end
	end
	return tbRet
end

function SwornFriends:IsConnected(nPid1, nPid2)
	local tbInfo1 = self:_GetConnectInfo(nPid1)
	local tbInfo2 = self:_GetConnectInfo(nPid2)
	if not tbInfo1 or not tbInfo2 then
		return false
	end
	return tbInfo1==tbInfo2
end

function SwornFriends:_GetConnectInfo(nPid)
	return self._tbConnections[nPid]
end

function SwornFriends:_IsMainTitleUsed(szTitle)
	return self._tbUsedMainTitles[szTitle]
end

function SwornFriends:_ScriptDataGetKey(nSlot)
	return string.format("SwornFriends%d", nSlot)
end

function SwornFriends:_SetMaxSlot(nMax)
	self._nMaxSlot = nMax
	ScriptData:SaveAtOnce("SwornFriendsMaxSlot", self._nMaxSlot)
	Log("SwornFriends:_SetMaxSlot", self._nMaxSlot)
end

function SwornFriends:_ScriptDataGetFreeKey()
	for i=1, self._nMaxSlot+1 do
		local szKey = self:_ScriptDataGetKey(i)
		ScriptData:AddDef(szKey)
		local tbValue = ScriptData:GetValue(szKey)
		if #tbValue<self.Def.nMaxSavePerScriptData then
			if i>self._nMaxSlot then
				self:_SetMaxSlot(i)
			end
			return i, szKey
		end
	end
	Log("[x] SwornFriends:_ScriptDataGetFreeKey")
end

function SwornFriends:_ScriptDataAdd(tbData)
	local nSlot, szKey = self:_ScriptDataGetFreeKey()
	if not nSlot then
		Log("[x] SwornFriends:_ScriptDataAdd")
		return
	end
	local tbValue = ScriptData:GetValue(szKey)
	table.insert(tbValue, tbData)
	ScriptData:AddModifyFlag(szKey)

	for nPid in pairs(tbData[2]) do
		self._tbPidSlotMap[nPid] = nSlot
	end
end

function SwornFriends:_ScriptDataModified(nPid)
	local nSlot = self._tbPidSlotMap[nPid]
	if not nSlot then
		Log("[x] SwornFriends:_ScriptDataModified", nPid)
		return
	end
	
	local szKey = self:_ScriptDataGetKey(nSlot)
	ScriptData:AddModifyFlag(szKey)
end

function SwornFriends:UpdateTeamBuff(tbMembers, nRemovedPid)
	if MODULE_ZONESERVER then return end
	
	local tbAddBuffPids = {}
	for nIdx, nPid in ipairs(tbMembers) do
		for i=nIdx+1, #tbMembers do
			local nPid2 = tbMembers[i]
			if self:IsConnected(nPid, nPid2) then
				tbAddBuffPids[nPid] = true
				tbAddBuffPids[nPid2] = true
			end
		end
	end

	local nBuffId = self.Def.nTeamBuffId
	local tbAll = Lib:CopyTB(tbMembers)
	if nRemovedPid then
		table.insert(tbAll, nRemovedPid)
	end
	for _, nPid in ipairs(tbAll) do
		local pPlayer = KPlayer.GetPlayerObjById(nPid)
		if pPlayer then
			local pNpc = pPlayer.GetNpc()
			local tbSkillState = pNpc.GetSkillState(nBuffId)
			if tbAddBuffPids[nPid] then
    			if not tbSkillState then
					pNpc.AddSkillState(nBuffId, self.Def.nTeamBuffLevel, 3, Env.GAME_FPS*self.Def.nTeamBuffDuration, 1, 1)
				end
			else
				if tbSkillState then
					pNpc.RemoveSkillState(nBuffId)
				end
			end
		end
	end
end