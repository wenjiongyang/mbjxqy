if 1 then
	return
end

local nDebrisCacheDuraTime = 60 * 2;  --玩家的抢夺列表缓存时间 --TODO 玩家的索引直接存另一个表里想探索那样就不用缓存了
local CACHE_PLAYER_NUM = 120; 		  --缓存列表里的最大玩家数

Debris.tbAllCacheList = Debris.tbAllCacheList or {} --缓存的每个玩家的可抢夺列表 --nTimeOut, --[] tblist

-- nId = nItemId * 100 + nIndex

-- tbAllPlayer[nId][nHonorLevel][dwRoleId] = 1

-- tbAllCacheList[dwRoleId][nId] = {nTimeout =3232, tbList = {} }

local tbAllCacheList = Debris.tbAllCacheList
local tbEquipDebris = ValueItem.EqiupDebris; --记录装备的key 值

--完成一次的碎片抢夺
local fnFinishOneRobDebris = function (pPlayer)
	DegreeCtrl:ReduceDegree(pPlayer, "Debris", 1)
	EverydayTarget:AddCount(pPlayer, "Debris");
	LogD(Env.LOGD_ActivityPlay, pPlayer.szAccount, pPlayer.dwID, pPlayer.nLevel, nil, Env.LOGD_VAL_FINISH_TASK, Env.LOGD_MIS_DEBRIS, pPlayer.GetFightPower());
end

Debris.tbAllPlayer = Debris.tbAllPlayer or {};
Debris.tbAllAvoidRob = Debris.tbAllAvoidRob or {}  --[dwRoldID] = nEndTime

function Debris:OnStartup(tbAllAsync)
	if 1 then
		return
	end
	local nTimeNow = GetTime()
	local tbAllAvoidRob = self.tbAllAvoidRob
	for _, pAnsyPlayer in ipairs(tbAllAsync) do
		local dwRoleId = pAnsyPlayer.dwID;
		local nTop = pAnsyPlayer.GetTopDebris()
		if nTop ~= 0 then
			local nHonorLevel = pAnsyPlayer.GetHonorLevel()
			local nAnsyIndex = Debris.AysncTop1From
			for i = nTop, nTop - 1, -1 do
				local tbKindInfo = Debris.tbSettingLevel[i]
				for j, nItemId in ipairs(tbKindInfo.tbItems) do
					local nAnsyKey = nAnsyIndex + j
					local nVal = pAnsyPlayer.GetAsyncValue(nAnsyKey)
					if nVal ~= 0 then
						local tbBit = KLib.GetBitTB(nVal)
						for nIndex = 1 , tbKindInfo.nNum do
							if tbBit[nIndex] == 1 then
								self:AddPlayerPool(dwRoleId, nItemId, nHonorLevel, nIndex)
							end
						end
					end
				end
				nAnsyIndex = Debris.AysncTop2From
			end
		end

		--免战时间
		local nAvoidTime = pAnsyPlayer.GetDebrisAvoidTime();
		if nAvoidTime ~= 0 then
			if nAvoidTime > nTimeNow then
				tbAllAvoidRob[dwRoleId] = nAvoidTime
			else
				pAnsyPlayer.SetDebrisAvoidTime(0); --只是新设置免战时和启动服务器时改异步数据，其他时候直接用内存里的，不用到这
			end
		end
	end
end


function Debris:Active(nTimeNow)
	if 1 then
		return
	end
	-- 去除超时的玩家列表缓存
	for dwRoleId, v in pairs(tbAllCacheList) do
		for nId, tbInfo in pairs(v) do
			if nTimeNow > tbInfo.nTimeout then
				v[nId] = nil
			end
		end
		if not next(v) then
			tbAllCacheList[dwRoleId] = nil
		end
	end
	--遍历免战池
	local tbAvoidRob = self.tbAllAvoidRob
	for k,v in pairs(tbAvoidRob) do
		if nTimeNow > v then
			tbAvoidRob[k] = nil
		end
	end
end


--玩家头衔变化且有碎片时， 获得失去碎片时 ， 免战事件时，改变玩家池，由于强的是指定碎片
function Debris:AddPlayerPool(dwRoleId, nItemId, nHonorLevel, nIndex)
	if 1 then
		return
	end
	local nId = nItemId * 100 + nIndex
	local tbAllPlayer = self.tbAllPlayer
	if not tbAllPlayer[nId] then
		tbAllPlayer[nId]  = {}
	end

	for k,v in pairs(tbAllPlayer[nId]) do
		v[dwRoleId]	 = nil
	end

	if not tbAllPlayer[nId][nHonorLevel] then
		tbAllPlayer[nId][nHonorLevel] = {}
	end
	tbAllPlayer[nId][nHonorLevel][dwRoleId] = 1;
end

