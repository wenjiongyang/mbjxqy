


local tbMapStepSetting = MapExplore.tbMapStepSetting
local tbMaspIndex = MapExplore.tbMaspIndex


local MAX_STEP = MapExplore.MAX_STEP
local MAX_SAME_ENEMY = MapExplore.MAX_SAME_ENEMY

local KIND_ENNEMY   = MapExplore.KIND_ENNEMY
-- local KIND_FUBEN    = MapExplore.KIND_FUBEN
local KIND_ITEM 	= MapExplore.KIND_ITEM
local KIND_COIN 	= MapExplore.KIND_COIN

local SAVE_GROUP 		   = 12
-- local KEY_LAST_FUBEN_DAY   = 7 --对应到上次探索出地宫的天数 ---不存客户端的
-- local KEY_LAST_FUBEN_COUNT = 8 --上次探索出地宫时对应的当天的探索次数
local KEY_EXPLORE_DAY 	   = 9 --上次探索的天数
-- local KEY_EXPLORE_COUNT	   = 10 --上次探索的那一天的次数 --因为次数可以购买所以不方便用degree来算今天用了多少次
-- local KEY_FUBEN_COUNT_TOTAL= 11 --总的探索次数,出现过地宫后就不更新了
------------------------

--遇敌池  [nMapTemplateId][nHonor][dwRoleId] =nIndex

MapExplore.tbAllEnemys = MapExplore.tbAllEnemys or {}
MapExplore.tbAllEnemysIndex = MapExplore.tbAllEnemysIndex or {} -- 遇敌池索引
MapExplore.tbNotUsedEnemyIndex = MapExplore.tbNotUsedEnemyIndex or {} -- 暂时不用的遇敌池索引，因为中间有被移除所以用这个
local tbAllEnemysIndex = MapExplore.tbAllEnemysIndex


function MapExplore:InitPlayers(tbAllAsync)
	local tbAllEnemys = self.tbAllEnemys
	local tbHonLevels = {0}
	for k,v in pairs(Player.tbHonorLevelSetting) do
		table.insert(tbHonLevels, k)
	end

	for nMapTemplateId, v  in pairs(tbMaspIndex) do
		tbAllEnemys[nMapTemplateId] = {}
		tbAllEnemysIndex[nMapTemplateId] = {}
		self.tbNotUsedEnemyIndex[nMapTemplateId] = {}

		for i,nHonorLevel in ipairs(tbHonLevels) do
			tbAllEnemys[nMapTemplateId][nHonorLevel]  = {}
			tbAllEnemysIndex[nMapTemplateId][nHonorLevel]  = {}
			self.tbNotUsedEnemyIndex[nMapTemplateId][nHonorLevel] = {}
		end
	end

	for _, pAnsyPlayer in ipairs(tbAllAsync) do
		local nMapTemplateId = pAnsyPlayer.GetMapExploreEnyMap()
		if nMapTemplateId ~= 0 and tbAllEnemys[nMapTemplateId] then
			local nHonorLevel = pAnsyPlayer.GetHonorLevel()
			table.insert(tbAllEnemysIndex[nMapTemplateId][nHonorLevel], pAnsyPlayer.dwID)
			tbAllEnemys[nMapTemplateId][nHonorLevel][pAnsyPlayer.dwID] = #tbAllEnemysIndex[nMapTemplateId][nHonorLevel];
		end
	end

	self.tbInMapExplorePlayers = {};
end

local fnGetToday = function ()
	return Lib:GetLocalDay(GetTime() - 3600 * 4 )
end

function MapExplore:AddEnemy(nMapTemplateId, nHonor, dwRoleId)
	--玩家只能存在于一个地图的遇敌池，所以先检查他在其他池子是否存在了
	self:RemoveEnemy(dwRoleId)
	local pAsync  = KPlayer.GetAsyncData(dwRoleId)
	if not pAsync then
		return
	end
	pAsync.SetMapExploreEnyMap(nMapTemplateId)

	local tbAllEnemys = self.tbAllEnemys

	--默认是插到最后的，中间有不用的index就放到中间
	local nCanUseIndex = next( self.tbNotUsedEnemyIndex[nMapTemplateId][nHonor] )
	if not nCanUseIndex then
		table.insert(tbAllEnemysIndex[nMapTemplateId][nHonor], dwRoleId)
		nCanUseIndex = #tbAllEnemysIndex[nMapTemplateId][nHonor]

	else
		self.tbNotUsedEnemyIndex[nMapTemplateId][nHonor][nCanUseIndex] = nil;
		tbAllEnemysIndex[nMapTemplateId][nHonor][nCanUseIndex] = dwRoleId
	end
	tbAllEnemys[nMapTemplateId][nHonor][dwRoleId]  = nCanUseIndex
