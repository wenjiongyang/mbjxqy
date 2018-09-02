if not MODULE_ZONESERVER then
	return
end

local tbDefine = InDifferBattle.tbDefine;

InDifferBattle.tbMapInst = InDifferBattle.tbMapInst or {} --放的是实际实例
InDifferBattle.tbInGamePlayers = InDifferBattle.tbInGamePlayers or {};
InDifferBattle.tbRoleZoneIndex = InDifferBattle.tbRoleZoneIndex or {}; 


function InDifferBattle:OpenSignUp() --nIndex 是第几个战场图
	if self.tbReadyMapTypes then
		for nReadyMapId,v in ipairs(self.tbReadyMapTypes) do
			local tbPlayers = KPlayer.GetMapPlayer(nReadyMapId) 	
			for i, pPlayer in ipairs(tbPlayers) do
				pPlayer.ZoneLogout();
			end
		end
	end

	self:StopSignUp();
	self.tbRoleZoneIndex = {} --这个不能结束报名时清掉，不然战场没打完已经停止报名时到发奖时就会没有对应玩家数据
	self.tbCreateMapIngIds = {};

	local tbCreateTypes = { "Normal" };
	local szQulifyType = self:GetCurOpenQualifyType()
	if szQulifyType then
		table.insert(tbCreateTypes, szQulifyType)
	end

	self.tbReadyMapWaitIds = {};

	self.tbReadyMapTypes = {};
	self.tbTotalPlayerNum = {};

	for _, szType in ipairs(tbCreateTypes) do
		local nReadyMapId = CreateMap(tbDefine.nReadyMapTemplateId);		
		self.tbReadyMapTypes[nReadyMapId] = szType
		self.tbTotalPlayerNum[nReadyMapId] = 0;
	end
end

function InDifferBattle:StopSignUp()
	if self.nActiveTimer then
		Timer:Close(self.nActiveTimer)
		self.nActiveTimer = nil;
	end
	if self.nActiveTimerReady then
		Timer:Close(self.nActiveTimerReady)
		self.nActiveTimerReady = nil;
	end

	if self.tbReadyMapTypes then
		for nReadyMapId,v in pairs(self.tbReadyMapTypes) do
			KPlayer.MapBoardcastScript(nReadyMapId, "Ui:OpenWindow", "QYHLeftInfo", "InDifferBattleClose")	
			local tbPlayers = KPlayer.GetMapPlayer(nReadyMapId)
			for i,pPlayer in ipairs(tbPlayers) do
				if not self.tbRoleZoneIndex[pPlayer.dwID] then
					pPlayer.CenterMsg("未能匹配進活動，請下一場再來！", true)
				end
			end	
		end
	end
	
	self.tbTotalPlayerNum = nil;
	self.tbOldTeamInfo 	 = nil;
	self.tbOldTeamMembers = nil;
	self.tbRandomFactionGroup = nil;
	self.tbRandomRoomIndex = nil;
	-- self.tbReadyMapTypes = nil; --不能清，需要打完所有比赛时也用到
	self.tbReadyMapWaitIds = nil;
	
	CallZoneClientScript(-1, "InDifferBattle:OnServerStopSignUp");
end

function InDifferBattle:UpdateReadyMapInfo()
	local nTime = math.floor(Timer:GetRestTime(self.nActiveTimer) / Env.GAME_FPS);
	for nReadyMapId,_ in pairs(self.tbReadyMapTypes) do
		local nPlayerNum = self.tbTotalPlayerNum[nReadyMapId]
		local szNumInfo = string.format("%d/%d", nPlayerNum, tbDefine.nMaxTeamRoleNum * tbDefine.nMaxTeamNum)
		KPlayer.MapBoardcastScript(nReadyMapId, "Ui:DoLeftInfoUpdate", {nTime, szNumInfo})
	end
	return true
end

--传入id全部组队
function InDifferBattle:TeamUp(tbRoleIds)
	local dwRoleId1, dwRoleId2 = tbRoleIds[1], tbRoleIds[2]
	local bRet, nRet2,nRet3, teamData = TeamMgr:Create(dwRoleId1, dwRoleId2, true);
	if bRet and teamData then
		for j = 3, #tbRoleIds do
			teamData:AddMember(tbRoleIds[j], true);	
		end
		return teamData
	else
		Log("TeamUp Error bRet, nRet2,nRet3", bRet, nRet2,nRet3, dwRoleId1, dwRoleId2)
	end