--	移除是移除一个道具下的所有碎片，因为该玩家该道具只有一个碎片了
function Debris:RemovePlayerPool(dwRoleId, nItemId, nNum, bOne)
	if 1 then
		return
	end
	local tbAllPlayer = self.tbAllPlayer
	if bOne then
		local nId = nItemId * 100 + nNum
		if  tbAllPlayer[nId] then
			for k, v in pairs(tbAllPlayer[nId]) do
				v[dwRoleId]	 = nil
			end
		end
		return
	end
	for i = 1, nNum do
		local nId = nItemId * 100 + i
		if  tbAllPlayer[nId] then
			for k, v in pairs(tbAllPlayer[nId]) do
				v[dwRoleId]	 = nil
			end
		end
	end
end

--玩家的头衔发现变化了去更新，是可能离线时对他检查发现的
function Debris:RefreshPlayerPool(dwRoleId)
	if 1 then
		return
	end
	local tbAllPlayer =  self.tbAllPlayer
	for nId, v1 in pairs(tbAllPlayer) do
		for nHonorLevel,v2 in pairs(v1) do
			v2[dwRoleId] = nil;
		end
	end
	--只有最高两档
	local pPlayer = KPlayer.GetPlayerObjById(dwRoleId)
	local pRoleStay =  KPlayer.GetRoleStayInfo(dwRoleId);
	local pAsyncData;
	if not pRoleStay then
		return
	end
	if not pPlayer then
		pAsyncData = KPlayer.GetAsyncData(dwRoleId)
		if not pAsyncData then
			return
		end
	end

	local nHonorLevel = pRoleStay.nHonorLevel

	if pAsyncData then
		local nTop = pAsyncData.GetTopDebris()
		for i = nTop -1, nTop do
			local tbKindInfo = Debris.tbSettingLevel[i]
			if tbKindInfo then
				for _, nItemId in ipairs(tbKindInfo) do
					local nValue = tbEquipDebris:GetAsyncValue(pAsyncData, nItemId)
					if nValue ~= 0 then
						local tbBit = KLib.GetBitTB(nValue)
						local tbHansIndexes = {}
						for nIndex = 1 , tbKindInfo.nNum do
							if tbBit[nIndex] == 1 then
								table.insert(tbHansIndexes, nIndex)
							end
						end
						if #tbHansIndexes > 1 then
							for nIndex, _ in ipairs(tbHansIndexes) do
								self:AddPlayerPool(dwRoleId, nItemId, nHonorLevel, nIndex)
							end
						end
					end
				end
			end
		end
	else
		local nTop, nTop2 = self:GetTopestKind(pPlayer)
		local tbAllDebris = tbEquipDebris:GetAllValue(pPlayer)
		for nItemId, _ in pairs(tbAllDebris) do --所有有值的 0是自动删除的
			local nKind = Debris.tbItemIndex[nItemId]
			if nKind == nTop or nKind == nTop2 then
				local tbHansIndexes = {};
				local tbKindInfo = Debris.tbSettingLevel[nKind]
				local nVal = tbEquipDebris:GetValue(pPlayer, nItemId)
				local tbBit = KLib.GetBitTB(nVal)
				for nIndex = 1 , tbKindInfo.nNum do
					if tbBit[nIndex] == 1 then
						table.insert(tbHansIndexes, nIndex)
					end
				end
				if #tbHansIndexes > 1 then
					for nIndex, _ in ipairs(tbHansIndexes) do
						self:AddPlayerPool(dwRoleId, nItemId, nHonorLevel, nIndex)
					end
				end

			end
		end
	end
	return true
end