end

function MapExplore:RemoveEnemy(dwRoleId)
	local pAsync  = KPlayer.GetAsyncData(dwRoleId)
	if pAsync then
		pAsync.SetMapExploreEnyMap(0)
	end
	for nMap, v in pairs(self.tbAllEnemys) do
		for nH, v2 in pairs(v) do
			if v2[dwRoleId] then
				-- 不能直接移除索引，不然后面的RoleId对应的Index 就都要往后移了 就直接记个对应索引不可用
				tbAllEnemysIndex[nMap][nH][ v2[dwRoleId] ] = 0 ;
				self.tbNotUsedEnemyIndex[nMap][nH][ v2[dwRoleId] ] = 1;
				v2[dwRoleId] = nil
				break;
			end
		end
	end
end

--申请进入某一张地图的地图探索
function MapExplore:RequestExplore(pPlayer, nMapTemplateId)
	if not tbMaspIndex[nMapTemplateId] then
		return false, "沒有這張地圖探索設置"
	end

	if DegreeCtrl:GetDegree(pPlayer, "MapExplore") <= 0 then
		return false, "次數已用盡"
	end

	local pPlayerNpc = me.GetNpc();
	local nResult = pPlayerNpc.CanChangeDoing(Npc.Doing.skill);
	if nResult == 0 then
		return false, "目前狀態不能參加";
	end

	if not AsyncBattle:CanStartAsyncBattle(pPlayer) then
		return false, "請在安全區域下參與活動"
	end

	if pPlayer.nLevel >= self.MAX_LEVEL then
		return false
	end

	--每天清空 他的探索
	local nToday = fnGetToday()
	local nLastUpdateDay = pPlayer.GetUserValue(SAVE_GROUP, KEY_EXPLORE_DAY)
	local dwRoleId = pPlayer.dwID
	local tbPlayerData = pPlayer.GetScriptTable("MapExplore")
	tbPlayerData.tbStepInfo = tbPlayerData.tbStepInfo or {}
	local tbPlayerStepInfo = tbPlayerData.tbStepInfo
	if nLastUpdateDay ~= nToday then
		for nMapTemplateId, v in pairs(tbPlayerStepInfo) do
			tbPlayerStepInfo[nMapTemplateId] = 0;
		end

		tbPlayerData.tbResetInfo = {};
	end

	local nStep = tbPlayerStepInfo[nMapTemplateId]
	if not nStep then --user 保存上，userdata 没保存上 或者当天新加地图时
		 tbPlayerStepInfo[nMapTemplateId]  = 0
		 nStep = 0;

	end
	if nStep >= MAX_STEP then
		return false, "目前地圖已經探索完了"
	end

	if pPlayer.dwTeamID > 0 then
		local function fnQuitTeamAndRequestExplore()
			local pPlayer = KPlayer.GetPlayerObjById(dwRoleId)
			if not pPlayer then
				return
			end
			TeamMgr:QuiteTeam(pPlayer.dwTeamID, dwRoleId);
			self:RequestExplore(pPlayer, nMapTemplateId);
		end
		pPlayer.MsgBox("組隊狀態無法進入探索，是否退出目前隊伍？",
			{
				{"退出並進入", fnQuitTeamAndRequestExplore},
				{"取消"},
			})
		return;
	end

	pPlayer.EnterClientMap(nMapTemplateId, unpack(tbMapStepSetting[nMapTemplateId][nStep + 1]))

	pPlayer.CallClientScript("MapExplore:Begin", nMapTemplateId, nStep)
	pPlayer.nInMapExploreTemplate =  nMapTemplateId;--bInMapExplore
	self.tbInMapExplorePlayers[pPlayer.dwID] = GetTime()

	AssistClient:ReportQQScore(pPlayer, Env.QQReport_IsJoinExploreFuben, 1, 0, 1)
	return true