end


function InDifferBattle:ActiveOneMap(nReadyMapId)
	self.tbOldTeamInfo = {}; --因为这里已经又做了自动组队操作了，所以之前同步过来的信息应该清掉

	--先对没有组队的进行一个自动组队, 目前只是优先同服同家族的
	local nMaxTeamRoleNum = tbDefine.nMaxTeamRoleNum
	local tbPlayers = KPlayer.GetMapPlayer(nReadyMapId) 
	local tbSortPlayers = {}; --暂时没有队伍的玩家
	local tbHasTeams = {};
	for i, pPlayer in ipairs(tbPlayers) do
		if pPlayer.dwTeamID == 0 then
			table.insert(tbSortPlayers, {dwRoleId = pPlayer.dwID, nSort = (pPlayer.nServerIdx or 0) * 100000 + pPlayer.dwKinId % 2^20 } )
		else
			if not tbHasTeams[pPlayer.dwTeamID] then
				tbHasTeams[pPlayer.dwTeamID] = { tbRoles = {}, nSort = (pPlayer.nServerIdx or 0) * 100000 + pPlayer.dwKinId % 2^20 }
			end
			table.insert(tbHasTeams[pPlayer.dwTeamID].tbRoles, pPlayer.dwID)
		end
	end
	local tbHasSortIndex = {} -- [nSort] = {dwTeamID1, dwTeamID2 ...}
	local nCurTotalTeamNum = 0
	for dwTeamID,v in pairs(tbHasTeams) do
		if #v.tbRoles < nMaxTeamRoleNum then
			tbHasSortIndex[v.nSort] = tbHasSortIndex[v.nSort] or {};
			table.insert(tbHasSortIndex[v.nSort], dwTeamID);
		end
		nCurTotalTeamNum = nCurTotalTeamNum + 1;
 	end

 	table.sort( tbSortPlayers, function (a, b)
 		return a.nSort < b.nSort;
 	end )

 	--先是优先将同服同家族的塞到已建立的队伍中去
 	for i = #tbSortPlayers, 1, -1 do
 		local v = tbSortPlayers[i]
 		local tbCurSortTeamIDs = tbHasSortIndex[v.nSort]
 		if tbCurSortTeamIDs then
 			local nCurSortTeamID = tbCurSortTeamIDs[#tbCurSortTeamIDs]
 			table.insert(tbHasTeams[nCurSortTeamID].tbRoles, v.dwRoleId)
 			--组队操作
			local teamData = TeamMgr:GetTeamById(nCurSortTeamID);
			teamData:AddMember(v.dwRoleId, true);
 			table.remove(tbSortPlayers, i)
 			if #tbHasTeams[nCurSortTeamID].tbRoles == nMaxTeamRoleNum then
				table.remove(tbCurSortTeamIDs)	 			
				if not next(tbCurSortTeamIDs) then
					tbHasSortIndex[v.nSort] = nil;
				end
 			end
 		end
 	end
 	--直接将剩余的人塞到已建立的队伍中
 	local bHasRoles = true
 	for nSort, tbTeamIDs in pairs(tbHasSortIndex) do
 		for _, dwTeamID in ipairs(tbTeamIDs) do
 			local tbTeamRoles = tbHasTeams[dwTeamID].tbRoles
	 		for i = #tbTeamRoles + 1, nMaxTeamRoleNum do
	 			local tbRole = table.remove(tbSortPlayers)
	 			if not tbRole then
	 				bHasRoles = false
	 				break;
	 			else
		 			local teamData = TeamMgr:GetTeamById(dwTeamID); 
					teamData:AddMember(tbRole.dwRoleId, true);
					table.insert(tbHasTeams[dwTeamID].tbRoles, tbRole.dwRoleId)
	 			end
	 		end
 		end
 		if not bHasRoles then
 			break;
 		end
 	end

 	--剩余的先同 家族的组队 够3个的才组
 	local nMaxLeftTeam = math.floor(#tbSortPlayers / nMaxTeamRoleNum) 
 	if nMaxLeftTeam > 0 then
 		local tbNewTeamUpRoleIndex = {}; --已经组队的列表
 		local tbSameSortRoles = {};
 		local nLastSort = -1;
 		table.insert(tbSortPlayers, {dwRoleId = 0, nLastSort = -2 }) --为了兼容算法，
 		for i, tbRole in ipairs(tbSortPlayers) do
 			if tbRole.nSort ~= nLastSort then
 				local nCanTeamNum = math.floor(#tbSameSortRoles / nMaxTeamRoleNum)
 				for j = 1, nCanTeamNum do
 					local tbRoleIds = { unpack(tbSameSortRoles, (j - 1) * nMaxTeamRoleNum + 1, (j - 1) * nMaxTeamRoleNum + nMaxTeamRoleNum) };
 					local teamData = self:TeamUp(tbRoleIds) 
 					if teamData then
		 				nCurTotalTeamNum = nCurTotalTeamNum + 1;
		 				tbHasTeams[teamData.nTeamID] = { tbRoles = tbRoleIds }
		 			else
		 				Log(debug.traceback())
		 			end
 				end
				for i3 = i - #tbSameSortRoles , i - #tbSameSortRoles - 1 + nCanTeamNum * nMaxTeamRoleNum  do
 					table.insert(tbNewTeamUpRoleIndex, i3)
 				end

 				tbSameSortRoles = { tbRole.dwRoleId }
 				nLastSort = tbRole.nSort;
 			else
 				table.insert(tbSameSortRoles, tbRole.dwRoleId)
 			end
 		end
 		table.remove(tbSortPlayers) --算法去掉最后多于的

 		--去掉刚组上队的
 		for i = #tbNewTeamUpRoleIndex,1, -1 do
 			table.remove(tbSortPlayers, tbNewTeamUpRoleIndex[i])
 		end
 	end

	--剩余的就直接3个一组进行组队。 边缘的其实是会影响到下个服的，应该还是要类似上面的再做次针对同服的3个一组。
	local nMaxLeftTeam = math.floor(#tbSortPlayers / nMaxTeamRoleNum) 
 	if nMaxLeftTeam > 0 then
 		for i = 1, nMaxLeftTeam do
 			local tbRoleIds = {};
 			for j = 1, nMaxTeamRoleNum do
 				table.insert(tbRoleIds, tbSortPlayers[(i - 1) * nMaxTeamRoleNum + j].dwRoleId)
 			end
 			local teamData = self:TeamUp(tbRoleIds) 
 			if teamData then
 				nCurTotalTeamNum = nCurTotalTeamNum + 1;
 				tbHasTeams[teamData.nTeamID] = { tbRoles = tbRoleIds }
 			else
 				Log(debug.traceback())
 			end
 		end
 	end

 	if nCurTotalTeamNum  >= tbDefine.nMinTeamNum then
 		local nMatchNum = math.ceil(nCurTotalTeamNum / tbDefine.nMaxTeamNum)
 		local nEveryMatchTeamNum = math.ceil(nCurTotalTeamNum / nMatchNum)
 		local tbMapIds = {}

 		for i = 1, nMatchNum do
 			local nMapId = CreateMap(tbDefine.nFightMapTemplateId);
 			self.tbCreateMapIngIds[nMapId] = self.tbReadyMapTypes[nReadyMapId];
 			table.insert(tbMapIds, nMapId)
 			self.tbInGamePlayers[nMapId] = { tbRoles = {}, tbTeams = {} }; 
 		end

 		local nIndex = 0
 		for dwTeamID, v in pairs(tbHasTeams) do
 			nIndex = nIndex + 1;
 			local nGameIndex = (nIndex - 1) % nMatchNum + 1;
	        local nMapId = tbMapIds[nGameIndex]
	        self.tbInGamePlayers[nMapId].tbTeams[dwTeamID] = 1;
	        local tbRoles = self.tbInGamePlayers[nMapId].tbRoles
	        for _, nPlayerId in ipairs(v.tbRoles) do
	        	tbRoles[nPlayerId]	= 1;
	        end
 		end
 	end
end

--组队匹配
function InDifferBattle:Active()
	for nReadyMapId,v in pairs(self.tbReadyMapTypes) do
		self:ActiveOneMap(nReadyMapId)
	end
end

function InDifferBattle:OnSyncTeamInfo(dwCaptainID, tbMember) --因为各个服的队伍id是自增加有可能重复的
	for i, nPlayerId in ipairs(tbMember) do
		self.tbOldTeamInfo[nPlayerId] = dwCaptainID;
	end
	self.tbOldTeamMembers[dwCaptainID] = tbMember

end

function InDifferBattle:OnAllReadyMapCreate()
	self.tbOldTeamInfo	 = {};
	self.tbOldTeamMembers = {};
	self.nActiveTimer =	Timer:Register(Env.GAME_FPS * tbDefine.MATCH_SIGNUP_TIME, function ()
		self:Active()
		self.nActiveTimer = nil; --不循环了
		if not next(self.tbCreateMapIngIds) then
			self:StopSignUp()
		end
	end)	
	self.nActiveTimerReady =  Timer:Register(Env.GAME_FPS * 3, self.UpdateReadyMapInfo, self)

	CallZoneClientScript(-1, "InDifferBattle:OnServerOnReadyMapCreate", self.tbReadyMapTypes);

	--随机生成这次的门派选择
	local tbRandomFactionGroup = {}
	for i=1,20 do
		local tbRandFaction = {};
		for j = 1,Faction.MAX_FACTION_COUNT do
			table.insert(tbRandFaction, j)
		end
		for j = 1,Faction.MAX_FACTION_COUNT do
			local nRand2 = MathRandom(Faction.MAX_FACTION_COUNT)
			tbRandFaction[j], tbRandFaction[nRand2] = tbRandFaction[nRand2], tbRandFaction[j]
		end
		table.insert(tbRandomFactionGroup, tbRandFaction)
	end
	self.tbRandomFactionGroup = tbRandomFactionGroup
	--队伍随机进房间的顺序，--先打乱房间的顺序，然后按队伍顺序放进房间就好了
	local tbRandomRoomIndex = {}
	for i = 1,tbDefine.nMaxRoomNum do
		table.insert(tbRandomRoomIndex, i)
	end
	for i = 1,tbDefine.nMaxRoomNum do
		local nRand2 = MathRandom(tbDefine.nMaxRoomNum)
		tbRandomRoomIndex[i], tbRandomRoomIndex[nRand2] = tbRandomRoomIndex[nRand2], tbRandomRoomIndex[i]
	end
	self.tbRandomRoomIndex = tbRandomRoomIndex
end

function InDifferBattle:OnReadyMapCreate(nReadyMapId)
	table.insert(self.tbReadyMapWaitIds, nReadyMapId)
	local nReadyMapNum = 0;
	for k,v in pairs(self.tbReadyMapTypes) do
		nReadyMapNum = nReadyMapNum + 1;
	end
	if #self.tbReadyMapWaitIds == nReadyMapNum then
		self:OnAllReadyMapCreate()
		self.tbReadyMapWaitIds = nil;
	end
end

function InDifferBattle:OnLoginReadyMap()
	local nTime = math.floor(Timer:GetRestTime(self.nActiveTimer) / Env.GAME_FPS);
	me.CallClientScript("Battle:EnterReadyMap", "InDifferBattle", {nTime, string.format("%d / %d", self.tbTotalPlayerNum[me.nMapId], tbDefine.nMaxTeamRoleNum * tbDefine.nMaxTeamNum)})
end

function InDifferBattle:OnEnterReadyMap(nMapId)
	self.tbTotalPlayerNum[nMapId] = self.tbTotalPlayerNum[nMapId] + 1;
	local nTime = math.floor(Timer:GetRestTime(self.nActiveTimer) / Env.GAME_FPS);
	me.CallClientScript("Battle:EnterReadyMap", "InDifferBattle", {nTime, string.format("%d / %d", self.tbTotalPlayerNum[nMapId], tbDefine.nMaxTeamRoleNum * tbDefine.nMaxTeamNum)})

	if not self.nActiveTimer then --之前结束匹配到 地图全部创建完之间的时间内已有组队信息的进来这样还是会自动组上原来队会有可能超3人
		return
	end

	-- 跨服进来，重新组队
	local nOldCaptainId = self.tbOldTeamInfo[me.dwID]
	if nOldCaptainId then
		local tbMemeber = self.tbOldTeamMembers[nOldCaptainId]
		for i,nPlayerId in ipairs(tbMemeber) do
			if nPlayerId ~= me.dwID then
				local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
				if pPlayer then
					if pPlayer.dwTeamID <= 0 then
						TeamMgr:Create(me.dwID, pPlayer.dwID, true);
					else
						local teamData = TeamMgr:GetTeamById(pPlayer.dwTeamID);
						local nCurCount = teamData:GetMemberCount()
						--队长出去再组人进来，之前的队员出去再进来，就会是同队长导致可能4人
						if nCurCount >= tbDefine.nMaxTeamRoleNum then 
							return
						end
						teamData:AddMember(me.dwID, true);
					end
					local _, x, y = pPlayer.GetWorldPos()
					me.SetPosition(x, y)
					break;
				end
			end
		end
	end
end

function InDifferBattle:OnLeaveReadyMap(nMapId)
	if not self.tbTotalPlayerNum then
		return
	end
	self.tbTotalPlayerNum[nMapId] = self.tbTotalPlayerNum[nMapId] - 1;
end

function InDifferBattle:OnBattleMapCreate(nMapId)
	local szBattleType = self.tbCreateMapIngIds[nMapId]
	assert(szBattleType)
	local tbInst = Lib:NewClass(InDifferBattle.tbBattleBase)
	self.tbMapInst[nMapId] = tbInst 
	tbInst:Init(nMapId, self.tbInGamePlayers[nMapId].tbTeams, szBattleType)
	tbInst:Start();
	local tbTeamMemrbName = {};
	for dwRoleId,v in pairs(self.tbInGamePlayers[nMapId].tbRoles) do
		local pPlayer = KPlayer.GetPlayerObjById(dwRoleId)
		if pPlayer then
			tbTeamMemrbName[pPlayer.dwTeamID] = tbTeamMemrbName[pPlayer.dwTeamID] or {};
			table.insert(tbTeamMemrbName[pPlayer.dwTeamID], string.format("「%s」",pPlayer.szName) )
			self.tbRoleZoneIndex[pPlayer.dwID] = pPlayer.nZoneIndex
			CallZoneClientScript(pPlayer.nZoneIndex, "InDifferBattle:OnPlayedBattle", pPlayer.dwID, szBattleType)
			pPlayer.SwitchMap(nMapId, 0,0);
		end
	end
	for dwTeamID,v in pairs(tbTeamMemrbName) do
		local szAllName = table.concat( v, "、")
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Team, "本次幻境隊伍成員：" .. szAllName, dwTeamID)
		ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Team, "請從右側隨機的6個門派中選擇門派。", dwTeamID)
	end
	self.tbCreateMapIngIds[nMapId] = nil;
	if not next(self.tbCreateMapIngIds) then
		self:StopSignUp();
		--如果有别的类型，则定时后面发
		for k,szBattleType in pairs(self.tbReadyMapTypes) do
			if szBattleType ~= "Normal" then
				local nTotalMatchTime = 0
				for _,v2 in ipairs(InDifferBattle.tbDefine.STATE_TRANS) do
					nTotalMatchTime = nTotalMatchTime + v2.nSeconds
				end
				Timer:Register(Env.GAME_FPS * (nTotalMatchTime + 10), function ()
					CallZoneClientScript(-1, "InDifferBattle:CheckSendQualifyWinnerNews", szBattleType)
				end)
				break;
			end
		end
		

	end
end

function InDifferBattle:SendQualifyBattleWinRoleIds(tbWinRoleList)
	CallZoneClientScript(-1, "InDifferBattle:OnSynQualifyBattleWinRoleIds", tbWinRoleList)
end

function InDifferBattle:GetAddImityData(bWin, tbRoleIds, tbTeamReportInfo)
	-- 对 v 里的roleID 进行 22匹配，然后用小的在前面的形式，再对应到2个id的最小的死亡阶段，胜利则为 12，其他无死亡阶段10
	 --期望结果，[roleid1][roleid2] = nImity
	local tbAddImitySetting = tbDefine.tbAddImitySetting
	table.sort( tbRoleIds, function (a, b)
		return a < b;
	end )
	local tbRetData = {}
	for i = 1, #tbRoleIds - 1 do
		local dwRoleId1 = tbRoleIds[i];
		tbRetData[dwRoleId1] = {};
		local nState1 = tbTeamReportInfo[dwRoleId1].nDeathState
		local nScore1 = tbAddImitySetting[nState1] or 0;

		for j = i + 1,#tbRoleIds do
			local dwRoleId2 = tbRoleIds[j];
			local nState2 = tbTeamReportInfo[dwRoleId2].nDeathState
			local nScore2 = tbAddImitySetting[nState2] or 0;		
			tbRetData[dwRoleId1][dwRoleId2] = math.min(nScore1, nScore2)
		end
	end
	return tbRetData;
end

--把下面的合并到一起吧，用到了 zoneIndex
function InDifferBattle:SendTeamAwardZ(dwTeamID, dwWinnerTeam, tbTeamReportInfo, nMatchTime, szBattleType)
	--先加亲密度， 确定有区服在一起的
	local tbZoneIndexRoles = {}; --[nZoneIndex] = {roleId1, roleId2}
	for dwRoleId,v in pairs(tbTeamReportInfo) do
		local nZoneIndex = self.tbRoleZoneIndex[dwRoleId]
		if nZoneIndex then
			tbZoneIndexRoles[nZoneIndex] = tbZoneIndexRoles[nZoneIndex] or {};
			table.insert(tbZoneIndexRoles[nZoneIndex], dwRoleId)
		end
	end
	local bWin = dwTeamID == dwWinnerTeam
	for nZoneIndex,v in pairs(tbZoneIndexRoles) do
		if #v >= 2 then
			local tbRetData = self:GetAddImityData(bWin, v, tbTeamReportInfo)
			CallZoneClientScript(nZoneIndex, "InDifferBattle:AddTeamImity", tbRetData)
		end
	end
	local nResult = bWin and  Env.LogRound_SUCCESS or Env.LogRound_FAIL;

	for dwRoleId,v in pairs(tbTeamReportInfo) do
		local nZoneIndex = self.tbRoleZoneIndex[dwRoleId]
		if not nZoneIndex then
			Log(debug.traceback(), dwRoleId)
		else
			self.tbRoleZoneIndex[dwRoleId] = nil; 
			CallZoneClientScript(nZoneIndex, "InDifferBattle:SendPlayerAwardS", dwRoleId, nResult, nMatchTime, v.nScore, v.nKillCount, szBattleType)		
		end
	end
end

function InDifferBattle:OnBattleMapDestory(nMapId)
	self.tbInGamePlayers[nMapId] = nil;
	if self.tbMapInst[nMapId] then
		self.tbMapInst[nMapId]:OnMapDestroy();
		self.tbMapInst[nMapId] = nil;
	end
end

function InDifferBattle:GiveMoneyTo(pPlayer, dwRoleId2, nMoney)
	local nMapId = pPlayer.nMapId
	local tbInst = self.tbMapInst[pPlayer.nMapId]
	if not tbInst then
		return
	end
	local pPlayer2 = KPlayer.GetPlayerObjById(dwRoleId2)
	if not pPlayer2 then
		return
	end
	if pPlayer.nFightMode == 2 then
		pPlayer.CenterMsg("您已陣亡，無法進行操作")
		return
	end
	if pPlayer2.nFightMode == 2 then
		pPlayer.CenterMsg("對方已陣亡，無法接受贈送")
		return
	end

	if pPlayer2.nMapId ~= nMapId then
		return
	end
	if pPlayer.dwTeamID == 0 or pPlayer.dwTeamID ~= pPlayer2.dwTeamID then
		return
	end
	local nRole1Money = pPlayer.GetMoney(tbDefine.szMonoeyType)
	if nMoney >  nRole1Money or nMoney <= 0 then
		return
	end

	if pPlayer.CostMoney(tbDefine.szMonoeyType, nMoney, Env.LogWay_InDifferBattle) then
		pPlayer2.SendAward({{tbDefine.szMonoeyType, nMoney}}, false, false, Env.LogWay_InDifferBattle)
		pPlayer2.Msg( string.format("獲得「%s」贈送的#987%d", pPlayer.szName, nMoney))
		pPlayer.CallClientScript("InDifferBattle:OnGiveMoneySuc")
	end
end

function InDifferBattle:OnNpcDeath(pNpc, pKiller)
	local tbInst = self.tbMapInst[pNpc.nMapId]
	if not tbInst then
		return
	end
	tbInst:OnNpcDeath(pNpc, pKiller)
end

function InDifferBattle:OnCreateChatRoom(dwTeamID, uRoomHighId, uRoomLowId) 
	local tbMembers = TeamMgr:GetMembers(dwTeamID)
	local nMemberId = tbMembers[1]
	if not nMemberId then
		return
	end
	local pMember = KPlayer.GetPlayerObjById(nMemberId)
	if not pMember then
		return
	end
	local tbInst = self.tbMapInst[pMember.nMapId]
	if tbInst then
		for i,nMemberId in ipairs(tbMembers) do
			local pMember = KPlayer.GetPlayerObjById(nMemberId)
			if pMember then
				ChatMgr:JoinChatRoom(pMember, 1) 
			end
		end
		return true
	end
end

local tbC2zRequestInstFunc = {
	ChooseFaction = 1;
	RequetMapInfo = 1;
	ShopBuy = 1;
	UseItem = 1;
	SellItem = 1;
	EnhanceEquip = 1;
	HorseUpgrade = 1;
	BookUpgrade = 1;
	RequestLeave = 1;
	UseEquip = 1;
	UnuseEquip = 1;
	UpdateNpcDmgInfo = 1;
	RequestTeamScore = 1;
}
function InDifferBattle:RequestInst(pPlayer, szFunc, ... )
	if not tbC2zRequestInstFunc[szFunc] then
		return
	end
	local tbInst = self.tbMapInst[pPlayer.nMapId]
	if not tbInst then
		return
	end
	tbInst[szFunc](tbInst, pPlayer, ...)
end

function InDifferBattle:SetupMapCallback()
	local fnOnCreate = function (tbMap, nMapId)
		self:OnBattleMapCreate(nMapId)
	end

	local fnOnDestory = function (tbMap, nMapId)
		self:OnBattleMapDestory(nMapId)
	end

	local fnOnEnter = function (tbMap, nMapId)
		local tbInst = self.tbMapInst[nMapId]
		if tbInst then
			tbInst:OnEnter()
		end
	end

	local fnOnLeave = function (tbMap, nMapId)
		local tbInst = self.tbMapInst[nMapId]
		if tbInst then
			tbInst:OnLeave()
		end
	end

	local fnOnPlayerTrap = function (tbMap, nMapId, szTrapName)
		local tbInst = self.tbMapInst[nMapId]
		if tbInst then
			tbInst:OnPlayerTrap(szTrapName)
		end
	end

	local fnOnMapLogin = function (tbMap, nMapId)
		local tbInst = self.tbMapInst[nMapId]
		if tbInst then
			tbInst:OnLogin()
		end
	end

	local tbMapClass = Map:GetClass(tbDefine.nFightMapTemplateId)
	tbMapClass.OnCreate = fnOnCreate;
	tbMapClass.OnDestroy = fnOnDestory;
	tbMapClass.OnEnter = fnOnEnter;
	tbMapClass.OnLeave = fnOnLeave;
	tbMapClass.OnPlayerTrap = fnOnPlayerTrap;
	tbMapClass.OnLogin = fnOnMapLogin;

	local fnOnReadyMapCreate = function (tbMap, nMapId)
		self:OnReadyMapCreate(nMapId)
	end 

	local fnOnEnterReadyMap = function (tbMap, nMapId)
		self:OnEnterReadyMap(nMapId)
	end 

	local fnOnLeaveReadyMap = function (tbMap, nMapId)
		self:OnLeaveReadyMap(nMapId)
	end 
	local fnOnLoginReadyMap = function (tbMap, nMapId)
		self:OnLoginReadyMap(nMapId)
	end 

	local tbReadyMap = Map:GetClass(tbDefine.nReadyMapTemplateId);	
	tbReadyMap.OnCreate = fnOnReadyMapCreate;
	tbReadyMap.OnEnter = fnOnEnterReadyMap
	tbReadyMap.OnLeave = fnOnLeaveReadyMap
	tbReadyMap.OnLogin = fnOnLoginReadyMap;
end


InDifferBattle:SetupMapCallback()