function ImperialTomb:SendSecretInvite(nMapType, pPlayer, szTitle)

	self.tbSecretInviteList[nMapType] = self.tbSecretInviteList[nMapType] or {}

	self.tbSecretInviteList[nMapType][pPlayer.dwID] = GetTime()

	pPlayer.CallClientScript("ImperialTomb:SecretInvite", nMapType, szTitle);

	Log("[Info]", "ImperialTomb", "SendSecretInvite", nMapType,  pPlayer.dwID, pPlayer.szName);
end

function ImperialTomb:SecretEnterRequest(pPlayer, nType)
	local tbPlayerList = self.tbSecretInviteList[nType];
	local nPlayerId = pPlayer.dwID

	if not tbPlayerList or not tbPlayerList[nPlayerId] then
		return false, "目標地圖無法傳送"
	end

	if math.abs(GetTime() - tbPlayerList[nPlayerId]) > self.SECRET_ROOM_INVITE_TIME_OUT then
		pPlayer.CenterMsg(XT("密室的入口已關閉，看來慢了一步，下次可得速速前去才是！"))
		tbPlayerList[nPlayerId] = nil
		return false, "目標地圖無法傳送"
	end

	if self:GetSecretPlayerCount(nType) >= self.SECRET_ROOM_MAX_PLAYER then
		pPlayer.CenterMsg(XT("密室通路已封鎖，恐怕是前往的人數過多，導致道路封閉"))
		return false, "目標地圖無法傳送"
	end

	local tbMapInfo = self.tbSecretMapList[self:GetSecretMapType(nType)];
	if not tbMapInfo then
		return false, "目標地圖無法傳送"
	end

	if not self:IsNormalMapByTemplate(pPlayer.nMapTemplateId)  then
		return false, "目標地圖無法傳送"
	end

	tbPlayerList[nPlayerId] = nil

	Map:SwitchMapDirectly(tbMapInfo.nMapId, tbMapInfo.nMapTemplateId);

	Log("[Info]", "ImperialTomb", "SecretEnterRequest Success", pPlayer.szName, pPlayer.dwID, tbMapInfo.nMapId, tbMapInfo.nMapTemplateId, tbMapInfo.nType);
end

function ImperialTomb:OnLeaderDeath(pNpc, tbDamageInfo, pKiller, tbPlayer)
	local nNpcMapId, _, _ = pNpc.GetWorldPos();
	local tbMapInfo = self.tbMapList[nNpcMapId];
	if not tbMapInfo then
		Log("[Error]", "ImperialTomb", "OnLeaderDeath Not Found Map Info", nNpcMapId, pNpc.nId)
		return
	end

	local nMapType = tbMapInfo.nType;

	if MathRandom(100000) > self.SECRET_ROOM_INVITE_RATE then
		--没有随机到
		Log("[Info]", "ImperialTomb", "OnLeaderDeath Not In Rate", tbMapInfo.nMapId, tbMapInfo.nMapTemplateId, tbMapInfo.nType, pNpc.nId)
		return
	end

	if self:GetSecretPlayerCount(nMapType) >= self.SECRET_ROOM_MAX_PLAYER then
		Log("[Info]", "ImperialTomb", "OnLeaderDeath Max Player Limit", tbMapInfo.nMapId, tbMapInfo.nMapTemplateId, tbMapInfo.nType, pNpc.nId)
		return
	end

	local szName = pNpc.szName;

	for _, tbPlayerInfo in pairs(tbPlayer) do
		local pPlayer = tbPlayerInfo.pPlayer;
		self:SendSecretInvite(nMapType, pPlayer, szName)
	end
	
	Log("[Info]", "ImperialTomb", "OnLeaderDeath End", tbMapInfo.nMapId, tbMapInfo.nMapTemplateId, tbMapInfo.nType,  pNpc.nId);
end

function ImperialTomb:SyncSecretRoomTime(pPlayer)

	if not pPlayer.nEnterSecretTime then
		return
	end

	pPlayer.CallClientScript("ImperialTomb:SyncSecretRoomTime", 
		math.max(0, self.SECRET_ROOM_STAY_TIME - math.abs(GetTime() - pPlayer.nEnterSecretTime)))
end

function ImperialTomb:SyncSecretRoomProtectTime(pPlayer)

	if not pPlayer.nEnterSecretTime then
		return
	end

	pPlayer.CallClientScript("ImperialTomb:SyncSecretRoomProtectTime", 
		math.max(0, self.PROTECT_TIME - math.abs(GetTime() - pPlayer.nEnterSecretTime)))
end

function ImperialTomb:SyncSecretRoomSpawnTime(pPlayer, nTime)
	pPlayer.CallClientScript("ImperialTomb:SyncSecretRoomSpawnTime", 
		nTime or (math.max(Timer:GetRestTime(self.nSecretSpawnTimer), 0) / Env.GAME_FPS))
end


function ImperialTomb:GetSecretPlayerCount(nMapType)
	local tbMapInfo = self.tbSecretMapList[self:GetSecretMapType(nMapType)]
	if not tbMapInfo then
		return 0
	end

	local _,nCount = KPlayer.GetMapPlayer(tbMapInfo.nMapId)

	return nCount;
end

function ImperialTomb:OnEnterSecretRoom(pPlayer)
	pPlayer.nEnterSecretTime = GetTime();
	pPlayer.SetPkMode(Player.MODE_PEACE);
end