end

--从遇敌战斗回到探索地图
function MapExplore:ReEnterExplore(pPlayer)
	AsyncBattle:RequireLeaveBattle(pPlayer)
	local nMapTemplateId = pPlayer.nInMapExploreTemplate
	if not nMapTemplateId then
		return
	end
	local tbPlayerData = pPlayer.GetScriptTable("MapExplore")
	assert(tbPlayerData, pPlayer.dwID)
	local tbPlayerStepInfo = tbPlayerData.tbStepInfo
	assert(tbPlayerStepInfo, pPlayer.dwID)
	local nStep = tbPlayerStepInfo[nMapTemplateId]
	if not nStep then
		return
	end

	pPlayer.EnterClientMap(nMapTemplateId, unpack(tbMapStepSetting[nMapTemplateId][nStep + 1]))
	pPlayer.CallClientScript("MapExplore:Begin", nMapTemplateId, nStep)
end


--在地图上走一步 , 申请的时候次数就加上了
function MapExplore:MoveStep(pPlayer, nMapTemplateId, nPassStep)
	if not pPlayer.nInMapExploreTemplate then
		return
	end
	local dwRoleId = pPlayer.dwID
	local tbPlayerData = pPlayer.GetScriptTable("MapExplore")
	local tbPlayerStepInfo = tbPlayerData.tbStepInfo
	local nStep = tbPlayerStepInfo[nMapTemplateId]
	if nStep ~= nPassStep then
		pPlayer.CenterMsg("探索中~")
		return
	end
	if nStep >= MAX_STEP then
		pPlayer.CenterMsg("目前地圖已經探索完了")
		return
	end

	if not DegreeCtrl:ReduceDegree(pPlayer, "MapExplore", 1) then
		pPlayer.CenterMsg("次數已用盡")
		return
	end

	local nKind, nAwardId = self:GetRandKind(pPlayer, nMapTemplateId)
	if nKind == KIND_ENNEMY then
		nAwardId = self:GetEenemy(pPlayer, nMapTemplateId)
		if not nAwardId then --遇敌探空改成默认设置
			nKind, nAwardId = unpack(MapExplore.GET_NOTHING_SET)
		end
	end

	-- QQ会员加成
	if nKind == KIND_COIN then
		local nVipAddRate = 0;--pPlayer.GetQQVipInfo();
		local nRate = 1 + nVipAddRate;
		nAwardId = math.floor(nAwardId * nRate);
	end

	pPlayer.tbMapExploreFindInfo = {nKind, nAwardId}


	local nToday = fnGetToday()
	pPlayer.SetUserValue(SAVE_GROUP, KEY_EXPLORE_DAY, nToday)

    nStep = nStep + 1
	tbPlayerStepInfo[nMapTemplateId] = nStep

	if nKind == KIND_ENNEMY then
		self:FindEnemy(pPlayer, nMapTemplateId, nAwardId, nStep)
	else -- 随到道具 或银两 宝箱
		self:FindAward(pPlayer, nStep)
	end
	EverydayTarget:AddCount(pPlayer, "ExplorationFuben");
	Achievement:AddCount(pPlayer, "SearchFuben_1", 1)

	--LogD(Env.LOGD_ActivityPlay, pPlayer.szAccount, pPlayer.dwID, pPlayer.nLevel, string.format("%d_%d", nMapTemplateId, nStep), Env.LOGD_VAL_TAKE_TASK, Env.LOGD_MIS_EXPLOR, pPlayer.GetFightPower());
	Log("MapExplore:MoveStep find", dwRoleId, nMapTemplateId, nStep, nKind, nAwardId)
end