--获取没有的碎片
function Debris:AddRandomDerisToPlayer(pPlayer, nItemId)
	local nKind = Debris.tbItemIndex[nItemId]
 	if not nKind then
 		return false, "非法操作2"
	end
	local tbKindInfo = Debris.tbSettingLevel[nKind]

	local tbNotHaveIndexs = {}
	local tbBit = KLib.GetBitTB(tbEquipDebris:GetValue(pPlayer, nItemId))
	for i = 1 , tbKindInfo.nNum do
		if tbBit[i] ~= 1 then
			table.insert(tbNotHaveIndexs, i)
		end
	end
	local nRandIndex = tbNotHaveIndexs[MathRandom(#tbNotHaveIndexs)]
	return self:AddDerisToPlayer(pPlayer, nItemId, nRandIndex)
end


--给玩家增加几号碎片 ，只能在线给，而且不要在玩家登陆时候给，不然同步异步数据时会出问题,
function Debris:AddDerisToPlayer(pPlayer, nItemId, nIndex)
	if nIndex <= 0 then
		return false, "非法操作1"
	end
	local nKind = Debris.tbItemIndex[nItemId]
 	if not nKind then
 		return false, "非法操作2"
	end

	local tbKindInfo = Debris.tbSettingLevel[nKind]
	if nIndex > tbKindInfo.nNum then
		return false, "非法操作3"
	end

	local nVal = tbEquipDebris:GetValue(pPlayer, nItemId, nIndex)
	if nVal == 1 then
		return false, "已經擁有了該碎片"
	end

	local bRet = tbEquipDebris:SetValue(pPlayer, nItemId, nIndex, 1)
	Log(string.format("Debris:AddDerisToPlayer PlayerId:%d, nItemId:%d, nIndex:%d", pPlayer.dwID, nItemId, nIndex))
	if not bRet then
		Log("failed Debris:AddDerisToPlayer ", pPlayer.dwID, nItemId, nIndex)
		return
	end

	--超过2个碎片才能抢
	local nHasNum = 0
	local tbBit = KLib.GetBitTB(tbEquipDebris:GetValue(pPlayer, nItemId))
	for i = 1 , tbKindInfo.nNum do
		if tbBit[i] == 1 then
			nHasNum = nHasNum + 1
		end
	end

	local bMerge;
	if nHasNum == tbKindInfo.nNum then
		--合成碎片
		bMerge = true;
		tbEquipDebris:SetValue(pPlayer, nItemId, nil, nil, 0)
		pPlayer.AddItem(nItemId, 1, nil, Env.LogWay_DebrisMerge)
		Debris:RemovePlayerPool(pPlayer.dwID, nItemId, tbKindInfo.nNum)
		Log(string.format("Debris:AddDeris Merged item PlayerId:%d, nItemId:%d, nIndex:%d", pPlayer.dwID, nItemId, nIndex))

	-- elseif nHasNum > 1 then
		--判断下是不是玩家的最高2T
		-- local nTop, nTop2 = Debris:GetTopestKind(pPlayer)
		-- if nKind == nTop2 or nKind == nTop then
		-- 	if nHasNum == 2 then
		-- 		--把前面获得的那一块碎片也加入
		-- 		for i = 1 , tbKindInfo.nNum do
		-- 			if tbBit[i] == 1 then
		-- 				self:AddPlayerPool(pPlayer.dwID, nItemId, pPlayer.nHonorLevel, i)
		-- 			end
		-- 		end
		-- 	else
		-- 		self:AddPlayerPool(pPlayer.dwID, nItemId, pPlayer.nHonorLevel, nIndex)
		-- 	end
		-- end
	end

	-- pPlayer.CallClientScript("Debris:RefreshMainPanel")
	return true, nil, bMerge;
end

--玩家身上最高的2个T
function Debris:GetTopestKind(pPlayer, bAnsyc)
	if 1 then
		return
	end
	if bAnsyc then
		local nTop = pPlayer.GetTopDebris()
		return nTop, nTop -1
	end
	local nTop = 0
	local tbAllDebris = tbEquipDebris:GetAllValue(pPlayer)
	for nItemId, _ in pairs(tbAllDebris) do --所有有值的 0是自动删除的
		if Debris.tbItemIndex[nItemId] >= nTop then
			nTop = Debris.tbItemIndex[nItemId];
		end
	end
	local nTop2 = nTop - 1
	if nTop2 < 1 then
		return 2, 1
	end
	return nTop, nTop2
end

--更新异步数据
function Debris:UpdataeAysncData(pPlayer, pAnsyPlayer)
	if 1 then
		return
	end
	--因为下次异步数据对应的道具是变化的 所以先全部清0
	for i = Debris.AysncTop1From, Debris.AysncTop1From + Debris.AysncKeyUse do
		pAnsyPlayer.SetAsyncValue(i, 0)
	end

	local nTop = self:GetTopestKind(pPlayer)
	pAnsyPlayer.SetTopDebris(nTop)

	local tbAllDebris = tbEquipDebris:GetAllValue(pPlayer)

	for i = nTop -1, nTop do
		local tbKindInfo = Debris.tbSettingLevel[i]
		for _, nItemId in ipairs(tbKindInfo.tbItems) do
			if tbAllDebris[nItemId] then
				tbEquipDebris:SetAsyncValue(pAnsyPlayer, nItemId, nil, nil, tbAllDebris[nItemId])
			end
		end
	end
end

--将离线异步数据设置到在线玩家身上, 登录时调用
function Debris:UpdateOnlineData(pPlayer, pAnsyPlayer)
	if 1 then
		return
	end
	local nTop = pAnsyPlayer.GetTopDebris() --无碎片的玩家
	if nTop <= 0 then
		return
	end

	local nAnsyIndex = Debris.AysncTop1From
	for i = nTop, nTop - 1, -1 do
		local tbKindInfo = Debris.tbSettingLevel[i]
		for j, nItemId in ipairs(tbKindInfo.tbItems) do
			local nAnsyKey = nAnsyIndex + j
			local nVal = pAnsyPlayer.GetAsyncValue(nAnsyKey)
			tbEquipDebris:SetValue(pPlayer, nItemId, nil, nil, nVal);
		end
		nAnsyIndex = Debris.AysncTop2From
	end

	--更新免战时间，离线时被抢时会加免战时间， 以异步为准 直接反算更新
	local nAvoidTime = self.tbAllAvoidRob[pPlayer.dwID]
	if nAvoidTime  then
		local nTimeNow = GetTime()
		if nAvoidTime > nTimeNow then
			local nShouldDuraTime = self:GetAvoidRobBeginTime(nAvoidTime, nTimeNow)
			pPlayer.SetUserValue(self.SAVE_GROUP, self.KEY_AVOID_DUR, nShouldDuraTime)
			pPlayer.SetUserValue(self.SAVE_GROUP, self.KEY_AVOID_BEGIN, nTimeNow)
		else
			self.tbAllAvoidRob[pPlayer.dwID] = nil;
		end
	end
end

--抢夺移除该玩家的装备碎片
function Debris:RemoveDerisFromPlayer(dwRoleId, nItemId, nIndex)
	if nIndex <= 0 then
		return false, "非法操作1"
	end
	local nKind = Debris.tbItemIndex[nItemId]
 	if not nKind then
 		return false, "非法操作2"
	end

	local tbKindInfo = Debris.tbSettingLevel[nKind]
	if nIndex > tbKindInfo.nNum then
		return false, "非法操作3"
	end

	local nVal = 0;
	local pPlayer = KPlayer.GetPlayerObjById(dwRoleId)
	local pAnsyPlayer = nil

	if pPlayer then
		nVal = tbEquipDebris:GetValue(pPlayer, nItemId, nIndex)
	else
		pAnsyPlayer = KPlayer.GetAsyncData(dwRoleId)
		if not pAnsyPlayer then
			Log("Error  Debris:RemoveDerisFromPlayer, dwRoleId ", dwRoleId)
			Debris:RemovePlayerPool(dwRoleId, nItemId, tbKindInfo.nNum)
			return false, "資料已經過期"
		end
		nVal = tbEquipDebris:GetAsyncValue(pAnsyPlayer, nItemId, nIndex)
	end

	if nVal ~= 1 then
		Debris:RemovePlayerPool(dwRoleId, nItemId, nIndex, true)
		return false, "無該道具碎片"
	end

	local nTop, nTop2;
	if pPlayer then
		nVal = tbEquipDebris:SetValue(pPlayer, nItemId, nIndex, 0)
		nTop, nTop2 = Debris:GetTopestKind(pPlayer)
	else
		nVal = tbEquipDebris:SetAsyncValue(pAnsyPlayer, nItemId, nIndex, 0)
		nTop, nTop2 = Debris:GetTopestKind(pAnsyPlayer, true)
	end
	if not nVal then
		Log("Error Debris:RemoveDerisFromPlayer set value", pPlayer, dwRoleId, nItemId, nIndex)
		return
	end
	Log(string.format("Debris:RemoveDerisFromPlayer PlayerId:%d, nItemId:%d, nIndex:%d", dwRoleId, nItemId, nIndex))

	if 1 then
		return true
	end

	--如果该碎片不是本身的top2 ， 就直接不操作 玩家池了，
	if nKind ~= nTop and nKind ~= nTop2 then
		return true
	end

	--改变碎片玩家池子
	if nVal == 0 then
		Debris:RemovePlayerPool(dwRoleId, nItemId, tbKindInfo.nNum)
		return true
	end

	local nHasNum = 0
	local tbBit = KLib.GetBitTB(nVal)
	for i = 1 , tbKindInfo.nNum do
		if tbBit[i] == 1 then
			nHasNum = nHasNum + 1
		end
	end
	if nHasNum < 2 then
		Debris:RemovePlayerPool(dwRoleId, nItemId, tbKindInfo.nNum)
	end
	if pPlayer then
		pPlayer.CallClientScript("Debris:RefreshMainPanel");
	end

	return true
end

--0 是npc
local function GetRandomList(tbList)
	--tbList  [nHonor] ={ id, id, id }   nHonor= -2. -1, 0, 1
	if not next(tbList) then
		return
	end

	local tbResult = {}
	local tbHonerLevel = {-2, -1, 0, 1}; --因为是缓存的就不记录实际头衔了，会变

	for i = 4, 1, -1 do
		local nHonorLevel = tbHonerLevel[i]
		if not tbList[nHonorLevel] then
			table.remove(tbHonerLevel, i)
		else
			local nRandomIdx = MathRandom(#tbList[nHonorLevel])
			table.insert(tbResult, tbList[nHonorLevel][nRandomIdx]);
		end
	end

	local nHasBlank = 4 - #tbHonerLevel
	--把上面的和起来吧，因为从玩家池里随机还要不能重复的
	if nHasBlank > 0 then
		local tbAllTogther = { }
		local tbForbit = {} --对于已经抽到的就不又显示一次了
		for i,dwRoleId in ipairs(tbResult) do
			tbForbit[dwRoleId] = 1
		end

		for _,  nHonorLevel in ipairs(tbHonerLevel) do
		 	for _, dwRoleId in ipairs(tbList[nHonorLevel]) do
		 		if not tbForbit[dwRoleId] then
		 			table.insert(tbAllTogther, dwRoleId)
		 		end
		 	end
		 end

		for i = 1, nHasBlank do
			if #tbAllTogther > 0 then
				local nRandomIndx = MathRandom(#tbAllTogther)
				table.insert(tbResult, tbAllTogther[nRandomIndx])
				table.remove(tbAllTogther, nRandomIndx)
			else
				table.insert(tbResult, 0)
			end
		end
	end

	table.insert(tbResult, 0)
	return tbResult
end

--c2s 接口
function Debris:GetRobList(pPlayer, nItemId, nIndex, bRefresh)
	if 1 then
		return
	end
	local tbRoleLists = self:GetMyRobList(pPlayer, nItemId, nIndex)
	if not tbRoleLists then
		tbRoleLists = {0,0,0,0,0}
	end
	local tbResult = {}
	for i,v in ipairs(tbRoleLists) do
		--客户端随机产生npc名字就好了
		if v == 0 then
			table.insert(tbResult, {dwID = 0})
		else
			local nMyHonorLevel = pPlayer.nHonorLevel
			local tbRole = KPlayer.GetRoleStayInfo(v)
			if not tbRole then
				Log("Warn Debris:GetRobList not exit role ", v, pPlayer.dwID)
				--可能缓存过期了
				tbAllCacheList[pPlayer.dwID] = nil
				table.insert(tbResult, {dwID = 0})
			else
				local nHonorMinus = tbRole.nHonorLevel - nMyHonorLevel
				if nHonorMinus > 1 or nHonorMinus < -2 then
					table.insert(tbResult, {dwID = 0})
					tbAllCacheList[pPlayer.dwID] = nil
					--更新那个人的
					self:RefreshPlayerPool(v)
				else
					table.insert(tbResult, tbRole)
				end
			end
		end
	end

	pPlayer.CallClientScript("Debris:SyncRobListData", tbResult, nItemId, nIndex)
end

--获取抢夺列表 ,抢指定道具的指定 碎片编号
function Debris:GetMyRobList(pPlayer, nItemId, nIndex)
	if 1 then
		return
	end
	local nTimeNow = GetTime();
	--现在如果是0 -10点时 直接返回
	local nTodaySecs = Lib:GetTodaySec(nTimeNow)
	if nTodaySecs <= 36000 then
		return
	end
	local dwRoleId = pPlayer.dwID;
	local nId = nItemId * 100 + nIndex
	local tbMyCache = tbAllCacheList[dwRoleId]
	if tbMyCache  then
		if tbMyCache[nId] then
			if tbMyCache[nId].nTimeout > nTimeNow then
				return 	GetRandomList(tbMyCache[nId].tbList)
			else
				tbAllCacheList[dwRoleId][nId] = nil
			end
		end
	end

	local tbAllPlayer = self.tbAllPlayer
	local tbItemPlayerInfo = tbAllPlayer[nId]
	if not tbItemPlayerInfo then
		return
	end

	local tbAllFriend = KFriendShip.GetFriendList(dwRoleId)
	local tbAllKinMembs = {}
	if pPlayer.dwKinId ~= 0 then
		tbAllKinMembs = Kin:GetKinMembers(pPlayer.dwKinId)
	end
	--获取该玩家的可搜素列表，并作为缓存
	-- local tbResultHonor = {} --注意cache里存的honor 是 -2，-1，0，1 这种
	local tbAvoidRob = self.tbAllAvoidRob
	local tbList = {}
	local nMyHonorLevel = pPlayer.nHonorLevel
	local tbHonerLevel = {-2, -1, 0, 1};
	for i = 4, 1, -1 do
		local nHonorMinus = tbHonerLevel[i]
		local nHonor = nMyHonorLevel + nHonorMinus
		if nHonor >= 0  and tbItemPlayerInfo[nHonor] and next(tbItemPlayerInfo[nHonor])  then
			local tbThiHonorList = {}

			for dwPlayerId, _ in pairs(tbItemPlayerInfo[nHonor]) do
				if #tbThiHonorList > CACHE_PLAYER_NUM then
					break;
				end
				if dwPlayerId ~= dwRoleId and not tbAllFriend[dwPlayerId] and not tbAllKinMembs[dwPlayerId] then
					if not tbAvoidRob[dwPlayerId] or (nTimeNow > tbAvoidRob[dwPlayerId]) then
						table.insert(tbThiHonorList, dwPlayerId)
					end
				end
			end
			if #tbThiHonorList > 0 then
				tbList[nHonorMinus]	= tbThiHonorList
			end
		end
	end

	--缓存下来
	tbAllCacheList[dwRoleId] = tbAllCacheList[dwRoleId] or {}
	tbAllCacheList[dwRoleId][nId] = {
		nTimeout = nTimeNow + nDebrisCacheDuraTime,
		tbList   = tbList,
	};

	return GetRandomList(tbList)
end

--免战 ,--对离线的玩家直接更改免战池，玩家上线时会做同步
function Debris:AvoidRob(dwRoleId, nAvoidTime)
	if 1 then
		return
	end
	if nAvoidTime <= 0 then
		Log("Debris:AvoidRob not accept time <= 0 ", nAvoidTime)
		return false, "非法操作5"
	end
	local tbAvoidRob = self.tbAllAvoidRob
	local nTimeNow = GetTime();
	local pPlayer = KPlayer.GetPlayerObjById(dwRoleId)
	local pASync =  KPlayer.GetAsyncData(dwRoleId);
	if not pASync then
		return false, "not has pAsyncData"
	end
	if not pPlayer then
		tbAvoidRob[dwRoleId] = nTimeNow + nAvoidTime
		pASync.SetDebrisAvoidTime(nTimeNow + nAvoidTime)
		return true
	end

	local nDuraTime = pPlayer.GetUserValue(Debris.SAVE_GROUP, Debris.KEY_AVOID_DUR)
	if nDuraTime >= 24* 3600 then
		return false, "開啟失敗，目前免戰時間超過了24小時"
	end

	local nBeginTime = pPlayer.GetUserValue(Debris.SAVE_GROUP, Debris.KEY_AVOID_BEGIN)

	-- local nLeftTime = Debris:GetAvoidRobLeftTime(nBeginTime, nDuraTime, nTimeNow)
	local nEndTime = Debris:GetAvoidRobEndTime(nBeginTime, nDuraTime)
	local nNewEndTime = 0

	if nEndTime <= nTimeNow then
		pPlayer.SetUserValue(Debris.SAVE_GROUP, Debris.KEY_AVOID_BEGIN, nTimeNow)
		pPlayer.SetUserValue(Debris.SAVE_GROUP, Debris.KEY_AVOID_DUR,  nAvoidTime)
		nNewEndTime = Debris:GetAvoidRobEndTime(nTimeNow, nAvoidTime)
		--这时应该手动从玩家池中去掉该玩家
	else
		pPlayer.SetUserValue(Debris.SAVE_GROUP, Debris.KEY_AVOID_DUR,  nDuraTime + nAvoidTime)
		nNewEndTime = Debris:GetAvoidRobEndTime(nBeginTime, nDuraTime + nAvoidTime)
	end

	Log(string.format("Debris:AvoidRob role: %d, AddAviodTime:%d, nEndTime:%d", dwRoleId, nAvoidTime, nNewEndTime))

	--更改免战池
	tbAvoidRob[dwRoleId] = nNewEndTime
	pASync.SetDebrisAvoidTime(nNewEndTime)
	return true
end

--c2s 购买免战时间
function Debris:BuyDebrisAvoidRobTime(pPlayer, nIndex)
	if 1 then
		return
	end
	local tbBuyInfo = Debris.tbBuyAvoidRobSet[nIndex]
	if not tbBuyInfo then
		pPlayer.CenterMsg("非法操作1")
		return
	end

	--客户端查过一遍了，这里就直接扣除了
	if tbBuyInfo[1] == "item" then
		local nCost = pPlayer.ConsumeItemInAllPos(tbBuyInfo[3], tbBuyInfo[4], Env.LogWay_DebrisAvoidRob)
		if nCost < tbBuyInfo[4] then
			pPlayer.CenterMsg("非法操作2")
			return
		end
	elseif tbBuyInfo[1] == "Gold" then --其他货币
		local nCost = Lib.Calc:Link(pPlayer.nLevel, tbBuyInfo[3]);
		if pPlayer.GetMoney(tbBuyInfo[1] ) < nCost then
			pPlayer.CenterMsg("非法操作3")
			return
		end

		pPlayer.CostMoney(tbBuyInfo[1], nCost, Env.LogWay_DebrisAvoidRob)
	end

	local bRet, szMsg = self:AvoidRob(pPlayer.dwID, tbBuyInfo[2])
	if not bRet then
		pPlayer.CenterMsg(szMsg)
		return
	end

	pPlayer.CenterMsg("購買免戰時間成功")
	pPlayer.CallClientScript("Debris:RefreshMainPanel");
end

--停止玩家的免战 如抢夺成功之类的
function Debris:StopAvoidRob(pPlayer)
	if 1 then
		return
	end
	pPlayer.SetUserValue(Debris.SAVE_GROUP, Debris.KEY_AVOID_BEGIN, 0)
	pPlayer.SetUserValue(Debris.SAVE_GROUP, Debris.KEY_AVOID_DUR,  0)
	local tbAvoidRob = self.tbAllAvoidRob
	tbAvoidRob[pPlayer.dwID] = nil
	pPlayer.CallClientScript("Debris:RefreshMainPanel");
end

--显示翻牌界面，显示的时候就已经出结果了, 翻npc的牌子和翻玩家的牌子不一样， 翻npc的有个假的抢碎片
function Debris:ShowFlipCard(pPlayer, nItemId, nIndex, nFlipCardSetIndex, tbPlayerInfo)
	if 1 then
		return
	end
	local tbCardInfo = Debris.tbFipCardSetting[nFlipCardSetIndex]
	local nRand = MathRandom()
	local AwardInfo;
	for i, v in ipairs(tbCardInfo) do
		if nRand <= v.nProb then
			AwardInfo = v
			break
		end
	end

	if AwardInfo.Award == 0 then
		if not tbPlayerInfo then
			if nRand < AwardInfo.nProb / 2 then --当他是抢npc的碎片成功了
				--TODO客户端记住上次抢的npc名字
					local _,_,bMerge = self:AddDerisToPlayer(pPlayer, nItemId, nIndex)
					if bMerge then
						Achievement:AddCount(pPlayer, "Debris_2", 1)
					end
					Achievement:AddCount(pPlayer, "Debris_1", 1)
					LogD(Env.LOGD_ActivityAward, pPlayer.szAccount, pPlayer.dwID, pPlayer.nLevel, "FlipCard", "EquipDebris", nItemId, Env.LOGD_MIS_DEBRIS)
					pPlayer.CallClientScript("Debris:OpenFlipCard", true, nItemId, nIndex)
					return
			else
				--翻牌翻到了
				pPlayer.tbDerisFlipCardAward = { "EquipDebris", nItemId,  nIndex }
			end
		else
			--直接翻到了碎片
			pPlayer.tbDerisFlipCardAward = { "EquipDebris", nItemId,  nIndex }
		end
	else
		--直接翻出牌的操作
		pPlayer.tbDerisFlipCardAward = AwardInfo.Award
	end

	pPlayer.CallClientScript("Debris:OpenFlipCard", true, nil, nil, tbPlayerInfo);
end

--对npc的五连抢
function Debris:ShowFiveFlipCard(pPlayer, nItemId, nIndex, nFlipCardSetIndex)
	if 1 then
		return
	end
	local nMaxDegree = math.min(DegreeCtrl:GetDegree(pPlayer, "Debris"), 5)
	local tbCardInfo = Debris.tbFipCardSetting[nFlipCardSetIndex]
	local tbFinalAward = {}
	for i = 1, nMaxDegree do
		fnFinishOneRobDebris(pPlayer)
		local nRand = MathRandom()
		local AwardInfo;
		for i, v in ipairs(tbCardInfo) do
			if nRand <= v.nProb then
				AwardInfo = v
				break
			end
		end
		if AwardInfo.Award == 0 then
			table.insert(tbFinalAward, { "EquipDebris", nItemId,  nIndex })
			break
		else
			table.insert(tbFinalAward, AwardInfo.Award)
		end
	end
	pPlayer.SendAward(tbFinalAward, nil, nil, Env.LogWay_Debris)
	pPlayer.CallClientScript("Debris:OnGetDebrisMoreRobResult", tbFinalAward)
end


function Debris:GetCardAward(pPlayer)
	if 1 then
		return
	end
	local tbAward = pPlayer.tbDerisFlipCardAward
	if not tbAward then
		return
	end

	pPlayer.SendAward({tbAward}, nil, nil, Env.LogWay_Debris)
	pPlayer.CallClientScript("Debris:OnGetCardAward", tbAward);
	pPlayer.tbDerisFlipCardAward = nil
end

-- c2s
--抢指定玩家的指定碎片
function Debris:RobHim(pPlayer, dwRobId, nItemId, nIndex, nCount)
	if 1 then
		return
	end
	if nIndex <= 0 then
		pPlayer.CenterMsg("非法操作1")
		return
	end
	local nKind = Debris.tbItemIndex[nItemId]
 	if not nKind then
		pPlayer.CenterMsg("非法操作2")
 		return
	end

	local tbKindInfo = Debris.tbSettingLevel[nKind]
	if nIndex > tbKindInfo.nNum then
		pPlayer.CenterMsg("非法操作3")
		return
	end

	--次数判断
	local nDegree = DegreeCtrl:GetDegree(pPlayer, "Debris")
	if nDegree <= 0 then --购买的话客户端自己判断就好了
		pPlayer.CenterMsg("您的搶奪次數不足")
		return
	end

	if tbEquipDebris:GetValue(pPlayer, nItemId) == 0 then
		pPlayer.CenterMsg("必須要有一塊相關的碎片才能搶奪") --必须要有一块相关的碎片才能抢
		pPlayer.CallClientScript("Debris:RefreshMainPanel")
		return
	end

	--已有的碎片不能抢
	local nVal = tbEquipDebris:GetValue(pPlayer, nItemId, nIndex)
	if nVal == 1 then
		pPlayer.Msg("已經擁有了的碎片搶不了")
		return
	end

	--npc直接进翻牌
	if dwRobId == 0 then
		if nCount == 5 then
			Debris:ShowFiveFlipCard(pPlayer, nItemId, nIndex, tbKindInfo.nFlipCardSetIndex)
		else
			fnFinishOneRobDebris(pPlayer)
			Debris:ShowFlipCard(pPlayer, nItemId, nIndex, tbKindInfo.nFlipCardSetIndex)
		end


		return
	end

	local nId = nItemId * 100 + nIndex
	local dwMyId = pPlayer.dwID

	--刷新列表
	local fnCearList = function ()
		if tbAllCacheList[dwMyId] then
			tbAllCacheList[dwMyId][nId] = nil
		end
		Debris:GetRobList(pPlayer, nItemId, nIndex)
	end

	local pRoleStay = KPlayer.GetRoleStayInfo(dwRobId)
	if not pRoleStay then
		pPlayer.CenterMsg("您的數據過期了")
		fnCearList();
		return
	end

	--先判断对方是否免战
	local nTimeNow = GetTime()
	local tbAvoidRob = self.tbAllAvoidRob
	if tbAvoidRob[dwRobId] then
		if tbAvoidRob[dwRobId] > nTimeNow then
			pPlayer.CenterMsg("對方處於免戰期")
			fnCearList();
			return
		else
			tbAvoidRob[dwRobId] = nil
		end
	end

	--在检查下对方是不是自己的好友或者同家族
	if pPlayer.dwKinId ~= 0 and pPlayer.dwKinId == pRoleStay.dwKinId then
		pPlayer.CenterMsg("對方與你是同幫派成員")
		fnCearList()
		return
	end

	if FriendShip:IsFriend(dwMyId, dwRobId) then
		pPlayer.CenterMsg("對方與你是好友關係")
		fnCearList()
		return
	end

	--计算战斗胜率
	local bFightResult = FriendShip:FightWithHonor(pPlayer, pRoleStay) --
	if not bFightResult then
		fnFinishOneRobDebris(pPlayer)
		pPlayer.CallClientScript("Debris:OpenFlipCard", false, nil, nil, pRoleStay);
		return
	end
	--战胜了 再计算强的概率
	local nHonorMinus = pRoleStay.nHonorLevel - pPlayer.nHonorLevel
	bFightResult = MathRandom() <= (tbKindInfo.nRobProb * self:GetProbFactor(nHonorMinus))

	if not bFightResult then
		fnFinishOneRobDebris(pPlayer)
		Debris:ShowFlipCard(pPlayer, nItemId, nIndex, tbKindInfo.nFlipCardSetIndex, pRoleStay)
		return
	end

	-- 直接移除，移除失败，则说明数据过期， 注意如果
	local bRet, szMsg = Debris:RemoveDerisFromPlayer(dwRobId, nItemId, nIndex)
	if not bRet then
		pPlayer.CenterMsg(szMsg)
		fnCearList();
		return
	end

	Debris:StopAvoidRob(pPlayer)
	--给他增加免战时间
	--他肯定这时是不在免战期的，所以上线时设下他在 的免战就好了
	Debris:AvoidRob(dwRobId, tbKindInfo.nAvoidRobTime)

	fnFinishOneRobDebris(pPlayer)

	--增加碎片, 前面查过一遍了，应该不会失败
    local _,_,bMerge = Debris:AddDerisToPlayer(pPlayer, nItemId, nIndex) --todo 这里再加上产出的设置
	LogD(Env.LOGD_ActivityAward, pPlayer.szAccount, pPlayer.dwID, pPlayer.nLevel, "RobPlayer", "EquipDebris", nItemId, Env.LOGD_MIS_DEBRIS)
	if bMerge then
		Achievement:AddCount(pPlayer, "Debris_2", 1)
	end
	Achievement:AddCount(pPlayer, "Debris_1", 1)
	Achievement:AddCount(dwRobId, "DebrisRobbed_1", 1)

	--抢夺成功 ，仇恨操作
	local bEnemy, nHisHate = FriendShip:IsHeIsMyEnemy(dwMyId, dwRobId)
	local nAddHate = Debris:GetItemValue(nItemId) + FriendShip.nRobDebrisAddHate

	local nMinusHate = FriendShip:GetMinusHate(nAddHate, nHisHate);

	FriendShip:AddHate(pPlayer, pRoleStay,  - nMinusHate)
	if FriendShip:AddHate(pRoleStay, pPlayer,  nAddHate) then
		Player:SendNotifyMsg(dwRobId, {
			szType = "RobDebris",
			nTimeOut = GetTime() + 86400 * 15,
			nItemId = nItemId,
			nIndex = nIndex,
			dwID = pPlayer.dwID,
			})
	end

	pPlayer.CallClientScript("Debris:OpenFlipCard", bFightResult, nItemId, nIndex, pRoleStay)
end