function ImperialTomb:CheckSecretTime(pPlayer)
	local nNow = GetTime();
	if not pPlayer.nEnterSecretTime then
		pPlayer.nEnterSecretTime = nNow;
		return
	end

	if math.abs(nNow - pPlayer.nEnterSecretTime) >= self.SECRET_ROOM_STAY_TIME then

		local nTransMapId, nTransX, nTransY = self:GetDefaultPos(self:GetNormalMapType(self:GetMapType(pPlayer.nMapTemplateId)))
		if nTransMapId and (not self.bOpenEmperor or self.bOpenFemaleEmperor) then
			--秦始皇活动期间(女帝疑冢除外)如果离开需要直接离开秦陵
			pPlayer.SwitchMap(nTransMapId, nTransX, nTransY);
		else
			pPlayer.GotoEntryPoint();
		end
		return
	end

	if math.abs(nNow - pPlayer.nEnterSecretTime) >= self.PROTECT_TIME and pPlayer.nPkMode ~= Player.MODE_PK then
		pPlayer.SetPkMode(Player.MODE_PK);
	end
end

function ImperialTomb:SpawnSecret(nMapId, nMapType)
	local szLvlFrame = Lib:GetMaxTimeFrame(self.NPC_TIME_FRAME_LEVEL);
	local nLevel = nil
	if szLvlFrame then
		nLevel = self.NPC_TIME_FRAME_LEVEL[szLvlFrame]
	end

	if not nLevel then
		Log("[Error]", "ImperialTomb", "SpawnSecret Failed Not Found Level Config", nMapId)
		return
	end

	local tbPlayer, nCount = KPlayer.GetMapPlayer(nMapId)

	for _, pPlayer in pairs(tbPlayer) do
		local tbNpcInfo = self:TryGetRandomSecretNpc(nMapId, nMapType)
		if tbNpcInfo then
			local nTemplate = tbNpcInfo.nTemplate
			if type(nTemplate) == "table" then
				nTemplate = tbNpcInfo.nTemplate[nMapType]
			end

			for j=1,tbNpcInfo.nCount do
				local nX, nY = self:GetSecretRandomPos(tbNpcInfo.nPosType)
				if nX and nY then
					KNpc.Add(nTemplate, nLevel, 0, nMapId, nX, nY, 0);
				else
					Log("[Error]", "ImperialTomb", "SpawnSecret Random Pos nil")
					Lib:LogTB(tbNpcInfo)
				end
			end
		else
			Log("[Error]", "ImperialTomb", "SpawnSecret Random nil")
			Lib:LogTB(self.SECRET_ROOM_NPC)
		end

		self:SyncSecretRoomSpawnTime(pPlayer, self.SECRET_ROOM_SPAWN_INTERVAL)
	end
end

function ImperialTomb:GetSecretRandomPos(nPosType)
	local tbRangeList = self.SECRET_ROOM_POS[nPosType]
	if not tbRangeList then
		return
	end

	local tbRange = tbRangeList[MathRandom(#tbRangeList)];
	return MathRandom(tbRange[1][1], tbRange[2][1]), MathRandom(tbRange[1][2], tbRange[2][2])
end

function ImperialTomb:OnSpawnSecret()
	for nMapType, tbMapInfo in pairs(self.tbSecretMapList) do
		self:SpawnSecret(tbMapInfo.nMapId, tbMapInfo.nType)
	end

	return true
end

function ImperialTomb:CheckMapSameNpc(nMapId, nNpcTemplateId)
	local tbNpcList,_ = KNpc.GetMapNpc(nMapId)
	for _, pNpc in ipairs(tbNpcList) do
		if nNpcTemplateId == pNpc.nTemplateId then
			return true
		end
	end
end

function ImperialTomb:TryGetRandomSecretNpc(nMapId, nMapType, nTryCount)
	local nTryCount = nTryCount or 1
	if nTryCount > 50 then
		return
	end

	local tbNpcInfo, _ = Lib:GetRandomTable(self.SECRET_ROOM_NPC)
	if not tbNpcInfo then
		return
	end

	local nTemplate = tbNpcInfo.nTemplate
	if type(nTemplate) == "table" then
		nTemplate = tbNpcInfo.nTemplate[nMapType]
		--如果是首领，检查地图中是否还有没有击杀的首领
		if self:CheckMapSameNpc(nMapId, nTemplate) then
			return self:TryGetRandomSecretNpc(nMapId, nMapType, nTryCount + 1)
		end
	end

	return tbNpcInfo
end

function ImperialTomb:ClearPlayerSecretInvite(pPlayer)
	local bClear = false;
	for nMapType,tbMapInfo in pairs(self.tbNormalMapList) do
		local tbPlayerList = self.tbSecretInviteList[nMapType];
		if tbPlayerList then
			local nPlayerId = pPlayer.dwID
			if tbPlayerList[nPlayerId] then
				bClear = true
				tbPlayerList[nPlayerId] = nil
			end
		end
	end

	Log("[Info]", "ImperialTomb", "ClearPlayerSecretInvite Success", pPlayer.szName, pPlayer.dwID, tostring(bClear));
end

function ImperialTomb:ClearAllPlayerSecretInvite()
	for nMapId,_ in pairs(self.tbMapList) do
		local tbPlayer,_ = KPlayer.GetMapPlayer(nMapId)
		for _, pPlayer in ipairs(tbPlayer) do
			self:ClearPlayerSecretInvite(pPlayer)
			pPlayer.CallClientScript("Ui:RemoveNotifyMsg", "ImperialTombSecretInvite")
		end
	end
end