--前10次随机，如果一直没找到合适的就从 按顺序找到第一个
function MapExplore:GetEenemy(pPlayer, nMapTemplateId)
	local tbMapEnemys = tbAllEnemysIndex[nMapTemplateId]
	if not next(tbMapEnemys) then
		return
	end
	local nMyHonor = pPlayer.nHonorLevel
	local dwMyId = pPlayer.dwID
	local tbAllFriend = KFriendShip.GetFriendList(dwMyId)
	local tbAllKinMembs = {}
	if pPlayer.dwKinId ~= 0 then
		tbAllKinMembs = Kin:GetKinMembers(pPlayer.dwKinId)
	end
	tbAllFriend[dwMyId] = 1 --不让随到自己
	local tbMapExploreEnemyIds = pPlayer.tbMapExploreEnemyIds
	if tbMapExploreEnemyIds and next(tbMapExploreEnemyIds) then
		for dwRoleId, nCount in pairs(tbMapExploreEnemyIds) do
			if nCount >= MAX_SAME_ENEMY then
				tbAllFriend[dwRoleId] = 1
			end
		end
	end

	local nMyLevel = pPlayer.nLevel
	local nFromHonor = math.max(nMyHonor - 1, 0)
	local nToHonor = nMyHonor + 1
	for i = 1, 10 do
		local nHonorLevel = MathRandom(nFromHonor, nToHonor)
		local tbEnemy = tbMapEnemys[nHonorLevel]
		if tbEnemy and next(tbEnemy) then
			local nRandEnemy = tbEnemy[MathRandom(#tbEnemy)]
			if nRandEnemy ~= 0 and  not tbAllFriend[nRandEnemy] and not tbAllKinMembs[nRandEnemy] then
				local tbRoleInfo = KPlayer.GetRoleStayInfo(nRandEnemy)
				if tbRoleInfo and nMyLevel - tbRoleInfo.nLevel  < self.FIND_ENEMY_LEVEL then
					return nRandEnemy
				end
			end
		end
	end

	for nHonorLevel = nFromHonor, nToHonor do
		local tbEnemy = tbMapEnemys[nHonorLevel]
		if tbEnemy and next(tbEnemy) then
			for nIndex, dwRoleId in pairs(tbEnemy) do
				if  dwRoleId ~= 0 and not tbAllFriend[dwRoleId] and not tbAllKinMembs[dwRoleId] then
					local tbRoleInfo = KPlayer.GetRoleStayInfo(dwRoleId)
					if tbRoleInfo and nMyLevel - tbRoleInfo.nLevel  < self.FIND_ENEMY_LEVEL then
						return dwRoleId
					end
				end
			end
		end
	end

end

function MapExplore:FindEnemy(pPlayer, nMapTemplateId, dwEnemyId, nStep)
	local tbEnemyInfo = nil
	if dwEnemyId then
		tbEnemyInfo = KPlayer.GetRoleStayInfo(dwEnemyId)
		if tbEnemyInfo then
			pPlayer.tbMapExploreEnemyIds = pPlayer.tbMapExploreEnemyIds or {}
			pPlayer.tbMapExploreEnemyIds[dwEnemyId] = pPlayer.tbMapExploreEnemyIds[dwEnemyId] or 0
			pPlayer.tbMapExploreEnemyIds[dwEnemyId] = pPlayer.tbMapExploreEnemyIds[dwEnemyId] + 1; --对同一个人的遇敌次数

			if tbEnemyInfo.dwKinId ~= 0 then
				local memberData = Kin:GetMemberData(dwEnemyId);
				if memberData then
					tbEnemyInfo.szKinName = memberData:GetFullTitle()
				end
			end

		end
	end
	pPlayer.CallClientScript("MapExplore:OnFindEnemy", tbEnemyInfo, nStep)
end

function MapExplore:FindAward(pPlayer, nStep)
	pPlayer.CallClientScript("MapExplore:OnFindAward", nStep)		
end


--获取随机类型
function MapExplore:GetRandKind(pPlayer, nMapTemplateId)
	--初次探索前11次~20次必出地宫 ,以前没出过，

	local tbProb = tbMaspIndex[nMapTemplateId].tbProb
	local nRand = MathRandom()
	for i, v in ipairs(tbProb) do
		if nRand <= v[1] then
			return v[2], v[3]
		end
	end

end

function MapExplore:WalkEnd(pPlayer, nMapTemplateId)
	local dwRoleId = pPlayer.dwID
	local tbMapExploreFindInfo = pPlayer.tbMapExploreFindInfo
	if not tbMapExploreFindInfo then
		return
	end

	--如果是宝箱就直接拿到上面的奖励了
	local nKind, nAwardId = unpack(tbMapExploreFindInfo) --敌人时是敌人id
	if nKind == KIND_ITEM then
		pPlayer.SendAward({{"item", nAwardId, 1}}, nil, false, Env.LogWay_ExplorationFuben)
		pPlayer.CallClientScript("MapExplore:OnServerWalkEnd", nKind, nAwardId)

	elseif nKind == KIND_COIN then
		pPlayer.SendAward({{"Coin", nAwardId}}, nil, false, Env.LogWay_ExplorationFuben)
		pPlayer.CallClientScript("MapExplore:OnServerWalkEnd", nKind, nAwardId)

	elseif nKind == KIND_ENNEMY then
		if not nAwardId then
			pPlayer.CallClientScript("MapExplore:OnServerWalkEnd", nKind)

		else --有发现敌人的
			local tbRoleInfo = KPlayer.GetRoleStayInfo(nAwardId)
			pPlayer.nLastFubeEnmy  = nAwardId
			pPlayer.CallClientScript("MapExplore:OnServerWalkEnd", nKind, tbRoleInfo)

			Achievement:AddCount(pPlayer, "SearchFuben_2", 1)
		end
	else
		Log("Error IN MapExplore:WalkEnd",dwRoleId, nMapTemplateId, nKind, nAwardId)
	end

	pPlayer.tbMapExploreFindInfo = nil

	--放入遇敌池
	self:AddEnemy(nMapTemplateId, pPlayer.nHonorLevel, dwRoleId)
	LogD(Env.LOGD_ActivityPlay, pPlayer.szAccount, pPlayer.dwID, pPlayer.nLevel, nMapTemplateId, Env.LOGD_VAL_FINISH_TASK, Env.LOGD_MIS_EXPLOR, pPlayer.GetFightPower());
end

--攻击遇到的敌人
function MapExplore:AttackEnemy(pPlayer)
	local dwRoleId2 = pPlayer.nLastFubeEnmy
	if not dwRoleId2 then
		return
	end
	pPlayer.nLastFubeEnmy = nil
	local pAnsyPlayer2 = KPlayer.GetAsyncData(dwRoleId2)
	if not pAnsyPlayer2 then
		return
	end
	return self:DoAsyncAttackEnemy(pPlayer, pAnsyPlayer2, dwRoleId2)
end

function MapExplore:DoAsyncAttackEnemy(pPlayer, pAnsyPlayer2, dwRoleId2)
	if not pPlayer.SyncOtherPlayerAsyncData(dwRoleId2) then
		Log("FightWithAsync Sync him Player AsyncData Failed!!!", dwRoleId2)
		return;
	end

	local nBattleKey = GetTime()

	pPlayer.LeaveClientMap();

	if not AsyncBattle:CreateAsyncBattle(pPlayer, self.FIGHT_MAP, self.ENTER_POINT, "MapExploreAttack", dwRoleId2, nBattleKey, {dwRoleId2}) then
		Log("Error!! Enter AsyncAttackEnemy Map Failed!")
		return;
	end

	pPlayer.CallClientScript("MapExplore:CloseExplore");


	return true
end

--离开
function MapExplore:Leave(pPlayer)
	if pPlayer.nState ~= Player.emPLAYER_STATE_ALONE then
		return
	end
	pPlayer.tbMapExploreFindInfo = nil
	pPlayer.tbMapExploreEnemyIds = nil;
	pPlayer.nLastFubeEnmy = nil
	if pPlayer.LeaveClientMap() then  --如果从地宫进的 leave 会回到地宫
		if self.tbInMapExplorePlayers[pPlayer.dwID] then
			pPlayer.TLogRoundFlow(Env.LogWay_ExplorationFuben, pPlayer.nInMapExploreTemplate or 0, 0, GetTime() - self.tbInMapExplorePlayers[pPlayer.dwID] , Env.LogRound_SUCCESS, 0, 0);
			self.tbInMapExplorePlayers[pPlayer.dwID] = nil;	
		end
		pPlayer.CallClientScript("MapExplore:CloseExplore")
	end;
	pPlayer.nInMapExploreTemplate = nil;
end

--更新玩家的各个地图步数信息
function MapExplore:RequestUpdateMapExplore(pPlayer)
	local nToday = fnGetToday()
	local nLastUpdateDay = pPlayer.GetUserValue(SAVE_GROUP, KEY_EXPLORE_DAY)
	local tbStepInfo = {};
	local tbResetInfo = {};
	if nLastUpdateDay == nToday then
		local tbPlayerData = pPlayer.GetScriptTable("MapExplore") --包含重置信息
		tbStepInfo = tbPlayerData.tbStepInfo
		tbResetInfo = tbPlayerData.tbResetInfo
	end
	pPlayer.CallClientScript("MapExplore:ResponseUpdateMapExplore", tbStepInfo, tbResetInfo)
end

function MapExplore:RequestReset(pPlayer, nMapTemplateId)
	local nToday = fnGetToday()
	local nLastUpdateDay = pPlayer.GetUserValue(SAVE_GROUP, KEY_EXPLORE_DAY)
	if nToday ~= nLastUpdateDay then --没更新的话是不会出现重置请求的 重后就有2个table了
		pPlayer.CenterMsg("現不可重置探索")
		return 
	end

	local tbPlayerData = pPlayer.GetScriptTable("MapExplore")
	local bRet, szMsg = self:CanResetMap(nMapTemplateId, tbPlayerData.tbStepInfo, tbPlayerData.tbResetInfo)
	if not bRet then
		pPlayer.CenterMsg(szMsg)
		return
	end

	tbPlayerData.tbResetInfo[nMapTemplateId] = tbPlayerData.tbResetInfo[nMapTemplateId] or 0

	pPlayer.CostGold(self.RESET_COST, Env.LogWay_MapExploreReset, nil, self.RequestResetCallback, nMapTemplateId)
end

function MapExplore.RequestResetCallback(nPlayerId, bSucceed, szBillNo, nMapTemplateId)
	if not bSucceed then
		return false
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	if not pPlayer then
		return false
	end

	local nToday = fnGetToday()
	local nLastUpdateDay = pPlayer.GetUserValue(SAVE_GROUP, KEY_EXPLORE_DAY)
	if nToday ~= nLastUpdateDay then
		return false, "重置時間錯誤"
	end

	local tbPlayerData = pPlayer.GetScriptTable("MapExplore")

	DegreeCtrl:ReduceDegree(pPlayer, "MapExplorerReset", 1)

	--进行重置
	tbPlayerData.tbStepInfo[nMapTemplateId] = 0;
	tbPlayerData.tbResetInfo[nMapTemplateId] = tbPlayerData.tbResetInfo[nMapTemplateId] + 1

	pPlayer.CenterMsg("重置成功!")
	pPlayer.CallClientScript("MapExplore:ResponseUpdateMapExplore", tbPlayerData.tbStepInfo, tbPlayerData.tbResetInfo)
	return true
end

function MapExplore:OnAttackResult(pPlayer, nResult, tbBattleObj, dwRoleId2)
	local bAddHate, nRobJuBaoPen, nRobCoin, nMinusHate;
	if nResult == 1 then --成功
		--被打败的玩家从遇敌池子里去掉
		self:RemoveEnemy(dwRoleId2)
		bAddHate, nRobJuBaoPen, nRobCoin, nMinusHate = FriendShip:RobCoinAddHate(pPlayer, FriendShip.nMapExploreAddHate, dwRoleId2)
 		if bAddHate then
			Player:SendNotifyMsg(dwRoleId2, {
				szType = "MapExploreAttack",
				nTimeOut = GetTime() + 86400 * 15,
				dwID = pPlayer.dwID,
				nRobCoin = nRobCoin,
				nRobJuBaoPen = nRobJuBaoPen,
				})
 		end
 	end
 	local pRole2 = KPlayer.GetRoleStayInfo(dwRoleId2)
 	pPlayer.CallClientScript("MapExplore:OnClientAttackResult", nResult, pRole2, nMinusHate, nRobCoin)
end

AsyncBattle:ResgiterBattleType("MapExploreAttack", MapExplore, MapExplore.OnAttackResult, nil, MapExplore.FIGHT_MAP)
